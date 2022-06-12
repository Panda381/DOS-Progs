
///////////////////////////////////////////////////////////////////////////////
//
//                              Base Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// property category (determines color of how to display a pin and type of user interface)
// on change update PropCol table!
typedef enum PROPCAT {
	PCAT_VAL = 0,			// GRAY: numeric value (value input)
	PCAT_COLOR = 1,			// GREEN: color selection (color input)
	PCAT_CURVE = 2,			// BLUE: remap curve (value -> X -> value, value input, default linear)
	PCAT_GRAD = 3,			// RED: remap gradient (value -> X -> color, color input, default black->white)
	PCAT_ENUM = 4,			// YELLOW: enumeration values (value input)
	PCAT_CHECK = 5,			// BLACK: check box
	PCAT_LOOPBEGIN = 6,		// GREEN: output from LoopBegin
	PCAT_LOOPEND = 7,		// GREEN: output from LoopEnd
	PCAT_PARTICLE = 8,		// GREEN: output from Particle
};

class CFilter;

// filter property
class CProperty
{
protected:

	// parent of this property
	CFilter*	m_Parent;

	// property category
	PROPCAT		m_Category;

	// property name (displayed in filter icon)
	CText		m_Name;

	// tooltip ID
	int			m_ToolID;

	// source filter (NULL=use default value, of FLinear if PCAT_CURVE or PCAT_GRAD default)
	CFilter*	m_Filter;

	// default color (typically 0..1)
	CColor		m_Color;

	// default value (typically 0..1)
	real		m_Value;

	// minimal numeric user value (to recalculate to range 0..1)
	int			m_Min;
	real		m_MinVal;

	// maximal numeric user value (to recalculate to range 0..1)
	int			m_Max;
	real		m_MaxVal;

	// number of enumeration entries (can be shorter than number of steps)
	int			m_EnumNum;

	// list of enumeration entries
	CText*		m_Enum;

	// render color with default value (if m_Filter = NULL)
	void _RenderColD(CColor* col, real x, real y);

	// render color with filter (coordinates and output are typically in range 0..1)
	void _RenderColF(CColor* col, real x, real y);

	// render color pointer (coordinates and output are typically in range 0..1)
	void (CProperty::*pRenderCol) (CColor* col, real x, real y);
	
	// render value with default value (if m_Filter = NULL)
	real _RenderValD(real x, real y);

	// render value with filter (coordinates and output are typically in range 0..1)
	real _RenderValF(real x, real y);

	// render value pointer (coordinates and output are typically in range 0..1)
	real (CProperty::*pRenderVal) (real x, real y);

public:

	// constructor
	CProperty();

	// render color (coordinates and output are typically in range 0..1)
	inline void RenderCol(CColor* col, real x, real y) { (this->*pRenderCol)(col, x, y); }

	// render value (coordinates and output are typically in range 0..1)
	inline real RenderVal(real x, real y) { return (this->*pRenderVal)(x, y); }

	// get derivation in X and Y directiony (returns average height level)
	real Derive(real x, real y, real* dx, real* dy);

	// parent of this property
	inline CFilter* Parent() const { return m_Parent; }
	inline void SetParent(CFilter* parent) { m_Parent = parent; }

	// property category
	inline PROPCAT Category() const { return m_Category; }
	inline void SetCategory(PROPCAT cat) { m_Category = cat; }

	// property name (displayed in filter icon)
	inline CText Name() const { return m_Name; }
	inline void SetName(const CText& name) { m_Name = name; }

	// tooltip ID
	inline int ToolID() const { return m_ToolID; }
	inline void SetToolID(int id) { m_ToolID = id; }

	// source filter (NULL=use default value, of FLinear if PCAT_CURVE or PCAT_GRAD default)
	CFilter* Filter() const { return m_Filter; }
	void SetFilter(CFilter* filter);

	// default color (typically 0..1)
	void Color(CColor* col) const { col->Set(m_Color); }
	void SetColor(const CColor& col)
	{
		m_Color.Set(col);
		m_Value = m_Color.Gray();
	}

	inline real ColorR() const { return m_Color.r; }
	inline real ColorG() const { return m_Color.g; }
	inline real ColorB() const { return m_Color.b; }
	inline real ColorA() const { return m_Color.a; }
	inline u32 ColorRGBA() const { return m_Color.GetRGBA(); }
	inline void SetColorRGB(u32 rgb)
	{
		m_Color.SetRGB(rgb);
		m_Value = m_Color.Gray();
	}

	void SetColor(real r, real g, real b, real a)
	{
		m_Color.Set(r, g, b, a);
		m_Value = m_Color.Gray();
	}

	void SetColor(real r, real g, real b)
	{
		m_Color.Set(r, g, b);
		m_Value = m_Color.Gray();
	}

	void SetColorR(real r)
	{
		m_Color.r = r;
		m_Value = m_Color.Gray();
	}

	void SetColorG(real g)
	{
		m_Color.g = g;
		m_Value = m_Color.Gray();
	}

	void SetColorB(real b)
	{
		m_Color.b = b;
		m_Value = m_Color.Gray();
	}

	void SetColorA(real a)
	{
		m_Color.a = a;
		m_Value = m_Color.Gray();
	}

	// default value (typically 0..1)
	real Value() const { return m_Value; }
	void SetValue(real val)
	{
		m_Value = val;
		m_Color.SetGray(val);
	}

	// minimal numeric user value (to recalculate to range 0..1)
	inline int Min() const { return m_Min; }
	inline void SetMin(int min) { m_Min = min; }

	// corresponding minimal value (in range 0..1)
	inline real MinVal() const { return m_MinVal; }
	inline void SetMinVal(real val) { m_MinVal = val; }

	// maximal numeric user value (to recalculate to range 0..1)
	inline int Max() const { return m_Max; }
	inline void SetMax(int max) { m_Max = max; }

	// corresponding maximal value (in range 0..1)
	inline real MaxVal() const { return m_MaxVal; }
	inline void SetMaxVal(real val) { m_MaxVal = val; }

	// number of enumeration entries (can be shorter than number of steps)
	inline int EnumNum() const { return m_EnumNum; }

	// list of enumeration entries (SetEnum - list is terminated with empty string)
	inline CText* Enum() const { return m_Enum; }
	void SetEnum(CText* list);

	// user value (in range Min..Max)
	inline void SetUserValue(real val)
	{
		this->SetValue((val - this->Min()) / (real)(this->Max() - this->Min()) * 
			(this->MaxVal() - this->MinVal()) + this->MinVal());
	}

	inline real GetUserValue() const
	{
		return floor(((m_Value - this->MinVal())/(this->MaxVal() - this->MinVal()) *
			(this->Max() - this->Min()) + this->Min())*1000000 + (real)0.4)/1000000;
	}

	inline real RenderUserValue(real x, real y)
	{
		return floor(((this->RenderVal(x, y) - this->MinVal())/(this->MaxVal() - this->MinVal()) *
			(this->Max() - this->Min()) + this->Min())*1000000 + (real)0.4)/1000000;
	}

	// copy link from another property
	void CopyLink(CProperty* p)
	{
		this->SetFilter(p->Filter());
		m_Color = p->m_Color;
		m_Value = p->m_Value;		
	}
};
