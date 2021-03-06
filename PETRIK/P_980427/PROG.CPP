
#include "stdafx.h"
#include "peter.h"
#include "MainFrm.h"
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

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

//////////////////////////////////////////////////////
//          !!!!!!!!!!!!!!!!!!!!!!!!!				//
//   Nastavit zarovn�v�n� p�eklada�e na 4 Bajty,	//
//  aby souhlasilo zarovn�v�n� struktur v souboru	//
//	        !!!!!!!!!!!!!!!!!!!!!!!!!				//
//////////////////////////////////////////////////////


const int SplitSize = 6;							// ���ka p�ed�lu

/////////////////////////////////////////////////////////////////////////////
// vno�en� ��sti souboru

#include "ProgInit.cpp"			// inicializace bufferu a programu
#include "ProgFile.cpp"			// obsluha ulo�en� a na�ten� souboru
#include "ProgTrak.cpp"			// obsluha ta�en� p�ed�l� oken
#include "ProgDrag.cpp"			// obsluha ta�en� ikon
#include "ProgProp.cpp"			// obsluha vlastnost� prvk�
#include "ProgNav.cpp"			// obsluha navigace

/////////////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

IMPLEMENT_DYNCREATE(CProg, CFormView)

CProg::CProg()
	: CFormView(CProg::IDD)
{
	//{{AFX_DATA_INIT(CProg)
	//}}AFX_DATA_INIT

	Prog = this;

#ifdef _DEBUG
	ASSERT((sizeof(internalID)/sizeof(internalID[0])) == INTERNALNUM);
#endif

// vytvo�en� seznam� ikon
//	HIMAGELIST hImg;

//	m_Ico16 = new CImageList();
//	hImg = ImageList_Create(16,16,ILC_COLORDDB | ILC_MASK,INTERNALNUM,10);
//	ASSERT(hImg != NULL);
//	m_Ico16->Attach(hImg);

	m_Ico32 = new CImageList();
//	hImg = ImageList_Create(32,32,ILC_COLORDDB | ILC_MASK,INTERNALNUM,10);
///	ASSERT(hImg != NULL);
//	m_Ico32->Attach(hImg);

//	m_State16 = new CImageList();
//	hImg = ImageList_Create(8,16,ILC_COLORDDB | ILC_MASK,INTERNALNUM,10);
//	ASSERT(hImg != NULL);
//	m_State16->Attach(hImg);

	m_State32 = new CImageList();
//	hImg = ImageList_Create(12,32,ILC_COLORDDB | ILC_MASK,INTERNALNUM,10);
//	ASSERT(hImg != NULL);
//	m_State32->Attach(hImg);

// inicalizace buffer� ikon (pro jin� nastaven� ne� implicitn�)
//	m_BufIco16Int.m_Width = 16;
//	m_BufIco16Int.m_Height = 16;
//	m_BufIco16.m_Width = 16;
//	m_BufIco16.m_Height = 16;
//	m_BufState16.m_Width = 8;
//	m_BufState16.m_Height = 16;
	m_BufState32.m_Width = 12;

// nav�z�n� strom� na buffery programu
	m_BufObj.m_Tree = &m_Object;	// strom objekt�
	m_BufLoc.m_Tree = &m_Local; 	// strom lok�ln�ch objekt�
	m_BufStr.m_Tree = &m_Struc; 	// strom struktur
	m_BufCls.m_Tree = &m_Class; 	// strom t��d
	m_BufEdi.m_Tree = &m_Edit;		// strom editace

// nav�z�n� seznamu text� a odkaz na buffery programu
	for (int i = 0; i < PROGBUFNUM; i++)
	{
		m_Buf[i].m_ProgBuf = &(m_Buf[0]); // adresa v�ech buffer�
		m_Buf[i].m_Text = &m_Text;		// seznam text�
		m_Buf[i].m_Real = &m_Real;		// ��seln� buffer
		m_Buf[i].m_Bool = &m_Bool;		// logick� buffer
		m_Buf[i].m_Icon = &m_Icon;		// buffer obr�zk�
		m_Buf[i].m_BufID = i;			// identifikace bufferu
	}
//	m_BufInt.m_Text = &m_TextInt;	// texty pro intern� funkce

	m_Map.m_ProgBuf = &(m_Buf[0]);	// adresa buffer�

	m_ProgPic.m_Icon = &m_Icon;		// buffer ikon pro editor
	m_ProgMap.m_Map = &m_Map;		// buffer map
	m_ProgMap.m_Icon = &m_Icon;		// buffer map

	m_Dragging = FALSE; 			// nen� ta�en�
	m_Tracking = FALSE;				// nen� ta�en� p�ed�l�
	m_TrackDisp = FALSE;			// nen� zobrazen p�ed�l ta�en�

	m_ReDispCount = 0;				// nen� po�adov�no p�ekreslen�

	m_Saving = FALSE;				// nen� ukl�d�n�/na��t�n�

	m_AktBufID = BufEdiID;			// aktivn� buffer
//	m_AktTree = &m_Edit;			// aktivn� strom
	m_FilName = FALSE;				// neprob�h� pln�n� jm�na polo�ky
	m_Editing = FALSE;				// neprob�h� editace jm�na polo�ky
	m_OldRef = -2;					// ��ta� nen� zobrazen
//	m_FindDialog = NULL;			// nen� hledac� okno
//	m_FindDisp = FALSE;				// nen� zobrazeno hledac� okno
//	m_AktDef = 2;					// aktu�ln� stav p�ep�na�e "implicitn� text"
	m_EditBufN = BufEdiID;			// aktivn� edita�n� buffer
	m_EditItem = -1;				// nen� editavn� polo�ka
	m_FilDat = FALSE;				// nen� pln�n� dat

	m_OldEditX = -2;
	m_OldEditY = -2;
	m_OldEditMapX = -2;
	m_OldEditMapY = -2;
	
}

CProg::~CProg()
{
// zru�en� seznamu ikon
//	m_Ico16->DeleteImageList();
//	delete m_Ico16;
	m_Ico32->DeleteImageList();
	delete m_Ico32;
//	m_State16->DeleteImageList();
//	delete m_State16;
	m_State32->DeleteImageList();
	delete m_State32;
}

void CProg::DoDataExchange(CDataExchange* pDX)
{
	CFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CProg)
	DDX_Control(pDX, IDC_PROG_LOGIC, m_ProgLogic);
	DDX_Control(pDX, IDC_PROG_MUSIC, m_ProgMusic);
	DDX_Control(pDX, IDC_PROG_SOUND, m_ProgSound);
	DDX_Control(pDX, IDC_PROG_TEXT, m_ProgText);
	DDX_Control(pDX, IDC_PROG_REAL, m_ProgReal);
	DDX_Control(pDX, IDC_STATIC1, m_Nadpis1);
	DDX_Control(pDX, IDC_STATIC2, m_Nadpis2);
	DDX_Control(pDX, IDC_STATIC3, m_Nadpis3);
	DDX_Control(pDX, IDC_STATIC4, m_Nadpis4);
	DDX_Control(pDX, IDC_PROG_OBJECT, m_Object);
	DDX_Control(pDX, IDC_PROG_LOCAL, m_Local);
	DDX_Control(pDX, IDC_PROG_STRUC, m_Struc);
	DDX_Control(pDX, IDC_PROG_CLASS, m_Class);
	DDX_Control(pDX, IDC_PROG, m_Edit);
	DDX_Control(pDX, IDC_PROG_SPLIT1, m_Split1);
	DDX_Control(pDX, IDC_PROG_SPLIT2, m_Split2);
	DDX_Control(pDX, IDC_PROG_SPLIT3, m_Split3);
	DDX_Control(pDX, IDC_PROG_SPLIT4, m_Split4);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CProg, CFormView)
	//{{AFX_MSG_MAP(CProg)
	ON_WM_SIZE()
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG_OBJECT, OnBeginDragProgObj)
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG_LOCAL, OnBeginDragProgLoc)
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG_STRUC, OnBeginDragProgStr)
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG_CLASS, OnBeginDragProgCls)
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG, OnBeginDragProgEdi)
	ON_WM_LBUTTONUP()
	ON_WM_RBUTTONUP()
	ON_WM_MOUSEMOVE()
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG_OBJECT, OnItemExpandedProgObj)
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG_LOCAL, OnItemExpandedProgLoc)
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG_STRUC, OnItemExpandedProgStr)
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG_CLASS, OnItemExpandedProgCls)
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG, OnItemExpandedProgEdi)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG_OBJECT, OnSetFocusObject)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG_LOCAL, OnSetFocusLocal)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG_STRUC, OnSetFocusStruc)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG_CLASS, OnSetFocusClass)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG, OnSetFocusProg)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG_OBJECT, OnSelChangedObject)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG_LOCAL, OnSelChangedLocal)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG_STRUC, OnSelChangedStruc)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG_CLASS, OnSelChangedClass)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG, OnSelChangedEdit)
	ON_NOTIFY(NM_DBLCLK, IDC_PROG_OBJECT, OnDblclkProgObject)
	ON_NOTIFY(NM_DBLCLK, IDC_PROG_LOCAL, OnDblclkProgLocal)
	ON_COMMAND(ID_FILE_SAVE2, OnFileSave)
	ON_WM_SETCURSOR()
	ON_WM_LBUTTONDOWN()
	ON_WM_TIMER()
	ON_NOTIFY(TVN_BEGINLABELEDIT, IDC_PROG_OBJECT, OnBeginLabelEdit)
	ON_NOTIFY(TVN_ENDLABELEDIT, IDC_PROG_OBJECT, OnEndLabelEdit)
	ON_COMMAND(IDC_PROG_LOCK, OnProgLock)
	ON_UPDATE_COMMAND_UI(IDC_PROG_LOCK, OnUpdateProgLock)
	ON_COMMAND(IDC_PROG_OFF, OnProgOff)
	ON_UPDATE_COMMAND_UI(IDC_PROG_OFF, OnUpdateProgOff)
	ON_COMMAND(IDC_PROG_ICON, OnProgIcon)
	ON_COMMAND(IDC_PROG_CLIP, OnProgClip)
	ON_COMMAND(IDC_PROG_DEL, OnProgDel)
	ON_UPDATE_COMMAND_UI(IDC_PROG_REFER, OnUpdateProgRefer)
	ON_UPDATE_COMMAND_UI(IDC_PROG_DEF, OnUpdateProgDef)
	ON_COMMAND(IDC_PROG_DEF, OnProgDef)
	ON_EN_CHANGE(IDC_PROG_EDIT, OnChangeName)
	ON_NOTIFY(TVN_KEYDOWN, IDC_PROG, OnKeyDownProg)
	ON_COMMAND(IDC_PROG_REDO, OnProgRedo)
	ON_COMMAND(IDC_PROG_UNDO, OnProgUndo)
	ON_COMMAND(IDC_REF_DEF, OnRefDef)
	ON_COMMAND(IDC_REF_NEXT, OnRefNext)
	ON_COMMAND(IDC_REF_PREV, OnRefPrev)
	ON_EN_CHANGE(IDC_PROG_FIND, OnChangeFind)
	ON_COMMAND(IDC_PROG_NEXT, OnFindNext)
	ON_COMMAND(IDC_PROG_PREV, OnFindPrev)
	ON_COMMAND(IDC_PROG_EDIT2, OnProgEdit)
	ON_EN_CHANGE(IDC_PROG_TEXT, OnChangeProgText)
	ON_EN_CHANGE(IDC_PROG_REAL, OnChangeProgReal)
	ON_BN_CLICKED(IDC_PROG_LOGIC, OnProgLogic)
	ON_UPDATE_COMMAND_UI(IDC_PROG_UNDO, OnUpdateProgUndo)
	ON_UPDATE_COMMAND_UI(IDC_PROG_REDO, OnUpdateProgRedo)
	ON_UPDATE_COMMAND_UI(IDC_EDITICON_XY, OnUpdateEditiconXy)
	ON_UPDATE_COMMAND_UI(IDC_EDITMAP_XY, OnUpdateEditmapXy)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG_OBJECT, OnBeginDragProgObj)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG_LOCAL, OnBeginDragProgLoc)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG_STRUC, OnBeginDragProgStr)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG_CLASS, OnBeginDragProgCls)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG, OnBeginDragProgEdi)
	ON_NOTIFY(TVN_BEGINLABELEDIT, IDC_PROG_LOCAL, OnBeginLabelEdit)
	ON_NOTIFY(TVN_BEGINLABELEDIT, IDC_PROG_CLASS, OnBeginLabelEdit)
	ON_NOTIFY(TVN_BEGINLABELEDIT, IDC_PROG, OnBeginLabelEdit)
	ON_NOTIFY(TVN_BEGINLABELEDIT, IDC_PROG_STRUC, OnBeginLabelEdit)
	ON_NOTIFY(TVN_ENDLABELEDIT, IDC_PROG_STRUC, OnEndLabelEdit)
	ON_NOTIFY(TVN_ENDLABELEDIT, IDC_PROG_LOCAL, OnEndLabelEdit)
	ON_NOTIFY(TVN_ENDLABELEDIT, IDC_PROG_CLASS, OnEndLabelEdit)
	ON_NOTIFY(TVN_ENDLABELEDIT, IDC_PROG, OnEndLabelEdit)
	ON_NOTIFY(TVN_KEYDOWN, IDC_PROG_CLASS, OnKeyDownProg)
	ON_NOTIFY(TVN_KEYDOWN, IDC_PROG_LOCAL, OnKeyDownProg)
	ON_NOTIFY(TVN_KEYDOWN, IDC_PROG_OBJECT, OnKeyDownProg)
	ON_NOTIFY(TVN_KEYDOWN, IDC_PROG_STRUC, OnKeyDownProg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// diagnostika

#ifdef _DEBUG
void CProg::AssertValid() const
{
	CFormView::AssertValid();
}

void CProg::Dump(CDumpContext& dc) const
{
	CFormView::Dump(dc);
}
#endif //_DEBUG


/////////////////////////////////////////////////////////////////////////////
// zm�na velikosti okna

void CProg::OnSize(UINT nType, int cx, int cy) 
{
	ValidateRect(NULL);
	CFormView::OnSize(nType, cx, cy);
	ReSize();
	Invalidate(FALSE);		// zneplatn�n� cel�ho okna
}

void CProg::ReSize()
{
	CRect rect;			// klientsk� oblast cel�ho okna
	CRect rect1;		// lev� vertik�ln� rozd�lova�
	CRect rect2;		// lev� horizont�ln� rozd�lova�
	CRect rect3;		// prav� horizont�ln� rozd�lova�
	CRect rect4;		// prav� vertik�ln� rozd�lova�
	CRect rectProg;		// pole editace a ikony
	CRect rectLocal;	// lok�ln� objekty, nadpis
	CRect rectObject;	// glob�ln� objekty, nadpis
	CRect rectClass;	// struktury, nadpis
	CRect rectInter;	// t��dy, nadpis

	GetClientRect(&rect);

// lev� vertik�ln� rozd�lova�
	rect1 = rect;
	rect1.left = (rect.right*LeftWidth+Scale/2)/Scale;
	if (rect1.left > rect.right - 2*SplitSize)
		rect1.left = rect.right - 2*SplitSize;
	if (rect1.left < 0) 
		rect1.left = 0;

	rect1.right = rect1.left + SplitSize;

	if (m_Split1.m_hWnd != NULL)
	{
		m_Split1.MoveWindow(&rect1,FALSE);
	}

// prav� vertik�ln� rozd�lova�
	rect4 = rect;
	rect4.left = rect.right - (rect.right*RightWidth+Scale/2)/Scale;
	if (rect4.left < rect1.right)
		rect4.left = rect1.right;
	if (rect4.left > rect.right - SplitSize) 
		rect4.left = rect.right - SplitSize;

	rect4.right = rect4.left + SplitSize;

	if (m_Split3.m_hWnd != NULL)
	{
		m_Split3.MoveWindow(&rect4,FALSE);
	}

// pole editace
	rectProg = rect;
	rectProg.top = 0;
	rectProg.left = rect1.right;
	rectProg.right = rect4.left;
	
	if (m_Edit.m_hWnd != NULL)
	{
		m_Edit.MoveWindow(&rectProg,FALSE);
	}

//	rectProg.bottom = rectProg.top + 30;
	if (m_ProgReal.m_hWnd != NULL)
	{
		m_ProgReal.MoveWindow(&rectProg,FALSE);
	}

	if (m_ProgText.m_hWnd != NULL)
	{
		m_ProgText.MoveWindow(&rectProg,FALSE);
	}

	if (m_ProgPic.m_hWnd != NULL)
	{
		m_ProgPic.MoveWindow(&rectProg,FALSE);
//		m_ProgPic.Invalidate(FALSE);
	}

	if (m_ProgMap.m_hWnd != NULL)
	{
		m_ProgMap.MoveWindow(&rectProg,FALSE);
//		m_ProgPic.Invalidate(FALSE);
	}

	if (m_ProgSound.m_hWnd != NULL)
	{
		m_ProgSound.MoveWindow(&rectProg,FALSE);
	}

	if (m_ProgMusic.m_hWnd != NULL)
	{
		m_ProgMusic.MoveWindow(&rectProg,FALSE);
	}

	if (m_ProgLogic.m_hWnd != NULL)
	{
		m_ProgLogic.MoveWindow(&rectProg,FALSE);
	}

	if (m_ProgDialog.m_hWnd != NULL)
	{
		m_ProgDialog.MoveWindow(&rectProg,FALSE);
	}

	if (m_ProgSprite.m_hWnd != NULL)
	{
		m_ProgSprite.MoveWindow(&rectProg,FALSE);
	}


// lev� horizont�ln� rozd�lova�
	rect2.left = 0;
	rect2.right = rect1.left;
	rect2.top = (rect.bottom*LeftHeight+Scale/2)/Scale;
	if (rect2.top > rect.bottom - SplitSize)
		rect2.top = rect.bottom - SplitSize;
	rect2.bottom = rect2.top + SplitSize;

	if (m_Split2.m_hWnd != NULL)
	{
		m_Split2.MoveWindow(&rect2,FALSE);
	}

// pole objekt�
	rectObject.left = 0;
	rectObject.top = 15;
	rectObject.right = rect2.right;
	rectObject.bottom = rect2.top;
	if (m_Object.m_hWnd != NULL)
	{
		m_Object.MoveWindow(&rectObject,FALSE);
	}

	rectObject.bottom = rectObject.top;
	rectObject.top = 0;
	if (m_Nadpis1.m_hWnd != NULL)
	{
		m_Nadpis1.MoveWindow(&rectObject,FALSE);
	}

// pole lok�ln�ch objekt�
	rectLocal = rect;
	rectLocal.right = rect2.right;
	rectLocal.top = rect2.bottom + 15;

	if (m_Local.m_hWnd != NULL)
	{
		m_Local.MoveWindow(&rectLocal,FALSE);
	}

	rectLocal.bottom = rectLocal.top;
	rectLocal.top = rect2.bottom;
	if (m_Nadpis2.m_hWnd != NULL)
	{
		m_Nadpis2.MoveWindow(&rectLocal,FALSE);
	}

// prav� horizont�ln� rozd�lova�
	rect3 = rect;
	rect3.left = rect4.right;
	rect3.top =	(rect.bottom*RightHeight+Scale/2)/Scale;
	if (rect3.top > rect.bottom - SplitSize)
		rect3.top = rect.bottom - SplitSize;
	rect3.bottom = rect3.top + SplitSize;

	if (m_Split4.m_hWnd != NULL)
	{
		m_Split4.MoveWindow(&rect3,FALSE);
	}

// pole struktur
	rectInter = rect;
	rectInter.bottom = rect3.top;
	rectInter.left = rect3.left;
	rectInter.top = 15;
	if (m_Struc.m_hWnd != NULL)
	{
		m_Struc.MoveWindow(&rectInter,FALSE);
	}

	rectInter.bottom = rectInter.top;
	rectInter.top = 0;
	if (m_Nadpis3.m_hWnd != NULL)
	{
		m_Nadpis3.MoveWindow(&rectInter,FALSE);
	}

// pole t��d
	rectClass = rect;
	rectClass.left = rect3.left;
	rectClass.top = rect3.bottom + 15;

	if (m_Class.m_hWnd != NULL)
	{
		m_Class.MoveWindow(&rectClass,FALSE);
	}

	rectClass.bottom = rectClass.top;
	rectClass.top = rect3.bottom;
	if (m_Nadpis4.m_hWnd != NULL)
	{
		m_Nadpis4.MoveWindow(&rectClass,FALSE);
	}

// oprava Z po�ad� oken
	if (m_Nadpis1.m_hWnd != NULL && m_Nadpis2.m_hWnd != NULL && m_Split2.m_hWnd != NULL)
	{
		m_Nadpis2.SetWindowPos(&m_Nadpis1,0,0,0,0,
			SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOREDRAW | SWP_NOSIZE);
		m_Split2.SetWindowPos(&m_Nadpis2,0,0,0,0,
			SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOREDRAW | SWP_NOSIZE);
	}

	if (m_Nadpis3.m_hWnd != NULL && m_Nadpis4.m_hWnd != NULL && m_Split4.m_hWnd != NULL)
	{
		m_Nadpis4.SetWindowPos(&m_Nadpis3,0,0,0,0,
			SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOREDRAW | SWP_NOSIZE);
		m_Split4.SetWindowPos(&m_Nadpis4,0,0,0,0,
			SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOREDRAW | SWP_NOSIZE);
	}
}

/////////////////////////////////////////////////////////////////////////////
// aktualizace palet p�i p�ekreslen� okna

void CProg::OnDraw(CDC* pDC) 
{
	HPALETTE OldPal = ::SelectPalette(pDC->m_hDC, StdPalette, FALSE);
	::RealizePalette(pDC->m_hDC);
	::SelectPalette(pDC->m_hDC,OldPal,TRUE);
}

/////////////////////////////////////////////////////////////////////////////
// zaznamen�n� zm�ny v rozvinut� struktury stromu

void CProg::OnItemExpandedProgObj(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufObjID);
}

void CProg::OnItemExpandedProgLoc(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufLocID);
}

void CProg::OnItemExpandedProgStr(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufStrID);
}

void CProg::OnItemExpandedProgCls(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufClsID);
}

void CProg::OnItemExpandedProgEdi(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufEdiID);
}

void CProg::OnItemExpandedProg(NMHDR* pNMHDR, LRESULT* pResult, int buff) 
{
	NM_TREEVIEW* pnm = (NM_TREEVIEW*)pNMHDR;
	int index;

	if ((pnm->itemNew.mask & TVIF_STATE) != 0)
	{	
		index = m_Buf[buff].SrcItem(pnm->itemNew.hItem);
		if (index != -1)
		{
			if ((pnm->itemNew.state & TVIS_EXPANDED) != 0)
				m_Buf[buff].m_Items[index].param |= PR_EXP;
			else
				m_Buf[buff].m_Items[index].param &= ~PR_EXP;
		}
	}
	*pResult = 0;
}

/////////////////////////////////////////////////////////////////////////////
// zm�na aktivn� polo�ky nebo zm�na okna

void CProg::OnSelChangedObject(NMHDR* pNMHDR, LRESULT* pResult) 
{
	DispName();
	RefSelChange(BufObjID, BufClsID);
	RefSelChange(BufObjID, BufStrID);
	*pResult = 0;
}

void CProg::OnSelChangedLocal(NMHDR* pNMHDR, LRESULT* pResult) 
{
	DispName();
	RefSelChange(BufLocID, BufClsID);
	RefSelChange(BufLocID, BufStrID);
	*pResult = 0;
}

void CProg::OnSelChangedStruc(NMHDR* pNMHDR, LRESULT* pResult) 
{
	DispName();
	*pResult = 0;
}

void CProg::OnSelChangedClass(NMHDR* pNMHDR, LRESULT* pResult) 
{
	DispName();
	RefSelChange(BufClsID, BufStrID);
	*pResult = 0;
}

void CProg::OnSelChangedEdit(NMHDR* pNMHDR, LRESULT* pResult) 
{
	DispName();
	RefSelChange(BufEdiID, BufObjID);
	RefSelChange(BufEdiID, BufLocID);
	RefSelChange(BufEdiID, BufStrID);
	*pResult = 0;
}


void CProg::RefSelChange(int AktBuf, int RefBuf)
{
// lok�ln� prom�nn�
	CProgBuf* buf = &(m_Buf[AktBuf]);				// adresa aktivn�ho bufferu
	PROGITEM* item;									// adresa aktivn� polo�ky

// nalezen� aktivn� polo�ky
	short itemN = m_Buf[AktBuf].GetAkt();			// nalezen� aktivn� polo�ky

// je n�jak� polo�ka aktivn� ?
	if (itemN != -1)								// je vybran� polo�ka ?
	{
		item = &(buf->m_Items[itemN]);				// adresa aktivn� polo�ky

// je odkaz na referen�n� buffer ?
		if ((item->typ == RefBuf) && (item->refer != -1)) // je odkaz na buffer ?

// je platn� odkaz - nastaven� aktivn� polo�ky
			m_Buf[RefBuf].SetAkt(item->refer);		// nastaven� aktivn� polo�ky

// jinak vypnut� kurzoru
		else
			if (RefBuf != BufStrID)
				m_Buf[RefBuf].SetAkt(-1);			// vypnut� kurzoru
	}
}


void CProg::OnSetFocusObject(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufObjID;
//	m_AktTree = &m_Object;
	DispName();
}

void CProg::OnSetFocusLocal(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufLocID;
//	m_AktTree = &m_Local;
	DispName();
}


void CProg::OnSetFocusStruc(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufStrID;
//	m_AktTree = &m_Struc;
	DispName();
}

void CProg::OnSetFocusClass(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufClsID;
//	m_AktTree = &m_Class;
	DispName();
}

void CProg::OnSetFocusProg(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufEdiID;
//	m_AktTree = &m_Edit;
	DispName();
}

BOOL CProg::PreTranslateMessage(MSG* pMsg) 
{
	if (pMsg->message == WM_KEYDOWN)
	{
		if (pMsg->wParam == VK_RETURN)
		{
			CWnd* wnd = GetFocus();
			if (wnd != NULL)
			{
				if (m_Editing)
				{
					::SendMessage(m_Buf[m_AktBufID].m_Tree->m_hWnd, TVM_ENDEDITLABELNOW, FALSE, 0);
					return TRUE;
				}
				else
				{
					if (wnd->m_hWnd == m_Object.m_hWnd)
					{
							DblclkObject(m_BufObj.SrcItem(m_Object.GetSelectedItem()));
							return TRUE;
					}

					if (wnd->m_hWnd == m_Local.m_hWnd)
					{
						DblclkLocal(m_BufLoc.SrcItem(m_Local.GetSelectedItem()));
						return TRUE;
					}
				}
			}
		}

		if (m_Editing)
			if ((pMsg->wParam == VK_UP) || 
				(pMsg->wParam == VK_DOWN) || 
				(pMsg->wParam == VK_PRIOR) || 
				(pMsg->wParam == VK_NEXT) ||
				(pMsg->wParam == VK_ESCAPE))
			{
				CWnd* wnd = GetFocus();
				if (wnd != NULL)
				{
					::SendMessage(m_Buf[m_AktBufID].m_Tree->m_hWnd, TVM_ENDEDITLABELNOW, FALSE, 0);
					if (pMsg->wParam != VK_ESCAPE)
					{
						::SendMessage(m_Buf[m_AktBufID].m_Tree->m_hWnd, WM_KEYDOWN, pMsg->wParam, pMsg->lParam);
						::PostMessage(m_Buf[m_AktBufID].m_Tree->m_hWnd, TVM_EDITLABEL, 0, (LPARAM)m_Buf[m_AktBufID].m_Tree->GetSelectedItem());
					}
					return TRUE;
				}
			}
	}
	
	return CFormView::PreTranslateMessage(pMsg);
}

/////////////////////////////////////////////////////////////////////////////
// dvojklik my��

void CProg::OnDblclkProgObject(NMHDR* pNMHDR, LRESULT* pResult) 
{
	UINT		nFlags;
	HTREEITEM	hItem;
	int 		item;
	CPoint		pt;
	
	::GetCursorPos(&pt);
	m_Object.ScreenToClient(&pt);
	hItem = m_Object.HitTest(pt, &nFlags);
	item = m_BufObj.SrcItem(hItem); 

	DblclkObject(item);

//	m_AktBufID = BufEdiID;

	*pResult = 0;
}


void CProg::DblclkObject(int item)
{
	int 		i;
	int item2 = item;

	if ((item < 0) || (item >= m_BufObj.m_Num))
		return;
	m_Object.SelectItem(m_BufObj.m_Items[item].htree);
	CProgBuf* buf = &(m_BufLoc);
	i = m_BufObj.m_Items[item].index;
	buf->SetFirst(i);
	item = i;
	buf = &(m_BufEdi);
	if ((item >= 0) && (item < m_BufLoc.m_Num))
	{
		i = m_BufLoc.m_Items[item].index;
		buf->SetFirst(i);
	}

	m_EditItem = m_BufObj.m_Items[item2].index;
	SetEditMode(m_BufObj.m_Items[item2].model);

	AktAllDef();								// aktualizace defini�n�ch ukazatel�
}

void CProg::OnDblclkProgLocal(NMHDR* pNMHDR, LRESULT* pResult) 
{
	UINT		nFlags;
	HTREEITEM	hItem;
	int 		item;
	CPoint		pt;
	
	::GetCursorPos(&pt);
	m_Local.ScreenToClient(&pt);
	hItem = m_Local.HitTest(pt, &nFlags);
	item = m_BufLoc.SrcItem(hItem); 

	DblclkLocal(item);
	
//	m_AktBufID = BufEdiID;

	*pResult = 0;
}

void CProg::DblclkLocal(int item)
{
	int 		i;
	if ((item < 0) || (item >= m_BufLoc.m_Num))
		return;
	m_Local.SelectItem(m_BufLoc.m_Items[item].htree);
	CProgBuf*	buf = &(m_BufEdi);
	i = m_BufLoc.m_Items[item].index;
	buf->SetFirst(i);
	m_EditItem = item;

	m_EditItem = m_BufLoc.m_Items[item].index;
	SetEditMode(m_BufLoc.m_Items[item].model);

	AktAllDef();								// aktualizace defini�n�ch ukazatel�
}


void CProg::SetEditMode(short model)
{
	CString txt;

	m_FilDat = TRUE;							// p��znak pln�n� dat

	switch (model)
	{
	case TYP_FUNC:
		m_EditBufN = BufEdiID;
		m_Edit.ShowWindow(SW_SHOW);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	case TYP_REAL:
		m_EditBufN = BufNumID;
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_SHOW);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		txt.Format(_T("%.12lG"),m_Real.Get(m_EditItem));
		m_ProgReal.SetWindowText(txt);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	case TYP_BOOL:
		m_EditBufN = BufLogID;
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_SHOW);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		m_ProgLogic.SetCheck(m_Bool.Get(m_EditItem) ? 1 : 0);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	case TYP_TEXT:
		m_EditBufN = BufTxtID;
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_SHOW);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		m_ProgText.SetWindowText(m_Text.Get(m_EditItem));
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	case TYP_PIC:
		m_EditBufN = BufPicID;
		m_ProgPic.BegEdit(m_EditItem);
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_SHOW);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),TRUE,TRUE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_SHOW);
		break;
	case TYP_SND:
		m_EditBufN = BufEdiID;
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_SHOW);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	case TYP_MUS:
		m_EditBufN = BufEdiID;
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_SHOW);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	case TYP_MAP:
		m_EditBufN = BufMapID;
		m_ProgMap.BegEdit(m_EditItem);
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_SHOW);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),TRUE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	case TYP_DIALOG:
		m_EditBufN = BufEdiID;
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_SHOW);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	case TYP_SPRITE:
		m_EditBufN = BufEdiID;
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_SHOW);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
		break;
	default:
		m_EditBufN = BufEdiID;
		m_Edit.ShowWindow(SW_HIDE);
		m_ProgPic.ShowWindow(SW_HIDE);
		m_ProgReal.ShowWindow(SW_HIDE);
		m_ProgLogic.ShowWindow(SW_HIDE);
		m_ProgText.ShowWindow(SW_HIDE);
		m_ProgSound.ShowWindow(SW_HIDE);
		m_ProgMusic.ShowWindow(SW_HIDE);
		m_ProgMap.ShowWindow(SW_HIDE);
		m_ProgDialog.ShowWindow(SW_HIDE);
		m_ProgSprite.ShowWindow(SW_HIDE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndIconBar),FALSE,TRUE);
		MainFrame->ShowControlBar(&(MainFrame->m_wndMapBar),FALSE,TRUE);
//		MainFrame->m_wndIconBar.ShowWindow(SW_HIDE);
	}
	MainFrame->RecalcLayout();

	m_FilDat = FALSE;							// konec pln�n� dat
}



void CProg::OnChangeProgText() 
{
	if (m_FilDat) return;			// je pln�n� dat

	CString txt;

	m_ProgText.GetWindowText(txt);
	if ((m_EditItem >= 0) && (m_EditBufN == BufTxtID))
		m_Text.Set(m_EditItem, txt);
}

void CProg::OnChangeProgReal() 
{
	if (m_FilDat) return;			// je pln�n� dat

	CString txt;
	double num;
	int pocet;

	m_ProgReal.GetWindowText(txt);
	if ((m_EditItem >= 0) && (m_EditBufN == BufNumID))
	{
#ifdef _UNICODE
		pocet = swscanf(txt,_T("%lG"),&num);
#else
		pocet = sscanf(txt,_T("%lG"),&num);
#endif
		if (pocet)
			m_Real.Set(m_EditItem, num);
	}
}

void CProg::OnProgLogic() 
{
	if (m_FilDat) return;			// je pln�n� dat
	
	if ((m_EditItem >= 0) && (m_EditBufN == BufLogID))
	{
		m_Bool.Set(m_EditItem, m_ProgLogic.GetCheck());
	}
}

void CProg::OnProgRedo() 
{
	if (m_EditBufN == BufPicID)
//		(m_AktBufID == BufEdiID))
	{
		m_ProgPic.Redo();
	}
}

void CProg::OnProgUndo() 
{
	if (m_EditBufN == BufPicID)
//		(m_AktBufID == BufEdiID))
	{
		m_ProgPic.Undo();
	}
}


void CProg::OnUpdateProgUndo(CCmdUI* pCmdUI) 
{
	if (((m_ProgPic.m_UndoItem != m_ProgPic.m_Item) &&
		(m_ProgPic.m_UndoItem != -1)) ||
		(m_ProgPic.m_UndoAkt > 0))
		pCmdUI->Enable(TRUE);
	else
		pCmdUI->Enable(FALSE);	
}


void CProg::OnUpdateProgRedo(CCmdUI* pCmdUI) 
{
	if (m_ProgPic.m_UndoAkt < m_ProgPic.m_UndoNum-1)
		pCmdUI->Enable(TRUE);
	else
		pCmdUI->Enable(FALSE);	
}


void CProg::OnUpdateEditiconXy(CCmdUI* pCmdUI) 
{
// lok�ln� prom�nn�
	int x,y;					// aktu�ln� sou�adnice
	TCHAR buff[50];				// buffer k dek�dov�n� textu ��sla
	CStatic* txt;				// prvek zobrazen�ho textu

// p��prava aktu�ln�ch sou�adnic
	x = m_ProgPic.m_X;			// aktu�ln� sou�adnice X
	y = m_ProgPic.m_Y;			// aktu�ln� sou�adnice Y
	if ((x < 0) || 
		(x >= m_ProgPic.m_Width) ||
		(y < 0) ||
		(y >= m_ProgPic.m_Height))
	{
		x = -1;
		y = -1;
	}

// kontrola, zda se �daje zm�nily
	if ((x == m_OldEditX) &&
		(y == m_OldEditY))
		return;

// �schova nov�ch sou�adnic
	m_OldEditX = x;
	m_OldEditY = y;

	y = m_ProgPic.m_Height - 1 - y;

// p��prava textu
	if (x == -1)
		buff[0] = 0;
	else
		wsprintf(buff, _T("%d,%d"), x, y);

// nalezen� handle prvku
	txt = (CStatic*)(MainFrame->		// nalezen� okna textu
			m_wndIconBar.GetDlgItem(IDC_EDITICON_XY));

// nastaven� textu
	if (txt != NULL)					// bylo okno nalezeno ?
	{
		txt->SetWindowText(buff);		// nastaven� textu po�tu referenc�
	}
}


void CProg::OnUpdateEditmapXy(CCmdUI* pCmdUI) 
{
// lok�ln� prom�nn�
	int x,y;					// aktu�ln� sou�adnice
	TCHAR buff[50];				// buffer k dek�dov�n� textu ��sla
	CStatic* txt;				// prvek zobrazen�ho textu

// p��prava aktu�ln�ch sou�adnic
	x = m_ProgMap.m_X;			// aktu�ln� sou�adnice X
	y = m_ProgMap.m_Y;			// aktu�ln� sou�adnice Y

// kontrola, zda se �daje zm�nily
	if ((x == m_OldEditMapX) &&
		(y == m_OldEditMapY))
		return;

// �schova nov�ch sou�adnic
	m_OldEditMapX = x;
	m_OldEditMapY = y;

// p��prava textu
	if (x == -1)
		buff[0] = 0;
	else
		wsprintf(buff, _T("%d,%d"), x, y);

// nalezen� handle prvku
	txt = (CStatic*)(MainFrame->		// nalezen� okna textu
			m_wndMapBar.GetDlgItem(IDC_EDITMAP_XY));

// nastaven� textu
	if (txt != NULL)					// bylo okno nalezeno ?
	{
		txt->SetWindowText(buff);		// nastaven� textu po�tu referenc�
	}
}

