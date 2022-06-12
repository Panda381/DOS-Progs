	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Glass Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGlass::CFilterGlass()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Glass");
	m_HelpID = HELP_FGLASS;
	m_PropNum = 9;

	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetColor((real)104/255, (real)196/255, (real)143/255);

	m_Prop[PROP_GLASS_ROUGH].SetName("Roughness");
	m_Prop[PROP_GLASS_ROUGH].SetValue((real)0.5);
	m_Prop[PROP_GLASS_ROUGH].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_GLASS_CONTRAST].SetName("Contrast");
	m_Prop[PROP_GLASS_CONTRAST].SetValue((real)0.5);
	m_Prop[PROP_GLASS_CONTRAST].SetToolID(ID_PROP_GLASSCONTR);

	m_Prop[PROP_GLASS_SCALE].SetName("Scale");
	m_Prop[PROP_GLASS_SCALE].SetValue((real)0.5);
	m_Prop[PROP_GLASS_SCALE].SetToolID(ID_PROP_GLASSSCALE);

	m_Prop[PROP_GLASS_DENS].SetName("Density");
	m_Prop[PROP_GLASS_DENS].SetValue((real)0.4);
	m_Prop[PROP_GLASS_DENS].SetToolID(ID_PROP_GLASSDENS);

	m_Prop[PROP_GLASS_BUMP].SetName("Bump");
	m_Prop[PROP_GLASS_BUMP].SetValue((real)0.5);
	m_Prop[PROP_GLASS_BUMP].SetToolID(ID_PROP_GLASSBUMP);

	m_Prop[PROP_GLASS_BSCALE].SetName("BumpScale");
	m_Prop[PROP_GLASS_BSCALE].SetValue((real)0.4);
	m_Prop[PROP_GLASS_BSCALE].SetToolID(ID_PROP_GLASSBSCALE);

	m_Prop[PROP_GLASS_REFL].SetName("Reflections");
	m_Prop[PROP_GLASS_REFL].SetValue((real)0.5);
	m_Prop[PROP_GLASS_REFL].SetToolID(ID_PROP_GLASSREFL);

	m_Prop[PROP_GLASS_SEED].SetName("Seed");
	m_Prop[PROP_GLASS_SEED].SetMax(1000);
	m_Prop[PROP_GLASS_SEED].SetToolID(ID_PROP_SEED);

	m_Noise.Prop(PROP_CURVE_MIN)->SetValue((real)0.4);
	m_Noise.Prop(PROP_CURVE_MAX)->SetValue((real)0.6);
	m_Noise.Prop(PROP_CURNOI_DETAILS)->SetValue((real)0.3);

	m_Mul.Prop(PROP_SOURCE2)->SetValue((real)0.5);

	m_Perlin1.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.3);

	m_Perlin2.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.2);
	m_Perlin2.Prop(PROP_NOISE_ROUGHNESS)->SetValue((real)0.3);
	m_Perlin2.Prop(PROP_NOISE_CONTRAST)->SetValue((real)0.4);

	m_Emboss.Prop(PROP_EMBOSS_DIFFUSE)->SetValue((real)0.20);
	m_Emboss.Prop(PROP_EMBOSS_SPECULAR)->SetValue((real)0.35);
	m_Emboss.Prop(PROP_EMBOSS_SCALE)->SetValue((real)0.78);
	m_Emboss.Prop(PROP_EMBOSS_SHIFTX)->SetUserValue(-13);
	m_Emboss.Prop(PROP_EMBOSS_SHIFTY)->SetUserValue(28);
	m_Emboss.Prop(PROP_EMBOSS_ENVIRONMENT)->SetValue((real)0.2);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGlass::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Noise.Prop(PROP_CURNOI_SCALE)->CopyLink(&m_Prop[PROP_GLASS_DENS]);
		m_Noise.Prop(PROP_CURNOI_SEED)->CopyLink(&m_Prop[PROP_GLASS_SEED]);

		m_Mul.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_GLASS_BUMP]);

		m_Perlin1.Prop(PROP_NOISE_ROUGHNESS)->CopyLink(&m_Prop[PROP_GLASS_ROUGH]);
		m_Perlin1.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_GLASS_CONTRAST]);
		m_Perlin1.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_GLASS_SCALE]);
		m_Perlin1.Prop(PROP_NOISE_PROFILE)->SetFilter(&m_Noise);
		m_Perlin1.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_GLASS_SEED]);

		m_Perlin2.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_GLASS_BSCALE]);
		m_Perlin2.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_GLASS_SEED]);

		m_Switch21.Prop(PROP_SOURCE)->SetFilter(&m_Perlin1);
		m_Switch21.Prop(PROP_SOURCE2)->SetFilter(&m_Perlin2);
		m_Switch21.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Mul);

		m_Switch22.Prop(PROP_SOURCE)->SetFilter(&m_Perlin1);
		m_Switch22.Prop(PROP_SOURCE2)->SetFilter(&m_Perlin2);
		m_Switch22.Prop(PROP_SWITCH2_SWITCH)->CopyLink(&m_Prop[PROP_GLASS_BUMP]);

		m_Level.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Level.Prop(PROP_LEVEL_BRIGHT)->SetFilter(&m_Switch21);

		m_Emboss.Prop(PROP_SOURCE)->SetFilter(&m_Level);
		m_Emboss.Prop(PROP_EMBOSS_HEIGHTMAP)->SetFilter(&m_Switch22);

		m_Switch23.Prop(PROP_SOURCE)->SetFilter(&m_Level);
		m_Switch23.Prop(PROP_SOURCE2)->SetFilter(&m_Emboss);
		m_Switch23.Prop(PROP_SWITCH2_SWITCH)->CopyLink(&m_Prop[PROP_GLASS_REFL]);
	}

	m_Switch23.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGlass::RenderVal(real x, real y)
{
	CColor col;
	CFilterGlass::RenderCol(&col, x, y);
	return col.Gray();
}
