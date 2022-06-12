
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 BMP file                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

////////////////////////////////////////////////////////////////////
// BI_RLE8 data decompression
// missing code 2 - skip delta X 0..255, delta Y 0..255

void DekompRLE8(BYTE* dst, int dstN, const BYTE* src, int srcN, int wb)
{
	BYTE data;				// one data byte
	BYTE num;				// repeat counter
	int lineoff = 0;		// pixel offset on a line

	// while there is some data (it is only a rough control)
	while ((dstN > 0) && (srcN > 0))
	{
		// load first and second byte
		num = *src;
		src++;
		srcN--;

		data = *src;
		src++;
		srcN--;

		// repeat byte
		if (num != 0)
		{
			if ((int)num > dstN) num = (BYTE)dstN;
			lineoff += num;
			dstN -= num;

			memset(dst, data, num);
			dst += num;
		}
		else
		{
			// copy bytes without a change
			if (data > 2)
			{
				if ((int)data > srcN) data = (BYTE)srcN;
				if ((int)data > dstN) data = (BYTE)dstN;
				lineoff += data;
				dstN -= data;
				srcN -= data;

				memcpy(dst, src, data);
				dst += data;
				src += (data + 1) & ~1;
			}
			else
			{
				// escape code - end of line
				if (data == 0)
				{
					int i = wb - lineoff;
					if (i > dstN) i = dstN;
					if (i > 0)
					{
						dstN -= i;
						memset(dst, 0, i);
						dst += i;
					}
					lineoff = 0;
				}
				else
				{
					// escape code - end of bitmap
					if (data == 1) break;
				}
			}
		}
	}
}

////////////////////////////////////////////////////////////////////
// transfer one pixel
/*
inline void RLE4Store(BOOL& firstdst, BOOL& firstsrc,
									BYTE*& dst, const BYTE& data)
{
	if (firstsrc)
	{
		if (firstdst)
		{
			*dst = (BYTE)(data & 0xf0);
			firstdst = FALSE;
		}
		else
		{
			*dst |= (BYTE)(data >> 4);
			firstdst = TRUE;
			dst++;
		}
		firstsrc = FALSE;
	}
	else
	{
		if (firstdst)
		{
			*dst = (BYTE)(data << 4);
			firstdst = FALSE;
		}
		else
		{
			*dst |= (BYTE)(data & 0xf);
			firstdst = TRUE;
			dst++;
		}
		firstsrc = TRUE;
	}
}
*/
////////////////////////////////////////////////////////////////////
// BI_RLE4 data decompression
/*
void DekompRLE4(BYTE* dst, int dstN, const BYTE* src, int srcN)
{
	BYTE data;					// one data byte
	BYTE olddata;				// old data byte
	BYTE num;					// repeat counter
	int lineoff = 0;			// pixel offset on a line

	BOOL firstdst = TRUE;		// storing first nibble of a byte
	BOOL firstsrc;				// loading first nibble of a byte

	// while there is some data (it is only a rough control)
	while ((dstN > 0) && (srcN > 0))
	{
		// load first and second byte
		num = *src;
		src++;
		srcN--;

		data = *src;
		src++;
		srcN--;

		// loading first nibble of a byte
		firstsrc = TRUE;

		// repeat byte
		if (num != 0)
		{
			if ((int)num > 2*dstN) num = (BYTE)(2*dstN);
			lineoff += num;
			dstN -= num/2;

			for (; num > 0; num--)
			{
				RLE4Store(firstdst, firstsrc, dst, data);
			}
		}
		else
		{
			// copy bytes without a change
			if (data > 2)
			{
				lineoff += data;

				olddata = data;
				srcN -= ((data + 3) & ~3)/2;
				num = (BYTE)(data/2);
				dstN -= num;

				for (; num > 0; num--)
				{
					data = *src;
					src++;
					RLE4Store(firstdst, firstsrc, dst, data);
					RLE4Store(firstdst, firstsrc, dst, data);
				}

				if (olddata & 1)
				{
					data = *src;
					src++;
					RLE4Store(firstdst, firstsrc, dst, data);
				}
				src += (3 - ((olddata-1) & 3))/2;
			}
			else
			{
				// escape code - end of line
				if (data == 0)
				{
					for (lineoff = 7 - ((lineoff+7) & 7); lineoff > 0; lineoff--)
					{
						RLE4Store(firstdst, firstsrc, dst, data);
					}
				}
				else
				{
					// escape code - end of bitmap
					if (data == 1) break;
				}
			}
		}
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// decode BMP picture (returns NULL on error; returns Canvas with ref=1)

SCanvas* BMPDecode(const u8* buf, int size)
{
	// check BMP header size
	if (size < BMPHEADSIZE) return NULL;

	// get picture parameters
	BMPHEADER* bmp = (BMPHEADER*)buf;
	buf += BMPHEADSIZE;
	size -= BMPHEADSIZE;
	int w = bmp->biWidth;
	int wb = (w*3 + 3) & ~3;
	int h = bmp->biHeight;
	BOOL vflip = FALSE;
	if (h < 0)
	{
		vflip = TRUE;
		h = -h;
	}
	int b = bmp->biBitCount;
	int c = bmp->biCompression;

	// data offset and data size
	int off = bmp->bfOffBits - BMPHEADSIZE;
	int size2 = bmp->bfSize - bmp->bfOffBits;
	size -= off;
	buf += off;

	// check BMP file header
	if ((bmp->bfType != 0x4d42) ||
		(off < 0) || (off > 5000) ||
		(size2 > size) || (size2 < 10) ||
		(w < 1) || (w > PICMAXWH) ||
		(h < 1) || (h > PICMAXWH) ||
		(b != 24) ||
		(bmp->biPlanes != 1) ||
		(c != bmpBI_RGB) ||
		(size2 < w*wb-2))
		return NULL;

	// create destination canvas
	SCanvas* can = NewCanvas(w, h, 3);
	if (can == NULL) return NULL;

	// copy image
	if (wb == w*3)
		memcpy(can->d, buf, h*wb);
	else
	{
		u8* dd = can->d;
		for (; h > 0; h--)
		{
			memcpy(dd, buf, w*3);
			dd += w*3;
			buf += wb;
		}
	}

	// vertical flip
	if (vflip) VFlipCanvas(can);

	return can;
}

///////////////////////////////////////////////////////////////////////////////
// save BMP file (returns TRUE if OK)
/*
BOOL BMPSave(FILE* file, const BYTE* buf, SRGBA* pal, int w, int h, int bb,
														int size, TEXIFMT fmt)
{
	BOOL usepal = (fmt == TEXIFMT_PAL8);

	// prepare BMP file header
	bmpBITMAPFILEHEADER bmh;
	bmh.bfType = 0x4d42;
	bmh.bfSize = sizeof(bmpBITMAPFILEHEADER)+sizeof(bmpBITMAPINFOHEADER)+size;
	if (usepal) bmh.bfSize += 256*sizeof(SRGBA);
	bmh.bfReserved1 = 0;
	bmh.bfReserved2 = 0;
	bmh.bfOffBits = bmh.bfSize - size;

	// save BMP file header
	size_t n = fwrite(&bmh, 1, sizeof(bmpBITMAPFILEHEADER), file);
	if (n != sizeof(bmpBITMAPFILEHEADER)) return FALSE;

	// prepare BMP info header
	bmpBITMAPINFOHEADER bmi;
	bmi.biSize = sizeof(bmpBITMAPINFOHEADER);
	bmi.biWidth = w;
	bmi.biHeight = h;
	bmi.biPlanes = 1;
	bmi.biBitCount = (WORD)(bb*8);
	bmi.biCompression = bmpBI_RGB;
	bmi.biSizeImage = size;
	bmi.biXPelsPerMeter = 5906;
	bmi.biYPelsPerMeter = 5906;
	bmi.biClrUsed = 0;
	bmi.biClrImportant = 0;

	// save BMP info header
	n = fwrite(&bmi, 1, sizeof(bmpBITMAPINFOHEADER), file);
	if (n != sizeof(bmpBITMAPINFOHEADER)) return FALSE;

	// save palettes
	if (usepal)
	{
		n = fwrite(pal, 1, 256*sizeof(SRGBA), file);
		if (n != (size_t)(256*sizeof(SRGBA))) return FALSE;
	}

	// save data
	n = fwrite(buf, 1, size, file);
	if ((int)n != size) return FALSE;

	return TRUE;
}
*/
