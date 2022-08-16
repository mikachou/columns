Unit UDPile;	{unit� de gestion du d�placement d'une pile dans l'aire de jeu dessin�e}

interface

uses
	UCellule, UMatrice, UDMatVid, UPile, UDJoy, UDAire, WinAppli;
	
type
	pCDPile = ^CDPile;
	CDPile = object
		private
			APile : pCPile;								{Pile repr�sent�e}
			ADAire : pCDAire;							{DAire dans laquelle se meut la repr�sentation de la pile}
			ADJoyau : array[1..TaPileMax] of pCDJoyau;	{tableau des DJoyaux de la pile}
			ATombant : Boolean;
		public
			constructor Init (DA : pCDAire; Tail, NbCouleurs : Integer);
			constructor Restant (DPile :pCDPile);
			constructor Tombant (DA : pCDAire; limBas, Col, TaPile : Integer);
			procedure Dessiner;
			procedure Effacer;
			function Entre (Col : Integer) : Boolean;
			function Tombe : Boolean;
			function AGauche : Boolean;
			function ADroite : Boolean;
			procedure Change;
			function EstEntree : Boolean;
			function Taille : Integer;
			function DJoyau (n : Integer) : pCDJoyau;
			function Couleur (n : Integer) : TContenu;
			function Ligne (n : Integer) : Integer;
			function DAire : pCDAire;
			function Pile : pCPile;
			function Colonne : Integer;
			destructor Free;
	end;
	
implementation

{----------------------------------------------------------------------}
constructor CDPile.Init (DA : pCDAire; Tail, NbCouleurs : Integer);
begin
	ADAire := DA;
	ATombant := False;
	New (APile, Genere (ADAire^.Matrice, Tail, NbCouleurs));
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{ce constructor sert � initialiser une pile "restante" dont la nature un peu particuli�re
est expliqu�e dans la documentation
(voir unit� UJeu3 �galement, }
constructor CDPile.Restant (DPile :pCDPile);
begin
	ADAire := DPile^.DAire;
	ATombant := False;
	New (APile, Restant (DPile^.Pile))
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{les piles "tombantes" sont celles form�es � la suite de la disparition du joyau qui la soutenait
leur nature particuli�re est expliqu�e plus en d�tail dans la documentation 
(voir unit� UDAireAn �galement, proc�dure Effondrer et EffondreCreerPiles)}
constructor CDPile.Tombant (DA : pCDAire; limBas, Col, TaPile : Integer);
var
	DMat : pCDMatrice;
begin
	ADAire := DA;
	ATombant := True;
	New (APile, Tombant (ADAire^.Matrice, limBas, Col, TaPile));
end;
{----------------------------------------------------------------------}


{----------------------------------------------------------------------}
{dessin de la pile, les joyaux sont dessin�s l'un apr�s l'autre}
procedure CDPile.Dessiner;
var
	i : Integer;
begin
	for i := 1 to APile^.Taille do
		New (ADJoyau[i], Creer (ADAire^.DMatrice, APile^.Couleur (i), APile^.Ligne (i), APile^.Colonne, 1));
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{effacement de la pile, on met des rectangles de la couleur de la matrice sur les oyaux}
procedure CDPile.Effacer;
var
	i : Integer;
begin
	for i := 1 to APile^.Taille do
	begin
		ADJoyau[i]^.Effacer;
		Dispose (ADJoyau[i], Free);
	end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{vrai si la pile EST EN TRAIN d'entrer; faux si elle est deja entr�e, ou si elle
n'entre pas parce qu'elle est bloqu�e}
function CDPile.Entre (Col : Integer) : Boolean;
begin
	{Effacer;}
	Entre := APile^.Entre (Col);
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{vrai si la pile tombe; faux si elle est bloqu�e par quelque chose qui l'emp�che de tomber}
function CDPile.Tombe : Boolean;
var
	T : Integer;
begin
	if ATombant then
	begin
		ATombant := False;
		T := APile^.Taille;
		New (ADJoyau[T], Creer (ADAire^.DMatrice, APile^.Couleur (T), APile^.Ligne (T), APile^.Colonne, 1));
		ADJoyau[T]^.Effacer
	end
	else
		Effacer;
	Tombe := APile^.Tombe;
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{d�placer la pile � gauche}
function CDPile.AGauche : Boolean;
begin
	Effacer;
	AGauche := APile^.AGauche;
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{deplacer la pile � droite}
function CDPile.ADroite : Boolean;
begin
	Effacer;
	ADroite := APile^.ADroite;
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{changer l'ordre des joyaux dans la pile}
procedure CDPile.Change;
begin
	Effacer;
	APile^.Change;
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{vrai si la pile est deja entr�e, c'est � dire qu'elle n'essaie pas de rentrer}
function CDPile.EstEntree : Boolean;
begin
	EstEntree := APile^.EstEntree;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie la taille de la pile en nombre de joyaux}
function CDPile.Taille : Integer;
begin
	Taille := APile^.Taille;
end;
{---------------------------------------------------------------------}		

{----------------------------------------------------------------------}
{renvoie le piointeur du djoyau correspondant � la n-i�me position}
function CDPile.DJoyau (n : Integer) : pCDJoyau;
begin
	DJoyau := ADJoyau[n];
end;
{---------------------------------------------------------------------}

{---------------------------------------------------------------------}
{renvoie la couleur du n-i�me joyau en partant du bas}
function CDPile.Couleur (n : Integer) : TContenu;
begin
	Couleur := APile^.Couleur (n);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie la ligne sur laquelle est situ� le n-i�me joyau de la pile}
function CDPile.Ligne (n : Integer) : Integer;
begin
	Ligne := APile^.Ligne (n);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{aire dans laquelle se meut la pile}
function CDPile.DAire : pCDAire;
begin
	DAire := ADAire;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{accesseur de l'attribut APile}
function CDPile.Pile : pCPile;
begin
	Pile := APile;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie la colonne sur laquelle se situe la pile}
function CDPile.Colonne : Integer;
begin
	Colonne := APile^.Colonne
end;

{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CDPile.Free;
var
	i : Integer;
begin
	for i := 1 to APile^.Taille do
	begin
		if APile^.Ligne (i) > 0 then
			Dispose (ADJoyau[i], Free);
	end;
	Dispose (APile, Free)
end;
{----------------------------------------------------------------------}

end.
