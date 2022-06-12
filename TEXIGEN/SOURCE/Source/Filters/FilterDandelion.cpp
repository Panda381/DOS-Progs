					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Dandelion Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDandelion::CFilterDandelion()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Dandelion");
	m_HelpID = HELP_FDANDELION;
	m_PropNum = 7;

	m_Prop[PROP_SOURCE].SetName("ColorLt");
	m_Prop[PROP_SOURCE].SetColor(1, 1, 0);

	m_Prop[PROP_SOURCE2].SetName("ColorDk");
	m_Prop[PROP_SOURCE2].SetColor((real)149/255, (real)149/255, 0);

	m_Prop[PROP_DAND_BACK].SetName("Background");
	m_Prop[PROP_DAND_BACK].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_DAND_BACK].SetColor(1, 1, 0, 0);

	m_Prop[PROP_DAND_DETAILS].SetName("Details");
	m_Prop[PROP_DAND_DETAILS].SetMinVal((real)0.5);
	m_Prop[PROP_DAND_DETAILS].SetUserValue(50);
	m_Prop[PROP_DAND_DETAILS].SetToolID(ID_PROP_ROSEDETAILS);

	m_Prop[PROP_DAND_RAYS].SetName("Rays");
	m_Prop[PROP_DAND_RAYS].SetValue((real)0.4);
	m_Prop[PROP_DAND_RAYS].SetToolID(ID_PROP_DANDRAYS);

	m_Prop[PROP_DAND_BEVEL].SetName("Bevel");
	m_Prop[PROP_DAND_BEVEL].SetValue((real)0.15);
	m_Prop[PROP_DAND_BEVEL].SetToolID(ID_PROP_BEVEL);

	m_Prop[PROP_DAND_SEED].SetName("Seed");
	m_Prop[PROP_DAND_SEED].SetMax(1000);
	m_Prop[PROP_DAND_SEED].SetToolID(ID_PROP_SEED);

	m_Star.Prop(PROP_STAR_RADIUS)->SetValue((real)0.5);
	m_Star.Prop(PROP_STAR_STUFFING)->SetValue((real)0.75);
	m_Star.Prop(PROP_STAR_SMOOTH)->SetValue(1);
	m_Cellular.Prop(PROP_CELLULAR_SQUEEZE)->SetUserValue(40);
	m_Round.Prop(PROP_BOX_WIDTH)->SetValue((real)0.4);
	m_Round.Prop(PROP_BOX_HEIGHT)->SetValue((real)0.4);
	m_Round.Prop(PROP_BOX_BEVEL)->SetValue((real)0.75);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDandelion::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Star.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Star.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_DAND_BACK]);
		m_Star.Prop(PROP_STAR_RAYS)->CopyLink(&m_Prop[PROP_DAND_RAYS]);
		m_Star.Prop(PROP_STAR_BEVEL)->CopyLink(&m_Prop[PROP_DAND_BEVEL]);

		m_Cellular.Prop(PROP_CELLULAR_SCALE)->CopyLink(&m_Prop[PROP_DAND_DETAILS]);
		m_Cellular.Prop(PROP_CELLULAR_SEED)->CopyLink(&m_Prop[PROP_DAND_SEED]);

		m_Polar.Prop(PROP_SOURCE)->SetFilter(&m_Cellular);

		m_Switch2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Switch2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Switch2.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Polar);

		m_Blend.Prop(PROP_SOURCE)->SetFilter(&m_Star);
		m_Blend.Prop(PROP_SOURCE2)->SetFilter(&m_Switch2);
		m_Blend.Prop(PROP_BLEND_OPACITY)->SetFilter(&m_Round);

		m_Cut.Prop(PROP_SOURCE)->SetFilter(&m_Blend);
		m_Cut.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_DAND_BACK]);
	}

	m_Cut.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDandelion::RenderVal(real x, real y)
{
	CColor col;
	CFilterDandelion::RenderCol(&col, x, y);
	return col.Gray();
}
