program Columns;

{AUTEUR : Michaël Schuh, AS 2008-2009, décembre 2008-janvier 2009
DESIGNATION : Jeu de type puzzle consistant à aligner des éléments de couleur déboulant
dans un ordre aléatoire, censé reproduire les règles du jeu original Columns paru en 1990
(cf Doc)

Pour des détails référez-vous à la documentation}

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
