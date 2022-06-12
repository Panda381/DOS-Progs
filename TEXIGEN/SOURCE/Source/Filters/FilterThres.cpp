	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Threshold Switch Sources
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold::CFilterThreshold()
{
	m_Group = FGRP_COL;
	m_Class = _T("Threshold");
	m_HelpID = HELP_FTHRESHOLD;
	m_PropNum = 5;

	m_Prop[PROP_THRES_LEVEL].SetName("Level");
	m_Prop[PROP_THRES_LEVEL].SetValue((real)0.5);
	m_Prop[PROP_THRES_LEVEL].SetToolID(ID_PROP_THRESLEVEL);

	m_Prop[PROP_THRES_TOLERANCE].SetName("Tolerance");
	m_Prop[PROP_THRES_TOLERANCE].SetToolID(ID_PROP_THRESTOL);

	m_Prop[PROP_THRES_LOW].SetCategory(PCAT_COLOR);
	m_Prop[PROP_THRES_LOW].SetName("Low");
	m_Prop[PROP_THRES_LOW].SetToolID(ID_PROP_THRESLOW);

	m_Prop[PROP_THRES_HIGH].SetCategory(PCAT_COLOR);
	m_Prop[PROP_THRES_HIGH].SetName("High");
	m_Prop[PROP_THRES_HIGH].SetValue(1);
	m_Prop[PROP_THRES_HIGH].SetToolID(ID_PROP_THRESHIGH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold::RenderCol(CColor* col, real x, real y)
{
	real tol = m_Prop[PROP_THRES_TOLERANCE].RenderVal(x, y);
	real lev = m_Prop[PROP_THRES_LEVEL].RenderVal(x, y);
	lev = lev*(1 - tol) + tol/2;
	real min = lev - tol/2;
	real max = lev + tol/2;
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);

	if (val < min)
	{
		m_Prop[PROP_THRES_LOW].RenderCol(col, x, y);
		return;
	}

	if (val >= max)
	{
		m_Prop[PROP_THRES_HIGH].RenderCol(col, x, y);
		return;
	}

	m_Prop[PROP_THRES_LOW].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_THRES_HIGH].RenderCol(&c, x, y);
	col->Trans(c, (val - min)/(max - min));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold::RenderVal(real x, real y)
{
	real tol = m_Prop[PROP_THRES_TOLERANCE].RenderVal(x, y);
	real lev = m_Prop[PROP_THRES_LEVEL].RenderVal(x, y);
	lev = lev*(1 - tol) + tol/2;
	real min = lev - tol/2;
	real max = lev + tol/2;
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);

	if (val < min)
	{
		return m_Prop[PROP_THRES_LOW].RenderVal(x, y);
	}

	if (val >= max)
	{
		return m_Prop[PROP_THRES_HIGH].RenderVal(x, y);
	}

	real low = m_Prop[PROP_THRES_LOW].RenderVal(x, y);
	real high = m_Prop[PROP_THRES_HIGH].RenderVal(x, y);
	real k = (val - min)/(max - min);
	return low*(1-k) + high*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold2::CFilterThreshold2()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold2");
	m_HelpID = HELP_FTHRESHOLD2;
	m_PropNum = 3;

	m_Prop[PROP_THRES2_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES2_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold2::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES2_LEVEL].RenderVal(x, y);
	m_Prop[(k >= 0.5) ? PROP_SOURCE2 : PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold2::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES2_LEVEL].RenderVal(x, y);
	return m_Prop[(k >= 0.5) ? PROP_SOURCE2 : PROP_SOURCE].RenderVal(x, y);
}

#define PROP_THRES3_LEVEL	3	// property - Threshold (0..1, switch on 0.33,0.66)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold3::CFilterThreshold3()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold3");
	m_HelpID = HELP_FTHRESHOLD3;
	m_PropNum = 4;

	m_Prop[PROP_THRES3_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES3_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold3::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES3_LEVEL].RenderVal(x, y);
	k = 3*CLAMP(k);
	int n = (int)k;
	if (n > 2) n = 2;
	m_Prop[n + PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold3::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES3_LEVEL].RenderVal(x, y);
	k = 3*CLAMP(k);
	int n = (int)k;
	if (n > 2) n = 2;
	return m_Prop[n + PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold4::CFilterThreshold4()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold4");
	m_HelpID = HELP_FTHRESHOLD4;
	m_PropNum = 5;

	m_Prop[PROP_THRES4_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES4_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold4::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES4_LEVEL].RenderVal(x, y);
	k = 4*CLAMP(k);
	int n = (int)k;
	if (n > 3) n = 3;
	m_Prop[n + PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold4::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES4_LEVEL].RenderVal(x, y);
	k = 4*CLAMP(k);
	int n = (int)k;
	if (n > 3) n = 3;
	return m_Prop[n + PROP_SOURCE].RenderVal(x, y);
}

#define PROP_THRES5_LEVEL	5	// property - Threshold (0..1, switch on 0.2,...0.8)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold5::CFilterThreshold5()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold5");
	m_HelpID = HELP_FTHRESHOLD5;
	m_PropNum = 6;

	m_Prop[PROP_THRES5_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES5_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold5::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES5_LEVEL].RenderVal(x, y);
	k = 5*CLAMP(k);
	int n = (int)k;
	if (n > 4) n = 4;
	m_Prop[n + PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold5::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES5_LEVEL].RenderVal(x, y);
	k = 5*CLAMP(k);
	int n = (int)k;
	if (n > 4) n = 4;
	return m_Prop[n + PROP_SOURCE].RenderVal(x, y);
}

#define PROP_THRES6_LEVEL	6	// property - Threshold (0..1, switch on 0.17,...0.83)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold6::CFilterThreshold6()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold6");
	m_HelpID = HELP_FTHRESHOLD6;
	m_PropNum = 7;

	m_Prop[PROP_THRES6_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES6_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold6::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES6_LEVEL].RenderVal(x, y);
	k = 6*CLAMP(k);
	int n = (int)k;
	if (n > 5) n = 5;
	m_Prop[n + PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold6::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES6_LEVEL].RenderVal(x, y);
	k = 6*CLAMP(k);
	int n = (int)k;
	if (n > 5) n = 5;
	return m_Prop[n + PROP_SOURCE].RenderVal(x, y);
}

#define PROP_THRES7_LEVEL	7	// property - Threshold (0..1, switch on 0.14,...0.86)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold7::CFilterThreshold7()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold7");
	m_HelpID = HELP_FTHRESHOLD7;
	m_PropNum = 8;

	m_Prop[PROP_THRES7_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES7_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold7::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES7_LEVEL].RenderVal(x, y);
	k = 7*CLAMP(k);
	int n = (int)k;
	if (n > 6) n = 6;
	m_Prop[n + PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold7::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES7_LEVEL].RenderVal(x, y);
	k = 7*CLAMP(k);
	int n = (int)k;
	if (n > 6) n = 6;
	return m_Prop[n + PROP_SOURCE].RenderVal(x, y);
}

#define PROP_THRES8_LEVEL	8	// property - Threshold (0..1, switch on 0.125,...0.875)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold8::CFilterThreshold8()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold8");
	m_HelpID = HELP_FTHRESHOLD8;
	m_PropNum = 9;

	m_Prop[PROP_THRES8_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES8_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold8::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES8_LEVEL].RenderVal(x, y);
	k = 8*CLAMP(k);
	int n = (int)k;
	if (n > 7) n = 7;
	m_Prop[n + PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold8::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES8_LEVEL].RenderVal(x, y);
	k = 8*CLAMP(k);
	int n = (int)k;
	if (n > 7) n = 7;
	return m_Prop[n + PROP_SOURCE].RenderVal(x, y);
}

#define PROP_THRES9_LEVEL	9	// property - Threshold (0..1, switch on 0.11,...0.89)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold9::CFilterThreshold9()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold9");
	m_HelpID = HELP_FTHRESHOLD9;
	m_PropNum = 10;

	m_Prop[PROP_THRES9_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES9_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold9::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES9_LEVEL].RenderVal(x, y);
	k = 9*CLAMP(k);
	int n = (int)k;
	if (n > 8) n = 8;
	m_Prop[n + PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold9::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES9_LEVEL].RenderVal(x, y);
	k = 9*CLAMP(k);
	int n = (int)k;
	if (n > 8) n = 8;
	return m_Prop[n + PROP_SOURCE].RenderVal(x, y);
}

#define PROP_THRES10_LEVEL	10	// property - Threshold (0..1, switch on 0.1,...0.9)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThreshold10::CFilterThreshold10()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Threshold10");
	m_HelpID = HELP_FTHRESHOLD10;
	m_PropNum = 11;

	m_Prop[PROP_THRES10_LEVEL].SetName("Threshold");
	m_Prop[PROP_THRES10_LEVEL].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThreshold10::RenderCol(CColor* col, real x, real y)
{
	real k = m_Prop[PROP_THRES10_LEVEL].RenderVal(x, y);
	k = 10*CLAMP(k);
	int n = (int)k;
	if (n > 9) n = 9;
	m_Prop[n + PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterThreshold10::RenderVal(real x, real y)
{
	real k = m_Prop[PROP_THRES9_LEVEL].RenderVal(x, y);
	k = 10*CLAMP(k);
	int n = (int)k;
	if (n > 9) n = 9;
	return m_Prop[n + PROP_SOURCE].RenderVal(x, y);
}
