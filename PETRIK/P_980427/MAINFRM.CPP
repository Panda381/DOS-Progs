// MainFrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "Peter.h"

#include "Select.h"
#include "Exec.h"
#include "IconBuf.h"
#include "TextBuf.h"
#include "RealBuf.h"
#include "BoolBuf.h"
#include "ProgBuf.h"
#include "MapBuf.h"
#include "EditDial.h"
#include "EditSprt.h"
#include "EditIcon.h"
#include "EditMap.h"
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

// definice textového pole k zobrazení souøadnic editoru ikony
#define	ICONBOX_INDEX	18			// index referenèního pole
#define ICONBOX_WIDTH	3*16		// šíøka referenèního pole
#define ICONBOX_HEIGHT	18			// výška referenèního pole

// definice polí v panelu plochy
#define MAP_INDEX		0			// poèáteèní index polí
#define MAPTEXT_WIDTH	3*16		// šíøka textu
#define MAPTEXT_HEIGHT	18			// výška textu
#define MAPEDIT_WIDTH	3*16		// šíøka editace
#define MAPEDIT_HEIGHT	18			// výška editace
#define MAPXY_WIDTH		5*16		// šíøka textu souøadnic
#define MAPXY_HEIGHT	18			// výška textu souøadnic

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
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_PEN, OnUpdateEditiconPen)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_ELIP, OnUpdateEditiconElip)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_FILL, OnUpdateEditiconFill)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_LINE, OnUpdateEditiconLine)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_PAINT, OnUpdateEditiconPaint)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_PIPE, OnUpdateEditiconPipe)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_RECT, OnUpdateEditiconRect)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_ROUND, OnUpdateEditiconRound)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_SELECT, OnUpdateEditiconSelect)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_SPRAY, OnUpdateEditiconSpray)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_XFLIP, OnUpdateEditiconXFlip)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_YFLIP, OnUpdateEditiconYFlip)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_RROT, OnUpdateEditiconRRot)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_LROT, OnUpdateEditiconLRot)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_XCOL, OnUpdateEditiconXCol)
	ON_COMMAND(IDC_EDITICON_ELIP, OnEditiconElip)
	ON_COMMAND(IDC_EDITICON_FILL, OnEditiconFill)
	ON_COMMAND(IDC_EDITICON_LINE, OnEditiconLine)
	ON_COMMAND(IDC_EDITICON_PAINT, OnEditiconPaint)
	ON_COMMAND(IDC_EDITICON_PEN, OnEditiconPen)
	ON_COMMAND(IDC_EDITICON_PIPE, OnEditiconPipe)
	ON_COMMAND(IDC_EDITICON_RECT, OnEditiconRect)
	ON_COMMAND(IDC_EDITICON_ROUND, OnEditiconRound)
	ON_COMMAND(IDC_EDITICON_SELECT, OnEditiconSelect)
	ON_COMMAND(IDC_EDITICON_SPRAY, OnEditiconSpray)
	ON_COMMAND(IDC_EDITICON_XFLIP, OnEditiconXFlip)
	ON_COMMAND(IDC_EDITICON_YFLIP, OnEditiconYFlip)
	ON_COMMAND(IDC_EDITICON_RROT, OnEditiconRRot)
	ON_COMMAND(IDC_EDITICON_LROT, OnEditiconLRot)
	ON_COMMAND(IDC_EDITICON_XCOL, OnEditiconXCol)
	//}}AFX_MSG_MAP
	// Global help commands
	ON_COMMAND(ID_HELP_FINDER, CFrameWnd::OnHelpFinder)
	ON_COMMAND(ID_HELP, CFrameWnd::OnHelp)
	ON_COMMAND(ID_CONTEXT_HELP, CFrameWnd::OnContextHelp)
	ON_COMMAND(ID_DEFAULT_HELP, CFrameWnd::OnHelpFinder)
//	ON_NOTIFY(NM_KILLFOCUS, IDC_EDITMAP_SIRKA_EDIT, OnKillFocusSirkaMap)
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
	m_wndToolBar.SetWindowText(_T("Program"));

// panel editace
	if (!m_wndEdiBar.Create(this) ||
		!m_wndEdiBar.LoadToolBar(IDR_EDIT))
	{
		return -1;      // fail to create
	}
	m_wndEdiBar.SetWindowText(_T("Úpravy"));


// panel editace ikon
	if (!m_wndIconBar.Create(this) ||
		!m_wndIconBar.LoadToolBar(IDR_EDITICON))
	{
		return -1;      // fail to create
	}
	m_wndIconBar.SetWindowText(_T("Kreslení"));

	CRect rect33(-ICONBOX_WIDTH, -ICONBOX_HEIGHT, 0, 0);
	if (!m_IconBox.Create(_T(""),WS_CHILD | SS_CENTER, rect33, &m_wndIconBar, IDC_EDITICON_XY))
	{
		return -1;
	}
	m_wndIconBar.SetButtonInfo(ICONBOX_INDEX-1, 0, TBBS_SEPARATOR, 1);
	m_wndIconBar.SetButtonInfo(ICONBOX_INDEX, IDC_EDITICON_XY, TBBS_SEPARATOR, ICONBOX_WIDTH);
	m_wndIconBar.SetButtonInfo(ICONBOX_INDEX+1, 0, TBBS_SEPARATOR, 1);
	if (m_IconBox.m_hWnd != NULL)
	{
		m_wndIconBar.GetItemRect(ICONBOX_INDEX, rect33);
		m_IconBox.SetWindowPos(NULL, rect33.left, rect33.top+3, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_IconBox.ShowWindow(SW_SHOW);
	}

// panel editace ploch
	if (!m_wndMapBar.Create(this) ||
		!m_wndMapBar.LoadToolBar(IDR_EDITMAP))
	{
		return -1;      // fail to create
	}
	m_wndMapBar.SetWindowText(_T("Plocha"));



	CRect rect34(-MAPTEXT_WIDTH, -MAPTEXT_HEIGHT, 0, 0);
	if (!m_MapSirkaText.Create(_T("šíøka"),WS_CHILD | SS_CENTER, rect34, &m_wndMapBar, IDC_EDITMAP_SIRKA_TEXT))
	{
		return -1;
	}
	m_wndMapBar.SetButtonInfo(MAP_INDEX, IDC_EDITMAP_SIRKA_TEXT, TBBS_SEPARATOR, MAPTEXT_WIDTH);
	if (m_MapSirkaText.m_hWnd != NULL)
	{
		m_wndMapBar.GetItemRect(MAP_INDEX, rect34);
		m_MapSirkaText.SetWindowPos(NULL, rect34.left, rect34.top+3, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_MapSirkaText.ShowWindow(SW_SHOW);
	}


	CRect rect24(-MAPEDIT_WIDTH, -MAPEDIT_HEIGHT, 0, 0);
	if (!m_MapSirkaEdit.Create(WS_CHILD | ES_AUTOHSCROLL, rect24, &m_wndMapBar, IDC_EDITMAP_SIRKA_EDIT))
	{
		return -1;
	}
	m_MapSirkaEdit.ModifyStyleEx(0,WS_EX_CLIENTEDGE,SWP_DRAWFRAME);

	HFONT hFont4 = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
	if (hFont4 == NULL)
		hFont4 = (HFONT)GetStockObject(ANSI_VAR_FONT);
	m_MapSirkaEdit.SendMessage(WM_SETFONT, (WPARAM)hFont4);

	m_wndMapBar.SetButtonInfo(MAP_INDEX+1, IDC_EDITMAP_SIRKA_EDIT, TBBS_SEPARATOR, MAPEDIT_WIDTH);
	if (m_MapSirkaEdit.m_hWnd != NULL)
	{
		m_wndMapBar.GetItemRect(MAP_INDEX+1, rect24);
		m_MapSirkaEdit.SetWindowPos(NULL, rect24.left, rect24.top+2, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_MapSirkaEdit.ShowWindow(SW_SHOW);
	}


	CRect rect35(-MAPTEXT_WIDTH, -MAPTEXT_HEIGHT, 0, 0);
	if (!m_MapVyskaText.Create(_T("výška"),WS_CHILD | SS_CENTER, rect35, &m_wndMapBar, IDC_EDITMAP_VYSKA_TEXT))
	{
		return -1;
	}
	m_wndMapBar.SetButtonInfo(MAP_INDEX+3, IDC_EDITMAP_VYSKA_TEXT, TBBS_SEPARATOR, MAPTEXT_WIDTH);
	if (m_MapVyskaText.m_hWnd != NULL)
	{
		m_wndMapBar.GetItemRect(MAP_INDEX+3, rect35);
		m_MapVyskaText.SetWindowPos(NULL, rect35.left, rect35.top+3, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_MapVyskaText.ShowWindow(SW_SHOW);
	}


	CRect rect25(-MAPEDIT_WIDTH, -MAPEDIT_HEIGHT, 0, 0);
	if (!m_MapVyskaEdit.Create(WS_CHILD | ES_AUTOHSCROLL, rect25, &m_wndMapBar, IDC_EDITMAP_VYSKA_EDIT))
	{
		return -1;
	}
	m_MapVyskaEdit.ModifyStyleEx(0,WS_EX_CLIENTEDGE,SWP_DRAWFRAME);

	HFONT hFont5 = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
	if (hFont5 == NULL)
		hFont5 = (HFONT)GetStockObject(ANSI_VAR_FONT);
	m_MapVyskaEdit.SendMessage(WM_SETFONT, (WPARAM)hFont5);

	m_wndMapBar.SetButtonInfo(MAP_INDEX+4, IDC_EDITMAP_VYSKA_EDIT, TBBS_SEPARATOR, MAPEDIT_WIDTH);
	if (m_MapVyskaEdit.m_hWnd != NULL)
	{
		m_wndMapBar.GetItemRect(MAP_INDEX+4, rect25);
		m_MapVyskaEdit.SetWindowPos(NULL, rect25.left, rect25.top+2, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_MapVyskaEdit.ShowWindow(SW_SHOW);
	}


	CRect rect36(-MAPXY_WIDTH, -MAPXY_HEIGHT, 0, 0);
	if (!m_MapXY.Create(_T(""),WS_CHILD | SS_CENTER, rect36, &m_wndMapBar, IDC_EDITMAP_XY))
	{
		return -1;
	}
	m_wndMapBar.SetButtonInfo(MAP_INDEX+6, IDC_EDITMAP_XY, TBBS_SEPARATOR, MAPXY_WIDTH);
	if (m_MapXY.m_hWnd != NULL)
	{
		m_wndMapBar.GetItemRect(MAP_INDEX+6, rect36);
		m_MapXY.SetWindowPos(NULL, rect36.left, rect36.top+3, 0, 0, 
			SWP_NOZORDER | SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOCOPYBITS);
		m_MapXY.ShowWindow(SW_SHOW);
	}


// panel vlastností
	if (!m_wndPropBar.Create(this) ||
		!m_wndPropBar.LoadToolBar(IDR_PROP))
	{
		return -1;      // fail to create
	}
	m_wndPropBar.SetWindowText(_T("Vlastnosti"));

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
	m_wndNavBar.SetWindowText(_T("Navigace"));

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
	if (!m_RefBox.Create(_T(""),WS_CHILD | SS_CENTER, rect3, &m_wndNavBar, IDC_PROG_REFER))
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

	m_wndNavBar.GetWindowRect(&rect);
	rect.OffsetRect(-rect.left + 200,rect.bottom - rect.top);
	m_wndIconBar.SetBarStyle(m_wndIconBar.GetBarStyle() |
		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
	m_wndIconBar.EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndIconBar,(UINT)0,&rect);
	RecalcLayout();

//	m_wndIconBar.GetWindowRect(&rect);
//	rect.OffsetRect(rect.right - rect.left + TOOLSPACE,0);
	m_wndMapBar.SetBarStyle(m_wndMapBar.GetBarStyle() |
		CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC);
	m_wndMapBar.EnableDocking(CBRS_ALIGN_ANY);
	DockControlBar(&m_wndMapBar,(UINT)0,&rect);
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
		ShowControlBar(&m_wndEdiBar,FALSE,TRUE);
//		m_wndEdiBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndPropBar,FALSE,TRUE);
//		m_wndPropBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndNavBar,FALSE,TRUE);
//		m_wndNavBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndIconBar,FALSE,TRUE);
//		m_wndIconBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndMapBar,FALSE,TRUE);
	
		break;

	case PageExec:
		m_PageExec = m_Page;					// úschova pøedešlé stránky
		pNewViewClass = RUNTIME_CLASS(CExec);
		resID = IDR_EXEC;
		m_wndStatusBar.SetIndicators(StatExec,
		  sizeof(StatExec)/sizeof(UINT));
		ShowControlBar(&m_wndEdiBar,FALSE,TRUE);
//		m_wndEdiBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndPropBar,FALSE,TRUE);
//		m_wndPropBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndNavBar,FALSE,TRUE);
//		m_wndNavBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndIconBar,FALSE,TRUE);
//		m_wndIconBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndMapBar,FALSE,TRUE);
		break;

	case PageProg:
		pNewViewClass = RUNTIME_CLASS(CProg);
		resID = IDR_PROG;
		m_wndStatusBar.SetIndicators(StatProg,
		  sizeof(StatProg)/sizeof(UINT));
		ShowControlBar(&m_wndEdiBar,TRUE,TRUE);
//		m_wndEdiBar.ShowWindow(TRUE);
		ShowControlBar(&m_wndPropBar,TRUE,TRUE);
//		m_wndPropBar.ShowWindow(TRUE);
		ShowControlBar(&m_wndNavBar,TRUE,TRUE);
//		m_wndNavBar.ShowWindow(TRUE);
		ShowControlBar(&m_wndIconBar,FALSE,TRUE);
//		m_wndIconBar.ShowWindow(FALSE);
		ShowControlBar(&m_wndMapBar,FALSE,TRUE);
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

				if (wnd->m_hWnd == m_MapSirkaEdit.m_hWnd)
				{
					if (Prog != NULL)
					{
						Prog->m_Buf[Prog->m_AktBufID].m_Tree->SetFocus();
						if (pMsg->wParam == VK_RETURN)
							Prog->m_ProgMap.OnSetMapSirka();
						else
							Prog->m_ProgMap.DispSirkaVyska();
					}
					return TRUE;
				}

				if (wnd->m_hWnd == m_MapVyskaEdit.m_hWnd)
				{
					if (Prog != NULL)
					{
						Prog->m_Buf[Prog->m_AktBufID].m_Tree->SetFocus();
						if (pMsg->wParam == VK_RETURN)
							Prog->m_ProgMap.OnSetMapVyska();
						else
							Prog->m_ProgMap.DispSirkaVyska();
					}
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


/////////////////////////////////////////////////////////////////////////////
// panel nástrojù editoru

void CMainFrame::OnUpdateEditiconElip(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeElip); }

void CMainFrame::OnUpdateEditiconFill(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeFill); }

void CMainFrame::OnUpdateEditiconLine(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeLine); }

void CMainFrame::OnUpdateEditiconPaint(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModePaint); }

void CMainFrame::OnUpdateEditiconPen(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModePen); }

void CMainFrame::OnUpdateEditiconPipe(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModePipe); }

void CMainFrame::OnUpdateEditiconRect(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeRect); }

void CMainFrame::OnUpdateEditiconRound(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeRound); }

void CMainFrame::OnUpdateEditiconSelect(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeSelect); }

void CMainFrame::OnUpdateEditiconSpray(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeSpray); }

void CMainFrame::OnUpdateEditiconXFlip(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeXFlip); }

void CMainFrame::OnUpdateEditiconYFlip(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeYFlip); }

void CMainFrame::OnUpdateEditiconRRot(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeRRot); }

void CMainFrame::OnUpdateEditiconLRot(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeLRot); }

void CMainFrame::OnUpdateEditiconXCol(CCmdUI* pCmdUI) 
	{ OnUpdateEditicon(pCmdUI, EditModeXCol); }

void CMainFrame::OnUpdateEditicon(CCmdUI* pCmdUI, int mode) 
{
	if (Prog != NULL)
		if (Prog->m_ProgPic.m_EditMode == mode)
			pCmdUI->SetCheck(1);
		else
			pCmdUI->SetCheck(0);
}

void CMainFrame::OnEditiconElip() 
	{ OnEditicon(EditModeElip); }

void CMainFrame::OnEditiconFill() 
	{ OnEditicon(EditModeFill); }

void CMainFrame::OnEditiconLine() 
	{ OnEditicon(EditModeLine); }

void CMainFrame::OnEditiconPaint() 
	{ OnEditicon(EditModePaint); }

void CMainFrame::OnEditiconPen() 
	{ OnEditicon(EditModePen); }

void CMainFrame::OnEditiconPipe() 
	{ OnEditicon(EditModePipe); }

void CMainFrame::OnEditiconRect() 
	{ OnEditicon(EditModeRect); }

void CMainFrame::OnEditiconRound() 
	{ OnEditicon(EditModeRound); }

void CMainFrame::OnEditiconSelect() 
	{ OnEditicon(EditModeSelect); }

void CMainFrame::OnEditiconSpray() 
	{ OnEditicon(EditModeSpray); }

void CMainFrame::OnEditiconXFlip() 
	{ OnEditicon(EditModeXFlip); }

void CMainFrame::OnEditiconYFlip() 
	{ OnEditicon(EditModeYFlip); }

void CMainFrame::OnEditiconRRot() 
	{ OnEditicon(EditModeRRot); }

void CMainFrame::OnEditiconLRot() 
	{ OnEditicon(EditModeLRot); }

void CMainFrame::OnEditiconXCol() 
	{ OnEditicon(EditModeXCol); }

void CMainFrame::OnEditicon(int mode) 
{
	if (Prog != NULL)
		Prog->m_ProgPic.SetEditMode(mode);
}

//void CMainFrame::OnKillFocusSirkaMap(NMHDR* pNMHDR, LRESULT* pResult)
//{
//	
//	*pResult = 0;
//}

