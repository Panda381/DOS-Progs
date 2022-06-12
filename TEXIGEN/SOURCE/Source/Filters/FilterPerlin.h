
///////////////////////////////////////////////////////////////////////////////
//
//                              Perlin Noise Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// interpolated 3D noise (output -1..+1, scale = 2...)
real NoiseSample(real x, real y, real z, int scaleX, int scaleY, int scaleZ, int seed);

#define PROP_NOISE_DETAILS	0		// property - Details (0..1 = 0 smooth (1 noise octave) ... 1 detailed (11 noise octaves), default 0.5)
#define PROP_NOISE_ROUGHNESS 1		// property - Roughness (0..1 = 0 smooth ... 1 roughness (noticable higher octaves), default 0.5)
#define PROP_NOISE_CONTRAST	2		// property - Contrast (0..1 = contrast 0=low..1=high, default 0.5)
#define PROP_NOISE_BRIGHT	3		// property - Brightness (0..1 = brightness 0=low..1=high, default 0.5)
#define PROP_NOISE_SCALE	4		// property - Scale (0..1 = scale, 0=256x small..1=normal, default 1)
#define PROP_NOISE_SQUEEZE	5		// property - Squeeze (0..1 = scale in X direction, 0=normal..1=128x small, default 0)
#define PROP_NOISE_ANGLE	6		// property - Angle (0..1 = angle -180..+180, default 0.5 = angle 0)
#define PROP_NOISE_SHIFTX	7		// property - ShiftX (0..1 = shift to left or right edge, default 0.5)
#define PROP_NOISE_SHIFTY	8		// property - ShiftY (0..1 = shift to bottom or top edge, default 0.5)
#define PROP_NOISE_SHIFTZ	9		// property - ShiftZ (0..1 = shift to height or low level, default 0)
#define PROP_NOISE_HEIGHT	10		// property - Height (0..1 = height in Z, 0=minimal, 1=max. variability 256x, default 0)
#define PROP_NOISE_PROFILE	11		// property - Profile (profile curve map, default linear)
#define PROP_NOISE_SEED		12		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// perlin noise generator
class CFilterPerlin : public CFilter
{
public:

	// constructor
	CFilterPerlin();

	// duplicate filter
	FILTER_DUPLICATE(CFilterPerlin);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
