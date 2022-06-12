// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

enum Pages { PageNone, PageSelect, PageExec, PageProg };

class CMainFrame : public CFrameWnd
{
public: // create from serialization only
	CMainFrame();
	DECLARE_DYNCREATE(CMainFrame)

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMainFrame)
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CMainFrame();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	void SetPage(Pages);

protected:  // control bar embedded members
	CStatusBar  m_wndStatusBar;
	CToolBar    m_wndToolBar;
//	CToolBar	m_wndStrucBar;
	CToolBar	m_wndObjBar;

	Pages		m_Page;				// aktivní stránka
	Pages		m_PageExec;			// pøedešlá stránka pøed Exe
//	Pages		m_PageEdit;			// pøedešlá stránka pøed Edit

// Generated message map functions
public:
	//{{AFX_MSG(CMainFrame)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnExec();
	afx_msg void OnSelect();
	afx_msg void OnStart();
	afx_msg void OnStop();
	afx_msg void OnFileOpen();
	afx_msg void OnFileClose();
	afx_msg void OnProg();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
