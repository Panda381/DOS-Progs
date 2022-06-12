
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Text String                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// multithreaded LONG increment
void LongIncrement(long* num);

// multithreaded LONG decrement (returns previous state)
long LongDecrement(long* num);

// text file code page (load/save)
typedef enum FILECP {
	FILECP_ANSI,						// default ANSI code page (Win 8 bits)
	FILECP_UTF16,						// WIDECHAR Windows code page (16 bits)
	FILECP_UTF7,						// UTF-7
	FILECP_UTF8,						// UTF-8
	FILECP_OEM,							// OEM, default DOS code page
};

///////////////////////////////////////////////////////////////////////////////
// Text string data (8 bytes + data)

typedef struct TEXTDATA_
{
	// reference counter (number of owners, 0=nobody)
	long		ref;

	// length of text string
	long		length;

	// text string data (including terminating zero)
	TCHAR		data[1];

} TEXTDATA;

// size of text string data head
#define SIZEOFTEXTDATA (2*sizeof(long))

// empty text string data
extern TEXTDATA EmptyTextData;

// convert text to INT number
int Int(LPCTSTR text);

// convert text to HEX number
DWORD Hex(LPCTSTR text);

// convert text to DOUBLE number
double Double(LPCTSTR text);

///////////////////////////////////////////////////////////////////////////////
// Text string

class CText
{
protected:

	// pointer to text string data
	TEXTDATA*	m_Data;

	// create new text data (old text data must be delete)
	// (on error attaches empty text string data and returns FALSE)
	BOOL NewBuffer(int length);

	// resize data buffer (ref must be = 1, returns FALSE on error)
	BOOL SetSize(int length);

public:

	// constructors
	inline CText() { Attach(&EmptyTextData); }
	inline CText(TEXTDATA* data) { Attach(data); }
	inline CText(const CText& src) { Attach(src.m_Data); }
	CText(TCHAR chr);
	CText(LPCTSTR txt, int length = -1);
#ifdef _UNICODE
	CText(LPCSTR txt, int length = -1);
#else // _UNICODE
	CText(LPCWSTR txt, int length = -1);
#endif // _UNICODE
	CText(CText txt1, CText txt2);
	CText(LPCTSTR txt1, CText txt2);
	CText(CText txt1, LPCTSTR txt2);
	CText(TCHAR chr, CText txt);
	CText(CText txt, TCHAR chr);

	// destructor
	inline ~CText() { Detach(); }

	// attach text string data
	void Attach(TEXTDATA* data);

	// detach (and destroy) text string data
	void Detach();

	// detach and attach text string data (avoid deleting identical data)
	inline void DetachAttach(TEXTDATA* data)
	{
		if (data != m_Data)
		{
			Detach();
			Attach(data);
		}
	}

	// appropriate text string data before write (returns FALSE on error)
	BOOL CopyWrite();

	// get reference counter of text string data
	inline int Ref() const { return m_Data->ref; }

	// text length
	inline int Length() const { return m_Data->length; }
	BOOL SetLength(int length);

	// check if string is empty
	inline BOOL IsEmpty() const { return m_Data->length == 0; }
	inline BOOL IsNotEmpty() const { return m_Data->length != 0; }

	// get text data
	inline TEXTDATA* Data() const { return m_Data; }

	// get text string
	inline TCHAR* DataData() const { return m_Data->data; }

	// retype operator
	inline operator LPCTSTR() const { return m_Data->data; }

	// empty string
	inline void Empty() { Detach(); Attach(&EmptyTextData); }

	// check if character index is valid
	inline BOOL IsValid(int inx) const
		{ return (DWORD)inx < (DWORD)m_Data->length; }
	inline BOOL IsNotValid(int inx) const
		{ return (DWORD)inx >= (DWORD)m_Data->length; }

	// array operator (without index checking)
	inline const TCHAR& operator[] (int inx) const
		{ return m_Data->data[inx]; }

	// get character at given position (with index checking)
	inline TCHAR At(int inx) const { if (IsValid(inx))
			return m_Data->data[inx]; else return _T('\0'); }
	inline TCHAR First() const { return At(0); }
	inline TCHAR Last() const { return At(m_Data->length-1); }

	// set character (with index checking, returns FALSE on error)
	BOOL SetAt(int inx, TCHAR chr);
	inline BOOL SetFirst(TCHAR chr) { return SetAt(0, chr); }
	inline BOOL SetLast(TCHAR chr) { return SetAt(m_Data->length-1, chr); }

	// set text (returns FALSE on error)
	void Set(const CText& txt);
	BOOL Set(LPCTSTR txt, int length = -1);
#ifdef _UNICODE
	BOOL Set(LPCSTR txt, int length = -1);
#else // _UNICODE
	BOOL Set(LPCWSTR txt, int length = -1);
#endif // _UNICODE
	BOOL Set(TCHAR chr);
	BOOL Set(const char* buf, int size, FILECP cp);

	// add repeated text (returns FALSE on error)
	BOOL AddRep(int count, CText txt);
	BOOL AddRep(int count, LPCTSTR txt, int length = -1);
#ifdef _UNICODE
	BOOL AddRep(int count, LPCSTR txt, int length = -1);
#else // _UNICODE
	BOOL AddRep(int count, LPCWSTR txt, int length = -1);
#endif // _UNICODE
	BOOL AddRep(int count, TCHAR chr);

	// set time in long format h:mm:ss (value is in seconds)
	void SetTime(int sec, BOOL add = FALSE);

	// add text (returns FALSE on error)
	inline BOOL Add(CText txt) { return AddRep(1, txt); }
	inline BOOL Add(LPCTSTR txt, int length = -1)
		{ return AddRep(1, txt, length); }
#ifdef _UNICODE
	inline BOOL Add(LPCSTR txt, int length = -1)
		{ return AddRep(1, txt, length); }
#else // _UNICODE
	inline BOOL Add(LPCWSTR txt, int length = -1)
		{ return AddRep(1, txt, length); }
#endif // _UNICODE
	inline BOOL Add(TCHAR chr) { return AddRep(1, chr); }

	// write text into buffer (without terminating zero)
	void Write(TCHAR* buf, int maxlen = BIGINT) const;
#ifdef _UNICODE
	void Write(LPSTR buf, int maxlen = BIGINT) const;
#else // _UNICODE
	void Write(LPWSTR buf, int maxlen = BIGINT) const;
#endif // _UNICODE
	int Write(char* buf, int bufsize, FILECP cp) const;

	// write text into buffer with terminating zero
	void WriteZ(TCHAR* buf, int maxlen = BIGINT) const;
#ifdef _UNICODE
	void WriteZ(LPSTR buf, int maxlen = BIGINT) const;
#else // _UNICODE
	void WriteZ(LPWSTR buf, int maxlen = BIGINT) const;
#endif // _UNICODE

	// find character (-1=not found) (warning,use _T('x') form, not (TCHAR)'x')
	int Find(TCHAR chr, int pos = 0) const;
	int FindRev(TCHAR chr, int pos = BIGINT) const;

	// find white space character (space, tab, newline, -1 = not found)
	int FindSpace(int pos = 0) const;
	int FindSpaceRev(int pos = BIGINT) const;

	// find non white space character (no space, tab, newline, -1 = not found)
	int FindNSpace(int pos = 0) const;
	int FindNSpaceRev(int pos = BIGINT) const;

	// find text (-1 = not found)
	int Find(const CText& txt, int pos = 0) const;
	int FindRev(const CText& txt, int pos = BIGINT) const;
	int Find(LPCTSTR txt, int length = -1, int pos = 0) const;
	int FindRev(LPCTSTR txt, int length = -1, int pos = BIGINT) const;

	// find characters from the list (-1 = not found)
	int FindList(LPCTSTR list, int count = -1, int pos = 0) const;
	inline int FindList(const CText& list, int pos = 0) const
		{ return FindList(list.m_Data->data, list.m_Data->length, pos); }
	int FindListRev(LPCTSTR list, int count = -1, int pos = BIGINT) const;
	inline int FindListRev(const CText& list, int pos = BIGINT) const
		{ return FindListRev(list.m_Data->data, list.m_Data->length, pos); }

	// find characters except the list (-1 = not found)
	int FindExcept(LPCTSTR list, int count = -1, int pos = 0) const;
	inline int FindExcept(const CText& list, int pos = 0) const
		{ return FindExcept(list.m_Data->data, list.m_Data->length, pos); }
	int FindExceptRev(LPCTSTR list, int count = -1, int pos = BIGINT) const;
	inline int FindExceptRev(const CText& list, int pos = BIGINT) const
		{ return FindExceptRev(list.m_Data->data, list.m_Data->length, pos); }

	// substitute strings (returns FALSE on error)
	BOOL Subst(CText txt, CText subst);

	// substitute characters from the list (returns FALSE on error)
	BOOL SubstList(LPCTSTR list, LPCTSTR subst, int count = -1);
	BOOL SubstList(CText list, CText subst);

	// convert text to uppercase (returns FALSE on error)
	BOOL UpperCase();

	// convert text to lowercase (returns FALSE on error)
	BOOL LowerCase();

	// left part of text (returns empty string on error)
	CText Left(int len) const;

	// right part of text (returns empty string on error)
	CText Right(int len) const;
	CText RightFrom(int pos) const;

	// middle part of text (returns empty string on error)
	CText Mid(int pos, int len) const;

	// insert text (returns FALSE on error)
	BOOL Insert(int pos, LPCTSTR txt, int length = -1);
	inline BOOL Insert(int pos, CText txt)
		{ return Insert(pos, txt.m_Data->data, txt.m_Data->length); }
	BOOL Insert(int pos, TCHAR chr);

	// delete characters (returns FALSE on error)
	BOOL Delete(int pos, int count = 1);
	inline BOOL DelFirst() { return Delete(0); }
	inline BOOL DelLast() { return Delete(m_Data->length - 1); }
	inline BOOL DelToEnd(int pos) { return Delete(pos, BIGINT); }

	// delete characters from the list (returns FALSE on error)
	BOOL DelList(LPCTSTR list, int count = -1);
	inline BOOL DelList(CText list)
		{ return DelList(list.m_Data->data, list.m_Data->length); }

	// delete characters except the list (returns FALSE on error)
	BOOL DelExcept(LPCTSTR list, int count = -1);
	inline BOOL DelExcept(CText list)
		{ return DelExcept(list.m_Data->data, list.m_Data->length); }

	// find and delete all words (return FALSE on error)
	BOOL DelWord(LPCTSTR txt, int length = -1);
	inline BOOL DelWord(CText txt)
		{ return DelWord(txt.m_Data->data, txt.m_Data->length); }

	// trim white spaces from the string (returns FALSE on error)
	BOOL TrimLeft();
	BOOL TrimRight();
	inline BOOL Trim() { return TrimRight() && TrimLeft(); }

	// nul correction (check and truncate text on NUL character)
	void CheckNul();

	// get number of rows using CR/LF (or LF)
	int RowsNum() const;
	int RowsNumLF() const;

	// get one row using CR/LF (or LF, trim CR))
	CText Row(int row) const;
	CText RowLF(int row) const;

	// convert INT number to text (returns FALSE on error)
	BOOL SetInt(int num, BOOL add = FALSE);
	inline BOOL AddInt(int num) { return SetInt(num, TRUE); }

	// set 2 digits (returns FALSE on error)
	BOOL Set2Dig(int num, BOOL add = FALSE);
	inline BOOL Add2Dig(int num) { return Set2Dig(num, TRUE); }

	// set 2 digits with space padding (returns FALSE on error)
	BOOL Set2DigSpc(int num, BOOL add = FALSE);
	inline BOOL Add2DigSpc(int num) { return Set2DigSpc(num, TRUE); }

	// set 4 digits (returns FALSE on error)
	BOOL Set4Dig(int num, BOOL add = FALSE);
	inline BOOL Add4Dig(int num) { return Set4Dig(num, TRUE); }

	// convert DWORD number to text as HEX (return FALSE on error)
	BOOL SetHex(DWORD num, int digits = -1, BOOL add = FALSE);
	inline BOOL AddHex(DWORD num, int digits = -1)
		{ return SetHex(num, digits, TRUE); }

	// convert DOUBLE number to text (returns FALSE on error)
	BOOL SetDouble(double num, int digits = 15, BOOL add = FALSE);
	inline BOOL AddDouble(double num, int digits = 15)
		{ return SetDouble(num, digits, TRUE); }
	inline BOOL SetFloat(float num, int digits = 7, BOOL add = FALSE)
		{ return SetDouble(num, digits, add); }
	inline BOOL AddFloat(float num, int digits = 7)
		{ return SetDouble(num, digits, TRUE); }

	// add color vector (in form (r,g,b,a))
	void AddColor(CColor* c);

	// get window text (returns FALSE on error)
	BOOL GetWindowText(const HWND wnd);

	// set window text
	void SetWindowText(const HWND wnd) const;

	// get dialog item text (returns FALSE on error)
	BOOL GetDialogText(const HWND wnd, int id);

	// set dialog item text
	void SetDialogText(const HWND wnd, int id) const;

	// format string (using printf() format, returns FALSE on error)
	//  "format" and destination CText cannot be the same!
	BOOL Format(LPCTSTR format, ...);
	BOOL Format(LPCTSTR format, va_list args);
	BOOL AddFormat(LPCTSTR format, ...);
	BOOL AddFormat(LPCTSTR format, va_list args);

	// convert text to INT/SHORT/CHAR number
	inline int Int() const { return ::Int(m_Data->data); }
	inline short Short() const { return (short)Int(); }
	inline char Char() const { return (char)Int(); }

	// convert text to HEX/WORD/BYTE number
	inline DWORD Hex() const { return ::Hex(m_Data->data); }
	inline WORD Word() const { return (WORD)Hex(); }
	inline BYTE Byte() const { return (BYTE)Hex(); }

	// convert text to DOUBLE/FLOAT number
	inline double Double() const { return ::Double(m_Data->data); };
	inline float Float() const { return (float)Double(); };

	// load/save file (returns FALSE on error)
	BOOL LoadFile(FILE* file, int size, FILECP cp = FILECP_ANSI);
	BOOL LoadFileName(LPCTSTR name, FILECP cp = FILECP_ANSI);
	BOOL SaveFile(FILE* file, FILECP cp = FILECP_ANSI) const;
	BOOL SaveFileName(LPCTSTR name, FILECP cp = FILECP_ANSI) const;

	// load text from resource
	void Load(int id);

	// load long text from resource, group "TEXT" (must be terminated with "<EOF>" string)
	void LoadLongText(LPCTSTR id);

	// get current directory
	void GetCurrentDir();

	// file name correction (returns new cursor position)
	int FileName(int curs);

	// path name correction (returns new cursor position)
	int PathName(int curs);

	// string correction (returns new cursor position)
	int StringCorr(int curs);

	// extract path
	CText ExtractPath() const;

	// add backslash on end of path
	void AddBackSlash();

	// delete backslash from end of path
	void DelBackSlash();

	// set operators
	const CText& operator= (const CText& txt);
	const CText& operator= (LPCTSTR txt);
#ifdef _UNICODE
	const CText& operator=(LPCSTR txt);
#else // _UNICODE
	const CText& operator=(LPCWSTR txt);
#endif // _UNICODE
	const CText& operator= (TCHAR chr);

	// add operators
	const CText& operator+= (CText txt);
	const CText& operator+= (LPCTSTR txt);
	const CText& operator+= (TCHAR chr);
	inline friend CText operator+ (const CText& txt1, const CText& txt2)
		{ return CText(txt1, txt2); }
	inline friend CText operator+ (LPCTSTR txt1, const CText& txt2)
		{ return CText(txt1, txt2); }
	inline friend CText operator+ (const CText& txt1, LPCTSTR txt2)
		{ return CText(txt1, txt2); }
	inline friend CText operator+ (TCHAR chr, const CText& txt)
		{ return CText(chr, txt); }
	inline friend CText operator+ (const CText& txt, TCHAR chr)
		{ return CText(txt, chr); }

	// compare operators
	friend BOOL operator== (const CText& txt1, const CText& txt2);
	friend BOOL operator== (LPCTSTR txt1, const CText& txt2);
	friend BOOL operator== (const CText& txt1, LPCTSTR txt2);
	friend BOOL operator== (TCHAR chr, const CText& txt);
	friend BOOL operator== (const CText& txt, TCHAR chr);
	friend BOOL operator!= (const CText& txt1, const CText& txt2);
	friend BOOL operator!= (LPCTSTR txt1, const CText& txt2);
	friend BOOL operator!= (const CText& txt1, LPCTSTR txt2);
	friend BOOL operator!= (TCHAR chr, const CText& txt);
	friend BOOL operator!= (const CText& txt, TCHAR chr);
	friend BOOL operator< (const CText& txt1, const CText& txt2);
	friend BOOL operator<= (const CText& txt1, const CText& txt2);
	friend BOOL operator> (const CText& txt1, const CText& txt2);
	friend BOOL operator>= (const CText& txt1, const CText& txt2);
};

extern CText EmptyText;

extern CText NewLine;

///////////////////////////////////////////////////////////////////////////////
// text string list

class CTextList : public CArray<CText>
{
public:

	// get text entry (with index checking)
	inline CText Get(int inx)
		{ if (IsValid(inx)) return m_List[inx]; else return EmptyText; }

	// set text entry (with index checking)
	inline void Set(int inx, const CText txt)
		{ if (IsValid(inx)) m_List[inx] = txt; }

	// split text string (destroys old content, returns FALSE on error)
	BOOL Split(const CText& text,LPCTSTR delim,int length=-1,int limit=BIGINT);
	BOOL Split(const CText& text, TCHAR delim = _T(' '), int limit = BIGINT);
	inline BOOL Split(const CText& text, const CText& delim, int limit=BIGINT)
		{ return Split(text, delim.DataData(), delim.Length(), limit); }
	BOOL SplitWords(const CText& text, int limit = BIGINT);
	BOOL SplitLines(const CText& text, int limit = BIGINT);

	// join text strings
	CText Join(LPCTSTR delim, int length = -1) const;
	CText Join(TCHAR delim = _T(' ')) const;
	CText JoinLines() const;
	inline CText Join(const CText& delim) const
		{ return Join(delim.DataData(), delim.Length()); }
};
