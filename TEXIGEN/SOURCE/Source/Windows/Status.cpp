
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Status Line                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText StatusClass(_T("msctls_statusbar32"));

///////////////////////////////////////////////////////////////////////////////
// constructor

CStatus::CStatus()
{
	// window type
	m_Type = WINTYPE_STATUS;

	// number of status line parts (1..STATUS_MAX)
	m_PartNum = 1;

	// widths of status line parts (-1 = autosize)
	for (int i = 0; i < STATUS_MAX; i++) m_PartWidth[i] = -1;
}

///////////////////////////////////////////////////////////////////////////////
// update widths of status line parts

void CStatus::UpdateParts()
{
	if (IsValid())
	{
		int w = ClientWidth();
		int i;

		// get width of fixed parts
		int n = 0;
		for (i = m_PartNum-1; i >= 0; i--)
			if (m_PartWidth[i] < 0) n++; else w -= m_PartWidth[i];
		if (w < 0) w = 0;
		if (n > 0) w /= n;

		// prepare right coordinates
		int x = 0;
		int xx[STATUS_MAX];
		for (i = 0; i < m_PartNum; i++)
		{
			if (m_PartWidth[i] < 0)
				x += w;
			else
				x += m_PartWidth[i];
			xx[i] = x;
		}
		if (n > 0) xx[m_PartNum-1] = -1;

		// set parts widths
		::SendMessage(m_Handle, SB_SETPARTS, m_PartNum, (LPARAM)xx);
	}
}

///////////////////////////////////////////////////////////////////////////////
// create status line (returns FALSE on error)
//		(resizing: parent window has WS_THICKFRAME style)

BOOL CStatus::CreateStatus(CWindow* parent /*= NULL*/)
{
	DWORD style = 0;
	if (parent == NULL) parent = DefParentWin;
	if ((parent != NULL) && parent->IsValid() &&
		((parent->GetStyle() & WS_THICKFRAME) != 0)) style = SBARS_SIZEGRIP;
	BOOL res = CreateChild(0, StatusClass, EmptyText, style, 0,0,0,0, parent);
	if (res)
	{
		UpdateParts();
		for (int i = 0; i < m_PartNum; i++)
			SetStatusText(m_StatusText[i], i, TRUE);
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// resize status line (after resizing parent window)

void CStatus::Resize()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, WM_SIZE, 0, 0);
		UpdateRect();
		UpdateParts();
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// number of status line parts (1..STATUS_MAX)

void CStatus::SetPartNum(int num /*= 1*/)
{
	if (num < 1) num = 1;
	if (num > STATUS_MAX) num = STATUS_MAX;
	int oldnum = m_PartNum;
	if (num != oldnum)
	{
		m_PartNum = num;

		if (IsValid())
		{
			UpdateParts();
			for (; oldnum < num; oldnum++)
				SetStatusText(m_StatusText[oldnum], oldnum, TRUE);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// set width of status line part (-1 = autosize)

void CStatus::SetPartWidth(int part /*= 0*/, int width /*= -1*/)
{
	if (PartIsValid(part))
	{
		m_PartWidth[part] = width;
		UpdateParts();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set status line text

void CStatus::SetStatusText(const CText& text, int part /*= 0*/,
													BOOL update /*= TRUE*/)
{
	if (PartIsValid(part) && (update || (m_StatusText[part] != text)))
	{
		m_StatusText[part] = text;

		if (IsValid() && (part < m_PartNum))
		{
			FillingOn();
			::SendMessage(m_Handle,SB_SETTEXT,part,(LPARAM)(LPCTSTR)text);
			FillingOff();
		}
	}
}
