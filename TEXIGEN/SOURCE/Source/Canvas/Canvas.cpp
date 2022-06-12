
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Canvas Drawing                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// vertical flip canvas

void VFlipCanvas(SCanvas* c)
{
	int wb = c->w * c->c;
	u8* s1 = c->d;
	int h = c->h;
	u8* s2 = s1 + wb*(h-1);

	int i, j, k;
	for (i = h/2; i > 0; i--)
	{
		for (j = wb/4; j > 0; j--)
		{
			k = *(u32*)s1;
			*(u32*)s1 = *(u32*)s2;
			*(u32*)s2 = k;
			s1 += 4;
			s2 += 4;
		}

		for (j = wb & 3; j > 0; j--)
		{
			k = *s1;
			*s1 = *s2;
			*s2 = (u8)k;
			s1++;
			s2++;
		}
		s2 -= 2*wb;
	}
}

///////////////////////////////////////////////////////////////////////////////
// flip RGB and BGR

void RGBflipBGR(SCanvas* c)
{
	int b = c->c;
	u8* d = c->d;
	int i;
	u8 k;
	for (i = c->w * c->h; i > 0; i--)
	{
		k = d[0];
		d[0] = d[2];
		d[2] = k;
		d += b;
	}
}

///////////////////////////////////////////////////////////////////////////////
// draw horizontal line BGR without alpha

void DrawHLine(SCanvas* dst, int x, int y, int w, u32 col)
{
	// check destination
	if ((DWORD)y >= (DWORD)dst->h) return;
	if (x < 0)
	{
		w += x;
		x = 0;
	}
	if (x + w > dst->w) w = dst->w - x;
	if (w <= 0) return;

	// destination without alpha
	u8* d = &dst->d[(x + dst->w*y)*dst->c];
	col &= 0xffffff;
	for (; w > 1; w--)
	{
		*(u32*)d = col;
		d += 3;
	}
	*(u32*)d = (*(u32*)d & 0xff000000) | col;
}

///////////////////////////////////////////////////////////////////////////////
// draw vertical line BGR without alpha

void DrawVLine(SCanvas* dst, int x, int y, int h, u32 col)
{
	// check destination
	if ((DWORD)x >= (DWORD)dst->w) return;
	if (y < 0)
	{
		h += y;
		y = 0;
	}
	if (y + h > dst->h) h = dst->h - y;
	if (h <= 0) return;

	// destination without alpha
	int dw = dst->w;
	u8* d = &dst->d[(x + dw*y)*dst->c];
	dw *= dst->c;
	col &= 0xffffff;
	for (; h > 0; h--)
	{
		*(u32*)d = (*(u32*)d & 0xff000000) | col;
		d += dw;
	}
}

///////////////////////////////////////////////////////////////////////////////
// draw frame

void DrawFrame(SCanvas* dst, int x, int y, int w, int h, u32 col)
{
	DrawHLine(dst, x, y, w, col);
	DrawHLine(dst, x, y + h - 1, w, col);
	DrawVLine(dst, x, y + 1, h - 2, col);
	DrawVLine(dst, x + w - 1, y + 1, h - 2, col);
}

///////////////////////////////////////////////////////////////////////////////
// draw horizontal dashed line BGR without alpha

void DrawHDash(SCanvas* dst, int x, int y, int w, u32 col1, u32 col2)
{
	// check destination
	if ((DWORD)y >= (DWORD)dst->h) return;
	if (x < 0)
	{
		w += x;
		x = 0;
	}
	if (x + w > dst->w) w = dst->w - x;
	if (w <= 0) return;

	// destination without alpha
	u8* d = &dst->d[(x + dst->w*y)*dst->c];
	col1 &= 0xffffff;
	col2 &= 0xffffff;
	for (; w > 1; w--)
	{
		*(u32*)d = (((x+y) & 2) == 0) ? col1 : col2;
		d += 3;
		x++;
	}
	*(u32*)d = (*(u32*)d & 0xff000000) | ((((x+y) & 2) == 0) ? col1 : col2);
}

///////////////////////////////////////////////////////////////////////////////
// draw vertical dashed line BGR without alpha

void DrawVDash(SCanvas* dst, int x, int y, int h, u32 col1, u32 col2)
{
	// check destination
	if ((DWORD)x >= (DWORD)dst->w) return;
	if (y < 0)
	{
		h += y;
		y = 0;
	}
	if (y + h > dst->h) h = dst->h - y;
	if (h <= 0) return;

	// destination without alpha
	int dw = dst->w;
	u8* d = &dst->d[(x + dw*y)*dst->c];
	dw *= dst->c;
	col1 &= 0xffffff;
	col2 &= 0xffffff;
	for (; h > 0; h--)
	{
		*(u32*)d = (*(u32*)d & 0xff000000) | ((((x+y) & 2) == 0) ? col1 : col2);
		d += dw;
		y++;
	}
}

///////////////////////////////////////////////////////////////////////////////
// draw dashed frame

void DrawDash(SCanvas* dst, int x, int y, int w, int h, u32 col1, u32 col2)
{
/*	if (x < 0)
	{
		w += x;
		x = 0;
	}
	if (x + w > dst->w) w = dst->w - x;
	if (y < 0)
	{
		h += y;
		y = 0;
	}
	if (y + h > dst->h) h = dst->h - y;
	if ((w <= 0) || (h <= 0)) return;
*/
	DrawHDash(dst, x, y, w, col1, col2);
	DrawHDash(dst, x, y + h - 1, w, col1, col2);
	DrawVDash(dst, x, y + 1, h - 2, col1, col2);
	DrawVDash(dst, x + w - 1, y + 1, h - 2, col1, col2);
}

///////////////////////////////////////////////////////////////////////////////
// draw rectangle BGR without alpha

void DrawRect(SCanvas* dst, int x, int y, int w, int h, u32 col)
{
	// limit destination
	if (x < 0)
	{
		w += x;
		x = 0;
	}
	if (x + w > dst->w) w = dst->w - x;
	if (y < 0)
	{
		h += y;
		y = 0;
	}
	if (y + h > dst->h) h = dst->h - y;
	if ((w <= 0) || (h <= 0)) return;

	// destination without alpha
	int dw = dst->w;
	u8* d = &dst->d[(x + dw*y)*dst->c];
	dw = (dw - w)*dst->c;
	col &= 0xffffff;
	int w2;
	dw += dst->c;
	for (; h > 0; h--)
	{
		for (w2 = w; w2 > 1; w2--)
		{
			*(u32*)d = col;
			d += 3;
		}
		*(u32*)d = (*(u32*)d & 0xff000000) | col;
		d += dw;
	}
}

///////////////////////////////////////////////////////////////////////////////
// draw text BGR without alpha

void DrawText(SCanvas* dst, const CText& txt, int x, int y, u32 col, int wmax /*= 0*/)
{
	// destination buffer
	int dw = dst->w;
	u8* b = &dst->d[(x + dw*y)*3];

	// loop through characters
	dw *= 3;
	int wnow = 0;
	const u8* s;
	int i, w, h;
	TCHAR ch;
	int fh = Font11->h;
	int fw = Font11->w;
	for (i = 0; i < txt.Length(); i++)
	{
		// get character
		ch = txt.At(i);

		// invalid character or space
		if ((ch < FONTMIN) || (ch > FONTMAX))
			b += 3*3;
		else
		{
			// get character 
			w = FontTabW[ch - FONTMIN];
			s = &Font11->d[FontTabX[ch - FONTMIN] + (fh - 1)*fw];

			// check max width
			if (wmax != 0)
			{
				wnow += w;
				if (wnow > wmax) return;
			}

			// draw one character
			for (; w > 0; w--)
			{
				for (h = fh; h > 0; h--)
				{
					if (*s < 128) *(u32*)b = (*(u32*)b & 0xff000000) | col;
					b += dw;
					s -= fw;
				}
				s += fh*fw + 1;
				b -= fh*dw - 3;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// draw arrow

#define DRAWARR(x,y)  *(int*)&b[(w*(y)+(x))*3] = col
#define DRAWARR2(x,y) *(int*)&b[(w*(y)+(x))*3] = col | (*(int*)&b[(w*(y)+(x))*3] & 0xff000000)

void DrawArrow(SCanvas* dst, int x, int y, u32 col)
{
	int w = dst->w;
	u8* b = &dst->d[(x + w*y)*3];

	DRAWARR2(0,0);
	DRAWARR(0,1); DRAWARR2(1,1);
	DRAWARR(0,2); DRAWARR(1,2); DRAWARR2(2,2);
	DRAWARR(0,3); DRAWARR(1,3); DRAWARR(2,3); DRAWARR2(3,3);
	DRAWARR(0,4); DRAWARR(1,4); DRAWARR(2,4); DRAWARR(3,4); DRAWARR2(4,4);
	DRAWARR(0,5); DRAWARR(1,5); DRAWARR(2,5); DRAWARR2(3,5);
	DRAWARR(0,6); DRAWARR(1,6); DRAWARR2(2,6);
	DRAWARR(0,7); DRAWARR2(1,7);
	DRAWARR2(0,8);
}

///////////////////////////////////////////////////////////////////////////////
// draw image

void DrawImage(SCanvas* dst, SCanvas* src, int x, int y, int h /*= 0*/)
{
	int dw = dst->w;
	u8* d = &dst->d[(x + dw*y)*3];
	dw *= 3;
	int w = src->w * 3;
	u8* s = src->d;
	if (h == 0) h = src->h;
	for (; h > 0; h--)
	{
		memcpy(d, s, w);
		d += dw;
		s += w;
	}
}

///////////////////////////////////////////////////////////////////////////////
// draw line

void DrawLine(SCanvas* dst, int x1, int y1, int x2, int y2, u32 col)
{
	// deltas
	int dx = x2 - x1;
	int dy = y2 - y1;
	u8* b = &dst->d[(x1 + dst->w*y1)*3];

	// one pixel
	if ((dx == 0) && (dy == 0))
	{
		*(int*)b = col | (*(int*)b & 0xff000000);
		return;
	}

	int tx = (dx < 0) ? -1 : 1;
	int ty = (dy < 0) ? -1 : 1;

	// X is more significant
	if (abs(dx) > abs(dy))
	{
		dy = abs(dy)*0x10000/abs(dx); 
		int y = 0x8000;
		ty *= dst->w*3;
		
		for (; x1 != x2; x1 += tx)
		{
			*(int*)b = col | (*(int*)b & 0xff000000);
			b += 3*tx;

			y += dy;
			if (y >= 0x10000)
			{
				y -= 0x10000;
				b += ty;
			}
		}

		*(int*)b = col | (*(int*)b & 0xff000000);
	}

	// Y is more significant
	else
	{
		dx = abs(dx)*0x10000/abs(dy); 
		int x = 0x8000;
		int ty2 = ty*dst->w*3;
		tx *= 3;
		
		for (; y1 != y2; y1 += ty)
		{
			*(int*)b = col | (*(int*)b & 0xff000000);
			b += ty2;

			x += dx;
			if (x >= 0x10000)
			{
				x -= 0x10000;
				b += tx;
			}
		}

		*(int*)b = col | (*(int*)b & 0xff000000);
	}
}

///////////////////////////////////////////////////////////////////////////////
// decode picture from memory (returns NULL on error; returns Canvas with ref=1)

SCanvas* ImgDecode(const u8* buf, int size)
{
	// decode BMP picture
	SCanvas* c = BMPDecode(buf, size);
	if (c != NULL) return c;

	// decode TGA picture
	c = TGADecode(buf, size);
	if (c != NULL) return c;

	// decode PNG picture
	c = PNGDecode(buf, size);
	if (c != NULL) return c;

	// decode JPG picture
	return JPGDecode(buf, size);
}

///////////////////////////////////////////////////////////////////////////////
// load picture from filename (returns NULL on error; returns Canvas with ref=1)

SCanvas* ImgLoad(const CText& filename)
{
	// open file
	FILE* f = _tfopen((LPCTSTR)filename, _T("rb"));
	if (f == NULL) return NULL;

	// get file size
	fseek(f, 0, SEEK_END);
	int size = ftell(f);
	fseek(f, 0, SEEK_SET);

	// create picture buffer
	u8* buf = (u8*)malloc(size);
	if (buf == NULL)
	{
		fclose(f);
		return NULL;
	}

	// load file into buffer
	int n = (int)fread(buf, 1, size, f);
	if (n != size)
	{
		free(buf);
		fclose(f);
		return NULL;
	}

	// decode picture from buffer
	SCanvas* c = ImgDecode(buf, size);

	// delete buffer
	free(buf);

	// close file
	fclose(f);
	return c;
}
