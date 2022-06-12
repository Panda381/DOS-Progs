				   
///////////////////////////////////////////////////////////////////////////////
//
//                             Rotation Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CText SeamlessRotateName[] = {
	CText(_T("0°")),
	CText(_T("45°")),
	CText(_T("90°")),
	CText(_T("135°")),
	CText(_T("180°")),
	CText(_T("225°")),
	CText(_T("270°")),
	CText(_T("315°")),

	CText(_T(""))
};

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRotate::CFilterRotate()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Rotate");
	m_HelpID = HELP_FROTATE;
	m_PropNum = 4;

	m_Prop[PROP_ROT_ANGLE].SetName("Angle");
	m_Prop[PROP_ROT_ANGLE].SetValue(0.5);
	m_Prop[PROP_ROT_ANGLE].SetMin(-180);
	m_Prop[PROP_ROT_ANGLE].SetMax(180);
	m_Prop[PROP_ROT_ANGLE].SetToolID(ID_PROP_ANGLE);

	m_Prop[PROP_ROT_X].SetName("CenterX");
	m_Prop[PROP_ROT_X].SetValue(0.5);
	m_Prop[PROP_ROT_X].SetMin(-50);
	m_Prop[PROP_ROT_X].SetMax(50);
	m_Prop[PROP_ROT_X].SetToolID(ID_PROP_ROTX);

	m_Prop[PROP_ROT_Y].SetName("CenterY");
	m_Prop[PROP_ROT_Y].SetValue(0.5);
	m_Prop[PROP_ROT_Y].SetMin(-50);
	m_Prop[PROP_ROT_Y].SetMax(50);
	m_Prop[PROP_ROT_Y].SetToolID(ID_PROP_ROTY);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRotate::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real angle = (m_Prop[PROP_ROT_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real centerx = m_Prop[PROP_ROT_X].RenderVal(x, y);
	real centery = m_Prop[PROP_ROT_Y].RenderVal(x, y);

	// transform coordinates
	x -= centerx;
	y -= centery;
	real sa = sin(angle);
	real ca = cos(angle);
	real x2 = x*ca + y*sa;
	real y2 = y*ca - x*sa;
	x = x2 + centerx;
	y = y2 + centery;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRotate::RenderVal(real x, real y)
{
	// load properties
	real angle = (m_Prop[PROP_ROT_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real centerx = m_Prop[PROP_ROT_X].RenderVal(x, y);
	real centery = m_Prop[PROP_ROT_Y].RenderVal(x, y);

	// transform coordinates
	x -= centerx;
	y -= centery;
	real sa = sin(angle);
	real ca = cos(angle);
	real x2 = x*ca + y*sa;
	real y2 = y*ca - x*sa;
	x = x2 + centerx;
	y = y2 + centery;

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRotate90::CFilterRotate90()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Rotate90");
	m_HelpID = HELP_FROTATE90;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRotate90::RenderCol(CColor* col, real x, real y)
{
	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, y, 1 - x);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRotate90::RenderVal(real x, real y)
{
	// render value
	return m_Prop[PROP_SOURCE].RenderVal(y, 1 - x);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRotate180::CFilterRotate180()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Rotate180");
	m_HelpID = HELP_FROTATE180;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRotate180::RenderCol(CColor* col, real x, real y)
{
	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, 1 - x, 1 - y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRotate180::RenderVal(real x, real y)
{
	// render value
	return m_Prop[PROP_SOURCE].RenderVal(1 - x, 1 - y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRotate270::CFilterRotate270()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Rotate270");
	m_HelpID = HELP_FROTATE270;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRotate270::RenderCol(CColor* col, real x, real y)
{
	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, 1 - y, x);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRotate270::RenderVal(real x, real y)
{
	// render value
	return m_Prop[PROP_SOURCE].RenderVal(1 - y, x);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDiagonal::CFilterDiagonal()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Diagonal");
	m_HelpID = HELP_FDIAGONAL;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDiagonal::RenderCol(CColor* col, real x, real y)
{
	// rotate by 45°
	//x -= 0.5;
	//y -= 0.5;
	//real sa = 1/sqrt(2);
	//real ca = 1/sqrt(2);
	//real x2 = x*ca + y*sa;
	//real y2 = y*ca - x*sa;
	//x = x2 + 0.5;
	//y = y2 + 0.5;
	// OR:
	// x2 = (x - 0.5)/sqrt(2) + (y - 0.5)/sqrt(2) + 0.5 = (x + y - 1)/sqrt(2) + 0.5
	// y2 = (y - 0.5)/sqrt(2) - (x - 0.5)/sqrt(2) + 0.5 = (y - x)/sqrt(2) + 0.5

	// scale by sqrt(2)
	// x = (x2 - 0.5)*sqrt(2) + 0.5;
	// y = (y2 - 0.5)*sqrt(2) + 0.5;
	// OR:
	// x2 = ((x + y - 1)/sqrt(2) + 0.5 - 0.5)*sqrt(2) + 0.5 = x + y - 0.5
	// y2 = ((y - x)/sqrt(2) + 0.5 - 0.5)*sqrt(2) + 0.5 = y - x + 0.5

	// rotate by 45° and scale by sqrt(2)
	real x2 = x + y - (real)0.5;
	real y2 = y - x + (real)0.5;

	// tiled
	if (x2 >= 1) x2 -= (int)x2;
	if (x2 < 0) x2 += (int)(1 - x2);
	if (y2 >= 1) y2 -= (int)y2;
	if (y2 < 0) y2 += (int)(1 - y2);

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x2, y2);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDiagonal::RenderVal(real x, real y)
{
	// rotate by 45° and scale by sqrt(2)
	real x2 = x + y - (real)0.5;
	real y2 = y - x + (real)0.5;

	// tiled
	if (x2 >= 1) x2 -= (int)x2;
	if (x2 < 0) x2 += (int)(1 - x2);
	if (y2 >= 1) y2 -= (int)y2;
	if (y2 < 0) y2 += (int)(1 - y2);

	// render value (with rotation by 45° and scale by sqrt(2))
	return m_Prop[PROP_SOURCE].RenderVal(x2, y2);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDiagonal2::CFilterDiagonal2()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Diagonal2");
	m_HelpID = HELP_FDIAGONAL2;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDiagonal2::RenderCol(CColor* col, real x, real y)
{
	// rotate by -45°
	//x -= 0.5;
	//y -= 0.5;
	//real sa = -1/sqrt(2);
	//real ca = 1/sqrt(2);
	//real x2 = x*ca + y*sa;
	//real y2 = y*ca - x*sa;
	//x = x2 + 0.5;
	//y = y2 + 0.5;
	// OR:
	// x2 = (x - 0.5)/sqrt(2) - (y - 0.5)/sqrt(2) + 0.5 = (x - y)/sqrt(2) + 0.5
	// y2 = (y - 0.5)/sqrt(2) + (x - 0.5)/sqrt(2) + 0.5 = (y + x - 1)/sqrt(2) + 0.5

	// scale by sqrt(2)
	// x = (x2 - 0.5)*sqrt(2) + 0.5;
	// y = (y2 - 0.5)*sqrt(2) + 0.5;
	// OR:
	// x2 = ((x - y)/sqrt(2) + 0.5 - 0.5)*sqrt(2) + 0.5 = x - y + 0.5
	// y2 = ((y + x - 1)/sqrt(2) + 0.5 - 0.5)*sqrt(2) + 0.5 = y + x - 0.5

	// rotate by -45° and scale by sqrt(2)
	real x2 = x - y + (real)0.5;
	real y2 = y + x - (real)0.5;

	// tiled
	if (x2 >= 1) x2 -= (int)x2;
	if (x2 < 0) x2 += (int)(1 - x2);
	if (y2 >= 1) y2 -= (int)y2;
	if (y2 < 0) y2 += (int)(1 - y2);

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x2, y2);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDiagonal2::RenderVal(real x, real y)
{
	// rotate by -45°
	//x -= 0.5;
	//y -= 0.5;
	//real sa = -1/sqrt(2);
	//real ca = 1/sqrt(2);
	//real x2 = x*ca + y*sa;
	//real y2 = y*ca - x*sa;
	//x = x2 + 0.5;
	//y = y2 + 0.5;
	// OR:
	// x2 = (x - 0.5)/sqrt(2) - (y - 0.5)/sqrt(2) + 0.5 = (x - y)/sqrt(2) + 0.5
	// y2 = (y - 0.5)/sqrt(2) + (x - 0.5)/sqrt(2) + 0.5 = (y + x - 1)/sqrt(2) + 0.5

	// scale by sqrt(2)
	// x = (x2 - 0.5)*sqrt(2) + 0.5;
	// y = (y2 - 0.5)*sqrt(2) + 0.5;
	// OR:
	// x2 = ((x - y)/sqrt(2) + 0.5 - 0.5)*sqrt(2) + 0.5 = x - y + 0.5
	// y2 = ((y + x - 1)/sqrt(2) + 0.5 - 0.5)*sqrt(2) + 0.5 = y + x - 0.5

	// rotate by -45° and scale by sqrt(2)
	real x2 = x - y + (real)0.5;
	real y2 = y + x - (real)0.5;

	// tiled
	if (x2 >= 1) x2 -= (int)x2;
	if (x2 < 0) x2 += (int)(1 - x2);
	if (y2 >= 1) y2 -= (int)y2;
	if (y2 < 0) y2 += (int)(1 - y2);

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x2, y2);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSeamlessRotate::CFilterSeamlessRotate()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("SeamlessRotate");
	m_HelpID = HELP_FSEAMLESSROTATE;
	m_PropNum = 2;

	m_Prop[PROP_ROT_ANGLE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_ROT_ANGLE].SetName("Angle");
	m_Prop[PROP_ROT_ANGLE].SetMax(8);
	m_Prop[PROP_ROT_ANGLE].SetEnum(SeamlessRotateName);
	m_Prop[PROP_ROT_ANGLE].SetToolID(ID_PROP_ANGLE3);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSeamlessRotate::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real a = m_Prop[PROP_ROT_ANGLE].RenderVal(x, y);
	if (a >= 1) a -= (int)a;
	if (a < 0) a += (int)(1 - a);
	int angle = (int)(a*8 + (real)0.5);

	// rotate by 45° and scale by sqrt(2)
	real x2, y2;
	if ((angle & 1) != 0)
	{
		// rotate by 45° and scale by sqrt(2)
		x2 = x + y - (real)0.5;
		y2 = y - x + (real)0.5;

		// tiled
		if (x2 >= 1) x2 -= (int)x2;
		if (x2 < 0) x2 += (int)(1 - x2);
		if (y2 >= 1) y2 -= (int)y2;
		if (y2 < 0) y2 += (int)(1 - y2);

		x = x2;
		y = y2;
	}

	// transform coordinates
	switch(angle/2)
	{
	// 90°, 135°
	case 1:
		x2 = y;
		y = 1 - x;
		x = x2;
		break;

	// 180°, 225°
	case 2:
		x = 1 - x;
		y = 1 - y;
		break;

	// 270°, 315°
	case 3:
		x2 = 1 - y;
		y = x;
		x = x2;
		break;

	// 0°, 45°
	default:
		break;
	}

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSeamlessRotate::RenderVal(real x, real y)
{
	// load properties
	real a = m_Prop[PROP_ROT_ANGLE].RenderVal(x, y);
	if (a >= 1) a -= (int)a;
	if (a < 0) a += (int)(1 - a);
	int angle = (int)(a*8 + (real)0.5);

	// rotate by 45° and scale by sqrt(2)
	real x2, y2;
	if ((angle & 1) != 0)
	{
		// rotate by 45° and scale by sqrt(2)
		x2 = x + y - (real)0.5;
		y2 = y - x + (real)0.5;

		// tiled
		if (x2 >= 1) x2 -= (int)x2;
		if (x2 < 0) x2 += (int)(1 - x2);
		if (y2 >= 1) y2 -= (int)y2;
		if (y2 < 0) y2 += (int)(1 - y2);

		x = x2;
		y = y2;
	}

	// transform coordinates
	switch(angle/2)
	{
	// 90°, 135°
	case 1:
		x2 = y;
		y = 1 - x;
		x = x2;
		break;

	// 180°, 225°
	case 2:
		x = 1 - x;
		y = 1 - y;
		break;

	// 270°, 315°
	case 3:
		x2 = 1 - y;
		y = x;
		x = x2;
		break;

	// 0°, 45°
	default:
		break;
	}

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}
