
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Window Frame                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFrame::CFrame()
{
	// window type
	m_Type = WINTYPE_FRAME;

	// frame type
	m_FrameType = FRAME_NONE;
}

///////////////////////////////////////////////////////////////////////////////
// create window frame (returns FALSE on error)

BOOL CFrame::CreateFrm(FRAMETYPE type, int x, int y, int w, int h,
													CWindow* parent /*= NULL*/)
{
	m_FrameType = type;

	long style = 0;
	long exstyle = 0;

	switch (type)
	{
	case FRAME_DARK: style = SS_BLACKFRAME; break;
	case FRAME_GRAY: style = SS_GRAYFRAME; break;
	case FRAME_LIGHT: style = SS_WHITEFRAME; break;
	case FRAME_ETCHED: style = SS_ETCHEDFRAME; break;
	case FRAME_HETCHED: style = SS_ETCHEDHORZ; break;
	case FRAME_VETCHED: style = SS_ETCHEDVERT; break;
	case FRAME_DARKRECT: style = SS_BLACKRECT; break;
	case FRAME_GRAYRECT: style = SS_GRAYRECT; break;
	case FRAME_LIGHTRECT: style = SS_WHITERECT; break;
	case FRAME_HALFSUNK: exstyle = WS_EX_STATICEDGE; break;
	case FRAME_SUNKEN: style = WS_BORDER; exstyle = WS_EX_CLIENTEDGE; break;
	case FRAME_DBLSUNK:	style = WS_BORDER;
			exstyle = WS_EX_STATICEDGE | WS_EX_CLIENTEDGE; break;
	case FRAME_LINE: style = WS_BORDER; break;
	case FRAME_LINESUNK: style = WS_BORDER; exstyle = WS_EX_STATICEDGE; break;
	case FRAME_RAISED: exstyle = WS_EX_DLGMODALFRAME; break;
	case FRAME_BUMP: style = WS_BORDER;
			exstyle = WS_EX_CLIENTEDGE | WS_EX_DLGMODALFRAME; break;
	default:
		break;
	}
	style |= SS_NOTIFY;
	return CreateChild(exstyle, StaticClass, EmptyText, style, x,y,w,h,parent);
}
