					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Sewing Button Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_SEWBTN_BACK		2		// property - Background
#define PROP_SEWBTN_SIZEOUT		3		// property - SizeOut
#define PROP_SEWBTN_SIZEIN		4		// property - SizeIn
#define PROP_SEWBTN_SIZEHOLE	5		// property - SizeHole
#define PROP_SEWBTN_BEVELOUT	6		// property - BevelOut
#define PROP_SEWBTN_BEVELIN		7		// property - BevelIn
#define PROP_SEWBTN_BEVELHOLE	8		// property - BevelHole
#define PROP_SEWBTN_DISTHOLE	9		// property - DistHole

// sewing button generator
class CFilterSewingButton : public CFilterSource3
{
protected:

	CFilterInvArc	m_InvArc;
	CFilterInvert	m_Invert;
	CFilterMul		m_Mul1;
	CFilterMul		m_Mul2;
	CFilterMul		m_Mul3;
	CFilterRound	m_Round1;
	CFilterMirror	m_Mirror;
	CFilterInject	m_Inject;
	CFilterRound	m_Round2;
	CFilterArc		m_Arc;
	CFilterRound	m_Round3;
	CFilterCut		m_Cut;

public:

	// constructor
	CFilterSewingButton();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSewingButton);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
