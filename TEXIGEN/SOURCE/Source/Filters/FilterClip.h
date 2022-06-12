
///////////////////////////////////////////////////////////////////////////////
//
//                               Paper Clip
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_CLIP_COLIN		0		// property - ColorIn
#define PROP_CLIP_COLOUT	1		// property - ColorOut
#define PROP_CLIP_BACK		2		// property - Background
#define PROP_CLIP_THICK		3		// property - Thickness
#define PROP_CLIP_SIZE		4		// property - Size
#define PROP_CLIP_WIDTH		5		// property - Width

// paper clip
class CFilterClip : public CFilterSource3
{
public:

	// constructor
	CFilterClip();

	// duplicate filter
	FILTER_DUPLICATE(CFilterClip);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
