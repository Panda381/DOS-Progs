
// EditIcon.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CEditIcon dialog

class CEditIcon : public CDialog
{
// Construction
public:
	CEditIcon(CWnd* pParent = NULL);   // standard constructor
	~CEditIcon();

// Dialog Data
	//{{AFX_DATA(CEditIcon)
	enum { IDD = IDD_EDIT_ICON };
	//}}AFX_DATA

	CIconBuf* m_Icon;					// buffer ikon
	unsigned char* m_Data;				// data ikony
	unsigned char* m_Push;				// buffer k meziúschovì dat

	unsigned char* m_Undo;				// undo buffer
	int m_UndoNum;						// poèet obrázkù v undo bufferu
	int m_UndoAkt;						// aktivní ukazatel ukládání do undo bufferu
	int m_UndoMax;						// max. velikost undo bufferu
	int m_UndoItem;						// èíslo ikony v undo bufferu

	int m_Item;							// èíslo editované ikony
	int m_dWidth;						// šíøka zobrazené ikony
	int m_dHeight;						// výška zobrazené ikony
	int m_dLeft;						// poèátek X zobrazené ikony
	int m_dTop;							// poèátek Y zobrazené ikony
	int m_incx;							// pøírustek bodù ve smìru X
	int m_incy;							// pøírustek bodù ve smìru Y

	int m_Width;						// šíøka ikony
	int m_Height;						// výška ikony
	int m_WidthByte;					// délka linky v bajtech

	unsigned char* m_BufCol;			// buffer obrázku palet
	int m_ColX;							// poèet barev X
	int m_ColXByte;						// šíøka obrázku barev v bajtech
	int	m_ColY;							// poèet barev Y
	int m_cWidth;						// zobrazená šíøka barev
	int m_cHeight;						// zobrazená výška barev
	int m_cLeft;						// poèátek zobrazení barev X
	int m_cTop;							// poèátek zobrazení barev Y
	int m_cincx;						// pøírustek barev X
	int m_cincy;						// pøírustek barev Y

	int m_ReDisp;						// èítaè požadavku aktualizace stromù (0 = není)
	UINT m_Timer;						// identifikátor èasovaèe

	int	m_EditMode;						// aktivní editaèní mód
	int m_OldEditMode;					// editaèní mód pøed volbou kapátka

	BOOL m_Editing;						// probíhá editování èáry (èi jiného prvku)
	BOOL m_Moving;						// je pøesouváni bloku
	BOOL m_Selecting;					// je oznaèen blok

	int m_OldX;							// pùvodní souøadnice kreslení X
	int m_OldY;							// pùvodní souøadnice kreslení Y

	short m_TopX;						// poèáteèní souøadnice X pøi tažení
	short m_TopY;						// poèáteèní souøadnice Y pøi tažení
	short m_EndX;						// koncová souøadnice X bloku
	short m_EndY;						// koncová souøadnice Y bloku

	short m_FirstTopX;					// výchozí poèáteèní souøadnice X pøi posunu bloku
	short m_FirstTopY;					// výchozí poèáteèní souøadnice Y pøi posunu bloku

	short m_CitRnd;						// èítaè náhodného èísla

	short m_X, m_Y;						// souøadnice kurzoru myši v obrázku

	CBitmap m_Pozadi;					// bitmapa pozadí
	CBitmap m_Pozadi2;					// bitmapa pozadí2

	unsigned char m_ColLeft;			// barva pro levé tlaèítko
	unsigned char m_ColRight;			// barva pro pravé tlaèítko
	unsigned char m_ColInd;				// barva indikátoru barvy (-1 = není)

	HCURSOR m_CurAkt;					// aktivní kurzor
	HCURSOR m_CurArrow;					// standardní kurzor
	HCURSOR m_CurPen;					// kurzor - pero
	HCURSOR m_CurPaint;					// kurzor - štìtec
	HCURSOR m_CurLine;					// kurzor - èára
	HCURSOR m_CurSpray;					// kurzor - sprej
	HCURSOR m_CurFill;					// kurzor - výplò
	HCURSOR m_CurRect;					// kurzor - obdélník
	HCURSOR m_CurRound;					// kurzor - kruh
	HCURSOR m_CurElip;					// kurzor - elipsa
	HCURSOR m_CurKapatko;				// kurzor - kapátko
	HCURSOR m_CurSelect;				// kurzor - výbìr
	HCURSOR m_CurSelMove;				// kurzor - pøesun výbìru
	HCURSOR m_CurRuka;					// kurzor - ruka

	void OnPaintDC(CDC& dc);
	void IconPaint(CDC* dc);
	void DispCol(unsigned char col);
	void DispSelCol(unsigned char col, int posun);
	void SetPoint(short x, short y, unsigned char col, CDC* dc);
	void SetPaint(short x, short y, unsigned char col, CDC* dc);
	void SetLine(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc);
	void SetLinePaint(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc);
	void ReDisp();
	void SetEditMode(int mode);
	void EditBlok(int mode);
	void Push();
	void Pop(CDC* dc);
	void SetSpray(short x, short y, unsigned char col, CDC* dc);
	void SetSpray0(short x, short y, unsigned char col, CDC* dc);
	void SetFill(short x, short y, unsigned char col, unsigned char fil, CDC* dc);
	void SetRect(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc);
	void SetRound(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc);
	void SetElip(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc);
	void DispSelect(CDC* dc);
	void MoveSelect(CDC* dc);
	void PushUndo();
	void PopUndo();
	void Undo();
	void Redo();
	void SetColInd(unsigned char col);

// zahájení editace ikony
	void BegEdit(short Index);

// poskytnutí barvy bodu
	inline unsigned char GetPoint(short x, short y)
	{
		return m_Data[m_WidthByte*(m_Height-1-y) + x];
	}

// poskytnutí barvy bodu ze zásobníku
	inline unsigned char GetPush(short x, short y)
	{
		return m_Push[m_WidthByte*(m_Height-1-y) + x];
	}

// zobrazení obdélníku (dc = NULL nekreslit na displej)
	inline void DispPoint(RECT* rc, unsigned char col, CDC* dc)
	{
		if (dc == NULL) return;							// není výstup na displej

		CBrush brush;									// štìtec
		if (col == 0)									// je pozadí ?
			if ((m_incx > 12) && (m_incy > 12))
				brush.CreatePatternBrush(&m_Pozadi2);	// barva pro pozadí 2
			else
				brush.CreatePatternBrush(&m_Pozadi);	// barva pro pozadí
		else
			brush.CreateSolidBrush(PALETTEINDEX(col));	// plná barva
		dc->FillRect(rc, &brush);
	}

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CEditIcon)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CEditIcon)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnPaint();
	afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnTimer(UINT nIDEvent);
	virtual BOOL OnInitDialog();
	afx_msg void OnClose();
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	//}}AFX_MSG
	void OnUpdatePen(CCmdUI* pCmdUI);
	DECLARE_MESSAGE_MAP()
};
