		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Color Correction Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRecolor::CFilterRecolor()
{
	m_Group = FGRP_COL;
	m_Class = _T("Recolor");
	m_HelpID = HELP_FRECOLOR;
	m_PropNum = 4;

	m_Prop[PROP_COLOR_HUE].SetName("Hue");
	m_Prop[PROP_COLOR_HUE].SetValue(0.5);
	m_Prop[PROP_COLOR_HUE].SetMin(-180);
	m_Prop[PROP_COLOR_HUE].SetMax(180);
	m_Prop[PROP_COLOR_HUE].SetToolID(ID_PROP_HUE);

	m_Prop[PROP_COLOR_SAT].SetName("Saturation");
	m_Prop[PROP_COLOR_SAT].SetValue(0.5);
	m_Prop[PROP_COLOR_SAT].SetMin(-50);
	m_Prop[PROP_COLOR_SAT].SetMax(50);
	m_Prop[PROP_COLOR_SAT].SetToolID(ID_PROP_SAT);

	m_Prop[PROP_COLOR_LUM].SetName("Luminance");
	m_Prop[PROP_COLOR_LUM].SetValue(0.5);
	m_Prop[PROP_COLOR_LUM].SetMin(-50);
	m_Prop[PROP_COLOR_LUM].SetMax(50);
	m_Prop[PROP_COLOR_LUM].SetToolID(ID_PROP_LUM);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRecolor::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real hue = m_Prop[PROP_COLOR_HUE].RenderVal(x, y) - (real)0.5;
	real sat = m_Prop[PROP_COLOR_SAT].RenderVal(x, y) * 2;
	real lev = m_Prop[PROP_COLOR_LUM].RenderVal(x, y);

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);

	// color correction
	if ((hue != 0) || (sat != 1))
	{
		col->RGBToHSL();
		col->r += hue;
		if (col->r < 0) col->r += 1;
		if (col->r >= 1) col->r -= 1;
		col->g *= sat;
		col->HSLToRGB();
	}
	col->Brightness(lev);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRecolor::RenderVal(real x, real y)
{
	CColor col;
	CFilterRecolor::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterHue::CFilterHue()
{
	m_Group = FGRP_COL;
	m_Class = _T("Hue");
	m_HelpID = HELP_FHUE;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterHue::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->RGBToHSL();
	col->g = col->b = col->r;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterHue::RenderVal(real x, real y)
{
	CColor col;
	m_Prop[PROP_SOURCE].RenderCol(&col, x, y);
	col.RGBToHSL();
	return col.r;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSaturation::CFilterSaturation()
{
	m_Group = FGRP_COL;
	m_Class = _T("Saturation");
	m_HelpID = HELP_FSATURATION;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSaturation::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->RGBToHSL();
	col->r = col->b = col->g;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSaturation::RenderVal(real x, real y)
{
	CColor col;
	m_Prop[PROP_SOURCE].RenderCol(&col, x, y);
	col.RGBToHSL();
	return col.g;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLuminance::CFilterLuminance()
{
	m_Group = FGRP_COL;
	m_Class = _T("Luminance");
	m_HelpID = HELP_FLUMINANCE;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLuminance::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->RGBToHSL();
	col->r = col->g = col->b;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLuminance::RenderVal(real x, real y)
{
	CColor col;
	m_Prop[PROP_SOURCE].RenderCol(&col, x, y);
	col.RGBToHSL();
	return col.b;
}

#define PROP_HSL_HUE	0			// property - Hue (0..1; 0=-180°, 1=+180°; def. 0.5)
#define PROP_HSL_SAT	1			// property - Saturation (0..1; 0=gray, 1=color; def. 0.5)
#define PROP_HSL_LUM	2			// property - Luminance (0..1; 0=dark, 1=bright; def. 0.5)
#define PROP_HSL_ALPHA	3			// property - Alpha (0..1; def. 1)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterHSL::CFilterHSL()
{
	m_Group = FGRP_COL;
	m_Class = _T("HSL");
	m_HelpID = HELP_FHSL;
	m_PropNum = 4;

	m_Prop[PROP_HSL_HUE].SetName("Hue");
	m_Prop[PROP_HSL_HUE].SetToolID(ID_PROP_HSLHUE);

	m_Prop[PROP_HSL_SAT].SetName("Saturation");
	m_Prop[PROP_HSL_SAT].SetToolID(ID_PROP_HSLSAT);

	m_Prop[PROP_HSL_LUM].SetName("Luminance");
	m_Prop[PROP_HSL_LUM].SetToolID(ID_PROP_HSLLUM);

	m_Prop[PROP_HSL_ALPHA].SetName("Alpha");
	m_Prop[PROP_HSL_ALPHA].SetValue(1);
	m_Prop[PROP_HSL_ALPHA].SetToolID(ID_PROP_ALPHA);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterHSL::RenderCol(CColor* col, real x, real y)
{
	col->r = m_Prop[PROP_HSL_HUE].RenderVal(x, y);
	col->g = m_Prop[PROP_HSL_SAT].RenderVal(x, y);
	col->b = m_Prop[PROP_HSL_LUM].RenderVal(x, y);
	col->a = m_Prop[PROP_HSL_ALPHA].RenderVal(x, y);
	col->HSLToRGB();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterHSL::RenderVal(real x, real y)
{
	CColor col;
	CFilterHSL::RenderCol(&col, x, y);
	return col.Gray();
}
