					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Granite Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGranite::CFilterGranite()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Granite");
	m_HelpID = HELP_FGRANITE;
	m_PropNum = 24;

	m_Prop[PROP_SOURCE].SetName("Background");
	m_Prop[PROP_SOURCE].SetColor((real)237/255, (real)216/255, (real)203/255);

	m_Prop[PROP_GRAN_NOISE].SetName("Noise");
	m_Prop[PROP_GRAN_NOISE].SetToolID(ID_PROP_GRANNOISE);
	m_Prop[PROP_GRAN_NOISE].SetMinVal((real)-0.1);
	m_Prop[PROP_GRAN_NOISE].SetUserValue(30);

	m_Prop[PROP_GRAN_NOISESCALE].SetName("NoiseScale");
	m_Prop[PROP_GRAN_NOISESCALE].SetValue((real)0.05);
	m_Prop[PROP_GRAN_NOISESCALE].SetToolID(ID_PROP_GRANNOISESCALE);

	m_Prop[PROP_GRAN_GRAINCOLOR].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRAN_GRAINCOLOR].SetName("GrainColor");
	m_Prop[PROP_GRAN_GRAINCOLOR].SetColor((real)85/255, (real)75/255, (real)62/255);
	m_Prop[PROP_GRAN_GRAINCOLOR].SetToolID(ID_PROP_GRAINCOLOR);

	m_Prop[PROP_GRAN_GRAINCONTR].SetName("GrainContr");
	m_Prop[PROP_GRAN_GRAINCONTR].SetValue((real)0.7);
	m_Prop[PROP_GRAN_GRAINCONTR].SetToolID(ID_PROP_GRAINCONTR);

	m_Prop[PROP_GRAN_GRAINLEVEL].SetName("GrainLevel");
	m_Prop[PROP_GRAN_GRAINLEVEL].SetValue((real)0.5);
	m_Prop[PROP_GRAN_GRAINLEVEL].SetToolID(ID_PROP_GRAINLEVEL);

	m_Prop[PROP_GRAN_GRAINSCALE].SetName("GrainScale");
	m_Prop[PROP_GRAN_GRAINSCALE].SetValue((real)0.2);
	m_Prop[PROP_GRAN_GRAINSCALE].SetToolID(ID_PROP_GRAINSCALE);

	m_Prop[PROP_GRAN_COLOR1A].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRAN_COLOR1A].SetName("Color1A");
	m_Prop[PROP_GRAN_COLOR1A].SetColor((real)190/255, (real)182/255, (real)173/255);
	m_Prop[PROP_GRAN_COLOR1A].SetToolID(ID_PROP_GRANCOLOR);

	m_Prop[PROP_GRAN_COLOR1B].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRAN_COLOR1B].SetName("Color1B");
	m_Prop[PROP_GRAN_COLOR1B].SetColor((real)167/255, (real)160/255, (real)158/255);
	m_Prop[PROP_GRAN_COLOR1B].SetToolID(ID_PROP_GRANCOLOR);

	m_Prop[PROP_GRAN_CONTRAST1].SetName("Contrast1");
	m_Prop[PROP_GRAN_CONTRAST1].SetValue((real)0.6);
	m_Prop[PROP_GRAN_CONTRAST1].SetToolID(ID_PROP_GRANCONTRAST);

	m_Prop[PROP_GRAN_LEVEL1].SetName("Level1");
	m_Prop[PROP_GRAN_LEVEL1].SetValue((real)0.55);
	m_Prop[PROP_GRAN_LEVEL1].SetToolID(ID_PROP_GRANLEVEL);

	m_Prop[PROP_GRAN_ROUGH1].SetName("Rough1");
	m_Prop[PROP_GRAN_ROUGH1].SetValue((real)0.9);
	m_Prop[PROP_GRAN_ROUGH1].SetToolID(ID_PROP_GRANROUGH);

	m_Prop[PROP_GRAN_SCALE1].SetName("Scale1");
	m_Prop[PROP_GRAN_SCALE1].SetValue((real)0.55);
	m_Prop[PROP_GRAN_SCALE1].SetToolID(ID_PROP_GRANSCALE);

	m_Prop[PROP_GRAN_SMOOTH1].SetName("Smooth1");
	m_Prop[PROP_GRAN_SMOOTH1].SetValue((real)0.4);
	m_Prop[PROP_GRAN_SMOOTH1].SetToolID(ID_PROP_GRANSMOOTH);

	m_Prop[PROP_GRAN_COLOR2A].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRAN_COLOR2A].SetName("Color2A");
	m_Prop[PROP_GRAN_COLOR2A].SetColor((real)200/255, (real)163/255, (real)138/255);
	m_Prop[PROP_GRAN_COLOR2A].SetToolID(ID_PROP_GRANCOLOR);

	m_Prop[PROP_GRAN_COLOR2B].SetCategory(PCAT_COLOR);
	m_Prop[PROP_GRAN_COLOR2B].SetName("Color2B");
	m_Prop[PROP_GRAN_COLOR2B].SetColor((real)180/255, (real)138/255, (real)101/255);
	m_Prop[PROP_GRAN_COLOR2B].SetToolID(ID_PROP_GRANCOLOR);

	m_Prop[PROP_GRAN_CONTRAST2].SetName("Contrast2");
	m_Prop[PROP_GRAN_CONTRAST2].SetValue((real)0.5);
	m_Prop[PROP_GRAN_CONTRAST2].SetToolID(ID_PROP_GRANCONTRAST);

	m_Prop[PROP_GRAN_LEVEL2].SetName("Level2");
	m_Prop[PROP_GRAN_LEVEL2].SetValue((real)0.47);
	m_Prop[PROP_GRAN_LEVEL2].SetToolID(ID_PROP_GRANLEVEL);

	m_Prop[PROP_GRAN_ROUGH2].SetName("Rough2");
	m_Prop[PROP_GRAN_ROUGH2].SetValue((real)0.75);
	m_Prop[PROP_GRAN_ROUGH2].SetToolID(ID_PROP_GRANROUGH);

	m_Prop[PROP_GRAN_SCALE2].SetName("Scale2");
	m_Prop[PROP_GRAN_SCALE2].SetValue((real)0.55);
	m_Prop[PROP_GRAN_SCALE2].SetToolID(ID_PROP_GRANSCALE);

	m_Prop[PROP_GRAN_SMOOTH2].SetName("Smooth2");
	m_Prop[PROP_GRAN_SMOOTH2].SetValue((real)0.1);
	m_Prop[PROP_GRAN_SMOOTH2].SetToolID(ID_PROP_GRANSMOOTH);

	m_Prop[PROP_GRAN_WEBCONTR].SetName("WebContr");
	m_Prop[PROP_GRAN_WEBCONTR].SetValue((real)0.1);
	m_Prop[PROP_GRAN_WEBCONTR].SetToolID(ID_PROP_WEBCONTR);

	m_Prop[PROP_GRAN_WEBGAMMA].SetName("WebGamma");
	m_Prop[PROP_GRAN_WEBGAMMA].SetValue((real)0.75);
	m_Prop[PROP_GRAN_WEBGAMMA].SetToolID(ID_PROP_WEBGAMMA);

	m_Prop[PROP_GRAN_SEED].SetName("Seed");
	m_Prop[PROP_GRAN_SEED].SetMax(1000);
	m_Prop[PROP_GRAN_SEED].SetToolID(ID_PROP_SEED);

	m_Add1.Prop(PROP_SOURCE2)->SetValue((real)0.04);
	m_Add2.Prop(PROP_SOURCE2)->SetValue((real)0.03);
	m_Add3.Prop(PROP_SOURCE2)->SetValue((real)0.02);
	m_Add4.Prop(PROP_SOURCE2)->SetValue((real)0.01);

	m_Interval.Prop(PROP_INT_MIN)->SetValue(-2);
	m_Interval.Prop(PROP_INT_MAX)->SetValue(+2);

	m_Cellular2.Prop(PROP_CELLULAR_DETAILS)->SetValue((real)0.1);
	m_Cellular2.Prop(PROP_CELLULAR_SOLID)->SetValue(1);

	m_Blur1.Prop(PROP_BLUR_RADIUSX)->SetValue((real)0.02);
	m_Blur1.Prop(PROP_BLUR_RADIUSY)->SetValue((real)0.02);

	m_Cellular4.Prop(PROP_CELLULAR_DETAILS)->SetValue((real)0.1);
	m_Cellular4.Prop(PROP_CELLULAR_SOLID)->SetValue(1);

	m_Blur2.Prop(PROP_BLUR_RADIUSX)->SetValue((real)0.02);
	m_Blur2.Prop(PROP_BLUR_RADIUSY)->SetValue((real)0.02);

	m_Cellular5.Prop(PROP_CELLULAR_DETAILS)->SetValue((real)0.7);
	m_Cellular5.Prop(PROP_CELLULAR_ROUGHNESS)->SetValue((real)0.4);
	m_Cellular5.Prop(PROP_CELLULAR_BRIGHT)->SetValue((real)0.37);
	m_Cellular5.Prop(PROP_CELLULAR_SCALE)->SetValue((real)0.3);

	m_Perlin3.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.8);
	m_Perlin3.Prop(PROP_NOISE_ROUGHNESS)->SetValue((real)0.4);
	m_Perlin3.Prop(PROP_NOISE_CONTRAST)->SetValue((real)0.3);
	m_Perlin3.Prop(PROP_NOISE_SCALE)->SetValue((real)0.5);

	m_Perlin4.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.8);
	m_Perlin4.Prop(PROP_NOISE_ROUGHNESS)->SetValue((real)0.4);
	m_Perlin4.Prop(PROP_NOISE_CONTRAST)->SetValue((real)0.3);
	m_Perlin4.Prop(PROP_NOISE_SCALE)->SetValue((real)0.5);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGranite::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Perlin1.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_GRAN_NOISE]);
		m_Perlin1.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_GRAN_NOISESCALE]);
		m_Perlin1.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add1);

		m_Level1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Level1.Prop(PROP_LEVEL_BRIGHT)->SetFilter(&m_Perlin1);

		m_Add1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_GRAN_SEED]);

		m_Perlin2.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_GRAN_GRAINCONTR]);
		m_Perlin2.Prop(PROP_NOISE_BRIGHT)->SetFilter(&m_Interval);
		m_Perlin2.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_GRAN_GRAINSCALE]);
		m_Perlin2.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add2);

		m_Interval.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_GRAN_GRAINLEVEL]);

		m_Add2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_GRAN_SEED]);

		m_Switch2.Prop(PROP_SOURCE)->SetFilter(&m_Level1);
		m_Switch2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_GRAN_GRAINCOLOR]);
		m_Switch2.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Perlin2);

		m_Cellular1.Prop(PROP_CELLULAR_ROUGHNESS)->CopyLink(&m_Prop[PROP_GRAN_ROUGH1]);
		m_Cellular1.Prop(PROP_CELLULAR_CONTRAST)->CopyLink(&m_Prop[PROP_GRAN_CONTRAST1]);
		m_Cellular1.Prop(PROP_CELLULAR_BRIGHT)->CopyLink(&m_Prop[PROP_GRAN_LEVEL1]);
		m_Cellular1.Prop(PROP_CELLULAR_SCALE)->CopyLink(&m_Prop[PROP_GRAN_SCALE1]);
		m_Cellular1.Prop(PROP_CELLULAR_SEED)->SetFilter(&m_Add3);

		m_Cellular2.Prop(PROP_CELLULAR_SCALE)->CopyLink(&m_Prop[PROP_GRAN_SCALE1]);
		m_Cellular2.Prop(PROP_CELLULAR_SEED)->SetFilter(&m_Add3);

		m_Threshold21.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_GRAN_COLOR1A]);
		m_Threshold21.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_GRAN_COLOR1B]);
		m_Threshold21.Prop(PROP_THRES2_LEVEL)->SetFilter(&m_Cellular2);

		m_Blur1.Prop(PROP_SOURCE)->SetFilter(&m_Threshold21);
		m_Blur1.Restart();

		m_Level2.Prop(PROP_SOURCE)->SetFilter(&m_Blur1);
		m_Level2.Prop(PROP_LEVEL_BRIGHT)->SetFilter(&m_Invert);

		m_Threshold1.Prop(PROP_SOURCE)->SetFilter(&m_Cellular1);
		m_Threshold1.Prop(PROP_THRES_TOLERANCE)->CopyLink(&m_Prop[PROP_GRAN_SMOOTH1]);
		m_Threshold1.Prop(PROP_THRES_LOW)->SetFilter(&m_Switch2);
		m_Threshold1.Prop(PROP_THRES_HIGH)->SetFilter(&m_Level2);

		m_Add3.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_GRAN_SEED]);

		m_Cellular3.Prop(PROP_CELLULAR_ROUGHNESS)->CopyLink(&m_Prop[PROP_GRAN_ROUGH2]);
		m_Cellular3.Prop(PROP_CELLULAR_CONTRAST)->CopyLink(&m_Prop[PROP_GRAN_CONTRAST2]);
		m_Cellular3.Prop(PROP_CELLULAR_BRIGHT)->CopyLink(&m_Prop[PROP_GRAN_LEVEL2]);
		m_Cellular3.Prop(PROP_CELLULAR_SCALE)->CopyLink(&m_Prop[PROP_GRAN_SCALE2]);
		m_Cellular3.Prop(PROP_CELLULAR_SEED)->SetFilter(&m_Add4);

		m_Cellular4.Prop(PROP_CELLULAR_SCALE)->CopyLink(&m_Prop[PROP_GRAN_SCALE2]);
		m_Cellular4.Prop(PROP_CELLULAR_SEED)->SetFilter(&m_Add4);

		m_Threshold23.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_GRAN_COLOR2A]);
		m_Threshold23.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_GRAN_COLOR2B]);
		m_Threshold23.Prop(PROP_THRES2_LEVEL)->SetFilter(&m_Cellular4);

		m_Blur2.Prop(PROP_SOURCE)->SetFilter(&m_Threshold23);
		m_Blur2.Restart();

		m_Level3.Prop(PROP_SOURCE)->SetFilter(&m_Blur2);
		m_Level3.Prop(PROP_LEVEL_BRIGHT)->SetFilter(&m_Invert);

		m_Threshold2.Prop(PROP_SOURCE)->SetFilter(&m_Cellular3);
		m_Threshold2.Prop(PROP_THRES_TOLERANCE)->CopyLink(&m_Prop[PROP_GRAN_SMOOTH2]);
		m_Threshold2.Prop(PROP_THRES_LOW)->SetFilter(&m_Threshold1);
		m_Threshold2.Prop(PROP_THRES_HIGH)->SetFilter(&m_Level3);

		m_Add4.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_GRAN_SEED]);

		m_Cellular5.Prop(PROP_CELLULAR_CONTRAST)->CopyLink(&m_Prop[PROP_GRAN_WEBCONTR]);
		m_Cellular5.Prop(PROP_CELLULAR_PROFILE)->SetFilter(&m_Bias);
		m_Cellular5.Prop(PROP_CELLULAR_SEED)->CopyLink(&m_Prop[PROP_GRAN_SEED]);

		m_Perlin3.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add4);

		m_Perlin4.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_GRAN_SEED]);

		m_Shift.Prop(PROP_SOURCE)->SetFilter(&m_Cellular5);
		m_Shift.Prop(PROP_SHIFT_X)->SetFilter(&m_Perlin3);
		m_Shift.Prop(PROP_SHIFT_Y)->SetFilter(&m_Perlin4);

		m_Invert.Prop(PROP_SOURCE)->SetFilter(&m_Shift);

		m_Bias.Prop(PROP_CURBIAS_BIAS)->CopyLink(&m_Prop[PROP_GRAN_WEBGAMMA]);
	}

	m_Threshold2.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGranite::RenderVal(real x, real y)
{
	CColor col;
	CFilterGranite::RenderCol(&col, x, y);
	return col.Gray();
}
