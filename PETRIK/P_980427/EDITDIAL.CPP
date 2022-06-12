// EditDial.cpp : implementation file
//

#include "stdafx.h"
#include "peter.h"
#include "EditDial.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CEditDial dialog


CEditDial::CEditDial(CWnd* pParent /*=NULL*/)
	: CDialog(CEditDial::IDD, pParent)
{
	//{{AFX_DATA_INIT(CEditDial)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CEditDial::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CEditDial)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CEditDial, CDialog)
	//{{AFX_MSG_MAP(CEditDial)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CEditDial message handlers
