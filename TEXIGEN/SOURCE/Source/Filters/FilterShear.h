				   
///////////////////////////////////////////////////////////////////////////////
//
//                               Shear Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// shear X filter (horizontal direction)
class CFilterShearX : public CFilterSource
{
public:

	// constructor
	CFilterShearX();

	// duplicate filter
	FILTER_DUPLICATE(CFilterShearX);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// shear Y filter (vertical direction)
class CFilterShearY : public CFilterShearX
{
public:

	// constructor
	CFilterShearY();

	// duplicate filter
	FILTER_DUPLICATE(CFilterShearY);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
