		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                  Warp Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// warp filter
class CFilterWarp : public CFilterSource
{
public:

	// constructor
	CFilterWarp();

	// duplicate filter
	FILTER_DUPLICATE(CFilterWarp);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// lens filter
class CFilterLens : public CFilterSource2
{
public:

	// constructor
	CFilterLens();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLens);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// polar filter
class CFilterPolar : public CFilterSource
{
public:

	// constructor
	CFilterPolar();

	// duplicate filter
	FILTER_DUPLICATE(CFilterPolar);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Cartesian filter
class CFilterCartes : public CFilterSource
{
public:

	// constructor
	CFilterCartes();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCartes);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
