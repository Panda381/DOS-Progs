					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Rose Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBlade::CFilterBlade()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Blade");
	m_HelpID = HELP_FBLADE;
	m_PropNum = 8;

	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetColor((real)107/255, (real)155/255, (real)60/255);

	m_Prop[PROP_BLADE_BACK].SetName("Background");
	m_Prop[PROP_BLADE_BACK].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_BLADE_BACK].SetColor(0,0,0,0);

	m_Prop[PROP_BLADE_CONTR].SetName("Contrast");
	m_Prop[PROP_BLADE_CONTR].SetMinVal((real)0.5);
	m_Prop[PROP_BLADE_CONTR].SetUserValue(30);
	m_Prop[PROP_BLADE_CONTR].SetToolID(ID_PROP_CONTRAST2);

	m_Prop[PROP_BLADE_FIBERS].SetName("Fibers");
	m_Prop[PROP_BLADE_FIBERS].SetMinVal((real)0.2);
	m_Prop[PROP_BLADE_FIBERS].SetUserValue(25);
	m_Prop[PROP_BLADE_FIBERS].SetToolID(ID_PROP_WOODFIBERS);

	m_Prop[PROP_BLADE_WIDTH].SetName("Width");
	m_Prop[PROP_BLADE_WIDTH].SetValue((real)0.06);
	m_Prop[PROP_BLADE_WIDTH].SetToolID(ID_PROP_BLADEWIDTH);

	m_Prop[PROP_BLADE_WARP].SetName("Warp");
	m_Prop[PROP_BLADE_WARP].SetMinVal((real)0.5);
	m_Prop[PROP_BLADE_WARP].SetMaxVal((real)0.7);
	m_Prop[PROP_BLADE_WARP].SetUserValue(50);
	m_Prop[PROP_BLADE_WARP].SetToolID(ID_PROP_BLADEWARP);

	m_Prop[PROP_BLADE_LIGHT].SetName("Light");
	m_Prop[PROP_BLADE_LIGHT].SetMin(-50);
	m_Prop[PROP_BLADE_LIGHT].SetMax(50);
	m_Prop[PROP_BLADE_LIGHT].SetValue((real)0.55);
	m_Prop[PROP_BLADE_LIGHT].SetToolID(ID_PROP_LTINTENS);

	m_Prop[PROP_BLADE_SEED].SetName("Seed");
	m_Prop[PROP_BLADE_SEED].SetMax(1000);
	m_Prop[PROP_BLADE_SEED].SetToolID(ID_PROP_SEED);

	m_Stairs.Prop(PROP_CURSTAIRS_STEPS)->SetValue((real)0.01);
	m_Noise1.Prop(PROP_CURNOI_DETAILS)->SetValue((real)0.1);
	m_Bezier2.Prop(PROP_BEZIER2_A1)->SetValue(1);
	m_Bezier2.Prop(PROP_BEZIER2_X2)->SetUserValue(75);
	m_Noise2.Prop(PROP_CURVE_BEG)->SetValue(-1);
	m_Noise2.Prop(PROP_CURNOI_DETAILS)->SetValue((real)0.2);
	m_Noise2.Prop(PROP_CURNOI_SCALE)->SetValue(1);
	m_Arc.Prop(PROP_CURVE_BEG)->SetValue(1);
	m_Arc.Prop(PROP_CURVE_END)->SetValue(0);
	m_Inject.Prop(PROP_INJECT_HEIGHT)->SetValue(1);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterBlade::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Stairs.Prop(PROP_CURVE_MIN)->SetFilter(&m_Invert3);
		m_Stairs.Prop(PROP_CURVE_MAX)->CopyLink(&m_Prop[PROP_BLADE_LIGHT]);

		m_Invert1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_BLADE_CONTR]);

		m_Invert2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_BLADE_WARP]);

		m_Invert3.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_BLADE_LIGHT]);

		m_Bright.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Bright.Prop(PROP_BRIGHT_BRIGHT)->SetFilter(&m_Stairs);

		m_Noise1.Prop(PROP_CURVE_MIN)->SetFilter(&m_Invert1);
		m_Noise1.Prop(PROP_CURVE_MAX)->CopyLink(&m_Prop[PROP_BLADE_CONTR]);
		m_Noise1.Prop(PROP_CURNOI_SCALE)->CopyLink(&m_Prop[PROP_BLADE_FIBERS]);
		m_Noise1.Prop(PROP_CURNOI_SEED)->CopyLink(&m_Prop[PROP_BLADE_SEED]);

		m_Bright2.Prop(PROP_SOURCE)->SetFilter(&m_Bright);
		m_Bright2.Prop(PROP_BRIGHT_BRIGHT)->SetFilter(&m_Noise1);

		m_Mul.Prop(PROP_SOURCE)->SetFilter(&m_Bezier2);
		m_Mul.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_BLADE_WIDTH]);

		m_Noise2.Prop(PROP_CURVE_MIN)->SetFilter(&m_Invert2);
		m_Noise2.Prop(PROP_CURVE_MAX)->CopyLink(&m_Prop[PROP_BLADE_WARP]);
		m_Noise2.Prop(PROP_CURNOI_SEED)->CopyLink(&m_Prop[PROP_BLADE_SEED]);

		m_Rotate270.Prop(PROP_SOURCE)->SetFilter(&m_Mul);

		m_Level.Prop(PROP_SOURCE)->SetFilter(&m_Noise2);
		m_Level.Prop(PROP_LEVEL_CONTRAST)->SetFilter(&m_Arc);

		m_Inject.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_BLADE_BACK]);
		m_Inject.Prop(PROP_SOURCE2)->SetFilter(&m_Bright2);
		m_Inject.Prop(PROP_INJECT_WIDTH)->SetFilter(&m_Rotate270);
		m_Inject.Prop(PROP_INJECT_SHIFTX)->SetFilter(&m_Rotate2702);

		m_Rotate2702.Prop(PROP_SOURCE)->SetFilter(&m_Level);

		m_Cut.Prop(PROP_SOURCE)->SetFilter(&m_Inject);
		m_Cut.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_BLADE_BACK]);
	}

	m_Cut.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBlade::RenderVal(real x, real y)
{
	CColor col;
	CFilterBlade::RenderCol(&col, x, y);
	return col.Gray();
}
