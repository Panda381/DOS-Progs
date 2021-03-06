
////////////////////////////////////////////////////////////////////
// definice polo�ky mapy
//
// Polo�ky jsou v map� ukl�d�ny zleva doprava od spodn�ho ��dku nahoru

#define MAXMAPWIDTH		1000	// maxim�ln� ���ka mapy
#define	MAXMAPHEIGHT	1000	// maxim�ln� v��ka mapy
#define	MAXMAPSIZE		100000	// maxim�ln� velikost mapy


typedef struct tagMAPITEM {
	short			icon;	// index ikony pol��ka
	unsigned short	param;	// parametry pol��ka - hodnota a p��znaky
} MAPITEM;

typedef struct tagMAP {
	short	width;			// ���ka plochy
	short	height;			// v��ka ikony
	MAPITEM	item[1];		// polo�ky mapy
} MAP;

// parametry:
#define	MAP_VALUE		0x03FF	// maska hodnoty pol��ka
#define MAP_FLAG0		0x0400	// p��znak 0
#define MAP_FLAG1		0x0800	// p��znak 1
#define MAP_FLAG2		0x1000	// p��znak 2
#define MAP_FLAG3		0x2000	// p��znak 3
#define MAP_FLAG4		0x4000	// p��znak 4
#define MAP_FLAG5		0x8000	// p��znak 5


////////////////////////////////////////////////////////////////////
// t��da bufferu mapy

class CMapBuf : public CObject
{
public:
	CMapBuf();				// konstruktor
	virtual ~CMapBuf();		// destruktor

	BYTE*		m_Data;		// data map
	int*		m_Index;	// indexy map

	short		m_Num;		// po�et polo�ek v bufferu
	short		m_IndexMax;	// velikost bufferu index� map (polo�ek)

	int			m_DataNum;	// po�et bajt� v bufferu dat map
	int			m_DataMax;	// velikost bufferu dat map (bajt�)

	CProgBuf*	m_ProgBuf;	// adresa tabulky buffer�

// vypr�zdn�n� bufferu
	inline void RemoveAll()
	{
		m_Num = 0;
		m_DataNum = 0;
	}

// zji�t�n� adresy polo�ky
	inline MAP* Get(short Index)
	{
		if ((Index <= 0) || (Index >= m_Num))
			return (MAP*) m_Data;
		else
			return (MAP*) &(m_Data[m_Index[Index]]);
	}

// navr�cen� po�tu polo�ek v bufferu
	inline short GetNum()
		{ return m_Num; }

// p�id�n� nov� polo�ky do bufferu
	short Add(MAP* item);

// vytvo�en� nov� mapy dan�ch rozm�r� (vrac� index, omez� velikost)
	short New(short width, short height);

// v�po�et velikosti mapy v bajtech
	inline int MapSize(MAP* map)
		{ return (map->width*map->height-1)*sizeof(MAPITEM) + sizeof(MAP); }

	inline int MapSize(short Index)
		{ return MapSize(Get(Index)); }

// zru�en� polo�ky z bufferu
	void Delete(short Index);

// nastaven� nov� velikosti mapy (omez� velikost)
	void SetSize(short Index, short width, short height);
};

