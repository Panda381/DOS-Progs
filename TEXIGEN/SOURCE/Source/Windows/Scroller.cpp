
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Scroller                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText ScrollerClass(_T("SCROLLBAR"));

// default width and height of scroller
int		DefScrollerW = 18;
int		DefScrollerH = 150;

///////////////////////////////////////////////////////////////////////////////
// constructor

CScroller::CScroller()
{
	// window type
	m_Type = WINTYPE_SCROLLER;

	// minimal value
	m_Min = 0;

	// maximal value (start of last page)
	m_Max = 100;

	// page length
	m_Page = 10;

	// scroller mode
	m_Mode = SB_CTL;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// create scroller (returns FALSE on error)

BOOL CScroller::CreateScroll(int x, int y, int w /*= 0*/, int h /*= 0*/,
		BOOL vert /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = (vert ? DefScrollerW : DefScrollerH);
	if (h == 0) h = (vert ? DefScrollerH : DefScrollerW);
	BOOL res = CreateChild(0, ScrollerClass, EmptyText,
						(vert ? SBS_VERT : SBS_HORZ), x, y, w, h, parent);
	SetRange(m_Min, m_Max, m_Page, TRUE);
	SetPos(0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set scroller range (0 to 65535)

void CScroller::SetRange(int min /*= 0*/, int max /*= 100*/, int page /*= 10*/,
														BOOL update/*=FALSE*/)
{
	if (min > max)
	{
		int k = min;
		min = max;
		max = k;
	}

	if ((min != m_Min) || (max != m_Max) || (page != m_Page) || update)
	{
		m_Min = min;
		m_Max = max;
		m_Page = page;

		if (IsValid())
		{
			FillingOn();
			SCROLLINFO si;
			si.cbSize = sizeof(si);
			si.fMask = SIF_RANGE | SIF_PAGE;
			si.nMin = min;
			si.nMax = max + page;
			si.nPage = page;
			::SetScrollInfo(m_Handle, m_Mode, &si, TRUE);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// limit position to valid scroller range

int _fastcall CScroller::Limit(int pos)
{
	if (pos < m_Min) pos = m_Min;
	if (pos > m_Max) pos = m_Max;
	return pos;
}

///////////////////////////////////////////////////////////////////////////////
// set current scroller position

int CScroller::GetPos()
{
	if (IsValid()) return Limit(::GetScrollPos(m_Handle, m_Mode));
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// set current scroller position

void CScroller::SetPos(int pos)
{
	if (IsValid())
	{
		FillingOn();
		::SetScrollPos(m_Handle, m_Mode, Limit(pos), TRUE);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// process window message (returns TRUE if position changed)

BOOL CScroller::OnMsg(WPARAM wParam, int step)
{
	int oldpos = GetPos();
	int pos = oldpos;

	switch (LOWORD(wParam))
	{
	case SB_LEFT: pos = 0; break;
	case SB_RIGHT: pos = Max(); break;
	case SB_LINELEFT: pos = oldpos - step; break;
	case SB_LINERIGHT: pos = oldpos + step; break;
	case SB_PAGELEFT: pos = oldpos - Page(); break;
	case SB_PAGERIGHT: pos = oldpos + Page(); break;
	case SB_THUMBPOSITION:
	case SB_THUMBTRACK: pos = HIWORD(wParam); break;
	}

	pos = Limit(pos);
	if (pos != oldpos)
	{
		SetPos(pos);
		return TRUE;
	}
	return FALSE;
}
