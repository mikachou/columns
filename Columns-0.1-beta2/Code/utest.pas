Unit UTest;		{unit� de tests}
{cette unit� contient ds proc�dures et fonctions servant � rep�rer des alignements de joyaux
et � compter ces joyaux align�s s'ils sont dans un alignement assez grand}

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
{procedure s'appelant r�cursivement pour v�rifier si le joyaux du dessus est le m�me que celui situ� en (Lin, Col)}
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
{procedure permettant de rep�rer les ensembles verticaux de ATaDisp joyaux de m�me couleur}
function CTest.Vertical : Integer;
var
	Lin, Col, n : Integer;
	Result : Integer;
begin
	Result := 0;			 {par d�faut}
	for Col := 1 to AMatrice^.Largeur do  {on cherche les ensembles verticaux sur chaque colonne
											de la matrice, l'une apr�s l'autre}
	begin
		Lin := 1;
		while Lin <= AMatrice^.Hauteur - ATaDisp + 1 do
		{on parcourt la colonne de bas en haut tant que les cellules sont
		occup�es, et tant qu'il y a assez de place au dessus pour former
		un ensemble de ATaDisp joyaux de m�me couleur}
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
{procedure s'appelant r�cursivement pour v�rifier si le joyaux � droite est le m�me que celui situ� en (Lin, Col)}
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
{procedure permettant de rep�rer les ensembles horizontaux de ATaDisp joyaux de m�me couleur}
function CTest.Horizontal : Integer;
var
	Lin, Col, n : Integer;
	Result : Integer;		{correspond au r�sultat de la fonction}
begin
	Result := 0;			 {par d�faut}
	for Lin := 1 to AMatrice^.Hauteur do  {on cherche les ensembles horizontaux sur chaque Ligne
											de la matrice, l'une apr�s l'autre}
	begin
		Col := 1;
		while Col <= AMatrice^.Largeur - ATaDisp + 1 do
		{on parcourt la ligne de gauche � droite tant qu'il y a assez de place
		� droite pour former un ensemble de ATaDisp joyaux de m�me couleur}
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
	Result : Integer;			{correspond au r�sultat de la fonction}
begin
	Result := 0;			{par d�faut}
	for Col := 1 to AMatrice^.Largeur - ATaDisp + 1 do
	begin
		Lin := 1;
		while AMatrice^.Cell_Occupee (Lin, Col) and (Lin <= AMatrice^.Hauteur - ATaDisp + 1) do
		{on parcourt la colonne de bas en haut  tant qu'il y a assez de place au dessus pour former
		un ensemble de ATaDisp joyaux de m�me couleur}
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
	Result : Integer;		{correspond au r�sultat de la fonction}
begin
	Result := 0;			{par d�faut}
	for Col := ATaDisp to AMatrice^.Largeur do
	begin
		Lin := 1;
		while AMatrice^.Cell_Occupee (Lin, Col) and (Lin <= AMatrice^.Hauteur - ATaDisp + 1) do
		{on parcourt la colonne de bas en haut  tant qu'il y a assez de place au dessus pour former
		un ensemble de ATaDisp joyaux de m�me couleur}
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
{renvoie la taille des �l�ments recherch�s}
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
