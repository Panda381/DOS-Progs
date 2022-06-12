				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Kaleidoscope
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CText KaleidModes[] = {
	CText(_T("Box")),
	CText(_T("Octagon")),
	CText(_T("Triangle")),
	CText(_T("Rhomb")),
	CText(_T("Mesh")),
	CText(_T("Hexagon")),
	CText(_T("Dodecagon")),

	CText(_T(""))
};

#define PROP_KALEID_MODE		1	// property - Mode

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterKaleidoscope::CFilterKaleidoscope()
{
	m_Group = FGRP_DEF;
	m_Class = _T("Kaleidoscope");
	m_HelpID = HELP_FKALEIDOSCOPE;
	m_PropNum = 2;

	m_Prop[PROP_KALEID_MODE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_KALEID_MODE].SetName("Mode");
	m_Prop[PROP_KALEID_MODE].SetValue((real)0.1);
	m_Prop[PROP_KALEID_MODE].SetEnum(KaleidModes);
	m_Prop[PROP_KALEID_MODE].SetToolID(ID_PROP_KALEIDMODE);
	m_Prop[PROP_KALEID_MODE].SetMax(10);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

#define KAL_SYMX 	{ if (x > (real)0.5) x = 1 - x; x *= 2; } // symetric in X direction
#define KAL_SYMY	{ if (y > (real)0.5) y = 1 - y; y *= 2; } // symetric in Y direction
#define KAL_DIA1	if (y > x) { real t = x; x = y; y = t; } // symetric by ascending diagonal
#define KAL_DIA2	if (y < 1 - x) { real t = 1 - x; x = 1 - y; y = t; } // symetric by descending diagonal
#define KAL_DIA3	if (y > 1 - x) { x = 1 - x; y = 1 - y; } // rotate by descending diagonal

void CFilterKaleidoscope::RenderCol(CColor* col, real x, real y)
{
	// load properties
	int mode = (int)(m_Prop[PROP_KALEID_MODE].RenderVal(x, y)*10+(real)0.5);

	// repeat coordinates
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);

	// mirroring
	switch (mode)
	{
	// Box
	case 0:
		KAL_SYMX;
		KAL_SYMY;
		break;

	// Octagon
	case 1:
		KAL_SYMX;
		KAL_SYMY;
		KAL_DIA1;
		break;

	// Triangle
	case 2:
		KAL_SYMX;
		KAL_SYMY;
		KAL_DIA2;
		break;
		
	// Rhomb
	case 3:
		KAL_DIA1;
		KAL_DIA2;
		if (y > (real)1.5 - x)
		{
			real t = (real)1.5 - x;
			x = (real)1.5 - y;
			y = t;
		}
		if (y < x - (real)0.5)
		{
			real t = x - (real)0.5;
			x = y + (real)0.5;
			y = t;
		}
		x -= (real)0.5;
		y -= (real)0.25;
		x *= 2;
		y *= 2;
		break;

	// Mesh
	case 4:
		KAL_SYMX;
		KAL_SYMY;
		KAL_SYMY;
		if (x >= (real)0.5)
		{
			x = (1 - x)*2;
			KAL_DIA1;
		}
		else
		{
			x *= 2;
			KAL_DIA2;
		}
		break;

	// Hexagon
	case 5:
		{
#define KA (real)1.1547005383792515 // a = 2/sqrt(3) ... lenght of triangle base
#define SIN120 (real)0.8660254037844386 // sin(120)
#define COS120 (real)-0.5 // cos(120)
#define SIN60 (real)0.8660254037844386 // sin(60)
#define COS60 (real)0.5 // cos(60)

			KAL_SYMY;
			real x2 = x * 6;
			int n = (int)x2;
			x2 -= n;
			if ((n & 1) == 0)
			{
				if (y < x2) n++;
			}
			else
			{
				if (y > 1 - x2) n++;
			}

			x *= 3*KA; // to get isosceles triangles

			// triangles from left to right
			real x3, y3;
			switch (n)
			{
			case 1:
				break;

			case 2:
				x -= (real)1.5*KA;
				y = 1 - y;
				x3 = x*COS120 + y*SIN120;
				y3 = y*COS120 - x*SIN120;
				x = x3;
				y = y3;
				break;

			case 3:
				x -= (real)1.5*KA;
				y -= 1;
				x3 = x*COS120 - y*SIN120;
				y3 = y*COS120 + x*SIN120;
				x = x3;
				y = y3;
				break;

			case 4:
				x -= (real)1.5*KA;
				y = 1 - y;
				break;

			case 5:
				x -= 3*KA;
				x3 = x*COS120 + y*SIN120;
				y3 = y*COS120 - x*SIN120;
				x = x3;
				y = y3;
				break;

			case 6:
				x -= 3*KA;
			default:
				x = -x;
				x3 = x*COS60 + y*SIN60;
				y3 = y*COS60 - x*SIN60;
				x = x3;
				y = y3;
				break;
			}
			x /= KA;
		}
		break;

	// Dodecagon
	default:
		{
			KAL_SYMX;
			KAL_SYMY;
			KAL_SYMY;
			KAL_DIA3;
#define KC (real)1.73205080756888 // 3/sqrt(3) = a + b
#define KB (real)0.577350269189626 // b = 1/sqrt(3)

			real x3, y3;
			x *= KC;	// to get rectangle triangles
			real x2 = x/KB;
			if (y > 1 - x2)
			{
				if (y < x2 - 1)
				{
					x -= KB;
					x3 = x*COS120 - y*SIN120;
					y3 = y*COS120 + x*SIN120;
					x = x3 + KB;
					y = y3;
				}
				else
				{
					y -= 1;
					x3 = x*COS60 + y*SIN60;
					y3 = y*COS60 - x*SIN60;
					x = -x3;
					y = y3 + 1;
				}
			}
			x += (1 - KB)/2;
		}
		break;
	}

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterKaleidoscope::RenderVal(real x, real y)
{
	CColor col;
	CFilterKaleidoscope::RenderCol(&col, x, y);
	return col.Gray();
}
