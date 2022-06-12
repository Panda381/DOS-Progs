	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Switch Sources
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROP_SWITCH_R	2		// property - SwitchR (0..1; R channel from 0=src1..1=src2)
#define PROP_SWITCH_G	3		// property - SwitchG (0..1; G channel from 0=src1..1=src2)
#define PROP_SWITCH_B	4		// property - SwitchB (0..1; B channel from 0=src1..1=src2)
#define PROP_SWITCH_A	5		// property - SwitchA (0..1; A channel from 0=src1..1=src2)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitchChan::CFilterSwitchChan()
{
	m_Group = FGRP_MUX;
	m_Class = _T("SwitchChan");
	m_HelpID = HELP_FSWITCHCHAN;
	m_PropNum = 6;

	m_Prop[PROP_SWITCH_R].SetName("Red");
	m_Prop[PROP_SWITCH_R].SetValue(0.5);
	m_Prop[PROP_SWITCH_R].SetToolID(ID_PROP_SWITCHR);

	m_Prop[PROP_SWITCH_G].SetName("Green");
	m_Prop[PROP_SWITCH_G].SetValue(0.5);
	m_Prop[PROP_SWITCH_G].SetToolID(ID_PROP_SWITCHG);

	m_Prop[PROP_SWITCH_B].SetName("Blue");
	m_Prop[PROP_SWITCH_B].SetValue(0.5);
	m_Prop[PROP_SWITCH_B].SetToolID(ID_PROP_SWITCHB);

	m_Prop[PROP_SWITCH_A].SetName("Alpha");
	m_Prop[PROP_SWITCH_A].SetValue(0.5);
	m_Prop[PROP_SWITCH_A].SetToolID(ID_PROP_SWITCHA);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitchChan::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real kr = m_Prop[PROP_SWITCH_R].RenderVal(x, y);
	real kg = m_Prop[PROP_SWITCH_G].RenderVal(x, y);
	real kb = m_Prop[PROP_SWITCH_B].RenderVal(x, y);
	real ka = m_Prop[PROP_SWITCH_A].RenderVal(x, y);

	// clamp ranges
	kr = CLAMP(kr);
	kg = CLAMP(kg);
	kb = CLAMP(kb);
	ka = CLAMP(ka);

	// render colors
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_SOURCE2].RenderCol(&c, x, y);

	// combine colors
	col->r = col->r*(1-kr) + c.r*kr;
	col->g = col->g*(1-kg) + c.g*kg;
	col->b = col->b*(1-kb) + c.b*kb;
	col->a = col->a*(1-ka) + c.a*ka;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitchChan::RenderVal(real x, real y)
{
	CColor col;
	CFilterSwitchChan::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch2::CFilterSwitch2()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch2");
	m_HelpID = HELP_FSWITCH2;
	m_PropNum = 3;

	m_Prop[PROP_SWITCH2_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH2_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH2_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch2::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH2_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// render colors
	CColor c;
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[PROP_SOURCE2].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch2::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH2_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// render values
	return m_Prop[PROP_SOURCE].RenderVal(x, y)*(1-k)
		+ m_Prop[PROP_SOURCE2].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch3::CFilterSwitch3()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch3");
	m_HelpID = HELP_FSWITCH3;
	m_PropNum = 4;

	m_Prop[PROP_SWITCH3_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH3_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH3_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch3::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH3_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 2;
	int n = (int)k;
	if (n > 1) n = 1;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[n+1+PROP_SOURCE].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch3::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH3_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 2;
	int n = (int)k;
	if (n > 1) n = 1;
	k -= n;

	// render values
	return m_Prop[n+PROP_SOURCE].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_SOURCE].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch4::CFilterSwitch4()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch4");
	m_HelpID = HELP_FSWITCH4;
	m_PropNum = 5;

	m_Prop[PROP_SWITCH4_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH4_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH4_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch4::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH4_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 3;
	int n = (int)k;
	if (n > 2) n = 2;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[n+1+PROP_SOURCE].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch4::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH4_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 3;
	int n = (int)k;
	if (n > 2) n = 2;
	k -= n;

	// render values
	return m_Prop[n+PROP_SOURCE].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_SOURCE].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch5::CFilterSwitch5()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch5");
	m_HelpID = HELP_FSWITCH5;
	m_PropNum = 6;

	m_Prop[PROP_SWITCH5_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH5_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH5_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch5::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH5_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 4;
	int n = (int)k;
	if (n > 3) n = 3;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[n+1+PROP_SOURCE].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch5::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH5_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 4;
	int n = (int)k;
	if (n > 3) n = 3;
	k -= n;

	// render values
	return m_Prop[n+PROP_SOURCE].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_SOURCE].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch6::CFilterSwitch6()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch6");
	m_HelpID = HELP_FSWITCH6;
	m_PropNum = 7;

	m_Prop[PROP_SWITCH6_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH6_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH6_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch6::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH6_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 5;
	int n = (int)k;
	if (n > 4) n = 4;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[n+1+PROP_SOURCE].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch6::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH6_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 5;
	int n = (int)k;
	if (n > 4) n = 4;
	k -= n;

	// render values
	return m_Prop[n+PROP_SOURCE].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_SOURCE].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch7::CFilterSwitch7()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch7");
	m_HelpID = HELP_FSWITCH7;
	m_PropNum = 8;

	m_Prop[PROP_SWITCH7_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH7_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH7_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch7::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH7_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 6;
	int n = (int)k;
	if (n > 5) n = 5;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[n+1+PROP_SOURCE].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch7::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH7_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 6;
	int n = (int)k;
	if (n > 5) n = 5;
	k -= n;

	// render values
	return m_Prop[n+PROP_SOURCE].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_SOURCE].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch8::CFilterSwitch8()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch8");
	m_HelpID = HELP_FSWITCH8;
	m_PropNum = 9;

	m_Prop[PROP_SWITCH8_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH8_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH8_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch8::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH8_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 7;
	int n = (int)k;
	if (n > 6) n = 6;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[n+1+PROP_SOURCE].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch8::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH8_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 7;
	int n = (int)k;
	if (n > 6) n = 6;
	k -= n;

	// render values
	return m_Prop[n+PROP_SOURCE].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_SOURCE].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch9::CFilterSwitch9()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch9");
	m_HelpID = HELP_FSWITCH9;
	m_PropNum = 10;

	m_Prop[PROP_SWITCH9_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH9_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH9_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch9::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH9_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 8;
	int n = (int)k;
	if (n > 7) n = 7;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[n+1+PROP_SOURCE].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch9::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH9_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 8;
	int n = (int)k;
	if (n > 7) n = 7;
	k -= n;

	// render values
	return m_Prop[n+PROP_SOURCE].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_SOURCE].RenderVal(x, y)*k;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSwitch10::CFilterSwitch10()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Switch10");
	m_HelpID = HELP_FSWITCH10;
	m_PropNum = 11;

	m_Prop[PROP_SWITCH10_SWITCH].SetName("Switch");
	m_Prop[PROP_SWITCH10_SWITCH].SetValue(0.5);
	m_Prop[PROP_SWITCH10_SWITCH].SetToolID(ID_PROP_SWITCH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSwitch10::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH10_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 9;
	int n = (int)k;
	if (n > 8) n = 8;
	k -= n;

	// render colors
	CColor c;
	m_Prop[n+PROP_SOURCE].RenderCol(col, x, y);
	m_Prop[n+1+PROP_SOURCE].RenderCol(&c, x, y);
	col->Trans(c, k);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSwitch10::RenderVal(real x, real y)
{
	// load properties
	real k = m_Prop[PROP_SWITCH10_SWITCH].RenderVal(x, y);
	k = CLAMP(k);

	// get region and remainder
	k *= 9;
	int n = (int)k;
	if (n > 8) n = 8;
	k -= n;

	// render values
	return m_Prop[n+PROP_SOURCE].RenderVal(x, y)*(1-k)
			+ m_Prop[n+1+PROP_SOURCE].RenderVal(x, y)*k;
}
