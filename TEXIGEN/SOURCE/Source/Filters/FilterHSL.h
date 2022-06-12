		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Color Correction Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_COLOR_HUE		1		// property - Hue (0..1; 0=-180°, 1=+180°; def. 0.5)
#define PROP_COLOR_SAT		2		// property - Saturation (0..1; 0=gray, 1=color; def. 0.5)
#define PROP_COLOR_LUM		3		// property - Luminance (0..1; 0=dark, 1=bright; def. 0.5)

// color correction filter
class CFilterRecolor : public CFilterSource
{
public:

	// constructor
	CFilterRecolor();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRecolor);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// extract HSL Hue
class CFilterHue : public CFilterSource
{
public:

	// constructor
	CFilterHue();

	// duplicate filter
	FILTER_DUPLICATE(CFilterHue);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// extract HSL Saturation
class CFilterSaturation : public CFilterSource
{
public:

	// constructor
	CFilterSaturation();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSaturation);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// extract HSL Luminance
class CFilterLuminance : public CFilterSource
{
public:

	// constructor
	CFilterLuminance();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLuminance);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// compose HSL channels
class CFilterHSL : public CFilter
{
public:

	// constructor
	CFilterHSL();

	// duplicate filter
	FILTER_DUPLICATE(CFilterHSL);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
