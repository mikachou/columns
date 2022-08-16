Unit UMatrice;
{unit� de d�finition de l'aire jeu, d�nomm�e "Matrice"}

interface

uses
	UCellule;

const
	LMax = 50;	{Largeur maximale que peut prendre l'aire de jeu, en nombre de cases}
	HMax = 50;	{Hauteur maximale que peut prendre l'aire de jeu, en nombre de cases}
	
type
	TRangee	 = array[1..LMax] of pCCellule;	{une rang�e de LMax cellules, num�rot�es 1 � LMax}
	TCoordonnees = array[1..HMax] of TRangee;	{un ensemble de HMax rang�es, num�rot�es 0 � HMax}
	pCMatrice = ^CMatrice;
	CMatrice = object
		private
			ACellule : TCoordonnees;			{Cellule est un tableau de type TCoordonnees, autrement dit 
												un tableau � deux dimensions de pCCellule}
			AHauteur : Integer;					{Hauteur de la matrice, en nombre de cases}
			ALargeur : Integer;					{Largeur de la matrice, en nombre de cases}
		public
			constructor Init (Larg, Haut : Integer);
			function Cell_Occupee (Ligne, Colonne : Integer) : Boolean;
			procedure Cell_Assigne (Contenu : TContenu; Ligne, Colonne : Integer);
			procedure Cell_Transfert (Ligne1, Colonne1, Ligne2, Colonne2 : Integer);
			function Cell_Contenu (Ligne, Colonne : Integer) : TContenu;
			function Cell_Disparait (Ligne, Colonne : Integer) : Boolean;
			procedure Cell_FaireDisparaitre (Disp : Boolean; Ligne, Colonne : Integer);
			procedure Disparaissent;
			procedure Effondrer;
			function Hauteur : Integer;
			function Largeur : Integer;
			destructor free;
	end;
	
implementation

{----------------------------------------------------------------------}
{construction de la matrice : les cellules pr�sentes dans un carr� de AHauteur * ALargeur
sont cr��es, les cellules restantes pouvant servir � l'�laboration d'une matrice
(on peut cr�er ici une matrice 50 * 50 ne sont pas construites, le pointeur les d�signant
recevant la valeur nil}
constructor CMatrice.Init (Larg, Haut : Integer);	
var
	i, j : Integer;
begin
	ALargeur := Larg;
	AHauteur := Haut;
	for i := 1 to AHauteur do
	begin
		for j := 1 to ALargeur do
			New (ACellule[i,j], Init (i, j));
		for j := ALargeur + 1 to LMax do
			ACellule[i,j] := nil;
	end;
	for i := AHauteur + 1 to HMax do
		for j := 1 to LMax do
			ACellule[i,j] := nil
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{teste si une cellule de la matrice est occup�e : renvoie "vrai" si c'est
le cas, "faux" dans le cas contraire}
function CMatrice.Cell_Occupee (Ligne, Colonne : Integer) : Boolean;
begin
	Cell_Occupee := ACellule[Ligne,Colonne]^.Occupee;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Assigne un contenu � la cellule situ�e en (Ligne,Colonne) : couleur, ou Nul}
procedure CMatrice.Cell_Assigne (Contenu : TContenu; Ligne, Colonne : Integer);
begin
	ACellule[Ligne,Colonne]^.Assigne (Contenu)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{transfere le contenu de la cellule de coordonn�es (Ligne1, Colonne1)
dans la cellule de coordonn�es (Ligne2, Colonne2)}
procedure CMatrice.Cell_Transfert (Ligne1, Colonne1, Ligne2, Colonne2 : Integer);
begin
	ACellule[Ligne1,Colonne1]^.Transfert (ACellule[Ligne2,Colonne2])
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CMatrice.Cell_Contenu (Ligne, Colonne : Integer) : TContenu;
begin
	Cell_Contenu := ACellule[Ligne,Colonne]^.Contenu;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CMatrice.Cell_Disparait (Ligne, Colonne : Integer) : Boolean;
begin
	Cell_Disparait := ACellule[Ligne,Colonne]^.Disparait;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CMatrice.Cell_FaireDisparaitre (Disp : Boolean; Ligne, Colonne : Integer);
begin
	ACellule[Ligne,Colonne]^.FaireDisparaitre (Disp);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CMatrice.Disparaissent;
var
	Lin, Col : Integer;
begin
	for Col := 1 to ALargeur do
		for Lin := 1 to AHauteur do
			if Cell_Disparait (Lin, Col) then
				Cell_Assigne (Nul, Lin, Col)
end;


{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{effondrement des joyaux restant de la matrice dans les interstices n�s
de la disparition des joyaux}
procedure CMatrice.Effondrer;
var
	Col, Lin, i : Integer;
begin
	for Col := 1 to ALargeur do		{on teste les colonnes l'une apres l'autre}
	begin
		if Cell_Disparait (AHauteur, Col) then	{cas o� le joyau tout en haut disparait}
			Cell_Assigne (Nul, AHauteur, Col);
		for Lin := AHauteur - 1 downto 1 do		{cas o� un des joyaux d'une des (H - 1) premieres lignes
												disparait, c'est le joyau du dessus qui
												prend la place}
			if Cell_Disparait (Lin, Col) then
				for i := Lin to AHauteur - 1 do
					Cell_Transfert (i + 1, Col, i, Col)
	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie la hauteur de la matrice, en nombre de cases}
function CMatrice.Hauteur : Integer;
begin
	Hauteur := AHauteur
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie la largeur de la matrice, en nombre de cases}
function CMatrice.Largeur : Integer;
begin
	Largeur := ALargeur
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{destruction de la matrice : chaque cellule est d�truite individuellement}
destructor CMatrice.Free;	
var
	i, j : Integer;
begin
	for i := 1 to AHauteur do
		for j := 1 to ALargeur do
			Dispose (ACellule[i,j], Free);
end;
{----------------------------------------------------------------------}

end.
