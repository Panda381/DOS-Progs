		   				   
///////////////////////////////////////////////////////////////////////////////
//
//                         Spectrum Gradient Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// spectrum gradient generator
class CFilterSpectrum : public CFilter
{
public:

	// constructor
	CFilterSpectrum();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSpectrum);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// thermographic gradient generator
class CFilterThermo : public CFilter
{
public:

	// constructor
	CFilterThermo();

	// duplicate filter
	FILTER_DUPLICATE(CFilterThermo);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
