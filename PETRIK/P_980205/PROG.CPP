
#include "stdafx.h"
#include "peter.h"
#include "Prog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CProg

IMPLEMENT_DYNCREATE(CProg, CFormView)

CProg::CProg()
	: CFormView(CProg::IDD)
{
	//{{AFX_DATA_INIT(CProg)
	//}}AFX_DATA_INIT

//	m_dwDefaultStyle |= TVS_HASLINES | TVS_LINESATROOT | TVS_HASBUTTONS | TVS_SHOWSELALWAYS;

	m_ImageList = new CImageList();
	m_ImageList->Create(16, 16, TRUE, 1, 10);
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDR_MAINFRAME));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_IF));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_IF_COND));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_IF_YES));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_IF_NO));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_WHILE));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_WHILE_COND));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_WHILE_BODY));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_WHILE_BREAK));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_BLOK));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_CASE));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_CASE_SUM));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_CASE_ON));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_CASE_EQU));
	m_ImageList->Add(AfxGetApp()->LoadIcon(IDI_CASE_DEF));

	m_ImageProg = new CImageList();
	m_ImageProg->Create(32, 32, TRUE, 1, 10);
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDR_MAINFRAME));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_IF));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_IF_COND));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_IF_YES));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_IF_NO));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_WHILE));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_WHILE_COND));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_WHILE_BODY));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_WHILE_BREAK));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_BLOK));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_CASE));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_CASE_SUM));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_CASE_ON));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_CASE_EQU));
	m_ImageProg->Add(AfxGetApp()->LoadIcon(IDI_CASE_DEF));

}

CProg::~CProg()
{
	m_ImageList->DeleteImageList();
	delete m_ImageList;

	m_ImageProg->DeleteImageList();
	delete m_ImageProg;
}

void CProg::DoDataExchange(CDataExchange* pDX)
{
	CFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CProg)
	DDX_Control(pDX, IDC_PROG_SPLIT, m_Split);
	DDX_Control(pDX, IDC_PROG_SELECT, m_Select);
	DDX_Control(pDX, IDC_PROG, m_Prog);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CProg, CFormView)
	//{{AFX_MSG_MAP(CProg)
	ON_WM_SIZE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CProg drawing

//void CProg::OnDraw(CDC* pDC)
//{
//	CDocument* pDoc = GetDocument();
//}

/////////////////////////////////////////////////////////////////////////////
// CProg diagnostics

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

void CProg::OnInitialUpdate() 
{
	CFormView::OnInitialUpdate();

	m_Select.SetImageList(m_ImageList, TVSIL_NORMAL);

	TV_INSERTSTRUCT tvs;

	tvs.hParent = NULL;
	tvs.hInsertAfter = TVI_LAST;
	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
	tvs.item.pszText = "Petøík";
	tvs.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_CHILDREN;
	tvs.item.cChildren = 3;

	HTREEITEM h0 = m_Select.InsertItem(&tvs);

	tvs.item.cChildren = 3;
	tvs.hParent = h0;
	tvs.item.iImage = 1;
	tvs.item.iSelectedImage = 1;
	tvs.item.pszText = "Podmínka";
	HTREEITEM h1 = m_Select.InsertItem(&tvs);
	
	tvs.item.cChildren = 3;
	tvs.item.iImage = 9;
	tvs.item.iSelectedImage = 9;
	tvs.item.pszText = "Blok pøíkazù";
	HTREEITEM h2 = m_Select.InsertItem(&tvs);

	tvs.hParent = h2;
	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Nìjaký pøíkaz";
	m_Select.InsertItem(&tvs);
	m_Select.InsertItem(&tvs);
	m_Select.InsertItem(&tvs);
	

	tvs.hParent = h0;
	tvs.item.iImage = 10;
	tvs.item.iSelectedImage = 10;
	tvs.item.cChildren = 3;
	tvs.item.pszText = "Rozvìtvení";
	h0 = m_Select.InsertItem(&tvs);

	tvs.hParent = h0;
	tvs.item.iImage = 11;
	tvs.item.iSelectedImage = 11;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Porovnávaný výraz";
	m_Select.InsertItem(&tvs);

	tvs.item.iImage = 12;
	tvs.item.iSelectedImage = 12;
	tvs.item.cChildren = 2;
	tvs.item.pszText = "Vìtev";
	h2 = m_Select.InsertItem(&tvs);

	tvs.item.iImage = 14;
	tvs.item.iSelectedImage = 14;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Implicitní obsluha";
	m_Select.InsertItem(&tvs);


	tvs.hParent = h2;
	tvs.item.iImage = 13;
	tvs.item.iSelectedImage = 13;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Porovnávaná hodnota";
	m_Select.InsertItem(&tvs);

	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
	tvs.item.pszText = "Pøíkaz";
	m_Select.InsertItem(&tvs);


//	tvs.hInsertAfter = TVI_SORT;
	tvs.item.iImage = 2;
	tvs.item.iSelectedImage = 2;
	tvs.item.pszText = "Platí ?";
	tvs.hParent = h1;
	m_Select.InsertItem(&tvs);

	tvs.item.pszText = "Splnìno";
	tvs.item.iImage = 3;
	tvs.item.iSelectedImage = 3;
	m_Select.InsertItem(&tvs);

	tvs.item.iImage = 4;
	tvs.item.iSelectedImage = 4;
	tvs.item.pszText = "Nesplnìno";
	tvs.item.cChildren = 2;
	HTREEITEM h12 = m_Select.InsertItem(&tvs);

	tvs.item.iImage = 5;
	tvs.item.iSelectedImage = 5;
	tvs.item.pszText = "Smyèka";
	tvs.item.cChildren = 2;
	tvs.hParent = h12;
	HTREEITEM h122 = m_Select.InsertItem(&tvs);

	tvs.item.iImage = 6;
	tvs.item.iSelectedImage = 6;
	tvs.item.pszText = "Platí ?";
	tvs.item.cChildren = 0;
	tvs.hParent = h122;
	m_Select.InsertItem(&tvs);

	tvs.item.iImage = 7;
	tvs.item.iSelectedImage = 7;
	tvs.item.pszText = "Tìlo smyèky";
	tvs.item.cChildren = 5;
	HTREEITEM h1222 = m_Select.InsertItem(&tvs);

	tvs.hParent = h1222;
	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Nìjaký pøíkaz";
	m_Select.InsertItem(&tvs);
	m_Select.InsertItem(&tvs);
	m_Select.InsertItem(&tvs);
	m_Select.InsertItem(&tvs);
	tvs.item.pszText = "Pøerušení cyklu";
	tvs.item.iImage = 8;
	tvs.item.iSelectedImage = 8;
	m_Select.InsertItem(&tvs);

//	tvs.hParent = h122;
	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
//	tvs.item.pszText = "Ještì nìjaký pøíkaz";
//	m_Select.InsertItem(&tvs);

	tvs.hParent = h12;
	tvs.item.pszText = "Konec scény";
	m_Select.InsertItem(&tvs);




	m_Prog.SetImageList(m_ImageProg, TVSIL_NORMAL);

	h0 = NULL;

for (int i=0; i<10; i++)
{

	tvs.hParent = h0;
	tvs.hInsertAfter = TVI_LAST;
	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
	tvs.item.pszText = "Petøík";
	tvs.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_CHILDREN;
	tvs.item.cChildren = 3;

	h0 = m_Prog.InsertItem(&tvs);

	tvs.item.cChildren = 3;
	tvs.hParent = h0;
	tvs.item.iImage = 1;
	tvs.item.iSelectedImage = 1;
	tvs.item.pszText = "Podmínka";
	h1 = m_Prog.InsertItem(&tvs);
	
	tvs.item.cChildren = 3;
	tvs.item.iImage = 9;
	tvs.item.iSelectedImage = 9;
	tvs.item.pszText = "Blok pøíkazù";
	h2 = m_Prog.InsertItem(&tvs);
	
	tvs.hParent = h2;
	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Nìjaký pøíkaz";
	m_Prog.InsertItem(&tvs);
	m_Prog.InsertItem(&tvs);
	m_Prog.InsertItem(&tvs);


	tvs.hParent = h0;
	tvs.item.cChildren = 3;
	tvs.item.iImage = 10;
	tvs.item.iSelectedImage = 10;
	tvs.item.pszText = "Rozvìtvení";
	h0 = m_Prog.InsertItem(&tvs);

	tvs.hParent = h0;
	tvs.item.iImage = 11;
	tvs.item.iSelectedImage = 11;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Porovnávaný výraz";
	m_Prog.InsertItem(&tvs);

	tvs.item.iImage = 12;
	tvs.item.iSelectedImage = 12;
	tvs.item.cChildren = 2;
	tvs.item.pszText = "Vìtev";
	h2 = m_Prog.InsertItem(&tvs);

	tvs.item.iImage = 14;
	tvs.item.iSelectedImage = 14;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Implicitní obsluha";
	m_Prog.InsertItem(&tvs);


	tvs.hParent = h2;
	tvs.item.iImage = 13;
	tvs.item.iSelectedImage = 13;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Porovnávaná hodnota";
	m_Prog.InsertItem(&tvs);

	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
	tvs.item.pszText = "Pøíkaz";
	m_Prog.InsertItem(&tvs);


//	tvs.hInsertAfter = TVI_SORT;
	tvs.item.iImage = 2;
	tvs.item.iSelectedImage = 2;
	tvs.item.pszText = "Platí ?";
	tvs.hParent = h1;
	m_Prog.InsertItem(&tvs);

	tvs.item.iImage = 3;
	tvs.item.iSelectedImage = 3;
	tvs.item.pszText = "Splnìno";
	m_Prog.InsertItem(&tvs);

	tvs.item.iImage = 4;
	tvs.item.iSelectedImage = 4;
	tvs.item.pszText = "Nesplnìno";
	tvs.item.cChildren = 2;
	h12 = m_Prog.InsertItem(&tvs);

	tvs.item.iImage = 5;
	tvs.item.iSelectedImage = 5;
	tvs.item.pszText = "Smyèka";
	tvs.item.cChildren = 2;
	tvs.hParent = h12;
	h122 = m_Prog.InsertItem(&tvs);

	tvs.item.iImage = 6;
	tvs.item.iSelectedImage = 6;
	tvs.item.pszText = "Platí ?";
	tvs.item.cChildren = 0;
	tvs.hParent = h122;
	m_Prog.InsertItem(&tvs);

	tvs.item.iImage = 7;
	tvs.item.iSelectedImage = 7;
	tvs.item.pszText = "Tìlo smyèky";
	tvs.item.cChildren = 5;
	h1222 = m_Prog.InsertItem(&tvs);

	tvs.hParent = h1222;
	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
	tvs.item.cChildren = 0;
	tvs.item.pszText = "Nìjaký pøíkaz";
	m_Prog.InsertItem(&tvs);
	m_Prog.InsertItem(&tvs);
	m_Prog.InsertItem(&tvs);
	m_Prog.InsertItem(&tvs);
	tvs.item.pszText = "Pøerušení cyklu";
	tvs.item.iImage = 8;
	tvs.item.iSelectedImage = 8;
	m_Prog.InsertItem(&tvs);

//	tvs.hParent = h122;
	tvs.item.iImage = 0;
	tvs.item.iSelectedImage = 0;
//	tvs.item.pszText = "Ještì nìjaký pøíkaz";
//	m_Prog.InsertItem(&tvs);

	tvs.hParent = h12;
	tvs.item.cChildren = 3;
	tvs.item.pszText = "Konec scény";
	h0 = m_Prog.InsertItem(&tvs);
}

}

void CProg::OnSize(UINT nType, int cx, int cy) 
{
	CFormView::OnSize(nType, cx, cy);
	
	CRect rect, rect2;
	GetClientRect(&rect);

	rect2 = rect;
	rect2.left = SelectWidth;
	if (rect2.left > rect.right / 2)
		rect2.left = rect.right / 2;

	rect2.right = rect2.left + 6;

	if (m_Split.m_hWnd != NULL)
	{
		m_Split.MoveWindow(&rect2);
	}

	rect.left = rect2.right;
	
	if (m_Prog.m_hWnd != NULL)
	{
		m_Prog.MoveWindow(&rect);
	}

	rect.left = 0;
	rect.right = rect2.left;

	if (m_Select.m_hWnd != NULL)
	{
		m_Select.MoveWindow(&rect);
	}

}
