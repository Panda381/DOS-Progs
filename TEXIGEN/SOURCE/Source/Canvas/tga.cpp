
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 TGA file                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// TGA RLE data decompression (returns size of unused input data)
//	dst = destination buffer
//	dstN = size of destination buffer
//	src = source data buffer
//	srcN = size of source data
//	b = number of bytes per pixel 1, 2, 3 or 4

int DekompTGA(BYTE* dst, int dstN, const BYTE* src, int srcN, int b)
{
	int num;				// repeat counter

	// while there is some data
	while ((dstN > 0) && (srcN > b))
	{
		// load head of data packet
		num = *src++;
		srcN--;

		// repeat pixel
		if ((num & 0x80) != 0)
		{
			num = (num & 0x7f) + 1;
			if (num*b > dstN) num = dstN/b;
			dstN -= num*b;
			srcN -= b;
			switch (b)
			{
			case 1:
				memset(dst, *src++, num);
				dst += num;
				break;

			case 2:
				{
					WORD d = *(WORD*)src;
					src += 2;
					for (; num > 0; num--)
					{
						*(WORD*)dst = d;
						dst += 2;
					}
				}
				break;

			case 3:
				{
					WORD d = *(WORD*)src;
					BYTE d2 = src[2];
					src += 3;
					for (; num > 0; num--)
					{
						*(WORD*)dst = d;
						dst[2] = d2;
						dst += 3;
					}
				}
				break;

			case 4:
				{
					DWORD d = *(DWORD*)src;
					src += 4;
					for (; num > 0; num--)
					{
						*(DWORD*)dst = d;
						dst += 4;
					}
				}
				break;
			}
		}
		else
		{
			// copy bytes without a change
			num++;
			if (num*b > dstN) num = dstN/b;
			if (num*b > srcN) num = srcN/b;
			num *= b;
			dstN -= num;
			srcN -= num;
			memcpy(dst, src, num);
			dst += num;
			src += num;
		}
	}
	return srcN;
}

///////////////////////////////////////////////////////////////////////////////
// decode TGA picture, only RGB-24b/RGBA-32b (returns NULL on error; returns Canvas with ref=1)

SCanvas* TGADecode(const u8* buf, int size)
{
	// check TGA header size
	if (size < TGAHEADSIZE) return NULL;

	// get picture parameters
	const TGAHEADER* tga = (TGAHEADER*)buf;
	buf += TGAHEADSIZE;				// skip TGA header
	int w = tga->Width;				// width
	int h = tga->Height;			// height
	int b = tga->BitsPerPixel;		// pixel bits
	int c = tga->DataTypeCode;		// compression
	size -= sizeof(TGAHEADER) + tga->IDLength;	// RLE data size

	// check TGA header
	if ((size <= 0) ||
		(tga->ColourMapLength != 0) || 
		(tga->ColorMapType != 0) ||
		((c != 2) && (c != 10)) ||
		(w < 1) || (w > PICMAXWH) ||
		(h < 1) || (h > PICMAXWH) ||
		((b != 24) && (b != 32)))
		return NULL;

	// skip identification string
	if (tga->IDLength > 0) buf += tga->IDLength;

	// data size
	b /= 8;
	int wb = w*b;
	int size2 = wb*h;
	if ((c == 2) && (size < size2)) return NULL;

	// create destination canvas
	SCanvas* can = NewCanvas(w, h, b);
	if (can == NULL) return NULL;

	// copy or decompression
	if (c == 2)
		memcpy(can->d, buf, size2);
	else
		DekompTGA(can->d, size2, buf, size, b);

	// vertical flip
	if ((tga->ImageDescriptor & B5) != 0) VFlipCanvas(can);

	return can;
}

///////////////////////////////////////////////////////////////////////////////
// save TGA file (returns TRUE if OK)
/*
BOOL TGASave(FILE* file, const BYTE* buf, BYTE* pal, int w, int h, int bb,
														int size, TEXIFMT fmt)
{
	BOOL usepal = (fmt == TEXIFMT_PAL8);

	// prepare TGA file header
	TGAHEADER tga;
	memset(&tga, 0, sizeof(TGAHEADER));
	tga.DataTypeCode = (BYTE)((fmt == TEXIFMT_L8) ? 3 : 2);
	if (usepal)
	{
		tga.ColorMapType = 1;
		tga.DataTypeCode = 1;
		tga.ColourMapLength = 256;
		tga.ColourMapDepth = 24;
	}
	tga.Width = (WORD)w;
	tga.Height = (WORD)h;
	tga.BitsPerPixel = (BYTE)(bb*8);
	if (fmt == TEXXFMT_A1R5G5B5) tga.ImageDescriptor = 1;
	if (fmt == TEXXFMT_A8R8G8B8) tga.ImageDescriptor = 8;

	// save TGA file header
	size_t n = fwrite(&tga, 1, sizeof(TGAHEADER), file);
	if (n != sizeof(TGAHEADER)) return FALSE;

	// save palettes
	if (usepal)
	{
		n = fwrite(pal, 1, 256*3, file);
		if (n != (size_t)(256*3)) return FALSE;
	}

	// save data
	n = fwrite(buf, 1, size, file);
	if ((int)n != size) return FALSE;

	return TRUE;
}
*/
