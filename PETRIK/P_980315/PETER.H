// Peter.h : main header file for the PETER application
//

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// glob�ln� prom�nn�

extern CString	Jmeno;				// jm�no editovan�ho programu (bez cesty a bez p��pony)
extern int		SelectWidth;		// ���ka pole pro v�b�r objektu a t�idy
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
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CPeterApp)
	afx_msg void OnAppAbout();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////
