
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                   Picture                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// picture

class CPicture : public CListEntryData<CPicture>
{
protected:

	// picture filename
	CText		m_Filename;

	// device picture dimension
	long		m_DevWidth;
	long		m_DevHeight;

	// picture dimension
	int			m_Width;
	int			m_Height;

	// OLE picture (NULL=none)
	IPicture*	m_Pic;

public:

	// constructor and destructor
	CPicture();
	~CPicture();

	// load picture (returns FALSE on error)
	BOOL LoadFile(const CText& filename);

	// picture filename
	inline const CText& Filename() const { return m_Filename; }

	// device picture dimension
	inline int DevWidth() const { return m_DevWidth; }
	inline int DevHeight() const { return m_DevHeight; }

	// picture dimension
	inline int Width() const { return m_Width; }
	inline int Height() const { return m_Height; }

	// OLE picture (NULL=none)
	inline IPicture* Pic() const { return m_Pic; }

	// draw picture
	void Draw(HDC dc, int w, int h);
};

class CPictureList : public CListList<CPicture>
{
public:

	// get picture (returns NULL on error)
	CPicture* Get(const CText& filename);

	// reload picture (returns NULL on error, does not send error event)
	CPicture* Reload(const CText& filename);
};

extern CPictureList	PicCache;

///////////////////////////////////////////////////////////////////////////////
// picture window

class CPictureWin : public CChildWindow
{
protected:

	// picture in cache (NULL=none)
	CPicture*	m_Picture;

	// autosize control
	BOOL		m_AutoSize;

	// do autosize and redraw
	void DoAutoSize();

public:

	// constructor
	CPictureWin();

	// create picture window (returns FALSE on error)
	BOOL CreatePic(int x, int y, int w, int h, CWindow* parent = NULL);

	// picture
	inline CPicture* Picture() const { return m_Picture; }

	// original picture dimension
	inline int PicWidth() const { return (m_Picture == NULL) ? 0 : m_Picture->Width(); }
	inline int PicHeight() const { return (m_Picture == NULL) ? 0 : m_Picture->Height(); }

	// autosize control
	inline BOOL AutoSize() const { return m_AutoSize; }
	void SetAutoSize(BOOL autosize)
	{
		if (m_AutoSize != autosize)
		{
			m_AutoSize = autosize;
			DoAutoSize();
		}
	}

	// draw control (on WM_PAINT message)
	void OnDraw(HDC dc);

	// load picture (returns FALSE on error)
	BOOL Load(const CText& filename);
};
