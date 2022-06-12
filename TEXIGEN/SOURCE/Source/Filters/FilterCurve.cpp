		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                              Curve generators
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLinear::CFilterLinear()
{
	m_Group = FGRP_CUR;
	m_Class = _T("Linear");
	m_HelpID = HELP_FLINEAR;
	m_PropNum = 4;
	m_Category = FCAT_CURVE;

	m_Prop[PROP_CURVE_BEG].SetName("Begin");
	m_Prop[PROP_CURVE_BEG].SetToolID(ID_PROP_CURBEG);

	m_Prop[PROP_CURVE_END].SetName("End");
	m_Prop[PROP_CURVE_END].SetValue(1);
	m_Prop[PROP_CURVE_END].SetToolID(ID_PROP_CUREND);

	m_Prop[PROP_CURVE_MIN].SetName("Min");
	m_Prop[PROP_CURVE_MIN].SetToolID(ID_PROP_CURMIN);

	m_Prop[PROP_CURVE_MAX].SetName("Max");
	m_Prop[PROP_CURVE_MAX].SetValue(1);
	m_Prop[PROP_CURVE_MAX].SetToolID(ID_PROP_CURMAX);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLinear::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLinear::RenderVal(real x, real y)
{
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	x = CLAMP((x - beg)/(end - beg));
	return x*(max - min) + min;
}

// default linear curve
CFilterLinear	FLinear;

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSquare::CFilterSquare()
{
	m_Class = _T("Square");
	m_HelpID = HELP_FSQUARE;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSquare::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSquare::RenderVal(real x, real y)
{
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	x = CLAMP((x - beg)/(end - beg));
	return x*x*(max - min) + min;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSquareRoot::CFilterSquareRoot()
{
	m_Class = _T("SquareRoot");
	m_HelpID = HELP_FSQUAREROOT;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSquareRoot::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSquareRoot::RenderVal(real x, real y)
{
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	x = CLAMP((x - beg)/(end - beg));
	return sqrt(x)*(max - min) + min;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterArc::CFilterArc()
{
	m_Class = _T("Arc");
	m_HelpID = HELP_FARC;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterArc::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterArc::RenderVal(real x, real y)
{
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	x = 1 - CLAMP((x - beg)/(end - beg));
	return sqrt(1 - x*x)*(max - min) + min;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterInvArc::CFilterInvArc()
{
	m_Class = _T("InvArc");
	m_HelpID = HELP_FINVARC;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterInvArc::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterInvArc::RenderVal(real x, real y)
{
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	x = CLAMP((x - beg)/(end - beg));
	return (1 - sqrt(1 - x*x))*(max - min) + min;
}

#define PROP_CURPWR_POWER	4	// property - Power (power value 0..1; 0=pow(1/8),0.5=pow(1),1=pow(8); default 0.8)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterPower::CFilterPower()
{
	m_Class = _T("Power");
	m_HelpID = HELP_FPOWER;
	m_PropNum = 5;

	m_Prop[PROP_CURPWR_POWER].SetName("Power");
	m_Prop[PROP_CURPWR_POWER].SetValue((real)0.8);
	m_Prop[PROP_CURPWR_POWER].SetToolID(ID_PROP_CURPOWER);
	m_Prop[PROP_CURPWR_POWER].SetMin(-50);
	m_Prop[PROP_CURPWR_POWER].SetMax(50);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterPower::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterPower::RenderVal(real x, real y)
{
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real pwr = pow(2,(m_Prop[PROP_CURPWR_POWER].RenderVal(x, y)-(real)0.5)*6);
	x = CLAMP((x - beg)/(end - beg));
	return pow(x,pwr)*(max - min) + min;
}

#define PROP_CURGAUS_WIDTH	4	// property - Width (width 0..1; 0=narrow..1=wide; default 0.9)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGaussian::CFilterGaussian()
{
	m_Class = _T("Gaussian");
	m_HelpID = HELP_FGAUSSIAN;
	m_PropNum = 5;

	m_Prop[PROP_CURGAUS_WIDTH].SetName("Width");
	m_Prop[PROP_CURGAUS_WIDTH].SetValue((real)0.9);
	m_Prop[PROP_CURGAUS_WIDTH].SetToolID(ID_PROP_GAUSSWIDTH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGaussian::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGaussian::RenderVal(real x, real y)
{
	// load properties
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real pwr = pow(2,(1-CLAMP(m_Prop[PROP_CURGAUS_WIDTH].RenderVal(x, y)))*10)*10;

	// render curve
	x = CLAMP((x - beg)/(end - beg));
	x = x - (real)0.5;
	x *= x;
	x = exp(-x*pwr);
	return x*(max - min) + min;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBias::CFilterBias()
{
	m_Class = _T("Bias");
	m_HelpID = HELP_FBIAS;
	m_PropNum = 5;

	m_Prop[PROP_CURBIAS_BIAS].SetName("Bias");
	m_Prop[PROP_CURBIAS_BIAS].SetValue((real)0.2);
	m_Prop[PROP_CURBIAS_BIAS].SetMin(-50);
	m_Prop[PROP_CURBIAS_BIAS].SetMax(50);
	m_Prop[PROP_CURBIAS_BIAS].SetToolID(ID_PROP_CURBIAS);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterBias::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBias::RenderVal(real x, real y)
{
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real t = m_Prop[PROP_CURBIAS_BIAS].RenderVal(x, y);
	x = CLAMP((x - beg)/(end - beg));
	if (t <= (real)0.001) t = (real)0.001;
	if (t >= (real)0.999) t = (real)0.999;
	return (x/((1/t-2)*(1-x)+1))*(max - min) + min;
}

#define PROP_CURGAIN_GAIN	4	// property - Gain (0..1; default 0.8)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGain::CFilterGain()
{
	m_Class = _T("Gain");
	m_HelpID = HELP_FGAIN;
	m_PropNum = 5;

	m_Prop[PROP_CURGAIN_GAIN].SetName("Gain");
	m_Prop[PROP_CURGAIN_GAIN].SetValue((real)0.8);
	m_Prop[PROP_CURGAIN_GAIN].SetMin(-50);
	m_Prop[PROP_CURGAIN_GAIN].SetMax(50);
	m_Prop[PROP_CURGAIN_GAIN].SetToolID(ID_PROP_CURGAIN);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGain::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGain::RenderVal(real x, real y)
{
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real t = 1 - m_Prop[PROP_CURGAIN_GAIN].RenderVal(x, y);
	x = CLAMP((x - beg)/(end - beg));
	if (t <= (real)0.001) t = (real)0.001;
	if (t >= (real)0.999) t = (real)0.999;
	if (x < 0.5)
		t = x/((1/t-2)*(1-2*x)+1);
	else
		t = ((1/t-2)*(1-2*x)-x)/((1/t-2)*(1-2*x)-1);
	return t*(max - min) + min;
}

#define PROP_CURIMP_BALANCE	4	// property - Balance (0..1; center position 0=left..1=right; default 0.5)
#define PROP_CURIMP_PLATEAU	5	// property - Plateau (0..1; plateau width; default 0)
#define PROP_CURIMP_SLOPE1	6	// property - Slope1 (0..1; left slope; default 0.15)
#define PROP_CURIMP_SLOPE2	7	// property - Slope2 (0..1; right slope; default 0.15)
#define PROP_CURIMP_SMOOTH	8	// property - Smooth (0..1; 0=sharp..1=smooth; default 0)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterImpulse::CFilterImpulse()
{
	m_Class = _T("Impulse");
	m_HelpID = HELP_FIMPULSE;
	m_PropNum = 9;

	m_Prop[PROP_CURIMP_BALANCE].SetName("Balance");
	m_Prop[PROP_CURIMP_BALANCE].SetValue((real)0.5);
	m_Prop[PROP_CURIMP_BALANCE].SetMin(-50);
	m_Prop[PROP_CURIMP_BALANCE].SetMax(50);
	m_Prop[PROP_CURIMP_BALANCE].SetToolID(ID_PROP_CURBALANCE);

	m_Prop[PROP_CURIMP_PLATEAU].SetName("Plateau");
	m_Prop[PROP_CURIMP_PLATEAU].SetToolID(ID_PROP_CURPLATEAU);

	m_Prop[PROP_CURIMP_SLOPE1].SetName("Slope1");
	m_Prop[PROP_CURIMP_SLOPE1].SetValue((real)0.15);
	m_Prop[PROP_CURIMP_SLOPE1].SetMin(-50);
	m_Prop[PROP_CURIMP_SLOPE1].SetMax(50);
	m_Prop[PROP_CURIMP_SLOPE1].SetToolID(ID_PROP_CURSLOPE1);

	m_Prop[PROP_CURIMP_SLOPE2].SetName("Slope2");
	m_Prop[PROP_CURIMP_SLOPE2].SetValue((real)0.15);
	m_Prop[PROP_CURIMP_SLOPE2].SetMin(-50);
	m_Prop[PROP_CURIMP_SLOPE2].SetMax(50);
	m_Prop[PROP_CURIMP_SLOPE2].SetToolID(ID_PROP_CURSLOPE2);

	m_Prop[PROP_CURIMP_SMOOTH].SetName("Smooth");
	m_Prop[PROP_CURIMP_SMOOTH].SetToolID(ID_PROP_CURSMOOTH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterImpulse::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterImpulse::RenderVal(real x, real y)
{
	// load properties
	real beg = CLAMP(m_Prop[PROP_CURVE_BEG].RenderVal(x, y));
	real end = CLAMP(m_Prop[PROP_CURVE_END].RenderVal(x, y));
	real min = CLAMP(m_Prop[PROP_CURVE_MIN].RenderVal(x, y));
	real max = CLAMP(m_Prop[PROP_CURVE_MAX].RenderVal(x, y));
	real bal = CLAMP(m_Prop[PROP_CURIMP_BALANCE].RenderVal(x, y));
	real plat = CLAMP(m_Prop[PROP_CURIMP_PLATEAU].RenderVal(x, y));
	real slope1 = CLAMP(m_Prop[PROP_CURIMP_SLOPE1].RenderVal(x, y));
	real slope2 = CLAMP(m_Prop[PROP_CURIMP_SLOPE2].RenderVal(x, y));
	real smooth = m_Prop[PROP_CURIMP_SMOOTH].RenderVal(x, y);

	// X coordinate
	if (end <= beg + (real)0.0001) end = beg + (real)0.0001;
	real w0 = end - beg;
	x = CLAMP((x - beg)/w0) * w0;

	// subtract plateau
	real w = w0 * (1 - plat);
	if (w <= 0) return max;

	// width of left slope using balance
	real w1 = bal*w;

	// mirror right slope to the left
	if (x >= w1)
	{
		x -= w1 + plat*w0;
		if (x <= 0) return max;
		w1 = w - w1;
		x = w1 - x;
		slope1 = slope2;
	}
	x /= w1;

	// bias
	x = x/((1/slope1-2)*(1-x)+1);

	// remap to smooth
	real x2 = (1 - cos(x*PI))/2;

	// smooth
	x = smooth*x2 + (1 - smooth)*x;

	return x*(max - min) + min;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterStairs::CFilterStairs()
{
	m_Class = _T("Stairs");
	m_HelpID = HELP_FSTAIRS;
	m_PropNum = 6;

	m_Prop[PROP_CURSTAIRS_STEPS].SetName("Steps");
	m_Prop[PROP_CURSTAIRS_STEPS].SetValue((real)0.05);
	m_Prop[PROP_CURSTAIRS_STEPS].SetToolID(ID_PROP_CURSTEPS);
	m_Prop[PROP_CURSTAIRS_STEPS].SetMinVal((real)0.01);
	m_Prop[PROP_CURSTAIRS_STEPS].SetMin(1);

	m_Prop[PROP_CURSTAIRS_SMOOTH].SetName("Smooth");
	m_Prop[PROP_CURSTAIRS_SMOOTH].SetToolID(ID_PROP_CURSMOOTH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterStairs::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterStairs::RenderVal(real x, real y)
{
	// load properties
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real k = m_Prop[PROP_CURSTAIRS_STEPS].RenderVal(x, y);
	real smooth = CLAMP(m_Prop[PROP_CURSTAIRS_SMOOTH].RenderVal(x, y));
	x = CLAMP((x - beg)/(end - beg));

	// clamp steps to 1..100
	if (k <= 0.01) k = (real)0.01;
	if (k >= 1) k = 1;
	int steps = (int)(k*100 + (real)0.5);

	// render stairs
	x *= steps+(real)0.99999;
	x -= smooth/2;
	smooth = 1 - smooth;
	real x0 = floor(x);
	x -= x0;
	if ((x >= smooth) && (smooth < 1)) x0 += (1 - cos((x-smooth)/(1-smooth)*PI))/2;
	if (x0 <= 0) x0 = 0;
	x = x0 / steps;
	if (x >= 1) x = 1;
	return x*(max - min) + min;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterNoise::CFilterNoise()
{
	m_Class = _T("Noise");
	m_HelpID = HELP_FNOISE;
	m_PropNum = 9;

	m_Prop[PROP_CURNOI_DETAILS].SetName("Details");
	m_Prop[PROP_CURNOI_DETAILS].SetMinVal((real)0.1);
	m_Prop[PROP_CURNOI_DETAILS].SetMin(1);
	m_Prop[PROP_CURNOI_DETAILS].SetMax(10);
	m_Prop[PROP_CURNOI_DETAILS].SetValue((real)0.5);
	m_Prop[PROP_CURNOI_DETAILS].SetToolID(ID_PROP_DETAILS);

	m_Prop[PROP_CURNOI_ROUGHNESS].SetName("Roughness");
	m_Prop[PROP_CURNOI_ROUGHNESS].SetValue((real)0.5);
	m_Prop[PROP_CURNOI_ROUGHNESS].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_CURNOI_SCALE].SetName("Scale");
	m_Prop[PROP_CURNOI_SCALE].SetValue((real)0.5);
	m_Prop[PROP_CURNOI_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_CURNOI_SHIFT].SetName("Shift");
	m_Prop[PROP_CURNOI_SHIFT].SetValue((real)0.5);
	m_Prop[PROP_CURNOI_SHIFT].SetMin(-50);
	m_Prop[PROP_CURNOI_SHIFT].SetMax(50);
	m_Prop[PROP_CURNOI_SHIFT].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_CURNOI_SEED].SetName("Seed");
	m_Prop[PROP_CURNOI_SEED].SetMax(1000);
	m_Prop[PROP_CURNOI_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterNoise::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterNoise::RenderVal(real x, real y)
{
	// load properties
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	int seed = (int)(m_Prop[PROP_CURNOI_SEED].RenderVal(x, y)*1000 + (real)0.5 + 11);
	real details = CLAMP(m_Prop[PROP_CURNOI_DETAILS].RenderVal(x, y));
	real roughness = m_Prop[PROP_CURNOI_ROUGHNESS].RenderVal(x, y);
	int scale = (int)(pow(2,CLAMP(1-m_Prop[PROP_CURNOI_SCALE].RenderVal(x, y))*8)+(real)0.5);

	// contrast correction from roughness
	real contrast = (real)0.5;
	contrast /= (real)(roughness*roughness*1.5+0.5);

	// render curve
	real x2 = CLAMP((x - beg)/(end - beg));
	x = x2 - m_Prop[PROP_CURNOI_SHIFT].RenderVal(x, y);
	scale++;
	real val = 0;
	int bands = (int)(details*10+0.5);
	if (bands < 1) bands = 1;
	for (; bands > 0; bands--)
	{
		real val1 = SmoothNoise1D(x, scale, seed);
		val += val1 * contrast;

		scale *= 2;

		contrast *= roughness;
		roughness *= (real)1.1;
		seed += 5;
	}

	val = CLAMP(val/2 + (real)0.5);

	return val*(max - min) + min;
}

#define PROP_CITY_WAVES			4		// property - Waves
#define PROP_CITY_CHAOS			5		// property - Chaos
#define PROP_CITY_SEED			6		// property - Chaos

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterCity::CFilterCity()
{
	m_Class = _T("City");
	m_HelpID = HELP_FCITY;
	m_PropNum = 7;

	m_Prop[PROP_CITY_WAVES].SetName("Waves");
	m_Prop[PROP_CITY_WAVES].SetValue((real)0.10);
	m_Prop[PROP_CITY_WAVES].SetToolID(ID_PROP_WAVES);

	m_Prop[PROP_CITY_CHAOS].SetName("Chaos");
	m_Prop[PROP_CITY_CHAOS].SetValue(0);
	m_Prop[PROP_CITY_CHAOS].SetToolID(ID_PROP_CITYCHAOS);

	m_Prop[PROP_CITY_SEED].SetName("Seed");
	m_Prop[PROP_CITY_SEED].SetMax(1000);
	m_Prop[PROP_CITY_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterCity::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCity::RenderVal(real x, real y)
{
	// load properties
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real waves = m_Prop[PROP_CITY_WAVES].RenderVal(x, y);
	real chaos = CLAMP(m_Prop[PROP_CITY_CHAOS].RenderVal(x, y));
	int seed = (int)(m_Prop[PROP_CITY_SEED].RenderVal(x, y)*1000 + (real)0.5 + 7);

	// render curve
	x = CLAMP((x - beg)/(end - beg));
	real k = x*waves*100;
	int n = (int)k;
	k -= n;
	real slide = Noise1D(n, seed+1572)/2*chaos + (real)0.5;
	real val = Noise1D(n + ((k > slide) ? 1 : 0), seed);
	val = CLAMP(val/2 + (real)0.5);
	return val*(max - min) + min;
}

#define PROP_CURWAV_WAVES	4	// property - Waves (number of waves/100 0..1; 0.1=1 wave...1=100 waves; default 0.05)
#define PROP_CURWAV_SHIFT	5	// property - Shift (0..1 = shift to left or right edge, default 0.5)
#define PROP_CURWAV_RANDA	6	// property - RandA (randomize amplitude 0..1: 0=none..1=random; default 1)
#define PROP_CURWAV_SLOPE	7	// property - Slope (0..1; default 0.5)
#define PROP_CURWAV_SMOOTH	8	// property - Smooth (0..1; 0=sharp..1=smooth; default 1)
#define PROP_CURWAV_SEED	9	// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// sine: randa=0, slope=0.5, smooth=1
// triangle: randa=0, slope=0.5, smooth=0
// bounce: randa=0, slope=0.75, smooth=1
// peaks: randa=0, slope=0.15, smooth=1

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterWave::CFilterWave()
{
	m_Class = _T("Wave");
	m_HelpID = HELP_FWAVE;
	m_PropNum = 10;

	m_Prop[PROP_CURWAV_WAVES].SetName("Waves");
	m_Prop[PROP_CURWAV_WAVES].SetValue((real)0.05);
	m_Prop[PROP_CURWAV_WAVES].SetToolID(ID_PROP_WAVES);

	m_Prop[PROP_CURWAV_SHIFT].SetName("Shift");
	m_Prop[PROP_CURWAV_SHIFT].SetValue((real)0.5);
	m_Prop[PROP_CURWAV_SHIFT].SetMin(-50);
	m_Prop[PROP_CURWAV_SHIFT].SetMax(50);
	m_Prop[PROP_CURWAV_SHIFT].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_CURWAV_RANDA].SetName("Amplitude");
	m_Prop[PROP_CURWAV_RANDA].SetToolID(ID_PROP_RANDA);

	m_Prop[PROP_CURWAV_SLOPE].SetName("Slope");
	m_Prop[PROP_CURWAV_SLOPE].SetValue((real)0.5);
	m_Prop[PROP_CURWAV_SLOPE].SetMin(-50);
	m_Prop[PROP_CURWAV_SLOPE].SetMax(50);
	m_Prop[PROP_CURWAV_SLOPE].SetToolID(ID_PROP_CURSLOPE);

	m_Prop[PROP_CURWAV_SMOOTH].SetName("Smooth");
	m_Prop[PROP_CURWAV_SMOOTH].SetValue((real)1);
	m_Prop[PROP_CURWAV_SMOOTH].SetToolID(ID_PROP_CURSMOOTH);

	m_Prop[PROP_CURWAV_SEED].SetName("Seed");
	m_Prop[PROP_CURWAV_SEED].SetMax(1000);
	m_Prop[PROP_CURWAV_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterWave::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterWave::RenderVal(real x, real y)
{
	// load properties
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real waves = m_Prop[PROP_CURWAV_WAVES].RenderVal(x, y) * 100;
	real randa = m_Prop[PROP_CURWAV_RANDA].RenderVal(x, y);
	int seed = (int)(m_Prop[PROP_CURWAV_SEED].RenderVal(x, y)*1000 + (real)0.5 + 5);
	real slope = CLAMP(m_Prop[PROP_CURWAV_SLOPE].RenderVal(x, y));
	real smooth = m_Prop[PROP_CURWAV_SMOOTH].RenderVal(x, y);
	real xx = CLAMP((x - beg)/(end - beg));
	x = xx - (m_Prop[PROP_CURWAV_SHIFT].RenderVal(x, y)-(real)0.5)/((waves > 1) ? waves : 1);
	waves *= 2;
	int scale = (int)(waves+(real)0.99999);
	if (scale < 2) scale = 2;

	// prepare X
	x *= waves;
	int x0 = (int)floor(x);
	x -= x0;
	int x1 = x0 % scale;
	if (x1 < 0) x1 += scale;
	int x2 = (x1 + 1) % scale;

	// random peaks
	real k1 = Noise1D(x1, seed)/4;
	real k2 = Noise1D(x2, seed)/4;

	// rising slope
	real k;
	if ((x0 & 1) == 0)
	{
		k1 += (real)0.25;
		k2 += (real)0.75;
		k1 = randa*k1;
		k2 = 1 - randa*(1 - k2);
		k = x/((1/slope-2)*(1-x)+1);
	}
	// falling slope
	else
	{
		k1 += (real)0.75;
		k2 += (real)0.25;
		k1 = 1 - randa*(1 - k1);
		k2 = randa*k2;
		k = 1 - (1-x)/((1/slope-2)*x+1);
	}

	// remap to smooth sinusoid
	real k3 = (1 - cos(k*PI))/2;

	// smooth
	k = smooth*k3 + (1 - smooth)*k;

	// shift to peaks
	k = k1 + k*(k2 - k1);

	// shift to min and max
	return k*(max - min) + min;
}

#define PROP_CURSAW_WAVES	4	// property - Waves (number of waves/100 0..1; 0.1=1 wave...1=100 waves; default 0.05)
#define PROP_CURSAW_SHIFT	5	// property - Shift (0..1 = shift to left or right edge, default 0.5)
#define PROP_CURSAW_REVERSE	6	// property - Reverse (check - reverse saw)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSaw::CFilterSaw()
{
	m_Class = _T("Saw");
	m_HelpID = HELP_FSAW;
	m_PropNum = 7;

	m_Prop[PROP_CURSAW_WAVES].SetName("Waves");
	m_Prop[PROP_CURSAW_WAVES].SetValue((real)0.05);
	m_Prop[PROP_CURSAW_WAVES].SetToolID(ID_PROP_WAVES);

	m_Prop[PROP_CURSAW_SHIFT].SetName("Shift");
	m_Prop[PROP_CURSAW_SHIFT].SetValue((real)0.5);
	m_Prop[PROP_CURSAW_SHIFT].SetMin(-50);
	m_Prop[PROP_CURSAW_SHIFT].SetMax(50);
	m_Prop[PROP_CURSAW_SHIFT].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_CURSAW_REVERSE].SetCategory(PCAT_CHECK);
	m_Prop[PROP_CURSAW_REVERSE].SetName("Reverse");
	m_Prop[PROP_CURSAW_REVERSE].SetMax(1);
	m_Prop[PROP_CURSAW_REVERSE].SetToolID(ID_PROP_SAWREVERSE);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSaw::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSaw::RenderVal(real x, real y)
{
	// load properties
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real waves = m_Prop[PROP_CURSAW_WAVES].RenderVal(x, y)*100;
	real shft = m_Prop[PROP_CURSAW_SHIFT].RenderVal(x, y) - (real)0.5;
	bool reverse = m_Prop[PROP_CURSAW_REVERSE].RenderVal(x, y) >= 0.5;

	// render curve
	x = CLAMP((x - beg)/(end - beg)) - shft/((waves > 1) ? waves : 1);
	real k = x*waves;
	k -= (int)floor(k);
	if (reverse) k = 1 - k;
	return k*(max - min) + min;
}

#define PROP_CURREC_WAVES	4	// property - Waves (number of waves/100 0..1; 0.1=1 wave...1=100 waves; default 0.05)
#define PROP_CURREC_SHIFT	5	// property - Shift (0..1 = shift to left or right edge, default 0.5)
#define PROP_CURREC_RATIO	6	// property - Ratio (ratio high to low 0..1: 0=minimum,1=maximum; default 0.5)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterRectangle::CFilterRectangle()
{
	m_Class = _T("Rectangle");
	m_HelpID = HELP_FRECTANGLE;
	m_PropNum = 7;

	m_Prop[PROP_CURREC_WAVES].SetName("Waves");
	m_Prop[PROP_CURREC_WAVES].SetValue((real)0.05);
	m_Prop[PROP_CURREC_WAVES].SetToolID(ID_PROP_WAVES);

	m_Prop[PROP_CURREC_SHIFT].SetName("Shift");
	m_Prop[PROP_CURREC_SHIFT].SetValue((real)0.5);
	m_Prop[PROP_CURREC_SHIFT].SetMin(-50);
	m_Prop[PROP_CURREC_SHIFT].SetMax(50);
	m_Prop[PROP_CURREC_SHIFT].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_CURREC_RATIO].SetName("Ratio");
	m_Prop[PROP_CURREC_RATIO].SetValue((real)0.5);
	m_Prop[PROP_CURREC_RATIO].SetToolID(ID_PROP_RATIO);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterRectangle::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterRectangle::RenderVal(real x, real y)
{
	// load properties
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real waves = m_Prop[PROP_CURREC_WAVES].RenderVal(x, y)*100;
	real shft = m_Prop[PROP_CURSAW_SHIFT].RenderVal(x, y) - (real)0.5;
	real ratio = 1 - m_Prop[PROP_CURREC_RATIO].RenderVal(x, y);

	// render curve
	x = CLAMP((x - beg)/(end - beg)) - shft/((waves > 1) ? waves : 1);
	real k = x*waves;
	k -= (int)floor(k);
	k = 1 - 2*abs(k - (real)0.5);
	return (k >= ratio) ? max : min;
}

#define PROP_CURTAB_SMOOTH		4	// property - Smooth (0..1; 0=sharp..1=smooth; default 0.5)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTable::CFilterTable()
{
	m_Class = _T("Table");
	m_HelpID = HELP_FTABLE;
	m_Category = FCAT_TABLE;
	this->SetList(_T("0,100"));
	m_PropNum = 5;

	m_Prop[PROP_CURTAB_SMOOTH].SetName("Smooth");
	m_Prop[PROP_CURTAB_SMOOTH].SetToolID(ID_PROP_CURSMOOTH);
	m_Prop[PROP_CURTAB_SMOOTH].SetValue((real)0.5);
}

///////////////////////////////////////////////////////////////////////////////
// set list

void CFilterTable::SetList(const CText& list)
{
	m_List = list;

	// split list to numbers
	CTextList lst;
	lst.Split(list, TCHAR(','));

	// load list
	int n = lst.Num();
	int i, j;
	CText txt;
	j = 0;
	for (i = 0; (i < n) && (j < TABMAX-1); i++)
	{
		txt = lst[i];
		txt.Trim();
		if (txt.IsNotEmpty())
		{
			m_ListVal[j++] = (real)txt.Double()/100;
		}
	}

	// insufficient numbers
	if (j == 0) m_ListVal[j++] = 0;
	if (j == 1) m_ListVal[j++] = m_ListVal[0];

	m_ListNum = j;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTable::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CFilterTable::RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTable::RenderVal(real x, real y)
{
	// load properties
	real beg = m_Prop[PROP_CURVE_BEG].RenderVal(x, y);
	real end = m_Prop[PROP_CURVE_END].RenderVal(x, y);
	real min = m_Prop[PROP_CURVE_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_CURVE_MAX].RenderVal(x, y);
	real smooth = m_Prop[PROP_CURTAB_SMOOTH].RenderVal(x, y);

	// render curve
	x = CLAMP((x - beg)/(end - beg));
	x *= (m_ListNum-1);
	int k1 = (int)x;
	if (k1 >= m_ListNum-1) k1 = m_ListNum - 2;
	x -= k1;
	int k2 = k1 + 1;
	real a = m_ListVal[k1];
	real b = m_ListVal[k2];
	real x1 = a + (b-a)*x;
	x = (1 - cos(x*PI))/2;
	real x2 = a + (b-a)*x;

	smooth *= 2;
	if (smooth < 1)
		x = x2*smooth + x1*(1-smooth);
	else
	{
		real t = 2 - smooth;
		if (t >= (real)0.9999) t = (real)0.9999;
		if (t <= (real)0.0001) t = (real)0.0001;
		if (x < (real)0.5)
			t = x/((1/t-2)*(1-2*x)+1);
		else
			t = ((1/t-2)*(1-2*x)-x)/((1/t-2)*(1-2*x)-1);
		smooth -= 1;
		real x3 = a + (b-a)*t;
		smooth *= smooth;
		x = x3*smooth + x2*(1-smooth);
	}

	return x*(max - min) + min;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBezier2::CFilterBezier2()
{
	m_Group = FGRP_CUR;
	m_Class = _T("Bezier2");
	m_HelpID = HELP_FBEZIER2;
	m_PropNum = 8;
	m_Category = FCAT_CURVE;

	m_Prop[PROP_BEZIER2_X1].SetName("X1");
	m_Prop[PROP_BEZIER2_X1].SetToolID(ID_PROP_BEZIERX1);

	m_Prop[PROP_BEZIER2_Y1].SetName("Y1");
	m_Prop[PROP_BEZIER2_Y1].SetToolID(ID_PROP_BEZIERY1);

	m_Prop[PROP_BEZIER2_A1].SetName("Angle1");
	m_Prop[PROP_BEZIER2_A1].SetValue((real)0.5);
	m_Prop[PROP_BEZIER2_A1].SetMin(-90);
	m_Prop[PROP_BEZIER2_A1].SetMax(90);
	m_Prop[PROP_BEZIER2_A1].SetToolID(ID_PROP_BEZIERA1);

	m_Prop[PROP_BEZIER2_S1].SetName("Strength1");
	m_Prop[PROP_BEZIER2_S1].SetValue((real)0.25);
	m_Prop[PROP_BEZIER2_S1].SetToolID(ID_PROP_BEZIERS1);

	m_Prop[PROP_BEZIER2_X2].SetName("X2");
	m_Prop[PROP_BEZIER2_X2].SetValue(1);
	m_Prop[PROP_BEZIER2_X2].SetToolID(ID_PROP_BEZIERX3);

	m_Prop[PROP_BEZIER2_Y2].SetName("Y2");
	m_Prop[PROP_BEZIER2_Y2].SetValue(1);
	m_Prop[PROP_BEZIER2_Y2].SetToolID(ID_PROP_BEZIERY3);

	m_Prop[PROP_BEZIER2_A2].SetName("Angle2");
	m_Prop[PROP_BEZIER2_A2].SetValue((real)0.5);
	m_Prop[PROP_BEZIER2_A2].SetMin(-90);
	m_Prop[PROP_BEZIER2_A2].SetMax(90);
	m_Prop[PROP_BEZIER2_A2].SetToolID(ID_PROP_BEZIERA3);

	m_Prop[PROP_BEZIER2_S2].SetName("Strength2");
	m_Prop[PROP_BEZIER2_S2].SetValue((real)0.25);
	m_Prop[PROP_BEZIER2_S2].SetToolID(ID_PROP_BEZIERS3);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterBezier2::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CFilterBezier2::RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBezier2::RenderVal(real x, real y)
{
	// load properties
	real x0 = m_Prop[PROP_BEZIER2_X1].RenderVal(x, y);
	real y0 = m_Prop[PROP_BEZIER2_Y1].RenderVal(x, y);
	if (x <= x0) return y0;
	real x3 = m_Prop[PROP_BEZIER2_X2].RenderVal(x, y);
	if (x3 < x0) x3 = x0;
	real y3 = m_Prop[PROP_BEZIER2_Y2].RenderVal(x, y);
	if (x >= x3) return y3;
	real a1 = (m_Prop[PROP_BEZIER2_A1].RenderVal(x, y) - (real)0.5)*PI;
	real s1 = m_Prop[PROP_BEZIER2_S1].RenderVal(x, y)*2;
	real a2 = (m_Prop[PROP_BEZIER2_A2].RenderVal(x, y) - (real)0.5)*PI;
	real s2 = m_Prop[PROP_BEZIER2_S2].RenderVal(x, y)*2;

	// control points
	real x1 = x0 + cos(a1)*s1;
	real y1 = y0 + sin(a1)*s1;
	real x2 = x3 - cos(a2)*s2;
	real y2 = y3 + sin(a2)*s2;

	// calculate value (simulate t using a few iterations)
	// P0 = (0,0)
	// P3 = (1,1)
	//   w0 = (1-t)*(1-t)*(1-t)
	//   w1 = 3*(1-t)*(1-t)*t
	//   w2 = 3*(1-t)*t*t
	//   w3 = t*t*t;
	//   x = w0*P0x + w1*P1x + w2*P2x + w3*P3x;
	//   y = w0*P0y + w1*P1y + w2*P2y + w3*P3y;
	real t = (x - x0)/(x3 - x0);
	int k;
	for (k = 30; k > 0; k--)
	{
		real xx = (1-t)*(1-t)*(1-t)*x0 + 3*(1-t)*(1-t)*t*x1 + 3*(1-t)*t*t*x2 + t*t*t*x3;
		t -= (xx - x)/6;
	}
	return (1-t)*(1-t)*(1-t)*y0 + 3*(1-t)*(1-t)*t*y1 + 3*(1-t)*t*t*y2 + t*t*t*y3;
}

#define PROP_BEZIER3_X1		0	// property - X1
#define PROP_BEZIER3_Y1		1	// property - Y1
#define PROP_BEZIER3_A1		2	// property - Angle1
#define PROP_BEZIER3_S1		3	// property - Strength1
#define PROP_BEZIER3_X2		4	// property - X2
#define PROP_BEZIER3_Y2		5	// property - Y2
#define PROP_BEZIER3_A2L	6	// property - Angle2L
#define PROP_BEZIER3_S2L	7	// property - Strength2L
#define PROP_BEZIER3_A2R	8	// property - Angle2R
#define PROP_BEZIER3_S2R	9	// property - Strength2R
#define PROP_BEZIER3_X3		10	// property - X3
#define PROP_BEZIER3_Y3		11	// property - Y3
#define PROP_BEZIER3_A3		12	// property - Angle3
#define PROP_BEZIER3_S3		13	// property - Strength3

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBezier3::CFilterBezier3()
{
	m_Group = FGRP_CUR;
	m_Class = _T("Bezier3");
	m_HelpID = HELP_FBEZIER3;
	m_PropNum = 14;
	m_Category = FCAT_CURVE;

	m_Prop[PROP_BEZIER3_X1].SetName("X1");
	m_Prop[PROP_BEZIER3_X1].SetToolID(ID_PROP_BEZIERX1);

	m_Prop[PROP_BEZIER3_Y1].SetName("Y1");
	m_Prop[PROP_BEZIER3_Y1].SetToolID(ID_PROP_BEZIERY1);

	m_Prop[PROP_BEZIER3_A1].SetName("Angle1");
	m_Prop[PROP_BEZIER3_A1].SetValue(1);
	m_Prop[PROP_BEZIER3_A1].SetMin(-90);
	m_Prop[PROP_BEZIER3_A1].SetMax(90);
	m_Prop[PROP_BEZIER3_A1].SetToolID(ID_PROP_BEZIERA1);

	m_Prop[PROP_BEZIER3_S1].SetName("Strength1");
	m_Prop[PROP_BEZIER3_S1].SetValue((real)0.25);
	m_Prop[PROP_BEZIER3_S1].SetToolID(ID_PROP_BEZIERS1);

	m_Prop[PROP_BEZIER3_X2].SetName("X2");
	m_Prop[PROP_BEZIER3_X2].SetValue((real)0.5);
	m_Prop[PROP_BEZIER3_X2].SetToolID(ID_PROP_BEZIERX2);

	m_Prop[PROP_BEZIER3_Y2].SetName("Y2");
	m_Prop[PROP_BEZIER3_Y2].SetValue((real)0.5);
	m_Prop[PROP_BEZIER3_Y2].SetToolID(ID_PROP_BEZIERY2);

	m_Prop[PROP_BEZIER3_A2L].SetName("Angle2L");
	m_Prop[PROP_BEZIER3_A2L].SetValue((real)0.75);
	m_Prop[PROP_BEZIER3_A2L].SetMin(-90);
	m_Prop[PROP_BEZIER3_A2L].SetMax(90);
	m_Prop[PROP_BEZIER3_A2L].SetToolID(ID_PROP_BEZIERA2L);

	m_Prop[PROP_BEZIER3_S2L].SetName("Strength2L");
	m_Prop[PROP_BEZIER3_S2L].SetValue((real)0.25);
	m_Prop[PROP_BEZIER3_S2L].SetToolID(ID_PROP_BEZIERS2L);

	m_Prop[PROP_BEZIER3_A2R].SetName("Angle2R");
	m_Prop[PROP_BEZIER3_A2R].SetValue((real)0.75);
	m_Prop[PROP_BEZIER3_A2R].SetMin(-90);
	m_Prop[PROP_BEZIER3_A2R].SetMax(90);
	m_Prop[PROP_BEZIER3_A2R].SetToolID(ID_PROP_BEZIERA2R);

	m_Prop[PROP_BEZIER3_S2R].SetName("Strength2R");
	m_Prop[PROP_BEZIER3_S2R].SetValue((real)0.25);
	m_Prop[PROP_BEZIER3_S2R].SetToolID(ID_PROP_BEZIERS2R);

	m_Prop[PROP_BEZIER3_X3].SetName("X3");
	m_Prop[PROP_BEZIER3_X3].SetValue(1);
	m_Prop[PROP_BEZIER3_X3].SetToolID(ID_PROP_BEZIERX3);

	m_Prop[PROP_BEZIER3_Y3].SetName("Y3");
	m_Prop[PROP_BEZIER3_Y3].SetValue(1);
	m_Prop[PROP_BEZIER3_Y3].SetToolID(ID_PROP_BEZIERY3);

	m_Prop[PROP_BEZIER3_A3].SetName("Angle3");
	m_Prop[PROP_BEZIER3_A3].SetValue((real)0.5);
	m_Prop[PROP_BEZIER3_A3].SetMin(-90);
	m_Prop[PROP_BEZIER3_A3].SetMax(90);
	m_Prop[PROP_BEZIER3_A3].SetToolID(ID_PROP_BEZIERA3);

	m_Prop[PROP_BEZIER3_S3].SetName("Strength3");
	m_Prop[PROP_BEZIER3_S3].SetValue((real)0.25);
	m_Prop[PROP_BEZIER3_S3].SetToolID(ID_PROP_BEZIERS3);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterBezier3::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CFilterBezier3::RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBezier3::RenderVal(real x, real y)
{
	// load properties
	real x0 = m_Prop[PROP_BEZIER3_X1].RenderVal(x, y);
	real y0 = m_Prop[PROP_BEZIER3_Y1].RenderVal(x, y);
	if (x <= x0) return y0;
	real x3 = m_Prop[PROP_BEZIER3_X3].RenderVal(x, y);
	if (x3 < x0) x3 = x0;
	real y3 = m_Prop[PROP_BEZIER3_Y3].RenderVal(x, y);
	if (x >= x3) return y3;
	real xx = m_Prop[PROP_BEZIER3_X2].RenderVal(x, y);
	if (xx < x0) xx = x0;
	if (xx > x3) xx = x3;
	real yy = m_Prop[PROP_BEZIER3_Y2].RenderVal(x, y);
	real a1, s1, a2, s2;
	if (x >= xx)
	{
		x0 = xx;
		y0 = yy;
		a1 = (m_Prop[PROP_BEZIER3_A2R].RenderVal(x, y) - (real)0.5)*PI;
		s1 = m_Prop[PROP_BEZIER3_S2R].RenderVal(x, y);
		a2 = (m_Prop[PROP_BEZIER3_A3].RenderVal(x, y) - (real)0.5)*PI;
		s2 = m_Prop[PROP_BEZIER3_S3].RenderVal(x, y);
	}
	else
	{
		x3 = xx;
		y3 = yy;
		a1 = (m_Prop[PROP_BEZIER3_A1].RenderVal(x, y) - (real)0.5)*PI;
		s1 = m_Prop[PROP_BEZIER3_S1].RenderVal(x, y);
		a2 = -(m_Prop[PROP_BEZIER3_A2L].RenderVal(x, y) - (real)0.5)*PI;
		s2 = m_Prop[PROP_BEZIER3_S2L].RenderVal(x, y);
	}

	// control points
	real x1 = x0 + cos(a1)*s1;
	real y1 = y0 + sin(a1)*s1;
	real x2 = x3 - cos(a2)*s2;
	real y2 = y3 + sin(a2)*s2;

	// calculate value (simulate t using a few iterations)
	// P0 = (0,0)
	// P3 = (1,1)
	//   w0 = (1-t)*(1-t)*(1-t)
	//   w1 = 3*(1-t)*(1-t)*t
	//   w2 = 3*(1-t)*t*t
	//   w3 = t*t*t;
	//   x = w0*P0x + w1*P1x + w2*P2x + w3*P3x;
	//   y = w0*P0y + w1*P1y + w2*P2y + w3*P3y;
	real t = (x - x0)/(x3 - x0);
	int k;
	for (k = 30; k > 0; k--)
	{
		real xx = (1-t)*(1-t)*(1-t)*x0 + 3*(1-t)*(1-t)*t*x1 + 3*(1-t)*t*t*x2 + t*t*t*x3;
		t -= (xx - x)/6;
	}
	return (1-t)*(1-t)*(1-t)*y0 + 3*(1-t)*(1-t)*t*y1 + 3*(1-t)*t*t*y2 + t*t*t*y3;
}
