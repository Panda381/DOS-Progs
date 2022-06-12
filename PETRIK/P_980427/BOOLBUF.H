
////////////////////////////////////////////////////////////////////
// tøída bufferu logických hodnot

////////////////////////////////////////////////////////////////////
// Poznámka - pøi kopii a pøesunu struktur se vytváøí nové položky,
//            staré se nechají se na místì.
////////////////////////////////////////////////////////////////////

class CBoolBuf : public CObject
{
public:
// konstruktor a destruktor
	CBoolBuf();
	~CBoolBuf();

// data
	char* m_pData;			// ukazatel na data
	int m_nSize;				// poèet prvkù
	int m_nMaxSize;				// maximální velikost bufferu

// zjištìní poètu položek v bufferu
	inline int GetSize() const 
		{ return m_nSize; }

// nastavení nové velikosti bufferu
	void SetSize(int nNewSize);

// poskytnutí položky na dané pozici
	inline char Get(int nIndex) const
		{ 
			if (nIndex < 0 || nIndex >= m_nSize)
				return 0;
			else
				return m_pData[nIndex]; 
		}

// nastavení položky na dané pozici
	inline void Set(int nIndex, char newElement)
		{
			if (nIndex >= 0 && nIndex < m_nSize)
			{
				if (newElement == 0)
					m_pData[nIndex] = 0;
				else
					m_pData[nIndex] = -1;
			}
		}

// pøístup k položce pole
	inline char& operator[] (int nIndex)
		{ 
			ASSERT(nIndex >= 0 && nIndex < m_nSize);
			return m_pData[nIndex]; 
		}

// pøidání položky na konec pole
	inline int Add(char newElement)
		{
			SetSize(m_nSize+1);
			if (newElement == 0)
				m_pData[m_nSize-1] = 0;
			else
				m_pData[m_nSize-1] = -1;
			return m_nSize-1;
		}

// vyprázdnìní celého bufferu
	inline void RemoveAll() { SetSize(0); }

// zrušení položky s daným indexem (implicitnì 1 položka)
	void Delete(int nIndex, int nCount = 1);
};
