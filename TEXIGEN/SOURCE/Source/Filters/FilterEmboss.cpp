		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Process Filters
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define ENVPICNUM	7				// number of environment pictures
#define ENVPICW		256				// width of environment picture
#define ENVPICH		256				// height of environment picture

// environment pictures list
CText EnvPicID[ENVPICNUM] = {
	CText(_T("RLINEAR")),
	CText(_T("RSKY")),
	CText(_T("RFOREST")),
	CText(_T("RPATH")),
	CText(_T("RPOND")),
	CText(_T("RSPRING")),
	CText(_T("RSUN")),
};

CText EnvPicName[ENVPICNUM+1] = {
	CText(_T("Light")),
	CText(_T("Sky")),
	CText(_T("Forest")),
	CText(_T("Path")),
	CText(_T("Pond")),
	CText(_T("Spring")),
	CText(_T("Sun")),

	CText(_T(""))
};

// smooth points list
CText SmoothPointsName[] = {
	CText(_T("5 points")),
	CText(_T("9 points")),
	CText(_T("21 points")),

	CText(_T(""))
};

SCanvas*	EnvPic[ENVPICNUM];			// environment pictures

// Gauss blur weights
real		GaussWeight[(BLURMAXRAD+1)*BLURMAXSIZE];

///////////////////////////////////////////////////////////////////////////////
// generate Gauss blur weights

void GenGaussWeight()
{
	int r, i;
	real k, t;
	real* w = GaussWeight;
	for (r = 0; r <= BLURMAXRAD; r++)
	{
		w[r] = 1;
		t = 1;
		for (i = r-1; i >= 0; i--)
		{
			k = (r-i)/(real)r;
			k = exp((real)-k*k*2);
			w[i] = k;
			w[r+r-i] = k;
			t += 2*k;
		}
		t = 1/t;
		for (i = 2*r+1-1; i >= 0; i--) w[i] *= t;
		w += BLURMAXSIZE;
	}
}

///////////////////////////////////////////////////////////////////////////////
// load environment pictures

void LoadEnvPic()
{
	int i;
	SCanvas* c;
	CColor col;
	u8 *s;

	for (i = 0; i < ENVPICNUM; i++)
	{
		c = NewCanvas(ENVPICW, ENVPICH);
		EnvPic[i] = c;
		HRSRC res = ::FindResource(Instance, EnvPicID[i], "REFLECT");
		if (res != NULL)
		{
			HGLOBAL glob = ::LoadResource(Instance, res);
			if (glob != NULL)
			{
				u8* a = (u8*)::LockResource(glob);
				s = c->d;
				if (a != NULL) memcpy(s, a + TGAHEADSIZE, ENVPICW*ENVPICH*3);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBlur::CFilterBlur()
{
	m_Group = FGRP_PROC;
	m_Class = _T("Blur");
	m_HelpID = HELP_FBLUR;
	m_PropNum = 4;

	m_Tiled = TRUE;

	this->ClearCache(m_CacheIn);
	this->ClearCache(m_CacheTemp);
	this->ClearCache(m_CacheOut);

	m_Prop[PROP_BLUR_RADIUSX].SetName("RadiusX");
	m_Prop[PROP_BLUR_RADIUSX].SetToolID(ID_PROP_RADIUSX);
	m_Prop[PROP_BLUR_RADIUSX].SetValue((real)0.1);

	m_Prop[PROP_BLUR_RADIUSY].SetName("RadiusY");
	m_Prop[PROP_BLUR_RADIUSY].SetToolID(ID_PROP_RADIUSY);
	m_Prop[PROP_BLUR_RADIUSY].SetValue((real)0.1);

	m_Prop[PROP_BLUR_TILED].SetName("Tiled");
	m_Prop[PROP_BLUR_TILED].SetToolID(ID_PROP_TILED);
	m_Prop[PROP_BLUR_TILED].SetCategory(PCAT_CHECK);
	m_Prop[PROP_BLUR_TILED].SetValue(1);
	m_Prop[PROP_BLUR_TILED].SetMax(1);
}

///////////////////////////////////////////////////////////////////////////////
// clear cache

void CFilterBlur::ClearCache(u64* buf)
{
	int i;
	for (i = BLURCACHESIZE; i > 0; i--) *buf++ = BLURCACHEINV;
}

///////////////////////////////////////////////////////////////////////////////
// load one input sample

u64 CFilterBlur::LoadIn(int x, int y)
{
	if (m_Restart) return 0;

	u64* d = &m_CacheIn[x + y*BLURCACHEWH];
	u64 n = *d;
	if (n == BLURCACHEINV)
	{
		CColor c;
		m_Prop[PROP_SOURCE].RenderCol(&c, (x+(real)0.5)/BLURCACHEWH, (y+(real)0.5)/BLURCACHEWH);
		n = c.GetRGBA64();
		*d = n;
	}
	return n;
}

///////////////////////////////////////////////////////////////////////////////
// load one temporary sample (blured in X direction)

u64 CFilterBlur::LoadTemp(int x, int y)
{
	if (m_Restart) return 0;

	u64* d = &m_CacheTemp[x + y*BLURCACHEWH];
	u64 n = *d;
	if (n == BLURCACHEINV)
	{
		int i, x2, dx;

		// prepare weight table
		real* w = &GaussWeight[m_RadiusX*BLURMAXSIZE];

		// loop horizontally
		CColor c, c2;
		c.SetBlackA();
		dx = -m_RadiusX;
		for (i = 0; i < m_SizeX; i++)
		{
			// prepare real X
			x2 = x + dx;
			if (x2 < 0) x2 = m_Tiled ? (x2 + BLURCACHEWH) : 0;
			if (x2 >= BLURCACHEWH) x2 = m_Tiled ? (x2 - BLURCACHEWH) : (BLURCACHEWH-1);

			// get color
			c2.SetRGBA64(this->LoadIn(x2, y));
			c2.MulA(w[i]);
			c.AddA(c2);

			dx++;
			if (m_Restart) break;
		}

		// store color
		n = c.GetRGBA64();
		*d = n;
	}
	return n;
}

///////////////////////////////////////////////////////////////////////////////
// load one output sample

u64 CFilterBlur::LoadOut(int x, int y)
{
	if (m_Restart) return 0;

	u64* d = &m_CacheOut[x + y*BLURCACHEWH];
	u64 n = *d;
	if (n == BLURCACHEINV)
	{
		int i, y2, dy;

		// prepare weight table
		real* w = &GaussWeight[m_RadiusY*BLURMAXSIZE];

		// loop vertically
		CColor c, c2;
		c.SetBlackA();
		dy = -m_RadiusY;
		for (i = 0; i < m_SizeY; i++)
		{
			// prepare real Y
			y2 = y + dy;
			if (y2 < 0) y2 = m_Tiled ? (y2 + BLURCACHEWH) : 0;
			if (y2 >= BLURCACHEWH) y2 = m_Tiled ? (y2 - BLURCACHEWH) : (BLURCACHEWH-1);

			// get color
			c2.SetRGBA64(this->LoadTemp(x, y2));
			c2.MulA(w[i]);
			c.AddA(c2);

			dy++;
			if (m_Restart) break;
		}

		// store color
		n = c.GetRGBA64();
		*d = n;
	}
	return n;
}

///////////////////////////////////////////////////////////////////////////////
// render color of one pixel

void CFilterBlur::RenderCol1(CColor* col, real x, real y)
{
	// prepare coordinates
	if (m_Tiled)
	{
		if (x >= 1) x -= (int)x;
		if (x < 0) x += (int)(1 - x);
		if (y >= 1) y -= (int)y;
		if (y < 0) y += (int)(1 - y);
	}
	else
	{
		x = CLAMP(x);
		y = CLAMP(y);
	}

	x *= BLURCACHEWH;
	int x1 = (int)x;
	if (x1 >= BLURCACHEWH) x1 = BLURCACHEWH - 1;
	x -= x1;
	int x2 = x1 + 1;
	if (x2 >= BLURCACHEWH) x2 = m_Tiled ? 0 : x1;

	y *= BLURCACHEWH;
	int y1 = (int)y;
	if (y1 >= BLURCACHEWH) y1 = BLURCACHEWH - 1;
	y -= y1;
	int y2 = y1 + 1;
	if (y2 >= BLURCACHEWH) y2 = m_Tiled ? 0 : y1;

	// load samples
	u64 c11 = this->LoadOut(x1, y1);
	u64 c21 = this->LoadOut(x2, y1);
	u64 c12 = this->LoadOut(x1, y2);
	u64 c22 = this->LoadOut(x2, y2);

	// interpolate
	col->TransRGBA64(c11, c21, c12, c22, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

#define BW0			(real)1.0
real BlurWTab1[1] = { BW0 };

#define BW31		(real)0.8
#define BWS3		(BW0+2*BW31)
real BlurWTab3[3] = { BW31/BWS3, BW0/BWS3, BW31/BWS3 };

#define BW51		(real)0.9
#define BW52		(real)0.7
#define BWS5		(BW0+2*BW51+2*BW52)
real BlurWTab5[5] = { BW52/BWS5, BW51/BWS5, BW0/BWS5, BW51/BWS5, BW52/BWS5 };

#define BW71		(real)1
#define BW72		(real)0.9
#define BW73		(real)0.6
#define BWS7		(BW0+2*BW71+2*BW72+2*BW73)
real BlurWTab7[7] = { BW73/BWS7, BW72/BWS7, BW71/BWS7, BW0/BWS7, BW71/BWS7, BW72/BWS7, BW73/BWS7 };

#define BW91		(real)1
#define BW92		(real)1
#define BW93		(real)0.8
#define BW94		(real)0.4
#define BWS9		(BW0+2*BW91+2*BW92+2*BW93+2*BW94)
real BlurWTab9[9] = { BW94/BWS9, BW93/BWS9, BW92/BWS9, BW91/BWS9, BW0/BWS9, BW91/BWS9, BW92/BWS9, BW93/BWS9, BW94/BWS9 };

#define BWB1		(real)1
#define BWB2		(real)1
#define BWB3		(real)0.95
#define BWB4		(real)0.8
#define BWB5		(real)0.6
#define BWSB		(BW0+2*BWB1+2*BWB2+2*BWB3+2*BWB4+2*BWB5)
real BlurWTabB[11] = { BWB5/BWSB, BWB4/BWSB, BWB3/BWSB, BWB2/BWSB, BWB1/BWSB, BW0/BWSB, BWB1/BWSB, BWB2/BWSB, BWB3/BWSB, BWB4/BWSB, BWB5/BWSB };

void CFilterBlur::RenderCol2(CColor* col, real x, real y)
{
	// clear cache
	if (m_Restart)
	{
		m_Restart = FALSE;
		this->ClearCache(m_CacheIn);
		this->ClearCache(m_CacheTemp);
		this->ClearCache(m_CacheOut);
	}

	// render color with smooth interpolation (to avoid gradient steps)
#define BWINC ((real)1/BLURCACHEWH/5)
#define BMAXRAD 5

	int radx = m_RadiusX;
	if (radx > BMAXRAD) radx = BMAXRAD;
	int rady = m_RadiusY;
	if (rady > BMAXRAD) rady = BMAXRAD;

	if (!m_Tiled)
	{
		if (((x < 5*BWINC) || (x > 1 - 5*BWINC)) && (radx == 5)) radx = 4;
		if (((x < 4*BWINC) || (x > 1 - 4*BWINC)) && (radx == 4)) radx = 3;
		if (((x < 3*BWINC) || (x > 1 - 3*BWINC)) && (radx == 3)) radx = 2;
		if (((x < 2*BWINC) || (x > 1 - 2*BWINC)) && (radx == 2)) radx = 1;
		if (((x < BWINC) || (x > 1 - BWINC)) && (radx == 1)) radx = 0;
		if (((y < 5*BWINC) || (y > 1 - 5*BWINC)) && (rady == 5)) rady = 4;
		if (((y < 4*BWINC) || (y > 1 - 4*BWINC)) && (rady == 4)) rady = 3;
		if (((y < 3*BWINC) || (y > 1 - 3*BWINC)) && (rady == 3)) rady = 2;
		if (((y < 2*BWINC) || (y > 1 - 2*BWINC)) && (rady == 2)) rady = 1;
		if (((y < BWINC) || (y > 1 - BWINC)) && (rady == 1)) rady = 0;
	}
	real* wx = (radx == 0) ? BlurWTab1 : ((radx == 1) ? BlurWTab3 : ((radx == 2) ?
			BlurWTab5 : ((radx == 3) ? BlurWTab7 : ((radx == 4) ? BlurWTab9 : BlurWTabB))));
	real* wy = (rady == 0) ? BlurWTab1 : ((rady == 1) ? BlurWTab3 : ((rady == 2) ?
			BlurWTab5 : ((rady == 3) ? BlurWTab7 : ((rady == 4) ? BlurWTab9 : BlurWTabB))));

	int sizex = radx*2+1;
	int sizey = rady*2+1;
	col->SetBlackA();
	int i, j;
	real y2 = y - rady*BWINC;
	real x2, wwy;
	CColor c2;

	for (i = 0; i < sizey; i++)
	{
		wwy = wy[i];
		x2 = x - radx*BWINC;
		for (j = 0; j < sizex; j++)
		{
			this->RenderCol1(&c2, x2, y2);
			c2.MulA(wx[j]*wwy);
			col->AddA(c2);
			x2 += BWINC;
		}
		y2 += BWINC;
	}
}

void CFilterBlur::RenderCol(CColor* col, real x, real y)
{
	// get properties
	int radiusX = (int)(CLAMP(m_Prop[PROP_BLUR_RADIUSX].RenderVal(x, y))*BLURMAXRAD + (real)0.5);
	int radiusY = (int)(CLAMP(m_Prop[PROP_BLUR_RADIUSY].RenderVal(x, y))*BLURMAXRAD + (real)0.5);

	if (radiusX > BLURMAXRAD) radiusX = BLURMAXRAD;
	m_RadiusX = radiusX;
	int sizeX = radiusX*2 + 1;
	m_SizeX = sizeX;

	if (radiusY > BLURMAXRAD) radiusY = BLURMAXRAD;
	m_RadiusY = radiusY;
	int sizeY = radiusY*2 + 1;
	m_SizeY = sizeY;

	bool tiled = m_Prop[PROP_BLUR_TILED].RenderVal(x, y) >= 0.5;
	m_Tiled = tiled;

	this->RenderCol2(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBlur::RenderVal(real x, real y)
{
	CColor col;
	CFilterBlur::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterHighPass::CFilterHighPass()
{
	m_Group = FGRP_PROC;
	m_Class = _T("HighPass");
	m_HelpID = HELP_FHIGHPASS;
	m_PropNum = 6;

	this->ClearCache(m_CacheIn);
	this->ClearCache(m_CacheTemp);
	this->ClearCache(m_CacheOut);

	m_Prop[PROP_HIGHPASS_RADIUS].SetName("Radius");
	m_Prop[PROP_HIGHPASS_RADIUS].SetToolID(ID_PROP_RADIUS);
	m_Prop[PROP_HIGHPASS_RADIUS].SetValue((real)0.1);

	m_Prop[PROP_HIGHPASS_STRENGTH].SetName("Strength");
	m_Prop[PROP_HIGHPASS_STRENGTH].SetValue(1);
	m_Prop[PROP_HIGHPASS_STRENGTH].SetToolID(ID_PROP_STRENGTH);

	m_Prop[PROP_HIGHPASS_TILED].SetName("Tiled");
	m_Prop[PROP_HIGHPASS_TILED].SetToolID(ID_PROP_TILED);
	m_Prop[PROP_HIGHPASS_TILED].SetCategory(PCAT_CHECK);
	m_Prop[PROP_HIGHPASS_TILED].SetMax(1);

	m_Prop[PROP_HIGHPASS_LUMIN].SetName("Luminance");
	m_Prop[PROP_HIGHPASS_LUMIN].SetToolID(ID_PROP_HPLUMIN);
	m_Prop[PROP_HIGHPASS_LUMIN].SetCategory(PCAT_CHECK);
	m_Prop[PROP_HIGHPASS_LUMIN].SetMax(1);

	m_Prop[PROP_HIGHPASS_CONTRAST].SetName("Contrast");
	m_Prop[PROP_HIGHPASS_CONTRAST].SetValue((real)0.5);
	m_Prop[PROP_HIGHPASS_CONTRAST].SetToolID(ID_PROP_CONTRAST);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterHighPass::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real strength = m_Prop[PROP_HIGHPASS_STRENGTH].RenderVal(x, y);
	int radius = (int)(CLAMP(m_Prop[PROP_HIGHPASS_RADIUS].RenderVal(x, y))*BLURMAXRAD + (real)0.5);
	real contrast = m_Prop[PROP_HIGHPASS_CONTRAST].RenderVal(x, y);

	if (radius > BLURMAXRAD) radius = BLURMAXRAD;
	m_RadiusX = radius;
	m_RadiusY = radius;
	int s = radius*2 + 1;
	m_SizeX = s;
	m_SizeY = s;

	bool tiled = m_Prop[PROP_HIGHPASS_TILED].RenderVal(x, y) >= 0.5;
	m_Tiled = tiled;
	bool lumin = m_Prop[PROP_HIGHPASS_LUMIN].RenderVal(x, y) >= 0.5;

	// get base blurred color
	CColor c;
	this->RenderCol2(&c, x, y);

	// render color
	CColor c2;
	m_Prop[PROP_SOURCE].RenderCol(&c2, x, y);
	col->Set(c2);

	// difference
	c2.Sub(c);

	// contrast
	c2.Mul(contrast*contrast*4);
	c2.Add((real)0.5);

	// only luminance
	if (lumin)
	{
		real lum = c2.Gray();
		c2.Set(*col);
		c2.RGBToHSL();
		c2.b = lum;
		c2.HSLToRGB();
	}

	// strength
	col->Trans(c2, strength);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterHighPass::RenderVal(real x, real y)
{
	CColor col;
	CFilterHighPass::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterPercentile::CFilterPercentile()
{
	m_Group = FGRP_PROC;
	m_Class = _T("Percentile");
	m_HelpID = HELP_FPERCENTILE;
	m_PropNum = 5;

	m_Tiled = TRUE;
	m_RGB = FALSE;

	this->ClearCache(m_CacheIn);
	this->ClearCache(m_CacheMin);
	this->ClearCache(m_CacheMed);
	this->ClearCache(m_CacheMax);

	m_Prop[PROP_PERCENTILE_RADIUS].SetName("Radius");
	m_Prop[PROP_PERCENTILE_RADIUS].SetToolID(ID_PROP_RADIUS);
	m_Prop[PROP_PERCENTILE_RADIUS].SetValue((real)0.1);

	m_Prop[PROP_PERCENTILE_PERCENTILE].SetName("Percentile");
	m_Prop[PROP_PERCENTILE_PERCENTILE].SetValue((real)0.5);
	m_Prop[PROP_PERCENTILE_PERCENTILE].SetToolID(ID_PROP_PERCENTILE);

	m_Prop[PROP_PERCENTILE_TILED].SetName("Tiled");
	m_Prop[PROP_PERCENTILE_TILED].SetToolID(ID_PROP_TILED);
	m_Prop[PROP_PERCENTILE_TILED].SetCategory(PCAT_CHECK);
	m_Prop[PROP_PERCENTILE_TILED].SetValue(1);
	m_Prop[PROP_PERCENTILE_TILED].SetMax(1);

	m_Prop[PROP_PERCENTILE_RGB].SetName("RGB");
	m_Prop[PROP_PERCENTILE_RGB].SetToolID(ID_PROP_PERCRGB);
	m_Prop[PROP_PERCENTILE_RGB].SetCategory(PCAT_CHECK);
	m_Prop[PROP_PERCENTILE_RGB].SetMax(1);
}

///////////////////////////////////////////////////////////////////////////////
// clear cache

void CFilterPercentile::ClearCache(u64* buf)
{
	int i;
	for (i = PERCCACHESIZE; i > 0; i--) *buf++ = PERCCACHEINV;
}

///////////////////////////////////////////////////////////////////////////////
// load one input sample

u64 CFilterPercentile::LoadIn(int x, int y)
{
	if (m_Restart) return 0;

	u64* d = &m_CacheIn[x + y*PERCCACHEWH];
	u64 n = *d;
	if (n == PERCCACHEINV)
	{
		CColor c;
		m_Prop[PROP_SOURCE].RenderCol(&c, (x+(real)0.5)/PERCCACHEWH, (y+(real)0.5)/PERCCACHEWH);
		n = c.GetRGBA64();
		*d = n;
	}
	return n;
}

///////////////////////////////////////////////////////////////////////////////
// load one sample

void CFilterPercentile::Load1(CColor* col, real perc, int x, int y)
{
	int off = x + y*PERCCACHEWH;
	if (!m_Restart && (m_CacheMed[off] == PERCCACHEINV))
	{
		int i, j, dx, dy, x2, y2;

		// low radius
		int r = (int)m_Radius;
		if (m_Radius - r < (real)0.001) r++;

		int minR, minG, minB, minA, minY;
		u64 medR, medG, medB, medA;
		int medN;
		int maxR, maxG, maxB, maxA, maxY;

		minR = minG = minB = minA = minY = 1000000;
		medR = medG = medB = medA = medN = 0;
		maxR = maxG = maxB = maxA = maxY = -1000000;

		dy = -r;
		int r2 = r*r;
		for (i = 2*r+1; i > 0; i--)
		{
			y2 = y + dy;
			if (y2 < 0) y2 = m_Tiled ? (y2 + PERCCACHEWH) : 0;
			if (y2 >= PERCCACHEWH) y2 = m_Tiled ? (y2 - PERCCACHEWH) : (PERCCACHEWH-1);

			dx = -r;
			for (j = 2*r+1; j > 0; j--)
			{		
				x2 = x + dx;
				if (x2 < 0) x2 = m_Tiled ? (x2 + PERCCACHEWH) : 0;
				if (x2 >= PERCCACHEWH) x2 = m_Tiled ? (x2 - PERCCACHEWH) : (PERCCACHEWH-1);

				if (dx*dx + dy*dy <= r2)
				{
					u64 c = this->LoadIn(x2, y2);

					int r = (int)(c & 0xffff);
					int g = (int)((c >> 16) & 0xffff);
					int b = (int)((c >> 32) & 0xffff);
					int a = (int)(c >> 48);
					int y = r + g + b;

					medR += r; medG += g; medB += b; medA += a;
					medN++;

					if (m_RGB)
					{
						if (r < minR) minR = r;
						if (g < minG) minG = g;
						if (b < minB) minB = b;
						if (a < minA) minA = a;

						if (r > maxR) maxR = r;
						if (g > maxG) maxG = g;
						if (b > maxB) maxB = b;
						if (a > maxA) maxA = a;
					}
					else
					{
						if (y < minY)
						{
							minR = r; minG = g; minB = b; minA = a; minY = y;
						}

						if (y > maxY)
						{
							maxR = r; maxG = g; maxB = b; maxA = a; maxY = y;
						}
					}
				}
				dx++;
			}
			dy++;
		}
		medR /= medN; medG /= medN; medB /= medN; medA /= medN;

		// high radius
		if (m_Radius - r > (real)0.001)
		{
			r++;

			int minR2, minG2, minB2, minA2, minY2;
			u64 medR2, medG2, medB2, medA2;
			int medN2;
			int maxR2, maxG2, maxB2, maxA2, maxY2;

			minR2 = minG2 = minB2 = minA2 = minY2 = 100000;
			medR2 = medG2 = medB2 = medA2 = medN2 = 0;
			maxR2 = maxG2 = maxB2 = maxA2 = maxY2 = -100000;

			dy = -r;
			r2 = r*r;
			for (i = 2*r+1; i > 0; i--)
			{
				y2 = y + dy;
				if (y2 < 0) y2 = m_Tiled ? (y2 + PERCCACHEWH) : 0;
				if (y2 >= PERCCACHEWH) y2 = m_Tiled ? (y2 - PERCCACHEWH) : (PERCCACHEWH-1);

				dx = -r;
				for (j = 2*r+1; j > 0; j--)
				{		
					x2 = x + dx;
					if (x2 < 0) x2 = m_Tiled ? (x2 + PERCCACHEWH) : 0;
					if (x2 >= PERCCACHEWH) x2 = m_Tiled ? (x2 - PERCCACHEWH) : (PERCCACHEWH-1);

					if (dx*dx + dy*dy <= r2)
					{
						u64 c = this->LoadIn(x2, y2);

						int r = (int)(c & 0xffff);
						int g = (int)((c >> 16) & 0xffff);
						int b = (int)((c >> 32) & 0xffff);
						int a = (int)(c >> 48);
						int y = r + g + b;

						medR2 += r; medG2 += g; medB2 += b; medA2 += a;
						medN2++;

						if (m_RGB)
						{
							if (r < minR2) minR2 = r;
							if (g < minG2) minG2 = g;
							if (b < minB2) minB2 = b;
							if (a < minA2) minA2 = a;

							if (r > maxR2) maxR2 = r;
							if (g > maxG2) maxG2 = g;
							if (b > maxB2) maxB2 = b;
							if (a > maxA2) maxA2 = a;
						}
						else
						{
							if (y < minY2)
							{
								minR2 = r; minG2 = g; minB2 = b; minA2 = a; minY2 = y;
							}

							if (y > maxY2)
							{
								maxR2 = r; maxG2 = g; maxB2 = b; maxA2 = a; maxY2 = y;
							}
						}
					}
					dx++;
				}
				dy++;
			}
			medR2 /= medN2; medG2 /= medN2; medB2 /= medN2; medA2 /= medN2;

			// interpolate values
			r = (int)m_Radius;
			real w = m_Radius - r;

			minR = (int)((minR2 - minR)*w + minR);
			minG = (int)((minG2 - minG)*w + minG);
			minB = (int)((minB2 - minB)*w + minB);
			minA = (int)((minA2 - minA)*w + minA);

			medR = (int)(((int)medR2 - (int)medR)*w + (int)medR);
			medG = (int)(((int)medG2 - (int)medG)*w + (int)medG);
			medB = (int)(((int)medB2 - (int)medB)*w + (int)medB);
			medA = (int)(((int)medA2 - (int)medA)*w + (int)medA);

			maxR = (int)((maxR2 - maxR)*w + maxR);
			maxG = (int)((maxG2 - maxG)*w + maxG);
			maxB = (int)((maxB2 - maxB)*w + maxB);
			maxA = (int)((maxA2 - maxA)*w + maxA);
		}

		// save values
		m_CacheMin[off] = minR | ((u64)minG << 16) | ((u64)minB << 32) | ((u64)minA << 48);
		m_CacheMed[off] = medR | (medG << 16) | (medB << 32) | (medA << 48);
		m_CacheMax[off] = maxR | ((u64)maxG << 16) | ((u64)maxB << 32) | ((u64)maxA << 48);
	}

	perc *= 2;
	if (perc <= 1)
	{
		col->SetRGBA64(m_CacheMin[off]);
		if (perc > 0)
		{
			CColor c;
			c.SetRGBA64(m_CacheMed[off]);
			col->Trans(c, perc);
		}
	}
	else
	{
		perc -= 1;
		if (perc < 1)
		{
			col->SetRGBA64(m_CacheMed[off]);
			CColor c;
			c.SetRGBA64(m_CacheMax[off]);
			col->Trans(c, perc);
		}
		else
			col->SetRGBA64(m_CacheMax[off]);
	}
}

///////////////////////////////////////////////////////////////////////////////
// render color of one pixel

void CFilterPercentile::RenderCol1(CColor* col, real perc, real x, real y)
{
	// prepare coordinates
	if (m_Tiled)
	{
		if (x >= 1) x -= (int)x;
		if (x < 0) x += (int)(1 - x);
		if (y >= 1) y -= (int)y;
		if (y < 0) y += (int)(1 - y);
	}
	else
	{
		x = CLAMP(x);
		y = CLAMP(y);
	}

	x *= PERCCACHEWH;
	int x1 = (int)x;
	if (x1 >= PERCCACHEWH) x1 = PERCCACHEWH - 1;
	x -= x1;
	int x2 = x1 + 1;
	if (x2 >= PERCCACHEWH) x2 = m_Tiled ? 0 : x1;

	y *= PERCCACHEWH;
	int y1 = (int)y;
	if (y1 >= PERCCACHEWH) y1 = PERCCACHEWH - 1;
	y -= y1;
	int y2 = y1 + 1;
	if (y2 >= PERCCACHEWH) y2 = m_Tiled ? 0 : y1;

	// load samples
	CColor c11, c21, c12, c22;
	this->Load1(&c11, perc, x1, y1);
	this->Load1(&c21, perc, x2, y1);
	this->Load1(&c12, perc, x1, y2);
	this->Load1(&c22, perc, x2, y2);

	// interpolate
	c11.Trans(c21, x);
	c12.Trans(c22, x);
	col->Trans(c11, c12, y);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterPercentile::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real perc = m_Prop[PROP_PERCENTILE_PERCENTILE].RenderVal(x, y);
	m_Radius = CLAMP(m_Prop[PROP_PERCENTILE_RADIUS].RenderVal(x, y))*PERCMAXRAD;
	m_Tiled = m_Prop[PROP_PERCENTILE_TILED].RenderVal(x, y) >= 0.5;
	m_RGB = m_Prop[PROP_PERCENTILE_RGB].RenderVal(x, y) >= 0.5;

	// clear cache
	if (m_Restart)
	{
		m_Restart = FALSE;
		this->ClearCache(m_CacheIn);
		this->ClearCache(m_CacheMin);
		this->ClearCache(m_CacheMed);
		this->ClearCache(m_CacheMax);
	}

	// get color
	this->RenderCol1(col, perc, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterPercentile::RenderVal(real x, real y)
{
	CColor col;
	CFilterPercentile::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterEmboss::CFilterEmboss()
{
	m_Group = FGRP_PROC;
	m_Class = _T("Emboss");
	m_HelpID = HELP_FEMBOSS;
	m_PropNum = 12;

	m_Prop[PROP_SOURCE].SetValue((real)128/255);

	m_Prop[PROP_EMBOSS_HEIGHTMAP].SetName("HeightMap");
	m_Prop[PROP_EMBOSS_HEIGHTMAP].SetToolID(ID_PROP_HEIGHTMAP);

	m_Prop[PROP_EMBOSS_BASE].SetName("Base");
	m_Prop[PROP_EMBOSS_BASE].SetToolID(ID_PROP_EMBBASE);

	m_Prop[PROP_EMBOSS_DIFFUSE].SetName("Diffuse");
	m_Prop[PROP_EMBOSS_DIFFUSE].SetValue((real)0.5);
	m_Prop[PROP_EMBOSS_DIFFUSE].SetToolID(ID_PROP_DIFFUSE);

	m_Prop[PROP_EMBOSS_AMBIENT].SetName("Ambient");
	m_Prop[PROP_EMBOSS_AMBIENT].SetValue(0.5);
	m_Prop[PROP_EMBOSS_AMBIENT].SetToolID(ID_PROP_AMBIENT);

	m_Prop[PROP_EMBOSS_SPECULAR].SetName("Specular");
	m_Prop[PROP_EMBOSS_SPECULAR].SetValue(0.5);
	m_Prop[PROP_EMBOSS_SPECULAR].SetToolID(ID_PROP_SPECULAR);

	m_Prop[PROP_EMBOSS_METAL].SetName("Metal");
	m_Prop[PROP_EMBOSS_METAL].SetValue((real)0.25);
	m_Prop[PROP_EMBOSS_METAL].SetToolID(ID_PROP_METAL);

	m_Prop[PROP_EMBOSS_SATURATION].SetName("Saturation");
	m_Prop[PROP_EMBOSS_SATURATION].SetValue((real)0.5);
	m_Prop[PROP_EMBOSS_SATURATION].SetToolID(ID_PROP_EMBOSSSAT);

	m_Prop[PROP_EMBOSS_SCALE].SetName("Scale");
	m_Prop[PROP_EMBOSS_SCALE].SetValue((real)0.5);
	m_Prop[PROP_EMBOSS_SCALE].SetToolID(ID_PROP_EMBOSSSCALE);

	m_Prop[PROP_EMBOSS_SHIFTX].SetName("ShiftX");
	m_Prop[PROP_EMBOSS_SHIFTX].SetValue((real)0.25);
	m_Prop[PROP_EMBOSS_SHIFTX].SetMin(-50);
	m_Prop[PROP_EMBOSS_SHIFTX].SetMax(50);
	m_Prop[PROP_EMBOSS_SHIFTX].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_EMBOSS_SHIFTY].SetName("ShiftY");
	m_Prop[PROP_EMBOSS_SHIFTY].SetValue((real)0.75);
	m_Prop[PROP_EMBOSS_SHIFTY].SetMin(-50);
	m_Prop[PROP_EMBOSS_SHIFTY].SetMax(50);
	m_Prop[PROP_EMBOSS_SHIFTY].SetToolID(ID_PROP_SHIFTY);

	m_Prop[PROP_EMBOSS_ENVIRONMENT].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EMBOSS_ENVIRONMENT].SetName("Environment");
	m_Prop[PROP_EMBOSS_ENVIRONMENT].SetValue((real)0.3);
	m_Prop[PROP_EMBOSS_ENVIRONMENT].SetMax(10);
	m_Prop[PROP_EMBOSS_ENVIRONMENT].SetEnum(EnvPicName);
	m_Prop[PROP_EMBOSS_ENVIRONMENT].SetToolID(ID_PROP_ENVIRONMENT);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterEmboss::RenderCol(CColor* col, real x, real y)
{
	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);

	// derivations
	real dx, dy;
	real level = m_Prop[PROP_EMBOSS_HEIGHTMAP].Derive(x, y, &dx, &dy);
	real dx0 = dx;
	real dy0 = dy;

	// base level
	real base = m_Prop[PROP_EMBOSS_BASE].RenderVal(x, y);
	if (level < base) return;

	// load properties
	real diffuse = m_Prop[PROP_EMBOSS_DIFFUSE].RenderVal(x, y);
	diffuse = diffuse*diffuse*10;
	real ambient = m_Prop[PROP_EMBOSS_AMBIENT].RenderVal(x, y);
	real specular = m_Prop[PROP_EMBOSS_SPECULAR].RenderVal(x, y);
	real metal = m_Prop[PROP_EMBOSS_METAL].RenderVal(x, y);
	real saturation = m_Prop[PROP_EMBOSS_SATURATION].RenderVal(x, y);
	real scale0 = m_Prop[PROP_EMBOSS_SCALE].RenderVal(x, y);
	real scale = pow(2,CLAMP(1-scale0)*10)*4;
	real shiftx = CLAMP(m_Prop[PROP_EMBOSS_SHIFTX].RenderVal(x, y)) - (real)0.5;
	real shifty = CLAMP(m_Prop[PROP_EMBOSS_SHIFTY].RenderVal(x, y)) - (real)0.5;

	// environment
	int env = (int)(m_Prop[PROP_EMBOSS_ENVIRONMENT].RenderVal(x, y)*10 + (real)0.5);
	if ((DWORD)env >= ENVPICNUM) env = 0;
	SCanvas* pic = EnvPic[env];

	// add diffuse light
	real d = atan((dx - dy)*1000)/(PI/2)/2;
	if (d < 0) d /= 2;
	ambient += d*diffuse;

	// add ambient light
	if (ambient > (real)0.5)
		col->Add(ambient - (real)0.5);
	else
		col->Brightness(ambient);
	col->Clamp();

	// environment color
	dx = dx*scale - shiftx;
	if (dx >= 1) dx -= (int)dx;
	if (dx < 0) dx += (int)(1 - dx);
	dx *= 2;
	if (dx > 1) dx = 2 - dx;

	dx *= ENVPICW;
	if (dx < 0) dx = 0;
	if (dx > ENVPICW) dx = ENVPICW;
	int xi = (int)dx;
	if (xi >= ENVPICW) xi = ENVPICW-1;
	dx -= xi;
	int xi2 = xi + 1;
	if (xi2 >= ENVPICW) xi2 = ENVPICW-1;

	dy = -dy*scale + shifty;
	if (dy >= 1) dy -= (int)dy;
	if (dy < 0) dy += (int)(1 - dy);
	dy *= 2;
	if (dy > 1) dy = 2 - dy;

	dy *= ENVPICH;
	if (dy < 0) dy = 0;
	if (dy > ENVPICH) dy = ENVPICH;
	int yi = (int)dy;
	if (yi >= ENVPICH) yi = ENVPICH-1;
	dy -= yi;
	int yi2 = yi + 1;
	if (yi2 >= ENVPICH) yi2 = ENVPICH-1;

	// add metal and saturation
	CColor c;
	c.TransBGR(*(u32*)&pic->d[(xi + yi*ENVPICW)*3],
				*(u32*)&pic->d[(xi2 + yi*ENVPICW)*3],
				*(u32*)&pic->d[(xi + yi2*ENVPICW)*3],
				*(u32*)&pic->d[(xi2 + yi2*ENVPICW)*3],
				dx, dy);
	real a = col->a;
	CColor c2;
	c2.Trans(*col, c, metal);
	col->Add((c.Gray() - (real)0.5)*metal);
	col->Clamp();
	col->Trans(c2, saturation);
	col->a = a;

	/*
	CColor c2;
	c2.Trans(*col, c, saturation*metal);
	c2.RGBToHSL();
	c.RGBToHSL();
	col->RGBToHSL();
	col->r = c2.r; // Hue
	col->g = CLAMP(c2.g*(1-metal/2) - ((c.b > col->b) ? ((c.b - col->b)*(1-saturation)*metal) : 0)); // Saturation
	col->b = col->b*(1-metal) + c.b*metal; // Lumination
	col->HSLToRGB();
	*/

	// add specular
#define DGRAD ((real)0.001)
#define DLGHT ((real)0.1)
	//  vx = (DGRAD, 0, dx0) ... gradient vector in X direction
	//  vy = (0, DGRAD, dy0) ... gradient vector in Y direction
	//     v1 x v2 = (y1*z2-y2*z1, z1*x2-z2*x1, x1*y2- x2*y1)
	//  vn = (DGRAD*dx0, DGRAD*dy0, DGRAD*DGRAD) ... normal vector
	//  vnlen = DGRAD*sqrt(dx0*dx0 + dy0*dy0 + DGRAD*DGRAD) ... length of normal vector
	//  vl = (sx, sy, DLGHT) ... light vector, sx,sy=shift
	//  vllen = sqrt(sx*sx + sy*sy + DLGHT*DLGHT) ... length of light vector
	//     dot = vn . vl = DGRAD*(dx0*sx + dy0*sy + DGRAD*DLGHT)
	//  spec = dot/vnlen/vllen = (dx0*sx + dy0*sy + DGRAD*DLGHT)/sqrt(dx0*dx0+dy0*dy0+DGRAD*DGRAD)/sqrt(sx*sx+sy*sy+0.01)
	d = (-dx0*shiftx-dy0*shifty+DGRAD*DLGHT)/sqrt((dx0*dx0+dy0*dy0+DGRAD*DGRAD)*(shiftx*shiftx+shifty*shifty+DLGHT*DLGHT)); //*(real)1.2 - (real)0.2;
	if (d > 0)
	{
		d = d*d*specular*specular*2 - (real)0.2;
		//d = pow(d,pow(2,(1-scale0)*5))*specular*specular*2 - (real)0.2;
		if (d > 0)
		{
			col->Add(d);
			col->Clamp();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterEmboss::RenderVal(real x, real y)
{
	CColor col;
	CFilterEmboss::RenderCol(&col, x, y);
	return col.Gray();
}

#define PROP_SMOOTH_RADIUS	1	// property - radius
#define PROP_SMOOTH_POINTS	2	// property - points

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterSmooth::CFilterSmooth()
{
	m_Group = FGRP_PROC;
	m_Class = _T("Smooth");
	m_HelpID = HELP_FSMOOTH;
	m_PropNum = 3;

	m_Prop[PROP_SMOOTH_RADIUS].SetName("Radius");
	m_Prop[PROP_SMOOTH_RADIUS].SetToolID(ID_SMOOTH_RADIUS);
	m_Prop[PROP_SMOOTH_RADIUS].SetValue((real)0.05);

	m_Prop[PROP_SMOOTH_POINTS].SetCategory(PCAT_ENUM);
	m_Prop[PROP_SMOOTH_POINTS].SetName("Points");
	m_Prop[PROP_SMOOTH_POINTS].SetMax(10);
	m_Prop[PROP_SMOOTH_POINTS].SetValue((real)0.1);
	m_Prop[PROP_SMOOTH_POINTS].SetEnum(SmoothPointsName);
	m_Prop[PROP_SMOOTH_POINTS].SetToolID(ID_SMOOTH_POINTS);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

#define SW0			(real)1.0

#define SW51_		(real)0.6
#define SWS5		(SW0+4*SW51_)
#define SW50		SW0/SWS5
#define SW51		SW51_/SWS5

#define SW91_		(real)0.75
#define SW92_		(real)0.5
#define SWS9		(SW0+4*SW91_+4*SW92_)
#define SW90		SW0/SWS9
#define SW91		SW91_/SWS9
#define SW92		SW92_/SWS9

#define SW211_		(real)0.8
#define SW212_		(real)0.6
#define SW213_		(real)0.5
#define SW214_		(real)0.4
#define SWS21		(SW0+4*SW211_+4*SW212_+4*SW213_+8*SW214_)
#define SW210		SW0/SWS21
#define SW211		SW211_/SWS21
#define SW212		SW212_/SWS21
#define SW213		SW213_/SWS21
#define SW214		SW214_/SWS21

#define SMCOL(dx,dy,cc) { m_Prop[PROP_SOURCE].RenderCol(&c, x+(dx), y+(dy)); c.MulA(cc); col->AddA(c); }

void CFilterSmooth::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real r = m_Prop[PROP_SMOOTH_RADIUS].RenderVal(x, y)/100;
	if (r <= (real)0.00001)
	{
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
		return;
	}
	int points = (int)(m_Prop[PROP_SMOOTH_POINTS].RenderVal(x, y)*10 + (real)0.5);
	if (points < 0) points = 0;

	// render color
	col->SetBlackA();
	CColor c;

	switch (points)
	{
	// 5 points
	case 0:
		SMCOL(-r,+r,SW51);						SMCOL(+r,+r,SW51);
							SMCOL(0,0,SW50);
		SMCOL(-r,-r,SW51);						SMCOL(+r,-r,SW51);
		break;

	// 9 points
	case 1:
		SMCOL(-r,+r,SW92);	SMCOL(0,+r,SW91);	SMCOL(+r,+r,SW92);
		SMCOL(-r,0,SW91);	SMCOL(0,0,SW90);	SMCOL(+r,0,SW91);
		SMCOL(-r,-r,SW92);	SMCOL(0,-r,SW91);	SMCOL(+r,-r,SW92);
		break;

	// 21 points
	default:
							SMCOL(-r,2*r,SW214); SMCOL(0,2*r,SW213); SMCOL(+r,2*r,SW214);
		SMCOL(-2*r,+r,SW214); SMCOL(-r,+r,SW212); SMCOL(0,+r,SW211); SMCOL(+r,+r,SW212);	SMCOL(2*r,+r,SW214);
		SMCOL(-2*r,0,SW213); SMCOL(-r,0,SW211); SMCOL(0,0,SW210);	SMCOL(+r,0,SW211);   	SMCOL(2*r,0,SW213);
		SMCOL(-2*r,-r,SW214); SMCOL(-r,-r,SW212); SMCOL(0,-r,SW211); SMCOL(+r,-r,SW212);	SMCOL(2*r,-r,SW214);
							SMCOL(-r,-2*r,SW214); SMCOL(0,-2*r,SW213); SMCOL(+r,-2*r,SW214);
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterSmooth::RenderVal(real x, real y)
{
	CColor col;
	CFilterSmooth::RenderCol(&col, x, y);
	return col.Gray();
}

#define PROP_NORMAL_STRENGTH	1	// property - strength

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterNormal::CFilterNormal()
{
	m_Group = FGRP_PROC;
	m_Class = _T("Normal");
	m_HelpID = HELP_FNORMAL;
	m_PropNum = 2;

	m_Prop[PROP_SOURCE].SetCategory(PCAT_VAL);
	m_Prop[PROP_SOURCE].SetName("HeightMap");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_HEIGHTMAP);

	m_Prop[PROP_NORMAL_STRENGTH].SetName("Strength");
	m_Prop[PROP_NORMAL_STRENGTH].SetValue((real)0.5);
	m_Prop[PROP_NORMAL_STRENGTH].SetToolID(ID_PROP_STRENGTH);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterNormal::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real strength = pow(2,m_Prop[PROP_NORMAL_STRENGTH].RenderVal(x, y)*12)*2;

	// derivations
	real dx, dy;
	m_Prop[PROP_SOURCE].Derive(x, y, &dx, &dy);

	// get normal vector
	dx *= -strength;
	dy *= -strength;
	real k = 1/sqrt(dx*dx + dy*dy + 1);
	dx *= k;
	dy *= k;

	// set normal
	col->r = dx/2 + (real)0.5;
	col->g = dy/2 + (real)0.5;
	col->b = k/2 + (real)0.5;
	col->a = 1;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterNormal::RenderVal(real x, real y)
{
	CColor col;
	CFilterNormal::RenderCol(&col, x, y);
	return col.Gray();
}

#define PROP_CONTOUR_RADIUS		1	// property - radius
#define PROP_CONTOUR_TILED		2	// property - tiled

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterContour::CFilterContour()
{
	m_Group = FGRP_PROC;
	m_Class = _T("Contour");
	m_HelpID = HELP_FCONTOUR;
	m_PropNum = 3;

	m_Prop[PROP_CONTOUR_RADIUS].SetName("Radius");
	m_Prop[PROP_CONTOUR_RADIUS].SetValue((real)0.1);
	m_Prop[PROP_CONTOUR_RADIUS].SetToolID(ID_CONTOUR_RADIUS);

	m_Prop[PROP_CONTOUR_TILED].SetName("Tiled");
	m_Prop[PROP_CONTOUR_TILED].SetToolID(ID_PROP_TILED);
	m_Prop[PROP_CONTOUR_TILED].SetCategory(PCAT_CHECK);
	m_Prop[PROP_CONTOUR_TILED].SetMax(1);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterContour::RenderCol(CColor* col, real x, real y)
{
	// get properties
	real radius = m_Prop[PROP_CONTOUR_RADIUS].RenderVal(x, y)/50;
	bool tiled = m_Prop[PROP_CONTOUR_TILED].RenderVal(x, y) >= 0.5;

	// tiled
	real x1 = x - radius;
	real x2 = x + radius;
	real y1 = y - radius;
	real y2 = y + radius;
	if (tiled)
	{
		if (x1 >= 1) x1 -= (int)x1;
		if (x1 < 0) x1 += (int)(1 - x1);
		if (x2 >= 1) x2 -= (int)x2;
		if (x2 < 0) x2 += (int)(1 - x2);
		if (y1 >= 1) y1 -= (int)y1;
		if (y1 < 0) y1 += (int)(1 - y1);
		if (y2 >= 1) y2 -= (int)y2;
		if (y2 < 0) y2 += (int)(1 - y2);
	}
	else
	{
		if (x1 < (real)0.0001) x1 = (real)0.0001;
		if (x2 < (real)0.0001) x2 = (real)0.0001;
		if (y1 < (real)0.0001) y1 = (real)0.0001;
		if (y2 < (real)0.0001) y2 = (real)0.0001;
		if (x1 > (real)0.9999) x1 = (real)0.9999;
		if (x2 > (real)0.9999) x2 = (real)0.9999;
		if (y1 > (real)0.9999) y1 = (real)0.9999;
		if (y2 > (real)0.9999) y2 = (real)0.9999;
	}

	// derivations
	CColor c1, c2, c3, c4;
	m_Prop[PROP_SOURCE].RenderCol(&c1, x1, y1);
	m_Prop[PROP_SOURCE].RenderCol(&c2, x2, y1);
	m_Prop[PROP_SOURCE].RenderCol(&c3, x1, y2);
	m_Prop[PROP_SOURCE].RenderCol(&c4, x2, y2);

	// generate contour
	real a, b;
	a = abs(c1.r-c2.r);
	b = abs(c1.r-c3.r);
	if (b > a) a = b;
	b = abs(c1.r-c4.r);
	if (b > a) a = b;
	b = abs(c2.r-c3.r);
	if (b > a) a = b;
	b = abs(c2.r-c4.r);
	if (b > a) a = b;
	b = abs(c3.r-c4.r);
	if (b > a) a = b;
	col->r = a;

	a = abs(c1.g-c2.g);
	b = abs(c1.g-c3.g);
	if (b > a) a = b;
	b = abs(c1.g-c4.g);
	if (b > a) a = b;
	b = abs(c2.g-c3.g);
	if (b > a) a = b;
	b = abs(c2.g-c4.g);
	if (b > a) a = b;
	b = abs(c3.g-c4.g);
	if (b > a) a = b;
	col->g = a;

	a = abs(c1.b-c2.b);
	b = abs(c1.b-c3.b);
	if (b > a) a = b;
	b = abs(c1.b-c4.b);
	if (b > a) a = b;
	b = abs(c2.b-c3.b);
	if (b > a) a = b;
	b = abs(c2.b-c4.b);
	if (b > a) a = b;
	b = abs(c3.b-c4.b);
	if (b > a) a = b;
	col->b = a;

	col->a = (c1.a + c2.a + c3.a + c4.a)/4;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterContour::RenderVal(real x, real y)
{
	// get properties
	real radius = m_Prop[PROP_CONTOUR_RADIUS].RenderVal(x, y)/50;
	bool tiled = m_Prop[PROP_CONTOUR_TILED].RenderVal(x, y) >= 0.5;

	// tiled
	real x1 = x - radius;
	real x2 = x + radius;
	real y1 = y - radius;
	real y2 = y + radius;
	if (tiled)
	{
		if (x1 >= 1) x1 -= (int)x1;
		if (x1 < 0) x1 += (int)(1 - x1);
		if (x2 >= 1) x2 -= (int)x2;
		if (x2 < 0) x2 += (int)(1 - x2);
		if (y1 >= 1) y1 -= (int)y1;
		if (y1 < 0) y1 += (int)(1 - y1);
		if (y2 >= 1) y2 -= (int)y2;
		if (y2 < 0) y2 += (int)(1 - y2);
	}
	else
	{
		if (x1 < (real)0.0001) x1 = (real)0.0001;
		if (x2 < (real)0.0001) x2 = (real)0.0001;
		if (y1 < (real)0.0001) y1 = (real)0.0001;
		if (y2 < (real)0.0001) y2 = (real)0.0001;
		if (x1 > (real)0.9999) x1 = (real)0.9999;
		if (x2 > (real)0.9999) x2 = (real)0.9999;
		if (y1 > (real)0.9999) y1 = (real)0.9999;
		if (y2 > (real)0.9999) y2 = (real)0.9999;
	}

	// derivations
	real c1, c2, c3, c4;
	c1 = m_Prop[PROP_SOURCE].RenderVal(x1, y1);
	c2 = m_Prop[PROP_SOURCE].RenderVal(x2, y1);
	c3 = m_Prop[PROP_SOURCE].RenderVal(x1, y2);
	c4 = m_Prop[PROP_SOURCE].RenderVal(x2, y2);

	// generate contour
	real a, b;
	a = abs(c1-c2);
	b = abs(c1-c3);
	if (b > a) a = b;
	b = abs(c1-c4);
	if (b > a) a = b;
	b = abs(c2-c3);
	if (b > a) a = b;
	b = abs(c2-c4);
	if (b > a) a = b;
	b = abs(c3-c4);
	if (b > a) a = b;
	return a;
}
