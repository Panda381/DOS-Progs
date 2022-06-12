// Peter.h : main header file for the PETER application
//

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// globální promìnné

extern CString	Jmeno;				// jméno editovaného programu (bez cesty a bez pøípony)

// parametry obrazovky
extern int ScreenWidth;				// šíøka obrazovky
extern int ScreenHeight;			// výška obrazovky

// konfiguraèní promìnné
extern int Profile;					// èíslo profilu (z pøíkazového øádku)
extern CString ProfName;			// jméno profilu

extern int Scale;					// mìøítko pro relativní rozmìry okna

extern int MainLeft;				// relativní pozice hlavního okna vlevo
extern int MainTop;					// relativní pozice hlavního okna nahoøe
extern int MainWidth;				// relativní šíøka hlavního okna
extern int MainHeight;				// relativní výška hlavního okna

extern int LeftWidth;				// relativní šíøka levého pole (objekty)
extern int LeftHeight;				// relativní výška levého horního okna (globální objekty)
extern int RightWidth;				// relativní šíøka pravého pole (tøídy)
extern int RightHeight;				// relativní výška pravého horního okna (struktury)

extern BOOL Maximized;				// pøíznak maximalizace okna

extern CString FindString;			// hledaný text

// globální objekty
class CMainFrame;
extern	CMainFrame*	MainFrame;		// hlavní okno aplikace
class CPeterApp;
extern	CPeterApp theApp;			// hlavní objekt aplikace
class CProg;
extern CProg* Prog;					// hlavní okno programování

//extern int		SelectWidth;		// šíøka pole pro výbìr objektu a tøidy
extern BITMAPINFO* StdBitmapInfo;	// standardní záhlaví BMP
extern HPALETTE StdPalette;			// vlastní palety

extern unsigned char KonvPal[256];	// konverzní tabulka palet
extern void GenKonvPal(BITMAPINFO* bmp); // generování konverzní tabulky

extern const int ColCol;			// poèet barev standardních palet
extern const int ColLev;			// poèet úrovní standardních palet
extern const int StdColors;			// poèet vlastních palet (zaèínají od 0)

// konverze barev
inline void KonvCopy(unsigned char* dst, unsigned char* src, int num)
{
	for (; num > 0; num--)
	{
		dst[0] = KonvPal[src[0]];
		dst++;
		src++;
	}
}

/////////////////////////////////////////////////////////////////////////////
// CPeterApp:
// See Peter.cpp for the implementation of this class
//

class CPeterApp : public CWinApp
{
public:
	CPeterApp();
	~CPeterApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPeterApp)
	public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CPeterApp)
	afx_msg void OnAppAbout();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

public:
	void ReadIni();
	void ReadIniInt(int& result, LPCTSTR entry, int deflt);
	void WriteIni();
};


/////////////////////////////////////////////////////////////////////////////
// mód editace ikony

enum EditMode
{ 
	EditModeElip,					// elipsa
	EditModeFill,					// výplò
	EditModeLine,					// èára
	EditModePaint,					// štìtec
	EditModePen,					// pero
	EditModePipe,					// kapátko
	EditModeRect,					// obdélník
	EditModeRound,					// kruh
	EditModeSelect,					// blok
	EditModeSpray,					// sprej
	EditModeXFlip,					// horizontální pøevrácení
	EditModeYFlip,					// vertikální pøevrácení
	EditModeRRot,					// otoèení R
	EditModeLRot,					// otoèení L
	EditModeXCol,					// zámìna barev
};


/////////////////////////////////////////////////////////////////////////////
// realokace velkých bufferù (adr = NULL vytvoøení, size = 0 zrušení)

void* _Aloc(void* adr, int size);

inline void Aloc(char*& adr, int size)
	{ adr = (char*)_Aloc(adr, size); }

inline void Aloc(unsigned char*& adr, int size)
	{ adr = (unsigned char*)_Aloc(adr, size); }

inline void Aloc(BITMAPINFO*& adr, int size)
	{ adr = (BITMAPINFO*)_Aloc(adr, size); }

inline void Aloc(double*& adr, int size)
	{ adr = (double*)_Aloc(adr, size); }

inline void Aloc(int*& adr, int size)				// velikost udána v poètu položek int !
	{ adr = (int*)_Aloc(adr, size*sizeof(int)); }
