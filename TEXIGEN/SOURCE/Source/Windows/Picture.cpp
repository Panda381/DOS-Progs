
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                   Picture                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CPictureList	PicCache;

///////////////////////////////////////////////////////////////////////////////
// picture constructor

CPicture::CPicture()
{
	// OLE picture (NULL=none)
	m_Pic = NULL;
}

CPicture::~CPicture()
{
	if (m_Pic != NULL) m_Pic->Release();
}

///////////////////////////////////////////////////////////////////////////////
// load picture (returns FALSE on error)

BOOL CPicture::LoadFile(const CText& filename)
{
	// delete old picture
	if (m_Pic != NULL)
	{
		m_Pic->Release();
		m_Pic = NULL;
	}

	// reset parameters
	m_Filename = filename;
	m_DevWidth = 0;
	m_DevHeight = 0;
	m_Width = 0;
	m_Height = 0;

	// open file
	HANDLE file = ::CreateFile(filename, GENERIC_READ, FILE_SHARE_READ, NULL,
		OPEN_EXISTING,  FILE_ATTRIBUTE_ARCHIVE | FILE_ATTRIBUTE_READONLY, NULL);
	if (file != INVALID_HANDLE_VALUE)
	{
		// get file size
		int size = ::GetFileSize(file, NULL);
		if ((size != INVALID_FILE_SIZE) && (size > 10) && (size < 100000000))
		{
			// create global memory block
			HGLOBAL g = ::GlobalAlloc(GMEM_MOVEABLE, size + 1000);
			if (g != NULL)
			{
				// lock global memory block
				void* p = ::GlobalLock(g);
				if (p != NULL)
				{
					// read file into memory block
					DWORD read = 0;
					BOOL res = ::ReadFile(file, p, size, &read, NULL);

					// close file and release memory block
					::CloseHandle(file);
					file = INVALID_HANDLE_VALUE;
					::GlobalUnlock(g);

					if (res && ((int)read == size))
					{
						// create stream
						IStream* s = NULL;
						if ((::CreateStreamOnHGlobal(g, TRUE, &s) == S_OK) && (s != NULL))
						{
							// load picture
							if ((::OleLoadPicture(s, size, FALSE, IID_IPicture, (void**)&m_Pic) == S_OK) && (m_Pic != NULL))
							{
								// get picture size
								m_Pic->get_Width(&m_DevWidth);
								m_Pic->get_Height(&m_DevHeight);

								// get and check real dimensions
								HDC dc0 = ::GetDC(NULL);
								m_Width = MulDiv(m_DevWidth, ::GetDeviceCaps(dc0, LOGPIXELSX), 2540);
								m_Height = MulDiv(m_DevHeight, ::GetDeviceCaps(dc0, LOGPIXELSY), 2540);
								::ReleaseDC(NULL, dc0);
								if ((m_Width > 0) && (m_Width <= 32000) && (m_Height > 0) && (m_Height <= 32000))
								{
									s->Release();
									::GlobalFree(g);
									return TRUE;
								}

								// delete picture object
								m_Pic->Release();
								m_Pic = NULL;
							}

							// delete stream
							s->Release();
						}
					}
				}

				// delete memory block
				::GlobalFree(g);
			}
		}

		// close file
		if (file != INVALID_HANDLE_VALUE) ::CloseHandle(file);
	}

	return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// draw picture

void CPicture::Draw(HDC dc, int w, int h)
{
	if (m_Pic != NULL)
	{
		RECT rc;
		rc.left = 0;
		rc.top = 0;
		rc.right = w;
		rc.bottom = h;

		m_Pic->Render(dc, 0, 0, w, h,
			0, m_DevHeight, m_DevWidth, -m_DevHeight, &rc);
	}
}

///////////////////////////////////////////////////////////////////////////////
// get picture (returns NULL on error)

CPicture* CPictureList::Get(const CText& filename)
{
	// find existing picture
	CPicture* p;
	ListForEach(p, this)
	{
		if (p->Filename() == filename) return p;
	}

	// load new picture
	p = new CPicture();
	if (p != NULL)
	{
		// load image
		if (!p->LoadFile(filename)) return NULL;
		AddLast(p);
	}
	return p;
}

///////////////////////////////////////////////////////////////////////////////
// reload picture (returns NULL on error, does not send error event)

CPicture* CPictureList::Reload(const CText& filename)
{
	// find existing picture
	CPicture* p = NULL;
	CPicture* p2;
	ListForEach(p2, this)
	{
		if (p2->Filename() == filename)
		{
			p = p2;
			break;
		}
	}

	// load new picture
	if (p == NULL)
	{
		p = new CPicture();
		if (p == NULL) return NULL;
		AddLast(p);
	}

	// load image
	p->LoadFile(filename);

	return p;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CPictureWin::CPictureWin()
{
	// window type
	m_Type = WINTYPE_PICTURE;

	// picture in cache (NULL=none)
	m_Picture = NULL;

	// autosize control
	m_AutoSize = FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// create picture window (returns FALSE on error)

BOOL CPictureWin::CreatePic(int x, int y, int w, int h,
													CWindow* parent /*= NULL*/)
{
	return CreateChild(0, StaticClass, EmptyText, SS_NOTIFY, x,y,w,h,parent);
}

///////////////////////////////////////////////////////////////////////////////
// do autosize and redraw

void CPictureWin::DoAutoSize()
{
	if (m_AutoSize)
	{
		if ((m_Picture != NULL) && (m_Picture->Pic() != NULL))
			Resize(m_Picture->Width(), m_Picture->Height());
		else
			Resize(1, 1);
	}
	Redraw();
}

///////////////////////////////////////////////////////////////////////////////
// draw control (on WM_PAINT message)

void CPictureWin::OnDraw(HDC dc)
{
	//HBRUSH brush = ::CreateSolidBrush(::GetSysColor(COLOR_BTNFACE));
	//RECT rc;
	//rc.left = 0;
	//rc.top = 0;
	//rc.right = Width();
	//rc.bottom = Height();
	//::FillRect(dc, &rc, brush);
	//::DeleteObject(brush);
	if ((m_Picture != NULL) && (m_Picture->Pic() != NULL))
		m_Picture->Draw(dc, Width(), Height());
}

///////////////////////////////////////////////////////////////////////////////
// load picture (returns FALSE on error)

BOOL CPictureWin::Load(const CText& filename)
{
	m_Picture = PicCache.Get(filename);
	DoAutoSize();
	return (m_Picture != NULL);
}
