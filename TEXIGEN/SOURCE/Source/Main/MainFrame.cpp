
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              Application Window                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

/////////////////////////////////////////////////////////////////////////////
// selection toolbar

TBBUTTON  TBSButton[] = {
	{TBS_GROUP,		ID_NEWGROUP,	TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_NEW,		ID_NEW,			TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_OPEN,		ID_OPEN,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_INFO,		ID_INFO,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_DELETE,	ID_DELETE,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{0,				0,				TBSTATE_ENABLED,	TBSTYLE_SEP,		0,		0},
	{TBS_DEFAULT,	ID_DEFAULT,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_MUTATE,	ID_MUTATE,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_GENERATE,	ID_GENERATE,	TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_SAVE,		ID_SAVEVAR,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{0,				0,				TBSTATE_ENABLED,	TBSTYLE_SEP,		0,		0},
	{TBS_RENDER,	ID_RENDER,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{0,				0,				TBSTATE_ENABLED,	TBSTYLE_SEP,		0,		0},
	{TBS_ZOOMOUT,	ID_ZOOMOUT,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_ZOOMIN,	ID_ZOOMIN,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
};

// number of buttons of selection toolbar
const int TBSButtonNum = sizeof(TBSButton) / sizeof(TBBUTTON);

/////////////////////////////////////////////////////////////////////////////
// editation toolbar

TBBUTTON  TBEButton[] = {
	{TBS_SAVE,		ID_SAVE,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_SAVEAS,	ID_SAVEAS,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_CLOSE,		ID_CLOSE,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_INFO,		ID_INFO,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{0,				0,				TBSTATE_ENABLED,	TBSTYLE_SEP,		0,		0},
	{TBS_RENDER,	ID_RENDER,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{0,				0,				TBSTATE_ENABLED,	TBSTYLE_SEP,		0,		0},
	{TBS_ZOOMIN,	ID_ZOOMIN,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
	{TBS_ZOOMOUT,	ID_ZOOMOUT,		TBSTATE_ENABLED,	TBSTYLE_BUTTON,		0,		0},
};

// number of buttons of editation toolbar
const int TBEButtonNum = sizeof(TBEButton) / sizeof(TBBUTTON);

///////////////////////////////////////////////////////////////////////////////
// variables

CMainFrame*	MainFrame = NULL;			// main frame of the application (ROOT)
LPCTSTR		MainFrameClass = _T("TexiGenMainFrame"); // name of the mainframe class
HMENU		MainMenu = NULL;			// current main menu

int			MainFrameLeft;				// main frame X coordinate
int			MainFrameTop;				// main frame Y coordinate
int			MainFrameWidth;				// main frame width
int			MainFrameHeight;			// main frame height
BOOL		MainFrameMax = FALSE;		// main frame is maximized
int			MainFrameClientLeft;		// inner X coordinate of main frame
int			MainFrameClientTop;			// inner Y coordinate of main frame
int			MainFrameClientWidth;		// inner width of main frame (0=auto)
int			MainFrameClientHeight;		// inner height of main frame (0=auto)

//int			ScreenBits = 0;				// color bits in fullscreen (0=auto)

int			ToolBarID = IDB_SELECT;		// tool bar bitmap resource ID (0=none)
int			ToolBarNum = TBS_NUM;		// number of toolbar icons
//TBBUTTON*	ToolBarBtn = TBSButton;		// toolbar buttons
//int			ToolBarBtnNum = TBSButtonNum;	// number of toolbar buttons

// main frame style
#define MAINFRAME_STYLE	(WS_BORDER | WS_CAPTION | WS_VISIBLE | WS_THICKFRAME |\
				WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_OVERLAPPED | WS_SYSMENU |\
				WS_CLIPCHILDREN | WS_CLIPSIBLINGS)
#define MAINFRAME_STYLEEX	(WS_EX_APPWINDOW | WS_EX_CONTROLPARENT | \
				WS_EX_WINDOWEDGE)

// preview progress bas
CProgress PreviewProgress;

///////////////////////////////////////////////////////////////////////////////
// constructor

CMainFrame::CMainFrame()
{
	// window type
	m_Type = WINTYPE_MAINFRAME;

	// status line enabled
	m_StatusOn = FALSE;

	// tool tip enabled
	m_ToolTipOn = FALSE;

	// tool bar enabled
	m_ToolBarOn = FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// enable command (in menu and tool bar)

void EnableCmd(int id, BOOL enable)
{
	if (MainMenu != NULL) ::EnableMenuItem(MainMenu, id,
			MF_BYCOMMAND | enable ? MF_ENABLED : MF_GRAYED);
	MainFrame->ToolBar()->EnableBtn(id, enable);
}

//////////////////////////////////////////////////////////////////////////////
// check command (in menu and tool bar)

void CheckCmd(int id, BOOL check)
{
	if (MainMenu != NULL) ::CheckMenuItem(MainMenu, id,
			MF_BYCOMMAND | (check ? MF_CHECKED : MF_UNCHECKED));
	MainFrame->ToolBar()->CheckBtn(id, check);
}

///////////////////////////////////////////////////////////////////////////////
// tool tip service

void DoToolTip(LPARAM lParam)
{
	TOOLTIPTEXT* tip = (TOOLTIPTEXT*)lParam;
	CText txt;
	tip->szText[0] = 0;
	int id = (int)tip->hdr.idFrom;
	if (tip->uFlags & TTF_IDISHWND)
		id = ::GetDlgCtrlID((HWND)(tip->hdr.idFrom));
	txt.Load(id);
	int pos = txt.Find(_T('|'));
	int len = pos;
	if (len > 79) len = 79;
	if (len >= 0)
	{
		memcpy(tip->szText, (LPCTSTR)txt, len*sizeof(TCHAR));
		tip->szText[len] = 0;
		txt.Delete(0, pos+1);
	}
	tip->hinst = NULL;

	SetStatusText(txt);
}

///////////////////////////////////////////////////////////////////////////////
// update window size and position

void CMainFrame::UpdateRect()
{
	// update window coordinates
	CWindow::UpdateRect();

	MainFrameMax = ::IsZoomed(MainFrame->Handle());
	WriteIniBool("MainFrameMax", MainFrameMax);

	if (!MainFrameMax)
	{
		MainFrameLeft = Left();
		MainFrameTop = Top();
		MainFrameWidth = Width();
		MainFrameHeight = Height();

		// write ini
		WriteIniInt("MainFrameLeft", MainFrameLeft);
		WriteIniInt("MainFrameTop", MainFrameTop);
		WriteIniInt("MainFrameWidth", MainFrameWidth);
		WriteIniInt("MainFrameHeight", MainFrameHeight);
	}

	// update status line
	m_Status.Resize();
	if (m_StatusOn && m_Status.IsValid())
		m_ClientRect.bottom -= m_Status.Height();

	// update progress bar
	PreviewProgress.Move(m_Status.ClientWidth() - PREVBARW2 + 4, 4);

	// update toolbar
	m_ToolBar.Resize();
	if (m_ToolBarOn && m_ToolBar.IsValid())
		m_ClientRect.top += m_ToolBar.Height() - 1;

	// store client dimension
	MainFrameClientLeft = ClientLeft();
	MainFrameClientTop = ClientTop();
	MainFrameClientWidth = ClientWidth();
	MainFrameClientHeight = ClientHeight();

	// get screen color bits
	//if (IsValid())
	//{
	//	HDC dc = ::GetDC(m_Handle);
	//	if (dc)
	//	{
	//		ScreenBits = ::GetDeviceCaps(dc, BITSPIXEL);
	//		::ReleaseDC(m_Handle, dc);
	//	}
	//}
}

/////////////////////////////////////////////////////////////////////////////
// status line enabled

void CMainFrame::SetStatusOn(BOOL on, BOOL update /*= FALSE*/)
{
	if ((on != m_StatusOn) || update)
	{
		m_StatusOn = on;
		if (IsValid())
		{
			m_Status.SetVisible(on, update);
			UpdateRect();
			::SendMessage(m_Handle, WM_SIZE, SIZE_RESTORED,
				MAKELPARAM(ClientWidth(), ClientHeight()));
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// create status line

void CMainFrame::CreateStatus()
{
	if (IsValid())
	{
		m_Status.CreateStatus(this);
		SetStatusOn(m_StatusOn, TRUE);
	}
}

/////////////////////////////////////////////////////////////////////////////
// tool tip enabled

void CMainFrame::SetToolTipOn(BOOL on)
{
	if (on != m_ToolTipOn)
	{
		m_ToolTipOn = on;
		if (IsValid()) m_ToolTip.SetActive(on);
	}
}

/////////////////////////////////////////////////////////////////////////////
// create tool tip

void CMainFrame::CreateToolTip()
{
	if (IsValid())
	{
		m_ToolTip.CreateToolTip(this);
		SetToolTipOn(TRUE);
	}
}

/////////////////////////////////////////////////////////////////////////////
// tool bar enabled

void CMainFrame::SetToolBarOn(BOOL on, BOOL update /*= FALSE*/)
{
	if ((m_ToolBarOn != on) || update)
	{
		m_ToolBarOn = on;
		if (IsValid())
		{
			m_ToolBar.SetVisible(on, update);
			UpdateRect();
			::SendMessage(m_Handle, WM_SIZE, SIZE_RESTORED,
				MAKELPARAM(ClientWidth(), ClientHeight()));
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// create tool bar

void CMainFrame::CreateToolBar()
{
	if (IsValid() && (ToolBarID > 0))
	{
		m_ToolBar.CreateToolBar(ToolBarID, ToolBarNum, TRUE, FALSE, this);
		SetToolBarOn(TRUE);
	}
}

/////////////////////////////////////////////////////////////////////////////
// about dialog

CWindow AboutWindow;
CLabel AboutVersionLabel;
CLabel AboutCopyrightLabel;
CEdit AboutWebEdit;
CEdit AboutHomeEdit;
CEdit AboutEmailEdit;
CEdit AboutPortfolioEdit;
CEdit AboutLicenseEdit;

INT_PTR CALLBACK AboutProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	CText txt;

	switch (msg)
	{
	case WM_INITDIALOG:
		AboutWindow.SetHandle(hWnd);
		AboutVersionLabel.InitDlg(IDC_VERSION, &AboutWindow);
		AboutVersionLabel.SetText(_T("TexiGen v") VERTXT2);
		txt = _T("(c) ") VERYEARTXT _T(" ");
		AboutCopyrightLabel.InitDlg(IDC_COPYRIGHT, &AboutWindow);
		txt += AboutCopyrightLabel.GetText();
		AboutCopyrightLabel.SetText(txt);
		AboutWebEdit.InitDlg(IDC_WEB, &AboutWindow);
		AboutWebEdit.SetText(_T("www.breatharian.eu/TexiGen"));
		AboutHomeEdit.InitDlg(IDC_HOME, &AboutWindow);
		AboutHomeEdit.SetText(_T("panda38.sweb.cz"));
		AboutEmailEdit.InitDlg(IDC_EMAIL, &AboutWindow);
		AboutEmailEdit.SetText(_T("Panda38@seznam.cz"));
		AboutPortfolioEdit.InitDlg(IDC_PORTFOLIO, &AboutWindow);
		AboutPortfolioEdit.SetText(_T("www.shutterstock.com/g/PandaWild"));
		AboutLicenseEdit.InitDlg(IDC_LICENSE, &AboutWindow);
		txt.LoadLongText(_T("LICENSE"));
		AboutLicenseEdit.SetText(txt);
		return TRUE;

	case WM_COMMAND:
		switch(HIWORD(wParam))
		{
		case 0:
		case 1:
			switch (LOWORD(wParam))
			{
			case IDOK:
			case IDCANCEL:
				::EndDialog(hWnd, LOWORD(wParam));
				return TRUE;
			}
			break;
		}
		break;
	}
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// info dialog

CWindow InfoWindow;
CEdit InfoEdit;

INT_PTR CALLBACK InfoProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_INITDIALOG:
		InfoWindow.SetHandle(hWnd);
		InfoEdit.InitDlg(IDC_EDIT, &InfoWindow);
		InfoEdit.SetText(FInfo);
		InfoEdit.Enable(EditMode);
		return TRUE;

	case WM_COMMAND:
		switch(HIWORD(wParam))
		{
		case 0:
		case 1:
			switch (LOWORD(wParam))
			{
			case IDOK:
				if (EditMode)
				{
					CText txt;
					txt = InfoEdit.GetText();
					if (txt != FInfo)
					{
						SetModi();
						FInfo = txt;
					}
				}
			case IDCANCEL:
				::EndDialog(hWnd, LOWORD(wParam));
				return TRUE;
			}
			break;
		}
		break;
	}
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// message service of main frame

LRESULT CALLBACK MainFrameProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	int wmId, wmEvent;

	// window messages
	switch (msg)
	{
	// close application
	case WM_CLOSE:
		if (CheckModi())
		{
			::DestroyWindow(MainFrame->Handle());
		}
		return 0;

	// notifications
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

			HWND ctrl = hdr->hwndFrom;
			if (ctrl != NULL)
			{
				if (SelectMode && (ctrl == GraphList.Box()->Handle())
					&& !GraphList.Box()->Filling()
					&& (hdr->code == LVN_ITEMCHANGED))
				{
					NMLISTVIEW* nm = (NMLISTVIEW*)lParam;
					if ((nm->uChanged & LVIF_STATE) &&
						(nm->uNewState & LVIS_SELECTED))
					{
						SelectGraph(GraphList.GetSelInx());
					}
					break;
				}

				if (SelectMode && (ctrl == VarList.Box()->Handle())
					&& !VarList.Box()->Filling()
					&& (hdr->code == LVN_ITEMCHANGED))
				{
					NMLISTVIEW* nm = (NMLISTVIEW*)lParam;
					if ((nm->uChanged & LVIF_STATE) &&
						(nm->uNewState & LVIS_SELECTED))
					{
						SelectVar(VarList.GetSelInx());
					}
					break;
				}
			}
		}
		break;

	// menu select
	case WM_MENUSELECT:
		if ((LOWORD(wParam) != 0) && ((HIWORD(wParam) & MF_POPUP) == 0))
		{
			CText txt;
			txt.Load(LOWORD(wParam));
			txt.Delete(0, txt.Find(_T('|'))+1);
			SetStatusText(txt);
		}
		else
			SetStatusText(EmptyText);
		return 0;

	// commands
	case WM_COMMAND:
		wmId    = LOWORD(wParam); 
		wmEvent = HIWORD(wParam); 

		if (wmEvent == LBN_SELCHANGE)
		{
			if (SelectMode)
			{
				if (((HWND)lParam == GroupList.Box()->Handle())
						&& !GroupList.Box()->Filling())
				{
					SelectGroup(GroupList.GetSelInx());
					break;
				}

				if (((HWND)lParam == OutSelBox.Handle())
						&& !OutSelBox.Filling())
				{
					PrevFilter = NULL;
					OutFilterInx = OutSelBox.GetSelect();
					if ((DWORD)OutFilterInx >= (DWORD)OutFilterNum) OutFilterInx = -1;
					WriteIniInt("Output", OutFilterInx);
					SPrevRenderStart();
					break;
				}
			}

			if (EditMode)
			{
				if (((HWND)lParam == GrpSelListBox.Handle())
						&& !GrpSelListBox.Filling())
				{
					SetGroupFSel(GrpSelListBox.GetSelect());
					break;
				}
			}

			if (((HWND)lParam == ZoomSelBox.Handle())
					&& !ZoomSelBox.Filling())
			{
				int n = ZoomSelBox.GetSelect();
				if ((DWORD)n < (DWORD)ZOOMNUM) SetZoom(n);
				break;
			}
		}

		// Parse the menu selections:
		switch (wmId)
		{
		// About
		case ID_ABOUT:
			::DialogBoxParam(Instance, MAKEINTRESOURCE(IDD_ABOUTBOX),
				MainFrame->Handle(), AboutProc, (LPARAM)0);
			break;

		// Help
		case ID_HELP:
			{
				if (SelectMode)
					HelpHelp(HELP_MAINFRAME);
				else
				{
					CFilter* f = EditCtrlF;
					if (f != NULL)
						HelpHelp(f->HelpID());
					else
						HelpHelp(HELP_EDITOR);
				}
			}
			break;

		case ID_HELP_CONTENT:
			HelpHelp(0);
			break;

		// create new group
		case ID_NEWGROUP:
			if (SelectMode)
			{
				::DialogBoxParam(Instance, MAKEINTRESOURCE(IDD_NEWGROUP),
					MainFrame->Handle(), NewGroupProc, (LPARAM)0);
			}
			break;

		// create new filter
		case ID_NEW:
			if (SelectMode)
			{
				if (::DialogBoxParam(Instance, MAKEINTRESOURCE(IDD_NEWFILTER),
					MainFrame->Handle(), NewFilterProc, (LPARAM)0) == IDOK)
					goto OPENNEWFILTER;
			}
			break;

		// set Czech language
		case ID_LANGUAGE_CZ:
			SetLanguage(LANG_CZ);
			break;

		// set English language
		case ID_LANGUAGE_EN:
			SetLanguage(LANG_EN);
			break;

 		// tiles
		case ID_TILES:
			if (SelectMode && !OutTilesCheck.Filling())
			{
				Tiles = !OutTilesCheck.GetCheck();
				OutTilesCheck.SetCheck(Tiles);
				WriteIniBool("Tiles", Tiles);
				SelectRedraw();
			}

			if (EditMode && !OutTilesCheck.Filling())
			{
				Tiles = !OutTilesCheck.GetCheck();
				OutTilesCheck.SetCheck(Tiles);
				WriteIniBool("Tiles", Tiles);
				EditRedraw();
			}
			break;

 		// lock
		case ID_LOCK:
			if (EditMode && !LockViewCheck.Filling())
			{
				Lock = !Lock;
				LockViewCheck.SetCheck(Lock);
				if (!Lock && (PrevFilter != EditCtrlF) && (EditCtrlF != NULL))
				{
					PrevFilter = EditCtrlF;
					EPrevRenderStart();
					DrawView();
					EditRedraw();
				}
				//WriteIniBool("Lock", Lock);
			}
			break;

		case ID_QUIT:
			if (CheckModi())
			{
				::DestroyWindow(MainFrame->Handle());
			}
			break;

		// open/close edit
		case ID_OPEN:
OPENNEWFILTER:
		case ID_CLOSE:
			PrevFilter = NULL;
			if (SelectMode)
			{
				CloseSelect();
				CreateEdit();
				ReloadMainMenu();
			}
			else
			{
				if (CheckModi())
				{
					CloseEdit();
					CreateSelect();
					ReloadMainMenu();
				}
			}
			break;

		case ID_SAVE:
		case ID_SAVEVAR:
			if (EditMode)
			{
				SaveGraph(GraphFilename);
			}
			if (SelectMode)
			{
				SaveVar();
				LoadVarList();
			}
			break;

		case ID_SAVEAS:
			if (EditMode) SaveGraphAs();
			break;

		case ID_INFO:
			::DialogBoxParam(Instance, MAKEINTRESOURCE(IDD_INFO),
				MainFrame->Handle(), InfoProc, (LPARAM)0);
			break;

		// delete
		case ID_DELETE:
			if (EditMode) EditDelete();
			if (SelectMode) SelectDelete();
			break;

		case ID_RENDER:
			OpenRender();
			break;

		case ID_DEFAULT:
			if (SelectMode)
			{
				LoadDefVar();
				SelectVar(-1);
			}
			break;

		case ID_GENERATE:
			if (SelectMode)
			{
				GenRandVar();
				SelectVar(-1);
			}
			break;

		case ID_MUTATE:
			if (SelectMode)
			{
				MutateVar();
				SelectVar(-1);
			}
			break;

		case ID_ZOOMIN:
			if (Zoom < ZOOMNUM-1) SetZoom(Zoom + 1);
			break;

		case ID_ZOOMOUT:
			if (Zoom > 0) SetZoom(Zoom - 1);
			break;

		case ID_VIEWLEFT:
			ViewShift(-1, 0);
			break;

		case ID_VIEWRIGHT:
			ViewShift(+1, 0);
			break;

		case ID_VIEWUP:
			ViewShift(0, +1);
			break;

		case ID_VIEWDOWN:
			ViewShift(0, -1);
			break;

		case ID_COPYPAR:
			if (EditMode) CopyParEdit();
			break;

		case ID_PASTEPAR:
			if (EditMode) PasteParEdit();
			break;

		case ID_COPYVAR:
			CopyVar();
			break;

		case ID_PASTEVAR:
			PasteVar();
			break;

		case ID_RENUM:
			RenumVar();
			break;

		case ID_LOCKINV:
			if (SelectMode) PropFrame.LockInv();
			break;

		//case ID_AUTOGENER:
		//	if (EditMode) AutoGener();
		//	break;

		case ID_PREV_STOP:		PreviewPriority = 0; goto PRIORUPDATE;
		case ID_PREV_IDLE:		PreviewPriority = 1; goto PRIORUPDATE;
		case ID_PREV_LOWEST:	PreviewPriority = 2; goto PRIORUPDATE;
		case ID_PREV_VERYLOW:	PreviewPriority = 3; goto PRIORUPDATE;
		case ID_PREV_LOW:		PreviewPriority = 4; goto PRIORUPDATE;
		case ID_PREV_LOWER:		PreviewPriority = 5; goto PRIORUPDATE;
		case ID_PREV_NORMAL:	PreviewPriority = 6;
PRIORUPDATE:
			MenuPrevPriorUpdate();
			WriteIniInt("PreviewPriority", PreviewPriority);
			UpdatePreviewPriority();
			break;

		case ID_PREV_DIM0:		PrevDim = 0; goto PREVDIMUPDATE;
		case ID_PREV_DIM1:		PrevDim = 1; goto PREVDIMUPDATE;
		case ID_PREV_DIM2:		PrevDim = 2; goto PREVDIMUPDATE;
		case ID_PREV_DIM3:		PrevDim = 3; goto PREVDIMUPDATE;
		case ID_PREV_DIM4:		PrevDim = 4; goto PREVDIMUPDATE;
		case ID_PREV_DIM5:		PrevDim = 5; goto PREVDIMUPDATE;
		case ID_PREV_DIM6:		PrevDim = 6; goto PREVDIMUPDATE;
		case ID_PREV_DIM7:		PrevDim = 7; goto PREVDIMUPDATE;
		case ID_PREV_DIM8:		PrevDim = 8; goto PREVDIMUPDATE;
		case ID_PREV_DIM9:		PrevDim = 9;
PREVDIMUPDATE:
			MenuPrevDimUpdate();
			WriteIniInt("PreviewDimension", PrevDim);
			ClearPrevBuf();
			SelectResize();
			SPrevRenderStart();
			break;

		case ID_PREV_DIM20:		PrevDim2 = 0; goto PREVDIMUPDATE2;
		case ID_PREV_DIM21:		PrevDim2 = 1; goto PREVDIMUPDATE2;
		case ID_PREV_DIM22:		PrevDim2 = 2; goto PREVDIMUPDATE2;
		case ID_PREV_DIM23:		PrevDim2 = 3;
PREVDIMUPDATE2:
			MenuPrevDimUpdate();
			WriteIniInt("PreviewDimension2", PrevDim2);
			ClearPrevBuf();
			EditResize();
			EPrevRenderStart();
			break;

/*		case ID_MARK_VAR:
			MarkVar = !MarkVar;
			CheckCmd(ID_MARK_VAR, MarkVar);
			WriteIniBool("MarkVar", MarkVar);
			break;

		case ID_MARK_ALL:
			if (SelectMode)
			{
				CText txt, txt2;
				txt.Load(ID_MARK_ALL2);
				txt2.Load(ID_MARK_ALL3);
				if (::MessageBox(MainFrame->Handle(), txt2, txt, MB_OKCANCEL) == IDOK)
				{
#define BMPICONSIZE (FPREVWH*FPREVWH*3+sizeof(BMPHEADER))
					int i;
					CText filename;
					u8 buf[BMPICONSIZE];
					for (i = 0; i < VarList.Num(); i++)
					{
						filename = VarList[i].ImgFileName();
						FILE* file = _tfopen(filename, _T("r+b"));
						if (file != NULL)
						{
							if (fread(buf, 1, BMPICONSIZE, file) == BMPICONSIZE)
							{
								if ((((BMPHEADER*)buf)->biWidth == FPREVWH) &&
									(((BMPHEADER*)buf)->biHeight == FPREVWH))
								{
									GenMark(buf + sizeof(BMPHEADER));
									fseek(file, 0, SEEK_SET);
									fwrite(buf, 1, BMPICONSIZE, file);
								}
							}
							fclose(file);
						}
					}
					LoadVarList();
				}
			}
			break;
*/
		}
		break;

	case WM_PAINT:
		{
			PAINTSTRUCT ps;
			HDC dc;
			dc = BeginPaint(hWnd, &ps);
			EndPaint(hWnd, &ps);

			SelectRedraw();
			EditRedraw();
		}
		break;

	case WM_DESTROY:
		::KillTimer(MainFrame->Handle(), TIMERID);
		::PostQuitMessage(0);
		break;

	case WM_MOVE:
		MainFrame->UpdateRect();
		break;

	case WM_SIZE:
		if (wParam != SIZE_MINIMIZED)
		{
			MainFrame->UpdateRect();
			if (SelectMode) SelectResize();
			if (EditMode) EditResize();
		}
		break;

	case WM_SIZING:
		{
			CRect* rc = (CRect*)lParam;
			if (rc->Width() < MAINFRAMEMINWIDTH) rc->SetWidth(MAINFRAMEMINWIDTH);
			if (rc->Height() < MAINFRAMEMINHEIGHT) rc->SetHeight(MAINFRAMEMINHEIGHT);
		}
		break;

	case WM_TIMER:
		PreviewStatTimer();
		if (PrevUpDisp && ((PrevStepN <= 4) || (PreviewPriority == 0))) RedrawPreview();
		if (FilterViewReq && EditMode)
		{
			DrawView();
			RepaintView();
		}
		PreviewProgress.SetVisible((PrevProg > 0) && (PrevProg < PrevProgN));
		PreviewProgress.SetPos(PrevProg*100/PrevProgN);
		break;

	case WM_HSCROLL:
	case WM_VSCROLL:
		{
			HWND wnd = (HWND)lParam;
			if (PropFrame.OnScroller(wnd, wParam)) break;

			if ((wnd == FGrpScroller.Handle()) && !FGrpScroller.Filling())
			{
				if (FGrpScroller.OnMsg(wParam, 100))
				{
					GroupFiltersTop[GroupFSel] = FGrpScroller.GetPos();
					EditGSelRedraw();
				}
			}

			if ((wnd == ViewHScroller.Handle()) && !ViewHScroller.Filling())
			{
				if (ViewHScroller.OnMsg(wParam, 100))
				{
					int old = ViewViewSX;
					ViewViewSX = ViewHScroller.GetPos();
					ViewViewX += ViewViewSX - old;
					ResizeView();
					EditRedraw();
				}
			}

			if ((wnd == ViewVScroller.Handle()) && !ViewVScroller.Filling())
			{
				if (ViewVScroller.OnMsg(wParam, 100))
				{
					int old = ViewViewSY;
					ViewViewSY = ViewVScroller.Max() - ViewVScroller.GetPos();
					ViewViewY += ViewViewSY - old;
					ResizeView();
					EditRedraw();
				}
			}
		}
		break;

	case WM_LBUTTONDBLCLK:
	case WM_MBUTTONUP:
	case WM_MBUTTONDOWN:
	case WM_RBUTTONUP:
	case WM_RBUTTONDOWN:
	case WM_LBUTTONUP:
	case WM_LBUTTONDOWN:
	case WM_MOUSEMOVE:
		if (EditMode)
		{
			int x = GET_X_LPARAM(lParam);
			int y = GET_Y_LPARAM(lParam);
			EditOnMouse(x, y, ((wParam & MK_LBUTTON) != 0), ((wParam & MK_RBUTTON) != 0), ((wParam & MK_MBUTTON) != 0), msg);
		}
		break;
	}
	return ::DefWindowProc(hWnd, msg, wParam, lParam);
}

/////////////////////////////////////////////////////////////////////////////
// create main frame (returns TRUE if success)

BOOL MainFrameCreate()
{
	// register window class
	WNDCLASS wcl;
	wcl.style = CS_OWNDC | CS_DBLCLKS;
	wcl.lpfnWndProc = MainFrameProc;
	wcl.cbClsExtra = 0;
	wcl.cbWndExtra = 0;
	wcl.hInstance = Instance;
	wcl.hIcon = ::LoadIcon(Instance, MAKEINTRESOURCE(IDI_MAINFRAME));
	wcl.hCursor = ::LoadCursor(NULL, IDC_ARROW);
	wcl.hbrBackground = NULL;
	wcl.lpszMenuName = NULL;
	wcl.lpszClassName = MainFrameClass;
	::RegisterClass(&wcl);

	// main frame position
	if (MainFrameWidth > ScreenWidth) MainFrameWidth = ScreenWidth;
	if (MainFrameWidth < MAINFRAMEMINWIDTH) MainFrameWidth = MAINFRAMEMINWIDTH;
	if (MainFrameHeight > ScreenHeight) MainFrameHeight = ScreenHeight;
	if (MainFrameHeight < MAINFRAMEMINHEIGHT) MainFrameHeight = MAINFRAMEMINHEIGHT;
	if (MainFrameLeft + MainFrameWidth < 20) MainFrameLeft = 20 - MainFrameWidth;
	if (MainFrameLeft > ScreenWidth - 20) MainFrameLeft = ScreenWidth - 20;
	if (MainFrameTop < 0) MainFrameTop = 0;
	if (MainFrameTop > ScreenHeight - 40) MainFrameTop = ScreenHeight - 40;

	// create main frame
	BOOL max = MainFrameMax;
	if (!MainFrame->CreateWin(MAINFRAME_STYLEEX,MainFrameClass,EmptyText,
			MAINFRAME_STYLE,MainFrameLeft,MainFrameTop,MainFrameWidth,MainFrameHeight,NULL,NULL))
			return FALSE;

	DefParentWin = MainFrame;

	// maximize window
	if (max) ::ShowWindow(MainFrame->Handle(), SW_SHOWMAXIMIZED);

	// create status line, tool tips and tool bar
	MainFrame->CreateStatus();
	MainFrame->CreateToolTip();
	MainFrame->CreateToolBar();

	// create progress bar
	MainFrame->Status()->SetPartNum(2);
	MainFrame->Status()->SetPartWidth(1, PREVBARW2);
	PreviewProgress.CreateBar(MainFrame->Status()->ClientWidth() - PREVBARW2 + 4, 4,
		TRUE, FALSE, PREVBARW, 15, MainFrame->Status());

	// create timer
	::SetTimer(MainFrame->Handle(), TIMERID, TIMERTIME, NULL);

	MainFrame->UpdateRect();
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set mainframe caption

void SetCaption()
{
	CText txt;
	if (EditMode)
	{
		txt = GraphFilename;
		int pos = txt.FindListRev(_T("\\:"), 2);
		if (pos >= 0) txt.Delete(0, pos+1);
		if (Modi) txt += TCHAR('*');
		txt += _T(" - ");
	}
	txt += "TexiGen";
	MainFrame->SetText(txt);
}
