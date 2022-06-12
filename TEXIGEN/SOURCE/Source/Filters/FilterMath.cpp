				   
///////////////////////////////////////////////////////////////////////////////
//
//                   Mathematical operations (without clamping)
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterInvert::CFilterInvert()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Invert");
	m_HelpID = HELP_FINVERT;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterInvert::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->Invert();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterInvert::RenderVal(real x, real y)
{
	return 1 - m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterNegate::CFilterNegate()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Negate");
	m_HelpID = HELP_FNEGATE;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterNegate::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->Negate();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterNegate::RenderVal(real x, real y)
{
	return -m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterAbs::CFilterAbs()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Abs");
	m_HelpID = HELP_FABS;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterAbs::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->AbsA();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterAbs::RenderVal(real x, real y)
{
	return abs(m_Prop[PROP_SOURCE].RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSqr::CFilterSqr()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Sqr");
	m_HelpID = HELP_FSQR;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSqr::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->Sqr();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSqr::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return val*val;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSqrt::CFilterSqrt()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Sqrt");
	m_HelpID = HELP_FSQRT;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSqrt::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->Sqrt();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSqrt::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return sqrt(abs(val));
}

#define	PROP_GRAN_STEPS	1		// number of breaks (=steps-1) of granularity

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGranularity::CFilterGranularity()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Granularity");
	m_HelpID = HELP_FGRANULARITY;

	m_Prop[PROP_GRAN_STEPS].SetCategory(PCAT_VAL);
	m_Prop[PROP_GRAN_STEPS].SetName("Steps");
	m_Prop[PROP_GRAN_STEPS].SetToolID(ID_PROP_GRANSTEPS);
	m_Prop[PROP_GRAN_STEPS].SetValue((real)0.03);
	m_Prop[PROP_GRAN_STEPS].SetMin(2);
	m_Prop[PROP_GRAN_STEPS].SetMinVal((real)0.02);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGranularity::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_GRAN_STEPS].RenderCol(&c, x, y);
	c.r = (1/(c.r*100));
	c.g = (1/(c.g*100));
	c.b = (1/(c.b*100));
	col->Gran(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGranularity::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	real val2 = m_Prop[PROP_GRAN_STEPS].RenderVal(x, y);
	return GRAN(val, 1/(val2*100));
}

#define	PROP_MOD_STEP	1		// step size

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMod::CFilterMod()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Mod");
	m_HelpID = HELP_FMOD;

	m_Prop[PROP_MOD_STEP].SetCategory(PCAT_VAL);
	m_Prop[PROP_MOD_STEP].SetName("Step");
	m_Prop[PROP_MOD_STEP].SetToolID(ID_PROP_MODSTEP);
	m_Prop[PROP_MOD_STEP].SetValue(0.5);
	m_Prop[PROP_MOD_STEP].SetMin(1);
	m_Prop[PROP_MOD_STEP].SetMinVal((real)0.01);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMod::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_MOD_STEP].RenderCol(&c, x, y);
	c.Add((real)0.01);
	col->ModCol(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMod::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	real val2 = m_Prop[PROP_MOD_STEP].RenderVal(x, y) + (real)0.01;
	return MODUL(val, val2);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterAdd::CFilterAdd()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Add");
	m_HelpID = HELP_FADD;

	m_Prop[PROP_SOURCE2].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE2].SetName("Add");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_ADD);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterAdd::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;

	m_Prop[PROP_SOURCE2].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE2].RenderCol(&c, x, y);
	col->Add(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterAdd::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	real val2 = m_Prop[PROP_SOURCE2].RenderVal(x, y);
	return val + val2;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSub::CFilterSub()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Sub");
	m_HelpID = HELP_FSUB;

	m_Prop[PROP_SOURCE2].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE2].SetName("Subtract");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_SUB);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSub::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_SOURCE2].RenderCol(&c, x, y);
	col->Sub(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSub::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	real val2 = m_Prop[PROP_SOURCE2].RenderVal(x, y);
	return val - val2;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSubInv::CFilterSubInv()
{
	m_Group = FGRP_MATH;
	m_Class = _T("SubInv");
	m_HelpID = HELP_FSUBINV;

	m_Prop[PROP_SOURCE2].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE].SetName("Subtract");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_SUB);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSubInv::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_SOURCE].RenderCol(&c, x, y);
	col->Sub(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSubInv::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE2].RenderVal(x, y);
	real val2 = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return val - val2;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMul::CFilterMul()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Mul");
	m_HelpID = HELP_FMUL;

	m_Prop[PROP_SOURCE2].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE2].SetName("Multiply");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_MUL);
	m_Prop[PROP_SOURCE2].SetValue(1);
	m_Prop[PROP_SOURCE2].SetMax(200);
	m_Prop[PROP_SOURCE2].SetMaxVal(2);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMul::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_SOURCE2].RenderCol(&c, x, y);
	col->Mul(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMul::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	real val2 = m_Prop[PROP_SOURCE2].RenderVal(x, y);
	return val * val2;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDiv::CFilterDiv()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Div");
	m_HelpID = HELP_FDIV;

	m_Prop[PROP_SOURCE2].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE2].SetName("Divisor");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_DIV);
	m_Prop[PROP_SOURCE2].SetValue(1);
	m_Prop[PROP_SOURCE2].SetMin(1);
	m_Prop[PROP_SOURCE2].SetMinVal((real)0.01);
	m_Prop[PROP_SOURCE2].SetMax(200);
	m_Prop[PROP_SOURCE2].SetMaxVal(2);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDiv::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_SOURCE2].RenderCol(&c, x, y);
	col->Div(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDiv::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	real val2 = m_Prop[PROP_SOURCE2].RenderVal(x, y);
	return val / val2;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDivInv::CFilterDivInv()
{
	m_Group = FGRP_MATH;
	m_Class = _T("DivInv");
	m_HelpID = HELP_FDIVINV;

	m_Prop[PROP_SOURCE2].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE2].SetName("Dividend");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_DIV2);
	m_Prop[PROP_SOURCE2].SetValue(1);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDivInv::RenderCol(CColor* col, real x, real y)
{
	CColor c;
	m_Prop[PROP_SOURCE].RenderCol(&c, x, y);
	m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
	col->Div(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDivInv::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	real val2 = m_Prop[PROP_SOURCE2].RenderVal(x, y);
	return val2 / val;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterPow::CFilterPow()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Pow");
	m_HelpID = HELP_FPOW;

	m_Prop[PROP_SOURCE2].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE2].SetName("Exponent");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_EXP);
	m_Prop[PROP_SOURCE2].SetValue(1);
	m_Prop[PROP_SOURCE2].SetMax(200);
	m_Prop[PROP_SOURCE2].SetMaxVal(2);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterPow::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_SOURCE2].RenderCol(&c, x, y);
	col->PowCol(c);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterPow::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	real val2 = m_Prop[PROP_SOURCE2].RenderVal(x, y);
	return pow(val, val2);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSin::CFilterSin()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Sin");
	m_HelpID = HELP_FSIN;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSin::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->SinCol();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSin::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return SINNORM(val);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterCos::CFilterCos()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Cos");
	m_HelpID = HELP_FCOS;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterCos::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->CosCol();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCos::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return COSNORM(val);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLog::CFilterLog()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Log");
	m_HelpID = HELP_FLOG;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLog::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->LogCol();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLog::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return log10(9*val + 1);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterExp::CFilterExp()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Exp");
	m_HelpID = HELP_FEXP;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterExp::RenderCol(CColor* col, real x, real y)
{
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->ExpCol();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterExp::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return (pow(10,val)-1)/9;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterInterval::CFilterInterval()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Interval");
	m_HelpID = HELP_FINTERVAL;
	m_PropNum = 3;

	m_Prop[PROP_INT_MIN].SetName("Min");
	m_Prop[PROP_INT_MIN].SetToolID(ID_PROP_INTMIN);

	m_Prop[PROP_INT_MAX].SetName("Max");
	m_Prop[PROP_INT_MAX].SetValue(1);
	m_Prop[PROP_INT_MAX].SetToolID(ID_PROP_INTMAX);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterInterval::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real min = m_Prop[PROP_INT_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_INT_MAX].RenderVal(x, y);

	// recalc value
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	col->Interval(min, max);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterInterval::RenderVal(real x, real y)
{
	// get properties
	real min = m_Prop[PROP_INT_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_INT_MAX].RenderVal(x, y);

	// recalc value
	return m_Prop[PROP_SOURCE].RenderVal(x, y)*(max - min) + min;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRandom::CFilterRandom()
{
	m_Group = FGRP_MATH;
	m_Class = _T("Random");
	m_HelpID = HELP_FRANDOM;
	m_PropNum = 3;

	m_Prop[PROP_RAND_MIN].SetName("Min");
	m_Prop[PROP_RAND_MIN].SetToolID(ID_PROP_RNDMIN);

	m_Prop[PROP_RAND_MAX].SetName("Max");
	m_Prop[PROP_RAND_MAX].SetValue(1);
	m_Prop[PROP_RAND_MAX].SetToolID(ID_PROP_RNDMAX);

	m_Prop[PROP_RAND_SEED].SetName("Seed");
	m_Prop[PROP_RAND_SEED].SetMax(1000);
	m_Prop[PROP_RAND_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRandom::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CFilterRandom::RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRandom::RenderVal(real x, real y)
{
	real min = m_Prop[PROP_RAND_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_RAND_MAX].RenderVal(x, y);
	int seed = (int)(m_Prop[PROP_RAND_SEED].RenderVal(x, y)*1000 + (real)0.5);
	return (Noise1D(234, seed)/2 + (real)0.5)*(max - min) + min;
}
