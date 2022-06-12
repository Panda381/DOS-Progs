					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Dandelion Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_DAND_BACK		2		// property - Background
#define PROP_DAND_DETAILS	3		// property - Details
#define PROP_DAND_RAYS		4		// property - Rays
#define PROP_DAND_BEVEL		5		// property - Bevel
#define PROP_DAND_SEED		6		// property - Seed

// dandelion generator
class CFilterDandelion : public CFilterSource3
{
protected:

	CFilterStar		m_Star;
	CFilterCellular	m_Cellular;
	CFilterRound	m_Round;
	CFilterPolar	m_Polar;
	CFilterSwitch2	m_Switch2;
	CFilterBlend	m_Blend;
	CFilterCut		m_Cut;

public:

	// constructor
	CFilterDandelion();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDandelion);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
