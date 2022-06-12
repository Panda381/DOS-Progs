					 
///////////////////////////////////////////////////////////////////////////////
//
//                               Clamp Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// clamp filter - limit values to range 0..1
class CFilterClamp : public CFilterSource
{
public:

	// constructor
	CFilterClamp();

	// duplicate filter
	FILTER_DUPLICATE(CFilterClamp);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
