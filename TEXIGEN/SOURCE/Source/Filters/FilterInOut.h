
///////////////////////////////////////////////////////////////////////////////
//
//                             Input/Output Filters
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// input filter - only template
class CFilterIn abstract : public CFilter
{
protected:

	// filter label
	CText	m_Label;

public:

	// constructor
	CFilterIn();

	// filter label
	inline CText Label() const { return m_Label; }
	inline void SetLabel(const CText& label) { m_Label = label; m_Label.StringCorr(0); }
};

// numeric value
class CFilterValue : public CFilterIn
{
protected:

	// current input numeric value
	real		m_Value;

	// default input numeric value
	real		m_DefValue;

	// recalculated output value
	real		m_OutValue;

	// minimal numeric user value (to recalculate to range 0..1)
	int			m_Min;

	// maximal numeric user value (to recalculate to range 0..1)
	int			m_Max;

	// minimal numeric result value
	real		m_MinVal;

	// maximal numeric result value
	real		m_MaxVal;

	// update output value
	void UpdateOutValue()
	{
		if (m_Max == m_Min)
		{
			m_OutValue = (real)((m_Max < 0) ? -1e20 : +1e20);
		}
		else
			m_OutValue = (m_Value - m_Min) / (real)(m_Max - m_Min) *
			(m_MaxVal - m_MinVal) + m_MinVal;
	}

public:

	// constructor
	CFilterValue();

	// duplicate filter
	FILTER_DUPLICATE(CFilterValue);

	// current input numeric value
	inline real Value() const { return m_Value; }
	inline void SetValue(real value) { m_Value = value; UpdateOutValue(); }

	// default input numeric value
	inline real DefValue() const { return m_DefValue; }
	inline void SetDefValue(real value) { m_DefValue = value; SetValue(value); }

	// minimal numeric user value (to recalculate to range 0..1)
	inline int Min() const { return m_Min; }
	inline void SetMin(int min) { m_Min = min; UpdateOutValue(); }

	// maximal numeric user value (to recalculate to range 0..1)
	inline int Max() const { return m_Max; }
	inline void SetMax(int max) { m_Max = max; UpdateOutValue(); }

	// minimal numeric result value
	inline real MinVal() const { return m_MinVal; }
	inline void SetMinVal(real minval) { m_MinVal = minval; UpdateOutValue(); }

	// maximal numeric result value
	inline real MaxVal() const { return m_MaxVal; }
	inline void SetMaxVal(real maxval) { m_MaxVal = maxval; UpdateOutValue(); }

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// color value
class CFilterColor : public CFilterIn
{
protected:

	// current color value (range 0..1)
	CColor		m_Color;

	// default color value (range 0..1)
	CColor		m_DefColor;

public:

	// constructor
	CFilterColor();

	// duplicate filter
	FILTER_DUPLICATE(CFilterColor);
	
	// current color value (range 0..1)
	inline CColor* Color() { return &m_Color; }

	// default color value (range 0..1) (update current color value too!)
	inline CColor* DefColor() { return &m_DefColor; }

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// picture input filter
class CFilterImage : public CFilterIn
{
protected:

	// needs load
	BOOL	m_NeedLoad;

	// video filter
	BOOL	m_FilterVideo;

	// current video frame
	int		m_VideoFrame;

	// current input filename (empty = no file)
	CText	m_FileName;

	// default input filename
	CText	m_DefFileName;

	// image is tiled
	BOOL	m_Tiled;

	// canvas buffer (NULL=none)
	SCanvas* m_Canvas;

	// delete canvas buffer
	inline void DelBuf()
	{
		if (m_Canvas != NULL)
		{
			DetachCanvas(m_Canvas);
			m_Canvas = NULL;
		}
	}

	BOOL NeedLoad() const;

public:

	// constructor
	CFilterImage();

	// destructor
	virtual ~CFilterImage() { this->DelBuf(); }

	// image properties
	inline int PicW() const { return (m_Canvas == NULL) ? 1 : m_Canvas->w; }
	inline int PicH() const { return (m_Canvas == NULL) ? 1 : m_Canvas->h; }
	inline int PicC() const { return (m_Canvas == NULL) ? 3 : m_Canvas->c; }
	inline int PicSize() const { return (m_Canvas == NULL) ? 3 : (m_Canvas->w*m_Canvas->h*m_Canvas->c); }
	inline u8* PicData() const { return (m_Canvas == NULL) ? NULL : &m_Canvas->d[0]; }

	// duplicate filter
	//FILTER_DUPLICATE(CFilterImage);
	virtual CFilter* Duplicate() const { CFilterImage* f = new CFilterImage; *f = *this;
		f->_dupcor(); if (m_Canvas != NULL) AttachCanvas(m_Canvas); return f; }

	// video filter
	inline BOOL	FilterVideo() const { return m_FilterVideo; }

	// current input filename (need FLock during set filename!), empty = no file
	inline CText FileName() const { return m_FileName; }
	inline void SetFileName(CText filename)
	{
		filename.PathName(0);
		if (filename != m_FileName)
		{
			m_NeedLoad = TRUE;
			m_FileName = filename;
			this->DelBuf();
		}
	}

	// default input filename (need FLock during set filename!)
	inline CText DefFileName() const { return m_DefFileName; }
	inline void SetDefFileName(const CText& filename)
	{
		m_DefFileName = filename;
		m_DefFileName.PathName(0);
		SetFileName(filename);
	}

	// image is tiled
	inline BOOL Tiled() const { return m_Tiled; }
	inline void SetTiled(BOOL tiled) { m_Tiled = tiled; }

	// load file before rendering (returns FALSE on error)
	bool FileLoad();

	// read color from input image
	void ReadCol(CColor* col, int x, int y);

	// render color (coordinates are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// video input filter
class CFilterVideo : public CFilterImage
{
protected:

public:

	// constructor
	CFilterVideo();
};

#define PROP_IMAGE_SQUEEZE	0		// property - Squeeze

// picture data input filter
class CFilterImageData : public CFilter
{
protected:

	// input filename
	CText	m_FileName;

	// image is tiled
	BOOL	m_Tiled;

	// canvas buffer (NULL=none)
	SCanvas* m_Canvas;

public:

	// constructor
	CFilterImageData();

	// delete canvas buffer
	inline void DelBuf()
	{
		if (m_Canvas != NULL)
		{
			DetachCanvas(m_Canvas);
			m_Canvas = NULL;
		}
	}

	// destructor
	virtual ~CFilterImageData() { this->DelBuf(); }

	// image properties
	inline int PicW() const { return (m_Canvas == NULL) ? 1 : m_Canvas->w; }
	inline int PicH() const { return (m_Canvas == NULL) ? 1 : m_Canvas->h; }
	inline int PicC() const { return (m_Canvas == NULL) ? 3 : m_Canvas->c; }
	inline int PicSize() const { return (m_Canvas == NULL) ? 3 : (m_Canvas->w*m_Canvas->h*m_Canvas->c); }
	inline u8* PicData() const { return (m_Canvas == NULL) ? NULL : m_Canvas->d; }

	// create canvas (return pointer to buffer or NULL on error)
	inline u8* CreateData(int w, int h, int c)
	{
		this->DelBuf();
		m_Canvas = NewCanvas(w, h, c);
		if (m_Canvas == NULL) return NULL;
		return m_Canvas->d;
	}

	// duplicate filter
	//FILTER_DUPLICATE(CFilterImage);
	virtual CFilter* Duplicate() const { CFilterImageData* f = new CFilterImageData; *f = *this;
		f->_dupcor(); if (m_Canvas != NULL) AttachCanvas(m_Canvas); return f; }

	// input filename (load file)
	inline CText FileName() const { return m_FileName; }
	inline void SetFileName0(const CText& filename) { m_FileName = filename; m_FileName.PathName(0); };
	void SetFileName(const CText& filename);

	// image is tiled
	inline BOOL Tiled() const { return m_Tiled; }
	inline void SetTiled(BOOL tiled) { m_Tiled = tiled; }

	// read color from input buffer
	void ReadCol(CColor* col, int x, int y);

	// render color (coordinates are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// (main) output filter
class CFilterOut : public CFilterSource
{
protected:

	// filter label
	CText	m_Label;

public:

	// constructor
	CFilterOut();

	// filter label
	inline CText Label() const { return m_Label; }
	inline void SetLabel(const CText& label) { m_Label = label; m_Label.StringCorr(0); }

	// duplicate filter
	FILTER_DUPLICATE(CFilterOut);
};
