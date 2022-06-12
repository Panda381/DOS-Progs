				   
///////////////////////////////////////////////////////////////////////////////
//
//                             Rotation Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern CText SeamlessRotateName[];

#define PROP_ROT_ANGLE	1		// property - Angle (0..1 = angle -180..+180, default 0.5 = angle 0)
#define PROP_ROT_X		2		// property - CenterX (0..1 = left..right edge, default 0.5 = center)
#define PROP_ROT_Y		3		// property - CenterY (0..1 = bottom..top edge, default 0.5 = center)

// rotation filter
class CFilterRotate : public CFilterSource
{
public:

	// constructor
	CFilterRotate();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRotate);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// rotate 90° filter
class CFilterRotate90 : public CFilterSource
{
public:

	// constructor
	CFilterRotate90();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRotate90);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// rotate 180° filter
class CFilterRotate180 : public CFilterSource
{
public:

	// constructor
	CFilterRotate180();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRotate180);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// rotate 270° filter
class CFilterRotate270 : public CFilterSource
{
public:

	// constructor
	CFilterRotate270();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRotate270);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// rotate diagonal up
class CFilterDiagonal : public CFilterSource
{
public:

	// constructor
	CFilterDiagonal();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDiagonal);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// rotate diagonal down
class CFilterDiagonal2 : public CFilterSource
{
public:

	// constructor
	CFilterDiagonal2();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDiagonal2);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// seamless rotation filter
class CFilterSeamlessRotate : public CFilterSource
{
public:

	// constructor
	CFilterSeamlessRotate();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSeamlessRotate);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
