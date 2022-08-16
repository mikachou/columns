
Unit UCellule;

interface
	
type
	{définition des couleurs que peuvent prendre un joyau, ou une cellule :
	Bleu, Jaune, Rouge, Vert, Orange, Violet,
	Magique : pour le joyau magique,
	Nul : pour une cellule vide}
	TContenu = (Bleu, Jaune, Rouge, Orange, Violet, Vert, Nul);
	
	{objet Cellule, définition de la classe et du pointeur associé}
	pCCellule = ^CCellule;
	CCellule = object
		private
			ALigne : Integer;		{ligne sur laquelle se trouve la cellule 
									dans la matrice à laquelle elle appartient}
			AColonne : Integer;		{colonne dans laquelle se trouve la cellule
									dans la matrice à laquelle elle appartient}
			AContenu : TContenu;	{Contenu de la cellule, qui peut être une couleur ou Nul}
			ADisparait : Boolean;	{Vrai si le contenu d'une cellule disparait, faux dans le cas contraire}
		public
			constructor Init (Lin, Col : Integer);
			function Contenu : TContenu;
			function Occupee : Boolean;
			procedure Assigne (Cont : TContenu);
			procedure Transfert (Cellule : pCCellule);
			function Disparait : Boolean;
			procedure FaireDisparaitre (Disp : Boolean);
			destructor Free;
	end;

implementation

{----------------------------------------------------------------------}	
constructor CCellule.Init (Lin, Col : Integer);
begin
	ALigne := Lin;
	AColonne := Col;
	AContenu := Nul;
	ADisparait := False;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Renvoie le contenu d'une cellule : couleur, ou Nul}
function CCellule.Contenu : TContenu;
begin
	Contenu := AContenu;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Teste l'occupation d'une cellule, "vrai" si la cellule contient une
couleur, "faux" dans le cas contraire (Nul)}
function CCellule.Occupee : Boolean;
begin
	Occupee := AContenu <> Nul
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Assigne à la cellule un contenu (couleur ou Nul)}
procedure CCellule.Assigne (Cont : TContenu);
begin
	AContenu := Cont;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Transfert le contenu d'une cellule vers une autre, l'attribut AContenu 
de la cellule dont le contenu est transféré reçoit la valeur Nul (elle
n'a plus de couleur}
procedure CCellule.Transfert (Cellule : pCCellule);
begin
	Cellule^.Assigne (AContenu);
	AContenu := Nul;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Vrai si le contenu de la cellule est marqué pour disparaitre
Faux dans le cas contraire}
function CCellule.Disparait : Boolean;
begin
	Disparait := ADisparait
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
{Marque une cellule pour qu'elle disparaisse}
procedure CCellule.FaireDisparaitre (Disp : Boolean);
begin
	ADisparait := Disp;
end;
{----------------------------------------------------------------------}

{----------------------------------------------------------------------}
destructor CCellule.Free;
begin
end;
{----------------------------------------------------------------------}

end.
