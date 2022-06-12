
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                    ToolTip                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern const CText ToolTipClass;

///////////////////////////////////////////////////////////////////////////////
// tooltip

class CToolTip : public CWindow
{
protected:


public:

	// constructor
	CToolTip();

	// create tooltip (returns FALSE on error)
	BOOL CreateToolTip(CWindow* parent = NULL);

	// activate tooltip
	void SetActive(BOOL active);

	// add tooltip
	void Add(CChildWindow* win, BOOL track = FALSE);
	void Add(int id, const CRect& rc);

	// delete tooltip
	void Del(CChildWindow* win);
	void Del(int id, const CRect& rc);
};
