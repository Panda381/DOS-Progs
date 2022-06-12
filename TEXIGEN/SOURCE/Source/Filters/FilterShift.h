				   
///////////////////////////////////////////////////////////////////////////////
//
//                             Shift Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_SHIFT_X	1		// property - ShiftX (0..1 = shift center to left or right edge, default 0.5 = no shift)
#define PROP_SHIFT_Y	2		// property - ShiftY (0..1 = shift center to bottom or top edge, default 0.5 = no shift)

// shift filter
class CFilterShift : public CFilterSource
{
public:

	// constructor
	CFilterShift();

	// duplicate filter
	FILTER_DUPLICATE(CFilterShift);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_LOOKUP_X	1		// property - LookupX
#define PROP_LOOKUP_Y	2		// property - LookupY

// lookup filter
class CFilterLookup : public CFilterSource
{
public:

	// constructor
	CFilterLookup();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLookup);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
