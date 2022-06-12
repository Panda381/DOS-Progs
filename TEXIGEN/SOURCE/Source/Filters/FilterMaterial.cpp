	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Material Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CText FilterMatMode[] = {
	CText(_T("Wood")),			// 0
	CText(_T("Metal")),			// 1
	CText(_T("Glass")),			// 2
	CText(_T("Malachite")),		// 3
	CText(_T("Marble")),		// 4
	CText(_T("Granite")),		// 5
	CText(_T("Cracks")),		// 6
	CText(_T("Fabric")),		// 7

	CText(_T(""))
};

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMaterial::CFilterMaterial()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Material");
	m_HelpID = HELP_FMATERIAL;
	m_PropNum = 6;

	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetColor((real)206/255, (real)183/255, (real)130/255);

	m_Prop[PROP_MAT_MATERIAL].SetCategory(PCAT_ENUM);
	m_Prop[PROP_MAT_MATERIAL].SetName("Material");
	m_Prop[PROP_MAT_MATERIAL].SetEnum(FilterMatMode);
	m_Prop[PROP_MAT_MATERIAL].SetMax(10);
	m_Prop[PROP_MAT_MATERIAL].SetToolID(ID_PROP_MATMODE);

	m_Prop[PROP_MAT_CONTRAST].SetName("Contrast");
	m_Prop[PROP_MAT_CONTRAST].SetValue((real)0.65);
	m_Prop[PROP_MAT_CONTRAST].SetToolID(ID_PROP_CONTRAST2);

	m_Prop[PROP_MAT_ROUGH].SetName("Roughness");
	m_Prop[PROP_MAT_ROUGH].SetValue((real)0.2);
	m_Prop[PROP_MAT_ROUGH].SetToolID(ID_PROP_ROUGHNESS2);

	m_Prop[PROP_MAT_ROTATE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_MAT_ROTATE].SetName("Rotate");
	m_Prop[PROP_MAT_ROTATE].SetMax(8);
	m_Prop[PROP_MAT_ROTATE].SetEnum(SeamlessRotateName);
	m_Prop[PROP_MAT_ROTATE].SetToolID(ID_PROP_ANGLE3);

	m_Prop[PROP_MAT_SEED].SetName("Seed");
	m_Prop[PROP_MAT_SEED].SetMax(1000);
	m_Prop[PROP_MAT_SEED].SetToolID(ID_PROP_SEED);

	m_Mul.Prop(PROP_SOURCE2)->SetValue((real)0.5);

	m_Interval.Prop(PROP_INT_MIN)->SetValue((real)-0.5);
	m_Interval.Prop(PROP_INT_MAX)->SetValue((real)0.5);

	m_Recolor1.Prop(PROP_COLOR_SAT)->SetUserValue(-20);
	m_Recolor1.Prop(PROP_COLOR_LUM)->SetUserValue(-10);

	m_Mul2.Prop(PROP_SOURCE2)->SetValue((real)0.1);

	m_Recolor2.Prop(PROP_COLOR_SAT)->SetUserValue(-20);
	m_Recolor2.Prop(PROP_COLOR_LUM)->SetUserValue(10);

	m_Metal.Prop(PROP_METAL_LTANGLE)->SetUserValue(3);
	m_Metal.Prop(PROP_METAL_SCALE)->SetUserValue(30);

	m_Glass.Prop(PROP_GLASS_REFL)->SetUserValue(75);

	m_Marble.Prop(PROP_MARBLE_SCALE)->SetUserValue(60);

	m_Cracks.Prop(PROP_CRACKS_THIN)->SetUserValue(12);
	m_Cracks.Prop(PROP_CRACKS_SCALE)->SetUserValue(55);

	m_Add2.Prop(PROP_SOURCE2)->SetValue((real)0.0499);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMaterial::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Mul.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_MAT_CONTRAST]);

		m_Interval.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_MAT_CONTRAST]);

		m_Add.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Add.Prop(PROP_SOURCE2)->SetFilter(&m_Interval);

		m_Sub.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Sub.Prop(PROP_SOURCE2)->SetFilter(&m_Interval);

		m_Recolor1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Recolor1.Prop(PROP_COLOR_HUE)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);

		m_Recolor2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Recolor2.Prop(PROP_COLOR_HUE)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);

		m_Mul2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);

		m_Wood.Prop(PROP_SOURCE)->SetFilter(&m_Add);
		m_Wood.Prop(PROP_SOURCE2)->SetFilter(&m_Sub);
		m_Wood.Prop(PROP_WOOD_RINGS)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);
		m_Wood.Prop(PROP_WOOD_SEED)->CopyLink(&m_Prop[PROP_MAT_SEED]);

		m_Metal.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Metal.Prop(PROP_METAL_LTINTENS)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);
		m_Metal.Prop(PROP_METAL_CONTRAST)->SetFilter(&m_Mul);
		m_Metal.Prop(PROP_METAL_SEED)->CopyLink(&m_Prop[PROP_MAT_SEED]);

		m_Glass.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Glass.Prop(PROP_GLASS_CONTRAST)->CopyLink(&m_Prop[PROP_MAT_CONTRAST]);
		m_Glass.Prop(PROP_GLASS_DENS)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);
		m_Glass.Prop(PROP_GLASS_BUMP)->CopyLink(&m_Prop[PROP_MAT_CONTRAST]);
		m_Glass.Prop(PROP_GLASS_SEED)->CopyLink(&m_Prop[PROP_MAT_SEED]);

		m_Malachite.Prop(PROP_SOURCE)->SetFilter(&m_Add);
		m_Malachite.Prop(PROP_SOURCE2)->SetFilter(&m_Sub);
		m_Malachite.Prop(PROP_SOURCE3)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Malachite.Prop(PROP_MALACH_DENSITY)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);
		m_Malachite.Prop(PROP_MALACH_SEED)->CopyLink(&m_Prop[PROP_MAT_SEED]);

		m_Marble.Prop(PROP_SOURCE)->SetFilter(&m_Sub);
		m_Marble.Prop(PROP_SOURCE2)->SetFilter(&m_Add);
		m_Marble.Prop(PROP_MARBLE_SMUDGES)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);
		m_Marble.Prop(PROP_MARBLE_SEED)->CopyLink(&m_Prop[PROP_MAT_SEED]);

		m_Granite.Prop(PROP_SOURCE)->SetFilter(&m_Add);
		m_Granite.Prop(PROP_GRAN_GRAINCOLOR)->SetFilter(&m_Sub);
		m_Granite.Prop(PROP_GRAN_COLOR1A)->SetFilter(&m_Recolor1);
		m_Granite.Prop(PROP_GRAN_COLOR1B)->SetFilter(&m_Recolor2);
		m_Granite.Prop(PROP_GRAN_COLOR2A)->SetFilter(&m_Recolor1);
		m_Granite.Prop(PROP_GRAN_COLOR2B)->SetFilter(&m_Recolor2);
		m_Granite.Prop(PROP_GRAN_SEED)->CopyLink(&m_Prop[PROP_MAT_SEED]);

		m_Cracks.Prop(PROP_SOURCE)->SetFilter(&m_Sub);
		m_Cracks.Prop(PROP_SOURCE2)->SetFilter(&m_Add);
		m_Cracks.Prop(PROP_CRACKS_LAYERS)->SetFilter(&m_Mul2);
		m_Cracks.Prop(PROP_CRACKS_SEED)->CopyLink(&m_Prop[PROP_MAT_SEED]);

		m_Fabric.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Fabric.Prop(PROP_FABRIC_ROUGH)->CopyLink(&m_Prop[PROP_MAT_ROUGH]);
		m_Fabric.Prop(PROP_FABRIC_EMBOSS)->CopyLink(&m_Prop[PROP_MAT_CONTRAST]);
		m_Fabric.Prop(PROP_FABRIC_SEED)->CopyLink(&m_Prop[PROP_MAT_SEED]);

		m_Add2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_MAT_MATERIAL]);

		m_Threshold10.Prop(PROP_SOURCE)->SetFilter(&m_Wood);
		m_Threshold10.Prop(PROP_SOURCE2)->SetFilter(&m_Metal);
		m_Threshold10.Prop(PROP_SOURCE3)->SetFilter(&m_Glass);
		m_Threshold10.Prop(PROP_SOURCE4)->SetFilter(&m_Malachite);
		m_Threshold10.Prop(PROP_SOURCE5)->SetFilter(&m_Marble);
		m_Threshold10.Prop(PROP_SOURCE6)->SetFilter(&m_Granite);
		m_Threshold10.Prop(PROP_SOURCE7)->SetFilter(&m_Cracks);
		m_Threshold10.Prop(PROP_SOURCE8)->SetFilter(&m_Fabric);
		m_Threshold10.Prop(PROP_THRES10_LEVEL)->SetFilter(&m_Add2);

		m_SeamlessRotate.Prop(PROP_SOURCE)->SetFilter(&m_Threshold10);
		m_SeamlessRotate.Prop(PROP_ROT_ANGLE)->CopyLink(&m_Prop[PROP_MAT_ROTATE]);

		m_Wood.Restart();
		m_Metal.Restart();
		m_Glass.Restart();
		m_Malachite.Restart();
		m_Marble.Restart();
		m_Granite.Restart();
		m_Cracks.Restart();
		m_Fabric.Restart();
	}

	m_SeamlessRotate.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMaterial::RenderVal(real x, real y)
{
	CColor col;
	CFilterMaterial::RenderCol(&col, x, y);
	return col.Gray();
}
