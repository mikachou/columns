Unit UDPile;	{unité de gestion du déplacement d'une pile dans l'aire de jeu dessinée}

interface

uses
	UCellule, UMatrice, UDMatVid, UPile, UDJoy, UDAire, WinAppli;
	
type
	pCDPile = ^CDPile;
	CDPile = object
		private
			APile : pCPile;								{Pile représentée}
			ADAire : pCDAire;							{DAire dans laquelle se meut la représentation de la pile}
			ADJoyau : array[1..TaPileMax] of pCDJoyau;	{tableau des DJoyaux de la pile}
			ATombant : Boolean;
		public
			constructor Init (DA : pCDAire; Tail, NbCouleurs : Integer; ProbaMagique : Real);
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
constructor CDPile.Init (DA : pCDAire; Tail, NbCouleurs : Integer; ProbaMagique : Real);
begin
	ADAire := DA;
	ATombant := False;
	New (APile, Genere (ADAire^.Matrice, Tail, NbCouleurs, ProbaMagique));
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
constructor CDPile.Restant (DPile :pCDPile);
begin
	ADAire := DPile^.DAire;
	ATombant := False;
	New (APile, Restant (DPile^.Pile))
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
constructor CDPile.Tombant (DA : pCDAire; limBas, Col, TaPile : Integer);
var
	DMat : pCDMatrice;
begin
	ADAire := DA;
	ATombant := True;
	DrawString (50, 500, 'Eliminer');
	New (APile, Tombant (ADAire^.Matrice, limBas, Col, TaPile));
end;
{----------------------------------------------------------------------}


{----------------------------------------------------------------------}
procedure CDPile.Dessiner;
var
	i : Integer;
begin
	for i := 1 to APile^.Taille do
		New (ADJoyau[i], Creer (ADAire^.DMatrice, APile^.Couleur (i), APile^.Ligne (i), APile^.Colonne, 1));
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
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
function CDPile.Entre (Col : Integer) : Boolean;
begin
	{Effacer;}
	Entre := APile^.Entre (Col);
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
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
function CDPile.AGauche : Boolean;
begin
	Effacer;
	AGauche := APile^.AGauche;
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDPile.ADroite : Boolean;
begin
	Effacer;
	ADroite := APile^.ADroite;
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDPile.Change;
begin
	Effacer;
	APile^.Change;
	Dessiner;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDPile.EstEntree : Boolean;
begin
	EstEntree := APile^.EstEntree;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDPile.Taille : Integer;
begin
	Taille := APile^.Taille;
end;
{---------------------------------------------------------------------}		

{----------------------------------------------------------------------}
function CDPile.DJoyau (n : Integer) : pCDJoyau;
begin
	DJoyau := ADJoyau[n];
end;
{---------------------------------------------------------------------}

{---------------------------------------------------------------------}
function CDPile.Couleur (n : Integer) : TContenu;
begin
	Couleur := APile^.Couleur (n);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDPile.Ligne (n : Integer) : Integer;
begin
	Ligne := APile^.Ligne (n);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDPile.DAire : pCDAire;
begin
	DAire := ADAire;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CDPile.Pile : pCPile;
begin
	Pile := APile;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
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
