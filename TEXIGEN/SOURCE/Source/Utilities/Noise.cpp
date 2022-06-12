
///////////////////////////////////////////////////////////////////////////////
//
//                               Noise Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// 1D coordinate noise generator (output -1..+1)

real Noise1D(int x, int seed)
{
	int n = x + seed*1327;
	n = (n << 13) ^ n;
	return 1 - (real)(int)((n*(n*n*15731 + 789221) + 1376312589) & 0x7fffffff)/0x40000000;
}

///////////////////////////////////////////////////////////////////////////////
// 2D coordinate noise generator (output -1..+1)

real Noise2D(int x, int y, int seed)
{
	int n = x + y*321 + seed*1327;
	n = (n << 13) ^ n;
	return 1 - (real)(int)((n*(n*n*15731 + 789221) + 1376312589) & 0x7fffffff)/0x40000000;
}

///////////////////////////////////////////////////////////////////////////////
// 3D coordinate noise generator (output -1..+1)

real Noise3D(int x, int y, int z, int seed)
{
	int n = x + y*321 + z*51327 + seed*1327;
	n = (n << 13) ^ n;
	return 1 - (real)(int)((n*(n*n*15731 + 789221) + 1376312589) & 0x7fffffff)/0x40000000;
}

///////////////////////////////////////////////////////////////////////////////
// interpolated 1D noise (output -1..+1, scale = 1...)

real SmoothNoise1D(real x, int scale, int seed)
{
	// scale coordinates
	x *= scale;

	// remainder
	int x1 = (int)floor(x);
	x -= x1;

	// coordinates
	x1 = x1 % scale;
	if (x1 < 0) x1 += scale;
	int x0 = (x1 + scale - 1) % scale;
	int x2 = (x1 + 1) % scale;
	int x3 = (x2 + 1) % scale;

	// noise in points
	real k0 = Noise1D(x0, seed);
	real k1 = Noise1D(x1, seed);
	real k2 = Noise1D(x2, seed);
	real k3 = Noise1D(x3, seed);

	// cubic interpolate noise
	real p = (k3 - k2) - (k0 - k1);
	real q = (k0 - k1) - p;
	real r = k2 - k0;
	real s = k1;

	return (((p*x + q)*x + r)*x + s)*(real)0.92;
}

///////////////////////////////////////////////////////////////////////////////
// interpolated 2D noise (output -1..+1, scale = 1...)
/*
real SmoothNoise2D(real x, real y, int scale, int seed)
{
	// scale coordinates
	x *= scale;
	y *= scale;

	// remainder
	int x1 = (int)floor(x);
	x -= x1;
	int y1 = (int)floor(y);
	y -= y1;

	// coordinates
	x1 = x1 % scale;
	if (x1 < 0) x1 += scale;
	int x2 = (x1 + 1) % scale;
	y1 = y1 % scale;
	if (y1 < 0) y1 += scale;
	int y2 = (y1 + 1) % scale;

	// noise in points
	real k11 = Noise2D(x1, y1, seed);
	real k21 = Noise2D(x2, y1, seed);
	real k12 = Noise2D(x1, y2, seed);
	real k22 = Noise2D(x2, y2, seed);

	// interpolate noise
	real k1 = k11*(1-x) + k21*x;
	real k2 = k12*(1-x) + k22*x;
	return k1*(1-y) + k2*y;
}
*/
