
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Progress Bar                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern const CText ProgressClass;

// default width and height of progress bar
extern int DefProgressW;
extern int DefProgressH;

///////////////////////////////////////////////////////////////////////////////
// progress bar

class CProgress : public CChildWindow
{
protected:

	// minimal value (0 to 65535)
	int		m_Min;

	// maximal value (0 to 65535)
	int		m_Max;

	// current value (min .. max)
	int		m_Pos;

public:

	// constructor
	CProgress();

	// create progress bar (flat=not 3D, returns FALSE on error)
	BOOL CreateBar(int x, int y, BOOL flat = FALSE, BOOL vert = FALSE, 
								int w = 0, int h = 0, CWindow* parent = NULL);

	// progress bar range (0 to 65535)
	inline int Min() const { return m_Min; }
	inline int Max() const { return m_Max; }
	void SetRange(int min = 0, int max = 100, BOOL update = FALSE);

	// limit position to valid progress bar range
	int _fastcall Limit(int pos);

	// current progress bar position
	inline int Pos() const { return m_Pos; }
	void SetPos(int pos, BOOL update = FALSE);
};
