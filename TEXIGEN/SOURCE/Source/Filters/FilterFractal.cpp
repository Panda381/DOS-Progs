				   
///////////////////////////////////////////////////////////////////////////////
//
//					                   Fractals
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CText FilterFractalFormula[] = {
	CText(_T("Z^2+C")),			// 0
	CText(_T("Z^3+C")),			// 1
	CText(_T("Z^4+C")),			// 2
	CText(_T("Z^5+C")),			// 3
	CText(_T("Z^6+C")),			// 4
	CText(_T("Z^7+C")),			// 5
	CText(_T("Z^8+C")),			// 6
	CText(_T("Z^9+C")),			// 7
	CText(_T("Z^10+C")),		// 8
	CText(_T("Z^11+C")),		// 9
	CText(_T("Z^12+C")),		// 10
	CText(_T("Z^2-Z+C")),		// 11
	CText(_T("Z^3-Z^2+Z+C")),	// 12
	CText(_T("Z^3+Z+C")),		// 13
	CText(_T("Z*(C+1)-C0*Z^2")),// 14
	CText(_T("Z*(C+1)-C*Z^2")),	// 15
	CText(_T("(Z-1)*(Z+.5)*(Z^2-1)+C")), // 16

	CText(_T(""))
};

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterFractal::CFilterFractal()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Fractal");
	m_HelpID = HELP_FFRACTAL;
	m_PropNum = 11;

	m_Prop[PROP_FRACTAL_DETAILS].SetName("Details");
	m_Prop[PROP_FRACTAL_DETAILS].SetMinVal((real)0.001);
	m_Prop[PROP_FRACTAL_DETAILS].SetMin(1);
	m_Prop[PROP_FRACTAL_DETAILS].SetMax(1000);
	m_Prop[PROP_FRACTAL_DETAILS].SetUserValue(100);
	m_Prop[PROP_FRACTAL_DETAILS].SetToolID(ID_PROP_MANDSTEPS);

	m_Prop[PROP_FRACTAL_SCALE].SetName("Scale");
	m_Prop[PROP_FRACTAL_SCALE].SetValue(1);
	m_Prop[PROP_FRACTAL_SCALE].SetMax(1000);
	m_Prop[PROP_FRACTAL_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_FRACTAL_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_FRACTAL_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_FRACTAL_SQUEEZE].SetMin(-50);
	m_Prop[PROP_FRACTAL_SQUEEZE].SetMax(50);
	m_Prop[PROP_FRACTAL_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);

	m_Prop[PROP_FRACTAL_ANGLE].SetName("Angle");
	m_Prop[PROP_FRACTAL_ANGLE].SetValue((real)0.5);
	m_Prop[PROP_FRACTAL_ANGLE].SetMin(-180);
	m_Prop[PROP_FRACTAL_ANGLE].SetMax(180);
	m_Prop[PROP_FRACTAL_ANGLE].SetToolID(ID_PROP_ANGLE2);

	m_Prop[PROP_FRACTAL_SHIFTX].SetName("ShiftX");
	m_Prop[PROP_FRACTAL_SHIFTX].SetMinVal((real)-2.5);
	m_Prop[PROP_FRACTAL_SHIFTX].SetMaxVal((real)2.5);
	m_Prop[PROP_FRACTAL_SHIFTX].SetMin(-25000);
	m_Prop[PROP_FRACTAL_SHIFTX].SetMax(25000);
	m_Prop[PROP_FRACTAL_SHIFTX].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_FRACTAL_SHIFTY].SetName("ShiftY");
	m_Prop[PROP_FRACTAL_SHIFTY].SetMinVal((real)-2.5);
	m_Prop[PROP_FRACTAL_SHIFTY].SetMaxVal((real)2.5);
	m_Prop[PROP_FRACTAL_SHIFTY].SetMin(-25000);
	m_Prop[PROP_FRACTAL_SHIFTY].SetMax(25000);
	m_Prop[PROP_FRACTAL_SHIFTY].SetToolID(ID_PROP_SHIFTY);

	m_Prop[PROP_FRACTAL_SMOOTH].SetName("Smooth");
	m_Prop[PROP_FRACTAL_SMOOTH].SetValue(1);
	m_Prop[PROP_FRACTAL_SMOOTH].SetMaxVal(2);
	m_Prop[PROP_FRACTAL_SMOOTH].SetMax(200);
	m_Prop[PROP_FRACTAL_SMOOTH].SetToolID(ID_PROP_MANDELSMOOTH);

	m_Prop[PROP_FRACTAL_FORMULA].SetCategory(PCAT_ENUM);
	m_Prop[PROP_FRACTAL_FORMULA].SetName("Formula");
	m_Prop[PROP_FRACTAL_FORMULA].SetEnum(FilterFractalFormula);
	m_Prop[PROP_FRACTAL_FORMULA].SetToolID(ID_PROP_MANDELFORMULA);

	m_Prop[PROP_FRACTAL_JULIA].SetCategory(PCAT_CHECK);
	m_Prop[PROP_FRACTAL_JULIA].SetName("Julia");
	m_Prop[PROP_FRACTAL_JULIA].SetMax(1);
	m_Prop[PROP_FRACTAL_JULIA].SetValue(1);
	m_Prop[PROP_FRACTAL_JULIA].SetToolID(ID_PROP_JULIAMODE);

	m_Prop[PROP_FRACTAL_KR].SetName("Kr");
	m_Prop[PROP_FRACTAL_KR].SetMinVal(-2);
	m_Prop[PROP_FRACTAL_KR].SetMaxVal(2);
	m_Prop[PROP_FRACTAL_KR].SetMin(-2000);
	m_Prop[PROP_FRACTAL_KR].SetMax(2000);
	m_Prop[PROP_FRACTAL_KR].SetValue((real)0.3);
	m_Prop[PROP_FRACTAL_KR].SetToolID(ID_PROP_JULIAKR);

	m_Prop[PROP_FRACTAL_KI].SetName("Ki");
	m_Prop[PROP_FRACTAL_KI].SetMinVal(-2);
	m_Prop[PROP_FRACTAL_KI].SetMaxVal(2);
	m_Prop[PROP_FRACTAL_KI].SetMin(-2000);
	m_Prop[PROP_FRACTAL_KI].SetMax(2000);
	m_Prop[PROP_FRACTAL_KI].SetValue((real)0.45);
	m_Prop[PROP_FRACTAL_KI].SetToolID(ID_PROP_JULIAKI);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterFractal::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CFilterFractal::RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

const real log2 = (real)log((real)2);
const real log3 = (real)log((real)3);
const real log4 = (real)log((real)4);
const real log5 = (real)log((real)5);
const real log6 = (real)log((real)6);
const real log7 = (real)log((real)7);
const real log8 = (real)log((real)8);
const real log9 = (real)log((real)9);
const real logx10 = (real)log((real)10);
const real log11 = (real)log((real)11);
const real log12 = (real)log((real)12);

#define FRACSMOOTH(logx) { if (smooth > (real)0.00001) { if (i == steps) return 1; \
		real zn = z.Modulus(); real nu = log(log(zn) / (logx/smooth)) / (logx/smooth); \
		return (i + 1 - nu)/steps; } }

#define MANDEL(powx, logx) { for (i = 0; i < steps; i++) { \
		if (z.Modulus2() >= FRACTHRES) break; z.powx(); z += k; } FRACSMOOTH(logx); }

real CFilterFractal::RenderVal(real x, real y)
{
	// load properties
	int formula = (int)(m_Prop[PROP_FRACTAL_FORMULA].RenderVal(x, y)*100+(real)0.5);
	int steps = (int)(m_Prop[PROP_FRACTAL_DETAILS].RenderVal(x, y)*1000);
	if (steps < 1) steps = 1;
	real scale = pow(2,(m_Prop[PROP_FRACTAL_SCALE].RenderVal(x, y)-1)*20)*3;
	real squeeze = CLAMP(m_Prop[PROP_FRACTAL_SQUEEZE].RenderVal(x, y));
	real squeezeX = (squeeze <= (real)0.5) ? 1 : pow(2, (squeeze-(real)0.5)*10);
	real squeezeY = (squeeze >= (real)0.5) ? 1 : pow(2, ((real)0.5-squeeze)*10);
	real x2 = (x - (real)0.5)*squeezeX;
	real y2 = (y - (real)0.5)*squeezeY;
	real angle = (m_Prop[PROP_FRACTAL_ANGLE].RenderVal(x, y) - (real)0.5) * PI2;
	real cosa = cos(angle);
	real sina = sin(angle);
	real cr = (x2*cosa + y2*sina)*scale + m_Prop[PROP_FRACTAL_SHIFTX].RenderVal(x, y);
	real ci = (y2*cosa - x2*sina)*scale + m_Prop[PROP_FRACTAL_SHIFTY].RenderVal(x, y);
	real kr = cr;
	real ki = ci;			    
	bool julia = m_Prop[PROP_FRACTAL_JULIA].RenderVal(x, y) >= (real)0.5;
	if (julia)
	{
		kr = m_Prop[PROP_FRACTAL_KR].RenderVal(x, y);
		ki = m_Prop[PROP_FRACTAL_KI].RenderVal(x, y);
	}

	// Continuous (smooth) coloring http://en.wikipedia.org/wiki/Mandelbrot_set#Continuous_.28smooth.29_coloring
	real smooth = m_Prop[PROP_FRACTAL_SMOOTH].RenderVal(x, y);

	// iterations
	int i;
	complex c(cr, ci);
	complex z(cr, ci);
	complex k(kr, ki);
	complex z2, z3;

#define FRACTHRES 20

	switch (formula)
	{
	// 0: Z^2+C .. 9: Z^12+C
	default: MANDEL(Pow2, log2); break;
	case  1: MANDEL(Pow3, log3); break;
	case  2: MANDEL(Pow4, log4); break;
	case  3: MANDEL(Pow5, log5); break;
	case  4: MANDEL(Pow6, log6); break;
	case  5: MANDEL(Pow7, log7); break;
	case  6: MANDEL(Pow8, log8); break;
	case  7: MANDEL(Pow9, log9); break;
	case  8: MANDEL(Pow10, logx10); break;
	case  9: MANDEL(Pow11, log11); break;
	case 10: MANDEL(Pow12, log12); break;

	// 11: Z^2-Z+C
	case 11:
		for (i = 0; i < steps; i++)
		{
			if (z.Modulus2() >= FRACTHRES) break;
			z2 = z;
			z2.Pow2();
			z = z2 - z + k;
		}
		FRACSMOOTH(log2);
		break;

	// 12: Z^3-Z^2+Z+C
	case 12:
		for (i = 0; i < steps; i++)
		{
			if (z.Modulus2() >= FRACTHRES) break;
			z3 = z;
			z3.Pow3();
			z2 = z;
			z2.Pow2();
			z = z3 - z2 + z + k;
		}
		FRACSMOOTH(log3);
		break;

	// 13: Z^3+Z+C
	case 13:
		for (i = 0; i < steps; i++)
		{
			if (z.Modulus2() >= FRACTHRES) break;
			z3 = z;
			z3.Pow3();
			z = z3 + z + k;
		}
		FRACSMOOTH(log3);
		break;

	// 14: Z*(C+1)-C0*Z^2
	case 14:
		for (i = 0; i < steps; i++)
		{
			if (z.Modulus2() >= FRACTHRES) break;
			z2 = z;
			z2.Pow2();
			z = (k + 1)*z - c*z2;
		}
		FRACSMOOTH(log2);
		break;

	// 15: Z*(K+1)-C*Z^2
	case 15:
		for (i = 0; i < steps; i++)
		{
			if (z.Modulus2() >= FRACTHRES) break;
			z2 = z;
			z2.Pow2();
			z = (k + 1)*z - k*z2;
		}
		FRACSMOOTH(log2);
		break;

	// 16: (Z-1)*(Z+.5)*(Z^2-1)+C
	case 16:
		for (i = 0; i < steps; i++)
		{
			if (z.Modulus2() >= FRACTHRES) break;
			z2 = z;
			z2.Pow2();
			z = (z-1)*(z+0.5)*(z2-1)+k;
		}
		FRACSMOOTH(log3);
		break;
	}
	return (real)i/steps;;
}
