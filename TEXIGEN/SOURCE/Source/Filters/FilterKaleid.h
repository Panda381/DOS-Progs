				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Kaleidoscope
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Kaleidoscope
class CFilterKaleidoscope : public CFilterSource
{
public:

	// constructor
	CFilterKaleidoscope();

	// duplicate filter
	FILTER_DUPLICATE(CFilterKaleidoscope);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
