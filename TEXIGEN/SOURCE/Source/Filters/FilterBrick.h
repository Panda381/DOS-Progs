
///////////////////////////////////////////////////////////////////////////////
//
//                              Brick Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern CText FilterBrickFillMode[];

extern CText FilterFloorFillMode[];

#define BRICKMAX	50		// max. rows and columns of brick pattern

#define PROP_BRICK_BRICK	0		// property - Brick (brick color or pattern)
#define PROP_BRICK_MORTAR	1		// property - Mortar (mortar color or pattern)
#define PROP_BRICK_WIDTH	2		// property - Width (number of bricks horizontally 0.01..1; in 0.01 steps, default 0.02)
#define PROP_BRICK_HEIGHT	3		// property - Height (number of bricks vertically 0.01..1; in 0.01 steps, default 0.06)
#define PROP_BRICK_GAP		4		// property - Gap (gap between bricks (=mortar thickness) 0..1; default 0.1)
#define PROP_BRICK_BEVEL	5		// property - Bevel (bevel width 0..1; default 0.02)
#define PROP_BRICK_CORNERS	6		// property - Corners (corners rounding 0..1, default 0.05)
#define PROP_BRICK_BOND		7		// property - Bond (bond of brick rows - set of decimal digits (max. 6 rows), default 0.14)
// Digits:
//	0=terminate pattern
//	1=width 1, shift 0
//	2=width 1, shift 1/4
//	3=width 1, shift 1/3
//	4=width 1, shift 1/2
//	5=width 1, shift 2/3
//	6=width 1, shift 3/4
//	7=width 1/2, shift 0
//	8=width 1/2, shift 1/4
//	9=width 3/2, shift 0
//
// Samples of bonds: 
//	0.14 running (stretcher)
//	0.12 running 1/4
//	0.13 running 1/3
//	0.15 running 2/3
//	0.153 raking left
//	0.135 raking right
//	0.1 stack
//	0.118 stack 3
//	0.141418 Scottish (or American)
//	0.18 English
//	0.1278 double English
//	0.1248 raking English
//	0.78 header
#define PROP_BRICK_CHAOS	8		// property - Chaos (randomize shift of rows 0..1, default 0)
#define PROP_BRICK_HUE		9		// property - Hue (randomize color 0..1, default 0)
#define PROP_BRICK_SAT		10		// property - Saturation (randomize saturation 0..1, default 0)
#define PROP_BRICK_LUM		11		// property - Luminance (randomize luminance 0..1, default 0)
#define PROP_BRICK_FILL		12		// property - Fill (fill mode: 0=image, 0.1=random image, 0.2=solid, 0.3=random solid; default 0.1)
#define PROP_BRICK_PROFILE	13		// property - Profile
#define PROP_BRICK_SEED		14		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// brick generator
class CFilterBrick : public CFilter
{
protected:

	// pattern value list (separate with commas and semicolons)
	CText	m_List;

	// number of rows
	int		m_RowNum;

	// max. length of row
	int		m_ColMax;

	// length of rows
	int		m_RowLen[BRICKMAX];

	// brick patterns - row, column (0..1)
	real	m_Pattern[BRICKMAX][BRICKMAX];

	// pavement generator
	BOOL	m_PavMode;

public:

	// constructor
	CFilterBrick();

	// pattern value list (separate with commas and semicolons)
	inline CText List() const { return m_List; }
	void SetList(const CText& list);

	// number of rows
	inline int RowNum() const { return m_RowNum; }

	// max. length of row
	inline int ColMax() const { return m_ColMax; }

	// duplicate filter
	FILTER_DUPLICATE(CFilterBrick);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// pavement generator
class CFilterPaving : public CFilterBrick
{
public:

	// constructor
	CFilterPaving();

	// duplicate filter
	FILTER_DUPLICATE(CFilterPaving);
};

#define PROP_FLOOR_MORTAR	3		// property - Mortar (mortar color or pattern)
#define PROP_FLOOR_TILES	4		// property - Tiles (number of bricks 0.01..1; in 0.01 steps, default 0.02)
#define PROP_FLOOR_DIAGONAL	5		// property - Diagonal
#define PROP_FLOOR_GAP		6		// property - Gap (gap between bricks (=mortar thickness) 0..1; default 0.1)
#define PROP_FLOOR_HUE		7		// property - Hue (randomize color 0..1, default 0)
#define PROP_FLOOR_SAT		8		// property - Saturation (randomize saturation 0..1, default 0)
#define PROP_FLOOR_LUM		9		// property - Luminance (randomize luminance 0..1, default 0)
#define PROP_FLOOR_FILL		10		// property - Fill (fill mode: 0=image, 0.1=random image, 0.2=solid, 0.3=random solid; default 0.1)
#define PROP_FLOOR_BEVEL	11		// property - Bevel (bevel width 0..1; default 0.02)
#define PROP_FLOOR_PROFILE	12		// property - Profile
#define PROP_FLOOR_SEED		13		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// floor generator
class CFilterFloor : public CFilterSource4
{
public:

	// constructor
	CFilterFloor();

	// duplicate filter
	FILTER_DUPLICATE(CFilterFloor);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
