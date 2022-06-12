// MainFrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "Peter.h"

#include "Select.h"
#include "Exec.h"
#include "IconBuf.h"
#include "TextBuf.h"
#include "ProgBuf.h"
#include "Prog.h"
#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

// definice editaèního pole v panelu vlastností
#define	EDITBOX_INDEX	4			// index editaèního pole
#define	EDITBOX_WIDTH	10*16		// šíøka editaèního pole
#define	EDITBOX_HEIGHT	18			// výška editaèního pole

// definice editaèního pole textu k hledání
#define	FINDBOX_INDEX	0			// index editaèního pole
#define	FINDBOX_WIDTH	6*16		// šíøka editaèního pole
#define	FINDBOX_HEIGHT	18			// výška editaèního pole

// definice textového pole k zobrazení referencí
#define	REFBOX_INDEX	5			// index referenèního pole
#define REFBOX_WIDTH	2*16		// šíøka referenèního pole
#define REFBOX_HEIGHT	18			// výška referenèního pole

#define TOOLSPACE		2			// mezera mezi toolbar

/////////////////////////////////////////////////////////////////////////////
// CMainFrame

IMPLEMENT_DYNCREATE(CMainFrame, CFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CFrameWnd)
	//{{AFX_MSG_MAP(CMainFrame)
	ON_WM_CREATE()
	ON_COMMAND(IDR_EXEC, OnExec)
	ON_COMMAND(IDR_SELECT, OnSelect)
	ON_COMMAND(ID_START, OnStart)
	ON_COMMAND(ID_STOP, OnStop)
	ON_COMMAND(ID_FILE_OPEN2, OnFileOpen)
	ON_COMMAND(ID_FILE_CLOSE2, OnFileClose)
	ON_COMMAND(IDR_PROG, OnProg)
	ON_WM_CLOSE()
	ON_WM_SHOWWINDOW()
	ON_COMMAND(ID_FILE_NEW2, OnFileNew2)
	//}}AFX_MSG_MAP
	// Global help commands
	ON_COMMAND(ID_HELP_FINDER, CFrameWnd::OnHelpFinder)
	ON_COMMAND(ID_HELP, CFrameWnd::OnHelp)
	ON_COMMAND(ID_CONTEXT_HELP, CFrameWnd::OnContextHelp)
	ON_COMMAND(ID_DEFAULT_HELP, CFrameWnd::OnHelpFinder)
END_MESSAGE_MAP()

static UINT StatSelect[] =
{
	ID_SEPARATOR,           // status line indicator
};

static UINT StatProg[] =
{
	ID_SEPARATOR,           // status line indicator
//	ID_INDICATOR_POS,
//	ID_INDICATOR_OVR,
};

static UINT StatExec[] =
{
	ID_SEPARATOR,           // status line indicator
};

/////////////////////////////////////////////////////////////////////////////
// CMainFrame construction/destruction

CMainFrame::CMainFrame()
{
	m_Page = PageNone;
	m_PageExec = PageSelect;
}

CMainFrame::~CMainFrame()
{
}

int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
// nastavení rozmìrù a pozice hlavního okna
	RECT rc;
	rc.left = (ScreenWidth*MainLeft+Scale/2)/Scale;
	rc.top = (ScreenHeight*MainTop+Scale/2)/Scale;
	rc.right = rc.left + (ScreenWidth*MainWidth+Scale/2)/Scale;
	rc.bottom = rc.top + (ScreenHeight*MainHeight+Scale/2)/Scale;
	if (rc.right < 30) rc.right = 30;
	if (rc.left > ScreenWidth-30) rc.left = ScreenWidth-30;
	if (rc.top > ScreenHeight-30) rc.top = ScreenHeight-30;
	MoveWindow(&rc, FALSE);

	if (CFrameWnd::OnCreate(lpCreateStruct) == -1)
		return -1;

// panel programu (soubory)
	if (!m_wndToolBar.Create(this) ||
		!m_wndToolBar.LoadToolBar(IDR_SELECT))
	{
		return -1;      // fail to create
	}
	m_wndToolBar.SetWindowText("Program");

// panel editace
	if (!m_wndEdiBar.Create(this) ||
		!m_wndEdiBar.LoadToolBar(IDR_EDIT))
	{
		return -1;      // fail to create
	}
	m_wndEdiBar.SetWindowText("Úpravy");


// panel vlastností
	if (!m_wndPropBar.Create(this) ||
		!m_wndPropBar.LoadToolBar(IDR_PROP))
	{
		return -1;      // fail to create
	}
	m_wndPropBar.SetWindowText("Vlastnosti");

	CRect rect2(-EDITBOX_WIDTH, -EDITBOX_HEIGHT, 0, 0);
	if (!m_NameBox.Create(WS_CHILD | ES_AUTOHSCROLL, rect2, &m_wndPropBar, IDC_PROG_EDIT))
	{
		return -1;
	}
	m_NameBox.ModifyStyleEx(0,WS_EX_CLIENTEDGE,SWP_DRAWFRAME);

	HFONT hFont = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
	if (hFont == NULL)
		hFont = (HFONT)GetStockObject(ANSI_VAR_FONT);
	m_NameBox.SendMessage(WM_SETFONT, (WPARAM)hFont);

	m_wndPropBar.SetButtonInfo(EDITBOX_INDEX, IDC_PROG_EDIT, TBBS_SEPARATOR, EDITBOX_WIDTH);
	if (m_NameBox.m_hWnd != NULL)
	{
		m_wndPropBar.GetItemRect(EDITBOX_INDEX, rect2);
		m_NameBox.SetWindowPos(NULL, rect2.left, rect2.top+2, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_NameBox.ShowWindow(SW_SHOW);
	}

// panel navigace
	if (!m_wndNavBar.Create(this) ||
		!m_wndNavBar.LoadToolBar(IDR_NAVIG))
	{
		return -1;      // fail to create
	}
	m_wndNavBar.SetWindowText("Navigace");

	CRect rect4(-FINDBOX_WIDTH, -FINDBOX_HEIGHT, 0, 0);
	if (!m_FindBox.Create(WS_CHILD | ES_AUTOHSCROLL, rect4, &m_wndNavBar, IDC_PROG_FIND))
	{
		return -1;
	}
	m_FindBox.ModifyStyleEx(0,WS_EX_CLIENTEDGE,SWP_DRAWFRAME);

	hFont = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
	if (hFont == NULL)
		hFont = (HFONT)GetStockObject(ANSI_VAR_FONT);
	m_FindBox.SendMessage(WM_SETFONT, (WPARAM)hFont);

	m_wndNavBar.SetButtonInfo(FINDBOX_INDEX, IDC_PROG_FIND, TBBS_SEPARATOR, FINDBOX_WIDTH);
	if (m_FindBox.m_hWnd != NULL)
	{
		m_wndNavBar.GetItemRect(FINDBOX_INDEX, rect4);
		m_FindBox.SetWindowPos(NULL, rect4.left, rect4.top+2, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_FindBox.SetWindowText(FindString);
		m_FindBox.ShowWindow(SW_SHOW);
	}

	CRect rect3(-REFBOX_WIDTH, -REFBOX_HEIGHT, 0, 0);
	if (!m_RefBox.Create("",WS_CHILD | SS_CENTER, rect3, &m_wndNavBar, IDC_PROG_REFER))
	{
		return -1;
	}
	m_wndNavBar.SetButtonInfo(REFBOX_INDEX-1, 0, TBBS_SEPARATOR, 1);
	m_wndNavBar.SetButtonInfo(REFBOX_INDEX, IDC_PROG_REFER, TBBS_SEPARATOR, REFBOX_WIDTH);
	m_wndNavBar.SetButtonInfo(REFBOX_INDEX+1, 0, TBBS_SEPARATOR, 1);
	if (m_RefBox.m_hWnd != NULL)
	{
		m_wndNavBar.GetItemRect(REFBOX_INDEX, rect3);
		m_RefBox.SetWindowPos(NULL, rect3.left, rect3.top+3, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_RefBox.ShowWindow(SW_SHOW);
	}

// stavový panel
	if (!m_wndStatusBar.Create(this) ||
		!m_wndStatusBar.SetIndicators(StatSelect,
		  sizeof(StatSelect)/sizeof(UINT)))
	{
		TRACE0("Failed to create status bar\n");
		return -1;      // fail to create
	}

	RecalcLayout();

	EnableDocking(CBRS_ALIGN_ANY);

	m_wndToolBar.SetBarStyle(m_wndToolBar.GetBarStyle() |
		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
	m_wndToolBar.EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndToolBar);
	RecalcLayout();

	CRect rect;

	m_wndToolBar.GetWindowRect(&rect);
	rect.OffsetRect(rect.right - rect.left + TOOLSPACE,0);
	m_wndEdiBar.SetBarStyle(m_wndEdiBar.GetBarStyle() |
		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
	m_wndEdiBar.EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndEdiBar,(UINT)0,&rect);
	RecalcLayout();


	m_wndEdiBar.GetWindowRect(&rect);
	rect.OffsetRect(rect.right - rect.left + TOOLSPACE,0);
	m_wndPropBar.SetBarStyle(m_wndPropBar.GetBarStyle() |
		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
	m_wndPropBar.EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndPropBar,(UINT)0,&rect);
	RecalcLayout();


	m_wndPropBar.GetWindowRect(&rect);
	rect.OffsetRect(rect.right - rect.left + TOOLSPACE,0);
	m_wndNavBar.SetBarStyle(m_wndNavBar.GetBarStyle() |
		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
	m_wndNavBar.EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndNavBar,(UINT)0,&rect);
	RecalcLayout();



//	m_wndObjBar.GetWindowRect(&rect);
//	rect.OffsetRect(150,0);
//	m_wndStrucBar.SetBarStyle(m_wndStrucBar.GetBarStyle() |
//		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
//	m_wndStrucBar.EnableDocking(CBRS_ALIGN_ANY);
//	DockControlBar(&m_wndStrucBar,(UINT)0,&rect);

//	RecalcLayout();


//	if (Maximized)
//		ShowWindow(SW_SHOWMAXIMIZED);


//	LoadBarState(_T("General"));

	return 0;
}

/////////////////////////////////////////////////////////////////////////////
// CMainFrame diagnostics

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
	CFrameWnd::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
	CFrameWnd::Dump(dc);
}

#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// nastavení nové stránky

void CMainFrame::OnSelect() 
{
	SetPage(PageSelect);
}

void CMainFrame::OnExec() 
{
	SetPage(PageExec);
}

void CMainFrame::OnProg() 
{
	SetPage(PageProg);
}

void CMainFrame::OnStop() 
{
	SetPage(m_PageExec);
}

void CMainFrame::SetPage(Pages page)
{
// pokraèovat, jen je-li stránka opravdu zmìnìna
	if (page == m_Page) return;

	CView* pOldActiveView = GetActiveView();

	CRuntimeClass* pNewViewClass;
	int resID;

// pøíprava definice nové stránky
	switch (page)
	{
	case PageSelect:
		pNewViewClass = RUNTIME_CLASS(CSelect);
		resID = IDR_SELECT;
		m_wndStatusBar.SetIndicators(StatSelect,
		  sizeof(StatSelect)/sizeof(UINT));
		m_wndEdiBar.ShowWindow(FALSE);
		m_wndPropBar.ShowWindow(FALSE);
		m_wndNavBar.ShowWindow(FALSE);
		break;

	case PageExec:
		m_PageExec = m_Page;					// úschova pøedešlé stránky
		pNewViewClass = RUNTIME_CLASS(CExec);
		resID = IDR_EXEC;
		m_wndStatusBar.SetIndicators(StatExec,
		  sizeof(StatExec)/sizeof(UINT));
		m_wndEdiBar.ShowWindow(FALSE);
		m_wndPropBar.ShowWindow(FALSE);
		m_wndNavBar.ShowWindow(FALSE);
		break;

	case PageProg:
		pNewViewClass = RUNTIME_CLASS(CProg);
		resID = IDR_PROG;
		m_wndStatusBar.SetIndicators(StatProg,
		  sizeof(StatProg)/sizeof(UINT));
		m_wndEdiBar.ShowWindow(TRUE);
		m_wndPropBar.ShowWindow(TRUE);
		m_wndNavBar.ShowWindow(TRUE);
		break;
	
	default:
		return;
	}

// naètení nástrojového panelu
	m_wndToolBar.LoadToolBar(resID);

// naètení tabulky akcelerátorù
	m_hAccelTable = NULL;
	LoadAccelTable(MAKEINTRESOURCE(resID));

// naètení hlavního menu
	HMENU hMenu;
	hMenu = ::GetMenu(m_hWnd);
	HMENU hMenuN;
	hMenuN = ::LoadMenu(AfxGetApp()->m_hInstance,MAKEINTRESOURCE(resID));
	if (hMenuN != NULL)
	{
		if (hMenu != NULL) 
			::DestroyMenu(hMenu);
		::SetMenu(m_hWnd,hMenuN);
		m_hMenuDefault = hMenuN;
	}

	m_Page = page;

	CCreateContext context;
	context.m_pNewViewClass = pNewViewClass;
	context.m_pCurrentDoc = GetActiveDocument();
	CView* pNewView = STATIC_DOWNCAST(CView, CreateView(&context));
	if (pNewView != NULL)
	{
		pNewView->ShowWindow(SW_SHOW);
		pNewView->OnInitialUpdate();
		SetActiveView(pNewView);
		RecalcLayout();
		pOldActiveView->DestroyWindow();
	}
}


void CMainFrame::OnFileClose() 
{
	OnSelect();	
}

void CMainFrame::OnStart() 
{
	OnExec();
}

void CMainFrame::OnFileOpen() 
{
	OnProg();	
}

void CMainFrame::OnClose() 
{
//	SaveBarState(_T("General"));

// úschova rozmìrù hlavního okna
	WINDOWPLACEMENT wp;
	GetWindowPlacement(&wp);
	RECT rc = wp.rcNormalPosition;

	MainLeft = (rc.left*Scale+ScreenWidth/2)/ScreenWidth;
	MainTop = (rc.top*Scale+ScreenHeight/2)/ScreenHeight;
	MainWidth = ((rc.right-rc.left)*Scale+ScreenWidth/2)/ScreenWidth;
	MainHeight = ((rc.bottom-rc.top)*Scale+ScreenHeight/2)/ScreenHeight;

	Maximized = IsZoomed();

	CFrameWnd::OnClose();
}


void CMainFrame::OnShowWindow(BOOL bShow, UINT nStatus) 
{
	CFrameWnd::OnShowWindow(bShow, nStatus);

	if (Maximized && bShow)
		ShowWindow(SW_SHOWMAXIMIZED);
}


void CMainFrame::OnFileNew2() 
{
	
}


BOOL CMainFrame::PreTranslateMessage(MSG* pMsg) 
{
	if (pMsg->message == WM_KEYDOWN)
	{
		if ((pMsg->wParam == VK_RETURN) || (pMsg->wParam == VK_TAB) || (pMsg->wParam == VK_ESCAPE))
		{
			CWnd* wnd = GetFocus();
			if (wnd != NULL)
			{
				if (wnd->m_hWnd == m_NameBox.m_hWnd)
				{
					if (Prog != NULL)
						Prog->m_Buf[Prog->m_AktBufID].m_Tree->SetFocus();
					return TRUE;
				}

				if (wnd->m_hWnd == m_FindBox.m_hWnd)
				{
					if (Prog != NULL)
					{
						Prog->m_Buf[Prog->m_AktBufID].m_Tree->SetFocus();
						if (pMsg->wParam == VK_RETURN)
							Prog->OnFindNext();
					}
					return TRUE;
				}
			}
		}
	}
	
	return CFrameWnd::PreTranslateMessage(pMsg);
}

