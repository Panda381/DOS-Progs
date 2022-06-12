
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Child Window                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// default parent window (if parent = NULL)
extern CWindow*	DefParentWin;

extern BOOL		CreateChildVisible;		// create window child items visible

// dialog item border type
typedef enum BORDER {
	BORDER_NONE,		// no border
	BORDER_HALFSUNK,	// half sunken (1 point)
	BORDER_SUNKEN,		// sunken (2 points)
	BORDER_DBLSUNK,		// doubly sunken (4 points)
	BORDER_LINE,		// line, flat control (1 point)
	BORDER_LINESUNK,	// line and half sunken (2 points)
	BORDER_RAISED,		// raised (2 points)
	BORDER_BUMP,		// bumped (raised and sunken, 5 points)
};

// horizontal align
typedef enum HALIGN {
	HA_LEFT,			// left
	HA_CENTER,			// horizontally center
	HA_RIGHT,			// right
};

// vertical align
typedef enum VALIGN {
	VA_TOP,				// top
	VA_MIDDLE,			// vertically center
	VA_BOTTOM,			// bottom
};

///////////////////////////////////////////////////////////////////////////////
// child window class

class CChildWindow : public CWindow
{
protected:

	// window item identifier
	int			m_Id;

	// next identifier
	static int	m_IDNext;

public:

	// constructor
	CChildWindow();

	// window item identifier
	inline int Id() const { return m_Id; }
	int GetId();
	void SetId(int id, BOOL update = FALSE);
	
	// create child window (returns FALSE on error)
	BOOL CreateChild(DWORD exstyle, const CText& classname, const CText& text,
		DWORD style, int x, int y, int w, int h, CWindow* parent = NULL);

	// init dialog item (existing in dialog window)
	void InitDlg(int id, CWindow* parent);

	// dialog item border
	void SetBorder(BORDER border);
	BORDER GetBorder();

	// update label from resource (separated with "|")
	void UpdateLabel();
};
