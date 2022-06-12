	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Wood Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterWood::CFilterWood()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Wood");
	m_HelpID = HELP_FWOOD;
	m_PropNum = 8;

	m_Prop[PROP_SOURCE].SetName("Color1");
	m_Prop[PROP_SOURCE].SetColor((real)239/255, (real)217/255, (real)126/255);

	m_Prop[PROP_SOURCE2].SetName("Color2");
	m_Prop[PROP_SOURCE2].SetColor((real)154/255, (real)121/255, (real)75/255);

	m_Prop[PROP_WOOD_RINGS].SetName("Rings");
	m_Prop[PROP_WOOD_RINGS].SetValue((real)0.13);
	m_Prop[PROP_WOOD_RINGS].SetToolID(ID_PROP_WOODRINGS);

	m_Prop[PROP_WOOD_SMOOTH].SetName("Smooth");
	m_Prop[PROP_WOOD_SMOOTH].SetValue((real)0.76);
	m_Prop[PROP_WOOD_SMOOTH].SetToolID(ID_PROP_WOODSMOOTH);

	m_Prop[PROP_WOOD_DENSITY].SetName("Density");
	m_Prop[PROP_WOOD_DENSITY].SetValue(1);
	m_Prop[PROP_WOOD_DENSITY].SetToolID(ID_PROP_WOODDENS);

	m_Prop[PROP_WOOD_ROTATE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_WOOD_ROTATE].SetName("Rotate");
	m_Prop[PROP_WOOD_ROTATE].SetMax(8);
	m_Prop[PROP_WOOD_ROTATE].SetEnum(SeamlessRotateName);
	m_Prop[PROP_WOOD_ROTATE].SetToolID(ID_PROP_ANGLE3);

	m_Prop[PROP_WOOD_FIBERS].SetName("Fibers");
	m_Prop[PROP_WOOD_FIBERS].SetValue((real)0.5);
	m_Prop[PROP_WOOD_FIBERS].SetMaxVal((real)0.5);
	m_Prop[PROP_WOOD_FIBERS].SetToolID(ID_PROP_WOODFIBERS);

	m_Prop[PROP_WOOD_SEED].SetName("Seed");
	m_Prop[PROP_WOOD_SEED].SetMax(1000);
	m_Prop[PROP_WOOD_SEED].SetToolID(ID_PROP_SEED);

	m_Perlin1.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.6);
	m_Perlin1.Prop(PROP_NOISE_CONTRAST)->SetValue((real)0.43);
	m_Perlin1.Prop(PROP_NOISE_BRIGHT)->SetValue((real)0.45);

	m_Noise1.Prop(PROP_CURNOI_DETAILS)->SetValue((real)0.2);
	m_Noise1.Prop(PROP_CURNOI_ROUGHNESS)->SetValue((real)0.33);
	m_Noise1.Prop(PROP_CURNOI_SCALE)->SetValue((real)0.70);

	m_Noise2.Prop(PROP_CURNOI_DETAILS)->SetValue((real)0.8);
	m_Noise2.Prop(PROP_CURNOI_ROUGHNESS)->SetValue((real)0.74);

	m_Perlin2.Prop(PROP_NOISE_ROUGHNESS)->SetValue((real)0.53);
	m_Perlin2.Prop(PROP_NOISE_BRIGHT)->SetValue((real)0.38);
	m_Perlin2.Prop(PROP_NOISE_SCALE)->SetValue((real)0.08);
	m_Perlin2.Prop(PROP_NOISE_SQUEEZE)->SetValue((real)0.75);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterWood::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Invert.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_WOOD_SMOOTH]);

		m_Perlin1.Prop(PROP_NOISE_ROUGHNESS)->SetFilter(&m_Invert);
		m_Perlin1.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_WOOD_SEED]);

		m_Noise1.Prop(PROP_CURNOI_SEED)->CopyLink(&m_Prop[PROP_WOOD_SEED]);

		m_Noise2.Prop(PROP_CURNOI_SCALE)->CopyLink(&m_Prop[PROP_WOOD_DENSITY]);
		m_Noise2.Prop(PROP_CURNOI_SEED)->CopyLink(&m_Prop[PROP_WOOD_SEED]);

		m_Switch21.Prop(PROP_SOURCE)->SetFilter(&m_Noise1);
		m_Switch21.Prop(PROP_SOURCE2)->SetFilter(&m_Perlin1);
		m_Switch21.Prop(PROP_SWITCH2_SWITCH)->CopyLink(&m_Prop[PROP_WOOD_RINGS]);

		m_Colorize.Prop(PROP_SOURCE)->SetFilter(&m_Switch21);
		m_Colorize.Prop(PROP_COLORIZE_GRADIENT)->SetFilter(&m_Noise2);

		m_Switch22.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Switch22.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Switch22.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Colorize);

		m_Sqr.Prop(PROP_SOURCE)->SetFilter(&m_Switch22);

		m_Perlin2.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_WOOD_FIBERS]);
		m_Perlin2.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_WOOD_SEED]);

		m_Switch23.Prop(PROP_SOURCE)->SetFilter(&m_Switch22);
		m_Switch23.Prop(PROP_SOURCE2)->SetFilter(&m_Sqr);
		m_Switch23.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Perlin2);

		m_SeamlessRotate.Prop(PROP_SOURCE)->SetFilter(&m_Switch23);
		m_SeamlessRotate.Prop(PROP_ROT_ANGLE)->CopyLink(&m_Prop[PROP_WOOD_ROTATE]);
	}

	m_SeamlessRotate.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterWood::RenderVal(real x, real y)
{
	CColor col;
	CFilterWood::RenderCol(&col, x, y);
	return col.Gray();
}
