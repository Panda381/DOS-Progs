				   
///////////////////////////////////////////////////////////////////////////////
//
//                             Shift Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterShift::CFilterShift()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Shift");
	m_HelpID = HELP_FSHIFT;
	m_PropNum = 3;

	m_Prop[PROP_SHIFT_X].SetName("ShiftX");
	m_Prop[PROP_SHIFT_X].SetValue((real)0.5);
	m_Prop[PROP_SHIFT_X].SetMin(-50);
	m_Prop[PROP_SHIFT_X].SetMax(50);
	m_Prop[PROP_SHIFT_X].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_SHIFT_Y].SetName("ShiftY");
	m_Prop[PROP_SHIFT_Y].SetValue((real)0.5);
	m_Prop[PROP_SHIFT_Y].SetMin(-50);
	m_Prop[PROP_SHIFT_Y].SetMax(50);
	m_Prop[PROP_SHIFT_Y].SetToolID(ID_PROP_SHIFTY);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterShift::RenderCol(CColor* col, real x, real y)
{
	// load properties and shift coordinates
	real x2 = x - (m_Prop[PROP_SHIFT_X].RenderVal(x, y) - (real)0.5);
	real y2 = y - (m_Prop[PROP_SHIFT_Y].RenderVal(x, y) - (real)0.5);

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x2, y2);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterShift::RenderVal(real x, real y)
{
	// load properties and shift coordinates
	real x2 = x - (m_Prop[PROP_SHIFT_X].RenderVal(x, y) - (real)0.5);
	real y2 = y - (m_Prop[PROP_SHIFT_Y].RenderVal(x, y) - (real)0.5);

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x2, y2);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLookup::CFilterLookup()
{
	m_Group = FGRP_TRANS;
	m_Class = _T("Lookup");
	m_HelpID = HELP_FLOOKUP;
	m_PropNum = 3;

	m_Prop[PROP_LOOKUP_X].SetCategory(PCAT_CURVE);
	m_Prop[PROP_LOOKUP_X].SetFilter(&FLinear);
	m_Prop[PROP_LOOKUP_X].SetName("LookupX");
	//m_Prop[PROP_LOOKUP_X].SetValue((real)0.5);
	m_Prop[PROP_LOOKUP_X].SetToolID(ID_PROP_LOOKUPX);

	m_Prop[PROP_LOOKUP_Y].SetName("LookupY");
	m_Prop[PROP_LOOKUP_Y].SetValue((real)0.5);
	m_Prop[PROP_LOOKUP_Y].SetToolID(ID_PROP_LOOKUPY);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLookup::RenderCol(CColor* col, real x, real y)
{
	// load coordinates
	real x2 = m_Prop[PROP_LOOKUP_X].RenderVal(x, y);
	real y2 = m_Prop[PROP_LOOKUP_Y].RenderVal(x, y);

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x2, y2);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLookup::RenderVal(real x, real y)
{
	// load coordinates
	real x2 = m_Prop[PROP_LOOKUP_X].RenderVal(x, y);
	real y2 = m_Prop[PROP_LOOKUP_Y].RenderVal(x, y);

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x2, y2);
}
