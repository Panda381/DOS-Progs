		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Process Filters
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define BLURCACHEWH		512			// cache buffer width and height
#define BLURCACHESIZE	(BLURCACHEWH*BLURCACHEWH) // cache buffer size
#define BLURCACHEINV	0xdeadf00ddeadf00d // cache invalid flag
#define BLURMAXRAD		(100*BLURCACHEWH/256) // blur max. Gauss window radius
#define BLURMAXSIZE		(BLURMAXRAD*2+1) // blur max. Gauss window size

// Gauss blur weights
extern real GaussWeight[(BLURMAXRAD+1)*BLURMAXSIZE];

// generate Gauss blur weights
void GenGaussWeight();

#define PROP_BLUR_RADIUSX	1	// property - radius X
#define PROP_BLUR_RADIUSY	2	// property - radius Y
#define PROP_BLUR_TILED		3	// property - tiled

// blur filter
class CFilterBlur : public CFilterSource
{
protected:

	// input image cache
	u64			m_CacheIn[BLURCACHESIZE];

	// temporary image cache (blured in X direction)
	u64			m_CacheTemp[BLURCACHESIZE];

	// output image cache
	u64			m_CacheOut[BLURCACHESIZE];

	// clear cache
	void ClearCache(u64* buf);

	// load one input sample
	u64 LoadIn(int x, int y);

	// load one temporary sample (blured in X direction)
	u64 LoadTemp(int x, int y);

	// load one output sample
	u64 LoadOut(int x, int y);

	// tiled
	bool		m_Tiled;

	// Gauss window radius
	int			m_RadiusX;
	int			m_RadiusY;

	// Gauss window size
	int			m_SizeX;
	int			m_SizeY;

	// render color of one pixel
	void RenderCol1(CColor* col, real x, real y);
	void RenderCol2(CColor* col, real x, real y);

public:

	// constructor
	CFilterBlur();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBlur);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_HIGHPASS_RADIUS	1	// property - radius
#define PROP_HIGHPASS_STRENGTH	2	// property - strength
#define PROP_HIGHPASS_TILED		3	// property - tiled
#define PROP_HIGHPASS_LUMIN		4	// property - luminance
#define PROP_HIGHPASS_CONTRAST	5	// property - contrast

// high pass filter
class CFilterHighPass : public CFilterBlur
{

public:

	// constructor
	CFilterHighPass();

	// duplicate filter
	FILTER_DUPLICATE(CFilterHighPass);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PERCCACHEWH		512			// cache buffer width and height
#define PERCCACHESIZE	(PERCCACHEWH*PERCCACHEWH) // cache buffer size
#define PERCCACHEINV	0xdeadf00ddeadf00d	// cache invalid flag
#define PERCMAXRAD		(100*PERCCACHEWH/256) // max. window radius

#define PROP_PERCENTILE_RADIUS		1	// property - radius
#define PROP_PERCENTILE_PERCENTILE	2	// property - percentile
#define PROP_PERCENTILE_TILED		3	// property - tiled
#define PROP_PERCENTILE_RGB			4	// property - RGB

// percentile filter
class CFilterPercentile : public CFilterSource
{
protected:

	// input image cache
	u64			m_CacheIn[PERCCACHESIZE];

	// minimum, median and maximum image cache
	u64			m_CacheMin[PERCCACHESIZE];
	u64			m_CacheMed[PERCCACHESIZE];
	u64			m_CacheMax[PERCCACHESIZE];

	// clear cache
	void ClearCache(u64* buf);

	// load one input sample
	u64 LoadIn(int x, int y);

	// load one sample
	void Load1(CColor* col, real perc, int x, int y);

	// tiled
	bool		m_Tiled;

	// RGB
	bool		m_RGB;

	// radius (in pixel)
	real		m_Radius;

	// render color of one pixel
	void RenderCol1(CColor* col, real perc, real x, real y);

public:

	// constructor
	CFilterPercentile();

	// duplicate filter
	FILTER_DUPLICATE(CFilterPercentile);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_EMBOSS_HEIGHTMAP	1	// property - height map
#define PROP_EMBOSS_BASE		2	// property - base level
#define PROP_EMBOSS_DIFFUSE		3	// property - diffuse light
#define PROP_EMBOSS_AMBIENT		4	// property - ambient light
#define PROP_EMBOSS_SPECULAR	5	// property - specular light
#define PROP_EMBOSS_METAL		6	// property - metal reflection
#define PROP_EMBOSS_SATURATION	7	// property - saturation
#define PROP_EMBOSS_SCALE		8	// property - scale of environment image
#define PROP_EMBOSS_SHIFTX		9	// property - ShiftX
#define PROP_EMBOSS_SHIFTY		10	// property - ShiftY
#define PROP_EMBOSS_ENVIRONMENT	11	// property - environment

// emboss filter
class CFilterEmboss : public CFilterSource
{
public:

	// constructor
	CFilterEmboss();

	// duplicate filter
	FILTER_DUPLICATE(CFilterEmboss);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// smooth filter
class CFilterSmooth : public CFilterSource
{
public:

	// constructor
	CFilterSmooth();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSmooth);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// normal map filter
class CFilterNormal : public CFilterSource
{
public:

	// constructor
	CFilterNormal();

	// duplicate filter
	FILTER_DUPLICATE(CFilterNormal);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// contour filter
class CFilterContour : public CFilterSource
{
public:

	// constructor
	CFilterContour();

	// duplicate filter
	FILTER_DUPLICATE(CFilterContour);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

///////////////////////////////////////////////////////////////////////////////
// load environment pictures

void LoadEnvPic();
