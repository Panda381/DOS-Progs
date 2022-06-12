				   
///////////////////////////////////////////////////////////////////////////////
//
//                             Color Channels Mixer
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// mix color channels filter
class CFilterMixer : public CFilterSource
{
public:

	// constructor
	CFilterMixer();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMixer);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
