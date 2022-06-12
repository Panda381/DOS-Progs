
////////////////////////////////////////////////////////////////////
// definice položky mapy
//
// Položky jsou v mapì ukládány zleva doprava od spodního øádku nahoru

#define MAXMAPWIDTH		1000	// maximální šíøka mapy
#define	MAXMAPHEIGHT	1000	// maximální výška mapy
#define	MAXMAPSIZE		100000	// maximální velikost mapy


typedef struct tagMAPITEM {
	short			icon;	// index ikony políèka
	unsigned short	param;	// parametry políèka - hodnota a pøíznaky
} MAPITEM;

typedef struct tagMAP {
	short	width;			// šíøka plochy
	short	height;			// výška ikony
	MAPITEM	item[1];		// položky mapy
} MAP;

// parametry:
#define	MAP_VALUE		0x03FF	// maska hodnoty políèka
#define MAP_FLAG0		0x0400	// pøíznak 0
#define MAP_FLAG1		0x0800	// pøíznak 1
#define MAP_FLAG2		0x1000	// pøíznak 2
#define MAP_FLAG3		0x2000	// pøíznak 3
#define MAP_FLAG4		0x4000	// pøíznak 4
#define MAP_FLAG5		0x8000	// pøíznak 5


////////////////////////////////////////////////////////////////////
// tøída bufferu mapy

class CMapBuf : public CObject
{
public:
	CMapBuf();				// konstruktor
	virtual ~CMapBuf();		// destruktor

	BYTE*		m_Data;		// data map
	int*		m_Index;	// indexy map

	short		m_Num;		// poèet položek v bufferu
	short		m_IndexMax;	// velikost bufferu indexù map (položek)

	int			m_DataNum;	// poèet bajtù v bufferu dat map
	int			m_DataMax;	// velikost bufferu dat map (bajtù)

	CProgBuf*	m_ProgBuf;	// adresa tabulky bufferù

// vyprázdnìní bufferu
	inline void RemoveAll()
	{
		m_Num = 0;
		m_DataNum = 0;
	}

// zjištìní adresy položky
	inline MAP* Get(short Index)
	{
		if ((Index <= 0) || (Index >= m_Num))
			return (MAP*) m_Data;
		else
			return (MAP*) &(m_Data[m_Index[Index]]);
	}

// navrácení poètu položek v bufferu
	inline short GetNum()
		{ return m_Num; }

// pøidání nové položky do bufferu
	short Add(MAP* item);

// vytvoøení nové mapy daných rozmìrù (vrací index, omezí velikost)
	short New(short width, short height);

// výpoèet velikosti mapy v bajtech
	inline int MapSize(MAP* map)
		{ return (map->width*map->height-1)*sizeof(MAPITEM) + sizeof(MAP); }

	inline int MapSize(short Index)
		{ return MapSize(Get(Index)); }

// zrušení položky z bufferu
	void Delete(short Index);

// nastavení nové velikosti mapy (omezí velikost)
	void SetSize(short Index, short width, short height);
};

