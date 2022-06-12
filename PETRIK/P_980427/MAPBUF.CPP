
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

#define DATAREZERVA		0x1000	// rezerva pøi zvìtšování bufferu dat (bajtù)
#define INDEXREZERVA	100		// rezerva pøi zvìtšování bufferu indexù (položek)

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CMapBuf::CMapBuf()
{
	m_Data = NULL;			// nejsou data mapy
	m_Index = NULL;			// nejsou indexy mapy
	m_Num = 0;				// není žádná položka v bufferu
	m_DataNum = 0;			// poèet bajtù v bufferu dat mapy
	m_DataMax = 0;			// velikost bufferu dat mapy
	m_IndexMax = 0;			// velikost bufferu indexù map (položek)
}

CMapBuf::~CMapBuf()
{
	Aloc(m_Data,0);			// zrušení bufferu dat
	Aloc(m_Index,0);		// zrušení bufferu indexù
}


////////////////////////////////////////////////////////////////////
// pøidání položky do bufferu (vrací index)

short CMapBuf::Add(MAP* map)
{
// velikost pøidávané položky v bajtech
	int size = MapSize(map);

// zvìtšení bufferu indexù
	if (m_Num >= m_IndexMax)
	{
		m_IndexMax = m_Num + INDEXREZERVA;
		Aloc(m_Index, m_IndexMax);
	}

// zvìtšení bufferu dat
	if (m_DataNum+size > m_DataMax)
	{
		m_DataMax = m_DataNum + size + DATAREZERVA;
		Aloc(m_Data, m_DataMax);
	}

// kopie dat položky
	memcpy(m_Data + m_DataNum, map, size);

// nastavení indexu na položku
	m_Index[m_Num] = m_DataNum;

// zvýšení èítaèe položek
	m_Num++;

// zvýšení ukazatele velikosti dat v bufferu
	m_DataNum += size;

// navrácení indexu nové položky
	return m_Num-1;
}


////////////////////////////////////////////////////////////////////
// vytvoøení nové mapy daných rozmìrù (vrací index)

short CMapBuf::New(short width, short height)
{
// omezení velikosti mapy
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

// velikost nové položky v bajtech
	int size = (width*height-1)*sizeof(MAPITEM) + sizeof(MAP);

// zvìtšení bufferu indexù
	if (m_Num >= m_IndexMax)
	{
		m_IndexMax = m_Num + INDEXREZERVA;
		Aloc(m_Index, m_IndexMax);
	}

// zvìtšení bufferu dat
	if (m_DataNum+size > m_DataMax)
	{
		m_DataMax = m_DataNum + size + DATAREZERVA;
		Aloc(m_Data, m_DataMax);
	}

// adresa nové položky
	MAP* map = (MAP*)(m_Data + m_DataNum);

// inicializace dat položky
	map->width = width;
	map->height = height;
	memset(&map->item[0], 0, width*height*sizeof(MAPITEM));

// nastavení indexu na položku
	m_Index[m_Num] = m_DataNum;

// zvýšení èítaèe položek
	m_Num++;

// zvýšení ukazatele velikosti dat v bufferu
	m_DataNum += size;

// navrácení indexu nové položky
	return m_Num-1;
}


////////////////////////////////////////////////////////////////////
// nastavení nové velikosti mapy

void CMapBuf::SetSize(short Index, short width, short height)
{
// lokální promìnné
	int size;							// nová velikost položky
	int oldwidth;						// pùvodní šíøka položky
	int oldheight;						// pùvodní výška položky
	int oldsize;						// pùvodní velikost položky
	int difsize;						// rozdíl velikostí (zvýšení)
	short i;							// pracovní èítaè
	BYTE* src;							// ukazatele pøi operacích pøesunu
	BYTE* dst;

// kontrola indexu
	if ((Index < 0) || (Index >= m_Num))
		return;

// omezení velikosti mapy
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

// pùvodní velikost položky v bajtech
	oldsize = MapSize(Index);			// pùvodní velikost

// nová velikost položky v bajtech, rozdíl velikostí
	size = (width*height-1)*sizeof(MAPITEM) + sizeof(MAP);
	difsize = size - oldsize;			// rozdíl velikostí

// zvìtšení bufferu dat, je-li potøeba
	if (m_DataNum + difsize > m_DataMax)
	{
		m_DataMax = m_DataNum + difsize + DATAREZERVA;
		Aloc(m_Data, m_DataMax);
	}

// adresa korigované položky
	MAP* map = Get(Index);

// úschova pùvodních parametrù položky
	oldwidth = map->width;				// pùvodní šíøka položky
	oldheight = map->height;			// pùvodní výška položky

// oprava poètu øádkù
	if (height != oldheight)
	{
		src = (BYTE*)map + (oldwidth*oldheight-1)*sizeof(MAPITEM) + sizeof(MAP);
		dst = (BYTE*)map + (oldwidth*height-1)*sizeof(MAPITEM) + sizeof(MAP);

		if (Index < m_Num-1)
		{
			memmove(dst, src, m_DataNum - m_Index[Index+1]);
		}
		m_DataNum += (height-oldheight)*oldwidth*sizeof(MAPITEM);
		map->height = height;				// nová výška položky

		if (height > oldheight)
		{
			memset(src, 0, (height - oldheight)*oldwidth*sizeof(MAPITEM));
		}
	}

// oprava délky øádkù
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
		map->width = width;					// nová šíøka položky
	}

// korekce indexù na ostatní položky
	for (i = Index+1; i < m_Num-1; i++)
	{
		m_Index[i] += difsize;
	}
}


////////////////////////////////////////////////////////////////////
// zrušení položky

void CMapBuf::Delete(short Index)
{
// lokální promìnné
	short i, b;					// pracovní èítaèe
	int	size;					// velikost rušených dat
	CProgBuf* buf;				// ukazatel na programový buffer
	PROGITEM* item;				// ukazatel na položku programu

// kontrola indexu
	if ((Index < 0) || (Index >= m_Num))
		return;

// poèet bajtù ke zrušení
	size = MapSize(Index);

// zrušení dat položky (pøísun zbylých položek)
	if (Index < m_Num-1)
		memmove(&(m_Data[m_Index[Index]]), &(m_Data[m_Index[Index+1]]), 
			m_DataNum - m_Index[Index+1]);

// snížení èítaèe dat v bufferu
	m_DataNum -= size;

// zrušení indexu a korekce zbylých indexù
	for (i = Index; i < m_Num-1; i++)
	{
		m_Index[i] = m_Index[i+1] - size;
	}

// snížení èítaèe položek
	m_Num--;

// korekce referencí v programových bufferech
	for (b = 0; b < PROGBUFNUM; b++) // ukazatel èísla bufferu
	{
		buf = &m_ProgBuf[b]; // adresa bufferu

		for (i = buf->m_Num-1; i >= 0; i--) // èítání indexu položky dolù
		{
			item = &(buf->m_Items[i]);		// úschova adresy položky

			if ((item->data == BufMapID) &&	// odkaz na buffer mapy
				(item->index >= Index))		// index, který bude ovlivnìn
			{
				if (item->index == Index)	// je to rušený index ?
				{
					item->index = -1;		// zrušení odkazu
					item->data = -1;
				}
				else
					item->index--;			// jinak korekce indexu
			}
		}
	}
}

