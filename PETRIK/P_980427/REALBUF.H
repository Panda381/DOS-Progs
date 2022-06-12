
////////////////////////////////////////////////////////////////////
// tøída bufferu èísel

////////////////////////////////////////////////////////////////////
// Poznámka - pøi kopii a pøesunu struktur se vytváøí nové položky
//            èísel, staré se nechají se na místì.
////////////////////////////////////////////////////////////////////

class CRealBuf : public CObject
{
public:
// konstruktor a destruktor
	CRealBuf();
	virtual ~CRealBuf();

// data
	double* m_pData;			// ukazatel na data
	int m_nSize;				// poèet prvkù
	int m_nMaxSize;				// maximální velikost bufferu

// zjištìní poètu položek v bufferu
	inline int GetSize() const 
		{ return m_nSize; }

// nastavení nové velikosti bufferu
	void SetSize(int nNewSize);

// poskytnutí položky na dané pozici
	inline double Get(int nIndex) const
		{ 
			if (nIndex < 0 || nIndex >= m_nSize)
				return 0;
			else
				return m_pData[nIndex]; 
		}

// nastavení položky na dané pozici
	inline void Set(int nIndex, double newElement)
		{
			if (nIndex >= 0 && nIndex < m_nSize)
				m_pData[nIndex] = newElement;
		}

// pøístup k položce pole
	inline double& operator[] (int nIndex)
		{ 
			ASSERT(nIndex >= 0 && nIndex < m_nSize);
			return m_pData[nIndex]; 
		}

// pøidání položky na konec pole
	inline int Add(double newElement)
		{
			SetSize(m_nSize+1);
			m_pData[m_nSize-1] = newElement;
			return m_nSize-1;
		}

// vyprázdnìní celého bufferu
	inline void RemoveAll() { SetSize(0); }

// zrušení položky s daným indexem (implicitnì 1 položka)
	void Delete(int nIndex, int nCount = 1);
};
