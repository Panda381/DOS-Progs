					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Sewing Button Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSewingButton::CFilterSewingButton()
{
	m_Group = FGRP_PAT;
	m_Class = _T("SewingButton");
	m_HelpID = HELP_FSEWINGBUTTON;
	m_PropNum = 10;

	m_Prop[PROP_SOURCE].SetName("ColorOut");
	m_Prop[PROP_SOURCE].SetColor(1, 0, 0);

	m_Prop[PROP_SOURCE2].SetName("ColorIn");
	m_Prop[PROP_SOURCE2].SetColor((real)200/255, 0, 0);

	m_Prop[PROP_SEWBTN_BACK].SetName("Background");
	m_Prop[PROP_SEWBTN_BACK].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_SEWBTN_BACK].SetColor(0, 0, 0, 0);

	m_Prop[PROP_SEWBTN_SIZEOUT].SetName("SizeOut");
	m_Prop[PROP_SEWBTN_SIZEOUT].SetValue((real)0.5);
	m_Prop[PROP_SEWBTN_SIZEOUT].SetToolID(ID_PROP_SEWBTN_SIZEOUT);

	m_Prop[PROP_SEWBTN_SIZEIN].SetName("SizeIn");
	m_Prop[PROP_SEWBTN_SIZEIN].SetValue(1);
	m_Prop[PROP_SEWBTN_SIZEIN].SetToolID(ID_PROP_SEWBTN_SIZEIN);

	m_Prop[PROP_SEWBTN_SIZEHOLE].SetName("SizeHole");
	m_Prop[PROP_SEWBTN_SIZEHOLE].SetValue((real)0.2);
	m_Prop[PROP_SEWBTN_SIZEHOLE].SetToolID(ID_PROP_SEWBTN_SIZEHOLE);

	m_Prop[PROP_SEWBTN_BEVELOUT].SetName("BevelOut");
	m_Prop[PROP_SEWBTN_BEVELOUT].SetValue((real)0.2);
	m_Prop[PROP_SEWBTN_BEVELOUT].SetToolID(ID_PROP_SEWBTN_BEVELOUT);

	m_Prop[PROP_SEWBTN_BEVELIN].SetName("BevelIn");
	m_Prop[PROP_SEWBTN_BEVELIN].SetValue((real)0.15);
	m_Prop[PROP_SEWBTN_BEVELIN].SetToolID(ID_PROP_SEWBTN_BEVELIN);

	m_Prop[PROP_SEWBTN_BEVELHOLE].SetName("BevelHole");
	m_Prop[PROP_SEWBTN_BEVELHOLE].SetValue((real)0.2);
	m_Prop[PROP_SEWBTN_BEVELHOLE].SetToolID(ID_PROP_SEWBTN_BEVELHOLE);

	m_Prop[PROP_SEWBTN_DISTHOLE].SetName("DistHole");
	m_Prop[PROP_SEWBTN_DISTHOLE].SetToolID(ID_PROP_SEWBTN_DISTHOLE);
	m_Prop[PROP_SEWBTN_DISTHOLE].SetMaxVal(2);
	m_Prop[PROP_SEWBTN_DISTHOLE].SetUserValue(50);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSewingButton::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Invert.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SEWBTN_BEVELOUT]);

		m_Mul1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SEWBTN_SIZEOUT]);
		m_Mul1.Prop(PROP_SOURCE2)->SetFilter(&m_Invert);

		m_Mul2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SEWBTN_SIZEIN]);
		m_Mul2.Prop(PROP_SOURCE2)->SetFilter(&m_Mul1);

		m_Mul3.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SEWBTN_DISTHOLE]);
		m_Mul3.Prop(PROP_SOURCE2)->SetFilter(&m_Mul2);

		m_Round1.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SEWBTN_BACK]);
		m_Round1.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Round1.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SEWBTN_SIZEHOLE]);
		m_Round1.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SEWBTN_SIZEHOLE]);
		m_Round1.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SEWBTN_BEVELHOLE]);
		m_Round1.Prop(PROP_BOX_PROFILE)->SetFilter(&m_InvArc);

		m_Mirror.Prop(PROP_SOURCE)->SetFilter(&m_Round1);

		m_Inject.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Inject.Prop(PROP_SOURCE2)->SetFilter(&m_Mirror);
		m_Inject.Prop(PROP_INJECT_WIDTH)->SetFilter(&m_Mul3);
		m_Inject.Prop(PROP_INJECT_HEIGHT)->SetFilter(&m_Mul3);

		m_Round2.Prop(PROP_SOURCE)->SetFilter(&m_Inject);
		m_Round2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Round2.Prop(PROP_BOX_WIDTH)->SetFilter(&m_Mul2);
		m_Round2.Prop(PROP_BOX_HEIGHT)->SetFilter(&m_Mul2);
		m_Round2.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SEWBTN_BEVELIN]);
		m_Round2.Prop(PROP_BOX_PROFILE)->SetFilter(&m_InvArc);

		m_Round3.Prop(PROP_SOURCE)->SetFilter(&m_Round2);
		m_Round3.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SEWBTN_BACK]);
		m_Round3.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SEWBTN_SIZEOUT]);
		m_Round3.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SEWBTN_SIZEOUT]);
		m_Round3.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SEWBTN_BEVELOUT]);
		m_Round3.Prop(PROP_BOX_PROFILE)->SetFilter(&m_Arc);

		m_Cut.Prop(PROP_SOURCE)->SetFilter(&m_Round3);
		m_Cut.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SEWBTN_BACK]);
	}

	m_Cut.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSewingButton::RenderVal(real x, real y)
{
	CColor col;
	CFilterSewingButton::RenderCol(&col, x, y);
	return col.Gray();
}
