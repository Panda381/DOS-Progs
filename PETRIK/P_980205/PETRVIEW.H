// PetrView.h : interface of the CPeterView class
//
/////////////////////////////////////////////////////////////////////////////

class CPeterView : public CFormView
{
protected: // create from serialization only
	CPeterView();
	DECLARE_DYNCREATE(CPeterView)

public:
	//{{AFX_DATA(CPeterView)
	enum{ IDD = IDD_PETER_FORM };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

// Attributes
public:
	CPeterDoc* GetDocument();

//	CSelect		m_Select;

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPeterView)
	public:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CPeterView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	//{{AFX_MSG(CPeterView)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

#ifndef _DEBUG  // debug version in PetrView.cpp
inline CPeterDoc* CPeterView::GetDocument()
   { return (CPeterDoc*)m_pDocument; }
#endif

/////////////////////////////////////////////////////////////////////////////
