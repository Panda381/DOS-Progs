// PetrView.cpp : implementation of the CPeterView class
//

#include "stdafx.h"
#include "Peter.h"

#include "PetrDoc.h"
//#include "Select.h"
#include "PetrView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPeterView

IMPLEMENT_DYNCREATE(CPeterView, CFormView)

BEGIN_MESSAGE_MAP(CPeterView, CFormView)
	//{{AFX_MSG_MAP(CPeterView)
	ON_WM_CREATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPeterView construction/destruction

CPeterView::CPeterView()
	: CFormView(CPeterView::IDD)
{
	//{{AFX_DATA_INIT(CPeterView)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT


//	CWnd* frm;
//	frm = GetDlgItem(IDD_PETER_FORM);
	
}

CPeterView::~CPeterView()
{
}

void CPeterView::DoDataExchange(CDataExchange* pDX)
{
	CFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CPeterView)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BOOL CPeterView::PreCreateWindow(CREATESTRUCT& cs)
{
	return CFormView::PreCreateWindow(cs);
}

/////////////////////////////////////////////////////////////////////////////
// CPeterView diagnostics

#ifdef _DEBUG
void CPeterView::AssertValid() const
{
	CFormView::AssertValid();
}

void CPeterView::Dump(CDumpContext& dc) const
{
	CFormView::Dump(dc);
}

CPeterDoc* CPeterView::GetDocument() // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CPeterDoc)));
	return (CPeterDoc*)m_pDocument;
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CPeterView message handlers

int CPeterView::OnCreate(LPCREATESTRUCT lpCreateStruct) 
{
	if (CFormView::OnCreate(lpCreateStruct) == -1)
		return -1;
	
//	m_Select.Create(CSelect::IDD, this);
	
	return 0;
}
