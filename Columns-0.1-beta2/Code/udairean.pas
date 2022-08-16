Unit UDAireAn;
{animations dans l'aire de jeu}

interface

uses
	UCellule, UMatrice, UDAire, UDPile, UDJoy, WinAppli;

const
	nMaxJoyaux = 80;			{nombre maximum de joyaux pouvant être formé pendant une disparition
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
			ARangeeExplose : array[1..HMax] of Integer;		{la rangée en indice, le numéro de l'animation d'explosion
															qu'on lui applique en valeur (cf unité UDJoy)}
			ACellExplose : array[1..HMax, 1..LMax] of pCDJoyau;	{cellule explosant lors de l'animation de défaite}
			ASon : Boolean;									{sons activés ou non}
			procedure DisparaitCreerJoyaux;
			procedure DisparaitFaire (Son : Boolean);
			procedure DisparaitJoyauxFree;
			procedure TestSuiv (Lin, Col : Integer; var n : Integer);
			procedure EffondreCreerPiles ;
			procedure EffondreFaire (Restant : pCDPile; Col : Integer);
			procedure EffondrePilesFree;
			procedure LigneExplose;
		public
			constructor Init (DA : pCDAire; Son : Boolean);
			procedure Disparition (Son : Boolean);
			procedure Effondrer (Restant : pCDPile; Col : Integer);
			procedure Perdu (Son : Boolean);
			destructor Free;
	end;

implementation

{----------------------------------------------------------------------}
constructor CDAireAn.Init (DA : pCDAire; Son : Boolean);
var
	i, j : Integer;
begin
	ADAire := DA;
	ANbDisp := 0;
	ANbEff := 0;
	ASon := Son;
	for i := 1 to nMaxJoyaux do
		AJoyauxDisp[i] := nil;
	for i := 1 to nMaxPiles do
		APileEff[i] := nil;
	for i := 1 to ADAire^.Hauteur do
		ARangeeExplose[i] := 1 - i;				{valeur initiale cohérente}
	for i := 1 to HMax do
		for j := 1 to LMax do
			ACellExplose[i,j] := nil;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{création des joyaux qui vont disparaitre en s'animant}
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
{animation de l'explosion}
procedure CDAireAn.DisparaitFaire;
var
	i, j : Integer;
begin
	{ici on clignote...}
	for i := 1 to 5 do
	begin
		for j := 1 to ANbDisp do
			AJoyauxDisp[j]^.Effacer;
		Wait (35);
		for j := 1 to ANbDisp do
			AJoyauxDisp[j]^.Dessiner;
		Wait (35);
	end;
	if Son then
		ExecFile('SndRec32 /embedding /play SE1.wav');
	{là on explose}
	for i := 1 to 7 do
	begin
		for j := 1 to ANbDisp do
			AJoyauxDisp[j]^.Explose (i);
		Wait (50)
	end;
	{et là on efface les résidus}
	for i := 1 to ANbDisp do
		AJoyauxDisp[i]^.Effacer;
	Wait (100);
	ADAire^.Disparaissent;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{le dispose sur les djoyaux crées pour lesbesoins de l'animations}
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
procedure CDAireAn.Disparition (Son : Boolean);
begin
	DisparaitCreerJoyaux;
	DisparaitFaire (Son);
	DisparaitJoyauxFree;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{c'est une procédure récursive qui compte le nombre de joyaux présents dans une pile
si on part d'une cellule occupée, et qu'on teste celle du dessus, et que celle-ci est occupée,
alors on teste la 3e à partir de la 2e au moyen d'une procédure récursive, et ainsi de suite, jusqu'à arriver
en haut de la pile (cellule vide ou haut de la matrice)}
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
begin
	for Col := 1 to ADAire^.Largeur do {test colonne après colonne}
	begin
		Lin := 0;

		{on va tester ligne par ligne la présence d'une cellule occupée, en partant du bas}
		repeat
			Lin := Lin + 1;
		until (not ADAire^.Cell_Occupee (Lin, Col)) or (Lin = ADAire^.Hauteur - 1);

		repeat
			n := 0;
			{dès qu'on trouve une cellule vide (en train de disparaitre)
			on fait un test recursif sur les cellules du dessus afin d'identifier
			un bloc de cellules pleines jusqu'à la prochaine cellule vide ou
			au haut de la matrice}
			if (not ADAire^.Cell_Occupee (Lin, Col)) then
				TestSuiv (Lin + 1, Col, n);	{voir procedure TestSuiv au dessus}
			if n > 0 then
			begin
				ANbEff := ANbEff + 1;
				New (APileEff[ANbEff], Tombant (ADAire, Lin + 1, Col, n));	
				{on créé une pile "tombante" à partir de la ligne au dessus du joyau qui vient de disparaitre.
				Cf UDPile et la documentation}
			end;
			Lin := Lin + n + 1			 {on poursuit le test au dela des n joyaux ne disparaisant pas formant une pile qui va tomber}
		until (Lin >= ADAire^.Hauteur)
		{on effectue le test jusquà la dernière ligne}
	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{on fait s'effondrer les piles créées pour les besoins de l'effondrement}
procedure CDAireAn.EffondreFaire (Restant : pCDPile; Col : Integer);
var
	i : Integer;
	Tombe : Boolean;
	UneTombe : Boolean;			{au moins une pile tombe}
begin
	repeat
		UneTombe := False;
		i := 0;
		while i < ANbEff do
		begin
			i := i + 1;
			if APileEff[i]^.Tombe then
				Tombe := True
			else
				Tombe := False;
			UneTombe := UneTombe or Tombe ;
		end;
		if Restant <> nil then
		begin
			if Restant^.EstEntree then
			begin
				if Restant^.Tombe then
					Tombe := True
				else
					Tombe := False
			end
			else
			begin
				if Restant^.Entre (Col) then
					Tombe := True
				else
					Tombe := False
			end;
		UneTombe := UneTombe or Tombe ;
		end;
		Wait (25)
	until not UneTombe
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
procedure CDAireAn.Effondrer (Restant : pCDPile; Col : Integer);
begin
	EffondreCreerPiles;
	EffondreFaire (Restant, Col);
	EffondrePilesFree
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
procedure CDAireAn.LigneExplose;
var
	Lin, Col : Integer;
begin
	{affiche sur chaque ligne à laquelle a été associée une valeur entre
	1 et 8 l'image représentant l'étape de l'explosion identifiée par la valeur
	(pour une valeur de 4 on affiche l'image 4)}
	for Lin := 1 to ADAire^.Hauteur do
		if ARangeeExplose[Lin] = 1 then
			for Col := 1 to ADAire^.Largeur do
			begin
				New (ACellExplose[Lin, Col], Init (ADAire^.DMatrice, nul, Lin, Col, 1));
				ACellExplose[Lin,Col]^.Explose (ARangeeExplose[Lin])
			end
		else if (ARangeeExplose[Lin] > 1) and (ARangeeExplose[Lin] < 8) then
			for Col := 1 to ADAire^.Largeur do
				ACellExplose[Lin,Col]^.Explose (ARangeeExplose[Lin])
		else if ARangeeExplose[Lin] = 8 then
			for Col := 1 to ADAire^.Largeur do
			begin
				ACellExplose[Lin,Col]^.Effacer;
				Dispose (ACellExplose[Lin,Col], Free)
			end;
end;
{----------------------------------------------------------------------}


{----------------------------------------------------------------------}
{créé une explosion des éléments de l'aire de jeu (feu d'artifice}
procedure CDAireAn.Perdu (Son : Boolean);

var
	i : Integer;
	n_expl : Integer;							{numéro de l'explosion (cf unité UDJoy)
												de 1 à 8 : 1->7 = explosions, 8 = le noir}
begin
	if Son then
		for i := 1 to 4 do
			ExecFile('SndRec32 /embedding /play SE2.wav');
			
	{dans cette boucle while on s'arrange pour associer une valeur entière 0<=n<9 à toutes 
	les cellules d'une meme ligne et on incremente cette valeur de 1 a chaque itération}
	{la différence entre la valeur associée à une ligne et la valeur associée à la ligne 
	qui lui est immédiatement inférieure est 1, de sorte qu'à un instant donnée on observe
	en "dégradé" toutes les étapes d'une explosion, et que ce dégradé parcourt la matrice de bas en haut}
	while ARangeeExplose[ADAire^.Hauteur] < 8 do
	begin
		for i := 1 to ADAire^.Hauteur do
			ARangeeExplose[i] := ARangeeExplose[i] + 1;
		LigneExplose;
		Wait (30);
	end;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CDAireAn.Free;
begin
end;
{----------------------------------------------------------------------}

end.
