					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Malachite Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMalachite::CFilterMalachite()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Malachite");
	m_HelpID = HELP_FMALACHITE;
	m_PropNum = 8;

	m_Prop[PROP_SOURCE].SetName("Color1");
	m_Prop[PROP_SOURCE].SetColor((real)7/255, (real)92/255, (real)37/255);

	m_Prop[PROP_SOURCE2].SetName("Color2");
	m_Prop[PROP_SOURCE2].SetColor((real)43/255, (real)240/255, (real)132/255);

	m_Prop[PROP_SOURCE3].SetName("Background");
	m_Prop[PROP_SOURCE3].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_SOURCE3].SetColor((real)44/255, (real)92/255, (real)56/255);

	m_Prop[PROP_MALACH_ROUGH].SetName("Roughness");
	m_Prop[PROP_MALACH_ROUGH].SetMaxVal((real)0.7);
	m_Prop[PROP_MALACH_ROUGH].SetUserValue(50);
	m_Prop[PROP_MALACH_ROUGH].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_MALACH_SCALE].SetName("Scale");
	m_Prop[PROP_MALACH_SCALE].SetMinVal((real)0.3);
	m_Prop[PROP_MALACH_SCALE].SetUserValue(40);
	m_Prop[PROP_MALACH_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_MALACH_RINGS].SetName("Rings");
	m_Prop[PROP_MALACH_RINGS].SetMinVal((real)-0.2);
	m_Prop[PROP_MALACH_RINGS].SetMaxVal((real)1.2);
	m_Prop[PROP_MALACH_RINGS].SetUserValue((real)70);
	m_Prop[PROP_MALACH_RINGS].SetToolID(ID_PROP_MALACHRINGS);

	m_Prop[PROP_MALACH_DENSITY].SetName("Density");
	m_Prop[PROP_MALACH_DENSITY].SetValue((real)0.3);
	m_Prop[PROP_MALACH_DENSITY].SetToolID(ID_PROP_MALACHDENS);

	m_Prop[PROP_MALACH_SEED].SetName("Seed");
	m_Prop[PROP_MALACH_SEED].SetMax(1000);
	m_Prop[PROP_MALACH_SEED].SetToolID(ID_PROP_SEED);

	m_Perlin.Prop(PROP_NOISE_DETAILS)->SetValue(1);
	m_Perlin.Prop(PROP_NOISE_CONTRAST)->SetValue((real)0.45);
	m_Noise.Prop(PROP_CURNOI_DETAILS)->SetValue(1);
	m_Threshold.Prop(PROP_THRES_TOLERANCE)->SetValue((real)0.05);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMalachite::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Perlin.Prop(PROP_NOISE_ROUGHNESS)->CopyLink(&m_Prop[PROP_MALACH_ROUGH]);
		m_Perlin.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_MALACH_SCALE]);
		m_Perlin.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_MALACH_SEED]);

		m_Noise.Prop(PROP_CURNOI_SCALE)->CopyLink(&m_Prop[PROP_MALACH_DENSITY]);
		m_Noise.Prop(PROP_CURNOI_SEED)->CopyLink(&m_Prop[PROP_MALACH_SEED]);

		m_Colorize.Prop(PROP_SOURCE)->SetFilter(&m_Perlin);
		m_Colorize.Prop(PROP_COLORIZE_GRADIENT)->SetFilter(&m_Noise);

		m_Switch21.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Switch21.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Switch21.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Colorize);

		m_Threshold.Prop(PROP_SOURCE)->SetFilter(&m_Perlin);
		m_Threshold.Prop(PROP_THRES_LEVEL)->CopyLink(&m_Prop[PROP_MALACH_RINGS]);

		m_Switch22.Prop(PROP_SOURCE)->SetFilter(&m_Switch21);
		m_Switch22.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE3]);
		m_Switch22.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Threshold);
	}

	m_Switch22.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMalachite::RenderVal(real x, real y)
{
	CColor col;
	CFilterMalachite::RenderCol(&col, x, y);
	return col.Gray();
}
