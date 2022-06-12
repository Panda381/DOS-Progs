// Exec.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CExec form view

#ifndef __AFXEXT_H__
#include <afxext.h>
#endif

class CExec : public CFormView
{
public:
	CExec();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CExec)

// Form Data
public:
	//{{AFX_DATA(CExec)
	enum { IDD = IDR_EXEC };
	CAnimateCtrl	m_Exec;
	//}}AFX_DATA

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CExec)
	public:
	virtual void OnInitialUpdate();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CExec();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
	//{{AFX_MSG(CExec)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
