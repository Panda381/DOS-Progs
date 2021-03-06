
////////////////////////////////////////////////////////////////////
// t��da bufferu logick�ch hodnot

////////////////////////////////////////////////////////////////////
// Pozn�mka - p�i kopii a p�esunu struktur se vytv��� nov� polo�ky,
//            star� se nechaj� se na m�st�.
////////////////////////////////////////////////////////////////////

class CBoolBuf : public CObject
{
public:
// konstruktor a destruktor
	CBoolBuf();
	~CBoolBuf();

// data
	char* m_pData;			// ukazatel na data
	int m_nSize;				// po�et prvk�
	int m_nMaxSize;				// maxim�ln� velikost bufferu

// zji�t�n� po�tu polo�ek v bufferu
	inline int GetSize() const 
		{ return m_nSize; }

// nastaven� nov� velikosti bufferu
	void SetSize(int nNewSize);

// poskytnut� polo�ky na dan� pozici
	inline char Get(int nIndex) const
		{ 
			if (nIndex < 0 || nIndex >= m_nSize)
				return 0;
			else
				return m_pData[nIndex]; 
		}

// nastaven� polo�ky na dan� pozici
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

// p��stup k polo�ce pole
	inline char& operator[] (int nIndex)
		{ 
			ASSERT(nIndex >= 0 && nIndex < m_nSize);
			return m_pData[nIndex]; 
		}

// p�id�n� polo�ky na konec pole
	inline int Add(char newElement)
		{
			SetSize(m_nSize+1);
			if (newElement == 0)
				m_pData[m_nSize-1] = 0;
			else
				m_pData[m_nSize-1] = -1;
			return m_nSize-1;
		}

// vypr�zdn�n� cel�ho bufferu
	inline void RemoveAll() { SetSize(0); }

// zru�en� polo�ky s dan�m indexem (implicitn� 1 polo�ka)
	void Delete(int nIndex, int nCount = 1);
};
