
////////////////////////////////////////////////////////////////////
// t��da bufferu ikon

class CIconBuf : public CObject
{
public:
	CIconBuf();					// konstruktor
	virtual ~CIconBuf();		// destruktor

	unsigned char*	m_Data;		// data ikon
	unsigned char*	m_Mask;		// data masky ikon
	int				m_Num;		// po�et ikon v bufferu
	int				m_Width;	// ���ka jedn� ikony (bod�)
	int				m_Height;	// v��ka jedn� ikony (linek)

	BOOL Load(int num, int id);	// na�ten� ikon z resource
	BOOL GenerMask();			// vygenerov�n� masky ikon
	void AddList(CImageList* list); // p�id�n� ikon do seznamu ikon
};
