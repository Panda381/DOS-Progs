
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Edit Box                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText EditClass(_T("Edit"));

// default width and height of edit box
int		DefEditW = 100;
int		DefEditH = 21;

///////////////////////////////////////////////////////////////////////////////
// constructor

CEdit::CEdit()
{
	// window type
	m_Type = WINTYPE_EDIT;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// create single line edit box (flat=not 3D, returns FALSE on error)
// special flags: 0, ES_NUMBER, ES_LOWERCASE, ES_UPPERCASE, ES_PASSWORD

BOOL CEdit::CreateSingle(int x,int y,int w /*=0*/,HALIGN halign/*=ALIGN_LEFT*/,
	BOOL flat /*= FALSE*/, int flags /*= 0*/, int h /*= 0*/,
	CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefEditW;
	if (h == 0) h = DefEditH;
	long style = ES_AUTOHSCROLL | /*ES_NOHIDESEL |*/ WS_GROUP | WS_TABSTOP | flags;
	switch (halign)
	{
	case HA_CENTER: style |= ES_CENTER; break;
	case HA_RIGHT: style |= ES_RIGHT; break;
	default: style |= ES_LEFT;
	}
	if (flat) style |= WS_BORDER;
	return CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), EditClass, EmptyText, style,
												x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// create multi line edit box (flat=not 3D, returns FALSE on error)

BOOL CEdit::CreateText(int x, int y, int w /*= 0*/, int h /*= 0*/,
							BOOL flat /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefEditW;
	if (h == 0) h = DefEditH;
	return CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), EditClass, EmptyText,
			ES_MULTILINE | ES_WANTRETURN | WS_GROUP | WS_TABSTOP |
			(flat ? WS_BORDER : 0) | WS_VSCROLL | ES_AUTOHSCROLL |
			ES_AUTOVSCROLL | ES_NOHIDESEL, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// create multi line edit box wrapping words
//  (flat=not 3D, returns FALSE on error)

BOOL CEdit::CreateWrap(int x, int y, int w /*= 0*/, int h /*= 0*/,
							BOOL flat /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefEditW;
	if (h == 0) h = DefEditH;
	return CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), EditClass, EmptyText,
			ES_MULTILINE | ES_WANTRETURN | WS_GROUP | WS_TABSTOP |
			(flat ? WS_BORDER : 0) | WS_VSCROLL | ES_AUTOVSCROLL |
			ES_NOHIDESEL, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// create small multi line edit box, limited by frame
//	(flat=not 3D, returns FALSE on error)

BOOL CEdit::CreateMemo(int x, int y, int w /*= 0*/, int h /*= 0*/,
							BOOL flat /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = DefEditW;
	if (h == 0) h = DefEditH;
	return CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), EditClass, EmptyText,
			ES_MULTILINE | ES_WANTRETURN | WS_GROUP | WS_TABSTOP |
			(flat ? WS_BORDER : 0) | ES_NOHIDESEL, x, y, w, h, parent);
}

///////////////////////////////////////////////////////////////////////////////
// enable edit box

void CEdit::Enable(BOOL enable, BOOL update /*= FALSE*/)
{
	if ((enable != m_Enabled) || update)
	{
		m_Enabled = enable;
		if (IsValid())
		{
			FillingOn();
			::SendMessage(m_Handle, EM_SETREADONLY, !enable, 0);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// set number into edit box

void CEdit::SetInt(int num)
{
	CText txt;
	txt.SetInt(num);
	SetText(txt);
}

void CEdit::SetNum(double num, int digits /*= 15*/)
{
	CText txt;
	txt.SetDouble(num, digits);
	SetText(txt);
}

///////////////////////////////////////////////////////////////////////////////
// get current selection (start=-1 nothing, end=-1 all)

void CEdit::GetSel(int* start /*= NULL*/, int* end /*= NULL*/)
{
	if (start != NULL) *start = 0;
	if (end != NULL) *end = 0;
	if (IsValid()) ::SendMessage(m_Handle,EM_GETSEL,(WPARAM)start,(LPARAM)end);
}

int CEdit::GetSelStart()
{
	int start;
	GetSel(&start, NULL);
	return start;
}

int CEdit::GetSelEnd()
{
	int end;
	GetSel(NULL, &end);
	return end;
}

///////////////////////////////////////////////////////////////////////////////
// set selection (start=-1 nothing, end=-1 all)

void CEdit::SetSel(int start, int end)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, EM_SETSEL, (WPARAM)start, (LPARAM)end);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// scroll edit to ensure caret visibility

void CEdit::EnsureVisible()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, EM_SCROLLCARET, 0, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get text limitation (0=unlimited)

int CEdit::GetLimitText()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, EM_GETLIMITTEXT, 0, 0);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// set text limitation (0=unlimited)

void CEdit::SetLimitText(int num /*= 0*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, EM_SETLIMITTEXT, (WPARAM)num, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// modification flag

BOOL CEdit::GetModify()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, EM_GETMODIFY, 0, 0);
	return 0;
}

void CEdit::SetModify(BOOL modify /*= TRUE*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, EM_SETMODIFY, (WPARAM)modify, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// replace selection or insert text at current position

void CEdit::ReplaceSel(LPCTSTR text, BOOL canundo /*= TRUE*/)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, EM_REPLACESEL, (WPARAM)canundo, (LPARAM)text);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// check if edit can undo last operation

BOOL CEdit::CanUndo()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, EM_CANUNDO, 0, 0);
	return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// clear undo buffer

void CEdit::ClearUndo()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, EM_EMPTYUNDOBUFFER, 0, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// undo last operation

void CEdit::Undo()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, EM_UNDO, 0, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// clear selection

void CEdit::Clear()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, WM_CLEAR, 0, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// copy selection into clipboard

void CEdit::Copy()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, WM_COPY, 0, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// cut selection into clipboard

void CEdit::Cut()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, WM_CUT, 0, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// paste text from clipboard

void CEdit::Paste()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, WM_PASTE, 0, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get character position (offset in text) from client coordinates

int CEdit::CharFromCoord(int x, int y)
{
	if (IsValid())
	{
		return LOWORD(::SendMessage(m_Handle, EM_CHARFROMPOS, 0,
															MAKELPARAM(x,y)));
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// get client coordinates of a character (-1=character with caret)

void CEdit::CoordFromChar(int* x /*=NULL*/, int* y /*=NULL*/, int pos /*=-1*/)
{
	if (IsValid())
	{
		if (pos == -1) pos = GetPos();
		DWORD n = (int)::SendMessage(m_Handle, EM_POSFROMCHAR, (WPARAM)pos, 0);
		if (x != NULL) *x = (short)LOWORD(n);
		if (y != NULL) *y = (short)HIWORD(n);
	}
	else
	{
		if (x != NULL) *x = 0;
		if (y != NULL) *y = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// get line index from client coordinates

int CEdit::LineFromCoord(int x, int y)
{
	if (IsValid())
	{
		return (short)HIWORD(::SendMessage(m_Handle, EM_CHARFROMPOS, 0,
															MAKELPARAM(x,y)));
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// get index of first visible line (or first visible character for single line)

int CEdit::FirstVisible()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// get character position of a line (-1=current line with caret)

int CEdit::GetLinePos(int inx /*= -1*/)
{
	if (IsValid()) return (int)::SendMessage(m_Handle,EM_LINEINDEX,(WPARAM)inx,0);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// get line index from a character in the line (-1=current line with caret)

int CEdit::GetLineInx(int pos /*= -1*/)
{
	if (IsValid())
		return (int)::SendMessage(m_Handle, EM_LINEFROMCHAR, (WPARAM)pos, 0);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// get length of a line from a character in the line (-1=current line)

int CEdit::GetLineLength(int pos /*= -1*/)
{
	if (IsValid())
	{
		if (pos == -1) pos = GetPos();
		return (int)::SendMessage(m_Handle, EM_LINELENGTH, (WPARAM)pos, 0);
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// get number of lines (1 or more)

int CEdit::GetLineCount()
{
	if (IsValid()) return (int)::SendMessage(m_Handle, EM_GETLINECOUNT, 0, 0);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// get line (-1=current line with caret)

CText CEdit::GetLine(int inx /*= -1*/)
{
	CText txt;
	if (IsValid())
	{
		if (inx == -1) inx = GetLineInx();
		int n = GetLinePos(inx);
		n = GetLineLength(n) + 100;
		if (n < 0) n = 0;
		if (n > 0xffff) n = 0xffff;
		TCHAR* buf = (TCHAR*)malloc(n*sizeof(TCHAR));
		if (buf != NULL)
		{
			*(WORD*)buf = (WORD)n;
			n = (int)::SendMessage(m_Handle, EM_GETLINE, (WPARAM)inx, (LPARAM)buf);
			if (n > 0) txt.Set(buf, n);
			free(buf);
		}
	}
	return txt;
}
