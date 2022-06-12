
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Child Window                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

BOOL		CreateChildVisible = TRUE;	// create window child items visible

// next identifier
int		CChildWindow::m_IDNext = 25000;

// default parent window (if parent = NULL)
CWindow* DefParentWin = NULL;

///////////////////////////////////////////////////////////////////////////////
// constructor

CChildWindow::CChildWindow()
{
	// window type
	m_Type = WINTYPE_CHILD;

	// window item identifier
	m_Id = m_IDNext++;
}

///////////////////////////////////////////////////////////////////////////////
// get window item identifier

int CChildWindow::GetId()
{
	if (IsValid()) m_Id = (int)GetLong(GWL_ID);
	return m_Id;
}

///////////////////////////////////////////////////////////////////////////////
// set window item identifier

void CChildWindow::SetId(int id, BOOL update /*= FALSE*/)
{
	if ((id != m_Id) || update)
	{
		m_Id = id;
		if (IsValid())
		{
			FillingOn();
			SetLong(GWL_ID, id);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// create child window (returns FALSE on error)

BOOL CChildWindow::CreateChild(DWORD exstyle, const CText& classname,
	const CText& text, DWORD style, int x, int y, int w, int h,
	CWindow* parent /*= NULL*/)
{
	if (CreateChildVisible) style |= WS_VISIBLE;
	if (parent == NULL) parent = DefParentWin;

	BOOL res = CreateWin(exstyle, classname, text, style|WS_CHILD,
											x, y, w, h, parent, (HMENU)(INT_PTR)m_Id);
	if (res) SetFont(FontDefault);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// init dialog item (existing in dialog window)

void CChildWindow::InitDlg(int id, CWindow* parent)
{
	m_Parent = parent;
	m_Id = id;
	m_Handle = ::GetDlgItem(((parent == NULL) ? NULL : parent->Handle()), id);
	m_Visible = TRUE;
	m_Enabled = TRUE;
	UpdateRect();
	GetEnabled();
	GetText();
}

///////////////////////////////////////////////////////////////////////////////
// set dialog item border

void CChildWindow::SetBorder(BORDER border)
{
	// get style
	long style = GetStyle();
	long exstyle = GetExStyle();

	// reset flags
	style &= ~(WS_BORDER | WS_DLGFRAME | WS_THICKFRAME);
	exstyle &= ~(WS_EX_CLIENTEDGE | WS_EX_STATICEDGE | WS_EX_DLGMODALFRAME |
					WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW);

	switch (border)
	{
	case BORDER_HALFSUNK:	// half sunken (1 point)
		exstyle |= WS_EX_STATICEDGE;
		break;

	case BORDER_SUNKEN:		// sunken (2 points)
		style |= WS_BORDER;
		exstyle |= WS_EX_CLIENTEDGE;
		break;

	case BORDER_DBLSUNK:	// doubly sunken (4 points)
		style |= WS_BORDER;
		exstyle |= WS_EX_STATICEDGE | WS_EX_CLIENTEDGE;
		break;

	case BORDER_LINE:		// line (1 point)
		style |= WS_BORDER;
		break;

	case BORDER_LINESUNK:	// line and half sunken (2 points)
		style |= WS_BORDER;
		exstyle |= WS_EX_STATICEDGE;
		break;

	case BORDER_RAISED:		// raised (2 points)
		exstyle |= WS_EX_DLGMODALFRAME;
		break;

	case BORDER_BUMP:		// bumped (raised and sunken, 5 points)
		style |= WS_BORDER;
		exstyle |= WS_EX_CLIENTEDGE | WS_EX_DLGMODALFRAME;
		break;

	//case BORDER_NONE:		// no border
	default:
		break;
	}

	// set new style
	SetStyle(style);
	SetExStyle(exstyle);
	UpdateFrame();
}

///////////////////////////////////////////////////////////////////////////////
// get dialog item border

BORDER CChildWindow::GetBorder()
{
	long style = GetStyle();
	long exstyle = GetExStyle();

	if (style & WS_BORDER)
		if (exstyle & WS_EX_CLIENTEDGE)
			if (exstyle & WS_EX_STATICEDGE)
				return BORDER_DBLSUNK;	// doubly sunken (4 points)
			else
				if (exstyle & WS_EX_DLGMODALFRAME)
					return BORDER_BUMP;	// bumped (raised and sunken, 5 points)
				else
					return BORDER_SUNKEN; // sunken (2 points)
		else
			if (exstyle & WS_EX_STATICEDGE)
				return BORDER_LINESUNK;	// line and half sunken (2 points)
			else
				return BORDER_LINE;		// line (1 point)
	else
		if (exstyle & WS_EX_STATICEDGE)
			return BORDER_HALFSUNK;		// half sunken (1 point)
		else
			if (exstyle & WS_EX_DLGMODALFRAME)
				return BORDER_RAISED;	// raised (2 points)
			else
				return BORDER_NONE;		// no border
}

///////////////////////////////////////////////////////////////////////////////
// update label from resource (separated with "|")

void CChildWindow::UpdateLabel()
{
	if (IsValid())
	{
		CText txt;
		txt.Load(m_Id);
		if (txt.IsNotEmpty())
		{
			int pos = txt.Find(_T('|'));
			if (pos > 0) txt.DelToEnd(pos);
			SetText(txt);
		}
	}
}
