
////////////////////////////////////////////////////////////////////
// t��da bufferu text�

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
//	CIntArray		m_Count;	// ��ta�e pou�it� text�

//	unsigned char*	m_Data;		// data i
//	unsigned char*	m_Mask;		// data masky ikon
//	int				m_Num;		// po�et ikon v bufferu
//	int				m_Width;	// ���ka jedn� ikony (bod�)
//	int				m_Height;	// v��ka jedn� ikony (linek)
//
//	BOOL Load(int num, int id);	// na�ten� ikon z resource
//	BOOL GenerMask();			// vygenerov�n� masky ikon
//	void AddList(CImageList* list); // p�id�n� ikon do seznamu ikon

};
