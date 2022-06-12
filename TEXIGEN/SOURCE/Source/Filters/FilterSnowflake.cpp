	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                              Snowflake Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSnowflake::CFilterSnowflake()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Snowflake");
	m_HelpID = HELP_FSNOWFLAKE;
	m_PropNum = 5;

	m_Prop[PROP_SOURCE].SetName("LightColor");
	m_Prop[PROP_SOURCE].SetColor(1,1,1,1);

	m_Prop[PROP_SOURCE2].SetName("DarkColor");
	m_Prop[PROP_SOURCE2].SetColor((real)128/255, (real)128/255, (real)128/255);

	m_Prop[PROP_SOURCE3].SetName("Background");

	m_Prop[PROP_SNOW_ROUGH].SetName("Roughness");
	m_Prop[PROP_SNOW_ROUGH].SetMinVal((real)0.5);
	m_Prop[PROP_SNOW_ROUGH].SetUserValue(50);
	m_Prop[PROP_SNOW_ROUGH].SetToolID(ID_PROP_ROUGHNESS2);

	m_Prop[PROP_SNOW_SEED].SetName("Seed");
	m_Prop[PROP_SNOW_SEED].SetMax(1000);
	m_Prop[PROP_SNOW_SEED].SetToolID(ID_PROP_SEED);

	m_Add.Prop(PROP_SOURCE2)->SetValue((real)0.01);

	m_Perlin1.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.1);
	m_Perlin1.Prop(PROP_NOISE_CONTRAST)->SetValue((real)0.45);
	m_Perlin1.Prop(PROP_NOISE_BRIGHT)->SetValue((real)0.4);
	m_Perlin1.Prop(PROP_NOISE_SQUEEZE)->SetUserValue(-20);
	m_Perlin1.Prop(PROP_NOISE_ANGLE)->SetUserValue(-30);

	m_Perlin2.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.1);
	m_Perlin2.Prop(PROP_NOISE_CONTRAST)->SetValue((real)0.45);
	m_Perlin2.Prop(PROP_NOISE_BRIGHT)->SetValue((real)0.4);
	m_Perlin2.Prop(PROP_NOISE_SQUEEZE)->SetUserValue(-20);
	m_Perlin2.Prop(PROP_NOISE_ANGLE)->SetUserValue(30);

	m_Blend1.Prop(PROP_BLEND_MODE)->SetValue((real)0.06);

	m_Perlin3.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.2);
	m_Perlin3.Prop(PROP_NOISE_CONTRAST)->SetValue((real)0.45);
	m_Perlin3.Prop(PROP_NOISE_BRIGHT)->SetValue((real)0.4);
	m_Perlin3.Prop(PROP_NOISE_SCALE)->SetValue((real)0.5);

	m_Blend2.Prop(PROP_BLEND_MODE)->SetValue((real)0.06);

	m_Bias1.Prop(PROP_CURVE_BEG)->SetValue((real)0.7);
	m_Bias1.Prop(PROP_CURBIAS_BIAS)->SetUserValue(35);

	m_Bias2.Prop(PROP_CURBIAS_BIAS)->SetUserValue(40);

	m_Round.Prop(PROP_BOX_WIDTH)->SetValue((real)0.5);
	m_Round.Prop(PROP_BOX_HEIGHT)->SetValue((real)0.5);
	m_Round.Prop(PROP_BOX_BEVEL)->SetValue((real)0.1);

	m_Level.Prop(PROP_LEVEL_CONTRAST)->SetValue((real)0.85);
	m_Level.Prop(PROP_LEVEL_GAMMA)->SetValue((real)0.7);

	m_Rotate1.Prop(PROP_ROT_ANGLE)->SetUserValue(60);

	m_Threshold.Prop(PROP_THRES_LEVEL)->SetValue((real)0.01);

	m_Rotate2.Prop(PROP_ROT_ANGLE)->SetUserValue(120);

	m_Blend3.Prop(PROP_BLEND_MODE)->SetValue((real)0.06);

	m_Blend4.Prop(PROP_BLEND_MODE)->SetValue((real)0.06);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSnowflake::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Add.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SNOW_SEED]);

		m_Perlin1.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_SNOW_ROUGH]);
		m_Perlin1.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add);

		m_Perlin2.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_SNOW_ROUGH]);
		m_Perlin2.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_SNOW_SEED]);

		m_Blend1.Prop(PROP_SOURCE)->SetFilter(&m_Perlin1);
		m_Blend1.Prop(PROP_SOURCE2)->SetFilter(&m_Perlin2);

		m_Perlin3.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_SNOW_SEED]);

		m_Blend2.Prop(PROP_SOURCE)->SetFilter(&m_Blend1);
		m_Blend2.Prop(PROP_SOURCE2)->SetFilter(&m_Perlin3);

		m_Mul1.Prop(PROP_SOURCE)->SetFilter(&m_Bias1);
		m_Mul1.Prop(PROP_SOURCE2)->SetFilter(&m_Rotate90);

		m_Rotate90.Prop(PROP_SOURCE)->SetFilter(&m_Bias2);

		m_Mul2.Prop(PROP_SOURCE)->SetFilter(&m_Blend2);
		m_Mul2.Prop(PROP_SOURCE2)->SetFilter(&m_Mul1);

		m_Round.Prop(PROP_SOURCE)->SetFilter(&m_Blend4);

		m_Mirror.Prop(PROP_SOURCE)->SetFilter(&m_Mul2);

		m_Level.Prop(PROP_SOURCE)->SetFilter(&m_Round);

		m_Rotate1.Prop(PROP_SOURCE)->SetFilter(&m_Mirror);

		m_Threshold.Prop(PROP_SOURCE)->SetFilter(&m_Level);

		m_Switch2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Switch2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Switch2.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Level);

		m_Rotate2.Prop(PROP_SOURCE)->SetFilter(&m_Mirror);

		m_Blend3.Prop(PROP_SOURCE)->SetFilter(&m_Mirror);
		m_Blend3.Prop(PROP_SOURCE2)->SetFilter(&m_Rotate1);

		m_Threshold2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE3]);
		m_Threshold2.Prop(PROP_SOURCE2)->SetFilter(&m_Switch2);
		m_Threshold2.Prop(PROP_THRES2_LEVEL)->SetFilter(&m_Threshold);

		m_Blend4.Prop(PROP_SOURCE)->SetFilter(&m_Rotate2);
		m_Blend4.Prop(PROP_SOURCE2)->SetFilter(&m_Blend3);

		m_Cut.Prop(PROP_SOURCE)->SetFilter(&m_Threshold2);
		m_Cut.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE3]);
	}

	m_Cut.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSnowflake::RenderVal(real x, real y)
{
	CColor col;
	CFilterSnowflake::RenderCol(&col, x, y);
	return col.Gray();
}
