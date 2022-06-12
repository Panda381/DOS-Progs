					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Tussock Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTussock::CFilterTussock()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Tussock");
	m_HelpID = HELP_FTUSSOCK;
	m_PropNum = 15;

	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetColor((real)86/255, (real)166/255, (real)60/255);

	m_Prop[PROP_TUSSOCK_RNDCOLOR].SetName("RndColor");
	m_Prop[PROP_TUSSOCK_RNDCOLOR].SetMinVal((real)0.5);
	m_Prop[PROP_TUSSOCK_RNDCOLOR].SetUserValue(5);
	m_Prop[PROP_TUSSOCK_RNDCOLOR].SetToolID(ID_PROP_TUSRNDCOL);

	m_Prop[PROP_TUSSOCK_SIZE].SetName("Size");
	m_Prop[PROP_TUSSOCK_SIZE].SetMaxVal((real)0.5);
	m_Prop[PROP_TUSSOCK_SIZE].SetValue((real)0.5);
	m_Prop[PROP_TUSSOCK_SIZE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_TUSSOCK_RNDSIZE].SetName("RndSize");
	m_Prop[PROP_TUSSOCK_RNDSIZE].SetMinVal((real)0.5);
	m_Prop[PROP_TUSSOCK_RNDSIZE].SetMaxVal(0);
	m_Prop[PROP_TUSSOCK_RNDSIZE].SetUserValue(70);
	m_Prop[PROP_TUSSOCK_RNDSIZE].SetToolID(ID_PROP_TUSRNDSIZE);

	m_Prop[PROP_TUSSOCK_CONTRAST].SetName("Contrast");
	m_Prop[PROP_TUSSOCK_CONTRAST].SetMinVal((real)0.5);
	m_Prop[PROP_TUSSOCK_CONTRAST].SetUserValue(30);
	m_Prop[PROP_TUSSOCK_CONTRAST].SetToolID(ID_PROP_CONTRAST2);

	m_Prop[PROP_TUSSOCK_FIBERS].SetName("Fibers");
	m_Prop[PROP_TUSSOCK_FIBERS].SetMinVal((real)0.2);
	m_Prop[PROP_TUSSOCK_FIBERS].SetUserValue(25);
	m_Prop[PROP_TUSSOCK_FIBERS].SetToolID(ID_PROP_WOODFIBERS);

	m_Prop[PROP_TUSSOCK_WIDTH].SetName("Width");
	m_Prop[PROP_TUSSOCK_WIDTH].SetValue((real)0.04);
	m_Prop[PROP_TUSSOCK_WIDTH].SetToolID(ID_PROP_BLADEWIDTH);

	m_Prop[PROP_TUSSOCK_WARP].SetName("Warp");
	m_Prop[PROP_TUSSOCK_WARP].SetMinVal((real)0.5);
	m_Prop[PROP_TUSSOCK_WARP].SetMaxVal((real)0.7);
	m_Prop[PROP_TUSSOCK_WARP].SetUserValue(30);
	m_Prop[PROP_TUSSOCK_WARP].SetToolID(ID_PROP_BLADEWARP);

	m_Prop[PROP_TUSSOCK_LIGHT].SetName("Light");
	m_Prop[PROP_TUSSOCK_LIGHT].SetMin(-50);
	m_Prop[PROP_TUSSOCK_LIGHT].SetMax(50);
	m_Prop[PROP_TUSSOCK_LIGHT].SetUserValue(-5);
	m_Prop[PROP_TUSSOCK_LIGHT].SetToolID(ID_PROP_LTINTENS);

	m_Prop[PROP_TUSSOCK_COUNT].SetName("Count");
	m_Prop[PROP_TUSSOCK_COUNT].SetMin(1);
	m_Prop[PROP_TUSSOCK_COUNT].SetMinVal((real)0.01);
	m_Prop[PROP_TUSSOCK_COUNT].SetUserValue(50);
	m_Prop[PROP_TUSSOCK_COUNT].SetToolID(ID_PROP_TUSCOUNT);

	m_Prop[PROP_TUSSOCK_RANGE].SetName("Range");
	m_Prop[PROP_TUSSOCK_RANGE].SetMinVal((real)0.5);
	m_Prop[PROP_TUSSOCK_RANGE].SetUserValue(40);
	m_Prop[PROP_TUSSOCK_RANGE].SetToolID(ID_PROP_TUSRANGE);

	m_Prop[PROP_TUSSOCK_FAN].SetName("Fan");
	m_Prop[PROP_TUSSOCK_FAN].SetMinVal((real)0.5);
	m_Prop[PROP_TUSSOCK_FAN].SetMaxVal((real)0.75);
	m_Prop[PROP_TUSSOCK_FAN].SetUserValue(15);
	m_Prop[PROP_TUSSOCK_FAN].SetToolID(ID_PROP_TUSFAN);

	m_Prop[PROP_TUSSOCK_SHADOWS].SetName("Shadows");
	m_Prop[PROP_TUSSOCK_SHADOWS].SetValue((real)0.2);
	m_Prop[PROP_TUSSOCK_SHADOWS].SetToolID(ID_PROP_TUSSHADOWS);

	m_Prop[PROP_TUSSOCK_SHDWSHFT].SetName("ShdwShft");
	m_Prop[PROP_TUSSOCK_SHDWSHFT].SetMinVal((real)0.5);
	m_Prop[PROP_TUSSOCK_SHDWSHFT].SetMaxVal((real)0.6);
	m_Prop[PROP_TUSSOCK_SHDWSHFT].SetUserValue(30);
	m_Prop[PROP_TUSSOCK_SHDWSHFT].SetToolID(ID_PROP_TUSSHDWSHFT);

	m_Prop[PROP_TUSSOCK_VARIANT].SetName("Seed");
	m_Prop[PROP_TUSSOCK_VARIANT].SetMax(1000);
	m_Prop[PROP_TUSSOCK_VARIANT].SetToolID(ID_PROP_SEED);

	m_LoopBegin.Prop(PROP_SOURCE)->SetColor(0,0,0,0);
	m_Add1.Prop(PROP_SOURCE2)->SetValue((real)0.1);
	m_Blade1.Prop(PROP_SOURCE)->SetValue(0);
	m_Blade1.Prop(PROP_SOURCE2)->SetColor(1, 1, 1, 0);
	m_Blade1.Prop(PROP_BLADE_CONTR)->SetUserValue(0);
	m_Blade1.Prop(PROP_BLADE_FIBERS)->SetUserValue(0);
	m_Blade1.Prop(PROP_BLADE_LIGHT)->SetUserValue(0);
	m_Blend.Prop(PROP_BLEND_MODE)->SetUserValue(1);
	m_Blend.Prop(PROP_BLEND_ALPHAMOD)->SetValue(1);
	m_Add3.Prop(PROP_SOURCE2)->SetValue((real)0.2);
	m_Random3.Prop(PROP_RAND_MAX)->SetUserValue(50);
	m_Rotate.Prop(PROP_ROT_Y)->SetValue(0);
	m_Scale.Prop(PROP_SCALE_Y)->SetValue(0);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTussock::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_LoopBegin.Prop(PROP_LOOP_END)->SetFilter(&m_LoopEnd);
		m_LoopBegin.Prop(PROP_LOOP_NUM)->CopyLink(&m_Prop[PROP_TUSSOCK_COUNT]);

		m_Invert1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_TUSSOCK_RNDCOLOR]);

		m_Add1.Prop(PROP_SOURCE)->SetFilter(&m_Add2);

		m_Blade1.Prop(PROP_BLADE_WIDTH)->CopyLink(&m_Prop[PROP_TUSSOCK_WIDTH]);
		m_Blade1.Prop(PROP_BLADE_WARP)->CopyLink(&m_Prop[PROP_TUSSOCK_WARP]);
		m_Blade1.Prop(PROP_BLADE_SEED)->SetFilter(&m_Add2);

		m_LoopIndex.Prop(PROP_SOURCE)->SetFilter(&m_LoopBegin);

		m_Invert2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_TUSSOCK_SHDWSHFT]);

		m_Random1.Prop(PROP_RAND_MIN)->SetFilter(&m_Invert1);
		m_Random1.Prop(PROP_RAND_MAX)->CopyLink(&m_Prop[PROP_TUSSOCK_RNDCOLOR]);
		m_Random1.Prop(PROP_RAND_SEED)->SetFilter(&m_Add1);

		m_Shift1.Prop(PROP_SOURCE)->SetFilter(&m_Blade1);
		m_Shift1.Prop(PROP_SHIFT_X)->CopyLink(&m_Prop[PROP_TUSSOCK_SHDWSHFT]);
		m_Shift1.Prop(PROP_SHIFT_Y)->SetFilter(&m_Invert2);

		m_Add2.Prop(PROP_SOURCE)->SetFilter(&m_LoopIndex);
		m_Add2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_TUSSOCK_VARIANT]);

		m_Recolor.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Recolor.Prop(PROP_COLOR_HUE)->SetFilter(&m_Random1);

		m_Blend.Prop(PROP_SOURCE)->SetFilter(&m_LoopBegin);
		m_Blend.Prop(PROP_SOURCE2)->SetFilter(&m_Shift1);
		m_Blend.Prop(PROP_BLEND_OPACITY)->CopyLink(&m_Prop[PROP_TUSSOCK_SHADOWS]);

		m_Invert3.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_TUSSOCK_RANGE]);

		m_Add3.Prop(PROP_SOURCE)->SetFilter(&m_Add2);

		m_Invert4.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_TUSSOCK_FAN]);

		m_Blade2.Prop(PROP_SOURCE)->SetFilter(&m_Recolor);
		m_Blade2.Prop(PROP_BLADE_BACK)->SetFilter(&m_Blend);
		m_Blade2.Prop(PROP_BLADE_CONTR)->CopyLink(&m_Prop[PROP_TUSSOCK_CONTRAST]);
		m_Blade2.Prop(PROP_BLADE_FIBERS)->CopyLink(&m_Prop[PROP_TUSSOCK_FIBERS]);
		m_Blade2.Prop(PROP_BLADE_WIDTH)->CopyLink(&m_Prop[PROP_TUSSOCK_WIDTH]);
		m_Blade2.Prop(PROP_BLADE_WARP)->CopyLink(&m_Prop[PROP_TUSSOCK_WARP]);
		m_Blade2.Prop(PROP_BLADE_LIGHT)->CopyLink(&m_Prop[PROP_TUSSOCK_LIGHT]);
		m_Blade2.Prop(PROP_BLADE_SEED)->SetFilter(&m_Add2);

		m_Random2.Prop(PROP_RAND_MIN)->SetFilter(&m_Invert3);
		m_Random2.Prop(PROP_RAND_MAX)->CopyLink(&m_Prop[PROP_TUSSOCK_RANGE]);
		m_Random2.Prop(PROP_RAND_SEED)->SetFilter(&m_Add2);

		m_Random3.Prop(PROP_RAND_MIN)->CopyLink(&m_Prop[PROP_TUSSOCK_RNDSIZE]);
		m_Random3.Prop(PROP_RAND_SEED)->SetFilter(&m_Add3);

		m_Random4.Prop(PROP_RAND_MIN)->CopyLink(&m_Prop[PROP_TUSSOCK_FAN]);
		m_Random4.Prop(PROP_RAND_MAX)->SetFilter(&m_Invert4);
		m_Random4.Prop(PROP_RAND_SEED)->SetFilter(&m_Add2);

		m_Rotate.Prop(PROP_SOURCE)->SetFilter(&m_Blade2);
		m_Rotate.Prop(PROP_ROT_ANGLE)->SetFilter(&m_Random4);

		m_Shift2.Prop(PROP_SOURCE)->SetFilter(&m_Rotate);
		m_Shift2.Prop(PROP_SHIFT_X)->SetFilter(&m_Random2);

		m_Scale.Prop(PROP_SOURCE)->SetFilter(&m_Shift2);
		m_Scale.Prop(PROP_SCALE_SCALE)->CopyLink(&m_Prop[PROP_TUSSOCK_SIZE]);
		m_Scale.Prop(PROP_SCALE_STRETCHY)->SetFilter(&m_Random3);

		m_LoopEnd.Prop(PROP_SOURCE)->SetFilter(&m_Scale);

		m_Cut.Prop(PROP_SOURCE)->SetFilter(&m_LoopEnd);

		m_LoopBegin.Restart();
		m_Blade1.Restart();
		m_Blade2.Restart();
		m_LoopEnd.Restart();
	}

	m_Cut.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTussock::RenderVal(real x, real y)
{
	CColor col;
	CFilterTussock::RenderCol(&col, x, y);
	return col.Gray();
}
