
///////////////////////////////////////////////////////////////////////////////
//
//                                      Star
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_STAR_RAYS		2		// property - Rays
#define PROP_STAR_RADIUS	3		// property - Radius
#define PROP_STAR_STUFFING	4		// property - Stuffing
#define PROP_STAR_SQUEEZE	5		// property - Squeeze
#define PROP_STAR_ANGLE		6		// property - Angle
#define PROP_STAR_SHIFTX	7		// property - ShiftX
#define PROP_STAR_SHIFTY	8		// property - ShiftY
#define PROP_STAR_SMOOTH	9		// property - SmoothOut
#define PROP_STAR_SMOOTHIN	10		// property - SmoothIn
#define PROP_STAR_HOLE		11		// property - Hole
#define PROP_STAR_TILES		12		// property - Tiles
#define PROP_STAR_BEVEL		13		// property - Bevel
#define PROP_STAR_PROFILE	14		// property - Profile

// star
class CFilterStar : public CFilterSource2
{
public:

	// constructor
	CFilterStar();

	// duplicate filter
	FILTER_DUPLICATE(CFilterStar);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
