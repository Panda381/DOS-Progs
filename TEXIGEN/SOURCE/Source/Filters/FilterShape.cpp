	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Shape Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CText FilterShapeMode[] = {
	CText(_T("Box")),			// 0
	CText(_T("Round Box")),		// 1
	CText(_T("Circle")),		// 2
	CText(_T("Triangle")),		// 3
	CText(_T("Spade")),			// 4
	CText(_T("Heart")),			// 5
	CText(_T("Diamond")),		// 6
	CText(_T("Club")),			// 7
	CText(_T("Droplet")),		// 8
	CText(_T("Star 4")),		// 9
	CText(_T("Star 5")),		// 10
	CText(_T("Star 8")),		// 11
	CText(_T("Pentagon")),		// 12
	CText(_T("Hexagon")),		// 13
	CText(_T("Sun")),			// 14

	CText(_T(""))
};

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterShape::CFilterShape()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Shape");
	m_HelpID = HELP_FSHAPE;
	m_PropNum = 7;

	m_Prop[PROP_SOURCE].SetName("Color");
	m_Prop[PROP_SOURCE].SetValue(1);

	m_Prop[PROP_SOURCE2].SetName("Background");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_BACKGROUND);

	m_Prop[PROP_SHAPE_SHAPE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_SHAPE_SHAPE].SetName("Shape");
	m_Prop[PROP_SHAPE_SHAPE].SetEnum(FilterShapeMode);
	m_Prop[PROP_SHAPE_SHAPE].SetValue((real)0.05);
	m_Prop[PROP_SHAPE_SHAPE].SetToolID(ID_PROP_SHAPEMODE);

	m_Prop[PROP_SHAPE_SIZE].SetName("Size");
	m_Prop[PROP_SHAPE_SIZE].SetValue((real)0.45);
	m_Prop[PROP_SHAPE_SIZE].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_SHAPE_ANGLE].SetName("Angle");
	m_Prop[PROP_SHAPE_ANGLE].SetValue(0.5);
	m_Prop[PROP_SHAPE_ANGLE].SetMin(-180);
	m_Prop[PROP_SHAPE_ANGLE].SetMax(180);
	m_Prop[PROP_SHAPE_ANGLE].SetToolID(ID_PROP_ANGLE2);

	m_Prop[PROP_SHAPE_BEVEL].SetName("Bevel");
	m_Prop[PROP_SHAPE_BEVEL].SetToolID(ID_PROP_BEVEL);

	m_Prop[PROP_SHAPE_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_SHAPE_PROFILE].SetName("Profile");
	m_Prop[PROP_SHAPE_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_SHAPE_PROFILE].SetToolID(ID_PROP_BEVELPROFILE);

	m_Mul.Prop(PROP_SOURCE2)->SetValue((real)0.5);

	m_Box2.Prop(PROP_BOX_CORNERS)->SetValue((real)0.42);

	m_Triangle.Prop(PROP_TRI_X1)->SetValue(0);
	m_Triangle.Prop(PROP_TRI_Y1)->SetValue(0);
	m_Triangle.Prop(PROP_TRI_Y2)->SetValue(1);
	m_Triangle.Prop(PROP_TRI_X3)->SetValue(1);
	m_Triangle.Prop(PROP_TRI_Y3)->SetValue(0);

	m_Star.Prop(PROP_STAR_RAYS)->SetValue((real)0.04);

	m_Star2.Prop(PROP_STAR_RAYS)->SetValue((real)0.05);

	m_Star3.Prop(PROP_STAR_RAYS)->SetValue((real)0.08);

	m_Star4.Prop(PROP_STAR_RAYS)->SetValue((real)0.05);
	m_Star4.Prop(PROP_STAR_STUFFING)->SetValue(1);

	m_Star5.Prop(PROP_STAR_RAYS)->SetValue((real)0.06);
	m_Star5.Prop(PROP_STAR_STUFFING)->SetValue(1);

	m_Star6.Prop(PROP_STAR_RAYS)->SetValue((real)0.32);
	m_Star6.Prop(PROP_STAR_STUFFING)->SetValue((real)0.75);

	m_Mul2.Prop(PROP_SOURCE2)->SetValue(11);

	m_Sub.Prop(PROP_SOURCE2)->SetValue((real)1.05);

	m_Sub2.Prop(PROP_SOURCE2)->SetValue((real)0.55);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterShape::RenderCol(CColor* col, real x, real y)
{
	if (m_Restart)
	{
		// links to other filters need to be set here and not in constructor, otherwise it does not work correctly
		m_Restart = FALSE;

		m_Mul.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);

		m_Box.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Box.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Box.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Box.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Box.Prop(PROP_BOX_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Box.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Box.Prop(PROP_BOX_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Box2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Box2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Box2.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Box2.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Box2.Prop(PROP_BOX_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Box2.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Box2.Prop(PROP_BOX_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Round.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Round.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Round.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Round.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Round.Prop(PROP_BOX_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Round.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Round.Prop(PROP_BOX_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Triangle.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Triangle.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Triangle.Prop(PROP_TRI_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Triangle.Prop(PROP_TRI_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Spade.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Spade.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Spade.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Spade.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Spade.Prop(PROP_BOX_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Spade.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Spade.Prop(PROP_BOX_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Heart.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Heart.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Heart.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Heart.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Heart.Prop(PROP_BOX_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Heart.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Heart.Prop(PROP_BOX_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Diamond.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Diamond.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Diamond.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Diamond.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Diamond.Prop(PROP_BOX_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Diamond.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Diamond.Prop(PROP_BOX_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Club.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Club.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Club.Prop(PROP_BOX_WIDTH)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Club.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Club.Prop(PROP_BOX_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Club.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Club.Prop(PROP_BOX_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Droplet.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Droplet.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Droplet.Prop(PROP_BOX_WIDTH)->SetFilter(&m_Mul);
		m_Droplet.Prop(PROP_BOX_HEIGHT)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Droplet.Prop(PROP_BOX_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Droplet.Prop(PROP_BOX_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Droplet.Prop(PROP_BOX_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Star.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Star.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Star.Prop(PROP_STAR_RADIUS)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Star.Prop(PROP_STAR_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Star.Prop(PROP_STAR_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Star.Prop(PROP_STAR_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Star2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Star2.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Star2.Prop(PROP_STAR_RADIUS)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Star2.Prop(PROP_STAR_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Star2.Prop(PROP_STAR_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Star2.Prop(PROP_STAR_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Star3.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Star3.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Star3.Prop(PROP_STAR_RADIUS)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Star3.Prop(PROP_STAR_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Star3.Prop(PROP_STAR_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Star3.Prop(PROP_STAR_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Star4.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Star4.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Star4.Prop(PROP_STAR_RADIUS)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Star4.Prop(PROP_STAR_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Star4.Prop(PROP_STAR_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Star4.Prop(PROP_STAR_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Star5.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Star5.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Star5.Prop(PROP_STAR_RADIUS)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Star5.Prop(PROP_STAR_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Star5.Prop(PROP_STAR_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Star5.Prop(PROP_STAR_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Star6.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SOURCE]);
		m_Star6.Prop(PROP_SOURCE2)->CopyLink(&m_Prop[PROP_SOURCE2]);
		m_Star6.Prop(PROP_STAR_RADIUS)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);
		m_Star6.Prop(PROP_STAR_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);
		m_Star6.Prop(PROP_STAR_BEVEL)->CopyLink(&m_Prop[PROP_SHAPE_BEVEL]);
		m_Star6.Prop(PROP_STAR_PROFILE)->CopyLink(&m_Prop[PROP_SHAPE_PROFILE]);

		m_Scale.Prop(PROP_SOURCE)->SetFilter(&m_Triangle);
		m_Scale.Prop(PROP_SCALE_SCALE)->CopyLink(&m_Prop[PROP_SHAPE_SIZE]);

		m_Rotate.Prop(PROP_SOURCE)->SetFilter(&m_Scale);
		m_Rotate.Prop(PROP_ROT_ANGLE)->CopyLink(&m_Prop[PROP_SHAPE_ANGLE]);

		m_Mul2.Prop(PROP_SOURCE)->CopyLink(&m_Prop[PROP_SHAPE_SHAPE]);

		m_Sub.Prop(PROP_SOURCE)->SetFilter(&m_Mul2);

		m_Sub2.Prop(PROP_SOURCE)->SetFilter(&m_Mul2);

		m_Sub.Prop(PROP_SOURCE)->SetFilter(&m_Mul2);

		m_Threshold10.Prop(PROP_SOURCE)->SetFilter(&m_Box);
		m_Threshold10.Prop(PROP_SOURCE2)->SetFilter(&m_Box2);
		m_Threshold10.Prop(PROP_SOURCE3)->SetFilter(&m_Round);
		m_Threshold10.Prop(PROP_SOURCE4)->SetFilter(&m_Rotate);
		m_Threshold10.Prop(PROP_SOURCE5)->SetFilter(&m_Spade);
		m_Threshold10.Prop(PROP_SOURCE6)->SetFilter(&m_Heart);
		m_Threshold10.Prop(PROP_SOURCE7)->SetFilter(&m_Diamond);
		m_Threshold10.Prop(PROP_SOURCE8)->SetFilter(&m_Club);
		m_Threshold10.Prop(PROP_SOURCE9)->SetFilter(&m_Droplet);
		m_Threshold10.Prop(PROP_SOURCE10)->SetFilter(&m_Star);
		m_Threshold10.Prop(PROP_THRES10_LEVEL)->SetFilter(&m_Mul2);

		m_Threshold102.Prop(PROP_SOURCE)->SetFilter(&m_Star2);
		m_Threshold102.Prop(PROP_SOURCE2)->SetFilter(&m_Star3);
		m_Threshold102.Prop(PROP_SOURCE3)->SetFilter(&m_Star4);
		m_Threshold102.Prop(PROP_SOURCE4)->SetFilter(&m_Star5);
		m_Threshold102.Prop(PROP_SOURCE5)->SetFilter(&m_Star6);
		m_Threshold102.Prop(PROP_THRES10_LEVEL)->SetFilter(&m_Sub);

		m_Threshold2.Prop(PROP_SOURCE)->SetFilter(&m_Threshold10);
		m_Threshold2.Prop(PROP_SOURCE2)->SetFilter(&m_Threshold102);
		m_Threshold2.Prop(PROP_THRES2_LEVEL)->SetFilter(&m_Sub2);
	}

	m_Threshold2.RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterShape::RenderVal(real x, real y)
{
	CColor col;
	CFilterShape::RenderCol(&col, x, y);
	return col.Gray();
}
