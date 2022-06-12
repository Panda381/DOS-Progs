
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Property Frame                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// property control type
typedef enum PROPCT {
	PROPCT_INFO,		// info
	PROPCT_VAL,			// value
	PROPCT_VALLOCK,		// value with lock
	PROPCT_ENUM,		// enumeration
	PROPCT_COL,			// color RGBA
	PROPCT_COLRGB,		// color RGB
	PROPCT_COLLOCK,		// color RGBA with lock
	PROPCT_COLRGBLOCK,	// color RGB with lock
	PROPCT_IMG,			// image
	PROPCT_IMGLOCK,		// image with lock
	PROPCT_TEXT,		// text
	PROPCT_CHK,			// switch
	PROPCT_TILES,		// tiles switch
	PROPCT_MIN,			// min/max
	PROPCT_MINVAL,		// min/max value
};

// callback on lock change
typedef void (*cbOnLock) (int inx, BOOL lock);

// callback on value change
typedef void (*cbOnValue) (int inx, real value);

// callback on color change
typedef void (*cbOnColor) (int inx, const CColor* col);

// callback on image/text change
typedef void (*cbOnImage) (int inx, CText filename);

// callback on switch/tiles change
typedef void (*cbOnSwitch) (int inx, BOOL chk);

// callback on min/max change
typedef void (*cbOnMinMax) (int inx, int min, int max);

// callback on min/max value change
typedef void (*cbOnMinMaxVal) (int inx, real minval, real maxval);

// property control
class CPropCtrl
{
protected:

	// property index
	int			m_Index;

	// parent
	CFrame*		m_Parent;

	// property control type
	PROPCT		m_Type;

	// use lock
	BOOL		m_UseLock;

	// lock
	CCheckBox	m_Lock;

	// label
	CLabel		m_Label;

	// info
	CLabel		m_Info;

	// value/enumeration controls
	real		m_Value;
	CSlider		m_VSlider;
	CDropList	m_EDrop;
	CEdit		m_VValue;
	CButtonPic	m_VDown;
	CButtonPic	m_VUp;

	// color controls
	CColor		m_Color;
	CButtonPic	m_CColor;
	CLabel		m_CLabel[4];
	CEdit		m_CEdit[4];

	// image/text controls
	CText		m_FileName;
	CEdit		m_IEdit;
	CButton		m_IClear;
	CButton		m_IBrowse;

	// switch control
	CCheckBox	m_SSwitch;

	// min/max control
	CEdit		m_MMinEdit;
	CLabel		m_MMaxLabel;
	CEdit		m_MMaxEdit;

	// update color button image
	void UpdateColBtnImg(u32 color);

public:

	// property index
	inline int Index() const { return m_Index; }

	// parent
	inline CFrame* Parent() const { return m_Parent; }

	// property control type
	inline PROPCT Type() const { return m_Type; }

	// use lock
	inline BOOL UseLock() const { return m_UseLock; }

	// create control (returns FALSE on error)
	BOOL Create(int index, CFrame* parent, PROPCT type, CText label, int toolid);

	// property lock
	inline BOOL GetLock() { return m_Lock.GetCheck(); }
	inline void SetLock(BOOL lock) { m_Lock.SetCheck(lock); }

	// set info
	inline void SetInfo(const CText& text) { m_Info.SetText(text); }

	// set value control minimum and maximum (default 0 and 100)
	void SetMinMax(int min, int max);

	// set value of value/enumeration control
	inline real GetValue() const { return m_Value; }
	inline real GetValueEdit() { return (real)m_VValue.GetNum(); }
	inline int GetValueSlider() { return m_VSlider.GetPos(); }
	inline int GetValueEnum() { return m_EDrop.GetSelect(); }
	void SetValue(real val, CWindow* except = NULL);

	// set enumeration list (entries separated with "|" character)
	void SetEnum(const CText lst[], int num);
	void SetEnum(const CText& text);

	// set color
	inline void GetColor(CColor* col) const { return col->Set(m_Color); }
	inline real GetColorEdit(int inx) { return (real)m_CEdit[inx].GetNum()/255; }
	void SetColor(CColor* col, CWindow* except = NULL);

	// set image filename/text
	inline CText GetImg() const { return m_FileName; }
	inline CText GetImgEdit() { return m_IEdit.GetText(); }
	void SetImg(const CText& text, CWindow* except = NULL);

	// set switch
	inline BOOL GetSwitch() { return m_SSwitch.GetCheck(); }
	inline void SetSwitch(BOOL on) { m_SSwitch.SetCheck(on); }

	// set min/max control values
	inline int GetMinEdit() { return m_MMinEdit.GetInt(); }
	inline void SetMinEdit(int min) { m_MMinEdit.SetInt(min); }
	inline int GetMaxEdit() { return m_MMaxEdit.GetInt(); }
	inline void SetMaxEdit(int max) { m_MMaxEdit.SetInt(max); }

	// set min/max value control values
	inline real GetMinValEdit() { return (real)m_MMinEdit.GetNum(); }
	inline void SetMinValEdit(real minval) { m_MMinEdit.SetNum(minval); }
	inline real GetMaxValEdit() { return (real)m_MMaxEdit.GetNum(); }
	inline void SetMaxValEdit(real maxval) { m_MMaxEdit.SetNum(maxval); }

	// move control
	void Move(int y);

	// destroy control
	void Destroy();
};

// property frame
class CPropFrame
{
protected:

	// control list
	CArray<CPropCtrl> m_List;

	// layout rectangle
	CRect		m_Rect;

	// frame
	CFrame		m_Frame;
	CScroller	m_Scroller;

	// callback on lock change
	// typedef void (*cbOnLock) (int inx, BOOL lock);
	cbOnLock	m_OnLock;

	// callback on value change (NULL=none)
	// typedef void (*cbOnValue) (int inx, real value);
	cbOnValue	m_OnValue;

	// callback on color change (NULL=none)
	// typedef void (*cbOnColor) (int inx, const CColor* col);
	cbOnColor	m_OnColor;

	// callback on image change (NULL=none)
	// typedef void (*cbOnImage) (int inx, CText filename);
	cbOnImage	m_OnImage;

	// callback on switch/tiles change (NULL=none)
	// typedef void (*cbOnSwitch) (int inx, BOOL chk);
	cbOnSwitch	m_OnSwitch;

	// callback on min/max change (NULL=none)
	// typedef void (*cbOnMinMax) (int inx, int min, int max);
	cbOnMinMax	m_OnMinMax;

	// callback on min/max value change (NULL=none)
	// typedef void (*cbOnMinMaxVal) (int inx, real minval, real maxval);
	cbOnMinMaxVal m_OnMinMaxVal;

	// frame virtual height and top
	int			m_VHeight;
	int			m_VTop;
	void UpdateVHeight();

	// scroll frame content to new position
	void Scroll();

public:

	// constructor
	CPropFrame();

	// entries list
	CPropCtrl* List() { return &m_List[0]; }

	// number of entries in the list
	inline int Num() const { return m_List.Num(); }

	// check if entry index is valid
	inline BOOL IsValid(int inx) const { return m_List.IsValid(inx); }

	// entry (without index checking)
	inline CPropCtrl& operator[] (int inx) { return m_List[inx]; }
	inline const CPropCtrl& operator[] (int inx) const { return m_List[inx]; }

	// frame
	inline CFrame* Frame() { return &m_Frame; }

	// callback on lock change
	// typedef void (*cbOnLock) (int inx, BOOL lock);
	inline void SetOnLock(cbOnLock cb) { m_OnLock = cb; }

	// set callback on value change (NULL=none)
	// typedef void (*cbOnValue) (int inx, real value);
	inline void SetOnValue(cbOnValue cb) { m_OnValue = cb; }

	// set callback on color change (NULL=none)
	// typedef void (*cbOnColor) (int inx, const CColor* col);
	inline void SetOnColor(cbOnColor cb) { m_OnColor = cb; }

	// set callback on image change (NULL=none)
	// typedef void (*cbOnImage) (int inx, CText filename);
	inline void SetOnImage(cbOnImage cb) { m_OnImage = cb; }

	// set callback on switch/tiles change (NULL=none)
	// typedef void (*cbOnSwitch) (int inx, BOOL chk);
	inline void SetOnSwitch(cbOnSwitch cb) { m_OnSwitch = cb; }

	// set callback on min/max change (NULL=none)
	// typedef void (*cbOnMinMax) (int inx, int min, int max);
	inline void SetOnMinMax(cbOnMinMax cb) { m_OnMinMax = cb; }

	// set callback on min/max value change (NULL=none)
	// typedef void (*cbOnMinMaxVal) (int inx, real minval, real maxval);
	inline void SetOnMinMaxVal(cbOnMinMaxVal cb) { m_OnMinMaxVal = cb; }

	// lock/unlock window update
	inline void LockUpdate() { ::LockWindowUpdate(m_Frame.Handle()); }
	inline static void UnlockUpdate() { ::LockWindowUpdate(NULL); }

	// frame virtual height and top
	inline int VHeight() const { return m_VHeight; }
	inline int VTop() const { return m_VTop; }
	inline int Height() const { return m_Rect.Height(); }

	// invert all locks
	void LockInv();

	// on command message (returns TRUE if message was processed)
	BOOL OnCommand(CWindow* w, int id);

	// on scroller message (returns TRUE if message was processed)
	BOOL OnScroller(HWND wnd, WPARAM wParam);

	// move frame
	void Move(int x, int y, int w, int h);

	// show frame
	void Show();

	// hide frame and all controls
	void Hide();

	// add control (returns NULL on error)
	CPropCtrl* Add(PROPCT type, CText label, int labid);
	CPropCtrl* Add(PROPCT type, int lab, int labid)
	{
		CText label;
		label.Load(lab);
		return this->Add(type, label, labid);
	}

	// delete all controls (and clear all callbacks)
	void DelAll();
};

// Property frame global variable
extern CPropFrame PropFrame;
