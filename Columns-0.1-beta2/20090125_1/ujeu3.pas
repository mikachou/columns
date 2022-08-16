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
			ANbJoyaux : Integer;                {Nombre de joyaux collectés dans la partie}
			ANiveau : Integer;                  {Niveau de jeu courant}
			ATemps : Integer;                   {Temps écoulé avant que la pile ne tombe d'une case,
												si le joueur ne fait rien}
			ADebut : Boolean;					{vrai si la partie vient de commencer, faux dans le cas contraire}
			ATrtSpecial : Boolean;				{a "vrai" quand on fait un traitement spécial d'une pile
												qui n'est pas parvenue a entrer dans l'aire de jeu}
			function CalculeNiveau : Integer;
			function CalculeTemps : Integer;
			procedure Clavier;
			procedure Controle;
			procedure NbJoyauxAfficher;
			procedure AfficherNiveau;
			procedure PileCreer;
			procedure Apercu;
			procedure PileMouvement;
			procedure TraiterRestant (DP : pCDPile);
			function ChercheAlignements : Integer;
			function EliminerJoyaux : Boolean;
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
	New (ADAire, Creer (6, 13, 300, 50, 36, 1, True, 0, 7));
	New (ADAireAn, Init (ADAire));
	New (AApercu, Creer (250, 50, 3, 36, 1, 0));
	ANiveau := 0;
	ANbJoyaux := 0;
	ATemps := 1000;
	APerdu := False;
	ADebut := True;
	DrawString (50, 40, 'Joyaux : ');
	NbJoyauxAfficher;
	DrawString (50, 100, 'Niveau : ');
	AfficherNiveau;
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
{calcule le temps que mets une pile Ã  descendre d'une case (base=1000ms)}
function CJeu.CalculeTemps : Integer;
var
	T : Real;
begin
	T := 1000 * exp (ANiveau * ln (0.9));	{autrement dit T := 1000 * (0.9 *puissance* ANiveau)}
	CalculeTemps := Round (T)
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
		37 : ADPile^.AGauche;
		39 : ADPile^.ADroite;
		40 : if ADPile^.EstEntree then ADPile^.Tombe else ADPile^.Entre (3);
		38 : ADPile^.Change
	end;
end;

{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CJeu.Controle;
var
	T : Integer;
begin
	ResetTickCount;
	T := TickCount;
	repeat
		AEvenement := NewEvent;
		if (AEvenement = eKeyboard) and (ATombe) then Clavier;
	until (AEvenement = eQuit) or (not ATombe) or (TickCount - T >= ATemps)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{affichage du nombre de joyaux collectés}
procedure CJeu.NbJoyauxAfficher;
var
	NbS : string;         {chaine de caractère servant à afficher le nombre de joyaux glanés par le joueur}
begin
	Str (ANbJoyaux, NbS);
	DrawString (50, 60, NbS);
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
	DrawString (50, 120, NivS)
end;
{----------------------------------------------------------------------}


{----------------------------------------------------------------------}
procedure CJeu.PileCreer;
begin
	if ADebut then
		begin
			New (ADPile, Init (ADAire, 3, 6, 0));
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
	New (ADPileSuiv, Init (ADAire, 3, 6, 0));
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
procedure CJeu.PileMouvement;
begin
	repeat
		if ADPile^.EstEntree then
			ATombe := ADPile^.Tombe
		else
			ATombe := ADPile^.Entre (3);
		Controle;
	until (not ATombe) or (AEvenement = eQuit);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CJeu.TraiterRestant (DP : pCDPile);
var
	Restant : pCDPile;
	Col : Integer;
begin
	New (Restant, Restant (DP));
	Col := DP^.Colonne;
	Dispose (DP, Free);
	if EliminerJoyaux then
	begin
		repeat
		until (not EliminerJoyaux);
		repeat
		until (not Restant^.Entre (3));
		repeat
		until (not Restant^.Tombe);
		if not Restant^.EstEntree then
			TraiterRestant (Restant)
	end
	else
	begin
		Dispose (Restant, Free);
		APerdu := True;
	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{recherche des alignements de joyaux}
function CJeu.ChercheAlignements : Integer;
begin
	ChercheAlignements := ADAire^.Tester (3);
end;

{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CJeu.EliminerJoyaux : Boolean;
var
	n : Integer;				{variable servant à compter le nombre de joyaux éliminés}
begin
	n := ChercheAlignements;
	if n > 0 then
	begin
		ANbJoyaux := ANbJoyaux + n;
		EliminerJoyaux := True;
		ADAireAn^.Disparition;
		ADAireAn^.Effondrer;
		NbJoyauxAfficher;
		AfficherNiveau;
	end
	else
		EliminerJoyaux := False
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CJeu.Derouler;
begin
	repeat									{Cette boucle se répète...}
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
		if EliminerJoyaux then					{on élimine les éventuels joyaux alignés}
		begin
			repeat                                  {on élimine tous les joyayx jusqu'à ce qu'on ne puisse plus
													en éliminer}
			until not EliminerJoyaux;
			ATemps := CJeu.CalculeTemps				{on recalcule le temps écoulé pour qu'une pile avance d'une case}
		end;
		DrawString (10, 550, '           ');
	until (AEvenement = eQuit) or APerdu;   {... jusquà ce que le joueur quitte le jeu ou que
											la partie soit perdue}
	if APerdu then
	begin
		DrawString (50, 150, 'Perdu!');
		repeat
		until NewEvent = eQuit
	end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CJeu.Free;
begin
	Dispose (AApercu, Free);
	Dispose (ADAireAn, Free);
	Dispose (ADAire, Free)
end;
{----------------------------------------------------------------------}

end.
