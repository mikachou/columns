Unit UPile;
{unit� de manipulation d'un objet Pile, compos� de TaPile joyaux}

interface

uses
	UCellule, UMatrice, UJoyau;

const
	TaPileMax = 10;			{la taille maximale d'une pile, en nombre de joyaux}

type

	pCPile = ^CPile;
	CPile = object
		private
			AJoyau : array[1..TaPileMax] of pCJoyau;	{tableau des joyaux composant la pile}
			ATaPile : Integer;							{Taille de la pile de joyaux, en nombre de joyaux}
			ALigne : Integer;							{ligne sur laquelle se trouve la base de la pile}
			AColonne : Integer;							{colonne sur laquelle se situe la pile}
			AMatrice : pCMatrice;						{matrice dans laquelle se meut la pile}
			AMagique : Boolean;							{"vrai" si la pile est magique, c'est-�-dire constitu�e
														de TaPile joyaux magiques, "faux" si elle ne l'est pas,
														c'est-�-dire constitu�e d'aucun joyau magique}
		public
			constructor Genere (Mat : pCMatrice; TaPile, NbCouleurs : Integer; ProbaMagique : Real);
			constructor Restant (Pile :pCPile);
			constructor Tombant (Mat : pCMatrice; limBas, Col, TaPile: Integer);
			function EstEntree : Boolean;
			function Entre (Col : Integer) : Boolean;
			function Tombe : Boolean;
			function AGauche : Boolean;
			function ADroite : Boolean;
			procedure Change;
			function Ligne (n : Integer) : Integer;
			function Colonne : Integer;
			function Couleur (n : Integer) : TContenu;
			function Taille : Integer;
			function Joyau (n : Integer): pCJoyau;
			function Matrice : pCMatrice;
			destructor Free;
	end;

implementation

constructor CPile.Genere (Mat : pCMatrice; TaPile, NbCouleurs : Integer; ProbaMagique : Real);
var
	i : Integer;
	Magic : Boolean;
begin
	AMatrice := Mat;
	ATaPile := TaPile;
	AColonne := 0;
	ALigne := 0;
	for i := 1 to ATaPile do
		New (AJoyau[i], Genere (NbCouleurs, 0, 0, AMatrice));
	for i := ATaPile + 1 to TaPileMax do
		AJoyau[i] := nil
end;

{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{g�n�ration d'une nouvelle pile � partir du restant de la pr�c�dente rest�e
en dehors de la matrice. Ce constructeur sera utile lorsqu'� la suite d'un
alignement un des joyaux de la pile disparaitra alors que des �l�ments de la pile
seront rest�s dehors. Le reste de la pile entrera alors par la suite}
constructor CPile.Restant (Pile :pCPile);
var
	Dedans : Boolean;
	i, j : Integer;
	Joy : pCJoyau;
begin
	Dedans := True;
	i := 0;
	while Dedans do
	begin
		i := i + 1;
		Joy := Pile^.Joyau (i);
		Dedans := Joy^.EstEntre
	end;
	AMatrice := Pile^.Matrice;
	ATaPile := Pile^.Taille - i + 1;
	AMagique := False;
	AColonne := 0;
	ALigne := 0;
	for j := i to Pile^.Taille do
	begin
		Joy	:= Pile^.Joyau (j);
		New (AJoyau[j - i + 1], Init (Joy^.Couleur, 0, 0, AMatrice));
	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{g�n�ration d'une pile � partir d'une colonne en �tat d'effondrement dans la matrice
les limite d'une telle pile sont :
le joyau du dessous qui est en train de disparaitre
ET (le joyau du dessus qui est en train de disparaitre
	OU le vide
	OU la limite sup�rieure de la matrice)
la variable limBas d�signe la ligne sur laquelle se situe le joyau inf�rieur
de la pile}
constructor CPile.Tombant (Mat : pCMatrice; limBas, Col, TaPile : Integer);
var
	i : Integer;
begin
	AMatrice := Mat;
	ATaPile := TaPile;
	ALigne := limBas;
	AColonne := Col;
	AMagique := False;
	for i := 1 to ATaPile do
		New (AJoyau[i], Init (AMatrice^.Cell_Contenu (ALigne + i - 1, AColonne), ALigne + i - 1, AColonne, AMatrice));
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{"Vrai" si la pile est entr�e dans la matrice, "Faux" dans le cas contraire
La pile est consid�r�e comme �tant entr�e dans la matrice d�s que le joyau
situ� � son sommet (AJoyay[TaPile]) est entr�}
function CPile.EstEntree : Boolean;
begin
	EstEntree := AJoyau[ATaPile]^.EstEntre;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Teste si la pile entre ("vrai") ou non ("faux") dans la matrice.
Si la pile est deja entr�e, on consid�re qu'elle n'y entre pas.
Si des joyaux de la pile sont bloqu�s avant leur entr�e dans la matrice,
on consid�re �galement qu'elle n'y entre pas}
function CPile.Entre (Col : Integer) : Boolean;
var
	i : Integer;
begin
	if not CPile.EstEntree then
	begin
		if AColonne = 0 then AColonne := Col;
		i := 1;
		while (AJoyau[i]^.EstEntre) and (i <= ATaPile) do
		begin
			AJoyau[i]^.Tombe;
			i := i + 1
		end;
		Entre := AJoyau[i]^.Entre (AColonne);
		ALigne := AJoyau[1]^.Ligne
	end
	else
		Entre := False
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Chute de la pile dans la matrice, devient "faux" quand la pile arr�te de chuter
= bute sur quelque chose ou arrive tout en bas}
function CPile.Tombe : Boolean;
var
	i : Integer;
begin
	if CPile.EstEntree then
	begin
		if AJoyau[1]^.Tombe then
		begin
			Tombe := True;
			if ATaPile > 1 then
				for i := 2 to ATaPile do
					AJoyau[i]^.Tombe;
			Aligne := AJoyau[1]^.Ligne
		end
		else
			Tombe := False
	end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{d�placement � gauche dans la matrice, "faux" quand la matrice ne peut aller �
gauche lorsqu'un objet ou le bord de la matrice l'en emp�che, "vrai" dans le cas
contraire}
function CPile.AGauche : Boolean;
var
	i : Integer;
begin
	if AJoyau[1]^.AGauche then
	begin
		AGauche := True;
		if ATaPile > 1 then
			for i := 2 to ATaPile do
				AJoyau[i]^.AGauche;
		AColonne := AJoyau[1]^.Colonne
	end
	else
		AGauche := False
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{d�placement � droite dans la matrice, "faux" quand la matrice ne peut aller �
droite lorsqu'un objet ou le bord de la matrice l'en emp�che, "vrai" dans le cas
contraire}
function CPile.ADroite : Boolean;
var
	i : Integer;
begin
	if AJoyau[1]^.ADroite then
	begin
		ADroite := True;
		if ATaPile > 1 then
			for i := 2 to ATaPile do
				AJoyau[i]^.ADroite;
		AColonne := AJoyau[1]^.Colonne
	end
	else
		ADroite := False
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Cette proc�dure sert � changer l'ordre des joyaux dans la pile}
procedure CPile.Change;
var
	i : Integer;
	swap : TContenu;
begin
	if ATaPile > 1 then
	begin
		swap := AJoyau[1]^.Couleur;
		for i := 1 to ATaPile - 1 do
			AJoyau[i]^.Assigne (AJoyau[i+1]^.Couleur);
		AJoyau[ATaPile]^.Assigne (swap)
	end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie le num�ro de ligne du n-i�me joyau de la pile. Le premier est situ� en bas, 
le TaPile-i�me en haut}
function CPile.Ligne (n : Integer) : Integer;
begin
	Ligne := AJoyau[n]^.Ligne;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie le num�ro de colonne de la pile}
function CPile.Colonne : Integer;
begin
	Colonne := AColonne;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie la couleur du n-i�me joyau de la pile}
function CPile.Couleur (n : Integer) : TContenu;
begin
	Couleur := AJoyau[n]^.Couleur;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie la couleur du n-i�me joyau de la pile}
function CPile.Taille : Integer;
begin
	Taille := ATapile;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CPile.Joyau (n : Integer): pCJoyau;
begin
	Joyau := AJoyau[n]
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CPile.Matrice : pCMatrice;
begin
	Matrice := AMatrice
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CPile.Free;
var
	i : Integer;
begin
	for i := 1 to ATaPile do
		Dispose (AJoyau[i], Free)
end;
{----------------------------------------------------------------------}

end.
