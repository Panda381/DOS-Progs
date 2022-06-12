// Exec.cpp : implementation file
//

#include "stdafx.h"
#include "peter.h"
#include "Exec.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CExec

IMPLEMENT_DYNCREATE(CExec, CFormView)

CExec::CExec()
	: CFormView(CExec::IDD)
{
	//{{AFX_DATA_INIT(CExec)
	//}}AFX_DATA_INIT
}

CExec::~CExec()
{
}

void CExec::DoDataExchange(CDataExchange* pDX)
{
	CFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CExec)
	DDX_Control(pDX, IDC_EXEC, m_Exec);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CExec, CFormView)
	//{{AFX_MSG_MAP(CExec)
	ON_WM_SIZE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CExec diagnostics

#ifdef _DEBUG
void CExec::AssertValid() const
{
	CFormView::AssertValid();
}

void CExec::Dump(CDumpContext& dc) const
{
	CFormView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CExec message handlers

void CExec::OnSize(UINT nType, int cx, int cy) 
{
	CFormView::OnSize(nType, cx, cy);
	
	CRect rect;
	GetClientRect(&rect);
	if (m_Exec.m_hWnd != NULL)
	{
		m_Exec.MoveWindow(&rect);
	}
}

void CExec::OnInitialUpdate() 
{
	CFormView::OnInitialUpdate();
	
	m_Exec.Open(_T("Dillo.avi"));

	Invalidate();	

}
