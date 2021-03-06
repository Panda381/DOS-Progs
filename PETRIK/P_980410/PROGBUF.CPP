
#include "stdafx.h"
#include "peter.h"
#include "TextBuf.h"
#include "ProgBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define PROGREZERVA 100			// rezerva p�i zv�t�ov�n� bufferu

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CProgBuf::CProgBuf()
{
// vytvo�en� datov�ho bufferu
	m_Items = (PROGITEM*) malloc(sizeof(PROGITEM)*PROGREZERVA);
	ASSERT(m_Items != NULL);

// inicializace ukazatel�
	m_Num = 0;					// nen� ��dn� polo�ka
	m_Max = PROGREZERVA;		// sou�asn� velikost bufferu
	m_First = 0;				// prvn� zobrazen� polo�ka bufferu
	m_Next = 0;					// n�sleduj�c� (nezobrazen�) polo�ka bufferu
	m_Tree = NULL;				// nen� strom
	m_ProgBuf = NULL;			// neni mapa buffer� program�
	m_AktDef = -1;				// nen� aktivni definovan� polo�ka
}

CProgBuf::~CProgBuf()
{
	free(m_Items);				// zru�en� datov�ho bufferu
}


////////////////////////////////////////////////////////////////////
// vlo�en� polo�ky do bufferu (-1 = na konec)
// Pozor - pou��t vr�cen� skute�n� index, proto�e jej m��e opravit !!!

short int CProgBuf::Insert(PROGITEM* item, short int Index)
{
// p��prava lok�ln�ch prom�nn�ch
	short int i,j, b;			// pracovn� ��ta�e
	short int after;			// index p�ede�l� polo�ky (pou��v� se p�i vkl�d�n� do stromu)
	PROGITEM* src;				// ukazatel na zdrojovou polo�ku, adresa nov� polo�ky
	PROGITEM* dst;				// ukazatel na c�lovou polo�ku, pracovn� ukazatel polo�ek
	CProgBuf* buf;				// adresa bufferu p�i korekci odkaz� a p�i hled�n� textu
	TV_ITEM parItem;			// opravovan� polo�ka rodi�e ve stromu
	TV_INSERTSTRUCT tvs;		// vkl�dan� polo�ka do stromu
	CString txt;				// buffer textu p�i hled�n� textu k polo�ce
	short int param;			// mezi�schova parametr� polo�ky
	short int model;			// mezi�schova modelu

	ASSERT(item != NULL);		// vkl�dan� polo�ka mus� b�t platn�

// zv��en� velikosti bufferu (-1 = chyba)
	if (m_Num >= m_Max)			// je p�ete�en� velikosti ?
	{
		dst = (PROGITEM*)realloc(m_Items,	// realokace bufferu
			sizeof(PROGITEM)*(m_Num+PROGREZERVA));
		if (dst == NULL) return -1;		// je chyba realokace ?
		m_Items = dst;			// nastaven� nov� adresy bufferu
		m_Max = m_Num + PROGREZERVA; // nov� velikost bufferu
	}

// omezen� indexu rodi�e (-1 = nen� rodi�)
	i = item->parent;			// po�adovan� index rodi�e
	if ((i < -1) || (i >= m_Num)) // je platn� index rodi�e ?
	{
		i = -1;					// polo�ka nem� rodi�e
		item->parent = i;		// oprava indexu rodi�e
	}

// omezen� indexu polo�ky (i = index rodi�e, -1 = nen� rodi�)
	if ((Index < 0) || (Index > m_Num)) // je platn� index polo�ky ?
		Index = m_Num;			// omezen� indexu polo�ky na konec
	if (Index < i+1)			// je polo�ka za rodi�em ?
		Index = i+1;			// pro parent = -1 bude Index = 0

// oprava indexu, aby nele�el v podv�tvi (i = index rodi�e, -1 = nen�)
	after = i;					// p�ede�l� polo�ka = rodi� (-1 = nen�)
	j = i+1;					// prvn� potomek rodi�e (pro -1 bude = 0)
	while (j < Index)			// dokud je polo�ka p�ed indexem
	{
		if (m_Items[j].parent != i) // m� je�t� polo�ka stejn�ho rodi�e ?
			break;				// nem� ji� stejn�ho rodi�e - konec
		after = j;				// bude to p�edch�zej�c� polo�ka
		j += m_Items[j].items;	// posun ukazatele na n�sleduj�c� polo�ku
	}
	Index = j;					// nalezen� po�adovan� index

// oprava prvn� a n�sleduj�c� polo�ky k zobrazen�
	if (Index < m_First)		// vlo�eno p�ed zobrazen� po��tek ?
		m_First++;				// po��tek se odsune
	if (Index <= m_Next)		// vlo�eno p�ed nezobrazen� konec ?
		m_Next++;				// nezobrazen� konec se odsune

// odsun zb�vaj�c�ch polo�ek
	src = &(m_Items[Index]);	// zdroj - polo�ka na vkl�dan� pozici
	dst = &(m_Items[Index+1]);	// c�l - n�sleduj�c� pozice
	if (Index < m_Num)			// jsou n�jak� polo�ky k odsunut� ?
		memmove(dst,src,sizeof(PROGITEM)*(m_Num-Index)); // odsun polo�ek
	m_Num++;					// zv��en� ��ta�e po�tu polo�ek

// inicializace polo�ky (src = adresa k ulo�en� nov� polo�ky)
	memcpy(src, item, sizeof(PROGITEM)); // kopie obsahu polo�ky
	src->htree = NULL;			// nen� polo�ka stromu
	src->counter = 0;			// nulov�n� ��ta�e odkaz� na polo�ku
	src->childs = 0;			// nen� ��dn� potomek
	src->items = 1;				// celkov� po�et prvk� ve v�tvi

// korekce odkaz� na rodi�e v n�sleduj�c�ch polo�k�ch
	for (i = Index+1; i < m_Num; i++) // oprava od n�sleduj�c� polo�ky
	{
		if (m_Items[i].parent >= Index) // je odkaz na rodi� za indexem ?
			m_Items[i].parent++;	// oprava odkazu na rodi�e
	}

// zv��en� ��ta�e potomk� u rodi�e
	i = src->parent;			// index rodi�e
	if (i != -1)				// je platn� rodi� ?
		m_Items[i].childs++;	// zv��en� ��ta�e potomk� u rodi�e

// zv��en� ��ta�� prvk� u rodi�� (i = rodi�)
	while (i != -1)				// bude dal�i rodi� ?
	{
		m_Items[i].items++;		// zv��en� ��ta�e prvk� u dori�e
		i = m_Items[i].parent;	// p�edch�zej�c� rodi�
	}

// korekce aktivn� definovan� polo�ky
	if (Index <= m_AktDef)		// je polo�ka p�ed aktivn� definovanou ?
		m_AktDef++;				// oprava aktivn� definovan� polo�ky
	
// korekce referenc� z jin�ch buffer� do tohoto bufferu
	for (b = 0; b < PROGBUFNUM; b++) // ukazatel ��sla bufferu
	{
		if (b != m_BufID)		// nekoriguje se tento buffer
		{
			buf = &m_ProgBuf[b]; // adresa bufferu
			for (i = buf->m_Num-1; i >= 0; i--) // ��t�n� indexu polo�ky dol�
			{
				dst = &(buf->m_Items[i]);	// �schova adresy polo�ky

				if (dst->typ == m_BufID)	// je deklarace na tento buffer ?
					if (dst->refer >= Index) // je index na odsunutou polo�ku ?
						dst->refer++;		// oprava indexu odkazu

				if (dst->data == m_BufID)	// jsou data v tomto bufferu ?
					if (dst->index >= Index) // je index na odsunutou polo�ku ?
						dst->index++;		// oprava indexu odkazu
			}
		}
	}

// zv��en� ��ta�e referenc� u deklara�n�ho vzoru
	if ((src->typ != -1) && (src->refer != -1)) // je platn� odkaz ?
		m_ProgBuf[src->typ].m_Items[src->refer].counter++; // oprava ��ta�e odkaz�

// test, zda m� b�t polo�ka vlo�ena do stromu
	if ((m_Tree != NULL) &&					// je strom ?
		(Index >= m_First) &&				// je polo�ka za po��tkem zobrazen� ?
		(Index < m_Next))					// je polo�ka p�ed koncem zobrazen� ?
	{

// test, zda je rodi� zobrazen ve stromu (kv�li jeho aktualizaci)
		if ((src->parent >= m_First) &&		// je rodi� za po��tkem zobrazen� ?
				(src->parent < m_Next))		// je rodi� p�ed koncem zobrazen� ?
		{

// nastaven� nov�ho po�tu potomk� u rodi�e a p��prava handle rodi�e polo�ky
			tvs.hParent = m_Items[src->parent].htree; // identifik�tor rodi�e polo�ky
			parItem.mask = TVIF_CHILDREN | TVIF_HANDLE;	// maska - opravuje se po�et potomk�
			parItem.hItem = tvs.hParent;		// handle polo�ky (= rodi�)
			parItem.cChildren = m_Items[src->parent].childs; // nov� po�et potomk� rodi�e
			m_Tree->SetItem(&parItem);			// nastaven� nov�ho po�tu potomk� rodi�e
		}
		else
			tvs.hParent = NULL;				// jinak polo�ka nem� rodi�e

// ur�en� polo�ky, za kterou m� b�t nov� polo�ka vlo�ena
		if (after == src->parent)			// je to prvn� polo�ka za rodi�em ?
			tvs.hInsertAfter = TVI_FIRST;	// polo�ka vlo�ena na za��tek seznamu
		else
			tvs.hInsertAfter = m_Items[after].htree; // jinak handle p�ede�l� polo�ky

// p��prava masky, stavu a ostatn�ch parametr� polo�ky
		param = src->param;					// mezi�schova parametr� polo�ky

		tvs.item.mask = TVIF_CHILDREN | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_STATE | TVIF_TEXT;
		tvs.item.stateMask = TVIS_BOLD | TVIS_CUT | TVIS_EXPANDED | TVIS_STATEIMAGEMASK;
		tvs.item.state = INDEXTOSTATEIMAGEMASK(STATE_NONE);
		if (m_BufID == BufEdiID)			// lze to jen v editoru
			if (src->parent != -1)			// mus� b�t platn� rodi�
				if (m_Items[src->parent].param & PR_GET_COMMAND) // mus� b�t pou�ito jako p��kaz
				{
					model = src->model;		// mezi�schova modelu
					if ((param & (PR_GET_EXPRES | PR_GET_BOOL)) ||
						((model > TYP_FUNC) && (model < TYP_FUNC_)) ||
						(model == TYP_FNT) || (model == TYP_FTT))
						tvs.item.state = INDEXTOSTATEIMAGEMASK(STATE_SET);
				}

		if (param & (PR_LOCK | PR_LOCK_DEP)) tvs.item.state |= TVIS_BOLD;	// zv�razn�n�
		if (param & (PR_OFF | PR_OFF_DEP)) tvs.item.state |= TVIS_CUT;	// ze�ednut�
		if (param & PR_EXP) tvs.item.state |= TVIS_EXPANDED; // rozvinut�
		tvs.item.cChildren = 0;				// po�et potomk� (zat�m nen� ��dn�)

// nalezen� platn� ikony
		dst = src;							// adresa nov� polo�ky
		while ((dst->icon == -1) &&			// dokud je ikona implicitn�
				(dst->typ != -1) &&			// ... a je platn� blok s deklarac�
				(dst->refer != -1))			// ... a je platn� index polo�ky s deklarac�
			dst = &(m_ProgBuf[dst->typ].m_Items[dst->refer]); // polo�ka p�ede�l� deklarace
		tvs.item.iImage = dst->icon;		// index ikony polo�ky
		tvs.item.iSelectedImage = dst->icon; // index vybran� ikony polo�ky

// nalezen� platn�ho textu
		dst = src;							// adresa nov� polo�ky
		buf = this;							// adresa tohoto bufferu
		while ((dst->name == -1) &&			// dokud je text implicitn�
			(dst->typ != -1) &&				// ... a je platn� blok s deklarac�
			(dst->refer != -1))				// ... a je platn� index polo�ky s deklarac�
		{
			buf = &m_ProgBuf[dst->typ];		// adresa bufferu s deklarac�
			dst = &(buf->m_Items[dst->refer]); // adresa polo�ky s deklarac�
		}

		if (dst->name != -1)				// je text polo�ku platn� ?
		{
			txt = buf->m_Text->Get(dst->name); // na�ten� textu k polo�ce
			tvs.item.pszText = txt.GetBuffer(1); // nastaven� adresy textu
		}
		else
			tvs.item.pszText = NULL;		// jinak polo�ka nem� text

// vlo�en� polo�ky do stromu
		src->htree = m_Tree->InsertItem(&tvs); // vlo�en� polo�ky do stromu
	}

// navr�cen� opraven�ho indexu
	return Index;
}


////////////////////////////////////////////////////////////////////
// zru�en� polo�ky z bufferu (rekurzivn�, se zru�en�m potomk�!)
// na ru�en� polo�ky se nesm� nic odkazovat (counter = 0 !)
 
void CProgBuf::Delete(short int Index)
{
// p��prava lok�ln�ch prom�nn�ch
	short int childs;				// ��ta� potomk� polo�ky
	short int parent;				// index rodi�e ru�en� polo�ky
	short int i, b;					// pracovn� ��ta�e
	CProgBuf* buf;					// adresa bufferu p�i korekci odkaz�
	PROGITEM* dst;					// pracovn� ukazatel polo�ek
	TV_ITEM parItem;				// polo�ka pro opravu rodi�e ve stromu

// kontrola indexu polo�ky (mus� b�t platn�)
	if ((Index < 0) || (Index >= m_Num)) return;

// kontrola - na polo�ku se nesm� nic odkazovat
	ASSERT(m_Items[Index].counter == 0);

// nejd��ve zru�en� potomk� (rekurzivn�)
	childs = m_Items[Index].childs;	// po�et p��m�ch potomk� ke zru�en�
	for (i = 0; i < childs; i++)
		Delete(Index+1);			// zru�en� n�sleduj�c� polo�ky (=potomek)

// kontrola - polo�ka te� ji� nesm� m�t ��dn�ho potomka
	ASSERT(m_Items[Index].childs == 0);	// po�et potomk�
	ASSERT(m_Items[Index].items == 1);	// po�et prvk� v t�to v�tvi

// �schova rodi�e polo�ky
	parent = m_Items[Index].parent;	// index rodi�e ru�en� polo�ky

// zru�en� polo�ky ze stromu
	if ((m_Tree != NULL) &&			// je platn� strom ?
		(Index >= m_First) &&		// je za prvn� zobrazenou polo�kou ?
		(Index < m_Next))			// je p�ed posledn� (nezobrazenou) polo�kou ?
		m_Tree->DeleteItem(m_Items[Index].htree); // zru�en� polo�ky ze stromu

// oprava prvn� a n�sleduj�c� polo�ky k zobrazen�
	if (Index < m_First) m_First--;	// oprava prvn� polo�ky, je-li pod n�
	if (Index < m_Next) m_Next--;	// oprava n�sleduj�c� polo�ky, je-li pod n�

// korekce aktivn� definovan� polo�ky
	if (Index < m_AktDef)			// je polo�ka p�ed aktivn� definovanou ?
		m_AktDef--;					// oprava aktivn� definovan� polo�ky
	else
		if (Index == m_AktDef)		// je ru�ena aktivn� definovan� polo�ka ?
			m_AktDef = -1;			// polo�ka bude neplatn�

// sn�en� ��ta�e referenc� u deklara�n� polo�ky
	if ((m_Items[Index].typ != -1) &&	// je platn� blok s deklarac� ?
		(m_Items[Index].refer != -1))	// je platn� index deklara�n� polo�ky ?
		m_ProgBuf[m_Items[Index].typ].m_Items[
			m_Items[Index].refer].counter--;	// sn�en� ��ta�e referen�n�ch odkaz�

// zru�en� textu ze seznamu (ponech� index - trochu se to �asem nafoukne)
	i = m_Items[Index].name;		// index textov� polo�ky
	if (i != -1) m_Text->ElementAt(i).Empty(); // vypr�zdn�n� textov� polo�ky

// p��sun zb�vaj�c�ch polo�ek
	if (Index < m_Num-1)			// jsou n�jak� polo�ky k p�isunut� ?
		memmove(&(m_Items[Index]),	// p��sun zb�vaj�c�ch polo�ek
			&(m_Items[Index+1]),
			sizeof(PROGITEM)*(m_Num-1-Index));
	m_Num--;						// sn�en� po�tu prvk� v bufferu

// korekce odkaz� na rodi�e v n�sleduj�c�ch polo�k�ch
	for (i = Index; i < m_Num; i++)	// cyklus a� po konec bufferu
		if (m_Items[i].parent > Index) // je rodi� polo�ky za ru�enou polo�kou ?
			m_Items[i].parent--;	// sn�en� indexu rodi�e polo�ky

// korekce referenc� v ostatn�ch bufferech
	for (b = 0; b < PROGBUFNUM; b++)	// cyklus p�ed v�echny buffery
	{
		if (b != m_BufID)			// tento buffer se nekoriguje
		{
			buf = &m_ProgBuf[b];	// adresa bufferu
			for (i = buf->m_Num-1; i >= 0; i--) // ��t�n� indexu polo�ky dol�
			{
				dst = &(buf->m_Items[i]);	// �schova adresy polo�ky

				if (dst->typ == m_BufID)	// je deklarace na tento buffer ?
					if (dst->refer > Index) // je index na p�isunutou polo�ku ?
						dst->refer--;		// oprava indexu odkazu

				if (dst->data == m_BufID)	// jsou data v tomto bufferu ?
					if (dst->index > Index) // je index na p�isunutou polo�ku ?
						dst->index--;		// oprava indexu odkazu
			}
		}
	}

// sn�en� ��ta�� prvk� u rodi��
	i = parent;								// index rodi�e
	while (i != -1)							// dokud je n�jak� platn� rodi�
	{
		m_Items[i].items--;					// sn�en� po�tu prvk� u rodi�e
		i = m_Items[i].parent;				// index dal��ho rodi�e
	}

// sn�en� po�tu p��m�ch potomk� u rodi�e
	if (parent != -1)						// je platn� rodi� ?
	{
		m_Items[parent].childs--;			// sn�en� po�tu p��m�ch potomk� u rodi�e

// nastaven� nov�ho po�tu potomk� u rodi�e ve stromu
		if ((m_Tree != NULL) &&				// je platn� strom ?
			(parent >= m_First) &&			// je rodi� za prvn� soubrazenou polo�kou ?
			(parent < m_Next))				// je rodi� p�ed n�sleduj�c� (nezobrazenou) polo�kou ?
		{
			parItem.hItem = m_Items[parent].htree; // handle polo�ky rodi�e
			parItem.mask = TVIF_CHILDREN | TVIF_HANDLE; // maska platn�ch �daj�
			parItem.cChildren = m_Items[parent].childs; // po�et potomk� rodi�e
			m_Tree->SetItem(&parItem);		// nastaven� parametr� rodi�e
		}
	}
}


////////////////////////////////////////////////////////////////////
// nalezen� polo�ky podle handle (vrac� index, -1 = nenalezeno)

short int CProgBuf::SrcItem(HTREEITEM hItem)
{
	int i;									// pracovn� �ita�

// nalezen� polo�ky
	if (hItem != NULL)						// je handle polo�ky platn� ?
		for (i = m_Num-1; i >= 0; i--)		// cyklus p�ed v�echny polo�ky
			if (m_Items[i].htree == hItem)	// je to hledan� polo�ka ?
				return i;					// index nalezen� polo�ky

// polo�ka nenalezena
	return -1;								// p��znak nenalezen� polo�ky
}


////////////////////////////////////////////////////////////////////
// p�ekreslen� (aktualizace) stromu

void CProgBuf::ReDisp()
{
	TV_INSERTSTRUCT tvs;					// vkl�dan� polo�ka do stromu
	PROGITEM*	item;						// adresa zobrazovan� polo�ky
	PROGITEM*	item2;						// pracovn� adresa pro nalezen� ikony	
	CString		txt;						// buffer nalezen�ho textu k polo�ce
	CProgBuf*	buf;						// ukazatel bufferu p�i hled�ni textu
	int			i;							// pracovn� ��ta�
	short int	param;						// mezi�schova parametr� polo�ky
	short int	model;						// mezi�schova modelu

	m_AktDef = -1;							// nen� aktivni definovan� polo�ka

// kontrola, zda je strom platn�
	if (m_Tree == NULL) return;

// zru�en� v�ech p�vodn�ch polo�ek stromu
	m_Tree->DeleteAllItems();

// vynulov�n� handle v�ech polo�ek v bufferu
	for (i = 0; i < m_Num; i++)
		m_Items[i].htree = NULL;

// cyklus p�es v�echny zobrazen� polo�ky bufferu
	for (i = m_First; i < m_Next; i++)
	{
// adresa zobrazovan� polo�ky
		item = &m_Items[i];

// p��prava handle rodi�e polo�ky
		if (item->parent < m_First)			// je rodi� polo�ky zobrazen ?
			tvs.hParent = NULL;				// rodi� nezobrazen
		else
			tvs.hParent = m_Items[item->parent].htree; // handle rodi�e polo�ky

// handle p�edch�zej�c� polo�ky - vkl�d� se v�dy na konec
		tvs.hInsertAfter = TVI_LAST;

// maska platn�ch dat polo�ky
		tvs.item.mask = TVIF_CHILDREN | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_STATE | TVIF_TEXT;

// p��prava stavu polo�ky
		param = item->param;					// mezi�schova parametr� polo�ky

		tvs.item.stateMask = TVIS_BOLD | TVIS_CUT | TVIS_EXPANDED | TVIS_STATEIMAGEMASK;
		tvs.item.state =  INDEXTOSTATEIMAGEMASK(STATE_NONE);

		if (m_BufID == BufEdiID)			// lze to jen v editoru
			if (item->parent != -1)			// mus� b�t platn� rodi�
				if (m_Items[item->parent].param & PR_GET_COMMAND) // mus� b�t pou�ito jako p��kaz
				{
					model = item->model;	// mezi�schova modelu
					if ((param & (PR_GET_EXPRES | PR_GET_BOOL)) ||
						((model > TYP_FUNC) && (model < TYP_FUNC_)) ||
						(model == TYP_FNT) || (model == TYP_FTT))
						tvs.item.state = INDEXTOSTATEIMAGEMASK(STATE_SET);
				}

		if (param & (PR_LOCK | PR_LOCK_DEP)) tvs.item.state |= TVIS_BOLD;	// zv�razn�n�
		if (param & (PR_OFF | PR_OFF_DEP)) tvs.item.state |= TVIS_CUT;	// ze�ednut�
		if (param & PR_EXP) tvs.item.state |= TVIS_EXPANDED; // rozvinut�

// ostatn� parametry polo�ky
		tvs.item.cchTextMax = 0;
		tvs.item.cChildren = item->childs;	// po�et p��m�ch potomk� polo�ky

// nalezen� platn� ikony
		item2 = item;						// v�choz� adresa polo�ky
		while ((item2->icon == -1) &&		// dokus je ikona implicitn�
			(item2->typ != -1) &&			// ... a je platn� blok s deklarac�
			(item2->refer != -1))			// ... a je platn� index s deklarac�
			item2 = &(m_ProgBuf[item2->typ].m_Items[item2->refer]); // adresa deklara�n� polo�ky
		tvs.item.iImage = item2->icon;			// index ikony
		tvs.item.iSelectedImage = item2->icon;	// index vybran� ikony

// nalezen� platn�ho textu
		item2 = item;						// v�choz� adresa polo�ky
		buf = this;							// adresa tohoto bufferu
		while ((item2->name == -1) &&		// dokud je text implicitn�
			(item2->typ != -1) &&			// ... a je platn� blok s deklarac�
			(item2->refer != -1))			// ... a je platn� index polo�ky s deklarac�
		{
			buf = &m_ProgBuf[item2->typ];	// adresa bufferu s deklarac�
			item2 = &(buf->m_Items[item2->refer]); // adresa polo�ky s deklarac�
		}

		if (item2->name != -1)				// je text polo�ky platn� ?
		{
			txt = buf->m_Text->Get(item2->name); // na�ten� textu k polo�ce
			tvs.item.pszText = txt.GetBuffer(1); // nastaven� adresy textu
		}
		else
			tvs.item.pszText = NULL;		// jinak polo�ka nem� text

// vlo�en� polo�ky do stromu
		item->htree = m_Tree->InsertItem(&tvs);
	}
}


/////////////////////////////////////////////////////////////////////////////
// kopie v�tve prvk� z jin�ho bufferu do tohoto
//
// prov�d� korekce:
//		- nulov�n� p��znaku PR_INTERNAL
//		- zaji�t�n� kop�rov�n� n�kter�ch polo�ek bez potomk�
//		- zm�na reference na zdrojov� okno
//		- rozvinut� v�tve p�i kopii ze stromu struktur
//		  nebo p�i kopii do nerozvinut� polo�ky
//		- kop�ruje definici obsahu funkce (jen nen�-li p�esun)
//
// vstupn� prom�nn�:
//		dst		- index c�lov� polo�ky
//		parent	- index rodi�e c�lov� polo�ky
//		bufID	- ID zdrojov�ho bufferu
//		src		- index zdrojov� polo�ky
//		move	- p��znak m�du p�esunu (nekop�rovat definice funkc�)
//
// vrac� opraven� index c�lov� polo�ky

short int CProgBuf::Copy(short int dst, short int parent, short int bufID, short int src, BOOL move)
{
	return Copy2(dst, parent, bufID, src, move, TRUE);
}


short int CProgBuf::Copy2(short int& dst, short int parent, short int bufID, short int& src, BOOL move, BOOL first)
{
// lok�ln� prom�nn�
	int result;			// navr�cen� v�sledek - opraven� index c�lov� polo�ky
	PROGITEM item;		// buffer kop�rovan� polo�ky
	int i;				// pracovn� ��ta�
	CString txt;		// buffer p�i kopii textu polo�ky

// na�ten� zdrojov� polo�ky do pracovn�ho bufferu
	memcpy(&item, &(m_ProgBuf[bufID].m_Items[src]), sizeof(PROGITEM));

// nastaven� rodi�e
	item.parent = parent;

// zru�en� p��znaku intern� funkce
	item.param &= ~PR_INTERNAL;

// test, zda se maj� kop�rovat potomci
	if	(
		 (
		  (bufID == BufStrID)			// kopie z bufferu intern�ch struktur
		  &&
		  (
		   (item.refer == FncNum) 		// ��slo se kop�ruje bez obsahu
		   ||
		   (item.refer == FncWhileBody) // t�lo cyklu se kop�ruje bez p�eru�en� cyklu
		  )
		 ) 
		 ||
		 (bufID == BufClsID)			// t��dy se kop�ruj� v�dy bez potomk�
		)
		item.childs = 0;				// nejsou ��dn� potomci

// zm�na reference na zdrojov� okno, je-li kopie mezi okny
	if (bufID != m_BufID)				// je kopie mezi okny ?
	{
		item.typ = bufID;				// ��slo bloku s deklarac�
		item.refer = src;				// index deklara�n� polo�ky
		item.name = -1;					// text polo�ky implicitn�
		item.icon = -1;					// ikona polo�ky implicitn�
		item.data = -1;					// nejsou data
		item.index = -1;
	}

// kopie textu (p�i p�esunu se text jen p�edefinuje)
	if (item.name != -1)				// je platn� text ?
		if (move)						// je m�d p�esunu ?
			m_ProgBuf[bufID].m_Items[src].name = -1; // zru�en� textu u vzoru
		else
		{
			txt = m_ProgBuf[bufID].m_Text->Get(item.name); // na�ten� textu polo�ky
			item.name = m_Text->Add(txt);	// p�id�n� textu do seznamu
		}

// vlo�en� prvku do stromu
	dst = Insert(&item, dst);			// vlo�en� nov�ho prvku
	result = dst;						// navr�cen� v�sledek

// kopie definice programu u funkce
	if ((item.model == TYP_FUNC) &&		// je to funkce ?
		((item.data == BufLocID) ||		// reference na lok�ln� objekty
		(item.data == BufEdiID)))		// ... nebo na editor

		if ((item.index >= 0) &&		// je platn� index ?
			(item.index < m_ProgBuf[item.data].m_Num))
	{
//		if (move)						// je m�d p�esunu ?
//		{
//			m_ProgBuf[bufID].m_Items[src].index = -1; // nejsou data
//		}
//		else
		{
			item.index = m_ProgBuf[item.data].	// kopie dat funkce
				Copy(m_ProgBuf[item.data].m_Num, -1, item.data, item.index, move);
			m_Items[dst].index = item.index;	// index na defini�n� data
		}
	}
	
// zaji�t�n� viditelnosti (kopie ze struktur nebo kopie prvn� polo�ky)
	if ((bufID == BufStrID) || first)
		m_Tree->EnsureVisible(m_Items[dst].htree);

// oprava zdrojov�ho indexu p�i kop�rov�n� v jednom stromu
	if (bufID == m_BufID)
		if (dst <= src) src++;

// zv��en� ukazatel� polo�ek
	parent = dst;						// polo�ka bude rodi�em pro dal�� polo�ky
	src++;								// zv��en� ukazatele zdrojov� polo�ky
	dst++;								// zv��en� ukazatele c�lov� polo�ky

// rekurzn� kopie potomk�
	for (i = 0; i < item.childs; i++)	// cyklus pro v�echny potomky
		Copy2(dst, parent, bufID, src, move, FALSE); // kopie potomk�

// navr�cen� v�sledek - opraven� index t�to polo�ky
	return result;
}


/////////////////////////////////////////////////////////////////////////////
// nastaven� prvn� zobrazen� polo�ky s p��padn�m p�ekreslen�m,
// po�adovan� index m��e b�t ve v�tvi (nemus� b�t ROOT)
// navrac� TRUE, pokud bylo okno p�ekresleno

BOOL CProgBuf::SetFirst(short First)
{
// lok�ln� prom�nn�
	short Next = m_Num;					// p��t� polo�ka

// zobrazeno v�e - nen� ��dn� polo�ka nebo nen� EDIT ani LOCAL
	if ((m_Num == 0) ||					// nen� ��dn� polo�ka
		((m_BufID != BufEdiID) &&		// .. nebo je jin� buffer ne� EDIT
		(m_BufID != BufLocID)))			// .. nebo je jin� buffer ne� LOCAL
	{
		First = 0;						// nov� prvn� polo�ka, aby se zobrazilo v�e
	}
	else
	{

// omezen� prvn� polo�ky (zde je Next == m_Num)
		if (First >= Next)				// je p�ete�en� maxim�ln� polo�ky ?
			First = Next-1;				// maxim�ln� hodnota prvn� polo�ky
		if (First < 0) First = 0;		// minim�ln� hodnota prvn� polo�ky

// nalezen� ROOT polo�ky
		while (m_Items[First].parent != -1)	// je to ji� ROOT ?
			First = m_Items[First].parent;	// p�esm�rov�n� na rodi�e

// aktualizace p�i�t� polo�ky
		Next = First + m_Items[First].items; // n�sleduj�c� polo�ka
		First++;						// korekce prvn� zobrazen� polo�ky
	}

// p�ekreslen� okna, pokud se �daje zm�nily
	if ((First != m_First) || (Next != m_Next)) // zm�nilo se nastaven� ?
	{		
		m_First = First;				// nov� prvn� polo�ka
		m_Next = Next;					// nov� p��t� polo�ka
		ReDisp();						// p�ekreslen� displeje
		return TRUE;					// p��znak p�ekreslen� okna
	}
	else
		return FALSE;					// okno nebylo p�ekresleno
}


/////////////////////////////////////////////////////////////////////////////
// nalezen� textu k polo�ce

CString CProgBuf::GetName(short Index)
{
// lok�ln� prom�nn�
	CProgBuf* buf = this;					// ukazatel adresy bufferu
	PROGITEM* item;							// ukazatel adresy polo�ky
	CString result = "";					// n�vratov� hodnota

// kontrola platnosti indexu
	if ((Index >= 0) && (Index < m_Num))	// je index platn� ?
	{

// adresa polo�ky
		item = &(buf->m_Items[Index]);		// adresa polo�ky

// nalezen� platn�ho textu k prvku
		while ((item->name == -1) &&		// dokud je text implicitn�
				(item->typ != -1) &&		// ... a je platn� blok s deklarac�
				(item->refer != -1))		// ... a je platn� index polo�ky s deklarac�
		{	
			buf = &(m_ProgBuf[item->typ]);	// adresa bufferu s deklarac�
			item = &(buf->m_Items[item->refer]); // adresa polo�ky s deklarac�
		}

// na�ten� textu k polo�ce
		if (item->name != -1)				// je text polo�ky platn� ?
			result = buf->m_Text->Get(item->name); // na�ten� textu k polo�ce
	}

// navr�cen� textu
	return result;
}


/////////////////////////////////////////////////////////////////////////////
// nalezen� polo�ky odkazuj�c� se na po�adovan� data (-1 = nenalezeno)

short int CProgBuf::SrcDat(short bufID, short Index)
{
	int i;									// pracovn� �ita�

// nalezen� polo�ky
	for (i = m_Num-1; i >= 0; i--)			// cyklus p�ed v�echny polo�ky
		if ((m_Items[i].index == Index)	&&	// souhlas� index ?
			(m_Items[i].data == bufID))		// souhlas� buffer ?
			return i;						// index nalezen� polo�ky

// polo�ka nenalezena
	return -1;								// p��znak nenalezen� polo�ky
}


/////////////////////////////////////////////////////////////////////////////
// hled�n� referen�n� polo�ky v bufferu od aktu�ln� polo�ky (-1 = nenalezeno)
//
// vstup:
//	bufID - ��slo bufferu hledan� reference
//	Index - index hledan� reference
//	Smer  - po�adovan� sm�r (od aktu�ln� polo�ky) 1 nebo -1

short int CProgBuf::SrcRef(short bufID, short Index, short Smer)
{
// lok�ln� prom�nn�, p��prava aktu�ln� polo�ky
	HTREEITEM htree = m_Tree->GetSelectedItem(); // nalezen� aktivn�ho prvku
	short itemN = SrcItem(htree);			// nalezen� indexu aktivn�ho prvku
	if (itemN == -1) itemN = 0;				// korekce, nen�-li prvek vybr�n
	PROGITEM* item = &(m_Items[itemN]);		// adresa prvku
	short i;								// ��ta� prvk�

// cyklus p�es v�echny polo�ky
	for (i = m_Num-1; i >= 0; i--)			// cyklus p�es v�echny polo�ky
	{

// zv��en� ukazatele polo�ky
		itemN += Smer;						// zv��en� ��sla polo�ky
		item += Smer;						// zv��en� adresy polo�ky

		if (itemN >= m_Num)					// je p�ete�en� ��sla polo�ky ?
		{
			itemN = 0;						// korekce ��sla polo�ky
			item = m_Items;					// korekce adresy polo�ky
		}

		if (itemN < 0)						// je podte�en� ��sla polo�ky ?
		{
			itemN = m_Num-1;				// korekce ��sla polo�ky
			item = &(m_Items[itemN]);		// korekce adresy polo�ky
		}

// test, zda to je hledan� polo�ka
		if ((item->typ == bufID) &&			// souhlas� referen�n� buffer ?
			(item->refer == Index))			// souhlas� referen�n� index ?
		{
			return itemN;					// index nalezen� polo�ky
		}
	}
	return -1;								// polo�ka nenalezena
}


/////////////////////////////////////////////////////////////////////////////
// nalezen� aktivn� polo�ky (-1 = nen� ��dn� polo�ka)

short int CProgBuf::GetAkt()
{
	return SrcItem(m_Tree->GetSelectedItem());
}


/////////////////////////////////////////////////////////////////////////////
// nastaven� aktivn� polo�ky (-1 = vypnuta)

void CProgBuf::SetAkt(short Index)
{
	if ((Index < 0) || (Index >= m_Num))	// je index platn� ?
		m_Tree->SelectItem(NULL);			// zru�en� v�b�ru
	else
		m_Tree->SelectItem(m_Items[Index].htree); // nastaven� aktivn� polo�ky
}


/////////////////////////////////////////////////////////////////////////////
// ozna�en� definovan� polo�ky (-1 = odzna�en�)

void CProgBuf::SetDef(short int Index)
{
// korekce indexu
	if ((Index >= m_Num) || (Index < 0))	// je index platn� ?
		Index = -1;							// p��znak neplatnosti indexu

// kontrola, zda se polo�ka m�n�
	if (Index == m_AktDef) return;			// polo�ka je ji� nastavena

// zru�en� ozna�en� star� polo�ky
	if ((m_AktDef >= 0) && (m_AktDef < m_Num))
		if (m_Items[m_AktDef].htree != NULL)
			m_Tree->SetItem(m_Items[m_AktDef].htree,
				TVIF_STATE, NULL, 0, 0, INDEXTOSTATEIMAGEMASK(STATE_NONE),
				TVIS_STATEIMAGEMASK, NULL);

// nastaven� nov� polo�ky
	m_AktDef = Index;						// ulo�en� nov� hodnoty
	if (Index != -1)						// m� se ozna�en� zobrazit ?
		if (m_Items[Index].htree != NULL)
			m_Tree->SetItem(m_Items[Index].htree,
				TVIF_STATE, NULL, 0, 0, INDEXTOSTATEIMAGEMASK(STATE_SELECT),
				TVIS_STATEIMAGEMASK, NULL);
}
