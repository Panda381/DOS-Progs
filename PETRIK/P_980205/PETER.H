// Peter.h : main header file for the PETER application
//

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

extern CString	Jmeno;				// jm�no programu (bez cesty a bez p��pony)
extern int		SelectWidth;		// ���ka pole pro v�b�r objektu

/////////////////////////////////////////////////////////////////////////////
// CPeterApp:
// See Peter.cpp for the implementation of this class
//

class CPeterApp : public CWinApp
{
public:
	CPeterApp();

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
