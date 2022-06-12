				   
///////////////////////////////////////////////////////////////////////////////
//
//                               Shear Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROP_SHEAR_SHEAR	1		// property - Shear (0..1 = shear -100% left/bottom .. +100% right/top, default 0.5 = no shear)
#define PROP_SHEAR_CENTER	2		// property - Center (0..1 = left/bottom..right/top edge, default 0.5 = center)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterShearX::CFilterShearX()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("ShearX");
	m_HelpID = HELP_FSHEARX;
	m_PropNum = 3;

	m_Prop[PROP_SHEAR_SHEAR].SetName("Shear");
	m_Prop[PROP_SHEAR_SHEAR].SetValue((real)0.5);
	m_Prop[PROP_SHEAR_SHEAR].SetMin(-50);
	m_Prop[PROP_SHEAR_SHEAR].SetMax(50);
	m_Prop[PROP_SHEAR_SHEAR].SetToolID(ID_PROP_SHEAR);

	m_Prop[PROP_SHEAR_CENTER].SetName("Center");
	m_Prop[PROP_SHEAR_CENTER].SetValue((real)0.5);
	m_Prop[PROP_SHEAR_CENTER].SetMin(-50);
	m_Prop[PROP_SHEAR_CENTER].SetMax(50);
	m_Prop[PROP_SHEAR_CENTER].SetToolID(ID_PROP_SHEARCENTER);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterShearX::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real shear = m_Prop[PROP_SHEAR_SHEAR].RenderVal(x, y);
	real center = m_Prop[PROP_SHEAR_CENTER].RenderVal(x, y);

	// transform coordinates
	x -= (y - center) * (shear - (real)0.5)*2;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterShearX::RenderVal(real x, real y)
{
	// load properties
	real shear = m_Prop[PROP_SHEAR_SHEAR].RenderVal(x, y);
	real center = m_Prop[PROP_SHEAR_CENTER].RenderVal(x, y);

	// transform coordinates
	x -= (y - center) * (shear - (real)0.5)*2;

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterShearY::CFilterShearY()
{
	m_Class = _T("ShearY");
	m_HelpID = HELP_FSHEARY;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterShearY::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real shear = m_Prop[PROP_SHEAR_SHEAR].RenderVal(x, y);
	real center = m_Prop[PROP_SHEAR_CENTER].RenderVal(x, y);

	// transform coordinates
	y -= (x - center) * (shear - (real)0.5)*2;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterShearY::RenderVal(real x, real y)
{
	// load properties
	real shear = m_Prop[PROP_SHEAR_SHEAR].RenderVal(x, y);
	real center = m_Prop[PROP_SHEAR_CENTER].RenderVal(x, y);

	// transform coordinates
	y -= (x - center) * (shear - (real)0.5)*2;

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}
