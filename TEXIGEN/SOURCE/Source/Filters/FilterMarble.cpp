					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Marble Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMarble::CFilterMarble()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Marble");
	m_HelpID = HELP_FMARBLE;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetName("Color1");
	m_Prop[PROP_SOURCE].SetColor((real)98/255, (real)143/255, (real)121/255);

	m_Prop[PROP_SOURCE2].SetName("Color2");
	m_Prop[PROP_SOURCE2].SetColor((real)187/255, (real)219/255, (real)203/255);

	m_Prop[PROP_MARBLE_BIAS].SetName("Gamma");
	m_Prop[PROP_MARBLE_BIAS].SetValue((real)0.7);
	m_Prop[PROP_MARBLE_BIAS].SetToolID(ID_PROP_GAMMA);

	m_Prop[PROP_MARBLE_SCALE].SetName("Scale");
	m_Prop[PROP_MARBLE_SCALE].SetValue((real)0.7);
	m_Prop[PROP_MARBLE_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_MARBLE_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_MARBLE_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_MARBLE_SQUEEZE].SetMin(-50);
	m_Prop[PROP_MARBLE_SQUEEZE].SetMax(50);
	m_Prop[PROP_MARBLE_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);

	m_Prop[PROP_MARBLE_WARP].SetName("Warp");
	m_Prop[PROP_MARBLE_WARP].SetMaxVal((real)0.5);
	m_Prop[PROP_MARBLE_WARP].SetUserValue(40);
	m_Prop[PROP_MARBLE_WARP].SetToolID(ID_PROP_WARP);

	m_Prop[PROP_MARBLE_DETAILS].SetName("Details");
	m_Prop[PROP_MARBLE_DETAILS].SetMinVal((real)0.1);
	m_Prop[PROP_MARBLE_DETAILS].SetMin(1);
	m_Prop[PROP_MARBLE_DETAILS].SetMax(10);
	m_Prop[PROP_MARBLE_DETAILS].SetValue(1);
	m_Prop[PROP_MARBLE_DETAILS].SetToolID(ID_PROP_DETAILS);

	m_Prop[PROP_MARBLE_ROUGH].SetName("Roughness");
	m_Prop[PROP_MARBLE_ROUGH].SetMaxVal((real)0.5);
	m_Prop[PROP_MARBLE_ROUGH].SetUserValue(90);
	m_Prop[PROP_MARBLE_ROUGH].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_MARBLE_SMUDGES].SetName("Smudges");
	m_Prop[PROP_MARBLE_SMUDGES].SetValue((real)0.4);
	m_Prop[PROP_MARBLE_SMUDGES].SetToolID(ID_PROP_MARSMUDGES);

	m_Prop[PROP_MARBLE_SEED].SetName("Seed");
	m_Prop[PROP_MARBLE_SEED].SetMax(1000);
	m_Prop[PROP_MARBLE_SEED].SetValue((real)0.001);
	m_Prop[PROP_MARBLE_SEED].SetToolID(ID_PROP_SEED);

	m_Cellular.Prop(PROP_CELLULAR_ROUGHNESS)->SetValue((real)0.5);
	m_Perlin1.Prop(PROP_NOISE_SCALE)->SetValue((real)0.6);
	m_Perlin2.Prop(PROP_NOISE_SCALE)->SetValue((real)0.6);
	m_Add1.Prop(PROP_SOURCE2)->SetValue((real)0.01);
	m_Mul1.Prop(PROP_SOURCE2)->SetValue(2);
	m_Mul2.Prop(PROP_SOURCE2)->SetValue(2);
	m_Add2.Prop(PROP_SOURCE2)->SetValue((real)0.02);
	m_Perlin3.Prop(PROP_NOISE_SCALE)->SetValue((real)0.6);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMarble::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Cellular.Prop(PROP_CELLULAR_SCALE)->CopyLink(&m_Prop[PROP_MARBLE_SCALE]);
		m_Cellular.Prop(PROP_CELLULAR_SQUEEZE)->CopyLink(&m_Prop[PROP_MARBLE_SQUEEZE]);
		m_Cellular.Prop(PROP_CELLULAR_PROFILE)->SetFilter(&m_Bias);
		m_Cellular.Prop(PROP_CELLULAR_SEED)->CopyLink(&m_Prop[PROP_MARBLE_SEED]);

		m_Perlin1.Prop(PROP_NOISE_DETAILS)->CopyLink(&m_Prop[PROP_MARBLE_DETAILS]);
		m_Perlin1.Prop(PROP_NOISE_ROUGHNESS)->CopyLink(&m_Prop[PROP_MARBLE_ROUGH]);
		m_Perlin1.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_MARBLE_WARP]);
		m_Perlin1.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_MARBLE_SEED]);

		m_Perlin2.Prop(PROP_NOISE_DETAILS)->CopyLink(&m_Prop[PROP_MARBLE_DETAILS]);
		m_Perlin2.Prop(PROP_NOISE_ROUGHNESS)->CopyLink(&m_Prop[PROP_MARBLE_ROUGH]);
		m_Perlin2.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_MARBLE_WARP]);
		m_Perlin2.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add1);

		m_Bias.Prop(PROP_CURBIAS_BIAS)->CopyLink(&m_Prop[PROP_MARBLE_BIAS]);

		m_Add1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_MARBLE_SEED]);

		m_Mul1.Prop(PROP_SOURCE)->SetFilter(&m_Perlin1);

		m_Mul2.Prop(PROP_SOURCE)->SetFilter(&m_Perlin2);

		m_Shift.Prop(PROP_SOURCE)->SetFilter(&m_Cellular);
		m_Shift.Prop(PROP_SHIFT_X)->SetFilter(&m_Mul1);
		m_Shift.Prop(PROP_SHIFT_Y)->SetFilter(&m_Mul2);

		m_Switch2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Switch2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Switch2.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Shift);

		m_Add2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_MARBLE_SEED]);

		m_Perlin3.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_MARBLE_SMUDGES]);
		m_Perlin3.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add2);

		m_Level.Prop(PROP_SOURCE)->SetFilter(&m_Switch2);
		m_Level.Prop(PROP_LEVEL_GAMMA)->SetFilter(&m_Perlin3);
	}

	m_Level.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMarble::RenderVal(real x, real y)
{
	CColor col;
	CFilterMarble::RenderCol(&col, x, y);
	return col.Gray();
}
