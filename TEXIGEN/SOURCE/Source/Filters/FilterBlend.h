	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Blending Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern CText FilterBlendModes[];

#define PROP_BLEND_OPACITY	2	// property - Opacity (0..1; 0=no effect..1=full effect; default 1)
#define PROP_BLEND_MODE		3	// property - Mode (0..1; blend mode in hundredths, 0.00=Normal, 0.01=Darken,...)
#define PROP_BLEND_ALPHAMOD	4	// property - AlphaMod (0 or 1=modulate result alpha with destination alpha)

// blending filter
class CFilterBlend : public CFilterSource2
{
public:

	// constructor
	CFilterBlend();

	// duplicate filter
	FILTER_DUPLICATE(CFilterBlend);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

///////////////////////////////////////////////////////////////////////////////
// blending colors

void Blend(CColor* col, const CColor& src, real opacity, int mode, bool alphamod=false);
