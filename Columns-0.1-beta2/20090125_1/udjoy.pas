Unit UDJoy;
{Unité permettant de dessiner ou d'effacer des joyaux}

interface

uses
	UCellule, UDMatVid, WinAppli;

type
	pCDJoyau = ^CDJoyau;
	CDJoyau = object
		private
			AX1 : Integer;				{coordonnée X du coin superieur gauche du joyau dans la fenetre WinAppli}
			AY1 : Integer;				{coordonnée Y du coin superieur gauche du joyau dans la fenetre WinAppli}
			AX2 : Integer;				{coordonnée X du coin inférieur droit du joyau dans la fenetre WinAppli}
			AY2 : Integer;				{coordonnée Y du coin inférieur droit du joyau dans la fenetre WinAppli}
			ALigne : Integer;			{ligne sur laquelle se trouve le joyau dans la matrice}
			AColonne : Integer;			{colonne sur laquelle se trouve le joyau dans la matrice}
			ACote : Integer;			{longueur du côté d'un joyau, en pixels}
			ACouleur : TContenu;		{couleur du AJoyau, attribut de type TContenu}
			ADCouleur : TColor;			{couleur du joyau sur le dessin}
			ADMatrice : pCDMatrice;		{dessin de matrice dans lequel on va mettre le DJoyau}
			AEspace : Integer;			{espace séparant le bord du joyau au bord de la cellule, en pixel}
			function Couleur : TColor;
			function Dedans : Boolean;
		public
			constructor Init (DMatrice : pCDMatrice; Coul : TContenu; Lin, Col, Esp : Integer);
			procedure Dessiner;
			constructor Creer (DMatrice : pCDMatrice; Coul : TContenu; Lin, Col, Esp : Integer);
			procedure Effacer;
			procedure Blink;
			destructor Free;
			destructor Detruire;
	end;

implementation

{----------------------------------------------------------------------}
function CDJoyau.Couleur : TColor;
begin
	case ACouleur of
		Bleu   : Couleur := 1;
		Jaune  : Couleur := 14;
		Rouge  : Couleur := 12;
		Orange : Couleur := 11;
		Violet : Couleur := 5;
		Vert   : Couleur := 10;
		else Couleur := 0;		{valeur temporaire, pour cause de test...}
	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
constructor CDJoyau.Init (DMatrice : pCDMatrice; Coul : TContenu; Lin, Col, Esp : Integer);
begin
	ACouleur := Coul;
	ADCouleur := CDJoyau.Couleur;
	ALigne := Lin;
	AColonne := Col;
	ADMatrice := DMatrice;
	AEspace := Esp;
	ACote := DMatrice^.Cell_Cote - 2 * AEspace;
	{if Dedans then}							{le joyau est bien dans la matrice}
	begin
		AX1 := (AColonne - 1) * DMatrice^.Cell_Cote + DMatrice^.X0 + AEspace;
		AY1 := (DMatrice^.Hauteur - ALigne) * DMatrice^.Cell_Cote + DMatrice^.Y0 + AEspace;
		AX2 := AX1 + ACote;
		AY2 := AY1 + ACote;
	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDJoyau.Dedans : Boolean;
{vérifie que le joyau est bien dans la matrice}
begin
	Dedans := (ALigne >= 1) and (ALigne <= ADMatrice^.Hauteur) and (AColonne >= 1) and (AColonne <= ADMatrice^.Largeur);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDJoyau.Dessiner;
begin
	PenWidth (1);
	PenColor (ADCouleur);
	BrushColor (ADCouleur);
	if Dedans then							{le joyau est bien dans la matrice}
		DrawRect (AX1, AY1, AX2, AY2)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
constructor CDJoyau.Creer (DMatrice : pCDMatrice; Coul : TContenu; Lin, Col, Esp : Integer);
begin
	CDJoyau.Init (DMatrice, Coul, Lin, Col, Esp);
	CDJoyau.Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDJoyau.Effacer;
begin
	PenWidth (1);
	PenColor (ADMatrice^.Couleur);
	BrushColor (ADMatrice^.Couleur);
	if Dedans then							{le joyau est bien dans la matrice}
		DrawRect (AX1, AY1, AX2, AY2)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{provoque un 'blink' (éclair) à l'endroit du joyau}
procedure CDJoyau.Blink;
begin
	PenWidth (1);
	PenColor (15);
	BrushColor (15);
	if Dedans then							{le joyau est bien dans la matrice}
		DrawRect (AX1, AY1, AX2, AY2)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CDJoyau.Free;
begin
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CDJoyau.Detruire;
begin
	CDJoyau.Effacer
end;
{----------------------------------------------------------------------}

end.
