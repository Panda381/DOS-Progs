				   
///////////////////////////////////////////////////////////////////////////////
//
//                             Color Channels Mixer
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROP_MIX_RTOR	1		// property - RtoR (0..1 = R source to R output, default 1 = all)
#define PROP_MIX_RTOG	2		// property - RtoG (0..1 = R source to G output, default 0 = nothing)
#define PROP_MIX_RTOB	3		// property - RtoB (0..1 = R source to B output, default 0 = nothing)
#define PROP_MIX_RTOA	4		// property - RtoA (0..1 = R source to A output, default 0 = nothing)

#define PROP_MIX_GTOR	5		// property - GtoR (0..1 = G source to R output, default 0 = nothing)
#define PROP_MIX_GTOG	6		// property - GtoG (0..1 = G source to G output, default 1 = all)
#define PROP_MIX_GTOB	7		// property - GtoB (0..1 = G source to B output, default 0 = nothing)
#define PROP_MIX_GTOA	8		// property - GtoA (0..1 = G source to A output, default 0 = nothing)

#define PROP_MIX_BTOR	9		// property - BtoR (0..1 = B source to R output, default 0 = nothing)
#define PROP_MIX_BTOG	10		// property - BtoG (0..1 = B source to G output, default 0 = nothing)
#define PROP_MIX_BTOB	11		// property - BtoB (0..1 = B source to B output, default 1 = all)
#define PROP_MIX_BTOA	12		// property - BtoA (0..1 = B source to A output, default 0 = nothing)

#define PROP_MIX_ATOR	13		// property - AtoR (0..1 = A source to R output, default 0 = nothing)
#define PROP_MIX_ATOG	14		// property - AtoG (0..1 = A source to G output, default 0 = nothing)
#define PROP_MIX_ATOB	15		// property - AtoB (0..1 = A source to B output, default 0 = nothing)
#define PROP_MIX_ATOA	16		// property - AtoA (0..1 = A source to A output, default 1 = all)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMixer::CFilterMixer()
{
	m_Group = FGRP_COL;
	m_Class = _T("Mixer");
	m_HelpID = HELP_FMIXER;
	m_PropNum = 17;

	m_Prop[PROP_MIX_RTOR].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_RTOR].SetName("RtoR");
	m_Prop[PROP_MIX_RTOR].SetToolID(ID_PROP_RTOR);
	m_Prop[PROP_MIX_RTOR].SetValue(1);

	m_Prop[PROP_MIX_RTOG].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_RTOG].SetName("RtoG");
	m_Prop[PROP_MIX_RTOG].SetToolID(ID_PROP_RTOG);
	m_Prop[PROP_MIX_RTOG].SetValue(0);

	m_Prop[PROP_MIX_RTOB].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_RTOB].SetName("RtoB");
	m_Prop[PROP_MIX_RTOB].SetToolID(ID_PROP_RTOB);
	m_Prop[PROP_MIX_RTOB].SetValue(0);

	m_Prop[PROP_MIX_RTOA].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_RTOA].SetName("RtoA");
	m_Prop[PROP_MIX_RTOA].SetToolID(ID_PROP_RTOA);
	m_Prop[PROP_MIX_RTOA].SetValue(0);


	m_Prop[PROP_MIX_GTOR].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_GTOR].SetName("GtoR");
	m_Prop[PROP_MIX_GTOR].SetToolID(ID_PROP_GTOR);
	m_Prop[PROP_MIX_GTOR].SetValue(0);

	m_Prop[PROP_MIX_GTOG].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_GTOG].SetName("GtoG");
	m_Prop[PROP_MIX_GTOG].SetToolID(ID_PROP_GTOG);
	m_Prop[PROP_MIX_GTOG].SetValue(1);

	m_Prop[PROP_MIX_GTOB].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_GTOB].SetName("GtoB");
	m_Prop[PROP_MIX_GTOB].SetToolID(ID_PROP_GTOB);
	m_Prop[PROP_MIX_GTOB].SetValue(0);

	m_Prop[PROP_MIX_GTOA].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_GTOA].SetName("GtoA");
	m_Prop[PROP_MIX_GTOA].SetToolID(ID_PROP_GTOA);
	m_Prop[PROP_MIX_GTOA].SetValue(0);


	m_Prop[PROP_MIX_BTOR].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_BTOR].SetName("BtoR");
	m_Prop[PROP_MIX_BTOR].SetToolID(ID_PROP_BTOR);
	m_Prop[PROP_MIX_BTOR].SetValue(0);

	m_Prop[PROP_MIX_BTOG].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_BTOG].SetName("BtoG");
	m_Prop[PROP_MIX_BTOG].SetToolID(ID_PROP_BTOG);
	m_Prop[PROP_MIX_BTOG].SetValue(0);

	m_Prop[PROP_MIX_BTOB].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_BTOB].SetName("BtoB");
	m_Prop[PROP_MIX_BTOB].SetToolID(ID_PROP_BTOB);
	m_Prop[PROP_MIX_BTOB].SetValue(1);

	m_Prop[PROP_MIX_BTOA].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_BTOA].SetName("BtoA");
	m_Prop[PROP_MIX_BTOA].SetToolID(ID_PROP_BTOA);
	m_Prop[PROP_MIX_BTOA].SetValue(0);


	m_Prop[PROP_MIX_ATOR].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_ATOR].SetName("AtoR");
	m_Prop[PROP_MIX_ATOR].SetToolID(ID_PROP_ATOR);
	m_Prop[PROP_MIX_ATOR].SetValue(0);

	m_Prop[PROP_MIX_ATOG].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_ATOG].SetName("AtoG");
	m_Prop[PROP_MIX_ATOG].SetToolID(ID_PROP_ATOG);
	m_Prop[PROP_MIX_ATOG].SetValue(0);

	m_Prop[PROP_MIX_ATOB].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_ATOB].SetName("AtoB");
	m_Prop[PROP_MIX_ATOB].SetToolID(ID_PROP_ATOB);
	m_Prop[PROP_MIX_ATOB].SetValue(0);

	m_Prop[PROP_MIX_ATOA].SetCategory(PCAT_VAL);
	m_Prop[PROP_MIX_ATOA].SetName("AtoA");
	m_Prop[PROP_MIX_ATOA].SetToolID(ID_PROP_ATOA);
	m_Prop[PROP_MIX_ATOA].SetValue(1);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMixer::RenderCol(CColor* col, real x, real y)
{
	// render color
	CColor c;
	m_Prop[PROP_SOURCE].RenderCol(&c, x, y);

	// combine red channel
	real r2r = m_Prop[PROP_MIX_RTOR].RenderVal(x, y);
	real g2r = m_Prop[PROP_MIX_GTOR].RenderVal(x, y);
	real b2r = m_Prop[PROP_MIX_BTOR].RenderVal(x, y);
	real a2r = m_Prop[PROP_MIX_ATOR].RenderVal(x, y);
	col->r = c.r*r2r + c.g*g2r + c.b*b2r + c.a*a2r;

	// combine green channel
	real r2g = m_Prop[PROP_MIX_RTOG].RenderVal(x, y);
	real g2g = m_Prop[PROP_MIX_GTOG].RenderVal(x, y);
	real b2g = m_Prop[PROP_MIX_BTOG].RenderVal(x, y);
	real a2g = m_Prop[PROP_MIX_ATOG].RenderVal(x, y);
	col->g = c.r*r2g + c.g*g2g + c.b*b2g + c.a*a2g;

	// combine blue channel
	real r2b = m_Prop[PROP_MIX_RTOB].RenderVal(x, y);
	real g2b = m_Prop[PROP_MIX_GTOB].RenderVal(x, y);
	real b2b = m_Prop[PROP_MIX_BTOB].RenderVal(x, y);
	real a2b = m_Prop[PROP_MIX_ATOB].RenderVal(x, y);
	col->b = c.r*r2b + c.g*g2b + c.b*b2b + c.a*a2b;

	// combine alpha channel
	real r2a = m_Prop[PROP_MIX_RTOA].RenderVal(x, y);
	real g2a = m_Prop[PROP_MIX_GTOA].RenderVal(x, y);
	real b2a = m_Prop[PROP_MIX_BTOA].RenderVal(x, y);
	real a2a = m_Prop[PROP_MIX_ATOA].RenderVal(x, y);
	col->a = c.r*r2a + c.g*g2a + c.b*b2a + c.a*a2a;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMixer::RenderVal(real x, real y)
{
	CColor col;
	CFilterMixer::RenderCol(&col, x, y);
	return col.Gray();
}
