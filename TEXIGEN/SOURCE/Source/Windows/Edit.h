
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Edit Box                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, notification code:
//				EN_CHANGE, EN_KILLFOCUS, EN_SETFOCUS, EN_UPDATE

extern const CText EditClass;

// default width and height of edit box
extern int DefEditW;
extern int DefEditH;

///////////////////////////////////////////////////////////////////////////////
// edit box

class CEdit : public CChildWindow
{
public:

	// constructor
	CEdit();

	// create single line edit box (flat=not 3D, returns FALSE on error)
	// special flags: 0, ES_NUMBER, ES_LOWERCASE, ES_UPPERCASE, ES_PASSWORD
	BOOL CreateSingle(int x, int y, int w = 0, HALIGN halign = HA_LEFT,
			BOOL flat = FALSE, int flags = 0, int h = 0, CWindow* parent=NULL);

	inline BOOL CreateEdit(int x, int y, int w = 0, BOOL flat = FALSE,
											int h = 0, CWindow* parent = NULL)
		{ return CreateSingle(x, y, w, HA_LEFT, flat, 0, h, parent); }

	inline BOOL CreateNum(int x, int y, int w = 0, BOOL flat = FALSE,
											int h = 0, CWindow* parent = NULL)
		{ return CreateSingle(x, y, w, HA_RIGHT, flat, ES_NUMBER, h, parent); }

	inline BOOL CreateLow(int x, int y, int w = 0, BOOL flat = FALSE,
											int h = 0, CWindow* parent = NULL)
		{ return CreateSingle(x, y, w, HA_LEFT, flat, ES_LOWERCASE,h,parent); }

	inline BOOL CreateUp(int x, int y, int w = 0, BOOL flat = FALSE,
											int h = 0, CWindow* parent = NULL)
		{ return CreateSingle(x, y, w, HA_LEFT, flat, ES_UPPERCASE,h,parent); }

	inline BOOL CreatePsw(int x, int y, int w = 0, BOOL flat = FALSE,
											int h = 0, CWindow* parent = NULL)
		{ return CreateSingle(x, y, w, HA_LEFT, flat, ES_PASSWORD, h,parent); }

	// create multi line edit box (flat=not 3D, returns FALSE on error)
	BOOL CreateText(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
													CWindow* parent = NULL);

	// create multi line edit box wrapping words
	//	(flat=not 3D, returns FALSE on error)
	BOOL CreateWrap(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
													CWindow* parent = NULL);

	// create small multi line edit box, limited by frame
	//	(flat=not 3D, returns FALSE on error)
	BOOL CreateMemo(int x, int y, int w = 0, int h = 0, BOOL flat = FALSE,
													CWindow* parent = NULL);

	// enable edit box
	virtual void Enable(BOOL enable, BOOL update = FALSE);

	// get/set number into edit box
	inline int Int() const { return m_Text.Int(); }
	inline int GetInt() { return GetText().Int(); }
	inline double Num() const { return m_Text.Double(); }
	inline double GetNum() { return GetText().Double(); }
	void SetInt(int num);
	void SetNum(double num, int digits = 15);

	// current selection (start=-1 nothing, end=-1 all)
	void GetSel(int* start = NULL, int* end = NULL);
	int GetSelStart();
	int GetSelEnd();
	void SetSel(int start, int end);
	inline void SetSelAll() { SetSel(0, -1); }
	inline void SetSelNone() { SetSel(-1, -1); }

	// caret position (offset in text)
	inline int GetPos() { return GetSelStart(); }
	inline void SetPos(int pos) { SetSel(pos, pos); }

	// scroll edit to ensure caret visibility
	void EnsureVisible();

	// text limitation (0=unlimited)
	int GetLimitText();
	void SetLimitText(int num = 0);

	// modification flag
	BOOL GetModify();
	void SetModify(BOOL modify = TRUE);

	// replace selection or insert text at current position
	void ReplaceSel(LPCTSTR text, BOOL canundo = TRUE);

	// check if edit can undo last operation
	BOOL CanUndo();

	// clear undo buffer
	void ClearUndo();

	// undo last operation
	void Undo();

	// clear selection
	void Clear();

	// copy selection into clipboard
	void Copy();

	// cut selection into clipboard
	void Cut();

	// paste text from clipboard
	void Paste();

	// get character position (offset in text) from client coordinates
	int CharFromCoord(int x, int y);

	// get client coordinates of a character (-1=character with caret)
	void CoordFromChar(int* x = NULL, int* y = NULL, int pos = -1);

	// get line index from client coordinates
	int LineFromCoord(int x, int y);

	// get index of first visible line (or first visible char. for single line)
	int FirstVisible();

	// get character position of a line (-1=current line with caret)
	int GetLinePos(int inx = -1);

	// get line index from a character in the line (-1=current line with caret)
	int GetLineInx(int pos = -1);

	// get length of a line from a character in the line (-1=current line)
	int GetLineLength(int pos = -1);
	inline int GetLineLengthInx(int inx = -1)
		{ return GetLineLength(GetLinePos(inx)); }

	// get number of lines (1 or more)
	int GetLineCount();

	// get line (-1=current line with caret)
	CText GetLine(int inx = -1);
};
