
////////////////////////////////////////////////////////////////////
// t��da bufferu text�


////////////////////////////////////////////////////////////////////
// Pozn�mka - p�i kopii a p�esunu struktur se vytv��� nov� indexy
//            text�, star� se pouze vynuluj�, ale nechaj� se na m�st�.
//            T�m p�i editaci nar�st� tabulka index� text�, ale snad
//            by to nem�lo vadit - je dost rezerva a p�i ukon�en�
//            programu se v�e sprav�.
////////////////////////////////////////////////////////////////////

class CTextBuf : public CStringArray
{
public:
// konstruktor
	CTextBuf() { SetSize(0,100); };

// poskytnut� �et�zce s dan�m indexem
	inline CString Get(int nIndex) const
		{ return CStringArray::GetAt(nIndex); }

// nastaven� �et�zce s dan�m indexem
	inline void Set(int nIndex, LPCTSTR newElement)
		{ CStringArray::SetAt(nIndex, newElement); }

// p�id�n� �et�zce, vr�t� jeho index
//	int Add(CString);

// zru�en� v�ech text� v textov�m poli
//	void RemoveAll();

// zji�t�n� po�tu text� v textov�m poli (v�etn� nepou�it�ch)
//	int GetSize() const;

// reference na polo�ku v seznamu
//	CString& ElementAt(int nIndex);
};
