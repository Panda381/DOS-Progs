// Peter.cpp : Defines the class behaviors for the application.
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
#include "PetrDoc.h"

//#include "PetrView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// globální promìnné

// jméno editovaného souboru
CString	Jmeno = "";			// jméno editovaného souboru (bez cesty a bez pøípony)

// parametry obrazovky
int ScreenWidth;			// šíøka obrazovky
int ScreenHeight;			// výška obrazovky

// konfiguraèní promìnné
int Profile = 1;			// èíslo profilu (z pøíkazového øádku)
CString ProfName;			// jméno profilu

int Scale;					// mìøítko pro relativní rozmìry okna

int MainLeft;				// relativní pozice hlavního okna vlevo
int MainTop;				// relativní pozice hlavního okna nahoøe
int MainWidth;				// relativní šíøka hlavního okna
int MainHeight;				// relativní výška hlavního okna

int LeftWidth;				// relativní šíøka levého pole (objekty)
int LeftHeight;				// relativní výška levého horního okna (globální objekty)
int RightWidth;				// relativní šíøka pravého pole (tøídy)
int RightHeight;			// relativní výška pravého horního okna (struktury)

BOOL Maximized;				// pøíznak maximalizace okna

CString FindString = _T("");	// hledaný text

// globální objekty
CMainFrame*	MainFrame = NULL;// hlavní okno aplikace
CPeterApp theApp;			// hlavní objekt aplikace
CProg* Prog = NULL;			// okno editoru programování

// standardní palety
HPALETTE StdPalette;		// vlastní palety
BITMAPINFO* StdBitmapInfo;	// standardní záhlaví BMP

unsigned char KonvPal[256];	// konverzní tabulka palet

// tabulka hladin standardních barev (0 až 256)
const short ColLevTab[] = 
{
	256,
	256*13/16, 
	256*10/16,
	256*7/16,
	256*4/16,
};

// tabulka odstínù standardních barev (0 až 255) - poøadí B, G, R, F,
const RGBQUAD ColColTab[] = 
{ 
	0,		0,		255,		0,			// èervená
	0,		114,	255,		0,
	0,		182,	255,		0,
	0,		255,	255,		0,			// žlutá
	0,		255,	166,		0,
	0,		255,	0,			0,			// zelená
	138,	255,	0,			0,
	255,	255,	0,			0,			// modrozelená
	255,	186,	0,			0,
	255,	114,	0,			0,
	255,	0,		0,			0,			// modrá
	255,	0,		114,		0,
	255,	0,		174,		0,
	255,	0,		255,		0,			// fialová
	138,	0,		255,		0,

	200,	174,	255,		0,
	210,	220,	255,		0,
	150,	166,	255,		0,
	150,	198,	255,		0,
	182,	255,	255,		0,
	162,	255,	162,		0,
	222,	255,	138,		0,
	255,	242,	210,		0,
	255,	210,	154,		0,
	255,	162,	198,		0,

/*
	96,		96,		255,		0,
	96,		128,	255,		0,
	96,		192,	255,		0,
	96,		255,	255,		0,
	96,		255,	192,		0,
	192,	96,		255,		0,
	192,	128,	255,		0,
	192,	192,	255,		0,
	192,	255,	255,		0,
	192,	255,	192,		0,
	255,	96,		255,		0,
	255,	128,	255,		0,
	255,	192,	255,		0,
	255,	255,	192,		0,*/
	255,	255,	255,		0,			// bílá
	96,		96,		96,			0,			// šedá
};


const int ColLev = sizeof(ColLevTab)/sizeof(ColLevTab[0]);	// poèet hladin barev
const int ColCol = sizeof(ColColTab)/sizeof(ColColTab[0]);	// poèet odstínù barev
const int StdColors = 1 + ColCol*ColLev;					// poèet vlastních palet (zaèínají od 0)

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

// pøíprava parametrù obrazovky
	ScreenWidth = ::GetSystemMetrics(SM_CXMAXIMIZED);
	ScreenHeight = ::GetSystemMetrics(SM_CYMAXIMIZED);

// naètení konfigurace z INI
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


// kontrola pøeteèení poètu barev
	ASSERT(StdColors < 256 - 32);


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





	StdBitmapInfo->bmiColors[0].rgbRed =	151;
	StdBitmapInfo->bmiColors[0].rgbGreen =	3;
	StdBitmapInfo->bmiColors[0].rgbBlue =	151;

	for (int k = 0; k < ColCol; k++)
	{
		StdBitmapInfo->bmiColors[k*ColLev+1] = ColColTab[k];

		for (int l = 1; l < ColLev; l++)
		{
			StdBitmapInfo->bmiColors[k*ColLev+1+l].rgbRed = 
				StdBitmapInfo->bmiColors[k*ColLev+1].rgbRed * ColLevTab[l] / 256;
			StdBitmapInfo->bmiColors[k*ColLev+1+l].rgbGreen = 
				StdBitmapInfo->bmiColors[k*ColLev+1].rgbGreen * ColLevTab[l] / 256;
			StdBitmapInfo->bmiColors[k*ColLev+1+l].rgbBlue = 
				StdBitmapInfo->bmiColors[k*ColLev+1].rgbBlue * ColLevTab[l] / 256;
			StdBitmapInfo->bmiColors[k*ColLev+1+l].rgbReserved = 0;
		}
	}


	k = 2*ColLev-1;
	for (int m = StdColors - 2*ColLev; m < StdColors; m++)
	{
		int n = k * 255 / (2*ColLev-1);
		StdBitmapInfo->bmiColors[m].rgbRed = n;
		StdBitmapInfo->bmiColors[m].rgbGreen = n;
		StdBitmapInfo->bmiColors[m].rgbBlue = n;
		k--;
	}

	GenKonvPal(StdBitmapInfo);

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
// ukonèení aplikace

int CPeterApp::ExitInstance() 
{
	WriteIni();				// zápis konfigurace
	return CWinApp::ExitInstance();
}


/////////////////////////////////////////////////////////////////////////////
// generování konverzní tabulky barev obrázku

void GenKonvPal(BITMAPINFO* bmp)
{
// lokální promìnné
	short i, j;				// pracovní èítaèe
	short min;				// vzdálenost od nalezené nejbližší barvy
	short akt;				// vzdálenost od aktuální barvy
	unsigned char last;		// poslední nalezená nejbližší barva
	BYTE r,g,b;				// hledaná barva
	RGBQUAD* rgb;			// ukazatel standardních palet

// index 0 zùstane vždy nezmìnìn
	KonvPal[0] = 0;

// cyklus pøes všechny importované barvy
	for (i = 1; i < 256; i++)
	{

// pøíprava pro hledání jedné barvy
		min = 3*256;		// asi tak nìjaká velká vzdálenost
		r = bmp->bmiColors[i].rgbRed;	// èervená
		g = bmp->bmiColors[i].rgbGreen;	// zelená
		b = bmp->bmiColors[i].rgbBlue;	// modrá
		rgb = &(StdBitmapInfo->bmiColors[1]);	// ukazatel barev

// cyklus pøes všechny standardní barvy
		for (j = 1; j < StdColors; j++)
		{

// vzdálenost od aktuální barvy
			akt =	abs(rgb->rgbRed - r) +
					abs(rgb->rgbGreen - g) +
					abs(rgb->rgbBlue - b);

// kontrola vzdálenosti od standardní barvy
			if (akt < min)
			{
				min = akt;				// nová vzdálenost
				last = (unsigned char)j; // nový index nejbližší barvy
			}

// posun na další standardní barvu
			rgb++;
		}

// konverzní hodnota
		KonvPal[i] = last;
	}
}


/////////////////////////////////////////////////////////////////////////////
// obsluha konfigurace

// pomocné texty pro INI
CString tProfile;			// text profilu (pomocné - sestaví se)
TCHAR* tProfile0	= _T("Profile%u");

TCHAR* tProfName	= _T("Name");

TCHAR* tLastFile	= _T("LastFile");

TCHAR* tScale		= _T("Scale");

TCHAR* tMainLeft	= _T("Left");
TCHAR* tMainTop		= _T("Top");
TCHAR* tMainWidth	= _T("Width");
TCHAR* tMainHeight	= _T("Height");

TCHAR* tLeftWidth	= _T("LeftWidth");
TCHAR* tLeftHeight	= _T("LeftHeight");
TCHAR* tRightWidth	= _T("RightWidth");
TCHAR* tRightHeight	= _T("RightHeight");

TCHAR* tMaximized	= _T("Maximized");

TCHAR* tFindText	= _T("FindText");

// naètení konfigurace
void CPeterApp::ReadIni()
{
	tProfile.Format(tProfile0, Profile );	// sestavení jména profilu

	ProfName = GetProfileString(tProfile, tProfName, _T("Default"));

	Jmeno = GetProfileString(tProfile, tLastFile, _T(""));

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

// naètení jednoho rozmìrového èísla z konfigurace
void CPeterApp::ReadIniInt(int& result, LPCTSTR entry, int deflt)
{
	result = GetProfileInt(tProfile, entry, deflt);
	if (result < -Scale) result = -Scale;
	if (result > Scale) result = Scale;
	if (&result != &MainLeft && result < 0) result = 0;
}

// uložení konfigurace
void CPeterApp::WriteIni()
{
	tProfile.Format(tProfile0, Profile );	// sestavení jména profilu

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


/////////////////////////////////////////////////////////////////////////////
// alokace bufferù (old = NULL vytvoøí nový, size = 0 zruší buffer)

void* _Aloc(void* old, int size)
{
// prázdný buffer se neruší
	if ((old == NULL) && (size == 0))
		return NULL;

// realokace bufferu
	void* buf = realloc(old, size);

// kontrola úspìšnosti operace
	if ((buf == NULL) && (size != 0))
	{
		::MessageBox(NULL, _T("Lituji, program bude ukonèen z dùvodu nedostatku pamìti!"),
			_T("Nedostatek pamìti"), MB_OK | MB_ICONSTOP);
		exit(-1);
	}

// návrat nové adresy bufferu
	return buf;
}

