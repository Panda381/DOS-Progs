
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              Application Window                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define MAINFRAMEMINWIDTH 400			// main frame minimal width
#define MAINFRAMEMINHEIGHT 350			// main frame minimal height

#define STRIPEW	320						// width of left stripe (and height of preview)

extern int		MainFrameLeft;			// main frame X coordinate
extern int		MainFrameTop;			// main frame Y coordinate
extern int		MainFrameWidth;			// main frame width
extern int		MainFrameHeight;		// main frame height
extern BOOL		MainFrameMax;			// main frame is maximized
extern int		MainFrameClientLeft;	// inner X coordinate of main frame
extern int		MainFrameClientTop;		// inner Y coordinate of main frame
extern int		MainFrameClientWidth;	// inner width of main frame (0=auto)
extern int		MainFrameClientHeight;	// inner height of main frame (0=auto)

//extern int		ScreenBits;				// fullscreen color bits (0=auto)

extern int		ToolBarID;				// tool bar bitmap resource ID (0=none)
extern int		ToolBarNum;				// number of toolbar icons
extern TBBUTTON* ToolBarBtn;			// toolbar buttons
extern int		ToolBarBtnNum;			// number of toolbar buttons

// selection toolbar icons
enum {
	TBS_GROUP = 0,			// New Group
	TBS_NEW,				// New Filter
	TBS_OPEN,				// Open Filter
	TBS_DELETE,				// Delete
	TBS_INFO,				// Info
	TBS_DEFAULT,			// Default Variation
	TBS_GENERATE,			// Generate Variation
	TBS_SAVE,				// Save Variation or filter
	TBS_RENDER,				// Render
	TBS_CLOSE,				// Close Filter
	TBS_SAVEAS,				// Save As
	TBS_ZOOMIN,				// Zoom In
	TBS_ZOOMOUT,			// Zoom Out
	TBS_VIEWLEFT,			// View Left
	TBS_VIEWRIGHT,			// View Right
	TBS_VIEWUP,				// View Up
	TBS_VIEWDOWN,			// View Down
	TBS_MUTATE,				// Mutate Variation

	TBS_NUM					// number of toolbar buttons
};

// preview progress bas
#define PREVBARW	120
#define PREVBARW2	(PREVBARW+20)
extern CProgress PreviewProgress;

// timer
#define TIMERID		5678
#define TIMERTIME	55		// time of main timer (in [ms])

/////////////////////////////////////////////////////////////////////////////
// selection toolbar

extern TBBUTTON  TBSButton[];
extern const int TBSButtonNum;

/////////////////////////////////////////////////////////////////////////////
// editation toolbar

extern TBBUTTON  TBEButton[];
extern const int TBEButtonNum;

///////////////////////////////////////////////////////////////////////////////
// application window class

class CMainFrame : public CWindow
{
protected:

	// status line enabled
	BOOL		m_StatusOn;

	// status line
	CStatus		m_Status;

	// tool tip enabled
	BOOL		m_ToolTipOn;

	// tool tip
	CToolTip	m_ToolTip;

	// tool bar enabled
	BOOL		m_ToolBarOn;

	// tool bar
	CToolBar	m_ToolBar;

public:

	// constructor
	CMainFrame();

	// status line enabled
	BOOL StatusOn() const { return m_StatusOn; }
	void SetStatusOn(BOOL on, BOOL update = FALSE);

	// status line
	CStatus* Status() { return &m_Status; }

	// create status line
	void CreateStatus();

	// tool tip enabled
	BOOL ToolTipOn() const { return m_ToolTipOn; }
	void SetToolTipOn(BOOL on);

	// tool tip
	CToolTip* ToolTip() { return &m_ToolTip; }

	// create tool tip
	void CreateToolTip();

	// add tool tip
	inline void AddToolTip(CChildWindow* win) { m_ToolTip.Add(win); }
	inline void AddToolTip(int id, CRect& rc) { m_ToolTip.Add(id, rc); }

	// delete tool tip
	inline void DelToolTip(CChildWindow* win) { m_ToolTip.Del(win); }
	inline void DelToolTip(int id, CRect& rc) { m_ToolTip.Del(id, rc); }

	// tool bar enabled
	BOOL ToolBarOn() const { return m_ToolBarOn; }
	void SetToolBarOn(BOOL on, BOOL update = FALSE);

	// tool bar
	CToolBar* ToolBar() { return &m_ToolBar; }

	// create tool bar
	void CreateToolBar();

	// update window size and position
	virtual void UpdateRect();
};

extern CMainFrame*	MainFrame;			// main frame of the application (ROOT)
extern HMENU		MainMenu;			// current main menu

///////////////////////////////////////////////////////////////////////////////
// enable command (in menu and tool bar)

void EnableCmd(int id, BOOL enable);

//////////////////////////////////////////////////////////////////////////////
// check command

void CheckCmd(int id, BOOL check);

/////////////////////////////////////////////////////////////////////////////
// create main frame (returns TRUE if success)

BOOL MainFrameCreate();

///////////////////////////////////////////////////////////////////////////////
// status line visible

inline BOOL StatusOn() { return MainFrame->StatusOn(); }
inline void SetStatusOn(BOOL on) { MainFrame->SetStatusOn(on); }

///////////////////////////////////////////////////////////////////////////////
// width of status line (-1 = autosize)

inline int StatusWidth(int part = 0)
	{ return MainFrame->Status()->PartWidth(part); }
inline void SetStatusWidth(int part = 0, int width = -1)
	{ MainFrame->Status()->SetPartWidth(part, width); }

///////////////////////////////////////////////////////////////////////////////
// number of parts of status line

inline int StatusNum() { return MainFrame->Status()->PartNum(); }
inline void SetStatusNum(int num = 1) { MainFrame->Status()->SetPartNum(num); }

///////////////////////////////////////////////////////////////////////////////
// text of status line

inline CText StatusText(int part = 0)
	{ return MainFrame->Status()->StatusText(part); }
inline void SetStatusText(const CText& text, int part = 0)
	{ MainFrame->Status()->SetStatusText(text, part, FALSE); }

///////////////////////////////////////////////////////////////////////////////
// activate tooltip

inline BOOL ToolTipOn() { return MainFrame->ToolTipOn(); }
inline void SetToolTipOn(BOOL on) { MainFrame->SetToolTipOn(on); }

///////////////////////////////////////////////////////////////////////////////
// add tooltip

inline void ToolTipAdd(CChildWindow* win, BOOL track = FALSE)
	{ MainFrame->ToolTip()->Add(win, track); }
inline void ToolTipAdd(int id, const CRect& rc)
	{ MainFrame->ToolTip()->Add(id, rc); }

///////////////////////////////////////////////////////////////////////////////
// delete tooltip

inline void ToolTipDel(CChildWindow* win) { MainFrame->ToolTip()->Del(win); }
inline void ToolTipDel(int id, const CRect& rc)
	{ MainFrame->ToolTip()->Del(id, rc); }

///////////////////////////////////////////////////////////////////////////////
// toolbar visible

inline BOOL ToolBarOn() { return MainFrame->ToolBarOn(); }
inline void SetToolBarOn(BOOL on) { MainFrame->SetToolBarOn(on); }

///////////////////////////////////////////////////////////////////////////////
// tool tip service

void DoToolTip(LPARAM lParam);

///////////////////////////////////////////////////////////////////////////////
// set main frame caption

void SetCaption();
