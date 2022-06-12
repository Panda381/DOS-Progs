
///////////////////////////////////////////////////////////////////////////////
//
//                              Perlin Noise Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// Pen Kerlin's permutation table
//    Get key for (x,y,z) vector: n = tab[tab[tab[x] + y] + z]
static const int PermTab[256] = {
	151, 160, 137,  91,  90,  15, 131,  13, 201,  95,  96,  53, 194, 233,   7, 225,
	140,  36, 103,  30,  69, 142,   8,  99,  37, 240,  21,  10,  23, 190,   6, 148,
	247, 120, 234,  75,   0,  26, 197,  62,  94, 252, 219, 203, 117,  35,  11,  32,
	 57, 177,  33,  88, 237, 149,  56,  87, 174,  20, 125, 136, 171, 168,  68, 175,
	 74, 165,  71, 134, 139,  48,  27, 166,  77, 146, 158, 231,  83, 111, 229, 122,
	 60, 211, 133, 230, 220, 105,  92,  41,  55,  46, 245,  40, 244, 102, 143,  54,
	 65,  25,  63, 161,   1, 216,  80,  73, 209,  76, 132, 187, 208,  89,  18, 169,
	200, 196, 135, 130, 116, 188, 159,  86, 164, 100, 109, 198, 173, 186,   3,  64,
	 52, 217, 226, 250, 124, 123,   5, 202,  38, 147, 118, 126, 255,  82,  85, 212,
	207, 206,  59, 227,  47,  16,  58,  17, 182, 189,  28,  42, 223, 183, 170, 213,
	119, 248, 152,   2,  44, 154, 163,  70, 221, 153, 101, 155, 167,  43, 172,   9,
	129,  22,  39, 253,  19,  98, 108, 110,  79, 113, 224, 232, 178, 185, 112, 104,
	218, 246,  97, 228, 251,  34, 242, 193, 238, 210, 144,  12, 191, 179, 162, 241,
	 81,  51, 145, 235, 249,  14, 239, 107,  49, 192, 214,  31, 181, 199, 106, 157,
	184,  84, 204, 176, 115, 121,  50,  45, 127,   4, 150, 254, 138, 236, 205,  93,
	222, 114,  67,  29,  24,  72, 243, 141, 128, 195,  78,  66, 215,  61, 156, 180
};

// load value from permutation table
#define Perm(x) PermTab[((x) + seed) & 0xff]

// fade curve (with zero derivation in edges)
inline static real Fade(real t)
{
	//return (1 - cos(t*PI))/2;
	return t*t*t*(t*(t*6-15)+10);
}

// linear interpolation from 'a' to 'b' with weight 't'
inline static real Lerp(real t, real a, real b)
{
	return a + t*(b - a);
}

// get gradient using hash value
inline static real Grad(int hash, real x, real y, real z)
{
	// prepare hash value (0..15)
	int h = hash & 0xf;

	// u: 0..7 x, 8..15 y
	real u = (h < 8) ? x : y;
	if ((h & 1) != 0) u = -u;

	// v: 12 14 x, 0..3 y, 
	real v = (h < 4) ? y : (((h == 12) || (h == 14)) ? x : z);
	if ((h & 2) != 0) v = -v;

	// sum vectors
	//	 0:  x  y
	//	 1: -x  y
	//	 2:  x -y
	//	 3: -x -y
	//	 4:  x  z
	//	 5: -x  z
	//	 6:  x -z
	//	 7: -x -z
	//	 8:  y  z
	//	 9: -y  z
	//	10:  y -z
	//	11: -y -z
	//	12:  y  x
	//	13: -y  z
	//	14:  y -x
	//	15: -y -z
	return u + v;
}

// interpolated 3D noise (output -1..+1)
real NoiseSample(real x, real y, real z, real scaleX, real scaleY, real scaleZ, real cosa, real sina, int seed)
{
	// randomize seed
	seed *= 51;

	// scale coordinates
	if (scaleX > 2) scaleX = floor(scaleX);
	if (scaleY > 2) scaleY = floor(scaleY);
	if (scaleZ > 2) scaleZ = floor(scaleZ);
	x *= scaleX;
	y *= scaleY;
	z *= scaleZ;

	// split to integer and fractional (0..1) part
	int x1 = (int)x;
	x -= x1;
	int y1 = (int)y;
	y -= y1;
	int z1 = (int)z;
	z -= z1;

	// end coordinate and weight (2 end points smoothly passes to 1 end point)
	int x2 = x1 + 1;
	real wx = 1;
	if (x2 + 1 > scaleX)
	{
		if (x2 > scaleX)
		{
			x1 -= 1;
			x++;
			if (x1 < 0)
			{
				x1 = 0;
				x--;
			}
		}
		if (scaleX > (real)0.00001) x /= scaleX - x1;
		x2 = 0;
		if (scaleX < 1) wx = scaleX;
	}

	int y2 = y1 + 1;
	real wy = 1;
	if (y2 + 1 > scaleY)
	{
		if (y2 > scaleY)
		{
			y1 -= 1;
			y++;
			if (y1 < 0)
			{
				y1 = 0;
				y--;
			}
		}
		if (scaleY > (real)0.00001) y /= scaleY - y1;
		y2 = 0;
		if (scaleY < 1) wy = scaleY;
	}

	int z2 = z1 + 1;
	real wz = 1;
	if (z2 + 1 > scaleZ)
	{
		if (z2 > scaleZ)
		{
			z1 -= 1;
			z++;
			if (z1 < 0)
			{
				z1 = 0;
				z--;
			}
		}
		if (scaleZ > (real)0.00001) z /= scaleZ - z1;
		z2 = 0;
		if (scaleZ < 1) wz = scaleZ;
	}

	// fade curves (to avoid edges)
	real u = Fade(x);
	real v = Fade(y);
	real w = Fade(z);

	// base of hash coordinates of corners (without z coordinate)
	int A = Perm(x1);
	int AA = Perm(A + y1);
	int AB = Perm(A + y2);
	int B = Perm(x2);
	int BA = Perm(B + y1);
	int BB = Perm(B + y2);

	// get gradients of all 8 corners
#define W3D (real)0.7
#define W3D2 (real)0.3
	real gAAA = Grad(Perm(AA + z1),     x*wx,     y*wy,     z*wz)*W3D + Noise3D(x1, y1, z1, seed)*W3D2;
	real gBAA = Grad(Perm(BA + z1), (x-1)*wx,     y*wy,     z*wz)*W3D + Noise3D(x2, y1, z1, seed)*W3D2;
	real gABA = Grad(Perm(AB + z1),     x*wx, (y-1)*wy,     z*wz)*W3D + Noise3D(x1, y2, z1, seed)*W3D2;
	real gBBA = Grad(Perm(BB + z1), (x-1)*wx, (y-1)*wy,     z*wz)*W3D + Noise3D(x2, y2, z1, seed)*W3D2;
	real gAAB = Grad(Perm(AA + z2),     x*wx,     y*wy, (z-1)*wz)*W3D + Noise3D(x1, y1, z2, seed)*W3D2;
	real gBAB = Grad(Perm(BA + z2), (x-1)*wx,     y*wy, (z-1)*wz)*W3D + Noise3D(x2, y1, z2, seed)*W3D2;
	real gABB = Grad(Perm(AB + z2),     x*wx, (y-1)*wy, (z-1)*wz)*W3D + Noise3D(x1, y2, z2, seed)*W3D2;
	real gBBB = Grad(Perm(BB + z2), (x-1)*wx, (y-1)*wy, (z-1)*wz)*W3D + Noise3D(x2, y2, z2, seed)*W3D2;

	// interpolate gradients from all 8 corners
	return Lerp(w,
		Lerp(v, Lerp(u, gAAA, gBAA), Lerp(u, gABA, gBBA)),
		Lerp(v, Lerp(u, gAAB, gBAB), Lerp(u, gABB, gBBB)));
}

// Recommended profiles:
//  CFilterLinear or none = linear (default Perlin noise)
//  CFilterGain = camouflage generator
//  CFilterImp = electricity
//  CFilterImp with bal=0.6, sl1=0.1, sl2=0.3, smooth=1 = ghost
//	CFilterWave = organic

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterPerlin::CFilterPerlin()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Perlin");
	m_HelpID = HELP_FPERLIN;
	m_PropNum = 13;

	m_Prop[PROP_NOISE_DETAILS].SetName("Details");
	m_Prop[PROP_NOISE_DETAILS].SetMinVal((real)0.1);
	m_Prop[PROP_NOISE_DETAILS].SetMin(1);
	m_Prop[PROP_NOISE_DETAILS].SetMax(10);
	m_Prop[PROP_NOISE_DETAILS].SetValue((real)0.5);
	m_Prop[PROP_NOISE_DETAILS].SetToolID(ID_PROP_DETAILS);

	m_Prop[PROP_NOISE_ROUGHNESS].SetName("Roughness");
	m_Prop[PROP_NOISE_ROUGHNESS].SetValue((real)0.5);
	m_Prop[PROP_NOISE_ROUGHNESS].SetToolID(ID_PROP_ROUGHNESS);

	m_Prop[PROP_NOISE_CONTRAST].SetName("Contrast");
	m_Prop[PROP_NOISE_CONTRAST].SetValue((real)0.5);
	m_Prop[PROP_NOISE_CONTRAST].SetToolID(ID_PROP_CONTRAST);

	m_Prop[PROP_NOISE_BRIGHT].SetName("Brightness");
	m_Prop[PROP_NOISE_BRIGHT].SetValue((real)0.5);
	m_Prop[PROP_NOISE_BRIGHT].SetToolID(ID_PROP_BRIGHT);

	m_Prop[PROP_NOISE_SCALE].SetName("Scale");
	m_Prop[PROP_NOISE_SCALE].SetValue((real)0.75);
	m_Prop[PROP_NOISE_SCALE].SetToolID(ID_PROP_SCALE);

	m_Prop[PROP_NOISE_SQUEEZE].SetName("Squeeze");
	m_Prop[PROP_NOISE_SQUEEZE].SetValue((real)0.5);
	m_Prop[PROP_NOISE_SQUEEZE].SetMin(-50);
	m_Prop[PROP_NOISE_SQUEEZE].SetMax(50);
	m_Prop[PROP_NOISE_SQUEEZE].SetToolID(ID_PROP_SQUEEZE);

	m_Prop[PROP_NOISE_ANGLE].SetName("Angle");
	m_Prop[PROP_NOISE_ANGLE].SetValue((real)0.5);
	m_Prop[PROP_NOISE_ANGLE].SetMin(-180);
	m_Prop[PROP_NOISE_ANGLE].SetMax(180);
	m_Prop[PROP_NOISE_ANGLE].SetToolID(ID_PROP_ANGLE);

	m_Prop[PROP_NOISE_SHIFTX].SetName("ShiftX");
	m_Prop[PROP_NOISE_SHIFTX].SetValue((real)0.5);
	m_Prop[PROP_NOISE_SHIFTX].SetMin(-50);
	m_Prop[PROP_NOISE_SHIFTX].SetMax(50);
	m_Prop[PROP_NOISE_SHIFTX].SetToolID(ID_PROP_SHIFTX);

	m_Prop[PROP_NOISE_SHIFTY].SetName("ShiftY");
	m_Prop[PROP_NOISE_SHIFTY].SetValue((real)0.5);
	m_Prop[PROP_NOISE_SHIFTY].SetMin(-50);
	m_Prop[PROP_NOISE_SHIFTY].SetMax(50);
	m_Prop[PROP_NOISE_SHIFTY].SetToolID(ID_PROP_SHIFTY);

	m_Prop[PROP_NOISE_SHIFTZ].SetName("ShiftZ");
	m_Prop[PROP_NOISE_SHIFTZ].SetToolID(ID_PROP_SHIFTZ);

	m_Prop[PROP_NOISE_HEIGHT].SetName("Height");
	m_Prop[PROP_NOISE_HEIGHT].SetToolID(ID_PROP_NOISEHEIGHT);

	m_Prop[PROP_NOISE_PROFILE].SetName("Profile");
	m_Prop[PROP_NOISE_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_NOISE_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_NOISE_PROFILE].SetToolID(ID_PROP_NOISEPROFILE);

	m_Prop[PROP_NOISE_SEED].SetName("Seed");
	m_Prop[PROP_NOISE_SEED].SetMax(1000);
	m_Prop[PROP_NOISE_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterPerlin::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CFilterPerlin::RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterPerlin::RenderVal(real x, real y)
{
	// load properties
	int seed = (int)(m_Prop[PROP_NOISE_SEED].RenderVal(x, y)*1000 + (real)0.5 + 22);
	real details = CLAMP(m_Prop[PROP_NOISE_DETAILS].RenderVal(x, y));
	real roughness = m_Prop[PROP_NOISE_ROUGHNESS].RenderVal(x, y);
	real contrast = pow(2,m_Prop[PROP_NOISE_CONTRAST].RenderVal(x, y)*10)/25;
	real bright = (m_Prop[PROP_NOISE_BRIGHT].RenderVal(x, y) - (real)0.5)*2;
	real scale = pow(2,CLAMP(1-m_Prop[PROP_NOISE_SCALE].RenderVal(x, y))*10)/4;
	real squeeze = CLAMP(m_Prop[PROP_NOISE_SQUEEZE].RenderVal(x, y));
	real squeezeX = (squeeze < (real)0.5) ? 1 : pow(2, (squeeze-(real)0.5)*18);
	real squeezeY = (squeeze >= (real)0.5) ? 1 : pow(2, ((real)0.5-squeeze)*18);
	real scaleX = scale*squeezeX;
	real scaleY = scale*squeezeY;
	real scaleZ = pow(2,CLAMP(m_Prop[PROP_NOISE_HEIGHT].RenderVal(x, y))*12)/16;
	real x0 = x - m_Prop[PROP_NOISE_SHIFTX].RenderVal(x, y);
	real y0 = y - m_Prop[PROP_NOISE_SHIFTY].RenderVal(x, y);
	real z = m_Prop[PROP_NOISE_SHIFTZ].RenderVal(x, y);
	real angle = -(m_Prop[PROP_NOISE_ANGLE].RenderVal(x, y) - (real)0.5) * PI * 2;
	real cosa = cos(angle);
	real sina = sin(angle);
	x = x0*cosa + y0*sina;
	y = y0*cosa - x0*sina;
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	if (y >= 1) y -= (int)y;
	if (y < 0) y += (int)(1 - y);
	if (z >= 1) z -= (int)z;
	if (z < 0) z += (int)(1 - z);

	// contrast correction from roughness
	contrast /= (real)(roughness*roughness*1.5+0.5);

	// generate value
	real val = 0;
	int bands = (int)(details*10+0.5);
	if (bands < 1) bands = 1;
	for (; bands > 0; bands--)
	{
		real val1 = NoiseSample(x, y, z, scaleX, scaleY, scaleZ, cosa, sina, seed);
		val1 = (m_Prop[PROP_NOISE_PROFILE].RenderVal(val1/2 + (real)0.5, y)-(real)0.5)*2;
		val += val1 * contrast;

		scaleX *= 2;
		scaleY *= 2;
		scaleZ += 1;

		contrast *= roughness;
		roughness *= (real)1.1;
		seed += 5;
	}
	val += bright;

	return CLAMP(val/2 + (real)0.5);
}
