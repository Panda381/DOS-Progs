
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Spin Control                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications: UDN_DELTAPOS, WM_HSCROLL, WM_VSCROLL

extern const CText SpinClass;

// default width and height of spin control
extern int DefSpinW;
extern int DefSpinH;

///////////////////////////////////////////////////////////////////////////////
// spin control

class CSpin : public CChildWindow
{
protected:


public:

	// constructor
	CSpin();

	// create spin control (returns FALSE on error)
	BOOL CreateSpin(int x, int y, int w = 0, int h = 0, BOOL horz = FALSE,
													CWindow* parent = NULL);

	inline BOOL CreateVSpin(int x, int y, int w=0,int h=0,CWindow* parent=NULL)
		{ return CreateSpin(x, y, w, h, FALSE, parent); }

	inline BOOL CreateHSpin(int x, int y, int w=0,int h=0,CWindow* parent=NULL)
		{ return CreateSpin(x, y, w, h, TRUE, parent); }
};
