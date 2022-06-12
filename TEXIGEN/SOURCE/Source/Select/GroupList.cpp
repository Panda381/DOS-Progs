
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                             Filter Group List                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// filter group list global object
CGroupList GroupList;

///////////////////////////////////////////////////////////////////////////////
// constructor

CGroupList::CGroupList()
{
	m_SelInx = -1;
}

///////////////////////////////////////////////////////////////////////////////
// set path and reload list (returns TRUE = path changed and list reloaded)

BOOL CGroupList::SetPath(const CText& path)
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

void CGroupList::SetSelInx(int inx)
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
}

///////////////////////////////////////////////////////////////////////////////
// move list

void CGroupList::Move(int x, int y, int w, int h)
{
	m_Rect.Set(x, y, w, h);
	m_Title.MoveResize(x, y, w, DefLabelH);
	m_Box.MoveResize(x, y + DefLabelH, w, h - DefLabelH);
}

///////////////////////////////////////////////////////////////////////////////
// show list

void CGroupList::Show()
{
	// create title
	if (!m_Title.IsValid()) m_Title.CreateCenter(EmptyText,
		m_Rect.left, m_Rect.top, m_Rect.Width(), DefLabelH, MainFrame);

	// create selection box
	if (!m_Box.IsValid()) m_Box.CreateLst(m_Rect.left, m_Rect.top + DefLabelH,
		m_Rect.Width(), m_Rect.Height() - DefLabelH, TRUE, FALSE, MainFrame);

	// show controls
	m_Title.SetVisible(TRUE);
	m_Box.SetVisible(TRUE);

	// update language
	this->UpdateLang();
}

///////////////////////////////////////////////////////////////////////////////
// hide list

void CGroupList::Hide()
{
	m_Title.SetVisible(FALSE);
	m_Box.SetVisible(FALSE);
}

///////////////////////////////////////////////////////////////////////////////
// update language text

void CGroupList::UpdateLang()
{
	m_Title.LoadText(IDS_GROUPSEL_TITLE);
}

///////////////////////////////////////////////////////////////////////////////
// delete all entries from list

void CGroupList::DelAll()
{
	// delete list box
	m_Box.DelAll();

	// no entry
	m_List.DelAll();
	m_SelInx = -1;
}

///////////////////////////////////////////////////////////////////////////////
// (re)load list

void CGroupList::Load()
{
	// delete variations
	this->DelAll();
	if (m_Path.IsEmpty()) return;

	// find all directories
	CText name = m_Path + _T("\\*.*");
	CText txt;
 	WIN32_FIND_DATA fd;
	HANDLE fnd = ::FindFirstFile(name, &fd);
	if (fnd != INVALID_HANDLE_VALUE)
	{
		do {
			// skip non-directories
			if (((fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == 0) ||
				(fd.cFileName[0] == TCHAR('.')))
				continue;

			// prepare name
			name = fd.cFileName;

			// add new entry
			int inx = m_List.New();
			if (inx < 0) break;
			CGroupEntry* v = &m_List[inx];
			v->SetName(name, m_Path);

			// add new entry into list box
			m_Box.Ins(v->Name(), inx);

			// selected entry
			if (name == m_SelName) m_SelInx = inx;

		// find next file
		} while (::FindNextFile(fnd, &fd));

		// close search
		::FindClose(fnd);
	}

	// selected entry
	if ((m_SelInx < 0) && (this->Num() > 0)) m_SelInx = 0;
	m_Box.SetSelect(m_SelInx);
}

///////////////////////////////////////////////////////////////////////////////
// set group index (-1 = none)

void SelectGroup(int inx)
{
	GroupList.SetSelInx(inx);
	WriteIniTxt("Group", GroupList.SelName());
	LoadGraphList();
}

///////////////////////////////////////////////////////////////////////////////
// load group list

void LoadGroupList()
{
	if (!GroupList.SetPath(DataDir)) GroupList.Load();
	LoadGraphList();
}
