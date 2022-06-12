
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Spin Control                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const CText SpinClass(_T("msctls_updown32"));

// default width and height of spin control
int		DefSpinW = 12;
int		DefSpinH = 22;

///////////////////////////////////////////////////////////////////////////////
// constructor

CSpin::CSpin()
{
	// window type
	m_Type = WINTYPE_SPIN;

	// can accept focus
	m_CanFocus = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// create spin control (returns FALSE on error)

BOOL CSpin::CreateSpin(int x, int y, int w /*= 0*/, int h /*= 0*/,
		BOOL horz /*= FALSE*/, CWindow* parent /*= NULL*/)
{
	if (w == 0) w = (horz ? DefSpinH : DefSpinW);
	if (h == 0) h = (horz ? DefSpinW : DefSpinH);
	return CreateChild(0, SpinClass, EmptyText, WS_GROUP | WS_TABSTOP |
								(horz ? UDS_HORZ : 0), x, y, w, h, parent);
}
