
///////////////////////////////////////////////////////////////////////////////
//
//                                      Star
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// TODO: Star implementation is very weak and need complete reconstruction!

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterStar::CFilterStar()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Star");
	m_HelpID = HELP_FSTAR;
	m_PropNum = 15;

	m_Prop[PROP_SOURCE].SetValue(1);
	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_BOXCOLOR);

	m_Prop[PROP_SOURCE2].SetName("Background");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_BACKGROUND);

	m_Prop[PROP_STAR_RAYS].SetName("Rays");
	m_Prop[PROP_STAR_RAYS].SetValue((real)0.05);
	m_Prop[PROP_STAR_RAYS].SetMin(3);
	m_Prop[PROP_STAR_RAYS].SetMinVal((real)0.03);
	m_Prop[PROP_STAR_RAYS].SetToolID(ID_PROP_STARRAYS);

	m_Prop[PROP_STAR_RADIUS].SetName("Radius");
	m_Prop[PROP_STAR_RADIUS].SetValue((real)0.25);
	m_Prop[PROP_STAR_RADIUS].SetToolID(ID_PROP_STARRADIUS);

	m_Prop[PROP_STAR_STUFFING].SetName("Stuffing");
	m_Prop[PROP_STAR_STUFFING].SetValue((real)0.5);
	m_Prop[PROP_STAR_STUFFING].SetToolID(ID_PROP_STARSTUFFING);

	m_Prop[PROP_STAR_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_STAR_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_STAR_SQUEEZE].SetMin(-50);
	m_Prop[PROP_STAR_SQUEEZE].SetMax(50);
	m_Prop[PROP_STAR_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);

	m_Prop[PROP_STAR_ANGLE].SetName("Angle");
	m_Prop[PROP_STAR_ANGLE].SetValue(0.5);
	m_Prop[PROP_STAR_ANGLE].SetMin(-180);
	m_Prop[PROP_STAR_ANGLE].SetMax(180);
	m_Prop[PROP_STAR_ANGLE].SetToolID(ID_PROP_ANGLE2);

	m_Prop[PROP_STAR_SHIFTX].SetName("ShiftX");
	m_Prop[PROP_STAR_SHIFTX].SetValue((real)0.5);
	m_Prop[PROP_STAR_SHIFTX].SetMin(-50);
	m_Prop[PROP_STAR_SHIFTX].SetMax(50);
	m_Prop[PROP_STAR_SHIFTX].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_STAR_SHIFTY].SetName("ShiftY");
	m_Prop[PROP_STAR_SHIFTY].SetValue((real)0.5);
	m_Prop[PROP_STAR_SHIFTY].SetMin(-50);
	m_Prop[PROP_STAR_SHIFTY].SetMax(50);
	m_Prop[PROP_STAR_SHIFTY].SetToolID(ID_PROP_SHIFTY);

	m_Prop[PROP_STAR_SMOOTH].SetName("SmoothOut");
	m_Prop[PROP_STAR_SMOOTH].SetToolID(ID_PROP_STARSMOOTH);

	m_Prop[PROP_STAR_SMOOTHIN].SetName("SmoothIn");
	m_Prop[PROP_STAR_SMOOTHIN].SetToolID(ID_PROP_STARSMOOTHIN);

	m_Prop[PROP_STAR_HOLE].SetName("Hole");
	m_Prop[PROP_STAR_HOLE].SetToolID(ID_PROP_HOLE);

	m_Prop[PROP_STAR_TILES].SetName("Tiles");
	m_Prop[PROP_STAR_TILES].SetToolID(ID_PROP_TILES);

	m_Prop[PROP_STAR_BEVEL].SetName("Bevel");
	m_Prop[PROP_STAR_BEVEL].SetToolID(ID_PROP_BEVEL);

	m_Prop[PROP_STAR_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_STAR_PROFILE].SetName("Profile");
	m_Prop[PROP_STAR_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_STAR_PROFILE].SetToolID(ID_PROP_BEVELPROFILE);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterStar::RenderCol(CColor* col, real x, real y)
{
	// get properties
	int rays = (int)(m_Prop[PROP_STAR_RAYS].RenderVal(x, y)*100 + (real)0.5);
	if (rays < 3) rays = 3;
	real radius = CLAMP(m_Prop[PROP_STAR_RADIUS].RenderVal(x, y));
	real radin = CLAMP(m_Prop[PROP_STAR_STUFFING].RenderVal(x, y)) * cos(PI/rays);
	real squeeze = CLAMP(m_Prop[PROP_STAR_SQUEEZE].RenderVal(x, y))*2;
	real width = 1;
	real height = 1;
	if (squeeze > 1) width = 2 - squeeze; else height = squeeze;
	width *= radius*2;
	height *= radius*2;
	real angle = (m_Prop[PROP_STAR_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real shiftx = m_Prop[PROP_STAR_SHIFTX].RenderVal(x, y);
	real shifty = m_Prop[PROP_STAR_SHIFTY].RenderVal(x, y);
	int tiles = (int)(CLAMP(m_Prop[PROP_STAR_TILES].RenderVal(x, y))*100 + (real)0.5);
	real bevel = m_Prop[PROP_STAR_BEVEL].RenderVal(x, y);
	if (bevel <= 0) bevel = 0;
	if (bevel >= (real)1.2) bevel = (real)1.2;
	bevel *= radin;
	real hole = CLAMP(m_Prop[PROP_STAR_HOLE].RenderVal(x, y))*radin;

	// prepare smooth
	real smoothin = CLAMP(m_Prop[PROP_STAR_SMOOTHIN].RenderVal(x, y));
	real smoothout = CLAMP(m_Prop[PROP_STAR_SMOOTH].RenderVal(x, y));
	real smooth = smoothin;
	if (smoothout > smooth) smooth = smoothout;
	real kk = smoothin + smoothout;
	if (kk > 0)
	{
		smoothin *= smooth/kk;
		smoothout *= smooth/kk;
	}

	// resize in case of outer smooth (not accurated!)
	if (smoothout > 0)
	{
		// r1,r3=1-(1-radin)*smoothout, r2=1, t=0.5,
		// r=(1-t)*(1-t)*r1 + 2*t*(1-t)*r2 + t*t*r3 = 0.25*r1 + 0.5*r2 + 0.25*r3
		kk = 1/((1-(1-radin)*sqrt(smoothout))/2 + (real)0.5);
		width *= kk;
		height *= kk;
	}

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

	// find star (using boundary circle) and prepare local coordinates
	real fg = 0;
	real ca = cos(angle);
	real sa = sin(angle);
	bool in = false;
	real xy = 1;
	real xx3 = 0;
	real yy3 = 0;
	if ((width > 0) && (height > 0) && (radin > 0))
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
					xx3 = (xx2*ca + yy2*sa)/dx;
					yy3 = (yy2*ca - xx2*sa)/dy;
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
			xx3 = (xx*ca + yy*sa)/dx;
			yy3 = (yy*ca - xx*sa)/dy;
			xy = xx3*xx3 + yy3*yy3;
			in = (xy <= 1);
		}
	}

	// detections in star (angle goes from top to left)
	if (in && (xy > 0))
	{
		// relative angle
		real a = atan2(-xx3, yy3);
		if (a < 0) a += PI2;
		real da = PI2/rays;
		real a2 = a/da;
		real n = (real)(int)a2;
		a2 -= n;

		// edges
		real ar1 = n*da;
		real x1 = -sin(ar1);
		real y1 = cos(ar1);
		real ar2 = ar1 + da/2;
		real x2 = -sin(ar2)*radin;
		real y2 = cos(ar2)*radin;
		real ar3 = ar1 + da;
		real x3 = -sin(ar3);
		real y3 = cos(ar3);

		// inner smooth
		if ((smoothin > 0) && (a2 <= 0.5 + smoothin/2) && (a2 >= 0.5 - smoothin/2))
		{
			// start point on descending edge
			// 1) axis through start point: y = x*yr/xr
			// 2) descending edge: (x - x2)*(y1 - y2) = (y - y2)*(x1 - x2)
			// intersection at start point: (x - x2)*(y1 - y2) = (x*yr/xr - y2)*(x1 - x2)
			// start point: x = (x2*y1 - x1*y2)/(yr/xr*(x2 - x1) + (y1 - y2))
			real ar = ar2 - smoothin/2*da;
			real xr = -sin(ar);
			real yr = cos(ar);
			if (abs(xr) < (real)1e-10) xr = (real)1e-10;
			real kk = yr/xr*(x2 - x1) + y1 - y2;
			if (abs(kk) < (real)1e-10) kk = (real)1e-10;
			x1 = (x2*y1 - x1*y2)/kk;
			y1 = x1*yr/xr;

			// end point on ascending edge
			// 1) axis through end point: y = x*yr/xr
			// 2) ascending edge: (x - x2)*(y3 - y2) = (y - y2)*(x3 - x2)
			// intersection at start point: (x - x2)*(y3 - y2) = (x*yr/xr - y2)*(x3 - x2)
			// start point: x = (x2*y3 - x3*y2)/(yr/xr*(x2 - x3) + (y3 - y2))
			ar += smoothin*da;
			xr = -sin(ar);
			yr = cos(ar);
			if (abs(xr) < (real)1e-10) xr = (real)1e-10;
			kk = yr/xr*(x2 - x3) + y3 - y2;
			if (abs(kk) < (real)1e-10) kk = (real)1e-10;
			x3 = (x2*y3 - x3*y2)/kk;
			y3 = x3*yr/xr;

			// find Bezier curve at direction of the point xx3, yy3 (using iteration)
			real t = (a2 - (real)0.5 + smoothin/2)/smoothin;
			real xx = 0;
			real yy = 0;
			real aa;
			int i;
			for (i = 5; i > 0; i--)
			{
				xx = (1-t)*(1-t)*x1 + 2*t*(1-t)*x2 + t*t*x3;
				yy = (1-t)*(1-t)*y1 + 2*t*(1-t)*y2 + t*t*y3;
				aa = atan2(-xx, yy);
				if (aa < 0) aa += PI2;
				real da = aa - a;
				if (da < -PI) da += PI2;
				if (da > PI) da -= PI2;
				da = da / PI2 * rays / smoothin;
				t -= da;
				t = CLAMP(t);
			}
			xx = (1-t)*(1-t)*x1 + 2*t*(1-t)*x2 + t*t*x3;
			yy = (1-t)*(1-t)*y1 + 2*t*(1-t)*y2 + t*t*y3;

			// check if the point is inside
			in = (xy <= xx*xx + yy*yy);

			if (in)
			{
				fg = 1;
				if (bevel > 0)
				{
					fg = sqrt(sqr(xx3 - xx) + sqr(yy3 - yy))/bevel;
					if (fg > 1) fg = 1;
				}
			}
		}
		// outer smooth
		else if ((smoothout > 0) && ((a2 <= smoothout/2) || (a2 >= 1 - smoothout/2)))
		{
			real t;
			if (a2 < (real)0.5)
			{
				t = a2 / smoothout + (real)0.5;
				ar3 = ar2;
				x3 = x2;
				y3 = y2;
				ar2 = ar1;
				x2 = x1;
				y2 = y1;
				ar1 -= da/2;
				x1 = -sin(ar1)*radin;
				y1 = cos(ar1)*radin;
			}
			else
			{
				t = (a2 - (1 - smoothout/2))/smoothout;
				ar1 = ar2;
				x1 = x2;
				y1 = y2;
				ar2 = ar3;
				x2 = x3;
				y2 = y3;
				ar3 += da/2;
				x3 = -sin(ar3)*radin;
				y3 = cos(ar3)*radin;
			}

			// start point on ascending edge
			// 1) axis through start point: y = x*yr/xr
			// 2) ascending edge: (x - x2)*(y1 - y2) = (y - y2)*(x1 - x2)
			// intersection at start point: (x - x2)*(y1 - y2) = (x*yr/xr - y2)*(x1 - x2)
			// start point: x = (x2*y1 - x1*y2)/(yr/xr*(x2 - x1) + (y1 - y2))
			real ar = ar2 - smoothout/2*da;
			real xr = -sin(ar);
			real yr = cos(ar);
			if (abs(xr) < (real)1e-10) xr = (real)1e-10;
			real kk = yr/xr*(x2 - x1) + y1 - y2;
			if (abs(kk) < (real)1e-10) kk = (real)1e-10;
			x1 = (x2*y1 - x1*y2)/kk;
			y1 = x1*yr/xr;

			// end point on descending edge
			// 1) axis through end point: y = x*yr/xr
			// 2) descending edge: (x - x2)*(y3 - y2) = (y - y2)*(x3 - x2)
			// intersection at start point: (x - x2)*(y3 - y2) = (x*yr/xr - y2)*(x3 - x2)
			// start point: x = (x2*y3 - x3*y2)/(yr/xr*(x2 - x3) + (y3 - y2))
			ar += smoothout*da;
			xr = -sin(ar);
			yr = cos(ar);
			if (abs(xr) < (real)1e-10) xr = (real)1e-10;
			kk = yr/xr*(x2 - x3) + y3 - y2;
			if (abs(kk) < (real)1e-10) kk = (real)1e-10;
			x3 = (x2*y3 - x3*y2)/kk;
			y3 = x3*yr/xr;

			// find Bezier curve at direction of the point xx3, yy3 (using iteration)
			real xx = 0;
			real yy = 0;
			real aa;
			int i;
			for (i = 10; i > 0; i--)
			{
				xx = (1-t)*(1-t)*x1 + 2*t*(1-t)*x2 + t*t*x3;
				yy = (1-t)*(1-t)*y1 + 2*t*(1-t)*y2 + t*t*y3;
				aa = atan2(-xx, yy);
				if (aa < 0) aa += PI2;
				real da = aa - a;
				if (da < -PI) da += PI2;
				if (da > PI) da -= PI2;
				da = da / PI2 * rays / smoothout;
				t -= da*(real)0.03;
				t = CLAMP(t);
			}
			xx = (1-t)*(1-t)*x1 + 2*t*(1-t)*x2 + t*t*x3;
			yy = (1-t)*(1-t)*y1 + 2*t*(1-t)*y2 + t*t*y3;

			// check if the point is inside
			in = (xy <= xx*xx + yy*yy);
		
			if (in)
			{
				fg = 1;
				if (bevel > 0)
				{
					fg = sqrt(sqr(xx3 - xx) + sqr(yy3 - yy))/bevel;
					if (fg > 1) fg = 1;
				}
			}
		}
		// edges
		else
		{
			if (a2 >= (real)0.5)
			{
				x1 = x2;
				y1 = y2;
				x2 = x3;
				y2 = y3;
			}

			// detect intersection with edge
			//   edge line: y = (x - xr1)/(xr2 - xr1)*(yr2 - yr1) + yr1
			//   point line: y = x/xx3*yy3
			//   intersection: x/xx3*yy3 = (x - xr1)/(xr2 - xr1)*(yr2 - yr1) + yr1
			// or:
			//   edge line: x = (y - yr1)/(yr2 - yr1)*(xr2 - xr1) + xr1
			//   point line: x = y/yy3*xx3
			//   intersection: y/yy3*xx3 = (y - yr1)/(yr2 - yr1)*(xr2 - xr1) + xr1
			real xs, ys;
			if ((abs(xx3) > (real)0.00001) && (abs(x2 - x1) > (real)0.00001) && (abs(yy3/xx3 + (y1 - y2)/(x2 - x1)) > (real)0.00001))
			{
				xs = (x2*y1 - x1*y2)/((y1 - y2) + yy3/xx3*(x2 - x1));
				ys = xs/xx3*yy3;
			}
			else
			{
				ys = (x1*y2 - x2*y1)/(xx3/yy3*(y2 - y1) + (x1 - x2));
				xs = ys/yy3*xx3;
			}
			in = (xy <= (xs*xs + ys*ys));

			if (in)
			{
				fg = 1;
				if (bevel > 0)
				{
					fg = sqrt(sqr(xx3 - xs) + sqr(yy3 - ys))/bevel;
					if (fg > 1) fg = 1;
				}
			}
		}
	}
	if (!in || (xy < hole*hole)) fg = 0;

	// render color
	fg = m_Prop[PROP_STAR_PROFILE].RenderVal(fg, y);
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

real CFilterStar::RenderVal(real x, real y)
{
	CColor col;
	CFilterStar::RenderCol(&col, x, y);
	return col.Gray();
}

