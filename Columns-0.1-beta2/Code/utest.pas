Unit UTest;		{unité de tests}
{cette unité contient ds procédures et fonctions servant à repérer des alignements de joyaux
et à compter ces joyaux alignés s'ils sont dans un alignement assez grand}

interface

uses
	UCellule, UMatrice;

type
	pCTest = ^CTest;
	CTest = object
		private
			AMatrice : pCMatrice;		{Matrice sur laquelle on va effectuer le test}
			ATaDisp : Integer;			{Longueur (taille) des alignements entrainant disparition}
			function Dessus (Lin, Col : Integer; var n : Integer) : Integer;
			function ADroite (Lin, Col : Integer; var n : Integer) : Integer;
			function NE (Lin, Col : Integer; var n : Integer) : Integer;
			function NO (Lin, Col : Integer; var n : Integer) : Integer;
		public
			constructor Init (Mat : pCMatrice; TaDisp : Integer);
			function Vertical : Integer;
			function Horizontal : Integer;
			function Diag_SONE : Integer;
			function Diag_SENO : Integer;
			function Faire : Integer;
			function Taille : Integer;
			destructor Free;
	end;

implementation

{----------------------------------------------------------------------}
constructor CTest.Init (Mat : pCMatrice; TaDisp : Integer);
var
	i, j : Integer;
begin
	AMatrice := Mat;
	ATaDisp := TaDisp;
	for i := 1 to AMatrice^.Hauteur do
		for j := 1 to AMatrice^.Largeur do
			AMatrice^.Cell_FaireDisparaitre (False, i, j);
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CTest.Dessus (Lin, Col : Integer; var n : Integer) : Integer;
{procedure s'appelant récursivement pour vérifier si le joyaux du dessus est le même que celui situé en (Lin, Col)}
begin
	if Lin + 1 <= AMatrice^.Hauteur then
		if AMatrice^.Cell_Contenu (Lin, Col) = AMatrice^.Cell_Contenu (Lin + 1, Col) then
		begin
			n := n + 1;
			CTest.Dessus (Lin + 1, Col, n);
		end;
	if n >= ATaDisp then
	begin
		AMatrice^.Cell_FaireDisparaitre (True, Lin, Col);
		Dessus := n
	end
	else
		Dessus := 0;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{procedure permettant de repérer les ensembles verticaux de ATaDisp joyaux de même couleur}
function CTest.Vertical : Integer;
var
	Lin, Col, n : Integer;
	Result : Integer;
begin
	Result := 0;			 {par défaut}
	for Col := 1 to AMatrice^.Largeur do  {on cherche les ensembles verticaux sur chaque colonne
											de la matrice, l'une après l'autre}
	begin
		Lin := 1;
		while Lin <= AMatrice^.Hauteur - ATaDisp + 1 do
		{on parcourt la colonne de bas en haut tant que les cellules sont
		occupées, et tant qu'il y a assez de place au dessus pour former
		un ensemble de ATaDisp joyaux de même couleur}
		begin
			n := 1;
			if AMatrice^.Cell_Occupee (Lin, Col) then
				if CTest.Dessus (Lin, Col, n) <> 0 then
					Result := Result + n;
			Lin := Lin + n;
		end
	end;
	Vertical := Result
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CTest.ADroite (Lin, Col : Integer; var n : Integer) : Integer;
{procedure s'appelant récursivement pour vérifier si le joyaux à droite est le même que celui situé en (Lin, Col)}
begin
	if Col + 1 <= AMatrice^.Largeur then
		if AMatrice^.Cell_Contenu (Lin, Col) = AMatrice^.Cell_Contenu (Lin, Col + 1) then
		begin
			n := n + 1;
			CTest.ADroite (Lin, Col + 1, n);
		end;
	if n >= ATaDisp then
	begin
		AMatrice^.Cell_FaireDisparaitre (True, Lin, Col);
		ADroite := n
	end
	else
		ADroite := 0;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{procedure permettant de repérer les ensembles horizontaux de ATaDisp joyaux de même couleur}
function CTest.Horizontal : Integer;
var
	Lin, Col, n : Integer;
	Result : Integer;		{correspond au résultat de la fonction}
begin
	Result := 0;			 {par défaut}
	for Lin := 1 to AMatrice^.Hauteur do  {on cherche les ensembles horizontaux sur chaque Ligne
											de la matrice, l'une après l'autre}
	begin
		Col := 1;
		while Col <= AMatrice^.Largeur - ATaDisp + 1 do
		{on parcourt la ligne de gauche à droite tant qu'il y a assez de place
		à droite pour former un ensemble de ATaDisp joyaux de même couleur}
		begin
			n := 1;
			if AMatrice^.Cell_Occupee (Lin, Col) then
				if CTest.ADroite (Lin, Col, n) <> 0 then
					Result := Result + n;
			Col := Col + n
		end
	end;
	Horizontal := Result
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CTest.NE (Lin, Col : Integer; var n : Integer) : Integer;
begin
	if (Lin + 1 <= AMatrice^.Hauteur) and (Col + 1 <= AMatrice^.Largeur) then
		if AMatrice^.Cell_Contenu (Lin, Col) = AMatrice^.Cell_Contenu (Lin + 1, Col + 1) then
		begin
			n := n + 1;
			CTest.NE (Lin + 1, Col + 1, n);
		end;
	if n >= ATaDisp then
	begin
		AMatrice^.Cell_FaireDisparaitre (True, Lin, Col);
		NE := n
	end
	else
		NE := 0
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CTest.Diag_SONE : Integer;
{on cherche les alignements dont la direction est Sud-Ouest Nord-Est}
var
	Lin, Col, n : Integer;
	Result : Integer;			{correspond au résultat de la fonction}
begin
	Result := 0;			{par défaut}
	for Col := 1 to AMatrice^.Largeur - ATaDisp + 1 do
	begin
		Lin := 1;
		while AMatrice^.Cell_Occupee (Lin, Col) and (Lin <= AMatrice^.Hauteur - ATaDisp + 1) do
		{on parcourt la colonne de bas en haut  tant qu'il y a assez de place au dessus pour former
		un ensemble de ATaDisp joyaux de même couleur}
		begin
			n := 1;
			if CTest.NE (Lin, Col, n) <> 0 then
				Result := Result + n;
			Lin := Lin + 1;
		end
	end;
	Diag_SONE := Result
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CTest.NO (Lin, Col : Integer; var n : Integer) : Integer;
begin
	if (Lin + 1 <= AMatrice^.Hauteur) and (Col - 1 >= 1) then
		if AMatrice^.Cell_Contenu (Lin, Col) = AMatrice^.Cell_Contenu (Lin + 1, Col - 1) then
		begin
			n := n + 1;
			CTest.NO (Lin + 1, Col - 1, n);
		end;
	if n >= ATaDisp then
	begin
		AMatrice^.Cell_FaireDisparaitre (True, Lin, Col);
		NO := n
	end
	else
		NO := 0
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
function CTest.Diag_SENO : Integer;
var
	Lin, Col, n : Integer;
	Result : Integer;		{correspond au résultat de la fonction}
begin
	Result := 0;			{par défaut}
	for Col := ATaDisp to AMatrice^.Largeur do
	begin
		Lin := 1;
		while AMatrice^.Cell_Occupee (Lin, Col) and (Lin <= AMatrice^.Hauteur - ATaDisp + 1) do
		{on parcourt la colonne de bas en haut  tant qu'il y a assez de place au dessus pour former
		un ensemble de ATaDisp joyaux de même couleur}
		begin
			n := 1;
			if CTest.NO (Lin, Col, n) <> 0 then
				Result := Result + n;
			Lin := Lin + 1;
		end
	end;
	Diag_SENO := Result
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{cherche les alignements d'au moins ATaDisp joyaux sur la matrice, retourne une valeur > 0
s'il y a au moins un alignement, 0 dans le cas contraire}
function CTest.Faire : Integer;
begin
	Faire := Vertical + Horizontal + Diag_SONE + Diag_SENO
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{renvoie la taille des éléments recherchés}
function CTest.Taille : Integer;
begin
	Taille := ATaDisp;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CTest.Free;
begin
end;
{----------------------------------------------------------------------}

end.
