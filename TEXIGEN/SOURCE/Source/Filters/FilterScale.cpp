				   
///////////////////////////////////////////////////////////////////////////////
//
//                               Scale Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterScale::CFilterScale()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Scale");
	m_HelpID = HELP_FSCALE;
	m_PropNum = 6;

	m_Prop[PROP_SCALE_SCALE].SetName("Scale");
	m_Prop[PROP_SCALE_SCALE].SetValue(0.5);
	m_Prop[PROP_SCALE_SCALE].SetMin(-50);
	m_Prop[PROP_SCALE_SCALE].SetMax(50);
	m_Prop[PROP_SCALE_SCALE].SetToolID(ID_PROP_SCALE2);

	m_Prop[PROP_SCALE_STRETCHX].SetName("StretchX");
	m_Prop[PROP_SCALE_STRETCHX].SetValue(0.5);
	m_Prop[PROP_SCALE_STRETCHX].SetMin(-50);
	m_Prop[PROP_SCALE_STRETCHX].SetMax(50);
	m_Prop[PROP_SCALE_STRETCHX].SetToolID(ID_PROP_STRETCHX);

	m_Prop[PROP_SCALE_STRETCHY].SetName("StretchY");
	m_Prop[PROP_SCALE_STRETCHY].SetValue(0.5);
	m_Prop[PROP_SCALE_STRETCHY].SetMin(-50);
	m_Prop[PROP_SCALE_STRETCHY].SetMax(50);
	m_Prop[PROP_SCALE_STRETCHY].SetToolID(ID_PROP_STRETCHY);

	m_Prop[PROP_SCALE_X].SetName("CenterX");
	m_Prop[PROP_SCALE_X].SetValue(0.5);
	m_Prop[PROP_SCALE_X].SetMin(-50);
	m_Prop[PROP_SCALE_X].SetMax(50);
	m_Prop[PROP_SCALE_X].SetToolID(ID_PROP_SCALEX);

	m_Prop[PROP_SCALE_Y].SetName("CenterY");
	m_Prop[PROP_SCALE_Y].SetValue(0.5);
	m_Prop[PROP_SCALE_Y].SetMin(-50);
	m_Prop[PROP_SCALE_Y].SetMax(50);
	m_Prop[PROP_SCALE_Y].SetToolID(ID_PROP_SCALEY);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterScale::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real scale = pow(2,((real)0.5 - m_Prop[PROP_SCALE_SCALE].RenderVal(x, y))*8);
	real stretchx = pow(2,((real)0.5 - m_Prop[PROP_SCALE_STRETCHX].RenderVal(x, y))*4) * scale;
	real stretchy = pow(2,((real)0.5 - m_Prop[PROP_SCALE_STRETCHY].RenderVal(x, y))*4) * scale;
	real centerx = m_Prop[PROP_SCALE_X].RenderVal(x, y);
	real centery = m_Prop[PROP_SCALE_Y].RenderVal(x, y);

	// transform coordinates
	x = (x - centerx) * stretchx + centerx;
	y = (y - centery) * stretchy + centery;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterScale::RenderVal(real x, real y)
{
	// load properties
	real scale = pow(2,((real)0.5 - m_Prop[PROP_SCALE_SCALE].RenderVal(x, y))*8);
	real stretchx = pow(2,((real)0.5 - m_Prop[PROP_SCALE_STRETCHX].RenderVal(x, y))*4) * scale;
	real stretchy = pow(2,((real)0.5 - m_Prop[PROP_SCALE_STRETCHY].RenderVal(x, y))*4) * scale;
	real centerx = m_Prop[PROP_SCALE_X].RenderVal(x, y);
	real centery = m_Prop[PROP_SCALE_Y].RenderVal(x, y);

	// transform coordinates
	x = (x - centerx) * stretchx + centerx;
	y = (y - centery) * stretchy + centery;

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTaper::CFilterTaper()
{
	m_Group = FGRP_DEF;
	m_Class = _T("Taper");
	m_HelpID = HELP_FTAPER;
	m_PropNum = 5;

	m_Prop[PROP_TAPER_TAPERX].SetName("TaperX");
	m_Prop[PROP_TAPER_TAPERX].SetValue(0.5);
	m_Prop[PROP_TAPER_TAPERX].SetMin(-50);
	m_Prop[PROP_TAPER_TAPERX].SetMax(50);
	m_Prop[PROP_TAPER_TAPERX].SetToolID(ID_PROP_TAPERX);

	m_Prop[PROP_TAPER_TAPERY].SetName("TaperY");
	m_Prop[PROP_TAPER_TAPERY].SetValue(0.5);
	m_Prop[PROP_TAPER_TAPERY].SetMin(-50);
	m_Prop[PROP_TAPER_TAPERY].SetMax(50);
	m_Prop[PROP_TAPER_TAPERY].SetToolID(ID_PROP_TAPERY);

	m_Prop[PROP_TAPER_X].SetName("CenterX");
	m_Prop[PROP_TAPER_X].SetValue(0.5);
	m_Prop[PROP_TAPER_X].SetMin(-50);
	m_Prop[PROP_TAPER_X].SetMax(50);
	m_Prop[PROP_TAPER_X].SetToolID(ID_PROP_TAPERX2);

	m_Prop[PROP_TAPER_Y].SetName("CenterY");
	m_Prop[PROP_TAPER_Y].SetValue(0.5);
	m_Prop[PROP_TAPER_Y].SetMin(-50);
	m_Prop[PROP_TAPER_Y].SetMax(50);
	m_Prop[PROP_TAPER_Y].SetToolID(ID_PROP_TAPERY2);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTaper::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real taperx = 4*m_Prop[PROP_TAPER_TAPERX].RenderVal(x, y) - 2;
	real tapery = 4*m_Prop[PROP_TAPER_TAPERY].RenderVal(x, y) - 2;
	real centerx = m_Prop[PROP_TAPER_X].RenderVal(x, y);
	real centery = m_Prop[PROP_TAPER_Y].RenderVal(x, y);

	// transform coordinates
	real k = 1/((1 - taperx*(x - centerx))*(1 - tapery*(y - centery)));
	x = (x - centerx)*k + centerx;
	y = (y - centery)*k + centery;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTaper::RenderVal(real x, real y)
{
	// load properties
	real taperx = 4*m_Prop[PROP_TAPER_TAPERX].RenderVal(x, y) - 2;
	real tapery = 4*m_Prop[PROP_TAPER_TAPERY].RenderVal(x, y) - 2;
	real centerx = m_Prop[PROP_TAPER_X].RenderVal(x, y);
	real centery = m_Prop[PROP_TAPER_Y].RenderVal(x, y);

	// transform coordinates
	real k = 1/((1 - taperx*(x - centerx))*(1 - tapery*(y - centery)));
	x = (x - centerx)*k + centerx;
	y = (y - centery)*k + centery;

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDeform::CFilterDeform()
{
	m_Group = FGRP_DEF;
	m_Class = _T("Deform");
	m_HelpID = HELP_FDEFORM;
	m_PropNum = 11;

	m_Prop[PROP_SOURCE].SetColor(0,0,0,0);

	m_Prop[PROP_DEFORM_BACK].SetName("Backface");
	m_Prop[PROP_DEFORM_BACK].SetToolID(ID_PROP_BACKFACE);
	m_Prop[PROP_DEFORM_BACK].SetColor(0,0,0,0);

	m_Prop[PROP_DEFORM_BG].SetName("Background");
	m_Prop[PROP_DEFORM_BG].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_DEFORM_BG].SetColor(0,0,0,0);

	m_Prop[PROP_DEFORM_X1].SetName("X1");
	m_Prop[PROP_DEFORM_X1].SetValue(0.25);
	m_Prop[PROP_DEFORM_X1].SetMin(-50);
	m_Prop[PROP_DEFORM_X1].SetMax(50);
	m_Prop[PROP_DEFORM_X1].SetToolID(ID_PROP_DEFORMX1);

	m_Prop[PROP_DEFORM_Y1].SetName("Y1");
	m_Prop[PROP_DEFORM_Y1].SetValue(0.25);
	m_Prop[PROP_DEFORM_Y1].SetMin(-50);
	m_Prop[PROP_DEFORM_Y1].SetMax(50);
	m_Prop[PROP_DEFORM_Y1].SetToolID(ID_PROP_DEFORMY1);

	m_Prop[PROP_DEFORM_X2].SetName("X2");
	m_Prop[PROP_DEFORM_X2].SetValue(0.25);
	m_Prop[PROP_DEFORM_X2].SetMin(-50);
	m_Prop[PROP_DEFORM_X2].SetMax(50);
	m_Prop[PROP_DEFORM_X2].SetToolID(ID_PROP_DEFORMX2);

	m_Prop[PROP_DEFORM_Y2].SetName("Y2");
	m_Prop[PROP_DEFORM_Y2].SetValue(0.75);
	m_Prop[PROP_DEFORM_Y2].SetMin(-50);
	m_Prop[PROP_DEFORM_Y2].SetMax(50);
	m_Prop[PROP_DEFORM_Y2].SetToolID(ID_PROP_DEFORMY2);

	m_Prop[PROP_DEFORM_X3].SetName("X3");
	m_Prop[PROP_DEFORM_X3].SetValue(0.75);
	m_Prop[PROP_DEFORM_X3].SetMin(-50);
	m_Prop[PROP_DEFORM_X3].SetMax(50);
	m_Prop[PROP_DEFORM_X3].SetToolID(ID_PROP_DEFORMX3);

	m_Prop[PROP_DEFORM_Y3].SetName("Y3");
	m_Prop[PROP_DEFORM_Y3].SetValue(0.75);
	m_Prop[PROP_DEFORM_Y3].SetMin(-50);
	m_Prop[PROP_DEFORM_Y3].SetMax(50);
	m_Prop[PROP_DEFORM_Y3].SetToolID(ID_PROP_DEFORMY3);

	m_Prop[PROP_DEFORM_X4].SetName("X4");
	m_Prop[PROP_DEFORM_X4].SetValue(0.75);
	m_Prop[PROP_DEFORM_X4].SetMin(-50);
	m_Prop[PROP_DEFORM_X4].SetMax(50);
	m_Prop[PROP_DEFORM_X4].SetToolID(ID_PROP_DEFORMX4);

	m_Prop[PROP_DEFORM_Y4].SetName("Y4");
	m_Prop[PROP_DEFORM_Y4].SetValue(0.25);
	m_Prop[PROP_DEFORM_Y4].SetMin(-50);
	m_Prop[PROP_DEFORM_Y4].SetMax(50);
	m_Prop[PROP_DEFORM_Y4].SetToolID(ID_PROP_DEFORMY4);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDeform::RenderCol(CColor* col, real x, real y)
{
	// load properties (with some deviation to avoid undefined state)
	real x1 = m_Prop[PROP_DEFORM_X1].RenderVal(x, y) - (real)1.1e-6;
	real y1 = m_Prop[PROP_DEFORM_Y1].RenderVal(x, y) - (real)1.2e-6;
	real x2 = m_Prop[PROP_DEFORM_X2].RenderVal(x, y) - (real)1.3e-6;
	real y2 = m_Prop[PROP_DEFORM_Y2].RenderVal(x, y) + (real)1.4e-6;
	real x3 = m_Prop[PROP_DEFORM_X3].RenderVal(x, y) + (real)1.5e-6;
	real y3 = m_Prop[PROP_DEFORM_Y3].RenderVal(x, y) + (real)1.6e-6;
	real x4 = m_Prop[PROP_DEFORM_X4].RenderVal(x, y) + (real)1.7e-6;
	real y4 = m_Prop[PROP_DEFORM_Y4].RenderVal(x, y) - (real)1.8e-6;

	real x0 = x;
	real y0 = y;

	//  2  23   3
	//      0
	//  1  14   4
	//
	// x14 = (x4 - x1)*x + x1		y14 = (y4 - y1)*x + y1
	// x23 = (x3 - x2)*x + x2		y23 = (y3 - y2)*x + y2
	// x0 = (x23 - x14)*y + x14		y0 = (y23 - y14)*y + y14
	// --------
	// x0 = ((x3 - x2)*x + x2 - (x4 - x1)*x - x1)*y + (x4 - x1)*x + x1 = (x3-x2-x4+x1)*x*y + (x4-x1)*x + (x2-x1)*y + x1
	// y0 = ((y3 - y2)*x + y2 - (y4 - y1)*x - y1)*y + (y4 - y1)*x + y1 = (y3-y2-y4+y1)*x*y + (y4-y1)*x + (y2-y1)*y + y1
	// --------
	// a = x3 - x2 - x4 + x1
	// b = x4 - x1
	// c = x2 - x1
	// d = x1 - x0
	// e = y3 - y2 - y4 + y1
	// f = y4 - y1
	// g = y2 - y1
	// h = y1 - y0
	//
	// a*x*y + b*x + c*y + d = 0
	// e*x*y + f*x + g*y + h = 0

	real a = x3 - x2 - x4 + x1;
	real b = x4 - x1;
	real c = x2 - x1;
	real d = x1 - x0;
	real e = y3 - y2 - y4 + y1;
	real f = y4 - y1;
	real g = y2 - y1;
	real h = y1 - y0;

	// -------
	// (a*y + b)*x + c*y + d = 0   x = (-d - c*y)/(a*y + b)
	// (e*y + f)*x + g*y + h = 0   x = (-h - g*y)/(e*y + f)
	//
	// (-d - c*y)/(a*y + b) = (-h - g*y)/(e*y + f)
	// (-d - c*y)*(e*y + f) = (-h - g*y)*(a*y + b)
	// -d*e*y - c*e*y^2 - d*f - c*f*y = -h*a*y - g*a*y^2 - h*b - g*b*y
	// (g*a-c*e)*y^2 + (h*a+g*b-d*e-c*f)*y + (h*b-d*f) = 0
	//
	// m = g*a-c*e
	// n = h*a+g*b-d*e-c*f
	// o = h*b-d*f
	// m*y^2 + n*y + o = 0
	// y(1,2) = (+-sqrt(n*n - 4*m*o) - n)/(2*m)

	real m = g*a - c*e;
	real n = h*a + g*b - d*e - c*f;
	real o = h*b - d*f;
	real kk = n*n - 4*m*o;
	if ((kk < 0) || (abs(m) < (real)1e-25))
	{
		m_Prop[PROP_DEFORM_BG].RenderCol(col, x, y);
		return;
	}
	m = 1/(2*m);
	kk = sqrt(kk);
	real yy = (kk - n)*m;

	// --------
	// (a*x + c)*y + b*x + d = 0	y = (-d - b*x)/(a*x + c)
	// (e*x + g)*y + f*x + h = 0	y = (-h - f*x)/(e*x + g)
	//
	// (-d - b*x)/(a*x + c) = (-h - f*x)/(e*x + g)
	// (-d - b*x)*(e*x + g) = (-h - f*x)*(a*x + c)
	// -d*e*x - b*e*x^2 - d*g - b*g*x = -h*a*x - f*a*x^2 - h*c - f*c*x
	// (f*a-b*e)*x^2 + (h*a+f*c-d*e-b*g)*x + (h*c-d*g) = 0
	//
	// p = f*a-b*e
	// q = h*a+f*c-d*e-b*g
	// r = h*c-d*g
	// p*x^2 + q*x + r = 0
	// x(1,2) = (+-sqrt(q*q - 4*p*r) - q)/(2*p)

	real p = f*a - b*e;
	real q = h*a + f*c - d*e - b*g;
	real r = h*c - d*g;
	real kk2 = q*q - 4*p*r;
	if ((kk2 < 0) || (abs(p) < (real)1e-25))
	{
		m_Prop[PROP_DEFORM_BG].RenderCol(col, x, y);
		return;
	}
	p = 1/(2*p);
	kk2 = sqrt(kk2);
	real xx = (-kk2 - q)*p;

	// backface
	int id = PROP_SOURCE;
	if ((yy < 0) || (yy >= 1) || (xx < 0) || (xx >= 1))
	{
		yy = (-kk - n)*m;
		xx = (kk2 - q)*p;
		id = PROP_DEFORM_BACK;
	}

	// invalid
	if ((yy < 0) || (yy >= 1) || (xx < 0) || (xx >= 1))
	{
		m_Prop[PROP_DEFORM_BG].RenderCol(col, x, y);
		return;
	}

	// render color
	m_Prop[id].RenderCol(col, xx, yy);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDeform::RenderVal(real x, real y)
{
	CColor col;
	CFilterDeform::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterEnform::CFilterEnform()
{
	m_Group = FGRP_DEF;
	m_Class = _T("Enform");
	m_HelpID = HELP_FENFORM;
	m_PropNum = 9;

	m_Prop[PROP_ENFORM_X1].SetName("X1");
	m_Prop[PROP_ENFORM_X1].SetValue(0);
	m_Prop[PROP_ENFORM_X1].SetMin(-50);
	m_Prop[PROP_ENFORM_X1].SetMax(50);
	m_Prop[PROP_ENFORM_X1].SetToolID(ID_PROP_DEFORMX1);

	m_Prop[PROP_ENFORM_Y1].SetName("Y1");
	m_Prop[PROP_ENFORM_Y1].SetValue(0);
	m_Prop[PROP_ENFORM_Y1].SetMin(-50);
	m_Prop[PROP_ENFORM_Y1].SetMax(50);
	m_Prop[PROP_ENFORM_Y1].SetToolID(ID_PROP_DEFORMY1);

	m_Prop[PROP_ENFORM_X2].SetName("X2");
	m_Prop[PROP_ENFORM_X2].SetValue(0);
	m_Prop[PROP_ENFORM_X2].SetMin(-50);
	m_Prop[PROP_ENFORM_X2].SetMax(50);
	m_Prop[PROP_ENFORM_X2].SetToolID(ID_PROP_DEFORMX2);

	m_Prop[PROP_ENFORM_Y2].SetName("Y2");
	m_Prop[PROP_ENFORM_Y2].SetValue(1);
	m_Prop[PROP_ENFORM_Y2].SetMin(-50);
	m_Prop[PROP_ENFORM_Y2].SetMax(50);
	m_Prop[PROP_ENFORM_Y2].SetToolID(ID_PROP_DEFORMY2);

	m_Prop[PROP_ENFORM_X3].SetName("X3");
	m_Prop[PROP_ENFORM_X3].SetValue(1);
	m_Prop[PROP_ENFORM_X3].SetMin(-50);
	m_Prop[PROP_ENFORM_X3].SetMax(50);
	m_Prop[PROP_ENFORM_X3].SetToolID(ID_PROP_DEFORMX3);

	m_Prop[PROP_ENFORM_Y3].SetName("Y3");
	m_Prop[PROP_ENFORM_Y3].SetValue(1);
	m_Prop[PROP_ENFORM_Y3].SetMin(-50);
	m_Prop[PROP_ENFORM_Y3].SetMax(50);
	m_Prop[PROP_ENFORM_Y3].SetToolID(ID_PROP_DEFORMY3);

	m_Prop[PROP_ENFORM_X4].SetName("X4");
	m_Prop[PROP_ENFORM_X4].SetValue(1);
	m_Prop[PROP_ENFORM_X4].SetMin(-50);
	m_Prop[PROP_ENFORM_X4].SetMax(50);
	m_Prop[PROP_ENFORM_X4].SetToolID(ID_PROP_DEFORMX4);

	m_Prop[PROP_ENFORM_Y4].SetName("Y4");
	m_Prop[PROP_ENFORM_Y4].SetValue(0);
	m_Prop[PROP_ENFORM_Y4].SetMin(-50);
	m_Prop[PROP_ENFORM_Y4].SetMax(50);
	m_Prop[PROP_ENFORM_Y4].SetToolID(ID_PROP_DEFORMY4);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterEnform::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real x1 = m_Prop[PROP_ENFORM_X1].RenderVal(x, y);
	real y1 = m_Prop[PROP_ENFORM_Y1].RenderVal(x, y);
	real x2 = m_Prop[PROP_ENFORM_X2].RenderVal(x, y);
	real y2 = m_Prop[PROP_ENFORM_Y2].RenderVal(x, y);
	real x3 = m_Prop[PROP_ENFORM_X3].RenderVal(x, y);
	real y3 = m_Prop[PROP_ENFORM_Y3].RenderVal(x, y);
	real x4 = m_Prop[PROP_ENFORM_X4].RenderVal(x, y);
	real y4 = m_Prop[PROP_ENFORM_Y4].RenderVal(x, y);

	// transpose coordinates
	real xx = (x3-x2-x4+x1)*x*y + (x4-x1)*x + (x2-x1)*y + x1;
	real yy = (y3-y2-y4+y1)*x*y + (y4-y1)*x + (y2-y1)*y + y1;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, xx, yy);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterEnform::RenderVal(real x, real y)
{
	// load properties
	real x1 = m_Prop[PROP_ENFORM_X1].RenderVal(x, y);
	real y1 = m_Prop[PROP_ENFORM_Y1].RenderVal(x, y);
	real x2 = m_Prop[PROP_ENFORM_X2].RenderVal(x, y);
	real y2 = m_Prop[PROP_ENFORM_Y2].RenderVal(x, y);
	real x3 = m_Prop[PROP_ENFORM_X3].RenderVal(x, y);
	real y3 = m_Prop[PROP_ENFORM_Y3].RenderVal(x, y);
	real x4 = m_Prop[PROP_ENFORM_X4].RenderVal(x, y);
	real y4 = m_Prop[PROP_ENFORM_Y4].RenderVal(x, y);

	// transpose coordinates
	real xx = (x3-x2-x4+x1)*x*y + (x4-x1)*x + (x2-x1)*y + x1;
	real yy = (y3-y2-y4+y1)*x*y + (y4-y1)*x + (y2-y1)*y + y1;

	// render color
	return m_Prop[PROP_SOURCE].RenderVal(xx, yy);
}

#define PROP_TILE_REPEAT		1		// property - Repeat

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTileX::CFilterTileX()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("TileX");
	m_HelpID = HELP_FTILEX;
	m_PropNum = 2;

	m_Prop[PROP_TILE_REPEAT].SetName("Repeat");
	m_Prop[PROP_TILE_REPEAT].SetMinVal((real)0.01);
	m_Prop[PROP_TILE_REPEAT].SetValue((real)0.01);
	m_Prop[PROP_TILE_REPEAT].SetMin(1);
	m_Prop[PROP_TILE_REPEAT].SetToolID(ID_PROP_REPEAT);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTileX::RenderCol(CColor* col, real x, real y)
{
	int repeat = (int)(CLAMP(m_Prop[PROP_TILE_REPEAT].RenderVal(x, y))*100 + (real)0.5);
	if (repeat < 1) repeat = 1;
	x *= repeat;
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTileX::RenderVal(real x, real y)
{
	int repeat = (int)(CLAMP(m_Prop[PROP_TILE_REPEAT].RenderVal(x, y))*100 + (real)0.5);
	if (repeat < 1) repeat = 1;
	x *= repeat;
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTileY::CFilterTileY()
{
	m_Class = _T("TileY");
	m_HelpID = HELP_FTILEY;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTileY::RenderCol(CColor* col, real x, real y)
{
	int repeat = (int)(CLAMP(m_Prop[PROP_TILE_REPEAT].RenderVal(x, y))*100 + (real)0.5);
	if (repeat < 1) repeat = 1;
	y *= repeat;
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTileY::RenderVal(real x, real y)
{
	int repeat = (int)(CLAMP(m_Prop[PROP_TILE_REPEAT].RenderVal(x, y))*100 + (real)0.5);
	if (repeat < 1) repeat = 1;
	y *= repeat;
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTile::CFilterTile()
{
	m_Class = _T("Tile");
	m_HelpID = HELP_FTILE;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTile::RenderCol(CColor* col, real x, real y)
{
	int repeat = (int)(CLAMP(m_Prop[PROP_TILE_REPEAT].RenderVal(x, y))*100 + (real)0.5);
	if (repeat < 1) repeat = 1;
	x *= repeat;
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	y *= repeat;
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTile::RenderVal(real x, real y)
{
	int repeat = (int)(CLAMP(m_Prop[PROP_TILE_REPEAT].RenderVal(x, y))*100 + (real)0.5);
	if (repeat < 1) repeat = 1;
	x *= repeat;
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	y *= repeat;
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterFlipX::CFilterFlipX()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("FlipX");
	m_HelpID = HELP_FFLIPX;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterFlipX::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, 1-x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterFlipX::RenderVal(real x, real y)
{
	return m_Prop[PROP_SOURCE].RenderVal(1-x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterFlipY::CFilterFlipY()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("FlipY");
	m_HelpID = HELP_FFLIPY;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterFlipY::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, 1-y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterFlipY::RenderVal(real x, real y)
{
	return m_Prop[PROP_SOURCE].RenderVal(x, 1-y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMirrorX::CFilterMirrorX()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("MirrorX");
	m_HelpID = HELP_FMIRRORX;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMirrorX::RenderCol(CColor* col, real x, real y)
{
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	x *= 2;
	m_Prop[PROP_SOURCE].RenderCol(col, (x >= 1) ? (2 - x) : x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMirrorX::RenderVal(real x, real y)
{
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	x *= 2;
	return m_Prop[PROP_SOURCE].RenderVal((x >= 1) ? (2 - x) : x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMirrorY::CFilterMirrorY()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("MirrorY");
	m_HelpID = HELP_FMIRRORY;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMirrorY::RenderCol(CColor* col, real x, real y)
{
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	y *= 2;
	m_Prop[PROP_SOURCE].RenderCol(col, x, (y >= 1) ? (2 - y) : y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMirrorY::RenderVal(real x, real y)
{
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	y *= 2;
	return m_Prop[PROP_SOURCE].RenderVal(x, (y >= 1) ? (2 - y) : y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMirror::CFilterMirror()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Mirror");
	m_HelpID = HELP_FMIRROR;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMirror::RenderCol(CColor* col, real x, real y)
{
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	x *= 2;
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	y *= 2;
	m_Prop[PROP_SOURCE].RenderCol(col, (x >= 1) ? (2 - x) : x, (y >= 1) ? (2 - y) : y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMirror::RenderVal(real x, real y)
{
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	x *= 2;
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	y *= 2;
	return m_Prop[PROP_SOURCE].RenderVal((x >= 1) ? (2 - x) : x, (y >= 1) ? (2 - y) : y);
}

#define PROP_SEAM_BLENDX		1		// property - BlendX
#define PROP_SEAM_BLENDY		2		// property - BlendY

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSeamless::CFilterSeamless()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Seamless");
	m_HelpID = HELP_FSEAMLESS;
	m_PropNum = 3;

	m_Prop[PROP_SEAM_BLENDX].SetName("BlendX");
	m_Prop[PROP_SEAM_BLENDX].SetValue((real)0.1);
	m_Prop[PROP_SEAM_BLENDX].SetToolID(ID_PROP_BLENDX);

	m_Prop[PROP_SEAM_BLENDY].SetName("BlendY");
	m_Prop[PROP_SEAM_BLENDY].SetValue((real)0.1);
	m_Prop[PROP_SEAM_BLENDY].SetToolID(ID_PROP_BLENDY);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSeamless::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real mx = CLAMP(m_Prop[PROP_SEAM_BLENDX].RenderVal(x, y))/2;
	real my = CLAMP(m_Prop[PROP_SEAM_BLENDY].RenderVal(x, y))/2;
	bool tiledx = (mx > 0.001);
	bool tiledy = (my > 0.001);

	// tiled, scale
	if (tiledx)
	{
		if (x >= 1) x -= (int)x;
		if (x < 0) x += (int)(1 - x);
		x = (x - (real)0.5) * (1 - mx) + (real)0.5;
	}

	if (tiledy)
	{
		if (y >= 1) y -= (int)y;
		if (y < 0) y += (int)(1 - y);
		y = (y - (real)0.5) * (1 - my) + (real)0.5;
	}

	// base color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);

	// blend in X direction
	CColor c;
	if (tiledx)
	{
		if (x < mx)
		{
			m_Prop[PROP_SOURCE].RenderCol(&c, x + 1 - mx, y);
			col->Trans(c, (mx - x)/mx);
		}

		if (x > 1 - mx)
		{
			m_Prop[PROP_SOURCE].RenderCol(&c, x - 1 + mx, y);
			col->Trans(c, (x - 1 + mx)/mx);
		}
	}

	// blend in Y direction
	if (tiledy)
	{
		if (y < my)
		{
			real y2 = y + 1 - my;
			m_Prop[PROP_SOURCE].RenderCol(&c, x, y2);

			// combination with X in corners
			if (tiledx)
			{
				CColor c2;
				if (x < mx)
				{
					m_Prop[PROP_SOURCE].RenderCol(&c2, x + 1 - mx, y2);
					c.Trans(c2, (mx - x)/mx);
				}

				if (x > 1 - mx)
				{
					m_Prop[PROP_SOURCE].RenderCol(&c2, x - 1 + mx, y2);
					c.Trans(c2, (x - 1 + mx)/mx);
				}
			}

			col->Trans(c, (my - y)/my);
		}

		if (y > 1 - my)
		{
			real y2 = y - 1 + my;
			m_Prop[PROP_SOURCE].RenderCol(&c, x, y2);

			// combination with X in corners
			if (tiledx)
			{
				CColor c2;
				if (x < mx)
				{
					m_Prop[PROP_SOURCE].RenderCol(&c2, x + 1 - mx, y2);
					c.Trans(c2, (mx - x)/mx);
				}

				if (x > 1 - mx)
				{
					m_Prop[PROP_SOURCE].RenderCol(&c2, x - 1 + mx, y2);
					c.Trans(c2, (x - 1 + mx)/mx);
				}
			}

			col->Trans(c, (y - 1 + my)/my);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSeamless::RenderVal(real x, real y)
{
	CColor col;
	CFilterSeamless::RenderCol(&col, x, y);
	return col.Gray();
}
