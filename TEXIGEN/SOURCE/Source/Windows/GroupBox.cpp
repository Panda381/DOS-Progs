
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Group Box                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CGroupBox::CGroupBox()
{
	// window type
	m_Type = WINTYPE_GROUPBOX;
}

///////////////////////////////////////////////////////////////////////////////
// create group box (returns FALSE on error)

BOOL CGroupBox::CreateGrp(const CText& text, int x, int y, int w, int h,
													CWindow* parent /*= NULL*/)
{
	return CreateChild(WS_EX_TRANSPARENT, ButtonClass, text,
									BS_GROUPBOX, x, y, w, h, parent);
}

BOOL CGroupBox::CreateGrp(int txtid, int x, int y, int w, int h,
													CWindow* parent /*= NULL*/)
{
	CText text;
	text.Load(txtid);
	return CreateGrp(text, x, y, w, h, parent);
}
