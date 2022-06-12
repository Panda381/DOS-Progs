
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              Slider (Track Bar)                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications: WM_HSCROLL, WM_VSCROLL

extern const CText SliderClass;

extern int	DefSliderW0;		// default width of slider with no marks
extern int	DefSliderW1;		// default width of slider with single marks
extern int	DefSliderW2;		// default width of slider with double marks

extern int	DefSliderT0;		// default thumb width with no marks
extern int	DefSliderT1;		// default thumb width with single marks
extern int	DefSliderT2;		// default thumb width with double marks

///////////////////////////////////////////////////////////////////////////////
// slider

class CSlider : public CChildWindow
{
protected:

	// minimal value (or negative value)
	int		m_Min;

	// maximal value (or negative value)
	int		m_Max;

	// page size
	int		m_Page;

	// range signum (+1 if min <= max, -1 if min > max)
	int		m_Sign;

public:

	// constructor
	CSlider();

	// create slider
	BOOL CreateSlider(DWORD style, int x, int y, int w, int h,
													CWindow* parent = NULL);

	// create horizontal slider (with single marks)
	BOOL CreateHSlider(int x, int y, int w, BOOL bottom = FALSE, int h = 0,
													CWindow* parent = NULL);

	// create low horizontal slider (without marks)
	BOOL CreateLowSlider(int x, int y, int w, int h = 0, CWindow* parent=NULL);

	// create vertical slider (with single marks)
	BOOL CreateVSlider(int x, int y, int h, BOOL right = FALSE, int w = 0,
													CWindow* parent = NULL);

	// create wide vertical slider (with double marks)
	BOOL CreateWideSlider(int x, int y, int h, int w = 0,CWindow* parent=NULL);

	// set thumb length
	void SetThumbLength(int len);

	// slider range (min can be greater than max)
	inline int Min() const { return m_Min*m_Sign; }
	inline int Max() const { return m_Max*m_Sign; }
	void SetRange(int min, int max, BOOL update = FALSE);
	inline int Page() const { return m_Page; }

	// limit position to valid slider range
	int _fastcall Limit(int pos);

	// set slider page size (0=default 1/10 of range)
	void SetPage(int page = 0);

	// set marks frequency (0=default 1/10 of range)
	void SetFreq(int freq = 0);

	// get slider position
	int GetPos();

	// set slider position
	void SetPos(int pos);
};
