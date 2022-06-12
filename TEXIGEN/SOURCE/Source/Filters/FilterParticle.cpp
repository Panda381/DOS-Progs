
///////////////////////////////////////////////////////////////////////////////
//
//                            Particle Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROP_PARTICLE_CHANCE1		5		// property - Chance1
#define PROP_PARTICLE_CHANCE2		6		// property - Chance2
#define PROP_PARTICLE_CHANCE3		7		// property - Chance3
#define PROP_PARTICLE_CHANCE4		8		// property - Chance4
#define PROP_PARTICLE_CHANCE5		9		// property - Chance5
#define PROP_PARTICLE_BACKGROUND	10		// property - Background
#define PROP_PARTICLE_SIZE			11		// property - Size
#define PROP_PARTICLE_RNDSIZE		12		// property - RndSize
#define PROP_PARTICLE_ANGLE			13		// property - Angle
#define PROP_PARTICLE_RNDANGLE		14		// property - RndAngle
#define PROP_PARTICLE_SQUASH		15		// property - Squash
#define PROP_PARTICLE_RNDSQUASH		16		// property - RndSquash
#define PROP_PARTICLE_RNDPOSX		17		// property - RndPosX
#define PROP_PARTICLE_RNDPOSY		18		// property - RndPosY
#define PROP_PARTICLE_RNDHUE		19		// property - RndHue
#define PROP_PARTICLE_RNDSAT		20		// property - RndSat
#define PROP_PARTICLE_RNDLUM		21		// property - RndLum
#define PROP_PARTICLE_TINTCOL		22		// property - TintCol
#define PROP_PARTICLE_TINT			23		// property - Tint
#define PROP_PARTICLE_TINTMODE		24		// property - TintMode
#define PROP_PARTICLE_OPACITY		25		// property - Opacity
#define PROP_PARTICLE_RNDOPACITY	26		// property - RndOpacity
#define PROP_PARTICLE_BLEND			27		// property - Blend
#define PROP_PARTICLE_DETAILS		28		// property - Details
#define PROP_PARTICLE_ROUGHNESS		29		// property - Roughness
#define PROP_PARTICLE_POSX			30		// property - PosX
#define PROP_PARTICLE_POSY			31		// property - PosY
#define PROP_PARTICLE_SCALE			32		// property - Scale
#define PROP_PARTICLE_SQUEEZE		33		// property - Squeeze
#define PROP_PARTICLE_SEED			34		// property - Seed

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterParticle::CFilterParticle()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Particle");
	m_HelpID = HELP_FPARTICLE;
	m_Category = FCAT_PARTICLE;
	m_PropNum = 35;

	m_ParticleX = (real)0.5;
	m_ParticleY = (real)0.5;
	m_Band = 0;

	m_Prop[PROP_SOURCE].SetColor((real)0/255, (real)128/255, (real)192/255);
	m_Prop[PROP_SOURCE2].SetColor((real)221/255, (real)160/255, (real)34/255);
	m_Prop[PROP_SOURCE3].SetColor((real)87/255, (real)196/255, (real)15/255);
	m_Prop[PROP_SOURCE4].SetColor((real)206/255, (real)49/255, (real)132/255);
	m_Prop[PROP_SOURCE5].SetColor((real)232/255, (real)227/255, (real)57/255);

	m_Prop[PROP_PARTICLE_CHANCE1].SetName("Chance1");
	m_Prop[PROP_PARTICLE_CHANCE1].SetValue((real)0.75);
	m_Prop[PROP_PARTICLE_CHANCE1].SetToolID(ID_PROP_PARTCHANCE1);

	m_Prop[PROP_PARTICLE_CHANCE2].SetName("Chance2");
	m_Prop[PROP_PARTICLE_CHANCE2].SetToolID(ID_PROP_PARTCHANCE2);

	m_Prop[PROP_PARTICLE_CHANCE3].SetName("Chance3");
	m_Prop[PROP_PARTICLE_CHANCE3].SetToolID(ID_PROP_PARTCHANCE3);

	m_Prop[PROP_PARTICLE_CHANCE4].SetName("Chance4");
	m_Prop[PROP_PARTICLE_CHANCE4].SetToolID(ID_PROP_PARTCHANCE4);

	m_Prop[PROP_PARTICLE_CHANCE5].SetName("Chance5");
	m_Prop[PROP_PARTICLE_CHANCE5].SetToolID(ID_PROP_PARTCHANCE5);

	m_Prop[PROP_PARTICLE_BACKGROUND].SetCategory(PCAT_COLOR);
	m_Prop[PROP_PARTICLE_BACKGROUND].SetName("Background");
	m_Prop[PROP_PARTICLE_BACKGROUND].SetToolID(ID_PROP_PARTBACK);

	m_Prop[PROP_PARTICLE_SIZE].SetName("Size");
	m_Prop[PROP_PARTICLE_SIZE].SetValue((real)0.5);
	m_Prop[PROP_PARTICLE_SIZE].SetToolID(ID_PROP_PARTSIZE);

	m_Prop[PROP_PARTICLE_RNDSIZE].SetName("RndSize");
	m_Prop[PROP_PARTICLE_RNDSIZE].SetValue((real)0.5);
	m_Prop[PROP_PARTICLE_RNDSIZE].SetToolID(ID_PROP_PARTRNDSIZE);

	m_Prop[PROP_PARTICLE_ANGLE].SetName("Angle");
	m_Prop[PROP_PARTICLE_ANGLE].SetValue((real)0.5);
	m_Prop[PROP_PARTICLE_ANGLE].SetMin(-180);
	m_Prop[PROP_PARTICLE_ANGLE].SetMax(180);
	m_Prop[PROP_PARTICLE_ANGLE].SetToolID(ID_PROP_PARTANGLE);

	m_Prop[PROP_PARTICLE_RNDANGLE].SetName("RndAngle");
	m_Prop[PROP_PARTICLE_RNDANGLE].SetValue((real)1);
	m_Prop[PROP_PARTICLE_RNDANGLE].SetToolID(ID_PROP_PARTRNDANGLE);

	m_Prop[PROP_PARTICLE_SQUASH].SetName("Squash");
	m_Prop[PROP_PARTICLE_SQUASH].SetValue((real)0.5);
	m_Prop[PROP_PARTICLE_SQUASH].SetMin(-50);
	m_Prop[PROP_PARTICLE_SQUASH].SetMax(50);
	m_Prop[PROP_PARTICLE_SQUASH].SetToolID(ID_PROP_PARTSQUASH);

	m_Prop[PROP_PARTICLE_RNDSQUASH].SetName("RndSquash");
	m_Prop[PROP_PARTICLE_RNDSQUASH].SetToolID(ID_PROP_PARTRNDSQUASH);

	m_Prop[PROP_PARTICLE_RNDPOSX].SetName("RndPosX");
	m_Prop[PROP_PARTICLE_RNDPOSX].SetValue(1);
	m_Prop[PROP_PARTICLE_RNDPOSX].SetToolID(ID_PROP_PARTRNDPOSX);

	m_Prop[PROP_PARTICLE_RNDPOSY].SetName("RndPosY");
	m_Prop[PROP_PARTICLE_RNDPOSY].SetValue(1);
	m_Prop[PROP_PARTICLE_RNDPOSY].SetToolID(ID_PROP_PARTRNDPOSY);

	m_Prop[PROP_PARTICLE_RNDHUE].SetName("RndHue");
	m_Prop[PROP_PARTICLE_RNDHUE].SetToolID(ID_PROP_PARTRNDHUE);

	m_Prop[PROP_PARTICLE_RNDSAT].SetName("RndSat");
	m_Prop[PROP_PARTICLE_RNDSAT].SetToolID(ID_PROP_PARTRNDSAT);

	m_Prop[PROP_PARTICLE_RNDLUM].SetName("RndLum");
	m_Prop[PROP_PARTICLE_RNDLUM].SetToolID(ID_PROP_PARTRNDLUM);

	m_Prop[PROP_PARTICLE_TINTCOL].SetCategory(PCAT_COLOR);
	m_Prop[PROP_PARTICLE_TINTCOL].SetName("TintCol");
	m_Prop[PROP_PARTICLE_TINTCOL].SetColor((real)50/255, (real)0/255, (real)160/255);
	m_Prop[PROP_PARTICLE_TINTCOL].SetToolID(ID_PROP_PARTTINTCOL);

	m_Prop[PROP_PARTICLE_TINT].SetName("Tint");
	m_Prop[PROP_PARTICLE_TINT].SetToolID(ID_PROP_PARTTINT);

	m_Prop[PROP_PARTICLE_TINTMODE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_PARTICLE_TINTMODE].SetName("TintMode");
	m_Prop[PROP_PARTICLE_TINTMODE].SetEnum(FilterBlendModes);
	m_Prop[PROP_PARTICLE_TINTMODE].SetValue((real)0.25); // "ColorBlend" mode
	m_Prop[PROP_PARTICLE_TINTMODE].SetToolID(ID_PROP_PARTTINTMODE);

	m_Prop[PROP_PARTICLE_OPACITY].SetName("Opacity");
	m_Prop[PROP_PARTICLE_OPACITY].SetValue(1);
	m_Prop[PROP_PARTICLE_OPACITY].SetToolID(ID_PROP_PARTOPACITY);

	m_Prop[PROP_PARTICLE_RNDOPACITY].SetName("RndOpacity");
	m_Prop[PROP_PARTICLE_RNDOPACITY].SetToolID(ID_PROP_PARTRNDOPACITY);

	m_Prop[PROP_PARTICLE_BLEND].SetCategory(PCAT_ENUM);
	m_Prop[PROP_PARTICLE_BLEND].SetName("BlendMode");
	m_Prop[PROP_PARTICLE_BLEND].SetEnum(FilterBlendModes);
	m_Prop[PROP_PARTICLE_BLEND].SetToolID(ID_PROP_PARTBLEND);

	m_Prop[PROP_PARTICLE_DETAILS].SetName("Details");
	m_Prop[PROP_PARTICLE_DETAILS].SetMinVal((real)0.1);
	m_Prop[PROP_PARTICLE_DETAILS].SetMin(1);
	m_Prop[PROP_PARTICLE_DETAILS].SetMax(10);
	m_Prop[PROP_PARTICLE_DETAILS].SetValue((real)0.3);
	m_Prop[PROP_PARTICLE_DETAILS].SetToolID(ID_PROP_DETAILS);

	m_Prop[PROP_PARTICLE_ROUGHNESS].SetName("Roughness");
	m_Prop[PROP_PARTICLE_ROUGHNESS].SetValue((real)0.9);
	m_Prop[PROP_PARTICLE_ROUGHNESS].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_PARTICLE_POSX].SetName("ShiftX");
	m_Prop[PROP_PARTICLE_POSX].SetValue((real)0.5);
	m_Prop[PROP_PARTICLE_POSX].SetMin(-50);
	m_Prop[PROP_PARTICLE_POSX].SetMax(50);
	m_Prop[PROP_PARTICLE_POSX].SetToolID(ID_PROP_PARTPOSX);

	m_Prop[PROP_PARTICLE_POSY].SetName("ShiftY");
	m_Prop[PROP_PARTICLE_POSY].SetValue((real)0.5);
	m_Prop[PROP_PARTICLE_POSY].SetMin(-50);
	m_Prop[PROP_PARTICLE_POSY].SetMax(50);
	m_Prop[PROP_PARTICLE_POSY].SetToolID(ID_PROP_PARTPOSY);

	m_Prop[PROP_PARTICLE_SCALE].SetName("Scale");
	m_Prop[PROP_PARTICLE_SCALE].SetValue((real)0.6);
	m_Prop[PROP_PARTICLE_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_PARTICLE_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_PARTICLE_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_PARTICLE_SQUEEZE].SetMin(-50);
	m_Prop[PROP_PARTICLE_SQUEEZE].SetMax(50);
	m_Prop[PROP_PARTICLE_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);

	m_Prop[PROP_PARTICLE_SEED].SetName("Seed");
	m_Prop[PROP_PARTICLE_SEED].SetMax(1000);
	m_Prop[PROP_PARTICLE_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterParticle::RenderCol(CColor* col, real x, real y)
{
	// load properties
	CColor bg;
	m_Prop[PROP_PARTICLE_BACKGROUND].RenderCol(&bg, x, y);
	real details = CLAMP(m_Prop[PROP_PARTICLE_DETAILS].RenderVal(x, y));
	real roughness = CLAMP(m_Prop[PROP_PARTICLE_ROUGHNESS].RenderVal(x, y));
	real scale = pow(2,CLAMP(1-m_Prop[PROP_PARTICLE_SCALE].RenderVal(x, y))*8);
	real squeeze = CLAMP(m_Prop[PROP_PARTICLE_SQUEEZE].RenderVal(x, y));
	real squeezeX = (squeeze < (real)0.5) ? 1 : pow(2, (squeeze-(real)0.5)*10);
	real squeezeY = (squeeze >= (real)0.5) ? 1 : pow(2, ((real)0.5-squeeze)*10);
	int scaleX = (int)(scale*squeezeX+(real)0.5);
	int scaleY = (int)(scale*squeezeY+(real)0.5);
	int seed = (int)(m_Prop[PROP_PARTICLE_SEED].RenderVal(x, y)*1000 + (real)0.5) + 327;

	real xx = x - CLAMP(m_Prop[PROP_PARTICLE_POSX].RenderVal(x, y)) + (real)0.5;
	real yy = y - CLAMP(m_Prop[PROP_PARTICLE_POSY].RenderVal(x, y)) + (real)0.5;
	if (xx >= 1) xx -= (int)xx;
	if (xx < 0) xx += (int)(1 - xx);
	if (yy >= 1) yy -= (int)yy;
	if (yy < 0) yy += (int)(1 - yy);

	// generate value
	int xr[5];
	int yr[5];
	int bands = (int)(details*10+0.5);
	if (bands < 1) bands = 1;
	col->Set(bg);
	int i,j, xi, yi, s;
	real r, x0, y0, dx, dy, x3, y3, a, sa, ca, size3, sx, sy, sq, xx2, yy2;
	CColor c;
	real opacity0 = 1;
	m_Band = 0;
	for (; bands > 0; bands--)
	{
		// prepare coordinates
		real x2 = xx*scaleX;
		real y2 = yy*scaleY;
		xi = (int)x2;
		if (xi >= scaleX) xi -= scaleX;
		yi = (int)y2;
		if (yi >= scaleY) yi -= scaleY;
		x2 -= (real)0.5;
		y2 -= (real)0.5;

		// 25 nearest edges
		xr[2] = xi;
		xr[1] = xr[2] - 1; if (xr[1] < 0) xr[1] += scaleX;
		xr[0] = xr[1] - 1; if (xr[0] < 0) xr[0] += scaleX;
		xr[3] = xr[2] + 1; if (xr[3] >= scaleX) xr[3] -= scaleX;
		xr[4] = xr[3] + 1; if (xr[4] >= scaleX) xr[4] -= scaleX;

		yr[2] = yi;
		yr[1] = yr[2] - 1; if (yr[1] < 0) yr[1] += scaleY;
		yr[0] = yr[1] - 1; if (yr[0] < 0) yr[0] += scaleY;
		yr[3] = yr[2] + 1; if (yr[3] >= scaleY) yr[3] -= scaleY;
		yr[4] = yr[3] + 1; if (yr[4] >= scaleY) yr[4] -= scaleY;

		// find near particles
		for (i = 0; i < 5; i++)
		{
			for (j = 0; j < 5; j++)
			{
				// prepare coordinate of particle
				x0 = (real)(xr[2] + j - 2 + (real)0.5);
				y0 = (real)(yr[2] + i - 2 + (real)0.5);
				xx2 = x0/scaleX;
				yy2 = y0/scaleY;
				if (xx2 < 0) xx2 += 1;
				if (xx2 >= 1) xx2 -= 1;
				if (yy2 < 0) yy2 += 1;
				if (yy2 >= 1) yy2 -= 1;
				m_ParticleX = xx2;
				m_ParticleY = yy2;
				real rndposx = CLAMP(m_Prop[PROP_PARTICLE_RNDPOSX].RenderVal(xx2, yy2));
				real rndposy = CLAMP(m_Prop[PROP_PARTICLE_RNDPOSY].RenderVal(xx2, yy2));
				x0 += Noise2D(xr[j], yr[i], seed)*rndposx;
				y0 += Noise2D(xr[j]+167, yr[i]+321, seed+537)*rndposy;

				// new real coordinate of particle
				xx2 = x0/scaleX;
				yy2 = y0/scaleY;
				if (xx2 < 0) xx2 += 1;
				if (xx2 >= 1) xx2 -= 1;
				if (yy2 < 0) yy2 += 1;
				if (yy2 >= 1) yy2 -= 1;
				m_ParticleX = xx2;
				m_ParticleY = yy2;

				// prepare size at these coordinates
				real size = CLAMP(m_Prop[PROP_PARTICLE_SIZE].RenderVal(xx2, yy2));

				// check distance
				dx = x2 + (real)0.5 - x0;
				dy = y2 + (real)0.5 - y0;
				if (dx*dx + dy*dy < size*size*2/4)
				{
					// prepare chance at these coordinates
					real chance1 = CLAMP(m_Prop[PROP_PARTICLE_CHANCE1].RenderVal(xx2, yy2));
					real chance2 = CLAMP(m_Prop[PROP_PARTICLE_CHANCE2].RenderVal(xx2, yy2));
					real chance3 = CLAMP(m_Prop[PROP_PARTICLE_CHANCE3].RenderVal(xx2, yy2));
					real chance4 = CLAMP(m_Prop[PROP_PARTICLE_CHANCE4].RenderVal(xx2, yy2));
					real chance5 = CLAMP(m_Prop[PROP_PARTICLE_CHANCE5].RenderVal(xx2, yy2));

					real chance = chance1;
					if (chance2 > chance) chance = chance2;
					if (chance3 > chance) chance = chance3;
					if (chance4 > chance) chance = chance4;
					if (chance5 > chance) chance = chance5;
					real ch = chance1+chance2+chance3+chance4+chance5;
					if (ch > 0)
					{
						chance1 /= ch;
						chance2 /= ch;
						chance3 /= ch;
						chance4 /= ch;
						chance5 /= ch;
					}

					// check chance to create particle
					r = Noise2D(xr[j]+31, yr[i]+593, seed+287)*(real)0.4999 + (real)0.5;
					if ((r < chance) && (chance > 0))
					{
						// prepare transformations at these coordinates
						real angle = (CLAMP(m_Prop[PROP_PARTICLE_ANGLE].RenderVal(xx2, yy2)) - (real)0.5)*PI2;
						real squash = CLAMP(m_Prop[PROP_PARTICLE_SQUASH].RenderVal(xx2, yy2));
						real rndsize = CLAMP(m_Prop[PROP_PARTICLE_RNDSIZE].RenderVal(xx2, yy2));
						real rndangle = CLAMP(m_Prop[PROP_PARTICLE_RNDANGLE].RenderVal(xx2, yy2));
						real rndsquash = CLAMP(m_Prop[PROP_PARTICLE_RNDSQUASH].RenderVal(xx2, yy2));
						real squashx = 1;
						real squashy = 1;
						if (squash >= (real)0.5) squashx = 1 - (squash - (real)0.5)*2; else squashy = squash*2;

						// recalculate to particle coordinate
						a = angle + Noise2D(xr[j]+213, yr[i]+523, seed+113)*rndangle*PI;
						sa = sin(a);
						ca = cos(a);
						x3 = dx*ca + dy*sa;
						y3 = dy*ca - dx*sa;
						size3 = size*(1 - (Noise2D(xr[j]+11, yr[i]+103, seed+52)/2 + (real)0.5)*rndsize);
						sx = size3*squashx;
						sy = size3*squashy;
						sq = Noise2D(xr[j]+59, yr[i]+336, seed+201)*rndsquash;
						if (sq >= 0) sx *= (1 - sq); else sy *= (1 + sq);
						if ((sx > 0) && (sy > 0))
						{
							// resize and check valid boundaries
							x3 /= sx;
							y3 /= sy;
							x3 += (real)0.5;
							y3 += (real)0.5;
							if ((x3 >= 0) && (x3 <= 1) && (y3 >= 0) && (y3 <= 1))
							{
								// render particle color
								r /= chance;
								r -= chance1;
								if (r <= 0) s = PROP_SOURCE;
								else
								{
									r -= chance2;
									if (r <= 0) s = PROP_SOURCE2;
									else
									{
										r -= chance3;
										if (r <= 0) s = PROP_SOURCE3;
										else
										{
											r -= chance4;
											if (r <= 0) s = PROP_SOURCE4;
											else s = PROP_SOURCE5;
										}
									}
								}
								m_Prop[s].RenderCol(&c, x3, y3);

								// tint
								real tint = CLAMP(m_Prop[PROP_PARTICLE_TINT].RenderVal(xx2, yy2));
								if (tint > 0)
								{
									CColor tintcol;
									m_Prop[PROP_PARTICLE_TINTCOL].RenderCol(&tintcol, xx2, yy2);
									int tintmode = (int)(m_Prop[PROP_PARTICLE_TINTMODE].RenderVal(xx2, yy2)*100+0.5);
									real a = c.a;
									Blend(&c, tintcol, tint, tintmode);
									c.a = a;
								}

								// random hue and saturation
								real hue = CLAMP(m_Prop[PROP_PARTICLE_RNDHUE].RenderVal(xx2, yy2));
								real sat = CLAMP(m_Prop[PROP_PARTICLE_RNDSAT].RenderVal(xx2, yy2));
								real lum = CLAMP(m_Prop[PROP_PARTICLE_RNDLUM].RenderVal(xx2, yy2));
								if ((hue > 0) || (sat > 0))
								{
									c.RGBToHSL();
									c.r += hue*Noise2D(xr[j]+555, yr[i]+12, seed+348)/2;
									if (c.r < 0) c.r += 1;
									if (c.r >= 1) c.r -= 1;
									c.g *= 1 + sat*Noise2D(xr[j]+984, yr[i]+503, seed+24);
									c.HSLToRGB();
								}
								if (lum > 0) c.Brightness((real)0.5 + lum*Noise2D(xr[j]+90, yr[i]+127, seed+86)/2);

								// blend
								real opacity = opacity0 * CLAMP(m_Prop[PROP_PARTICLE_OPACITY].RenderVal(xx2, yy2) + 
												m_Prop[PROP_PARTICLE_RNDOPACITY].RenderVal(xx2, yy2) *
												Noise2D(xr[j]+18, yr[i]+24, seed+790));
								if (opacity > 0)
								{
									int blend = (int)(m_Prop[PROP_PARTICLE_BLEND].RenderVal(xx2, yy2)*100+0.5);
									Blend(col, c, opacity, blend);
								}
							}
						}
					}
				}
			}
		}

		scaleX *= 2;
		scaleY *= 2;
		seed += 189;
		opacity0 *= roughness;

		m_Band++;
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterParticle::RenderVal(real x, real y)
{
	CColor col;
	CFilterParticle::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterParticleX::CFilterParticleX()
{
	m_Group = FGRP_PAT;
	m_Class = _T("ParticleX");
	m_HelpID = HELP_FPARTICLEX;

	m_Prop[PROP_SOURCE].SetCategory(PCAT_PARTICLE);
	m_Prop[PROP_SOURCE].SetName("Particle");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_PARTICLE);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterParticleX::RenderCol(CColor* col, real x, real y)
{
	CFilter* f = m_Prop[PROP_SOURCE].Filter();
	if ((f != NULL) && (f->Category() == FCAT_PARTICLE))
		col->SetGray(((CFilterParticle*)f)->ParticleX());
	else
		col->SetBlack();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterParticleX::RenderVal(real x, real y)
{
	CFilter* f = m_Prop[PROP_SOURCE].Filter();
	if ((f != NULL) && (f->Category() == FCAT_PARTICLE))
		return ((CFilterParticle*)f)->ParticleX();
	else
		return 0;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterParticleY::CFilterParticleY()
{
	m_Group = FGRP_PAT;
	m_Class = _T("ParticleY");
	m_HelpID = HELP_FPARTICLEY;

	m_Prop[PROP_SOURCE].SetCategory(PCAT_PARTICLE);
	m_Prop[PROP_SOURCE].SetName("Particle");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_PARTICLE);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterParticleY::RenderCol(CColor* col, real x, real y)
{
	CFilter* f = m_Prop[PROP_SOURCE].Filter();
	if ((f != NULL) && (f->Category() == FCAT_PARTICLE))
		col->SetGray(((CFilterParticle*)f)->ParticleY());
	else
		col->SetBlack();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterParticleY::RenderVal(real x, real y)
{
	CFilter* f = m_Prop[PROP_SOURCE].Filter();
	if ((f != NULL) && (f->Category() == FCAT_PARTICLE))
		return ((CFilterParticle*)f)->ParticleY();
	else
		return 0;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterParticleRnd::CFilterParticleRnd()
{
	m_Group = FGRP_PAT;
	m_Class = _T("ParticleRnd");
	m_HelpID = HELP_FPARTICLERND;
	m_PropNum = 4;

	m_Prop[PROP_SOURCE].SetCategory(PCAT_PARTICLE);
	m_Prop[PROP_SOURCE].SetName("Particle");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_PARTICLE);

	m_Prop[PROP_PARTRND_MIN].SetName("Min");
	m_Prop[PROP_PARTRND_MIN].SetToolID(ID_PROP_RNDMIN);

	m_Prop[PROP_PARTRND_MAX].SetName("Max");
	m_Prop[PROP_PARTRND_MAX].SetValue(1);
	m_Prop[PROP_PARTRND_MAX].SetToolID(ID_PROP_RNDMAX);

	m_Prop[PROP_PARTRND_SEED].SetName("Seed");
	m_Prop[PROP_PARTRND_SEED].SetMax(1000);
	m_Prop[PROP_PARTRND_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterParticleRnd::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CFilterParticleRnd::RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterParticleRnd::RenderVal(real x, real y)
{
	real min = m_Prop[PROP_PARTRND_MIN].RenderVal(x, y);
	real max = m_Prop[PROP_PARTRND_MAX].RenderVal(x, y);
	int seed = (int)(m_Prop[PROP_PARTRND_SEED].RenderVal(x, y)*1000 + (real)0.5);

	x = 0;
	y = 0;
	int band = 0;
	CFilter* f = m_Prop[PROP_SOURCE].Filter();
	if ((f != NULL) && (f->Category() == FCAT_PARTICLE))
	{
		x = ((CFilterParticle*)f)->ParticleX();
		y = ((CFilterParticle*)f)->ParticleY();
		band = ((CFilterParticle*)f)->Band();
	}

	return (Noise2D((int)(x*7896), (int)(y*13452), seed+3*band+342)/2 + (real)0.5)*(max - min) + min;
}
