
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Tool Bar                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText ToolBarClass(_T("ToolbarWindow32"));

int DefToolBarBtnW = 26;		// default tool bar button width
int DefToolBarBtnH = 26;		// default tool bar button height
int DefToolBarIcoW = 24;		// default tool bar icon width
int DefToolBarIcoH = 24;		// default tool bar icon height

///////////////////////////////////////////////////////////////////////////////
// constructor

CToolBar::CToolBar()
{
	// window type
	m_Type = WINTYPE_TOOLBAR;

	// number of buttons
	m_BtnNum = 0;

	// handle of tooltip
	m_ToolTip = NULL;

	// use labels
	m_UseLabels = FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// create toolbar (using bitmap ID and number of buttons in bitmap)
// Palette color with index 0 is transparent.

BOOL CToolBar::CreateToolBar(int barid, int num, BOOL flat /*= TRUE*/,
						BOOL labels /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_BtnNum = 0;

	// create toolbar
	BOOL res = CreateChild(0, ToolBarClass, EmptyText, TBSTYLE_TOOLTIPS |
		WS_BORDER | (flat ? TBSTYLE_FLAT : 0) | (labels ? (TBSTYLE_LIST |
		TBSTYLE_AUTOSIZE) : 0), 0, 0, 0, 0, parent);
	m_UseLabels = labels;

	if (res)
	{
		// set icon size
		SetIconSize(DefToolBarIcoW, DefToolBarIcoH);

		// set button size
		SetBtnSize(DefToolBarBtnW, DefToolBarBtnH);

		// define size of button descriptor
		::SendMessage(m_Handle, TB_BUTTONSTRUCTSIZE, sizeof(TBBUTTON), 0);

		// add bitmap
		TBADDBITMAP tbab;
		tbab.hInst = Instance;
		tbab.nID = barid;
		::SendMessage(m_Handle, TB_ADDBITMAP, num, (LPARAM)&tbab);

		// get tooltip handle
		m_ToolTip = (HWND)::SendMessage(m_Handle, TB_GETTOOLTIPS, 0, 0);
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// resize toolbar (after resizing parent window)

void CToolBar::Resize()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, TB_AUTOSIZE, 0, 0); 
		UpdateRect();
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set icon size

void CToolBar::SetIconSize(int w, int h)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle,TB_SETBITMAPSIZE,0,MAKELONG((WORD)w,(WORD)h));
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set button size

void CToolBar::SetBtnSize(int w, int h)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle,TB_SETBUTTONSIZE,0,MAKELONG((WORD)w,(WORD)h));
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// add buttons (returns FALSE on error)

BOOL CToolBar::AddBtn(TBBUTTON* btn, int num /*= 1*/)
{
	BOOL res = FALSE;

	if (IsValid())
	{
		FillingOn();

		// add buttons
		res = (BOOL)::SendMessage(m_Handle, TB_ADDBUTTONS, num, (LPARAM)btn);
		if (res)
		{
			m_BtnNum += num;

			// add texts
			if (m_UseLabels)
			{
				CText txt;
				TBBUTTONINFO bi;
				for (int j = 0; j < num; j++)
				{
					txt.Load(btn[j].idCommand);
					int p = txt.Find('|');
					if (p >= 0) txt.DelToEnd(p);

					bi.cbSize = sizeof(TBBUTTONINFO);
					bi.dwMask = TBIF_TEXT;
					bi.pszText = (LPTSTR)(LPCTSTR)txt;
					bi.cchText = txt.Length();
					::SendMessage(m_Handle, TB_SETBUTTONINFO, btn[j].idCommand,
																(LPARAM)&bi);
				}
			}

			// resize tool bar
			::SendMessage(Handle(), TB_AUTOSIZE, 0, 0); 
			UpdateRect();
		}

		FillingOff();
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// delete buttons

void CToolBar::DelBtn(int inx, int num /*= 1*/)
{
	if (!InxIsValid(inx) || (num <= 0)) return;
	if (num > m_BtnNum - inx) num = m_BtnNum - inx;

	m_BtnNum -= num;
	if (IsValid())
	{
		inx += num;
		for (; num > 0; num--)
		{
			inx--;
			::SendMessage(m_Handle, TB_DELETEBUTTON, inx, 0);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// enable button (using command identifier)

void CToolBar::EnableBtn(int id, BOOL enable)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, TB_ENABLEBUTTON, id, enable);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// check button (using command identifier)

void CToolBar::CheckBtn(int id, BOOL check)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, TB_CHECKBUTTON, id, check);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// add control to tooltip

void CToolBar::AddToolTip(CChildWindow* w, int id)
{
	w->SetId(id);
	TOOLINFO ti;
	memset(&ti, 0, sizeof(ti));
	ti.cbSize = sizeof(ti);
	ti.uFlags = TTF_SUBCLASS | TTF_IDISHWND;
	ti.hwnd = m_Handle;
	ti.uId = (UINT_PTR)w->Handle();
	ti.lpszText = LPSTR_TEXTCALLBACK;
	::SendMessage(m_ToolTip, TTM_ADDTOOL, 0, (LPARAM)&ti);
}

///////////////////////////////////////////////////////////////////////////////
// delete control from tooltip

void CToolBar::DelToolTip(CChildWindow* w)
{
	TOOLINFO ti;
	memset(&ti, 0, sizeof(ti));
	ti.cbSize = sizeof(ti);
	ti.uFlags = TTF_SUBCLASS | TTF_IDISHWND;
	ti.hwnd = m_Handle;
	ti.uId = (UINT_PTR)w->Handle();
	::SendMessage(m_ToolTip, TTM_DELTOOL, 0, (LPARAM)&ti);
}
