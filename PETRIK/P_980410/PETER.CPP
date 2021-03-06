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
// glob�ln� prom�nn�

// jm�no editovan�ho souboru
CString	Jmeno = "";			// jm�no editovan�ho souboru (bez cesty a bez p��pony)

// parametry obrazovky
int ScreenWidth;			// ���ka obrazovky
int ScreenHeight;			// v��ka obrazovky

// konfigura�n� prom�nn�
int Profile = 1;			// ��slo profilu (z p��kazov�ho ��dku)
CString ProfName;			// jm�no profilu

int Scale;					// m���tko pro relativn� rozm�ry okna

int MainLeft;				// relativn� pozice hlavn�ho okna vlevo
int MainTop;				// relativn� pozice hlavn�ho okna naho�e
int MainWidth;				// relativn� ���ka hlavn�ho okna
int MainHeight;				// relativn� v��ka hlavn�ho okna

int LeftWidth;				// relativn� ���ka lev�ho pole (objekty)
int LeftHeight;				// relativn� v��ka lev�ho horn�ho okna (glob�ln� objekty)
int RightWidth;				// relativn� ���ka prav�ho pole (t��dy)
int RightHeight;			// relativn� v��ka prav�ho horn�ho okna (struktury)

BOOL Maximized;				// p��znak maximalizace okna

CString FindString = _T("");	// hledan� text

// glob�ln� objekty
CMainFrame*	MainFrame = NULL;// hlavn� okno aplikace
CPeterApp theApp;			// hlavn� objekt aplikace
CProg* Prog = NULL;			// okno editoru programov�n�

// standardn� palety
HPALETTE StdPalette;		// vlastn� palety
BITMAPINFO* StdBitmapInfo;	// standardn� z�hlav� BMP

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
// inicializace aplikace

BOOL CPeterApp::InitInstance()
{

// inicializace 3D vzhledu oken
#ifdef _AFXDLL
	Enable3dControls();
#else
	Enable3dControlsStatic();
#endif

// p��prava parametr� obrazovky
	ScreenWidth = ::GetSystemMetrics(SM_CXMAXIMIZED);
	ScreenHeight = ::GetSystemMetrics(SM_CYMAXIMIZED);

// na�ten� konfigurace z INI
	ReadIni();

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



// na�ten� standardn�ho z�hlav� BMP
	HRSRC hRes = ::FindResource(AfxGetResourceHandle(), MAKEINTRESOURCE(IDB_PALETY), RT_BITMAP);
	ASSERT(hRes != NULL);
	HGLOBAL hData = ::LoadResource(AfxGetResourceHandle(), hRes);
	ASSERT(hData != NULL);
	memcpy(StdBitmapInfo, ::LockResource(hData), sizeof(BITMAPINFO) + sizeof(RGBQUAD)*255);
	StdBitmapInfo->bmiHeader.biSizeImage = 0;
	StdBitmapInfo->bmiHeader.biSizeImage = 0;

// vytvo�en� standardn�ch palet
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

	MainFrame = (CMainFrame*)m_pMainWnd;
	MainFrame->OnSelect();

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
// ukon�en� aplikace

int CPeterApp::ExitInstance() 
{
	WriteIni();				// z�pis konfigurace
	return CWinApp::ExitInstance();
}

/////////////////////////////////////////////////////////////////////////////
// obsluha konfigurace

// pomocn� texty pro INI
CString tProfile;			// text profilu (pomocn� - sestav� se)
char* tProfile0		= "Profile%u";

char* tProfName		= "Name";

char* tLastFile		= "LastFile";

char* tScale		= "Scale";

char* tMainLeft		= "Left";
char* tMainTop		= "Top";
char* tMainWidth	= "Width";
char* tMainHeight	= "Height";

char* tLeftWidth	= "LeftWidth";
char* tLeftHeight	= "LeftHeight";
char* tRightWidth	= "RightWidth";
char* tRightHeight	= "RightHeight";

char* tMaximized	= "Maximized";

char* tFindText		= "FindText";

// na�ten� konfigurace
void CPeterApp::ReadIni()
{
	tProfile.Format(tProfile0, Profile );	// sestaven� jm�na profilu

	ProfName = GetProfileString(tProfile, tProfName, "Default");

	Jmeno = GetProfileString(tProfile, tLastFile, "");

	Scale = GetProfileInt(tProfile, tScale, 10000);
	if (Scale < 100) Scale = 100;
	if (Scale > 100000) Scale = 100000;

	ReadIniInt(MainLeft,	tMainLeft,		Scale * 1/20);
	ReadIniInt(MainTop,		tMainTop,		Scale * 1/20);
	ReadIniInt(MainWidth,	tMainWidth,		Scale * 18/20);
	ReadIniInt(MainHeight,	tMainHeight,	Scale * 18/20);

	ReadIniInt(LeftWidth,	tLeftWidth,		Scale * 1/5);
	ReadIniInt(LeftHeight,	tLeftHeight,	Scale * 2/3);
	ReadIniInt(RightWidth,	tRightWidth,	Scale * 1/5);
	ReadIniInt(RightHeight,	tRightHeight,	Scale * 2/3);

	Maximized = GetProfileInt(tProfile, tMaximized, FALSE);

	FindString = GetProfileString(tProfile, tFindText);
}

// na�ten� jednoho rozm�rov�ho ��sla z konfigurace
void CPeterApp::ReadIniInt(int& result, LPCTSTR entry, int deflt)
{
	result = GetProfileInt(tProfile, entry, deflt);
	if (result < -Scale) result = -Scale;
	if (result > Scale) result = Scale;
	if (&result != &MainLeft && result < 0) result = 0;
}

// ulo�en� konfigurace
void CPeterApp::WriteIni()
{
	tProfile.Format(tProfile0, Profile );	// sestaven� jm�na profilu

	WriteProfileString(tProfile, tProfName, ProfName);

	WriteProfileString(tProfile, tLastFile, Jmeno);

	WriteProfileInt(tProfile, tScale,		Scale);

	WriteProfileInt(tProfile, tMainLeft,	MainLeft);
	WriteProfileInt(tProfile, tMainTop,		MainTop);
	WriteProfileInt(tProfile, tMainWidth,	MainWidth);
	WriteProfileInt(tProfile, tMainHeight,	MainHeight);

	WriteProfileInt(tProfile, tLeftWidth,	LeftWidth);
	WriteProfileInt(tProfile, tLeftHeight,	LeftHeight);
	WriteProfileInt(tProfile, tRightWidth,	RightWidth);
	WriteProfileInt(tProfile, tRightHeight,	RightHeight);

	WriteProfileInt(tProfile, tMaximized,	Maximized);

	WriteProfileString(tProfile, tFindText,	FindString);
}

/////////////////////////////////////////////////////////////////////////////
// okno About

void CPeterApp::OnAppAbout()
{
	CDialog About(IDD_ABOUTBOX);
	About.DoModal();
}

