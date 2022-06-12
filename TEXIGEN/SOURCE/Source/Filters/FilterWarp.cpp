		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                  Warp Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROP_WARP_HEIGHTMAP	1	// property - height map
#define PROP_WARP_STRENGTH	2	// property - Strentgh (minimum value 0..1; default 0.2)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterWarp::CFilterWarp()
{
	m_Group = FGRP_DEF;
	m_Class = _T("Warp");
	m_HelpID = HELP_FWARP;
	m_PropNum = 3;

	m_Prop[PROP_WARP_HEIGHTMAP].SetName("HeightMap");
	m_Prop[PROP_WARP_HEIGHTMAP].SetToolID(ID_PROP_HEIGHTMAP);

	m_Prop[PROP_WARP_STRENGTH].SetName("Strength");
	m_Prop[PROP_WARP_STRENGTH].SetValue((real)0.5);
	m_Prop[PROP_WARP_STRENGTH].SetToolID(ID_PROP_STRENGTH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterWarp::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real strength = m_Prop[PROP_WARP_STRENGTH].RenderVal(x, y);
	strength = strength*strength*strength*200;

	// derivations
	real dx, dy;
	m_Prop[PROP_WARP_HEIGHTMAP].Derive(x, y, &dx, &dy);

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x + dx*strength, y + dy*strength);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterWarp::RenderVal(real x, real y)
{
	// load properties
	real strength = m_Prop[PROP_WARP_STRENGTH].RenderVal(x, y);
	strength = strength*strength*strength*200;

	// derivations
	real dx, dy;
	m_Prop[PROP_WARP_HEIGHTMAP].Derive(x, y, &dx, &dy);

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x + dx*strength, y + dy*strength);
}

#define PROP_LENS_DIAMETER		2	// property - Diameter
#define PROP_LENS_REFRACTION	3	// property - Refraction

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLens::CFilterLens()
{
	m_Group = FGRP_DEF;
	m_Class = _T("Lens");
	m_HelpID = HELP_FLENS;
	m_PropNum = 4;

	m_Prop[PROP_LENS_DIAMETER].SetName("Diameter");
	m_Prop[PROP_LENS_DIAMETER].SetToolID(ID_LENS_DIAMETER);
	m_Prop[PROP_LENS_DIAMETER].SetValue((real)0.75);

	m_Prop[PROP_LENS_REFRACTION].SetName("Refraction");
	m_Prop[PROP_LENS_REFRACTION].SetValue((real)0.75);
	m_Prop[PROP_LENS_REFRACTION].SetMin(-50);
	m_Prop[PROP_LENS_REFRACTION].SetMax(50);
	m_Prop[PROP_LENS_REFRACTION].SetToolID(ID_LENS_REFRACTION);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLens::RenderCol(CColor* col, real x, real y)
{
	// get diameter
	real r = m_Prop[PROP_LENS_DIAMETER].RenderVal(x, y)/2 + (real)0.0001;

	// distance
	real dx = (x - (real)0.5)/r;
	real dy = (y - (real)0.5)/r;
	real d = dx*dx + dy*dy;

	// background
	if (d > 1)
	{
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
		return;
	}

	// prepare polar coordinates
	d = sqrt(d);
	real a = atan2(dy, dx);

	// get refraction
	real pwr = pow(2,-(m_Prop[PROP_LENS_REFRACTION].RenderVal(x, y)-(real)0.5)*6);

	// refraction
	d = 1-pow((1-d), pwr);

	// get cartesian coordinates
	dx = d*cos(a);
	dy = d*sin(a);

	// render color
	m_Prop[PROP_SOURCE2].RenderCol(col, (dx+1)/2, (dy+1)/2);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLens::RenderVal(real x, real y)
{
	CColor col;
	CFilterLens::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterPolar::CFilterPolar()
{
	m_Group = FGRP_DEF;
	m_Class = _T("Polar");
	m_HelpID = HELP_FPOLAR;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterPolar::RenderCol(CColor* col, real x, real y)
{
	x = (x - (real)0.5)*2;
	y = (y - (real)0.5)*2;
	real d = sqrt(x*x + y*y);
	real a = atan2(x, y)/PI2 + (real)0.5;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, a, d);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterPolar::RenderVal(real x, real y)
{
	x = (x - (real)0.5)*2;
	y = (y - (real)0.5)*2;
	real d = sqrt(x*x + y*y);
	real a = atan2(x, y)/PI2 + (real)0.5;

	return m_Prop[PROP_SOURCE].RenderVal(a, d);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterCartes::CFilterCartes()
{
	m_Group = FGRP_DEF;
	m_Class = _T("Cartes");
	m_HelpID = HELP_FCARTES;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterCartes::RenderCol(CColor* col, real x, real y)
{
	real a = (x - (real)0.5)*PI2;
	real d = y/2;
	x = d*sin(a) + (real)0.5;
	y = d*cos(a) + (real)0.5;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCartes::RenderVal(real x, real y)
{
	CColor col;
	CFilterCartes::RenderCol(&col, x, y);
	return col.Gray();
}
