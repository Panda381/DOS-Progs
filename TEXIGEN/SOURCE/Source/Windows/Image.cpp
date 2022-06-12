
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                   Image                                   //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CImage::CImage()
{
	// window type
	m_Type = WINTYPE_IMAGE;

	// image
	m_Image = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// set image

void CImage::SetImage(HANDLE img, BOOL update /*= FALSE*/)
{
	if ((img != m_Image) || update)
	{
		m_Image = img;
		if (IsValid())
		{
			FillingOn();
			::SendMessage(m_Handle, STM_SETIMAGE, IMAGE_BITMAP, (LPARAM)img);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// set image with ID
//  transp - use transparency (only 8-bit paletted image)
//			substitutes colors:
//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 

void CImage::SetImage(int id, BOOL transp /*= TRUE*/)
{
	HANDLE img = LoadWinImg(id, transp);
	SetImage(img);
}

///////////////////////////////////////////////////////////////////////////////
// clear (delete) image

void CImage::DelImage()
{
	HANDLE img = m_Image;
	if (m_Image != NULL)
	{
		SetImage(NULL);
		::DeleteObject(img);
	}
}

///////////////////////////////////////////////////////////////////////////////
// create image (returns FALSE on error)

BOOL CImage::CreateImg(HANDLE img, int x, int y, int w, int h,
													CWindow* parent /*= NULL*/)
{
	BOOL res = CreateChild(0, StaticClass, EmptyText, SS_BITMAP | SS_NOTIFY |
		SS_CENTERIMAGE | SS_REALSIZEIMAGE, x, y, w, h, parent);
	if (res) SetImage(img);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// create image (returns FALSE on error)
//  transp - use transparency (only 8-bit paletted image)
//			substitutes colors:
//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 

BOOL CImage::CreateImg(int imgid, int x, int y, int w, int h,
							BOOL transp /*= TRUE*/, CWindow* parent /*= NULL*/)
{
	HANDLE img = LoadWinImg(imgid, transp);
	return CreateImg(img, x, y, w, h, parent);
}
