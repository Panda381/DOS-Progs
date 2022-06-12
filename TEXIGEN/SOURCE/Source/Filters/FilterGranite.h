					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Granite Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_GRAN_NOISE		1		// property - Noise
#define PROP_GRAN_NOISESCALE 2		// property - NoiseScale
#define PROP_GRAN_GRAINCOLOR 3		// property - GrainColor
#define PROP_GRAN_GRAINCONTR 4		// property - GrainContr
#define PROP_GRAN_GRAINLEVEL 5		// property - GrainLevel
#define PROP_GRAN_GRAINSCALE 6		// property - GrainScale
#define PROP_GRAN_COLOR1A	7		// property - Color1A
#define PROP_GRAN_COLOR1B	8		// property - Color1B
#define PROP_GRAN_CONTRAST1	9		// property - Contrast1
#define PROP_GRAN_LEVEL1	10		// property - Level1
#define PROP_GRAN_ROUGH1	11		// property - Rough1
#define PROP_GRAN_SCALE1	12		// property - Scale1
#define PROP_GRAN_SMOOTH1	13		// property - Smooth1
#define PROP_GRAN_COLOR2A	14		// property - Color2A
#define PROP_GRAN_COLOR2B	15		// property - Color2B
#define PROP_GRAN_CONTRAST2	16		// property - Contrast2
#define PROP_GRAN_LEVEL2	17		// property - Level2
#define PROP_GRAN_ROUGH2	18		// property - Rough2
#define PROP_GRAN_SCALE2	19		// property - Scale2
#define PROP_GRAN_SMOOTH2	20		// property - Smooth2
#define PROP_GRAN_WEBCONTR	21		// property - WebContr
#define PROP_GRAN_WEBGAMMA	22		// property - WebGamma
#define PROP_GRAN_SEED		23		// property - Seed

// granite generator
class CFilterGranite : public CFilterSource
{
protected:

	CFilterPerlin	m_Perlin1;
	CFilterLevel	m_Level1;
	CFilterAdd		m_Add1;

	CFilterPerlin	m_Perlin2;
	CFilterInterval	m_Interval;
	CFilterAdd		m_Add2;
	CFilterSwitch2	m_Switch2;

	CFilterCellular	m_Cellular1;
	CFilterCellular	m_Cellular2;
	CFilterThreshold2 m_Threshold21;
	CFilterBlur		m_Blur1;
	CFilterLevel	m_Level2;
	CFilterThreshold m_Threshold1;
	CFilterAdd		m_Add3;

	CFilterCellular	m_Cellular3;
	CFilterCellular	m_Cellular4;
	CFilterThreshold2 m_Threshold23;
	CFilterBlur		m_Blur2;
	CFilterLevel	m_Level3;
	CFilterThreshold m_Threshold2;
	CFilterAdd		m_Add4;

	CFilterCellular	m_Cellular5;
	CFilterPerlin	m_Perlin3;
	CFilterPerlin	m_Perlin4;
	CFilterShift	m_Shift;
	CFilterInvert	m_Invert;
	CFilterBias		m_Bias;

public:

	// constructor
	CFilterGranite();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGranite);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
