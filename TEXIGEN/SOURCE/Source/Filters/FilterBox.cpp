
///////////////////////////////////////////////////////////////////////////////
//
//                                      Box
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

real HeartShape[HEARTSHAPEN+1];	// radius of samples; index=angle 0..PI2
real SpadeShape[SPADESHAPEN+1];	// radius of samples; index=angle 0..PI2
real DropletShape[DROPLETSHAPEN+1];	// radius of samples; index=angle 0..PI2

#define DOLLARW		1024			// width of dollar sign
#define DOLLARH		2048			// height of dollar sign
u8		DollarMap[DOLLARW*DOLLARH];	// dollar sign map

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBox::CFilterBox()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Box");
	m_HelpID = HELP_FBOX;
	m_PropNum = 11;

	m_Prop[PROP_SOURCE].SetValue(1);
	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_BOXCOLOR);

	m_Prop[PROP_SOURCE2].SetName("Background");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_BACKGROUND);

	m_Prop[PROP_BOX_WIDTH].SetName("Width");
	m_Prop[PROP_BOX_WIDTH].SetValue((real)0.25);
	m_Prop[PROP_BOX_WIDTH].SetToolID(ID_PROP_WIDTH);

	m_Prop[PROP_BOX_HEIGHT].SetName("Height");
	m_Prop[PROP_BOX_HEIGHT].SetValue((real)0.25);
	m_Prop[PROP_BOX_HEIGHT].SetToolID(ID_PROP_HEIGHT);

	m_Prop[PROP_BOX_ANGLE].SetName("Angle");
	m_Prop[PROP_BOX_ANGLE].SetValue(0.5);
	m_Prop[PROP_BOX_ANGLE].SetMin(-180);
	m_Prop[PROP_BOX_ANGLE].SetMax(180);
	m_Prop[PROP_BOX_ANGLE].SetToolID(ID_PROP_ANGLE2);

	m_Prop[PROP_BOX_SHIFTX].SetName("ShiftX");
	m_Prop[PROP_BOX_SHIFTX].SetValue((real)0.5);
	m_Prop[PROP_BOX_SHIFTX].SetMin(-50);
	m_Prop[PROP_BOX_SHIFTX].SetMax(50);
	m_Prop[PROP_BOX_SHIFTX].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_BOX_SHIFTY].SetName("ShiftY");
	m_Prop[PROP_BOX_SHIFTY].SetValue((real)0.5);
	m_Prop[PROP_BOX_SHIFTY].SetMin(-50);
	m_Prop[PROP_BOX_SHIFTY].SetMax(50);
	m_Prop[PROP_BOX_SHIFTY].SetToolID(ID_PROP_SHIFTY);

	m_Prop[PROP_BOX_TILES].SetName("Tiles");
	m_Prop[PROP_BOX_TILES].SetToolID(ID_PROP_TILES);

	m_Prop[PROP_BOX_BEVEL].SetName("Bevel");
	m_Prop[PROP_BOX_BEVEL].SetToolID(ID_PROP_BEVEL);

	m_Prop[PROP_BOX_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_BOX_PROFILE].SetName("Profile");
	m_Prop[PROP_BOX_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_BOX_PROFILE].SetToolID(ID_PROP_BEVELPROFILE);

	m_Prop[PROP_BOX_CORNERS].SetName("Corners");
	m_Prop[PROP_BOX_CORNERS].SetToolID(ID_PROP_CORNERS);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterBox::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y));
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y));
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y))/2;
	real corn = m_Prop[PROP_BOX_CORNERS].RenderVal(x, y);
	corn *= (width > height) ? height : width;
	width *= 2;
	height *= 2;

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// box limits
	real x1 = -width/2;
	real x2 = +width/2;
	real y1 = -height/2;
	real y2 = +height/2;

	// box detection
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real bevelx = width * bevel;
	real bevely = height * bevel;
	bevel = bevelx;
	if (bevely < bevel) bevel = bevely;
	real xx3 = 0;
	real yy3 = 0;
	if ((width > 0) && (height > 0))
	{
		if (tiles > 0)
		{
			int i, j;
			real yy2 = yy - 2;
			for (i = 5; i > 0; i--)
			{
				real xx2 = xx - 2;
				for (j = 5; j > 0; j--)
				{
					xx3 = xx2*ca + yy2*sa;
					yy3 = yy2*ca - xx2*sa;
					in = (xx3 >= x1) && (xx3 < x2) && (yy3 >= y1) && (yy3 < y2);
					if (in) break;
					xx2++;
				}
				if (in) break;
				yy2++;
			}
		}
		else
		{
			xx3 = xx*ca + yy*sa;
			yy3 = yy*ca - xx*sa;
			in = ((xx3 >= x1) && (xx3 < x2) && (yy3 >= y1) && (yy3 < y2));
		}
	}

	// transform corners to one corner
	real x3 = abs(xx3);
	real y3 = abs(yy3);
	real xc = x2 - corn;
	real yc = y2 - corn;

	// corners
	if (in && (corn > 0) && (x3 > xc) && (y3 > yc))
	{
		if (sqr(x3 - xc) + sqr(y3 - yc) > sqr(corn)) in = false;
	}

	// bevel
	real fg = 0;
	real fg2;
	if (in)
	{
		fg = 1;
		if (bevel > 0)
		{
			if (x3 > x2 - bevel) fg = (x2 - x3)/bevel;
			fg2 = 1;
			if (y3 > y2 - bevel) fg2 = (y2 - y3)/bevel;
			if (fg2 < fg) fg = fg2;
		}
		else
			bevel = (real)0.00001;

		// corners
		if (corn > 0)
		{
			// corner is bigger than bevel, inner corner is small and round
			if (corn >= bevel)
			{
				if ((x3 > xc) && (y3 > yc))
				{
					fg2 = 1 - (sqrt(sqr(x3 - xc) + sqr(y3 - yc)) - (corn - bevel))/bevel;
					if (fg2 < 0) fg2 = 0;
					if (fg2 < fg) fg = fg2;
				}
			}
			else
			{
				real xc2 = x2 - bevel;
				real yc2 = y2 - bevel;

				// corner is lower than bevel, inner corner is rectangular
				if ((x3 > xc2) && (y3 > yc2))
				{
					real a = atan((y3 - yc2)/(x3 - xc2));	// angle to this point
					real b = atan((bevel - corn)/bevel); // angle to last point of corner
					if ((a >= b) && (a <= PI/2 - b)) // line to point is withing range of corner
					{
						real c = (a - b) / (PI/2 - 2*b) * PI/2; // relative angle in corner circle
						real dx4 = cos(c)*corn + bevel-corn; // delta from inner corner to outer corner
						real dy4 = sin(c)*corn + bevel-corn;
						real dx = x3 - xc2; // delta from inner corner to point
						real dy = y3 - yc2;
						fg2 = 1 - sqrt((dx*dx + dy*dy)/(dx4*dx4 + dy4*dy4)); // relative distance from inner corner to point
						if (fg2 < 0) fg2 = 0;
						if (fg2 < fg) fg = fg2;
					}
				}
			}
		}
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBox::RenderVal(real x, real y)
{
	CColor col;
	CFilterBox::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRound::CFilterRound()
{
	m_Class = _T("Round");
	m_HelpID = HELP_FROUND;
	m_PropNum = 10;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRound::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y))*(real)2 + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y))*(real)2 + (real)0.0001;
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y));

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// round limits
	real dx = width/2;
	real dy = height/2;

	// circle detection
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real xy = 1;
	if ((width > 0) && (height > 0))
	{
		if (tiles > 0)
		{
			int i, j;
			real yy2 = yy - 2;
			for (i = 5; i > 0; i--)
			{
				real xx2 = xx - 2;
				for (j = 5; j > 0; j--)
				{
					real xx3 = (xx2*ca + yy2*sa)/dx;
					real yy3 = (yy2*ca - xx2*sa)/dy;
					xy = xx3*xx3 + yy3*yy3;
					in = (xy <= 1);
					if (in) break;
					xx2++;
				}
				if (in) break;
				yy2++;
			}
		}
		else
		{
			real xx2 = (xx*ca + yy*sa)/dx;
			real yy2 = (yy*ca - xx*sa)/dy;
			xy = xx2*xx2 + yy2*yy2;
			in = (xy <= 1);
		}
	}

	// bevel
	real fg = 0;
	if (in)
	{
		fg = 1;
		if (bevel > 0)
		{
			xy = sqrt(xy);
			if (xy > 1 - bevel) fg = (1 - xy)/bevel;
		}
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRound::RenderVal(real x, real y)
{
	CColor col;
	CFilterRound::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTriangle::CFilterTriangle()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Triangle");
	m_HelpID = HELP_FTRIANGLE;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetValue(1);
	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_BOXCOLOR);

	m_Prop[PROP_SOURCE2].SetName("Background");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_BACKGROUND);

	m_Prop[PROP_TRI_X1].SetName("X1");
	m_Prop[PROP_TRI_X1].SetValue((real)0.25);
	m_Prop[PROP_TRI_X1].SetToolID(ID_PROP_TRIX1);

	m_Prop[PROP_TRI_Y1].SetName("Y1");
	m_Prop[PROP_TRI_Y1].SetValue((real)0.25);
	m_Prop[PROP_TRI_Y1].SetToolID(ID_PROP_TRIY1);

	m_Prop[PROP_TRI_X2].SetName("X2");
	m_Prop[PROP_TRI_X2].SetValue((real)0.5);
	m_Prop[PROP_TRI_X2].SetToolID(ID_PROP_TRIX2);

	m_Prop[PROP_TRI_Y2].SetName("Y2");
	m_Prop[PROP_TRI_Y2].SetValue((real)0.75);
	m_Prop[PROP_TRI_Y2].SetToolID(ID_PROP_TRIY2);

	m_Prop[PROP_TRI_X3].SetName("X3");
	m_Prop[PROP_TRI_X3].SetValue((real)0.75);
	m_Prop[PROP_TRI_X3].SetToolID(ID_PROP_TRIX3);

	m_Prop[PROP_TRI_Y3].SetName("Y3");
	m_Prop[PROP_TRI_Y3].SetValue((real)0.25);
	m_Prop[PROP_TRI_Y3].SetToolID(ID_PROP_TRIY3);

	m_Prop[PROP_TRI_BEVEL].SetName("Bevel");
	m_Prop[PROP_TRI_BEVEL].SetToolID(ID_PROP_BEVEL);

	m_Prop[PROP_TRI_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_TRI_PROFILE].SetName("Profile");
	m_Prop[PROP_TRI_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_TRI_PROFILE].SetToolID(ID_PROP_BEVELPROFILE);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTriangle::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real x1 = CLAMP(m_Prop[PROP_TRI_X1].RenderVal(x, y));
	real y1 = CLAMP(m_Prop[PROP_TRI_Y1].RenderVal(x, y));
	real x2 = CLAMP(m_Prop[PROP_TRI_X2].RenderVal(x, y));
	real y2 = CLAMP(m_Prop[PROP_TRI_Y2].RenderVal(x, y));
	real x3 = CLAMP(m_Prop[PROP_TRI_X3].RenderVal(x, y));
	real y3 = CLAMP(m_Prop[PROP_TRI_Y3].RenderVal(x, y));
	real bevel = CLAMP(m_Prop[PROP_TRI_BEVEL].RenderVal(x, y));

	// distance to lines
	real fg = 0;
	if ((x >= 0) && (x <= 1) && (y >= 0) && (y <= 1))
	{
		real d10 = 10;
		real d1 = 20;
		real d20 = 10;
		real d2 = 20;
		real d30 = 10;
		real d3 = 20;

		// distance to line P1-P2
		real dx = x2 - x1;
		real dy = y2 - y1;
		real dxy = sqrt(dx*dx + dy*dy);
		if (dxy > 0)
		{
			d10 = (dy*x3 - dx*y3 - x1*y2 + x2*y1)/dxy;
			d1 = (dy*x - dx*y - x1*y2 + x2*y1)/dxy;
		}

		// distance to line P2-P3
		dx = x3 - x2;
		dy = y3 - y2;
		dxy = sqrt(dx*dx + dy*dy);
		if (dxy > 0)
		{
			d20 = (dy*x1 - dx*y1 - x2*y3 + x3*y2)/dxy;
			d2 = (dy*x - dx*y - x2*y3 + x3*y2)/dxy;
		}

		// distance to line P3-P1
		dx = x1 - x3;
		dy = y1 - y3;
		dxy = sqrt(dx*dx + dy*dy);
		if (dxy > 0)
		{
			d30 = (dy*x2 - dx*y2 - x3*y1 + x1*y3)/dxy;
			d3 = (dy*x - dx*y - x3*y1 + x1*y3)/dxy;
		}

		// check if point is inside the triangle
		if ((d10 != 0) && (d20 != 0) && (d30 != 0))
		{
			real d11 = d1 / d10;
			real d22 = d2 / d20;
			real d33 = d3 / d30;
			if ((d11 >= 0) && (d11 <= 1) && (d22 >= 0) && (d22 <= 1) && (d33 >= 0) && (d33 <= 1))
			{
				fg = 1;

				// bevel
				if (bevel > 0)
				{
					d10 = abs(d10);
					d20 = abs(d20);
					d30 = abs(d30);
					real d0 = d10;
					if (d20 < d0) d0 = d20;
					if (d30 < d0) d0 = d30;
					d0 *= (real)0.5*bevel;
					if (d0 > 0)
					{
						d1 = abs(d1/d0);
						d2 = abs(d2/d0);
						d3 = abs(d3/d0);
						fg = d1;
						if (d2 < fg) fg = d2;
						if (d3 < fg) fg = d3;
						if (fg < 0) fg = 0;
						if (fg > 1) fg = 1;
					}
				}
			}
		}
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTriangle::RenderVal(real x, real y)
{
	CColor col;
	CFilterTriangle::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterInject::CFilterInject()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Inject");
	m_HelpID = HELP_FINJECT;
	m_PropNum = 6;

	m_Prop[PROP_SOURCE2].SetValue(1);

	m_Prop[PROP_INJECT_WIDTH].SetName("Width");
	m_Prop[PROP_INJECT_WIDTH].SetValue((real)0.5);
	m_Prop[PROP_INJECT_WIDTH].SetToolID(ID_PROP_WIDTH);

	m_Prop[PROP_INJECT_HEIGHT].SetName("Height");
	m_Prop[PROP_INJECT_HEIGHT].SetValue((real)0.5);
	m_Prop[PROP_INJECT_HEIGHT].SetToolID(ID_PROP_HEIGHT);

	m_Prop[PROP_INJECT_SHIFTX].SetName("ShiftX");
	m_Prop[PROP_INJECT_SHIFTX].SetValue((real)0.5);
	m_Prop[PROP_INJECT_SHIFTX].SetMin(-50);
	m_Prop[PROP_INJECT_SHIFTX].SetMax(50);
	m_Prop[PROP_INJECT_SHIFTX].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_INJECT_SHIFTY].SetName("ShiftY");
	m_Prop[PROP_INJECT_SHIFTY].SetValue((real)0.5);
	m_Prop[PROP_INJECT_SHIFTY].SetMin(-50);
	m_Prop[PROP_INJECT_SHIFTY].SetMax(50);
	m_Prop[PROP_INJECT_SHIFTY].SetToolID(ID_PROP_SHIFTY);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterInject::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_INJECT_WIDTH].RenderVal(x, y)) + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_INJECT_HEIGHT].RenderVal(x, y)) + (real)0.0001;
	real shiftx = m_Prop[PROP_INJECT_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_INJECT_SHIFTY].RenderVal(x, y);

	// box limits
	real x1 = shiftx - width/2;
	real x2 = shiftx + width/2;
	real y1 = shifty - height/2;
	real y2 = shifty + height/2;

	// render color
	if ((x >= x1) && (x < x2) && (y >= y1) && (y < y2))
		m_Prop[PROP_SOURCE2].RenderCol(col, (x - x1)/width, (y - y1)/height);
	else
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterInject::RenderVal(real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_INJECT_WIDTH].RenderVal(x, y)) + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_INJECT_HEIGHT].RenderVal(x, y)) + (real)0.0001;
	real shiftx = m_Prop[PROP_INJECT_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_INJECT_SHIFTY].RenderVal(x, y);

	// box limits
	real x1 = shiftx - width/2;
	real x2 = shiftx + width/2;
	real y1 = shifty - height/2;
	real y2 = shifty + height/2;

	// render color
	if ((x >= x1) && (x < x2) && (y >= y1) && (y < y2))
		return m_Prop[PROP_SOURCE2].RenderVal((x - x1)/width, (y - y1)/height);
	else
		return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// initialize heart shape
// Heart curves: http://mathworld.wolfram.com/HeartCurve.html
// x = 16*sin(t)^3
// y = 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)

void HeartInit()
{
	// debug clear buffer
	int i;
	for (i = 0; i <= HEARTSHAPEN; i++) HeartShape[i] = -1;

	// generate heart curve
	real t, a, x, y, r;
	real dt = (real)PI2/HEARTSHAPEN/4;
	for (t = 0; t <= PI2; t += dt)
	{
		x = sin(t);
		x = x*x*x/2;
		y = (13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t))/(real)28.95 + (real)0.0875;
		a = atan2(y, x);
		r = sqrt(x*x + y*y);
		if (a < 0) a += PI2;
		i = (int)(a / PI2 * HEARTSHAPEN);
		if (i < 0) i = 0;
		if (i > HEARTSHAPEN) i = HEARTSHAPEN;
		HeartShape[i] = r;
	}
	HeartShape[HEARTSHAPEN] = HeartShape[0];

	// debug check buffer
	for (i = 0; i <= HEARTSHAPEN; i++)
	{
		if (HeartShape[i] <= 0)
		{
			IntError(_T("HeartInit: Invalid curve"));
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterHeart::CFilterHeart()
{
	m_Class = _T("Heart");
	m_HelpID = HELP_FHEART;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetColor(1,0,0,1);
	m_Prop[PROP_SOURCE2].SetColor(1,0,0,0);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterHeart::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y))*(real)2 + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y))*(real)2 + (real)0.0001;
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y));

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// heart detection
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real xx3 = 0;
	real yy3 = 0;
	if ((width > 0) && (height > 0))
	{
		if (tiles > 0)
		{
			int i, j;
			real yy2 = yy - 2;
			for (i = 5; i > 0; i--)
			{
				real xx2 = xx - 2;
				for (j = 5; j > 0; j--)
				{
					xx3 = (xx2*ca + yy2*sa)/width;
					yy3 = (yy2*ca - xx2*sa)/height;
					in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
					if (in) break;
					xx2++;
				}
				if (in) break;
				yy2++;
			}
		}
		else
		{
			xx3 = (xx*ca + yy*sa)/width;
			yy3 = (yy*ca - xx*sa)/height;
			in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
		}
	}

	// detect heart shape
	real d = sqrt(sqr(xx3) + sqr(yy3));
	real fg = 0;
	if (in)
	{
		real a = atan2(yy3, xx3);
		if (a < 0) a += PI2;
		a = a / PI2 * HEARTSHAPEN;
		int i = (int)a;
		if (i > HEARTSHAPEN-1) i = HEARTSHAPEN-1;
		a -= i;
		real r = HeartShape[i]*(1-a) + HeartShape[i+1]*a;
		in = (d <= r);

		// bevel
		if (in)
		{
			fg = 1;
			if (bevel > 0.00001)
			{
				fg = (r - d)/(bevel*r);
				if (fg < 0) fg = 0;
				if (fg > 1) fg = 1;
			}
		}
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterHeart::RenderVal(real x, real y)
{
	CColor col;
	CFilterHeart::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDiamond::CFilterDiamond()
{
	m_Class = _T("Diamond");
	m_HelpID = HELP_FDIAMOND;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetColor(1,0,0,1);
	m_Prop[PROP_SOURCE2].SetColor(1,0,0,0);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDiamond::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y))*(real)2 + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y))*(real)2 + (real)0.0001;
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y));

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// diamond detection
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real xx3 = 0;
	real yy3 = 0;
	if ((width > 0) && (height > 0))
	{
		if (tiles > 0)
		{
			int i, j;
			real yy2 = yy - 2;
			for (i = 5; i > 0; i--)
			{
				real xx2 = xx - 2;
				for (j = 5; j > 0; j--)
				{
					xx3 = (xx2*ca + yy2*sa)/width;
					yy3 = (yy2*ca - xx2*sa)/height;
					in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
					if (in) break;
					xx2++;
				}
				if (in) break;
				yy2++;
			}
		}
		else
		{
			xx3 = (xx*ca + yy*sa)/width;
			yy3 = (yy*ca - xx*sa)/height;
			in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
		}
	}

	// detect diamond shape
	real fg = 0;
	if (in)
	{
		xx3 = DIAMONDXY - abs(xx3);
		yy3 = DIAMONDXY - abs(yy3);
		real d = sqrt(sqr(xx3) + sqr(yy3)) - DIAMONDR;
		in = (d >= 0);

		// bevel
		if (in)
		{
			fg = 1;
			if (bevel > 0.00001)
			{
				fg = d/bevel*3;
				if (fg > 1) fg = 1;
			}
		}
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDiamond::RenderVal(real x, real y)
{
	CColor col;
	CFilterDiamond::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// initialize spade shape
// x = 0.01*(-t^2 + 40*t + 1200)*sin(PI*t/180)
// y = 0.01*(-t^2 + 40*t + 1200)*cos(PI*t/180)
// t = 0..60

void SpadeInit()
{
	// debug clear buffer
	int i;
	for (i = 0; i <= SPADESHAPEN; i++) SpadeShape[i] = -1;

	// generate spade curve
	real t, a, x, y, r;
	real dt = (real)60/SPADESHAPEN/10;
	for (t = 0; t <= 60; t += dt)
	{
		x = (-t*t + 40*t + 1200)*sin(PI*t/180)/1580;
		y = (real)(0.4999 - (-t*t + 40*t + 1200)*cos(PI*t/180)/1800);
		a = atan2(y, x);
		r = sqrt(x*x + y*y);
		if (a < 0) a += PI2;
		i = (int)(a / PI2 * SPADESHAPEN);
		if (i < 0) i = 0;
		if (i > SPADESHAPEN) i = SPADESHAPEN;
		SpadeShape[i] = r;

		x = -x;
		a = atan2(y, x);
		r = sqrt(x*x + y*y);
		if (a < 0) a += PI2;
		i = (int)(a / PI2 * SPADESHAPEN);
		if (i < 0) i = 0;
		if (i > SPADESHAPEN) i = SPADESHAPEN;
		SpadeShape[i] = r;
	}
	SpadeShape[SPADESHAPEN] = SpadeShape[0];

	// debug check buffer
	for (i = 0; i <= SPADESHAPEN; i++)
	{
		if (SpadeShape[i] <= 0)
		{
			IntError(_T("SpadeInit: Invalid curve"));
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSpade::CFilterSpade()
{
	m_Class = _T("Spade");
	m_HelpID = HELP_FSPADE;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetColor(0,0,0,1);
	m_Prop[PROP_SOURCE2].SetColor(0,0,0,0);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSpade::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y))*(real)2 + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y))*(real)2 + (real)0.0001;
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y));

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// spade detection
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real xx3 = 0;
	real yy3 = 0;
	if ((width > 0) && (height > 0))
	{
		if (tiles > 0)
		{
			int i, j;
			real yy2 = yy - 2;
			for (i = 5; i > 0; i--)
			{
				real xx2 = xx - 2;
				for (j = 5; j > 0; j--)
				{
					xx3 = (xx2*ca + yy2*sa)/width;
					yy3 = (yy2*ca - xx2*sa)/height;
					in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
					if (in) break;
					xx2++;
				}
				if (in) break;
				yy2++;
			}
		}
		else
		{
			xx3 = (xx*ca + yy*sa)/width;
			yy3 = (yy*ca - xx*sa)/height;
			in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
		}
	}

	// detect spade shape
	real d = sqrt(sqr(xx3) + sqr(yy3));
	real fg = 0;
	if (in)
	{
		// leaf
		real a = atan2(yy3, xx3);
		if (a < 0) a += PI2;
		a = a / PI2 * SPADESHAPEN;
		int i = (int)a;
		if (i > SPADESHAPEN-1) i = SPADESHAPEN-1;
		a -= i;
		real r = SpadeShape[i]*(1-a) + SpadeShape[i+1]*a;
		in = (d <= r);

		// bevel
		if (in)
		{
			fg = 1;
			if (bevel > 0.00001)
			{
				fg = (r - d)/(bevel*r);
				if (fg < 0) fg = 0;
				if (fg > 1) fg = 1;
			}
		}

		// stalk
		if ((yy3 < 0) && (yy3 > -0.5) && (xx3 >= -SPADESTALK) && (xx3 <= SPADESTALK))
		{
			real k = (yy3 + (real)0.51)*2;
			k = (1 - sqrt(k))*SPADESTALK;
			if ((xx3 < k) && (xx3 > -k))
			{
				in = true;
				real fg2 = 1;

				// stalk bevel
				real b = bevel * SPADESTALK*(real)0.58;
				if (b > 0.00001)
				{
					fg2 = (k - xx3)/b;
					if (fg2 > 1) fg2 = 1;
					real fg3 = (xx3 + k)/b;
					if (fg3 < 0) fg3 = 0;
					if (fg3 > 1) fg3 = 1;
					if (fg3 < fg2) fg2 = fg3;
					fg3 = (yy3 + (real)0.5)/b;
					if (fg3 > 1) fg3 = 1;
					if (fg3 < fg2) fg2 = fg3;
				}
				if (fg2 > fg) fg = fg2;
			}
		}
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSpade::RenderVal(real x, real y)
{
	CColor col;
	CFilterSpade::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterClub::CFilterClub()
{
	m_Class = _T("Club");
	m_HelpID = HELP_FCLUB;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetColor(0,0,0,1);
	m_Prop[PROP_SOURCE2].SetColor(0,0,0,0);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterClub::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y))*(real)2 + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y))*(real)2 + (real)0.0001;
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y));

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// spade detection
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real xx3 = 0;
	real yy3 = 0;
	if ((width > 0) && (height > 0))
	{
		if (tiles > 0)
		{
			int i, j;
			real yy2 = yy - 2;
			for (i = 5; i > 0; i--)
			{
				real xx2 = xx - 2;
				for (j = 5; j > 0; j--)
				{
					xx3 = (xx2*ca + yy2*sa)/width;
					yy3 = (yy2*ca - xx2*sa)/height;
					in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
					if (in) break;
					xx2++;
				}
				if (in) break;
				yy2++;
			}
		}
		else
		{
			xx3 = (xx*ca + yy*sa)/width;
			yy3 = (yy*ca - xx*sa)/height;
			in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
		}
	}

	// detect club shape
	real fg = 0;
	if (in)
	{
		// leafs
		real y4 = (real)0.5 - CLUBR1;
		real d = sqrt(sqr(xx3) + sqr(yy3 - y4));
		in = (d <= CLUBR1);

		real x4 = (real)0.5 - CLUBR1;
		y4 = (real)-0.13;
		if (!in)
		{
			d = sqrt(sqr(xx3 - x4) + sqr(yy3 - y4));
			in = (d <= CLUBR1);
		}

		x4 = (real)-0.5 + CLUBR1;
		if (!in)
		{
			d = sqrt(sqr(xx3 - x4) + sqr(yy3 - y4));
			in = (d <= CLUBR1);
		}

		// bevel
		if (in)
		{
			fg = 1;
			if (bevel > 0.00001)
			{
				fg = (CLUBR1 - d)/(bevel*CLUBR1);
				if (fg < 0) fg = 0;
				if (fg > 1) fg = 1;
			}
		}

		// centre
		d = sqrt(sqr(xx3) + sqr(yy3 + (real)0.05));
		if (d <= CLUBR2)
		{
			if (bevel > 0.00001)
			{
				real fg2 = (CLUBR2 - d)/(bevel*CLUBR2);
				if (fg2 < 0) fg2 = 0;
				if (fg2 > 1) fg2 = 1;
				fg += fg2;
				if (fg > 1) fg = 1;
			}
			else
				fg = 1;
			in = true;
		}

		// stalk
		if ((yy3 < 0) && (yy3 > -0.5) && (xx3 >= -SPADESTALK) && (xx3 <= SPADESTALK))
		{
			real k = (yy3 + (real)0.51)*2;
			k = (1 - sqrt(k))*SPADESTALK;
			if ((xx3 < k) && (xx3 > -k))
			{
				in = true;
				real fg2 = 1;

				// stalk bevel
				real b = bevel * SPADESTALK*(real)0.58;
				if (b > 0.00001)
				{
					fg2 = (k - xx3)/b;
					if (fg2 > 1) fg2 = 1;
					real fg3 = (xx3 + k)/b;
					if (fg3 < 0) fg3 = 0;
					if (fg3 > 1) fg3 = 1;
					if (fg3 < fg2) fg2 = fg3;
					fg3 = (yy3 + (real)0.5)/b;
					if (fg3 > 1) fg3 = 1;
					if (fg3 < fg2) fg2 = fg3;
				}
				if (fg2 > fg) fg = fg2;
			}
		}
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterClub::RenderVal(real x, real y)
{
	CColor col;
	CFilterClub::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// initialize droplet shape
// Joukowski airfoil: http://math.stackexchange.com/questions/51539/a-math-function-that-draws-water-droplet-shape
// x = q*sin(t)*(1 - 1/(sqr(1 - q*(1 - cos(t))) + q*q*sqr(sin(t))))
// y = q*cos(t) + (1 - q*(1 - cos(t)))/(sqr(1 - q*(1 - cos(t))) + q*q*sqr(sin(t)))
// t = 0..2PI
// q = 0.5..1 (default 2/3)

void DropletInit()
{
	// debug clear buffer
	int i;
	for (i = 0; i <= DROPLETSHAPEN; i++) DropletShape[i] = -1;

	// generate droplet curve
	real t, a, x, y, r;
	real dt = (real)PI2/DROPLETSHAPEN/10;
	real q = (real)2/3;
	for (t = 0; t <= PI2; t += dt)
	{
		x = q*sin(t)*(1 - 1/(sqr(1 - q*(1 - cos(t))) + q*q*sqr(sin(t))));
		y = q*cos(t) + (1 - q*(1 - cos(t)))/(sqr(1 - q*(1 - cos(t))) + q*q*sqr(sin(t)));
		x *= (real)0.3078;
		y = (y + (real)0.9999)*(real)0.18744;

		a = atan2(y, x);
		r = sqrt(x*x + y*y);
		if (a < 0) a += PI2;
		i = (int)(a / PI2 * DROPLETSHAPEN);
		if (i < 0) i = 0;
		if (i > DROPLETSHAPEN) i = DROPLETSHAPEN;
		DropletShape[i] = r;

		x = -x;
		a = atan2(y, x);
		r = sqrt(x*x + y*y);
		if (a < 0) a += PI2;
		i = (int)(a / PI2 * DROPLETSHAPEN);
		if (i < 0) i = 0;
		if (i > DROPLETSHAPEN) i = DROPLETSHAPEN;
		DropletShape[i] = r;
	}
	DropletShape[DROPLETSHAPEN] = DropletShape[0];

	// debug check buffer
	for (i = 0; i <= DROPLETSHAPEN; i++)
	{
		if (DropletShape[i] <= 0)
		{
			IntError(_T("DropletInit: Invalid curve"));
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDroplet::CFilterDroplet()
{
	m_Class = _T("Droplet");
	m_HelpID = HELP_FDROPLET;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetColor(0,(real)0.8,(real)1,1);
	m_Prop[PROP_SOURCE2].SetColor(0,(real)0.8,(real)1,0);

	m_Prop[PROP_BOX_WIDTH].SetValue((real)0.14);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDroplet::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y))*(real)2 + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y))*(real)2 + (real)0.0001;
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y));

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// droplet detection
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real xx3 = 0;
	real yy3 = 0;
	if ((width > 0) && (height > 0))
	{
		if (tiles > 0)
		{
			int i, j;
			real yy2 = yy - 2;
			for (i = 5; i > 0; i--)
			{
				real xx2 = xx - 2;
				for (j = 5; j > 0; j--)
				{
					xx3 = (xx2*ca + yy2*sa)/width;
					yy3 = (yy2*ca - xx2*sa)/height;
					in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
					if (in) break;
					xx2++;
				}
				if (in) break;
				yy2++;
			}
		}
		else
		{
			xx3 = (xx*ca + yy*sa)/width;
			yy3 = (yy*ca - xx*sa)/height;
			in = (xx3 >= -0.5) && (xx3 < 0.5) && (yy3 >= -0.5) && (yy3 < 0.5);
		}
	}

	// detect droplet shape
	real d = sqrt(sqr(xx3) + sqr(yy3));
	real fg = 0;
	if (in)
	{
		real a = atan2(yy3, xx3);
		if (a < 0) a += PI2;
		a = a / PI2 * DROPLETSHAPEN;
		int i = (int)a;
		if (i > DROPLETSHAPEN-1) i = DROPLETSHAPEN-1;
		a -= i;
		real r = DropletShape[i]*(1-a) + DropletShape[i+1]*a;
		in = (d <= r);

		// bevel
		if (in)
		{
			fg = 1;
			if (bevel > 0.00001)
			{
				fg = (r - d)/(bevel*r);
				if (fg < 0) fg = 0;
				if (fg > 1) fg = 1;
			}
		}
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDroplet::RenderVal(real x, real y)
{
	CColor col;
	CFilterDroplet::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterJinJang::CFilterJinJang()
{
	m_Class = _T("JinJang");
	m_HelpID = HELP_FJINJANG;
	m_PropNum = 12;

	m_Prop[PROP_SOURCE].SetValue(0);
	m_Prop[PROP_SOURCE].SetName("Black");

	m_Prop[PROP_SOURCE2].SetValue(1);
	m_Prop[PROP_SOURCE2].SetName("White");

	m_Prop[PROP_JINJANG_CIRCLE].SetName("Circle");
	m_Prop[PROP_JINJANG_CIRCLE].SetValue((real)0.25);
	m_Prop[PROP_JINJANG_CIRCLE].SetToolID(ID_PROP_JINJANGCIRCLE);

	m_Prop[PROP_JINJANG_BACK].SetName("Background");
	m_Prop[PROP_JINJANG_BACK].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_JINJANG_BACK].SetCategory(PCAT_COLOR);
	m_Prop[PROP_JINJANG_BACK].SetColor(1,1,1,0);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterJinJang::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y))*(real)2 + (real)0.0001;
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y))*(real)2 + (real)0.0001;
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y))/2;
	real circle = CLAMP(m_Prop[PROP_JINJANG_CIRCLE].RenderVal(x, y));

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// jinjang detection
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real xx3 = 0;
	real yy3 = 0;
	real xy = 1;
	if ((width > 0) && (height > 0))
	{
		if (tiles > 0)
		{
			int i, j;
			real yy2 = yy - 2;
			for (i = 5; i > 0; i--)
			{
				real xx2 = xx - 2;
				for (j = 5; j > 0; j--)
				{
					xx3 = (xx2*ca + yy2*sa)/width*2;
					yy3 = (yy2*ca - xx2*sa)/height*2;
					xy = xx3*xx3 + yy3*yy3;
					in = (xy <= 1);
					if (in) break;
					xx2++;
				}
				if (in) break;
				yy2++;
			}
		}
		else
		{
			xx3 = (xx*ca + yy*sa)/width*2;
			yy3 = (yy*ca - xx*sa)/height*2;
			xy = xx3*xx3 + yy3*yy3;
			in = (xy <= 1);
		}
	}

	// detect jinjang shape
	real fg = 0;
	if (in)
	{
		fg = (real)((xx3 < 0) ? 1 : 0);
		real d1 = sqrt((xx3*xx3 + (yy3-(real)0.5)*(yy3-(real)0.5)))*2;
		real a1 = atan2(xx3, yy3-(real)0.5);
		real d2 = sqrt((xx3*xx3 + (yy3+(real)0.5)*(yy3+(real)0.5)))*2;
		real a2 = atan2(-xx3, -yy3-(real)0.5);

		if (bevel > 0)
		{
			if (circle > 0)
			{
				if (d1 < circle+bevel/2) fg = 1 - (circle+bevel/2-d1)/bevel;
				if (d2 < circle+bevel/2) fg = (circle+bevel/2-d2)/bevel;
			}
			if (fg >= 1) fg = 1;
			if (fg <= 0) fg = 0;

			if (xx3 >= 0)
			{
				if ((a1 >= 0) && (a1 < PI/3) && (d1 >= (1 + circle)/2)) bevel *= a1/PI*3;
				if (bevel > 0)
				{
					if ((d1 < 1+bevel/2) && ((d1 >= circle+bevel/2) || (circle <= 0)))
					{
						fg = (1+bevel/2-d1)/bevel;
						if (fg >= 1) fg = 1;
					}
				}
				else
					if ((d1 < 1) && (d1 >= circle)) fg = 1;
			}
			else
			{
				if ((a2 >= 0) && (a2 < PI/3) && (d2 >= (1 + circle)/2)) bevel *= a2/PI*3;
				if (bevel > 0)
				{
					if ((d2 < 1+bevel/2) && ((d2 >= circle+bevel/2) || (circle <= 0)))
					{
						fg = 1 - (1+bevel/2-d2)/bevel;
						if (fg <= 0) fg = 0;
					}
				}
				else
					if ((d2 < 1) && (d2 >= circle)) fg = 0;
			}
		}
		else
		{
			if (d1 < circle) fg = 0;
			if (d2 < circle) fg = 1;

			if (xx3 >= 0)
			{
				if ((d1 < 1) && (d1 >= circle)) fg = 1;
			}
			else
			{
				if ((d2 < 1) && (d2 >= circle)) fg = 0;
			}
		}
	}

	// render color
	if (in)
	{
		if (fg >= 1)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
			if (fg <= 0)
				m_Prop[PROP_SOURCE].RenderCol(col, x, y);
			else
			{
				fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
				CColor f;
				m_Prop[PROP_SOURCE2].RenderCol(&f, x, y);
				m_Prop[PROP_SOURCE].RenderCol(col, x, y);
				col->Trans(f, fg);
			}
	}
	else
		m_Prop[PROP_JINJANG_BACK].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterJinJang::RenderVal(real x, real y)
{
	CColor col;
	CFilterJinJang::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// load dollar pictures

void LoadDollarPic()
{
	memset(DollarMap, 0, DOLLARW*DOLLARH);

	// open resource
	HRSRC res = ::FindResource(Instance, "DOLLAR", "REFLECT");
	if (res != NULL)
	{
		HGLOBAL glob = ::LoadResource(Instance, res);
		if (glob != NULL)
		{
			u8* a = (u8*)::LockResource(glob);
			if (a != NULL)
			{
				// check bitmap header
				bmpBITMAPFILEHEADER* bmp = (bmpBITMAPFILEHEADER*)a;
#define DOLLARDATAOFF (sizeof(bmpBITMAPFILEHEADER) + sizeof(bmpBITMAPINFOHEADER) + 4*256*sizeof(BYTE)) // 1078 bytes
				if ((bmp->bfType == 0x4d42) && (bmp->bfSize > 100000) && (bmp->bfOffBits == DOLLARDATAOFF))
				{
					bmpBITMAPINFOHEADER* b = (bmpBITMAPINFOHEADER*)(a + sizeof(bmpBITMAPFILEHEADER));
					if ((b->biSize == sizeof(bmpBITMAPINFOHEADER)) &&
						(b->biWidth == DOLLARW) && (b->biHeight == DOLLARH) &&
						(b->biBitCount == 8) && (b->biCompression == bmpBI_RLE8))
					{
						// bitmap decompression
						DekompRLE8(DollarMap, DOLLARW*DOLLARH, a + DOLLARDATAOFF, bmp->bfSize - DOLLARDATAOFF, DOLLARW);

						// !!!! error in decompressor code 2 (skipping delta X Y), clear short white line lower left
						memset(DollarMap, 0, DOLLARW);

						return;
					}
				}
			}
		}
	}

	IntError(_T("LoadDollarPic: Invalid picture"));
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDollar::CFilterDollar()
{
	m_Class = _T("Dollar");
	m_HelpID = HELP_FDOLLAR;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetColor(1,1,0,1);
	m_Prop[PROP_SOURCE2].SetColor(1,1,0,0);

	m_Prop[PROP_BOX_WIDTH].SetValue((real)0.5);
	m_Prop[PROP_BOX_HEIGHT].SetValue(1);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDollar::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real width = CLAMP(m_Prop[PROP_BOX_WIDTH].RenderVal(x, y));
	real height = CLAMP(m_Prop[PROP_BOX_HEIGHT].RenderVal(x, y));
	if ((width < (real)0.00001) || (height < (real)0.00001))
	{
		m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		return;
	}
	real angle = (m_Prop[PROP_BOX_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_BOX_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_BOX_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_BOX_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = CLAMP(m_Prop[PROP_BOX_BEVEL].RenderVal(x, y));

	// tiles
	real xx = x;
	real yy = y;
	if (tiles > 0)
	{
		xx *= tiles;
		yy *= tiles;
		if (xx >= 1) xx -= (int)xx;
		if (xx < 0) xx += (int)(1 - xx);
		if (yy >= 1) yy -= (int)yy;
		if (yy < 0) yy += (int)(1 - yy);
	}

	// shift
	xx = xx - shiftx;
	yy = yy - shifty;

	// rotation
	real ca = cos(angle);
	real sa = sin(angle);
	real xx2 = xx*ca + yy*sa;
	real yy2 = yy*ca - xx*sa;

	// scale
	xx = xx2/width;
	yy = yy2/height;
	xx += (real)0.5;
	yy += (real)0.5;

	// image coordinates
	xx *= DOLLARW;
	yy *= DOLLARH;
	int x1 = (int)floor(xx);
	int y1 = (int)floor(yy);
	xx -= x1;
	yy -= y1;
	int x2 = x1 + 1;
	int y2 = y1 + 1;
	real fg = 0;
	if ((x2 >= 0) && (x1 < DOLLARW) && (y2 >= 0) && (y1 < DOLLARH))
	{
		if (x1 < 0) x1 = 0;
		if (y1 < 0) y1 = 0;
		if (x2 >= DOLLARW) x2 = DOLLARW - 1;
		if (y2 >= DOLLARH) y2 = DOLLARH - 1;
		real fg11 = DollarMap[x1 + y1*DOLLARW]/(real)255;
		real fg12 = DollarMap[x1 + y2*DOLLARW]/(real)255;
		real fg21 = DollarMap[x2 + y1*DOLLARW]/(real)255;
		real fg22 = DollarMap[x2 + y2*DOLLARW]/(real)255;
		real fg1 = (fg21 - fg11)*xx + fg11;
		real fg2 = (fg22 - fg12)*xx + fg12;
		fg = (fg2 - fg1)*yy + fg1;
		if (bevel < (real)0.002) bevel = (real)0.002;
		fg /= bevel;
	}

	// render color
	fg = m_Prop[PROP_BOX_PROFILE].RenderVal(fg, y);
	if (fg >= 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (fg <= 0)
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
		else
		{
			CColor f;
			m_Prop[PROP_SOURCE].RenderCol(&f, x, y);
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
			col->Trans(f, fg);
		}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDollar::RenderVal(real x, real y)
{
	CColor col;
	CFilterDollar::RenderCol(&col, x, y);
	return col.Gray();
}

