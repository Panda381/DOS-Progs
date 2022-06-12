	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Fabric Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_FABRIC_WIDTH		2		// property - Width
#define PROP_FABRIC_HEIGHT		3		// property - Height
#define PROP_FABRIC_ROUGH		4		// property - Roughness
#define PROP_FABRIC_EMBOSS		5		// property - Emboss
#define PROP_FABRIC_SEED		6		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// fabric filter
class CFilterFabric : public CFilterSource2
{
protected:

	CFilterInterval	m_Interval1;
	CFilterInterval	m_Interval2;
	CFilterMul		m_Mul;
	CFilterWood		m_Wood;
	CFilterPaving	m_Paving1;
	CFilterPaving	m_Paving2;
	CFilterPaving	m_Paving3;
	CFilterLevel	m_Level;
	CFilterEmboss	m_Emboss;
	CFilterBlend	m_Blend;

public:

	// constructor
	CFilterFabric();

	// duplicate filter
	FILTER_DUPLICATE(CFilterFabric);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
