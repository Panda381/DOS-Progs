
///////////////////////////////////////////////////////////////////////////////
//
//                          Cellular Worley Noise Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_CELLULAR_DETAILS	0		// property - Details (0..1 = 0 smooth (1 noise octave) ... 1 detailed (11 noise octaves), default 0.5)
#define PROP_CELLULAR_ROUGHNESS 1		// property - Roughness (0..1 = 0 smooth ... 1 roughness (noticable higher octaves), default 0)
#define PROP_CELLULAR_CONTRAST	2		// property - Contrast (0..1 = contrast 0=low..1=high, default 0.5)
#define PROP_CELLULAR_BRIGHT	3		// property - Brightness (0..1 = brightness 0=low..1=high, default 0.5)
#define PROP_CELLULAR_SCALE		4		// property - Scale (0..1 = scale, 0=256x small..1=normal, default 0.6)
#define PROP_CELLULAR_SQUEEZE	5		// property - Squeeze (0..1 = scale in X direction, 0=normal..1=128x small, default 0)
#define PROP_CELLULAR_ANGLE		6		// property - Angle (0..1 = angle -180..+180, default 0.5 = no rotation)
#define PROP_CELLULAR_SHIFTX	7		// property - ShiftX (0..1 = shift to left or right edge, default 0.5 = no shift)
#define PROP_CELLULAR_SHIFTY	8		// property - ShiftY (0..1 = shift to bottom or top edge, default 0.5 = no shift)
#define PROP_CELLULAR_CHAOS		9		// property - Chaos (jittering 0..1, 0=regular..1=random, default 0.5)
#define PROP_CELLULAR_SOLID		10		// property - Solid (0=shadow, 1=solid, default 0)
#define PROP_CELLULAR_FORM		11		// property - Formula (formula mode 0..1 in 0.1 steps, default 0)
// Formula: 0=F2-F1, 0.1=2F3-F2-F1, 0.2=F3-F2, 0.3=F1, 0.4=Avg(F1,F2), 0.5=Avg(F1,F2,F3), 0.6=F1/F2, 0.7=F1*F2, ...
#define PROP_CELLULAR_DIST		12		// property - Distance (distance mode 0..1 in 0.1 steps, default 0)
// Distance: 0=Square, 0.1=Manhattan, 0.2=Chebyshev, 0.3=Minkowski
#define PROP_CELLULAR_PROFILE	13		// property - Profile (profile curve map, default linear)
#define PROP_CELLULAR_SEED		14		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// form=0 (F2-F1), dist=0 (sqr): stones
// form=0 (F2-F1), dist=0.1 (man) or 0.2 (cheb): techno
// form=0.3 (F1), dist=0 (sqr): balls
// form=0.3 (F1), dist=0 (sqr), filter=FilterImp: cells
// form=0.3 (F1), dist=0.1 (man): pyramids
// form=0.4 or 0.3 (avg(F1,F2), dist=0 (sqr), details=0.2, rough=0.2, profile=impulse: electric cells

// cellular Worley noise generator
class CFilterCellular : public CFilter
{
public:

	// constructor
	CFilterCellular();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCellular);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// mosaic generator
class CFilterMosaic : public CFilter
{
public:

	// constructor
	CFilterMosaic();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMosaic);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

//extern CText FilterMosaicFillMode[];
