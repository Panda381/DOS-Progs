
///////////////////////////////////////////////////////////////////////////////
//
//                            Hexacomb Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CText FilterBevelMode[] = {
	CText(_T("Inner")),			// 0
	CText(_T("Middle")),		// 1
	CText(_T("Outer")),			// 2

	CText(_T(""))
};

#define PROP_HEXA_BRICK		0		// property - Brick (brick color or pattern)
#define PROP_HEXA_MORTAR	1		// property - Mortar (mortar color or pattern)
#define PROP_HEXA_WIDTH		2		// property - Width (number of double-bricks horizontally 0.01..1; in 0.01 steps, default 0.02)
#define PROP_HEXA_HEIGHT	3		// property - Height (number of bricks vertically 0.01..1; in 0.01 steps, default 0.06)
#define PROP_HEXA_GAP		4		// property - Gap (gap between bricks (=mortar thickness) 0..1; default 0.1)
#define PROP_HEXA_BEVEL		5		// property - Bevel (bevel width 0..1; default 0.02)
#define PROP_HEXA_HUE		6		// property - Hue (randomize color 0..1, default 0)
#define PROP_HEXA_SAT		7		// property - Saturation (randomize saturation 0..1, default 0)
#define PROP_HEXA_LUM		8		// property - Luminance (randomize luminance 0..1, default 0)
#define PROP_HEXA_FILL		9		// property - Fill (fill mode: 0=image, 0.1=random image, 0.2=solid, 0.3=random solid; default 0.1)
#define PROP_HEXA_BEVELMODE	10		// property - BevelMode
#define PROP_HEXA_PROFILE	11		// property - Profile
#define PROP_HEXA_SEED		12		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterHexacomb::CFilterHexacomb()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Hexacomb");
	m_HelpID = HELP_FHEXACOMB;
	m_PropNum = 13;

	m_Prop[PROP_HEXA_BRICK].SetName("Brick");
	m_Prop[PROP_HEXA_BRICK].SetToolID(ID_PROP_BRICK);

	m_Prop[PROP_HEXA_MORTAR].SetName("Mortar");
	m_Prop[PROP_HEXA_MORTAR].SetValue(1);
	m_Prop[PROP_HEXA_MORTAR].SetToolID(ID_PROP_MORTAR);

	m_Prop[PROP_HEXA_WIDTH].SetName("Width");
	m_Prop[PROP_HEXA_WIDTH].SetValue((real)0.05);
	m_Prop[PROP_HEXA_WIDTH].SetToolID(ID_PROP_CHECKWIDTH);
	m_Prop[PROP_HEXA_WIDTH].SetMinVal((real)0.01);
	m_Prop[PROP_HEXA_WIDTH].SetMin(1);

	m_Prop[PROP_HEXA_HEIGHT].SetName("Height");
	m_Prop[PROP_HEXA_HEIGHT].SetValue((real)0.08);
	m_Prop[PROP_HEXA_HEIGHT].SetToolID(ID_PROP_CHECKHEIGHT);
	m_Prop[PROP_HEXA_HEIGHT].SetMinVal((real)0.01);
	m_Prop[PROP_HEXA_HEIGHT].SetMin(1);

	m_Prop[PROP_HEXA_GAP].SetName("Gap");
	m_Prop[PROP_HEXA_GAP].SetValue((real)0.15);
	m_Prop[PROP_HEXA_GAP].SetToolID(ID_PROP_BRICKGAP);

	m_Prop[PROP_HEXA_BEVEL].SetName("Bevel");
	m_Prop[PROP_HEXA_BEVEL].SetToolID(ID_PROP_BRICKBEVEL);

	m_Prop[PROP_HEXA_HUE].SetName("Hue");
	m_Prop[PROP_HEXA_HUE].SetToolID(ID_PROP_BRICKHUE);

	m_Prop[PROP_HEXA_SAT].SetName("Saturation");
	m_Prop[PROP_HEXA_SAT].SetToolID(ID_PROP_BRICKSAT);

	m_Prop[PROP_HEXA_LUM].SetName("Luminance");
	m_Prop[PROP_HEXA_LUM].SetToolID(ID_PROP_BRICKLUM);

	m_Prop[PROP_HEXA_FILL].SetCategory(PCAT_ENUM);
	m_Prop[PROP_HEXA_FILL].SetName("Fill");
	m_Prop[PROP_HEXA_FILL].SetValue((real)0.1);
	m_Prop[PROP_HEXA_FILL].SetMax(10);
	m_Prop[PROP_HEXA_FILL].SetEnum(FilterFloorFillMode);
	m_Prop[PROP_HEXA_FILL].SetToolID(ID_PROP_FLOORFILL);

	m_Prop[PROP_HEXA_BEVELMODE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_HEXA_BEVELMODE].SetName("BevelMode");
	m_Prop[PROP_HEXA_BEVELMODE].SetValue((real)0.2);
	m_Prop[PROP_HEXA_BEVELMODE].SetMax(10);
	m_Prop[PROP_HEXA_BEVELMODE].SetEnum(FilterBevelMode);
	m_Prop[PROP_HEXA_BEVELMODE].SetToolID(ID_PROP_BEVELMODE);

	m_Prop[PROP_HEXA_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_HEXA_PROFILE].SetName("Profile");
	m_Prop[PROP_HEXA_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_HEXA_PROFILE].SetToolID(ID_PROP_BEVELPROFILE);

	m_Prop[PROP_HEXA_SEED].SetName("Seed");
	m_Prop[PROP_HEXA_SEED].SetMax(1000);
	m_Prop[PROP_HEXA_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterHexacomb::RenderCol(CColor* col, real x, real y)
{
	// load properties
	int numX = (int)(m_Prop[PROP_HEXA_WIDTH].RenderVal(x, y)*100 + (real)0.5);
	if (numX < 1) numX = 1;
	int numY = (int)(m_Prop[PROP_HEXA_HEIGHT].RenderVal(x, y)*100 + (real)0.5);
	if (numY < 1) numY = 1;
	real gap = CLAMP(m_Prop[PROP_HEXA_GAP].RenderVal(x, y));
	real bev = CLAMP(m_Prop[PROP_HEXA_BEVEL].RenderVal(x, y));
	real hue = m_Prop[PROP_HEXA_HUE].RenderVal(x, y);
	real sat = m_Prop[PROP_HEXA_SAT].RenderVal(x, y);
	real lum = m_Prop[PROP_HEXA_LUM].RenderVal(x, y);
	int fill = (int)(m_Prop[PROP_HEXA_FILL].RenderVal(x, y)*10 + (real)0.5);
	int bevelmode = (int)(m_Prop[PROP_HEXA_BEVELMODE].RenderVal(x, y)*10 + (real)0.5);
	int seed = (int)(m_Prop[PROP_HEXA_SEED].RenderVal(x, y)*1000 + (real)0.5);

	// vertical position (row of blocks)
	real h = (real)1/numY; // row height
	real y2 = y * numY;
	int row = (int)floor(y2);
	y2 -= row;
	row %= numY;
	if (row < 0) row += numY; // row in window from bottom

	// horizontal position (brick in row)
	real w = (real)1/numX; // brick width
	real x2 = x * numX;
	int pos = (int)floor(x2);
	x2 -= pos;
	pos %= numX;
	if (pos < 0) pos += numX; // brick in window from left
	pos *= 2;
	x2 *= 3;

	// detect row and pos
	if ((x2 < 0.5) || ((x2 < 1) && ((y2 >= x2) || (y2 < 1 - x2))))
	{
		pos--;
		x2 += (real)1.5;
		if (y2 < (real)0.5)
		{
			row--;
			y2 += 0.5;
		}
		else
			y2 -= 0.5;
	}
	else if ((x2 >= 2.5) || ((x2 >= 2) && ((y2 >= 3 - x2) || (y2 < x2 - 2))))
	{
		pos++;
		x2 -= (real)1.5;
		if (y2 < (real)0.5)
		{
			row--;
			y2 += 0.5;
		}
		else
			y2 -= 0.5;
	}
	if (row < 0) row += numY;
	if (row >= numY) row -= numY;
	if (pos < 0) pos += 2*numX;
	if (pos >= 2*numX) pos -= 2*numX;

	x2 -= (real)1.5;
	x2 /= 1.5;
	real x3 = x2;
	x2 *= (real)0.8660254037844386; // cos(60) = sqrt(3)/2
	y2 -= 0.5;

	// normalize angle
	real d = sqrt(sqr(x2) + sqr(y2))*(real)0.999999;
	real a = atan2(x2, y2) + PI/6;
	if (a < 0) a += PI2;
	a *= 6/PI2;
	a -= (int)a;
	a -= 0.5;
	
	// bevel
	real fg = 1 - d*cos(a*PI2/6)*2 - gap;
	switch (bevelmode)
	{
	case 0: bev *= (1-gap); break;
	case 2: bev *= gap; fg += bev; break;
	default: fg += bev/2; break;
	}
	if (bev < (real)0.000001)
		fg = (real)((fg > 0) ? 1 : 0);
	else
		fg /= bev;

	// fill mode
	real x0 = x;
	real y0 = y;
	if (gap > (real)0.999999) gap = (real)0.999999;
	x2 = x3*(real)0.75/(1-gap);
	y2 = y2/(1-gap);
	x2 += (real)0.5;
	y2 += (real)0.5;
	w /= 2;
	switch (fill)
	{
	case 1: // random image
		x = (Noise2D(pos, row, seed+5)+1)/2*(1-w) + x2*w;
		y = (Noise2D(pos, row, seed+10)+1)/2*(1-h) + y2*h;
		break;

	case 2: // solid
		x = (pos + (real)0.5)*w;
		y = (row + (real)0.5 + (((pos & 1) != 0) ? (real)0.25 : 0))*h;
		break;

	case 3: // random solid
		x = (Noise2D(pos, row, seed+15)+1)/2*(1-w) + w/2;
		y = (Noise2D(pos, row, seed+20)+1)/2*(1-h) + h/2;
		break;

	case 4: // whole image
		x = x2;
		y = y2;
		break;
	}

	// render brick color
	if (fg > 0)
	{
		m_Prop[PROP_HEXA_BRICK].RenderCol(col, x, y);
	}

	// color correction
	if ((hue > 0) || (sat > 0))
	{
		col->RGBToHSL();
		col->r += hue*(Noise2D(pos, row, seed+70)/2);
		if (col->r < 0) col->r += 1;
		if (col->r >= 1) col->r -= 1;
		col->g *= 1 + sat*Noise2D(pos, row, seed+113);
		col->HSLToRGB();
	}
	if (lum > 0) col->Brightness((real)0.5 + lum*(Noise2D(pos, row, seed+200)/2));

	// add mortar
	if (fg <= 0)
		m_Prop[PROP_HEXA_MORTAR].RenderCol(col, x0, y0);
	else
	{
		fg = m_Prop[PROP_HEXA_PROFILE].RenderVal(fg, y0);
		CColor f;
		m_Prop[PROP_HEXA_MORTAR].RenderCol(&f, x0, y0);
		col->Trans(f, (1-fg));
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterHexacomb::RenderVal(real x, real y)
{
	CColor col;
	CFilterHexacomb::RenderCol(&col, x, y);
	return col.Gray();
}
