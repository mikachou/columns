Unit UDMatVid;
{Unité servant à dessiner une matrice sans les joyaux}

interface

uses
	UCellule, UMatrice, WinAppli;
	
type
	pCDMatrice = ^CDMatrice;
	CDMatrice = object
		private
			AMatrice : pCMatrice;		{matrice représentée}
			AHautPx : Integer;			{Hauteur de la matrice, exprimée en pixels}
			ALargPx : Integer;			{Largeur de la matrice, exprimée en pixels}
			AX0 : Integer;				{coordonnée X du coin supérieur gauche de la matrice}
			AY0 : Integer;				{coordonnée Y du coin supérieur gauche de la matrice}
			ACouleur : TColor;			{couleur du fond de la matrice}
			AClGrille : TColor; 		{couleur de la grille}
			ACell_Cote : Integer;		{côté d'une cellule, en pixels}
			AGrille : Boolean;			{présence ou non d'une grille dans le dessin de la matrice}
			procedure DessineGrille;
		public
			constructor Init (Larg, Haut, X, Y, Cote : Integer; Grille : Boolean; Coul, ClGrille : Tcolor);
			procedure Dessiner;
			constructor Creer (Larg, Haut, X, Y, Cote : Integer; Grille : Boolean; Coul, ClGrille : TColor);
			function Hauteur : Integer;
			function Largeur : Integer;
			function HautPx : Integer;
			function LargPx : Integer;
			function Couleur : TColor;
			function X0 : Integer;
			function Y0 : Integer;
			function Cell_Cote : Integer;
			function Cell_Occupee (Lin, Col : Integer) : Boolean;
			procedure Cell_Assigne (Contenu : TContenu; Lin, Col : Integer);
			procedure Cell_Transfert (Lin1, Col1, Lin2, Col2 : Integer);
			function Cell_Contenu (Lin, Col : Integer) : TContenu;
			function Cell_Disparait (Lin, Col : Integer) : Boolean;
			procedure Cell_FaireDisparaitre (Disp : Boolean; Lin, Col : Integer);
			procedure Disparaissent;
			procedure Effondrer;
			function Matrice : pCMatrice;
			destructor Free;
	end;

implementation

{----------------------------------------------------------------------}
constructor CDMatrice.Init (Larg, Haut, X, Y, Cote : Integer; Grille : Boolean; Coul, ClGrille : Tcolor);
begin
	New (AMatrice, Init (Larg, Haut));
	ACouleur := Coul;
	AClGrille := ClGrille;
	AX0 := X;
	AY0 := Y;
	ACell_Cote := Cote;
	AHautPx := AMatrice^.Hauteur * ACell_Cote;
	ALargPx := AMatrice^.Largeur * ACell_Cote;
	AGrille := Grille
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{dessine la grille de la matrice}
procedure CDmatrice.DessineGrille;
var
	i : Integer;
begin
	for i := 1 to AMatrice^.Largeur - 1 do
		DrawLine (AX0 + i * ACell_Cote, AY0, AX0 + i * ACell_Cote, AY0 + AHautPx);
	for i := 1 to AMatrice^.Hauteur - 1 do
		DrawLine (AX0, AY0 + i * ACell_Cote, AX0 + ALargPx, AY0 + i * ACell_Cote);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{dessine la matrice, et éventuellement une grille par l'appel de la
méthode privée CDMatrice.DessineGrille}
procedure CDMatrice.Dessiner;
begin
	PenWidth (1);
	PenColor (AclGrille);
	BrushColor (ACouleur);
	DrawRect (AX0, AY0, AX0 + ALargPx, AY0 + AHautPx);
	if AGrille then CDmatrice.DessineGrille
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Crée un dessin de matrice vide en initialisant ses attributs}
constructor CDMatrice.Creer (Larg, Haut, X, Y, Cote : Integer; Grille : Boolean; Coul, ClGrille : TColor);
begin
	CDMatrice.Init (Larg, Haut, X, Y, Cote, Grille, Coul, ClGrille);
	CDMatrice.Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Hauteur de la matrice, en nombre de cases}
function CDMatrice.Hauteur : Integer;
begin
	Hauteur := AMatrice^.Hauteur;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Largeur de la matrice, en nombre de cases}
function CDMatrice.Largeur : Integer;
begin
	Largeur := AMatrice^.Largeur;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Hauteur de la matrice en pixels}
function CDMatrice.HautPx : Integer;
begin
	HautPx := AHautPx;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Largeur de la matrice en pixels}
function CDMatrice.LargPx : Integer;
begin
	LargPx := ALargPx;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Longueur en pixels du coté d'une cellule de la matrice}
function CDMatrice.Cell_Cote : Integer;
begin
	Cell_Cote := ACell_Cote;
end;

{----------------------------------------------------------------------}
function CDMatrice.X0 : Integer;
begin
	X0 := AX0;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDMatrice.Y0 : Integer;
begin
	Y0 := AY0;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Couleur de la matrice}
function CDMatrice.Couleur : TColor;
begin
	Couleur := ACouleur;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDMatrice.Cell_Occupee (Lin, Col : Integer) : Boolean;
begin
	Cell_Occupee := AMatrice^.Cell_Occupee (Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDMatrice.Cell_Assigne (Contenu : TContenu; Lin, Col : Integer);
begin
	AMatrice^.Cell_Assigne (Contenu, Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDMatrice.Cell_Transfert (Lin1, Col1, Lin2, Col2 : Integer);
begin
	AMatrice^.Cell_Transfert (Lin1, Col1, Lin2, Col2)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDMatrice.Cell_Contenu (Lin, Col : Integer) : TContenu;
begin
	Cell_Contenu := AMatrice^.Cell_Contenu (Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDMatrice.Cell_Disparait (Lin, Col : Integer) : Boolean;
begin
	Cell_Disparait := AMAtrice^.Cell_Disparait (Lin, Col);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDMatrice.Cell_FaireDisparaitre (Disp : Boolean; Lin, Col : Integer);
begin
	AMatrice^.Cell_FaireDisparaitre (Disp, Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDMatrice.Disparaissent;
begin
	AMatrice^.Disparaissent;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDMatrice.Effondrer;
begin
	AMatrice^.Effondrer
end;
{----------------------------------------------------------------------}

function CDMatrice.Matrice : pCMatrice;
begin
	Matrice := AMatrice;
end;

{----------------------------------------------------------------------}
destructor CDMatrice.Free;
begin
	Dispose (AMatrice, Free)
end;
{----------------------------------------------------------------------}

end.
