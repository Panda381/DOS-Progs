
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Tool Bar                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications: using WM_COMMAND

extern const CText ToolBarClass;

extern int DefToolBarBtnW;		// default tool bar button width
extern int DefToolBarBtnH;		// default tool bar button height
extern int DefToolBarIcoW;		// default tool bar icon width
extern int DefToolBarIcoH;		// default tool bar icon height

///////////////////////////////////////////////////////////////////////////////
// tool bar

class CToolBar : public CChildWindow
{
protected:

	// number of buttons
	int			m_BtnNum;

	// handle of tooltip
	HWND		m_ToolTip;

	// use labels
	BOOL		m_UseLabels;

public:

	// constructor
	CToolBar();

	// number of buttons
	inline int BtnNum() const { return m_BtnNum; }

	// check if button index is valid
	inline BOOL InxIsValid(int inx) const
		{ return ((DWORD)inx < (DWORD)m_BtnNum); }

	// handle of tooltip
	inline HWND ToolTip() const { return m_ToolTip; }

	// create toolbar (using bitmap ID and number of buttons in bitmap)
	// Palette color with index 0 is transparent.
	BOOL CreateToolBar(int barid, int num, BOOL flat = TRUE,
						BOOL labels = FALSE, CWindow* parent = NULL);

	// resize toolbar (after resizing parent window)
	void Resize();

	// set icon size
	void SetIconSize(int w, int h);

	// set button size
	void SetBtnSize(int w, int h);

	// add buttons (use macros below)
	BOOL AddBtn(TBBUTTON* btn, int num = 1);

	// delete buttons
	void DelBtn(int inx, int num = 1);
	inline void DelAllBtn() { DelBtn(0, BIGINT); }

	// enable button (using command identifier)
	void EnableBtn(int id, BOOL enable);

	// check button (using command identifier)
	void CheckBtn(int id, BOOL check);

	// add control to tooltip
	void AddToolTip(CChildWindow* w, int id);

	// delete control from tooltip
	void DelToolTip(CChildWindow* w);
};

// macros for TBBUTTON definition
#define TBBTN(i,id)			{i, id, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0, 0}
#define TBBTN_CHECK(i,id)	{i, id, TBSTATE_ENABLED, TBSTYLE_CHECK, 0, 0}
#define TBBTN_RADIO(i,id)	{i, id, TBSTATE_ENABLED, TBSTYLE_CHECKGROUP, 0, 0}
#define TBBTN_SEP			{0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0, 0}
