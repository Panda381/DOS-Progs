// EditSprt.cpp : implementation file
//

#include "stdafx.h"
#include "peter.h"
#include "EditSprt.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CEditSprite dialog


CEditSprite::CEditSprite(CWnd* pParent /*=NULL*/)
	: CDialog(CEditSprite::IDD, pParent)
{
	//{{AFX_DATA_INIT(CEditSprite)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CEditSprite::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CEditSprite)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CEditSprite, CDialog)
	//{{AFX_MSG_MAP(CEditSprite)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CEditSprite message handlers
