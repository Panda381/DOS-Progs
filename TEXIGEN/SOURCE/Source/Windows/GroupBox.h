
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Group Box                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// group box

class CGroupBox : public CChildWindow
{
protected:


public:

	// constructor
	CGroupBox();

	// create group box (returns FALSE on error)
	BOOL CreateGrp(const CText& text, int x, int y, int w, int h,
													CWindow* parent = NULL);
	BOOL CreateGrp(int txtid, int x, int y, int w, int h, CWindow* parent = NULL);
};
