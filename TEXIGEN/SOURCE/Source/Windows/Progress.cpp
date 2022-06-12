
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Progress Bar                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText ProgressClass(_T("msctls_progress32"));

// default width and height of progress bar
int		DefProgressW = 150;
int		DefProgressH = 18;

///////////////////////////////////////////////////////////////////////////////
// constructor

CProgress::CProgress()
{
	// window type
	m_Type = WINTYPE_PROGRESS;

	// minimal value (0 to 65535)
	m_Min = 0;

	// maximal value (0 to 65535)
	m_Max = 100;

	// current value (min .. max)
	m_Pos = 0;
}

///////////////////////////////////////////////////////////////////////////////
// create progress bar (flat=not 3D, returns FALSE on error)

BOOL CProgress::CreateBar(int x, int y, BOOL flat /*= FALSE*/,
	BOOL vert /*=FALSE*/, int w /*=0*/, int h /*=0*/,CWindow* parent /*=NULL*/)
{
	if (w == 0) w = (vert ? DefProgressH : DefProgressW);
	if (h == 0) h = (vert ? DefProgressW : DefProgressH);
	BOOL res = CreateChild((flat ? 0 : WS_EX_CLIENTEDGE), ProgressClass,
		EmptyText, (flat ? WS_BORDER : 0) | (vert ? PBS_VERTICAL : 0),
		x, y, w, h, parent);
	SetRange(m_Min, m_Max, TRUE);
	SetPos(m_Pos, TRUE);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set progress bar range (0 to 65535)

void CProgress::SetRange(int min/*=0*/,int max/*=100*/,BOOL update/*=FALSE*/)
{
	if (min > max)
	{
		int k = min;
		min = max;
		max = k;
	}

	if ((min != m_Min) || (max != m_Max) || update)
	{
		m_Min = min;
		m_Max = max;
		m_Pos = Limit(m_Pos);

		if (IsValid())
		{
			FillingOn();
			::SendMessage(m_Handle, PBM_SETRANGE, 0, MAKELPARAM(min, max));
			::SendMessage(m_Handle, PBM_SETSTEP, 1, 0);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// limit position to valid progress bar range

int _fastcall CProgress::Limit(int pos)
{
	if (pos < m_Min) pos = m_Min;
	if (pos > m_Max) pos = m_Max;
	return pos;
}

///////////////////////////////////////////////////////////////////////////////
// set current progress bar position

void CProgress::SetPos(int pos, BOOL update /*= FALSE*/)
{
	pos = Limit(pos);
	if ((pos != m_Pos) || update)
	{
		m_Pos = pos;

		if (IsValid())
		{
			FillingOn();
			::SendMessage(m_Handle, PBM_SETPOS, pos, 0);
			FillingOff();
		}
	}
}
