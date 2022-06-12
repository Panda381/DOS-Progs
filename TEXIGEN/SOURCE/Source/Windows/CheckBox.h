
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                          Check Box and Radio Button                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, check box click

// default width and height of check box and radio button
extern int DefCheckBoxW;
extern int DefCheckBoxH;

///////////////////////////////////////////////////////////////////////////////
// check box

class CCheckBox : public CChildWindow
{
protected:


public:

	// constructor
	CCheckBox();

	// create check box (flat=not 3D, btn=button like, returns FALSE on error)
	BOOL CreateChk(const CText& text, int x, int y, BOOL flat = FALSE,
			BOOL btn = FALSE, int w = 0, int h = 0, CWindow* parent = NULL);

	// create radio button (flat=not 3D,btn=button like,returns FALSE on error)
	BOOL CreateRadio(const CText& text, int x, int y, BOOL flat = FALSE,
			BOOL btn = FALSE, int w = 0, int h = 0, CWindow* parent = NULL);

	// check state (TRUE=1, FALSE=0 or BST_INDETERMINATE=2)
	int GetCheck();
	void SetCheck(int check);

	// execute button click
	void Click();
};
