// EditMap.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CEditMap dialog

class CEditMap : public CDialog
{
// Construction
public:
	CEditMap(CWnd* pParent = NULL);   // standard constructor
	virtual ~CEditMap();

// Dialog Data
	//{{AFX_DATA(CEditMap)
	enum { IDD = IDD_EDIT_MAP };
	CScrollBar			m_HScroll;
	CScrollBar			m_VScroll;
	//}}AFX_DATA

	CMapBuf*	m_Map;				// adresa bufferu map
	CIconBuf*	m_Icon;				// adresa bufferu ikon

// primární parametry plochy
	short	m_Index;				// index editované mapy
	MAP*	m_Data;					// ukazatel na data plochy
	int		m_Width;				// šíøka editované plochy (políèek)
	int		m_Height;				// výška editované plochy (políèek)
	int		m_IconWidth;			// šíøka ikony (bodù)
	int		m_IconHeight;			// výška ikony (bodù)

// uživatelem nastavený poèátek zobrazení plochy
	int		m_tLeft;				// poèáteèní bod plochy vlevo
	int		m_tBottom;				// poèáteèní bod plochy dole

// rozmìry ikony v bodech celkem
	int		m_mWidth;				// šíøka editované plochy celkem (v bodech)
	int		m_mHeight;				// výška editované plochy celkem (v bodech)

// souøadnice klientské oblasti pro plochu
	int		m_cWidth;				// šíøka klientské oblasti pro editovanou plochu
	int		m_cHeight;				// výška klientské oblasti pro editovanou plochu

// skuteènì zobrazená èást plochy v bodech
	int		m_dWidth;				// šíøka zobrazené èásti plochy v bodech
	int		m_dHeight;				// výška zobrazené èásti plochy v bodech
	int		m_dLeft;				// levý poèátek zobrazené èásti plochy
	int		m_dTop;					// horní poèátek zobrazené èásti plochy

// skuteènì zobrazená èást plochy v ikonách (okrajové ikony mohou být zobrazeny neúplnì)
	int		m_iLeft;				// levá první zobrazená ikona (i necelá)
	int		m_iBottom;				// spodní první zobrazená ikona (i necelá)
	int		m_iRight;				// pravá poslední zobrazená ikona (i necelá)
	int		m_iTop;					// horní poslední zobrazená ikona (i necelá)

// neúplné zobrazení okrajových ikon (rozsah 1 až m_IconWidth,m_IconHeight)
	int		m_oLeft;				// poèet bodù ikony vlevo
	int		m_oBottom;				// poèet bodù ikony dole
	int		m_oRight;				// poèet bodù ikony vpravo
	int		m_oTop;					// poèet bodù ikony nahoøe

// posuvníky
	BOOL	m_HScrollDisp;			// horizontální posuvník zapnut
	BOOL	m_VScrollDisp;			// vertikální posuvník zapnut

	int		m_X;					// aktuální souøadice kurzoru myši (v ikonách)
	int		m_Y;					// aktuální souøadice kurzoru myši (v ikonách)

// obsluha tažení
	BOOL	m_BegDrag;				// je možné zahájení tažení
	int		m_BegX;					// poèáteèní souøadnice kurzoru myši X pøed tažením
	int		m_BegY;					// poèáteèní souøadnice kurzoru myši Y pøed tažením
	BOOL	m_Copy;					// pøíznak módu kopie (pravé tlaèítko)
	BOOL	m_Draging;				// zahájen mód tažení
	int		m_DragX;				// tažený prvek - souøadnice X
	int		m_DragY;				// tažený prvek - souøadnice Y
	CSize	m_HotSpot;				// bod uchycení taženého prvku
	CIconBuf	m_DragIcon;			// buffer tažené ikony
	CImageList*	m_DragList;			// seznam obrázkù pro tažení


	HCURSOR		m_CurAkt;			// aktivní kurzor
	HCURSOR		m_CurArrow;			// standardní kurzor šipky (IDC_ARROW)
	HCURSOR		m_CurSelect;		// kurzor pro výbìr
	HCURSOR		m_CurSelMove;		// kurzor - pøesun výbìru
	HCURSOR		m_CurCopy;			// kurzor kopírování
	HCURSOR		m_CurMove;			// kurzor pøesunu
	HCURSOR		m_CurDelete;		// tažení se zrušením
	HCURSOR		m_CurNoDrag;		// zákaz tažení

	void BegEdit(short Index);
	void Recalc();
	void DispSirkaVyska();
	void OnSetMapSirka();
	void OnSetMapVyska();
	void SetScroll();
	void DragDrop(short item);
	void EndDrag();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CEditMap)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
public:

	// Generated message map functions
	//{{AFX_MSG(CEditMap)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnPaint();
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	virtual BOOL OnInitDialog();
	afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDblClk(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
