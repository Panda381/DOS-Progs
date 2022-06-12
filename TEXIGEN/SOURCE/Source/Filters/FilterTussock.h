					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Tussock Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_TUSSOCK_RNDCOLOR	1	// property - RndColor
#define PROP_TUSSOCK_SIZE		2	// property - Size
#define PROP_TUSSOCK_RNDSIZE	3	// property - RndSize
#define PROP_TUSSOCK_CONTRAST	4	// property - Contrast
#define PROP_TUSSOCK_FIBERS		5	// property - Fibers
#define PROP_TUSSOCK_WIDTH		6	// property - Width
#define PROP_TUSSOCK_WARP		7	// property - Warp
#define PROP_TUSSOCK_LIGHT		8	// property - Light
#define PROP_TUSSOCK_COUNT		9	// property - Count
#define PROP_TUSSOCK_RANGE		10	// property - Range
#define PROP_TUSSOCK_FAN		11	// property - Fan
#define PROP_TUSSOCK_SHADOWS	12	// property - Shadows
#define PROP_TUSSOCK_SHDWSHFT	13	// property - ShdwShft
#define PROP_TUSSOCK_VARIANT	14	// property - Variant

// tussock generator
class CFilterTussock : public CFilterSource
{
protected:

	CFilterLoopBegin m_LoopBegin;
	CFilterInvert	m_Invert1;
	CFilterAdd		m_Add1;
	CFilterBlade	m_Blade1;
	CFilterLoopIndex m_LoopIndex;
	CFilterInvert	m_Invert2;
	CFilterRandom	m_Random1;
	CFilterShift	m_Shift1;
	CFilterAdd		m_Add2;
	CFilterRecolor	m_Recolor;
	CFilterBlend	m_Blend;
	CFilterInvert	m_Invert3;
	CFilterAdd		m_Add3;
	CFilterInvert	m_Invert4;
	CFilterBlade	m_Blade2;
	CFilterRandom	m_Random2;
	CFilterRandom	m_Random3;
	CFilterRandom	m_Random4;
	CFilterRotate	m_Rotate;
	CFilterShift	m_Shift2;
	CFilterScale	m_Scale;
	CFilterLoopEnd	m_LoopEnd;
	CFilterCut		m_Cut;

public:

	// constructor
	CFilterTussock();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTussock);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
