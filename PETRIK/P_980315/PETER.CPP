// Peter.cpp : Defines the class behaviors for the application.
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
#include "PetrDoc.h"

//#include "PetrView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// globální promìnné

CString	Jmeno;				// jméno editovaného programu (bez cesty a bez pøípony)
int SelectWidth;			// šíøka pole pro výbìr objektu a tøidy
HPALETTE StdPalette;		// vlastní palety
BITMAPINFO* StdBitmapInfo;		// standardní záhlaví BMP

/////////////////////////////////////////////////////////////////////////////
// CPeterApp

BEGIN_MESSAGE_MAP(CPeterApp, CWinApp)
	//{{AFX_MSG_MAP(CPeterApp)
	ON_COMMAND(ID_APP_ABOUT, OnAppAbout)
	//}}AFX_MSG_MAP
	ON_COMMAND(ID_FILE_NEW2, CWinApp::OnFileNew)
	ON_COMMAND(ID_FILE_OPEN2, CWinApp::OnFileOpen)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CPeterApp::CPeterApp()
{
	StdPalette = NULL;
	StdBitmapInfo = (BITMAPINFO*) new unsigned char[sizeof(BITMAPINFO) + sizeof(RGBQUAD)*255];
}

CPeterApp::~CPeterApp()
{
	if (StdPalette != NULL)
	{
		DeleteObject(StdPalette);
		StdPalette = NULL;
	}
	delete StdBitmapInfo;
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CPeterApp object

CPeterApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CPeterApp initialization

BOOL CPeterApp::InitInstance()
{
	// Standard initialization

#ifdef _AFXDLL
	Enable3dControls();			// Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();	// Call this when linking to MFC statically
#endif

// inicializace globálních promìnných
	if (::GetSystemMetrics(SM_CXSCREEN) > 900)
		if (::GetSystemMetrics(SM_CXSCREEN) > 1080)
			SelectWidth = 280;			// šíøka pole pro výbìr objektu
		else
			SelectWidth = 240;			// šíøka pole pro výbìr objektu
	else
		if (::GetSystemMetrics(SM_CXSCREEN) > 700)
			SelectWidth = 200;			// šíøka pole pro výbìr objektu
		else
			SelectWidth = 170;


	Jmeno = "";					// jméno programu nezadáno

//	LoadStdProfileSettings(0);  // Load standard INI file options (including MRU)

	// Register document templates

	CSingleDocTemplate* pDocTemplate;
	pDocTemplate = new CSingleDocTemplate(
		IDR_MAINFRAME,
		RUNTIME_CLASS(CPeterDoc),
		RUNTIME_CLASS(CMainFrame),       // main SDI frame window
		RUNTIME_CLASS(CSelect));
	AddDocTemplate(pDocTemplate);

	// Enable DDE Execute open
//	EnableShellOpen();
//	RegisterShellFileTypes(TRUE);

	// Parse command line for standard shell commands, DDE, file open
//	CCommandLineInfo cmdInfo;
//	ParseCommandLine(cmdInfo);

	// Dispatch commands specified on the command line
//	if (!ProcessShellCommand(cmdInfo))
//		return FALSE;



// naètení standardního záhlaví BMP
	HRSRC hRes = ::FindResource(AfxGetResourceHandle(), MAKEINTRESOURCE(IDB_PALETY), RT_BITMAP);
	ASSERT(hRes != NULL);
	HGLOBAL hData = ::LoadResource(AfxGetResourceHandle(), hRes);
	ASSERT(hData != NULL);
	memcpy(StdBitmapInfo, ::LockResource(hData), sizeof(BITMAPINFO) + sizeof(RGBQUAD)*255);
	StdBitmapInfo->bmiHeader.biSizeImage = 0;
	StdBitmapInfo->bmiHeader.biSizeImage = 0;

// vytvoøení standardních palet
	LOGPALETTE* pStdPalette = (LOGPALETTE*) new char[sizeof(PALETTEENTRY)*(StdColors-1)+sizeof(LOGPALETTE)];
	pStdPalette->palVersion = 0x300;
	pStdPalette->palNumEntries = StdColors;
	for (int i=0; i<StdColors; i++)
	{
		pStdPalette->palPalEntry[i].peRed = StdBitmapInfo->bmiColors[i].rgbRed;
		pStdPalette->palPalEntry[i].peGreen = StdBitmapInfo->bmiColors[i].rgbGreen; 
		pStdPalette->palPalEntry[i].peBlue = StdBitmapInfo->bmiColors[i].rgbBlue;
		pStdPalette->palPalEntry[i].peFlags = 0;
	}
	StdPalette = ::CreatePalette(pStdPalette);
	ASSERT(StdPalette != NULL);
	delete pStdPalette;


	// Enable drag/drop open
//	m_pMainWnd->DragAcceptFiles();

	OnFileNew();

	((CMainFrame*)m_pMainWnd)->OnSelect();

//	if (m_lpCmdLine[0] != '\0')
//	{
//	}


//	CMainFrame* frm = new CMainFrame;
//	frm->LoadFrame(IDR_MAINFRAME);
//	frm->ShowWindow(TRUE);
//	frm->UpdateWindow();
//	m_pMainWnd = frm;


	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
		// No message handlers
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

// App command to run the dialog
void CPeterApp::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.DoModal();
}

/////////////////////////////////////////////////////////////////////////////
// CPeterApp commands

