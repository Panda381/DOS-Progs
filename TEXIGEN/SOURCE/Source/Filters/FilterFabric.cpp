	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Fabric Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterFabric::CFilterFabric()
{
	m_Group = FGRP_MAT;
	m_Class = _T("Fabric");
	m_HelpID = HELP_FFABRIC;
	m_PropNum = 7;

	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetColor((real)135/255, (real)108/255, (real)69/255);

	m_Prop[PROP_SOURCE2].SetName("Background");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_BACKGROUND);

	m_Prop[PROP_FABRIC_WIDTH].SetName("Width");
	m_Prop[PROP_FABRIC_WIDTH].SetValue((real)0.3);
	m_Prop[PROP_FABRIC_WIDTH].SetToolID(ID_PROP_FABRICWIDTH);
	m_Prop[PROP_FABRIC_WIDTH].SetMinVal((real)0.01);
	m_Prop[PROP_FABRIC_WIDTH].SetMin(1);

	m_Prop[PROP_FABRIC_HEIGHT].SetName("Height");
	m_Prop[PROP_FABRIC_HEIGHT].SetValue((real)0.3);
	m_Prop[PROP_FABRIC_HEIGHT].SetToolID(ID_PROP_FABRICHEIGHT);
	m_Prop[PROP_FABRIC_HEIGHT].SetMinVal((real)0.01);
	m_Prop[PROP_FABRIC_HEIGHT].SetMin(1);

	m_Prop[PROP_FABRIC_ROUGH].SetName("Roughness");
	m_Prop[PROP_FABRIC_ROUGH].SetValue((real)0.5);
	m_Prop[PROP_FABRIC_ROUGH].SetToolID(ID_PROP_ROUGHNESS2);

	m_Prop[PROP_FABRIC_EMBOSS].SetName("Emboss");
	m_Prop[PROP_FABRIC_EMBOSS].SetValue(1);
	m_Prop[PROP_FABRIC_EMBOSS].SetToolID(ID_PROP_EMBOSS);

	m_Prop[PROP_FABRIC_SEED].SetName("Seed");
	m_Prop[PROP_FABRIC_SEED].SetMax(1000);
	m_Prop[PROP_FABRIC_SEED].SetToolID(ID_PROP_SEED);

	m_Interval1.Prop(PROP_INT_MIN)->SetValue((real)0.5);
	
	m_Interval2.Prop(PROP_INT_MIN)->SetValue((real)0.5);
	m_Interval2.Prop(PROP_INT_MAX)->SetValue((real)0);
	
	m_Mul.Prop(PROP_SOURCE2)->SetValue((real)0.5);
	
	m_Wood.Prop(PROP_WOOD_RINGS)->SetValue((real)0.03);
	m_Wood.Prop(PROP_WOOD_SMOOTH)->SetValue((real)0.6);
	m_Wood.Prop(PROP_WOOD_DENSITY)->SetValue((real)0.5);
	m_Wood.Prop(PROP_WOOD_ROTATE)->SetUserValue(2);
	
	m_Paving1.Prop(PROP_BRICK_GAP)->SetValue(0);
	m_Paving1.Prop(PROP_BRICK_BEVEL)->SetValue(0);
	m_Paving1.Prop(PROP_BRICK_CORNERS)->SetValue(0);
	m_Paving1.Prop(PROP_BRICK_BOND)->SetUserValue(10);
	m_Paving1.Prop(PROP_BRICK_FILL)->SetValue(0);
	
	m_Paving2.Prop(PROP_BRICK_MORTAR)->SetValue((real)78/255);
	m_Paving2.Prop(PROP_BRICK_GAP)->SetValue(0);
	m_Paving2.Prop(PROP_BRICK_BEVEL)->SetValue((real)0.11);
	m_Paving2.Prop(PROP_BRICK_CORNERS)->SetValue(0);
	m_Paving2.Prop(PROP_BRICK_BOND)->SetUserValue(15);
	m_Paving2.Prop(PROP_BRICK_FILL)->SetValue((real)0.4);

	m_Paving3.Prop(PROP_BRICK_BRICK)->SetValue(1);
	m_Paving3.Prop(PROP_BRICK_MORTAR)->SetValue(0);
	m_Paving3.Prop(PROP_BRICK_GAP)->SetValue(0);
	m_Paving3.Prop(PROP_BRICK_BEVEL)->SetValue((real)0.14);
	m_Paving3.Prop(PROP_BRICK_CORNERS)->SetValue(0);
	m_Paving3.Prop(PROP_BRICK_BOND)->SetUserValue(15);
	m_Paving3.Prop(PROP_BRICK_FILL)->SetValue((real)0.2);

	m_Emboss.Prop(PROP_EMBOSS_DIFFUSE)->SetValue((real)0.15);
	m_Emboss.Prop(PROP_EMBOSS_SPECULAR)->SetValue(0);
	m_Emboss.Prop(PROP_EMBOSS_METAL)->SetValue(0);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterFabric::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Interval1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_FABRIC_ROUGH]);

		m_Interval2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_FABRIC_ROUGH]);

		m_Mul.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_FABRIC_ROUGH]);

		m_Wood.Prop(PROP_SOURCE)->SetFilter(&m_Interval1);
		m_Wood.Prop(PROP_SOURCE2)->SetFilter(&m_Interval2);
		m_Wood.Prop(PROP_WOOD_FIBERS)->SetFilter(&m_Mul);
		m_Wood.Prop(PROP_WOOD_SEED)->CopyLink(&m_Prop[PROP_FABRIC_SEED]);

		m_Paving1.Prop(PROP_BRICK_BRICK)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Paving1.Prop(PROP_BRICK_MORTAR)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Paving1.Prop(PROP_BRICK_WIDTH)->CopyLink(&m_Prop[PROP_FABRIC_WIDTH]);
		m_Paving1.Prop(PROP_BRICK_HEIGHT)->CopyLink(&m_Prop[PROP_FABRIC_HEIGHT]);

		m_Paving2.Prop(PROP_BRICK_BRICK)->SetFilter(&m_Wood);
		m_Paving2.Prop(PROP_BRICK_WIDTH)->CopyLink(&m_Prop[PROP_FABRIC_WIDTH]);
		m_Paving2.Prop(PROP_BRICK_HEIGHT)->CopyLink(&m_Prop[PROP_FABRIC_HEIGHT]);
		m_Paving2.Prop(PROP_BRICK_SEED)->CopyLink(&m_Prop[PROP_FABRIC_SEED]);

		m_Paving3.Prop(PROP_BRICK_WIDTH)->CopyLink(&m_Prop[PROP_FABRIC_WIDTH]);
		m_Paving3.Prop(PROP_BRICK_HEIGHT)->CopyLink(&m_Prop[PROP_FABRIC_HEIGHT]);

		m_Level.Prop(PROP_SOURCE)->SetFilter(&m_Paving1);
		m_Level.Prop(PROP_LEVEL_BRIGHT)->SetFilter(&m_Paving2);

		m_Emboss.Prop(PROP_SOURCE)->SetFilter(&m_Level);
		m_Emboss.Prop(PROP_EMBOSS_HEIGHTMAP)->SetFilter(&m_Paving3);

		m_Blend.Prop(PROP_SOURCE)->SetFilter(&m_Level);
		m_Blend.Prop(PROP_SOURCE2)->SetFilter(&m_Emboss);
		m_Blend.Prop(PROP_BLEND_OPACITY)->CopyLink(&m_Prop[PROP_FABRIC_EMBOSS]);

		m_Wood.Restart();
	}

	m_Blend.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterFabric::RenderVal(real x, real y)
{
	CColor col;
	CFilterFabric::RenderCol(&col, x, y);
	return col.Gray();
}
