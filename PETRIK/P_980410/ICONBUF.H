
////////////////////////////////////////////////////////////////////
// tøída bufferu ikon

class CIconBuf : public CObject
{
public:
	CIconBuf();					// konstruktor
	virtual ~CIconBuf();		// destruktor

	unsigned char*	m_Data;		// data ikon
	unsigned char*	m_Mask;		// data masky ikon
	int				m_Num;		// poèet ikon v bufferu
	int				m_Width;	// šíøka jedné ikony (bodù)
	int				m_Height;	// výška jedné ikony (linek)

	BOOL Load(int num, int id);	// naètení ikon z resource
	BOOL GenerMask();			// vygenerování masky ikon
	void AddList(CImageList* list); // pøidání ikon do seznamu ikon
};
