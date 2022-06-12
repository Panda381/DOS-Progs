
///////////////////////////////////////////////////////////////////////////////
//
//                                      Box
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_BOX_WIDTH	2		// property - Width
#define PROP_BOX_HEIGHT	3		// property - Height
#define PROP_BOX_ANGLE	4		// property - Angle (0..1 = angle -180..+180, default 0.5 = angle 0)
#define PROP_BOX_SHIFTX	5		// property - ShiftX (0..1 = shift to left or right edge, default 0.5 = no shift)
#define PROP_BOX_SHIFTY	6		// property - ShiftY (0..1 = shift to bottom or top edge, default 0.5 = no shift)
#define PROP_BOX_TILES	7		// property - Tiles
#define PROP_BOX_BEVEL	8		// property - Bevel
#define PROP_BOX_PROFILE 9		// property - Profile
#define PROP_BOX_CORNERS 10		// property - Corners

// box
class CFilterBox : public CFilterSource2
{
public:

	// constructor
	CFilterBox();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBox);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// round
class CFilterRound : public CFilterBox
{
public:

	// constructor
	CFilterRound();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRound);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_TRI_X1		2		// property - X1
#define PROP_TRI_Y1		3		// property - Y1
#define PROP_TRI_X2		4		// property - X2
#define PROP_TRI_Y2		5		// property - Y2
#define PROP_TRI_X3		6		// property - X3
#define PROP_TRI_Y3		7		// property - Y3
#define PROP_TRI_BEVEL	8		// property - Bevel
#define PROP_TRI_PROFILE 9		// property - Profile

// triagle
class CFilterTriangle : public CFilterSource2
{
public:

	// constructor
	CFilterTriangle();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTriangle);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_INJECT_WIDTH	2	// property - Width
#define PROP_INJECT_HEIGHT	3	// property - Height
#define PROP_INJECT_SHIFTX	4	// property - ShiftX (0..1 = shift to left or right edge, default 0.5 = no shift)
#define PROP_INJECT_SHIFTY	5	// property - ShiftY (0..1 = shift to bottom or top edge, default 0.5 = no shift)

// inject
class CFilterInject : public CFilterSource2
{
public:

	// constructor
	CFilterInject();

	// duplicate filter
	FILTER_DUPLICATE(CFilterInject);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// heart
class CFilterHeart : public CFilterBox
{
public:

	// constructor
	CFilterHeart();

	// duplicate filter
	FILTER_DUPLICATE(CFilterHeart);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define DIAMONDXY 2					// center of outer circle
#define DIAMONDR (DIAMONDXY+(real)0.5)	// radius of outer circle

// diamond
class CFilterDiamond : public CFilterBox
{
public:

	// constructor
	CFilterDiamond();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDiamond);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define SPADESTALK (real)0.15	// spade stalk width

// spade
class CFilterSpade : public CFilterBox
{
public:

	// constructor
	CFilterSpade();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSpade);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define CLUBR1 (real)0.235	// club leaf radius 1
#define CLUBR2 (real)0.18	// club leaf radius 2

// club
class CFilterClub : public CFilterBox
{
public:

	// constructor
	CFilterClub();

	// duplicate filter
	FILTER_DUPLICATE(CFilterClub);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// droplet
class CFilterDroplet : public CFilterBox
{
public:

	// constructor
	CFilterDroplet();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDroplet);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_JINJANG_CIRCLE 10		// property - Circle
#define PROP_JINJANG_BACK	11		// property - Background

// jin jang
class CFilterJinJang : public CFilterBox
{
public:

	// constructor
	CFilterJinJang();

	// duplicate filter
	FILTER_DUPLICATE(CFilterJinJang);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// dollar
class CFilterDollar : public CFilterBox
{
public:

	// constructor
	CFilterDollar();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDollar);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define HEARTSHAPEN		5000			// heart number of samples
extern real HeartShape[HEARTSHAPEN+1];	// radius of samples; index=angle 0..PI2
#define SPADESHAPEN		5000			// spade number of samples
extern real SpadeShape[SPADESHAPEN+1];	// radius of samples; index=angle 0..PI2
#define DROPLETSHAPEN	5000			// droplet number of samples
extern real DropletShape[DROPLETSHAPEN+1];	// radius of samples; index=angle 0..PI2

///////////////////////////////////////////////////////////////////////////////
// initialize heart shape

void HeartInit();

///////////////////////////////////////////////////////////////////////////////
// initialize spade shape

void SpadeInit();

///////////////////////////////////////////////////////////////////////////////
// initialize droplet shape

void DropletInit();

///////////////////////////////////////////////////////////////////////////////
// load dollar pictures

void LoadDollarPic();
