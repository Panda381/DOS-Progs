
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                JPEG file                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"
#include "jpeg\cdjpeg.h"

const u8* JPEGInputBuf;
int JPEGInputSize;

BYTE*	JPEGOutDst = NULL;		// destination pointer into output buffer
BYTE*	JPEGOutEnd = NULL;		// end of output buffer
int		JPEGWidth;				// image width
int		JPEGHeight;				// image height
int		JPEGBytes;				// bytes per pixel
BOOL	JPEGError = FALSE;		// error flag
int		JPEGWidthBytes;			// bytes per image row

// error service
static void JPEGErrorExit(j_common_ptr cinfo)
{
	JPEGError = TRUE;
}

// null error message table
static const char * const cdjpeg_message_table[] = {
  NULL
};

// read data
size_t JFREAD(FILE* file, void* buf, int sizeofbuf)
{
	int n = JPEGInputSize;
	if (n > sizeofbuf) n = sizeofbuf;
	memcpy(buf, JPEGInputBuf, n);
	JPEGInputBuf += n;
	JPEGInputSize -= n;
	return n;
}

///////////////////////////////////////////////////////////////////////////////
// decode JPG picture (returns NULL on error; returns Canvas with ref=1)

SCanvas* JPGDecode(const u8* buf, int size)
{
	// check JPEG header
	if ((size<20)||(buf[0]!=0xff)||(buf[1]!=0xd8)||(buf[2]!=0xff)) return NULL;

	JPEGInputBuf = buf;
	JPEGInputSize = size;

	// local variables
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;

	// create decompression object
	JPEGError = FALSE;
	cinfo.err = jpeg_std_error(&jerr);
	cinfo.err->error_exit = JPEGErrorExit;
	jpeg_create_decompress(&cinfo);
	if (JPEGError) return NULL;

	// default error messages
	jerr.addon_message_table = cdjpeg_message_table;
	jerr.first_addon_message = 0;
	jerr.last_addon_message = 0;
	cinfo.err->trace_level = 0;

	// data source for decompression
	cinfo.dct_method = JDCT_FLOAT;
	cinfo.dither_mode = JDITHER_NONE;
	jpeg_stdio_src(&cinfo, NULL);
	if (JPEGError) { jpeg_destroy_decompress(&cinfo); return NULL; }

	// read file header
	jpeg_read_header(&cinfo, TRUE);
	if (JPEGError) { jpeg_destroy_decompress(&cinfo); return NULL; }

	// calculate output image dimension
	jpeg_calc_output_dimensions(&cinfo);
	JPEGWidth = cinfo.output_width;
	JPEGBytes = cinfo.output_components;
	JPEGHeight = cinfo.output_height;
	JPEGWidthBytes = JPEGWidth*JPEGBytes;
	if (JPEGError ||
		((JPEGBytes != 1) && (JPEGBytes != 3) && (JPEGBytes != 4)) ||
		(JPEGWidth < 1) || (JPEGWidth > PICMAXWH) ||
		(JPEGHeight < 1) || (JPEGHeight > PICMAXWH))
	{
			jpeg_destroy_decompress(&cinfo); 
			return NULL;
	}

	// create output buffer
	int s = JPEGWidthBytes*JPEGHeight;
	SCanvas* can = NewCanvas(JPEGWidth, JPEGHeight, 3);
	if (can == NULL) return NULL;
	if (JPEGError) { jpeg_destroy_decompress(&cinfo); free(can); return FALSE; }
	JPEGOutDst = can->d;
	JPEGOutEnd = can->d + s;

	// start decompressor
	jpeg_start_decompress(&cinfo);
	if (JPEGError)
	{
		jpeg_destroy_decompress(&cinfo);
		free(can);
		return NULL;
	}

	// read image data
	while (cinfo.output_scanline < cinfo.output_height)
	{
		jpeg_read_scanlines(&cinfo, &JPEGOutDst, 1);
		if (JPEGError)
		{
			jpeg_finish_decompress(&cinfo);
			jpeg_destroy_decompress(&cinfo);
			free(can);
			return NULL;
		}
		JPEGOutDst += JPEGWidthBytes;
	}

	// finish decompression
	jpeg_finish_decompress(&cinfo);
	jpeg_destroy_decompress(&cinfo);

	// convert RGBx to RGB
	if (JPEGBytes == 4)
	{
		BYTE* s = can->d;
		BYTE* d = s;
		int i = JPEGWidth*JPEGHeight;
		for (; i > 0; i--)
		{
			d[0] = s[0];
			d[1] = s[1];
			d[2] = s[2];
			s += 4;
			d += 3;
		}
	}

	// convert L8 to RGB
	if (JPEGBytes == 1)
	{
		BYTE* s = can->d;
		BYTE* d = s;
		BYTE b;
		int i = JPEGWidth*JPEGHeight - 1;
		s += i;
		d += i*3;
		for (; i >= 0; i--)
		{
			b = *s;
			d[0] = b;
			d[1] = b;
			d[2] = b;
			s--;
			d -= 3;
		}
	}

	// correction
	RGBflipBGR(can);
	VFlipCanvas(can);

	return can;
}

///////////////////////////////////////////////////////////////////////////////
// save JPEG file - only RGB (returns TRUE if OK)

BOOL JPGSave(const CText& filename, SCanvas* can, int quality /*= 50*/)
{
	if (can->c != 3) return FALSE;

	// open file
	FILE* file = _tfopen((LPCTSTR)filename, _T("wb"));
	if (file == NULL) return FALSE;

	// local variables
	struct jpeg_compress_struct cinfo;
	struct jpeg_error_mgr jerr;

	// create compression object
	JPEGError = FALSE;
	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo);
	if (JPEGError)
	{
		fclose(file);
		return FALSE;
	}

	// default error messages
	jerr.addon_message_table = cdjpeg_message_table;
	jerr.first_addon_message = 0;
	jerr.last_addon_message = 0;

	// set JPEF parameters
	cinfo.in_color_space = JCS_RGB;
	cinfo.image_width = can->w;
	cinfo.image_height = can->h;
	cinfo.input_components = 3;
	jpeg_set_defaults(&cinfo);
    cinfo.optimize_coding = TRUE;
	jpeg_set_quality(&cinfo, quality, TRUE);

	// don't use progression - VirtualDub cannot understand it
	//jpeg_simple_progression(&cinfo);

	// set destination
	jpeg_stdio_dest(&cinfo, file);

	// start compressor
	jpeg_start_compress(&cinfo, TRUE);

	// process data
	RGBflipBGR(can);
	u8* buf = can->d + (can->h-1)*can->w*3;
	while (cinfo.next_scanline < (DWORD)can->h)
	{
		jpeg_write_scanlines(&cinfo, &buf, 1);
		buf -= can->w*3;
	}
	RGBflipBGR(can);

	// finish compression and release memory
	jpeg_finish_compress(&cinfo);
	jpeg_destroy_compress(&cinfo);

	fclose(file);
	return !JPEGError;
}

