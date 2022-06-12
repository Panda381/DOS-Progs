
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Status Line                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern const CText StatusClass;

#define STATUS_MAX	10		// max. number of status line parts

///////////////////////////////////////////////////////////////////////////////
// status line

class CStatus : public CChildWindow
{
protected:

	// status line text
	CText		m_StatusText[STATUS_MAX];

	// number of status line parts (1..STATUS_MAX)
	int			m_PartNum;

	// widths of status line parts (-1 = autosize)
	int			m_PartWidth[STATUS_MAX];

public:

	// constructor
	CStatus();

	// create status line (returns FALSE on error)
	//		(resizing: parent window has WS_THICKFRAME style)
	BOOL CreateStatus(CWindow* parent = NULL);

	// resize status line (after resizing parent window)
	void Resize();

	// update widths of status line parts
	void UpdateParts();

	// check if part index is in valid range
	static inline BOOL PartIsValid(int part)
		{ return (DWORD)part < (DWORD)STATUS_MAX; }

	// number of status line parts (1..STATUS_MAX)
	inline int PartNum() const { return m_PartNum; }
	void SetPartNum(int num = 1);

	// width of status line part (-1 = autosize)
	inline int PartWidth(int part = 0) const
		{ return PartIsValid(part) ? m_PartWidth[part] : 0; }
	void SetPartWidth(int part = 0, int width = -1);

	// status line text
	inline CText StatusText(int part = 0)
		{ return PartIsValid(part) ? m_StatusText[part] : EmptyText; }
	void SetStatusText(const CText& text, int part = 0, BOOL update = TRUE);
};
