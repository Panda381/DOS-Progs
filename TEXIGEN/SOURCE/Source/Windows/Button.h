
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                    Button                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, button click

extern const CText ButtonClass;

// default width and height of button
extern int DefButtonW;
extern int DefButtonH;

///////////////////////////////////////////////////////////////////////////////
// button

class CButton : public CChildWindow
{
protected:


public:

	// constructor
	CButton();

	// create button (def=default frame, flat=not 3D, returns FALSE on error)
	BOOL CreateBtn(const CText& text, int x, int y, BOOL def = FALSE,
				BOOL flat = FALSE, int w = 0, int h = 0, CWindow* parent = NULL);

	// execute button click
	void Click();
};
