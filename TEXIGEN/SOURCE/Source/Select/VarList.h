
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              Variation List                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// variation entry
class CVarEntry
{
protected:

	// name (without path and extension)
	CText		m_Name;

	// full filename (with path)
	CText		m_FileName;

	// image full filename (with path)
	CText		m_ImgFileName;

	// image (NULL=none)
	HBITMAP		m_Image;

	// image index in image list (-1=none)
	int			m_ImageInx;

public:

	// name (without path and extension)
	inline CText Name() const { return m_Name; }
	inline void SetName(const CText& name, const CText& path)
	{
		m_Name = name;
		m_FileName = path + _T("\\") + name + _T("." VAREXT);
		m_ImgFileName = path + _T("\\") + name + _T("." PREVEXT);
	}

	// full filename (with path)
	inline CText FileName() const { return m_FileName; }

	// image full filename (with path)
	inline CText ImgFileName() const { return m_ImgFileName; }

	// image
	inline HBITMAP Image() const { return m_Image; }
	inline void SetImage(HBITMAP img) { m_Image = img; }
	inline void DelImage()
	{
		if (m_Image != NULL)
		{
			::DeleteObject(m_Image);
			m_Image = NULL;
		}
	}

	// image index in image list
	inline int ImageInx() const { return m_ImageInx; }
	inline void SetImageInx(int inx) { m_ImageInx = inx; }
};

// variation list
class CVarList
{
protected:

	// path (without ending "\", empty = none)
	CText		m_Path;

	// entries list
	CArray<CVarEntry>	m_List;

	// selected entry name (Empty = none)
	CText		m_SelName;

	// selected entry index (-1 = none)
	int			m_SelInx;

	// image list (NULL=none)
	HIMAGELIST	m_ImgList;

	// layout rectangle (title and box)
	CRect		m_Rect;

	// selection title
	CLabel		m_Title;

	// selection box
	CListView	m_Box;

	// next variation number
	int			m_NextVar;

public:

	// constructor
	CVarList();

	// path (without ending "\", empty = none)
	inline CText Path() const { return m_Path; }

	// set path and reload list (returns TRUE = path changed and list reloaded)
	BOOL SetPath(const CText& path);

	// entries list
	CVarEntry* List() { return &m_List[0]; }

	// number of entries in the list
	inline int Num() const { return m_List.Num(); }

	// check if entry index is valid
	inline BOOL IsValid(int inx) const { return m_List.IsValid(inx); }

	// entry (without index checking)
	inline CVarEntry& operator[] (int inx) { return m_List[inx]; }
	inline const CVarEntry& operator[] (int inx) const { return m_List[inx]; }

	// filename with path (empty = none)
	CText Filename(int inx) { return this->IsValid(inx) ? m_List[inx].FileName() : EmptyText; }
	CText Filename() { return this->Filename(m_SelInx); }

	// image filename with path
	CText ImgFilename(int inx) { return this->IsValid(inx) ? m_List[inx].ImgFileName() : EmptyText; }
	CText ImgFilename() { return this->ImgFilename(m_SelInx); }

	// selected entry name (Empty = none)
	inline CText SelName() const { return m_SelName; }
	inline void SetSelName(const CText& name) { m_SelName = name; }

	// selected entry index (-1 or NULL = none)
	inline int SelInx() const { return m_SelInx; }
	void SetSelInx(int inx);
	inline int GetSelInx() { return m_Box.GetSelect(); }
	inline CVarEntry* Selected() { return this->IsValid(m_SelInx) ? &m_List[m_SelInx] : NULL; }

	// image list (NULL=none)
	inline HIMAGELIST ImgList() const { return m_ImgList; }
	inline void SetImgList(HIMAGELIST list) { m_ImgList = list; }

	// selection title
	inline CLabel* Title() { return &m_Title; }

	// variation selection box
	inline CListView* Box() { return &m_Box; }

	// next variation number
	inline int NextVar() { return m_NextVar; }

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

	// renumber variants
	void Renumber();
};

// variation list global object
extern CVarList VarList;

///////////////////////////////////////////////////////////////////////////////
// select variation index (-1 = none)

void SelectVar(int inx, BOOL update = TRUE);

///////////////////////////////////////////////////////////////////////////////
// load variation list

void LoadVarList();

///////////////////////////////////////////////////////////////////////////////
// renumber variants

void RenumVar();
