					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Cracks Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_CRACKS_ROUGH	2		// property - Roughness
#define PROP_CRACKS_THIN	3		// property - Thin
#define PROP_CRACKS_SCALE	4		// property - Scale
#define PROP_CRACKS_SQUEEZE	5		// property - Squeeze
#define PROP_CRACKS_LAYERS	6		// property - Layers
#define PROP_CRACKS_LEVEL	7		// property - Level
#define PROP_CRACKS_SEED	8		// property - Seed

// cracks generator
class CFilterCracks : public CFilterSource2
{
protected:

	CFilterLoopBegin	m_LoopBegin;
	CFilterLoopIndex	m_LoopIndex;
	CFilterAdd			m_Add1;
	CFilterAdd			m_Add2;
	CFilterPerlin		m_Perlin1;
	CFilterPerlin		m_Perlin2;
	CFilterBlend		m_Blend;
	CFilterInterval		m_Interval;
	CFilterLoopEnd		m_LoopEnd;
	CFilterAbs			m_Abs;
	CFilterSwitch2		m_Switch2;
	CFilterMul			m_Mul;
	CFilterAdd			m_Add3;

public:

	// constructor
	CFilterCracks();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCracks);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
