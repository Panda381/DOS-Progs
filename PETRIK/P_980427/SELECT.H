// Select.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CSelect form view

#ifndef __AFXEXT_H__
#include <afxext.h>
#endif

class CSelect : public CFormView
{
public:
	CSelect();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CSelect)

// Form Data
public:
	//{{AFX_DATA(CSelect)
	enum { IDD = IDR_SELECT };
	CListCtrl	m_Select;
	//}}AFX_DATA
	
	CImageList* m_ImageList;

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CSelect)
	public:
	virtual void OnInitialUpdate();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CSelect();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
	//{{AFX_MSG(CSelect)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnUpdateStart(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFileOpen(CCmdUI* pCmdUI);
	afx_msg void OnItemchangedSelectlist(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDblclkSelectlist(NMHDR* pNMHDR, LRESULT* pResult);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
