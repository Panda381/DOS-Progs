// EditIcon.cpp : implementation file
//

#include "stdafx.h"
#include "peter.h"

#include "Select.h"
#include "Exec.h"
#include "IconBuf.h"
#include "TextBuf.h"
#include "RealBuf.h"
#include "BoolBuf.h"
#include "ProgBuf.h"
#include "MapBuf.h"
#include "EditDial.h"
#include "EditSprt.h"
#include "EditIcon.h"
#include "EditMap.h"
#include "Prog.h"
#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


#define ZOBRAZRAM 5				// hladina pro zobrazení rámu výbìru barev
#define TIMEOUT 18
#define UNDOMAX 10				// pøírustek pro undo buffer

/////////////////////////////////////////////////////////////////////////////
// CEditIcon dialog


CEditIcon::CEditIcon(CWnd* pParent /*=NULL*/)
	: CDialog(CEditIcon::IDD, pParent)
{
	m_Item = -1;
	m_dWidth = 32;
	m_dHeight = 32;
	m_dLeft = 0;
	m_dTop = 0;
	m_incx = 1;
	m_incy = 1;

	m_Height = 32;
	m_Width = 32;
	m_WidthByte = 32;

	m_ColX = 10;
	m_ColY = 6;
	m_cWidth = 10;
	m_cHeight = 6;
	m_cLeft = 0;
	m_cTop = 0;
	m_cincx = 1;
	m_cincy = 1;

	m_OldX = 0;
	m_OldY = 0;

	m_TopX = 0;
	m_TopY = 0;
	m_EndX = m_Width-1;
	m_EndY = m_Height-1;

	m_ColLeft = StdColors-2*ColLev;	// bílá
	m_ColRight = StdColors - 1;		// èerná
	m_ColInd = 255;

	m_ReDisp = 0;
	m_Timer = 0;

	m_Editing = FALSE;				// není editování
	m_Selecting = FALSE;			// není výbìr bloku
	m_Moving = FALSE;				// není pøesouvání bloku
	m_EditMode = EditModePen;
	m_OldEditMode = EditModePen;

// naètení bitmapy pozadí
	m_Pozadi.LoadBitmap(IDB_POZADI);
	m_Pozadi2.LoadBitmap(IDB_POZADI2);

// pøíprava poètu barev
	m_ColX = ColCol+1;							// poèet odstínù barev
	m_ColXByte = (m_ColX + 3) & ~0x03;			// šíøka obrázku v bajtech
	m_ColY = ColLev;							// poèet hladin barev

// vytvoøení bufferu pro obrázek výbìru barev
	m_BufCol = NULL;
	Aloc(m_BufCol, m_ColXByte*m_ColY);			// vytvoøení bufferu pro data

// vytvoøení bufferu pro meziúschovu obrázku
	m_Push = NULL;
	Aloc(m_Push, m_WidthByte*m_Height);

	m_Data = m_Push;

// undo buffer
	m_Undo = NULL;
	m_UndoNum = 0;
	m_UndoAkt = 0;
	m_UndoMax = 0;
	m_UndoItem = -1;

// vygenerování dat obrázku výbìru barev
	unsigned char col = 1;

	for (int i = 0; i < m_ColX; i++)
	{
		for (int j = 0; j < m_ColY; j++)
		{
			if (i == 0)
			{
				m_BufCol[(m_ColY - 1 - j)*m_ColXByte] = 0;
			}
			else
			{
				m_BufCol[(m_ColY - 1 - j)*m_ColXByte + i] = col;
				col++;
			}
		}
	}


	//{{AFX_DATA_INIT(CEditIcon)
	//}}AFX_DATA_INIT

	m_CurArrow = ::LoadCursor(0, MAKEINTRESOURCE(IDC_ARROW));
	ASSERT(m_CurArrow != NULL);

	m_CurPen = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_PEN));
	ASSERT(m_CurPen != NULL);

	m_CurPaint = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_PAINT));
	ASSERT(m_CurPaint != NULL);

	m_CurLine = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_LINE));
	ASSERT(m_CurLine != NULL);

	m_CurSpray = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_SPRAY));
	ASSERT(m_CurSpray != NULL);

	m_CurFill = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_FILL));
	ASSERT(m_CurFill != NULL);

	m_CurRect = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_RECT));
	ASSERT(m_CurRect != NULL);

	m_CurRound = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_ROUND));
	ASSERT(m_CurRound != NULL);

	m_CurElip = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_ELIP));
	ASSERT(m_CurElip != NULL);

	m_CurKapatko = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_KAPATKO));
	ASSERT(m_CurKapatko != NULL);

	m_CurSelect = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_SELECT));
	ASSERT(m_CurSelect != NULL);

	m_CurSelMove = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_SELECTMOVE));
	ASSERT(m_CurSelMove != NULL);

	m_CurRuka = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_RUKA));
	ASSERT(m_CurRuka != NULL);
}

CEditIcon::~CEditIcon()
{
	Aloc(m_BufCol, 0);
	Aloc(m_Push, 0);
	Aloc(m_Undo, 0);
}

void CEditIcon::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CEditIcon)
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CEditIcon, CDialog)
	//{{AFX_MSG_MAP(CEditIcon)
	ON_WM_SIZE()
	ON_WM_PAINT()
	ON_WM_SETCURSOR()
	ON_WM_LBUTTONDOWN()
	ON_WM_RBUTTONDOWN()
	ON_WM_TIMER()
	ON_WM_CLOSE()
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONUP()
	ON_WM_RBUTTONUP()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// zahájení editace ikony

void CEditIcon::BegEdit(short Index)
{
	if (Index < 0) Index = 0;
	if (Index == m_Item) return;
	m_Item = Index;
	if (m_UndoItem == -1) m_UndoItem = m_Item;
	m_Data = m_Icon->Get(m_Item);

	m_Moving = FALSE;
	m_Selecting = FALSE;
	m_Editing = FALSE;

	Invalidate(FALSE);
}


/////////////////////////////////////////////////////////////////////////////
// CEditIcon message handlers

void CEditIcon::OnSize(UINT nType, int cx, int cy) 
{
	CDialog::OnSize(nType, cx, cy);
	
// parametry obrázku
	m_dWidth = cx;
	m_dHeight = cy*4/5;
	if (m_dHeight > m_dWidth)
		m_dHeight = m_dWidth;
	else
		m_dWidth = m_dHeight;

	m_incy = m_dHeight / m_Height;
	if (m_incy < 1) m_incy = 1;
	m_dHeight = m_incy * m_Height;

	m_incx = m_dWidth / m_Width;
	if (m_incx < 1) m_incx = 1;
	m_dWidth = m_incx * m_Width;
	
	m_dLeft = (cx - m_dWidth) / 2;
	m_dTop = (cy*4/5 - m_dHeight) / 2;

// parametry barev
	m_cWidth = cx;
	m_cHeight = cy/5;

	m_cincy = m_cHeight / m_ColY;
	if (m_cincy < 1) m_cincy = 1;
	m_cHeight = m_cincy * m_ColY;

	m_cincx = m_cWidth / m_ColX;
	if (m_cincx < 1) m_incx = 1;
	m_cWidth = m_cincx * m_ColX;
	
	m_cLeft = (cx - m_cWidth) / 2;
	m_cTop = cy - m_cHeight;
}


/////////////////////////////////////////////////////////////////////////////
// vykreslení editaèního okna

void CEditIcon::OnPaint() 
{
	CPaintDC dc(this);
	OnPaintDC(dc);
}

void CEditIcon::OnPaintDC(CDC& dc)
{
// lokální promìnné
	short i,j;					// pracovní èítaèe
//	CPen* OldPen;				// úschova pùvodního pera
	HPALETTE OldPal;			// úschova pùvodních palet
	RECT rc;
//	unsigned char col;			// barva

// nastavení vlastních palet
	OldPal = ::SelectPalette(dc.m_hDC, StdPalette, FALSE);
	::RealizePalette(dc.m_hDC);

// pøekreslení ikony
	IconPaint(&dc);

// vykreslení pole výbìru barev
	StdBitmapInfo->bmiHeader.biWidth = m_ColX;
	StdBitmapInfo->bmiHeader.biHeight = m_ColY;

	::StretchDIBits(dc.m_hDC,
		m_cLeft, m_cTop, m_cWidth, m_cHeight,
		0, 0, m_ColX, m_ColY, m_BufCol, StdBitmapInfo,
		DIB_RGB_COLORS, SRCCOPY);

	StdBitmapInfo->bmiHeader.biHeight = m_Width;

// souøadnice pole s barvou podkladu
		rc.left = m_cLeft;
		rc.right = m_cLeft + m_cincx;
		rc.top = m_cTop;
		rc.bottom = m_cTop + m_cHeight;

// vykreslení pole podkladu
	DispPoint(&rc, 0, &dc);

// kontrola, zda je dostateèná velikost k vykreslení rámeèkù
	if ((m_cincx > ZOBRAZRAM) && (m_cincy > ZOBRAZRAM))
	{

// vykreslení rámeèku pole s barvou podkladu
		dc.DrawEdge(&rc, EDGE_SUNKEN, BF_RECT);

// cyklus pøes všechny sloupce (kromì prvního sloupce s podkladem)
		rc.left = m_cLeft + m_cincx;
		for (i = 1; i < m_ColX; i++)
		{

// cyklus pøes všechny øádky
			rc.right = rc.left + m_cincx;
			rc.top = m_cTop;
			for (j = 0; j < m_ColY; j++)
			{

// vykreslení rámeèku pole
				rc.bottom = rc.top + m_cincy;
				dc.DrawEdge(&rc, EDGE_SUNKEN, BF_RECT);
				rc.top = rc.bottom;
			}
			rc.left = rc.right;
		}
	}

// zobrazení ukazatelù vybrané barvy
	DispSelCol(m_ColLeft, 6);
	DispSelCol(m_ColRight, 3);
	DispSelCol(m_ColInd, 2);

// návrat pùvodních palet
	::SelectPalette(dc.m_hDC,OldPal,TRUE);

// zobrazení výbìru bloku (nefunguje s dc)
	if (m_Selecting)
	{
		CDC* dc2 = GetDC();
		DispSelect(dc2);
		ReleaseDC(dc2);
	}
}


/////////////////////////////////////////////////////////////////////////////
// pøekreslení obrázku ikony

void CEditIcon::IconPaint(CDC* dc)
{
// lokální promìnné
	short i,j;					// pracovní èítaèe
	CPen* OldPen;				// úschova pùvodního pera
	RECT rc;
	unsigned char col;			// barva

// nastavení parametrù záhlaví bitmapy
	StdBitmapInfo->bmiHeader.biWidth = m_Icon->m_Width;
	StdBitmapInfo->bmiHeader.biHeight = m_Icon->m_Height;

// zobrazení obrázku
	::StretchDIBits(dc->m_hDC,
		m_dLeft,m_dTop,m_dWidth,m_dHeight,0,0,m_Width,m_Height,
		m_Icon->Get(m_Item), StdBitmapInfo,
		DIB_RGB_COLORS, SRCCOPY);

// výbìr èerného pera
	OldPen = (CPen*) dc->SelectStockObject(BLACK_PEN);

	if ((m_incx > 4) && (m_incy > 4))
	{

// nakreslení vertikálních èar pøes obrázek
		for (i = 0; i <= m_Width; i++)
		{
			dc->MoveTo(m_dLeft + i*m_incx, m_dTop);
			dc->LineTo(m_dLeft + i*m_incx, m_dTop + m_dHeight + 1);
		}

// nakreslení horizontálních èar pøes obrázek
		for (i = 0; i <= m_Height; i++)
		{
			dc->MoveTo(m_dLeft, m_dTop + i*m_incy);
			dc->LineTo(m_dLeft + m_dWidth, m_dTop + i*m_incy);
		}
	}

// návrat pùvodního pera
	dc->SelectObject(OldPen);

// vykreslení bodù pozadí
	if ((m_incx > 5) && (m_incy > 5))
	{
		for (i = 0; i < m_Width; i++)
		{
			for (j = 0; j < m_Height; j++)
			{
				col = GetPoint(i,j);

				if (col == 0)
				{
					rc.left = m_dLeft + i*m_incx + 1;
					rc.top = m_dTop + j*m_incy + 1;
					rc.right = rc.left + m_incx - 1;
					rc.bottom = rc.top + m_incy - 1;
					DispPoint(&rc, col, dc);
				}
			}
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// zobrazení kurzoru myši

BOOL CEditIcon::OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message) 
{
// naètení pozice myši
	POINT pt;
	::GetCursorPos(&pt);				// naètení pozice myši
	ScreenToClient(&pt);				// pøevod na souøadnice okna

// implicitní kurzor
	m_CurAkt = m_CurArrow;				// implicitní kurzor šipky

// test, zda je editaèní pole
	if (((pt.x >= m_dLeft) &&
		(pt.x < m_dLeft + m_dWidth) &&
		(pt.y >= m_dTop) &&
		(pt.y < m_dTop + m_dHeight)) ||
		m_Editing)
	{
		switch (m_EditMode)
		{
			case EditModePipe:	m_CurAkt = m_CurKapatko;
								break;

			case EditModePaint:	m_CurAkt = m_CurPaint;
								break;

			case EditModeLine:	m_CurAkt = m_CurLine;
								break;

			case EditModeSpray:	m_CurAkt = m_CurSpray;
								break;

			case EditModeFill:	m_CurAkt = m_CurFill;
								break;

			case EditModeRect:	m_CurAkt = m_CurRect;
								break;

			case EditModeRound:	m_CurAkt = m_CurRound;
								break;

			case EditModeElip:	m_CurAkt = m_CurElip;
								break;

			case EditModeSelect:
								if (m_Selecting &&

									(((m_TopX <= m_EndX) &&
									(pt.x >= m_dLeft + m_TopX*m_incx) &&
									(pt.x < m_dLeft + (m_EndX+1)*m_incx)) ||

									((m_TopX > m_EndX) &&
									(pt.x >= m_dLeft + m_EndX*m_incx) &&
									(pt.x < m_dLeft + (m_TopX+1)*m_incx))) &&

									(((m_TopY <= m_EndY) &&
									(pt.y >= m_dTop + m_TopY*m_incy) &&
									(pt.y < m_dTop + (m_EndY+1)*m_incy)) ||

									((m_TopY > m_EndY) &&
									(pt.y >= m_dTop + m_EndY*m_incy) &&
									(pt.y < m_dTop + (m_TopY+1)*m_incy))) &&

									(!m_Editing || m_Moving))
								{
									if (m_Moving)
										m_CurAkt = m_CurRuka;
									else
										m_CurAkt = m_CurSelMove;
								}
								else
								{
									m_CurAkt = m_CurSelect;
								}

								break;

			default:			m_CurAkt = m_CurPen;
		}
	}

// test, zda je pole barev
	if ((pt.x >= m_cLeft) &&
		(pt.x < m_cLeft + m_cWidth) &&
		(pt.y >= m_cTop) &&
		(pt.y < m_cTop + m_cHeight) &&
		(!m_Editing))
		m_CurAkt = m_CurKapatko;

// zobrazení nového kurzoru myši
	::SetCursor(m_CurAkt);				// zobrazení kurzoru myši

	return TRUE;						// pøíznak, že se nemá pokraèovat
}


/////////////////////////////////////////////////////////////////////////////
// stisk levého tlaèítka myši

void CEditIcon::OnLButtonDown(UINT nFlags, CPoint point) 
{
	int sx;
	int sy;
	unsigned char col;

	CDialog::OnLButtonDown(nFlags, point);
	
// zmìna barvy
	sx = (point.x - m_cLeft) / m_cincx;
	sy = (point.y - m_cTop) / m_cincy;

	if ((point.x >= m_cLeft) && (point.y >= m_cTop) && (sx < m_ColX) && (sy < m_ColY))
	{
		col = m_BufCol[m_ColXByte*(m_ColY-1-sy) + sx];
	
		if (col != m_ColLeft)
		{
			DispCol(m_ColLeft);
			m_ColLeft = col;
			DispSelCol(m_ColLeft, 6);
			DispSelCol(m_ColRight, 3);
		}

		if (m_EditMode == EditModePipe)
			SetEditMode(EditModePipe);
	}

// nastavení bodu
	sx = (point.x - m_dLeft) / m_incx;
	sy = (point.y - m_dTop) / m_incy;

	if ((point.x >= m_dLeft) && (point.y >= m_dTop) && (sx < m_Width) && (sy < m_Height))
	{
		CDC* dc = GetDC();
		HPALETTE OldPal = ::SelectPalette(dc->m_hDC, StdPalette, FALSE);
		::RealizePalette(dc->m_hDC);

		switch (m_EditMode)
		{
		case EditModePen:
			PushUndo();
			m_Editing = TRUE;
			m_OldX = sx;
			m_OldY = sy;
			SetPoint(sx,sy,m_ColLeft, dc);
			break;

		case EditModePaint:
			PushUndo();
			m_Editing = TRUE;
			m_OldX = sx;
			m_OldY = sy;
			SetPaint(sx,sy,m_ColLeft, dc);
			break;

		case EditModeSpray:
			PushUndo();
			m_OldX = sx;
			m_OldY = sy;
			m_Editing = TRUE;
			SetSpray(sx,sy,m_ColLeft, dc);
			SetSpray(sx,sy,m_ColLeft, dc);
			SetSpray(sx,sy,m_ColLeft, dc);
			break;

		case EditModeLine:
			PushUndo();
			m_Editing = TRUE;
			Push();
			m_OldX = sx;
			m_OldY = sy;
			m_TopX = sx;
			m_TopY = sy;
			SetPoint(sx,sy,m_ColLeft, dc);
			break;

		case EditModePipe:
			col = GetPoint(sx, sy);
			if (col != m_ColLeft)
			{
				DispCol(m_ColLeft);
				m_ColLeft = col;
				DispSelCol(m_ColLeft, 6);
				DispSelCol(m_ColRight, 3);
			}
			SetEditMode(m_OldEditMode);
			break;

		case EditModeFill:
			col = GetPoint(sx, sy);
			if (col != m_ColLeft)
			{
				PushUndo();
				SetFill(sx,sy,m_ColLeft,col,dc);
			}
			break;

		case EditModeRect:
			PushUndo();
			m_Editing = TRUE;
			Push();
			m_OldX = sx;
			m_OldY = sy;
			m_TopX = sx;
			m_TopY = sy;
			SetPoint(sx,sy,m_ColLeft, dc);
			break;

		case EditModeRound:
			PushUndo();
			m_Editing = TRUE;
			Push();
			m_OldX = sx;
			m_OldY = sy;
			m_TopX = sx;
			m_TopY = sy;
			SetPoint(sx,sy,m_ColLeft, dc);
			break;

		case EditModeElip:
			PushUndo();
			m_Editing = TRUE;
			Push();
			m_OldX = sx;
			m_OldY = sy;
			m_TopX = sx;
			m_TopY = sy;
			SetPoint(sx,sy,m_ColLeft, dc);
			break;

		case EditModeSelect:
			if (m_Selecting)
			{
				if (
					((m_TopX <= m_EndX) && 
					 ((sx < m_TopX) ||(sx > m_EndX))) ||

					((m_TopX > m_EndX) && 
					 ((sx < m_EndX) ||(sx > m_TopX))) ||

					((m_TopY <= m_EndY) &&
					((sy < m_TopY) || (sy > m_EndY))) ||

					((m_TopY > m_EndY) &&
					((sy < m_EndY) || (sy > m_TopY))))
				{
					DispSelect(dc);
					m_Selecting = FALSE;
				}
				else
				{
					m_Editing = TRUE;
					m_Moving = TRUE;
					m_OldX = sx;
					m_OldY = sy;
					::SetCursor(m_CurRuka);
				}
			}

			if (!m_Selecting)
			{
				PushUndo();
				Push();
				m_Editing = TRUE;
				m_Selecting = TRUE;
				m_Moving = FALSE;
				m_OldX = sx;
				m_OldY = sy;
				m_TopX = sx;
				m_TopY = sy;
				m_EndX = sx;
				m_EndY = sy;
				m_FirstTopX = sx;
				m_FirstTopY = sy;
				DispSelect(dc);
			}
			break;

		default:;
		}

		::SelectPalette(dc->m_hDC,OldPal,TRUE);
		ReleaseDC(dc);

	}
}


/////////////////////////////////////////////////////////////////////////////
// stisk pravého tlaèítka myši

void CEditIcon::OnRButtonDown(UINT nFlags, CPoint point) 
{
	CDialog::OnRButtonDown(nFlags, point);

	int sx = (point.x - m_cLeft) / m_cincx;
	int sy = (point.y - m_cTop) / m_cincy;
	unsigned char col;

	if ((point.x >= m_cLeft) && (point.y >= m_cTop) && (sx < m_ColX) && (sy < m_ColY))
	{
		col = m_BufCol[m_ColXByte*(m_ColY-1-sy) + sx];

		if (col != m_ColRight)
		{
			DispCol(m_ColRight);
			m_ColRight = col;
			DispSelCol(m_ColLeft, 6);
			DispSelCol(m_ColRight, 3);

			if ((m_EditMode == EditModeSelect) && m_Selecting)
			{
				CDC* dc2 = GetDC();
				HPALETTE OldPal2 = ::SelectPalette(dc2->m_hDC, StdPalette, FALSE);
				::RealizePalette(dc2->m_hDC);

				DispSelect(dc2);
				MoveSelect(dc2);
				DispSelect(dc2);

				::SelectPalette(dc2->m_hDC,OldPal2,TRUE);
				ReleaseDC(dc2);
			}

		}

		if (m_EditMode == EditModePipe)
			SetEditMode(EditModePipe);
	}

// nastavení bodu
	sx = (point.x - m_dLeft) / m_incx;
	sy = (point.y - m_dTop) / m_incy;

	if ((point.x >= m_dLeft) && (point.y >= m_dTop) && (sx < m_Width) && (sy < m_Height))
	{
		CDC* dc = GetDC();
		HPALETTE OldPal = ::SelectPalette(dc->m_hDC, StdPalette, FALSE);
		::RealizePalette(dc->m_hDC);

		switch (m_EditMode)
		{
		case EditModePen:
			PushUndo();
			m_Editing = TRUE;
			m_OldX = sx;
			m_OldY = sy;
			SetPoint(sx,sy,m_ColRight, dc);
			break;

		case EditModePaint:
			PushUndo();
			m_Editing = TRUE;
			m_OldX = sx;
			m_OldY = sy;
			SetPaint(sx,sy,m_ColRight, dc);
			break;

		case EditModeSpray:
			PushUndo();
			m_OldX = sx;
			m_OldY = sy;
			m_Editing = TRUE;
			SetSpray(sx,sy,m_ColRight, dc);
			SetSpray(sx,sy,m_ColRight, dc);
			SetSpray(sx,sy,m_ColRight, dc);
			break;

		case EditModeLine:
			PushUndo();
			m_Editing = TRUE;
			Push();
			m_OldX = sx;
			m_OldY = sy;
			m_TopX = sx;
			m_TopY = sy;
			SetPoint(sx,sy,m_ColRight, dc);
			break;

		case EditModePipe:
			col = GetPoint(sx, sy);
			if (col != m_ColRight)
			{
				DispCol(m_ColRight);
				m_ColRight = col;
				DispSelCol(m_ColLeft, 6);
				DispSelCol(m_ColRight, 3);
			}
			SetEditMode(m_OldEditMode);
			break;

		case EditModeFill:
			col = GetPoint(sx, sy);
			if (col != m_ColRight)
			{
				PushUndo();
				SetFill(sx,sy,m_ColRight,col,dc);
			}
			break;

		case EditModeRect:
			PushUndo();
			m_Editing = TRUE;
			Push();
			m_OldX = sx;
			m_OldY = sy;
			m_TopX = sx;
			m_TopY = sy;
			SetPoint(sx,sy,m_ColRight, dc);
			break;

		case EditModeRound:
			PushUndo();
			m_Editing = TRUE;
			Push();
			m_OldX = sx;
			m_OldY = sy;
			m_TopX = sx;
			m_TopY = sy;
			SetPoint(sx,sy,m_ColRight, dc);
			break;

		case EditModeElip:
			PushUndo();
			m_Editing = TRUE;
			Push();
			m_OldX = sx;
			m_OldY = sy;
			m_TopX = sx;
			m_TopY = sy;
			SetPoint(sx,sy,m_ColRight, dc);
			break;

		case EditModeSelect:
			if (m_Selecting)
			{
				DispSelect(dc);
				m_Moving = FALSE;
				m_Selecting = FALSE;
				m_Editing = FALSE;
			}
			break;

		default:;
		}

		::SelectPalette(dc->m_hDC,OldPal,TRUE);
		ReleaseDC(dc);
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace zobrazení stromù (je-li to potøeba)

void CEditIcon::ReDisp()
{
	Prog->m_Ico32->DeleteImageList();
	delete Prog->m_Ico32;
	Prog->m_Ico32 = Prog->m_Icon.GenerList();

	Prog->m_Object.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);
	Prog->m_Local.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);
	Prog->m_Struc.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);
	Prog->m_Class.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);
	Prog->m_Edit.SetImageList(Prog->m_Ico32, TVSIL_NORMAL);

	Prog->m_Object.Invalidate();
	Prog->m_Local.Invalidate();
	Prog->m_Struc.Invalidate();
	Prog->m_Class.Invalidate();
	Prog->m_Edit.Invalidate();

	m_ReDisp = 0;
}


/////////////////////////////////////////////////////////////////////////////
// výplò (col = nová barva, fil = podklad) (dc = NULL nekreslit na displej)

void CEditIcon::SetFill(short x, short y, unsigned char col, unsigned char fil,  CDC* dc)
{
	short min = x;
	short max = x;
	short i;

	SetPoint(x, y, col, dc);

// výplò minimálním smìrem
	while ((min > 0) && (GetPoint(min-1,y) == fil))
	{
		min--;
		SetPoint(min, y, col, dc);
	}

// výplò maximálním smìrem
	while ((max < m_Width - 1) && (GetPoint(max+1,y) == fil))
	{
		max++;
		SetPoint(max, y, col, dc);
	}

// výplò smìrem nahoru
	if (y > 0)
	{
		y--;
		for (i = min; i <= max; i++)
		{
			if (GetPoint(i, y) == fil)
				SetFill(i,y,col,fil,dc);
		}
		y++;
	}

// výplò smìrem dolù
	if (y < m_Height - 1)
	{
		y++;
		for (i = min; i <= max; i++)
		{
			if (GetPoint(i, y) == fil)
				SetFill(i,y,col,fil,dc);
		}
		y--;
	}
}


/////////////////////////////////////////////////////////////////////////////
// nastavení bodu štìtce (vykreslí na displej, ale neaktualizuje stromy)
// (dc = NULL nekreslit na displej)

void CEditIcon::SetPaint(short x, short y, unsigned char col, CDC* dc)
{
	SetPoint(x-1, y-2, col, dc);
	SetPoint(x  , y-2, col, dc);

	SetPoint(x-2, y-1, col, dc);
	SetPoint(x-1, y-1, col, dc);
	SetPoint(x  , y-1, col, dc);
	SetPoint(x+1, y-1, col, dc);

	SetPoint(x-2, y  , col, dc);
	SetPoint(x-1, y  , col, dc);
	SetPoint(x  , y  , col, dc);
	SetPoint(x+1, y  , col, dc);

	SetPoint(x-1, y+1, col, dc);
	SetPoint(x  , y+1, col, dc);
}


/////////////////////////////////////////////////////////////////////////////
// nastavení bodu spreje (vykreslí na displej, ale neaktualizuje stromy)
// (dc = NULL nekreslit na displej)

void CEditIcon::SetSpray(short x, short y, unsigned char col, CDC* dc)
{
	SetSpray0(x-1, y-2, col, dc);
	SetSpray0(x  , y-2, col, dc);

	SetSpray0(x-2, y-1, col, dc);
	SetSpray0(x-1, y-1, col, dc);
	SetSpray0(x  , y-1, col, dc);
	SetSpray0(x+1, y-1, col, dc);

	SetSpray0(x-2, y  , col, dc);
	SetSpray0(x-1, y  , col, dc);
	SetSpray0(x  , y  , col, dc);
	SetSpray0(x+1, y  , col, dc);

	SetSpray0(x-1, y+1, col, dc);
	SetSpray0(x  , y+1, col, dc);
}

void CEditIcon::SetSpray0(short x, short y, unsigned char col, CDC* dc)
{
	if ((rand() & 0x7f) < 10)
		SetPoint(x, y, col, dc);
}

/////////////////////////////////////////////////////////////////////////////
// nastavení bodu (vykreslí na displej, ale neaktualizuje stromy) (dc = NULL nekreslit na displej)

void CEditIcon::SetPoint(short x, short y, unsigned char col, CDC* dc)
{
// kontrola souøadnic
	if ((x < 0) || (y < 0) ||
		(x >= m_Width) || (y >= m_Height))
		return;

// lokální promìnné
	RECT rc;

// test, zda je zmìna barvy
	if (GetPoint(x,y) != col)
	{

// uložení nové barvy bodu
		m_Data[m_WidthByte*(m_Height-1-y) + x] = col;

// souøadnice bodu (buï se sítí nebo bez sítì)
		if ((m_incx > 4) && (m_incy > 4))
		{
			rc.left = m_dLeft + x*m_incx + 1;
			rc.top = m_dTop + y*m_incy + 1;
			rc.right = rc.left + m_incx - 1;
			rc.bottom = rc.top + m_incy - 1;
		}
		else
		{
			rc.left = m_dLeft + x*m_incx;
			rc.top = m_dTop + y*m_incy;
			rc.right = rc.left + m_incx;
			rc.bottom = rc.top + m_incy;
		}

// zobrazení bodu na displej
		DispPoint(&rc, col, dc);

// požadavek aktualizace zobrazení stromù
		m_ReDisp = TIMEOUT;
	}
}


/////////////////////////////////////////////////////////////////////////////
// zobrazení indikátoru výbìru barvy

void CEditIcon::DispSelCol(unsigned char col, int posun)
{
// lokální promìnné
	CDC* dc = GetDC();			// otevøení kontextu zaøízení
	RECT rc;					// souøadnice`políèka
	short i,j;					// pracovní èítaèe

// je políèko s barvou pozadí ?
	if (m_BufCol[m_ColXByte*(m_ColY-1)] == col)
	{

// souøadnice políèka
		if (posun <= 2)
		{
			rc.left = m_cLeft;
			rc.top = m_cTop;
			rc.right = m_cLeft + m_cincx;
			rc.bottom = m_cTop + m_cHeight;

// vykreslení rámeèku
			dc->DrawEdge(&rc, EDGE_RAISED, BF_RECT);
		}
		else
		{
			rc.left = m_cLeft + m_cincx/posun;
			rc.top = m_cTop + m_cincy/posun;
			rc.right = m_cLeft + m_cincx - m_cincx/posun;
			rc.bottom = m_cTop + m_cHeight - m_cincy/posun;

// vykreslení rámeèku
			dc->DrawEdge(&rc, EDGE_BUMP, BF_RECT);
		}

	}
	else
	{

// cyklus pøes všechny sloupce (kromì políèka pozadí)
		for (i = 1; i < m_ColX; i++)
		{

// cyklus pøes všechny øádky
			for (j = 0; j < m_ColY; j++)
			{

// test, zda to je hledaná barva
				if (m_BufCol[i+m_ColXByte*(m_ColY-1-j)] == col)
				{

// souøadnice políèka
					if (posun <= 2)
					{
						rc.left = i*m_cincx + m_cLeft;
						rc.top = j*m_cincy + m_cTop;
						rc.right = (i+1)*m_cincx + m_cLeft;
						rc.bottom = (j+1)*m_cincy + m_cTop;

// vykreslení rámeèku
						dc->DrawEdge(&rc, EDGE_RAISED,BF_RECT);
					}
					else
					{
						rc.left = i*m_cincx + m_cLeft + m_cincx/posun;
						rc.top = j*m_cincy + m_cTop + m_cincy/posun;
						rc.right = (i+1)*m_cincx + m_cLeft - m_cincx/posun;
						rc.bottom = (j+1)*m_cincy + m_cTop - m_cincy/posun;

// vykreslení rámeèku
						dc->DrawEdge(&rc, EDGE_BUMP, BF_RECT);
					}

				}
			}
		}
	}

// uvolnìní kontextu zaøízení
	ReleaseDC(dc);
}


/////////////////////////////////////////////////////////////////////////////
// vymazání políèka pro volbu barvy

void CEditIcon::DispCol(unsigned char col)
{
// lokální promìnné
	HPALETTE OldPal;			// úschova pùvodních palet
	RECT rc;					// souøadnice`políèka
	CDC* dc = GetDC();			// otevøení kontextu zaøízení
	short i,j;					// pracovní èítaèe

// nastavení vlastních palet
	OldPal = ::SelectPalette(dc->m_hDC, StdPalette, FALSE);
	::RealizePalette(dc->m_hDC);

	StdBitmapInfo->bmiHeader.biWidth = m_ColX;
	StdBitmapInfo->bmiHeader.biHeight = m_ColY;

// je políèko s barvou pozadí ?
	if (m_BufCol[m_ColXByte*(m_ColY-1)] == col)
	{

// souøadnice políèka
		rc.left = m_cLeft;
		rc.top = m_cTop;
		rc.right = m_cLeft + m_cincx;
		rc.bottom = m_cTop + m_cHeight;

// vymazání s vykreslením rámeèku
		if ((m_cincx > ZOBRAZRAM) && (m_cincy > ZOBRAZRAM))
		{
			dc->DrawEdge(&rc, EDGE_SUNKEN, BF_RECT);
			rc.left += 2;
			rc.top += 2;
			rc.right -= 2;
			rc.bottom -= 2;
		}
		DispPoint(&rc, 0, dc);
	}

// prohledání ostatních políèek
	else
	{

// cyklus pøes všechny sloupce (kromì políèka pozadí)
		for (i = 1; i < m_ColX; i++)
		{

// cyklus pøes všechny øádky
			for (j = 0; j < m_ColY; j++)
			{

// test, zda to je hledaná barva
				if (m_BufCol[i+m_ColXByte*(m_ColY-1-j)] == col)
				{

// souøadnice políèka
					rc.left = i*m_cincx + m_cLeft;
					rc.top = j*m_cincy + m_cTop;
					rc.right = rc.left + m_cincx;
					rc.bottom = rc.top + m_cincy;

// vymazání s vykreslením rámeèku
					if ((m_cincx > ZOBRAZRAM) && (m_cincy > ZOBRAZRAM))
					{
						dc->DrawEdge(&rc, EDGE_SUNKEN, BF_RECT);
						rc.left += 2;
						rc.top += 2;
						rc.right -= 2;
						rc.bottom -= 2;
					}
					DispPoint(&rc, col, dc);
				}
			}
		}
	}

// návrat pùvodních palet
	StdBitmapInfo->bmiHeader.biHeight = m_Width;

	::SelectPalette(dc->m_hDC,OldPal,TRUE);
	ReleaseDC(dc);
}


void CEditIcon::OnTimer(UINT nIDEvent) 
{
	CDialog::OnTimer(nIDEvent);

	if (m_ReDisp)
	{
		m_ReDisp--;
		if (!m_ReDisp)
			ReDisp();
	}
}

BOOL CEditIcon::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	m_Timer = SetTimer(5623, 50, NULL);

	return TRUE; 
}

void CEditIcon::OnClose() 
{
	KillTimer(m_Timer);
	m_Timer = 0;

	CDialog::OnClose();
}

void CEditIcon::OnMouseMove(UINT nFlags, CPoint point) 
{

// nastavení bodu
	int sx = (point.x - m_dLeft) / m_incx;
	int sy = (point.y - m_dTop) / m_incy;

	if (m_Editing)
	{
		if (point.x < m_dLeft)
		{
			point.x = m_dLeft;
			sx = 0;
		}

		if (point.y < m_dTop)
		{
			point.y = m_dTop;
			sy = 0;
		}

		if (sx >= m_Width)
			sx = m_Width - 1;

		if (sy >= m_Height)
			sy = m_Height - 1;
	}

// souøadnice myši pro zobrazení
	m_X = sx;
	m_Y = sy;

	if ((point.x >= m_dLeft) && (point.y >= m_dTop) && (sx < m_Width) && (sy < m_Height))
	{	
		if ((nFlags & (MK_LBUTTON | MK_RBUTTON)) && m_Editing)
		{
			CDC* dc = GetDC();
			HPALETTE OldPal;

			OldPal = ::SelectPalette(dc->m_hDC, StdPalette, FALSE);
			::RealizePalette(dc->m_hDC);

			switch (m_EditMode)
			{
			case EditModePen:
				if (nFlags & MK_LBUTTON)
				{
					SetLine(m_OldX, m_OldY, sx, sy, m_ColLeft, dc);
				}
				else
				{
					SetLine(m_OldX, m_OldY, sx, sy, m_ColRight, dc);
				}
				m_OldX = sx;
				m_OldY = sy;
				break;

			case EditModeLine:
				if ((m_OldX != sx) || (m_OldY != sy))
				{
					Pop(dc);
					if (nFlags & MK_LBUTTON)
					{
						SetLine(m_TopX, m_TopY, sx, sy, m_ColLeft, dc);
					}
					else
					{
						SetLine(m_TopX, m_TopY, sx, sy, m_ColRight, dc);
					}
					m_OldX = sx;
					m_OldY = sy;
				}
				break;

			case EditModePaint:
				if (nFlags & MK_LBUTTON)
				{
					SetLinePaint(m_OldX, m_OldY, sx, sy, m_ColLeft, dc);
				}
				else
				{
					SetLinePaint(m_OldX, m_OldY, sx, sy, m_ColRight, dc);
				}
				m_OldX = sx;
				m_OldY = sy;
				break;

			case EditModeSpray:
				if ((m_OldX != sx) || (m_OldY != sy))
				{
					if (nFlags & MK_LBUTTON)
					{
						SetSpray(sx, sy, m_ColLeft, dc);
					}
					else
					{
						SetSpray(sx, sy, m_ColRight, dc);
					}
					m_OldX = sx;
					m_OldY = sy;
				}
				break;

			case EditModeRect:
				if ((m_OldX != sx) || (m_OldY != sy))
				{
					if (nFlags & MK_LBUTTON)
					{
						SetRect(m_TopX, m_TopY, sx, sy, m_ColLeft, dc);
					}
					else
					{
						SetRect(m_TopX, m_TopY, sx, sy, m_ColRight, dc);
					}
					m_OldX = sx;
					m_OldY = sy;
				}
				break;

			case EditModeRound:
				if ((m_OldX != sx) || (m_OldY != sy))
				{
					if (nFlags & MK_LBUTTON)
					{
						SetRound(m_TopX, m_TopY, sx, sy, m_ColLeft, dc);
					}
					else
					{
						SetRound(m_TopX, m_TopY, sx, sy, m_ColRight, dc);
					}
					m_OldX = sx;
					m_OldY = sy;
				}
				break;

			case EditModeElip:
				if ((m_OldX != sx) || (m_OldY != sy))
				{
					if (nFlags & MK_LBUTTON)
					{
						SetElip(m_TopX, m_TopY, sx, sy, m_ColLeft, dc);
					}
					else
					{
						SetElip(m_TopX, m_TopY, sx, sy, m_ColRight, dc);
					}
					m_OldX = sx;
					m_OldY = sy;
				}
				break;

			case EditModeSelect:
				if ((m_OldX != sx) || (m_OldY != sy))
				{
					if (m_Selecting)
					{
						DispSelect(dc);

						if (m_Moving)
						{
							m_TopX += sx - m_OldX;
							m_TopY += sy - m_OldY;
							m_EndX += sx - m_OldX;
							m_EndY += sy - m_OldY;
							MoveSelect(dc);
						}
						else
						{
							m_EndX = sx;
							m_EndY = sy;
						}

						DispSelect(dc);
						m_OldX = sx;
						m_OldY = sy;
					}
				}
				break;

			default:;
			}

			::SelectPalette(dc->m_hDC,OldPal,TRUE);

			if (m_ReDisp) m_ReDisp = TIMEOUT;

			ReleaseDC(dc);

			SetColInd(255);
		}
		else
		{
			m_Editing = FALSE;
			m_Moving = FALSE;
			SetColInd(GetPoint(sx, sy));
		}
	}
	else
		SetColInd(255);

	CDialog::OnMouseMove(nFlags, point);
}


/////////////////////////////////////////////////////////////////////////////
// zobrazení bloku pøi pøesunu (dc = NULL nekreslit na displej)

void CEditIcon::MoveSelect(CDC* dc)
{
// lokální promìnné
	short	x,y;					// souøadnice

// cyklus pøes všechny body
	for (x = 0; x < m_Width; x++)
	{
		for (y = 0; y < m_Height; y++)
		{

// zobrazení taženého bloku
			if (
				(((m_TopX <= m_EndX) &&
				(x >= m_TopX) && (x <= m_EndX)) ||

				((m_TopX > m_EndX) &&
				(x >= m_EndX) && (x <= m_TopX))) &&

				(((m_TopY <= m_EndY) &&
				(y >= m_TopY) && (y <= m_EndY)) ||

				((m_TopY > m_EndY) &&
				(y >= m_EndY) && (y <= m_TopY)))
				)
			{
				SetPoint(x,y,m_Push[x - m_TopX + m_FirstTopX + 
					(m_Height-1-(y - m_TopY + m_FirstTopY))*m_WidthByte],dc);
			}
			else

// zobrazení podkladové barvy
			{
				if (
					(((m_TopX <= m_EndX) &&
					(x >= m_FirstTopX) &&
					(x <= m_EndX - m_TopX + m_FirstTopX)) ||

					((m_TopX > m_EndX) &&
					(x >= m_EndX - m_TopX + m_FirstTopX) &&
					(x <= m_FirstTopX))) &&

					(((m_TopY <= m_EndY) &&
					(y >= m_FirstTopY) &&
					(y <= m_EndY - m_TopY + m_FirstTopY)) ||

					((m_TopY > m_EndY) &&
					(y >= m_EndY - m_TopY + m_FirstTopY) &&
					(y <= m_FirstTopY)))
					)
				{
					SetPoint(x,y,m_ColRight,dc);
				}

// zobrazení platného políèka
				else
				{
					SetPoint(x,y,m_Push[x + (m_Height-1-y)*m_WidthByte],dc);
				}
			}
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// nastavení obdélníku (vykreslí na displej, ale neaktualizuje stromy)
// aktualizuje obsah displeje podle uschovaného bufferu m_Push !
// (dc = NULL nekreslit na displej)

void CEditIcon::SetRect(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc)
{
	short x,y;

	if (x1 > x2)
	{
		x = x1;
		x1 = x2;
		x2 = x;
	}

	if (y1 > y2)
	{
		y = y1;
		y1 = y2;
		y2 = y;
	}


	for (x = 0; x < m_Width; x++)
	{
		for (y = 0; y < m_Height; y++)
		{
			if ((x < x1) || (x > x2) || (y < y1) || (y > y2))
			{
				SetPoint(x,y,m_Push[x + (m_Height-1-y)*m_WidthByte], dc);
			}
			else
			{
				SetPoint(x,y,col,dc);
			}
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// zobrazení kruhu (vykreslí na displej, ale neaktualizuje stromy)
// aktualizuje obsah displeje podle uschovaného bufferu m_Push !
// (dc = NULL nekreslit na displej)

void CEditIcon::SetRound(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc)
{
// lokální promìnné
	short x,y;							// ukazatele bodu
	short d;							// prùmìr kruhu
	double sx, sy;						// støed kruhu
	double dx,dy;						// vzdálenost bodu od støedu

// oprava poøadí souøadnic X
	if (x1 > x2)
	{
		x = x1;
		x1 = x2;
		x2 = x;
	}

// oprava poøadí souøadnic Y
	if (y1 > y2)
	{
		y = y1;
		y1 = y2;
		y2 = y;
	}

// prùmìr kruhu (vèetnì koncových bodù)
	d = (short)(sqrt((double)((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1)))+0.4) + 1;

// støed kruhu (zatím zaokrouhlené na celé body)
	sx = (short)((x1 + x2) / 2);		// souøadnice støedu X
	sy = (short)((y1 + y2) / 2);		// souøadnice støedu Y

// korekce støedu pro sudý prùmìr
	if ((d & 1) == 0)
	{
		sx += 0.5;
		sy += 0.5;
	}

// vykreslení kruhu
	for (x = 0; x < m_Width; x++)
	{
		for (y = 0; y < m_Height; y++)
		{
			dx = abs(x - sx)*2;
			dy = abs(y - sy)*2;

			if (dx*dx + dy*dy > (double)d*d)
			{				
				SetPoint(x,y,m_Push[x + (m_Height-1-y)*m_WidthByte], dc);
			}
			else
			{
				SetPoint(x,y,col,dc);
			}
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// zobrazení elipsy (vykreslí na displej, ale neaktualizuje stromy)
// aktualizuje obsah displeje podle uschovaného bufferu m_Push !
// (dc = NULL nekreslit na displej)

void CEditIcon::SetElip(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc)
{
// lokální promìnné
	short x,y;							// ukazatele bodu
	double sx, sy;						// støed elipsy
	double dx,dy;						// vzdálenost bodu od støedu
	double rx, ry;						// polomìr ve smìru X a Y

// oprava poøadí souøadnic X
	if (x1 > x2)
	{
		x = x1;
		x1 = x2;
		x2 = x;
	}

// oprava poøadí souøadnic Y
	if (y1 > y2)
	{
		y = y1;
		y1 = y2;
		y2 = y;
	}

// polomìr elipsy
	rx = (double)(x2 + 1 - x1) / 2;
	ry = (double)(y2 + 1 - y1) / 2;
	rx *= rx;
	ry *= ry;

// støed elipsy
	sx = (double)(x1 + x2) / 2;			// souøadnice støedu X
	sy = (double)(y1 + y2) / 2;			// souøadnice støedu Y

// vykreslení elipsy
	for (x = 0; x < m_Width; x++)
	{
		for (y = 0; y < m_Height; y++)
		{
			dx = abs(x - sx);			// vzdálenost X od støedu
			dy = abs(y - sy);			// vzdálenost Y od støedu

			if (
				(x < x1) ||
				(x > x2) ||
				(y < y1) ||
				(y > y2) ||
				(dy*dy/ry > (1 - dx*dx/rx))
				)
			{				
				SetPoint(x,y,m_Push[x + (m_Height-1-y)*m_WidthByte], dc);
			}
			else
			{
				SetPoint(x,y,col,dc);
			}
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// nastavení èáry (vykreslí na displej, ale neaktualizuje stromy)
// (dc = NULL nekreslit na displej)

void CEditIcon::SetLine(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc)
{
// lokální promìnné
	short i;						// pracovní èítaè
	short dx;						// rozdíl souøadnic X
	short dy;						// rozdíl souøadnic Y

// oprava souøadnic, aby èára šla vždy zleva doprava (tj. x1 vlevo, x2 vpravo)
	if (x2 < x1)
	{
		i = x2; x2 = x1; x1 = i;
		i = y2; y2 = y1; y1 = i;
	}

// rozdíl souøadnic X
	dx = x2 - x1;

// smìr nahoru (tj. y1 dole, y2 nahoøe)
	if (y1 >= y2)
	{

// rozdíl souøadnic Y
		dy = y1 - y2;

// strmì nahoru
		if (dx <= dy)
		{
			for (i = 0; i < dy; i++)
			{
				SetPoint(x1 + (dx*i + dy/2)/dy, y1, col, dc);
				y1--;
			}
		}

// mírnì nahoru
		else
		{
			for (i = 0; i < dx; i++)
			{
				SetPoint(x1, y1 - (dy*i + dx/2)/dx, col, dc);
				x1++;
			}
		}
	}

// smìr dolù (tj. y1 nahoøe, y2 dole)
	else
	{

// rozdíl souøadnic Y
		dy = y2 - y1;

// stromì dolù
		if (dx <= dy)
		{
			for (i = 0; i < dy; i++)
			{
				SetPoint(x1 + (dx*i + dy/2)/dy, y1, col, dc);
				y1++;
			}
		}

// mírnì dolù
		else
		{
			for (i = 0; i < dx; i++)
			{
				SetPoint(x1, y1 + (dy*i + dx/2)/dx, col, dc);
				x1++;
			}
		}
	}

// vykreslení koncového bodu (nedìlat v cyklu pro pøípad dx,dy = 0)
	SetPoint(x2, y2, col, dc);
}


/////////////////////////////////////////////////////////////////////////////
// nastavení èáry štìtcem (vykreslí na displej, ale neaktualizuje stromy)
// (dc = NULL nekreslit na displej)

void CEditIcon::SetLinePaint(short x1, short y1, short x2, short y2, unsigned char col, CDC* dc)
{
// lokální promìnné
	short i;						// pracovní èítaè
	short dx;						// rozdíl souøadnic X
	short dy;						// rozdíl souøadnic Y

// oprava souøadnic, aby èára šla vždy zleva doprava (tj. x1 vlevo, x2 vpravo)
	if (x2 < x1)
	{
		i = x2; x2 = x1; x1 = i;
		i = y2; y2 = y1; y1 = i;
	}

// rozdíl souøadnic X
	dx = x2 - x1;

// smìr nahoru (tj. y1 dole, y2 nahoøe)
	if (y1 >= y2)
	{

// rozdíl souøadnic Y
		dy = y1 - y2;

// strmì nahoru
		if (dx <= dy)
		{
			for (i = 0; i < dy; i++)
			{
				SetPaint(x1 + (dx*i + dy/2)/dy, y1, col, dc);
				y1--;
			}
		}

// mírnì nahoru
		else
		{
			for (i = 0; i < dx; i++)
			{
				SetPaint(x1, y1 - (dy*i + dx/2)/dx, col, dc);
				x1++;
			}
		}
	}

// smìr dolù (tj. y1 nahoøe, y2 dole)
	else
	{

// rozdíl souøadnic Y
		dy = y2 - y1;

// stromì dolù
		if (dx <= dy)
		{
			for (i = 0; i < dy; i++)
			{
				SetPaint(x1 + (dx*i + dy/2)/dy, y1, col, dc);
				y1++;
			}
		}

// mírnì dolù
		else
		{
			for (i = 0; i < dx; i++)
			{
				SetPaint(x1, y1 + (dy*i + dx/2)/dx, col, dc);
				x1++;
			}
		}
	}

// vykreslení koncového bodu (nedìlat v cyklu pro pøípad dx,dy = 0)
	SetPaint(x2, y2, col, dc);
}


void CEditIcon::OnLButtonUp(UINT nFlags, CPoint point) 
{
	if (m_Moving)
		::SetCursor(m_CurSelMove);

	m_Editing = FALSE;
	m_Moving = FALSE;
	CDialog::OnLButtonUp(nFlags, point);
}

void CEditIcon::OnRButtonUp(UINT nFlags, CPoint point) 
{
	m_Editing = FALSE;	
	m_Moving = FALSE;
	CDialog::OnRButtonUp(nFlags, point);
}

void CEditIcon::Push()
{
	memcpy(m_Push, m_Data, m_WidthByte*m_Height);
}


// (dc = NULL nekreslit na displej)
void CEditIcon::Pop(CDC* dc)
{
	short x,y;
//	CDC* dc = GetDC();
//	HPALETTE OldPal = ::SelectPalette(dc->m_hDC, StdPalette, FALSE);
//	::RealizePalette(dc->m_hDC);

	for (x = 0; x < m_Width; x++)
		for (y = 0; y < m_Height; y++)
			SetPoint(x,y,m_Push[x + (m_Height-1-y)*m_WidthByte], dc);

//	::SelectPalette(dc->m_hDC,OldPal,TRUE);
//	ReleaseDC(dc);
}


/////////////////////////////////////////////////////////////////////////////
// zapnutí/vypnutí zobrazení výbìru (dc = NULL nekreslit na displej)

void CEditIcon::DispSelect(CDC* dc)
{
// lokální promìnné
	int x1, y1, x2, y2;			// souøadnice obdélníku
	int x12, y12, x22, y22;		// souøadnice obdélníku
	int s;						// šíøka èáry
	HBRUSH hOldBrush = NULL;	// pùvodní štìtec

	if (dc == NULL) return;

// vytvoøení štìtce
	CBrush* brush = dc->GetHalftoneBrush(); // prokládaný štìtec

// výbìr štìtce
	if (brush != NULL)			// je štìtec platný ?
		hOldBrush = (HBRUSH)::SelectObject(dc->m_hDC, brush->m_hObject);

// šíøka èáry
	s = (m_incx + m_incy)/8;
	if (s == 0) s++;

// pøíprava souøadnic obdélníku
	x1 = m_TopX;
	x2 = m_EndX;
	y1 = m_TopY;
	y2 = m_EndY;

// oprava poøadí souøadnic X
	if (x1 > x2)
	{
		x1 = x2;
		x2 = m_TopX;
	}
	x2++;						// vèetnì koncového bodu

// oprava poøadí souøadnic Y
	if (y1 > y2)
	{
		y1 = y2;
		y2 = m_TopY;
	}
	y2++;						// vèetnì koncového bodu

// výpoèet souøadnic v bodech
	x1 = x1*m_incx + m_dLeft;
	x2 = x2*m_incx + m_dLeft + 1;
	y1 = y1*m_incy + m_dTop;
	y2 = y2*m_incy + m_dTop + 1;

// omezení souøadnic
	if (x1 < m_dLeft)	
		x12 = m_dLeft;
	else
		x12 = x1;

	if (y1 < m_dTop)
		y12 = m_dTop-s;
	else
		y12 = y1;

	if (x2 > m_dLeft + m_dWidth + 1)
		x22 = m_dLeft + m_dWidth + 1;
	else
		x22 = x2;

	if (y2 > m_dTop + m_dHeight + 1)
		y22 = m_dTop + m_dHeight + 1 + s;
	else
		y22 = y2;

// horní linka
	if (y1 >= m_dTop)
		dc->PatBlt(x12, y12, x22-x12, s, PATINVERT);

// spodní linka
	if (y2 <= m_dTop + m_dHeight + 1)
		dc->PatBlt(x12, y22-s, x22-x12, s, PATINVERT);

// levá linka
	if (x1 >= m_dLeft)
		dc->PatBlt(x12, y12+s, s, y22-y12-2*s, PATINVERT);

// pravá linka
	if (x2 <= m_dLeft + m_dWidth + 1)
		dc->PatBlt(x22-s, y12+s, s, y22-y12-2*s, PATINVERT);

// navrácení pùvodního štìtce
	if (hOldBrush != NULL)
		SelectObject(dc->m_hDC, hOldBrush); // návrat pùvodního štìtce
}


/////////////////////////////////////////////////////////////////////////////
// zmìna editaèního módu, editaèní pøíkazy

void CEditIcon::SetEditMode(int mode)
{
// lokální promìnné
	CDC* dc;					// kontext displeje
	HPALETTE OldPal;			// pùvodní palety

// editaèní pøíkazy
	if ((mode == EditModeXFlip) ||
		(mode == EditModeYFlip) ||
		(mode == EditModeRRot) ||
		(mode == EditModeLRot) ||
		(mode == EditModeXCol))
	{
		EditBlok(mode);
		return;
	}

// vypnutí módu editace
	if (m_Selecting)
	{
		dc = GetDC();
		OldPal = ::SelectPalette(dc->m_hDC, StdPalette, FALSE);
		::RealizePalette(dc->m_hDC);
		DispSelect(dc);
		m_Selecting = FALSE;
		::SelectPalette(dc->m_hDC,OldPal,TRUE);
		ReleaseDC(dc);
	}

// vypnutí módù kapátka nebo bloku (pøi opakovaném stisku aktivního módu)
	if (((m_EditMode == EditModePipe) || 
		(m_EditMode == EditModeSelect)) &&
		(mode == m_EditMode))
	{
		mode = m_OldEditMode;
	}

// ostatní tlaèítka se pøi opakování nezmìní
	if (mode == m_EditMode)
		return;

// pøi zapnutí kapátka èi bloku úschova módu
	if (((mode == EditModePipe) ||
		(mode == EditModeSelect)) &&
		(m_EditMode != EditModePipe) && 
		(m_EditMode != EditModeSelect))
	{
		m_OldEditMode = m_EditMode;
	}

// nastavení nového módu
	m_EditMode = mode;
}


/////////////////////////////////////////////////////////////////////////////
// editaèní pøíkazy

void CEditIcon::EditBlok(int mode)
{
// lokální promìnné
	CDC* dc;					// kontext displeje
	HPALETTE OldPal;			// pùvodní palety
	short x, y;					// ukazatel souøadnic
	short x1, y1, x2, y2;		// hranièní souøadnice

// pøíprava displeje
	dc = GetDC();
	OldPal = ::SelectPalette(dc->m_hDC, StdPalette, FALSE);
	::RealizePalette(dc->m_hDC);

// pøíprava souøadnic pro blokovou operaci
	if ((m_EditMode == EditModeSelect) && m_Selecting)
	{
		x1 = m_FirstTopX;
		x2 = m_EndX-m_TopX+m_FirstTopX;
		y1 = m_FirstTopY;
		y2 = m_EndY-m_TopY+m_FirstTopY;
	}
	else
	{
		x1 = 0;
		x2 = m_Width-1;
		y1 = 0;
		y2 = m_Height-1;
	}

// oprava poøadí souøadnic
	if (x1 > x2)
	{
		x = x1;
		x1 = x2;
		x2 = x;
	}

	if (y1 > y2)
	{
		y = y1;
		y1 = y2;
		y2 = y;
	}

// korekce pro rotaèní pøíkazy
	if ((mode == EditModeRRot) || (mode == EditModeLRot))
	{
		if ((y2 - y1) > (x2 - x1))
			y2 = y1 + x2 - x1;

		if ((x2 - x1) > (y2 - y1))
			x2 = x1 + y2 - y1;
	}

// vypnutí bloku, pøíp. úschova obsahu
	if (m_Selecting)
	{
		DispSelect(dc);
		Pop(NULL);
	}
	else
	{
		Push();
	}

// cyklus pøes všechny body
	for (x = x1; x <= x2; x++)
	{
		for (y = y1; y <= y2; y++)
		{
			switch (mode)
			{

// horízontální pøevrácení
			case EditModeXFlip:

				SetPoint(x,y,GetPush(x2-(x-x1),y),NULL);
				break;

// vertikální pøevrácení
			case EditModeYFlip:

				SetPoint(x,y,GetPush(x,y2-(y-y1)),NULL);
				break;

// otoèení vpravo
			case EditModeRRot:

				SetPoint(x,y,GetPush(y-y1+x1,y2-(x-x1)),NULL);
				break;

// otoèení vlevo
			case EditModeLRot:

				SetPoint(x,y,GetPush(x2-(y-y1),x-x1+y1),NULL);
				break;

// zámìna barev
			case EditModeXCol:

				if (GetPush(x,y) == m_ColLeft)
				{
					SetPoint(x,y,m_ColRight,NULL);
				}
				else
				{
					if (GetPush(x,y) == m_ColRight)
					{
						SetPoint(x,y,m_ColLeft,NULL);
					}
				}
			}
		}
	}

// navrácení bloku
	if (m_Selecting) 
	{
		Push();
		MoveSelect(NULL);
	}

// pøekreslení displeje
	IconPaint(dc);

// zapnutí bloku
	if (m_Selecting) 
	{
		DispSelect(dc);
	}

// návrat kontextu displeje
	::SelectPalette(dc->m_hDC,OldPal,TRUE);
	ReleaseDC(dc);
}


/////////////////////////////////////////////////////////////////////////////
// uložení ikony do undo bufferu - do aktuálního ukazatele, posune jej

void CEditIcon::PushUndo()
{
// po zmìnì ikony se buffer nuluje
	if (m_UndoItem != m_Item)
	{
		m_UndoAkt = 0;
		m_UndoItem = m_Item;
	}

// zrušení položek za aktivním ukazatelem
	m_UndoNum = m_UndoAkt+1;

// zvìtšení bufferu
	if (m_UndoNum > m_UndoMax)
	{
		m_UndoMax += UNDOMAX;
		Aloc(m_Undo, m_UndoMax*m_WidthByte*m_Height);
	}

// kopie aktivní položky do bufferu
	memcpy(&m_Undo[m_UndoAkt*m_WidthByte*m_Height], m_Data, m_WidthByte*m_Height);

// zvýšení ukazatele
	m_UndoAkt++;
}


/////////////////////////////////////////////////////////////////////////////
// navrácení ikony z undo bufferu - z aktuálního ukazatele, neposune jej

void CEditIcon::PopUndo()
{
// lokální promìnné
	CDC* dc;					// kontext displeje
	HPALETTE OldPal;			// pùvodní palety

// navrácení minule editované ikony
	if (m_UndoItem != m_Item)
	{
		if ((m_UndoItem < 0) ||
			(m_UndoItem >= m_Icon->GetSize()))
			return;

		BegEdit(m_UndoItem);
		return;
	}

// kontrola, zda je co navracet
	if (m_UndoAkt >= m_UndoNum)
		return;

// navrácení dat
	memcpy(m_Data, &m_Undo[m_UndoAkt*m_WidthByte*m_Height], m_WidthByte*m_Height);

// pøíprava displeje k obnovení
	dc = GetDC();
	OldPal = ::SelectPalette(dc->m_hDC, StdPalette, FALSE);
	::RealizePalette(dc->m_hDC);

// vypnutí bloku
	m_Selecting = FALSE;

// pøekreslení displeje
	IconPaint(dc);

// návrat kontextu displeje
	::SelectPalette(dc->m_hDC,OldPal,TRUE);
	ReleaseDC(dc);

// požadavek aktualizace zobrazení stromù
	m_ReDisp = TIMEOUT;
}


/////////////////////////////////////////////////////////////////////////////
// UNDO

void CEditIcon::Undo()
{
// navrácení minule editované ikony
	if (m_UndoItem != m_Item)
	{
		PopUndo();
		return;
	}

// kontrola, zda je co navracet
	if (m_UndoAkt == 0)
		return;

// úschova aktuálního stavu, je-li na konci
	if (m_UndoAkt == m_UndoNum)
	{
		PushUndo();
		m_UndoAkt--;
	}

// posun ukazatele v bufferu
	m_UndoAkt--;

// obnovení ikony
	PopUndo();
}


/////////////////////////////////////////////////////////////////////////////
// REDO

void CEditIcon::Redo()
{
// navrácení minule editované ikony
	if (m_UndoItem != m_Item)
	{
		PopUndo();
		return;
	}

// kontrola, zda je co navracet
	if (m_UndoAkt >= m_UndoNum-1)
		return;

// posun ukazatele
	m_UndoAkt++;

// obnovení ikony
	PopUndo();
}


/////////////////////////////////////////////////////////////////////////////
// nastavení indikátoru barvy

void CEditIcon::SetColInd(unsigned char col)
{
	if (col == m_ColInd) return;

	DispCol(m_ColInd);

	if (m_ColLeft == m_ColInd)
		DispSelCol(m_ColLeft, 6);

	if (m_ColRight == m_ColInd)
		DispSelCol(m_ColRight, 3);

	m_ColInd = col;

	DispSelCol(m_ColInd, 2);
}

