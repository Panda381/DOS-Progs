	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Wood Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_WOOD_RINGS		2		// property - Rings
#define PROP_WOOD_SMOOTH	3		// property - Smooth
#define PROP_WOOD_DENSITY	4		// property - Density
#define PROP_WOOD_ROTATE	5		// property - Rotate
#define PROP_WOOD_FIBERS	6		// property - Fibers
#define PROP_WOOD_SEED		7		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// wood filter
class CFilterWood : public CFilterSource2
{
protected:

	CFilterInvert	m_Invert;
	CFilterPerlin	m_Perlin1;
	CFilterNoise	m_Noise1;
	CFilterNoise	m_Noise2;
	CFilterSwitch2	m_Switch21;
	CFilterColorize	m_Colorize;
	CFilterSwitch2	m_Switch22;
	CFilterSqr		m_Sqr;
	CFilterPerlin	m_Perlin2;
	CFilterSwitch2	m_Switch23;
	CFilterSeamlessRotate m_SeamlessRotate;

public:

	// constructor
	CFilterWood();

	// duplicate filter
	FILTER_DUPLICATE(CFilterWood);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
