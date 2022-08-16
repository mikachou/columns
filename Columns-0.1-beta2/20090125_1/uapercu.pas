Unit UApercu;
{modélisation de la prévisualisation de la pile}

interface

uses
	UCellule, UMatrice, UDMatVid, UDPile, UDJoy, WinAppli;

const
	TaPrMax = 10;	{taille maximale de l'aire de prévisualisation de la pile}

type
	pCApercu = ^CApercu;
	CApercu = object
		private
			ADMatrice : pCDMatrice;
			ATaille : Integer;
			AEspace : Integer;
		public
			constructor Creer (X, Y, Taille, Cote, Esp : Integer; Coul : TColor);
			procedure Dessiner (DPile : pCDPile);
			procedure Effacer;
			destructor Free;
	end;

implementation

{----------------------------------------------------------------------}
constructor CApercu.Creer (X, Y, Taille, Cote, Esp : Integer; Coul : TColor);
begin
	AEspace := Esp;
	ATaille := Taille;
	New (ADMatrice, Creer (1, ATaille, X, Y, Cote, False, Coul, Coul));
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CApercu.Dessiner (DPile : pCDPile);
var
	i : Integer;
	Joy : pCDJoyau;
begin
	for i := 1 to ATaille do
	begin
		New (Joy, Creer (ADMatrice, DPile^.Couleur (i), i, 1, AEspace));
		Dispose (Joy, Free)
	end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CApercu.Effacer;
begin
	ADMatrice^.Dessiner
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CApercu.Free;
begin
	Dispose (ADMatrice, Free);
end;
{----------------------------------------------------------------------}

end.