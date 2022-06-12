
///////////////////////////////////////////////////////////////////////////////
//
//                                      Cut
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterCut::CFilterCut()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Cut");
	m_HelpID = HELP_FCUT;
	m_PropNum = 6;

	m_Prop[PROP_SOURCE].SetValue(1);

	m_Prop[PROP_SOURCE2].SetName("Background");
	m_Prop[PROP_SOURCE2].SetColor(0,0,0,0);
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_BACKGROUND);

	m_Prop[PROP_CUT_X1].SetName("Left");
	m_Prop[PROP_CUT_X1].SetToolID(ID_PROP_CUTX1);

	m_Prop[PROP_CUT_X2].SetName("Right");
	m_Prop[PROP_CUT_X2].SetValue(1);
	m_Prop[PROP_CUT_X2].SetToolID(ID_PROP_CUTX2);

	m_Prop[PROP_CUT_Y1].SetName("Bottom");
	m_Prop[PROP_CUT_Y1].SetToolID(ID_PROP_CUTY1);

	m_Prop[PROP_CUT_Y2].SetName("Top");
	m_Prop[PROP_CUT_Y2].SetValue(1);
	m_Prop[PROP_CUT_Y2].SetToolID(ID_PROP_CUTY2);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterCut::RenderCol(CColor* col, real x, real y)
{
	if (	(x >= m_Prop[PROP_CUT_X1].RenderVal(x, y)) &&
			(x < m_Prop[PROP_CUT_X2].RenderVal(x, y)) &&
			(y >= m_Prop[PROP_CUT_Y1].RenderVal(x, y)) &&
			(y < m_Prop[PROP_CUT_Y2].RenderVal(x, y)))
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCut::RenderVal(real x, real y)
{
	if (	(x >= m_Prop[PROP_CUT_X1].RenderVal(x, y)) &&
			(x < m_Prop[PROP_CUT_X2].RenderVal(x, y)) &&
			(y >= m_Prop[PROP_CUT_Y1].RenderVal(x, y)) &&
			(y < m_Prop[PROP_CUT_Y2].RenderVal(x, y)))
		return m_Prop[PROP_SOURCE].RenderVal(x, y);
	else
		return m_Prop[PROP_SOURCE2].RenderVal(x, y);
}
