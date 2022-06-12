
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                            Font Selection Dialog                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// global font selection dialog
CFontSel	FontSel;

///////////////////////////////////////////////////////////////////////////////
// constructor

CFontSel::CFontSel()
{
	m_Font.lfHeight = -16;
	m_Font.lfWidth = 0;
	m_Font.lfEscapement = 0;
	m_Font.lfOrientation = 0;
	m_Font.lfWeight = 400;
	m_Font.lfItalic = FALSE;
	m_Font.lfUnderline = FALSE;
	m_Font.lfStrikeOut = FALSE;
	m_Font.lfCharSet = DEFAULT_CHARSET;
	m_Font.lfOutPrecision = OUT_DEFAULT_PRECIS;
	m_Font.lfClipPrecision = CLIP_DEFAULT_PRECIS;
	m_Font.lfQuality = DEFAULT_QUALITY;
	m_Font.lfPitchAndFamily = DEFAULT_PITCH | FF_DONTCARE;
	memcpy(m_Font.lfFaceName, _T("Arial"), 6*sizeof(TCHAR));
}

///////////////////////////////////////////////////////////////////////////////
// typeface name of the font

CText CFontSel::Face()
{
	m_Font.lfFaceName[LF_FACESIZE-1] = 0;
	CText txt(m_Font.lfFaceName);
	return txt;
}

void CFontSel::SetFace(CText face)
{
	if (face.Length() > (LF_FACESIZE-1)) face.Delete(LF_FACESIZE-1);
	face.WriteZ(m_Font.lfFaceName);
}

///////////////////////////////////////////////////////////////////////////////
// execute font selection dialog (returns FALSE on error or cancel)

BOOL CFontSel::Execute(CWindow* parent /*= NULL*/)
{
	// default parent
	if (parent == NULL) parent = DefParentWin;

	// prepare structure
	CHOOSEFONT f;
	f.lStructSize = sizeof(CHOOSEFONT);
	f.hwndOwner = (parent == NULL) ? NULL : parent->Handle();
	f.lpLogFont = &m_Font;
	f.Flags = CF_FORCEFONTEXIST | CF_INITTOLOGFONTSTRUCT |
				CF_NOVERTFONTS | CF_SCREENFONTS;

	return ::ChooseFont(&f);
}
