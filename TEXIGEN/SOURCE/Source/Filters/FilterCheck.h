
///////////////////////////////////////////////////////////////////////////////
//
//                              Check Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// switched check generator
class CFilterCheck : public CFilterSource2
{
public:

	// constructor
	CFilterCheck();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCheck);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// solid color check generator
class CFilterCheckSolid : public CFilterCheck
{
public:

	// constructor
	CFilterCheckSolid();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCheckSolid);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// switched rhomb generator
class CFilterRhomb : public CFilterCheck
{
public:

	// constructor
	CFilterRhomb();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRhomb);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// solid rhomb generator
class CFilterRhombSolid : public CFilterCheck
{
public:

	// constructor
	CFilterRhombSolid();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRhombSolid);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
