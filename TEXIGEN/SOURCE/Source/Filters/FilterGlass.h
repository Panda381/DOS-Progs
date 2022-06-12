	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Glass Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_GLASS_ROUGH	1		// property - Roughness
#define PROP_GLASS_CONTRAST	2		// property - Contrast
#define PROP_GLASS_SCALE	3		// property - Scale
#define PROP_GLASS_DENS		4		// property - Density
#define PROP_GLASS_BUMP		5		// property - Bump
#define PROP_GLASS_BSCALE	6		// property - BumpScale
#define PROP_GLASS_REFL		7		// property - Reflections
#define PROP_GLASS_SEED		8		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// glass filter
class CFilterGlass : public CFilterSource
{
protected:

	CFilterNoise	m_Noise;
	CFilterMul		m_Mul;
	CFilterPerlin	m_Perlin1;
	CFilterPerlin	m_Perlin2;
	CFilterSwitch2	m_Switch21;
	CFilterSwitch2	m_Switch22;
	CFilterLevel	m_Level;
	CFilterEmboss	m_Emboss;
	CFilterSwitch2	m_Switch23;

public:

	// constructor
	CFilterGlass();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGlass);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
