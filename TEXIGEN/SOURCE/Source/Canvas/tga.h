
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 TGA file                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// TGA file header

#pragma pack(push,1)
typedef struct _TGAHEADER {
	BYTE	IDLength;			// 0: length of identification string
	BYTE	ColorMapType;		// 1: color map type (1=color map, 0=none)
	BYTE	DataTypeCode;		// 2: data type code
								//		0=no image
								//		1=uncompressed, color-mapped
								//		2=uncompressed, RGB
								//		3=uncompressed, B&W
								//		9=RLE color-mapped
								//		10=RLE RGB
								//		11=RLE B&W
	WORD	ColourMapOrigin;	// 3: index of first color map entry
	WORD	ColourMapLength;	// 5: count of color map entries
	BYTE	ColourMapDepth;		// 7: number of bits in each color map entry
								//	  (16:A1R5G5B5, 24:R8G8B8, 32:A8R8G8B8)
	WORD	X_Origin;			// 8: X coordinate of lower left corner
	WORD	Y_Origin;			// 10: Y coordinate of lower left corner
	WORD	Width;				// 12: width of image
	WORD	Height;				// 14: height of image
	BYTE	BitsPerPixel;		// 16: bits per each color value
								//	(16:A1R5G5B5, 24:R8G8B8, 32:A8R8G8B8)
	BYTE	ImageDescriptor;	// 17: image descriptor
								//		bit 0..3: number of alpha channel bits
								//				associated with each pixel
								//				0 or 1 for TGA16, 0 for TGA24,
								//				8 for TGA32
								//		- invalid from some apps,incl.Photoshop
								//		bit 4:	0=origin in left, 1=right
								//		bit 5:	0=origin in bottom, 1=top
								//		bit 6,7: interleaving
								//				0=non interleaved
								//				1=even/odd interleaving
								//				2=four way interleaving
	// - identification string follows (0 to 255 characters)
	// - color map data follows (16, 24 or 32 bits per color entry)
	// - image data follows
	//		RLE:	bit 7:	1=repeat following pixel 1 to 128
	//						0=copy following pixels 1 to 128
} TGAHEADER;
#pragma pack(pop)

#define TGAHEADSIZE sizeof(TGAHEADER) // = 18

/*
///////////////////////////////////////////////////////////////////////////////
// save TGA file (returns TRUE if OK)

BOOL TGASave(FILE* file, const BYTE* buf, BYTE* pal, int w, int h, int bb,
														int size, TEXIFMT fmt);
*/

///////////////////////////////////////////////////////////////////////////////
// decode TGA picture (returns NULL on error; returns Canvas with ref=1)

SCanvas* TGADecode(const u8* buf, int size);
