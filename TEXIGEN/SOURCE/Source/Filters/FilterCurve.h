		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                              Curve generators
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_CURVE_BEG	0	// property - Begin (start X of curve 0..1; default 0)
#define PROP_CURVE_END	1	// property - End (end X of curve 0..1; default 1)
#define PROP_CURVE_MIN	2	// property - Min (minimum value 0..1; default 0)
#define PROP_CURVE_MAX	3	// property - Max (maximum value 0..1; default 1)

// linear curve
class CFilterLinear : public CFilter
{
public:

	// constructor
	CFilterLinear();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLinear);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// default linear curve
extern CFilterLinear FLinear;

// square curve
class CFilterSquare : public CFilterLinear
{
public:

	// constructor
	CFilterSquare();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSquare);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// square root curve
class CFilterSquareRoot : public CFilterLinear
{
public:

	// constructor
	CFilterSquareRoot();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSquareRoot);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// arc curve
class CFilterArc : public CFilterLinear
{
public:

	// constructor
	CFilterArc();

	// duplicate filter
	FILTER_DUPLICATE(CFilterArc);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// invert arc curve
class CFilterInvArc : public CFilterLinear
{
public:

	// constructor
	CFilterInvArc();

	// duplicate filter
	FILTER_DUPLICATE(CFilterInvArc);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// power curve
class CFilterPower : public CFilterLinear
{
public:

	// constructor
	CFilterPower();

	// duplicate filter
	FILTER_DUPLICATE(CFilterPower);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Gaussian curve
class CFilterGaussian : public CFilterLinear
{
public:

	// constructor
	CFilterGaussian();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGaussian);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_CURBIAS_BIAS	4	// property - Bias (0..1; default 0.2)

// bias curve
class CFilterBias : public CFilterLinear
{
public:

	// constructor
	CFilterBias();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBias);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// gain curve
class CFilterGain : public CFilterLinear
{
public:

	// constructor
	CFilterGain();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGain);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Impulse curve
class CFilterImpulse : public CFilterLinear
{
public:

	// constructor
	CFilterImpulse();

	// duplicate filter
	FILTER_DUPLICATE(CFilterImpulse);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_CURSTAIRS_STEPS	4	// property - Steps (0..1; 0.01..1 = 1 to 100 steps; default 0.08)
#define PROP_CURSTAIRS_SMOOTH	5	// property - Smooth (0..1; 0=sharp..1=smooth, default 0)

// stairs curve
class CFilterStairs : public CFilterLinear
{
public:

	// constructor
	CFilterStairs();

	// duplicate filter
	FILTER_DUPLICATE(CFilterStairs);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_CURNOI_DETAILS		4		// property - Details (0..1 = 0 smooth (1 noise octave) ... 1 detailed (11 noise octaves), default 0.5)
#define PROP_CURNOI_ROUGHNESS	5		// property - Roughness (0..1 = 0 smooth ... 1 roughness (noticable higher octaves), default 0.5)
#define PROP_CURNOI_SCALE		6		// property - Scale (0..1 = scale, 0=256x small..1=normal, default 0.5)
#define PROP_CURNOI_SHIFT		7		// property - Shift (0..1 = shift to left or right edge, default 0.5)
#define PROP_CURNOI_SEED		8		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// noise curve
class CFilterNoise : public CFilterLinear
{
public:

	// constructor
	CFilterNoise();

	// duplicate filter
	FILTER_DUPLICATE(CFilterNoise);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// city curve
class CFilterCity : public CFilterLinear
{
public:

	// constructor
	CFilterCity();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCity);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// wave curve
class CFilterWave : public CFilterLinear
{
public:

	// constructor
	CFilterWave();

	// duplicate filter
	FILTER_DUPLICATE(CFilterWave);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// sawtooth curve
class CFilterSaw : public CFilterLinear
{
public:

	// constructor
	CFilterSaw();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSaw);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// rectangle curve
class CFilterRectangle : public CFilterLinear
{
public:

	// constructor
	CFilterRectangle();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRectangle);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define TABMAX	1024	// max. entriesin tabled curve

// tabled curve
class CFilterTable : public CFilterLinear
{
protected:

	// filter value list
	CText	m_List;

	// number of values
	int		m_ListNum;

	// table of values
	real	m_ListVal[TABMAX];

public:

	// constructor
	CFilterTable();

	// filter value list
	inline CText List() const { return m_List; }
	inline void SetList(const CText& list);

	// number of values
	inline int ListNum() const { return m_ListNum; }

	// duplicate filter
	FILTER_DUPLICATE(CFilterTable);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_BEZIER2_X1		0	// property - X1
#define PROP_BEZIER2_Y1		1	// property - Y1
#define PROP_BEZIER2_A1		2	// property - Angle1
#define PROP_BEZIER2_S1		3	// property - Strength1
#define PROP_BEZIER2_X2		4	// property - X2
#define PROP_BEZIER2_Y2		5	// property - Y2
#define PROP_BEZIER2_A2		6	// property - Angle2
#define PROP_BEZIER2_S2		7	// property - Strength2

// 2-point Bezier curve
class CFilterBezier2 : public CFilter
{
public:

	// constructor
	CFilterBezier2();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBezier2);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 3-point Bezier curve
class CFilterBezier3 : public CFilter
{
public:

	// constructor
	CFilterBezier3();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBezier3);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
