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

/////////////////////////////////////////////////////////////////////////////
// CMainFrame

IMPLEMENT_DYNCREATE(CMainFrame, CFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CFrameWnd)
	//{{AFX_MSG_MAP(CMainFrame)
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_COMMAND(IDR_EXEC, OnExec)
	ON_COMMAND(IDR_SELECT, OnSelect)
	ON_COMMAND(ID_START, OnStart)
	ON_COMMAND(ID_STOP, OnStop)
	ON_COMMAND(ID_FILE_OPEN2, OnFileOpen)
	ON_COMMAND(ID_FILE_CLOSE2, OnFileClose)
	ON_COMMAND(IDR_PROG, OnProg)
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
	MoveWindow(0,0,::GetSystemMetrics(SM_CXSCREEN)*15/16,
		::GetSystemMetrics(SM_CYSCREEN)*9/10,FALSE);

	if (CFrameWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
	
	if (!m_wndToolBar.Create(this) ||
		!m_wndToolBar.LoadToolBar(IDR_SELECT))
	{
		return -1;      // fail to create
	}

	if (!m_wndObjBar.Create(this) ||
		!m_wndObjBar.LoadToolBar(IDR_OBJECT))
	{
		return -1;      // fail to create
	}

//	if (!m_wndStrucBar.Create(this) ||
//		!m_wndStrucBar.LoadToolBar(IDR_STRUC))
//	{
//		return -1;      // fail to create
//	}

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
	rect.OffsetRect(250,0);
	m_wndObjBar.SetBarStyle(m_wndObjBar.GetBarStyle() |
		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
	m_wndObjBar.EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndObjBar,(UINT)0,&rect);

	RecalcLayout();
//	m_wndObjBar.GetWindowRect(&rect);
//	rect.OffsetRect(150,0);
//	m_wndStrucBar.SetBarStyle(m_wndStrucBar.GetBarStyle() |
//		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
//	m_wndStrucBar.EnableDocking(CBRS_ALIGN_ANY);
//	DockControlBar(&m_wndStrucBar,(UINT)0,&rect);

//	RecalcLayout();

	CenterWindow();

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
// CMainFrame message handlers

void CMainFrame::OnSize(UINT nType, int cx, int cy) 
{
	CFrameWnd::OnSize(nType, cx, cy);
	
//	if (m_Select.m_hWnd == NULL || m_wndStatusBar.m_hWnd == NULL
//		|| m_wndToolBar.m_hWnd == NULL) return;

//	CRect rect;
//	CRect rect2;
//	GetClientRect(&rect);
//	m_wndToolBar.GetWindowRect(&rect2);
//	ScreenToClient(&rect2);
//	rect.top = rect2.bottom;
//	m_wndStatusBar.GetWindowRect(&rect2);
//	ScreenToClient(&rect2);
//	rect.bottom = rect2.top-2;
//	m_Select.MoveWindow(&rect,TRUE);

//	m_Select.EnableWindow();
//	(m_Select.GetDlgItem(IDC_CHECK1))->EnableWindow();

	
}


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
//		m_wndStrucBar.ShowWindow(FALSE);
		m_wndObjBar.ShowWindow(FALSE);
		break;

	case PageExec:
		m_PageExec = m_Page;					// úschova pøedešlé stránky
		pNewViewClass = RUNTIME_CLASS(CExec);
		resID = IDR_EXEC;
		m_wndStatusBar.SetIndicators(StatExec,
		  sizeof(StatExec)/sizeof(UINT));
//		m_wndStrucBar.ShowWindow(FALSE);
		m_wndObjBar.ShowWindow(FALSE);
		break;

	case PageProg:
		pNewViewClass = RUNTIME_CLASS(CProg);
		resID = IDR_PROG;
		m_wndStatusBar.SetIndicators(StatProg,
		  sizeof(StatProg)/sizeof(UINT));
//		m_wndStrucBar.ShowWindow(TRUE);
		m_wndObjBar.ShowWindow(TRUE);
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

