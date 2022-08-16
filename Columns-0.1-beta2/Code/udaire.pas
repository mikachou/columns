Unit UDAire;
{dessine l'aire de jeu (matrice et éventuels joyaux) à un instant donné}
{animation de la disparition des joyaux et de l'effondrement de la matrice}

interface

uses
	UCellule, UMatrice, UDMatVid, UDJoy, UTest, WinAppli;

type
	TDRangee = array[1..LMax] of pCDJoyau;
	TDCoordonnees = array[1..HMax] of TDRangee;
	pCDAire = ^CDAire;
	CDAire = object
		private
			ADMatrice : pCDMatrice;
			ADCellule : TDCoordonnees;
		public
			constructor Init (Larg, Haut, X, Y, Cote, Esp : Integer; Grille : Boolean; Coul, ClGrille : TColor);
			constructor Creer (Larg, Haut, X, Y, Cote, Esp : Integer; Grille : Boolean; Coul, ClGrille : TColor);
			procedure Retourner;
			function Matrice : pCMatrice;
			function DMatrice : pCDMatrice;
			procedure Tester (n : Integer; var Vert, Horz, SONE, SENO : Integer);
			function Cell_Occupee (Lin, Col : Integer) : Boolean;
			function Cell_Contenu (Lin, Col : Integer) : TContenu;
			function Cell_Disparait (Lin, Col : Integer) : Boolean;
			function NbDisparaissant : Integer;
			procedure Disparaissent;
			procedure Effondrer;
			function Hauteur : Integer;
			function Largeur : Integer;
			function Couleur : TColor;
			function X0 : Integer;
			function Y0 : Integer;
			function HautPx : Integer;
			function LargPx : Integer;
			destructor Free;

	end;

implementation

{----------------------------------------------------------------------}
constructor CDAire.Init (Larg, Haut, X, Y, Cote, Esp : Integer; Grille : Boolean; Coul, ClGrille : TColor);
var
	i, j : Integer;
begin
	New (ADMatrice, Init (Larg, Haut, X, Y, Cote, Grille, Coul, ClGrille));
	for i := 1 to ADMatrice^.Hauteur do
	begin
		for j := 1 to ADMatrice^.Largeur do
		begin
			New (ADCellule[i,j], Init (ADMatrice, ADMatrice^.Cell_Contenu (i, j), i, j, Esp));
			Dispose (ADCellule[i,j], Free)
		end;
		for j := ADMatrice^.Largeur + 1 to LMax do
			ADCellule[i,j] := nil;
	end;
	for i := ADMatrice^.Hauteur + 1 to HMax do
		for j := 1 to LMax do
			ADCellule[i,j] := nil
end;
{----------------------------------------------------------------------}



{----------------------------------------------------------------------}
{initialise une aire de jeu et l dessine}
constructor CDAire.Creer (Larg, Haut, X, Y, Cote, Esp : Integer; Grille : Boolean; Coul, ClGrille : TColor);
begin
	CDAire.Init (Larg, Haut, X, Y, Cote, Esp, Grille, Coul, ClGrille);
	ADMatrice^.Dessiner
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{dessine l'aire et son contenu}
procedure CDAire.Retourner;
var
	i, j : Integer;
begin
	ADMatrice^.Dessiner;
	for i := 1 to ADMatrice^.Hauteur do
		for j := 1 to ADMatrice^.Largeur do
		begin
			New (ADCellule[i,j], Init (ADMatrice, ADMatrice^.Cell_Contenu (i, j), i, j, 1));
			if ADMatrice^.Cell_Contenu (i, j) <> nul then
				ADCellule[i, j]^.Dessiner;
			Dispose (ADCellule[i,j], Free);
		end;
end;
{----------------------------------------------------------------------}
{renvoie le pointeur de l'attribut matrice}
function CDAire.Matrice : pCMatrice;
begin
	Matrice := ADMatrice^.Matrice
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie le pointeur de l'attribut dmatrice}
function CDAire.DMatrice : pCDMatrice;
begin
	DMatrice := ADMatrice;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{recherche d'alignements de joyaux}
{renvoie le nombre de joyaux situés sur un alignements de n joyaux pour les
alignements de chaque type}
procedure CDAire.Tester (n : Integer; var Vert, Horz, SONE, SENO : Integer);
var
	Test : pCTest;
begin
	New (Test, Init (Matrice, n));
	Vert := Test^.Vertical;
	Horz := Test^.Horizontal;
	SONE := Test^.Diag_SONE;
	SENO := Test^.Diag_SENO;
	Dispose (Test, Free)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{teste l'occupation d'une cellule}
function CDAire.Cell_Occupee (Lin, Col : Integer) : Boolean;
begin
	Cell_Occupee := ADMatrice^.Cell_Occupee (Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Contenu d'une cellule}
function CDAire.Cell_Contenu (Lin, Col : Integer) : TContenu;
begin
	Cell_Contenu := ADMatrice^.Cell_Contenu (Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{True s'il est prévu que la cellule disparaisse, False dans le cas contraire}
function CDAire.Cell_Disparait (Lin, Col : Integer) : Boolean;
begin
	Cell_Disparait := ADMatrice^.Cell_Disparait (Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{compte le nombre de joyaux disparaissant en parcourant la matrice}
function CDAire.NbDisparaissant : Integer;
var
	Lin, Col, nb : Integer;
begin
	nb := 0;
	for Lin := 1 to ADMatrice^.Hauteur do
		for Col := 1 to ADMatrice^.Largeur do
			if Cell_Disparait (Lin, Col) then
				nb := nb + 1;
	NbDisparaissant := nb
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{assigne la valeur Nul aux cellules qui disparaissent}
procedure CDAire.Disparaissent;
begin
	ADMatrice^.Disparaissent
end;

{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{effondrement des joyaux de l'aire}
procedure CDAire.Effondrer;
begin
	ADMatrice^.Effondrer;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{hauteur de l'aire, en nombre de lignes}
function CDAire.Hauteur : Integer;
begin
	Hauteur := ADMatrice^.Hauteur
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{largeur de l'aire, en nombre de colonnes}
function CDAire.Largeur : Integer;
begin
	Largeur := ADMatrice^.Largeur;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{couleur (TColor) de l'aire de jeu (noire dans le cas qui nous occupe}
function CDAire.Couleur : TColor;
begin
	Couleur := ADMatrice^.Couleur;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{coordonnée X du coin supérieur gauche de l'aire de jeu}
function CDAire.X0 : Integer;
begin
	X0 := ADMatrice^.X0;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{coordonnée Y du coin supérieur gauche de l'aire de jeu}
function CDAire.Y0 : Integer;
begin
	Y0 := ADMatrice^.Y0;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Hauteur (en pixel) de l'aire de jeu}
function CDAire.HautPx : Integer;
begin
	HautPx := ADMatrice^.HautPx;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Largeur (en pixel) de l'aire de jeu}
function CDAire.LargPx : Integer;
begin
	LargPx := ADMatrice^.LargPx;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CDAire.Free;
var
	i, j : Integer;
begin
	Dispose (ADMatrice, Free);
end;
{----------------------------------------------------------------------}

end.
