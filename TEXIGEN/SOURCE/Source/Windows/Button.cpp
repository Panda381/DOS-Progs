
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                    Button                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText ButtonClass(_T("Button"));

// default width and height of button
int		DefButtonW = 75;
int		DefButtonH = 25;

///////////////////////////////////////////////////////////////////////////////
// constructor

CButton::CButton()
{
	// window type
	m_Type = WINTYPE_BUTTON;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// create button (def=default frame, flat=not 3D, returns FALSE on error)

BOOL CButton::CreateBtn(const CText& text, int x, int y, BOOL def /*= FALSE*/,
						BOOL flat /*= FALSE*/, int w /*= 0*/, int h /*= 0*/,
						CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefButtonW;
	if (h == 0) h = DefButtonH;
	return CreateChild(0, ButtonClass, text,
				(def ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON) |
				(flat ? BS_FLAT : 0) |
				WS_GROUP | WS_TABSTOP, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// execute button click

void CButton::Click()
{
	if (IsValid()) ::SendMessage(m_Handle, BM_CLICK, 0, 0);
}
