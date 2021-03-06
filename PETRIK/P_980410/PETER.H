// Peter.h : main header file for the PETER application
//

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// glob�ln� prom�nn�

extern CString	Jmeno;				// jm�no editovan�ho programu (bez cesty a bez p��pony)

// parametry obrazovky
extern int ScreenWidth;				// ���ka obrazovky
extern int ScreenHeight;			// v��ka obrazovky

// konfigura�n� prom�nn�
extern int Profile;					// ��slo profilu (z p��kazov�ho ��dku)
extern CString ProfName;			// jm�no profilu

extern int Scale;					// m���tko pro relativn� rozm�ry okna

extern int MainLeft;				// relativn� pozice hlavn�ho okna vlevo
extern int MainTop;					// relativn� pozice hlavn�ho okna naho�e
extern int MainWidth;				// relativn� ���ka hlavn�ho okna
extern int MainHeight;				// relativn� v��ka hlavn�ho okna

extern int LeftWidth;				// relativn� ���ka lev�ho pole (objekty)
extern int LeftHeight;				// relativn� v��ka lev�ho horn�ho okna (glob�ln� objekty)
extern int RightWidth;				// relativn� ���ka prav�ho pole (t��dy)
extern int RightHeight;				// relativn� v��ka prav�ho horn�ho okna (struktury)

extern BOOL Maximized;				// p��znak maximalizace okna

extern CString FindString;			// hledan� text

// glob�ln� objekty
class CMainFrame;
extern	CMainFrame*	MainFrame;		// hlavn� okno aplikace
class CPeterApp;
extern	CPeterApp theApp;			// hlavn� objekt aplikace
class CProg;
extern CProg* Prog;					// hlavn� okno programov�n�

//extern int		SelectWidth;		// ���ka pole pro v�b�r objektu a t�idy
extern BITMAPINFO* StdBitmapInfo;	// standardn� z�hlav� BMP
extern HPALETTE StdPalette;			// vlastn� palety

const int StdColors = 16+2*6*16;	// po�et vlastn�ch palet (za��naj� od 0)

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
