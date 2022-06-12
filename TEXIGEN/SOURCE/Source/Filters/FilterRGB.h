
///////////////////////////////////////////////////////////////////////////////
//
//                              RGB channels
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// extract channel R
class CFilterRed : public CFilterSource
{
public:

	// constructor
	CFilterRed();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRed);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// extract channel G
class CFilterGreen : public CFilterSource
{
public:

	// constructor
	CFilterGreen();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGreen);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// extract channel B
class CFilterBlue : public CFilterSource
{
public:

	// constructor
	CFilterBlue();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBlue);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// extract channel A
class CFilterAlpha : public CFilterSource
{
public:

	// constructor
	CFilterAlpha();

	// duplicate filter
	FILTER_DUPLICATE(CFilterAlpha);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// set A channel
class CFilterSetAlpha : public CFilterSource
{
public:

	// constructor
	CFilterSetAlpha();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSetAlpha);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// compound channels
class CFilterRGB : public CFilter
{
public:

	// constructor
	CFilterRGB();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRGB);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
