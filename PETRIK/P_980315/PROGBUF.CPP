
#include "stdafx.h"
#include "peter.h"
#include "TextBuf.h"
#include "ProgBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define PROGREZERVA 100

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CProgBuf::CProgBuf()
{
	m_Items = (PROGITEM*) malloc(sizeof(PROGITEM)*PROGREZERVA);
	ASSERT(m_Items != NULL);
	m_Num = 0;					// nen� ��dn� polo�ka
	m_Max = PROGREZERVA;		// sou�asn� velikost bufferu
	m_First = 0;				// prvn� zobrazen� polo�ka bufferu
	m_Next = 0;					// n�sleduj�c� (nezobrazen�) polo�ka bufferu
	m_Tree = NULL;				// nen� strom
	m_ProgBuf = NULL;
}

CProgBuf::~CProgBuf()
{
	free(m_Items);
}


////////////////////////////////////////////////////////////////////
// vlo�en� polo�ky do bufferu (-1 = na konec)
// Pozor - pou��t vr�cen� skute�n� index, proto�e jej m��e opravit !!!

int CProgBuf::Insert(PROGITEM* item, int Index)
{
	ASSERT(item != NULL);
	int	i,j;
	int after;

	if (m_BufID == 2)
	{
		int iii = m_Num;
		m_Num = Index;
		m_Num = iii;
	}

// zv��en� velikosti bufferu
	if (m_Num >= m_Max)
	{
		PROGITEM* buf;
		buf = (PROGITEM*)realloc(m_Items, sizeof(PROGITEM) * (m_Num+PROGREZERVA));
		if (buf == NULL) return -1;
		m_Items = buf;
		m_Max = m_Num + PROGREZERVA;
	}

// oprava indexu polo�ky
	i = item->parent;
	if ((i < -1) || (i >= m_Num))
	{
		i = -1;
		item->parent = i;
	}
	if ((Index < 0) || (Index > m_Num)) Index = m_Num;
	if (Index < i+1) Index = i+1;		// pro parent = -1 bude Index = 0

// oprava indexu, aby nele�el v podv�tvi (i = rodi�)
	after = i;
	j = i+1;							// prvn� potomek
	while (j < Index)
	{
		if (m_Items[j].parent != i)
			break;
		after = j;
		j += m_Items[j].items;
	}
	Index = j;

// oprava prvn� a n�sleduj�c� polo�ky k zobrazen�
	if (Index < m_First)
		m_First++;
	if (Index <= m_Next)
		m_Next++;

// p��prava adres
	PROGITEM* src;
	PROGITEM* dst;
	src = &(m_Items[Index]);
	dst = &(m_Items[Index+1]);

// odsun zb�vaj�c�ch polo�ek
	if (Index < m_Num)
		memmove(dst,src,sizeof(PROGITEM) * (m_Num-Index));
	m_Num++;			// zv��en� po�tu polo�ek

// inicializace polo�ky
	memcpy(src, item, sizeof(PROGITEM));
	src->htree = NULL;
	src->counter = 0;
	src->childs = 0;
	src->items = 1;

// korekce odkaz� na rodi�e v n�sleduj�c�ch polo�k�ch
	for (i = Index+1; i < m_Num; i++)
	{
		if (m_Items[i].parent >= Index)
			m_Items[i].parent++;
	}

// korekce referenc� v ostatn�ch bufferech
	for (int b = 0; b < PROGBUFNUM; b++)
	{
		if (b != m_BufID)
		{
			CProgBuf* buf = &m_ProgBuf[b];
			for (i = buf->m_Num-1; i >= 0; i--)
			{
				if (buf->m_Items[i].typ == m_BufID)
				{
					if (buf->m_Items[i].refer >= Index)
					{
						buf->m_Items[i].refer++;
					}
				}
			}
		}
	}

// zv��en� ��ta�e potomk� u rodi�e
	i = src->parent;
	if (i != -1)
		m_Items[i].childs++;

// zv��en� ��ta�� prvk� u rodi�� (i = rodi�)
	while (i != -1)
	{
		m_Items[i].items++;
		i = m_Items[i].parent;
	}

// zv��en� ��ta�e referenc� u origin�lu
	if ((src->typ != -1) && (src->refer != -1))
	{
		m_ProgBuf[src->typ].m_Items[src->refer].counter++;
	}

// vlo�en� polo�ky do stromu
	if ((m_Tree != NULL) &&
		(Index >= m_First) &&
		(Index <= m_Next))
	{
		TV_ITEM parItem;
		TV_INSERTSTRUCT tvs;

		if ((src->parent >= m_First) &&
				(src->parent <= m_Next))
		{
			tvs.hParent = m_Items[src->parent].htree;
			parItem.mask = TVIF_CHILDREN;
			parItem.hItem = tvs.hParent;
			parItem.cChildren = m_Items[src->parent].childs;
			m_Tree->SetItem(&parItem);
		}
		else
			tvs.hParent = NULL;

		if (after == src->parent)
			tvs.hInsertAfter = TVI_FIRST;
		else
			tvs.hInsertAfter = m_Items[after].htree;

		tvs.item.mask = TVIF_STATE | TVIF_CHILDREN |
			TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT;

		tvs.item.stateMask = TVIS_EXPANDED | TVIS_BOLD | TVIS_CUT;
		tvs.item.state = 0;
		if ((src->param & PR_EXP) != 0)
			tvs.item.state |= TVIS_EXPANDED;
		if ((src->param & PR_BOLD) != 0)
			tvs.item.state |= TVIS_BOLD;
		if ((src->param & PR_GRAY) != 0)
			tvs.item.state |= TVIS_CUT;

		tvs.item.cchTextMax = 0;
		tvs.item.cChildren = src->childs;

// nalezen� ikony
		PROGITEM* src2 = src;

		while ((src2->icon == -1) && (src2->typ != -1) && (src2->refer != -1))
			src2 = &(m_ProgBuf[src2->typ].m_Items[src2->refer]);

		tvs.item.iImage = src2->icon;
		tvs.item.iSelectedImage = src2->icon;

// nalezen� textu
		CString txt;
		CProgBuf* pbuf;

		src2 = src;
		pbuf = this;
		while ((src2->name == -1) && (src2->typ != -1) && (src2->refer != -1))
		{
			pbuf = &m_ProgBuf[src2->typ];
			src2 = &(pbuf->m_Items[src2->refer]);
		}

		if (src2->name != -1)
		{
			txt = pbuf->m_Text->Get(src2->name);
			tvs.item.pszText = txt.GetBuffer(1);
		}
		else
			tvs.item.pszText = NULL;

// vlo�en� polo�ky do stromu ("txt" nesm� je�t� b�t zru�eno !)
		src->htree = m_Tree->InsertItem(&tvs);
	}

	return Index;
}

////////////////////////////////////////////////////////////////////
// zru�en� polo�ky z bufferu (rekurzivn�, se zru�en�m potomk�!)
 
void CProgBuf::Delete(int Index)
{
// kontrola indexu polo�ky
	if ((Index < 0) || (Index >= m_Num)) return;

// zru�en� potomk�
	int childs = m_Items[Index].childs;
	for (int i = 0; i < childs; i++)
		Delete(Index+1);

// �schova rodi�e polo�ky
	int parent = m_Items[Index].parent;

// zru�en� polo�ky ze stromu
	if ((m_Tree != NULL) &&
		(Index >= m_First) &&
		(Index < m_Next))
		m_Tree->DeleteItem(m_Items[Index].htree);

// oprava prvn� a n�sleduj�c� polo�ky k zobrazen�
	if (Index < m_First)
		m_First--;
	if (Index < m_Next)
		m_Next--;

// sn�en� ��ta�e referenc� u origin�lu
	if ((m_Items[Index].typ != -1) && (m_Items[Index].refer != -1))
	{
		m_ProgBuf[m_Items[Index].typ].m_Items[m_Items[Index].refer].counter--;
	}

// zru�en� textu ze seznamu (ponech� index - trochu se to �asem nafoukne)
	int nTxt = m_Items[Index].name;
	if (nTxt != -1)
	{
		m_Text->ElementAt(nTxt).Empty();
	}

// p��sun zb�vaj�c�ch polo�ek
	if (Index < m_Num-1)
		memmove(&(m_Items[Index]), &(m_Items[Index+1]),sizeof(PROGITEM) * (m_Num-1-Index));
	m_Num--;

// korekce odkaz� na rodi�e v n�sleduj�c�ch polo�k�ch
	for (i = Index; i < m_Num; i++)
	{
		if (m_Items[i].parent > Index)
			m_Items[i].parent--;
	}

// korekce referenc� v ostatn�ch bufferech
	for (int b = 0; b < PROGBUFNUM; b++)
	{
		if (b != m_BufID)
		{
			CProgBuf* buf = &(m_ProgBuf[b]);
			for (i = buf->m_Num-1; i >= 0; i--)
			{
				if (buf->m_Items[i].typ == m_BufID)
				{
					if (buf->m_Items[i].refer >= Index)
					{
						buf->m_Items[i].refer--;
					}
				}
			}
		}
	}

// �n�en� ��ta�� prvk� u rodi��
	i = parent;
	while (i != -1)
	{
		m_Items[i].items--;
		i = m_Items[i].parent;
	}

// sn�en� po�tu potomk� u rodi�e
	if (parent != -1)
	{
		m_Items[parent].childs--;

// nastaven� nov�ho po�tu potomk� u rodi�e ve stromu
		if ((m_Tree != NULL) &&
			(parent >= m_First) &&
			(parent <= m_Next))
		{
			TV_ITEM parItem;
			parItem.hItem = m_Items[parent].htree;
			parItem.mask = TVIF_CHILDREN;
			parItem.cChildren = m_Items[parent].childs;
			m_Tree->SetItem(&parItem);
		}
	}
}

////////////////////////////////////////////////////////////////////
// nalezen� polo�ky podle handle (-1 = nenalezeno)

int CProgBuf::SrcItem(HTREEITEM hItem)
{
// nalezen� polo�ky
	if (hItem != NULL)
		for (int i = 0; i < m_Num; i++)
			if (m_Items[i].htree == hItem)
				return i;

// polo�ka nenalezena
	return -1;
}


////////////////////////////////////////////////////////////////////
// p�ekreslen� stromu

void CProgBuf::ReDisp()
{
	if (m_Tree == NULL) return;

	TV_INSERTSTRUCT tvs;
	PROGITEM*	item;
	PROGITEM*	item2;
	CString		txt;
	CProgBuf*	pbuf;
	int			i;

	m_Tree->DeleteAllItems();

	for (i = 0; i < m_Num; i++)
		m_Items[i].htree = NULL;

	for (i = m_First; i < m_Next; i++)
	{
		item = &m_Items[i];

		if (item->parent < m_First)
			tvs.hParent = NULL;
		else
			tvs.hParent = m_Items[item->parent].htree;

		tvs.hInsertAfter = TVI_LAST;

		tvs.item.mask = TVIF_STATE | TVIF_CHILDREN |
			TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT;

		tvs.item.stateMask = TVIS_EXPANDED | TVIS_BOLD | TVIS_CUT;
		tvs.item.state = 0;
		if ((item->param & PR_EXP) != 0)
			tvs.item.state |= TVIS_EXPANDED;
		if ((item->param & PR_BOLD) != 0)
			tvs.item.state |= TVIS_BOLD;
		if ((item->param & PR_GRAY) != 0)
			tvs.item.state |= TVIS_CUT;

		tvs.item.cchTextMax = 0;
		tvs.item.cChildren = item->childs;

// nalezen� ikony
		item2 = item;

		while ((item2->icon == -1) && (item2->typ != -1) && (item2->refer != -1))
			item2 = &(m_ProgBuf[item2->typ].m_Items[item2->refer]);

		tvs.item.iImage = item2->icon;
		tvs.item.iSelectedImage = item2->icon;

// nalezen� textu
		item2 = item;
		pbuf = this;
		while ((item2->name == -1) && (item2->typ != -1) && (item2->refer != -1))
		{
			pbuf = &m_ProgBuf[item2->typ];
			item2 = &(pbuf->m_Items[item2->refer]);
		}

		if (item2->name != -1)
		{
			txt = pbuf->m_Text->Get(item2->name);
			tvs.item.pszText = txt.GetBuffer(1);
		}
		else
			tvs.item.pszText = NULL;

// vlo�en� polo�ky do stromu ("txt" nesm� je�t� b�t zru�eno !)
		item->htree = m_Tree->InsertItem(&tvs);
	}
}
