	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Shape Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_SHAPE_SHAPE	2		// property - Shape
#define PROP_SHAPE_SIZE		3		// property - Size
#define PROP_SHAPE_ANGLE	4		// property - Angle
#define PROP_SHAPE_BEVEL	5		// property - Bevel
#define PROP_SHAPE_PROFILE	6		// property - Profile

// shape filter
class CFilterShape : public CFilterSource2
{
protected:

	CFilterMul		m_Mul;
	CFilterBox		m_Box;
	CFilterBox		m_Box2;
	CFilterRound	m_Round;
	CFilterTriangle	m_Triangle;
	CFilterSpade	m_Spade;
	CFilterHeart	m_Heart;
	CFilterDiamond	m_Diamond;
	CFilterClub		m_Club;
	CFilterDroplet	m_Droplet;
	CFilterStar		m_Star;
	CFilterStar		m_Star2;
	CFilterStar		m_Star3;
	CFilterStar		m_Star4;
	CFilterStar		m_Star5;
	CFilterStar		m_Star6;
	CFilterScale	m_Scale;
	CFilterRotate	m_Rotate;
	CFilterMul		m_Mul2;
	CFilterSub		m_Sub;
	CFilterSub		m_Sub2;
	CFilterThreshold10 m_Threshold10;
	CFilterThreshold10 m_Threshold102;
	CFilterThreshold2 m_Threshold2;

public:

	// constructor
	CFilterShape();

	// duplicate filter
	FILTER_DUPLICATE(CFilterShape);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
