		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Gradient Colorize Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterColorize::CFilterColorize()
{
	m_Group = FGRP_COL;
	m_Class = _T("Colorize");
	m_HelpID = HELP_FCOLORIZE;
	m_PropNum = 2;
	m_Prop[PROP_SOURCE].SetCategory(PCAT_VAL);

	m_Prop[PROP_COLORIZE_GRADIENT].SetCategory(PCAT_GRAD);
	m_Prop[PROP_COLORIZE_GRADIENT].SetName("Gradient");
	m_Prop[PROP_COLORIZE_GRADIENT].SetFilter(&FLinear);
	m_Prop[PROP_COLORIZE_GRADIENT].SetToolID(ID_PROP_COLGRAD);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterColorize::RenderCol(CColor* col, real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	m_Prop[PROP_COLORIZE_GRADIENT].RenderCol(col, val, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterColorize::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return m_Prop[PROP_COLORIZE_GRADIENT].RenderVal(val, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterColorizeChan::CFilterColorizeChan()
{
	m_Group = FGRP_COL;
	m_Class = _T("ColorizeChan");
	m_HelpID = HELP_FCOLORIZECHAN;
	m_PropNum = 5;

	m_Prop[PROP_COLORIZECHAN_GRADIENTR].SetName("ProfileR");
	m_Prop[PROP_COLORIZECHAN_GRADIENTR].SetCategory(PCAT_CURVE);
	m_Prop[PROP_COLORIZECHAN_GRADIENTR].SetFilter(&FLinear);
	m_Prop[PROP_COLORIZECHAN_GRADIENTR].SetToolID(ID_PROP_COLRGRAD);

	m_Prop[PROP_COLORIZECHAN_GRADIENTG].SetName("ProfileG");
	m_Prop[PROP_COLORIZECHAN_GRADIENTG].SetCategory(PCAT_CURVE);
	m_Prop[PROP_COLORIZECHAN_GRADIENTG].SetFilter(&FLinear);
	m_Prop[PROP_COLORIZECHAN_GRADIENTG].SetToolID(ID_PROP_COLGGRAD);

	m_Prop[PROP_COLORIZECHAN_GRADIENTB].SetName("ProfileB");
	m_Prop[PROP_COLORIZECHAN_GRADIENTB].SetCategory(PCAT_CURVE);
	m_Prop[PROP_COLORIZECHAN_GRADIENTB].SetFilter(&FLinear);
	m_Prop[PROP_COLORIZECHAN_GRADIENTB].SetToolID(ID_PROP_COLBGRAD);

	m_Prop[PROP_COLORIZECHAN_GRADIENTA].SetName("ProfileA");
	m_Prop[PROP_COLORIZECHAN_GRADIENTA].SetCategory(PCAT_CURVE);
	m_Prop[PROP_COLORIZECHAN_GRADIENTA].SetFilter(&FLinear);
	m_Prop[PROP_COLORIZECHAN_GRADIENTA].SetToolID(ID_PROP_COLAGRAD);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterColorizeChan::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->r = m_Prop[PROP_COLORIZECHAN_GRADIENTR].RenderVal(col->r, y);
	col->g = m_Prop[PROP_COLORIZECHAN_GRADIENTG].RenderVal(col->g, y);
	col->b = m_Prop[PROP_COLORIZECHAN_GRADIENTB].RenderVal(col->b, y);
	col->a = m_Prop[PROP_COLORIZECHAN_GRADIENTA].RenderVal(col->a, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterColorizeChan::RenderVal(real x, real y)
{
	CColor col;
	CFilterColorizeChan::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDecolorize::CFilterDecolorize()
{
	m_Group = FGRP_COL;
	m_Class = _T("Decolorize");
	m_HelpID = HELP_FDECOLORIZE;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDecolorize::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->Decolorize();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDecolorize::RenderVal(real x, real y)
{
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}
