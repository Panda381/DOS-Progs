
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Scroller                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notification: WM_HSCROLL, WM_VSCROLL

extern const CText ScrollerClass;

// default width and height of scroller
extern int DefScrollerW;
extern int DefScrollerH;

///////////////////////////////////////////////////////////////////////////////
// scroller

class CScroller : public CChildWindow
{
protected:

	// minimal value
	int		m_Min;

	// maximal value (start of last page)
	int		m_Max;

	// page length
	int		m_Page;

	// scroller mode
	//  SB_CTL=control, SB_HORZ=window horizontal, SB_VERT=window vertical
	int		m_Mode;

public:

	// constructor
	CScroller();

	// create scroller (returns FALSE on error)
	BOOL CreateScroll(int x, int y, int w = 0, int h = 0, BOOL vert = FALSE,
													CWindow* parent = NULL);

	// create horizontal scroller (returns FALSE on error)
	BOOL CreateHScroll(int x, int y, int w = 0, int h = 0,CWindow* parent=NULL)
		{ return CreateScroll(x, y, w, h, FALSE, parent); }

	// create vertical scroller (returns FALSE on error)
	BOOL CreateVScroll(int x, int y, int w = 0, int h = 0,CWindow* parent=NULL)
		{ return CreateScroll(x, y, w, h, TRUE, parent); }

	// scroller range
	inline int Min() const { return m_Min; }
	inline int Max() const { return m_Max; }
	inline int Page() const { return m_Page; }
	void SetRange(int min=0, int max=100, int page=10, BOOL update=FALSE);

	// scroller mode
	//  SB_CTL=control, SB_HORZ=window horizontal, SB_VERT=window vertical
	inline int Mode() const { return m_Mode; }
	inline void SetMode(int mode) { m_Mode = mode; }

	// limit position to valid scroller range
	int _fastcall Limit(int pos);

	// current scroller position
	int GetPos();
	void SetPos(int pos);

	// process window message (returns TRUE if position changed)
	BOOL OnMsg(WPARAM wParam, int step);
};
