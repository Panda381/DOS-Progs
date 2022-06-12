
///////////////////////////////////////////////////////////////////////////////
//
//                              Check Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROP_CHECK_WIDTH		2		// property - Width (number of tiles horizontally 0.01..1; in 0.01 steps, default 0.08)
#define PROP_CHECK_HEIGHT		3		// property - Height (number of tiles vertically 0.01..1; in 0.01 steps, default 0.08)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterCheck::CFilterCheck()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Check");
	m_HelpID = HELP_FCHECK;
	m_PropNum = 4;
	m_Prop[PROP_SOURCE2].SetValue(1);

	m_Prop[PROP_CHECK_WIDTH].SetName("Width");
	m_Prop[PROP_CHECK_WIDTH].SetValue((real)0.08);
	m_Prop[PROP_CHECK_WIDTH].SetToolID(ID_PROP_CHECKWIDTH);
	m_Prop[PROP_CHECK_WIDTH].SetMinVal((real)0.01);
	m_Prop[PROP_CHECK_WIDTH].SetMin(1);

	m_Prop[PROP_CHECK_HEIGHT].SetName("Height");
	m_Prop[PROP_CHECK_HEIGHT].SetValue((real)0.08);
	m_Prop[PROP_CHECK_HEIGHT].SetToolID(ID_PROP_CHECKHEIGHT);
	m_Prop[PROP_CHECK_HEIGHT].SetMinVal((real)0.01);
	m_Prop[PROP_CHECK_HEIGHT].SetMin(1);
}

CFilterCheckSolid::CFilterCheckSolid()
{
	m_Class = _T("CheckSolid");
	m_HelpID = HELP_FCHECKSOLID;
}

CFilterRhomb::CFilterRhomb()
{
	m_Class = _T("Rhomb");
	m_HelpID = HELP_FRHOMB;
}

CFilterRhombSolid::CFilterRhombSolid()
{
	m_Class = _T("RhombSolid");
	m_HelpID = HELP_FRHOMBSOLID;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterCheck::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real w = m_Prop[PROP_CHECK_WIDTH].RenderVal(x, y)*100;
	real h = m_Prop[PROP_CHECK_HEIGHT].RenderVal(x, y)*100;

	// determine color
	int x0 = (int)floor(x*w);
	int y0 = (int)floor(y*h);

	// render color
	m_Prop[(((x0 + y0) & 1) == 0) ? PROP_SOURCE : PROP_SOURCE2].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCheck::RenderVal(real x, real y)
{
	// load properties
	real w = m_Prop[PROP_CHECK_WIDTH].RenderVal(x, y)*100;
	real h = m_Prop[PROP_CHECK_HEIGHT].RenderVal(x, y)*100;

	// determine color
	int x0 = (int)floor(x*w);
	int y0 = (int)floor(y*h);

	// render value
	return m_Prop[(((x0 + y0) & 1) == 0) ? PROP_SOURCE : PROP_SOURCE2].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterCheckSolid::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real w = m_Prop[PROP_CHECK_WIDTH].RenderVal(x, y)*100;
	real h = m_Prop[PROP_CHECK_HEIGHT].RenderVal(x, y)*100;
	if ((w == 0) || (h == 0))
	{
		col->SetBlack();
		return;
	}

	// determine color
	int x0 = (int)floor(x*w);
	int y0 = (int)floor(y*h);

	// render color
	m_Prop[(((x0 + y0) & 1) == 0) ? PROP_SOURCE : PROP_SOURCE2].RenderCol(col,
					(real)((x0 + 0.5)/w), (real)((y0 + 0.5)/h));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCheckSolid::RenderVal(real x, real y)
{
	// load properties
	real w = m_Prop[PROP_CHECK_WIDTH].RenderVal(x, y)*100;
	real h = m_Prop[PROP_CHECK_HEIGHT].RenderVal(x, y)*100;
	if ((w == 0) || (h == 0)) return 0;

	// determine color
	int x0 = (int)floor(x*w);
	int y0 = (int)floor(y*h);

	// render value
	return m_Prop[(((x0 + y0) & 1) == 0) ? PROP_SOURCE : PROP_SOURCE2].RenderVal(
				(real)((x0 + 0.5)/w), (real)((y0 + 0.5)/h));
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRhomb::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real w = m_Prop[PROP_CHECK_WIDTH].RenderVal(x, y)*100;
	real h = m_Prop[PROP_CHECK_HEIGHT].RenderVal(x, y)*100;

	// rotate
	real x1 = x*w;
	real y1 = y*h;
	real x2 = (x1 - y1);
	real y2 = (y1 + x1);
	x2 += (real)0.5;
	y2 += (real)0.5;

	// determine color
	int x0 = (int)floor(x2);
	int y0 = (int)floor(y2);

	// render color
	m_Prop[(((x0 + y0) & 1) == 0) ? PROP_SOURCE : PROP_SOURCE2].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRhomb::RenderVal(real x, real y)
{
	// load properties
	real w = m_Prop[PROP_CHECK_WIDTH].RenderVal(x, y)*100;
	real h = m_Prop[PROP_CHECK_HEIGHT].RenderVal(x, y)*100;

	// rotate
	real x1 = x*w;
	real y1 = y*h;
	real x2 = (x1 - y1);
	real y2 = (y1 + x1);
	x2 += (real)0.5;
	y2 += (real)0.5;

	// determine color
	int x0 = (int)floor(x2);
	int y0 = (int)floor(y2);

	// render value
	return m_Prop[(((x0 + y0) & 1) == 0) ? PROP_SOURCE : PROP_SOURCE2].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRhombSolid::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real w = m_Prop[PROP_CHECK_WIDTH].RenderVal(x, y)*100;
	real h = m_Prop[PROP_CHECK_HEIGHT].RenderVal(x, y)*100;
	if ((w == 0) || (h == 0))
	{
		col->SetBlack();
		return;
	}

	// rotate
	real x1 = x*w;
	real y1 = y*h;
	real x2 = (x1 - y1);
	real y2 = (y1 + x1);
	x2 += (real)0.5;
	y2 += (real)0.5;

	// determine color
	int x0 = (int)floor(x2);
	int y0 = (int)floor(y2);

	// render color
	if (((x0 + y0) & 1) == 0)
		m_Prop[PROP_SOURCE].RenderCol(col, floor(x*w+(real)0.5)/w, floor(y*h+(real)0.5)/h);
	else
		m_Prop[PROP_SOURCE2].RenderCol(col, (floor(x*w)+(real)0.5)/w, (floor(y*h)+(real)0.5)/h);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRhombSolid::RenderVal(real x, real y)
{
	// load properties
	real w = m_Prop[PROP_CHECK_WIDTH].RenderVal(x, y)*100;
	real h = m_Prop[PROP_CHECK_HEIGHT].RenderVal(x, y)*100;
	if ((w == 0) || (h == 0)) return 0;

	// rotate
	real x1 = x*w;
	real y1 = y*h;
	real x2 = (x1 - y1);
	real y2 = (y1 + x1);
	x2 += (real)0.5;
	y2 += (real)0.5;

	// determine color
	int x0 = (int)floor(x2);
	int y0 = (int)floor(y2);

	// render value
	if (((x0 + y0) & 1) == 0)
		return m_Prop[PROP_SOURCE].RenderVal(floor(x*w+(real)0.5)/w, floor(y*h+(real)0.5)/h);
	else
		return m_Prop[PROP_SOURCE2].RenderVal((floor(x*w)+(real)0.5)/w, (floor(y*h)+(real)0.5)/h);
}
