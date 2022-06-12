
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Base Window Class                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// load Windows image from resources (returns NULL on error)
//  transp - use transparency (only 8-bit paletted image)
//			substitutes colors:
//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 

HANDLE LoadWinImg(int id, BOOL transp = TRUE);

///////////////////////////////////////////////////////////////////////////////
// window type

typedef enum _WINTYPE
{
	WINTYPE_BASE,			// base window class
	WINTYPE_MAINFRAME,		// main application window
	WINTYPE_DIALOG,			// dialog window
	WINTYPE_CHILD,			// base child item
	WINTYPE_BUTTON,			// button
	WINTYPE_BUTTONPIC,		// button with picture
	WINTYPE_CHECKBOX,		// check box and radio button
	WINTYPE_CHECKPIC,		// check box with picture
	WINTYPE_LABEL,			// text label
	WINTYPE_GROUPBOX,		// group box
	WINTYPE_FRAME,			// window frame
	WINTYPE_IMAGE,			// image
	WINTYPE_EDIT,			// edit box
	WINTYPE_RICHEDIT,		// rich edit
	WINTYPE_LISTBOX,		// single selection list box
	WINTYPE_MULTILIST,		// multi selection list box
	WINTYPE_DROPLIST,		// drop-down list box
	WINTYPE_COMBOBOX,		// combo box
	WINTYPE_COMBOLIST,		// combo list
	WINTYPE_LISTVIEW,		// list view
	WINTYPE_PROGRESS,		// progress bar
	WINTYPE_SCROLLER,		// scroller
	WINTYPE_SPIN,			// spin control
	WINTYPE_STATUS,			// status line
	WINTYPE_TABS,			// tabs
	WINTYPE_TOOLTIP,		// tooltip
	WINTYPE_SLIDER,			// slider (track bar)
	WINTYPE_TOOLBAR,		// tool bar
	WINTYPE_TREEVIEW,		// tree view
	WINTYPE_PICTURE,		// picture
} WINTYPE;

///////////////////////////////////////////////////////////////////////////////
// arrange flags

// horizontal - relative if none, stretch if both
#define ARRANGE_LEFT	B0			// arrange left
#define ARRANGE_RIGHT	B1			// arrange right

// vertical - relative if none, stretch if both
#define ARRANGE_TOP		B2			// arrange top
#define ARRANGE_BOTTOM	B3			// arrange bottom

// width - no change default
#define	ARRANGE_WIDTH	B4			// arrange width relative

// height - no change default
#define ARRANGE_HEIGHT	B5			// arrange height relative

// arrange all absolute
#define ARRANGE_ABS		(ARRANGE_LEFT | ARRANGE_TOP)

// arrange all relative
#define	ARRANGE_REL		(ARRANGE_WIDTH | ARRANGE_HEIGHT)

// arrange all stretch
#define ARRANGE_STRETCH	(ARRANGE_LEFT|ARRANGE_RIGHT|ARRANGE_TOP|ARRANGE_BOTTOM)

LRESULT CALLBACK MyWinProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);

///////////////////////////////////////////////////////////////////////////////
// base window class

class CWindow : public CTreeEntry
{
protected:

	// window unique ID
	//CText		m_ID;

	// window hash list
	//CListEntry	m_HashEntry;

	// handle hash list
	CListEntry	m_HHashEntry;

	// window type
	WINTYPE		m_Type;

	// static object - must not be destroyed
	BOOL		m_Static;

	// window handle (NULL=none)
	HWND		m_Handle;

	// programmatic filling of window content (>0 ignore notifications)
	int			m_Filling;

	// window is visible
	BOOL		m_Visible;

	// window is enabled
	BOOL		m_Enabled;

	// window size and position in screen coordinates
	CRect		m_AbsRect;

	// window size and position in client coordinates
	CRect		m_Rect;

	// window client area
	CRect		m_ClientRect;

	// window class name
	CText		m_Class;

	// window text (title or content)
	CText		m_Text;

	// arrange flags
	int			m_ArrangeFlags;

	// initial parent's client area
	CRect		m_InitParRect;

	// initial client coordinates
	CRect		m_InitRect;

	// original message handler (NULL=none)
	WNDPROC		m_WinProc;

	// can accept focus
	BOOL		m_CanFocus;

	// key flags
	int			m_KeyFlags;

    // filter property index (-1=invalid)
	int			m_PropInx;

public:

	// constructor and destructor
	CWindow();
	virtual ~CWindow() {};

	// set window filling on/off (must be paired)
	inline void FillingOn() { m_Filling++; }
	inline void FillingOff() { m_Filling--; }

	// next neighbor (NULL=none)
	inline CWindow* Next() const { return (CWindow*)m_Next; }

	// previous neighbor (NULL=none)
	inline CWindow* Prev() const { return (CWindow*)m_Prev; }

	// parent (NULL=none, root)
	inline CWindow* Parent() const { return (CWindow*)m_Parent; }

	// first child (NULL=none)
	inline CWindow* First() const { return (CWindow*)m_First; }

	// last child (NULL=none)
	inline CWindow* Last() const { return (CWindow*)m_Last; }

	// find next tree entry (cyclical)
	inline CWindow* NextTreeEntry()
		{ return (CWindow*)CTreeEntry::NextTreeEntry(); }

	// find next entry, continue with neighbor, NULL=root (return NULL=none)
	inline CWindow* NextEntryNeigh(CWindow* root)
		{ return (CWindow*)CTreeEntry::NextEntryNeigh(root); }

	// find next entry in tree branch, NULL=root (return NULL=none)
	inline CWindow* NextEntryBranch(CWindow* root)
		{ return (CWindow*)CTreeEntry::NextEntryBranch(root); }

	// find next entry in the tree (returns NULL=none)
	inline CWindow* NextEntry() { return NextEntryBranch(NULL); }

	// add new child (or branch) into begin of list (new child can have
	// branch of children, it must have initialized entries m_First and m_Last)
	inline void AddFirst(CWindow* entry) { CTreeEntry::AddFirst(entry); }

	// add new child (or branch) into end of list (new child can have
	// branch of children, it must have initialized entries m_First and m_Last)
	inline void AddLast(CWindow* entry) { CTreeEntry::AddLast(entry); }

	// add neighbor (or branch) after current entry (neighbor can have
	// branch of children, it must have initialized entries m_First and m_Last)
	inline void AddAfter(CWindow* entry) { CTreeEntry::AddAfter(entry); }

	// add neighbor (or branch) before current entry (neighbor can have
	// branch of children, it must have initialized entries m_First and m_Last)
	inline void AddBefore(CWindow* entry) { CTreeEntry::AddBefore(entry); }

	// detach entry (children will stay attached to entry, Parent <- NULL)
	inline void Delete() { CTreeEntry::Delete(); }

	// handle hash list
	CListEntry*	HHashEntry() { return &m_HHashEntry; }
	static CWindow* WinHHashEntry(CListEntry* e)
		{ return ObjectFromList(e, CWindow, m_HHashEntry); }

	// window type
	inline WINTYPE Type() const { return m_Type; }
	inline void SetType(WINTYPE type) { m_Type = type; }

	// static object - must not be destroyed
	inline BOOL	Static() const { return m_Static; }
	inline void SetStatic(BOOL stat) { m_Static = stat; }

	// window handle (NULL=none)
	inline HWND Handle() const { return m_Handle; }
	inline void SetHandle(HWND wnd) { m_Handle = wnd; UpdateRect(); }
	inline operator HWND() const { return m_Handle; }

	// create window (returns FALSE on error)
	BOOL CreateWin(DWORD exstyle, const CText& classname, const CText& text,
		DWORD style, int x, int y, int w, int h, CWindow* parent, HMENU menu);

	// destroy chlidren of window
	void DestroyChildren();

	// destroy window with its children
	void Destroy();

	// check, if window is valid
	inline BOOL IsValid() const { return m_Handle != NULL; }

	// programmatic filling of window content (=ignore notifications)
	inline BOOL Filling() const { return m_Filling > 0; }

	// window is visible
	inline BOOL Visible() const { return m_Visible; }
	void SetVisible(BOOL visible, BOOL update = FALSE);

	// window is enabled
	inline BOOL Enabled() const { return m_Enabled; }
	virtual void Enable(BOOL enable, BOOL update = FALSE);
	BOOL GetEnabled();

	// window size and position in screen coordinates
	inline const CRect& AbsRect() const { return m_AbsRect; }
	inline int AbsLeft() const { return m_AbsRect.left; }
	inline int AbsTop() const { return m_AbsRect.top; }
	inline int AbsRight() const { return m_AbsRect.right; }
	inline int AbsBottom() const { return m_AbsRect.bottom; }

	// window size and position in client coordinates
	inline const CRect& Rect() const { return m_Rect; }
	inline int Left() const { return m_Rect.left; }
	inline int X() const { return m_Rect.left; }
	inline int Top() const { return m_Rect.top; }
	inline int Y() const { return m_Rect.top; }
	inline int Right() const { return m_Rect.right; }
	inline int X2() const { return m_Rect.right; }
	inline int Bottom() const { return m_Rect.bottom; }
	inline int Y2() const { return m_Rect.bottom; }
	inline int Width() const { return m_Rect.Width(); }
	inline int W() const { return m_Rect.Width(); }
	inline int Height() const { return m_Rect.Height(); }
	inline int H() const { return m_Rect.Height(); }

	// window client area
	inline const CRect& ClientRect() const { return m_ClientRect; }
	inline int ClientLeft() const { return m_ClientRect.left; }
	inline int ClientTop() const { return m_ClientRect.top; }
	inline int ClientRight() const { return m_ClientRect.right; }
	inline int ClientBottom() const { return m_ClientRect.bottom; }
	inline int ClientWidth() const { return m_ClientRect.Width(); }
	inline int ClientHeight() const { return m_ClientRect.Height(); }

	// check point in screen coordinates if it hits the window
	inline BOOL AbsHit(int x, int y) const { return m_AbsRect.Hit(x, y); }

	// check point in client coordinates if it hits the window
	inline BOOL Hit(int x, int y) const { return m_Rect.Hit(x, y); }

	// check if rectangle in screen coordinates overlaps the window
	inline BOOL AbsOverlap(const CRect& rc) const
		{ return m_AbsRect.Overlap(rc); }

	// check if rectangle in client coordinates overlaps the window
	inline BOOL Overlap(const CRect& rc) const { return m_Rect.Overlap(rc); }

	// check if two windows overlaps
	inline BOOL Overlap(const CWindow& wnd) const
		{ return m_AbsRect.Overlap(wnd.AbsRect()); }

	// update window size and position
	virtual void UpdateRect();

	// move and resize window (in client coordinates)
	void MoveResize(int x, int y, int w, int h);
	inline void Move(int x, int y) { MoveResize(x, y, W(), H()); }
	inline void Resize(int w, int h) { MoveResize(X(), Y(), w, h); }
	inline void AddPos(int dx, int dy) { Move(X() + dx, Y() + dy); }
	inline void AddSize(int dw, int dh) { Resize(W() + dw, H() + dh); }

	// arrange flags
	inline int ArrangeFlags() const { return m_ArrangeFlags; }
	inline void SetArrangeFlags(int flags) { m_ArrangeFlags = flags; }

	// arrange window after resizing parent
	void Arrange();

	// invalidate window content
	void Invalidate();
	void Invalidate(const CRect* rc);
	void Invalidate(int left, int top, int right, int bottom);

	// update window content (if it need update)
	void Update();

	// update window frame after changing window style
	void UpdateFrame();

	// redraw window content (invalidate and update)
	void Redraw();

	// disable window redraw
	void RedrawOff();

	// enable window redraw
	void RedrawOn();

	// window class name
	inline CText Class() const { return m_Class; }

	// window text (title or content)
	inline CText Text() const { return m_Text; }
	CText GetText();
	void SetText(const CText& txt, BOOL update = FALSE);
	inline void LoadText(int id) { m_Text.Load(id); SetText(m_Text, TRUE); }
	inline void SetEmpty(BOOL update = FALSE) { SetText(EmptyText, update); }
	void SetTextInt(int num, BOOL update = FALSE);
	void SetTextDouble(double num, BOOL update = FALSE);

	// set font
	virtual void SetFont(HFONT font);

	// window LONG value (you should use UpdateFrame after changing win frame)
	LONG_PTR GetLong(int inx);
	void SetLong(int inx, LONG_PTR val);
	inline long GetStyle() { return (long)GetLong(GWL_STYLE); }
	inline void SetStyle(long val) { SetLong(GWL_STYLE, val); }
	inline long GetExStyle() { return (long)GetLong(GWL_EXSTYLE); }
	inline void SetExStyle(long val) { SetLong(GWL_EXSTYLE, val); }
	inline void* GetData() { return (void*)GetLong(GWLP_USERDATA); }
	inline void SetData(void* val) { SetLong(GWLP_USERDATA, (LONG_PTR)val); }

	// set focus to this window (returns handle of previous window with focus)
	HWND SetFocus();

	// check whether window has focus
	BOOL HasFocus();

	// recalculate screen coordinates to client coordinates
	void RectToClient(CRect* rc);
	void PosToClient(POINT* pos);
	void PosToClient(int* x = NULL, int* y = NULL);
	int XToClient(int x);
	int YToClient(int y);

	// recalculate client coordinates to screen coordinates
	void RectToScreen(CRect* rc);
	void PosToScreen(POINT* pos);
	void PosToScreen(int* x = NULL, int* y = NULL);
	int XToScreen(int x);
	int YToScreen(int y);

	// original message handler (NULL=none)
	inline WNDPROC WinProc() { return m_WinProc; }

	// can accept focus
	inline BOOL CanFocus() { return m_CanFocus; }
	inline void SetCanFocus(BOOL ok) { m_CanFocus = ok; }

	// get owner of control (=window)
	CWindow* Owner();

	// key flags
	inline int KeyFlags() const { return m_KeyFlags; }
	inline void SetKeyFlags(int flags) { m_KeyFlags = flags; }

    // filter property index (-1=invalid)
	inline int PropInx() const { return m_PropInx; }
	inline void SetPropInx(int inx) { m_PropInx = inx; }
};

///////////////////////////////////////////////////////////////////////////////
// window hash list

#define WINHASH_BITS	20		// window hash list - number of bits of hash key
#define WINHASH_KEYS	(1 << WINHASH_BITS) // number of hash keys (1048576)
#define WINHASH_MASK	(WINHASH_KEYS - 1) // mask of hash key (0xFFFFF)

///////////////////////////////////////////////////////////////////////////////
// handle window hash list

class CWindowHList
{
protected:

	// array of hash list branches (size: 8 MB)
	CListEntry		m_Hash[WINHASH_KEYS];

	// total number of entries in the list
	int				m_Count;

public:

	// constructor
	inline CWindowHList()
	{
		int i;
		for (i = WINHASH_KEYS-1; i >= 0; i--) m_Hash[i].Init();
		m_Count = 0;
	}

	// total number of entries in the list
	inline int Count() const { return m_Count; }

	// hash value of the entry
	static inline int Hash(HWND wnd) { return ((DWORD)(LONG_PTR)wnd) & WINHASH_MASK; }

	static inline int Hash(CWindow* entry)
	{
		return Hash(entry->Handle());
	}

	// detach entry from the list
	inline void Delete(CWindow* entry)
	{
		entry->HHashEntry()->Del();
		m_Count--;
	}

	// add new entry into list (without checking similar entries)
	inline void Add(CWindow* win)
	{
		m_Hash[Hash(win)].AddBefore(win->HHashEntry());
		m_Count++;
	}

	// find window by HWND (NULL=not found)
	CWindow* Find(HWND wnd)
	{
		CWindow* entry;
		CListEntry* e;
		CListEntry* list = &m_Hash[Hash(wnd)];
		for (e = list->Next(); e != list; e = e->Next())
		{
			entry = CWindow::WinHHashEntry(e);
			if (entry->Handle() == wnd) return entry;
		}
		return NULL;
	}

	inline CWindow* Find(CWindow* entry)
	{
		return Find(entry->Handle());
	}

	// add new entry into list if it does not exist
	void AddNew(CWindow* entry)
	{
		CWindow* e = Find(entry->Handle());
		if (e == NULL) Add(entry);
	}
};

extern CWindowHList	WinHList;			// handle window hash list
