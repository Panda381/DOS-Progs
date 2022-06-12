
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  List View                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText ListViewClass(_T("SysListView32"));

// default width and height of list view
int		DefListViewW = 150;
int		DefListViewH = 100;

// LVM_HITTEST, LVM_GETSUBITEMRECT
/*
public FormMain()
{
    editbox.Parent = listView;
    editbox.Hide();
    editbox.LostFocus += new EventHandler(editbox_LostFocus);
    listView.MouseDoubleClick += new MouseEventHandler(listView_MouseDoubleClick);
    listView.FullRowSelect = true;
}

private void listView_MouseDoubleClick(object sender, MouseEventArgs e)
{
    hitinfo = listView.HitTest(e.X, e.Y);
    editbox.Bounds = hitinfo.SubItem.Bounds;
    editbox.Text = hitinfo.SubItem.Text;
    editbox.Focus();
    editbox.Show();
}

void editbox_LostFocus(object sender, EventArgs e)
{
    hitinfo.SubItem.Text = editbox.Text;
    editbox.Hide();
}
*/

///////////////////////////////////////////////////////////////////////////////
// constructor

CListView::CListView()
{
	// window type
	m_Type = WINTYPE_LISTVIEW;

	// number of columns
	m_ColNum = 0;

	// descriptor of columns
	m_ColDesc = NULL;

	// size of descriptor of columns
	m_ColMax = 0;

	// number of entries in the list
	m_ItemNum = 0;

	// can accept focus
	m_CanFocus = TRUE;

	// selected row (-1=none)
	m_Select = -1;
}

CListView::~CListView()
{
	free(m_ColDesc);
}

///////////////////////////////////////////////////////////////////////////////
// get number of columns

int CListView::GetColNum()
{
	m_ColNum = 0;
	if (IsValid())
	{
		for (; m_ColNum < 200; m_ColNum++)
			if (GetColAlign(m_ColNum) < 0) break;
		if (m_ColNum == 200) m_ColNum = 0;
	}
	return m_ColNum;
}

///////////////////////////////////////////////////////////////////////////////
// get number of entries in the list

int CListView::GetItemNum()
{
	m_ItemNum = 0;
	if (IsValid())
	{
		m_ItemNum = (int)::SendMessage(m_Handle, LVM_GETITEMCOUNT, 0, 0);
		if (m_ItemNum < 0) m_ItemNum = 0;
	}
	return m_ItemNum;
}

///////////////////////////////////////////////////////////////////////////////
// get first visible row

int CListView::GetFirstVisible()
{
	LVHITTESTINFO lvi;
	lvi.iItem = 0;
	if (IsValid())
	{
		lvi.pt.x = 2;
		lvi.pt.y = 2;
		::SendMessage(Handle(), LVM_HITTEST, 0, (LPARAM)&lvi);
	}
	return lvi.iItem;
}

///////////////////////////////////////////////////////////////////////////////
// get row height (need valid item 0)

int CListView::GetRowHeight()
{
	int h = 0;
	if (IsValid())
	{
		RECT rc;
		rc.left = LVIR_BOUNDS;
		if (::SendMessage(m_Handle, LVM_GETITEMRECT, 0, (LPARAM)&rc))
			h = rc.bottom - rc.top;
	}
	return h;
}

///////////////////////////////////////////////////////////////////////////////
// create iconed list view (returns FALSE on error)

BOOL CListView::CreateIco(int x, int y, int w /*= 0*/, int h /*= 0*/,
					BOOL flat /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_ColNum = 0;
	m_ItemNum = 0;
	if (w == 0) w = DefListViewW;
	if (h == 0) h = DefListViewH;
	BOOL res = CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), ListViewClass, EmptyText,
		WS_GROUP | WS_TABSTOP | (flat ? WS_BORDER : 0) | LVS_ICON | LVS_AUTOARRANGE | LVS_SHOWSELALWAYS | LVS_SINGLESEL,
		x, y, w, h, parent);

	if (res)
	{
		FillingOn();
		::SendMessage(m_Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 
			LVS_EX_BORDERSELECT, LVS_EX_BORDERSELECT);
		FillingOff();
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// create small icon list view (returns FALSE on error)

BOOL CListView::CreateSmall(int x, int y, int w /*= 0*/, int h /*= 0*/,
					BOOL flat /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_ColNum = 0;
	m_ItemNum = 0;
	if (w == 0) w = DefListViewW;
	if (h == 0) h = DefListViewH;
	return CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), ListViewClass, EmptyText,
		WS_GROUP | WS_TABSTOP | (flat ? WS_BORDER : 0) | LVS_SMALLICON | LVS_SHOWSELALWAYS | LVS_SINGLESEL,
		x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// create listed list view (returns FALSE on error)

BOOL CListView::CreateLst(int x, int y, int w /*= 0*/, int h /*= 0*/,
					BOOL flat /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	m_ColNum = 0;
	m_ItemNum = 0;
	if (w == 0) w = DefListViewW;
	if (h == 0) h = DefListViewH;
	return CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), ListViewClass, EmptyText,
		WS_GROUP | WS_TABSTOP | (flat ? WS_BORDER : 0) | LVS_LIST | LVS_SHOWSELALWAYS
		| LVS_SINGLESEL, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// create report list view (returns FALSE on error)

BOOL CListView::CreateRep(int x, int y, int w /*= 0*/, int h /*= 0*/,
	BOOL flat /*= FALSE*/, BOOL header /*= TRUE*/, BOOL grid /*= TRUE*/, CWindow* parent /*= NULL*/)
{
	m_ColNum = 0;
	m_ItemNum = 0;
	m_Select = -1;
	if (w == 0) w = DefListViewW;
	if (h == 0) h = DefListViewH;
	BOOL res = CreateChild((flat?0:WS_EX_CLIENTEDGE), ListViewClass, EmptyText,
		WS_GROUP | WS_TABSTOP | (flat ? WS_BORDER : 0) | LVS_REPORT |
		LVS_SHOWSELALWAYS | LVS_SINGLESEL | (header ? 0 : LVS_NOCOLUMNHEADER), x, y, w, h, parent);

	if (res)
	{
		FillingOn();
		::SendMessage(m_Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 
			LVS_EX_GRIDLINES | LVS_EX_FLATSB | LVS_EX_FULLROWSELECT,
			(grid ? LVS_EX_GRIDLINES : 0) | (flat ? LVS_EX_FLATSB:0) | LVS_EX_FULLROWSELECT);
		FillingOff();
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// add columns in report view (from given column position)

void CListView::AddCol(LVADDCOLUMN* col, int num /*= 1*/, int pos /*=BIGINT*/)
{
	if ((num <= 0) || !IsValid()) return;

	// filling ON
	FillingOn();

	// check columnt position
	if (pos > m_ColNum) pos = m_ColNum;

	// resize column descriptor
	int max = m_ColNum + num;
	if (m_ColMax < max)
	{
		LVADDCOLUMN* d = (LVADDCOLUMN*)realloc(m_ColDesc, max*sizeof(LVADDCOLUMN));
		if (d == NULL) return;
		m_ColDesc = d;
		for (; m_ColMax < max; m_ColMax++)
		{
			new (&d[m_ColMax].text) CText;
		}
	}

	// move items
	int id = max-1;
	int is = id - num;

	for (; is >= pos;)
	{
		m_ColDesc[id] = m_ColDesc[is];
		id--;
		is--;
	}

	// add columns to descriptor
	is = num-1;
	id = pos + num - 1;
	for (; is >= 0;)
	{
		m_ColDesc[id] = col[is];
		id--;
		is--;
	}

	// column descriptor
	LVCOLUMN lvc;
	lvc.mask = LVCF_FMT | LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM;

	// insert fake column (aligned left)
	BOOL fake = FALSE;
	if (pos <= 0)
	{
		lvc.fmt = LVCFMT_LEFT;
		lvc.cx = 0;
		lvc.pszText = NULL;
		lvc.iSubItem = -1;
		fake = (::SendMessage(m_Handle, LVM_INSERTCOLUMN, 0, (LPARAM)&lvc)>=0);
		pos = 1;
	}

	// insert columns
	for (int i = 0; i < num; i++)
	{
		lvc.fmt = col[i].align;
		lvc.cx = col[i].width;
		lvc.pszText = (LPTSTR)(LPCTSTR)col[i].text.DataData();
		lvc.iSubItem = pos;
		if (::SendMessage(m_Handle, LVM_INSERTCOLUMN, pos, (LPARAM)&lvc) >= 0)
			m_ColNum++;
		pos++;
	}

	// delete fake column
	if (fake) ::SendMessage(m_Handle, LVM_DELETECOLUMN, 0, 0);

	// filling OFF
	FillingOff();

	Redraw();
}

///////////////////////////////////////////////////////////////////////////////
// delete columns in report view (from given column position)

void CListView::DelCol(int pos, int num /*= 1*/)
{
	if (IsValid())
	{
		FillingOn();

		if (pos >= m_ColNum) pos = m_ColNum-1;
		if (pos < 0) pos = 0;
		if (num > m_ColNum - pos) num = m_ColNum - pos;
		pos += num;

		for (; num > 0; num--)
		{
			pos--;
			if (::SendMessage(m_Handle, LVM_DELETECOLUMN,pos,0))
			{
				m_ColNum--;
				int i;
				for (i = pos; i < m_ColNum; i++) m_ColDesc[i] = m_ColDesc[i+1];
			}
		}
		FillingOff();

		Redraw();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get column info (returns FALSE on error)

BOOL CListView::GetCol(LVADDCOLUMN* col, int pos)
{
	BOOL res = FALSE;
	if (IsValid())
	{
		TCHAR* buf = (TCHAR*)malloc(260*sizeof(TCHAR));
		if (buf == NULL) return FALSE;

		LVCOLUMN lvc;
		lvc.mask = LVCF_FMT | LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM;
		lvc.fmt = 0;
		lvc.cx = 0;
		lvc.pszText = buf;
		lvc.cchTextMax = 260;
		lvc.iSubItem = pos;
		res = (BOOL)::SendMessage(m_Handle, LVM_GETCOLUMN, pos, (LPARAM)&lvc);
		if (res)
		{
			col->align = lvc.fmt & (LVCFMT_LEFT|LVCFMT_CENTER|LVCFMT_RIGHT);
			col->width = lvc.cx;
			buf[259] = 0;
			col->text.Set(buf);
		}
		free(buf);
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// get column width (returns 0 on error)

int CListView::GetColWidth(int pos /*= 0*/)
{
	if (ColIsValid(pos) && IsValid())
		return (int)::SendMessage(m_Handle, LVM_GETCOLUMNWIDTH, pos, 0);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// get item rect (returns FALSE on error)

BOOL CListView::GetRowRect(int inx, RECT* rc)
{
	rc->left = LVIR_LABEL;
	return (BOOL)::SendMessage(Handle(), LVM_GETITEMRECT, inx, (LPARAM)rc);
}

BOOL CListView::GetCellRect(int inx, int col, RECT* rc)
{
	rc->top = col;
	rc->left = LVIR_LABEL;
	return (BOOL)::SendMessage(Handle(), LVM_GETSUBITEMRECT, inx, (LPARAM)rc);
}

///////////////////////////////////////////////////////////////////////////////
// get column align (returns LVCFMT_LEFT, LVCFMT_CENTER, LVCFMT_RIGHT,
// or -1 on error)

int CListView::GetColAlign(int pos)
{
	int align = -1;
	if (IsValid())
	{
		LVCOLUMN lvc;
		lvc.mask = LVCF_FMT | LVCF_SUBITEM;
		lvc.fmt = -1;
		lvc.iSubItem = pos;
		if (::SendMessage(m_Handle, LVM_GETCOLUMN, pos, (LPARAM)&lvc))
			align = lvc.fmt & LVCFMT_JUSTIFYMASK;
		else
			align = -1;
	}
	return align;
}

///////////////////////////////////////////////////////////////////////////////
// get column title

CText CListView::GetColTitle(int pos)
{
	LVADDCOLUMN col;
	GetCol(&col, pos);
	return col.text;
}

///////////////////////////////////////////////////////////////////////////////
// insert text entry into list (-1 = end of list)
//	(returns index of new entry or -1 on error)

int CListView::Ins(LPCTSTR text, int inx /*= -1*/)
{
	int res = -1;
	if (IsValid())
	{
		FillingOn();

		if ((DWORD)inx > (DWORD)m_ItemNum) inx = m_ItemNum;
		if (inx < 0) inx = 0;

		LVITEM lvi;
		lvi.mask = LVIF_STATE | LVIF_TEXT;
		lvi.iItem = inx;
		lvi.iSubItem = 0;
		lvi.state = 0;
		lvi.stateMask = 0;
		lvi.pszText = (LPTSTR)text;
		res = (int)::SendMessage(m_Handle, LVM_INSERTITEM, 0, (LPARAM)&lvi);
		if (res >= 0)
		{
			m_ItemNum++;
			if (m_Select >= inx) m_Select++;
		}

		FillingOff();
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// insert image entry into list (-1 = end of list)
//	(returns index of new entry or -1 on error)

int CListView::InsImg(int imginx, int inx /*= -1*/)
{
	int res = -1;
	if (IsValid())
	{
		FillingOn();

		if ((DWORD)inx > (DWORD)m_ItemNum) inx = m_ItemNum;
		if (inx < 0) inx = 0;

		LVITEM lvi;
		lvi.mask = LVIF_STATE | LVIF_IMAGE;
		lvi.iItem = inx;
		lvi.iSubItem = 0;
		lvi.state = 0;
		lvi.stateMask = 0;
		lvi.iImage = imginx;
		res = (int)::SendMessage(m_Handle, LVM_INSERTITEM, 0, (LPARAM)&lvi);
		if (res >= 0)
		{
			m_ItemNum++;
			if (m_Select >= inx) m_Select++;
		}

		FillingOff();
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// add multiple items (separated with "|", returns last index or -1 on error)

int CListView::AddMulti(const CTextList& list)
{
	int res = -1;
	for (int i = 0; i < list.Num(); i++)
	{
		res = Add(list[i]);
		if (res < 0) return res;
	}
	return res;
}

int CListView::AddMulti(const CText& txt)
{
	CTextList list;
	if (!list.Split(txt, _T('|'))) return -1;
	return AddMulti(list);
}

int CListView::AddMulti(int id)
{
	CText txt;
	txt.Load(id);
	return AddMulti(txt);
}

///////////////////////////////////////////////////////////////////////////////
// delete entry

void CListView::Del(int inx)
{
	if (IsValid() && ((DWORD)inx < (DWORD)m_ItemNum))
	{
		FillingOn();
		if (::SendMessage(m_Handle, LVM_DELETEITEM, inx, 0))
		{
			if ((m_Select > 0) && (m_Select > inx)) m_Select--;
			m_ItemNum--;
		}
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// delete all entries

void CListView::DelAll()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, LVM_DELETEALLITEMS, 0, 0);
		m_ItemNum = 0;
		FillingOff();
	}
	m_Select = -1;
}

///////////////////////////////////////////////////////////////////////////////
// set item text

void CListView::SetItemText(LPCTSTR text, int inx, int pos /*= 0*/)
{
	if (IsValid() && InxIsValid(inx) /*&& ColIsValid(pos)*/)
	{
		FillingOn();

		LVITEM lvi;
		lvi.mask = LVIF_TEXT; 
		lvi.iItem = inx;
		lvi.iSubItem = pos;
		lvi.pszText = (LPTSTR)text;
		::SendMessage(m_Handle, LVM_SETITEMTEXT, inx, (LPARAM)&lvi); 

		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get item text

CText CListView::GetItemText(int inx, int pos /*= 0*/)
{
	CText txt;
	if (IsValid() && InxIsValid(inx) /*&& ColIsValid(pos)*/)
	{
		TCHAR* buf = (TCHAR*)malloc(2048*sizeof(TCHAR));
		if (buf == NULL) return txt;

		LVITEM lvi;
		lvi.mask = LVIF_TEXT; 
		lvi.iItem = inx;
		lvi.iSubItem = pos;
		lvi.pszText = buf;
		lvi.cchTextMax = 2048;
		int n = (int)::SendMessage(m_Handle, LVM_GETITEMTEXT, inx, (LPARAM)&lvi);
		if (n > 0)
		{
			if (n > 2048) n = 2048;
			txt.Set(lvi.pszText, n);
		}
		free(buf);
	}
	return txt;
}

///////////////////////////////////////////////////////////////////////////////
// set item image (images need to be prepared using SetImageList)

void CListView::SetItemImg(int imginx, int inx, int pos /*= 0*/)
{
	if (IsValid() && InxIsValid(inx) /*&& ColIsValid(pos)*/)
	{
		FillingOn();

		LVITEM lvi;
		lvi.mask = LVIF_IMAGE; 
		lvi.stateMask = 0;
		lvi.iItem = inx;
		lvi.iSubItem = pos;
		lvi.iImage = imginx;
		::SendMessage(m_Handle, LVM_SETITEM, 0, (LPARAM)&lvi); 

		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// ensure entry visible

void CListView::EnsureVisible(int inx)
{
	if (IsValid() && ((DWORD)inx < (DWORD)m_ItemNum))
	{
		FillingOn();
		::SendMessage(m_Handle, LVM_ENSUREVISIBLE, inx, FALSE); 
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get first selected entry (-1 = none)

int CListView::GetSelect()
{
	m_Select = -1;
	if (IsValid())
	{
		m_Select = (int)::SendMessage(m_Handle, LVM_GETNEXTITEM, (WPARAM)-1,
							(LPARAM)MAKELPARAM((UINT)LVNI_SELECTED, 0));
	}
	return m_Select;
}

///////////////////////////////////////////////////////////////////////////////
// set selected entry (-1 = none)

void CListView::SetSelect(int inx /*= -1*/)
{
	if (IsValid())
	{
		if (!InxIsValid(inx)) inx = -1;
		if (inx != GetSelect())
		{
			FillingOn();
			LVITEM lvi;
			lvi.stateMask = LVIS_SELECTED | LVIS_FOCUSED;
			if (InxIsValid(inx))
			{
				lvi.state = LVIS_SELECTED | LVIS_FOCUSED;
				::SendMessage(m_Handle, LVM_SETITEMSTATE, inx, (LPARAM)&lvi);
			}
			else
			{
				inx = -1;
				lvi.state = 0;
				::SendMessage(m_Handle, LVM_SETITEMSTATE, (WPARAM)-1,
																(LPARAM)&lvi);
			}
			FillingOff();
			m_Select = inx;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// init dialog item (existing in dialog window)

void CListView::InitDlg(int id, CWindow* parent)
{
	CChildWindow::InitDlg(id, parent);
	GetItemNum();
	GetColNum();

	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 
			LVS_EX_GRIDLINES | LVS_EX_FULLROWSELECT,
			LVS_EX_GRIDLINES | LVS_EX_FULLROWSELECT);
		FillingOff();
	}
	GetSelect();
}

///////////////////////////////////////////////////////////////////////////////
// redraw range of items

void CListView::RedrawItems(int first, int last)
{
	if (IsValid())
	{
		::SendMessage(Handle(), LVM_REDRAWITEMS, first, last);
		Update();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set image list normal (returns previous image list - should be destroyed by caller)

HIMAGELIST CListView::SetImageList(HIMAGELIST img)
{
	if (IsValid())
	{
		return (HIMAGELIST)::SendMessage(Handle(), LVM_SETIMAGELIST, LVSIL_NORMAL, (LPARAM)img);
	}
	return NULL;
}

///////////////////////////////////////////////////////////////////////////////
// set image list small (returns previous image list - should be destroyed by caller)

HIMAGELIST CListView::SetImageListSmall(HIMAGELIST img)
{
	if (IsValid())
	{
		return (HIMAGELIST)::SendMessage(Handle(), LVM_SETIMAGELIST, LVSIL_SMALL, (LPARAM)img);
	}
	return NULL;
}
