
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                           Check Box with Picture                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// default width and height of check box with picture
int		DefCheckPicW = 36;
int		DefCheckPicH = 36;

///////////////////////////////////////////////////////////////////////////////
// constructor

CCheckPic::CCheckPic()
{
	// window type
	m_Type = WINTYPE_CHECKPIC;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// create check box (flat=not 3D, returns FALSE on error)

BOOL CCheckPic::CreateChkPic(HANDLE img, int x, int y, BOOL flat /*= FALSE*/,
					int w /*= 0*/, int h /*= 0*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefCheckPicW;
	if (h == 0) h = DefCheckPicH;
	BOOL res = CreateChild(0, ButtonClass, EmptyText,
				BS_PUSHLIKE | (flat ? BS_FLAT : 0) | BS_BITMAP |
				BS_CHECKBOX | WS_GROUP | WS_TABSTOP, x, y, w, h, parent);
	if (res) SetImage(img);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// create check box (flat=not 3D, btn=button like, returns FALSE on error)
//  transp - use transparency (only 8-bit paletted image)
//			substitutes colors:
//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 

BOOL CCheckPic::CreateChkPic(int imgid, int x, int y, BOOL flat /*= FALSE*/,
	int w /*=0*/,int h /*=0*/,BOOL transp /*=TRUE*/,CWindow* parent /*=NULL*/)
{
	if (w == 0) w = DefCheckPicW;
	if (h == 0) h = DefCheckPicH;
	BOOL res = CreateChild(0, ButtonClass, EmptyText,
				BS_PUSHLIKE | (flat ? BS_FLAT : 0) | BS_BITMAP |
				BS_CHECKBOX | WS_GROUP | WS_TABSTOP, x, y, w, h, parent);
	if (res) SetImage(imgid, transp);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get check state

BOOL CCheckPic::Check()
{
	int res = FALSE;
	if (IsValid()) res = (int)::SendMessage(m_Handle, BM_GETCHECK, 0, 0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set check state

void CCheckPic::SetCheck(BOOL check)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, BM_SETCHECK, check, 0);
		FillingOff();
	}
}
