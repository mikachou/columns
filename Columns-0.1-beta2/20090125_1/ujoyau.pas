Unit UJoyau;
{Unité de manipulation de l'objet "joyau". 
Le comportement d'un CJoyau a une incidence sur le contenu de la Matrice}

interface

uses
	UCellule, UMatrice;

type
	
	pCJoyau = ^CJoyau;
	CJoyau = object
		private
			ACouleur : TContenu;	{couleur du joyau}
			ALigne : Integer;		{ligne à l'intérieur de laquelle se trouve le joyau}
			AColonne : Integer;		{colonne à l'intérieur de laquelle se trouve le joyau}
			AMatrice : pCMatrice;	{matrice à l'intérieur de laquelle se meut le joyau}
			function Transfert (Lin, Col : Integer) : Boolean;
		public
			constructor Init (Coul : TContenu; Lin, Col : Integer; Matrice : pCMatrice);
			constructor Genere (NbCouleurs : Real; Lin, Col : Integer; Matrice : pCMatrice);
			function Couleur : TContenu;
			function Ligne : Integer;
			function Colonne : Integer;
			function Entre (Col : Integer) : Boolean;
			function EstEntre : Boolean;
			function Tombe : Boolean;
			function ADroite : Boolean;
			function AGauche : Boolean;
			procedure Assigne (Coul : TContenu);
			destructor Free;
	end;

implementation

{----------------------------------------------------------------------}
{Constructeur du joyau, initialise ses paramètres}
constructor CJoyau.Init (Coul : TContenu; Lin, Col : Integer; Matrice : pCMatrice);
begin
	ACouleur := Coul;
	ALigne := Lin;
	AColonne := Col;
	AMatrice := Matrice;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Fonction générant un TContenu (couleur) aléatoire en fonction d'un nombre
de couleurs déterminé}
function CouleurGenere (NbCouleurs : Real) : TContenu;
var
	C : Integer;
begin
	C := Round (Int (NbCouleurs * Random + 1));
	Case C of
		1 : CouleurGenere := Bleu;
		2 : CouleurGenere := Jaune;
		3 : CouleurGenere := Rouge;
		4 : CouleurGenere := Orange;
		5 : CouleurGenere := Violet;
		6 : CouleurGenere := Vert
	end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{constructeur initialisant un joyau avec une couleur aléatoire}
constructor CJoyau.Genere (NbCouleurs : Real; Lin, Col : Integer; Matrice : pCMatrice);
var
	Coul : TContenu;
begin
	Coul := CouleurGenere (NbCouleurs);
	CJoyau.Init (Coul, Lin, Col, Matrice)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Renvoie la valeur de l'attribut couleur du joyau}
function CJoyau.Couleur : TContenu;
begin
	Couleur := ACouleur;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Renvoie la valeur de l'attribut ligne du joyau}
function CJoyau.Ligne : Integer;
begin
	Ligne := ALigne
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Renvoie la valeur de l'attribut colonne du joyau}
function CJoyau.Colonne : Integer;
begin
	Colonne := AColonne
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{la fonction renvoie "vrai" si le joyau entre dans la matrice, "faux" dans le cas contraire.
Cette dernière possibilité se produira lorsqu'un joyau, tout en haut, empêchera physiquement le joyau d'entrer}
function CJoyau.Entre (Col : Integer): Boolean;
begin
	if AMatrice^.Cell_Occupee (AMatrice^.Hauteur, Col) then
		Entre := False
	else
	begin
		Entre := True;
		ALigne := AMatrice^.Hauteur;
		AColonne := Col;
		AMatrice^.Cell_Assigne (ACouleur, ALigne, AColonne)
	end;
end;		
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Méthode testant si un joyau est bien entré dans la matrice}
function CJoyau.EstEntre : Boolean;
begin
	EstEntre := (ALigne >= 1) and (ALigne <= AMatrice^.Hauteur)
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Teste la présence d'un joyau en (Ligne, Colonne) : s'il y a un joyau,
alors la fonction renvoie "faux", s'il n'y en a pas, le joyau est tranféré
en (Ligne, Colonne) et la fonction renvoie "vrai"}
function CJoyau.Transfert (Lin, Col : Integer) : Boolean;
begin
	if AMatrice^.Cell_Occupee (Lin, Col) then
		Transfert := False
	else
	begin
		AMatrice^.Cell_Transfert (ALigne, AColonne, Lin, Col);
		ALigne := Lin;
		AColonne := Col;
		Transfert := True;
	end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Teste le mouvement du joyau vers le bas (la cellule du dessous dans la 
matrice). Si la cellule du dessous a pour contenu Nul, alors il n'y a pas
de joyau en dessous, et le joyau tombe : la fonction renvoie "vrai". Dans
le cas contraire, ou alors s'il n'existe pas de cellule en dessous, elle 
renvoie "faux"}
function CJoyau.Tombe : Boolean;
begin
	if ALigne > 1 then {le joyau n'est pas sur la dernière ligne}
		Tombe := CJoyau.Transfert (ALigne - 1, AColonne)
	else 				{le joyau est sur la dernière ligne}
		Tombe := False
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CJoyau.ADroite : Boolean;
begin
	if (AColonne <> 0) and (AColonne < AMatrice^.Largeur) then
	{test AColonne <> 0 : on constate effectivement un bug sur les mouvements
	vers la droite lorqu'une pile entredans l'aire de jeu (plantage), en raison
	de la valeur initiale de AColonne vraisemblablement...}
		ADroite := CJoyau.Transfert (ALigne, AColonne + 1)
	else
		ADroite := False
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CJoyau.AGauche : Boolean;
begin
	if AColonne > 1 then
		AGauche := CJoyau.Transfert (ALigne, AColonne - 1)
	else
		AGauche := False
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Cette procédure sert à assigner une couleur (de type TContenu) à un joyau}
procedure CJoyau.Assigne (Coul : TContenu);
begin
	ACouleur := Coul;
	if CJoyau.EstEntre then
		AMatrice^.Cell_Assigne (ACouleur, ALigne, AColonne);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CJoyau.Free;
begin 
end;
{----------------------------------------------------------------------}
			
end.
