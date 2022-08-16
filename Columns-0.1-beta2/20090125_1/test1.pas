program Test1;

uses
	UJeu3, WinAppli;

var
	Jeu : pCJeu;

begin
	Randomize;
	InitAppli ('Columns', 800, 600);
	New (Jeu, Init);
	Jeu^.Derouler;
	DoneAppli;
	Dispose (Jeu, Free);
end.
