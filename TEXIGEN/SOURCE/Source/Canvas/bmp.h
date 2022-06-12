
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 BMP file                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// BMP file header

#pragma pack(push,1)

typedef struct _bmpBITMAPFILEHEADER { // 14 bytes
		WORD	bfType;
		DWORD	bfSize;
		WORD	bfReserved1;
		WORD	bfReserved2;
		DWORD	bfOffBits;
} bmpBITMAPFILEHEADER;

typedef struct _bmpBITMAPINFOHEADER{ // 40 bytes
		DWORD	biSize;
		long	biWidth;
		long	biHeight;
		WORD	biPlanes;
		WORD	biBitCount;
		DWORD	biCompression;
		DWORD	biSizeImage;
		long	biXPelsPerMeter;
		long	biYPelsPerMeter;
		DWORD	biClrUsed;
		DWORD	biClrImportant;
} bmpBITMAPINFOHEADER;

// ...or in compact form
typedef struct _BMPHEADER { // 54 bytes
		WORD	bfType;
		DWORD	bfSize;
		WORD	bfReserved1;
		WORD	bfReserved2;
		DWORD	bfOffBits;

		DWORD	biSize;
		long	biWidth;
		long	biHeight;
		WORD	biPlanes;
		WORD	biBitCount;
		DWORD	biCompression;
		DWORD	biSizeImage;
		long	biXPelsPerMeter;
		long	biYPelsPerMeter;
		DWORD	biClrUsed;
		DWORD	biClrImportant;
} BMPHEADER;
#pragma pack(pop)

#define BMPHEADSIZE sizeof(BMPHEADER)

#define bmpBI_RGB	0
#define bmpBI_RLE8	1
#define bmpBI_RLE4	2

////////////////////////////////////////////////////////////////////
// BI_RLE8 data decompression
// missing code 2 - skip delta X 0..255, delta Y 0..255

void DekompRLE8(BYTE* dst, int dstN, const BYTE* src, int srcN, int wb);

////////////////////////////////////////////////////////////////////
// BI_RLE4 data decompression

//void DekompRLE4(BYTE* dst, int dstN, const BYTE* src, int srcN);

/*
///////////////////////////////////////////////////////////////////////////////
// save BMP file, no alpha (returns TRUE if OK)

BOOL BMPSave(FILE* file, const BYTE* buf, int w, int h);
  */

///////////////////////////////////////////////////////////////////////////////
// decode BMP picture (returns NULL on error; returns Canvas with ref=1)

SCanvas* BMPDecode(const u8* buf, int size);
