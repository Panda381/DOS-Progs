
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Combo Box                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText ComboClass(_T("ComboBox"));

// default width and height of drop-down list box
int		DefDropListW = 100;
int		DefDropListH = 100;

// default width and height of combo box
int		DefComboBoxW = 100;
int		DefComboBoxH = 100;

// default width and height of combo list
int		DefComboListW = 100;
int		DefComboListH = 100;

///////////////////////////////////////////////////////////////////////////////
// constructor

CComboBase::CComboBase()
{
	// number of entries in the list
	m_ItemNum = 0;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// get number of entries in the list

int CComboBase::GetItemNum()
{
	if (IsValid()) m_ItemNum = (int)::SendMessage(m_Handle, CB_GETCOUNT, 0, 0);
	if (m_ItemNum < 0) m_ItemNum = 0;
	return m_ItemNum;
}

///////////////////////////////////////////////////////////////////////////////
// get combo box info (returns FALSE on error)

BOOL CComboBase::GetInfo(COMBOBOXINFO* info)
{
	int res = FALSE;
	if (IsValid())
	{
		info->cbSize = sizeof(COMBOBOXINFO);
		res = ::GetComboBoxInfo(m_Handle, info);
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get coordinates of edit box (return FALSE on error)

BOOL CComboBase::GetEditRect(CRect* rc)
{
	BOOL res = FALSE;
	if (IsValid())
	{
		COMBOBOXINFO info;
		res = GetInfo(&info);
		if (!res) return FALSE;
		*rc = info.rcItem;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get handle of drop-down list (return NULL on error)

HWND CComboBase::GetDropHWND()
{
	HWND res = NULL;
	if (IsValid())
	{
		COMBOBOXINFO info;
		if (GetInfo(&info)) res = info.hwndList;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get drop-down list screen coordinates (returns FALSE on error)

BOOL CComboBase::GetDropRect(CRect* rc)
{
	int res = FALSE;
	if (IsValid())
		res = (int)::SendMessage(m_Handle, CB_GETDROPPEDCONTROLRECT, 0, (LPARAM)rc);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// add text into list (returns index of new entry or -1,-2 on error)

int CComboBase::Add(LPCTSTR text)
{
	int res = -1;
	if (IsValid())
	{
		FillingOn();
		res = (int)::SendMessage(m_Handle, CB_ADDSTRING, 0, (LPARAM)text);
		FillingOff();
		if (res >= 0) m_ItemNum++;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// add multiple items (separated with "|", returns last index or -1,-2)

int CComboBase::AddMulti(const CTextList& list)
{
	int res = -1;
	for (int i = 0; i < list.Num(); i++)
	{
		res = Add(list[i]);
		if (res < 0) return res;
	}
	return res;
}

int CComboBase::AddMulti(const CText& txt)
{
	CTextList list;
	if (!list.Split(txt, _T('|'))) return -1;
	return AddMulti(list);
}

int CComboBase::AddMulti(int id)
{
	CText txt;
	txt.Load(id);
	return AddMulti(txt);
}

///////////////////////////////////////////////////////////////////////////////
// insert text into list at given position, -1=end of list
//	(returns index of new entry or -1,-2 on error)

int CComboBase::Ins(LPCTSTR text, int inx /*= -1*/)
{
	int res = -1;
	if (IsValid())
	{
		FillingOn();
		res = (int)::SendMessage(m_Handle,CB_INSERTSTRING,(WPARAM)inx,(LPARAM)text);
		FillingOff();
		if (res >= 0) m_ItemNum++;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// delete entry

void CComboBase::Del(int inx)
{
	if (InxIsValid(inx) && IsValid())
	{
		FillingOn();
		int res = (int)::SendMessage(m_Handle, CB_DELETESTRING, (WPARAM)inx, 0);
		FillingOff();
		if (res >= 0) m_ItemNum = res;
	}
}

///////////////////////////////////////////////////////////////////////////////
// delete all entries

void CComboBase::DelAll()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_RESETCONTENT, 0, 0);
		FillingOff();
		m_ItemNum = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// get selected entry (-1 = none)

int CComboBase::GetSelect()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, CB_GETCURSEL, 0, 0);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// set selected entry (-1 = none)

void CComboBase::SetSelect(int inx /*= -1*/)
{
	if (IsValid())
	{
		if (!InxIsValid(inx)) inx = -1;
		if (inx != GetSelect())
		{
			FillingOn();
			::SendMessage(m_Handle, CB_SETCURSEL, (WPARAM)inx, 0);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// init dialog item (existing in dialog window)

void CComboBase::InitDlg(int id, CWindow* parent)
{
	CChildWindow::InitDlg(id, parent);
	GetItemNum();
}

///////////////////////////////////////////////////////////////////////////////
// get user data of an entry (returns (void*)-1 on error)

void* CComboBase::GetData(int inx)
{
	void* res = (void*)-1;
	if (InxIsValid(inx) && IsValid())
		res = (void*)::SendMessage(m_Handle, CB_GETITEMDATA, (WPARAM)inx, 0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set user data of an entry (inx = -1 all entries)

void CComboBase::SetData(void* data, int inx /*= -1*/)
{
	if ((InxIsValid(inx) || (inx == -1)) && IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SETITEMDATA, (WPARAM)inx, (LPARAM)data);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// find entry in the list (not case sensitive, start = previous entry,
// returns -1 = not found)

int CComboBase::Find(LPCTSTR text, int start /*= -1*/)
{
	if (IsValid()) return (int)::SendMessage(m_Handle, CB_FINDSTRINGEXACT,
												(WPARAM)start, (LPARAM)text);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// find entry in the list starting with substring (not case sensitive,
// start = previous entry, returns -1 = not found)

int CComboBase::FindSub(LPCTSTR text, int start /*= -1*/)
{
	if (IsValid()) return (int)::SendMessage(m_Handle, CB_FINDSTRING,
												(WPARAM)start, (LPARAM)text);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// line height in pixels

int CComboBase::GetItemHeight()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, CB_GETITEMHEIGHT, 0, 0);
	return 0;
}

void CComboBase::SetItemHeight(int height /*= 14*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SETITEMHEIGHT, 0, (LPARAM)height);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// selection field height (in pixels)

int CComboBase::GetEditHeight()
{
	if (IsValid())
		return (int)::SendMessage(m_Handle, CB_GETITEMHEIGHT, (WPARAM)-1, 0);
	return 0;
}

void CComboBase::SetEditHeight(int height /*= 16*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SETITEMHEIGHT, (WPARAM)-1, (LPARAM)height);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get length of text of entry (returns 0 on error)

int CComboBase::GetItemLength(int inx)
{
	int res = 0;
	if (IsValid() && InxIsValid(inx))
	{
		res = (int)::SendMessage(m_Handle, CB_GETLBTEXTLEN, (WPARAM)inx, 0);
		if (res < 0) res = 0;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get text of entry (returns empty text on error)

CText CComboBase::GetItemText(int inx)
{
	CText txt;
	if (IsValid() && InxIsValid(inx))
	{
		int len = GetItemLength(inx);
		if (len > 0)
		{
			if (txt.SetLength(len))
			{
				len = (int)::SendMessage(m_Handle, CB_GETLBTEXT, (WPARAM)inx,
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
// get index of first visible entry (if list box is dropped down)

int CComboBase::FirstVisible()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, CB_GETTOPINDEX, 0, 0);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// set index of first visible entry (if list box is dropped down)

void CComboBase::SetFirstVisible(int inx)
{
	if (IsValid()) ::SendMessage(m_Handle, CB_SETTOPINDEX, (WPARAM)inx, 0);
}

///////////////////////////////////////////////////////////////////////////////
// find and select item starting with substring (not case sensitive,
// start = previous entry, returns -1 = not found)

int CComboBase::SelectSub(LPCTSTR text, int start /*= -1*/)
{
	if (IsValid()) return (int)::SendMessage(m_Handle, CB_SELECTSTRING,
												(WPARAM)start, (LPARAM)text);
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CDropList::CDropList()
{
	// window type
	m_Type = WINTYPE_DROPLIST;
}

///////////////////////////////////////////////////////////////////////////////
// create list box (returns FALSE on error)

BOOL CDropList::CreateLst(int x, int y, int w /*= 0*/, int h /*= 0*/,
		BOOL sort /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_ItemNum = 0;
	if (w == 0) w = DefDropListW;
	if (h == 0) h = DefDropListH;
	return CreateChild(0, ComboClass, EmptyText, CBS_AUTOHSCROLL |
		CBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_GROUP | WS_TABSTOP |
		CBS_DROPDOWNLIST | (sort ? CBS_SORT  : 0), x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// get coordinates of button in combo box (return FALSE on error)

BOOL CDropList::GetButtonRect(CRect* rc)
{
	BOOL res = FALSE;
	if (IsValid())
	{
		COMBOBOXINFO info;
		res = GetInfo(&info);
		if (!res) return FALSE;
		*rc = info.rcButton;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// check, if list box is dropped down

BOOL CDropList::IsDropped()
{
	int res = FALSE;
	if (IsValid())
		res = (int)::SendMessage(m_Handle, CB_GETDROPPEDSTATE, 0, 0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set drop-down list box

void CDropList::DropDown(BOOL drop /*= TRUE*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SHOWDROPDOWN, (WPARAM)drop, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get minimum dropped width (0 = minimum, returns -1 on error)

int CDropList::DroppedWidth()
{
	int res = -1;
	if (IsValid())
		res = (int)::SendMessage(m_Handle, CB_GETDROPPEDWIDTH, 0, 0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set minimum dropped width (0 = minimum, returns -1 on error)

void CDropList::SetDroppedWidth(int width /*= 0*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SETDROPPEDWIDTH, (WPARAM)width, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CComboBox::CComboBox()
{
	// window type
	m_Type = WINTYPE_COMBOBOX;
}

///////////////////////////////////////////////////////////////////////////////
// create combo box (returns FALSE on error)

BOOL CComboBox::CreateLst(int x, int y, int w /*= 0*/, int h /*= 0*/,
		BOOL sort /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_ItemNum = 0;
	if (w == 0) w = DefComboBoxW;
	if (h == 0) h = DefComboBoxH;
	return CreateChild(0, ComboClass, EmptyText, CBS_AUTOHSCROLL |
		CBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_GROUP | WS_TABSTOP |
		CBS_DROPDOWN | (sort ? CBS_SORT  : 0), x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// get coordinates of button in combo box (return FALSE on error)

BOOL CComboBox::GetButtonRect(CRect* rc)
{
	BOOL res = FALSE;
	if (IsValid())
	{
		COMBOBOXINFO info;
		res = GetInfo(&info);
		if (!res) return FALSE;
		*rc = info.rcButton;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get handle of edit box (return NULL on error)

HWND CComboBox::GetEditHWND()
{
	HWND res = NULL;
	if (IsValid())
	{
		COMBOBOXINFO info;
		if (GetInfo(&info)) res = info.hwndItem;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// check, if list box is dropped down

BOOL CComboBox::IsDropped()
{
	int res = FALSE;
	if (IsValid())
		res = (int)::SendMessage(m_Handle, CB_GETDROPPEDSTATE, 0, 0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set drop-down list box

void CComboBox::DropDown(BOOL drop /*= TRUE*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SHOWDROPDOWN, (WPARAM)drop, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get minimum dropped width (0 = minimum, returns -1 on error)

int CComboBox::DroppedWidth()
{
	int res = -1;
	if (IsValid())
		res = (int)::SendMessage(m_Handle, CB_GETDROPPEDWIDTH, 0, 0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set minimum dropped width (0 = minimum, returns -1 on error)

void CComboBox::SetDroppedWidth(int width /*= 0*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SETDROPPEDWIDTH, (WPARAM)width, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get current edit selection (start = -1 nothing, end = -1 all)

void CComboBox::GetEditSel(int* start /*= NULL*/, int* end /*= NULL*/)
{
	if (start != NULL) *start = 0;
	if (end != NULL) *end = 0;
	if (IsValid())
		::SendMessage(m_Handle, CB_GETEDITSEL, (WPARAM)start, (LPARAM)end);
}

int CComboBox::GetSelStart()
{
	int start;
	GetEditSel(&start, NULL);
	return start;
}

int CComboBox::GetSelEnd()
{
	int end;
	GetEditSel(NULL, &end);
	return end;
}

///////////////////////////////////////////////////////////////////////////////
// set edit selection (start=-1 nothing, end=-1 all)

void CComboBox::SetEditSel(int start, int end)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SETEDITSEL, 0, MAKELPARAM(start, end));
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set text limitation of edit box (0=unlimited)

void CComboBox::SetLimitText(int num /*= 0*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_LIMITTEXT, (WPARAM)num, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CComboList::CComboList()
{
	// window type
	m_Type = WINTYPE_COMBOLIST;
}

///////////////////////////////////////////////////////////////////////////////
// create combo list (returns FALSE on error)

BOOL CComboList::CreateLst(int x, int y, int w /*= 0*/, int h /*= 0*/,
		BOOL sort /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_ItemNum = 0;
	if (w == 0) w = DefComboListW;
	if (h == 0) h = DefComboListH;
	return CreateChild(0, ComboClass, EmptyText, CBS_AUTOHSCROLL |
		CBS_NOINTEGRALHEIGHT | WS_VSCROLL | WS_GROUP | WS_TABSTOP |
		CBS_SIMPLE | (sort ? CBS_SORT  : 0), x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// get handle of edit box (return NULL on error)

HWND CComboList::GetEditHWND()
{
	HWND res = NULL;
	if (IsValid())
	{
		COMBOBOXINFO info;
		if (GetInfo(&info)) res = info.hwndItem;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get current edit selection (start = -1 nothing, end = -1 all)

void CComboList::GetEditSel(int* start /*= NULL*/, int* end /*= NULL*/)
{
	if (start != NULL) *start = 0;
	if (end != NULL) *end = 0;
	if (IsValid())
		::SendMessage(m_Handle, CB_GETEDITSEL, (WPARAM)start, (LPARAM)end);
}

int CComboList::GetSelStart()
{
	int start;
	GetEditSel(&start, NULL);
	return start;
}

int CComboList::GetSelEnd()
{
	int end;
	GetEditSel(NULL, &end);
	return end;
}

///////////////////////////////////////////////////////////////////////////////
// set edit selection (start=-1 nothing, end=-1 all)

void CComboList::SetEditSel(int start, int end)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_SETEDITSEL, 0, MAKELPARAM(start, end));
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set text limitation of edit box (0=unlimited)

void CComboList::SetLimitText(int num /*= 0*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, CB_LIMITTEXT, (WPARAM)num, 0);
		FillingOff();
	}
}
