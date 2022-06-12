
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Combo Box                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, notification code:
//				CBN_CLOSEUP, CBN_DROPDOWN, CBN_EDITCHANGE,
//				CBN_KILLFOCUS, CBN_SELCHANGE, CBN_SELENDCANCEL, CBN_SELENDOK

extern const CText ComboClass;

// default width and height of drop-down list box
extern int DefDropListW;
extern int DefDropListH;

// default width and height of combo box
extern int DefComboBoxW;
extern int DefComboBoxH;

// default width and height of combo list
extern int DefComboListW;
extern int DefComboListH;

///////////////////////////////////////////////////////////////////////////////
// combo list box - base class

class CComboBase : public CChildWindow
{
protected:

	// number of entries in the list
	int			m_ItemNum;

public:

	// constructor
	CComboBase();

	// number of entries in the list
	inline int ItemNum() const { return m_ItemNum; }
	int GetItemNum();

	// check if index is valid
	inline BOOL InxIsValid(int inx) const
		{ return (DWORD)inx < (DWORD)m_ItemNum; }

	// get combo box info (returns FALSE on error)
	BOOL GetInfo(COMBOBOXINFO* info);

	// get coordinates of edit box (return FALSE on error)
	BOOL GetEditRect(CRect* rc);	

	// get handle of drop-down list (return NULL on error)
	HWND GetDropHWND();

	// get drop-down list screen coordinates (returns FALSE on error)
	BOOL GetDropRect(CRect* rc);

	// add text into list (returns index of new entry or -1,-2 on error)
	int Add(LPCTSTR text);

	// add multiple items (separated with "|", returns last index or -1,-2)
	int AddMulti(const CTextList& list);
	int AddMulti(const CText& txt);
	int AddMulti(int id);

	// insert text into list at given position, -1=end of list
	//	(returns index of new entry or -1,-2 on error)
	int Ins(LPCTSTR text, int inx = -1);

	// delete entry
	void Del(int inx);

	// delete all entries
	void DelAll();

	// selected entry (-1 = none)
	int GetSelect();
	void SetSelect(int inx = -1);

	// init dialog item (existing in dialog window)
	void InitDlg(int id, CWindow* parent);

	// get user data of an entry (returns (void*)-1 on error)
	void* GetData(int inx);

	// set user data of an entry (inx = -1 all entries)
	void SetData(void* data, int inx = -1);

	// find entry in the list (not case sensitive, start = previous entry,
	// returns -1 = not found)
	int Find(LPCTSTR text, int start = -1);

	// find entry in the list starting with substring (not case sensitive,
	// start = previous entry, returns -1 = not found)
	int FindSub(LPCTSTR text, int start = -1);

	// line height (in pixels)
	int GetItemHeight();
	void SetItemHeight(int height = 14);

	// selection field height (in pixels)
	int GetEditHeight();
	void SetEditHeight(int height = 16);

	// get length of text of entry
	int GetItemLength(int inx);

	// get text of entry
	CText GetItemText(int inx);

	// index of first visible entry (if list box is dropped down)
	int FirstVisible();
	void SetFirstVisible(int inx);

	// find and select item starting with substring (not case sensitive,
	// start = previous entry, returns -1 = not found)
	int SelectSub(LPCTSTR text, int start = -1);
};

///////////////////////////////////////////////////////////////////////////////
// drop-down list box (drop-down list: YES, edit: NO)

class CDropList : public CComboBase
{
public:
	// constructor
	CDropList();

	// create list box (returns FALSE on error)
	BOOL CreateLst(int x, int y, int w = 0, int h = 0, BOOL sort = FALSE,
													CWindow* parent = NULL);

	// get coordinates of button (return FALSE on error)
	BOOL GetButtonRect(CRect* rc);	

	// check, if list box is dropped down
	BOOL IsDropped();

	// set drop-down list box
	void DropDown(BOOL drop = TRUE);

	// minimum dropped width (0 = minimum, returns -1 on error)
	int DroppedWidth();
	void SetDroppedWidth(int width = 0);
};

///////////////////////////////////////////////////////////////////////////////
// combo box (drop-down list: YES, edit: YES)

class CComboBox : public CComboBase
{
public:
	// constructor
	CComboBox();

	// create combo box (returns FALSE on error)
	BOOL CreateLst(int x, int y, int w = 0, int h = 0, BOOL sort = FALSE,
													CWindow* parent = NULL);

	// get coordinates of button (return FALSE on error)
	BOOL GetButtonRect(CRect* rc);	

	// get handle of edit box (return NULL on error)
	HWND GetEditHWND();

	// check, if list box is dropped down
	BOOL IsDropped();

	// set drop-down list box
	void DropDown(BOOL drop = TRUE);

	// minimum dropped width (0 = minimum, returns -1 on error)
	int DroppedWidth();
	void SetDroppedWidth(int width = 0);

	// current edit selection (start = -1 nothing, end = -1 all)
	void GetEditSel(int* start = NULL, int* end = NULL);
	int GetSelStart();
	int GetSelEnd();
	void SetEditSel(int start, int end);
	inline void SelEditAll() { SetEditSel(0, -1); }
	inline void SelEditNone() { SetEditSel(-1, -1); }

	// set text limitation of edit box (0=unlimited)
	void SetLimitText(int num = 0);
};

///////////////////////////////////////////////////////////////////////////////
// combo list (drop-down list: NO, edit: YES)

class CComboList : public CComboBase
{
public:
	// constructor
	CComboList();

	// create combo list (returns FALSE on error)
	BOOL CreateLst(int x, int y, int w = 0, int h = 0, BOOL sort = FALSE,
													CWindow* parent = NULL);

	// get handle of edit box (return NULL on error)
	HWND GetEditHWND();

	// current edit selection (start = -1 nothing, end = -1 all)
	void GetEditSel(int* start = NULL, int* end = NULL);
	int GetSelStart();
	int GetSelEnd();
	void SetEditSel(int start, int end);
	inline void SelEditAll() { SetEditSel(0, -1); }
	inline void SelEditNone() { SetEditSel(-1, -1); }

	// set text limitation of edit box (0=unlimited)
	void SetLimitText(int num = 0);
};
