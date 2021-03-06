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
	CStatic m_IconBox;				// pole sou�adnic grafick�ho editoru

// prvky editoru map
	CStatic	m_MapSirkaText;			// pole textu "���ka"
	CEdit	m_MapSirkaEdit;			// pole editace ���ky
	CStatic m_MapVyskaText;			// pole textu "v��ka"
	CEdit	m_MapVyskaEdit;			// pole editace v��ky
	CStatic m_MapXY;				// pole sou�adnic

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
	CToolBar	m_wndIconBar;
	CToolBar	m_wndMapBar;

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
	afx_msg void OnUpdateEditiconElip(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconFill(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconLine(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconPaint(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconPen(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconPipe(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconRect(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconRound(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconSelect(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconSpray(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconXFlip(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconYFlip(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconRRot(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconLRot(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconXCol(CCmdUI* pCmdUI);
	afx_msg void OnEditiconElip();
	afx_msg void OnEditiconFill();
	afx_msg void OnEditiconLine();
	afx_msg void OnEditiconPaint();
	afx_msg void OnEditiconPen();
	afx_msg void OnEditiconPipe();
	afx_msg void OnEditiconRect();
	afx_msg void OnEditiconRound();
	afx_msg void OnEditiconSelect();
	afx_msg void OnEditiconSpray();
	afx_msg void OnEditiconXFlip();
	afx_msg void OnEditiconYFlip();
	afx_msg void OnEditiconRRot();
	afx_msg void OnEditiconLRot();
	afx_msg void OnEditiconXCol();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

//	void OnKillFocusSirkaMap(NMHDR* pNMHDR, LRESULT* pResult);

	void OnUpdateEditicon(CCmdUI* pCmdUI, int mode);
	void OnEditicon(int mode);
};

/////////////////////////////////////////////////////////////////////////////
