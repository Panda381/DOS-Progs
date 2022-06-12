					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Rose Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRose::CFilterRose()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Rose");
	m_HelpID = HELP_FROSE;
	m_PropNum = 7;

	m_Prop[PROP_SOURCE].SetName("ColorLt");
	m_Prop[PROP_SOURCE].SetColor(1, 0, 0);

	m_Prop[PROP_SOURCE2].SetName("ColorDk");
	m_Prop[PROP_SOURCE2].SetColor((real)89/255, 0, 0);

	m_Prop[PROP_ROSE_BACK].SetName("Background");
	m_Prop[PROP_ROSE_BACK].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_ROSE_BACK].SetColor((real)160/255, 0, 0, 0);

	m_Prop[PROP_ROSE_DETAILS].SetName("Details");
	m_Prop[PROP_ROSE_DETAILS].SetMinVal((real)0.5);
	m_Prop[PROP_ROSE_DETAILS].SetUserValue(40);
	m_Prop[PROP_ROSE_DETAILS].SetToolID(ID_PROP_ROSEDETAILS);

	m_Prop[PROP_ROSE_WARP].SetName("Warp");
	m_Prop[PROP_ROSE_WARP].SetMaxVal((real)0.5);
	m_Prop[PROP_ROSE_WARP].SetUserValue(60);
	m_Prop[PROP_ROSE_WARP].SetToolID(ID_PROP_WARP);

	m_Prop[PROP_ROSE_BEVEL].SetName("Bevel");
	m_Prop[PROP_ROSE_BEVEL].SetValue((real)0.05);
	m_Prop[PROP_ROSE_BEVEL].SetToolID(ID_PROP_BEVEL);

	m_Prop[PROP_ROSE_SEED].SetName("Seed");
	m_Prop[PROP_ROSE_SEED].SetMax(1000);
	m_Prop[PROP_ROSE_SEED].SetToolID(ID_PROP_SEED);

	m_Add.Prop(PROP_SOURCE2)->SetValue((real)0.01);
	m_Perlin1.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.1);
	m_Perlin1.Prop(PROP_NOISE_SCALE)->SetValue((real)0.6);
	m_Perlin2.Prop(PROP_NOISE_DETAILS)->SetValue((real)0.1);
	m_Perlin2.Prop(PROP_NOISE_SCALE)->SetValue((real)0.6);
	m_Cellular.Prop(PROP_CELLULAR_DETAILS)->SetValue((real)0.1);
	m_Cellular.Prop(PROP_CELLULAR_BRIGHT)->SetValue((real)0.6);
	m_Cellular.Prop(PROP_CELLULAR_SQUEEZE)->SetUserValue(-8);
	m_Level1.Prop(PROP_LEVEL_CONTRAST)->SetValue((real)0.2);
	m_Level2.Prop(PROP_LEVEL_CONTRAST)->SetValue((real)0.2);
	m_Round.Prop(PROP_BOX_WIDTH)->SetValue((real)0.5);
	m_Round.Prop(PROP_BOX_HEIGHT)->SetValue((real)0.5);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRose::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Add.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_ROSE_SEED]);

		m_Perlin1.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_ROSE_WARP]);
		m_Perlin1.Prop(PROP_NOISE_SEED)->CopyLink(&m_Prop[PROP_ROSE_SEED]);

		m_Perlin2.Prop(PROP_NOISE_CONTRAST)->CopyLink(&m_Prop[PROP_ROSE_WARP]);
		m_Perlin2.Prop(PROP_NOISE_SEED)->SetFilter(&m_Add);

		m_Cellular.Prop(PROP_CELLULAR_SCALE)->CopyLink(&m_Prop[PROP_ROSE_DETAILS]);
		m_Cellular.Prop(PROP_CELLULAR_SHIFTX)->SetFilter(&m_Perlin1);
		m_Cellular.Prop(PROP_CELLULAR_SHIFTY)->SetFilter(&m_Perlin2);
		m_Cellular.Prop(PROP_CELLULAR_PROFILE)->SetFilter(&m_SquareRoot);
		m_Cellular.Prop(PROP_CELLULAR_SEED)->CopyLink(&m_Prop[PROP_ROSE_SEED]);

		m_Polar.Prop(PROP_SOURCE)->SetFilter(&m_Cellular);

		m_Level1.Prop(PROP_SOURCE)->SetFilter(&m_Perlin1);

		m_Level2.Prop(PROP_SOURCE)->SetFilter(&m_Perlin2);

		m_Switch2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Switch2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Switch2.Prop(PROP_SWITCH2_SWITCH)->SetFilter(&m_Polar);

		m_Round.Prop(PROP_SOURCE)->SetFilter(&m_Switch2);
		m_Round.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_ROSE_BACK]);
		m_Round.Prop(PROP_BOX_SHIFTX)->SetFilter(&m_Level1);
		m_Round.Prop(PROP_BOX_SHIFTY)->SetFilter(&m_Level2);
		m_Round.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_ROSE_BEVEL]);

		m_Cut.Prop(PROP_SOURCE)->SetFilter(&m_Round);
		m_Cut.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_ROSE_BACK]);
	}

	m_Cut.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRose::RenderVal(real x, real y)
{
	CColor col;
	CFilterRose::RenderCol(&col, x, y);
	return col.Gray();
}
