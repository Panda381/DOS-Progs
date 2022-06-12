
///////////////////////////////////////////////////////////////////////////////
//
//                                      Card
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// card
class CFilterCard : public CFilter
{
protected:

	// card color
	int		m_CardCol;

	// render card symbol (xc, yc=coordinate of center)
	void CardSym(CColor* col, real x, real y, real xc, real yc, BOOL rot, BOOL mini = FALSE);

	// render card digit (xc, yc=coordinate of center)
	void CardDig(CColor* col, real x, real y, int dig, real xc, real yc, BOOL rot, BOOL mini = TRUE);

public:

	// constructor
	CFilterCard();

	// duplicate filter
	FILTER_DUPLICATE(CFilterCard);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

////////////////////////////////////////////////////////////////////
// BI_RLE8 data decompression
// missing code 2 - skip delta X 0..255, delta Y 0..255

//void DekompRLE8(BYTE* dst, int dstN, BYTE* src, int srcN, int wb);

///////////////////////////////////////////////////////////////////////////////
// load card pictures

void LoadCardPic();
