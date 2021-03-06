
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
	unsigned char* m_Push;				// buffer k mezi�schov� dat

	unsigned char* m_Undo;				// undo buffer
	int m_UndoNum;						// po�et obr�zk� v undo bufferu
	int m_UndoAkt;						// aktivn� ukazatel ukl�d�n� do undo bufferu
	int m_UndoMax;						// max. velikost undo bufferu
	int m_UndoItem;						// ��slo ikony v undo bufferu

	int m_Item;							// ��slo editovan� ikony
	int m_dWidth;						// ���ka zobrazen� ikony
	int m_dHeight;						// v��ka zobrazen� ikony
	int m_dLeft;						// po��tek X zobrazen� ikony
	int m_dTop;							// po��tek Y zobrazen� ikony
	int m_incx;							// p��rustek bod� ve sm�ru X
	int m_incy;							// p��rustek bod� ve sm�ru Y

	int m_Width;						// ���ka ikony
	int m_Height;						// v��ka ikony
	int m_WidthByte;					// d�lka linky v bajtech

	unsigned char* m_BufCol;			// buffer obr�zku palet
	int m_ColX;							// po�et barev X
	int m_ColXByte;						// ���ka obr�zku barev v bajtech
	int	m_ColY;							// po�et barev Y
	int m_cWidth;						// zobrazen� ���ka barev
	int m_cHeight;						// zobrazen� v��ka barev
	int m_cLeft;						// po��tek zobrazen� barev X
	int m_cTop;							// po��tek zobrazen� barev Y
	int m_cincx;						// p��rustek barev X
	int m_cincy;						// p��rustek barev Y

	int m_ReDisp;						// ��ta� po�adavku aktualizace strom� (0 = nen�)
	UINT m_Timer;						// identifik�tor �asova�e

	int	m_EditMode;						// aktivn� edita�n� m�d
	int m_OldEditMode;					// edita�n� m�d p�ed volbou kap�tka

	BOOL m_Editing;						// prob�h� editov�n� ��ry (�i jin�ho prvku)
	BOOL m_Moving;						// je p�esouv�ni bloku
	BOOL m_Selecting;					// je ozna�en blok

	int m_OldX;							// p�vodn� sou�adnice kreslen� X
	int m_OldY;							// p�vodn� sou�adnice kreslen� Y

	short m_TopX;						// po��te�n� sou�adnice X p�i ta�en�
	short m_TopY;						// po��te�n� sou�adnice Y p�i ta�en�
	short m_EndX;						// koncov� sou�adnice X bloku
	short m_EndY;						// koncov� sou�adnice Y bloku

	short m_FirstTopX;					// v�choz� po��te�n� sou�adnice X p�i posunu bloku
	short m_FirstTopY;					// v�choz� po��te�n� sou�adnice Y p�i posunu bloku

	short m_CitRnd;						// ��ta� n�hodn�ho ��sla

	short m_X, m_Y;						// sou�adnice kurzoru my�i v obr�zku

	CBitmap m_Pozadi;					// bitmapa pozad�
	CBitmap m_Pozadi2;					// bitmapa pozad�2

	unsigned char m_ColLeft;			// barva pro lev� tla��tko
	unsigned char m_ColRight;			// barva pro prav� tla��tko
	unsigned char m_ColInd;				// barva indik�toru barvy (-1 = nen�)

	HCURSOR m_CurAkt;					// aktivn� kurzor
	HCURSOR m_CurArrow;					// standardn� kurzor
	HCURSOR m_CurPen;					// kurzor - pero
	HCURSOR m_CurPaint;					// kurzor - �t�tec
	HCURSOR m_CurLine;					// kurzor - ��ra
	HCURSOR m_CurSpray;					// kurzor - sprej
	HCURSOR m_CurFill;					// kurzor - v�pl�
	HCURSOR m_CurRect;					// kurzor - obd�ln�k
	HCURSOR m_CurRound;					// kurzor - kruh
	HCURSOR m_CurElip;					// kurzor - elipsa
	HCURSOR m_CurKapatko;				// kurzor - kap�tko
	HCURSOR m_CurSelect;				// kurzor - v�b�r
	HCURSOR m_CurSelMove;				// kurzor - p�esun v�b�ru
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

// zah�jen� editace ikony
	void BegEdit(short Index);

// poskytnut� barvy bodu
	inline unsigned char GetPoint(short x, short y)
	{
		return m_Data[m_WidthByte*(m_Height-1-y) + x];
	}

// poskytnut� barvy bodu ze z�sobn�ku
	inline unsigned char GetPush(short x, short y)
	{
		return m_Push[m_WidthByte*(m_Height-1-y) + x];
	}

// zobrazen� obd�ln�ku (dc = NULL nekreslit na displej)
	inline void DispPoint(RECT* rc, unsigned char col, CDC* dc)
	{
		if (dc == NULL) return;							// nen� v�stup na displej

		CBrush brush;									// �t�tec
		if (col == 0)									// je pozad� ?
			if ((m_incx > 12) && (m_incy > 12))
				brush.CreatePatternBrush(&m_Pozadi2);	// barva pro pozad� 2
			else
				brush.CreatePatternBrush(&m_Pozadi);	// barva pro pozad�
		else
			brush.CreateSolidBrush(PALETTEINDEX(col));	// pln� barva
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
