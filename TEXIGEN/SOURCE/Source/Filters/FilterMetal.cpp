	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Metal Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CText SeamlessRotateNameMetal[] = {
	CText(_T("0°")),
	CText(_T("45°")),
	CText(_T("90°")),
	CText(_T("135°")),
	CText(_T("180°")),
	CText(_T("225°")),
	CText(_T("270°")),
	CText(_T("315°")),
	CText(_T("Radial")),

	CText(_T(""))
};

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMetal::CFilterMetal()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Metal");
	m_HelpID = HELP_FMETAL;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetColor((real)188/255, (real)193/255, (real)197/255);

	m_Prop[PROP_METAL_LTSCALE].SetName("LtScale");
	m_Prop[PROP_METAL_LTSCALE].SetValue(1);
	m_Prop[PROP_METAL_LTSCALE].SetMinVal((real)0.4);
	m_Prop[PROP_METAL_LTSCALE].SetToolID(ID_PROP_LTSCALE);

	m_Prop[PROP_METAL_LTANGLE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_METAL_LTANGLE].SetName("LtAngle");
	m_Prop[PROP_METAL_LTANGLE].SetMax(8);
	m_Prop[PROP_METAL_LTANGLE].SetEnum(SeamlessRotateNameMetal);
	m_Prop[PROP_METAL_LTANGLE].SetToolID(ID_PROP_LTANGLE);

	m_Prop[PROP_METAL_LTINTENS].SetName("LtIntens");
	m_Prop[PROP_METAL_LTINTENS].SetValue((real)0.75);
	m_Prop[PROP_METAL_LTINTENS].SetToolID(ID_PROP_LTINTENS);

	m_Prop[PROP_METAL_SCALE].SetName("Scale");
	m_Prop[PROP_METAL_SCALE].SetValue((real)0.55);
	m_Prop[PROP_METAL_SCALE].SetMinVal((real)0.3);
	m_Prop[PROP_METAL_SCALE].SetMaxVal((real)0.8);
	m_Prop[PROP_METAL_SCALE].SetToolID(ID_PROP_METALSCALE);

	m_Prop[PROP_METAL_DENSITY].SetName("Density");
	m_Prop[PROP_METAL_DENSITY].SetValue((real)0.15);
	m_Prop[PROP_METAL_DENSITY].SetMaxVal((real)0.3);
	m_Prop[PROP_METAL_DENSITY].SetToolID(ID_PROP_METALDENS);

	m_Prop[PROP_METAL_ANGLE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_METAL_ANGLE].SetName("Angle");
	m_Prop[PROP_METAL_ANGLE].SetMax(8);
	m_Prop[PROP_METAL_ANGLE].SetEnum(SeamlessRotateName);
	m_Prop[PROP_METAL_ANGLE].SetToolID(ID_PROP_METALANGLE);

	m_Prop[PROP_METAL_CONTRAST].SetName("Contrast");
	m_Prop[PROP_METAL_CONTRAST].SetValue((real)0.25);
	m_Prop[PROP_METAL_CONTRAST].SetMaxVal((real)0.5);
	m_Prop[PROP_METAL_CONTRAST].SetToolID(ID_PROP_METALCONT);

	m_Prop[PROP_METAL_WAVES].SetName("Waves");
	m_Prop[PROP_METAL_WAVES].SetValue((real)0.7*(real)0.4);
	m_Prop[PROP_METAL_WAVES].SetMaxVal((real)0.4);
	m_Prop[PROP_METAL_WAVES].SetToolID(ID_PROP_METALWAVES);

	m_Prop[PROP_METAL_SEED].SetName("Seed");
	m_Prop[PROP_METAL_SEED].SetMax(1000);
	m_Prop[PROP_METAL_SEED].SetToolID(ID_PROP_SEED);

	m_Noise1.Prop(PROP_CURNOI_DETAILS)->SetValue((real)0.3);

	m_Perlin.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.3);

	m_Noise2.Prop(PROP_CURNOI_DETAILS)->SetValue((real)0.3);
	m_Noise2.Prop(PROP_CURNOI_SCALE)->SetValue((real)0.76);

	m_Blend1.Prop(PROP_BLEND_MODE)->SetValue((real)0.11);

	m_Blend2.Prop(PROP_BLEND_MODE)->SetValue((real)0.11);

	m_Sub.Prop(PROP_SOURCE2)->SetValue((real)0.11);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMetal::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Noise1.Prop(PROP_CURNOI_SCALE)->CopyLink(&m_Prop[PROP_METAL_LTSCALE]);
		m_Noise1.Prop(PROP_CURNOI_SEED)->CopyLink(&m_Prop[PROP_METAL_SEED]);

		m_Perlin.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_METAL_CONTRAST]);
		m_Perlin.Prop(PROP_NOISE_BRIGHT)->SetFilter(&m_Rotate90);
		m_Perlin.Prop(PROP_NOISE_SCALE)->CopyLink(&m_Prop[PROP_METAL_SCALE]);
		m_Perlin.Prop(PROP_NOISE_SQUEEZE)->CopyLink(&m_Prop[PROP_METAL_DENSITY]);
		m_Perlin.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_METAL_SEED]);

		m_SeamlessRotate1.Prop(PROP_SOURCE)->SetFilter(&m_Noise1);
		m_SeamlessRotate1.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_METAL_LTANGLE]);

		m_SeamlessRotate2.Prop(PROP_SOURCE)->SetFilter(&m_Perlin);
		m_SeamlessRotate2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_METAL_ANGLE]);

		m_Noise2.Prop(PROP_CURNOI_SEED)->CopyLink(&m_Prop[PROP_METAL_SEED]);

		m_Blend1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Blend1.Prop(PROP_SOURCE2)->SetFilter(&m_SeamlessRotate2);

		m_Blend2.Prop(PROP_SOURCE)->SetFilter(&m_Blend1);
		m_Blend2.Prop(PROP_SOURCE2)->SetFilter(&m_SeamlessRotate1);
		m_Blend2.Prop(PROP_BLEND_OPACITY)->CopyLink(&m_Prop[PROP_METAL_LTINTENS]);

		m_Level.Prop(PROP_SOURCE)->SetFilter(&m_Noise2);
		m_Level.Prop(PROP_LEVEL_CONTRAST)->CopyLink(&m_Prop[PROP_METAL_WAVES]);

		m_Rotate90.Prop(PROP_SOURCE)->SetFilter(&m_Level);

		m_Polar.Prop(PROP_SOURCE)->SetFilter(&m_Blend2);

		m_Sub.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_METAL_LTANGLE]);

		m_Threshold8.Prop(PROP_SOURCE)->SetFilter(&m_Blend2);
		m_Threshold8.Prop(PROP_SOURCE2)->SetFilter(&m_Blend2);
		m_Threshold8.Prop(PROP_SOURCE3)->SetFilter(&m_Blend2);
		m_Threshold8.Prop(PROP_SOURCE4)->SetFilter(&m_Blend2);
		m_Threshold8.Prop(PROP_SOURCE5)->SetFilter(&m_Blend2);
		m_Threshold8.Prop(PROP_SOURCE6)->SetFilter(&m_Blend2);
		m_Threshold8.Prop(PROP_SOURCE7)->SetFilter(&m_Blend2);
		m_Threshold8.Prop(PROP_SOURCE8)->SetFilter(&m_Polar);
		m_Threshold8.Prop(PROP_THRES8_LEVEL)->SetFilter(&m_Sub);
	}

	m_Threshold8.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMetal::RenderVal(real x, real y)
{
	CColor col;
	CFilterMetal::RenderCol(&col, x, y);
	return col.Gray();
}
