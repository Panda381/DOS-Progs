// Peter.h : main header file for the PETER application
//

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// globální promìnné

extern CString	Jmeno;				// jméno editovaného programu (bez cesty a bez pøípony)
extern int		SelectWidth;		// šíøka pole pro výbìr objektu a tøidy
extern BITMAPINFO* StdBitmapInfo;	// standardní záhlaví BMP
extern HPALETTE StdPalette;			// vlastní palety

const int StdColors = 16+2*6*16;	// poèet vlastních palet (zaèínají od 0)

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
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CPeterApp)
	afx_msg void OnAppAbout();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////
