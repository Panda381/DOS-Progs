					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Blade Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_BLADE_BACK		1		// property - Background
#define PROP_BLADE_CONTR	2		// property - Contrast
#define PROP_BLADE_FIBERS	3		// property - Fibers
#define PROP_BLADE_WIDTH	4		// property - Width
#define PROP_BLADE_WARP		5		// property - Warp
#define PROP_BLADE_LIGHT	6		// property - Warp
#define PROP_BLADE_SEED		7		// property - Seed

// blade generator
class CFilterBlade : public CFilterSource2
{
protected:

	CFilterStairs	m_Stairs;
	CFilterInvert	m_Invert1;
	CFilterInvert	m_Invert2;
	CFilterInvert	m_Invert3;
	CFilterBright	m_Bright;
	CFilterNoise	m_Noise1;
	CFilterBezier2	m_Bezier2;
	CFilterBright	m_Bright2;
	CFilterMul		m_Mul;
	CFilterNoise	m_Noise2;
	CFilterArc		m_Arc;
	CFilterRotate270 m_Rotate270;
	CFilterLevel	m_Level;
	CFilterRotate270 m_Rotate2702;
	CFilterInject	m_Inject;
	CFilterCut		m_Cut;

public:

	// constructor
	CFilterBlade();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBlade);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
