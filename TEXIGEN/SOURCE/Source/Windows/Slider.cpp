
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              Slider (Track Bar)                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText SliderClass(_T("msctls_trackbar32"));

int		DefSliderW0 = 21;		// default width of slider with no marks
int		DefSliderW1 = 30;		// default width of slider with single marks
int		DefSliderW2 = 43;		// default width of slider with double marks

int		DefSliderT0 = 18;		// default thumb width with no marks
int		DefSliderT1 = 18;		// default thumb width with single marks
int		DefSliderT2 = 26;		// default thumb width with double marks

///////////////////////////////////////////////////////////////////////////////
// constructor

CSlider::CSlider()
{
	// window type
	m_Type = WINTYPE_SLIDER;

	// minimal value (or negative value)
	m_Min = 0;

	// maximal value (or negative value)
	m_Max = 100;

	// page size
	m_Page = 10;

	// range signum (+1 if min <= max, -1 if min > max)
	m_Sign = 1;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// create slider

BOOL CSlider::CreateSlider(DWORD style, int x, int y, int w /*= 0*/,
								int h /*= 0*/, CWindow* parent /*= NULL*/)
{
	BOOL res = CreateChild(0, SliderClass, EmptyText, style | WS_TABSTOP |
			TBS_FIXEDLENGTH, x, y, w, h, parent);
	SetRange(Min(), Max(), TRUE);
	SetPage();
	SetFreq();
	SetPos(Min());
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// create horizontal slider (with single marks)

BOOL CSlider::CreateHSlider(int x, int y, int w, BOOL bottom /*= FALSE*/,
									int h /*= 0*/, CWindow* parent/*= NULL*/)
{
	if (h == 0) h = DefSliderW1;
	BOOL res = CreateSlider(TBS_AUTOTICKS | TBS_HORZ | TBS_DOWNISLEFT |
		(bottom ? TBS_BOTTOM : TBS_TOP), x, y, w, h, parent);
	if (res) SetThumbLength(DefSliderT1);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// create low horizontal slider (without marks)

BOOL CSlider::CreateLowSlider(int x, int y, int w, int h /*= 0*/,
													CWindow* parent/*= NULL*/)
{
	if (h == 0) h = DefSliderW0;
	BOOL res = CreateSlider(TBS_NOTICKS | TBS_HORZ | TBS_TOP | TBS_DOWNISLEFT,
														x, y, w, h, parent);
	if (res) SetThumbLength(DefSliderT0);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// create vertical slider (with single marks)

BOOL CSlider::CreateVSlider(int x, int y, int h, BOOL right /*= FALSE*/,
									int w /*= 0*/, CWindow* parent/*= NULL*/)
{
	if (w == 0) w = DefSliderW1;
	BOOL res = CreateSlider(TBS_AUTOTICKS | TBS_VERT | TBS_DOWNISLEFT |
		(right ? TBS_RIGHT : TBS_LEFT), x, y, w, h, parent);
	if (res) SetThumbLength(DefSliderT1);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// create wide vertical slider (with double marks)

BOOL CSlider::CreateWideSlider(int x, int y, int h, int w /*= 0*/,
													CWindow* parent/*= NULL*/)
{
	if (w == 0) w = DefSliderW2;
	BOOL res = CreateSlider(TBS_AUTOTICKS | TBS_VERT | TBS_BOTH |
									TBS_DOWNISLEFT, x, y, w, h, parent);
	if (res) SetThumbLength(DefSliderT2);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// set thumb length

void CSlider::SetThumbLength(int len)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, TBM_SETTHUMBLENGTH, len, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set slider range

void CSlider::SetRange(int min, int max, BOOL update /*= FALSE*/)
{
	int sign = 1;
	if (min > max)
	{
		min = -min;
		max = -max;
		sign = -1;
	}

	if ((min != m_Min) || (max != m_Max) || (sign != m_Sign) || update)
	{
		m_Min = min;
		m_Max = max;
		m_Sign = sign;

		if (IsValid())
		{
			FillingOn();
			::SendMessage(m_Handle, TBM_SETRANGEMIN, FALSE, min);
			::SendMessage(m_Handle, TBM_SETRANGEMAX, TRUE, max);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// limit position to valid slider range

int _fastcall CSlider::Limit(int pos)
{
	pos *= m_Sign;
	if (pos < m_Min) pos = m_Min;
	if (pos > m_Max) pos = m_Max;
	pos *= m_Sign;
	return pos;
}

///////////////////////////////////////////////////////////////////////////////
// set slider page size

void CSlider::SetPage(int page /*= 0*/)
{
	if (IsValid())
	{
		page = abs(page);
		if (page == 0) page = (m_Max - m_Min)/10;
		m_Page = page;
		FillingOn();
		::SendMessage(m_Handle, TBM_SETPAGESIZE, 0, page);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set marks frequency (0=default 1/10 of range)

void CSlider::SetFreq(int freq /*= 0*/)
{
	if (IsValid())
	{
		freq = abs(freq);
		if (freq == 0) freq = (m_Max - m_Min)/10;
		FillingOn();
		::SendMessage(m_Handle, TBM_SETTICFREQ, (WPARAM)(WORD)freq, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get slider position

int CSlider::GetPos()
{
	if (IsValid())
		return Limit((int)::SendMessage(m_Handle, TBM_GETPOS, 0, 0)*m_Sign);
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// set slider position

void CSlider::SetPos(int pos)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, TBM_SETPOS, TRUE, (LPARAM)(Limit(pos)*m_Sign));
		FillingOff();
	}
}
