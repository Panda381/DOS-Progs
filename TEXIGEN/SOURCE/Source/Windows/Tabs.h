
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                    Tabs                                   //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notification: TCN_SELCHANGE

extern const CText TabsClass;

///////////////////////////////////////////////////////////////////////////////
// tabs

class CTabs : public CChildWindow
{
protected:

	// tab text list
	CTextList	m_ItemList;

public:

	// constructor
	CTabs();

	// check if tab index is valid
	inline BOOL InxIsValid(int inx) const { return m_ItemList.IsValid(inx); }

	// number of tabs
	inline int ItemNum() const { return m_ItemList.Num(); }

	// tab text
	inline CText ItemText(int inx) { return m_ItemList.Get(inx); }
	void SetItemText(const CText& text, int inx, BOOL update = FALSE);

	// tab text list
	inline const CTextList* ItemList() const { return &m_ItemList; }

	// create tab control
	BOOL CreateTabs(int x, int y, int w, int h, CWindow* parent = NULL);

	// insert new tab (-1=last tab, returns index of new tab or -1 on error)
	int Ins(const CText& text, int inx = -1);
	inline int Add(const CText& text) { return Ins(text, -1); }

	// delete all tabs
	void DelAll();
};
