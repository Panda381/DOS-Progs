		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Gradient Colorize Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_COLORIZE_GRADIENT	1	// property - Gradient (color dependent on X = 0..1)

// gradient colorize filter or curve remap
class CFilterColorize : public CFilterSource
{
public:

	// constructor
	CFilterColorize();

	// duplicate filter
	FILTER_DUPLICATE(CFilterColorize);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_COLORIZECHAN_GRADIENTR	1	// property - GradientR (value dependent on X = 0..1)
#define PROP_COLORIZECHAN_GRADIENTG	2	// property - GradientG (value dependent on X = 0..1)
#define PROP_COLORIZECHAN_GRADIENTB	3	// property - GradientB (value dependent on X = 0..1)
#define PROP_COLORIZECHAN_GRADIENTA	4	// property - GradientA (value dependent on X = 0..1)

// gradient colorize channel filter
class CFilterColorizeChan : public CFilterSource
{
public:

	// constructor
	CFilterColorizeChan();

	// duplicate filter
	FILTER_DUPLICATE(CFilterColorizeChan);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// decolorize filter
class CFilterDecolorize : public CFilterSource
{
public:

	// constructor
	CFilterDecolorize();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDecolorize);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
