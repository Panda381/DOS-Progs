
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                    Tabs                                   //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText TabsClass(_T("SysTabControl32"));

///////////////////////////////////////////////////////////////////////////////
// constructor

CTabs::CTabs()
{
	// window type
	m_Type = WINTYPE_TABS;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set tab text

void CTabs::SetItemText(const CText& text, int inx, BOOL update /*= FALSE*/)
{
	if (InxIsValid(inx) && (update || (text != ItemText(inx))))
	{
		m_ItemList[inx] = text;
		if (IsValid())
		{
			FillingOn();
			TCITEM tc;
			tc.mask = TCIF_TEXT;
			tc.pszText = (LPTSTR)(LPCTSTR)text;
			::SendMessage(m_Handle, TCM_SETITEM, inx, (LPARAM)&tc);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// create tab control

BOOL CTabs::CreateTabs(int x, int y, int w, int h, CWindow* parent /*= NULL*/)
{
	m_ItemList.DelAll();
	return CreateChild(0, TabsClass, EmptyText, WS_CLIPSIBLINGS | WS_GROUP |
		WS_TABSTOP, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// insert new tab (-1=last tab, returns index of new tab or -1 on error)

int CTabs::Ins(const CText& text, int inx /*= -1*/)
{
	int res = -1;
	if (IsValid())
	{
		if (!InxIsValid(inx)) inx = ItemNum();
		FillingOn();
		TCITEM tc;
		tc.mask = TCIF_TEXT;
		tc.pszText = (LPTSTR)(LPCTSTR)text;
		res = (int)::SendMessage(m_Handle, TCM_INSERTITEM, inx, (LPARAM)&tc);
		if (res >= 0) m_ItemList.Insert(res, text);
		FillingOff();
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// delete all tabs

void CTabs::DelAll()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, TCM_DELETEALLITEMS, 0, 0);
		FillingOff();
	}
	m_ItemList.DelAll();
}

