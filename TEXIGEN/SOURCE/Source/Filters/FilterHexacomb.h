
///////////////////////////////////////////////////////////////////////////////
//
//                            Hexacomb Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// hexacomb generator
class CFilterHexacomb : public CFilterSource2
{
public:

	// constructor
	CFilterHexacomb();

	// duplicate filter
	FILTER_DUPLICATE(CFilterHexacomb);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
