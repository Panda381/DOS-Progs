				   
///////////////////////////////////////////////////////////////////////////////
//
//                   Mathematical operations (without clamping)
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Invert (1 - Source; without alpha)
class CFilterInvert : public CFilterSource
{
public:

	// constructor
	CFilterInvert();

	// duplicate filter
	FILTER_DUPLICATE(CFilterInvert);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Negate (0 - Source; without alpha)
class CFilterNegate : public CFilterSource
{
public:

	// constructor
	CFilterNegate();

	// duplicate filter
	FILTER_DUPLICATE(CFilterNegate);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Absolute value (with alpha)
class CFilterAbs : public CFilterSource
{
public:

	// constructor
	CFilterAbs();

	// duplicate filter
	FILTER_DUPLICATE(CFilterAbs);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Square (Source * Source, reduce gamma; without alpha)
class CFilterSqr : public CFilterSource
{
public:

	// constructor
	CFilterSqr();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSqr);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Square root (sqrt(abs(Source)), raise gamma; without alpha)
class CFilterSqrt : public CFilterSource
{
public:

	// constructor
	CFilterSqrt();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSqrt);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// granularity with given step (Integer(Source/Source2)*Source2; without alpha)
class CFilterGranularity : public CFilterSource2
{
public:

	// constructor
	CFilterGranularity();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGranularity);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// modulo in given step (Source - Integer(Source/Source2)*Source2; without alpha)
class CFilterMod : public CFilterSource2
{
public:

	// constructor
	CFilterMod();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMod);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Add (Source + Source2; without alpha)
class CFilterAdd : public CFilterSource2
{
public:

	// constructor
	CFilterAdd();

	// duplicate filter
	FILTER_DUPLICATE(CFilterAdd);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Subtract (Source - Source2; without alpha)
class CFilterSub : public CFilterSource2
{
public:

	// constructor
	CFilterSub();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSub);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Subtract invert (Source2 - Source; without alpha)
class CFilterSubInv : public CFilterSource2
{
public:

	// constructor
	CFilterSubInv();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSubInv);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Multiply (Source * Source2; without alpha)
class CFilterMul : public CFilterSource2
{
public:

	// constructor
	CFilterMul();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMul);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Divide (Source / Source2; without alpha)
class CFilterDiv : public CFilterSource2
{
public:

	// constructor
	CFilterDiv();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDiv);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Divide invert (Source2 / Source; without alpha)
class CFilterDivInv : public CFilterSource2
{
public:

	// constructor
	CFilterDivInv();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDivInv);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Power (Source ^ Source2; without alpha)
class CFilterPow : public CFilterSource2
{
public:

	// constructor
	CFilterPow();

	// duplicate filter
	FILTER_DUPLICATE(CFilterPow);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Sinus (input 0..1=angle 0..360°, output 0..1 with middle 0.5; without alpha)
class CFilterSin : public CFilterSource
{
public:

	// constructor
	CFilterSin();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSin);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Cosinus (input 0..1=angle 0..360°, output 0..1 with middle 0.5; without alpha)
class CFilterCos : public CFilterSource
{
public:

	// constructor
	CFilterCos();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCos);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Logarithm (log10(9*Source+1) - source and result are in range 0..1; without alpha)
class CFilterLog : public CFilterSource
{
public:

	// constructor
	CFilterLog();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLog);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Exponential ((exp10(Source)-1)/9 - source and result are in range 0..1; without alpha)
class CFilterExp : public CFilterSource
{
public:

	// constructor
	CFilterExp();

	// duplicate filter
	FILTER_DUPLICATE(CFilterExp);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define	PROP_INT_MIN	1		// property - Min
#define	PROP_INT_MAX	2		// property - Max

// interval
class CFilterInterval : public CFilterSource
{
public:

	// constructor
	CFilterInterval();

	// duplicate filter
	FILTER_DUPLICATE(CFilterInterval);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define	PROP_RAND_MIN	0		// property - Min
#define	PROP_RAND_MAX	1		// property - Max
#define PROP_RAND_SEED	2		// property - Seed

// interval
class CFilterRandom : public CFilter
{
public:

	// constructor
	CFilterRandom();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRandom);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
