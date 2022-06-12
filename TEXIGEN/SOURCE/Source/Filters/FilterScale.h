				   
///////////////////////////////////////////////////////////////////////////////
//
//                               Scale Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_SCALE_SCALE	1		// property - Scale (0..1 = scale 1/4 small..4 big, default 0.5 = 1 no resize)
#define PROP_SCALE_STRETCHX	2		// property - StretchX (0..1 = scale X 1/4 small..4 big, default 0.5 = 1 no resize)
#define PROP_SCALE_STRETCHY	3		// property - StretchY (0..1 = scale Y 1/4 small..4 big, default 0.5 = 1 no resize)
#define PROP_SCALE_X		4		// property - CenterX (0..1 = left..right edge, default 0.5 = center)
#define PROP_SCALE_Y		5		// property - CenterY (0..1 = bottom..top edge, default 0.5 = center)

// scale filter
class CFilterScale : public CFilterSource
{
public:

	// constructor
	CFilterScale();

	// duplicate filter
	FILTER_DUPLICATE(CFilterScale);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_TAPER_TAPERX	1		// property - TaperX
#define PROP_TAPER_TAPERY	2		// property - TaperY
#define PROP_TAPER_X		3		// property - CenterX
#define PROP_TAPER_Y		4		// property - CenterY

// taper filter
class CFilterTaper : public CFilterSource
{
public:

	// constructor
	CFilterTaper();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTaper);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_DEFORM_BACK	1		// property - Backface
#define PROP_DEFORM_BG		2		// property - Background
#define PROP_DEFORM_X1		3		// property - X1
#define PROP_DEFORM_Y1		4		// property - Y1
#define PROP_DEFORM_X2		5		// property - X2
#define PROP_DEFORM_Y2		6		// property - Y2
#define PROP_DEFORM_X3		7		// property - X3
#define PROP_DEFORM_Y3		8		// property - Y3
#define PROP_DEFORM_X4		9		// property - X4
#define PROP_DEFORM_Y4		10		// property - Y4

// deform filter
class CFilterDeform : public CFilterSource3
{
public:

	// constructor
	CFilterDeform();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDeform);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_ENFORM_X1		1		// property - X1
#define PROP_ENFORM_Y1		2		// property - Y1
#define PROP_ENFORM_X2		3		// property - X2
#define PROP_ENFORM_Y2		4		// property - Y2
#define PROP_ENFORM_X3		5		// property - X3
#define PROP_ENFORM_Y3		6		// property - Y3
#define PROP_ENFORM_X4		7		// property - X4
#define PROP_ENFORM_Y4		8		// property - Y4

// enform filter
class CFilterEnform : public CFilterSource
{
public:

	// constructor
	CFilterEnform();

	// duplicate filter
	FILTER_DUPLICATE(CFilterEnform);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// tileX filter
class CFilterTileX : public CFilterSource
{
public:

	// constructor
	CFilterTileX();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTileX);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// tileY filter
class CFilterTileY : public CFilterTileX
{
public:

	// constructor
	CFilterTileY();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTileY);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// tile filter
class CFilterTile : public CFilterTileX
{
public:

	// constructor
	CFilterTile();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTile);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// FlipX filter
class CFilterFlipX : public CFilterSource
{
public:

	// constructor
	CFilterFlipX();

	// duplicate filter
	FILTER_DUPLICATE(CFilterFlipX);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// FlipY filter
class CFilterFlipY : public CFilterSource
{
public:

	// constructor
	CFilterFlipY();

	// duplicate filter
	FILTER_DUPLICATE(CFilterFlipY);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Mirror filter
class CFilterMirror : public CFilterSource
{
public:

	// constructor
	CFilterMirror();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMirror);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// MirrorX filter
class CFilterMirrorX : public CFilterSource
{
public:

	// constructor
	CFilterMirrorX();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMirrorX);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// MirrorY filter
class CFilterMirrorY : public CFilterSource
{
public:

	// constructor
	CFilterMirrorY();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMirrorY);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Seamless filter
class CFilterSeamless : public CFilterSource
{
public:

	// constructor
	CFilterSeamless();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSeamless);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
