
/******************************************************************\
*                                                                  *
*                        Buffer mapy                               *
*                                                                  *
\******************************************************************/

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

#define DATAREZERVA		0x1000	// rezerva p�i zv�t�ov�n� bufferu dat (bajt�)
#define INDEXREZERVA	100		// rezerva p�i zv�t�ov�n� bufferu index� (polo�ek)

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CMapBuf::CMapBuf()
{
	m_Data = NULL;			// nejsou data mapy
	m_Index = NULL;			// nejsou indexy mapy
	m_Num = 0;				// nen� ��dn� polo�ka v bufferu
	m_DataNum = 0;			// po�et bajt� v bufferu dat mapy
	m_DataMax = 0;			// velikost bufferu dat mapy
	m_IndexMax = 0;			// velikost bufferu index� map (polo�ek)
}

CMapBuf::~CMapBuf()
{
	Aloc(m_Data,0);			// zru�en� bufferu dat
	Aloc(m_Index,0);		// zru�en� bufferu index�
}


////////////////////////////////////////////////////////////////////
// p�id�n� polo�ky do bufferu (vrac� index)

short CMapBuf::Add(MAP* map)
{
// velikost p�id�van� polo�ky v bajtech
	int size = MapSize(map);

// zv�t�en� bufferu index�
	if (m_Num >= m_IndexMax)
	{
		m_IndexMax = m_Num + INDEXREZERVA;
		Aloc(m_Index, m_IndexMax);
	}

// zv�t�en� bufferu dat
	if (m_DataNum+size > m_DataMax)
	{
		m_DataMax = m_DataNum + size + DATAREZERVA;
		Aloc(m_Data, m_DataMax);
	}

// kopie dat polo�ky
	memcpy(m_Data + m_DataNum, map, size);

// nastaven� indexu na polo�ku
	m_Index[m_Num] = m_DataNum;

// zv��en� ��ta�e polo�ek
	m_Num++;

// zv��en� ukazatele velikosti dat v bufferu
	m_DataNum += size;

// navr�cen� indexu nov� polo�ky
	return m_Num-1;
}


////////////////////////////////////////////////////////////////////
// vytvo�en� nov� mapy dan�ch rozm�r� (vrac� index)

short CMapBuf::New(short width, short height)
{
// omezen� velikosti mapy
	if (width > MAXMAPWIDTH)
		width = MAXMAPWIDTH;

	if (height > MAXMAPHEIGHT)
		height = MAXMAPHEIGHT;

	if (width < 1)
		width = 1;

	if (height < 1)
		height = 1;

	if (width * height > MAXMAPSIZE)
		height = MAXMAPSIZE / width;

// velikost nov� polo�ky v bajtech
	int size = (width*height-1)*sizeof(MAPITEM) + sizeof(MAP);

// zv�t�en� bufferu index�
	if (m_Num >= m_IndexMax)
	{
		m_IndexMax = m_Num + INDEXREZERVA;
		Aloc(m_Index, m_IndexMax);
	}

// zv�t�en� bufferu dat
	if (m_DataNum+size > m_DataMax)
	{
		m_DataMax = m_DataNum + size + DATAREZERVA;
		Aloc(m_Data, m_DataMax);
	}

// adresa nov� polo�ky
	MAP* map = (MAP*)(m_Data + m_DataNum);

// inicializace dat polo�ky
	map->width = width;
	map->height = height;
	memset(&map->item[0], 0, width*height*sizeof(MAPITEM));

// nastaven� indexu na polo�ku
	m_Index[m_Num] = m_DataNum;

// zv��en� ��ta�e polo�ek
	m_Num++;

// zv��en� ukazatele velikosti dat v bufferu
	m_DataNum += size;

// navr�cen� indexu nov� polo�ky
	return m_Num-1;
}


////////////////////////////////////////////////////////////////////
// nastaven� nov� velikosti mapy

void CMapBuf::SetSize(short Index, short width, short height)
{
// lok�ln� prom�nn�
	int size;							// nov� velikost polo�ky
	int oldwidth;						// p�vodn� ���ka polo�ky
	int oldheight;						// p�vodn� v��ka polo�ky
	int oldsize;						// p�vodn� velikost polo�ky
	int difsize;						// rozd�l velikost� (zv��en�)
	short i;							// pracovn� ��ta�
	BYTE* src;							// ukazatele p�i operac�ch p�esunu
	BYTE* dst;

// kontrola indexu
	if ((Index < 0) || (Index >= m_Num))
		return;

// omezen� velikosti mapy
	if (width > MAXMAPWIDTH)
		width = MAXMAPWIDTH;

	if (height > MAXMAPHEIGHT)
		height = MAXMAPHEIGHT;

	if (width < 1)
		width = 1;

	if (height < 1)
		height = 1;

	if (width * height > MAXMAPSIZE)
		height = MAXMAPSIZE / width;

// p�vodn� velikost polo�ky v bajtech
	oldsize = MapSize(Index);			// p�vodn� velikost

// nov� velikost polo�ky v bajtech, rozd�l velikost�
	size = (width*height-1)*sizeof(MAPITEM) + sizeof(MAP);
	difsize = size - oldsize;			// rozd�l velikost�

// zv�t�en� bufferu dat, je-li pot�eba
	if (m_DataNum + difsize > m_DataMax)
	{
		m_DataMax = m_DataNum + difsize + DATAREZERVA;
		Aloc(m_Data, m_DataMax);
	}

// adresa korigovan� polo�ky
	MAP* map = Get(Index);

// �schova p�vodn�ch parametr� polo�ky
	oldwidth = map->width;				// p�vodn� ���ka polo�ky
	oldheight = map->height;			// p�vodn� v��ka polo�ky

// oprava po�tu ��dk�
	if (height != oldheight)
	{
		src = (BYTE*)map + (oldwidth*oldheight-1)*sizeof(MAPITEM) + sizeof(MAP);
		dst = (BYTE*)map + (oldwidth*height-1)*sizeof(MAPITEM) + sizeof(MAP);

		if (Index < m_Num-1)
		{
			memmove(dst, src, m_DataNum - m_Index[Index+1]);
		}
		m_DataNum += (height-oldheight)*oldwidth*sizeof(MAPITEM);
		map->height = height;				// nov� v��ka polo�ky

		if (height > oldheight)
		{
			memset(src, 0, (height - oldheight)*oldwidth*sizeof(MAPITEM));
		}
	}

// oprava d�lky ��dk�
	if (width != oldwidth)
	{
		src = (BYTE*)map + (oldwidth - 1)*sizeof(MAPITEM) + sizeof(MAP);
		dst = (BYTE*)map + (width - 1)*sizeof(MAPITEM) + sizeof(MAP);

		for (i = 0; i < height; i++)
		{
			memmove(dst, src, m_DataNum - (m_Index[Index] + (i*width+oldwidth-1)*sizeof(MAPITEM) + sizeof(MAP)));

			if (width > oldwidth)
			{
				memset(src, 0, (width-oldwidth)*sizeof(MAPITEM));
			}

			src += width*sizeof(MAPITEM);
			dst += width*sizeof(MAPITEM);
			m_DataNum += (width - oldwidth)*sizeof(MAPITEM);
		}
		map->width = width;					// nov� ���ka polo�ky
	}

// korekce index� na ostatn� polo�ky
	for (i = Index+1; i < m_Num-1; i++)
	{
		m_Index[i] += difsize;
	}
}


////////////////////////////////////////////////////////////////////
// zru�en� polo�ky

void CMapBuf::Delete(short Index)
{
// lok�ln� prom�nn�
	short i, b;					// pracovn� ��ta�e
	int	size;					// velikost ru�en�ch dat
	CProgBuf* buf;				// ukazatel na programov� buffer
	PROGITEM* item;				// ukazatel na polo�ku programu

// kontrola indexu
	if ((Index < 0) || (Index >= m_Num))
		return;

// po�et bajt� ke zru�en�
	size = MapSize(Index);

// zru�en� dat polo�ky (p��sun zbyl�ch polo�ek)
	if (Index < m_Num-1)
		memmove(&(m_Data[m_Index[Index]]), &(m_Data[m_Index[Index+1]]), 
			m_DataNum - m_Index[Index+1]);

// sn�en� ��ta�e dat v bufferu
	m_DataNum -= size;

// zru�en� indexu a korekce zbyl�ch index�
	for (i = Index; i < m_Num-1; i++)
	{
		m_Index[i] = m_Index[i+1] - size;
	}

// sn�en� ��ta�e polo�ek
	m_Num--;

// korekce referenc� v programov�ch bufferech
	for (b = 0; b < PROGBUFNUM; b++) // ukazatel ��sla bufferu
	{
		buf = &m_ProgBuf[b]; // adresa bufferu

		for (i = buf->m_Num-1; i >= 0; i--) // ��t�n� indexu polo�ky dol�
		{
			item = &(buf->m_Items[i]);		// �schova adresy polo�ky

			if ((item->data == BufMapID) &&	// odkaz na buffer mapy
				(item->index >= Index))		// index, kter� bude ovlivn�n
			{
				if (item->index == Index)	// je to ru�en� index ?
				{
					item->index = -1;		// zru�en� odkazu
					item->data = -1;
				}
				else
					item->index--;			// jinak korekce indexu
			}
		}
	}
}

