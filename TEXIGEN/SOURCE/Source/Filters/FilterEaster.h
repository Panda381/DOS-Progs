
///////////////////////////////////////////////////////////////////////////////
//
//                              Easter Egg Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// easter egg generator
class CFilterEaster : public CFilterSource
{
public:

	// constructor
	CFilterEaster();

	// duplicate filter
	FILTER_DUPLICATE(CFilterEaster);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
