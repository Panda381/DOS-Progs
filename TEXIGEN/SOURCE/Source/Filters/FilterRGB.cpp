
///////////////////////////////////////////////////////////////////////////////
//
//                              RGB channels
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRed::CFilterRed()
{
	m_Group = FGRP_COL;
	m_Class = _T("Red");
	m_HelpID = HELP_FRED;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRed::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->g = col->b = col->r;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRed::RenderVal(real x, real y)
{
	CColor col;
	m_Prop[PROP_SOURCE].RenderCol(&col, x, y);
	return col.r;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGreen::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->r = col->b = col->g;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGreen::CFilterGreen()
{
	m_Group = FGRP_COL;
	m_Class = _T("Green");
	m_HelpID = HELP_FGREEN;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGreen::RenderVal(real x, real y)
{
	CColor col;
	m_Prop[PROP_SOURCE].RenderCol(&col, x, y);
	return col.g;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBlue::CFilterBlue()
{
	m_Group = FGRP_COL;
	m_Class = _T("Blue");
	m_HelpID = HELP_FBLUE;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterBlue::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->r = col->g = col->b;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBlue::RenderVal(real x, real y)
{
	CColor col;
	m_Prop[PROP_SOURCE].RenderCol(&col, x, y);
	return col.b;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterAlpha::CFilterAlpha()
{
	m_Group = FGRP_COL;
	m_Class = _T("Alpha");
	m_HelpID = HELP_FALPHA;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterAlpha::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->g = col->b = col->r = col->a;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterAlpha::RenderVal(real x, real y)
{
	CColor col;
	m_Prop[PROP_SOURCE].RenderCol(&col, x, y);
	return col.a;
}

#define PROP_SETALPHA_ALPHA	1		// property - Alpha

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSetAlpha::CFilterSetAlpha()
{
	m_Group = FGRP_COL;
	m_Class = _T("SetAlpha");
	m_HelpID = HELP_FSETALPHA;
	m_PropNum = 2;

	m_Prop[PROP_SETALPHA_ALPHA].SetName("Alpha");
	m_Prop[PROP_SETALPHA_ALPHA].SetValue(1);
	m_Prop[PROP_SETALPHA_ALPHA].SetToolID(ID_PROP_RGBA);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSetAlpha::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->a = m_Prop[PROP_SETALPHA_ALPHA].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSetAlpha::RenderVal(real x, real y)
{
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

#define PROP_CHANCOMP_R	0		// property - Red
#define PROP_CHANCOMP_G	1		// property - Green
#define PROP_CHANCOMP_B	2		// property - Blue
#define PROP_CHANCOMP_A	3		// property - Alpha

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRGB::CFilterRGB()
{
	m_Group = FGRP_COL;
	m_Class = _T("RGB");
	m_HelpID = HELP_FRGB;
	m_PropNum = 4;

	m_Prop[PROP_CHANCOMP_R].SetName("Red");
	m_Prop[PROP_CHANCOMP_R].SetToolID(ID_PROP_RGBR);

	m_Prop[PROP_CHANCOMP_G].SetName("Green");
	m_Prop[PROP_CHANCOMP_G].SetToolID(ID_PROP_RGBG);

	m_Prop[PROP_CHANCOMP_B].SetName("Blue");
	m_Prop[PROP_CHANCOMP_B].SetToolID(ID_PROP_RGBB);

	m_Prop[PROP_CHANCOMP_A].SetName("Alpha");
	m_Prop[PROP_CHANCOMP_A].SetValue(1);
	m_Prop[PROP_CHANCOMP_A].SetToolID(ID_PROP_RGBA);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRGB::RenderCol(CColor* col, real x, real y)
{
	col->Set(
		m_Prop[PROP_CHANCOMP_R].RenderVal(x, y),
		m_Prop[PROP_CHANCOMP_G].RenderVal(x, y),
		m_Prop[PROP_CHANCOMP_B].RenderVal(x, y),
		m_Prop[PROP_CHANCOMP_A].RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRGB::RenderVal(real x, real y)
{
	CColor col;
	CFilterRGB::RenderCol(&col, x, y);
	return col.Gray();
}
