
////////////////////////////////////////////////////////////////////
// tøída bufferu textù

class CTextBuf : public CStringArray
{
public:
	CTextBuf();
//	virtual ~CTextBuf();

	inline CString Get(int nIndex) const
		{ return CStringArray::GetAt(nIndex); }
	inline void Set(int nIndex, LPCTSTR newElement)
		{ CStringArray::SetAt(nIndex, newElement); }

//	CStringArray	m_Text;		// buffer s texty
//	CIntArray		m_Count;	// èítaèe použití textù

//	unsigned char*	m_Data;		// data i
//	unsigned char*	m_Mask;		// data masky ikon
//	int				m_Num;		// poèet ikon v bufferu
//	int				m_Width;	// šíøka jedné ikony (bodù)
//	int				m_Height;	// výška jedné ikony (linek)
//
//	BOOL Load(int num, int id);	// naètení ikon z resource
//	BOOL GenerMask();			// vygenerování masky ikon
//	void AddList(CImageList* list); // pøidání ikon do seznamu ikon

};
