
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 PNG file                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

const u8* PNGInputBuf;
int PNGInputSize;

// chunk identifiers
#define CHUNK_IEND	0x444e4549		// end of file 'IEND'
#define CHUNK_IHDR	0x52444849		// header 'IHDR'
#define CHUNK_PLTE	0x45544c50		// palette 'PLTE'
#define CHUNK_IDAT	0x54414449		// data 'IDAT'
#define CHUNK_tRNS	0x534e5274		// transparency 'tRNS'

// PNG IHDR header format (size 13 bytes)
#pragma pack(push,1)
typedef struct {
	DWORD	width;				// image width
	DWORD	height;				// image height
	BYTE	bitdepth;			// number of bits per color sample or index
	BYTE	colortype;			// color type (see below)
	BYTE	compression;
	BYTE	filter;
	BYTE	interlace;
}PNGHeader;
#pragma pack(pop)

// color type
#define COLTYPE_GRAY	0		// 1 grayscale sample, 1/2/4/8/16 bits
#define COLTYPE_RGB		2		// RGB triple of samples, 8/16 bits
#define COLTYPE_PAL		3		// palette index, 1/2/4/8 bits
#define COLTYPE_GRAYA	4		// 1 grayscale + 1 alpha sample, 8/16 bits
#define COLTYPE_RGBA	6		// RGB triple + 1 alpha sample, 8/16 bits

// CRC table
DWORD PNG_CRC[256];
BOOL PNGGenCRC();
BOOL CRC_Init = PNGGenCRC();

// buffers
BYTE*	PNGInBuf = NULL;			// data input buffer (=chunk data)
BYTE*	PNGInData = NULL;			// input data buffer
int		PNGInDataSize;				// input data buffer size
BYTE*	PNGInSrc;					// source pointer
BYTE*	PNGInEnd;					// end of input buffer
DWORD	PNGInSize;					// size of input buffer (=chunk length)

BYTE*	PNGRow[2];					// row buffers
int		PNGRowSize;					// size of image row
int		PNGRowInx;					// index of current row buffer

BYTE*	PNGOutBuf = NULL;			// data output buffer
BYTE*	PNGOutDst;					// destination pointer
BYTE*	PNGOutEnd;					// end of output buffer

SRGBA*	PNGPal = NULL;			// palette buffer

int		PNGW;						// width
int		PNGH;						// height
int		PNGBits;					// color bits per sample (1, 2, 4, 8, 16)
int		PNGBytes;					// color bytes per pixel (1, 2, 3, 4)
int		PNGColType;					// color type (COLTYPE_*)
SRGBA	PNGTransCol;				// transparent color
BOOL	PNGTransPal;				// use transparent palettes
BOOL	PNGUseTrans;				// use transparent color
BOOL	PNGInter;					// interlaced mode

int		PNGInterPass;				// current interlace pass

// LZ77 inflate decoder
DWORD	LZAdler32;					// Adler32 checksum
BYTE*	LZWin = NULL;				// LZ77 sliding window
DWORD	LZWinPos;					// output window position
DWORD	LZCopyPos;					// input copy position
DWORD	LZCopyCount;				// remaining LZ77 copy bytes
BOOL	LZFinalDataSet;				// final data set is read
int		LZWinSize;					// LZ77 sliding window size

int		LZBitPos;					// current bit position
BOOL	LZBitMode;					// reader is in bit mode

WORD	LZLitCount;					// remaining literal bytes

// Huffman decoder
class HuffmanDecoder
{
public:

	DWORD	m_maxcodesize;			// maximum code size
	DWORD	m_valuecount;			// number of values
	int*	m_maxcode;				// maximum Huffman code values
	int*	m_mincode;				// minimum Huffman code values
	DWORD*	m_valinx;				// indexes into minimum codes table
	DWORD*	m_values;				// values

	// constructor
	HuffmanDecoder()
	{
		m_maxcodesize = 0;
		m_valuecount = 0;
		m_maxcode = NULL;
		m_mincode = NULL;
		m_valinx = NULL;
		m_values = NULL;
	}

	// delete buffers
	void Delete()
	{
		free(m_maxcode);	m_maxcode = NULL;
		free(m_mincode);	m_mincode = NULL;
		free(m_valinx);		m_valinx = NULL;
		free(m_values);		m_values = NULL;
	}

	// destructor
	~HuffmanDecoder() { Delete(); }

	// initialize Huffman table (returns FALSE on error)
	BOOL MakeTable(DWORD maxcodesize, DWORD valuecount, 
												const DWORD* codelengths);

	// decode next value
	int Decode();

	// read Huffman length table (returns FALSE on error)
	BOOL ReadLengths(DWORD* lengths, DWORD count);
};

HuffmanDecoder	LZLit;				// Huffman literal
HuffmanDecoder	LZDist;				// Huffman distances
HuffmanDecoder	LZTemp;				// temporary decoder

#define INTERPASSES 7				// count of interlace passes

#define LZWINSIZE	(1 << 15)
#define LZWINMASK	(LZWINSIZE-1)
#define BADCODE 0xfffffff

#define LZMAXDISTANCECODESIZE 15
#define LZMAXLENGTHCODESIZE 15
#define LZMAXLENGTHLENGTHCODES 19
#define LZMAXLENGTHLENGTHCODESIZE 7

#define LZMAXLENGTHCODES 286
#define LZFIRSTLENGTHCODE 257
#define LZLENGTHCODECOUNT (LZMAXLENGTHCODES-LZFIRSTLENGTHCODE)
#define LZMAXDISTANCECODES 30
#define LZLITERALCOUNT 256
#define LZENDCODE LZLITERALCOUNT

// row filter type
#define FILTERNONE 0
#define FILTERSUB 1
#define FILTERUP 2
#define FILTERAVERAGE 3
#define FILTERPATH 4

// order of length codes
const BYTE LZDeflOrder[LZMAXLENGTHLENGTHCODES] = 
{
	16, 17, 18, 0,  8, 7,  9, 6, 10, 5,
	11,  4, 12, 3, 13, 2, 14, 1, 15,
};

const DWORD LZBitMask[9] = { 0, 1, 3, 7, 0xf, 0x1f, 0x3f, 0x7f, 0xff };

// lenths of fixed Huffman table
const DWORD LZLenTab[288] = 
{
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8,
};

// distances of fixed Huffman table
const DWORD LZDistTab[32] = 
{
	5, 5, 5, 5, 5, 5, 5, 5,
	5, 5, 5, 5, 5, 5, 5, 5,
	5, 5, 5, 5, 5, 5, 5, 5,
	5, 5, 5, 5, 5, 5, 5, 5,
};

// number of extra bits for code - 257
const int LZLenExt[LZLENGTHCODECOUNT] =
{
	0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2,
	2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0,
};

// base length for code - 257
const int LZLenBase[LZLENGTHCODECOUNT] =
{
	 3,   4,   5,   6,   7,   8,   9,  10,  11,  13,
	15,  17,  19,  23,  27,  31,  35,  43,  51,  59,
	67,  83,  99, 115, 131, 163, 195, 227, 258
};

// number of extra bits for distance
const int LZDistExt[LZMAXDISTANCECODES] =
{
	0,  0,  0,  0,  1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,
	6,  7,  7,  8,  8,  9,  9, 10, 10, 11, 11, 12, 12, 13, 13,
};

// base distance
const int LZDistBase[LZMAXDISTANCECODES] =
{
	   1,    2,     3,     4,     5,    7,    9,    13,    17,    25,
	  33,   49,    65,    97,   129,  193,  257,   385,   513,   769,
	1025, 1537,  2049,  3073,  4097, 6145, 8193, 12289, 16385, 24577,
};

// Adam7 interlace pattern
struct InterlaceInfo
{
	DWORD	rowinterval;
	DWORD	colinterval;
	DWORD	startrow;
	DWORD	startcol;
};

const InterlaceInfo LZInterlace[INTERPASSES] =
{
	{8, 8, 0, 0, },
	{8, 8, 0, 4, },
	{8, 4, 4, 0, },
	{4, 4, 0, 2, },
	{4, 2, 2, 0, },
	{2, 2, 0, 1, },
	{2, 1, 1, 0, },
};

///////////////////////////////////////////////////////////////////////////////
// generate PNG CRC table

BOOL PNGGenCRC()
{
	for(DWORD i = 0; i < 256; i++)
	{
		PNG_CRC[i] = i;
		for (int j = 0; j < 8; j++)
		{
			if ((PNG_CRC[i] & 1) == 0)
				PNG_CRC[i] >>= 1;
			else
				PNG_CRC[i] = 0xedb88320 ^ (PNG_CRC[i] >> 1);
		}
	}

	PNGRow[0] = NULL;
	PNGRow[1] = NULL;
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// delete PNG buffers on error

void PNGDelBuf()
{
	PNGInputSize = 0;

	// data input buffer (=chunk data)
	free(PNGInBuf);
	PNGInBuf = NULL;

	// row buffers
	free(PNGRow[0]);
	PNGRow[0] = NULL;
	free(PNGRow[1]);
	PNGRow[1] = NULL;

	// data output buffer
	free(PNGOutBuf);
	PNGOutBuf = NULL;

	// palette buffer
	free(PNGPal);
	PNGPal = NULL;

	// LZ77 sliding window
	free(LZWin);
	LZWin = NULL;

	// input data buffer
	free(PNGInData);
	PNGInData = NULL;
	PNGInDataSize = 0;
}

///////////////////////////////////////////////////////////////////////////////
// calculate CRC of a chunk

DWORD PNGGetCRC(long type, BYTE* data, int len)
{
	DWORD crc = (DWORD)-1;
	int i;

	// get CRC of chunk type
	for (i = 0; i < 4; i++)
	{
		crc = PNG_CRC[(crc ^ ((BYTE*)&type)[i]) & 0xff] ^ (crc >> 8);
	}

	// get CRC of chunk data
	for (i = 0; i < len; i++)
	{
		crc = PNG_CRC[(crc ^ data[i]) & 0xff] ^ (crc >> 8);
	}
	return ~crc;
}

///////////////////////////////////////////////////////////////////////////////
// read data into buffer (returns FALSE on error)

BOOL PNGReadData(void* buf, int size)
{
	int n = PNGInputSize;
	if (n > size) n = size;
	memcpy(buf, PNGInputBuf, n);
	PNGInputBuf += n;
	PNGInputSize -= n;
	return n == size;
}

///////////////////////////////////////////////////////////////////////////////
// read LONG number (returns FALSE on error)

inline BOOL PNGReadLong(DWORD* data)
{
	if (!PNGReadData(data, sizeof(DWORD))) return FALSE;
	*data = BigLit4(*data);
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// read one byte from input buffer

BYTE LZReadByte()
{
	if (PNGInSrc < PNGInEnd)
		return *PNGInSrc++;
	else
		return 0;
}

///////////////////////////////////////////////////////////////////////////////
// read one word from input buffer

WORD LZReadWord()
{
	BYTE b1 = LZReadByte();
	BYTE b2 = LZReadByte();
	return (WORD)(b1 | (b2 << 8));
}

///////////////////////////////////////////////////////////////////////////////
// read DWORD from input buffer

DWORD LZReadDWord()
{
	BYTE b1 = LZReadByte();
	BYTE b2 = LZReadByte();
	BYTE b3 = LZReadByte();
	BYTE b4 = LZReadByte();
	return (DWORD)(b1 | (b2 << 8) | (b3 << 16) | (b4 << 24));
}

///////////////////////////////////////////////////////////////////////////////
// enter bit mode

void LZEnterBitMode(int pos)
{
	if (!LZBitMode)
	{
		LZBitMode = TRUE;
		LZBitPos = pos;
	}
}

///////////////////////////////////////////////////////////////////////////////
// exit bit mode

void LZExitBitMode()
{
	if ((LZBitPos >= 0) && (PNGInSrc < PNGInEnd)) PNGInSrc++;
	LZBitMode = FALSE;
	LZBitPos = -1;
}

///////////////////////////////////////////////////////////////////////////////
// get bits from input buffer

int LZGetBits(int bits)
{
	// no data in input buffer left
	if (PNGInSrc >= PNGInEnd) return 0;

	// there is enough bits in current byte
	int res;
	if (bits <= 8 - LZBitPos)
	{
		res = (*PNGInSrc >> LZBitPos) & LZBitMask[bits];
		LZBitPos += bits;
	}
	else
	{
		res = 0;
		int bitsok = 0;

		// get remaining bits in current byte
		if (LZBitPos < 8)
		{
			bitsok = 8 - LZBitPos;
			res = (*PNGInSrc >> LZBitPos) & LZBitMask[bitsok];
			bits -= bitsok;
		}

		// get rest of bits
		while (bits > 0)
		{
			// increase read pointer
			PNGInSrc++;
			if (PNGInSrc >= PNGInEnd) return res;

			if (bits > 8)
			{
				bits -= 8;
				res |= (*PNGInSrc << bitsok);
				bitsok += 8;
			}
			else
			{
				res |= (*PNGInSrc & LZBitMask[bits]) << bitsok;
				LZBitPos = bits;
				break;
			}
		}
	}
	return res;
}

///////////////////////////////////////////////////////////////////////////////
// initialize Huffman table (returns FALSE on error)

BOOL HuffmanDecoder::MakeTable(DWORD maxcodesize, DWORD valuecount, 
												const DWORD* codelengths)
{
	DWORD i, j, k;
	m_maxcodesize = maxcodesize;
	m_valuecount = valuecount;

	// create buffers
	Delete();
	m_maxcode = (int*)malloc(maxcodesize*sizeof(int));
	m_mincode = (int*)malloc(maxcodesize*sizeof(int));
	m_valinx = (DWORD*)malloc(valuecount*sizeof(DWORD));
	m_values = (DWORD*)malloc(valuecount*sizeof(DWORD));
	if ((m_maxcode == NULL) || (m_mincode == NULL) || (m_valinx == NULL) ||
											(m_values == NULL)) return FALSE;

	// temporary buffer for code sizes
	DWORD* buffsizes = (DWORD*)malloc((valuecount+1)*sizeof(DWORD));
	if (buffsizes == NULL) return FALSE;

	// initialize table of values
	for (i = 0; i < valuecount; i++)
	{
		m_values[i] = i;
		buffsizes[i] = codelengths[i];
	}

	// sort table of values
	for (i = 0; i < valuecount-1; i++)
	{
		for (j = i+1; j < valuecount; j++)
		{
			if ((buffsizes[j] < buffsizes[i]) ||
				((buffsizes[j] == buffsizes[i]) &&
					(m_values[j] < m_values[i])))
			{
				k = buffsizes[j];
				buffsizes[j] = buffsizes[i];
				buffsizes[i] = k;
				k = m_values[j];
				m_values[j] = m_values[i];
				m_values[i] = k;
			}
		}
	}

	// temporary buffer for Huffman codes
	DWORD* buffcodes = (DWORD*)malloc(valuecount*sizeof(DWORD));
	if (buffcodes == NULL) { free(buffsizes); return FALSE; }

	// initialize Huffman codes
	DWORD lastlen = 0;
	DWORD code = 0;
	for (i = 0; i < valuecount; i++)
	{
		while(lastlen != buffsizes[i])
		{
			lastlen++;
			code <<= 1;
		}

		if (lastlen != 0)
		{
			buffcodes[i] = code;
			code++;
		}
	}

	// initialize tables
	for (i = 0; i < maxcodesize; i++)
	{
		m_mincode[i] = BADCODE;
		m_maxcode[i] = (DWORD)-1;
	}

	for (i = 0; i < valuecount; i++) m_valinx[i] = 0;

	DWORD last = 0;
	for (i = 0; i < valuecount; i++)
	{
		if (last != buffsizes[i])
		{
			last = buffsizes[i];
			m_valinx[last-1] = i;
			m_mincode[last-1] = buffcodes[i];
		}

		if (last != 0) m_maxcode[last-1] = buffcodes[i];
	}
	free(buffsizes);
	free(buffcodes);
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// decode next value

int HuffmanDecoder::Decode()
{
	// read code ("1" bit is prefix of longer code)
	int code = LZGetBits(1);
	DWORD codelength;
	for (codelength = 0; code > m_maxcode[codelength]; codelength++)
	{
		if (codelength >= m_maxcodesize) return 0;
		code = ((code << 1) | LZGetBits(1));
	}
	int offset = code - m_mincode[codelength];
	int index = m_valinx[codelength] + offset;
	return m_values[index];
}

///////////////////////////////////////////////////////////////////////////////
// read Huffman length table (returns FALSE on error)
//	0..15 = literal length value
//	16 = repeat last code N-times, N = next 2 bits + 3
//	17 = set N length codes to 0, N = next 3 bits + 3
//	18 = set N length codes to 0, N = next 7 bits + 11

BOOL HuffmanDecoder::ReadLengths(DWORD* lengths, DWORD count)
{
	DWORD i, k;
	for (i = 0; i < count;)
	{
		int cmd = Decode();

		// length value
		if (cmd < 16)
		{
			lengths[i] = cmd;
			i++;
		}

		// repeat last code
		else if (cmd == 16)
		{
			int n = LZGetBits(2) + 3;
			if (i == 0) return FALSE;
			k = lengths[i-1];
			if ((i + n) > count) return FALSE;
			for (; n > 0; n--)
			{
				lengths[i] = k;
				i++;
			}
		}

		// short fill with zero
		else if (cmd == 17)
		{
			int n = LZGetBits(3) + 3;
			if ((i + n) > count) return FALSE;
			for (; n > 0; n--)
			{
				lengths[i] = 0;
				i++;
			}
		}

		// long fill with zero
		else if (cmd == 18)
		{
			int n = LZGetBits(7) + 11;
			if ((i + n) > count) return FALSE;
			for (; n > 0; n--)
			{
				lengths[i] = 0;
				i++;
			}
		}

		// invalid code
		else
			return FALSE;
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// start new LZ77 data set (return FALSE on error)

BOOL LZStartNewDataSet()
{
	// enter bit mode
	LZEnterBitMode(0);

	// check final data set
	LZFinalDataSet = LZGetBits(1) != 0; 

	// compression type
	int compressiontype = LZGetBits(2);

	switch (compressiontype)
	{
	// uncompressed
	case 0:
		{
			LZExitBitMode();
			LZLitCount = LZReadWord();
			WORD testcount = LZReadWord();
			if ((LZLitCount != (WORD)~testcount) || (LZLitCount == 0)) return FALSE;
		}
		break;

	// fixed Huffman codes
	case 1:
		if (!LZLit.MakeTable(LZMAXLENGTHCODESIZE, 288, LZLenTab)) return FALSE;
		if (!LZDist.MakeTable(LZMAXDISTANCECODESIZE, 32, LZDistTab))
			return FALSE;
		LZLitCount = 0;
		break;

	// dynamic Huffman codes
	case 2:
		{
			DWORD hlit = LZGetBits(5);	// literal code count - 257
			DWORD hdist = LZGetBits(5);	// distance codes - 1
			DWORD hclen = LZGetBits(4);	// count of length codes - 4
			if ((hclen + 4) > LZMAXLENGTHLENGTHCODES) return FALSE;

			// read length codes
			DWORD lengths[LZMAXLENGTHLENGTHCODES];
			memset(lengths, 0, sizeof(lengths));
			DWORD i;
			for (i = 0; i < hclen+4; i++)
			{
				lengths[LZDeflOrder[i]] = LZGetBits(3);
			}

			// make table in temporary decoder
			if (!LZTemp.MakeTable(LZMAXLENGTHLENGTHCODESIZE,
                  LZMAXLENGTHLENGTHCODES, lengths)) return FALSE;

			// read literal codes
			DWORD literals [288];
			if (!LZTemp.ReadLengths(literals, hlit + 257)) return FALSE;

			// read distance codes
			DWORD distances[32];
			if (!LZTemp.ReadLengths(distances, hdist + 1)) return FALSE;

			// make Huffman tables
			if (!LZLit.MakeTable(LZMAXLENGTHCODESIZE, hlit+257, literals))
				return FALSE;
			if (!LZDist.MakeTable(LZMAXDISTANCECODESIZE, hdist+1, distances))
				return FALSE;
			LZLitCount = 0;
			break;
		}
		break;

	// 3 is invalid mode
	default:
		return FALSE;
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// initialize LZ77 decoder (return FALSE on error)

BOOL LZInit()
{
	LZFinalDataSet = FALSE;
	LZBitMode = FALSE;
	LZBitPos = -1;
	
	LZWin = (BYTE*)malloc(LZWINSIZE);
	if (LZWin == NULL) return FALSE;
	memset(LZWin, 0, LZWINSIZE);

	LZAdler32 = 1;
	LZWinPos = 0;
	LZCopyPos = 0;
	LZCopyCount = 0;

	// read compressed stream header BYTE 1
	BYTE d1 = LZReadByte();
	if ((d1 & 0xf) != 8) return FALSE; // compression method DEFLATED
	LZWinSize = (1 << (((d1 & 0xf0) >> 4) + 8)); // window size
	if (LZWinSize > LZWINSIZE) return FALSE;

	// read compressed stream header BYTE 2
	BYTE d2 = LZReadByte();
	if ((d2 & (1 << 5)) != 0) return FALSE; // preset dictionary

	// corrupt compression header
	if (((d2 | (d1 << 8)) % 31) != 0) return FALSE;

	// start new data set
	return LZStartNewDataSet();
}

///////////////////////////////////////////////////////////////////////////////
// add Adler32 checksum

void LZAdler(BYTE value)
{
#define ADLER_PRIME 65521
	DWORD low = LZAdler32 & 0xffff;
	DWORD hgh = (LZAdler32 >> 16);
	low = (low + value) % ADLER_PRIME;
	hgh = (low + hgh) % ADLER_PRIME;
	LZAdler32 = (hgh << 16) | low;
}

///////////////////////////////////////////////////////////////////////////////
// check Adler32 checksum (returns FALSE on error)

BOOL LZCheckAddler()
{
	LZExitBitMode();
	DWORD val = LZReadDWord();
	return val == LZAdler32;
}

///////////////////////////////////////////////////////////////////////////////
// decode LZ77 data (returns number of bytes or 0 on error)

int LZDecode(BYTE* buf, DWORD count)
{
	DWORD i = 0;
	DWORD val, len, dist;
	int ext;
	BYTE res;
	while (i < count)
	{
		// transfer data without compression
		if (LZLitCount > 0)
		{
			while ((LZLitCount > 0) && (i < count))
			{
				LZLitCount--;
				res = LZReadByte();
				LZWin[LZWinPos] = res;
				LZWinPos = (LZWinPos + 1) & LZWINMASK;
				LZAdler(res);
				buf[i] = res;
				i++;
			}

			// start new data set or stop
			if (LZLitCount == 0)
			{
				if (LZFinalDataSet)
				{
					if (!LZCheckAddler()) return 0;
				}
				else
				{
					if (!LZStartNewDataSet()) return 0;
				}
			}
		}

		// copy old data stream
		else if (LZCopyCount > 0)
		{
			while ((LZCopyCount > 0) && (i < count))
			{
				LZCopyCount--;
				res = LZWin[LZCopyPos];
				LZWin[LZWinPos] = res;
				LZCopyPos = (LZCopyPos + 1) & LZWINMASK;
				LZWinPos = (LZWinPos + 1) & LZWINMASK;
				LZAdler(res);
				buf[i] = res;
				i++;
			}
		}

		// deflate compression 
		else
		{
			// read next code
			val = LZLit.Decode();

			// data value
			if (val < LZLITERALCOUNT)
			{
				res = (BYTE)val;
				LZWin[LZWinPos] = res;
				LZWinPos = (LZWinPos + 1) & LZWINMASK;
				LZAdler(res);
				buf[i] = res;
				i++;
			}

			// end marker - start new data set or stop
			else if (val == LZENDCODE)
			{
				if (LZFinalDataSet)
				{
					if (!LZCheckAddler()) return 0;
					return i;
				}
				else
				{
					if (!LZStartNewDataSet()) return 0;
				}
			}

			// code to copy old string
			else if (val < LZMAXLENGTHCODES)
			{
				// prepare length of string
				ext = LZLenExt[val - LZFIRSTLENGTHCODE];
				len = LZLenBase[val - LZFIRSTLENGTHCODE];
				if (ext > 0) len += LZGetBits(ext);

				// prepare distance of string
				val = LZDist.Decode();
				if (val > 29) return 0;
				ext = LZDistExt[val];
				dist = LZDistBase[val];
				if (ext > 0) dist += LZGetBits(ext);

				// prepare state variables
				LZCopyPos = (LZWINSIZE + LZWinPos - dist) & LZWINMASK;
				LZCopyCount = len;

				// get first byte
				res = LZWin[LZCopyPos];
				LZWin[LZWinPos] = res;
				LZCopyPos = (LZCopyPos + 1) & LZWINMASK;
				LZWinPos = (LZWinPos + 1) & LZWINMASK;
				LZCopyCount--;
				LZAdler(res);
				buf[i] = res;
				i++;
			}

			// invalid code
			else return 0;
		}
	}
	return i;
}

///////////////////////////////////////////////////////////////////////////////
// path predictor

BYTE LZPathPredictor(BYTE left, BYTE up, BYTE upleft)
{
	int pp = left + up - upleft;
	int pa, pb, pc;

	if (pp > left)
		pa = pp - left;
	else
		pa = left - pp;

	if (pp > up)
		pb = pp - up;
	else
		pb = up - pp;

	if (pp > upleft)
		pc = pp - upleft;
	else
		pc = upleft - pp;

	if ((pa <= pb) && (pa <= pc)) return left;
	if (pb <= pc) return up;
	return upleft;
}

///////////////////////////////////////////////////////////////////////////////
// filter row

void LZFilter(int filter, int size)
{
	int lastrow = PNGRowInx ^ 1;		// index of previous raw
	int off = PNGBytes;					// pixel width
	int i;
	BYTE up, left, upleft;

	switch(filter)
	{
	// no filter
	case FILTERNONE:
		break;

	// subtract previous value
	case FILTERSUB:
		for (i = off; i < size; i++)
			PNGRow[PNGRowInx][i] = (BYTE)(PNGRow[PNGRowInx][i] +
										PNGRow[PNGRowInx][i-off]);
		break;

	// subtract previous row
	case FILTERUP:
		for (i = 0; i < size; i++)
			PNGRow[PNGRowInx][i] = (BYTE)(PNGRow[PNGRowInx][i] +
											PNGRow[lastrow][i]);
		break;

	// subtract average of previous value and previous row
	case FILTERAVERAGE:
		for (i = 0; i < size; i++)
		{
			up = PNGRow[lastrow][i];
			if (i < off)
				left = 0;
			else
				left = PNGRow[PNGRowInx][i-off];
			PNGRow[PNGRowInx][i] = (BYTE)(PNGRow[PNGRowInx][i] + (left+up)/2);
		}
		break;

	// path predictor 
	case FILTERPATH:
		for (i = 0; i < size; i++)
		{
			up = PNGRow[lastrow][i];
			if (i < off)
			{
				left = 0;
				upleft = 0;
			}
			else
			{
				left = PNGRow[PNGRowInx][i-off];
				upleft = PNGRow[lastrow][i-off];
			}
			PNGRow[PNGRowInx][i] = (BYTE)(PNGRow[PNGRowInx][i] +
								LZPathPredictor(left, up, upleft));
		}
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// copy non-interlaced row to image buffer

void LZCopyNonint(int row)
{
	int i;
	BYTE* dst = PNGOutBuf+row*PNGW*PNGBytes;
	BYTE* src = PNGRow[PNGRowInx];

	switch (PNGColType)
	{
	case COLTYPE_GRAY:
		switch (PNGBits)
		{
		case 1:
			for (i = 0; i < PNGW; i++)
			{
				*dst++ = (BYTE)((src[i/8] & (1 << (7 - (i&7)))) == 0 ? 0:255);
			}
			break;

		case 2:
			for (i = 0; i < PNGW; i++)
			{
				*dst++ = Col2To8((src[i/4] >> (6 - 2*(i & 3))) & 3);
			}
			break;

		case 4:
			for (i = 0; i < PNGW; i++)
			{
				if ((i & 1) == 0)
					*dst++ = Col4To8((src[i/2] >> 4) & 0xf);
				else
					*dst++ = Col4To8(src[i/2] & 0xf);
			}
			break;
		default:
			memcpy(dst, src, PNGW);
		}
		break;

	case COLTYPE_RGB:
		for (i = 0; i < PNGW; i++)
		{
			*dst++ = src[2];
			*dst++ = src[1];
			*dst++ = src[0];
			src += 3;
		}
		break;

	case COLTYPE_PAL:
		switch (PNGBits)
		{
		case 1:
			for (i = 0; i < PNGW; i++)
			{
				*dst++ = (BYTE)((src[i/8] >> (7 - (i & 7))) & 1);
			}
			break;

		case 2:
			for (i = 0; i < PNGW; i++)
			{
				*dst++ = (BYTE)((src[i/4] >> (6 - 2*(i & 3))) & 3);
			}
			break;

		case 4:
			for (i = 0; i < PNGW; i++)
			{
				if ((i & 1) == 0)
					*dst++ = (BYTE)((src[i/2] >> 4) & 0xf);
				else
					*dst++ = (BYTE)(src[i/2] & 0xf);
			}
			break;
		default:
			memcpy(dst, src, PNGW);
		}
		break;

	case COLTYPE_GRAYA:
		memcpy(dst, src, PNGW*2);
		break;

	case COLTYPE_RGBA:
		for (i = 0; i < PNGW; i++)
		{
			*dst++ = src[2];
			*dst++ = src[1];
			*dst++ = src[0];
			*dst++ = src[3];
			src += 4;
		}
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// copy interlaced row to image buffer

void LZCopyInt(int row, int pixels, const InterlaceInfo* info)
{
	int i = 0;
	BYTE* dst = PNGOutBuf + row*PNGW*PNGBytes + info->startcol*PNGBytes;
	BYTE* src = PNGRow[PNGRowInx];

	switch (PNGColType)
	{
	case COLTYPE_GRAY:
		switch (PNGBits)
		{
		case 1:
			for (i = 0; i < pixels; i++)
			{
				*dst = (BYTE)((src[i/8] & (1 << (7 - (i & 7)))) == 0 ? 0:255);
				dst += info->colinterval;
			}
			break;

		case 2:
			for (i = 0; i < pixels; i++)
			{
				*dst = Col2To8((src[i/4] >> (6 - 2*(i & 3))) & 3);
				dst += info->colinterval;
			}
			break;

		case 4:
			for (i = 0; i < pixels; i++)
			{
				if ((i & 1) == 0)
					*dst = Col4To8((src[i/2] >> 4) & 0xf);
				else
					*dst = Col4To8(src[i/2] & 0xf);
				dst += info->colinterval;
			}
			break;
		default:
			for (i = 0; i < pixels; i++)
			{
				*dst = *src;
				src++;
				dst += info->colinterval;
			}
		}
		break;

	case COLTYPE_RGB:
		for (i = 0; i < pixels; i++)
		{
			dst[0] = src[2];
			dst[1] = src[1];
			dst[2] = src[0];
			dst += info->colinterval*3;
			src += 3;
		}
		break;

	case COLTYPE_PAL:
		switch (PNGBits)
		{
		case 1:
			for (i = 0; i < pixels; i++)
			{
				*dst = (BYTE)((src[i/8] >> (7 - (i & 7))) & 1);
				dst += info->colinterval;
			}
			break;

		case 2:
			for (i = 0; i < pixels; i++)
			{
				*dst = (BYTE)((src[i/4] >> (6 - 2*(i & 3))) & 3);
				dst += info->colinterval;
			}
			break;

		case 4:
			for (i = 0; i < pixels; i++)
			{
				if ((i & 1) == 0)
					*dst = (BYTE)((src[i/2] >> 4) & 0xf);
				else
					*dst = (BYTE)(src[i/2] & 0xf);
				dst += info->colinterval;
			}
			break;
		default:
			for (i = 0; i < pixels; i++)
			{
				*dst = *src;
				src++;
				dst += info->colinterval;
			}
		}
		break;

	case COLTYPE_GRAYA:
		for (i = 0; i < pixels; i++)
		{
			dst[0] = src[0];
			dst[1] = src[1];
			src += 2;
			dst += info->colinterval*2;
		}
		break;

	case COLTYPE_RGBA:
		for (i = 0; i < pixels; i++)
		{
			dst[0] = src[2];
			dst[1] = src[1];
			dst[2] = src[0];
			dst[3] = src[3];
			src += 4;
			dst += info->colinterval*4;
		}
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// read non-interlaced data (returns FALSE on error)

BOOL LZReadNonint()
{
	// clear row buffers
	memset(PNGRow[0], 0, PNGRowSize);
	memset(PNGRow[1], 0, PNGRowSize);
	PNGRowInx = 0;

	// read all rows
	DWORD i;
	BYTE filter;
	for (i = 0; i < (DWORD)PNGH; i++)
	{
		// get filter mode
		if ((LZDecode(&filter, 1) != 1) || (filter > 4)) return FALSE;

		// read one row
		if (LZDecode(PNGRow[PNGRowInx],PNGRowSize) != PNGRowSize) return FALSE;

		// filter row
		LZFilter(filter, PNGRowSize);

		// copy row to image buffer
		LZCopyNonint(i);

		// switch buffer
		PNGRowInx ^= 1;
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// read interlaced data (returns FALSE on error)

BOOL LZReadInt()
{
	DWORD i;
	BYTE filter;

	for (PNGInterPass = 0; PNGInterPass < INTERPASSES; PNGInterPass++)
	{
		// interlace values
		const InterlaceInfo* info = LZInterlace + PNGInterPass;

		// check image size
		if (((int)info->startrow < PNGH) && ((int)info->startcol < PNGW))
		{
			// clear row buffers
			memset(PNGRow[0], 0, PNGRowSize);
			memset(PNGRow[1], 0, PNGRowSize);
			PNGRowInx = 0;

			// pixels per this row
			DWORD pixels = (PNGW - info->startcol + info->colinterval - 1)
														/ info->colinterval;

			// bytes per this row
			DWORD rowbytes = (pixels*PNGBytes*PNGBits + 7)/8;

			// read all rows
			for (i = info->startrow; i < (DWORD)PNGH; i += info->rowinterval)
			{
				// get filter mode
				if ((LZDecode(&filter, 1) != 1) || (filter > 4)) return FALSE;

				// read one row
				if (LZDecode(PNGRow[PNGRowInx], rowbytes) != (int)rowbytes)
					return FALSE;

				// filter row
				LZFilter(filter, rowbytes);

				// copy row to image buffer
				LZCopyInt(i, pixels, info);

				// switch buffer
				PNGRowInx ^= 1;
			}
		}
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// decode PNG picture (returns NULL on error; returns Canvas with ref=1)

SCanvas* PNGDecode(const u8* buf, int size)
{
	// check PNG signature
	if ((size < 100) || (buf[0] != 0x89) || (buf[1] != 'P') || (buf[2] != 'N') ||
		(buf[3] != 'G') || (buf[4] != 13) || (buf[5] != 10) ||
		(buf[6] != 26) || (buf[7] != 10)) return NULL;

	// prepare data
	int i;
	PNGW = 0;				// width
	PNGH = 0;				// height
	PNGTransPal = FALSE;	// use transparent palettes
	PNGUseTrans = FALSE;	// use transparent color
	PNGInData = NULL;		// no input data buffer
	PNGInDataSize = 0;		// size of input data buffer

	PNGInputBuf = buf + 8;
	PNGInputSize = size - 8;

	// read all chunks
	for (;;)
	{
		// read chunk data length
		PNGInSize = 0;
		if (!PNGReadLong(&PNGInSize) || (PNGInSize > 10000000))
			{ PNGDelBuf(); return NULL; }

		// read chunk type
		DWORD chunktype = 0;
		if (!PNGReadData(&chunktype, sizeof(DWORD)))
			{ PNGDelBuf(); return NULL; }

		// read chunk data
		PNGInBuf = (BYTE*)malloc(PNGInSize);
		if (PNGInBuf == NULL) { PNGDelBuf(); return NULL; }
		if (!PNGReadData(PNGInBuf, PNGInSize))
			{ PNGDelBuf();  return NULL; }

		// read and check CRC
		DWORD crc = 0;
		if (!PNGReadLong(&crc)) { PNGDelBuf(); return NULL; }
		DWORD crc2 = PNGGetCRC(chunktype, PNGInBuf, PNGInSize);
		if (crc2 != crc) { PNGDelBuf(); return NULL; }

		// end chunk 'IEND'
		if (chunktype == CHUNK_IEND)
		{
			free(PNGInBuf);
			PNGInBuf = NULL;
			break;
		}

		// process chunk
		switch (chunktype)
		{
		// header 'IHDR'
		case CHUNK_IHDR:
			{
				PNGHeader* png = (PNGHeader*)PNGInBuf;
				PNGW = BigLit4(png->width);
				PNGH = BigLit4(png->height);
				PNGBits = png->bitdepth;
				PNGColType = png->colortype;
				PNGInter = (png->interlace == 1);

				// check color type and bit depth (16 bit sample not supported)
				switch(PNGColType)
				{
				case COLTYPE_GRAY:
				case COLTYPE_PAL:
					if ((PNGBits != 1) && (PNGBits != 2) &&
							(PNGBits != 4) && (PNGBits != 8))
						{ PNGDelBuf(); return NULL; }
					PNGBytes = 1;
					break;

				case COLTYPE_RGB:
					if (PNGBits != 8) { PNGDelBuf(); return NULL;}
					PNGBytes = 3;
					break;

				case COLTYPE_GRAYA:
					if (PNGBits != 8) { PNGDelBuf(); return NULL;}
					PNGBytes = 2;
					break;

				case COLTYPE_RGBA:
					if (PNGBits != 8) { PNGDelBuf(); return NULL;}
					PNGBytes = 4;
					break;

				default:
					{ PNGDelBuf(); return NULL; }
				}

				// check PNG header
				if ((PNGW < 1) || (PNGW > PICMAXWH) ||
					(PNGH < 1) || (PNGH > PICMAXWH) ||
					(png->compression != 0) ||
					(png->filter != 0) ||
					(PNGInter > 1))
					{ PNGDelBuf(); return NULL; }
			}
			break;

		// palettes 'PLTE'
		case CHUNK_PLTE:
			if ((PNGPal == NULL) && (PNGColType == COLTYPE_PAL))
			{
				// check number of palettes
				i = PNGInSize/3;
				if ((i > (1<<PNGBits)) ||
					((int)PNGInSize != i*3) ||
					(PNGW == 0)||
					(PNGH == 0))
				{
					PNGDelBuf();
					return NULL;
				}

				// create palette buffer
				PNGPal = (SRGBA*)malloc(256*sizeof(SRGBA));
				if (PNGPal == NULL) { PNGDelBuf(); return NULL; }

				// convert palettes
				for (i--; i >= 0; i--)
				{
					PNGPal[i].r = PNGInBuf[i*3+0];
					PNGPal[i].g = PNGInBuf[i*3+1];
					PNGPal[i].b = PNGInBuf[i*3+2];
					PNGPal[i].a = 255;
				}
			}
			break;

		// transparency 'tRNS'
		case CHUNK_tRNS:
			switch (PNGColType)
			{
			// transparent palettes
			case COLTYPE_PAL:
				if (PNGPal != NULL)
				{
					PNGTransPal = TRUE;		// use transparent palettes
					if (PNGInSize > 256) PNGInSize = 256;
					for (i = 0; i < (int)PNGInSize; i++)
						PNGPal[i].a = PNGInBuf[i];
				}
				break;

			// transparent grayscale
			case COLTYPE_GRAY:
				if (PNGInSize >= 2)
				{
					PNGUseTrans = TRUE;
					PNGTransCol.r = PNGInBuf[1];
					PNGTransCol.g = PNGInBuf[1];
					PNGTransCol.b = PNGInBuf[1];
					PNGTransCol.a = 0;
				}
				break;

			// transparent RGB
			case COLTYPE_RGB:
				if (PNGInSize >= 6)
				{
					PNGUseTrans = TRUE;
					PNGTransCol.r = PNGInBuf[1];
					PNGTransCol.g = PNGInBuf[3];
					PNGTransCol.b = PNGInBuf[5];
					PNGTransCol.a = 0;
				}
				break;
			}
			break;

		// data 'IDAT'
		case CHUNK_IDAT:
			{
				BYTE* d = (BYTE*)realloc(PNGInData, PNGInDataSize + PNGInSize);
				if (d == NULL) { PNGDelBuf(); return NULL; }
				memcpy(d + PNGInDataSize, PNGInBuf, PNGInSize);
				PNGInData = d;
				PNGInDataSize += PNGInSize;
			}
			break;
		}

		// free chunk buffer
		free(PNGInBuf);
		PNGInBuf = NULL;
	}

	// header must be valid
	if ((PNGW == 0) || (PNGH == 0) || (PNGInDataSize == 0) ||
		((PNGPal == NULL) && (PNGColType == COLTYPE_PAL)))
	{
		PNGDelBuf();
		return NULL;
	}

	// input buffer
	PNGInSrc = PNGInData;			// source pointer
	PNGInEnd = PNGInData + PNGInDataSize; // end of input buffer

	// row size
	if (PNGBits >= 8)
		PNGRowSize = PNGW*PNGBytes;
	else
		PNGRowSize = (PNGW*PNGBits+7)/8;

	// raw buffers
	PNGRow[0] = (BYTE*)malloc(PNGRowSize);
	if (PNGRow[0] == NULL) { PNGDelBuf(); return NULL; }
	PNGRow[1] = (BYTE*)malloc(PNGRowSize);
	if (PNGRow[1] == NULL) { PNGDelBuf(); return NULL; }
	PNGRowInx = 0;

	// output buffer
	PNGOutBuf=(BYTE*)malloc(PNGW*PNGH*PNGBytes); // output buffer
	if (PNGOutBuf == NULL) { PNGDelBuf(); return NULL; }
	PNGOutDst = PNGOutBuf;		// destination pointer
	PNGOutEnd = PNGOutBuf + PNGW*PNGH*PNGBytes; // end of buffer

	// initialize LZ77 decoder (return FALSE on error)
	if (!LZInit()) { PNGDelBuf(); return NULL; }

	// read data interlaced or non-interlaced
	if (PNGInter)
	{
		if (!LZReadInt()) { PNGDelBuf(); return NULL; }
	}
	else
	{
		if (!LZReadNonint()) { PNGDelBuf(); return NULL; }
	}

	// delete input data buffer
	free(PNGInData);
	PNGInData = NULL;
	PNGInDataSize = 0;

	// invalid formats
	if ((PNGW < 1) || (PNGW > PICMAXWH) ||
		(PNGH < 1) || (PNGH > PICMAXWH) ||
		((PNGBytes != 3) && (PNGBytes != 4)))
	{
		PNGDelBuf();
		return NULL;
	}

	// create canvas
	SCanvas* can = NewCanvas(PNGW, PNGH, PNGBytes);
	if (can == NULL)
	{
		PNGDelBuf();
		return NULL;
	}

	// copy image
	memcpy(can->d, PNGOutBuf, PNGW*PNGH*PNGBytes);
	VFlipCanvas(can);
	PNGDelBuf();

	return can;
}
