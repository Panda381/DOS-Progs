
///////////////////////////////////////////////////////////////////////////////
//
//                               Paper Clip
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterClip::CFilterClip()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Clip");
	m_HelpID = HELP_FCLIP;
	m_PropNum = 6;

	m_Prop[PROP_CLIP_COLIN].SetColor((real)10/255, (real)180/255, 1);
	m_Prop[PROP_CLIP_COLIN].SetName("ColorIn");
	m_Prop[PROP_CLIP_COLIN].SetToolID(ID_PROP_COLORIN);

	m_Prop[PROP_CLIP_COLOUT].SetColor((real)5/255, (real)90/255, (real)120/255);
	m_Prop[PROP_CLIP_COLOUT].SetName("ColorOut");
	m_Prop[PROP_CLIP_COLOUT].SetToolID(ID_PROP_COLOROUT);

	m_Prop[PROP_CLIP_BACK].SetColor(0,0,0,0);
	m_Prop[PROP_CLIP_BACK].SetName("Background");
	m_Prop[PROP_CLIP_BACK].SetToolID(ID_PROP_BACKGROUND);

	m_Prop[PROP_CLIP_THICK].SetValue((real)0.25);
	m_Prop[PROP_CLIP_THICK].SetName("Thickness");
	m_Prop[PROP_CLIP_THICK].SetToolID(ID_PROP_CLIPTHICK);

	m_Prop[PROP_CLIP_SIZE].SetName("Size");
	m_Prop[PROP_CLIP_SIZE].SetValue(1);
	m_Prop[PROP_CLIP_SIZE].SetToolID(ID_PROP_CLIPSIZE);

	m_Prop[PROP_CLIP_WIDTH].SetName("Width");
	m_Prop[PROP_CLIP_WIDTH].SetValue((real)0.25);
	m_Prop[PROP_CLIP_WIDTH].SetToolID(ID_PROP_WIDTH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterClip::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real thick = CLAMP(m_Prop[PROP_CLIP_THICK].RenderVal(x, y))/8;
	real size = m_Prop[PROP_CLIP_SIZE].RenderVal(x, y);
	real w = CLAMP(m_Prop[PROP_CLIP_WIDTH].RenderVal(x, y));
	if (thick > w/5) thick = w/5;
	w -= thick;
	real thick2 = thick/2;
	real w2 = w/2;

	// invisible
	if ((thick < (real)0.00001) || (size < (real)0.00001) || (w < (real)0.00001))
	{
		m_Prop[PROP_CLIP_BACK].RenderCol(col, x, y);
		return;
	}

	// resize
	x = (x - (real)0.5)/size + (real)0.5;
	y = (y - (real)0.5)/size + (real)0.5;

	// upper big arc
	real ytop = 1 - thick2 - w2;
	real fg = 0;
	real d;
	if (y >= ytop)
	{
		real dx = x - (real)0.5;
		real dy = y - ytop;
		d = sqrt(dx*dx + dy*dy);
		if ((d <= w2 + thick2) && (d >= w2 - thick2))
		{
			fg = 1 - abs(d - w2)/thick2;
		}
	}

	// lower middle arc
	real dw = thick/6;	// space between wires
	real wm = w - thick - dw;
	real wm2 = wm/2;
	real ylow = wm2 + thick2;
	real xm = (real)0.5 - (w2 - wm2);
	if (fg == 0)
	{
		if (y <= ylow)
		{
			real dx = x - xm;
			real dy = y - ylow;
			d = sqrt(dx*dx + dy*dy);
			if ((d <= wm2 + thick2) && (d >= wm2 - thick2))
			{
				fg = 1 - abs(d - wm2)/thick2;
			}
		}
	}

	// upper small arc
	real ysmall = (ytop - ylow)*(real)0.8 + ylow;
	real ws = wm - thick - dw;
	real ws2 = ws/2;
	if (fg == 0)
	{
		if (y >= ysmall)
		{
			real dx = x - (real)0.5;
			real dy = y - ysmall;
			d = sqrt(dx*dx + dy*dy);
			if ((d <= ws2 + thick2) && (d >= ws2 - thick2))
				fg = 1 - abs(d - ws2)/thick2;
		}
	}

	// right outer column
	real ystop = (ytop - ylow)*(real)0.25 + ylow;
	if ((fg == 0) && (y >= ystop) && (y <= ytop) && (x >= (real)0.5 + w2 - thick2) && (x <= (real)0.5 + w2 + thick2))
		fg = 1 - abs(x - (real)0.5 - w2)/thick2;

	// left outer column
	if ((fg == 0) && (y >= ylow) && (y <= ytop) && (x >= (real)0.5 - w2 - thick2) && (x <= (real)0.5 - w2 + thick2))
		fg = 1 - abs(x - (real)0.5 + w2)/thick2;

	// right inner column
	if ((fg == 0) && (y >= ylow) && (y <= ysmall) && (x >= xm + wm2 - thick2) && (x <= xm + wm2 + thick2))
		fg = 1 - abs(x - xm - wm2)/thick2;

	// left inner column
	if ((fg == 0) && (y >= ystop) && (y <= ysmall) && (x >= (real)0.5 - ws2 - thick2) && (x <= (real)0.5 - ws2 + thick2))
		fg = 1 - abs(x - (real)0.5 + ws2)/thick2;

	// render color
	if (fg >= 1)
		m_Prop[PROP_CLIP_COLIN].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_CLIP_BACK].RenderCol(col, x, y);
		else
		{
			fg = 1 - fg;
			fg = sqrt(1 - fg*fg);
			CColor f;
			m_Prop[PROP_CLIP_COLIN].RenderCol(&f, x, y);
			m_Prop[PROP_CLIP_COLOUT].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterClip::RenderVal(real x, real y)
{
	CColor col;
	CFilterClip::RenderCol(&col, x, y);
	return col.Gray();
}
