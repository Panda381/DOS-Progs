		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Gradient Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// 2-step linear gradient generator
class CFilterGradient2 : public CFilter
{
public:

	// constructor
	CFilterGradient2();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient2);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 3-step linear gradient generator
class CFilterGradient3 : public CFilterGradient2
{
public:

	// constructor
	CFilterGradient3();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient3);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 4-step linear gradient generator
class CFilterGradient4 : public CFilterGradient3
{
public:

	// constructor
	CFilterGradient4();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient4);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 5-step linear gradient generator
class CFilterGradient5 : public CFilterGradient4
{
public:

	// constructor
	CFilterGradient5();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient5);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 6-step linear gradient generator
class CFilterGradient6 : public CFilterGradient5
{
public:

	// constructor
	CFilterGradient6();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient6);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 7-step linear gradient generator
class CFilterGradient7 : public CFilterGradient6
{
public:

	// constructor
	CFilterGradient7();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient7);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 8-step linear gradient generator
class CFilterGradient8 : public CFilterGradient7
{
public:

	// constructor
	CFilterGradient8();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient8);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 9-step linear gradient generator
class CFilterGradient9 : public CFilterGradient8
{
public:

	// constructor
	CFilterGradient9();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient9);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// 10-step linear gradient generator
class CFilterGradient10 : public CFilterGradient9
{
public:

	// constructor
	CFilterGradient10();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGradient10);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Radial gradient
class CFilterRadial : public CFilter
{
public:

	// constructor
	CFilterRadial();

	// duplicate filter
	FILTER_DUPLICATE(CFilterRadial);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Angular gradient
class CFilterAngular : public CFilter
{
public:

	// constructor
	CFilterAngular();

	// duplicate filter
	FILTER_DUPLICATE(CFilterAngular);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// color noise curve
class CFilterColorNoise : public CFilter
{
public:

	// constructor
	CFilterColorNoise();

	// duplicate filter
	FILTER_DUPLICATE(CFilterColorNoise);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
