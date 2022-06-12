	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Metal Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_METAL_LTSCALE		1		// property - LtScale
#define PROP_METAL_LTANGLE		2		// property - LtAngle
#define PROP_METAL_LTINTENS		3		// property - LtIntens
#define PROP_METAL_SCALE		4		// property - Scale
#define PROP_METAL_DENSITY		5		// property - Density
#define PROP_METAL_ANGLE		6		// property - Angle
#define PROP_METAL_CONTRAST		7		// property - Contrast
#define PROP_METAL_WAVES		8		// property - Waves
#define PROP_METAL_SEED			9		// property - Seed

// wood filter
class CFilterMetal : public CFilterSource
{
protected:

	CFilterNoise	m_Noise1;
	CFilterPerlin	m_Perlin;
	CFilterSeamlessRotate	m_SeamlessRotate1;
	CFilterSeamlessRotate	m_SeamlessRotate2;
	CFilterNoise	m_Noise2;
	CFilterBlend	m_Blend1;
	CFilterBlend	m_Blend2;
	CFilterLevel	m_Level;
	CFilterRotate90	m_Rotate90;
	CFilterPolar	m_Polar;
	CFilterSub		m_Sub;
	CFilterThreshold8 m_Threshold8;

public:

	// constructor
	CFilterMetal();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMetal);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
