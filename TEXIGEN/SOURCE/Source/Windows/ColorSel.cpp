
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                           Color Selection Dialog                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// global color selection dialog
CColorSel	ColorSel;

///////////////////////////////////////////////////////////////////////////////
// constructor

CColorSel::CColorSel()
{
	CText txt;
	for (int i = 0; i < USERCOLORS; i++)
	{
		txt.Format(_T("color%d"), i+1);
		m_UserCol[i] = ReadIniInt(txt, 0);
	}
	m_Color = 0;
}

///////////////////////////////////////////////////////////////////////////////
// execute color selection dialog (returns FALSE on error or cancel)

BOOL CColorSel::Execute(CWindow* parent /*= NULL*/)
{
	// default parent
	if (parent == NULL) parent = DefParentWin;

	// prepare structure
	CHOOSECOLOR c;
	c.lStructSize = sizeof(CHOOSECOLOR);
	c.hwndOwner = (parent == NULL) ? NULL : parent->Handle();
	c.rgbResult = m_Color;
	c.lpCustColors = m_UserCol;
	c.Flags = CC_ANYCOLOR | CC_FULLOPEN | CC_RGBINIT;
	c.lCustData = (LPARAM)this;

	// select color
	BOOL res = ::ChooseColor(&c);

	// save user colors
	CText txt;
	for (int i = 0; i < USERCOLORS; i++)
	{
		txt.Format(_T("color%d"), i+1);
		WriteIniInt(txt, m_UserCol[i]);
	}
	if (!res) return FALSE;

	// get new color
	m_Color = c.rgbResult;
	return TRUE;
}
