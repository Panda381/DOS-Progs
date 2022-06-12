
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                           Check Box with Picture                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, check box click

// default width and height of check box with picture
extern int DefCheckPicW;
extern int DefCheckPicH;

///////////////////////////////////////////////////////////////////////////////
// check box with picture

class CCheckPic : public CButtonPicBase
{
public:

	// constructor
	CCheckPic();

	// create check box (flat=not 3D, returns FALSE on error)
	BOOL CreateChkPic(HANDLE img, int x, int y, BOOL flat = FALSE,
					int w = 0, int h = 0, CWindow* parent = NULL);

	// create check box (flat=not 3D, btn=button like, returns FALSE on error)
	//  transp - use transparency (only 8-bit paletted image)
	//			substitutes colors:
	//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
	//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
	//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 
	BOOL CreateChkPic(int imgid, int x, int y, BOOL flat = FALSE,
				int w = 0, int h = 0, BOOL transp=TRUE, CWindow* parent=NULL);

	// check state
	BOOL Check();
	void SetCheck(BOOL check);
};
