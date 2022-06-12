
/******************************************************************\
*                                                                  *
*                                                                  *
*                   Obsluha programového bufferu                   *
*                                                                  *
*                                                                  *
\******************************************************************/

/*

Nízkoúrovòové operace s bufferem:
---------------------------------
	Insert ......... vložení položky do bufferu
	Delete ......... zrušení položky z bufferu
	ReDisp ......... pøekreslení (nové vygenerování) obsahu stromu

Podpùrné funkce:
----------------
	SetFirst ....... nastavení první zobrazené položky stromu
	GetName ........ nalezení textu k položce
	SrcItem ........ nalezení položky podle handle stromu
	SrcDat ......... nalezení položky s odkazem na data (na definici)
	SrcRef ......... nalezení položky s odkazem na referenci (na deklaraci)
	GetAkt ......... nalezení aktivní položky (kurzor)
	SetAkt ......... nastavení aktivní položky (kurzor)
	SetFocus ....... nastavení zamìøení na okno
	SetDef ......... nastavení ukazatele definované položky (šipka)

Vysokoúrovòové operace s bufferem:
----------------------------------
	DeleteTre ...... zrušení vìtve stromu (vèetnì závislých prvkù a dat)
	MoveTre ........ pøesun vìtve stromu v bufferu (s pøesmìrováním referencí)
	Copy ........... kopie vìtve stromu z jiného bufferu

*/

#include "stdafx.h"
#include "peter.h"
#include "MainFrm.h"
#include "IconBuf.h"
#include "TextBuf.h"
#include "RealBuf.h"
#include "BoolBuf.h"
#include "ProgBuf.h"
#include "MapBuf.h"
#include "EditDial.h"
#include "EditSprt.h"
#include "EditIcon.h"
#include "EditMap.h"
#include "Prog.h"


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
	m_Items = NULL;

// inicializace ukazatelù
	m_Num = 0;					// není žádná položka
	m_Max = 0;					// souèasná velikost bufferu
	m_First = 0;				// první zobrazená položka bufferu
	m_Next = 0;					// následující (nezobrazená) položka bufferu
	m_Tree = NULL;				// není strom
	m_ProgBuf = NULL;			// neni mapa bufferù programù
	m_AktDef = -1;				// není aktivni definovaná položka
	m_ReIcon = FALSE;			// není požadavek pøezobrazení stromù a oken
}

CProgBuf::~CProgBuf()
{
	Aloc(m_Items,0);			// zrušení datového bufferu
}


/******************************************************************\
*                                                                  *
*                                                                  *
*                  Nízkoúrovòové operace s bufferem                *
*                                                                  *
*                                                                  *
\******************************************************************/


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

// zvýšení velikosti bufferu
	if (m_Num >= m_Max)			// je pøeteèení velikosti ?
	{
		m_Max = m_Num + PROGREZERVA; // nová velikost bufferu
		Aloc(m_Items, sizeof(PROGITEM)*m_Max); // realokace bufferu
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
				if ((m_Items[src->parent].param & PR_GET_COMMAND) || // musí být použito jako pøíkaz
					(m_Items[src->parent].model == TYP_FUNC))	// nebo je jako parametr funkce
				{
					model = src->model;		// meziúschova modelu
					if (((param & (PR_GET_EXPRES | PR_GET_BOOL)) ||
						((model > TYP_FUNC) && (model < TYP_FUNC_)) ||
						(model == TYP_FNT) || (model == TYP_FTT)) &&
						(model != TYP_CASE_TEST))
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
//	if (i != -1) m_Text->ElementAt(i).Empty(); // vyprázdnìní textové položky
	if (i != -1) m_Text->Delete(i);	// vyprázdnìní textové položky

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
				if ((m_Items[item->parent].param & PR_GET_COMMAND) || // musí být použito jako pøíkaz
					(m_Items[item->parent].model == TYP_FUNC))	// nebo je jako parametr funkce
				{
					model = item->model;	// meziúschova modelu
					if (((param & (PR_GET_EXPRES | PR_GET_BOOL)) ||
						((model > TYP_FUNC) && (model < TYP_FUNC_)) ||
						(model == TYP_FNT) || (model == TYP_FTT)) &&
						(model != TYP_CASE_TEST))
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



/******************************************************************\
*                                                                  *
*                                                                  *
*                          Podpùrné funkce                         *
*                                                                  *
*                                                                  *
\******************************************************************/


/////////////////////////////////////////////////////////////////////////////
// nastavení první zobrazené položky s pøípadným pøekreslením,
// požadovaný index mùže být ve vìtvi (nemusí být ROOT)
// navrací TRUE, pokud bylo okno pøekresleno

BOOL CProgBuf::SetFirst(short First)
{
// lokální promìnné
	short Next = m_Num;					// pøíští položka

// neplatná první položka
	if (First == -1)
		First = Next;

// zobrazeno vše - není žádná položka nebo není EDIT ani LOCAL
	if ((m_Num == 0) ||					// není žádná položka
		((m_BufID != BufEdiID) &&		// .. nebo je jiný buffer než EDIT
		(m_BufID != BufLocID)))			// .. nebo je jiný buffer než LOCAL
	{
		First = 0;						// nová první položka, aby se zobrazilo vše
	}
	else
	{
		if (First != Next)
		{

// omezení první položky (zde je Next == m_Num)
			if (First >= Next)			// je pøeteèení maximální položky ?
				First = Next-1;			// maximální hodnota první položky
			if (First < 0) First = 0;	// minimální hodnota první položky

// nalezení ROOT položky
			while (m_Items[First].parent != -1)	// je to již ROOT ?
				First = m_Items[First].parent;	// pøesmìrování na rodièe

// aktualizace pøiští položky
			Next = First + m_Items[First].items; // následující položka
			First++;					// korekce první zobrazené položky
		}
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
// nalezení ikony k položce

short CProgBuf::GetIcon(short Index)
{
// lokální promìnné
	PROGITEM* item;							// ukazatel adresy položky
	short result = -1;						// návratová hodnota

// kontrola platnosti indexu
	if ((Index >= 0) && (Index < m_Num))	// je index platný ?
	{

// adresa položky
		item = &(m_Items[Index]);			// adresa položky

// nalezení platné ikony k položce
		while ((item->icon == -1) &&		// dokud je ikona implicitní
				(item->typ != -1) &&		// ... a je platný blok s deklarací
				(item->refer != -1))		// ... a je platný index položky s deklarací
			item = &(m_ProgBuf[item->typ].m_Items[item->refer]); // položka pøedešlé deklarace

// naètení ikony k položce
		result = item->icon;
	}

// navrácení textu
	return result;
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


/////////////////////////////////////////////////////////////////////////////
// nalezení položky odkazující se na požadovaná data (-1 = nenalezeno)

short int CProgBuf::SrcDat(short bufID, short Index)
{
	short i;								// pracovní èitaè

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
	if (m_Tree == NULL) return;				// je strom platný ?

	if ((Index < 0) || (Index >= m_Num))	// je index platný ?
		m_Tree->SelectItem(NULL);			// zrušení výbìru
	else
		m_Tree->SelectItem(m_Items[Index].htree); // nastavení aktivní položky
}


/////////////////////////////////////////////////////////////////////////////
// nastavení zamìøení na okno

void CProgBuf::SetFocus()
{
	if (m_Tree != NULL)						// je okno stromu platné ?
		m_Tree->SetFocus();					// nastavení zamìøení na strom
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



/******************************************************************\
*                                                                  *
*                                                                  *
*                 Vysokoúrovòové operace s bufferem                *
*                                                                  *
*                                                                  *
\******************************************************************/


////////////////////////////////////////////////////////////////////
// zrušení vìtve stromu (vèetnì závislých prvkù a dat)
//
// - zruší referenèní položky, které referují na nìkterý prvek ve vìtvi
// - zruší datové buffery, na které ukazují položky ve vìtvi
 
void CProgBuf::DeleteTre(short Index)
{
// pøíprava lokálních promìnných
	short i, b, nxt;				// pracovní èítaèe
	CProgBuf* buf;					// adresa bufferu pøi korekci odkazù
	PROGITEM* item;					// pracovní ukazatel položek

// kontrola indexu položky (musí být platný)
	if ((Index < 0) || (Index >= m_Num)) return;

// zrušení referujících položek
	nxt = Index + m_Items[Index].items;	// následující prvek
	for (b = 0; b < PROGBUFNUM; b++)	// cyklus pøed všechny buffery
	{
		if (b != m_BufID)			// tento buffer se nekoriguje
		{
			buf = &m_ProgBuf[b];	// adresa bufferu
			for (i = buf->m_Num-1; i >= 0; i--) // èítání indexu položky dolù
			{
				item = &(buf->m_Items[i]);	// úschova adresy položky

				if (item->typ == m_BufID)	// je deklarace na tento buffer ?
				{
					if ((item->refer >= Index) &&
						(item->refer < nxt))
						buf->DeleteTre(i);	// zrušení prvku
				}
			}
		}
	}

// zrušení datových bufferù (pøedpokládá se kontrola indexu u DeleteTre)
	for (i = Index; i < nxt; i++)
	{
		item = &(m_Items[i]);		// adresa položky

		if (item->index != -1)
		{
			if ((item->data >= 0) && 
				(item->data < PROGBUFNUM))
				m_ProgBuf[item->data].DeleteTre(item->index); // zrušení položky

			if (item->data == BufTxtID)	// reference na textový buffer
				m_Text->Delete(item->index);

			item->data = -1;
			item->index = -1;
		}
	}

// zrušení prvku
	Delete(Index);
}


/////////////////////////////////////////////////////////////////////////////
// pøesun vìtve stromu uvnitø bufferu (vèetnì zmìn referencí), vrací cílový index
//
// - pøesmìruje reference na položky ve vìtvi
// - pøidá nebo ubere parametry funkcí v programu
// - pøidá nebo ubere vlastnosti tøíd 

short CProgBuf::MoveTre(short dst, short parent, short src) 
{
// lokální promìnné
	short srcParent;							// rodiè zdrojového prvku
	short result;								// navrácený výsledek - opravený index cílové položky
	PROGITEM item;								// buffer pøesouvané položky
	PROGITEM* itemSrc;							// zdrojová položka
	PROGITEM* itemDst;							// cílová položka
	PROGITEM* itemRef;							// ukazatel položek pøi zmìnì referencí
	short i,b;									// pracovní èítaèe
	short refer;								// hledaný referenèní index
	short last;									// poslední výskyt odkazu na funkci pøi hledání
	CProgBuf* buf;								// ukazatel bufferu

// zdrojový prvek musí být platný
	ASSERT((src >= 0) && (src < m_Num));		// je zdrojový prvek platný ?

	if ((src < 0) || (src >= m_Num))			// je zdrojový prvek platný ?
		return -1;								// jinak konec - nový index neplatný
	itemSrc = &(m_Items[src]);					// adresa zdrojové položky

// rodiè zdrojového prvku
	srcParent = itemSrc->parent;				// rodiè zdrojového prvku

// omezení cílové pozice
	if (dst < 0) dst = 0;						// omezení minimální hodnoty cílového prvku
	if (dst > m_Num) dst = m_Num;				// omezení maximální hodnoty cílového prvku

// omezení cílového rodièe
	if ((parent < -1) || (parent >= m_Num))		// je platný rodiè ?
		parent = -1;							// položka nebude mít rodièe

// kontrola, zda není jen pøetažení na místì
	if (((src == dst) || (src == dst-1)) &&		// je zdrojová a cílová pozice shodná ?
		(srcParent == parent))					// je rodiè shodný ?
		return src;								// pøi pøetažení na místì se nic nedìje

// naètení zdrojového prvku
	memcpy(&item, itemSrc, sizeof(PROGITEM));	// kopie obsahu prvku do bufferu

// nastavení nového rodièe
	item.parent = parent;

// zrušení ukazatelù u staré položky
	itemSrc->data = -1;							// zrušení ukazatele na data (blok)
	itemSrc->index = -1;						// zrušení ukazatele na data (index)
	itemSrc->icon = -1;							// zrušení ukazatele na ikonu
	itemSrc->name = -1;							// zrušení ukazatele na text

// vložení nového prvku do stromu
	dst = Insert(&item, dst);					// vložení nového prvku
	result = dst;								// úschova nového indexu položky
	itemDst = &(m_Items[dst]);					// adresa cílové položky

// oprava zdrojového indexu
	if (src >= dst)								// bude zdrojový index ovlivnìn ?
	{
		src++;									// oprava zdrojového indexu
		itemSrc++;								// oprava adresy staré položky
	}
	if (srcParent >= dst)						// bude zdrojový rodiè ovlivnìn ?
		srcParent++;							// oprava zdrojového rodièe

// zrušení vstupní promìnné u funkce pøi pøesunu ze vstupních promìnných do bìžných promìnných
	if ((m_BufID == BufLocID) &&				// pouze u lokálních deklarací
		(srcParent != -1) &&						// je platný rodiè ?
		((m_Items[srcParent].model == TYP_IPARAM) &&	// byla to lokální promìnná ?
		((parent == -1) || (m_Items[parent].model != TYP_IPARAM)))) // teï již nebude lokální promìnná
	{
		refer = m_ProgBuf[BufObjID].SrcDat(BufLocID, m_Items[srcParent].parent); // nalezení globální deklarace
		last = -1;								// poslední výskyt funkce - zatím nic
		buf = &(m_ProgBuf[BufEdiID]);			// adresa bufferu editoru

		if (refer != -1)						// byla deklarace nalezena ?
		{
			for (i = 0; i < buf->m_Num; i++)	// cyklus pøes všechny položky editoru
			{
				itemRef = &(buf->m_Items[i]);	// adresa položky

				if ((itemRef->refer == refer) && // je odkaz na deklaraci ?
					(itemRef->typ == BufObjID))
					last = i;					// poslední výskyt funkce

				if ((itemRef->refer == src) &&	// je odkaz na tuto promìnnou ?
					(itemRef->typ == BufLocID) && // odkaz do lokálního bufferu ?
					(itemRef->parent == last))	// je rodièem tato funkce ?
				{
					buf->Delete(i);				// zrušení položky
					i--;						// oprava ukazatele
				}
			}
		}
	}

// pøesmìrování referencí ze staré položky na novou
	if (itemSrc->counter)						// byly na položku nìjaké reference ?
	{
		for (b = 0; b < PROGBUFNUM; b++)		// cyklus pøes všechny buffery
		{
			if (b != m_BufID)					// pøeskoèení tohoto bufferu
			{
				buf = &(m_ProgBuf[b]);			// adresa bufferu
				i = buf->m_Num-1;				// èíslo poslední položky
				itemRef = &(buf->m_Items[i]);	// adresa poslední položky

				for (; i >= 0; i--)				// cyklus pøes všechny položky (dolù)
				{
					if ((itemRef->refer == src)	&&	// je reference na položku ?
						(itemRef->typ == m_BufID))	// je deklaraèní odkaz na tento buffer ?
					{
						itemSrc->counter--;		// snížení èítaèe staré položky
						itemRef->refer = dst;	// pøesmìrování reference na novou položku
						itemDst->counter++;		// zvýšení èítaèe nové položky
					}
					itemRef--;					// snížení adresy položky
				}
			}
		}
	}

// teï již nesmí být žádná reference
	ASSERT(itemSrc->counter == 0);				// èítaè referencí musí být = 0

// pøidání vstupní promìnné funkce pøi pøesunu z bìžných promìnných do vstupních
	if ((m_BufID == BufLocID) &&				// pouze u lokálních deklarací
		(parent != -1) &&						// je platný cílový rodiè ?
		(m_Items[parent].model == TYP_IPARAM) &&	// bude to lokální promìnná ?
		((srcParent == -1) || (m_Items[srcParent].model != TYP_IPARAM))) // nebyla to lokální promìnná
	{
		refer = m_ProgBuf[BufObjID].SrcDat(BufLocID, m_Items[parent].parent); // nalezení globální deklarace
		buf = &(m_ProgBuf[BufEdiID]);			// adresa bufferu editoru

		if (refer != -1)						// byla deklarace nalezena ?
		{
			for (i = 0; i < buf->m_Num; i++)	// cyklus pøes všechny položky editoru
			{
				itemRef = &(buf->m_Items[i]);	// adresa položky

				if ((itemRef->refer == refer) && // je odkaz na deklaraci ?
					(itemRef->typ == BufObjID))
				{
					last = buf->Copy(i + dst - parent, i, BufLocID, dst);
					buf->m_Items[last].param |= PR_NOMOVE;
				}
			}
		}
	}

// pøesun potomkù
	src++;										// první potomek - zdroj
	dst++;										// první potomek - cíl
	for (i = itemSrc->childs; i > 0; i--)		// cyklus pøes všechny potomky
	{
		dst = MoveTre(dst, result, src);		// pøesun potomka
		if (src >= dst)							// byl zdrojový ukazatel odsunut ?
			src += m_Items[dst].items;			// oprava zdrojového ukazatele
		if (result >= src)						// je rodiè nad zdrojem ?
			result -= m_Items[dst].items;		// oprava rodièe
		dst += m_Items[dst].items;				// pozice pro dalšího potomka
	}
	src--;										// ukazatel na rodièe

// kontrola - všichni potomci musí být pøesunuti
	ASSERT(m_Items[src].items == 1);			// musela zbýt pouze 1 položka

// oprava indexu cílové položky
	if (src < result)							// bude položka pøisunuta ?
		result--;								// oprava indexu výchozí položky

// zrušení staré položky
	Delete(src);								// zrušení pùvodní zdrojové položky

	return result;
}


/////////////////////////////////////////////////////////////////////////////
// kopie vìtve prvkù z jiného bufferu do tohoto
//
// (u lokální definice funkcí musí být jako první položka vstupní parametry !)
//
// provádí korekce:
//		- nulování pøíznaku PR_INTERNAL
//		- zajištìní kopírování nìkterých položek bez potomkù
//		- zmìna reference na zdrojové okno
//		- duplikace textu
//		- duplikace definièních dat k položce (funkce)
//		- založení definice pro funkci
//		- rozvinutí vìtve pøi kopii ze stromu struktur
//		  nebo pøi kopii do nerozvinuté položky
//
// vstupní promìnné:
//		dst		- index cílové položky
//		parent	- index rodièe cílové položky
//		bufID	- ID zdrojového bufferu
//		src		- index zdrojové položky
//
// vrací opravený index cílové položky

short int CProgBuf::Copy(short int dst, short int parent, short int bufID, short int src)
{
	short retn;

	m_ReIcon = FALSE;
	retn = Copy2(dst, parent, bufID, src);


	if (m_ReIcon)
	{
		Prog->m_Ico32->DeleteImageList();
		delete Prog->m_Ico32;
		Prog->m_Ico32 = m_Icon->GenerList();

		Prog->m_Object.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);
		Prog->m_Local.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);
		Prog->m_Struc.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);
		Prog->m_Class.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);
		Prog->m_Edit.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);

		Prog->m_Object.Invalidate();
		Prog->m_Local.Invalidate();
		Prog->m_Struc.Invalidate();
		Prog->m_Class.Invalidate();
		Prog->m_Edit.Invalidate();

		m_ReIcon = FALSE;
	}

	return retn;
}


short int CProgBuf::Copy2(short int& dst, short int parent, short int bufID, short int& src)
{
// lokální promìnné
	short result;								// navrácený výsledek - opravený index cílové položky
	CProgBuf* buf = &(m_ProgBuf[bufID]);		// zdrojový buffer
	PROGITEM* itemsrc = &(buf->m_Items[src]);	// adresa zdrojové položky
	PROGITEM item;								// buffer kopírované položky
	short src2, src3;							// pracovní ukazatele
	short i;									// pracovní èítaè
	CString txt;								// buffer pøi kopii textu položky
	CProgBuf* buf2;								// pomocný ukazatel na buffer

// naètení zdrojové položky do pracovního bufferu
	memcpy(&item, itemsrc, sizeof(PROGITEM));

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
		 ((bufID == BufClsID) && (item.model != TYP_GROUP))	// tøídy se kopírují bez potomkù (kromì skupiny)
		 ||
		 ((bufID == BufLocID) && (m_BufID == BufEdiID))	// lokální objekty
		 ||
		 ((bufID == BufObjID) && (m_BufID == BufEdiID))	// globální objekty
		)
		item.childs = 0;				// nejsou žádní potomci

// zmìna reference na zdrojové okno, je-li kopie mezi okny
	if (bufID != m_BufID)				// je kopie mezi okny ?
	{
		item.typ = bufID;				// èíslo bloku s deklarací
		item.refer = src;				// index deklaraèní položky

// pøi kopii z okna tøíd zmìna na ROOT položku
		if ((bufID == BufClsID) && (item.model != TYP_GROUP))
		{
			i = src;
			while (buf->m_Items[i].parent != -1)
				i = buf->m_Items[i].parent;
			item.refer = i;

			if (i == src)
			{
				item.data = -1;					// nejsou data
				item.index = -1;
				item.name = -1;					// text položky implicitní
				item.icon = -1;					// ikona položky implicitní
			}
		}
		else
		{
			item.data = -1;					// nejsou data
			item.index = -1;

			if ((bufID != BufClsID) || (item.model != TYP_GROUP))
			{
				item.name = -1;					// text položky implicitní
				item.icon = -1;					// ikona položky implicitní
			}
		}
	}

// duplikace textu
	if (item.name != -1)				// je platný text ?
	{
		txt = buf->m_Text->Get(item.name); // naètení textu položky
		item.name = m_Text->Add(txt);	// pøidání textu do seznamu
	}

// duplikace dat obrázku
	if ((item.model == TYP_PIC) && (m_BufID != BufEdiID))
	{
		item.data = BufPicID;			// data v bufferu obrázkù
		item.index = m_Icon->Duplik(item.index); // duplikace obrázku
		item.icon = item.index;		// ikona
		m_ReIcon = TRUE;				// požadavek aktualizace
	}

// vložení prvku do stromu
	dst = Insert(&item, dst);			// vložení nového prvku
	result = dst;						// navrácený výsledek

// oprava zdrojového indexu pøi kopírování v jednom stromu
	if (bufID == m_BufID)
		if (dst <= src) src++;

// duplikace definice programu (u funkce)
	if ((item.data == BufLocID) ||		// reference na lokální objekty
		(item.data == BufEdiID))		// ... nebo na editor
	{
		buf2 = &(m_ProgBuf[item.data]);	// adresa bufferu

		if ((item.index >= 0) &&		// je platný index ?
			(item.index < buf2->m_Num))
		{
			item.index = buf2->Copy(buf2->m_Num, -1, item.data, item.index);
			m_Items[dst].index = item.index;	// index na definièní data
		}
	}

// duplikace dat textové položky
	if ((item.data == BufTxtID)	&&		// reference na textový buffer
		(item.index != -1))
	{
		m_Items[dst].index = m_Text->Add(m_Text->Get(item.index));
	}

// duplikace dat èíselné položky
	if ((item.data == BufNumID)	&&		// reference na èíselný buffer
		(item.index != -1))
	{
		m_Items[dst].index = m_Real->Add(m_Real->Get(item.index));
	}

// duplikace dat logické položky
	if ((item.data == BufLogID)	&&		// reference na logický buffer
		(item.index != -1))
	{
		m_Items[dst].index = m_Bool->Add(m_Bool->Get(item.index));
	}

// zajištìní definice dat položky
	InitDat(dst);

// pøidání vstupní lokální promìnné - pøidání parametru k funkcím
	if ((m_BufID == BufLocID) &&					// je cílem buffer lokálních objektù ?
		(parent != -1) &&							// je platný cílový rodiè ?
		(m_Items[parent].model == TYP_IPARAM))		// bude to lokální promìnná ?
	{
		src2 = m_ProgBuf[BufObjID].SrcDat(BufLocID, m_Items[parent].parent); // nalezení globální deklarace
		buf2 = &(m_ProgBuf[BufEdiID]);				// adresa bufferu editoru

		if (src2 != -1)								// byla deklarace nalezena ?
		{
			for (i = 0; i < buf->m_Num; i++)		// cyklus pøes všechny položky editoru
			{
				if ((buf2->m_Items[i].refer == src2) && // je odkaz na deklaraci ?
					(buf2->m_Items[i].typ == BufObjID))
				{
					src3 = buf2->Copy(i + dst - parent, i, BufLocID, dst);
					buf2->m_Items[src3].param |= PR_NOMOVE;
				}
			}
		}	
	}

// zajištìní viditelnosti pøi kopii ze struktur
	parent = dst;						// položka bude rodièem pro další položky
	if ((bufID == BufStrID) && (m_Tree != NULL))
		m_Tree->EnsureVisible(m_Items[dst].htree);
	dst++;								// zvýšení ukazatele cílové položky


/////////// globální funkce do editoru - pøidání vstupních parametrù funkce (relokuje buffer!)
// test, zda je kopie globální funkce do editoru
	if ((m_BufID == BufEdiID) &&					// je cílem editor ?
		(bufID == BufObjID) &&						// je zdrojem okno globálních objektù ?
		(itemsrc->model == TYP_FUNC) &&				// je kopírována funkce ?
		(itemsrc->data == BufLocID) &&				// má funkce lokální definici ?
		(itemsrc->index != -1))						// je lokální definice platná ?
	{

// pøíprava indexù vstupních promìnných
// (vstupní parametry musí být jako prvni potomek !)
		buf2 = &(m_ProgBuf[BufLocID]);				// lokální buffer
		src2 = itemsrc->index+2;					// index lokální definice

// kopie lokálních promìnných
		if (buf2->m_Items[src2-1].model == TYP_IPARAM) // jsou to vstupní parametry ?
			for (i = buf2->m_Items[src2-1].childs; i > 0; i--)
			{
				Copy2(dst, parent, BufLocID, src2); // kopie položky
				m_Items[dst-1].param |= PR_NOMOVE;
			}
	}


// rekurzní kopie potomkù
	src++;								// zvýšení ukazatele zdrojové položky
	for (i = 0; i < item.childs; i++)	// cyklus pro všechny potomky
		Copy2(dst, parent, bufID, src); // kopie potomkù

// navrácený výsledek - opravený index této položky
	return result;
}


/////////////////////////////////////////////////////////////////////////////
// vytvoøení dat položky (nejsou-li vytvoøena)

void CProgBuf::InitDat(short Index)
{
// lokální promìnné
	PROGITEM*	item;							// adresa aktuální položky
	PROGITEM	item2;							// buffer vytváøené položky
	short		refer;							// pomocný referenèní index

// kontrola indexu položky
	if ((Index < 0) || (Index >= m_Num))		// je index položky platný ?
		return;

// adresa položky
	item = &(m_Items[Index]);					// adresa položky

// test, zda jsou data již vytvoøena
	if ((item->data != -1) && (item->index != -1)) // jsou již data ?
		return;
	
// test, zda je to globální nebo lokální objekt
	if ((m_BufID == BufObjID) ||				// je to buffer globálních objektù ?
		(m_BufID == BufLocID))					// je to buffer lokálních objektù ?
	{

// vytvoøení dat pro funkci
		if (item->model == TYP_FUNC)				// je to funkce ?
		{	

// vytvoøení deklarace v editaèním oknì
			item2.param = PR_NOMOVE | PR_EXP | PR_GET_COMMAND; // parametry
			item2.model = TYP_FUNC;						// model - jako funkce
			item2.typ = -1;								// blok s deklarací - nepoužívá se
			item2.refer = -1;							// index deklarace - nepoužívá se
			item2.data = -1;							// není buffer s daty
			item2.index = -1;							// není index s daty
			item2.parent = -1;							// není rodiè
			item2.icon = -1;							// ikona (nepoužívá se)
			item2.name = -1;							// jméno (nepoužívá se)
			refer = m_ProgBuf[BufEdiID].Insert(&item2);	// vložení položky do editaèního stromu

// inicializace odkazu z funkce na data pro lokální buffer
			if (m_BufID == BufLocID)					// je cílem okno lokálních objektù ?
			{
				item->data = BufEdiID;					// identifikátor editaèního bloku
				item->index = refer;					// index datové položky
			}
			else
			{

// vytvoøení deklarace v oknì lokálních objektù
				item2.data = BufEdiID;					// odkaz na editaèní buffer
				item2.index = refer;					// index 
				item2.parent = m_ProgBuf[BufLocID].Insert(&item2);	// vložení položky do lokálních objektù

// vložení záhlaví pro vstupní parametry
				item2.param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL; // parametry
				item2.model = TYP_IPARAM;				// model - vstupní parametry
				item2.typ = BufIntID;					// deklarace je v interních funkcích
				item2.refer = FncPar;					// reference na vstupní parametry
				item2.data = -1;						// nejsou data
				item2.index = -1;
				m_ProgBuf[BufLocID].Insert(&item2);		// vložení položky do bufferu

// vložení záhlaví pro výstupní parametr
				item2.param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL | PR_ONE; // parametry
				item2.model = TYP_OPARAM;				// model - výstupni parametr
				item2.refer = FncOut;					// reference na výstupní parametr
				m_ProgBuf[BufLocID].Insert(&item2);		// vložení položky do bufferu

// inicializace odkazu z funkce na data pro globální buffer
				item->data = BufLocID;					// identifikátor lokálního bloku
				item->index = item2.parent;				// index datové položky
			}
		}

// vytvoøení dat pro èíselnou promìnnou
		if (item->model == TYP_REAL)					// je to èíselná promìnná ?
		{
			item->data = BufNumID;						// identifikátor èíselného bufferu
			item->index = m_Real->Add(0);				// vytvoøení nového èísla
		}

// vytvoøení dat pro textovou promìnnou
		if (item->model == TYP_TEXT)					// je to textová promìnná ?
		{
			item->data = BufTxtID;						// identifikátor textového bufferu
			item->index = m_Text->Add(_T(""));			// vytvoøení nového øetìzce
		}

// vytvoøení dat pro logickou promìnnou
		if (item->model == TYP_BOOL)					// je to logická promìnná ?
		{
			item->data = BufLogID;						// identifikátor logického bufferu
			item->index = m_Bool->Add(FALSE);			// vytvoøení nové hodnoty
		}
	}
}

