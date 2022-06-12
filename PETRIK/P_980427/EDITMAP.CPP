// EditMap.cpp : implementation file
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

#define TRACKSIRKA		16					// šíøka posuvníku

/////////////////////////////////////////////////////////////////////////////
// CEditMap dialog


CEditMap::CEditMap(CWnd* pParent /*=NULL*/)
	: CDialog(CEditMap::IDD, pParent)
{
	//{{AFX_DATA_INIT(CEditMap)
	//}}AFX_DATA_INIT

	m_Data = NULL;						// nejsou data
	m_Width = 25;						// šíøka editované plochy
	m_Height = 20;						// výška editované plochy
	m_IconWidth = 32;					// šíøka ikony
	m_IconHeight = 32;					// výška ikony
	m_DragList = NULL;
	m_BegDrag = FALSE;					// není zahájeno tažení

	m_tLeft = 0;						// poèáteèní bod plochy vlevo
	m_tBottom = 0;						// poèáteèní bod plochy dole

	m_X = -1;
	m_Y = -1;

	m_Draging = FALSE;					// není tažení

	m_CurArrow = ::LoadCursor(0, MAKEINTRESOURCE(IDC_ARROW));
	ASSERT(m_CurArrow != NULL);

	m_CurSelect = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_SELECT));
	ASSERT(m_CurSelect != NULL);

	m_CurSelMove = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_SELECTMOVE));
	ASSERT(m_CurSelMove != NULL);

	m_CurCopy = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_COPY));
	ASSERT(m_CurCopy != NULL);

	m_CurMove = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_MOVE));
	ASSERT(m_CurMove != NULL);

	m_CurDelete = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_DELETE));
	ASSERT(m_CurDelete != NULL);

	m_CurNoDrag = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_NODRAG));
	ASSERT(m_CurNoDrag != NULL);
}


CEditMap::~CEditMap()
{
	if (m_DragList != NULL)
		delete m_DragList;
}


void CEditMap::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CEditMap)
	DDX_Control(pDX, IDC_EDITMAP_HSCROLL, m_HScroll);
	DDX_Control(pDX, IDC_EDITMAP_VSCROLL, m_VScroll);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CEditMap, CDialog)
	//{{AFX_MSG_MAP(CEditMap)
	ON_WM_SIZE()
	ON_WM_PAINT()
	ON_WM_MOUSEMOVE()
	ON_WM_HSCROLL()
	ON_WM_VSCROLL()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONDBLCLK()
	ON_WM_RBUTTONDOWN()
	ON_WM_RBUTTONDBLCLK()
	ON_WM_LBUTTONUP()
	ON_WM_SETCURSOR()
	ON_WM_RBUTTONUP()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// nastavení šíøky a výšky pomocí editaèních polí (aktualizuje zobrazení)

void CEditMap::OnSetMapSirka()
{
// lokální promìnné
	CString txt;				// buffer textu
	int sirka;					// naètená hodnota šíøky
	CEdit* edit;				// pracovní prvek editaèního pole

// pøednastavení pro pøípad neúspìchu
	sirka = m_Width;

// zjištìní editaèního pole
	edit = (CEdit*)(MainFrame->
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_SIRKA_EDIT));
	if (edit != NULL)
	{

// naètení textu z editaèního pole
		edit->GetWindowText(txt);

// naètení zadaného èísla
#ifdef	_UNICODE
		swscanf(txt, _T("%d"), &sirka);
#else
		sscanf(txt, _T("%d"), &sirka);
#endif
	}

// kontrola zadané hodnoty
	if (sirka < 1) sirka = m_Width;
	if (sirka > MAXMAPWIDTH) sirka = MAXMAPWIDTH;

// èíslo nezmìnìno - aktualizace zobrazení
	if (sirka == m_Width)
	{
		DispSirkaVyska();
	}

// nastavení nového zadaného èísla
	else
	{
		m_Map->SetSize(m_Index, sirka, m_Height);
		BegEdit(m_Index);
	}
}

void CEditMap::OnSetMapVyska()
{
// lokální promìnné
	CString txt;				// buffer textu
	int vyska;					// naètená hodnota výšky
	CEdit* edit;				// pracovní prvek editaèního pole

// pøednastavení pro pøípad neúspìchu
	vyska = m_Height;

// zjištìní editaèního pole
	edit = (CEdit*)(MainFrame->
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_VYSKA_EDIT));
	if (edit != NULL)
	{

// naètení textu z editaèního pole
		edit->GetWindowText(txt);

// naètení zadaného èísla
#ifdef	_UNICODE
		swscanf(txt, _T("%d"), &vyska);
#else
		sscanf(txt, _T("%d"), &vyska);
#endif
	}

// kontrola zadané hodnoty
	if (vyska < 1) vyska = m_Height;
	if (vyska > MAXMAPHEIGHT) vyska = MAXMAPHEIGHT;

// èíslo nezmìnìno - aktualizace zobrazení
	if (vyska == m_Height)
	{
		DispSirkaVyska();
	}

// nastavení nového zadaného èísla
	else
	{
		m_Map->SetSize(m_Index, m_Width, vyska);
		BegEdit(m_Index);
	}
}

/////////////////////////////////////////////////////////////////////////////
// zahájení editace (i opakovanì po zmìnì rozmìrù)

void CEditMap::BegEdit(short Index)
{
	if (Index < 0) Index = 0;
	m_Index = Index;

	m_Data = m_Map->Get(Index);

	m_Width = m_Data->width;
	m_Height = m_Data->height;

	m_mWidth = m_Width * m_IconWidth;
	m_mHeight = m_Height * m_IconHeight;

	if (m_oLeft > m_IconWidth) m_oLeft = m_IconWidth;
	if (m_oRight > m_IconWidth) m_oRight = m_IconWidth;
	if (m_oTop > m_IconHeight) m_oTop = m_IconHeight;
	if (m_oBottom > m_IconHeight) m_oBottom = m_IconHeight;

	DispSirkaVyska();

	Recalc();
	SetScroll();
	Invalidate(TRUE);
}


/////////////////////////////////////////////////////////////////////////////
// zobrazení aktuálního nastavení šíøky a výšky

void CEditMap::DispSirkaVyska()
{
	CEdit* edit;				// pracovní prvek editaèního pole
	TCHAR buff[50];				// buffer k dekódování textu èísla

// šíøka plochy
	wsprintf(buff, _T("%d"), m_Width);
	edit = (CEdit*)(MainFrame->
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_SIRKA_EDIT));
	if (edit != NULL)
	{
		edit->SetWindowText(buff);
	}

// výška plochy
	wsprintf(buff, _T("%d"), m_Height);
	edit = (CEdit*)(MainFrame->
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_VYSKA_EDIT));
	if (edit != NULL)
	{
		edit->SetWindowText(buff);
	}
}


/////////////////////////////////////////////////////////////////////////////
// pøepoèet rozmìrù plochy

void CEditMap::Recalc()
{
// lokální promìnné
	CRect	rc;							// klientská oblast celého okna

// rozmìry klientské oblasti pro editovanou plochu
	GetClientRect(&rc);					// naètení rozmìrù okna
	m_cWidth = rc.right;				// šíøka klientské oblasti pro plochu
	m_cHeight = rc.bottom;				// výška klientské oblasti pro plochu

// zmenšení výšky, je-li horizontální posuvník
	if (m_cWidth - TRACKSIRKA < m_mWidth)
	{
		m_cHeight -= TRACKSIRKA;		// snížení výšky klientské oblasti
		if (m_cHeight < 1) m_cHeight = 1; // ochrana pøed nesmysly
	}

// zmenšení šíøky, je-li vertikální posuvník
	if (m_cHeight < m_mHeight)
	{
		m_cWidth -= TRACKSIRKA;			// snížení šíøky klientské oblasti
		if (m_cWidth < 1) m_cWidth = 1;	// ochrana pøed nesmysly
	}

// šíøka a výška zobrzené èásti plochy
	m_dWidth = m_mWidth;				// šíøka celkem
	if (m_dWidth > m_cWidth) m_dWidth = m_cWidth; // omezení na klientskou plochu
	m_dHeight = m_mHeight;				// výška celkem
	if (m_dHeight > m_cHeight) m_dHeight = m_cHeight;

// levý a horní poèátek zobrazení plochy v oknì
	m_dLeft = (m_cWidth - m_dWidth)/2;	// levý poèátek zobrazené èásti plochy
	m_dTop = (m_cHeight - m_dHeight)/2;	// horní poèátek zobrazené èásti plochy

// omezení poèáteèního bodu vlevo
	if (m_tLeft < 0)					// nesmí být záporný
		m_tLeft = 0;					// minimální hodnota
	if (m_tLeft > m_mWidth - m_dWidth)	// zbývá již ménì bodù ?
		m_tLeft = m_mWidth - m_dWidth;	// omezení na zbylý poèet bodù

// omezení poèáteèního bodu dole
	if (m_tBottom < 0)					// nesmí být záporný
		m_tBottom = 0;					// minimální hodnota
	if (m_tBottom > m_mHeight - m_dHeight) // zbývá již ménì bodù ?
		m_tBottom = m_mHeight - m_dHeight; // omezení na zbylý poèet bodù

// pøepoèet zobrazeného poèátku na ikony a body
	m_iLeft = m_tLeft / m_IconWidth;	// výpoèet první zobrazené ikony vlevo (i necelé)
	m_oLeft = m_IconWidth - (m_tLeft % m_IconWidth); // šíøka první zobrazené ikony vlevo
	m_iBottom = m_tBottom / m_IconHeight; // výpoèet první zobrazené ikony dole (i necelé)
	m_oBottom = m_IconHeight - (m_tBottom % m_IconHeight); // šíøka první zobrazené ikony dole

// výpoèet šíøky ikon vpravo a nahoøe
	m_oRight = m_IconWidth - ((m_mWidth - m_tLeft - m_dWidth) % m_IconWidth);
	m_oTop = m_IconHeight - ((m_mHeight - m_tBottom - m_dHeight) % m_IconHeight);

// výpoèet poslední zobrazené ikony
	m_iRight = m_iLeft + (m_dWidth - m_oLeft + m_IconWidth - 1) / m_IconWidth;
	m_iTop = m_iBottom + (m_dHeight - m_oBottom + m_IconHeight - 1) / m_IconHeight;

// pøíprava zapnutí posuvníkù
	if (m_dWidth < m_mWidth)
		m_HScrollDisp = TRUE;			// horizontální posuvník zapnut
	else
		m_HScrollDisp = FALSE;			// horizontální posuvník vypnut

	if (m_dHeight < m_mHeight)
		m_VScrollDisp = TRUE;			// vertikální posuvník zapnut
	else
		m_VScrollDisp = FALSE;			// vertikální posuvník vypnut
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace zobrazení posuvníkù

void CEditMap::SetScroll()
{
// lokální promìnné
	CRect	rc;							// klientská oblast celého okna
	CRect	rc1;						// rozmìry posuvníku
	SCROLLINFO	scr;					// informace o posuvnících

// rozmìry klientské oblasti
	GetClientRect(&rc);					// naètení rozmìrù okna

// nastavení horizontálního posuvníku
	if (m_HScroll.m_hWnd != NULL)
	{

// naètení aktuálního stavu
		m_HScroll.GetScrollInfo(&scr, SIF_ALL);
		scr.fMask = 0;					// pøednastavení - nic se nemìní

// minimální pozice
		if (scr.nMin != 0)
		{
			scr.nMin = 0;
			scr.fMask |= SIF_RANGE;
		}

// maximální pozice
		if (scr.nMax != m_mWidth)
		{
			scr.nMax = m_mWidth;
			scr.fMask |= SIF_RANGE;
		}

// velikost stránky
		if (scr.nPage != (UINT)m_dWidth)
		{
			scr.nPage = (UINT)m_dWidth;
			scr.fMask |= SIF_PAGE;
		}

// pozice posuvníku
		if (scr.nPos != m_tLeft)
		{
			scr.nPos = m_tLeft;
			scr.fMask |= SIF_POS;
		}

// nastavení nových parametrù posuvníku

		if (scr.fMask != 0)
		{
			m_HScroll.SetScrollInfo(&scr, TRUE);
		}

// zobrazení horizontálního posuvníku
		rc1.left = 0;
		rc1.top = rc.bottom - TRACKSIRKA;
		rc1.right = rc.right;
		rc1.bottom = rc.bottom;
		if (m_VScrollDisp) rc1.right -= TRACKSIRKA;

		m_HScroll.MoveWindow(&rc1,FALSE);
		m_HScroll.ShowWindow((m_HScrollDisp) ? SW_SHOWNA : SW_HIDE);
	}

// nastavení vertikálního posuvníku
	if (m_VScroll.m_hWnd != NULL)
	{

// naètení aktuálního stavu
		m_VScroll.GetScrollInfo(&scr, SIF_ALL);
		scr.fMask = 0;					// pøednastavení - nic se nemìní

// minimální pozice
		if (scr.nMin != 0)
		{
			scr.nMin = 0;
			scr.fMask |= SIF_RANGE;
		}

// maximální pozice
		if (scr.nMax != m_mHeight)
		{
			scr.nMax = m_mHeight;
			scr.fMask |= SIF_RANGE;
		}

// velikost stránky
		if (scr.nPage != (UINT)m_dHeight)
		{
			scr.nPage = m_dHeight;
			scr.fMask |= SIF_PAGE;
		}

// pozice posuvníku
		if (scr.nPos != m_mHeight - m_dHeight - m_tBottom)
		{
			scr.nPos = m_mHeight - m_dHeight - m_tBottom;
			scr.fMask |= SIF_POS;
		}

// nastavení nových parametrù posuvníku

		if (scr.fMask != 0)
		{
			m_VScroll.SetScrollInfo(&scr, TRUE);
		}

// zobrazení vertikálního posuvníku
		rc1.left = rc.right - TRACKSIRKA;
		rc1.top = 0;
		rc1.right = rc.right;
		rc1.bottom = rc.bottom;
		if (m_HScrollDisp) rc1.bottom -= TRACKSIRKA;

		m_VScroll.MoveWindow(&rc1,FALSE);
		m_VScroll.ShowWindow((m_VScrollDisp) ? SW_SHOWNA : SW_HIDE);
	}
}


/////////////////////////////////////////////////////////////////////////////
// CEditMap message handlers

void CEditMap::OnSize(UINT nType, int cx, int cy) 
{
	CDialog::OnSize(nType, cx, cy);

// pøepoèet zobrazené plochy
	Recalc();
	SetScroll();
}

void CEditMap::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	
// lokální promìnné
	HPALETTE OldPal;			// úschova pùvodních palet
	short i,j;					// pracovní èítaèe
	int left, top, width, height; // rozmìry obrázku
	int dleft, dtop;			// zobrazený poèátek ikony

// nastavení vlastních palet
	OldPal = ::SelectPalette(dc.m_hDC, StdPalette, FALSE);
	::RealizePalette(dc.m_hDC);

// nastavení parametrù záhlaví bitmapy
	StdBitmapInfo->bmiHeader.biWidth = m_IconWidth;
	StdBitmapInfo->bmiHeader.biHeight = m_IconHeight;


	left = m_IconWidth - m_oLeft;	// zdrojový levý okraj
	dleft = m_dLeft;			// cílový levý okraj

	for (i = m_iLeft; i <= m_iRight; i++)
	{
		top = m_IconHeight - m_oTop; // zdrojový horní okraj
		dtop = m_dTop;		// cílový horní okraj

		width = m_IconWidth - left;	// šíøka
		if (i == m_iRight)
			width = m_oRight - left;

		for (j = m_iTop; j >= m_iBottom; j--)
		{	

			height = m_IconHeight - top; // výška
			if (j == m_iBottom)
				height = m_oBottom - top;

// zobrazení obrázku
		::StretchDIBits(dc.m_hDC,
			dleft,				// cílový levý okraj
			dtop,				// cílový horní okraj
			width,				// cílová šíøka ikony
			height,				// cílová výška ikony

			left,				// zdrojová levá pozice
			0,					// zdrojová horní pozice
			width,				// zdrojová šíøka ikony
			height,				// zdrojová výška ikony

			m_Icon->Get(m_Data->item[i + j*m_Width].icon) 
				+ m_IconWidth*(m_IconHeight-top-height), 
			StdBitmapInfo,		// záhlaví bitmapy
			DIB_RGB_COLORS, SRCCOPY);

			dtop += m_IconHeight - top; // cílový horní okraj
			top = 0;			// zdrojový horní okraj
		}

		dleft += m_IconWidth - left; // cílový levý okraj
		left = 0;				// zdrojový levý okraj
	}

// návrat pùvodních palet
	::SelectPalette(dc.m_hDC,OldPal,TRUE);
	
}


void CEditMap::OnMouseMove(UINT nFlags, CPoint point) 
{
	CDialog::OnMouseMove(nFlags, point);

	int sx,sy;					// souøadnice myši pøepoètené na ikony
	CPoint itemPoint;			// souøadnice taženého prvku
	CPoint pt2;
	CPoint	ptScreen;			// pozice tažené ikony na obrazovce

	if (m_Draging)
	{
		pt2 = point - m_HotSpot + CPoint(m_IconWidth/2, m_IconHeight/2);
	}
	else
	{
		pt2 = point;
	}

	sx = (pt2.x - m_dLeft - m_oLeft + m_IconWidth)/m_IconWidth + m_iLeft;
	sy = m_iTop - (pt2.y - m_dTop - m_oTop + m_IconHeight)/m_IconHeight;

	if ((pt2.x >= m_dLeft) && (point.y >= m_dTop) &&
		(pt2.x < m_dLeft + m_dWidth) && (point.y < m_dTop + m_dHeight))
	{
		m_X = sx;
		m_Y = sy;
	}
	else
	{
		m_X = -1;
		m_Y = -1;
	}

// zahájení tažení
	if (((nFlags & (MK_LBUTTON | MK_RBUTTON)) != 0) &&
		(!m_Draging) &&
		(!Prog->m_Dragging) &&
		(m_BegDrag) &&
		(m_DragX != -1) &&
		(m_DragY != -1) &&
		((abs(point.x - m_BegX) > 3) ||
		(abs(point.y - m_BegY) > 3)))
	{

// nastavení pøíznakù pro tažení
		m_Draging = TRUE;

// vzdálenost kurzoru myši od poèátku prvku
		itemPoint.x = m_dLeft + (m_DragX*m_IconWidth - m_tLeft);
		itemPoint.y = m_dTop + m_dHeight - ((m_DragY+1)*m_IconHeight-m_tBottom);
		m_HotSpot = CPoint(m_BegX, m_BegY) - itemPoint;

// vytvoøení seznamu obrázkù pro tažení
		m_DragIcon.RemoveAll();						// zrušení ikon v bufferu
		m_DragIcon.Add(m_Icon->Get(					// pøidání tažené ikony do bufferu
			m_Data->item[m_DragX + m_DragY*m_Width].icon));
		m_DragList = m_DragIcon.GenerList();		// vytvoøení seznamu obrázkù

// zapnutí zobrazení obrázku tažení (bez uzamykání okna)
		m_DragList->DragShowNolock(TRUE);

// nastavení kurzoru myši
		if (m_Copy)
			::SetCursor(m_CurCopy);
		else
			::SetCursor(m_CurMove);
		
// vytvoøení nového obrázku tažení
		m_DragList->SetDragCursorImage(0, CPoint(m_HotSpot));

// zahájení operace tažení
		m_DragList->BeginDrag(0, CPoint(0,0));

// zahájení operace tažení, zákaz aktualizace okna
		m_DragList->DragEnter(NULL, point - m_HotSpot);

// pøetažení obrázku na aktuální pozici myši
			ptScreen = point - m_HotSpot;
			ClientToScreen(&ptScreen);
			m_DragList->DragMove(ptScreen);

// zahájení zachytávání myši
		SetCapture();
	}
	else
	{
		if (m_Draging && ((nFlags & (MK_LBUTTON | MK_RBUTTON) == 0)))
		{
			EndDrag();
		}
		else
		{
			if (m_Draging)
			{
// pøetažení obrázku na novou pozici
				ptScreen = point - m_HotSpot;
				ClientToScreen(&ptScreen);
				m_DragList->DragMove(ptScreen);


				if ((m_X == -1) || (m_Y == -1))
				{
					if (m_Copy)
						::SetCursor(m_CurNoDrag);
					else
						::SetCursor(m_CurDelete);
				}
				else
					if (m_Copy)
						::SetCursor(m_CurCopy);
					else
						::SetCursor(m_CurMove);
			}
		}
	}
}

BOOL CEditMap::OnInitDialog() 
{
	CDialog::OnInitDialog();

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}


void CEditMap::OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
	if (pScrollBar != NULL)
	{
		if (pScrollBar->m_hWnd == m_HScroll.m_hWnd)
		{
			int pos = pScrollBar->GetScrollPos();

			switch (nSBCode)
			{
			case SB_LEFT:
				pos = 0;
				break;
			case SB_LINELEFT:
				pos -= m_IconWidth;
				break;
			case SB_LINERIGHT:
				pos += m_IconWidth;
				break;
			case SB_PAGELEFT:
				pos -= (m_dWidth/m_IconWidth-1)*m_IconWidth;
				break;
			case SB_PAGERIGHT:
				pos += (m_dWidth/m_IconWidth-1)*m_IconWidth;
				break;
			case SB_RIGHT:
				pos = m_mWidth - m_dWidth;
				break;
			case SB_THUMBPOSITION:
			case SB_THUMBTRACK:
				pos = nPos;
			}

			if (pos < 0) pos = 0;
			if (pos >= m_mWidth - m_dWidth)
				pos = m_mWidth - m_dWidth;

			if (pos != m_tLeft)
			{
				m_tLeft = pos;
				Recalc();
				SetScroll();
				Invalidate(FALSE);
			}
		}
	}

	CDialog::OnHScroll(nSBCode, nPos, pScrollBar);
}

void CEditMap::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
	if (pScrollBar != NULL)
	{
		if (pScrollBar->m_hWnd == m_VScroll.m_hWnd)
		{
			int pos = pScrollBar->GetScrollPos();

			switch (nSBCode)
			{
			case SB_TOP:
				pos = 0;
				break;
			case SB_LINEUP:
				pos -= m_IconHeight;
				break;
			case SB_LINEDOWN:
				pos += m_IconHeight;
				break;
			case SB_PAGEUP:
				pos -= (m_dHeight/m_IconHeight-1)*m_IconHeight;
				break;
			case SB_PAGEDOWN:
				pos += (m_dHeight/m_IconHeight-1)*m_IconHeight;
				break;
			case SB_BOTTOM:
				pos = m_mHeight - m_dHeight;
				break;
			case SB_THUMBPOSITION:
			case SB_THUMBTRACK:
				pos = nPos;
			}

			if (pos < 0) pos = 0;
			if (pos >= m_mHeight - m_dHeight)
				pos = m_mHeight - m_dHeight;
			pos = m_mHeight - m_dHeight - pos;

			if (pos != m_tBottom)
			{
				m_tBottom = pos;
				Recalc();
				SetScroll();
				Invalidate(FALSE);
			}
		}
	}

	CDialog::OnVScroll(nSBCode, nPos, pScrollBar);
}

void CEditMap::DragDrop(short item)
{
	if ((item < 0) || 
		(item >= m_Icon->GetSize()) ||
		(m_X < 0) ||
		(m_X >= m_Width) ||
		(m_Y < 0) ||
		(m_Y >= m_Height))
		return;

	m_Data->item[m_X + m_Y*m_Width].icon = item;

	Invalidate(FALSE);
}

void CEditMap::OnLButtonDown(UINT nFlags, CPoint point) 
{
	CDialog::OnLButtonDown(nFlags, point);

	if (m_Draging)
	{
		EndDrag();
		return;
	}

	if ((m_X == -1) || (m_Y == -1)) return;

// úschova souøadnic pøed zahájením tažení
	m_BegX = point.x;			// úschova souøadnice X
	m_BegY = point.y;			// úschova souøadnice Y
	m_BegDrag = TRUE;
	m_Copy = FALSE;				// není mód kopie
		m_DragX = m_X;
		m_DragY = m_Y;
	
	short item = m_Data->item[m_X + m_Y*m_Width].icon;
	
	Prog->m_Buf[BufObjID].SetAkt(Prog->m_Buf[BufObjID].SrcDat(BufPicID, item));
	Prog->m_Buf[BufLocID].SetAkt(Prog->m_Buf[BufLocID].SrcDat(BufPicID, item));
}

void CEditMap::OnRButtonDown(UINT nFlags, CPoint point) 
{
	CDialog::OnRButtonDown(nFlags, point);

	if (m_Draging)
	{
		EndDrag();
		return;
	}

	if ((m_X == -1) || (m_Y == -1)) return;

// úschova souøadnic pøed zahájením tažení
	m_BegX = point.x;			// úschova souøadnice X
	m_BegY = point.y;			// úschova souøadnice Y
	m_BegDrag = TRUE;
	m_Copy = TRUE;				// je mód kopie
		m_DragX = m_X;
		m_DragY = m_Y;

	short item = m_Data->item[m_X + m_Y*m_Width].icon;
	
	Prog->m_Buf[BufObjID].SetAkt(Prog->m_Buf[BufObjID].SrcDat(BufPicID, item));
	Prog->m_Buf[BufLocID].SetAkt(Prog->m_Buf[BufLocID].SrcDat(BufPicID, item));
}

void CEditMap::OnLButtonDblClk(UINT nFlags, CPoint point) 
{
	CDialog::OnLButtonDblClk(nFlags, point);

	if (m_Draging)
	{
		EndDrag();
		return;
	}

	if ((m_X == -1) || (m_Y == -1)) return;

// úschova souøadnic pøed zahájením tažení
	m_BegX = point.x;			// úschova souøadnice X
	m_BegY = point.y;			// úschova souøadnice Y
	m_BegDrag = TRUE;
	m_Copy = FALSE;				// není mód kopie
		m_DragX = m_X;
		m_DragY = m_Y;

	short item = m_Data->item[m_X + m_Y*m_Width].icon;
	
	Prog->m_Buf[BufObjID].SetAkt(Prog->m_Buf[BufObjID].SrcDat(BufPicID, item));
	Prog->m_Buf[BufLocID].SetAkt(Prog->m_Buf[BufLocID].SrcDat(BufPicID, item));

	Prog->m_EditItem = item;
	Prog->SetEditMode(TYP_PIC);
	Prog->AktAllDef();
}

void CEditMap::OnRButtonDblClk(UINT nFlags, CPoint point) 
{
	CDialog::OnRButtonDblClk(nFlags, point);

	if (m_Draging)
	{
		EndDrag();
		return;
	}

	if ((m_X == -1) || (m_Y == -1)) return;

// úschova souøadnic pøed zahájením tažení
	m_BegX = point.x;			// úschova souøadnice X
	m_BegY = point.y;			// úschova souøadnice Y
	m_BegDrag = TRUE;
	m_Copy = TRUE;				// je mód kopie
		m_DragX = m_X;
		m_DragY = m_Y;

	short item = m_Data->item[m_X + m_Y*m_Width].icon;
	
	Prog->m_Buf[BufObjID].SetAkt(Prog->m_Buf[BufObjID].SrcDat(BufPicID, item));
	Prog->m_Buf[BufLocID].SetAkt(Prog->m_Buf[BufLocID].SrcDat(BufPicID, item));

	Prog->m_EditItem = item;
	Prog->SetEditMode(TYP_PIC);
	Prog->AktAllDef();
}


void CEditMap::OnLButtonUp(UINT nFlags, CPoint point) 
{
	CDialog::OnLButtonUp(nFlags, point);

	if (m_Draging)
	{
		short newitem = -1;
		short olditem = 0;

		newitem = m_Data->item[m_DragX + m_DragY*m_Width].icon;

		if ((m_X != -1) && (m_Y != -1))
		{
			olditem = m_Data->item[m_X + m_Y*m_Width].icon;
			m_Data->item[m_X + m_Y*m_Width].icon = newitem;
		}

		if (!m_Copy)
		{
			m_Data->item[m_DragX + m_DragY*m_Width].icon = olditem;
		}

		Invalidate(FALSE);
	}

	EndDrag();
}


void CEditMap::OnRButtonUp(UINT nFlags, CPoint point) 
{
	CDialog::OnRButtonUp(nFlags, point);

	if (m_Draging)
	{
		short newitem = -1;
		short olditem = 0;

		newitem = m_Data->item[m_DragX + m_DragY*m_Width].icon;

		if ((m_X != -1) && (m_Y != -1))
		{
			olditem = m_Data->item[m_X + m_Y*m_Width].icon;
			m_Data->item[m_X + m_Y*m_Width].icon = newitem;
		}

		if (!m_Copy)
		{
			m_Data->item[m_DragX + m_DragY*m_Width].icon = olditem;
		}

		Invalidate(FALSE);
	}

	EndDrag();
}


BOOL CEditMap::OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message) 
{

// naètení pozice myši
	POINT pt;
	::GetCursorPos(&pt);				// naètení pozice myši
	ScreenToClient(&pt);				// pøevod na souøadnice okna

// implicitní kurzor
	m_CurAkt = m_CurArrow;				// implicitní kurzor šipky

// test, zda je editaèní pole
	if (m_Draging)
	{
		if (m_Copy)
			m_CurAkt = m_CurCopy;
		else
			m_CurAkt = m_CurMove;

		if ((m_X == -1) || (m_Y == -1))
		{
			if (m_Copy)
				m_CurAkt = m_CurNoDrag;
			else
				m_CurAkt = m_CurDelete;
		}

	}

// zobrazení nového kurzoru myši
	::SetCursor(m_CurAkt);				// zobrazení kurzoru myši

	return TRUE;						// pøíznak, že se nemá pokraèovat
}


void CEditMap::EndDrag()
{
	m_BegDrag = FALSE;

	if (m_Draging)
	{
		m_Draging = FALSE;

// pozastavení tažení
		m_DragList->DragLeave(NULL);

// ukonèení tažení
		m_DragList->EndDrag();

		if (m_DragList != NULL)
		{
			delete m_DragList;
			m_DragList = NULL;
		}

// uvolnìní zachytávání myši
		ReleaseCapture();

		::SetCursor(m_CurArrow);

		m_DragIcon.RemoveAll();
	}
}

