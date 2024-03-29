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

// prim�rn� parametry plochy
	short	m_Index;				// index editovan� mapy
	MAP*	m_Data;					// ukazatel na data plochy
	int		m_Width;				// ���ka editovan� plochy (pol��ek)
	int		m_Height;				// v��ka editovan� plochy (pol��ek)
	int		m_IconWidth;			// ���ka ikony (bod�)
	int		m_IconHeight;			// v��ka ikony (bod�)

// u�ivatelem nastaven� po��tek zobrazen� plochy
	int		m_tLeft;				// po��te�n� bod plochy vlevo
	int		m_tBottom;				// po��te�n� bod plochy dole

// rozm�ry ikony v bodech celkem
	int		m_mWidth;				// ���ka editovan� plochy celkem (v bodech)
	int		m_mHeight;				// v��ka editovan� plochy celkem (v bodech)

// sou�adnice klientsk� oblasti pro plochu
	int		m_cWidth;				// ���ka klientsk� oblasti pro editovanou plochu
	int		m_cHeight;				// v��ka klientsk� oblasti pro editovanou plochu

// skute�n� zobrazen� ��st plochy v bodech
	int		m_dWidth;				// ���ka zobrazen� ��sti plochy v bodech
	int		m_dHeight;				// v��ka zobrazen� ��sti plochy v bodech
	int		m_dLeft;				// lev� po��tek zobrazen� ��sti plochy
	int		m_dTop;					// horn� po��tek zobrazen� ��sti plochy

// skute�n� zobrazen� ��st plochy v ikon�ch (okrajov� ikony mohou b�t zobrazeny ne�pln�)
	int		m_iLeft;				// lev� prvn� zobrazen� ikona (i necel�)
	int		m_iBottom;				// spodn� prvn� zobrazen� ikona (i necel�)
	int		m_iRight;				// prav� posledn� zobrazen� ikona (i necel�)
	int		m_iTop;					// horn� posledn� zobrazen� ikona (i necel�)

// ne�pln� zobrazen� okrajov�ch ikon (rozsah 1 a� m_IconWidth,m_IconHeight)
	int		m_oLeft;				// po�et bod� ikony vlevo
	int		m_oBottom;				// po�et bod� ikony dole
	int		m_oRight;				// po�et bod� ikony vpravo
	int		m_oTop;					// po�et bod� ikony naho�e

// posuvn�ky
	BOOL	m_HScrollDisp;			// horizont�ln� posuvn�k zapnut
	BOOL	m_VScrollDisp;			// vertik�ln� posuvn�k zapnut

	int		m_X;					// aktu�ln� sou�adice kurzoru my�i (v ikon�ch)
	int		m_Y;					// aktu�ln� sou�adice kurzoru my�i (v ikon�ch)

// obsluha ta�en�
	BOOL	m_BegDrag;				// je mo�n� zah�jen� ta�en�
	int		m_BegX;					// po��te�n� sou�adnice kurzoru my�i X p�ed ta�en�m
	int		m_BegY;					// po��te�n� sou�adnice kurzoru my�i Y p�ed ta�en�m
	BOOL	m_Copy;					// p��znak m�du kopie (prav� tla��tko)
	BOOL	m_Draging;				// zah�jen m�d ta�en�
	int		m_DragX;				// ta�en� prvek - sou�adnice X
	int		m_DragY;				// ta�en� prvek - sou�adnice Y
	CSize	m_HotSpot;				// bod uchycen� ta�en�ho prvku
	CIconBuf	m_DragIcon;			// buffer ta�en� ikony
	CImageList*	m_DragList;			// seznam obr�zk� pro ta�en�


	HCURSOR		m_CurAkt;			// aktivn� kurzor
	HCURSOR		m_CurArrow;			// standardn� kurzor �ipky (IDC_ARROW)
	HCURSOR		m_CurSelect;		// kurzor pro v�b�r
	HCURSOR		m_CurSelMove;		// kurzor - p�esun v�b�ru
	HCURSOR		m_CurCopy;			// kurzor kop�rov�n�
	HCURSOR		m_CurMove;			// kurzor p�esunu
	HCURSOR		m_CurDelete;		// ta�en� se zru�en�m
	HCURSOR		m_CurNoDrag;		// z�kaz ta�en�

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
