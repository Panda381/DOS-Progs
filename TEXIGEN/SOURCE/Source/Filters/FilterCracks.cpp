					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Cracks Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterCracks::CFilterCracks()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Cracks");
	m_HelpID = HELP_FCRACKS;
	m_PropNum = 9;

	m_Prop[PROP_SOURCE].SetName("Color");

	m_Prop[PROP_SOURCE2].SetName("Background");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_SOURCE2].SetValue(1);

	m_Prop[PROP_CRACKS_ROUGH].SetName("Roughness");
	m_Prop[PROP_CRACKS_ROUGH].SetMaxVal((real)0.5);
	m_Prop[PROP_CRACKS_ROUGH].SetUserValue(80);
	m_Prop[PROP_CRACKS_ROUGH].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_CRACKS_THIN].SetName("Thin");
	m_Prop[PROP_CRACKS_THIN].SetMinVal((real)5);
	m_Prop[PROP_CRACKS_THIN].SetMaxVal((real)100);
	m_Prop[PROP_CRACKS_THIN].SetUserValue(12);
	m_Prop[PROP_CRACKS_THIN].SetToolID(ID_PROP_CRACKSTHIN);

	m_Prop[PROP_CRACKS_SCALE].SetName("Scale");
	m_Prop[PROP_CRACKS_SCALE].SetValue((real)0.7);
	m_Prop[PROP_CRACKS_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_CRACKS_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_CRACKS_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_CRACKS_SQUEEZE].SetMin(-50);
	m_Prop[PROP_CRACKS_SQUEEZE].SetMax(50);
	m_Prop[PROP_CRACKS_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);

	m_Prop[PROP_CRACKS_LAYERS].SetName("Layers");
	m_Prop[PROP_CRACKS_LAYERS].SetMinVal((real)0.01);
	m_Prop[PROP_CRACKS_LAYERS].SetMaxVal((real)0.1);
	m_Prop[PROP_CRACKS_LAYERS].SetMin(1);
	m_Prop[PROP_CRACKS_LAYERS].SetMax(10);
	m_Prop[PROP_CRACKS_LAYERS].SetUserValue((real)2);
	m_Prop[PROP_CRACKS_LAYERS].SetToolID(ID_PROP_CRACKSLAYERS);

	m_Prop[PROP_CRACKS_LEVEL].SetName("Level");
	m_Prop[PROP_CRACKS_LEVEL].SetValue((real)0.5);
	m_Prop[PROP_CRACKS_LEVEL].SetToolID(ID_PROP_CRACKSLEVEL);

	m_Prop[PROP_CRACKS_SEED].SetName("Seed");
	m_Prop[PROP_CRACKS_SEED].SetMax(1000);
	m_Prop[PROP_CRACKS_SEED].SetToolID(ID_PROP_SEED);

	m_LoopBegin.Prop(PROP_SOURCE)->SetValue(1);
	m_Add2.Prop(PROP_SOURCE2)->SetValue((real)0.01);
	m_Perlin1.Prop(PROP_NOISE_DETAILS)->SetValue(1);
	m_Perlin2.Prop(PROP_NOISE_SCALE)->SetValue((real)0.6);
	m_Blend.Prop(PROP_BLEND_MODE)->SetValue((real)0.01);
	m_Interval.Prop(PROP_INT_MIN)->SetValue((real)-1);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterCracks::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_LoopBegin.Prop(PROP_LOOP_END)->SetFilter(&m_LoopEnd);
		m_LoopBegin.Prop(PROP_LOOP_NUM)->CopyLink(&m_Prop[PROP_CRACKS_LAYERS]);

		m_LoopIndex.Prop(PROP_SOURCE)->SetFilter(&m_LoopBegin);

		m_Add1.Prop(PROP_SOURCE)->SetFilter(&m_LoopIndex);
		m_Add1.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_CRACKS_SEED]);

		m_Add2.Prop(PROP_SOURCE)->SetFilter(&m_Add1);

		m_Perlin1.Prop(PROP_NOISE_ROUGHNESS)->CopyLink(&m_Prop[PROP_CRACKS_ROUGH]);
		m_Perlin1.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_CRACKS_SCALE]);
		m_Perlin1.Prop(PROP_NOISE_SQUEEZE)->CopyLink(&m_Prop[PROP_CRACKS_SQUEEZE]);
		m_Perlin1.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add1);

		m_Perlin2.Prop(PROP_NOISE_BRIGHT)->CopyLink(&m_Prop[PROP_CRACKS_LEVEL]);
		m_Perlin2.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add2);

		m_Blend.Prop(PROP_SOURCE)->SetFilter(&m_LoopBegin);
		m_Blend.Prop(PROP_SOURCE2)->SetFilter(&m_Add3);

		m_Interval.Prop(PROP_SOURCE)->SetFilter(&m_Perlin1);

		m_LoopEnd.Prop(PROP_SOURCE)->SetFilter(&m_Blend);

		m_Abs.Prop(PROP_SOURCE)->SetFilter(&m_Interval);

		m_Switch2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Switch2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Switch2.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_LoopEnd);

		m_Mul.Prop(PROP_SOURCE)->SetFilter(&m_Abs);
		m_Mul.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_CRACKS_THIN]);

		m_Add3.Prop(PROP_SOURCE)->SetFilter(&m_Mul);
		m_Add3.Prop(PROP_SOURCE2)->SetFilter(&m_Perlin2);

		m_LoopBegin.Restart();
		m_LoopEnd.Restart();
	}

	m_Switch2.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCracks::RenderVal(real x, real y)
{
	CColor col;
	CFilterCracks::RenderCol(&col, x, y);
	return col.Gray();
}
