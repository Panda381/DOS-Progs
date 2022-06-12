
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                             Filter Group List                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// filter group entry
class CGroupEntry
{
protected:

	// name (without path and extension)
	CText		m_Name;

	// graph folder (without ending path separator)
	CText		m_GraphPath;

public:

	// name (without path and extension)
	inline CText Name() const { return m_Name; }
	inline void SetName(const CText& name, const CText& path)
	{
		m_Name = name;
		m_GraphPath = path + _T("\\") + name;
	}

	// graph folder (without ending path separator)
	inline CText GraphPath() const { return m_GraphPath; }
};

// filter group list
class CGroupList
{
protected:

	// path (withou ending "\", empty = none)
	CText		m_Path;

	// entries list
	CArray<CGroupEntry>	m_List;

	// selected entry name (Empty = none)
	CText		m_SelName;

	// selected entry index (-1 = none)
	int			m_SelInx;

	// layout rectangle (title and box)
	CRect		m_Rect;

	// selection title
	CLabel		m_Title;

	// selection box
	CListBox	m_Box;

public:

	// constructor
	CGroupList();

	// path (without ending "\", empty = none)
	inline CText Path() const { return m_Path; }

	// set path and reload list (returns TRUE = path changed and list reloaded)
	BOOL SetPath(const CText& path);

	// entries list
	CGroupEntry* List() { return &m_List[0]; }

	// number of entries in the list
	inline int Num() const { return m_List.Num(); }

	// check if entry index is valid
	inline BOOL IsValid(int inx) const { return m_List.IsValid(inx); }

	// entry (without index checking)
	inline CGroupEntry& operator[] (int inx) { return m_List[inx]; }
	inline const CGroupEntry& operator[] (int inx) const { return m_List[inx]; }

	// graph path (empty = none)
	CText GraphPath(int inx) { return this->IsValid(inx) ? m_List[inx].GraphPath() : EmptyText; }
	CText GraphPath() { return this->GraphPath(m_SelInx); }

	// selected entry name (Empty = none)
	inline CText SelName() const { return m_SelName; }
	inline void SetSelName(const CText& name) { m_SelName = name; }

	// selected entry index (-1 or NULL = none)
	inline int SelInx() const { return m_SelInx; }
	void SetSelInx(int inx);
	inline int GetSelInx() { return m_Box.GetSelect(); }
	inline CGroupEntry* Selected() { return this->IsValid(m_SelInx) ? &m_List[m_SelInx] : NULL; }

	// selection title
	inline CLabel* Title() { return &m_Title; }

	// selection box
	inline CListBox* Box() { return &m_Box; }

	// move list
	void Move(int x, int y, int w, int h);

	// show list
	void Show();

	// hide list
	void Hide();

	// update language text
	void UpdateLang();

	// delete all entries
	void DelAll();

	// (re)load list
	void Load();
};

// filter group list global object
extern CGroupList GroupList;

///////////////////////////////////////////////////////////////////////////////
// set group index (-1 = none)

void SelectGroup(int inx);

///////////////////////////////////////////////////////////////////////////////
// load group list

void LoadGroupList();
