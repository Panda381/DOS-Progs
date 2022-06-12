
#include "stdafx.h"
#include "peter.h"
#include "Select.h"
#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CSelect

IMPLEMENT_DYNCREATE(CSelect, CFormView)

CSelect::CSelect()
	: CFormView(CSelect::IDD)
{
	//{{AFX_DATA_INIT(CSelect)
	//}}AFX_DATA_INIT
	m_ImageList = new CImageList();
	m_ImageList->Create(32, 32, TRUE, 1, 10);
}

CSelect::~CSelect()
{
	m_ImageList->DeleteImageList();
	delete m_ImageList;
}

void CSelect::DoDataExchange(CDataExchange* pDX)
{
	CFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CSelect)
	DDX_Control(pDX, IDC_SELECT, m_Select);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CSelect, CFormView)
	//{{AFX_MSG_MAP(CSelect)
	ON_WM_SIZE()
	ON_UPDATE_COMMAND_UI(ID_START, OnUpdateStart)
	ON_UPDATE_COMMAND_UI(ID_FILE_OPEN2, OnUpdateFileOpen)
	ON_NOTIFY(LVN_ITEMCHANGED, IDC_SELECT, OnItemchangedSelectlist)
	ON_NOTIFY(NM_DBLCLK, IDC_SELECT, OnDblclkSelectlist)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CSelect diagnostics

#ifdef _DEBUG
void CSelect::AssertValid() const
{
	CFormView::AssertValid();
}

void CSelect::Dump(CDumpContext& dc) const
{
	CFormView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CSelect message handlers

void CSelect::OnSize(UINT nType, int cx, int cy) 
{
	CFormView::OnSize(nType, cx, cy);
	
	CRect rect;
	GetClientRect(&rect);
	if (m_Select.m_hWnd != NULL)
	{
		m_Select.MoveWindow(&rect);
		m_Select.Arrange(LVA_ALIGNTOP);
	}

}


void CSelect::OnInitialUpdate() 
{
	CFormView::OnInitialUpdate();
	
// vyprázdnìní seznamu souborù
	m_Select.DeleteAllItems();

// vyprázdnìní seznamu obrázkù
	if (m_ImageList->GetImageCount() > 0)
	{
		m_ImageList->DeleteImageList();
		m_ImageList->Create(32, 32, TRUE, 1, 10);
	}

// nastavení seznamu obrázkù pro seznam
	m_Select.SetImageList(m_ImageList, LVSIL_NORMAL);		

// promìnné pro naètení seznamu
	WIN32_FIND_DATA wfd;
	HANDLE handle;
	CString jmeno;
	int poz;
	int i;
	HICON icon;
	BOOL code = TRUE;

// naètení seznamu souborù
	handle = ::FindFirstFile(_T(".\\*.pet"),&wfd);
	if (handle != INVALID_HANDLE_VALUE)
	{
		for (i = 0; code; i++)
		{
			jmeno = wfd.cFileName;
			icon = ::ExtractIcon(AfxGetApp()->m_hInstance, jmeno, 0);

			if ((int)icon <= 1)
			{
				icon = ::LoadIcon(AfxGetApp()->m_hInstance, MAKEINTRESOURCE(IDR_PETERTYPE));
			}

			if ((int)icon > 1)
			{
				m_ImageList->Add(icon);

				poz = jmeno.Find(_T("."));
				if (poz >= 0)
					m_Select.InsertItem(i,jmeno.Left(poz),i);
				else
					m_Select.InsertItem(i,jmeno,i);
			}
			code = ::FindNextFile(handle, &wfd);
		}
		::FindClose(handle);
	}

// nalezení jména programu v seznamu
	LV_FINDINFO find;
	if (Jmeno != "")
	{
		find.flags = LVFI_STRING;
		find.psz = Jmeno;
		i = m_Select.FindItem(&find);
		if (i >= 0)
			m_Select.SetItemState(i,LVIS_FOCUSED | LVIS_SELECTED,
			LVIS_FOCUSED | LVIS_SELECTED);
	}

// aktualizace zobrazeného jména v záhlaví okna
	CDocument* doc = GetDocument();
	if (doc != NULL)
	{
		if (Jmeno == _T(""))
			doc->SetTitle(_T("...."));
		else
			doc->SetTitle(Jmeno);
	}
}


void CSelect::OnUpdateStart(CCmdUI* pCmdUI) 
{
	if (Jmeno == "")
		pCmdUI->Enable(FALSE);
	else
		pCmdUI->Enable(TRUE);
}

void CSelect::OnUpdateFileOpen(CCmdUI* pCmdUI) 
{
	if (Jmeno == "")
		pCmdUI->Enable(FALSE);
	else
		pCmdUI->Enable(TRUE);
}


void CSelect::OnItemchangedSelectlist(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_LISTVIEW* pNMListView = (NM_LISTVIEW*)pNMHDR;
	CDocument* doc = GetDocument();
	if ((doc != NULL) && (pNMListView->iItem >= 0))
	{
		if (((pNMListView->uNewState & LVIS_FOCUSED) != 0) &&
			((pNMListView->uOldState & LVIS_FOCUSED) == 0))
		{
			Jmeno = m_Select.GetItemText(pNMListView->iItem,0);
			doc->SetTitle(Jmeno);
		}
	}
	
	*pResult = 0;
}

void CSelect::OnDblclkSelectlist(NMHDR* pNMHDR, LRESULT* pResult) 
{
	if (Jmeno != "")
	{
		((CMainFrame*)GetOwner())->OnStart();
	}
	
	*pResult = 0;
}

