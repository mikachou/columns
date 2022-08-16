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
			ADCouleur : Integer;		{couleur du joyau sur le dessin}
			ADMatrice : pCDMatrice;		{dessin de matrice dans lequel on va mettre le DJoyau}
			AEspace : Integer;			{espace séparant le bord du joyau au bord de la cellule, en pixel}
			{function Couleur : TColor;}
			function Couleur : Integer;
			function Dedans : Boolean;
		public
			constructor Init (DMatrice : pCDMatrice; Coul : TContenu; Lin, Col, Esp : Integer);
			procedure Dessiner;
			constructor Creer (DMatrice : pCDMatrice; Coul : TContenu; Lin, Col, Esp : Integer);
			procedure Effacer;
			procedure Blink;
			procedure Explose (n : Integer);
			destructor Free;
			destructor Detruire;
	end;

implementation

{----------------------------------------------------------------------}
{function CDJoyau.Couleur : TColor;}
function CDJoyau.Couleur : Integer;		{on choisit un bitmap}
begin
	{les anciennes valeurs de Couleur (de type TColor) avant que les joyaux ne soient des bmp}
	{case ACouleur of
		Bleu   : Couleur := 1;
		Jaune  : Couleur := 14;
		Rouge  : Couleur := 12;
		Orange : Couleur := 11;
		Violet : Couleur := 5;
		Vert   : Couleur := 10;
		else Couleur := 0;}		{valeur temporaire, pour cause de test...}
	{end;}
	case ACouleur of
		Bleu   : begin LoadImage (1, 'BLEU'); Couleur := 1; end;
		Jaune  : begin LoadImage (2, 'JAUNE'); Couleur := 2; end;
		Rouge  : begin LoadImage (3, 'ROUGE'); Couleur := 3; end;
		Orange : begin LoadImage (4, 'ORANGE'); Couleur := 4; end;
		Violet : begin LoadImage (5, 'VIOLET'); Couleur := 5; end;
		Vert   : begin LoadImage (6, 'VERT'); Couleur := 6; end;
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
	if Dedans then							{le joyau est bien dans la matrice}
	{on calcule les coordonnées (x1,y1) du coin supérieur gauche et (x2,y2) du coin inférieur droit
	du dessin du joyau. Ceux ci sont fonction de la position de la taille de la matrice et du côté d'une de ses cellules,
	ainsi que d'une variable espace qui determine l'espace entre le coté de la cellule et le bord du joyau}
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
{dessine le joyau. DrawRect correspon à l'ancienne version sans bmp}
procedure CDJoyau.Dessiner;
begin
	{les commandes placées ci-dessous en commentaires sont celles de l'anciennes versions qui utilisait Drawrect}
	{PenWidth (1);
	PenColor (ADCouleur);
	BrushColor (ADCouleur);}
	if Dedans then							{le joyau est bien dans la matrice}
		{DrawRect (AX1, AY1, AX2, AY2)}
		PutImage (ADCouleur, AX1, AY1)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{initialisation + dessin d'un djoyau}
constructor CDJoyau.Creer (DMatrice : pCDMatrice; Coul : TContenu; Lin, Col, Esp : Integer);
begin
	CDJoyau.Init (DMatrice, Coul, Lin, Col, Esp);
	CDJoyau.Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{effacement d'un joyau}
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
	if Dedans then
		DrawRect (AX1, AY1, AX2, AY2)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{explosion du joyau : chacune des 7 images correspond à une étape de l'explosion}
procedure CDJoyau.Explose (n : Integer);
begin
	case n of
		1 : LoadImage (7, 'EXPL1');
		2 : LoadImage (7, 'EXPL2');
		3 : LoadImage (7, 'EXPL3');
		4 : LoadImage (7, 'EXPL4');
		5 : LoadImage (7, 'EXPL5');
		6 : LoadImage (7, 'EXPL6');
		7 : LoadImage (7, 'EXPL7');
	end;
	if Dedans then
		PutImage (7, AX1, AY1)
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
