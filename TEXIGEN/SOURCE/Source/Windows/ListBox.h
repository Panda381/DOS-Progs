
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Simple List Box                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, notification code:
//				LBN_SELCANCEL, LBN_SELCHANGE, LBN_KILLFOCUS, LBN_SETFOCUS

extern const CText ListBoxClass;

// default width and height of list box
extern int DefListBoxW;
extern int DefListBoxH;

///////////////////////////////////////////////////////////////////////////////
// list box - base class

class CListBoxBase : public CChildWindow
{
protected:

	// number of entries in the list
	int			m_ItemNum;

public:

	// constructor
	CListBoxBase();

	// number of entries in the list
	inline int ItemNum() const { return m_ItemNum; }
	int GetItemNum();

	// check if index is valid
	inline BOOL InxIsValid(int inx) const
		{ return (DWORD)inx < (DWORD)m_ItemNum; }

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

	// get entry client coordinates (return FALSE on error)
	BOOL GetItemRect(CRect* rc, int inx);

	// get length of text of entry
	int GetItemLength(int inx);

	// get text of entry
	CText GetItemText(int inx);

	// index of first visible entry
	int FirstVisible();
	void SetFirstVisible(int inx);

	// get entry from client coordinates (-1 = not found)
	int ItemFromCoord(int x, int y);

	// set tab stops (32 default)
	void SetTabStops(int num, int* tabs);
	inline void SetTabStops(int tab) { SetTabStops(1, &tab); }
	inline void ResTabStops() { SetTabStops(0, NULL); }
};

///////////////////////////////////////////////////////////////////////////////
// single selection list box

class CListBox : public CListBoxBase
{
public:

	// constructor
	CListBox();

	// create list box (flat=not 3D, returns FALSE on error)
	BOOL CreateLst(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
				BOOL sort = FALSE, CWindow* parent = NULL);

	// selected entry (-1 = none)
	int GetSelect();
	void SetSelect(int inx = -1);

	// find and select item starting with substring (not case sensitive,
	// start = previous entry, returns -1 = not found)
	int SelectSub(LPCTSTR text, int start = -1);
};

///////////////////////////////////////////////////////////////////////////////
// multi selection list box

class CMultiList : public CListBoxBase
{
public:

	// constructor
	CMultiList();

	// create list box (flat=not 3D, returns FALSE on error)
	BOOL CreateLst(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
				BOOL sort = FALSE, CWindow* parent = NULL);

	// entry with caret (-1 = none)
	int GetSelect();
	void SetSelect(int inx = -1);

	// get selection state of an entry
	BOOL GetSel(int inx);

	// set selection state of an entry (-1=all entries)
	void SetSel(BOOL sel, int inx = -1);

	// select range of items
	void SelRange(BOOL sel, int first, int last);
	inline void SelNone() { SelRange(FALSE, 0, -1); }
	inline void SelAll() { SelRange(TRUE, 0, -1); }

	// get number of selected entries
	int GetSelCount();

	// get multi-selection list (returns malloc buffer, first integer = number
	// of entries, following list of INT indices, NULL=no items, use free())
	int* GetMultiSelList();
};
