					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Malachite Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_MALACH_ROUGH	3		// property - Roughness
#define PROP_MALACH_SCALE	4		// property - Scale
#define PROP_MALACH_RINGS	5		// property - Rings
#define PROP_MALACH_DENSITY	6		// property - Density
#define PROP_MALACH_SEED	7		// property - Seed

// malachite generator
class CFilterMalachite : public CFilterSource3
{
protected:

	CFilterPerlin	m_Perlin;
	CFilterNoise	m_Noise;
	CFilterColorize	m_Colorize;
	CFilterSwitch2	m_Switch21;
	CFilterThreshold m_Threshold;
	CFilterSwitch2	m_Switch22;

public:

	// constructor
	CFilterMalachite();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMalachite);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
