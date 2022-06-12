
///////////////////////////////////////////////////////////////////////////////
//
//                               Duo Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// duo output filter
class CFilterDuo : public CFilterSource2
{
public:

	// constructor
	CFilterDuo();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDuo);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// trio output filter
class CFilterTrio : public CFilterSource3
{
public:

	// constructor
	CFilterTrio();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTrio);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// diamond quattro output filter
class CFilterDiaQuattro : public CFilterSource4
{
public:

	// constructor
	CFilterDiaQuattro();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDiaQuattro);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// quattro output filter
class CFilterQuattro : public CFilterSource4
{
public:

	// constructor
	CFilterQuattro();

	// duplicate filter
	FILTER_DUPLICATE(CFilterQuattro);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// hexo output filter
class CFilterHexo : public CFilterSource6
{
public:

	// constructor
	CFilterHexo();

	// duplicate filter
	FILTER_DUPLICATE(CFilterHexo);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// octo output filter
class CFilterOcto : public CFilterSource8
{
public:

	// constructor
	CFilterOcto();

	// duplicate filter
	FILTER_DUPLICATE(CFilterOcto);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// nano output filter
class CFilterNano : public CFilterSource9
{
public:

	// constructor
	CFilterNano();

	// duplicate filter
	FILTER_DUPLICATE(CFilterNano);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
