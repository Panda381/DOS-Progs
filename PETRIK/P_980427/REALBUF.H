
////////////////////////////////////////////////////////////////////
// t��da bufferu ��sel

////////////////////////////////////////////////////////////////////
// Pozn�mka - p�i kopii a p�esunu struktur se vytv��� nov� polo�ky
//            ��sel, star� se nechaj� se na m�st�.
////////////////////////////////////////////////////////////////////

class CRealBuf : public CObject
{
public:
// konstruktor a destruktor
	CRealBuf();
	virtual ~CRealBuf();

// data
	double* m_pData;			// ukazatel na data
	int m_nSize;				// po�et prvk�
	int m_nMaxSize;				// maxim�ln� velikost bufferu

// zji�t�n� po�tu polo�ek v bufferu
	inline int GetSize() const 
		{ return m_nSize; }

// nastaven� nov� velikosti bufferu
	void SetSize(int nNewSize);

// poskytnut� polo�ky na dan� pozici
	inline double Get(int nIndex) const
		{ 
			if (nIndex < 0 || nIndex >= m_nSize)
				return 0;
			else
				return m_pData[nIndex]; 
		}

// nastaven� polo�ky na dan� pozici
	inline void Set(int nIndex, double newElement)
		{
			if (nIndex >= 0 && nIndex < m_nSize)
				m_pData[nIndex] = newElement;
		}

// p��stup k polo�ce pole
	inline double& operator[] (int nIndex)
		{ 
			ASSERT(nIndex >= 0 && nIndex < m_nSize);
			return m_pData[nIndex]; 
		}

// p�id�n� polo�ky na konec pole
	inline int Add(double newElement)
		{
			SetSize(m_nSize+1);
			m_pData[m_nSize-1] = newElement;
			return m_nSize-1;
		}

// vypr�zdn�n� cel�ho bufferu
	inline void RemoveAll() { SetSize(0); }

// zru�en� polo�ky s dan�m indexem (implicitn� 1 polo�ka)
	void Delete(int nIndex, int nCount = 1);
};
