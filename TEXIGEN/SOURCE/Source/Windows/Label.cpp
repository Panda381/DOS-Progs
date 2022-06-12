
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Text Label                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText StaticClass(_T("Static"));

// default width and height of text label
int		DefLabelW = 100;
int		DefLabelH = 14;

///////////////////////////////////////////////////////////////////////////////
// constructor

CLabel::CLabel()
{
	// window type
	m_Type = WINTYPE_LABEL;
}

///////////////////////////////////////////////////////////////////////////////
// create label aligned left (returns FALSE on error)

BOOL CLabel::CreateLeft(const CText& text, int x, int y, int w /*= 0*/,
									int h /*= 0*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefLabelW;
	if (h == 0) h = DefLabelH;
	return CreateChild(0, StaticClass, text,
					SS_LEFT | SS_NOTIFY | SS_NOPREFIX, x, y, w, h, parent);
}

BOOL CLabel::CreateLeft(int txtid, int x, int y, int w /*= 0*/, int h /*= 0*/,
													CWindow* parent /*= NULL*/)
{
	CText text;
	text.Load(txtid);
	return CreateLeft(text, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// create label centered (returns FALSE on error)

BOOL CLabel::CreateCenter(const CText& text, int x, int y, int w /*= 0*/,
									int h /*= 0*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefLabelW;
	if (h == 0) h = DefLabelH;
	return CreateChild(0, StaticClass, text,
				SS_CENTER | SS_NOTIFY | SS_NOPREFIX, x, y, w, h, parent);
}

BOOL CLabel::CreateCenter(int txtid, int x, int y, int w /*= 0*/, int h /*= 0*/,
													CWindow* parent /*= NULL*/)
{
	CText text;
	text.Load(txtid);
	return CreateCenter(text, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// create label aligned right (returns FALSE on error)

BOOL CLabel::CreateRight(const CText& text, int x, int y, int w /*= 0*/,
									int h /*= 0*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefLabelW;
	if (h == 0) h = DefLabelH;
	return CreateChild(0, StaticClass, text,
				SS_RIGHT | SS_NOTIFY | SS_NOPREFIX, x, y, w, h, parent);
}

BOOL CLabel::CreateRight(int txtid, int x, int y, int w /*= 0*/, int h /*= 0*/,
												CWindow* parent /*= NULL*/)
{
	CText text;
	text.Load(txtid);
	return CreateRight(text, x, y, w, h, parent);
}
