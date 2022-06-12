
#include "stdafx.h"
#include "peter.h"
#include "TextBuf.h"
#include "ProgBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define PROGREZERVA 100			// rezerva pøi zvìtšování bufferu

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CProgBuf::CProgBuf()
{
// vytvoøení datového bufferu
	m_Items = (PROGITEM*) malloc(sizeof(PROGITEM)*PROGREZERVA);
	ASSERT(m_Items != NULL);

// inicializace ukazatelù
	m_Num = 0;					// není žádná položka
	m_Max = PROGREZERVA;		// souèasná velikost bufferu
	m_First = 0;				// první zobrazená položka bufferu
	m_Next = 0;					// následující (nezobrazená) položka bufferu
	m_Tree = NULL;				// není strom
	m_ProgBuf = NULL;			// neni mapa bufferù programù
	m_AktDef = -1;				// není aktivni definovaná položka
}

CProgBuf::~CProgBuf()
{
	free(m_Items);				// zrušení datového bufferu
}


////////////////////////////////////////////////////////////////////
// vložení položky do bufferu (-1 = na konec)
// Pozor - použít vrácený skuteèný index, protože jej mùže opravit !!!

short int CProgBuf::Insert(PROGITEM* item, short int Index)
{
// pøíprava lokálních promìnných
	short int i,j, b;			// pracovní èítaèe
	short int after;			// index pøedešlé položky (používá se pøi vkládání do stromu)
	PROGITEM* src;				// ukazatel na zdrojovou položku, adresa nové položky
	PROGITEM* dst;				// ukazatel na cílovou položku, pracovní ukazatel položek
	CProgBuf* buf;				// adresa bufferu pøi korekci odkazù a pøi hledání textu
	TV_ITEM parItem;			// opravovaná položka rodièe ve stromu
	TV_INSERTSTRUCT tvs;		// vkládaná položka do stromu
	CString txt;				// buffer textu pøi hledání textu k položce
	short int param;			// meziúschova parametrù položky
	short int model;			// meziúschova modelu

	ASSERT(item != NULL);		// vkládaná položka musí být platná

// zvýšení velikosti bufferu (-1 = chyba)
	if (m_Num >= m_Max)			// je pøeteèení velikosti ?
	{
		dst = (PROGITEM*)realloc(m_Items,	// realokace bufferu
			sizeof(PROGITEM)*(m_Num+PROGREZERVA));
		if (dst == NULL) return -1;		// je chyba realokace ?
		m_Items = dst;			// nastavení nové adresy bufferu
		m_Max = m_Num + PROGREZERVA; // nová velikost bufferu
	}

// omezení indexu rodièe (-1 = není rodiè)
	i = item->parent;			// požadovaný index rodièe
	if ((i < -1) || (i >= m_Num)) // je platný index rodièe ?
	{
		i = -1;					// položka nemá rodièe
		item->parent = i;		// oprava indexu rodièe
	}

// omezení indexu položky (i = index rodièe, -1 = není rodiè)
	if ((Index < 0) || (Index > m_Num)) // je platný index položky ?
		Index = m_Num;			// omezení indexu položky na konec
	if (Index < i+1)			// je položka za rodièem ?
		Index = i+1;			// pro parent = -1 bude Index = 0

// oprava indexu, aby neležel v podvìtvi (i = index rodièe, -1 = není)
	after = i;					// pøedešlá položka = rodiè (-1 = není)
	j = i+1;					// první potomek rodièe (pro -1 bude = 0)
	while (j < Index)			// dokud je položka pøed indexem
	{
		if (m_Items[j].parent != i) // má ještì položka stejného rodièe ?
			break;				// nemá již stejného rodièe - konec
		after = j;				// bude to pøedcházející položka
		j += m_Items[j].items;	// posun ukazatele na následující položku
	}
	Index = j;					// nalezený požadovaný index

// oprava první a následující položky k zobrazení
	if (Index < m_First)		// vloženo pøed zobrazený poèátek ?
		m_First++;				// poèátek se odsune
	if (Index <= m_Next)		// vloženo pøed nezobrazený konec ?
		m_Next++;				// nezobrazený konec se odsune

// odsun zbývajících položek
	src = &(m_Items[Index]);	// zdroj - položka na vkládané pozici
	dst = &(m_Items[Index+1]);	// cíl - následující pozice
	if (Index < m_Num)			// jsou nìjaké položky k odsunutí ?
		memmove(dst,src,sizeof(PROGITEM)*(m_Num-Index)); // odsun položek
	m_Num++;					// zvýšení èítaèe poètu položek

// inicializace položky (src = adresa k uložení nové položky)
	memcpy(src, item, sizeof(PROGITEM)); // kopie obsahu položky
	src->htree = NULL;			// není položka stromu
	src->counter = 0;			// nulování èítaèe odkazù na položku
	src->childs = 0;			// není žádný potomek
	src->items = 1;				// celkový poèet prvkù ve vìtvi

// korekce odkazù na rodièe v následujících položkách
	for (i = Index+1; i < m_Num; i++) // oprava od následující položky
	{
		if (m_Items[i].parent >= Index) // je odkaz na rodiè za indexem ?
			m_Items[i].parent++;	// oprava odkazu na rodièe
	}

// zvýšení èítaèe potomkù u rodièe
	i = src->parent;			// index rodièe
	if (i != -1)				// je platný rodiè ?
		m_Items[i].childs++;	// zvýšení èítaèe potomkù u rodièe

// zvýšení èítaèù prvkù u rodièù (i = rodiè)
	while (i != -1)				// bude dalši rodiè ?
	{
		m_Items[i].items++;		// zvýšení èítaèe prvkù u dorièe
		i = m_Items[i].parent;	// pøedcházející rodiè
	}

// korekce aktivní definované položky
	if (Index <= m_AktDef)		// je položka pøed aktivní definovanou ?
		m_AktDef++;				// oprava aktivní definované položky
	
// korekce referencí z jiných bufferù do tohoto bufferu
	for (b = 0; b < PROGBUFNUM; b++) // ukazatel èísla bufferu
	{
		if (b != m_BufID)		// nekoriguje se tento buffer
		{
			buf = &m_ProgBuf[b]; // adresa bufferu
			for (i = buf->m_Num-1; i >= 0; i--) // èítání indexu položky dolù
			{
				dst = &(buf->m_Items[i]);	// úschova adresy položky

				if (dst->typ == m_BufID)	// je deklarace na tento buffer ?
					if (dst->refer >= Index) // je index na odsunutou položku ?
						dst->refer++;		// oprava indexu odkazu

				if (dst->data == m_BufID)	// jsou data v tomto bufferu ?
					if (dst->index >= Index) // je index na odsunutou položku ?
						dst->index++;		// oprava indexu odkazu
			}
		}
	}

// zvýšení èítaèe referencí u deklaraèního vzoru
	if ((src->typ != -1) && (src->refer != -1)) // je platný odkaz ?
		m_ProgBuf[src->typ].m_Items[src->refer].counter++; // oprava èítaèe odkazù

// test, zda má být položka vložena do stromu
	if ((m_Tree != NULL) &&					// je strom ?
		(Index >= m_First) &&				// je položka za poèátkem zobrazení ?
		(Index < m_Next))					// je položka pøed koncem zobrazení ?
	{

// test, zda je rodiè zobrazen ve stromu (kvùli jeho aktualizaci)
		if ((src->parent >= m_First) &&		// je rodiè za poèátkem zobrazení ?
				(src->parent < m_Next))		// je rodiè pøed koncem zobrazení ?
		{

// nastavení nového poètu potomkù u rodièe a pøíprava handle rodièe položky
			tvs.hParent = m_Items[src->parent].htree; // identifikátor rodièe položky
			parItem.mask = TVIF_CHILDREN | TVIF_HANDLE;	// maska - opravuje se poèet potomkù
			parItem.hItem = tvs.hParent;		// handle položky (= rodiè)
			parItem.cChildren = m_Items[src->parent].childs; // nový poèet potomkù rodièe
			m_Tree->SetItem(&parItem);			// nastavení nového poètu potomkù rodièe
		}
		else
			tvs.hParent = NULL;				// jinak položka nemá rodièe

// urèení položky, za kterou má být nová položka vložena
		if (after == src->parent)			// je to první položka za rodièem ?
			tvs.hInsertAfter = TVI_FIRST;	// položka vložena na zaèátek seznamu
		else
			tvs.hInsertAfter = m_Items[after].htree; // jinak handle pøedešlé položky

// pøíprava masky, stavu a ostatních parametrù položky
		param = src->param;					// meziúschova parametrù položky

		tvs.item.mask = TVIF_CHILDREN | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_STATE | TVIF_TEXT;
		tvs.item.stateMask = TVIS_BOLD | TVIS_CUT | TVIS_EXPANDED | TVIS_STATEIMAGEMASK;
		tvs.item.state = INDEXTOSTATEIMAGEMASK(STATE_NONE);
		if (m_BufID == BufEdiID)			// lze to jen v editoru
			if (src->parent != -1)			// musí být platný rodiè
				if (m_Items[src->parent].param & PR_GET_COMMAND) // musí být použito jako pøíkaz
				{
					model = src->model;		// meziúschova modelu
					if ((param & (PR_GET_EXPRES | PR_GET_BOOL)) ||
						((model > TYP_FUNC) && (model < TYP_FUNC_)) ||
						(model == TYP_FNT) || (model == TYP_FTT))
						tvs.item.state = INDEXTOSTATEIMAGEMASK(STATE_SET);
				}

		if (param & (PR_LOCK | PR_LOCK_DEP)) tvs.item.state |= TVIS_BOLD;	// zvýraznìní
		if (param & (PR_OFF | PR_OFF_DEP)) tvs.item.state |= TVIS_CUT;	// zešednutí
		if (param & PR_EXP) tvs.item.state |= TVIS_EXPANDED; // rozvinutí
		tvs.item.cChildren = 0;				// poèet potomkù (zatím není žádný)

// nalezení platné ikony
		dst = src;							// adresa nové položky
		while ((dst->icon == -1) &&			// dokud je ikona implicitní
				(dst->typ != -1) &&			// ... a je platný blok s deklarací
				(dst->refer != -1))			// ... a je platný index položky s deklarací
			dst = &(m_ProgBuf[dst->typ].m_Items[dst->refer]); // položka pøedešlé deklarace
		tvs.item.iImage = dst->icon;		// index ikony položky
		tvs.item.iSelectedImage = dst->icon; // index vybrané ikony položky

// nalezení platného textu
		dst = src;							// adresa nové položky
		buf = this;							// adresa tohoto bufferu
		while ((dst->name == -1) &&			// dokud je text implicitní
			(dst->typ != -1) &&				// ... a je platný blok s deklarací
			(dst->refer != -1))				// ... a je platný index položky s deklarací
		{
			buf = &m_ProgBuf[dst->typ];		// adresa bufferu s deklarací
			dst = &(buf->m_Items[dst->refer]); // adresa položky s deklarací
		}

		if (dst->name != -1)				// je text položku platný ?
		{
			txt = buf->m_Text->Get(dst->name); // naètení textu k položce
			tvs.item.pszText = txt.GetBuffer(1); // nastavení adresy textu
		}
		else
			tvs.item.pszText = NULL;		// jinak položka nemá text

// vložení položky do stromu
		src->htree = m_Tree->InsertItem(&tvs); // vložení položky do stromu
	}

// navrácení opraveného indexu
	return Index;
}


////////////////////////////////////////////////////////////////////
// zrušení položky z bufferu (rekurzivní, se zrušením potomkù!)
// na rušené položky se nesmí nic odkazovat (counter = 0 !)
 
void CProgBuf::Delete(short int Index)
{
// pøíprava lokálních promìnných
	short int childs;				// èítaè potomkù položky
	short int parent;				// index rodièe rušené položky
	short int i, b;					// pracovní èítaèe
	CProgBuf* buf;					// adresa bufferu pøi korekci odkazù
	PROGITEM* dst;					// pracovní ukazatel položek
	TV_ITEM parItem;				// položka pro opravu rodièe ve stromu

// kontrola indexu položky (musí být platný)
	if ((Index < 0) || (Index >= m_Num)) return;

// kontrola - na položku se nesmí nic odkazovat
	ASSERT(m_Items[Index].counter == 0);

// nejdøíve zrušení potomkù (rekurzivní)
	childs = m_Items[Index].childs;	// poèet pøímých potomkù ke zrušení
	for (i = 0; i < childs; i++)
		Delete(Index+1);			// zrušení následující položky (=potomek)

// kontrola - položka teï již nesmí mít žádného potomka
	ASSERT(m_Items[Index].childs == 0);	// poèet potomkù
	ASSERT(m_Items[Index].items == 1);	// poèet prvkù v této vìtvi

// úschova rodièe položky
	parent = m_Items[Index].parent;	// index rodièe rušené položky

// zrušení položky ze stromu
	if ((m_Tree != NULL) &&			// je platný strom ?
		(Index >= m_First) &&		// je za první zobrazenou položkou ?
		(Index < m_Next))			// je pøed poslední (nezobrazenou) položkou ?
		m_Tree->DeleteItem(m_Items[Index].htree); // zrušení položky ze stromu

// oprava první a následující položky k zobrazení
	if (Index < m_First) m_First--;	// oprava první položky, je-li pod ní
	if (Index < m_Next) m_Next--;	// oprava následující položky, je-li pod ní

// korekce aktivní definované položky
	if (Index < m_AktDef)			// je položka pøed aktivní definovanou ?
		m_AktDef--;					// oprava aktivní definované položky
	else
		if (Index == m_AktDef)		// je rušena aktivní definovaná položka ?
			m_AktDef = -1;			// položka bude neplatná

// snížení èítaèe referencí u deklaraèní položky
	if ((m_Items[Index].typ != -1) &&	// je platný blok s deklarací ?
		(m_Items[Index].refer != -1))	// je platný index deklaraèní položky ?
		m_ProgBuf[m_Items[Index].typ].m_Items[
			m_Items[Index].refer].counter--;	// snížení èítaèe referenèních odkazù

// zrušení textu ze seznamu (ponechá index - trochu se to èasem nafoukne)
	i = m_Items[Index].name;		// index textové položky
	if (i != -1) m_Text->ElementAt(i).Empty(); // vyprázdnìní textové položky

// pøísun zbývajících položek
	if (Index < m_Num-1)			// jsou nìjaké položky k pøisunutí ?
		memmove(&(m_Items[Index]),	// pøísun zbývajících položek
			&(m_Items[Index+1]),
			sizeof(PROGITEM)*(m_Num-1-Index));
	m_Num--;						// snížení poètu prvkù v bufferu

// korekce odkazù na rodièe v následujících položkách
	for (i = Index; i < m_Num; i++)	// cyklus až po konec bufferu
		if (m_Items[i].parent > Index) // je rodiè položky za rušenou položkou ?
			m_Items[i].parent--;	// snížení indexu rodièe položky

// korekce referencí v ostatních bufferech
	for (b = 0; b < PROGBUFNUM; b++)	// cyklus pøed všechny buffery
	{
		if (b != m_BufID)			// tento buffer se nekoriguje
		{
			buf = &m_ProgBuf[b];	// adresa bufferu
			for (i = buf->m_Num-1; i >= 0; i--) // èítání indexu položky dolù
			{
				dst = &(buf->m_Items[i]);	// úschova adresy položky

				if (dst->typ == m_BufID)	// je deklarace na tento buffer ?
					if (dst->refer > Index) // je index na pøisunutou položku ?
						dst->refer--;		// oprava indexu odkazu

				if (dst->data == m_BufID)	// jsou data v tomto bufferu ?
					if (dst->index > Index) // je index na pøisunutou položku ?
						dst->index--;		// oprava indexu odkazu
			}
		}
	}

// snížení èítaèù prvkù u rodièù
	i = parent;								// index rodièe
	while (i != -1)							// dokud je nìjaký platný rodiè
	{
		m_Items[i].items--;					// snížení poètu prvkù u rodièe
		i = m_Items[i].parent;				// index dalšího rodièe
	}

// snížení poètu pøímých potomkù u rodièe
	if (parent != -1)						// je platný rodiè ?
	{
		m_Items[parent].childs--;			// snížení poètu pøímých potomkù u rodièe

// nastavení nového poètu potomkù u rodièe ve stromu
		if ((m_Tree != NULL) &&				// je platný strom ?
			(parent >= m_First) &&			// je rodiè za první soubrazenou položkou ?
			(parent < m_Next))				// je rodiè pøed následující (nezobrazenou) položkou ?
		{
			parItem.hItem = m_Items[parent].htree; // handle položky rodièe
			parItem.mask = TVIF_CHILDREN | TVIF_HANDLE; // maska platných údajù
			parItem.cChildren = m_Items[parent].childs; // poèet potomkù rodièe
			m_Tree->SetItem(&parItem);		// nastavení parametrù rodièe
		}
	}
}


////////////////////////////////////////////////////////////////////
// nalezení položky podle handle (vrací index, -1 = nenalezeno)

short int CProgBuf::SrcItem(HTREEITEM hItem)
{
	int i;									// pracovní èitaè

// nalezení položky
	if (hItem != NULL)						// je handle položky platné ?
		for (i = m_Num-1; i >= 0; i--)		// cyklus pøed všechny položky
			if (m_Items[i].htree == hItem)	// je to hledaná položka ?
				return i;					// index nalezené položky

// položka nenalezena
	return -1;								// pøíznak nenalezení položky
}


////////////////////////////////////////////////////////////////////
// pøekreslení (aktualizace) stromu

void CProgBuf::ReDisp()
{
	TV_INSERTSTRUCT tvs;					// vkládaná položka do stromu
	PROGITEM*	item;						// adresa zobrazované položky
	PROGITEM*	item2;						// pracovní adresa pro nalezení ikony	
	CString		txt;						// buffer nalezeného textu k položce
	CProgBuf*	buf;						// ukazatel bufferu pøi hledáni textu
	int			i;							// pracovní èítaè
	short int	param;						// meziúschova parametrù položky
	short int	model;						// meziúschova modelu

	m_AktDef = -1;							// není aktivni definovaná položka

// kontrola, zda je strom platný
	if (m_Tree == NULL) return;

// zrušení všech pùvodních položek stromu
	m_Tree->DeleteAllItems();

// vynulování handle všech položek v bufferu
	for (i = 0; i < m_Num; i++)
		m_Items[i].htree = NULL;

// cyklus pøes všechny zobrazené položky bufferu
	for (i = m_First; i < m_Next; i++)
	{
// adresa zobrazované položky
		item = &m_Items[i];

// pøíprava handle rodièe položky
		if (item->parent < m_First)			// je rodiè položky zobrazen ?
			tvs.hParent = NULL;				// rodiè nezobrazen
		else
			tvs.hParent = m_Items[item->parent].htree; // handle rodièe položky

// handle pøedcházející položky - vkládá se vždy na konec
		tvs.hInsertAfter = TVI_LAST;

// maska platných dat položky
		tvs.item.mask = TVIF_CHILDREN | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_STATE | TVIF_TEXT;

// pøíprava stavu položky
		param = item->param;					// meziúschova parametrù položky

		tvs.item.stateMask = TVIS_BOLD | TVIS_CUT | TVIS_EXPANDED | TVIS_STATEIMAGEMASK;
		tvs.item.state =  INDEXTOSTATEIMAGEMASK(STATE_NONE);

		if (m_BufID == BufEdiID)			// lze to jen v editoru
			if (item->parent != -1)			// musí být platný rodiè
				if (m_Items[item->parent].param & PR_GET_COMMAND) // musí být použito jako pøíkaz
				{
					model = item->model;	// meziúschova modelu
					if ((param & (PR_GET_EXPRES | PR_GET_BOOL)) ||
						((model > TYP_FUNC) && (model < TYP_FUNC_)) ||
						(model == TYP_FNT) || (model == TYP_FTT))
						tvs.item.state = INDEXTOSTATEIMAGEMASK(STATE_SET);
				}

		if (param & (PR_LOCK | PR_LOCK_DEP)) tvs.item.state |= TVIS_BOLD;	// zvýraznìní
		if (param & (PR_OFF | PR_OFF_DEP)) tvs.item.state |= TVIS_CUT;	// zešednutí
		if (param & PR_EXP) tvs.item.state |= TVIS_EXPANDED; // rozvinutí

// ostatní parametry položky
		tvs.item.cchTextMax = 0;
		tvs.item.cChildren = item->childs;	// poèet pøímých potomkù položky

// nalezení platné ikony
		item2 = item;						// výchozí adresa položky
		while ((item2->icon == -1) &&		// dokus je ikona implicitní
			(item2->typ != -1) &&			// ... a je platný blok s deklarací
			(item2->refer != -1))			// ... a je platný index s deklarací
			item2 = &(m_ProgBuf[item2->typ].m_Items[item2->refer]); // adresa deklaraèní položky
		tvs.item.iImage = item2->icon;			// index ikony
		tvs.item.iSelectedImage = item2->icon;	// index vybrané ikony

// nalezení platného textu
		item2 = item;						// výchozí adresa položky
		buf = this;							// adresa tohoto bufferu
		while ((item2->name == -1) &&		// dokud je text implicitní
			(item2->typ != -1) &&			// ... a je platný blok s deklarací
			(item2->refer != -1))			// ... a je platný index položky s deklarací
		{
			buf = &m_ProgBuf[item2->typ];	// adresa bufferu s deklarací
			item2 = &(buf->m_Items[item2->refer]); // adresa položky s deklarací
		}

		if (item2->name != -1)				// je text položky platný ?
		{
			txt = buf->m_Text->Get(item2->name); // naètení textu k položce
			tvs.item.pszText = txt.GetBuffer(1); // nastavení adresy textu
		}
		else
			tvs.item.pszText = NULL;		// jinak položka nemá text

// vložení položky do stromu
		item->htree = m_Tree->InsertItem(&tvs);
	}
}


/////////////////////////////////////////////////////////////////////////////
// kopie vìtve prvkù z jiného bufferu do tohoto
//
// provádí korekce:
//		- nulování pøíznaku PR_INTERNAL
//		- zajištìní kopírování nìkterých položek bez potomkù
//		- zmìna reference na zdrojové okno
//		- rozvinutí vìtve pøi kopii ze stromu struktur
//		  nebo pøi kopii do nerozvinuté položky
//		- kopíruje definici obsahu funkce (jen není-li pøesun)
//
// vstupní promìnné:
//		dst		- index cílové položky
//		parent	- index rodièe cílové položky
//		bufID	- ID zdrojového bufferu
//		src		- index zdrojové položky
//		move	- pøíznak módu pøesunu (nekopírovat definice funkcí)
//
// vrací opravený index cílové položky

short int CProgBuf::Copy(short int dst, short int parent, short int bufID, short int src, BOOL move)
{
	return Copy2(dst, parent, bufID, src, move, TRUE);
}


short int CProgBuf::Copy2(short int& dst, short int parent, short int bufID, short int& src, BOOL move, BOOL first)
{
// lokální promìnné
	int result;			// navrácený výsledek - opravený index cílové položky
	PROGITEM item;		// buffer kopírované položky
	int i;				// pracovní èítaè
	CString txt;		// buffer pøi kopii textu položky

// naètení zdrojové položky do pracovního bufferu
	memcpy(&item, &(m_ProgBuf[bufID].m_Items[src]), sizeof(PROGITEM));

// nastavení rodièe
	item.parent = parent;

// zrušení pøíznaku interní funkce
	item.param &= ~PR_INTERNAL;

// test, zda se mají kopírovat potomci
	if	(
		 (
		  (bufID == BufStrID)			// kopie z bufferu interních struktur
		  &&
		  (
		   (item.refer == FncNum) 		// èíslo se kopíruje bez obsahu
		   ||
		   (item.refer == FncWhileBody) // tìlo cyklu se kopíruje bez pøerušení cyklu
		  )
		 ) 
		 ||
		 (bufID == BufClsID)			// tøídy se kopírují vždy bez potomkù
		)
		item.childs = 0;				// nejsou žádní potomci

// zmìna reference na zdrojové okno, je-li kopie mezi okny
	if (bufID != m_BufID)				// je kopie mezi okny ?
	{
		item.typ = bufID;				// èíslo bloku s deklarací
		item.refer = src;				// index deklaraèní položky
		item.name = -1;					// text položky implicitní
		item.icon = -1;					// ikona položky implicitní
		item.data = -1;					// nejsou data
		item.index = -1;
	}

// kopie textu (pøi pøesunu se text jen pøedefinuje)
	if (item.name != -1)				// je platný text ?
		if (move)						// je mód pøesunu ?
			m_ProgBuf[bufID].m_Items[src].name = -1; // zrušení textu u vzoru
		else
		{
			txt = m_ProgBuf[bufID].m_Text->Get(item.name); // naètení textu položky
			item.name = m_Text->Add(txt);	// pøidání textu do seznamu
		}

// vložení prvku do stromu
	dst = Insert(&item, dst);			// vložení nového prvku
	result = dst;						// navrácený výsledek

// kopie definice programu u funkce
	if ((item.model == TYP_FUNC) &&		// je to funkce ?
		((item.data == BufLocID) ||		// reference na lokální objekty
		(item.data == BufEdiID)))		// ... nebo na editor

		if ((item.index >= 0) &&		// je platný index ?
			(item.index < m_ProgBuf[item.data].m_Num))
	{
//		if (move)						// je mód pøesunu ?
//		{
//			m_ProgBuf[bufID].m_Items[src].index = -1; // nejsou data
//		}
//		else
		{
			item.index = m_ProgBuf[item.data].	// kopie dat funkce
				Copy(m_ProgBuf[item.data].m_Num, -1, item.data, item.index, move);
			m_Items[dst].index = item.index;	// index na definièní data
		}
	}
	
// zajištìní viditelnosti (kopie ze struktur nebo kopie první položky)
	if ((bufID == BufStrID) || first)
		m_Tree->EnsureVisible(m_Items[dst].htree);

// oprava zdrojového indexu pøi kopírování v jednom stromu
	if (bufID == m_BufID)
		if (dst <= src) src++;

// zvýšení ukazatelù položek
	parent = dst;						// položka bude rodièem pro další položky
	src++;								// zvýšení ukazatele zdrojové položky
	dst++;								// zvýšení ukazatele cílové položky

// rekurzní kopie potomkù
	for (i = 0; i < item.childs; i++)	// cyklus pro všechny potomky
		Copy2(dst, parent, bufID, src, move, FALSE); // kopie potomkù

// navrácený výsledek - opravený index této položky
	return result;
}


/////////////////////////////////////////////////////////////////////////////
// nastavení první zobrazené položky s pøípadným pøekreslením,
// požadovaný index mùže být ve vìtvi (nemusí být ROOT)
// navrací TRUE, pokud bylo okno pøekresleno

BOOL CProgBuf::SetFirst(short First)
{
// lokální promìnné
	short Next = m_Num;					// pøíští položka

// zobrazeno vše - není žádná položka nebo není EDIT ani LOCAL
	if ((m_Num == 0) ||					// není žádná položka
		((m_BufID != BufEdiID) &&		// .. nebo je jiný buffer než EDIT
		(m_BufID != BufLocID)))			// .. nebo je jiný buffer než LOCAL
	{
		First = 0;						// nová první položka, aby se zobrazilo vše
	}
	else
	{

// omezení první položky (zde je Next == m_Num)
		if (First >= Next)				// je pøeteèení maximální položky ?
			First = Next-1;				// maximální hodnota první položky
		if (First < 0) First = 0;		// minimální hodnota první položky

// nalezení ROOT položky
		while (m_Items[First].parent != -1)	// je to již ROOT ?
			First = m_Items[First].parent;	// pøesmìrování na rodièe

// aktualizace pøiští položky
		Next = First + m_Items[First].items; // následující položka
		First++;						// korekce první zobrazené položky
	}

// pøekreslení okna, pokud se údaje zmìnily
	if ((First != m_First) || (Next != m_Next)) // zmìnilo se nastavení ?
	{		
		m_First = First;				// nová první položka
		m_Next = Next;					// nová pøíští položka
		ReDisp();						// pøekreslení displeje
		return TRUE;					// pøíznak pøekreslení okna
	}
	else
		return FALSE;					// okno nebylo pøekresleno
}


/////////////////////////////////////////////////////////////////////////////
// nalezení textu k položce

CString CProgBuf::GetName(short Index)
{
// lokální promìnné
	CProgBuf* buf = this;					// ukazatel adresy bufferu
	PROGITEM* item;							// ukazatel adresy položky
	CString result = "";					// návratová hodnota

// kontrola platnosti indexu
	if ((Index >= 0) && (Index < m_Num))	// je index platný ?
	{

// adresa položky
		item = &(buf->m_Items[Index]);		// adresa položky

// nalezení platného textu k prvku
		while ((item->name == -1) &&		// dokud je text implicitní
				(item->typ != -1) &&		// ... a je platný blok s deklarací
				(item->refer != -1))		// ... a je platný index položky s deklarací
		{	
			buf = &(m_ProgBuf[item->typ]);	// adresa bufferu s deklarací
			item = &(buf->m_Items[item->refer]); // adresa položky s deklarací
		}

// naètení textu k položce
		if (item->name != -1)				// je text položky platný ?
			result = buf->m_Text->Get(item->name); // naètení textu k položce
	}

// navrácení textu
	return result;
}


/////////////////////////////////////////////////////////////////////////////
// nalezení položky odkazující se na požadovaná data (-1 = nenalezeno)

short int CProgBuf::SrcDat(short bufID, short Index)
{
	int i;									// pracovní èitaè

// nalezení položky
	for (i = m_Num-1; i >= 0; i--)			// cyklus pøed všechny položky
		if ((m_Items[i].index == Index)	&&	// souhlasí index ?
			(m_Items[i].data == bufID))		// souhlasí buffer ?
			return i;						// index nalezené položky

// položka nenalezena
	return -1;								// pøíznak nenalezení položky
}


/////////////////////////////////////////////////////////////////////////////
// hledání referenèní položky v bufferu od aktuální položky (-1 = nenalezeno)
//
// vstup:
//	bufID - èíslo bufferu hledané reference
//	Index - index hledané reference
//	Smer  - požadovaný smìr (od aktuální položky) 1 nebo -1

short int CProgBuf::SrcRef(short bufID, short Index, short Smer)
{
// lokální promìnné, pøíprava aktuální položky
	HTREEITEM htree = m_Tree->GetSelectedItem(); // nalezení aktivního prvku
	short itemN = SrcItem(htree);			// nalezení indexu aktivního prvku
	if (itemN == -1) itemN = 0;				// korekce, není-li prvek vybrán
	PROGITEM* item = &(m_Items[itemN]);		// adresa prvku
	short i;								// èítaè prvkù

// cyklus pøes všechny položky
	for (i = m_Num-1; i >= 0; i--)			// cyklus pøes všechny položky
	{

// zvýšení ukazatele položky
		itemN += Smer;						// zvýšení èísla položky
		item += Smer;						// zvýšení adresy položky

		if (itemN >= m_Num)					// je pøeteèení èísla položky ?
		{
			itemN = 0;						// korekce èísla položky
			item = m_Items;					// korekce adresy položky
		}

		if (itemN < 0)						// je podteèení èísla položky ?
		{
			itemN = m_Num-1;				// korekce èísla položky
			item = &(m_Items[itemN]);		// korekce adresy položky
		}

// test, zda to je hledaná položka
		if ((item->typ == bufID) &&			// souhlasí referenèní buffer ?
			(item->refer == Index))			// souhlasí referenèní index ?
		{
			return itemN;					// index nalezené položky
		}
	}
	return -1;								// položka nenalezena
}


/////////////////////////////////////////////////////////////////////////////
// nalezení aktivní položky (-1 = není žádná položka)

short int CProgBuf::GetAkt()
{
	return SrcItem(m_Tree->GetSelectedItem());
}


/////////////////////////////////////////////////////////////////////////////
// nastavení aktivní položky (-1 = vypnuta)

void CProgBuf::SetAkt(short Index)
{
	if ((Index < 0) || (Index >= m_Num))	// je index platný ?
		m_Tree->SelectItem(NULL);			// zrušení výbìru
	else
		m_Tree->SelectItem(m_Items[Index].htree); // nastavení aktivní položky
}


/////////////////////////////////////////////////////////////////////////////
// oznaèení definované položky (-1 = odznaèení)

void CProgBuf::SetDef(short int Index)
{
// korekce indexu
	if ((Index >= m_Num) || (Index < 0))	// je index platný ?
		Index = -1;							// pøíznak neplatnosti indexu

// kontrola, zda se položka mìní
	if (Index == m_AktDef) return;			// položka je již nastavena

// zrušení oznaèení staré položky
	if ((m_AktDef >= 0) && (m_AktDef < m_Num))
		if (m_Items[m_AktDef].htree != NULL)
			m_Tree->SetItem(m_Items[m_AktDef].htree,
				TVIF_STATE, NULL, 0, 0, INDEXTOSTATEIMAGEMASK(STATE_NONE),
				TVIS_STATEIMAGEMASK, NULL);

// nastavení nové položky
	m_AktDef = Index;						// uložení nové hodnoty
	if (Index != -1)						// má se oznaèení zobrazit ?
		if (m_Items[Index].htree != NULL)
			m_Tree->SetItem(m_Items[Index].htree,
				TVIF_STATE, NULL, 0, 0, INDEXTOSTATEIMAGEMASK(STATE_SELECT),
				TVIS_STATEIMAGEMASK, NULL);
}
