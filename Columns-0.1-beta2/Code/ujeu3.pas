Unit UJeu3;	{Unité de déroulement du jeu, 3ème version}

interface

uses
	UDAire, UDPile, UApercu, UDAireAn, WinAppli;

type
	pCJeu = ^CJeu;
	CJeu = object
		private
			ADAire : pCDAire;  					{l'aire de jeu}
			ADAireAn : pCDAireAn;				{gestion des animations dans l'aire de jeu}
			AApercu : pCApercu;                 {l'aperçu}
			ADPile : pCDPile;                   {la pile censée tomber}
			ADPileSuiv : pCDPile;				{la prochaine pile}
			ATombe : Boolean;                   {"vrai" si la pile tombe, "faux" dans le cas contraire}
			APerdu : Boolean;                   {si vrai, alors la partie est terminée et perdue}
			AEvenement : TEvent;                {Evènemenent INPUT}
			AVert : Integer;                    {nombre de joyaux alignés verticalement lors d'un test}
			AHorz : Integer;                    {-------------------------horizontalement-------------}
			ASONE : Integer;                    {-------------------------en diagonale----------------}
			ASENO : Integer;                    {-----------------------------------------------------}
			ANbJoyaux : Integer;                {Nombre de joyaux collectés dans la partie}
			ANbDisparaissant : Integer;			{Nombre de joyaux disparaissant lors d'une disparition}
			ANbReac : Integer;					{nombre de disparition au cours d'une réaction en chaîne}
			ANiveau : Integer;		                {Niveau de jeu courant}
			APointsMarques : LongInt;			{points marqués pendant une réaction en chaîne}
			AScore : LongInt;					{score du joueur}
			ATemps : Integer;                   {Temps écoulé avant que la pile ne tombe d'une case,
												si le joueur ne fait rien}
			ADebut : Boolean;					{vrai si la partie vient de commencer, faux dans le cas contraire}
			AQuit : Boolean;					{vrai si le joueur demande à quitter (quit box)}
			ATrtSpecial : Boolean;				{a "vrai" quand on fait un traitement spécial d'une pile
												qui n'est pas parvenue a entrer dans l'aire de jeu}
			ASon : Boolean;						{presence de son ou non}
			function CalculeNiveau : Integer;
			function CalculeTemps : Integer;
			function PointsMarques : LongInt;
			procedure Ecrire (Message : string; Longueur, X, Y : Integer);
			procedure Clavier;
			procedure Controle;
			procedure NbJoyauxAfficher;
			procedure AfficherNiveau;
			procedure AfficherPointsMarques;
			procedure EffacerPointsMarques;
			procedure AfficherScore;
			procedure Invitation;
			procedure PileCreer;
			procedure Apercu;
			procedure PileMouvement;
			procedure TraiterRestant (DP : pCDPile);
			procedure ChercheAlignements;
			function EliminerJoyaux (Restant : pCDPile; Col : Integer) : Boolean;
		public
			constructor Init;
			procedure Derouler;
			destructor Free;
	end;

implementation

{----------------------------------------------------------------------}
{initialisation des éléments du jeu : matrice, aperÃ§u de la prochaine pile}
constructor CJeu.Init;
begin
	LoadImage (1, 'INTRFCE');
	PutImage (1, 1, 1);
	LoadImage (10, 'GRILLE');
	PutImage (10, 276, 15);
	AQuit := False;
	{GetImage (10, ADAire^.X0, ADAire^.Y0, ADAire^.X0 + ADAire^.LargPx, ADAire^.Y0 + ADAire^.LargPx);}
	TextColor (Yellow);
	TextStyle ([Bold]);
	TextBkColor (Black);
	TextSize (25);
	ANiveau := 0;
	ANbJoyaux := 0;
	ANbDisparaissant := 0;
	ANbReac := 0;
	AScore := 0;
	ATemps := 1000;
	APerdu := False;
	ADebut := True;
	DrawString (120, 483, 'Joyaux');
	NbJoyauxAfficher;
	DrawString (120, 403, 'Niveau');
	AfficherNiveau;
	DrawString (120, 303, 'Score');
	AfficherScore;
	AVert := 0;
	AHorz := 0;
	ASENO := 0;
	ASONE := 0;
	ASon := False;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{pour calculer a^b (réel)}
function Puissance (a, b : Real) : Real;
begin
	Puissance := exp (b * ln (a));
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{détermination du niveau de jeu}
function CJeu.CalculeNiveau : Integer;
begin
	CalculeNiveau := ANbJoyaux div 20
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{calcule le temps que mets une pile à descendre d'une case (base=1000ms)}
function CJeu.CalculeTemps : Integer;
var
	T : Real;
begin
	{T := 1000 * exp (ANiveau * ln (0.9));}
	T := 1000 * Puissance (0.9, ANiveau);
	CalculeTemps := Round (T)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CJeu.PointsMarques : LongInt;
var
	PtsVert, PtsHorz, PtsDiag : LongInt;
begin
	{les points ajoutés au score sont fonction à la fois de la nature de l'alignement
	et du nombre de joyaux disparaissant. Lorsque trois joyaux disparaissent de l'aire de jeu
	chaque joyau situé dans un alignement vertical rapporte 10 points au joueur, si l'alignement
	est horizontal le joueur gagne 15 points, 20 point s'il est diagonal.
	Pour un joyaux en plus disparaissant dans toute l'aire de jeu, CHAQUE joyaux d'une alignement
	rapporte 5 point de plus. Par ailleurs un joyau présent sur deux types d'alignements à la fois
	(par exemple horizontal et diagonal) rapporte deux fois des points au score, une fois en tant
	qu'élément d'un alignement horizontal, une fois en tant qu'élément d'un alignement diagonal}
	PtsVert := (10 + 5 * (ANbDisparaissant - 3)) * AVert;
	PtsHorz := (15 + 5 * (ANbDisparaissant - 3)) * AHorz;
	PtsDiag := (20 + 5 * (AnbDisparaissant - 3)) * (ASONE + ASENO);

	PointsMarques := (Round (Puissance (4, ANbReac - 1))) * (PtsHorz + PtsVert + PtsDiag)
	{à chaque étape d'une réaction en chaine, les points marqués sonr multipliés par 4}
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{sert à afficher un message pour qu'il reste aligné sur sa droite
On indique la longueur totale du message, et la procédure crée un string
de la longueur désirée en ajoutant des espaces devant le message affiché}
procedure CJeu.Ecrire (Message : string; Longueur, X, Y : Integer);
var
	i, Diff : Integer;
	Esp : string;
begin
	Esp := '';
	Diff := Longueur - Length (Message);
	if Diff > 0 then
		for i := 1 to Diff do
			Esp := Esp + ' ';
	Message := Esp + Message;
	DrawString (X, Y, Message)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{gestion des évènements clavier pendant le jeu}
procedure CJeu.Clavier;
var
	Code : Integer;
begin
	GetKeyCode (Code);
	case Code of
		{flèche gauche}
		37 : if ADPile^.Colonne > 1 then ADPile^.AGauche;
		
		{flèche droite}
		39 : if ADPile^.Colonne < ADAire^.Largeur then ADPile^.ADroite;
		
		{bas}
		40 : if ADPile^.Ligne (1) > 1 then
				if ADPile^.EstEntree then
				begin
					if not (ADAire^.Cell_Occupee (ADPile^.Ligne (1) - 1, ADPile^.Colonne)) then
					begin
						ADPile^.Tombe;
						AScore := AScore + 1;
						AfficherScore
					end;
				end
				else
				begin
					ADPile^.Entre (3);
					AScore := AScore + 1
				end;
				
		{haut}
		38 : begin if ASon then ExecFile('SndRec32 /embedding /play SE7.wav'); ADPile^.Change end;
		
		{espace=pause}
		32 : repeat
				AEvenement := NewEvent;
				GetKeyCode (Code);
				if AEvenement = eQuit then AQuit := True
			until (Code = 32) or AQuit;
			
		{touche S}
		83 : ASon := not ASon;
	end;
end;

{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{gestion du contôle clavier}
procedure CJeu.Controle;
var
	T : Integer;
begin
	ResetTickCount;
	T := TickCount;
	repeat
		AEvenement := NewEvent;
		if (AEvenement = eKeyboard) and (ATombe) then Clavier
		else if AEvenement = eQuit then AQuit := True;
	until (AQuit) or (not ATombe) or (TickCount - T >= ATemps)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{affichage du nombre de joyaux collectés}
procedure CJeu.NbJoyauxAfficher;
var
	NbS : string;         {chaine de caractère servant à afficher le nombre de joyaux glanés par le joueur}
begin
	Str (ANbJoyaux, NbS);
	Ecrire (NbS, 3, 217, 519);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{affichage du niveau de jeu}
procedure CJeu.AfficherNiveau;
var
	NivS : string;
begin
	ANiveau := CalculeNiveau;
	Str (ANiveau, NivS);
	Ecrire (NivS, 2, 230, 439)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{à chaque disparition de joyaux dans l'aire de jeu des points sont marqués. 
Cette procédure affiche le nombre de points marqués à cette occasion}
procedure CJeu.AfficherPointsMarques;
var
	Coul : TColor;
	SPts : string;
begin
	Str (APointsMarques, SPts);
	case ANbReac of
		1 : Coul := LightMagenta;
		2 : Coul := LightGreen;
		3 : Coul := LightCyan;
		4 : Coul := Blue;
		5 : Coul := LightRed;
		else ; Coul := White;
	end;
	TextColor (Coul);
	TextStyle ([Bold]);
	TextBkColor (Black);
	TextSize (35);
	Ecrire (SPts, 5, 167, 227);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{on a besoin de lire le nombre de points marqués qu'à l'occasion de la disparion
après on efface ce nombre}
procedure CJeu.EffacerPointsMarques;
begin
	DrawString (167, 227, '     ');
	TextColor (Yellow);
	TextStyle ([Bold]);
	TextBkColor (Black);
	TextSize (25);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{affichage du score}
procedure CJeu.AfficherScore;
var
	ScoreS : string;
begin
	Str (ASCore, ScoreS);
	Ecrire (ScoreS, 8, 152, 339)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{invite le joueur à jouer en pressant la touche espace}
procedure CJeu.Invitation;
var
	T : LongInt;
	C : Integer;
begin
	ADebut := False;
	PutImage (10, 276, 15);
	DrawString (285, 250, 'Appuyez sur Espace');
	DrawString (310, 280, 'pour commencer');
	DrawString (285, 250, 'Appuyez sur Espace');
	DrawString (310, 280, 'pour commencer');
	{on affiche deux fois la phrase pour éviter un décalage inexpliqué entre les deux parties de la phrase}
	repeat
		AEvenement := NewEvent;
		if AEvenement = eKeyBoard then
		begin
			GetKeyCode (C);
			if C = 32 then
				ADebut := True;
			if C = 83 then
				ASon := not ASon;
		end;
		if AEvenement = eQuit then
			AQuit := True
	until ADebut or AQuit;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{crée une pile à mettre das l'aperçu, alors que la pile entrant dans
le jeu est celle affichée par l'aperçu précédemment}
procedure CJeu.PileCreer;
begin
	if ADebut then
		begin
			New (ADPile, Init (ADAire, 3, 6));
			ADebut := not ADebut
		end
	else
		begin
			if not ATrtSpecial then
				Dispose (ADPile, Free)
			else
				ATrtSpecial := False;
			ADPile := ADPileSuiv
		end;
	New (ADPileSuiv, Init (ADAire, 3, 6));
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{dessin de l'aperçu de la prochaine pile a entrer dans la matrice}
procedure CJeu.Apercu;
begin
	AApercu^.Dessiner (ADPileSuiv);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{mouvement d'une pile dans l'aire de jeu}
procedure CJeu.PileMouvement;
begin
	repeat
		if ADPile^.EstEntree then
			ATombe := ADPile^.Tombe
		else
			ATombe := ADPile^.Entre (3);
		Controle;
	until (not ATombe) or (AQuit);
	if ASon then
		ExecFile('SndRec32 /embedding /play SE4.wav');
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{cas d'une pile "restante" (cf doc)}
{une pile entre dans l'aire de jeu, mais toute la pile n'entre pas
(seulement un ou plusieurs joyaux), les autres dépassent.
Si au terme d'une réaction les autres joyaux peuvent rentrer, alors cette
pile "restante" intègre l'aire de jeu}
procedure CJeu.TraiterRestant (DP : pCDPile);
var
	Restant : pCDPile;
	Col : Integer;
begin
	New (Restant, Restant (DP));		
	{on crée une pile avec les restes de l'ancienne qui dépassent}
	Col := DP^.Colonne;
	Dispose (DP, Free);

	if EliminerJoyaux (Restant, Col) then			
	{si après une élimination de joyau la pile n'est pas entrée, on en recrée une restante
	(et ainsi de suite) = procédure récursive}
	begin
		if not Restant^.EstEntree then
			TraiterRestant (Restant)
		else
			repeat
			until (not EliminerJoyaux (nil, 0))
	end
	else
	begin
		{Dispose (Restant, Free);}
		APerdu := True;
	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{recherche des alignements de joyaux}
procedure CJeu.ChercheAlignements;
begin
	AVert := 0;
	AHorz := 0;
	ASENO := 0;
	ASONE := 0;
	ADAire^.Tester (3, AVert, AHorz, ASONE, ASENO);
end;

{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{processus d'élimination des joyaux}
function CJeu.EliminerJoyaux (Restant : pCDPile; Col : Integer) : Boolean;
begin
	ChercheAlignements;
	ANbDisparaissant := ADAire^.NbDisparaissant;
	if ANbDisparaissant > 0 then
	begin
		ANbReac := ANbReac + 1;
		ANbJoyaux := ANbJoyaux + ANbDisparaissant;
		EliminerJoyaux := True;
		APointsMarques := PointsMarques;
		AfficherPointsMarques;
		ADAireAn^.Disparition (ASon);
		ADAireAn^.Effondrer (Restant, Col);
		EffacerPointsMarques;
		AScore := AScore + APointsMarques;
		AfficherScore;
		NbJoyauxAfficher;
		AfficherNiveau;
	end
	else
		EliminerJoyaux := False
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CJeu.Derouler;
var
	n : Integer;							{on se servira de n pour compter le nombre d'itérations dans une réaction
											en chaîne}
begin
	repeat
		Invitation;
		APerdu := False;
		if not AQuit then
		begin
			New (ADAire, Creer (6, 13, 276, 15, 41, 1, True, 0, 7));
			New (ADAireAn, Init (ADAire, ASon));
			New (AApercu, Creer (219, 21, 3, 41, 1, 0));
			AScore := 0;
			ANbJoyaux := 0;
			ANiveau := 0;
			ATemps := 1000;
			NbJoyauxAfficher;
			AfficherNiveau;
			AfficherScore;
			repeat									{Cette boucle se répète...}
				ANbReac := 0;
				PileCreer;								{on créé la pile}
				Apercu;									{on affiche l'aperçu}
				PileMouvement;                          {la pile est déplacée dans la matrice}
				if not ADPile^.EstEntree then   		{si la pile n'entre pas on fait un traitement spécial
														(=procedure d'appel récursive)}
				begin
					ATrtSpecial := True;
					TraiterRestant (ADPile);
					ATemps := CJeu.CalculeTemps;
				end;
				if EliminerJoyaux (nil, 0) then					{on élimine les éventuels joyaux alignés}
				begin
					repeat                                  {on élimine tous les joyayx jusqu'à ce qu'on ne puisse plus
															en éliminer}
					until not EliminerJoyaux (nil, 0);
					ATemps := CJeu.CalculeTemps				{on recalcule le temps écoulé pour qu'une pile avance d'une case}
				end;
				if (not AQuit) and APerdu then				{cas où le joueur a perdu}
				begin
					ADAireAn^.Perdu (ASon);
					AApercu^.Effacer;
				end
			until (AQuit) or APerdu;   {... jusquà ce que le joueur quitte le jeu ou que
													la partie soit perdue}
		Dispose (ADAire, Free);
		Dispose (ADAireAn, Free);
		Dispose (AApercu, Free);
		end
	until AQuit
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CJeu.Free;
begin
end;
{----------------------------------------------------------------------}

end.
