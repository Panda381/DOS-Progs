
///////////////////////////////////////////////////////////////////////////////
//
//                                      Cut
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_CUT_X1		2		// property - X1
#define PROP_CUT_X2		3		// property - X2
#define PROP_CUT_Y1		4		// property - Y1
#define PROP_CUT_Y2		5		// property - Y2

// cut
class CFilterCut : public CFilterSource2
{
public:

	// constructor
	CFilterCut();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCut);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
