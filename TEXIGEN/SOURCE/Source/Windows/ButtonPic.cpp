
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                            Button with Picture                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// default width and height of button with picture
int		DefButtonPicW = 36;
int		DefButtonPicH = 36;

///////////////////////////////////////////////////////////////////////////////
// constructor

CButtonPicBase::CButtonPicBase()
{
	// button image
	m_Image = NULL;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set button image

void CButtonPicBase::SetImage(HANDLE img, BOOL update /*= FALSE*/)
{
	if ((img != m_Image) || update)
	{
		m_Image = img;
		if (IsValid())
		{
			FillingOn();
			::SendMessage(m_Handle, BM_SETIMAGE, IMAGE_BITMAP, (LPARAM)img);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// set button image with ID
//  transp - use transparency (only 8-bit paletted image)
//			substitutes colors:
//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 

void CButtonPicBase::SetImage(int id, BOOL transp /*= TRUE*/)
{
	HANDLE img = LoadWinImg(id, transp);
	SetImage(img);
}

///////////////////////////////////////////////////////////////////////////////
// execute button click

void CButtonPicBase::Click()
{
	if (IsValid()) ::SendMessage(m_Handle, BM_CLICK, 0, 0);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CButtonPic::CButtonPic()
{
	// window type
	m_Type = WINTYPE_BUTTONPIC;
}

///////////////////////////////////////////////////////////////////////////////
// create button (def=default frame, flat=not 3D, returns FALSE on error)

BOOL CButtonPic::CreateBtnPic(HANDLE img, int x, int y, BOOL def /*= FALSE*/,
						BOOL flat /*= FALSE*/, int w /*= 0*/, int h /*= 0*/,
						CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefButtonPicW;
	if (h == 0) h = DefButtonPicH;
	BOOL res = CreateChild(0, ButtonClass, EmptyText,
				(def ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON) |
				(flat ? BS_FLAT : 0) |
				BS_BITMAP | WS_GROUP | WS_TABSTOP, x, y, w, h, parent);
	if (res) SetImage(img);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// create button (def=default frame, flat=not 3D, returns FALSE on error)
//  transp - use transparency (only 8-bit paletted image)
//			substitutes colors:
//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 

BOOL CButtonPic::CreateBtnPic(int imgid, int x, int y, BOOL def /*= FALSE*/,
						BOOL flat /*= FALSE*/, int w /*= 0*/, int h /*= 0*/,
						BOOL transp /*= TRUE*/, CWindow* parent /*= NULL*/)
{
	HANDLE img = LoadWinImg(imgid, transp);
	return CreateBtnPic(img, x, y, def, flat, w, h, parent);
}
