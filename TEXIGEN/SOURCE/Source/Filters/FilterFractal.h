				   
///////////////////////////////////////////////////////////////////////////////
//
//					                   Fractals
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_FRACTAL_DETAILS	0		// property - Details
#define PROP_FRACTAL_SCALE		1		// property - Scale
#define PROP_FRACTAL_SQUEEZE	2		// property - Squeeze
#define PROP_FRACTAL_ANGLE		3		// property - Squeeze
#define PROP_FRACTAL_SHIFTX		4		// property - X
#define PROP_FRACTAL_SHIFTY		5		// property - Y
#define PROP_FRACTAL_SMOOTH		6		// property - Smooth
#define PROP_FRACTAL_FORMULA	7		// property - Formula
#define PROP_FRACTAL_JULIA		8		// property - Julia
#define PROP_FRACTAL_KR			9		// property - KR
#define PROP_FRACTAL_KI			10		// property - KI

// Fractal
class CFilterFractal : public CFilter
{
public:

	// constructor
	CFilterFractal();

	// duplicate filter
	FILTER_DUPLICATE(CFilterFractal);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
