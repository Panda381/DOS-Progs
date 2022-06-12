
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                           Color Selection Dialog                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define USERCOLORS	16				// number of user-defined colors

///////////////////////////////////////////////////////////////////////////////
// color selection dialog

class CColorSel
{
protected:

	// user-defined colors
	COLORREF	m_UserCol[USERCOLORS];

	// selected color
	COLORREF	m_Color;

public:

	// constructor
	CColorSel();

	// user-defined colors
	inline COLORREF* UserCol() { return m_UserCol; }

	// selected color
	inline COLORREF Color() const { return m_Color; }
	inline void SetColor(COLORREF col) { m_Color = col; }

	// execute color selection dialog (returns FALSE on error or cancel)
	BOOL Execute(CWindow* parent = NULL);
};

// global color selection dialog
extern CColorSel ColorSel;
