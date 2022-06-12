	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                              Snowflake Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_SNOW_ROUGH		3		// property - Roughness
#define PROP_SNOW_SEED		4		// property - Seed

// snowflake filter
class CFilterSnowflake : public CFilterSource3
{
protected:

	CFilterAdd		m_Add;
	CFilterPerlin	m_Perlin1;
	CFilterPerlin	m_Perlin2;
	CFilterBlend	m_Blend1;
	CFilterPerlin	m_Perlin3;
	CFilterBlend	m_Blend2;
	CFilterBias		m_Bias1;
	CFilterBias		m_Bias2;
	CFilterMul		m_Mul1;
	CFilterRotate90	m_Rotate90;
	CFilterMul		m_Mul2;
	CFilterRound	m_Round;
	CFilterMirror	m_Mirror;
	CFilterLevel	m_Level;
	CFilterRotate	m_Rotate1;
	CFilterThreshold m_Threshold;
	CFilterSwitch2	m_Switch2;
	CFilterRotate	m_Rotate2;
	CFilterBlend	m_Blend3;
	CFilterThreshold2 m_Threshold2;
	CFilterBlend	m_Blend4;
	CFilterCut		m_Cut;

public:

	// constructor
	CFilterSnowflake();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSnowflake);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
