
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                   Image                                   //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, image click

///////////////////////////////////////////////////////////////////////////////
// image

class CImage : public CChildWindow
{
protected:

	// image
	HANDLE		m_Image;

public:

	// constructor
	CImage();

	// image
	inline HANDLE Image() const { return m_Image; }
	void SetImage(HANDLE img, BOOL update = FALSE);

	// set image with ID
	//  transp - use transparency (only 8-bit paletted image)
	//			substitutes colors:
	//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
	//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
	//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 
	void SetImage(int id, BOOL transp = TRUE);

	// clear (delete) image
	void DelImage();

	// create image (returns FALSE on error)
	BOOL CreateImg(HANDLE img,int x,int y,int w,int h,CWindow* parent=NULL);

	// create image (returns FALSE on error)
	//  transp - use transparency (only 8-bit paletted image)
	//			substitutes colors:
	//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
	//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
	//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 
	BOOL CreateImg(int imgid, int x, int y, int w, int h,
								BOOL transp = TRUE, CWindow* parent = NULL);
};
