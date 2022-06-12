
///////////////////////////////////////////////////////////////////////////////
//
//                              Base Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// filter category (determines how to display filter content)
// on change update FiltCol table!
typedef enum FILTERCAT {
	FCAT_IMG = 0,			// color image or function (X and Y coordinates, RenderCol)
	FCAT_CURVE,				// curve (X coordinate, RenderVal, may depend on Y)
	FCAT_PIN,				// pin
	FCAT_INVALUE,			// IN input value filter
	FCAT_INCOLOR,			// IN input color filter
	FCAT_INIMAGE,			// IN input image filter CFilterImage
	FCAT_INIMAGEDATA,		// IN input image data filter (not visible to user)
	FCAT_OUT,				// OUT output filter
	FCAT_TABLE,				// table
	FCAT_BRICK,				// brick or paving
	FCAT_LOOPBEGIN,			// LoopBegin
	FCAT_LOOPEND,			// LoopEnd
	FCAT_SYS,				// system values
	FCAT_PARTICLE,			// particle
};

#define FCAT_IN_MIN		FCAT_INVALUE // first input filter
#define FCAT_IN_MAX		FCAT_INIMAGE // last input filter 

// filter group
// on change update ID_GROUP_LIST
typedef enum FILTERGRP {
	FGRP_COL = 0,			// color
	FGRP_MATH,				// mathematics
	FGRP_MUX,				// combinations
	FGRP_TRANS,				// transformations
	FGRP_PAT,				// patterns
	FGRP_MAT,				// materials
	FGRP_CUR,				// curves
	FGRP_GRAD,				// gradients
	FGRP_PROC,				// processing
	FGRP_DEF,				// deformations
	FGRP_INOUT,				// inputs/outputs
	FGRP_DEBUG,				// support

	FGRP_NUM
};

#define MAXPROP		50			// maximum number of properties

// dimensions
#define GRID		8			// grid module
#define FPREVWH		(8*GRID)	// filter preview size = 64 (need be even multiple of grid!)
#define FILTERW		(20*GRID)	// filter default width = 160 (need be multiple of grid!)
#define FILTERPINW	(4*GRID)	// pin width
#define FILTERH		(FPREVWH+2*GRID) // filter minimal height = 72 (need be even multiple of grid!)
#define FILTERVALH	(4*GRID)	// filter Value or Color height
#define FILTERTH	(2*GRID)	// filter title height = 16 (need be even multiple of grid!)
#define FILTERDY	(2*GRID)	// line delta = 16 (need be even multiple of grid!)
#define FGRPGAP		(2*GRID)	// gap between filters in group list
#define FGRPW		(FILTERW+FGRPGAP) // group picture width

#define FGRPBG		0xffffff	// filter group list background color

// filter duplicate function template (on change update CFilterImage)
#define FILTER_DUPLICATE(cls) virtual CFilter* Duplicate() const { cls* f = new cls; *f = *this; f->_dupcor(); return f; }

// general filter
class CFilter : public CListEntryData<CFilter>
{
protected:

	// filter category
	FILTERCAT	m_Category;

	// filter group
	FILTERGRP	m_Group;

	// filter identifying name
	CText		m_Name;

	// filter class name
	CText		m_Class;

	// filter help topic
	int			m_HelpID;

	// filter coordinates in graph
	int			m_X;
	int			m_Y;

	// filter image base height and width (without title)
	int			m_BaseH;
	int			m_BaseW;

	// output Y coordinate
	int			m_BaseOutY;

	// number of filter properties
	int			m_PropNum;

	// array of filter properties
	CProperty	m_Prop[MAXPROP];

	// filter base image (NULL=hidden internal filter, not connected)
	SCanvas*	m_Image;

	// filter preview (SCavnas structure)
	u8			m_Preview[CANVAS_SIZE + FPREVWH*FPREVWH*3 + 1];

	// request to generate preview
	BOOL		m_ReqPrev;

	// restart rendering (used by some filters to start again)
	volatile BOOL m_Restart;

	// filter is selected
	BOOL		m_Selected;

	// filter remapping during duplicate graph of filter
	CFilter*	m_FilterMap;

	// correction after duplication
	inline void _dupcor()
		{ for (int i = 0; i < MAXPROP; i++) m_Prop[i].SetParent(this); m_Restart = TRUE; }

public:

	// constructor
	CFilter();

	// destructor
	virtual ~CFilter() {}

	// filter category
	inline FILTERCAT Category() const { return m_Category; }
	inline void SetCategory(FILTERCAT cat) { m_Category = cat; this->InitBaseH(); }

	// filter group
	inline FILTERGRP Group() const { return m_Group; }
	inline void SetGroup(FILTERGRP group) { m_Group = group; }

	// filter identifying name
	inline CText Name() const { return m_Name; }
	inline void SetName(const CText& name) { m_Name = name; }

	// filter class name
	inline CText Class() const { return m_Class; }
	inline void SetClass(const CText& cls) { m_Class = cls; }

	// filter help topic
	inline int HelpID() const { return m_HelpID; }

	// filter image base height and width (without title FILTERTH)
	inline int BaseH() const { return m_BaseH; }
	inline int BaseW() const { return m_BaseW; }
	void InitBaseH();

	// output Y coordinate
	inline int BaseOutY() const { return m_BaseOutY; }

	// number of filter properties
	inline int PropNum() const { return m_PropNum; }
	inline void SetPropNum(int num) { m_PropNum = num; this->InitBaseH(); }

	// filter property
	inline CProperty* Prop(int inx) { return &m_Prop[inx]; }
	inline int PropInx(CProperty* prop) const { return (int)(prop - m_Prop); }

	// filter coordinates in graph
	inline int X() const { return m_X; }
	inline void SetX(int x) { m_X = x; }
	inline int Y() const { return m_Y; }
	inline void SetY(int y) { m_Y = y; }
	inline int W() const { return m_Image->w; }
	inline int H() const { return m_Image->h; }
	inline int X2() const { return m_X + m_Image->w; }
	inline int Y2() const { return m_Y + m_Image->h; }
	inline int PropX() const { return m_X; }
	int PropY(int inx) const;
	inline int PropY(CProperty* prop) const { return this->PropY(PropInx(prop)); }
	inline int OutX() const { return m_X + m_BaseW + 3; }
	inline int OutY() const { return m_BaseOutY + m_Y; }

	// filter base image (NULL=hidden internal filter, not connected)
	inline SCanvas* Image() const { return m_Image; }
	inline void SetImage(SCanvas* canvas) { m_Image = canvas; }

	// filter preview
	inline SCanvas* Preview() { return (SCanvas*)&m_Preview[0]; }

	// request to generate preview
	inline BOOL ReqPrev() const { return m_ReqPrev; }
	inline void SetReqPrev(BOOL req) { m_ReqPrev = req; if (req) m_Restart = TRUE; }
	inline void Restart() { m_Restart = TRUE; }

	// filter is selected
	inline BOOL Selected() const { return m_Selected; }
	inline void SetSelected(BOOL sel) { m_Selected = sel; }

	// filter remapping during duplicate graph of filter
	inline CFilter* FilterMap() const { return m_FilterMap; }
	inline void SetFilterMap(CFilter* f) { m_FilterMap = f; }

	// duplicate filter
	FILTER_DUPLICATE(CFilter);
	
	// open filter on start of rendering one image (returns FALSE on error)
	//virtual BOOL Open() { return TRUE; };

	// close filter on end of rendering one image
	//virtual void Close() {};

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y) { col->SetBlack(); }

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y) { return 0; }
};

#define PROP_SOURCE		0		// property - Source
#define PROP_SOURCE2	1		// property - Source2
#define PROP_SOURCE3	2		// property - Source3
#define PROP_SOURCE4	3		// property - Source4
#define PROP_SOURCE5	4		// property - Source5
#define PROP_SOURCE6	5		// property - Source6
#define PROP_SOURCE7	6		// property - Source7
#define PROP_SOURCE8	7		// property - Source8
#define PROP_SOURCE9	8		// property - Source9
#define PROP_SOURCE10	9		// property - Source10

// base filter with 1 source property
class CFilterSource abstract : public CFilter
{
public:

	// constructor
	CFilterSource();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y)
	{
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	}

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y)
	{
		return m_Prop[PROP_SOURCE].RenderVal(x, y);
	}
};

// pin
class CFilterPin : public CFilterSource
{
public:

	// constructor
	CFilterPin();

	// duplicate filter
	FILTER_DUPLICATE(CFilterPin);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y)
	{
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	}

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y)
	{
		return m_Prop[PROP_SOURCE].RenderVal(x, y);
	}
};

// base filter with 2 source properties
class CFilterSource2 abstract : public CFilterSource
{
public:

	// constructor
	CFilterSource2();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource2);
};

// base filter with 3 source properties
class CFilterSource3 abstract : public CFilterSource2
{
public:

	// constructor
	CFilterSource3();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource3);
};

// base filter with 4 source properties
class CFilterSource4 abstract : public CFilterSource3
{
public:

	// constructor
	CFilterSource4();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource4);
};

// base filter with 5 source properties
class CFilterSource5 abstract : public CFilterSource4
{
public:

	// constructor
	CFilterSource5();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource5);
};

// base filter with 6 source properties
class CFilterSource6 abstract : public CFilterSource5
{
public:

	// constructor
	CFilterSource6();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource6);
};

// base filter with 7 source properties
class CFilterSource7 abstract : public CFilterSource6
{
public:

	// constructor
	CFilterSource7();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource7);
};

// base filter with 8 source properties
class CFilterSource8 abstract : public CFilterSource7
{
public:

	// constructor
	CFilterSource8();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource8);
};

// base filter with 9 source properties
class CFilterSource9 abstract : public CFilterSource8
{
public:

	// constructor
	CFilterSource9();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource9);
};

// base filter with 10 source properties
class CFilterSource10 abstract : public CFilterSource9
{
public:

	// constructor
	CFilterSource10();

	// duplicate filter
	//FILTER_DUPLICATE(CFilterSource10);
};

// filter template list
#define TEMPLATENUM 1000
extern int TemplateNum;
extern CFilter*		Template[TEMPLATENUM];

// filter base image list
extern SCanvas*		FilterImageList[TEMPLATENUM];

// group list (0=all filters)
extern int			GroupNum[FGRP_NUM+1];			// number of filters in groups
extern CFilter*		GroupFilters[FGRP_NUM+1][TEMPLATENUM];	// group filters (Y=position in group image)
extern int			GroupFiltersY[FGRP_NUM+1][TEMPLATENUM];	// group filters Y position in group list
extern int			GroupFiltersH[FGRP_NUM+1][TEMPLATENUM];	// group filters height in group list
extern SCanvas*		GroupImageList[FGRP_NUM+1];	// group images
extern BITMAPINFO	GroupImageBMP[FGRP_NUM+1];	// group images bitmap info
extern int			GroupFiltersTop[FGRP_NUM+1];	// top of group filters

///////////////////////////////////////////////////////////////////////////////
// fill up filter template list

void TempFillUp();
