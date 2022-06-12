
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Canvas Drawing                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

typedef struct SCanvas_ {

	u16		w;		// canvas width
	u16		h;		// canvas height
	u16		ref;	// share reference counter of owners (single-threaded!, 0=no owner, can be deleted)
	u8		c;		// color bytes (3 if BGR, 4 if BGRA with alpha)
	u8		d[1];	// canvas data (in BGR or BGRA format) + 1 byte reserve to enable u32 operations

} SCanvas;

#define CANVAS_SIZE (3*sizeof(u16) + sizeof(u8)) // canvas size without data

#define ARROWWIDTH	5		// width of arrow

///////////////////////////////////////////////////////////////////////////////
// color as DWORD (a=0 transparency .. 255 opaque)

#define RGBACOL(r,g,b,a) ((DWORD)((((a) & 0xff) << 24) | (((r) & 0xff) << 16) | (((g) & 0xff) << 8) | ((b) & 0xff)))
#define RGBCOL(r,g,b) RGBACOL(r,g,b,255)

#define RGB_R(rgb) (((rgb) >> 16) & 0xff)
#define RGB_G(rgb) (((rgb) >> 8) & 0xff)
#define RGB_B(rgb) ((rgb) & 0xff)
#define RGB_A(rgb) (((rgb) >> 24) & 0xff)

// color as QUADRUPLE (palette entry)
typedef struct SRGBA_ {
		BYTE	b;
		BYTE	g;
		BYTE	r;
		BYTE	a;
} SRGBA;

///////////////////////////////////////////////////////////////////////////////
// create canvas using malloc (c = 3 or 4; ref=1; returns NULL on error)

inline SCanvas* NewCanvas(int w, int h, int c = 3)
{
	SCanvas* b = (SCanvas*)malloc(CANVAS_SIZE + w*h*c + 10);
	if (b != NULL)
	{
		b->w = (u16)w;
		b->h = (u16)h;
		b->ref = 1;
		b->c = (u8)c;
	}
	return b;
}

///////////////////////////////////////////////////////////////////////////////
// reallocate canvas using realloc (c = 3 or 4; returns NULL on error; ref not changed)

inline SCanvas* ReallocCanvas(SCanvas* old, int w, int h, int c = 3)
{
	SCanvas* b = (SCanvas*)realloc(old, CANVAS_SIZE + w*h*c + 10);
	if (b != NULL)
	{
		b->w = (u16)w;
		b->h = (u16)h;
		b->c = (u8)c;
	}
	return b;
}

///////////////////////////////////////////////////////////////////////////////
// attach canvas to owner

inline void AttachCanvas(SCanvas* c)
{
	c->ref++;
}

///////////////////////////////////////////////////////////////////////////////
// dettach canvas from owner and delete if not needed

inline void DetachCanvas(SCanvas* c)
{
	c->ref--;
	if (c->ref == 0) free(c);
}

///////////////////////////////////////////////////////////////////////////////
// flip RGB and BGR

void RGBflipBGR(SCanvas* c);

///////////////////////////////////////////////////////////////////////////////
// vertical flip canvas

void VFlipCanvas(SCanvas* c);

///////////////////////////////////////////////////////////////////////////////
// draw horizontal line

void DrawHLine(SCanvas* dst, int x, int y, int w, u32 col);

///////////////////////////////////////////////////////////////////////////////
// draw vertical line

void DrawVLine(SCanvas* dst, int x, int y, int h, u32 col);

///////////////////////////////////////////////////////////////////////////////
// draw frame

void DrawFrame(SCanvas* dst, int x, int y, int w, int h, u32 col);

///////////////////////////////////////////////////////////////////////////////
// draw horizontal dashed line

void DrawHDash(SCanvas* dst, int x, int y, int w, u32 col1, u32 col2);

///////////////////////////////////////////////////////////////////////////////
// draw vertical dashed line

void DrawVDash(SCanvas* dst, int x, int y, int h, u32 col1, u32 col2);

///////////////////////////////////////////////////////////////////////////////
// draw dashed frame

void DrawDash(SCanvas* dst, int x, int y, int w, int h, u32 col1, u32 col2);

///////////////////////////////////////////////////////////////////////////////
// draw rectangle

void DrawRect(SCanvas* dst, int x, int y, int w, int h, u32 col);

///////////////////////////////////////////////////////////////////////////////
// draw text

void DrawText(SCanvas* dst, const CText& txt, int x, int y, u32 col, int wmax = 0);

///////////////////////////////////////////////////////////////////////////////
// draw arrow

void DrawArrow(SCanvas* dst, int x, int y, u32 col);

///////////////////////////////////////////////////////////////////////////////
// draw image

void DrawImage(SCanvas* dst, SCanvas* src, int x, int y, int h = 0);

///////////////////////////////////////////////////////////////////////////////
// draw line

void DrawLine(SCanvas* dst, int x1, int y1, int x2, int y2, u32 col);

///////////////////////////////////////////////////////////////////////////////
// decode picture from memory (returns NULL on error; return Canvas with ref=1)

SCanvas* ImgDecode(const u8* buf, int size);

///////////////////////////////////////////////////////////////////////////////
// load picture from file (returns NULL on error; return Canvas with ref=1)

SCanvas* ImgLoad(const CText& filename);
