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
	CEdit	m_NameBox;				// edita�n� pole pro jm�no polo�ky
	CEdit	m_FindBox;				// edita�n� pole textu k hled�n�
	CStatic	m_RefBox;				// referen�n� pole pro po�et odkaz�

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMainFrame)
	public:
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CMainFrame();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	void SetPage(Pages);

public:  // control bar embedded members
	CStatusBar  m_wndStatusBar;
	CToolBar    m_wndToolBar;
//	CToolBar	m_wndStrucBar;
//	CToolBar	m_wndObjBar;
	CToolBar	m_wndEdiBar;
	CToolBar	m_wndPropBar;
	CToolBar	m_wndNavBar;

	Pages		m_Page;				// aktivn� str�nka
	Pages		m_PageExec;			// p�ede�l� str�nka p�ed Exe
//	Pages		m_PageEdit;			// p�ede�l� str�nka p�ed Edit

// Generated message map functions
public:
	//{{AFX_MSG(CMainFrame)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnExec();
	afx_msg void OnSelect();
	afx_msg void OnStart();
	afx_msg void OnStop();
	afx_msg void OnFileOpen();
	afx_msg void OnFileClose();
	afx_msg void OnProg();
	afx_msg void OnClose();
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	afx_msg void OnFileNew2();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
