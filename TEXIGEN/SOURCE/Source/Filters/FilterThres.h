	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Threshold Switch Sources
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_THRES_LEVEL	1	// property - Level
#define PROP_THRES_TOLERANCE 2	// property - Tolerance
#define PROP_THRES_LOW		3	// property - Low
#define PROP_THRES_HIGH		4	// property - High

// threshold filter
class CFilterThreshold : public CFilterSource
{
public:

	// constructor
	CFilterThreshold();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES2_LEVEL	2	// property - Threshold (0..1, switch on 0.5)

// 2-step threshold switch filter
class CFilterThreshold2 : public CFilterSource2
{
public:

	// constructor
	CFilterThreshold2();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold2);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES3_LEVEL	3	// property - Threshold (0..1, switch on 0.33,0.66)

// 3-step threshold switch filter
class CFilterThreshold3 : public CFilterSource3
{
public:

	// constructor
	CFilterThreshold3();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold3);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES4_LEVEL	4	// property - Threshold (0..1, switch on 0.25, 0.5, 0.75)

// 4-step threshold switch filter
class CFilterThreshold4 : public CFilterSource4
{
public:

	// constructor
	CFilterThreshold4();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold4);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES5_LEVEL	5	// property - Threshold (0..1, switch on 0.2,...0.8)

// 5-step threshold switch filter
class CFilterThreshold5 : public CFilterSource5
{
public:

	// constructor
	CFilterThreshold5();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold5);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES6_LEVEL	6	// property - Threshold (0..1, switch on 0.17,...0.83)

// 6-step threshold switch filter
class CFilterThreshold6 : public CFilterSource6
{
public:

	// constructor
	CFilterThreshold6();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold6);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES7_LEVEL	7	// property - Threshold (0..1, switch on 0.14,...0.86)

// 7-step threshold switch filter
class CFilterThreshold7 : public CFilterSource7
{
public:

	// constructor
	CFilterThreshold7();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold7);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES8_LEVEL	8	// property - Threshold (0..1, switch on 0.125,...0.875)

// 8-step threshold switch filter
class CFilterThreshold8 : public CFilterSource8
{
public:

	// constructor
	CFilterThreshold8();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold8);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES9_LEVEL	9	// property - Threshold (0..1, switch on 0.11,...0.89)

// 9-step threshold switch filter
class CFilterThreshold9 : public CFilterSource9
{
public:

	// constructor
	CFilterThreshold9();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold9);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_THRES10_LEVEL	10	// property - Threshold (0..1, switch on 0.1,...0.9)

// 10-step threshold switch filter
class CFilterThreshold10 : public CFilterSource10
{
public:

	// constructor
	CFilterThreshold10();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThreshold10);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
