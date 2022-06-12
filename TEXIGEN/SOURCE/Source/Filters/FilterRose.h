					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Rose Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_ROSE_BACK		2		// property - Background
#define PROP_ROSE_DETAILS	3		// property - Details
#define PROP_ROSE_WARP		4		// property - Warp
#define PROP_ROSE_BEVEL		5		// property - Bevel
#define PROP_ROSE_SEED		6		// property - Seed

// rose generator
class CFilterRose : public CFilterSource3
{
protected:

	CFilterAdd		m_Add;
	CFilterPerlin	m_Perlin1;
	CFilterPerlin	m_Perlin2;
	CFilterCellular	m_Cellular;
	CFilterSquareRoot m_SquareRoot;
	CFilterPolar	m_Polar;
	CFilterLevel	m_Level1;
	CFilterLevel	m_Level2;
	CFilterSwitch2	m_Switch2;
	CFilterRound	m_Round;
	CFilterCut		m_Cut;

public:

	// constructor
	CFilterRose();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRose);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
