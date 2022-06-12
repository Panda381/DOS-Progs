// PetrDoc.cpp : implementation of the CPeterDoc class
//

#include "stdafx.h"
#include "Peter.h"

#include "PetrDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPeterDoc

IMPLEMENT_DYNCREATE(CPeterDoc, CDocument)

BEGIN_MESSAGE_MAP(CPeterDoc, CDocument)
	//{{AFX_MSG_MAP(CPeterDoc)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPeterDoc construction/destruction

CPeterDoc::CPeterDoc()
{
}

CPeterDoc::~CPeterDoc()
{
}

BOOL CPeterDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CPeterDoc serialization

void CPeterDoc::Serialize(CArchive& ar)
{
	if (ar.IsStoring())
	{
	}
	else
	{
	}
}

/////////////////////////////////////////////////////////////////////////////
// CPeterDoc diagnostics

#ifdef _DEBUG
void CPeterDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CPeterDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CPeterDoc commands
