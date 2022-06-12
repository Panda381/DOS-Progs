
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Simple List Box                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText ListBoxClass(_T("ListBox"));

// default width and height of list box
int		DefListBoxW = 100;
int		DefListBoxH = 100;

///////////////////////////////////////////////////////////////////////////////
// constructor

CListBoxBase::CListBoxBase()
{
	// number of entries in the list
	m_ItemNum = 0;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// get number of entries in the list

int CListBoxBase::GetItemNum()
{
	if (IsValid()) m_ItemNum = (int)::SendMessage(m_Handle, LB_GETCOUNT, 0, 0);
	if (m_ItemNum < 0) m_ItemNum = 0;
	return m_ItemNum;
}

///////////////////////////////////////////////////////////////////////////////
// add text into list (returns index of new entry or -1,-2 on error)

int CListBoxBase::Add(LPCTSTR text)
{
	int res = -1;
	if (IsValid())
	{
		FillingOn();
		res = (int)::SendMessage(m_Handle, LB_ADDSTRING, 0, (LPARAM)text);
		FillingOff();
		if (res >= 0) m_ItemNum++;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// add multiple items (separated with "|", returns last index or -1,-2)

int CListBoxBase::AddMulti(const CTextList& list)
{
	int res = -1;
	for (int i = 0; i < list.Num(); i++)
	{
		res = Add(list[i]);
		if (res < 0) return res;
	}
	return res;
}

int CListBoxBase::AddMulti(const CText& txt)
{
	CTextList list;
	if (!list.Split(txt, _T('|'))) return -1;
	return AddMulti(list);
}

int CListBoxBase::AddMulti(int id)
{
	CText txt;
	txt.Load(id);
	return AddMulti(txt);
}

///////////////////////////////////////////////////////////////////////////////
// insert text into list at given position, -1=end of list
//	(returns index of new entry or -1,-2 on error)

int CListBoxBase::Ins(LPCTSTR text, int inx /*= -1*/)
{
	int res = -1;
	if (IsValid())
	{
		FillingOn();
		res = (int)::SendMessage(m_Handle,LB_INSERTSTRING,(WPARAM)inx,(LPARAM)text);
		FillingOff();
		if (res >= 0) m_ItemNum++;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// delete entry

void CListBoxBase::Del(int inx)
{
	if (InxIsValid(inx) && IsValid())
	{
		FillingOn();
		int res = (int)::SendMessage(m_Handle, LB_DELETESTRING, (WPARAM)inx, 0);
		FillingOff();
		if (res >= 0) m_ItemNum = res;
	}
}

///////////////////////////////////////////////////////////////////////////////
// delete all entries

void CListBoxBase::DelAll()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, LB_RESETCONTENT, 0, 0);
		FillingOff();
		m_ItemNum = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// init dialog item (existing in dialog window)

void CListBoxBase::InitDlg(int id, CWindow* parent)
{
	CChildWindow::InitDlg(id, parent);
	GetItemNum();
}

///////////////////////////////////////////////////////////////////////////////
// get user data of an entry (returns (void*)-1 on error)

void* CListBoxBase::GetData(int inx)
{
	void* res = (void*)-1;
	if (InxIsValid(inx) && IsValid())
		res = (void*)::SendMessage(m_Handle, LB_GETITEMDATA, (WPARAM)inx, 0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set user data of an entry (inx = -1 all entries)

void CListBoxBase::SetData(void* data, int inx /*= -1*/)
{
	if ((InxIsValid(inx) || (inx == -1)) && IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, LB_SETITEMDATA, (WPARAM)inx, (LPARAM)data);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// find entry in the list (not case sensitive, start = previous entry,
// returns -1 = not found)

int CListBoxBase::Find(LPCTSTR text, int start /*= -1*/)
{
	if (IsValid()) return (int)::SendMessage(m_Handle, LB_FINDSTRINGEXACT,
												(WPARAM)start, (LPARAM)text);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// find entry in the list starting with substring (not case sensitive,
// start = previous entry, returns -1 = not found)

int CListBoxBase::FindSub(LPCTSTR text, int start /*= -1*/)
{
	if (IsValid()) return (int)::SendMessage(m_Handle, LB_FINDSTRING,
												(WPARAM)start, (LPARAM)text);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// line height in pixels

int CListBoxBase::GetItemHeight()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, LB_GETITEMHEIGHT, 0, 0);
	return 0;
}

void CListBoxBase::SetItemHeight(int height /*= 14*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, LB_SETITEMHEIGHT, 0, (LPARAM)height);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get entry client coordinates (returns FALSE on error)

BOOL CListBoxBase::GetItemRect(CRect* rc, int inx)
{
	BOOL res = FALSE;
	if (IsValid() && InxIsValid(inx))
	{
		FillingOn();
		res = ::SendMessage(m_Handle,LB_GETITEMRECT,(WPARAM)inx,(LPARAM)rc)>=0;
		FillingOff();
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get length of text of entry (returns 0 on error)

int CListBoxBase::GetItemLength(int inx)
{
	int res = 0;
	if (IsValid() && InxIsValid(inx))
	{
		res = (int)::SendMessage(m_Handle, LB_GETTEXTLEN, (WPARAM)inx, 0);
		if (res < 0) res = 0;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get text of entry (returns empty text on error)

CText CListBoxBase::GetItemText(int inx)
{
	CText txt;
	if (IsValid() && InxIsValid(inx))
	{
		int len = GetItemLength(inx);
		if (len > 0)
		{
			if (txt.SetLength(len))
			{
				len = (int)::SendMessage(m_Handle, LB_GETTEXT, (WPARAM)inx,
													(LPARAM)txt.DataData());
				if (len < 0)
					txt.Empty();
				else
					if (len != txt.Length()) txt.SetLength(len);
			}
		}
	}
	return txt;
}

///////////////////////////////////////////////////////////////////////////////
// get index of first visible entry

int CListBoxBase::FirstVisible()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, LB_GETTOPINDEX, 0, 0);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// set index of first visible entry

void CListBoxBase::SetFirstVisible(int inx)
{
	if (IsValid()) ::SendMessage(m_Handle, LB_SETTOPINDEX, (WPARAM)inx, 0);
}

///////////////////////////////////////////////////////////////////////////////
// get entry from client coordinates (-1 = not found)

int CListBoxBase::ItemFromCoord(int x, int y)
{
	int res = 0;
	if (IsValid())
	{
		res = (int)::SendMessage(m_Handle, LB_ITEMFROMPOINT, 0, MAKELPARAM(x,y));
		res = HIWORD(res) ? -1 : LOWORD(res);
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set tab stops (32 default)

void CListBoxBase::SetTabStops(int num, int* tabs)
{
	if (IsValid()) ::SendMessage(m_Handle, LB_SETTABSTOPS, num, (LPARAM)tabs);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CListBox::CListBox()
{
	// window type
	m_Type = WINTYPE_LISTBOX;
}

///////////////////////////////////////////////////////////////////////////////
// create list box (returns FALSE on error)

BOOL CListBox::CreateLst(int x, int y, int w /*= 0*/, int h /*= 0*/,
	BOOL flat /*= FALSE*/, BOOL sort /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_ItemNum = 0;
	if (w == 0) w = DefListBoxW;
	if (h == 0) h = DefListBoxH;
	return CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), ListBoxClass, EmptyText,
		WS_VSCROLL | LBS_HASSTRINGS | LBS_NOINTEGRALHEIGHT | LBS_NOTIFY |
		WS_GROUP | WS_TABSTOP | (flat ? WS_BORDER : 0) | (sort ? LBS_SORT : 0)
		| LBS_USETABSTOPS, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// get selected entry (-1 = none)

int CListBox::GetSelect()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, LB_GETCURSEL, 0, 0);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// set selected entry (-1 = none)

void CListBox::SetSelect(int inx /*= -1*/)
{
	if (IsValid())
	{
		if (!InxIsValid(inx)) inx = -1;
		if (inx != GetSelect())
		{
			FillingOn();
			::SendMessage(m_Handle, LB_SETCURSEL, (WPARAM)inx, 0);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// find and select item starting with substring (not case sensitive,
// start = previous entry, returns -1 = not found, only single-selection)

int CListBox::SelectSub(LPCTSTR text, int start /*= -1*/)
{
	if (IsValid()) return (int)::SendMessage(m_Handle, LB_SELECTSTRING,
												(WPARAM)start, (LPARAM)text);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CMultiList::CMultiList()
{
	// window type
	m_Type = WINTYPE_MULTILIST;
}

///////////////////////////////////////////////////////////////////////////////
// create list box (returns FALSE on error)

BOOL CMultiList::CreateLst(int x, int y, int w /*= 0*/, int h /*= 0*/,
	BOOL flat /*= FALSE*/, BOOL sort /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_ItemNum = 0;
	if (w == 0) w = DefListBoxW;
	if (h == 0) h = DefListBoxH;
	return CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), ListBoxClass, EmptyText,
		WS_VSCROLL | LBS_HASSTRINGS | LBS_NOINTEGRALHEIGHT | LBS_NOTIFY |
		WS_GROUP | WS_TABSTOP | (flat ? WS_BORDER : 0) | (sort ? LBS_SORT : 0)
		| LBS_EXTENDEDSEL | LBS_MULTIPLESEL | LBS_USETABSTOPS,
		x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// get entry with caret (-1 = none)

int CMultiList::GetSelect()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, LB_GETCARETINDEX, 0, 0);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// set entry with caret (-1 = none)

void CMultiList::SetSelect(int inx /*= -1*/)
{
	if (IsValid())
	{
		if (!InxIsValid(inx)) inx = -1;
		if (inx != GetSelect())
		{
			FillingOn();
			::SendMessage(m_Handle, LB_SETCARETINDEX, (WPARAM)inx, FALSE);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// get selection state of an entry

BOOL CMultiList::GetSel(int inx)
{
	if (IsValid() && InxIsValid(inx))
		return (BOOL)::SendMessage(m_Handle, LB_GETSEL, (WPARAM)inx, 0);
	return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// set selection state of an entry (-1=all entries)

void CMultiList::SetSel(BOOL sel, int inx /*= -1*/)
{
	if ((InxIsValid(inx) || (inx == -1)) && IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, LB_SETSEL, (WPARAM)sel, (LPARAM)inx);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// select range of items

void CMultiList::SelRange(BOOL sel, int first, int last)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, LB_SELITEMRANGE, (WPARAM)sel,
													MAKELPARAM(first, last));
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get number of selected entries

int CMultiList::GetSelCount()
{
	int res = 0;
	if (IsValid()) res = (int)::SendMessage(m_Handle, LB_GETSELCOUNT, 0, 0);
	if (res < 0) res = 0;
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get multi-selection list (returns malloc buffer, first integer = number
// of entries, following list of INT indices, NULL=no items, use free())

int* CMultiList::GetMultiSelList()
{
	int* buf = NULL;
	if (IsValid())
	{
		int n = GetSelCount();
		if (n > 0) buf = (int*)malloc((n+1)*sizeof(int));
		if (buf != NULL)
		{
			n = (int)::SendMessage(m_Handle, LB_GETSELITEMS, (WPARAM)n,
															(LPARAM)&buf[1]);
			buf[0] = n;
			if (n <= 0)
			{
				free(buf);
				buf = NULL;
			}
		}
	}
	return buf;
}
