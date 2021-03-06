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

#define TRACKSIRKA		16					// ���ka posuvn�ku

/////////////////////////////////////////////////////////////////////////////
// CEditMap dialog


CEditMap::CEditMap(CWnd* pParent /*=NULL*/)
	: CDialog(CEditMap::IDD, pParent)
{
	//{{AFX_DATA_INIT(CEditMap)
	//}}AFX_DATA_INIT

	m_Data = NULL;						// nejsou data
	m_Width = 25;						// ���ka editovan� plochy
	m_Height = 20;						// v��ka editovan� plochy
	m_IconWidth = 32;					// ���ka ikony
	m_IconHeight = 32;					// v��ka ikony
	m_DragList = NULL;
	m_BegDrag = FALSE;					// nen� zah�jeno ta�en�

	m_tLeft = 0;						// po��te�n� bod plochy vlevo
	m_tBottom = 0;						// po��te�n� bod plochy dole

	m_X = -1;
	m_Y = -1;

	m_Draging = FALSE;					// nen� ta�en�

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
// nastaven� ���ky a v��ky pomoc� edita�n�ch pol� (aktualizuje zobrazen�)

void CEditMap::OnSetMapSirka()
{
// lok�ln� prom�nn�
	CString txt;				// buffer textu
	int sirka;					// na�ten� hodnota ���ky
	CEdit* edit;				// pracovn� prvek edita�n�ho pole

// p�ednastaven� pro p��pad ne�sp�chu
	sirka = m_Width;

// zji�t�n� edita�n�ho pole
	edit = (CEdit*)(MainFrame->
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_SIRKA_EDIT));
	if (edit != NULL)
	{

// na�ten� textu z edita�n�ho pole
		edit->GetWindowText(txt);

// na�ten� zadan�ho ��sla
#ifdef	_UNICODE
		swscanf(txt, _T("%d"), &sirka);
#else
		sscanf(txt, _T("%d"), &sirka);
#endif
	}

// kontrola zadan� hodnoty
	if (sirka < 1) sirka = m_Width;
	if (sirka > MAXMAPWIDTH) sirka = MAXMAPWIDTH;

// ��slo nezm�n�no - aktualizace zobrazen�
	if (sirka == m_Width)
	{
		DispSirkaVyska();
	}

// nastaven� nov�ho zadan�ho ��sla
	else
	{
		m_Map->SetSize(m_Index, sirka, m_Height);
		BegEdit(m_Index);
	}
}

void CEditMap::OnSetMapVyska()
{
// lok�ln� prom�nn�
	CString txt;				// buffer textu
	int vyska;					// na�ten� hodnota v��ky
	CEdit* edit;				// pracovn� prvek edita�n�ho pole

// p�ednastaven� pro p��pad ne�sp�chu
	vyska = m_Height;

// zji�t�n� edita�n�ho pole
	edit = (CEdit*)(MainFrame->
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_VYSKA_EDIT));
	if (edit != NULL)
	{

// na�ten� textu z edita�n�ho pole
		edit->GetWindowText(txt);

// na�ten� zadan�ho ��sla
#ifdef	_UNICODE
		swscanf(txt, _T("%d"), &vyska);
#else
		sscanf(txt, _T("%d"), &vyska);
#endif
	}

// kontrola zadan� hodnoty
	if (vyska < 1) vyska = m_Height;
	if (vyska > MAXMAPHEIGHT) vyska = MAXMAPHEIGHT;

// ��slo nezm�n�no - aktualizace zobrazen�
	if (vyska == m_Height)
	{
		DispSirkaVyska();
	}

// nastaven� nov�ho zadan�ho ��sla
	else
	{
		m_Map->SetSize(m_Index, m_Width, vyska);
		BegEdit(m_Index);
	}
}

/////////////////////////////////////////////////////////////////////////////
// zah�jen� editace (i opakovan� po zm�n� rozm�r�)

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
// zobrazen� aktu�ln�ho nastaven� ���ky a v��ky

void CEditMap::DispSirkaVyska()
{
	CEdit* edit;				// pracovn� prvek edita�n�ho pole
	TCHAR buff[50];				// buffer k dek�dov�n� textu ��sla

// ���ka plochy
	wsprintf(buff, _T("%d"), m_Width);
	edit = (CEdit*)(MainFrame->
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_SIRKA_EDIT));
	if (edit != NULL)
	{
		edit->SetWindowText(buff);
	}

// v��ka plochy
	wsprintf(buff, _T("%d"), m_Height);
	edit = (CEdit*)(MainFrame->
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_VYSKA_EDIT));
	if (edit != NULL)
	{
		edit->SetWindowText(buff);
	}
}


/////////////////////////////////////////////////////////////////////////////
// p�epo�et rozm�r� plochy

void CEditMap::Recalc()
{
// lok�ln� prom�nn�
	CRect	rc;							// klientsk� oblast cel�ho okna

// rozm�ry klientsk� oblasti pro editovanou plochu
	GetClientRect(&rc);					// na�ten� rozm�r� okna
	m_cWidth = rc.right;				// ���ka klientsk� oblasti pro plochu
	m_cHeight = rc.bottom;				// v��ka klientsk� oblasti pro plochu

// zmen�en� v��ky, je-li horizont�ln� posuvn�k
	if (m_cWidth - TRACKSIRKA < m_mWidth)
	{
		m_cHeight -= TRACKSIRKA;		// sn�en� v��ky klientsk� oblasti
		if (m_cHeight < 1) m_cHeight = 1; // ochrana p�ed nesmysly
	}

// zmen�en� ���ky, je-li vertik�ln� posuvn�k
	if (m_cHeight < m_mHeight)
	{
		m_cWidth -= TRACKSIRKA;			// sn�en� ���ky klientsk� oblasti
		if (m_cWidth < 1) m_cWidth = 1;	// ochrana p�ed nesmysly
	}

// ���ka a v��ka zobrzen� ��sti plochy
	m_dWidth = m_mWidth;				// ���ka celkem
	if (m_dWidth > m_cWidth) m_dWidth = m_cWidth; // omezen� na klientskou plochu
	m_dHeight = m_mHeight;				// v��ka celkem
	if (m_dHeight > m_cHeight) m_dHeight = m_cHeight;

// lev� a horn� po��tek zobrazen� plochy v okn�
	m_dLeft = (m_cWidth - m_dWidth)/2;	// lev� po��tek zobrazen� ��sti plochy
	m_dTop = (m_cHeight - m_dHeight)/2;	// horn� po��tek zobrazen� ��sti plochy

// omezen� po��te�n�ho bodu vlevo
	if (m_tLeft < 0)					// nesm� b�t z�porn�
		m_tLeft = 0;					// minim�ln� hodnota
	if (m_tLeft > m_mWidth - m_dWidth)	// zb�v� ji� m�n� bod� ?
		m_tLeft = m_mWidth - m_dWidth;	// omezen� na zbyl� po�et bod�

// omezen� po��te�n�ho bodu dole
	if (m_tBottom < 0)					// nesm� b�t z�porn�
		m_tBottom = 0;					// minim�ln� hodnota
	if (m_tBottom > m_mHeight - m_dHeight) // zb�v� ji� m�n� bod� ?
		m_tBottom = m_mHeight - m_dHeight; // omezen� na zbyl� po�et bod�

// p�epo�et zobrazen�ho po��tku na ikony a body
	m_iLeft = m_tLeft / m_IconWidth;	// v�po�et prvn� zobrazen� ikony vlevo (i necel�)
	m_oLeft = m_IconWidth - (m_tLeft % m_IconWidth); // ���ka prvn� zobrazen� ikony vlevo
	m_iBottom = m_tBottom / m_IconHeight; // v�po�et prvn� zobrazen� ikony dole (i necel�)
	m_oBottom = m_IconHeight - (m_tBottom % m_IconHeight); // ���ka prvn� zobrazen� ikony dole

// v�po�et ���ky ikon vpravo a naho�e
	m_oRight = m_IconWidth - ((m_mWidth - m_tLeft - m_dWidth) % m_IconWidth);
	m_oTop = m_IconHeight - ((m_mHeight - m_tBottom - m_dHeight) % m_IconHeight);

// v�po�et posledn� zobrazen� ikony
	m_iRight = m_iLeft + (m_dWidth - m_oLeft + m_IconWidth - 1) / m_IconWidth;
	m_iTop = m_iBottom + (m_dHeight - m_oBottom + m_IconHeight - 1) / m_IconHeight;

// p��prava zapnut� posuvn�k�
	if (m_dWidth < m_mWidth)
		m_HScrollDisp = TRUE;			// horizont�ln� posuvn�k zapnut
	else
		m_HScrollDisp = FALSE;			// horizont�ln� posuvn�k vypnut

	if (m_dHeight < m_mHeight)
		m_VScrollDisp = TRUE;			// vertik�ln� posuvn�k zapnut
	else
		m_VScrollDisp = FALSE;			// vertik�ln� posuvn�k vypnut
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace zobrazen� posuvn�k�

void CEditMap::SetScroll()
{
// lok�ln� prom�nn�
	CRect	rc;							// klientsk� oblast cel�ho okna
	CRect	rc1;						// rozm�ry posuvn�ku
	SCROLLINFO	scr;					// informace o posuvn�c�ch

// rozm�ry klientsk� oblasti
	GetClientRect(&rc);					// na�ten� rozm�r� okna

// nastaven� horizont�ln�ho posuvn�ku
	if (m_HScroll.m_hWnd != NULL)
	{

// na�ten� aktu�ln�ho stavu
		m_HScroll.GetScrollInfo(&scr, SIF_ALL);
		scr.fMask = 0;					// p�ednastaven� - nic se nem�n�

// minim�ln� pozice
		if (scr.nMin != 0)
		{
			scr.nMin = 0;
			scr.fMask |= SIF_RANGE;
		}

// maxim�ln� pozice
		if (scr.nMax != m_mWidth)
		{
			scr.nMax = m_mWidth;
			scr.fMask |= SIF_RANGE;
		}

// velikost str�nky
		if (scr.nPage != (UINT)m_dWidth)
		{
			scr.nPage = (UINT)m_dWidth;
			scr.fMask |= SIF_PAGE;
		}

// pozice posuvn�ku
		if (scr.nPos != m_tLeft)
		{
			scr.nPos = m_tLeft;
			scr.fMask |= SIF_POS;
		}

// nastaven� nov�ch parametr� posuvn�ku

		if (scr.fMask != 0)
		{
			m_HScroll.SetScrollInfo(&scr, TRUE);
		}

// zobrazen� horizont�ln�ho posuvn�ku
		rc1.left = 0;
		rc1.top = rc.bottom - TRACKSIRKA;
		rc1.right = rc.right;
		rc1.bottom = rc.bottom;
		if (m_VScrollDisp) rc1.right -= TRACKSIRKA;

		m_HScroll.MoveWindow(&rc1,FALSE);
		m_HScroll.ShowWindow((m_HScrollDisp) ? SW_SHOWNA : SW_HIDE);
	}

// nastaven� vertik�ln�ho posuvn�ku
	if (m_VScroll.m_hWnd != NULL)
	{

// na�ten� aktu�ln�ho stavu
		m_VScroll.GetScrollInfo(&scr, SIF_ALL);
		scr.fMask = 0;					// p�ednastaven� - nic se nem�n�

// minim�ln� pozice
		if (scr.nMin != 0)
		{
			scr.nMin = 0;
			scr.fMask |= SIF_RANGE;
		}

// maxim�ln� pozice
		if (scr.nMax != m_mHeight)
		{
			scr.nMax = m_mHeight;
			scr.fMask |= SIF_RANGE;
		}

// velikost str�nky
		if (scr.nPage != (UINT)m_dHeight)
		{
			scr.nPage = m_dHeight;
			scr.fMask |= SIF_PAGE;
		}

// pozice posuvn�ku
		if (scr.nPos != m_mHeight - m_dHeight - m_tBottom)
		{
			scr.nPos = m_mHeight - m_dHeight - m_tBottom;
			scr.fMask |= SIF_POS;
		}

// nastaven� nov�ch parametr� posuvn�ku

		if (scr.fMask != 0)
		{
			m_VScroll.SetScrollInfo(&scr, TRUE);
		}

// zobrazen� vertik�ln�ho posuvn�ku
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

// p�epo�et zobrazen� plochy
	Recalc();
	SetScroll();
}

void CEditMap::OnPaint() 
{
	CPaintDC dc(this); // device context for painting
	
// lok�ln� prom�nn�
	HPALETTE OldPal;			// �schova p�vodn�ch palet
	short i,j;					// pracovn� ��ta�e
	int left, top, width, height; // rozm�ry obr�zku
	int dleft, dtop;			// zobrazen� po��tek ikony

// nastaven� vlastn�ch palet
	OldPal = ::SelectPalette(dc.m_hDC, StdPalette, FALSE);
	::RealizePalette(dc.m_hDC);

// nastaven� parametr� z�hlav� bitmapy
	StdBitmapInfo->bmiHeader.biWidth = m_IconWidth;
	StdBitmapInfo->bmiHeader.biHeight = m_IconHeight;


	left = m_IconWidth - m_oLeft;	// zdrojov� lev� okraj
	dleft = m_dLeft;			// c�lov� lev� okraj

	for (i = m_iLeft; i <= m_iRight; i++)
	{
		top = m_IconHeight - m_oTop; // zdrojov� horn� okraj
		dtop = m_dTop;		// c�lov� horn� okraj

		width = m_IconWidth - left;	// ���ka
		if (i == m_iRight)
			width = m_oRight - left;

		for (j = m_iTop; j >= m_iBottom; j--)
		{	

			height = m_IconHeight - top; // v��ka
			if (j == m_iBottom)
				height = m_oBottom - top;

// zobrazen� obr�zku
		::StretchDIBits(dc.m_hDC,
			dleft,				// c�lov� lev� okraj
			dtop,				// c�lov� horn� okraj
			width,				// c�lov� ���ka ikony
			height,				// c�lov� v��ka ikony

			left,				// zdrojov� lev� pozice
			0,					// zdrojov� horn� pozice
			width,				// zdrojov� ���ka ikony
			height,				// zdrojov� v��ka ikony

			m_Icon->Get(m_Data->item[i + j*m_Width].icon) 
				+ m_IconWidth*(m_IconHeight-top-height), 
			StdBitmapInfo,		// z�hlav� bitmapy
			DIB_RGB_COLORS, SRCCOPY);

			dtop += m_IconHeight - top; // c�lov� horn� okraj
			top = 0;			// zdrojov� horn� okraj
		}

		dleft += m_IconWidth - left; // c�lov� lev� okraj
		left = 0;				// zdrojov� lev� okraj
	}

// n�vrat p�vodn�ch palet
	::SelectPalette(dc.m_hDC,OldPal,TRUE);
	
}


void CEditMap::OnMouseMove(UINT nFlags, CPoint point) 
{
	CDialog::OnMouseMove(nFlags, point);

	int sx,sy;					// sou�adnice my�i p�epo�ten� na ikony
	CPoint itemPoint;			// sou�adnice ta�en�ho prvku
	CPoint pt2;
	CPoint	ptScreen;			// pozice ta�en� ikony na obrazovce

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

// zah�jen� ta�en�
	if (((nFlags & (MK_LBUTTON | MK_RBUTTON)) != 0) &&
		(!m_Draging) &&
		(!Prog->m_Dragging) &&
		(m_BegDrag) &&
		(m_DragX != -1) &&
		(m_DragY != -1) &&
		((abs(point.x - m_BegX) > 3) ||
		(abs(point.y - m_BegY) > 3)))
	{

// nastaven� p��znak� pro ta�en�
		m_Draging = TRUE;

// vzd�lenost kurzoru my�i od po��tku prvku
		itemPoint.x = m_dLeft + (m_DragX*m_IconWidth - m_tLeft);
		itemPoint.y = m_dTop + m_dHeight - ((m_DragY+1)*m_IconHeight-m_tBottom);
		m_HotSpot = CPoint(m_BegX, m_BegY) - itemPoint;

// vytvo�en� seznamu obr�zk� pro ta�en�
		m_DragIcon.RemoveAll();						// zru�en� ikon v bufferu
		m_DragIcon.Add(m_Icon->Get(					// p�id�n� ta�en� ikony do bufferu
			m_Data->item[m_DragX + m_DragY*m_Width].icon));
		m_DragList = m_DragIcon.GenerList();		// vytvo�en� seznamu obr�zk�

// zapnut� zobrazen� obr�zku ta�en� (bez uzamyk�n� okna)
		m_DragList->DragShowNolock(TRUE);

// nastaven� kurzoru my�i
		if (m_Copy)
			::SetCursor(m_CurCopy);
		else
			::SetCursor(m_CurMove);
		
// vytvo�en� nov�ho obr�zku ta�en�
		m_DragList->SetDragCursorImage(0, CPoint(m_HotSpot));

// zah�jen� operace ta�en�
		m_DragList->BeginDrag(0, CPoint(0,0));

// zah�jen� operace ta�en�, z�kaz aktualizace okna
		m_DragList->DragEnter(NULL, point - m_HotSpot);

// p�eta�en� obr�zku na aktu�ln� pozici my�i
			ptScreen = point - m_HotSpot;
			ClientToScreen(&ptScreen);
			m_DragList->DragMove(ptScreen);

// zah�jen� zachyt�v�n� my�i
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
// p�eta�en� obr�zku na novou pozici
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

// �schova sou�adnic p�ed zah�jen�m ta�en�
	m_BegX = point.x;			// �schova sou�adnice X
	m_BegY = point.y;			// �schova sou�adnice Y
	m_BegDrag = TRUE;
	m_Copy = FALSE;				// nen� m�d kopie
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

// �schova sou�adnic p�ed zah�jen�m ta�en�
	m_BegX = point.x;			// �schova sou�adnice X
	m_BegY = point.y;			// �schova sou�adnice Y
	m_BegDrag = TRUE;
	m_Copy = TRUE;				// je m�d kopie
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

// �schova sou�adnic p�ed zah�jen�m ta�en�
	m_BegX = point.x;			// �schova sou�adnice X
	m_BegY = point.y;			// �schova sou�adnice Y
	m_BegDrag = TRUE;
	m_Copy = FALSE;				// nen� m�d kopie
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

// �schova sou�adnic p�ed zah�jen�m ta�en�
	m_BegX = point.x;			// �schova sou�adnice X
	m_BegY = point.y;			// �schova sou�adnice Y
	m_BegDrag = TRUE;
	m_Copy = TRUE;				// je m�d kopie
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

// na�ten� pozice my�i
	POINT pt;
	::GetCursorPos(&pt);				// na�ten� pozice my�i
	ScreenToClient(&pt);				// p�evod na sou�adnice okna

// implicitn� kurzor
	m_CurAkt = m_CurArrow;				// implicitn� kurzor �ipky

// test, zda je edita�n� pole
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

// zobrazen� nov�ho kurzoru my�i
	::SetCursor(m_CurAkt);				// zobrazen� kurzoru my�i

	return TRUE;						// p��znak, �e se nem� pokra�ovat
}


void CEditMap::EndDrag()
{
	m_BegDrag = FALSE;

	if (m_Draging)
	{
		m_Draging = FALSE;

// pozastaven� ta�en�
		m_DragList->DragLeave(NULL);

// ukon�en� ta�en�
		m_DragList->EndDrag();

		if (m_DragList != NULL)
		{
			delete m_DragList;
			m_DragList = NULL;
		}

// uvoln�n� zachyt�v�n� my�i
		ReleaseCapture();

		::SetCursor(m_CurArrow);

		m_DragIcon.RemoveAll();
	}
}

