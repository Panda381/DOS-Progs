
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                             Filter Graph List                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// filter graph list global object
CGraphList GraphList;

///////////////////////////////////////////////////////////////////////////////
// constructor

CGraphList::CGraphList()
{
	m_SelInx = -1;
	m_ImgList = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// set path and reload list (returns TRUE = path changed and list reloaded)

BOOL CGraphList::SetPath(const CText& path)
{
	if (path != m_Path)
	{
		if (m_Path.IsNotEmpty()) m_SelName.Empty();
		m_Path = path;
		this->Load();
		return TRUE;
	}
	return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// select entry index (-1 = none)

void CGraphList::SetSelInx(int inx)
{
	// set entry index
	if (this->IsValid(inx))
	{
		// valid entry
		m_SelName = m_List[inx].Name();
		m_SelInx = inx;
	}
	else
	{
		// invalid entry
		m_SelName.Empty();
		m_SelInx = -1;
	}

	// select entry
	m_Box.SetSelect(m_SelInx);
	m_Box.EnsureVisible(m_SelInx);
}

///////////////////////////////////////////////////////////////////////////////
// move list

void CGraphList::Move(int x, int y, int w, int h)
{
	m_Rect.Set(x, y, w, h);
	m_Title.MoveResize(x, y, w, DefLabelH);
	m_Box.MoveResize(x, y + DefLabelH, w, h - DefLabelH);
}

///////////////////////////////////////////////////////////////////////////////
// show list

void CGraphList::Show()
{
	// create title
	if (!m_Title.IsValid()) m_Title.CreateCenter(EmptyText,
		m_Rect.left, m_Rect.top, m_Rect.Width(), DefLabelH, MainFrame);

	// create selection box
	if (!m_Box.IsValid())
	{
		m_Box.CreateRep(m_Rect.left, m_Rect.top + DefLabelH,
			m_Rect.Width(), m_Rect.Height() - DefLabelH, TRUE, FALSE, FALSE, MainFrame);
		m_Box.AddCol(LVCFMT_LEFT, ICONWH + 2, "", 0, 0);
		m_Box.AddCol(LVCFMT_LEFT, m_Rect.Width() - ICONWH - 2 - 4 - 20, "", 1, 0);
	}

	// show controls
	m_Title.SetVisible(TRUE);
	m_Box.SetVisible(TRUE);

	// update language
	this->UpdateLang();
}

///////////////////////////////////////////////////////////////////////////////
// hide list

void CGraphList::Hide()
{
	m_Title.SetVisible(FALSE);
	m_Box.SetVisible(FALSE);
}

///////////////////////////////////////////////////////////////////////////////
// update language text

void CGraphList::UpdateLang()
{
	m_Title.LoadText(IDS_GRAPHSEL_TITLE);
}

///////////////////////////////////////////////////////////////////////////////
// delete all entries from list

void CGraphList::DelAll()
{
	// delete list box
	m_Box.DelAll();
	m_Box.SetImageListSmall(NULL);

	// delete images
	int i;
	for (i = 0; i < this->Num(); i++) m_List[i].DelImage();

	// delete image list
	if (m_ImgList != NULL)
	{
		ImageList_Destroy(m_ImgList);
		m_ImgList = NULL;
	}

	// no entry
	m_List.DelAll();
	m_SelInx = -1;
}

///////////////////////////////////////////////////////////////////////////////
// (re)load list

void CGraphList::Load()
{
	// delete graphs
	this->DelAll();
	if (m_Path.IsEmpty()) return;

	// create graph image list
	m_ImgList = ImageList_Create(ICONWH, ICONWH, ILC_COLOR24, 10, 10);
	m_Box.SetImageListSmall(m_ImgList);

	// find all graphs
	CText name = m_Path + _T("\\*." GRAPHEXT);
	CText txt;
 	WIN32_FIND_DATA fd;
	HANDLE fnd = ::FindFirstFile(name, &fd);
	if (fnd != INVALID_HANDLE_VALUE)
	{
		do {
			// skip directories
			if ((fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0) continue;

			// prepare name
			name = fd.cFileName;
			name.DelToEnd(name.Length() - 4);

			// add new entry
			int inx = m_List.New();
			if (inx < 0) break;
			CGraphEntry* v = &m_List[inx];
			v->SetName(name, m_Path);

			// create image
			HBITMAP bmp = (HBITMAP)::LoadImage(NULL, v->ImgFileName(), IMAGE_BITMAP,
				ICONWH, ICONWH, LR_DEFAULTCOLOR | LR_LOADFROMFILE);
			v->SetImage(bmp);
			if (bmp != NULL)
				v->SetImageInx(ImageList_Add(m_ImgList, bmp, NULL));
			else
				v->SetImageInx(-1);

			// add new entry into list box
			m_Box.InsImg(v->ImageInx(), inx);
			m_Box.SetItemText(v->Name(), inx, 1);

			// selected entry
			if (name == m_SelName) m_SelInx = inx;

		// find next file
		} while (::FindNextFile(fnd, &fd));

		// close search
		::FindClose(fnd);
	}

	// selected entry
	if ((m_SelInx < 0) && (this->Num() > 0))
	{
		m_SelInx = 0;
		m_SelName = m_List[0].Name();
		WriteIniTxt("Graph", m_SelName);
	}
	m_Box.SetSelect(m_SelInx);
	m_Box.EnsureVisible(m_SelInx);
}

///////////////////////////////////////////////////////////////////////////////
// set graph index (-1 = none)

void SelectGraph(int inx)
{
	GraphList.SetSelInx(inx);
	WriteIniTxt("Graph", GraphList.SelName());
	LoadGraph(GraphList.Filename());
	UpdateOutputList();
	SetCaption();
	LoadVarList();
}

///////////////////////////////////////////////////////////////////////////////
// load graph list

void LoadGraphList()
{
	if (!GraphList.SetPath(GroupList.GraphPath())) GraphList.Load();
	LoadGraph(GraphList.Filename());
	UpdateOutputList();
	SetCaption();
	LoadVarList();
}
