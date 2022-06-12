// ProgSel.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CProg view

class CProg : public CFormView
{
protected:
	CProg();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CProg)

// Attributes
public:
	//{{AFX_DATA(CProg)
	enum { IDD = IDR_PROG };
	CStatic	m_Split;
	CTreeCtrl	m_Select;
	CTreeCtrl	m_Prog;
	//}}AFX_DATA

	CImageList* m_ImageList;
	CImageList* m_ImageProg;

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CProg)
public:
	virtual void OnInitialUpdate();
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CProg();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
protected:
	//{{AFX_MSG(CProg)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
