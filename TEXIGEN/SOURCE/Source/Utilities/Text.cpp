
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Text String                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// empty text string data
TEXTDATA EmptyTextData = { BIGINT, 0, 0 };
CText EmptyText;

// round coefficients, used in SetDouble function
double SetDoubleCoeff[19] = { 5e0, 5e-1, 5e-2, 5e-3, 5e-4, 5e-5, 5e-6, 5e-7,
	5e-8, 5e-9, 5e-10, 5e-11, 5e-12, 5e-13, 5e-14, 5e-15, 5e-16 };

CText NewLine(_T("\r\n"));

///////////////////////////////////////////////////////////////////////////////
// multithreaded LONG increment

void LongIncrement(long* num)
{
	::InterlockedIncrement(num);
}

///////////////////////////////////////////////////////////////////////////////
// multithreaded LONG decrement (returns previous state)

long LongDecrement(long* num)
{
	return (::InterlockedDecrement(num));
}

///////////////////////////////////////////////////////////////////////////////
// constructors

CText::CText(TCHAR chr)
{
	if (chr == 0)
		Attach(&EmptyTextData);
	else
	{
		if (NewBuffer(1)) m_Data->data[0] = chr;
	}
}

CText::CText(LPCTSTR txt, int length /* = -1 */)
{
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlen(txt);
	}
	if (NewBuffer(len)) memcpy(m_Data->data, txt, len*sizeof(TCHAR));
}

#ifdef _UNICODE

CText::CText(LPCSTR txt, int length /* = -1 */)
{
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlenA(txt);
	}
	if (NewBuffer(len))
		::MultiByteToWideChar(CP_ACP, 0, txt, len, m_Data->data, len + 1);
}

#else // _UNICODE

CText::CText(LPCWSTR txt, int length /* = -1 */)
{
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlenW(txt);
	}
	if (NewBuffer(len))
		::WideCharToMultiByte(CP_ACP,0,txt,len,m_Data->data,len+1,NULL,NULL);
}

#endif // _UNICODE

CText::CText(CText txt1, CText txt2)
{ 
	int len1 = txt1.m_Data->length;
	int len2 = txt2.m_Data->length;
	if (!NewBuffer(len1 + len2)) return;
	memcpy(m_Data->data, txt1.m_Data->data, len1*sizeof(TCHAR));
	memcpy(&m_Data->data[len1], txt2.m_Data->data, len2*sizeof(TCHAR));
}

CText::CText(LPCTSTR txt1, CText txt2)
{ 
	int len1 = 0;
	if (txt1) len1 = ::lstrlen(txt1);
	int len2 = txt2.m_Data->length;
	if (!NewBuffer(len1 + len2)) return;
	memcpy(m_Data->data, txt1, len1*sizeof(TCHAR));
	memcpy(&m_Data->data[len1], txt2.m_Data->data, len2*sizeof(TCHAR));
}

CText::CText(CText txt1, LPCTSTR txt2)
{ 
	int len1 = txt1.m_Data->length;
	int len2 = 0;
	if (txt2 != NULL) len2 = ::lstrlen(txt2);
	if (!NewBuffer(len1 + len2)) return;
	memcpy(m_Data->data, txt1.m_Data->data, len1*sizeof(TCHAR));
	memcpy(&m_Data->data[len1], txt2, len2*sizeof(TCHAR));
}

CText::CText(TCHAR chr, CText txt)
{ 
	int len = txt.m_Data->length;
	if (!NewBuffer(1 + len)) return;
	m_Data->data[0] = chr;
	memcpy(&m_Data->data[1], txt.m_Data->data, len*sizeof(TCHAR));
}

CText::CText(CText txt, TCHAR chr)
{ 
	int len = txt.m_Data->length;
	if (!NewBuffer(len + 1)) return;
	memcpy(m_Data->data, txt.m_Data->data, len*sizeof(TCHAR));
	m_Data->data[len] = chr;
}

///////////////////////////////////////////////////////////////////////////////
// attach text string data

void CText::Attach(TEXTDATA* data)
{
	m_Data = data;
	LongIncrement(&data->ref);
}

///////////////////////////////////////////////////////////////////////////////
// detach (and destroy) text string data

void CText::Detach()
{
	if (LongDecrement(&m_Data->ref) == 0) free(m_Data);
}

///////////////////////////////////////////////////////////////////////////////
// create new text data (old text data must be delete)
// (on error attaches empty text string data and returns FALSE)

BOOL CText::NewBuffer(int length)
{
	TEXTDATA* data = (TEXTDATA*)malloc(
			(length+1)*sizeof(TCHAR) + SIZEOFTEXTDATA);
	if (data == NULL)
	{
		Attach(&EmptyTextData);
		return FALSE;
	}
	m_Data = data;
	data->ref = 1;
	data->length = length;
	data->data[length] = 0;
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// resize data buffer (ref must be = 1, returns FALSE on error)

BOOL CText::SetSize(int length)
{
	TEXTDATA* data = (TEXTDATA*)realloc(m_Data,
					(length+1)*sizeof(TCHAR) + SIZEOFTEXTDATA);
	if (data == NULL) return FALSE;
	m_Data = data;
	data->length = length;
	data->data[length] = 0;
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// appropriate text string data before write (returns FALSE on error)

BOOL CText::CopyWrite()
{
	TEXTDATA* data = m_Data;
	if (data->ref > 1)
	{
		if (!NewBuffer(data->length)) return FALSE;
		memcpy(m_Data->data, data->data, data->length*sizeof(TCHAR));
		if (LongDecrement(&data->ref) == 0) free(data);
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set text length (returns FALSE on error)

BOOL CText::SetLength(int length)
{
	if (!CopyWrite()) return FALSE;
	return SetSize(length);
}

///////////////////////////////////////////////////////////////////////////////
// set character (with index checking, returns FALSE on error)

BOOL CText::SetAt(int inx, TCHAR chr)
{
	if (IsValid(inx) && (chr != 0))
	{
		if (!CopyWrite()) return FALSE;
		m_Data->data[inx] = chr;
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set text (returns FALSE on error)

void CText::Set(const CText& txt)
{
	DetachAttach(txt.m_Data);
}

BOOL CText::Set(LPCTSTR txt, int length /* = -1 */)
{
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlen(txt);
	}
	Detach();
	if (!NewBuffer(len)) return FALSE;
	memcpy(m_Data->data, txt, len*sizeof(TCHAR));
	return TRUE;
}

#ifdef _UNICODE

BOOL CText::Set(LPCSTR txt, int length /* = -1 */)
{
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlenA(txt);
	}
	Detach();
	if (!NewBuffer(len)) return FALSE;
	::MultiByteToWideChar(CP_ACP, 0, txt, len, m_Data->data, len + 1);
	return TRUE;
}

#else // _UNICODE

BOOL CText::Set(LPCWSTR txt, int length /* = -1 */)
{
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlenW(txt);
	}
	Detach();
	if (!NewBuffer(len)) return FALSE;
	::WideCharToMultiByte(CP_ACP,0,txt,len,m_Data->data,len+1,NULL,NULL);
	return TRUE;
}

#endif // _UNICODE

BOOL CText::Set(TCHAR chr)
{
	if (chr == 0)
		Empty();
	else
	{
		Detach();
		if (!NewBuffer(1)) return FALSE;
		m_Data->data[0] = chr;
	}
	return TRUE;
}

BOOL CText::Set(const char* buf, int size, FILECP cp)
{
	TEXTDATA* data = m_Data;
	if (size < 0) size = 0;

#ifdef _UNICODE
	if ((cp == FILECP_UTF16) || (size == 0))
	{
		size /= sizeof(TCHAR);
		if (!NewBuffer(size))
		{
			Detach();
			m_Data = data;
			return FALSE;
		}
		memcpy(m_Data->data, buf, size*2);
		if (LongDecrement(&data->ref) == 0) free(data);
		CheckNul();
	}
	else
	{
		DWORD cp2;
		switch (cp)
		{
		case FILECP_UTF7: cp2 = CP_UTF7; break;
		case FILECP_UTF8: cp2 = CP_UTF8; break;
		case FILECP_OEM: cp2 = CP_OEMCP; break;
		default: cp2 = CP_ACP;
		}

		int size2 = ::MultiByteToWideChar(cp2, 0, buf, size, NULL, 0);
		if (size2 > 0)
		{
			if (!NewBuffer(size2))
			{
				Detach();
				m_Data = data;
				return FALSE;
			}
			::MultiByteToWideChar(cp2, 0, buf, size, m_Data->data, m_Data->length+1);
			if (LongDecrement(&data->ref) == 0) free(data);
			CheckNul();
		}
	}
#else // _UNICODE
	if ((cp == FILECP_ANSI) || (size == 0))
	{
		if (!NewBuffer(size))
		{
			Detach();
			m_Data = data;
			return FALSE;
		}
		memcpy(m_Data->data, buf, size);
		if (LongDecrement(&data->ref) == 0) free(data);
		CheckNul();
	}
	else
	{
		if (cp == FILECP_UTF16)
		{
			if (!Set((wchar_t*)buf, size/2))
			{
				Detach();
				m_Data = data;
				return FALSE;
			}
		}
		else
		{
			DWORD cp2;
			switch (cp)
			{
			case FILECP_UTF7: cp2 = CP_UTF7; break;
			case FILECP_OEM: cp2 = CP_OEMCP; break;
			default: cp2 = CP_UTF8;
			}

			int size2 = ::MultiByteToWideChar(cp2, 0, buf, size, NULL, 0);
			if (size2 > 0)
			{
				wchar_t* buf2 = (wchar_t*)malloc((size2+1)*2);
				if (buf2 == NULL)
				{
					Detach();
					m_Data = data;
					return FALSE;
				}
				::MultiByteToWideChar(cp2, 0, buf, size, buf2, size2+1);
				if (!Set(buf2, size2))
				{
					free(buf2);
					Detach();
					m_Data = data;
					return FALSE;
				}
				free(buf2);
				if (LongDecrement(&data->ref) == 0) free(data);
				CheckNul();
			}
		}
	}
#endif // _UNICODE
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// add repeated text (returns FALSE on error)

BOOL CText::AddRep(int count, CText txt)
{
	if (count < 0) count = 0;
	int len1 = m_Data->length;
	int len2 = txt.m_Data->length;
	if (!SetLength(len1 + len2*count)) return FALSE;
	TCHAR* dst = &m_Data->data[len1];
	for (; count > 0; count--)
	{
		memcpy(dst, txt.m_Data->data, len2*sizeof(TCHAR));
		dst += len2;
	}
	return TRUE;
}

BOOL CText::AddRep(int count, LPCTSTR txt, int length /* = -1 */)
{
	if (count < 0) count = 0;
	int len2 = 0;
	if (txt != NULL)
	{
		len2 = length;
		if (len2 < 0) len2 = ::lstrlen(txt);
	}
	int len1 = m_Data->length;
	if (!SetLength(len1 + len2*count)) return FALSE;
	TCHAR* dst = &m_Data->data[len1];
	for (; count > 0; count--)
	{
		memcpy(dst, txt, len2*sizeof(TCHAR));
		dst += len2;
	}
	return TRUE;
}

#ifdef _UNICODE

BOOL CText::AddRep(int count, LPCSTR txt, int length /* = -1 */)
{
	if (count < 0) count = 0;
	int len2 = 0;
	if (txt != NULL)
	{
		len2 = length;
		if (len2 < 0) len2 = ::lstrlenA(txt);
	}
	int len1 = m_Data->length;
	if (!SetLength(len1 + len2*count)) return FALSE;
	TCHAR* dst = &m_Data->data[len1];
	for (; count > 0; count--)
	{
		::MultiByteToWideChar(CP_ACP, 0, txt, len2, dst, len2+1);
		dst += len2;
	}
	return TRUE;
}

#else // _UNICODE

BOOL CText::AddRep(int count, LPCWSTR txt, int length /* = -1 */)
{
	if (count < 0) count = 0;
	int len2 = 0;
	if (txt != NULL)
	{
		len2 = length;
		if (len2 < 0) len2 = ::lstrlenW(txt);
	}
	int len1 = m_Data->length;
	if (!SetLength(len1 + len2*count)) return FALSE;
	TCHAR* dst = &m_Data->data[len1];
	for (; count > 0; count--)
	{
		::WideCharToMultiByte(CP_ACP, 0, txt, len2, dst, len2+1, NULL, NULL);
		dst += len2;
	}
	return TRUE;
}

#endif // _UNICODE

BOOL CText::AddRep(int count, TCHAR chr)
{
	if (count < 0) count = 0;
	if (chr == 0) return TRUE;
	int len = m_Data->length;
	if (!SetLength(len + count)) return FALSE;
	TCHAR* dst = &m_Data->data[len];
	for (; count > 0; count--) *dst++ = chr;
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// write text into buffer (without terminating zero)

void CText::Write(TCHAR* buf, int maxlen /* = BIGINT */) const
{
	int len = m_Data->length;
	if (len > maxlen) len = maxlen;
	if (len > 0) memcpy(buf, m_Data->data, len*sizeof(TCHAR));
}

#ifdef _UNICODE

void CText::Write(LPSTR buf, int maxlen /* = BIGINT */) const
{
	int len = m_Data->length;
	if (len > maxlen) len = maxlen;
	if (len > 0) ::WideCharToMultiByte(CP_ACP, 0, m_Data->data,
												len, buf, len, NULL, NULL);
}

#else // _UNICODE

void CText::Write(LPWSTR buf, int maxlen /* = BIGINT */) const
{
	int len = m_Data->length;
	if (len > maxlen) len = maxlen;
	if (len > 0) ::MultiByteToWideChar(CP_ACP, 0, m_Data->data,len,buf,len);
}

#endif // _UNICODE

int CText::Write(char* buf, int bufsize, FILECP cp) const
{
	if (bufsize < 0) bufsize = 0;
	int size = m_Data->length;

#ifdef _UNICODE
	if ((cp == FILECP_UTF16) || (size == 0))
	{
		size *= sizeof(TCHAR);
		if (size > bufsize) size = bufsize & ~1;
		memcpy(buf, m_Data->data, size);
	}
	else
	{
		DWORD cp2;
		switch (cp)
		{
		case FILECP_UTF7: cp2 = CP_UTF7; break;
		case FILECP_UTF8: cp2 = CP_UTF8; break;
		case FILECP_OEM: cp2 = CP_OEMCP; break;
		default: cp2 = CP_ACP;
		}
		size = ::WideCharToMultiByte(cp2, 0, m_Data->data,
				m_Data->length, NULL, 0, NULL, NULL);
		if (size > bufsize) size = bufsize;
		if (size > 0)
		{
			size = ::WideCharToMultiByte(cp2, 0, m_Data->data,
					m_Data->length, buf, size, NULL, NULL);
		}
	}
#else // _UNICODE
	if ((cp == FILECP_ANSI) || (size == 0))
	{
		if (size > bufsize) size = bufsize;
		memcpy(buf, m_Data->data, size);
	}
	else
	{
		if (cp == FILECP_UTF16)
		{
			size *= 2;
			if (size > bufsize) size = bufsize & ~1;
			Write(buf, size/2);
		}
		else
		{
			wchar_t* buf2 = (wchar_t*)malloc(size*2);
			if (buf2 == NULL) return 0;
			Write(buf2, size);

			DWORD cp2;
			switch (cp)
			{
			case FILECP_UTF7: cp2 = CP_UTF7; break;
			case FILECP_OEM: cp2 = CP_OEMCP; break;
			default: cp2 = CP_UTF8;
			}
			int size2 = ::WideCharToMultiByte(cp2, 0, buf2,
					size, NULL, 0, NULL, NULL);
			if (size2 > 0)
			{
				size2 = ::WideCharToMultiByte(cp2, 0, buf2,
						size, buf, size2, NULL, NULL);
			}
			free(buf2);
			size = size2;
		}
	}

#endif // _UNICODE
	return size;
}

///////////////////////////////////////////////////////////////////////////////
// write text into buffer with terminating zero

void CText::WriteZ(TCHAR* buf, int maxlen /* = BIGINT */) const
{
	int len = m_Data->length + 1;
	if (len > maxlen) len = maxlen;
	if (len > 0)
	{
		len--;
		if (len > 0) memcpy(buf, m_Data->data, len*sizeof(TCHAR));
		buf[len] = 0;
	}
}

#ifdef _UNICODE

void CText::WriteZ(LPSTR buf, int maxlen /* = BIGINT */) const
{
	int len = m_Data->length + 1;
	if (len > maxlen) len = maxlen;
	if (len > 0)
	{
		len--;
		if (len > 0) ::WideCharToMultiByte(CP_ACP, 0, m_Data->data,
												len, buf, len, NULL, NULL);
		buf[len] = 0;
	}
}

#else // _UNICODE

void CText::WriteZ(LPWSTR buf, int maxlen /* = BIGINT */) const
{
	int len = m_Data->length + 1;
	if (len > maxlen) len = maxlen;
	if (len > 0)
	{
		len--;
		if (len > 0)
			::MultiByteToWideChar(CP_ACP, 0, m_Data->data, len, buf, len);
		buf[len] = 0;
	}
}

#endif // _UNICODE

///////////////////////////////////////////////////////////////////////////////
// find character (-1 = not found) (warning, use _T('x') instead of (TCHAR)'x')

int CText::Find(TCHAR chr, int pos /*= 0*/) const
{
	if (pos < 0) pos = 0;
	int i = m_Data->length - pos;
	const TCHAR* data = &m_Data->data[pos];
	for (; i > 0; i--)
	{
		if (*data == chr) return (int)(data - m_Data->data);
		data++;
	}
	return -1;
}

int CText::FindRev(TCHAR chr, int pos /*= BIGINT*/) const
{
	if (pos >= m_Data->length) pos = m_Data->length-1;
	const TCHAR* data = &m_Data->data[pos];
	for (; pos >= 0; pos--)
	{
		if (*data == chr) return pos;
		data--;
	}
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// find white space character (space, tab, newline, -1 = not found)

int CText::FindSpace(int pos /*= 0*/) const
{
	if (pos < 0) pos = 0;
	int i = m_Data->length - pos;
	const TCHAR* data = &m_Data->data[pos];
	for (; i > 0; i--)
	{
		if ((DWORD)*data <= (DWORD)32) return (int)(data - m_Data->data);
		data++;
	}
	return -1;
}

int CText::FindSpaceRev(int pos /*= BIGINT*/) const
{
	if (pos >= m_Data->length) pos = m_Data->length-1;
	const TCHAR* data = &m_Data->data[pos];
	for (; pos > 0; pos--)
	{
		if ((DWORD)*data <= (DWORD)32) return pos;
		data--;
	}
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// find non white space character (no space, tab, newline, -1 = not found)

int CText::FindNSpace(int pos /*= 0*/) const
{
	if (pos < 0) pos = 0;
	int i = m_Data->length - pos;
	const TCHAR* data = &m_Data->data[pos];
	for (; i > 0; i--)
	{
		if ((DWORD)*data > (DWORD)32) return (int)(data - m_Data->data);
		data++;
	}
	return -1;
}

int CText::FindNSpaceRev(int pos /*= BIGINT*/) const
{
	if (pos >= m_Data->length) pos = m_Data->length-1;
	const TCHAR* data = &m_Data->data[pos];
	for (; pos > 0; pos--)
	{
		if ((DWORD)*data > (DWORD)32) return pos;
		data--;
	}
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// find text (-1 = not found)

int CText::Find(const CText& txt, int pos /*= 0*/) const
{
	// limit start position
	if (pos < 0) pos = 0;
	int i = m_Data->length;
	if (pos > i) return -1;

	// empty text
	int len = txt.m_Data->length;
	if (len == 0) return pos;

	// one-character text
	const TCHAR* fnd = txt.m_Data->data;
	TCHAR chr = *fnd;
	if (len == 1) return Find(chr, pos);

	// find string
	fnd++;
	len--;
	const TCHAR* data = &m_Data->data[pos];
	i = i - pos - len;
	for (; i >= 0; i--)
	{
		if (*data++ == chr)
		{
			if (memcmp(data, fnd, len*sizeof(TCHAR)) == 0)
				return (int)(data - m_Data->data - 1);
		}
	}
	return -1;
}

int CText::FindRev(const CText& txt, int pos /*= BIGINT*/) const
{
	// limit start position
	int len = txt.m_Data->length;
	if (pos > m_Data->length - len) pos = m_Data->length - len;
	if (pos < 0) return -1;

	// empty text
	if (len == 0) return pos;

	// one-character text
	const TCHAR* fnd = txt.m_Data->data;
	TCHAR chr = *fnd;
	if (len == 1) return FindRev(chr, pos);

	// find string
	fnd++;
	len--;
	const TCHAR* data = &m_Data->data[pos];
	for (; pos >= 0; pos--)
	{
		if (*data == chr)
		{
			if (memcmp(&data[1], fnd, len*sizeof(TCHAR)) == 0)
				return pos;
		}
		data--;
	}
	return -1;
}

int CText::Find(LPCTSTR txt, int length /*= -1*/, int pos /*= 0*/) const
{
	// limit start position
	if (pos < 0) pos = 0;
	int i = m_Data->length;
	if (pos > i) return -1;

	// get text length
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlen(txt);
	}

	// empty text
	if (len == 0) return pos;

	// one-character text
	const TCHAR* fnd = txt;
	TCHAR chr = *fnd;
	if (len == 1) return Find(chr, pos);

	// find string
	fnd++;
	len--;
	const TCHAR* data = &m_Data->data[pos];
	i = i - pos - len;
	for (; i >= 0; i--)
	{
		if (*data++ == chr)
		{
			if (memcmp(data, fnd, len*sizeof(TCHAR)) == 0)
				return (int)(data - m_Data->data - 1);
		}
	}
	return -1;
}

int CText::FindRev(LPCTSTR txt, int length /*= -1*/, int pos /*=BIGINT*/) const
{
	// get text length
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlen(txt);
	}

	// limit start position
	if (pos > m_Data->length - len) pos = m_Data->length - len;
	if (pos < 0) return -1;

	// empty text
	if (len == 0) return pos;

	// one-character text
	const TCHAR* fnd = txt;
	TCHAR chr = *fnd;
	if (len == 1) return FindRev(chr, pos);

	// find string
	fnd++;
	len--;
	const TCHAR* data = &m_Data->data[pos];
	for (; pos >= 0; pos--)
	{
		if (*data == chr)
		{
			if (memcmp(&data[1], fnd, len*sizeof(TCHAR)) == 0)
				return pos;
		}
		data--;
	}
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// find characters from the list (-1 = not found)

int CText::FindList(LPCTSTR list, int count /*= -1*/, int pos /*= 0*/) const
{
	// limit start position
	if (pos < 0) pos = 0;
	int len = m_Data->length;
	if (pos >= len) return -1;

	// prepare number of characters
	if (list == NULL) count = 0;
	if (count < 0) count = ::lstrlen(list);
	if (count == 0) return -1;
	count--;

	// find character
	TCHAR chr;
	int i;
	for (len -= pos; len > 0; len--)
	{
		chr = m_Data->data[pos];
		for (i = count; i >= 0; i--) if (chr == list[i]) return pos;
		pos++;
	}
	return -1;
}

int CText::FindListRev(LPCTSTR list,int count/*=-1*/,int pos/*=BIGINT*/) const
{
	// limit start position
	int len = m_Data->length;
	if (pos >= len) pos = len-1;
	if (pos < 0) return -1;

	// prepare number of characters
	if (list == NULL) count = 0;
	if (count < 0) count = ::lstrlen(list);
	if (count == 0) return -1;
	count--;

	// find character
	TCHAR chr;
	int i;
	for (; pos >= 0; pos--)
	{
		chr = m_Data->data[pos];
		for (i = count; i >= 0; i--) if (chr == list[i]) return pos;
	}
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// find characters except the list (-1 = not found)

int CText::FindExcept(LPCTSTR list, int count /*= -1*/, int pos /*= 0*/) const
{
	// limit start position
	if (pos < 0) pos = 0;
	int len = m_Data->length;
	if (pos >= len) return -1;

	// prepare number of characters
	if (list == NULL) count = 0;
	if (count < 0) count = ::lstrlen(list);
	if (count == 0) return pos;
	count--;

	// find character
	TCHAR chr;
	int i;
	BOOL ok;
	for (len -= pos; len > 0; len--)
	{
		chr = m_Data->data[pos];
		ok = TRUE;
		for (i = count; i >= 0; i--)
			if (chr == list[i])
			{
				ok=FALSE;
				break;
			}
		if (ok) return pos;
		pos++;
	}
	return -1;
}

int CText::FindExceptRev(LPCTSTR list,int count/*=-1*/,int pos/*=BIGINT*/)const
{
	// limit start position
	int len = m_Data->length;
	if (pos >= len) pos = len-1;
	if (pos < 0) return -1;

	// prepare number of characters
	if (list == NULL) count = 0;
	if (count < 0) count = ::lstrlen(list);
	if (count == 0) return pos;
	count--;

	// find character
	TCHAR chr;
	int i;
	BOOL ok;
	for (; pos >= 0; pos--)
	{
		chr = m_Data->data[pos];
		ok = TRUE;
		for (i = count; i >= 0; i--)
			if (chr == list[i])
			{
				ok=FALSE;
				break;
			}
		if (ok) return pos;
	}
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// substitute strings (returns FALSE on error)

BOOL CText::Subst(CText txt, CText subst)
{
	int pos = 0;
	int len;
	int txtlen = txt.m_Data->length;
	int substlen = subst.m_Data->length;
	for (;;)
	{
		// find text
		pos = Find(txt, pos);
		if (pos < 0) break;

		// copy buffer before write
		if (!CopyWrite()) return FALSE;

		// increase buffer size
		len = m_Data->length;
		if (substlen > txtlen)
			if (!SetSize(len - txtlen + substlen)) return FALSE;

		// move second part of the text
		if (substlen != txtlen)
			memmove(&m_Data->data[pos + substlen], &m_Data->data[pos + txtlen],
				(len - pos - txtlen)*sizeof(TCHAR));

		// copy substituted text
		memcpy(&m_Data->data[pos], subst.m_Data->data, substlen*sizeof(TCHAR));

		// decrease buffer size
		if (substlen < txtlen)
			if (!SetSize(len - txtlen + substlen)) return FALSE;

		// shift current position
		pos += substlen;
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// substitute characters from the list (returns FALSE on error)

BOOL CText::SubstList(LPCTSTR list, LPCTSTR subst, int count /*= -1*/)
{
	// prepare number of characters
	int count2 = count;
	if (list == NULL) count = 0;
	if (count < 0) count = ::lstrlen(list);
	if (subst == NULL) count2 = 0;
	if (count2 < 0) count2 = ::lstrlen(subst);
	if (count != count2) return FALSE;
	if (count == 0) return TRUE;

	// copy before write
	if (!CopyWrite()) return FALSE;

	// replace characters
	int len = m_Data->length;
	TCHAR* data = m_Data->data;
	TCHAR chr;
	int i;
	for (; len > 0; len--)
	{
		chr = *data;
		for (i = 0; i < count; i++)
		{
			if (chr == list[i])
			{
				*data = subst[i];
				break;
			}
		}
		data++;
	}
	return TRUE;
}

BOOL CText::SubstList(CText list, CText subst)
{
	int count = list.m_Data->length;
	if (count != subst.m_Data->length) return FALSE;
	return SubstList(list.m_Data->data, subst.m_Data->data, count);
}

///////////////////////////////////////////////////////////////////////////////
// convert text to uppercase (returns FALSE on error)

BOOL CText::UpperCase()
{
	if (!CopyWrite()) return FALSE;
	::CharUpperBuff(m_Data->data, m_Data->length);
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// convert text to lowercase (returns FALSE on error)

BOOL CText::LowerCase()
{
	if (!CopyWrite()) return FALSE;
	::CharLowerBuff(m_Data->data, m_Data->length);
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// left part of text (returns empty string on error)

CText CText::Left(int len) const
{
	if (len < 0) len = 0;
	int n = m_Data->length;
	if (len > n) len = n;
	return CText(m_Data->data, len);
}

///////////////////////////////////////////////////////////////////////////////
// right part of text (returns empty string on error)

CText CText::Right(int len) const
{
	if (len < 0) len = 0;
	int n = m_Data->length;
	if (len > n) len = n;
	return CText(&m_Data->data[n-len], len);
}

CText CText::RightFrom(int pos) const
{
	if (pos < 0) pos = 0;
	int n = m_Data->length;
	if (pos > n) pos = n;
	return CText(&m_Data->data[pos], n - pos);
}

///////////////////////////////////////////////////////////////////////////////
// middle part of text (returns empty string on error)

CText CText::Mid(int pos, int len) const
{
	if (pos < 0) pos = 0;
	int n = m_Data->length;
	if (pos > n) pos = n;
	if (len < 0) len = 0;
	if ((DWORD)(pos+len) > (DWORD)n) len = n - pos;
	return CText(&m_Data->data[pos], len);
}

///////////////////////////////////////////////////////////////////////////////
// insert text (returns FALSE on error)

BOOL CText::Insert(int pos, LPCTSTR txt, int length /*= -1*/)
{
	// prepare text length
	int len = 0;
	if (txt != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlen(txt);
	}

	// limit position
	if (pos < 0) pos = 0;
	int len0 = m_Data->length;
	if (pos > len0) pos = len0;

	// insert text
	if (!SetLength(len0 + len)) return FALSE;
	memmove(&m_Data->data[pos + len], &m_Data->data[pos],
									(len0 - pos)*sizeof(TCHAR));
	memcpy(&m_Data->data[pos], txt, len*sizeof(TCHAR));
	return TRUE;
}

BOOL CText::Insert(int pos, TCHAR chr)
{
	if (chr == 0) return TRUE;

	// limit position
	if (pos < 0) pos = 0;
	int len = m_Data->length;
	if (pos > len) pos = len;

	// insert text
	if (!SetLength(len + 1)) return FALSE;
	memmove(&m_Data->data[pos + 1], &m_Data->data[pos],
									(len - pos)*sizeof(TCHAR));
	m_Data->data[pos] = chr;
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// delete characters (returns FALSE on error)

BOOL CText::Delete(int pos, int count /*= 1*/)
{
	// limit position
	if (pos < 0) pos = 0;
	int len = m_Data->length;
	if (pos > len) pos = len;

	// limit length
	if (count < 0) count = 0;
	if (count > len) count = len;
	if ((pos + count) > len) count = len - pos;

	// delete characters
	if (count > 0)
	{
		if (!CopyWrite()) return FALSE;
		memcpy(&m_Data->data[pos], &m_Data->data[pos + count],
				(len - pos - count)*sizeof(TCHAR));
		return SetLength(len - count);
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// delete characters from the list (returns FALSE on error)

BOOL CText::DelList(LPCTSTR list, int count /*= -1*/)
{
	// prepare number of characters
	if (list == NULL) count = 0;
	if (count < 0) count = ::lstrlen(list);
	if (count == 0) return TRUE;
	count--;

	// empty string
	int len = m_Data->length;
	if (len == 0) return TRUE;

	// copy before write
	if (!CopyWrite()) return FALSE;

	// delete characters
	TCHAR* dst = m_Data->data;
	TCHAR* src = dst;
	TCHAR chr;
	BOOL ok;
	int i;
	for (; len > 0; len--)
	{
		chr = *src++;
		ok = TRUE;
		for (i = count; i >= 0; i--)
			if (chr == list[i])
			{
				ok = FALSE;
				break;
			}
		if (ok) *dst++ = chr;
	}

	// resize buffer
	if (src != dst) return SetLength((int)(dst - m_Data->data));
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// delete characters except the list (returns FALSE on error)

BOOL CText::DelExcept(LPCTSTR list, int count /*= -1*/)
{
	// prepare number of characters
	if (list == NULL) count = 0;
	if (count < 0) count = ::lstrlen(list);
	if (count == 0)
	{
		Empty();
		return TRUE;
	}
	count--;

	// empty string
	int len = m_Data->length;
	if (len == 0) return TRUE;

	// copy before write
	if (!CopyWrite()) return FALSE;

	// delete characters
	TCHAR* dst = m_Data->data;
	TCHAR* src = dst;
	TCHAR chr;
	int i;
	for (; len > 0; len--)
	{
		chr = *src++;
		for (i = count; i >= 0; i--)
			if (chr == list[i])
			{
				*dst++ = chr;
				break;
			}
	}

	// resize buffer
	if (src != dst) return SetLength((int)(dst - m_Data->data));
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// find and delete all words (return FALSE on error)

BOOL CText::DelWord(LPCTSTR txt, int length /*= -1*/)
{
	// prepare text length
	if (txt == NULL) length = 0;
	if (length < 0) length = ::lstrlen(txt);
	if (length == 0) return TRUE;

	// find and delete words
	int pos = 0;
	for (;;)
	{
		pos = Find(txt, length, pos);
		if (pos < 0) break;
		if (!Delete(pos, length)) return FALSE;
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// trim white spaces from the string (returns FALSE on error)

BOOL CText::TrimLeft()
{
	// find start of text
	TCHAR* d = m_Data->data;
	TCHAR chr = *d++;
	while ((chr != 0) && ((DWORD)chr <= (DWORD)' ')) chr = *d++;

	// delete white spaces
	int len = (int)(d - m_Data->data - 1);
	if (len > 0)
	{
		if (!CopyWrite()) return FALSE;
		int n = m_Data->length;
		memmove(m_Data->data, &m_Data->data[len], (n - len)*sizeof(TCHAR));
		return SetLength(n - len);
	}
	return TRUE;
}

BOOL CText::TrimRight()
{
	// find end of text
	int n = m_Data->length;
	TCHAR* d = &m_Data->data[n];
	for (; n > 0; n--)
	{
		d--;
		if ((DWORD)*d > (DWORD)' ') break;
	}

	// set new text length
	if (n != m_Data->length) return SetLength(n);
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// nul correction (check and truncate text on NUL character)

void CText::CheckNul()
{
	int len = ::lstrlen(m_Data->data);
	if ((len < m_Data->length) && (len >= 0))
	{
		m_Data->length = len;
		m_Data->data[len] = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// get number of rows using CR/LF

int CText::RowsNum() const
{
	TCHAR* data = m_Data->data;

	// add last row without CR/LF
	int len = m_Data->length;
	int rows = 0;
	if (((len >= 2) && ((data[len-2] != 13) || (data[len-1] != 10))) ||
		(len == 1)) rows = 1;

	// calculate number of rows
	TCHAR chr;
	for (len--; len > 0; len--)
	{
		chr = *data++;
		if ((chr == 13) && (*data == 10)) rows++;
	}
	return rows;
}

///////////////////////////////////////////////////////////////////////////////
// get number of rows using LF

int CText::RowsNumLF() const
{
	TCHAR* data = m_Data->data;

	// add last row without LF
	int len = m_Data->length;
	int rows = 0;
	if ((len >= 1) && (data[len - 1] != 10)) rows = 1;

	// calculate number of lines
	for (; len > 0; len--)
	{
		if (*data++ == 10) rows++;
	}
	return rows;
}

///////////////////////////////////////////////////////////////////////////////
// get one row using CR/LF

CText CText::Row(int row) const
{
	int len = m_Data->length;
	int start = 0;
	int next = 0;
	TCHAR* data = m_Data->data;
	for (; next < len; next++)
	{
		if ((*data == 13) && (next < len-1) && (data[1] == 10))
		{
			row--;
			if (row < 0) break;
			next++;
			data++;
			start = next + 1;
		}
		data++;
	}
	if (row > 0) start = next;
	return Mid(start, next-start);
}

///////////////////////////////////////////////////////////////////////////////
// get one row using LF, trim CR

CText CText::RowLF(int row) const
{
	int len = m_Data->length;
	int start = 0;
	int next = 0;
	TCHAR* data = m_Data->data;
	for (; next < len; next++)
	{
		if (*data == 10)
		{
			row--;
			if (row < 0) break;
			start = next + 1;
		}
		data++;
	}
	if (row > 0) start = next;
	while ((start < next) && (m_Data->data[start] == 13)) start++;
	while ((next > start) && (m_Data->data[next-1] == 13)) next--;
	return Mid(start, next-start);
}

///////////////////////////////////////////////////////////////////////////////
// convert INT number to text (returns FALSE on error)

BOOL CText::SetInt(int num, BOOL add /*= FALSE*/)
{
	// prepare temporary buffer
	TCHAR buf[16];
	TCHAR* dst = buf+16;
	int len = 0;
	DWORD n = num;

	// prepare sign
	BOOL sign = FALSE;
	if (num < 0)
	{
		sign = TRUE;
		n = -num;
	}

	// convert digits
	do {
		dst--;
		*dst = (TCHAR)((n % 10) + '0');
		n /= 10;
		len++;
	} while (n != 0);

	// store sign
	if (sign)
	{
		dst--;
		*dst = _T('-');
		len++;
	}

	// copy number into buffer
	int len0;
	if (add)
	{
		len0 = m_Data->length;
		if (!SetLength(len0 + len)) return FALSE;
	}
	else
	{
		len0 = 0;
		Detach();
		if (!NewBuffer(len)) return FALSE;
	}
	memcpy(&m_Data->data[len0], dst, len*sizeof(TCHAR));
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set 2 digits (returns FALSE on error)

BOOL CText::Set2Dig(int num, BOOL add /*= FALSE*/)
{
	if (num < 0) num = 0;
	if (num > 99) num = 99;
	int len;
	if (add)
	{
		len = m_Data->length;
		if (!SetLength(len + 2)) return FALSE;
	}
	else
	{
		len = 0;
		Detach();
		if (!NewBuffer(2)) return FALSE;
	}
	m_Data->data[len] = (TCHAR)(num/10 + '0');
	m_Data->data[len+1] = (TCHAR)(num % 10 + '0');
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set 2 digits with space padding (returns FALSE on error)

BOOL CText::Set2DigSpc(int num, BOOL add /*= FALSE*/)
{
	if (num < 0) num = 0;
	if (num > 99) num = 99;
	int len;
	if (add)
	{
		len = m_Data->length;
		if (!SetLength(len + 2)) return FALSE;
	}
	else
	{
		len = 0;
		Detach();
		if (!NewBuffer(2)) return FALSE;
	}
	m_Data->data[len] = (num < 10) ? _T(' ') : (TCHAR)(num/10 + '0');
	m_Data->data[len+1] = (TCHAR)(num % 10 + '0');
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set 4 digits (returns FALSE on error)

BOOL CText::Set4Dig(int num, BOOL add /*= FALSE*/)
{
	if (num < 0) num = 0;
	if (num > 9999) num = 9999;
	int len;
	if (add)
	{
		len = m_Data->length;
		if (!SetLength(len + 4)) return FALSE;
	}
	else
	{
		len = 0;
		Detach();
		if (!NewBuffer(4)) return FALSE;
	}
	int n = num/100;
	m_Data->data[len] = (TCHAR)(n/10 + '0');
	m_Data->data[len+1] = (TCHAR)(n % 10 + '0');
	n = num % 100;
	m_Data->data[len+2] = (TCHAR)(n/10 + '0');
	m_Data->data[len+3] = (TCHAR)(n % 10 + '0');
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set time in long format h:mm:ss (value is in seconds)

void CText::SetTime(int sec, BOOL add /*= FALSE*/)
{
	if (!add) Empty();
	int min = sec / 60;
	sec -= min*60;
	int hour = min / 60;
	min -= hour*60;
	this->AddInt(hour);
	this->Add(TCHAR(':'));
	this->Add2Dig(min);
	this->Add(TCHAR(':'));
	this->Add2Dig(sec);
}

///////////////////////////////////////////////////////////////////////////////
// convert DWORD number to text as HEX (return FALSE on error)

BOOL CText::SetHex(DWORD num, int digits /*= -1*/, BOOL add /*= FALSE*/)
{
	// prepare number of digits
	if (digits < 0)
	{
		if (num <= 0xffff)
			if (num <= 0xff)
				if (num <= 0xf) digits = 1; else digits = 2;
			else
				if (num <= 0xfff) digits = 3; else digits = 4;
		else
			if (num <= 0xffffff)
				if (num <= 0xfffff) digits = 5; else digits = 6;
			else
				if (num <= 0xfffffff) digits = 7; else digits = 8;
	}
	if (digits > 8) digits = 8;

	// prepare buffer
	if (add)
	{
		if (!SetLength(m_Data->length + digits)) return FALSE;
	}
	else
	{
		Detach();
		if (!NewBuffer(digits)) return FALSE;
	}

	// decode digits
	TCHAR* dst = &m_Data->data[m_Data->length];
	TCHAR chr;
	for (; digits > 0; digits--)
	{
		dst--;
		chr = (TCHAR)(num & 0xf);
		*dst = (TCHAR)((chr <= 9) ? (chr + '0') : (chr - 10 + 'A'));
		num >>= 4;
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// convert DOUBLE number to text (returns FALSE on error)

BOOL CText::SetDouble(double num, int digits /*= 15*/, BOOL add /*= FALSE*/)
{
	// limit number of digits
	if (digits < 1) digits = 1;
	if (digits > 16) digits = 16;

	// overflow
	if (((WORD*)&num)[3] == 0x7ff0) return Add(_T("1#INF"), 5);

	// zero
	if (num == 0) return Add(TCHAR('0'));

	// prepare sign
	BOOL sign = FALSE;
	if (num < 0)
	{
		sign = TRUE;
		num = -num;
	}

	// split number to exponent and mantissa
	int expI = 0;
	double mantD = num;
	if (mantD >= 1)
	{
		if (mantD >= 1e256) { mantD *= 1e-256; expI += 256; };
		if (mantD >= 1e128) { mantD *= 1e-128; expI += 128; };
		if (mantD >= 1e64)  { mantD *= 1e-64;  expI += 64;  };
		if (mantD >= 1e32)  { mantD *= 1e-32;  expI += 32;  };
		if (mantD >= 1e16)  { mantD *= 1e-16;  expI += 16;  };
		if (mantD >= 1e8)   { mantD *= 1e-8;   expI += 8;   };
		if (mantD >= 1e4)   { mantD *= 1e-4;   expI += 4;   };
		if (mantD >= 1e2)   { mantD *= 1e-2;   expI += 2;   };
		if (mantD >= 1e1)   { mantD *= 1e-1;   expI += 1;   };
	}
	else
	{
		if (mantD < 1e-256) { mantD *= 1e257;  expI -= 257; };
		if (mantD < 1e-128) { mantD *= 1e129;  expI -= 129; };
		if (mantD < 1e-64)  { mantD *= 1e65;   expI -= 65;  };
		if (mantD < 1e-32)  { mantD *= 1e33;   expI -= 33;  };
		if (mantD < 1e-16)  { mantD *= 1e17;   expI -= 17;  };
		if (mantD < 1e-8)   { mantD *= 1e9;    expI -= 9;   };
		if (mantD < 1e-4)   { mantD *= 1e5;    expI -= 5;   };
		if (mantD < 1e-2)   { mantD *= 1e3;    expI -= 3;   };
		if (mantD < 1e-1)   { mantD *= 1e2;    expI -= 2;   };
		if (mantD < 1e0)    { mantD *= 1e1;    expI -= 1;   };
	}

	// round last digit
	mantD += SetDoubleCoeff[digits];

	// mantissa correction
	mantD *= 1e7;
	if (mantD >= 1e8)
	{
		mantD /= 10;
		expI++;
	}

	// split mantissa to LOW and HIGH part
	int mantH = (int)(mantD);
	int mantL = (int)((mantD - mantH)*1e8);

	// decode mantissa (LOW and HIGH part)
	int i;
	TCHAR mantT[16];
	TCHAR* mantP = mantT + 16;

	for (i = 8; i > 0; i--)
	{
		mantP--;
		*mantP = (TCHAR)((mantL % 10) + '0');
		mantL /= 10;
	}

	for (i = 8; i > 0; i--)
	{
		mantP--;
		*mantP = (TCHAR)((mantH % 10) + '0');
		mantH /= 10;
	}

	// get number of significant digits
	TCHAR* dst = mantT + digits;
	int dig = digits;
	for (; dig > 1; dig--)
	{
		dst--;
		if (*dst != _T('0')) break;
	}

	// prepare sign
	TCHAR buf[30];
	dst = buf;
	if (sign)
	{
		*dst = '-';
		dst++;
	}

	// decode number without exponent, number >= 1
	if ((expI < digits) && (expI >= 0))
	{
		for (;;)
		{
			*dst++ = *mantP++;
			dig--;
			if ((expI <= 0) && (dig <= 0)) break;
			if (expI == 0) *dst++ = _T('.');
			expI--;
		}
	}

	// decode number without exponent, number < 1
	else
		if ((expI < 0) && (expI >= -3))
		{
			*dst++ = _T('0');
			*dst++ = _T('.');
			expI++;
			for (; expI < 0; expI++) *dst++ = _T('0');
			for (; dig > 0; dig--) *dst++ = *mantP++;
		}

		// decode number with exponent
		else
		{
			*dst++ = *mantP++;
			dig--;
			if (dig > 0)
			{
				*dst++ = _T('.');
				for (; dig > 0; dig--) *dst++ = *mantP++;
			}

			*dst++ = _T('e');
			if (expI < 0)
			{
				*dst++ = _T('-');
				expI = -expI;
			}

			if (expI > 99)
			{
				*dst++ = (TCHAR)(expI/100 + '0');
				expI = expI % 100;

				*dst++ = (TCHAR)(expI/10 + '0');
				expI = expI % 10;
			}
			else
				if (expI > 9)
				{
					*dst++ = (TCHAR)(expI/10 + '0');
					expI = expI % 10;
				}
			
			*dst++ = (TCHAR)(expI + '0');
		}

	// save number into buffer
	int len = (int)(dst - buf);
	int len0;
	if (add)
	{
		len0 = m_Data->length;
		if (!SetLength(len0 + len)) return FALSE;
	}
	else
	{
		len0 = 0;
		Detach();
		if (!NewBuffer(len)) return FALSE;
	}
	memcpy(&m_Data->data[len0], buf, len*sizeof(TCHAR));
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// add color vector (in form (r,g,b,a))

void CText::AddColor(CColor* c)
{
	*this += TCHAR('(');
	this->AddDouble(c->r*255);
	*this += TCHAR(',');
	this->AddDouble(c->g*255);
	*this += TCHAR(',');
	this->AddDouble(c->b*255);
	*this += TCHAR(',');
	this->AddDouble(c->a*255);
	*this += TCHAR(')');
}

///////////////////////////////////////////////////////////////////////////////
// get window text (returns FALSE on error)

BOOL CText::GetWindowText(const HWND wnd)
{
	Detach();
	if (!NewBuffer(::GetWindowTextLength(wnd))) return FALSE;
	::GetWindowText(wnd, m_Data->data, m_Data->length+1);
	return TRUE;
}


///////////////////////////////////////////////////////////////////////////////
// set window text

void CText::SetWindowText(const HWND wnd) const
{
	::SetWindowText(wnd, m_Data->data);
}

///////////////////////////////////////////////////////////////////////////////
// get dialog item text (returns FALSE on error)

BOOL CText::GetDialogText(const HWND wnd, int id)
{
	HWND item = ::GetDlgItem(wnd, id);
	if (item)
	{
		Detach();
		if (!NewBuffer(::GetWindowTextLength(item))) return FALSE;
		::GetWindowText(item, m_Data->data, m_Data->length+1);
	}
	else
		Empty();
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set dialog item text

void CText::SetDialogText(const HWND wnd, int id) const
{
	HWND item = ::GetDlgItem(wnd, id);
	if (item) ::SetWindowText(item, m_Data->data);
}

///////////////////////////////////////////////////////////////////////////////
// format string (using printf() format, returns FALSE on error)

BOOL CText::Format(LPCTSTR format, ...)
{
	va_list args;
	va_start(args, format);
	return Format(format, args);
}

BOOL CText::Format(LPCTSTR format, va_list args)
{
	int len = _vsctprintf(format, args);
	Detach();
	if (!NewBuffer(len)) return FALSE;
	_vstprintf(m_Data->data, format, args);
	return TRUE;
}

BOOL CText::AddFormat(LPCTSTR format, ...)
{
	va_list args;
	va_start(args, format);
	return AddFormat(format, args);
}

BOOL CText::AddFormat(LPCTSTR format, va_list args)
{
	int len = _vsctprintf(format, args);
	int len0 = m_Data->length;
	if (!SetLength(len0+len)) return FALSE;
	_vstprintf(&m_Data->data[len0], format, args);
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// convert text to INT number

int Int(LPCTSTR text)
{
	// get sign and skip spaces
	BOOL sign = FALSE;
	TCHAR chr = *text++;
	for (;;)
	{
		if (chr == _T('-'))
			sign = !sign;
		else
			if ((chr != _T('+')) && (chr != _T(' ')) && (chr != 9)) break;
		chr = *text++;
	}

	// load digits
	DWORD res = 0;
	while ((chr >= _T('0')) && (chr <= _T('9')))
	{
		res *= 10;
		res += (DWORD)(chr - _T('0'));
		if (res > 0x80000000) res = 0x80000000;
		chr = *text++;
	}

	// negative result
	if (sign) return -(int)res;
	if (res == 0x80000000) return 0x7fffffff;
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// convert text to HEX number

DWORD Hex(LPCTSTR text)
{
	// skip spaces
	TCHAR chr = *text++;
	while ((chr == _T(' ')) || (chr == 9)) chr = *text++;

	// load digits
	DWORD res = 0;
	int ch;
	for (;;)
	{
		// convert to upper case letter
		if ((chr >= 'a') && (chr <= 'f')) chr -= 'a' - 'A';

		// invalid character
		if (((chr < '0') || (chr > '9')) &&
			((chr < 'A') || (chr > 'F'))) break;

		if (res > 0xfffffff)
		{
			res = 0xffffffff;
			break;
		}
		else
		{
			ch = chr - '0';
			if (ch >= 10) ch -= 7;
			res *= 16;
			res += ch;
		}
		chr = *text++;
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// convert text to DOUBLE number

double Double(LPCTSTR text)
{
	// get sign and skip spaces
	BOOL sign = FALSE;
	TCHAR chr = *text++;
	for (;;)
	{
		if (chr == _T('-'))
			sign = !sign;
		else
			if ((chr != _T('+')) && (chr != _T(' ')) && (chr != 9)) break;
		chr = *text++;
	}

	// load digits of integer part
	double res = 0;
	while ((chr >= _T('0')) && (chr <= _T('9')))
	{
		res *= 10;
		res += chr - '0';
		chr = *text++;
	}

	// load digits of fractional part
	double frac = 1;
	if ((chr == _T('.')) || (chr == _T(',')))
	{
		chr = *text++;
		while ((chr >= _T('0')) && (chr <= _T('9')))
		{
			frac *= 10;
			res += (chr - '0')/frac;
			chr = *text++;
		}
	}

	// skip spaces
	while ((chr == _T(' ')) || (chr == 9)) chr = *text++;

	// check exponent
	int expN = 0;
	BOOL signE = FALSE;
	if ((chr == _T('E')) || (chr == _T('e')))
	{
		chr = *text++;

		// get sign and skip spaces
		for (;;)
		{
			if (chr == _T('-'))
				signE = !signE;
			else
				if ((chr != _T('+')) && (chr != _T(' ')) && (chr != 9)) break;
			chr = *text++;
		}

		// load exponent digits
		while ((chr >= _T('0')) && (chr <= _T('9')))
		{
			expN *= 10;
			expN += chr - '0';
			chr = *text++;
		}

		// multiple number with exponent
		if (expN != 0)
		{
			if (signE)
			{
				if (expN >= 256) { res *= 1e-256; expN -= 256; };
				if (expN >= 128) { res *= 1e-128; expN -= 128; };
				if (expN >=  64) { res *=  1e-64; expN -=  64; };
				if (expN >=  32) { res *=  1e-32; expN -=  32; };
				if (expN >=  16) { res *=  1e-16; expN -=  16; };
				if (expN >=   8) { res *=   1e-8; expN -=   8; };
				if (expN >=   4) { res *=   1e-4; expN -=   4; };
				if (expN >=   2) { res *=   1e-2; expN -=   2; };
				if (expN >=   1) { res *=   1e-1;              };
			}
			else
			{
				if (expN >= 256) { res *= 1e256; expN -= 256; };
				if (expN >= 128) { res *= 1e128; expN -= 128; };
				if (expN >=  64) { res *=  1e64; expN -=  64; };
				if (expN >=  32) { res *=  1e32; expN -=  32; };
				if (expN >=  16) { res *=  1e16; expN -=  16; };
				if (expN >=   8) { res *=   1e8; expN -=   8; };
				if (expN >=   4) { res *=   1e4; expN -=   4; };
				if (expN >=   2) { res *=   1e2; expN -=   2; };
				if (expN >=   1) { res *=   1e1;              };
			}
		}
	}

	// overflow
	if (chr == _T('#'))
	{
		if ((text[1] == _T('I')) &&
			(text[2] == _T('N')) &&
			(text[3] == _T('F')) &&
			((res == 1) || (res == 0)))
		{
			*(long long*)&res = ((long long)0x7ff0000000000000);
			return res;
		}
	}

	// result with sign
	if (sign) return -res;
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// load/save file (multibyte or UTF16, returns FALSE on error)

BOOL CText::LoadFile(FILE* file, int size, FILECP cp /*= FILECP_ANSI*/)
{
	TEXTDATA* data = m_Data;
	if (size < 0) size = 0;
	int n;

#ifdef _UNICODE
	if ((cp == FILECP_UTF16) || (size == 0))
	{
		size /= sizeof(TCHAR);
		if (!NewBuffer(size))
		{
			Detach();
			m_Data = data;
			return FALSE;
		}
		n = (int)fread(m_Data->data, 1, size*2, file);
		if (n != size*2)
		{
			Detach();
			m_Data = data;
			return FALSE;
		}
		if (LongDecrement(&data->ref) == 0) free(data);
		CheckNul();
	}
	else
	{
		char* buf = (char*)malloc(size+1);
		n = (int)fread(buf, 1, size, file);
		if (n != size) return FALSE;
		buf[size] = 0;

		DWORD cp2;
		switch (cp)
		{
		case FILECP_UTF7: cp2 = CP_UTF7; break;
		case FILECP_UTF8: cp2 = CP_UTF8; break;
		case FILECP_OEM: cp2 = CP_OEMCP; break;
		default: cp2 = CP_ACP;
		}

		int size2 = ::MultiByteToWideChar(cp2, 0, buf, size, NULL, 0);
		if (size2 > 0)
		{
			if (!NewBuffer(size2))
			{
				free(buf);
				Detach();
				m_Data = data;
				return FALSE;
			}
			::MultiByteToWideChar(cp2, 0, buf, size, m_Data->data,
														m_Data->length+1);
			free(buf);
			if (LongDecrement(&data->ref) == 0) free(data);
			CheckNul();
		}
		else
			free(buf);
	}
#else // _UNICODE
	if ((cp == FILECP_ANSI) || (size == 0))
	{
		if (!NewBuffer(size))
		{
			Detach();
			m_Data = data;
			return FALSE;
		}
		n = (int)fread(m_Data->data, 1, size, file);
		if (n != size)
		{
			Detach();
			m_Data = data;
			return FALSE;
		}
		if (LongDecrement(&data->ref) == 0) free(data);
		CheckNul();
	}
	else
	{
		char* buf = (char*)malloc(size);
		if (buf == NULL) return FALSE;
		n = (int)fread(buf, 1, size, file);
		if (n != size)
		{
			free(buf);
			return FALSE;
		}

		if (cp == FILECP_UTF16)
		{
			if (!Set((wchar_t*)buf, size/2))
			{
				free(buf);
				Detach();
				m_Data = data;
				return FALSE;
			}
		}
		else
		{
			DWORD cp2;
			switch (cp)
			{
			case FILECP_UTF7: cp2 = CP_UTF7; break;
			case FILECP_OEM: cp2 = CP_OEMCP; break;
			default: cp2 = CP_UTF8;
			}

			int size2 = ::MultiByteToWideChar(cp2, 0, buf, size, NULL, 0);
			if (size2 > 0)
			{
				wchar_t* buf2 = (wchar_t*)malloc((size2+1)*2);
				if (buf2 == NULL)
				{
					free(buf);
					Detach();
					m_Data = data;
					return FALSE;
				}
				::MultiByteToWideChar(cp2, 0, buf, size, buf2, size2+1);
				free(buf);
				if (!Set(buf2, size2))
				{
					free(buf2);
					Detach();
					m_Data = data;
					return FALSE;
				}
				free(buf2);
				if (LongDecrement(&data->ref) == 0) free(data);
				CheckNul();
			}
			else
				free(buf);
		}
	}
#endif // _UNICODE
	return TRUE;
}

BOOL CText::LoadFileName(LPCTSTR name, FILECP cp /*= FILECP_ANSI*/)
{
	// open file
	FILE* f = _tfopen(name, _T("rb"));
	if (f == NULL) return FALSE;

	// get file size
	fseek(f, 0, SEEK_END);
	int size = ftell(f);
	fseek(f, 0, SEEK_SET);

	// load file
	BOOL res = LoadFile(f, size, cp);
	
	// close file
	fclose(f);
	return res;
}

BOOL CText::SaveFile(FILE* file, FILECP cp /*= FILECP_ANSI*/) const
{
	size_t n;
	size_t size = m_Data->length;

#ifdef _UNICODE
	if ((cp == FILECP_UTF16) || (size == 0))
	{
		size *= sizeof(TCHAR);
		n = fwrite(m_Data->data, 1, size, file);
		if (n != size) return FALSE;
	}
	else
	{
		DWORD cp2;
		switch (cp)
		{
		case FILECP_UTF7: cp2 = CP_UTF7; break;
		case FILECP_UTF8: cp2 = CP_UTF8; break;
		case FILECP_OEM: cp2 = CP_OEMCP; break;
		default: cp2 = CP_ACP;
		}
		size = ::WideCharToMultiByte(cp2, 0, m_Data->data,
				m_Data->length, NULL, 0, NULL, NULL);
		if (size > 0)
		{
			char* buf = (char*)malloc(size+1);
			if (buf == NULL) return FALSE;
			::WideCharToMultiByte(cp2, 0, m_Data->data,
					m_Data->length, buf, (int)(size+1), NULL, NULL);
			n = fwrite(buf, 1, size, file);
			free(buf);
			if (n != size) return FALSE;
		}
	}
#else // _UNICODE
	if ((cp == FILECP_ANSI) || (size == 0))
	{
		n = fwrite(m_Data->data, 1, size, file);
		if (n != size) return FALSE;
	}
	else
	{
		wchar_t* buf = (wchar_t*)malloc((size+1)*2);
		if (buf == NULL) return FALSE;
		Write(buf, (int)(size+1));

		if (cp == FILECP_UTF16)
		{
			n = fwrite(buf, 1, size*2, file);
			free(buf);
			if (n != size*2) return FALSE;
		}
		else
		{
			DWORD cp2;
			switch (cp)
			{
			case FILECP_UTF7: cp2 = CP_UTF7; break;
			case FILECP_OEM: cp2 = CP_OEMCP; break;
			default: cp2 = CP_UTF8;
			}
			size_t size2 = ::WideCharToMultiByte(cp2, 0, buf,
					(int)size, NULL, 0, NULL, NULL);
			if (size2 > 0)
			{
				char* buf2 = (char*)malloc(size2+1);
				if (buf2 == NULL)
				{
					free(buf);
					return FALSE;
				}
				::WideCharToMultiByte(cp2, 0, buf,
						(int)size, buf2, (int)(size2+1), NULL, NULL);
				n = fwrite(buf2, 1, (int)size2, file);
				free(buf2);
				free(buf);
				if (n != size2) return FALSE;
			}
			else
				free(buf);
		}
	}
#endif // _UNICODE
	return TRUE;
}

BOOL CText::SaveFileName(LPCTSTR name, FILECP cp /*= FILECP_ANSI*/) const
{
	// open file
	FILE* f = _tfopen(name, _T("wb"));
	if (f == NULL) return FALSE;

	// save file
	BOOL res = SaveFile(f, cp);

	// close file
	fclose(f);

	// delete output file on error
	if (!res) _tremove(name);
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// load text from resource

void CText::Load(int id)
{
	TCHAR buf[0x201];
	buf[0] = 0;
	int len = ::LoadString(Instance, id, buf, 0x200);
	Set(buf, len);
}

///////////////////////////////////////////////////////////////////////////////
// load long text from resource, group "TEXT" (must be terminated with "<EOF>" string)

void CText::LoadLongText(LPCTSTR id)
{
	this->Empty();

	HRSRC res = ::FindResource(Instance, id, _T("TEXT"));
	if (res != NULL)
	{
		HGLOBAL glob = ::LoadResource(Instance, res);
		if (glob != NULL)
		{
			char* a = (char*)::LockResource(glob);
			if (a != NULL)
			{
				char* ap;
				ap = a;
				int i;
				for (i = 0; i < 10000; i++)
				{
					if (memcmp(ap, "<EOF>", 1) == 0) break;
					ap++;
				}

				this->Set(a, i);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// get current directory

void CText::GetCurrentDir()
{
	TCHAR buf[_MAX_PATH];
	buf[0] = 0;
	int len = (int)::GetCurrentDirectory(_MAX_PATH, buf);
	if (len < 0) len = 0;
	if (len > _MAX_PATH) len = _MAX_PATH;
	
	Detach();
	NewBuffer(len);
	memcpy(m_Data->data, buf, len*sizeof(TCHAR));
}

/////////////////////////////////////////////////////////////////////////////
// file name correction (returns new cursor position)

int CText::FileName(int curs)
{
	for (int i = m_Data->length-1; i >= 0; i--)
	{
		TCHAR ch = m_Data->data[i];
		if ((BYTE)ch < 32) ch = 0;

		switch(ch)
		{
		case 0:
		case _T('*'):
		case _T('|'):
		case _T('\\'):
		case _T(':'):
		case _T('"'):
		case _T('<'):
		case _T('>'):
		case _T('?'):
		case _T('/'):
			Delete(i,1);
			if (curs > i) curs--;
		}
	}
	return curs;
}

/////////////////////////////////////////////////////////////////////////////
// path name correction (returns new cursor position)

int CText::PathName(int curs)
{
	for (int i = m_Data->length-1; i >= 0; i--)
	{
		TCHAR ch = m_Data->data[i];
		if ((BYTE)ch < 32) ch = 0;

		switch(ch)
		{
		case 0:
		case _T('*'):
		case _T('|'):
		case _T('"'):
		case _T('<'):
		case _T('>'):
		case _T('?'):
		case _T('/'):
			Delete(i,1);
			if (curs > i) curs--;
		}
	}
	return curs;
}

/////////////////////////////////////////////////////////////////////////////
// string correction (returns new cursor position)

int CText::StringCorr(int curs)
{
	for (int i = m_Data->length-1; i >= 0; i--)
	{
		TCHAR ch = m_Data->data[i];
		if ((BYTE)ch < 32) ch = 0;

		switch(ch)
		{
		case 0:
		case _T('"'):
			Delete(i,1);
			if (curs > i) curs--;
		}
	}
	return curs;
}

/////////////////////////////////////////////////////////////////////////////
// extract path

CText CText::ExtractPath() const
{
	int pos = FindRev('\\');
	if (pos >= 0)
	{
		if ((pos > 0) && (At(pos-1) == ':')) pos++;
	}
	else
	{
		pos = FindRev(':');
		if (pos >= 0) pos++;
	}

	return CText(m_Data->data, pos);
}

/////////////////////////////////////////////////////////////////////////////
// add backslash on end of path

void CText::AddBackSlash()
{
	if (Last() != '\\') Add('\\');
}

/////////////////////////////////////////////////////////////////////////////
// delete backslash from end of path

void CText::DelBackSlash()
{
	if (Last() == '\\') DelLast();
}

///////////////////////////////////////////////////////////////////////////////
// set operators

const CText& CText::operator= (const CText& txt)
{
	DetachAttach(txt.m_Data);
	return *this;
}

const CText& CText::operator= (LPCTSTR txt)
{
	int len = 0;
	if (txt != NULL) len = ::lstrlen(txt);
	Detach();
	if (NewBuffer(len)) memcpy(m_Data->data, txt, len*sizeof(TCHAR));
	return *this;
}

#ifdef _UNICODE

const CText& CText::operator=(LPCSTR txt)
{
	int len = 0;
	if (txt != NULL) len = ::lstrlenA(txt);
	Detach();
	if (NewBuffer(len))
		::MultiByteToWideChar(CP_ACP, 0, txt, len, m_Data->data, len + 1);
	return *this;
}

#else // _UNICODE

const CText& CText::operator=(LPCWSTR txt)
{
	int len = 0;
	if (txt != NULL) len = ::lstrlenW(txt);
	Detach();
	if (NewBuffer(len))
		::WideCharToMultiByte(CP_ACP,0,txt,len,m_Data->data,len+1,NULL,NULL);
	return *this;
}

#endif // _UNICODE

const CText& CText::operator= (TCHAR chr)
{
	if (chr == 0)
		Empty();
	else
	{
		Detach();
		NewBuffer(1);
		m_Data->data[0] = chr;
	}
	return *this;
}

///////////////////////////////////////////////////////////////////////////////
// add operators

const CText& CText::operator+= (CText txt)
{
	int len1 = m_Data->length;
	int len2 = txt.m_Data->length;
	if (SetLength(len1 + len2))
		memcpy(&m_Data->data[len1], txt.m_Data->data, len2*sizeof(TCHAR));
	return *this;
}

const CText& CText::operator+= (LPCTSTR txt)
{
	int len1 = m_Data->length;
	int len2 = 0;
	if (txt != NULL) len2 = ::lstrlen(txt);
	if (SetLength(len1 + len2))
		memcpy(&m_Data->data[len1], txt, len2*sizeof(TCHAR));
	return *this;
}

const CText& CText::operator+= (TCHAR chr)
{
	int len = m_Data->length;
	if (SetLength(len + 1)) m_Data->data[len] = chr;
	return *this;
}

///////////////////////////////////////////////////////////////////////////////
// compare operators

BOOL operator== (const CText& txt1, const CText& txt2)
{
	if (txt1.m_Data == txt2.m_Data) return TRUE;
	int len = txt1.m_Data->length;
	return ((len == txt2.m_Data->length) &&
		(memcmp(txt1.m_Data->data, txt2.m_Data->data, len*sizeof(TCHAR))==0));
}

BOOL operator== (LPCTSTR txt1, const CText& txt2)
{
	int len = 0;
	if (txt1 != NULL) len = ::lstrlen(txt1);
	return ((len == txt2.m_Data->length) &&
		(memcmp(txt1, txt2.m_Data->data, len*sizeof(TCHAR))==0));
}

BOOL operator== (const CText& txt1, LPCTSTR txt2)
{
	int len = 0;
	if (txt2 != NULL) len = ::lstrlen(txt2);
	return ((len == txt1.m_Data->length) &&
		(memcmp(txt1.m_Data->data, txt2, len*sizeof(TCHAR))==0));
}

BOOL operator== (TCHAR chr, const CText& txt)
{
	return ((txt.m_Data->length == 1) && (txt.m_Data->data[0] == chr));
}

BOOL operator== (const CText& txt, TCHAR chr)
{
	return ((txt.m_Data->length == 1) && (txt.m_Data->data[0] == chr));
}

BOOL operator!= (const CText& txt1, const CText& txt2)
{
	if (txt1.m_Data == txt2.m_Data) return FALSE;
	int len = txt1.m_Data->length;
	return ((len != txt2.m_Data->length) ||
		(memcmp(txt1.m_Data->data, txt2.m_Data->data, len*sizeof(TCHAR))!=0));
}

BOOL operator!= (LPCTSTR txt1, const CText& txt2)
{
	int len = 0;
	if (txt1 != NULL) len = ::lstrlen(txt1);
	return ((len != txt2.m_Data->length) ||
		(memcmp(txt1, txt2.m_Data->data, len*sizeof(TCHAR))!=0));
}

BOOL operator!= (const CText& txt1, LPCTSTR txt2)
{
	int len = 0;
	if (txt2 != NULL) len = ::lstrlen(txt2);
	return ((len != txt1.m_Data->length) ||
		(memcmp(txt1.m_Data->data, txt2, len*sizeof(TCHAR))!=0));
}

BOOL operator!= (TCHAR chr, const CText& txt)
{
	return ((txt.m_Data->length != 1) || (txt.m_Data->data[0] != chr));
}

BOOL operator!= (const CText& txt, TCHAR chr)
{
	return ((txt.m_Data->length != 1) || (txt.m_Data->data[0] != chr));
}

BOOL operator< (const CText& txt1, const CText& txt2)
{
	int res = ::CompareString(
				LOCALE_USER_DEFAULT, 
				0, 
				txt1.m_Data->data,
				txt1.m_Data->length,
				txt2.m_Data->data,
				txt2.m_Data->length);
	return (res == CSTR_LESS_THAN);
}

BOOL operator<= (const CText& txt1, const CText& txt2)
{
	int res = ::CompareString(
				LOCALE_USER_DEFAULT, 
				0, 
				txt1.m_Data->data,
				txt1.m_Data->length,
				txt2.m_Data->data,
				txt2.m_Data->length);
	return ((res == CSTR_LESS_THAN) || (res == CSTR_EQUAL));
}

BOOL operator> (const CText& txt1, const CText& txt2)
{
	int res = ::CompareString(
				LOCALE_USER_DEFAULT, 
				0, 
				txt1.m_Data->data,
				txt1.m_Data->length,
				txt2.m_Data->data,
				txt2.m_Data->length);
	return (res == CSTR_GREATER_THAN);
}

BOOL operator>= (const CText& txt1, const CText& txt2)
{
	int res = ::CompareString(
				LOCALE_USER_DEFAULT, 
				0, 
				txt1.m_Data->data,
				txt1.m_Data->length,
				txt2.m_Data->data,
				txt2.m_Data->length);
	return ((res == CSTR_GREATER_THAN) || (res == CSTR_EQUAL));
}

///////////////////////////////////////////////////////////////////////////////
// split text string by delimiter (destroys old content,returns FALSE on error)

BOOL CTextList::Split(const CText& text, LPCTSTR delim, int length /*= -1*/,
														int limit /*= BIGINT*/)
{
	// delete old content
	DelAll();
	if (text.IsEmpty()) return TRUE;

	// prepare length of delimiter
	int len = 0;
	if (delim != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlen(delim);
	}

	// split text string
	int pos;
	int oldpos = 0;
	limit--;
	if (len <= 0)
		for (; oldpos < text.Length(); oldpos++)
		{
			if (m_Num >= limit) break;
			if (this->Add(CText(text[oldpos])) < 0) return FALSE;
		}
	else
		for (;;)
		{
			if (m_Num >= limit) break;
			pos = text.Find(delim, len, oldpos);
			if (pos < 0) break;
			if (this->Add(text.Mid(oldpos, pos - oldpos)) < 0) return FALSE;
			oldpos = pos + len;
		}
	return (this->Add(text.RightFrom(oldpos)) >= 0);
}

BOOL CTextList::Split(const CText& text, TCHAR delim, int limit /*= BIGINT*/)
{
	// delete old content
	DelAll();
	if (text.IsEmpty()) return TRUE;

	// split text string
	int pos;
	int oldpos = 0;
	limit--;
	for (;;)
	{
		if (m_Num >= limit) break;
		pos = text.Find(delim, oldpos);
		if (pos < 0) break;
		if (this->Add(text.Mid(oldpos, pos - oldpos)) < 0) return FALSE;
		oldpos = pos + 1;
	}
	return (this->Add(text.RightFrom(oldpos)) >= 0);
}

BOOL CTextList::SplitWords(const CText& text, int limit /*= BIGINT*/)
{
	// delete old content
	DelAll();
	if (text.IsEmpty()) return TRUE;

	// split text string
	int pos = 0;
	int oldpos;
	limit--;
	for (;;)
	{
		oldpos = text.FindNSpace(pos);
		if (oldpos < 0) break;
		pos = (m_Num >= limit) ? text.Length() : text.FindSpace(oldpos);
		if (pos < 0) pos = text.Length();
		if (this->Add(text.Mid(oldpos, pos - oldpos)) < 0) return FALSE;
	}
	return TRUE;
}

BOOL CTextList::SplitLines(const CText& text, int limit /*= BIGINT*/)
{
	// delete old content
	DelAll();
	if (text.IsEmpty()) return TRUE;

	// split text string
	int pos;
	int oldpos = 0;
	int p1, p2;
	limit--;
	for (;;)
	{
		if (m_Num >= limit) break;
		pos = text.Find(_T('\n'), oldpos);
		if (pos < 0) break;
		p1 = oldpos;
		p2 = pos;
		while ((p1 < p2) && (text[p1] == _T('\r'))) p1++;
		while ((p2 > p1) && (text[p2-1] == _T('\r'))) p2--;
		if (this->Add(text.Mid(p1, p2 - p1)) < 0) return FALSE;
		oldpos = pos + 1;
	}
	while ((oldpos < text.Length()) && (text[oldpos] == _T('\r'))) oldpos++;
	return (this->Add(text.RightFrom(oldpos)) >= 0);
}

///////////////////////////////////////////////////////////////////////////////
// join text strings

CText CTextList::Join(LPCTSTR delim, int length /*= -1*/) const
{
	CText txt;
	if (m_Num == 0) return txt;

	// prepare length of delimiter
	int len = 0;
	if (delim != NULL)
	{
		len = length;
		if (len < 0) len = ::lstrlen(delim);
	}

	// join strings
	int inx;
	txt = m_List[0];
	for (inx = 1; inx < m_Num; inx++)
	{
		txt.Add(delim, length);
		txt.Add(m_List[inx]);
	}
	return txt;
}

CText CTextList::Join(TCHAR delim /*= _T(' ')*/) const
{
	CText txt;
	if (m_Num == 0) return txt;

	// join strings
	int inx;
	txt = m_List[0];
	for (inx = 1; inx < m_Num; inx++)
	{
		txt.Add(delim);
		txt.Add(m_List[inx]);
	}
	return txt;
}

CText CTextList::JoinLines() const
{
	CText txt;
	if (m_Num == 0) return txt;

	// join strings
	int inx;
	txt = m_List[0];
	for (inx = 1; inx < m_Num; inx++)
	{
		txt.Add(NewLine);
		txt.Add(m_List[inx]);
	}
	return txt;
}
