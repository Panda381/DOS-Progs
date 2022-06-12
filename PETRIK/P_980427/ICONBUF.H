
////////////////////////////////////////////////////////////////////
// tøída bufferu ikon

class CIconBuf : public CObject
{
// konstruktor a destruktor
public:
	CIconBuf();					// konstruktor
	virtual ~CIconBuf();		// destruktor

// ukazatele bufferu
	unsigned char*	m_Data;		// data ikon
	int				m_Num;		// poèet ikon v bufferu
	int				m_Max;		// velikost bufferu
	int				m_Width;	// šíøka jedné ikony (bodù)
	int				m_Height;	// výška jedné ikony (linek)
	int				m_WidthByte;// délka jedné linky v bajtech
	int				m_ItemSize;	// velikost jedné ikony v bajtech

	BOOL			m_GenPal;	// pøíznak vygenerování palet pro LoadFile

// nastavení nové velikosti bufferu (v poètech ikon)
	void SetSize(int NewSize);

// poskytnutí poètu ikon
	inline int GetSize() const
		{ return m_Num; }

// poskytnutí adresy ikony (kontroluje meze - pøíp. vrací ikonu 0)
	inline unsigned char* Get(int Index) const
	{
		if ((Index <= 0) || (Index >= m_Num))
			return m_Data;
		else
			return &m_Data[m_ItemSize*Index];
	}

// nastavení dat ikony
	inline void Set(int Index, unsigned char* data)
	{
		memcpy(Get(Index), data, m_ItemSize);
	}

// pøidání nové ikony (vrací index)
	inline int Add(unsigned char* data)
	{
		SetSize(m_Num+1);		// nastavení nové velikosti bufferu
		Set(m_Num-1, data);		// nastavení dat ikony
		return m_Num-1;			// index nové položky
	}

// založení nové (prázdné) ikony (vrací index)
	inline int New()
	{
		SetSize(m_Num+1);		// nastavení nové velikosti bufferu
		memcpy(Get(m_Num-1), m_Data, m_ItemSize);
		return m_Num-1;			// index nové položky
	}

// duplikace ikony (kontroluje meze - pøíp. použije 0, vrací index nové ikony)
	inline int Duplik(int Index)
	{
		SetSize(m_Num+1);		// nastavení nové velikosti bufferu
		Set(m_Num-1, Get(Index)); // nastavení dat ikony
		return m_Num-1;			// index nové položky
	}

// výprázdnìní celého bufferu
	inline void RemoveAll() { m_Num = 0; }

// zrušení položky (implicitnì 1 položka)
	void Delete(int Index, int Count = 1);

// naètení ikon z resource
	void LoadRes(int id);

// naètení ikony ze souboru (vrací index ikony)
	int LoadFile(CString name);

// vygenerování dat bitmapy (vrací ukazatel na data vytvoøená pomocí Aloc)
// barevná bitmapa má na konci rezervu pro zarovnání linky na 8 bajtù
	unsigned char* GenerBitmap();

// vygenerování masky z barevné bitmapy (vrací ukazatel na data pomocí Aloc)
// barevná bitmapa musí mít na konci rezervu pro zarovnání linky na 8 bajtù
	unsigned char* GenerMask(unsigned char* bitmapa);

// vygenerování seznamu ikon (vrací ukazatel na seznam ikon)
	CImageList* GenerList();
};
