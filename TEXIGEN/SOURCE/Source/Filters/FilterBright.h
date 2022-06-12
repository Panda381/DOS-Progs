				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Brightness Level Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_BRIGHT_BRIGHT	1		// property - Brightness (0..1; 0=dark, 1=bright; def. 0.5)

// simple brightness filter (combines brightness with contrast)
class CFilterBright : public CFilterSource
{
public:

	// constructor
	CFilterBright();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBright);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_LEVEL_BRIGHT	1		// property - Brightness (0..1; 0=dark, 1=bright; def. 0.5)
#define PROP_LEVEL_CONTRAST	2		// property - Contrast (0..1; 0=gray, 1=b&w; def. 0.5)
#define PROP_LEVEL_GAMMA	3		// property - Gamma (0..1; 0=dark, 1=bright; def. 0.5)

// level filter
class CFilterLevel : public CFilterSource
{
public:

	// constructor
	CFilterLevel();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLevel);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_AMPLIF_GAIN	1		// property - Gain

// amplifier filter
class CFilterAmplifier : public CFilterSource
{
public:

	// constructor
	CFilterAmplifier();

	// duplicate filter
	FILTER_DUPLICATE(CFilterAmplifier);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
