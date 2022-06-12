
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                            Button with Picture                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, button click

// default width and height of button with picture
extern int DefButtonPicW;
extern int DefButtonPicH;

///////////////////////////////////////////////////////////////////////////////
// button with picture - base class

class CButtonPicBase : public CChildWindow
{
protected:

	// button image
	HANDLE		m_Image;

public:

	// constructor
	CButtonPicBase();

	// button image
	inline HANDLE Image() const { return m_Image; }
	void SetImage(HANDLE img, BOOL update = FALSE);

	// set button image with ID
	//  transp - use transparency (only 8-bit paletted image)
	//			substitutes colors:
	//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
	//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
	//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 
	void SetImage(int id, BOOL transp = TRUE);

	// execute button click
	void Click();
};

///////////////////////////////////////////////////////////////////////////////
// button with picture

class CButtonPic : public CButtonPicBase
{
public:

	// constructor
	CButtonPic();

	// create button (def=default frame, flat=not 3D, returns FALSE on error)
	BOOL CreateBtnPic(HANDLE img, int x, int y, BOOL def = FALSE,
				BOOL flat = FALSE, int w = 0, int h = 0, CWindow* parent=NULL);

	// create button (def=default frame, flat=not 3D, returns FALSE on error)
	//  transp - use transparency (only 8-bit paletted image)
	//			substitutes colors:
	//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
	//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
	//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 
	BOOL CreateBtnPic(int imgid, int x, int y, BOOL def = FALSE,BOOL flat = FALSE,
			int w = 0, int h = 0, BOOL transp = TRUE, CWindow* parent = NULL);
};
