
////////////////////////////////////////////////////////////////////
// t��da bufferu ikon

class CIconBuf : public CObject
{
// konstruktor a destruktor
public:
	CIconBuf();					// konstruktor
	virtual ~CIconBuf();		// destruktor

// ukazatele bufferu
	unsigned char*	m_Data;		// data ikon
	int				m_Num;		// po�et ikon v bufferu
	int				m_Max;		// velikost bufferu
	int				m_Width;	// ���ka jedn� ikony (bod�)
	int				m_Height;	// v��ka jedn� ikony (linek)
	int				m_WidthByte;// d�lka jedn� linky v bajtech
	int				m_ItemSize;	// velikost jedn� ikony v bajtech

	BOOL			m_GenPal;	// p��znak vygenerov�n� palet pro LoadFile

// nastaven� nov� velikosti bufferu (v po�tech ikon)
	void SetSize(int NewSize);

// poskytnut� po�tu ikon
	inline int GetSize() const
		{ return m_Num; }

// poskytnut� adresy ikony (kontroluje meze - p��p. vrac� ikonu 0)
	inline unsigned char* Get(int Index) const
	{
		if ((Index <= 0) || (Index >= m_Num))
			return m_Data;
		else
			return &m_Data[m_ItemSize*Index];
	}

// nastaven� dat ikony
	inline void Set(int Index, unsigned char* data)
	{
		memcpy(Get(Index), data, m_ItemSize);
	}

// p�id�n� nov� ikony (vrac� index)
	inline int Add(unsigned char* data)
	{
		SetSize(m_Num+1);		// nastaven� nov� velikosti bufferu
		Set(m_Num-1, data);		// nastaven� dat ikony
		return m_Num-1;			// index nov� polo�ky
	}

// zalo�en� nov� (pr�zdn�) ikony (vrac� index)
	inline int New()
	{
		SetSize(m_Num+1);		// nastaven� nov� velikosti bufferu
		memcpy(Get(m_Num-1), m_Data, m_ItemSize);
		return m_Num-1;			// index nov� polo�ky
	}

// duplikace ikony (kontroluje meze - p��p. pou�ije 0, vrac� index nov� ikony)
	inline int Duplik(int Index)
	{
		SetSize(m_Num+1);		// nastaven� nov� velikosti bufferu
		Set(m_Num-1, Get(Index)); // nastaven� dat ikony
		return m_Num-1;			// index nov� polo�ky
	}

// v�pr�zdn�n� cel�ho bufferu
	inline void RemoveAll() { m_Num = 0; }

// zru�en� polo�ky (implicitn� 1 polo�ka)
	void Delete(int Index, int Count = 1);

// na�ten� ikon z resource
	void LoadRes(int id);

// na�ten� ikony ze souboru (vrac� index ikony)
	int LoadFile(CString name);

// vygenerov�n� dat bitmapy (vrac� ukazatel na data vytvo�en� pomoc� Aloc)
// barevn� bitmapa m� na konci rezervu pro zarovn�n� linky na 8 bajt�
	unsigned char* GenerBitmap();

// vygenerov�n� masky z barevn� bitmapy (vrac� ukazatel na data pomoc� Aloc)
// barevn� bitmapa mus� m�t na konci rezervu pro zarovn�n� linky na 8 bajt�
	unsigned char* GenerMask(unsigned char* bitmapa);

// vygenerov�n� seznamu ikon (vrac� ukazatel na seznam ikon)
	CImageList* GenerList();
};
