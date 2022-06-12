					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Marble Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_MARBLE_BIAS	2		// property - Bias
#define PROP_MARBLE_SCALE	3		// property - Scale
#define PROP_MARBLE_SQUEEZE	4		// property - Squeeze
#define PROP_MARBLE_WARP	5		// property - Warp
#define PROP_MARBLE_DETAILS	6		// property - Details
#define PROP_MARBLE_ROUGH	7		// property - Roughness
#define PROP_MARBLE_SMUDGES	8		// property - Smudges
#define PROP_MARBLE_SEED	9		// property - Seed

// marble generator
class CFilterMarble : public CFilterSource2
{
protected:

	CFilterCellular	m_Cellular;
	CFilterPerlin	m_Perlin1;
	CFilterPerlin	m_Perlin2;
	CFilterBias		m_Bias;
	CFilterAdd		m_Add1;
	CFilterMul		m_Mul1;
	CFilterMul		m_Mul2;
	CFilterShift	m_Shift;
	CFilterSwitch2	m_Switch2;
	CFilterAdd		m_Add2;
	CFilterPerlin	m_Perlin3;
	CFilterLevel	m_Level;

public:

	// constructor
	CFilterMarble();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMarble);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
