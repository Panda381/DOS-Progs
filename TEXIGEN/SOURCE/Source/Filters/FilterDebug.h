		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Debug Filters
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// draw curve graph
class CFilterGraph : public CFilterSource
{
public:

	// constructor
	CFilterGraph();

	// duplicate filter
	FILTER_DUPLICATE(CFilterGraph);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// histogram
class CFilterHistogram : public CFilterSource
{
private:

	// histogram statistic
#define HISTWH 128
#define HISTINC ((real)1/HISTWH)
#define HISTVALS 256
	int		m_Hist[HISTVALS];
	int		m_HistMax;

public:

	// constructor
	CFilterHistogram();

	// duplicate filter
	FILTER_DUPLICATE(CFilterHistogram);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// RGB histogram
class CFilterHistogramRGB : public CFilterSource
{
private:

	// histogram statistic
	int		m_HistR[HISTVALS];
	int		m_HistG[HISTVALS];
	int		m_HistB[HISTVALS];
	int		m_HistMax;

public:

	// constructor
	CFilterHistogramRGB();

	// duplicate filter
	FILTER_DUPLICATE(CFilterHistogramRGB);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// X coordinate
class CFilterX : public CFilter
{
public:

	// constructor
	CFilterX();

	// duplicate filter
	FILTER_DUPLICATE(CFilterX);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Y coordinate
class CFilterY : public CFilter
{
public:

	// constructor
	CFilterY();

	// duplicate filter
	FILTER_DUPLICATE(CFilterY);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// X delta
class CFilterDX : public CFilter
{
public:

	// constructor
	CFilterDX();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDX);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// Y delta
class CFilterDY : public CFilter
{
public:

	// constructor
	CFilterDY();

	// duplicate filter
	FILTER_DUPLICATE(CFilterDY);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// time
class CFilterTime : public CFilter
{
public:

	// constructor
	CFilterTime();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTime);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// time delta
class CFilterTimeDelta : public CFilter
{
public:

	// constructor
	CFilterTimeDelta();

	// duplicate filter
	FILTER_DUPLICATE(CFilterTimeDelta);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
