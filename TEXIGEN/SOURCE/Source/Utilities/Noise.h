
///////////////////////////////////////////////////////////////////////////////
//
//                               Noise Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// 1D coordinate noise generator (output -1..+1)
real Noise1D(int x, int seed);

// 2D coordinate noise generator (output -1..+1)
real Noise2D(int x, int y, int seed);

// 3D coordinate noise generator (output -1..+1)
real Noise3D(int x, int y, int z, int seed);

// interpolated 1D noise (output -1..+1, scale = 1...)
real SmoothNoise1D(real x, int scale, int seed);

// interpolated 2D noise (output -1..+1, scale = 1...)
//real SmoothNoise2D(real x, real y, int scale, int seed);
