
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Base Window Class                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CWindowHList WinHList;					// handle window hash list

///////////////////////////////////////////////////////////////////////////////
// load Windows image from resources (returns NULL on error)
//  transp - use transparency (only 8-bit paletted image)
//			substitutes colors:
//				Dk Gray, RGB(128,128,128) -> COLOR_3DSHADOW 
//				Gray, RGB(192,192,192) -> COLOR_3DFACE 
//				Lt Gray, RGB(223,223,223) -> COLOR_3DLIGHT 

HANDLE LoadWinImg(int id, BOOL transp /*= TRUE*/)
{
	return ::LoadImage(Instance, MAKEINTRESOURCE(id), IMAGE_BITMAP, 0, 0,
											transp ? LR_LOADMAP3DCOLORS : 0);
}

/////////////////////////////////////////////////////////////////////////////
// common window message handler

LRESULT CALLBACK MyWinProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	// find this window
	CWindow* win = WinHList.Find(hWnd);
	if ((win == NULL) || (win->WinProc() == NULL))
		return ::DefWindowProc(hWnd, msg, wParam, lParam);

	// window messages
	switch (msg)
	{
	case WM_KEYDOWN:
		switch (win->Type())
		{
		case WINTYPE_MAINFRAME:
			{
				switch (wParam)
				{
				case VK_TAB:
					{
						HWND w2 = ::GetFocus();
						CWindow* win2 = WinHList.Find(w2);
						if ((win2 == NULL) || (win2->Parent() != win)) win2 = win->First();
						if (win2 != NULL)
						{
							BOOL back = FALSE;
							if (::GetAsyncKeyState(VK_SHIFT) < 0) back = TRUE;
							CWindow* win3 = win2;
							for (;;)
							{
								if (back)
								{
									win3 = win3->Prev();
									if (win3 == NULL) win3 = win->Last();
								}
								else
								{
									win3 = win3->Next();
									if (win3 == NULL) win3 = win->First();
								}
								if (win3 == win2) break;
								if (win3->CanFocus())
								{
									win3->SetFocus();
									break;
								}
							}
							if ((win3 == win2) && (win2->CanFocus())) win2->SetFocus();
						}
					}
					return 0;
				}
			}
			break;
		}
		break;

	case WM_PAINT:
		if (win->Type() == WINTYPE_PICTURE)
		{
			CPictureWin* win2 = (CPictureWin*)win;
			PAINTSTRUCT ps;
			HDC dc;
			dc = ::BeginPaint(win->Handle(), &ps);
			win2->OnDraw(dc);
			EndPaint(hWnd, &ps);
			return 0;
		}

		if (win->Type() == WINTYPE_GROUPBOX)
		{
			CWindow* win2;
			TreeForEachChild(win2, win)
			{
				win2->Redraw();
			}
		}
		break;

	case WM_COMMAND:
		{
			int wmId  = LOWORD(wParam); 
			HWND ctrl = (HWND)lParam;
			if (ctrl != NULL)
			{
				CWindow* w = WinHList.Find(ctrl);
				if ((w != NULL) && !w->Filling())
				{
					switch (w->Type())
					{
					case WINTYPE_BUTTON:
					case WINTYPE_BUTTONPIC:
					case WINTYPE_CHECKBOX:
					case WINTYPE_CHECKPIC:
					case WINTYPE_LABEL:
					case WINTYPE_PICTURE:
						if (HIWORD(wParam) == BN_CLICKED)
						{
							if (PropFrame.OnCommand(w, wmId)) return 0;
						}
						break;

					case WINTYPE_EDIT:
						if (HIWORD(wParam) == EN_CHANGE)
						{
							if (PropFrame.OnCommand(w, wmId)) return 0;
						}
						break;

					case WINTYPE_DROPLIST:
					case WINTYPE_COMBOBOX:
					case WINTYPE_COMBOLIST:
						if (HIWORD(wParam) == CBN_SELCHANGE)
						{
							if (PropFrame.OnCommand(w, wmId)) return 0;
						}
						break;
					}
				}
			}
		}
		break;

	case WM_NOTIFY:
		{
			NMHDR* hdr = (NMHDR*)lParam;

			switch (hdr->code)
			{
			case TTN_NEEDTEXT:
				DoToolTip(lParam);
				return 0;

			case TTN_POP:
				SetStatusText(EmptyText);
				return 0;
			}
		}
		break;

	case WM_HSCROLL:
	case WM_VSCROLL:
		{
			HWND wnd = (HWND)lParam;
			CWindow* w = WinHList.Find(wnd);
			if ((w != NULL) && !w->Filling())
			{
				switch (w->Type())
				{
				case WINTYPE_SLIDER:
					{
						if (w->Handle() == TimeSelSlider)
						{
							if (!TimeSelSlider.Filling())
							{
								PreviewTime = (real)(TimeSelSlider.GetPos()*0.01);
								FGraphRestart();
								if (SelectMode)
									SPrevRenderStart();
								else
									EPrevRenderStart();
							}
						}
						else
						{
							CSlider* w2 = (CSlider*)w;
							if (PropFrame.OnCommand(w, w2->Id())) return 0;
						}
					}
					break;
				}
			}			
		}
		break;

	case WM_MOUSEWHEEL:
		break;

	case WM_LBUTTONDOWN:
		break;

	case WM_MOUSEMOVE:
		break;

	case WM_MOUSELEAVE:
		break;
	}
	return ::CallWindowProc(win->WinProc(), hWnd, msg, wParam, lParam);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CWindow::CWindow()
{
	// window type
	m_Type = WINTYPE_BASE;

	// static object - must not be destroyed
	m_Static = FALSE;

	// window handle (NULL=none)
	m_Handle = NULL;

	// programmatic filling of window content (>0 ignore notifications)
	m_Filling = 0;

	// window is visible
	m_Visible = FALSE;

	// window is enabled
	m_Enabled = TRUE;

	// arrange flags
	m_ArrangeFlags = ARRANGE_REL;

	// window size and position
	m_AbsRect.Set(0, 0, 320, 240);
	m_Rect.Set(0, 0, 320, 240);
	m_InitParRect.Set(0, 0, 0, 0);

	// original message handler (NULL=none)
	m_WinProc = NULL;

	// can accept focus
	m_CanFocus = FALSE;

    // filter property index (-1=invalid)
	m_PropInx = -1;
}

///////////////////////////////////////////////////////////////////////////////
// create window (returns FALSE on error)

BOOL CWindow::CreateWin(DWORD exstyle, const CText& classname,
					const CText& text, DWORD style, int x, int y, int w, int h,
					CWindow* parent, HMENU menu)
{
	FillingOn();

	// create window
	m_Handle = ::CreateWindowEx(exstyle, classname, text,
		style | WS_CLIPCHILDREN | WS_CLIPSIBLINGS, x, y, w, h,
		((parent == NULL) ? NULL : parent->Handle()), menu, Instance, NULL);

	// subclassing window
	if (m_Handle != NULL)
	{
		m_WinProc = (WNDPROC)(LONG_PTR)::GetWindowLongPtr(m_Handle, GWLP_WNDPROC);
#pragma warning ( disable: 4244)		// warning - possible loww of data
		if (m_WinProc) ::SetWindowLongPtr(m_Handle, GWLP_WNDPROC, (LONG_PTR)MyWinProc);
#pragma warning ( default: 4244)		// warning - possible loww of data
	}
	else
	{
		//
	}

	// store windows parameters
	if (parent != NULL)
	{
		m_InitParRect = parent->ClientRect();
		parent->AddLast(this);
	}
	m_Visible = ((style & WS_VISIBLE) != 0);
	m_Enabled = ((style & WS_DISABLED) == 0);
	m_Class = classname;
	m_Text = text;

	// add new control
	WinHList.AddNew(this);

	// update window size and position
	UpdateRect();
	m_InitRect = m_Rect;

	FillingOff();

	return IsValid();
}

///////////////////////////////////////////////////////////////////////////////
// destroy children of window

void CWindow::DestroyChildren()
{
	while (First() != NULL)
	{
		CWindow* w = First();
		w->Destroy();
		if (!w->Static()) delete w;
	}
}

///////////////////////////////////////////////////////////////////////////////
// destroy window

void CWindow::Destroy()
{
	if (m_Handle == NULL) return;

	DestroyChildren();

	// subclassing window
	if ((m_Handle != NULL) && (m_WinProc != NULL))
	{
#pragma warning ( disable: 4244)		// warning - possible loww of data
		::SetWindowLongPtr(m_Handle, GWLP_WNDPROC, (LONG_PTR)m_WinProc);
#pragma warning ( default: 4244)		// warning - possible loww of data
		m_WinProc = NULL;
	}

	WinHList.Delete(this);
	Delete();

	if (IsValid())
	{
		FillingOn();
		::DestroyWindow(m_Handle);
		m_Handle = NULL;
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set window visibility

void CWindow::SetVisible(BOOL visible, BOOL update /*= FALSE*/)
{
	if ((visible != m_Visible) || update)
	{
		m_Visible = visible;
		if (IsValid())
		{
			FillingOn();
			::ShowWindow(m_Handle, visible ? SW_SHOW : SW_HIDE);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// enable window

void CWindow::Enable(BOOL enable, BOOL update /*= FALSE*/)
{
	if ((enable != m_Enabled) || update)
	{
		m_Enabled = enable;
		if (IsValid())
		{
			FillingOn();
			::EnableWindow(m_Handle, enable);
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// get enabled state from the window

BOOL CWindow::GetEnabled()
{
	if (IsValid())
	{
		m_Enabled = ::IsWindowEnabled(m_Handle);
	}
	return m_Enabled;
}

///////////////////////////////////////////////////////////////////////////////
// update window size and position

void CWindow::UpdateRect()
{
	if (IsValid())
	{
		// get window absolute position (in screen coordinates)
		::GetWindowRect(m_Handle, &m_AbsRect);
		m_Rect = m_AbsRect;

		// recalculate to parent's client coordinates
		if (Parent() != NULL)
		{
			int w = m_Rect.Width();
			int h = m_Rect.Height();
			::ScreenToClient(Parent()->Handle(), (POINT*)&m_Rect);
			m_Rect.SetWidth(w);
			m_Rect.SetHeight(h);
		}

		// get client rectangle
		::GetClientRect(m_Handle, &m_ClientRect);
	}
}

///////////////////////////////////////////////////////////////////////////////
// move and resize window

void CWindow::MoveResize(int x, int y, int w, int h)
{
	if (IsValid())
	{
		// prepare flags
		BOOL change = FALSE;
		DWORD flag = SWP_NOZORDER | SWP_NOACTIVATE | SWP_NOOWNERZORDER |
													SWP_NOMOVE | SWP_NOSIZE;

		// check new position
		if ((x != Left()) || (y != Top()))
		{
			flag &= ~SWP_NOMOVE;
			change = TRUE;
		}

		// check new dimension
		if ((w != Width()) || (h != Height()))
		{
			flag &= ~SWP_NOSIZE;
			flag |= SWP_DRAWFRAME;
			change = TRUE;
		}

		// move window
		if (change)
		{
			FillingOn();
			::SetWindowPos(m_Handle, NULL, x, y, w, h, flag);
			UpdateRect();
			FillingOff();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// arrange window after resizing parent

void CWindow::Arrange()
{
	// get current parent's client area
	if (Parent() == NULL) return;
	CRect* prc = &Parent()->m_ClientRect;

	// width of initial parent's client area
	int wp = m_InitParRect.Width();
	if (wp == 0) wp = 1;

	// arrange width
	int w = m_InitRect.Width();
	if (m_ArrangeFlags & ARRANGE_WIDTH) w = w * prc->Width() / wp;

	// arrange horizontal position
	int x = m_InitRect.left;
	switch (m_ArrangeFlags & (ARRANGE_LEFT|ARRANGE_RIGHT))
	{
	case 0:
		x = (x + m_InitRect.Width()/2)*prc->Width()/wp - w/2;
		break;

	case ARRANGE_LEFT:
		x = x + (prc->left - m_InitParRect.left);
		break;

	case ARRANGE_RIGHT:
		x = x + (prc->right - m_InitParRect.right) - (w - m_InitRect.Width());
		break;

	default: //ARRANGE_LEFT | ARRANGE_RIGHT:
		x = x + (prc->left - m_InitParRect.left);
		w = m_InitRect.right + (prc->right - m_InitParRect.right) - x;
	}

	// height of initial parent's client area
	int hp = m_InitParRect.Height();
	if (hp == 0) hp = 1;

	// arrange height
	int h = m_InitRect.Height();
	if (m_ArrangeFlags & ARRANGE_HEIGHT) h = h * prc->Height() / hp;

	// arrange vertical position
	int y = m_InitRect.top;
	switch (m_ArrangeFlags & (ARRANGE_TOP|ARRANGE_BOTTOM))
	{
	case 0:
		y = (y + m_InitRect.Height()/2)*prc->Height()/hp - h/2;
		break;

	case ARRANGE_TOP:
		y = y + (prc->top - m_InitParRect.top);
		break;

	case ARRANGE_BOTTOM:
		y = y + (prc->bottom - m_InitParRect.bottom) - (h-m_InitRect.Height());
		break;

	default: //ARRANGE_TOP | ARRANGE_BOTTOM:
		y = y + (prc->top - m_InitParRect.top);
		h = m_InitRect.bottom + (prc->bottom - m_InitParRect.bottom) - y;
	}

	// move and resize window
	MoveResize(x, y, w, h);
}

///////////////////////////////////////////////////////////////////////////////
// invalidate window content

void CWindow::Invalidate()
{
	if (IsValid())
	{
		FillingOn();
		::InvalidateRect(m_Handle, NULL, TRUE);
		FillingOff();
	}
}

void CWindow::Invalidate(const CRect* rc)
{
	if (IsValid())
	{
		FillingOn();
		::InvalidateRect(m_Handle, rc, TRUE);
		FillingOff();
	}
}

void CWindow::Invalidate(int left, int top, int right, int bottom)
{
	if (IsValid())
	{
		RECT rc;
		rc.left = left;
		rc.top = top;
		rc.right = right;
		rc.bottom = bottom;

		FillingOn();
		::InvalidateRect(m_Handle, &rc, TRUE);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// update window content (if it need update)

void CWindow::Update()
{
	if (IsValid())
	{
		FillingOn();
		::UpdateWindow(m_Handle);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// update window frame after changing window style

void CWindow::UpdateFrame()
{
	if (IsValid())
	{
		FillingOn();
		::SetWindowPos(m_Handle, NULL, 0, 0, 0, 0, SWP_FRAMECHANGED |
			SWP_DRAWFRAME | SWP_NOACTIVATE | SWP_NOCOPYBITS |
			SWP_NOOWNERZORDER | SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE);
		UpdateRect();
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// redraw window content (invalidate and update)

void CWindow::Redraw()
{
	if (IsValid())
	{
		FillingOn();
		::InvalidateRect(m_Handle, NULL, TRUE);
		::UpdateWindow(m_Handle);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// disable window redraw

void CWindow::RedrawOff()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, WM_SETREDRAW, FALSE, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// enable window redraw

void CWindow::RedrawOn()
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, WM_SETREDRAW, TRUE, 0);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get window text

CText CWindow::GetText()
{
	int len = 0;
	TCHAR* buf = NULL;

	if (IsValid())
	{
		// get text length
		int n = (int)::SendMessage(m_Handle, WM_GETTEXTLENGTH, 0, 0);
		if (n < 0) n = 0;
		if (n > 0xffff) n = 0xffff;
		n++;

		// create temporary buffer
		buf = (TCHAR*)malloc(n*sizeof(TCHAR));

		// get text
		if (buf != NULL) len = (int)::SendMessage(m_Handle,WM_GETTEXT,n,(LPARAM)buf);
	}

	if (len == 0)
		m_Text.Empty();
	else
		m_Text.Set(buf, len);

	free(buf);
	return m_Text;
}

///////////////////////////////////////////////////////////////////////////////
// set window text

void CWindow::SetText(const CText& txt, BOOL update /*= FALSE*/)
{
	if (IsValid())
	{
		if (update || (txt != m_Text))
		{
			m_Text = txt;
			FillingOn();
			::SendMessage(m_Handle, WM_SETTEXT, 0, (LPARAM)(LPCTSTR)txt);
			FillingOff();
		}
	}
}

void CWindow::SetTextInt(int num, BOOL update /*= FALSE*/)
{
	CText txt;
	txt.SetInt(num);
	SetText(txt, update);
}

void CWindow::SetTextDouble(double num, BOOL update /*= FALSE*/)
{
	CText txt;
	txt.SetDouble(num);
	SetText(txt, update);
}

///////////////////////////////////////////////////////////////////////////////
// set font

void CWindow::SetFont(HFONT font)
{
	if (IsValid())
	{
		FillingOn();
		::SendMessage(m_Handle, WM_SETFONT, (WPARAM)font, (LPARAM)TRUE);
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// get window LONG value

LONG_PTR CWindow::GetLong(int inx)
{
	if (IsValid())
		return ::GetWindowLongPtr(m_Handle, inx);
	else
		return 0;
}

///////////////////////////////////////////////////////////////////////////////
// set window LONG value (call UpdateFrame after changing window frame)

void CWindow::SetLong(int inx, LONG_PTR val)
{
	if (IsValid())
	{
		FillingOn();
#pragma warning ( disable: 4244)		// warning - possible loww of data
		::SetWindowLongPtr(m_Handle, inx, val);
#pragma warning ( default: 4244)		// warning - possible loww of data
		FillingOff();
	}
}

///////////////////////////////////////////////////////////////////////////////
// set focus to this window (returns handle of previous window with focus)

HWND CWindow::SetFocus()
{
	HWND wnd = NULL;
	if (IsValid())
	{
		FillingOn();
		wnd = ::SetFocus(m_Handle);
		FillingOff();
	}
	return wnd;
}

///////////////////////////////////////////////////////////////////////////////
// check whether window has focus

BOOL CWindow::HasFocus()
{
	HWND wnd = ::GetFocus();
	return (wnd == m_Handle);
}

///////////////////////////////////////////////////////////////////////////////
// recalculate screen coordinates to client coordinates

void CWindow::RectToClient(CRect* rc)
{
	if (IsValid())
	{
		int w = rc->Width();
		int h = rc->Height();
		PosToClient((POINT*)rc);
		rc->SetWidth(w);
		rc->SetHeight(h);
	}
}

void CWindow::PosToClient(POINT* pos)
{
	if (IsValid()) ::ScreenToClient(m_Handle, pos);
}

void CWindow::PosToClient(int* x /*= NULL*/, int* y /*= NULL*/)
{
	if (IsValid())
	{
		POINT pos;
		pos.x = ((x == NULL) ? 0 : *x);
		pos.y = ((y == NULL) ? 0 : *y);
		::ScreenToClient(m_Handle, &pos);
		if (x != NULL) *x = pos.x;
		if (y != NULL) *y = pos.y;
	}
}

int CWindow::XToClient(int x)
{
	PosToClient(&x, NULL);
	return x;
}

int CWindow::YToClient(int y)
{
	PosToClient(NULL, &y);
	return y;
}

///////////////////////////////////////////////////////////////////////////////
// recalculate client coordinates to screen coordinates

void CWindow::RectToScreen(CRect* rc)
{
	if (IsValid())
	{
		int w = rc->Width();
		int h = rc->Height();
		PosToScreen((POINT*)rc);
		rc->SetWidth(w);
		rc->SetHeight(h);
	}
}

void CWindow::PosToScreen(POINT* pos)
{
	if (IsValid()) ::ClientToScreen(m_Handle, pos);
}

void CWindow::PosToScreen(int* x /*= NULL*/, int* y /*= NULL*/)
{
	if (IsValid())
	{
		POINT pos;
		pos.x = ((x == NULL) ? 0 : *x);
		pos.y = ((y == NULL) ? 0 : *y);
		::ClientToScreen(m_Handle, &pos);
		if (x != NULL) *x = pos.x;
		if (y != NULL) *y = pos.y;
	}
}

int CWindow::XToScreen(int x)
{
	PosToScreen(&x, NULL);
	return x;
}

int CWindow::YToScreen(int y)
{
	PosToScreen(NULL, &y);
	return y;
}

///////////////////////////////////////////////////////////////////////////////
// get owner of control (=window)

CWindow* CWindow::Owner()
{
	CWindow* w = this;
	while ((w != NULL) && (w->Type() != WINTYPE_MAINFRAME))
		w = w->Parent();
	return w;
}
