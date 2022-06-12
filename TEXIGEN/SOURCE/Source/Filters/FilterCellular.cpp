
///////////////////////////////////////////////////////////////////////////////
//
//                          Cellular Worley Noise Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// formula mode
enum CELLFORM {
	CELLFORM_F2F1 = 0,		// F2-F1
	CELLFORM_2F3F2F1 = 1,	// 2F3-F2-F1
	CELLFORM_F3F2 = 2,		// F3-F2
	CELLFORM_F1 = 3,		// F1
	CELLFORM_AVGF12 = 4,	// Avg(F1,F2)
	CELLFORM_AVGF123 = 5,	// Avg(F1,F2,F3)
	CELLFORM_F1DIVF2 = 6,	// F1/F2
	CELLFORM_F1MULF2 = 7,	// F1*F2
	CELLFORM_SQR = 8,		// F1*F1
	CELLFORM_SQRT = 9,		// SQRT(F1)
	CELLFORM_F2 = 10,		// F2
	CELLFORM_F3 = 11,		// F3
};

// distance mode
enum CELLDIST {
	CELLDIST_SQR = 0,	// Square: sqrt(dx*dx + dy*dy)
	CELLDIST_MAN = 1,	// Manhattan: abs(dx) + abs(dy)
	CELLDIST_CHEB = 2,	// Chebyshev: max(abs(dx), abs(dy))
	CELLDIST_MIN = 3,	// Minkowski: (sqrt(abs(dx))+sqrt(abs(dy)))^2
};

CText FilterMosaicFillMode[] = {
	CText(_T("Image")),			// 0
	CText(_T("Random Image")),	// 1
	CText(_T("Solid")),			// 2
	CText(_T("Random Solid")),	// 3

	CText(_T(""))
};

// cellular 2D noise (output -1..+1, jitter=0..0.7)
real CellSample(real x, real y, int scaleX, int scaleY, int seed, int form, int dist, real jitter, bool solid, int* pxr = NULL, int* pyr = NULL)
{
	// randomize seed
	seed *= 51;

	// scale coordinates
	x *= scaleX;
	y *= scaleY;

	// align coordinates
	x = fmod(x, (real)scaleX);
	if (x < 0) x += scaleX;

	y = fmod(y, (real)scaleY);
	if (y < 0) y += scaleY;

	// 25 nearest edges
	int xr[5];
	xr[2] = (int)x;
	xr[1] = xr[2] - 1; if (xr[1] < 0) xr[1] += scaleX;
	xr[0] = xr[1] - 1; if (xr[0] < 0) xr[0] += scaleX;
	xr[3] = xr[2] + 1; if (xr[3] >= scaleX) xr[3] -= scaleX;
	xr[4] = xr[3] + 1; if (xr[4] >= scaleX) xr[4] -= scaleX;

	int yr[5];
	yr[2] = (int)y;
	yr[1] = yr[2] - 1; if (yr[1] < 0) yr[1] += scaleY;
	yr[0] = yr[1] - 1; if (yr[0] < 0) yr[0] += scaleY;
	yr[3] = yr[2] + 1; if (yr[3] >= scaleY) yr[3] -= scaleY;
	yr[4] = yr[3] + 1; if (yr[4] >= scaleY) yr[4] -= scaleY;

	// find 3 nearest points (distance 0..1)
	real f[3];
	f[0]=f[1]=f[2]=100000;
	int ij=0;
	int ijxr = 0;
	int ijyr = 0;
	int i,j;
	for (i = -2; i <= 2; i++)
		for (j = -2; j <= 2; j++)
		{
			// point noise dispersion: -0.7..+0.7
			real dx = xr[2] + j + Noise2D(xr[2+j], yr[2+i], seed)*jitter - x;
			real dy = yr[2] + i + Noise2D(xr[2+j]+153, yr[2+i]+12, seed+43)*jitter - y;
			real d;

			switch (dist) // results are normalized to produce F1 values aprox. 0..1
			{
			// 1: Manhattan: abs(dx) + abs(dy)
			case CELLDIST_MAN:
				d = (abs(dx) + abs(dy))*3/4;
				break;

			// 2: Chebyshev: max(abs(dx), abs(dy))
			case CELLDIST_CHEB:
				dx = abs(dx);
				dy = abs(dy);
				d = (dx > dy) ? dx : dy;
				break;

			// 3. Minkowski: (sqrt(abs(dx))+sqrt(abs(dy)))^2
			case CELLDIST_MIN:
				d = sqrt(abs(dx)) + sqrt(abs(dy));
				d = d*d*(real)0.4;
				break;

			// 0: Square: sqrt(dx*dx + dy*dy)
			default:
				d = sqrt(dx*dx + dy*dy);
			}

			if (d < f[0])
			{
				f[2] = f[1];
				f[1] = f[0];
				f[0] = d;
				ijxr = xr[2+j];
				ijyr = yr[2+i];
				ij = ijxr + ijyr*117;
			}
			else
				if (d < f[1])
				{
					f[2] = f[1];
					f[1] = d;
				}
				else
					if (d < f[2]) f[2] = d;
		}

	if (pyr != NULL)
	{
		*pxr = ijxr;
		*pyr = ijyr;
	}

	real val;
	if (solid)
		val = Noise1D(ij, seed);
	else
	{
		switch (form) // results normalized to produce value aprox. -1..1
		{
		// 1: 2F3-F2-F1
		case CELLFORM_2F3F2F1:
			val = (2*f[2] - f[1] - f[0]) - 1;
			break;

		// 2: F3-F2
		case CELLFORM_F3F2:
			val = (f[2] - f[1])*2 - 1;
			break;

		// 3: F1
		case CELLFORM_F1:
			val = (1 - f[0])*2 - 1;
			break;

		// 4: Avg(F1,F2)
		case CELLFORM_AVGF12:
			val = (real)1.25 - (f[0] + f[1]);
			break;

		// 5: Avg(F1,F2,F3)
		case CELLFORM_AVGF123:
			val = (real)1.4 - (f[0] + f[1] + f[2])*2/3;
			break;

		// 6: F1/F2
		case CELLFORM_F1DIVF2:
			val = (f[0] < 0.0001) ? 1 : (1 - f[0]/f[1])*2 - 1;
			break;

		// 7: F1*F2
		case CELLFORM_F1MULF2:
			val = 1 - f[0]*f[1]*(real)1.5;
			break;

		// 8: F1*F1
		case CELLFORM_SQR:
			val = 1 - f[0]*f[0]*(real)1.5;
			break;

		// 9: SQRT(F1)
		case CELLFORM_SQRT:
			val = (real)1.1 - ((f[0] < 0) ? 0 : sqrt(f[0]))*2;
			break;

		// 10: F2
		case CELLFORM_F2:
			val = (1 - f[1])*(real)1.7 - (real)0.5;
			break;

		// 11: F3
		case CELLFORM_F3:
			val = (1 - f[2])*(real)1.7 - (real)0.5;
			break;

		// 0: F2-F1
		default:
			val = (f[1] - f[0])*2 - 1;
		}
	}

	if (val >= 1) val = 1;
	if (val <= -1) val = -1;
	return val;
}

CText FilterCellularForm[] = {
	CText(_T("F2-F1")),			// 0
	CText(_T("2F3-F2-F1")),		// 1
	CText(_T("F3-F2")),			// 2
	CText(_T("F1")),			// 3
	CText(_T("Avg(F1,F2)")),	// 4
	CText(_T("Avg(F1,F2,F3)")),	// 5
	CText(_T("F1/F2")),			// 6
	CText(_T("F1*F2")),			// 7
	CText(_T("F1*F1")),			// 8
	CText(_T("sqrt(F1)")),		// 9
	CText(_T("F2")),			// 10
	CText(_T("F3")),			// 11

	CText(_T(""))
};

CText FilterCellularDist[] = {
	CText(_T("Square")),		// 0
	CText(_T("Manhattan")),		// 1
	CText(_T("Chebyshev")),		// 2
	CText(_T("Minkowski")),		// 3

	CText(_T(""))
};

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterCellular::CFilterCellular()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Cellular");
	m_HelpID = HELP_FCELLULAR;
	m_PropNum = 15;

	m_Prop[PROP_CELLULAR_DETAILS].SetName("Details");
	m_Prop[PROP_CELLULAR_DETAILS].SetMinVal((real)0.1);
	m_Prop[PROP_CELLULAR_DETAILS].SetMin(1);
	m_Prop[PROP_CELLULAR_DETAILS].SetMax(10);
	m_Prop[PROP_CELLULAR_DETAILS].SetValue((real)0.5);
	m_Prop[PROP_CELLULAR_DETAILS].SetToolID(ID_PROP_DETAILS);

	m_Prop[PROP_CELLULAR_ROUGHNESS].SetName("Roughness");
	m_Prop[PROP_CELLULAR_ROUGHNESS].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_CELLULAR_CONTRAST].SetName("Contrast");
	m_Prop[PROP_CELLULAR_CONTRAST].SetValue((real)0.5);
	m_Prop[PROP_CELLULAR_CONTRAST].SetToolID(ID_PROP_CONTRAST);

	m_Prop[PROP_CELLULAR_BRIGHT].SetName("Brightness");
	m_Prop[PROP_CELLULAR_BRIGHT].SetValue((real)0.5);
	m_Prop[PROP_CELLULAR_BRIGHT].SetToolID(ID_PROP_BRIGHT);

	m_Prop[PROP_CELLULAR_SCALE].SetName("Scale");
	m_Prop[PROP_CELLULAR_SCALE].SetValue((real)0.6);
	m_Prop[PROP_CELLULAR_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_CELLULAR_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_CELLULAR_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_CELLULAR_SQUEEZE].SetMin(-50);
	m_Prop[PROP_CELLULAR_SQUEEZE].SetMax(50);
	m_Prop[PROP_CELLULAR_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);

	m_Prop[PROP_CELLULAR_ANGLE].SetName("Angle");
	m_Prop[PROP_CELLULAR_ANGLE].SetValue((real)0.5);
	m_Prop[PROP_CELLULAR_ANGLE].SetMin(-180);
	m_Prop[PROP_CELLULAR_ANGLE].SetMax(180);
	m_Prop[PROP_CELLULAR_ANGLE].SetToolID(ID_PROP_ANGLE);

	m_Prop[PROP_CELLULAR_SHIFTX].SetName("ShiftX");
	m_Prop[PROP_CELLULAR_SHIFTX].SetValue((real)0.5);
	m_Prop[PROP_CELLULAR_SHIFTX].SetMin(-50);
	m_Prop[PROP_CELLULAR_SHIFTX].SetMax(50);
	m_Prop[PROP_CELLULAR_SHIFTX].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_CELLULAR_SHIFTY].SetName("ShiftY");
	m_Prop[PROP_CELLULAR_SHIFTY].SetValue((real)0.5);
	m_Prop[PROP_CELLULAR_SHIFTY].SetMin(-50);
	m_Prop[PROP_CELLULAR_SHIFTY].SetMax(50);
	m_Prop[PROP_CELLULAR_SHIFTY].SetToolID(ID_PROP_SHIFTY);

	m_Prop[PROP_CELLULAR_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_CELLULAR_PROFILE].SetName("Profile");
	m_Prop[PROP_CELLULAR_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_CELLULAR_PROFILE].SetToolID(ID_PROP_NOISEPROFILE);

	m_Prop[PROP_CELLULAR_CHAOS].SetName("Chaos");
	m_Prop[PROP_CELLULAR_CHAOS].SetValue(1);
	m_Prop[PROP_CELLULAR_CHAOS].SetToolID(ID_PROP_CELLULARCHAOS);

	m_Prop[PROP_CELLULAR_SOLID].SetCategory(PCAT_CHECK);
	m_Prop[PROP_CELLULAR_SOLID].SetName("Solid");
	m_Prop[PROP_CELLULAR_SOLID].SetMax(1);
	m_Prop[PROP_CELLULAR_SOLID].SetToolID(ID_PROP_CELLULARSOLID);

	m_Prop[PROP_CELLULAR_FORM].SetCategory(PCAT_ENUM);
	m_Prop[PROP_CELLULAR_FORM].SetName("Formula");
	m_Prop[PROP_CELLULAR_FORM].SetMax(10);
	m_Prop[PROP_CELLULAR_FORM].SetEnum(FilterCellularForm);
	m_Prop[PROP_CELLULAR_FORM].SetToolID(ID_PROP_CELLULARFORMULA);

	m_Prop[PROP_CELLULAR_DIST].SetCategory(PCAT_ENUM);
	m_Prop[PROP_CELLULAR_DIST].SetName("Distance");
	m_Prop[PROP_CELLULAR_DIST].SetMax(10);
	m_Prop[PROP_CELLULAR_DIST].SetEnum(FilterCellularDist);
	m_Prop[PROP_CELLULAR_DIST].SetToolID(ID_PROP_CELLULARDIST);

	m_Prop[PROP_CELLULAR_SEED].SetName("Seed");
	m_Prop[PROP_CELLULAR_SEED].SetMax(1000);
	m_Prop[PROP_CELLULAR_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterCellular::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCellular::RenderVal(real x, real y)
{
	// load properties
	int seed = (int)(m_Prop[PROP_CELLULAR_SEED].RenderVal(x, y)*1000 + (real)0.5);
	real details = CLAMP(m_Prop[PROP_CELLULAR_DETAILS].RenderVal(x, y));
	real roughness = m_Prop[PROP_CELLULAR_ROUGHNESS].RenderVal(x, y)*(real)0.8;
	real contrast = m_Prop[PROP_CELLULAR_CONTRAST].RenderVal(x, y)*2;
	real bright = (m_Prop[PROP_CELLULAR_BRIGHT].RenderVal(x, y) - (real)0.5)*3;
	real scale = pow(2,CLAMP(1-m_Prop[PROP_CELLULAR_SCALE].RenderVal(x, y))*8);
	real squeeze = CLAMP(m_Prop[PROP_CELLULAR_SQUEEZE].RenderVal(x, y));
	real squeezeX = (squeeze < (real)0.5) ? 1 : pow(2, (squeeze-(real)0.5)*10);
	real squeezeY = (squeeze >= (real)0.5) ? 1 : pow(2, ((real)0.5-squeeze)*10);
	int scaleX = (int)(scale*squeezeX+(real)0.5);
	int scaleY = (int)(scale*squeezeY+(real)0.5);
	real x0 = x - m_Prop[PROP_CELLULAR_SHIFTX].RenderVal(x, y);
	real y0 = y - m_Prop[PROP_CELLULAR_SHIFTY].RenderVal(x, y);
	real angle = -(m_Prop[PROP_CELLULAR_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real x2 = x0*cos(angle) + y0*sin(angle);
	real y2 = y0*cos(angle) - x0*sin(angle);
	x = x2 + (real)0.5;
	y = y2 + (real)0.5;
	real chaos = CLAMP(m_Prop[PROP_CELLULAR_CHAOS].RenderVal(x, y))*(real)0.7;
	bool solid = m_Prop[PROP_CELLULAR_SOLID].RenderVal(x, y) >= 0.5;
	int form = (int)(m_Prop[PROP_CELLULAR_FORM].RenderVal(x, y)*10 + (real)0.5);
	int dist = (int)(m_Prop[PROP_CELLULAR_DIST].RenderVal(x, y)*10 + (real)0.5);

	// contrast correction from roughness
	contrast /= (real)(roughness*roughness*1.5+1);
	bright += roughness;

	// generate value
	real val = 0;
	int bands = (int)(details*10+0.5);
	if (bands < 1) bands = 1;
	for (; bands > 0; bands--)
	{
		real val1 = CellSample(x, y, scaleX, scaleY, seed, form, dist, chaos, solid);
		val1 = (m_Prop[PROP_CELLULAR_PROFILE].RenderVal(val1/2 + (real)0.5, y)-(real)0.5)*2;
		val += val1 * contrast;

		scaleX *= 2;
		scaleY *= 2;

		contrast *= roughness;
		seed += 5;
	}
	val += bright;

	return CLAMP(val/2 + (real)0.5);
}

#define PROP_MOSAIC_BRICK		0		// property - Brick (brick color or pattern)
#define PROP_MOSAIC_MORTAR		1		// property - Mortar (mortar color or pattern)
#define PROP_MOSAIC_GAP			2		// property - Gap (gap between bricks (=mortar thickness))
#define PROP_MOSAIC_BEVEL		3		// property - Bevel (bevel width 0..1)
#define PROP_MOSAIC_SCALE		4		// property - Scale (0..1 = scale)
#define PROP_MOSAIC_SQUEEZE		5		// property - Squeeze (0..1 = scale in X direction, 0=normal..1=128x small, default 0)
#define PROP_MOSAIC_CHAOS		6		// property - Chaos (jittering 0..1, 0=regular..1=random, default 0.5)
#define PROP_MOSAIC_FORM		7		// property - Formula (formula mode 0..1 in 0.1 steps, default 0)
// Formula: 0=F2-F1, 0.1=2F3-F2-F1, 0.2=F3-F2, 0.3=F1, 0.4=Avg(F1,F2), 0.5=Avg(F1,F2,F3), 0.6=F1/F2, 0.7=F1*F2, ...
#define PROP_MOSAIC_DIST		8		// property - Distance (distance mode 0..1 in 0.1 steps, default 0)
// Distance: 0=Square, 0.1=Manhattan, 0.2=Chebyshev, 0.3=Minkowski
#define PROP_MOSAIC_HUE			9		// property - Hue (randomize color 0..1, default 0)
#define PROP_MOSAIC_SAT			10		// property - Saturation (randomize saturation 0..1, default 0)
#define PROP_MOSAIC_LUM			11		// property - Luminance (randomize luminance 0..1, default 0)
#define PROP_MOSAIC_FILL		12		// property - Fill (fill mode: 0=image, 0.1=random image, 0.2=solid, 0.3=random solid; default 0.1)
#define PROP_MOSAIC_SEED		13		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterMosaic::CFilterMosaic()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Mosaic");
	m_HelpID = HELP_FMOSAIC;
	m_PropNum = 14;

	m_Prop[PROP_MOSAIC_BRICK].SetCategory(PCAT_COLOR);
	m_Prop[PROP_MOSAIC_BRICK].SetName("Brick");
	m_Prop[PROP_MOSAIC_BRICK].SetColor((real)204/255, (real)76/255, (real)25/255);
	m_Prop[PROP_MOSAIC_BRICK].SetToolID(ID_PROP_BRICK);

	m_Prop[PROP_MOSAIC_MORTAR].SetCategory(PCAT_COLOR);
	m_Prop[PROP_MOSAIC_MORTAR].SetName("Mortar");
	m_Prop[PROP_MOSAIC_MORTAR].SetToolID(ID_PROP_MORTAR);

	m_Prop[PROP_MOSAIC_GAP].SetName("Gap");
	m_Prop[PROP_MOSAIC_GAP].SetValue((real)0.02);
	m_Prop[PROP_MOSAIC_GAP].SetToolID(ID_PROP_BRICKGAP);

	m_Prop[PROP_MOSAIC_BEVEL].SetName("Bevel");
	m_Prop[PROP_MOSAIC_BEVEL].SetToolID(ID_PROP_BRICKBEVEL);

	m_Prop[PROP_MOSAIC_SCALE].SetName("Scale");
	m_Prop[PROP_MOSAIC_SCALE].SetValue((real)0.6);
	m_Prop[PROP_MOSAIC_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_MOSAIC_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_MOSAIC_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_MOSAIC_SQUEEZE].SetMin(-50);
	m_Prop[PROP_MOSAIC_SQUEEZE].SetMax(50);
	m_Prop[PROP_MOSAIC_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);

	m_Prop[PROP_MOSAIC_CHAOS].SetName("Chaos");
	m_Prop[PROP_MOSAIC_CHAOS].SetValue(1);
	m_Prop[PROP_MOSAIC_CHAOS].SetToolID(ID_PROP_CELLULARCHAOS);

	m_Prop[PROP_MOSAIC_FORM].SetCategory(PCAT_ENUM);
	m_Prop[PROP_MOSAIC_FORM].SetName("Formula");
	m_Prop[PROP_MOSAIC_FORM].SetMax(10);
	m_Prop[PROP_MOSAIC_FORM].SetEnum(FilterCellularForm);
	m_Prop[PROP_MOSAIC_FORM].SetToolID(ID_PROP_CELLULARFORMULA);

	m_Prop[PROP_MOSAIC_DIST].SetCategory(PCAT_ENUM);
	m_Prop[PROP_MOSAIC_DIST].SetName("Distance");
	m_Prop[PROP_MOSAIC_DIST].SetMax(10);
	m_Prop[PROP_MOSAIC_DIST].SetEnum(FilterCellularDist);
	m_Prop[PROP_MOSAIC_DIST].SetToolID(ID_PROP_CELLULARDIST);

	m_Prop[PROP_MOSAIC_HUE].SetName("Hue");
	m_Prop[PROP_MOSAIC_HUE].SetToolID(ID_PROP_BRICKHUE);

	m_Prop[PROP_MOSAIC_SAT].SetName("Saturation");
	m_Prop[PROP_MOSAIC_SAT].SetToolID(ID_PROP_BRICKSAT);

	m_Prop[PROP_MOSAIC_LUM].SetName("Luminance");
	m_Prop[PROP_MOSAIC_LUM].SetToolID(ID_PROP_BRICKLUM);

	m_Prop[PROP_MOSAIC_FILL].SetCategory(PCAT_ENUM);
	m_Prop[PROP_MOSAIC_FILL].SetName("Fill");
	m_Prop[PROP_MOSAIC_FILL].SetValue((real)0.1);
	m_Prop[PROP_MOSAIC_FILL].SetMax(10);
	m_Prop[PROP_MOSAIC_FILL].SetEnum(FilterMosaicFillMode);
	m_Prop[PROP_MOSAIC_FILL].SetToolID(ID_PROP_MOSAICFILL);

	m_Prop[PROP_MOSAIC_SEED].SetName("Seed");
	m_Prop[PROP_MOSAIC_SEED].SetMax(1000);
	m_Prop[PROP_MOSAIC_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterMosaic::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real gap = m_Prop[PROP_MOSAIC_GAP].RenderVal(x, y);
	real bev = m_Prop[PROP_MOSAIC_BEVEL].RenderVal(x, y);
	real scale = pow(2,CLAMP(1-m_Prop[PROP_MOSAIC_SCALE].RenderVal(x, y))*8);
	real squeeze = CLAMP(m_Prop[PROP_MOSAIC_SQUEEZE].RenderVal(x, y));
	real squeezeX = (squeeze < (real)0.5) ? 1 : pow(2, (squeeze-(real)0.5)*10);
	real squeezeY = (squeeze >= (real)0.5) ? 1 : pow(2, ((real)0.5-squeeze)*10);
	int scaleX = (int)(scale*squeezeX+(real)0.5);
	int scaleY = (int)(scale*squeezeY+(real)0.5);
	real chaos = CLAMP(m_Prop[PROP_MOSAIC_CHAOS].RenderVal(x, y))*(real)0.7;
	int form = (int)(m_Prop[PROP_MOSAIC_FORM].RenderVal(x, y)*10 + (real)0.5);
	int dist = (int)(m_Prop[PROP_MOSAIC_DIST].RenderVal(x, y)*10 + (real)0.5);
	real hue = m_Prop[PROP_MOSAIC_HUE].RenderVal(x, y);
	real sat = m_Prop[PROP_MOSAIC_SAT].RenderVal(x, y);
	real lum = m_Prop[PROP_MOSAIC_LUM].RenderVal(x, y);
	int fill = (int)(m_Prop[PROP_MOSAIC_FILL].RenderVal(x, y)*10 + (real)0.5);
	int seed = (int)(m_Prop[PROP_MOSAIC_SEED].RenderVal(x, y)*1000 + (real)0.5);

	// generate value
	int xr = 0;
	int yr = 0;
	real val = CellSample(x, y, scaleX, scaleY, seed, form, dist, chaos, FALSE, &xr, &yr);
	val = CLAMP(val/2 + (real)0.5);
	real xr0 = (real)xr/scaleX;
	real yr0 = (real)yr/scaleY;

	// fill mode
	real x0 = x;
	real y0 = y;
	switch (fill)
	{
	case 1: // random image
		x = (x - xr0) + (Noise2D(xr, yr, seed+5)+1)/2*(real)0.5 + (real)0.15;
		y = (y - yr0) + (Noise2D(xr, yr, seed+10)+1)/2*(real)0.5 + (real)0.15;
		if (x < 0) x++;
		if (x >= 1) x--;
		if (y < 0) y++;
		if (y >= 1) y--;
		break;

	case 2: // solid
		x = xr0 + (real)0.5/scaleX;
		y = yr0 + (real)0.5/scaleY;
		break;

	case 3: // random solid
		x = (Noise2D(xr, yr, seed+15)+1)/2 + (real)0.5/scaleX;
		y = (Noise2D(xr, yr, seed+20)+1)/2 + (real)0.5/scaleY;
		break;
	}

	// prepare mort
	real mort = 1;
	if (val > gap)
	{
		if ((bev > 0) && (val < gap + bev))
			mort = (gap + bev - val) / bev;
		else
			mort = 0;
	}

	// render brick color
	if (mort < 1)
		m_Prop[PROP_MOSAIC_BRICK].RenderCol(col, x, y);
	else
		col->SetBlack();

	// color correction
	if ((hue > 0) || (sat > 0))
	{
		col->RGBToHSL();
		col->r += hue*(Noise2D(xr, yr, seed+70)/2);
		if (col->r < 0) col->r += 1;
		if (col->r >= 1) col->r -= 1;
		col->g *= 1 + sat*Noise2D(xr, yr, seed+113);
		col->HSLToRGB();
	}
	if (lum > 0) col->Brightness((real)0.5 + lum*(Noise2D(xr, yr, seed+200)/2));

	// render mortar color
	CColor c;
	if (mort > 0)
		m_Prop[PROP_MOSAIC_MORTAR].RenderCol(&c, x0, y0);
	else
		c.SetBlack();

	// transpose colors
	col->Trans(c, mort);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterMosaic::RenderVal(real x, real y)
{
	CColor col;
	CFilterMosaic::RenderCol(&col, x, y);
	return col.Gray();
}
