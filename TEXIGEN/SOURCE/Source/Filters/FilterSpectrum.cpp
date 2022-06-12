		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                         Spectrum Gradient Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSpectrum::CFilterSpectrum()
{
	m_Group = FGRP_GRAD;
	m_Class = _T("Spectrum");
	m_HelpID = HELP_FSPECTRUM;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterSpectrum::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	x = CLAMP(x);
	x *= (real)5.999;
	int x0 = (int)x;
	x -= x0;
	real xu = (1-cos(x*PI))/2;
	real xd = (1-cos((1-x)*PI))/2;

	// clear color
	col->SetBlack();

	// render color
	switch (x0)
	{
	case 0:
		col->r = 1;
		col->g = xu;
		break;

	case 1:
		col->r = xd;
		col->g = 1;
		break;

	case 2:
		col->g = 1;
		col->b = xu;
		break;

	case 3:
		col->g = xd;
		col->b = 1;
		break;

	case 4:
		col->b = 1;
		col->r = xu;
		break;

	default:
		col->b = xd;
		col->r = 1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSpectrum::RenderVal(real x, real y)
{
	CColor col;
	CFilterSpectrum::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterThermo::CFilterThermo()
{
	m_Group = FGRP_GRAD;
	m_Class = _T("Thermo");
	m_HelpID = HELP_FTHERMO;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterThermo::RenderCol(CColor* col, real x, real y)
{
	// X coordinate
	x = CLAMP(x);
	x *= (real)5.999;
	int x0 = (int)x;
	x -= x0;
	real xu = (1-cos(x*PI))/2;
	real xd = (1-cos((1-x)*PI))/2;

	// clear color
	col->SetBlack();

	// render color
	switch (x0)
	{
	case 0:
		col->b = xu;
		break;

	case 1:
		col->b = xd;
		col->g = xu;
		break;

	case 2:
		col->g = 1;
		col->r = xu;
		break;

	case 3:
		col->g = xd;
		col->r = 1;
		break;

	case 4:
		col->r = 1;
		col->b = xu;
		break;

	default:
		col->g = xu;
		col->r = 1;
		col->b = 1;
	}
}

// render value (coordinates and output are typically in range 0..1)
real CFilterThermo::RenderVal(real x, real y)
{
	CColor col;
	CFilterThermo::RenderCol(&col, x, y);
	return col.Gray();
}
