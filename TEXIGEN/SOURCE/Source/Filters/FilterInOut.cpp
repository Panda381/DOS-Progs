
///////////////////////////////////////////////////////////////////////////////
//
//                             Input/Output Filters
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterIn::CFilterIn()
{
	m_Group = FGRP_INOUT;
	m_Class = _T("In");
	m_Label = _T("Value");
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterValue::CFilterValue()
{
	m_Category = FCAT_INVALUE;
	m_Class = _T("Value");
	m_HelpID = HELP_FVALUE;
	m_Value = 0;
	m_DefValue = 0;
	m_OutValue = 0;
	m_Min = 0;
	m_Max = 100;
	m_MinVal = 0;
	m_MaxVal = 1;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterValue::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(m_OutValue);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterValue::RenderVal(real x, real y)
{
	return m_OutValue;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterColor::CFilterColor()
{
	m_Category = FCAT_INCOLOR;
	m_Class = _T("Color");
	m_Label = _T("Color");
	m_HelpID = HELP_FCOLOR;
	m_Color.SetBlack();
	m_DefColor.SetBlack();
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterColor::RenderCol(CColor* col, real x, real y)
{
	col->Set(m_Color);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterColor::RenderVal(real x, real y)
{
	return m_Color.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterImage::CFilterImage()
{
	m_Category = FCAT_INIMAGE;
	m_Class = _T("Image");
	m_HelpID = HELP_FIMAGE;
	m_Label = _T("Image");

	m_FilterVideo = FALSE;
	m_VideoFrame = -1;
	m_NeedLoad = TRUE;
	m_FileName = _T("image.tga");
	m_DefFileName = m_FileName;
	m_Tiled = FALSE;
	m_Canvas = NULL;
}

///////////////////////////////////////////////////////////////////////////////

BOOL CFilterImage::NeedLoad() const
{
	int inx;
	if (RenderMode)
		inx = (RenderFrames > 0) ? RenderFrame : 0;
	else if (PreviewMode)
		inx = (int)(PreviewTime*100 + 0.5);
	else
		inx = 0;

	return m_NeedLoad || (m_FilterVideo && (m_VideoFrame != inx));
}

///////////////////////////////////////////////////////////////////////////////
// load file before rendering (returns FALSE on error)

bool CFilterImage::FileLoad()
{
	// not need load
	if (!this->NeedLoad()) return true;
	m_NeedLoad = FALSE;

	int inx;
	if (RenderMode)
		inx = (RenderFrames > 0) ? RenderFrame : 0;
	else if (PreviewMode)
		inx = (int)(PreviewTime*100 + 0.5);
	else
		inx = 0;
	m_VideoFrame = inx;

	this->DelBuf();

	// no image
	CText name = m_FileName;
	if (m_FileName.IsEmpty()) return true;

	// prepare filename
	if (m_FilterVideo)
	{
		int pos = name.FindRev(TCHAR('.'));
		if (pos >= 0)
		{
			CText ext = name.RightFrom(pos);
			name.DelToEnd(pos);
			while ((pos > 0) &&
				(name[pos-1] >= TCHAR('0')) &&
				(name[pos-1] <= TCHAR('9')))
				pos--;
			int len = name.Length() - pos;
			if (len > 0)
			{
				name.DelToEnd(pos);
				CText txt = name.RightFrom(pos);
				int frame = txt.Int() + m_VideoFrame;
				txt.SetInt(frame);
				while (txt.Length()	< len) txt = TCHAR('0') + txt;
				name += txt;
			}
			name += ext;
		}
	}

	// load image
	m_Canvas = ImgLoad(name);
	if (m_Canvas == NULL) return false;
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// read color from input file (it closes the file on error)

void CFilterImage::ReadCol(CColor* col, int x, int y)
{
	// load file
	if (this->NeedLoad()) this->FileLoad();

	// invalid file
	u8* b = this->PicData();
	if (b == NULL)
	{
		col->SetBlackA();
		return;
	}

	// offset in buffer
	int off = (y*this->PicW() + x)*this->PicC();
	if ((off < 0) || (off > this->PicSize() - this->PicC()))
	{
		col->SetBlackA();
		return;
	}

	// get pixel from buffer
	col->SetRGBA(b[off+2], b[off+1], b[off], (this->PicC() == 4) ? b[off+3] : 255);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates are typically in range 0..1)

void CFilterImage::RenderCol(CColor* col, real x, real y)
{
	// restart, check filename
	//if (m_Restart)
	//{
	//	m_Restart = FALSE;
	//}

	// load file
	if (this->NeedLoad()) this->FileLoad();

	// invalid file
	if (m_Canvas == NULL)
	{
		col->SetBlackA();
		return;
	}

	// load properties
	BOOL tiled = m_Tiled; //(m_Prop[PROP_IN_TILED].RenderVal(x, y) >= 0.5);

	// wrap coordinates
	if (tiled)
	{
		if (x >= 1) x -= (int)x;
		if (x < 0) x += (int)(1 - x);
		if (y >= 1) y -= (int)y;
		if (y < 0) y += (int)(1-y);
	}
	else
	{
		x = CLAMP(x);
		y = CLAMP(y);
	}

	// transform to pixel coordinates (pixel is in middle of texel)
	x = x * this->PicW() + 0.5f;
	y = y * this->PicH() + 0.5f;

	// prepare left and right X coordinate
	int x1 = (int)x - 1;
	if (x1 < 0)
	{
		if (tiled) x1 += this->PicW(); else x1 = 0;
	}
	int x2 = x1 + 1;
	if (x2 >= this->PicW())
	{
		if (tiled) x2 -= this->PicW(); else x2 = this->PicW()-1;
	}

	// prepare top and bottom Y coordinate
	int y1 = (int)y - 1;
	if (y1 < 0)
	{
		if (tiled) y1 += this->PicH(); else y1 = 0;
	}
	int y2 = y1 + 1;
	if (y2 >= this->PicH())
	{
		if (tiled) y2 -= this->PicH(); else y2 = this->PicH()-1;
	}

	// delta of coordinates
	real dx = x - (int)x;
	real dy = y - (int)y;

	// read pixels from file
	CColor c11, c12, c21, c22;
	ReadCol(&c11, x1, y1);
	ReadCol(&c12, x2, y1);
	ReadCol(&c21, x1, y2);
	ReadCol(&c22, x2, y2);

	// interpolate pixels in X direction
	c11.MulA(1 - dx);
	c12.MulA(dx);
	c11.AddA(c12);

	c21.MulA(1 - dx);
	c22.MulA(dx);
	c21.AddA(c22);

	// interpolate pixels in Y direction
	c11.MulA(1 - dy);
	c21.MulA(dy);
	c11.AddA(c21);

	col->Set(c11);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterImage::RenderVal(real x, real y)
{
	CColor col;
	CFilterImage::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterVideo::CFilterVideo()
{
	m_Class = _T("Video");
	m_FilterVideo = TRUE;
	m_Label = _T("Video");
	m_HelpID = HELP_FVIDEO;
	m_VideoFrame = -1;
	m_FileName = EmptyText;
	m_DefFileName = m_FileName;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterImageData::CFilterImageData()
{
	m_Category = FCAT_INIMAGEDATA;
	m_Group = FGRP_INOUT;
	m_Class = _T("ImageData");
	m_HelpID = HELP_FIMAGEDATA;
	m_PropNum = 1;

	m_FileName = _T("");
	m_Tiled = FALSE;
	m_Canvas = NULL;

	m_Prop[PROP_IMAGE_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_IMAGE_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_IMAGE_SQUEEZE].SetMin(-50);
	m_Prop[PROP_IMAGE_SQUEEZE].SetMax(50);
	m_Prop[PROP_IMAGE_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);
}

///////////////////////////////////////////////////////////////////////////////
// load file

void CFilterImageData::SetFileName(const CText& filename)
{
	m_FileName = filename;
	m_FileName.PathName(0);

	this->DelBuf();
	if (m_FileName.IsEmpty()) return;

	// load image
	m_Canvas = ImgLoad(m_FileName);
}

///////////////////////////////////////////////////////////////////////////////
// read color from input buffer

void CFilterImageData::ReadCol(CColor* col, int x, int y)
{
	// invalid file
	u8* b = this->PicData();
	if (b == NULL)
	{
		col->SetBlackA();
		return;
	}

	// limit coordinates
	if (x < 0) x = 0;
	if (y < 0) y = 0;
	if (x >= this->PicW()) x = this->PicW() - 1;
	if (y >= this->PicH()) y = this->PicH() - 1;

	// get pixel from buffer
	int off = (y*this->PicW() + x)*this->PicC();
	if ((off < 0) || (off > this->PicSize() - this->PicC()))
	{
		col->SetBlackA();
		return;
	}
	col->SetRGBA(b[off+2], b[off+1], b[off], (this->PicC() == 4) ? b[off+3] : 255);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates are typically in range 0..1)

void CFilterImageData::RenderCol(CColor* col, real x, real y)
{
	// invalid file
	if (m_Canvas == NULL)
	{
		col->SetBlackA();
		return;
	}

	// load properties
	BOOL tiled = m_Tiled;
	real squeeze = m_Prop[PROP_IMAGE_SQUEEZE].RenderVal(x, y);

	// scale
	if ((squeeze == 0) || (squeeze == 1))
	{
		if (this->PicC() == 4)
			col->SetTransGray();
		else
			col->SetBlack();
		return;
	}
		
	if (squeeze >= (real)0.5)
		x = (x - (real)0.5)/(1 - squeeze)/2 + (real)0.5;
	else
		y = (y - (real)0.5)/squeeze/2 + (real)0.5;

	// wrap coordinates
	if (tiled)
	{
		if (x >= 1) x -= (int)x;
		if (x < 0) x += (int)(1 - x);
		if (y >= 1) y -= (int)y;
		if (y < 0) y += (int)(1-y);
	}
	else
	{
		if ((x < 0) || (x >= 1) || (y < 0) || (y >= 1))
		{
			if (this->PicC() == 4)
				col->SetTransGray();
			else
				col->SetBlack();
			return;
		}
	}

	// transform to pixel coordinates (pixel is in middle of texel)
	x = x * this->PicW() + (real)0.5;
	y = y * this->PicH() + (real)0.5;

	// prepare left and right X coordinate
	int x1 = (int)x - 1;
	if (x1 < 0)
	{
		if (tiled) x1 += this->PicW(); else x1 = 0;
	}
	int x2 = x1 + 1;
	if (x2 >= this->PicW())
	{
		if (tiled) x2 -= this->PicW(); else x2 = this->PicW()-1;
	}

	// prepare top and bottom Y coordinate
	int y1 = (int)y - 1;
	if (y1 < 0)
	{
		if (tiled) y1 += this->PicH(); else y1 = 0;
	}
	int y2 = y1 + 1;
	if (y2 >= this->PicH())
	{
		if (tiled) y2 -= this->PicH(); else y2 = this->PicH()-1;
	}

	// delta of coordinates
	real dx = x - (int)x;
	real dy = y - (int)y;

	// read pixels from file
	CColor c11, c12, c21, c22;
	ReadCol(&c11, x1, y1);
	ReadCol(&c12, x2, y1);
	ReadCol(&c21, x1, y2);
	ReadCol(&c22, x2, y2);

	// interpolate pixels
	c11.Trans(c12, dx);
	c21.Trans(c22, dx);
	c11.Trans(c21, dy);
	col->Set(c11);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterImageData::RenderVal(real x, real y)
{
	CColor col;
	CFilterImageData::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterOut::CFilterOut()
{
	m_Group = FGRP_INOUT;
	m_Category = FCAT_OUT;
	m_Class = _T("Out");
	m_HelpID = HELP_FOUT;
	m_Label = _T("Main");
}
