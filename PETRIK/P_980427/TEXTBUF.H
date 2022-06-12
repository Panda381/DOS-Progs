
////////////////////////////////////////////////////////////////////
// tøída bufferu textù


////////////////////////////////////////////////////////////////////
// Poznámka - pøi kopii a pøesunu struktur se vytváøí nové indexy
//            textù, staré se pouze vynulují, ale nechají se na místì.
//            Tím pøi editaci narùstá tabulka indexù textù, ale snad
//            by to nemìlo vadit - je dost rezerva a pøi ukonèení
//            programu se vše spraví.
////////////////////////////////////////////////////////////////////

class CTextBuf : public CStringArray
{
public:
// konstruktor
	CTextBuf() { SetSize(0,100); };

// poskytnutí øetìzce s daným indexem
	inline CString Get(int nIndex) const
		{ 
			if (nIndex >= 0)
				return CStringArray::GetAt(nIndex);
			else
				return _T("");
		}

// nastavení øetìzce s daným indexem
	inline void Set(int nIndex, LPCTSTR newElement)
		{ CStringArray::SetAt(nIndex, newElement); }

// zrušení (vyprázdnìní) øetìzce
	inline void Delete(int nIndex)
		{ CStringArray::ElementAt(nIndex).Empty(); }

// pøidání øetìzce, vrátí jeho index
//	int Add(CString);

// zrušení všech textù v textovém poli
//	void RemoveAll();

// zjištìní poètu textù v textovém poli (vèetnì nepoužitých)
//	int GetSize() const;

// reference na položku v seznamu
//	CString& ElementAt(int nIndex);
};
