		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Gradient Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROP_GRADIENT_COLOR1	0	// property - Color1
#define PROP_GRADIENT_COLOR2	1	// property - Color2
#define PROP_GRADIENT_COLOR3	2	// property - Color3
#define PROP_GRADIENT_COLOR4	3	// property - Color4
#define PROP_GRADIENT_COLOR5	4	// property - Color5
#define PROP_GRADIENT_COLOR6	5	// property - Color6
#define PROP_GRADIENT_COLOR7	6	// property - Color7
#define PROP_GRADIENT_COLOR8	7	// property - Color8
#define PROP_GRADIENT_COLOR9	8	// property - Color9
#define PROP_GRADIENT_COLOR10	9	// property - Color10

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient2::CFilterGradient2()
{
	m_Group = FGRP_GRAD;
	m_Class = _T("Gradient2");
	m_HelpID = HELP_FGRADIENT2;
	m_PropNum = 2;

	m_Prop[PROP_GRADIENT_COLOR1].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR1].SetName("Color1");
	m_Prop[PROP_GRADIENT_COLOR1].SetToolID(ID_PROP_SOURCE);
	m_Prop[PROP_GRADIENT_COLOR1].SetColorRGB(0xFF0000);

	m_Prop[PROP_GRADIENT_COLOR2].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR2].SetName("Color2");
	m_Prop[PROP_GRADIENT_COLOR2].SetToolID(ID_PROP_SOURCE2);
	m_Prop[PROP_GRADIENT_COLOR2].SetColorRGB(0x0000FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient2::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// render colors
	CColor c;
	m_Prop[PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[PROP_GRADIENT_COLOR2].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient2::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// render values
	return m_Prop[PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
		+ m_Prop[PROP_GRADIENT_COLOR2].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient3::CFilterGradient3()
{
	m_Class = _T("Gradient3");
	m_HelpID = HELP_FGRADIENT3;
	m_PropNum = 3;

	m_Prop[PROP_GRADIENT_COLOR2].SetColorRGB(0x00FF00);

	m_Prop[PROP_GRADIENT_COLOR3].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR3].SetName("Color3");
	m_Prop[PROP_GRADIENT_COLOR3].SetToolID(ID_PROP_SOURCE3);
	m_Prop[PROP_GRADIENT_COLOR3].SetColorRGB(0x0000FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient3::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 2;
	int n = (int)k;
	if (n > 1) n = 1;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient3::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 2;
	int n = (int)k;
	if (n > 1) n = 1;
	k -= n;

	// render values
	return m_Prop[n+PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient4::CFilterGradient4()
{
	m_Class = _T("Gradient4");
	m_HelpID = HELP_FGRADIENT4;
	m_PropNum = 4;

	m_Prop[PROP_GRADIENT_COLOR3].SetColorRGB(0x00FFFF);

	m_Prop[PROP_GRADIENT_COLOR4].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR4].SetName("Color4");
	m_Prop[PROP_GRADIENT_COLOR4].SetToolID(ID_PROP_SOURCE4);
	m_Prop[PROP_GRADIENT_COLOR4].SetColorRGB(0x0000FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient4::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 3;
	int n = (int)k;
	if (n > 2) n = 2;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient4::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 3;
	int n = (int)k;
	if (n > 2) n = 2;
	k -= n;

	// render values
	return m_Prop[n+PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient5::CFilterGradient5()
{
	m_Class = _T("Gradient5");
	m_HelpID = HELP_FGRADIENT5;
	m_PropNum = 5;

	m_Prop[PROP_GRADIENT_COLOR2].SetColorRGB(0xFFFF00);
	m_Prop[PROP_GRADIENT_COLOR3].SetColorRGB(0x00FF00);
	m_Prop[PROP_GRADIENT_COLOR4].SetColorRGB(0x00FFFF);

	m_Prop[PROP_GRADIENT_COLOR5].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR5].SetName("Color5");
	m_Prop[PROP_GRADIENT_COLOR5].SetToolID(ID_PROP_SOURCE5);
	m_Prop[PROP_GRADIENT_COLOR5].SetColorRGB(0x0000FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient5::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 4;
	int n = (int)k;
	if (n > 3) n = 3;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient5::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 4;
	int n = (int)k;
	if (n > 3) n = 3;
	k -= n;

	// render values
	return m_Prop[n+PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient6::CFilterGradient6()
{
	m_Class = _T("Gradient6");
	m_HelpID = HELP_FGRADIENT6;
	m_PropNum = 6;

	m_Prop[PROP_GRADIENT_COLOR5].SetColorRGB(0x007FFF);

	m_Prop[PROP_GRADIENT_COLOR6].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR6].SetName("Color6");
	m_Prop[PROP_GRADIENT_COLOR6].SetToolID(ID_PROP_SOURCE6);
	m_Prop[PROP_GRADIENT_COLOR6].SetColorRGB(0x0000FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient6::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 5;
	int n = (int)k;
	if (n > 4) n = 4;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient6::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 5;
	int n = (int)k;
	if (n > 4) n = 4;
	k -= n;

	// render values
	return m_Prop[n+PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient7::CFilterGradient7()
{
	m_Class = _T("Gradient7");
	m_HelpID = HELP_FGRADIENT7;
	m_PropNum = 7;

	m_Prop[PROP_GRADIENT_COLOR2].SetColorRGB(0xFF7F00);
	m_Prop[PROP_GRADIENT_COLOR3].SetColorRGB(0xFFFF00);
	m_Prop[PROP_GRADIENT_COLOR4].SetColorRGB(0x00FF00);
	m_Prop[PROP_GRADIENT_COLOR5].SetColorRGB(0x00FFFF);
	m_Prop[PROP_GRADIENT_COLOR6].SetColorRGB(0x007FFF);

	m_Prop[PROP_GRADIENT_COLOR7].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR7].SetName("Color7");
	m_Prop[PROP_GRADIENT_COLOR7].SetToolID(ID_PROP_SOURCE7);
	m_Prop[PROP_GRADIENT_COLOR7].SetColorRGB(0x0000FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient7::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 6;
	int n = (int)k;
	if (n > 5) n = 5;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient7::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 6;
	int n = (int)k;
	if (n > 5) n = 5;
	k -= n;

	// render values
	return m_Prop[n+PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient8::CFilterGradient8()
{
	m_Class = _T("Gradient8");
	m_HelpID = HELP_FGRADIENT8;
	m_PropNum = 8;

	m_Prop[PROP_GRADIENT_COLOR5].SetColorRGB(0x00FF7F);
	m_Prop[PROP_GRADIENT_COLOR6].SetColorRGB(0x00FFFF);
	m_Prop[PROP_GRADIENT_COLOR7].SetColorRGB(0x007FFF);

	m_Prop[PROP_GRADIENT_COLOR8].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR8].SetName("Color8");
	m_Prop[PROP_GRADIENT_COLOR8].SetToolID(ID_PROP_SOURCE8);
	m_Prop[PROP_GRADIENT_COLOR8].SetColorRGB(0x0000FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient8::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 7;
	int n = (int)k;
	if (n > 6) n = 6;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient8::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 7;
	int n = (int)k;
	if (n > 6) n = 6;
	k -= n;

	// render values
	return m_Prop[n+PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient9::CFilterGradient9()
{
	m_Class = _T("Gradient9");
	m_HelpID = HELP_FGRADIENT9;
	m_PropNum = 9;

	m_Prop[PROP_GRADIENT_COLOR4].SetColorRGB(0x7FFF00);
	m_Prop[PROP_GRADIENT_COLOR5].SetColorRGB(0x00FF00);
	m_Prop[PROP_GRADIENT_COLOR6].SetColorRGB(0x00FF7F);
	m_Prop[PROP_GRADIENT_COLOR7].SetColorRGB(0x00FFFF);
	m_Prop[PROP_GRADIENT_COLOR8].SetColorRGB(0x007FFF);

	m_Prop[PROP_GRADIENT_COLOR9].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR9].SetName("Color9");
	m_Prop[PROP_GRADIENT_COLOR9].SetToolID(ID_PROP_SOURCE9);
	m_Prop[PROP_GRADIENT_COLOR9].SetColorRGB(0x0000FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient9::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 8;
	int n = (int)k;
	if (n > 7) n = 7;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient9::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 8;
	int n = (int)k;
	if (n > 7) n = 7;
	k -= n;

	// render values
	return m_Prop[n+PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGradient10::CFilterGradient10()
{
	m_Class = _T("Gradient10");
	m_HelpID = HELP_FGRADIENT10;
	m_PropNum = 10;

	m_Prop[PROP_GRADIENT_COLOR10].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRADIENT_COLOR10].SetName("Color10");
	m_Prop[PROP_GRADIENT_COLOR10].SetToolID(ID_PROP_SOURCE10);
	m_Prop[PROP_GRADIENT_COLOR10].SetColorRGB(0xFF00FF);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGradient10::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 9;
	int n = (int)k;
	if (n > 8) n = 8;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_GRADIENT_COLOR1].RenderCol(col, x, y);
	m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGradient10::RenderVal(real x, real y)
{
	// X coordinate
	real k = CLAMP(x);

	// get region and remainder
	k *= 9;
	int n = (int)k;
	if (n > 8) n = 8;
	k -= n;

	// render values
	return m_Prop[n+PROP_GRADIENT_COLOR1].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_GRADIENT_COLOR1].RenderVal(x, y)*k;
}

#define PROP_RADIAL_GRADIENT	0	// property - Gradient
#define PROP_RADIAL_X			1	// property - CenterX
#define PROP_RADIAL_Y			2	// property - CenterY
#define PROP_RADIAL_WIDTH		3	// property - Width
#define PROP_RADIAL_HEIGHT		4	// property - Heigth

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRadial::CFilterRadial()
{
	m_Group = FGRP_GRAD;
	m_Class = _T("Radial");
	m_HelpID = HELP_FRADIAL;
	m_PropNum = 5;

	m_Prop[PROP_RADIAL_GRADIENT].SetCategory(PCAT_GRAD);
	m_Prop[PROP_RADIAL_GRADIENT].SetName("Gradient");
	m_Prop[PROP_RADIAL_GRADIENT].SetFilter(&FLinear);
	m_Prop[PROP_RADIAL_GRADIENT].SetToolID(ID_PROP_GRAD);

	m_Prop[PROP_RADIAL_X].SetName("CenterX");
	m_Prop[PROP_RADIAL_X].SetValue(0.5);
	m_Prop[PROP_RADIAL_X].SetMin(-50);
	m_Prop[PROP_RADIAL_X].SetMax(50);
	m_Prop[PROP_RADIAL_X].SetToolID(ID_PROP_RADIALX);

	m_Prop[PROP_RADIAL_Y].SetName("CenterY");
	m_Prop[PROP_RADIAL_Y].SetValue(0.5);
	m_Prop[PROP_RADIAL_Y].SetMin(-50);
	m_Prop[PROP_RADIAL_Y].SetMax(50);
	m_Prop[PROP_RADIAL_Y].SetToolID(ID_PROP_RADIALY);

	m_Prop[PROP_RADIAL_WIDTH].SetName("Width");
	m_Prop[PROP_RADIAL_WIDTH].SetValue((real)0.5);
	m_Prop[PROP_RADIAL_WIDTH].SetToolID(ID_PROP_RADIALW);

	m_Prop[PROP_RADIAL_HEIGHT].SetName("Height");
	m_Prop[PROP_RADIAL_HEIGHT].SetValue((real)0.5);
	m_Prop[PROP_RADIAL_HEIGHT].SetToolID(ID_PROP_RADIALH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRadial::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real centerx = m_Prop[PROP_RADIAL_X].RenderVal(x, y);
	real centery = m_Prop[PROP_RADIAL_Y].RenderVal(x, y);
	real width = m_Prop[PROP_RADIAL_WIDTH].RenderVal(x, y) + (real)1e-10;
	real height = m_Prop[PROP_RADIAL_HEIGHT].RenderVal(x, y) + (real)1e-10;

	// gradient coordinate
	real x2 = (x - centerx)/width;
	real y2 = (y - centery)/height;
	real val = sqrt(x2*x2 + y2*y2);

	// render color
	m_Prop[PROP_RADIAL_GRADIENT].RenderCol(col, val, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRadial::RenderVal(real x, real y)
{
	// load properties
	real centerx = m_Prop[PROP_RADIAL_X].RenderVal(x, y);
	real centery = m_Prop[PROP_RADIAL_Y].RenderVal(x, y);
	real width = m_Prop[PROP_RADIAL_WIDTH].RenderVal(x, y) + (real)1e-10;
	real height = m_Prop[PROP_RADIAL_HEIGHT].RenderVal(x, y) + (real)1e-10;

	// gradient coordinate
	real x2 = (x - centerx)/width;
	real y2 = (y - centery)/height;
	real val = sqrt(x2*x2 + y2*y2);

	// render value
	return m_Prop[PROP_RADIAL_GRADIENT].RenderVal(val, y);
}

#define PROP_ANGULAR_GRADIENT	0	// property - Gradient
#define PROP_ANGULAR_X			1	// property - CenterX
#define PROP_ANGULAR_Y			2	// property - CenterY
#define PROP_ANGULAR_REPEAT		3	// property - Repeat
#define PROP_ANGULAR_MIRROR		4	// property - Mirror

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterAngular::CFilterAngular()
{
	m_Group = FGRP_GRAD;
	m_Class = _T("Angular");
	m_HelpID = HELP_FANGULAR;
	m_PropNum = 5;

	m_Prop[PROP_ANGULAR_GRADIENT].SetCategory(PCAT_GRAD);
	m_Prop[PROP_ANGULAR_GRADIENT].SetName("Gradient");
	m_Prop[PROP_ANGULAR_GRADIENT].SetFilter(&FLinear);
	m_Prop[PROP_ANGULAR_GRADIENT].SetToolID(ID_PROP_GRAD);

	m_Prop[PROP_ANGULAR_X].SetName("CenterX");
	m_Prop[PROP_ANGULAR_X].SetValue(0.5);
	m_Prop[PROP_ANGULAR_X].SetMin(-50);
	m_Prop[PROP_ANGULAR_X].SetMax(50);
	m_Prop[PROP_ANGULAR_X].SetToolID(ID_PROP_RADIALX);

	m_Prop[PROP_ANGULAR_Y].SetName("CenterY");
	m_Prop[PROP_ANGULAR_Y].SetValue(0.5);
	m_Prop[PROP_ANGULAR_Y].SetMin(-50);
	m_Prop[PROP_ANGULAR_Y].SetMax(50);
	m_Prop[PROP_ANGULAR_Y].SetToolID(ID_PROP_RADIALY);

	m_Prop[PROP_ANGULAR_REPEAT].SetName("Repeat");
	m_Prop[PROP_ANGULAR_REPEAT].SetMinVal((real)0.01);
	m_Prop[PROP_ANGULAR_REPEAT].SetValue((real)0.01);
	m_Prop[PROP_ANGULAR_REPEAT].SetMin(1);
	m_Prop[PROP_ANGULAR_REPEAT].SetToolID(ID_PROP_REPEAT);

	m_Prop[PROP_ANGULAR_MIRROR].SetCategory(PCAT_CHECK);
	m_Prop[PROP_ANGULAR_MIRROR].SetName("Mirror");
	m_Prop[PROP_ANGULAR_MIRROR].SetMax(1);
	m_Prop[PROP_ANGULAR_MIRROR].SetToolID(ID_PROP_ANGULARMIRROR);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterAngular::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real centerx = m_Prop[PROP_ANGULAR_X].RenderVal(x, y);
	real centery = m_Prop[PROP_ANGULAR_Y].RenderVal(x, y);
	real repeat = m_Prop[PROP_ANGULAR_REPEAT].RenderVal(x, y)*100;
	bool mirror = m_Prop[PROP_ANGULAR_MIRROR].RenderVal(x, y) >= (real)0.5;

	// center
	x -= centerx;
	y -= centery;

	// polar cooordinates
	x *= 2;
	y *= 2;
	real d = sqrt(x*x + y*y);
	x = atan2(x, y)/PI2 + (real)0.5;
	y = d;

	// repeat
	x *= repeat;
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);

	// mirror
	if (mirror)
	{
		x *= 2;
		if (x >= 1) x = (2 - x);
	}

	// render color
	m_Prop[PROP_ANGULAR_GRADIENT].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterAngular::RenderVal(real x, real y)
{
	// load properties
	real centerx = m_Prop[PROP_ANGULAR_X].RenderVal(x, y);
	real centery = m_Prop[PROP_ANGULAR_Y].RenderVal(x, y);
	real repeat = m_Prop[PROP_ANGULAR_REPEAT].RenderVal(x, y)*100;
	bool mirror = m_Prop[PROP_ANGULAR_MIRROR].RenderVal(x, y) >= (real)0.5;

	// center
	x -= centerx;
	y -= centery;

	// polar cooordinates
	x *= 2;
	y *= 2;
	real d = sqrt(x*x + y*y);
	x = atan2(x, y)/PI2 + (real)0.5;
	y = d;

	// repeat
	x *= repeat;
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);

	// mirror
	if (mirror)
	{
		x *= 2;
		if (x >= 1) x = (2 - x);
	}

	// render value
	return m_Prop[PROP_ANGULAR_GRADIENT].RenderVal(x, y);
}

#define PROP_COLNOI_DETAILS		0		// property - Details (0..1 = 0 smooth (1 noise octave) ... 1 detailed (11 noise octaves), default 0.5)
#define PROP_COLNOI_ROUGHNESS	1		// property - Roughness (0..1 = 0 smooth ... 1 roughness (noticable higher octaves), default 0.5)
#define PROP_COLNOI_SCALE		2		// property - Scale (0..1 = scale, 0=256x small..1=normal, default 0.5)
#define PROP_COLNOI_SHIFT		3		// property - Shift (0..1 = shift to left or right edge, default 0.5)
#define PROP_COLNOI_SEED		4		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterColorNoise::CFilterColorNoise()
{
	m_Group = FGRP_GRAD;
	m_Class = _T("ColorNoise");
	m_HelpID = HELP_FCOLORNOISE;
	m_PropNum = 5;

	m_Prop[PROP_COLNOI_DETAILS].SetName("Details");
	m_Prop[PROP_COLNOI_DETAILS].SetMinVal((real)0.1);
	m_Prop[PROP_COLNOI_DETAILS].SetMin(1);
	m_Prop[PROP_COLNOI_DETAILS].SetMax(10);
	m_Prop[PROP_COLNOI_DETAILS].SetValue((real)0.5);
	m_Prop[PROP_COLNOI_DETAILS].SetToolID(ID_PROP_DETAILS);

	m_Prop[PROP_COLNOI_ROUGHNESS].SetName("Roughness");
	m_Prop[PROP_COLNOI_ROUGHNESS].SetValue((real)0.5);
	m_Prop[PROP_COLNOI_ROUGHNESS].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_COLNOI_SCALE].SetName("Scale");
	m_Prop[PROP_COLNOI_SCALE].SetValue((real)0.5);
	m_Prop[PROP_COLNOI_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_COLNOI_SHIFT].SetName("Shift");
	m_Prop[PROP_COLNOI_SHIFT].SetValue((real)0.5);
	m_Prop[PROP_COLNOI_SHIFT].SetMin(-50);
	m_Prop[PROP_COLNOI_SHIFT].SetMax(50);
	m_Prop[PROP_COLNOI_SHIFT].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_COLNOI_SEED].SetName("Seed");
	m_Prop[PROP_COLNOI_SEED].SetMax(1000);
	m_Prop[PROP_COLNOI_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterColorNoise::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real details = CLAMP(m_Prop[PROP_COLNOI_DETAILS].RenderVal(x, y));
	real roughness = m_Prop[PROP_COLNOI_ROUGHNESS].RenderVal(x, y);
	int scale = (int)(pow(2,CLAMP(1-m_Prop[PROP_COLNOI_SCALE].RenderVal(x, y))*8)+(real)0.5);
	int seed = (int)(m_Prop[PROP_COLNOI_SEED].RenderVal(x, y)*1000 + (real)0.5 + 153);

	// contrast correction from roughness
	real contrast = (real)0.5;
	contrast /= (real)(roughness*roughness*1.5+0.5);

	// render gradient
	x -= m_Prop[PROP_COLNOI_SHIFT].RenderVal(x, y);
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);

	scale++;
	col->SetBlack();
	int bands = (int)(details*10+0.5);
	if (bands < 1) bands = 1;
	for (; bands > 0; bands--)
	{
		real val1 = SmoothNoise1D(x, scale, seed);
		col->r += val1 * contrast;

		val1 = SmoothNoise1D(x, scale, seed + 29);
		col->g += val1 * contrast;

		val1 = SmoothNoise1D(x, scale, seed + 357);
		col->b += val1 * contrast;

		scale *= 2;

		contrast *= roughness;
		roughness *= (real)1.1;
		seed += 5;
	}

	col->r = CLAMP(col->r/2 + (real)0.5);
	col->g = CLAMP(col->g/2 + (real)0.5);
	col->b = CLAMP(col->b/2 + (real)0.5);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterColorNoise::RenderVal(real x, real y)
{
	CColor col;
	CFilterColorNoise::RenderCol(&col, x, y);
	return col.Gray();
}
