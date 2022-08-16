program Columns;

{AUTEUR : Micha�l Schuh, AS 2008-2009, d�cembre 2008-janvier 2009
DESIGNATION : Jeu de type puzzle consistant � aligner des �l�ments de couleur d�boulant
dans un ordre al�atoire, cens� reproduire les r�gles du jeu original Columns paru en 1990
(cf Doc)

Pour des d�tails r�f�rez-vous � la documentation}

{$R columns.res}

uses
	UJeu3, WinAppli;

var
	Jeu : pCJeu;

begin
	Randomize;
	InitAppli ('Columns', 800, 585);
	New (Jeu, Init);
	Jeu^.Derouler;
	DoneAppli;
	Dispose (Jeu, Free);
end.
