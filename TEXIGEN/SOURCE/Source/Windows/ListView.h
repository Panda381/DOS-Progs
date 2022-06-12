
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  List View                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern const CText ListViewClass;

// default width and height of list view
extern int DefListViewW;
extern int DefListViewH;

// column descriptor
typedef struct LVADDCOLUMN_ {
	int		align;			// align (LVCFMT_LEFT, LVCFMT_CENTER, LVCFMT_RIGHT)
							//	ListView: head and cell align
							//	GridView: head align
	int		cellalign;		//	ListView: not used
							//	GridView: cell align
	int		width;			// column width
	CText	text;			// column title
} LVADDCOLUMN;

///////////////////////////////////////////////////////////////////////////////
// list view

class CListView : public CChildWindow
{
protected:

	// number of columns
	int		m_ColNum;

	// descriptor of columns
	LVADDCOLUMN*	m_ColDesc;

	// size of descriptor of columns
	int		m_ColMax;

	// number of entries in the list
	int		m_ItemNum;

	// selected row (-1=none)
	int		m_Select;

public:

	// constructor
	CListView();
	virtual ~CListView();

	// number of columns in report view
	inline int ColNum() const { return m_ColNum; }
	int GetColNum();

	// descriptor of columns
	inline LVADDCOLUMN*	ColDesc() { return m_ColDesc; }

	// check if column is valid
	inline BOOL ColIsValid(int pos) const
		{ return (DWORD)pos < (DWORD)m_ColNum; }

	// number of entries in the list
	inline int ItemNum() const { return m_ItemNum; }
	int GetItemNum();

	// first visible row
	int GetFirstVisible();

	// get/set row height ("get" needs valid item 0)
	int GetRowHeight();

	// check if index is valid
	inline BOOL InxIsValid(int inx) const
		{ return (DWORD)inx < (DWORD)m_ItemNum; }

	// create iconed list view (flat=not 3D, returns FALSE on error)
	BOOL CreateIco(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
													CWindow* parent = NULL);

	// create small icon list view (flat=not 3D, returns FALSE on error)
	BOOL CreateSmall(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
													CWindow* parent = NULL);

	// create listed list view (flat=not 3D, returns FALSE on error)
	BOOL CreateLst(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
													CWindow* parent = NULL);

	// create report list view (flat=not 3D, returns FALSE on error)
	BOOL CreateRep(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
								BOOL header = TRUE, BOOL grid = TRUE, CWindow* parent = NULL);

	// add columns in report view (from given column position)
	void AddCol(LVADDCOLUMN* col, int num = 1, int pos = BIGINT);

	// add one column (align=LVCFMT_LEFT, LVCFMT_CENTER, LVCFMT_RIGHT)
	inline void AddCol(int align, int width, CText text, int pos = BIGINT, int cellalign = LVCFMT_LEFT)
	{ LVADDCOLUMN lva; lva.align = align; lva.width = width; lva.text = text; lva.cellalign = cellalign;
		AddCol(&lva, 1, pos); }

	// delete columns in report view (from given column position)
	void DelCol(int pos, int num = 1);

	// delete all columns in report view
	inline void DelColAll() { DelCol(0, BIGINT); }

	// get column info (returns FALSE on error)
	BOOL GetCol(LVADDCOLUMN* col, int pos);

	// get column width (returns 0 on error)
	int GetColWidth(int pos = 0);

	// get item rect (returns FALSE on error)
	BOOL GetRowRect(int inx, RECT* rc);
	BOOL GetCellRect(int inx, int col, RECT* rc);

	// get column align (returns LVCFMT_LEFT, LVCFMT_CENTER, LVCFMT_RIGHT,
	// or -1 on error)
	int GetColAlign(int pos);

	// get column title
	CText GetColTitle(int pos);

	// insert text entry into list (-1 = end of list)
	//	(returns index of new entry or -1 on error)
	int Ins(LPCTSTR text, int inx = -1);

	// insert image entry into list (-1 = end of list)
	//	(returns index of new entry or -1 on error)
	int InsImg(int imginx, int inx = -1);

	// add entry into list (returns index of new entry or -1 on error)
	inline int Add(LPCTSTR text) { return Ins(text, -1); }

	// add multiple items (separated with "|", returns last index or -1)
	int AddMulti(const CTextList& list);
	int AddMulti(const CText& txt);
	int AddMulti(int id);

	// delete entry
	void Del(int inx);

	// delete all entries
	void DelAll();

	// set item text
	void SetItemText(LPCTSTR text, int inx, int pos = 0);

	// get item text
	CText GetItemText(int inx, int pos = 0);

	// set item image (images need to be prepared using SetImageList)
	void SetItemImg(int imginx, int inx, int pos = 0);

	// ensure entry visible
	void EnsureVisible(int inx);

	// get first selected entry (-1 = none)
	inline int Select() const { return m_Select; }
	int GetSelect();

	// set selected entry (-1 = none)
	void SetSelect(int inx = -1);

	// init dialog item (existing in dialog window)
	void InitDlg(int id, CWindow* parent);

	// redraw range of items
	void RedrawItems(int first, int last);
	void RedrawSelect() { RedrawItems(Select(), Select()); }

	// set image list normal (returns previous image list - should be destroyed by caller)
	HIMAGELIST SetImageList(HIMAGELIST img);

	// set image list small (returns previous image list - should be destroyed by caller)
	HIMAGELIST SetImageListSmall(HIMAGELIST img);
};
