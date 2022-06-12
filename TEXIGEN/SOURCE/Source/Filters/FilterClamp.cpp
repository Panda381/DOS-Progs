					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Clamp Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterClamp::CFilterClamp()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Clamp");
	m_HelpID = HELP_FCLAMP;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterClamp::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->Clamp();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterClamp::RenderVal(real x, real y)
{
	return CLAMP(m_Prop[PROP_SOURCE].RenderVal(x, y));
}
