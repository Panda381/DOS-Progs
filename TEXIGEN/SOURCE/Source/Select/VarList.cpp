
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              Variation List                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// variation list global object
CVarList VarList;

///////////////////////////////////////////////////////////////////////////////
// constructor

CVarList::CVarList()
{
	m_SelInx = -1;
	m_ImgList = NULL;
	m_NextVar = 1;
}

///////////////////////////////////////////////////////////////////////////////
// set path and reload list (returns TRUE = path changed and list reloaded)

BOOL CVarList::SetPath(const CText& path)
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

void CVarList::SetSelInx(int inx)
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

void CVarList::Move(int x, int y, int w, int h)
{
	m_Rect.Set(x, y, w, h);
	m_Title.MoveResize(x, y, w, DefLabelH);
	m_Box.MoveResize(x, y + DefLabelH, w, h - DefLabelH);
}

///////////////////////////////////////////////////////////////////////////////
// show list

void CVarList::Show()
{
	// create title
	if (!m_Title.IsValid()) m_Title.CreateCenter(EmptyText,
		m_Rect.left, m_Rect.top, m_Rect.Width(), DefLabelH, MainFrame);

	// create selection box
	if (!m_Box.IsValid())
	{
		m_Box.CreateIco(m_Rect.left, m_Rect.top + DefLabelH,
			m_Rect.Width(), m_Rect.Height() - DefLabelH, TRUE, MainFrame);
		ListView_SetIconSpacing(m_Box.Handle(), ICONWH+7, ICONWH+7);
		if (m_ImgList != NULL) m_Box.SetImageList(m_ImgList);
	}

	// show controls
	m_Title.SetVisible(TRUE);
	m_Box.SetVisible(TRUE);

	// update language
	this->UpdateLang();
}

///////////////////////////////////////////////////////////////////////////////
// hide list

void CVarList::Hide()
{
	m_Title.SetVisible(FALSE);
	m_Box.SetVisible(FALSE);
}

///////////////////////////////////////////////////////////////////////////////
// update language text

void CVarList::UpdateLang()
{
	m_Title.LoadText(IDS_VARSEL_TITLE);
}

///////////////////////////////////////////////////////////////////////////////
// delete all entries from list

void CVarList::DelAll()
{
	// delete list box
	m_Box.DelAll();
	m_Box.SetImageList(NULL);

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

void CVarList::Load()
{
	// delete variations
	this->DelAll();
	if (m_Path.IsEmpty()) return;

	// create variation image list
	m_ImgList = ImageList_Create(ICONWH, ICONWH, ILC_COLOR24, 10, 10);
	m_Box.SetImageList(m_ImgList);

	// find all variations
	m_NextVar = 1;
	CText name = m_Path + _T("\\*." VAREXT);
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
			CVarEntry* v = &m_List[inx];
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

			// selected entry
			if (name == m_SelName) m_SelInx = inx;

			// next variation
			inx = name.Int() + 1;
			if (inx > m_NextVar) m_NextVar = inx;

		// find next file
		} while (::FindNextFile(fnd, &fd));

		// close search
		::FindClose(fnd);
	}

	// selected entry
	m_Box.SetSelect(m_SelInx);
	m_Box.EnsureVisible(m_SelInx);
}

///////////////////////////////////////////////////////////////////////////////
// set variation index (-1 = none)

void SelectVar(int inx, BOOL update /*= TRUE*/)
{
	VarList.SetSelInx(inx);
	WriteIniTxt("Variation", VarList.SelName());
	if (inx >= 0) LoadVar();
	if (update) UpdateSelCtrl();
	FGraphRestart();
	SPrevRenderStart();
}

///////////////////////////////////////////////////////////////////////////////
// load variation list

void LoadVarList()
{
	if (!VarList.SetPath(GraphList.VarPath())) VarList.Load();
	LoadVar();
	FGraphRestart();
	UpdateSelCtrl();
	SPrevRenderStart();
}

///////////////////////////////////////////////////////////////////////////////
// renumber variants

void RenumVar()
{
	int i;
	CVarEntry* e;
	CText name, filename, imgfilename, selname;
	for (i = 0; i < VarList.Num(); i++)
	{
		e = &VarList[i];
		name.Empty();
		if (i < 9) name.Add(TCHAR('0'));
		name.AddInt(i + 1);

		filename = VarList.Path() + _T("\\") + name + _T("." VAREXT);
		imgfilename = VarList.Path() + _T("\\") + name + _T("." PREVEXT);

		if (!FileExists(filename) && !FileExists(imgfilename))
		{
			if (VarList.SelName() == e->Name())
			{
				WriteIniTxt("Variation", name);
				VarList.SetSelName(name);
			}
			::MoveFile(e->FileName(), filename);
			::MoveFile(e->ImgFileName(), imgfilename);
		}
	}
	LoadVarList();
}
