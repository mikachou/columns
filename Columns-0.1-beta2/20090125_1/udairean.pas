Unit UDAireAn;
{animations dans l'aire de jeu}

interface

uses
	UCellule, UDAire, UDPile, UDJoy, WinAppli;

const
	nMaxJoyaux = 50;			{nombre maximum de joyaux pouvant être formé pendant une disparition
								(voir procédure Disparition)}
	nMaxPiles = 24;				{nombre maximum de piles pouvant être formé pendant un effondrement
								(voir procédure Effondrement)}

type
	pCDAireAn = ^CDAireAn;
	CDAireAn = object
		private
			ADAire : pCDAire;
			ANbDisp : Integer;								{nombre de joyaux disparaissant pendant une disparition}
			ANbEff:	Integer;								{nombre de piles formées pendant un effondrement}
			AJoyauxDisp : array[1..nMaxJoyaux] of pCDJoyau;	{ensemble des joyaux disparaissant lors d'une disparition}
			APileEff : array[1..nMaxPiles] of pCDPile;		{ensemble des piles nées de l'effondrement}
			procedure DisparaitCreerJoyaux;
			procedure DisparaitFaire;
			procedure DisparaitJoyauxFree;
			procedure TestSuiv (Lin, Col : Integer; var n : Integer);
			procedure EffondreCreerPiles;
			procedure EffondreFaire;
			procedure EffondrePilesFree;
		public
			constructor Init (DA : pCDAire);
			procedure Disparition;
			procedure Effondrer;
			destructor Free;
	end;

implementation

{----------------------------------------------------------------------}
constructor CDAireAn.Init (DA : pCDAire);
var
	i : Integer;
begin
	ADAire := DA;
	ANbDisp := 0;
	ANbEff := 0;
	for i := 1 to nMaxJoyaux do
		AJoyauxDisp[i] := nil;
	for i := 1 to nMaxPiles do
		APileEff[i] := nil
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDAireAn.DisparaitCreerJoyaux;
var
	Lin, Col : Integer;
begin
	for Lin := 1 to ADAire^.Hauteur do
		for Col := 1 to ADAire^.Largeur do
			if ADAire^.Cell_Disparait (Lin, Col) then
			begin
				ANbDisp := ANbDisp + 1;
				New (AJoyauxDisp[ANbDisp], Init (ADAire^.DMatrice, ADAire^.Cell_Contenu (Lin, Col), Lin, Col, 1))
			end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDAireAn.DisparaitFaire;
var
	i, j : Integer;
begin
	for i := 1 to 5 do
	begin
		for j := 1 to ANbDisp do
			AJoyauxDisp[j]^.Blink;
		Wait (50);
		for j := 1 to ANbDisp do
			AJoyauxDisp[j]^.Dessiner;
		Wait (50);
	end;
	for i := 1 to ANbDisp do
		AJoyauxDisp[i]^.Effacer;
	Wait (50);
	ADAire^.Disparaissent;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDAireAn.DisparaitJoyauxFree;
var
	i : Integer;
begin
	for i := 1 to ANbDisp do
		Dispose (AJoyauxDisp[i], Free);
	ANbDisp := 0
end;

{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{animation d'une disparition de joyaux dans la matrice}
procedure CDAireAn.Disparition;
begin
	DisparaitCreerJoyaux;
	DisparaitFaire;
	DisparaitJoyauxFree;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDAireAn.TestSuiv (Lin, Col : Integer; var n : Integer);
begin
	if ADAire^.Cell_Occupee (Lin, Col) then				{on regarde tout d'abord si la cellule est occupée}
	begin
		n := n + 1;									{si elle ne disparait pas, on ajoute 1 au nombre de joyaux formant la pile qui va tomber}
		if Lin + 1 <= ADAire^.Hauteur then	 		{et s'il y a une ligne au dessus
										(autrement dit si on est pas deja en haut de la matrice alors...}
			TestSuiv (Lin + 1, Col, n)				{... alors on teste la ligne du dessus de la même manière, et ainsi de suite}
	end
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDAireAn.EffondreCreerPiles;
var
	Lin, Col,  		{on va balayer la matrice colonne par colonne, et ligne par ligne}
	n : Integer;	{on se servira de cette variable pour compter le nombre de joyaux formant une pile qui tombe
					suite à une diparition}
	nbs, LimBas, Cols, ns : string;
begin
	for Col := 1 to ADAire^.Largeur do {test colonne après colonne}
	begin
		Lin := 0;

		repeat
			Lin := Lin + 1;
		until (not ADAire^.Cell_Occupee (Lin, Col)) or (Lin = ADAire^.Hauteur - 1);

		repeat
			n := 0;
			if (not ADAire^.Cell_Occupee (Lin, Col)) then
				TestSuiv (Lin + 1, Col, n);
			if n > 0 then
			begin
				ANbEff := ANbEff + 1;
				Str (ANbEff, nbs);
				Str (Lin+1, LimBas);
				Str (Col, Cols);
				Str (n, ns);
				DrawString (50, 300, concat ('Nombre piles : ',nbs));
				DrawString (50, 350, concat ('limite bas : ', Limbas));
				DrawString (50, 400, concat ('nombre : ', ns));
				DrawString (50, 450, concat ('Colonne : ', Cols));
				New (APileEff[ANbEff], Tombant (ADAire, Lin + 1, Col, n));
				DrawString (50, 600, 'Bling');
			end;
			Lin := Lin + n + 1			 {on poursuit le test au dela des n joyaux ne disparaisant pas formant une pile qui va tomber}
		until (Lin >= ADAire^.Hauteur - 1)
		{on effectue le test jusque l'avant dernière ligne (au dela c'est inutile, cf au dessus}

	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{on fait s'effondrer les piles créées pour les besoins de l'effondrement}
procedure CDAireAn.EffondreFaire;
var
	i : Integer;
	Tombe : Boolean;
begin
	Tombe := False;
	repeat
		i := 0;
		while i < ANbEff do
		begin
			i := i + 1;
			if APileEff[i]^.Tombe then
				Tombe := True
			else
				Tombe := False
		end;
		Wait (50)
	until not Tombe
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{on libère la mémoire des piles créées et à présent effondrées, car on en a plus besoin}
procedure CDAireAn.EffondrePilesFree;
var
	i : Integer;
begin
	for i := 1 to ANbEff do
		Dispose (APileEff[i], Free);
	ANbEff := 0
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDAireAn.Effondrer;
begin
	EffondreCreerPiles;
	EffondreFaire;
	EffondrePilesFree
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CDAireAn.Free;
begin
end;
{----------------------------------------------------------------------}

end.
