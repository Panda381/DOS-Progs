
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                    ToolTip                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText ToolTipClass(_T("tooltips_class32"));

///////////////////////////////////////////////////////////////////////////////
// constructor

CToolTip::CToolTip()
{
	// window type
	m_Type = WINTYPE_TOOLTIP;
}

///////////////////////////////////////////////////////////////////////////////
// create tooltip (returns FALSE on error)

BOOL CToolTip::CreateToolTip(CWindow* parent /*= NULL*/)
{
	if (parent == NULL) parent = DefParentWin;

	BOOL res = CreateWin(0, ToolTipClass, EmptyText, WS_POPUP | TTS_NOPREFIX |
		TTS_ALWAYSTIP, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		CW_USEDEFAULT, parent, NULL);

	if (res)
	{
		FillingOn();
		::SetWindowPos(m_Handle, HWND_TOPMOST, 0, 0, 0, 0,
			SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
		FillingOff();
		SetActive(TRUE);
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// activate tooltip

void CToolTip::SetActive(BOOL active)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, TTM_ACTIVATE, (WPARAM)active, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// add tooltip

void CToolTip::Add(CChildWindow* win, BOOL track /*= FALSE*/)
{
	if (IsValid())
	{
		FillingOn();
		TOOLINFO ti;
		memset(&ti, 0, sizeof(ti));
		ti.cbSize = sizeof(ti);
		ti.uFlags = TTF_SUBCLASS | TTF_IDISHWND | (track ? (TTF_CENTERTIP|TTF_TRACK|TTF_ABSOLUTE) : 0);
		ti.hwnd = (win->Parent() == NULL) ? NULL : win->Parent()->Handle();
		ti.uId = (UINT_PTR)(win->Handle());
		ti.lpszText = LPSTR_TEXTCALLBACK;
		ti.lParam = (LPARAM)this;
		::SendMessage(m_Handle, TTM_ADDTOOL, 0, (LPARAM)&ti);
		//if (track) ::SendMessage(m_Handle, TTM_TRACKACTIVATE, TRUE, (LPARAM)&ti);
		FillingOff();
	}
}

void CToolTip::Add(int id, const CRect& rc)
{
	if (IsValid())
	{
		FillingOn();
		TOOLINFO ti;
		memset(&ti, 0, sizeof(ti));
		ti.cbSize = sizeof(ti);
		ti.uFlags = TTF_SUBCLASS;
		ti.rect = rc;
		ti.hwnd = (Parent() == NULL) ? NULL : Parent()->Handle();
		ti.uId = id;
		ti.lpszText = LPSTR_TEXTCALLBACK;
		ti.lParam = (LPARAM)this;
		::SendMessage(m_Handle, TTM_ADDTOOL, 0, (LPARAM)&ti);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// delete tool tip

void CToolTip::Del(CChildWindow* win)
{
	if (IsValid() && win->IsValid())
	{
		FillingOn();
		TOOLINFO ti;
		memset(&ti, 0, sizeof(ti));
		ti.cbSize = sizeof(ti);
		ti.uFlags = TTF_SUBCLASS | TTF_IDISHWND;
		ti.hwnd = (win->Parent() == NULL) ? NULL : win->Parent()->Handle();
		ti.uId = (UINT_PTR)(win->Handle());
		ti.lParam = (LPARAM)this;
		::SendMessage(m_Handle, TTM_DELTOOL, 0, (LPARAM)&ti);
		FillingOff();
	}
}

void CToolTip::Del(int id, const CRect& rc)
{
	if (IsValid())
	{
		FillingOn();
		TOOLINFO ti;
		memset(&ti, 0, sizeof(ti));
		ti.cbSize = sizeof(ti);
		ti.uFlags = TTF_SUBCLASS;
		ti.rect = rc;
		ti.hwnd = (Parent() == NULL) ? NULL : Parent()->Handle();
		ti.uId = id;
		ti.lParam = (LPARAM)this;
		::SendMessage(m_Handle, TTM_DELTOOL, 0, (LPARAM)&ti);
		FillingOff();
	}
}
