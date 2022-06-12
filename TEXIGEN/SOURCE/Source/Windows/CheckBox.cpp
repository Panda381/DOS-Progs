
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                          Check Box and Radio Button                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// default width and height of check box and radio button
int		DefCheckBoxW = 100;
int		DefCheckBoxH = 16;

///////////////////////////////////////////////////////////////////////////////
// constructor

CCheckBox::CCheckBox()
{
	// window type
	m_Type = WINTYPE_CHECKBOX;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// create check box (def=default frame, flat=not 3D, returns FALSE on error)

BOOL CCheckBox::CreateChk(const CText& text, int x, int y,BOOL flat /*=FALSE*/,
	BOOL btn /*=FALSE*/, int w /*=0*/, int h /*=0*/, CWindow* parent /*=NULL*/)
{
	if (w == 0) w = DefCheckBoxW;
	if (h == 0) h = DefCheckBoxH;
	return CreateChild(0, ButtonClass, text,
				(btn ? BS_PUSHLIKE : 0) |
				(flat ? BS_FLAT : 0) |
				BS_3STATE | WS_GROUP | WS_TABSTOP, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// create radio button (def=default frame, flat=not 3D, returns FALSE on error)

BOOL CCheckBox::CreateRadio(const CText& text, int x,int y,BOOL flat/*=FALSE*/,
	BOOL btn /*=FALSE*/, int w /*=0*/, int h /*=0*/, CWindow* parent /*=NULL*/)
{
	if (w == 0) w = DefCheckBoxW;
	if (h == 0) h = DefCheckBoxH;
	return CreateChild(0, ButtonClass, text,
				(btn ? BS_PUSHLIKE : 0) |
				(flat ? BS_FLAT : 0) |
				BS_RADIOBUTTON | WS_GROUP | WS_TABSTOP, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// get check state (TRUE=1, FALSE=0 or BST_INDETERMINATE=2)

int CCheckBox::GetCheck()
{
	int res = FALSE;
	if (IsValid()) res = (int)::SendMessage(m_Handle, BM_GETCHECK, 0, 0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set check state (TRUE=1, FALSE=0 or BST_INDETERMINATE=2)

void CCheckBox::SetCheck(int check)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, BM_SETCHECK, check, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// execute button click

void CCheckBox::Click()
{
	if (IsValid()) ::SendMessage(m_Handle, BM_CLICK, 0, 0);
}
