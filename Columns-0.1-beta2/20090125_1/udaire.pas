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
			function Tester (n : Integer) : Integer;
			function Cell_Occupee (Lin, Col : Integer) : Boolean;
			function Cell_Contenu (Lin, Col : Integer) : TContenu;
			function Cell_Disparait (Lin, Col : Integer) : Boolean;
			procedure Disparaissent;
			procedure Effondrer;
			function Hauteur : Integer;
			function Largeur : Integer;
			function Couleur : TColor;
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
			ADCellule[i, j]^.Dessiner;
			Dispose (ADCellule[i,j], Free);
		end;
end;
{----------------------------------------------------------------------}
function CDAire.Matrice : pCMatrice;
begin
	Matrice := ADMatrice^.Matrice
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDAire.DMatrice : pCDMatrice;
begin
	DMatrice := ADMatrice;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{recherche d'alignements de joyaux}
function CDAire.Tester (n : Integer) : Integer;
var
	Test : pCTest;
begin
	New (Test, Init (Matrice, n));
	Tester := Test^.Faire;
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
function CDAire.Cell_Contenu (Lin, Col : Integer) : TContenu;
begin
	Cell_Contenu := ADMatrice^.Cell_Contenu (Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDAire.Cell_Disparait (Lin, Col : Integer) : Boolean;
begin
	Cell_Disparait := ADMatrice^.Cell_Disparait (Lin, Col)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}

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
function CDAire.Hauteur : Integer;
begin
	Hauteur := ADMatrice^.Hauteur
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDAire.Largeur : Integer;
begin
	Largeur := ADMatrice^.Largeur;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDAire.Couleur : TColor;
begin
	Couleur := ADMatrice^.Couleur;
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
