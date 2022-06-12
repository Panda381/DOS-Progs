
///////////////////////////////////////////////////////////////////////////////
//
//                                      Card
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define CARDDIGN	13				// number of card digits
#define CARDDIGW	1000			// width of one digit
#define CARDDIGH	1500			// height of one digit
#define CARDDIGWT	(CARDDIGN*CARDDIGW) // total width of card picture (6500)

u8		CardDigMap[CARDDIGWT*CARDDIGH]; // card digits gray map

///////////////////////////////////////////////////////////////////////////////
// load card pictures

void LoadCardPic()
{
	memset(CardDigMap, 0, CARDDIGWT*CARDDIGH);

	// open resource
	HRSRC res = ::FindResource(Instance, "CARDDIG", "REFLECT");
	if (res != NULL)
	{
		HGLOBAL glob = ::LoadResource(Instance, res);
		if (glob != NULL)
		{
			u8* a = (u8*)::LockResource(glob);
			if (a != NULL)
			{
				// check bitmap header
				bmpBITMAPFILEHEADER* bmp = (bmpBITMAPFILEHEADER*)a;
#define CARDDATAOFF (sizeof(bmpBITMAPFILEHEADER) + sizeof(bmpBITMAPINFOHEADER) + 4*256*sizeof(BYTE)) // 1078 bytes
				if ((bmp->bfType == 0x4d42) && (bmp->bfSize > 100000) && (bmp->bfOffBits == CARDDATAOFF))
				{
					bmpBITMAPINFOHEADER* b = (bmpBITMAPINFOHEADER*)(a + sizeof(bmpBITMAPFILEHEADER));
					if ((b->biSize == sizeof(bmpBITMAPINFOHEADER)) &&
						(b->biWidth == CARDDIGWT) && (b->biHeight == CARDDIGH) &&
						(b->biBitCount == 8) && (b->biCompression == bmpBI_RLE8))
					{
						// bitmap decompression
						DekompRLE8(CardDigMap, CARDDIGWT*CARDDIGH, a + CARDDATAOFF, bmp->bfSize - CARDDATAOFF, CARDDIGWT);

						// !!!! error in decompressor code 2 (skipping delta X Y), clear short white line behind "A".
						memset(CardDigMap, 0, CARDDIGW);

						return;
					}
				}
			}
		}
	}

	IntError(_T("LoadCardPic: Invalid picture"));
}

#define PROP_CARD_CARD		0		// property - Card
#define PROP_CARD_OUTLINE	1		// property - Outline
#define PROP_CARD_OUTCOL	2		// property - OutlineCol

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterCard::CFilterCard()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Card");
	m_HelpID = HELP_FCARD;
	m_PropNum = 3;

	m_Prop[PROP_CARD_CARD].SetName("Card");
	m_Prop[PROP_CARD_CARD].SetMin(0);
	m_Prop[PROP_CARD_CARD].SetMax(40);
	m_Prop[PROP_CARD_CARD].SetMinVal((real)0.00);
	m_Prop[PROP_CARD_CARD].SetMaxVal((real)0.40);
	m_Prop[PROP_CARD_CARD].SetToolID(ID_PROP_CARD);

	m_Prop[PROP_CARD_OUTLINE].SetValue((real)0.05);
	m_Prop[PROP_CARD_OUTLINE].SetName("Outline");
	m_Prop[PROP_CARD_OUTLINE].SetToolID(ID_PROP_CARDOUTLINE);

	m_Prop[PROP_CARD_OUTCOL].SetCategory(PCAT_COLOR);
	m_Prop[PROP_CARD_OUTCOL].SetValue((real)160/255);
	m_Prop[PROP_CARD_OUTCOL].SetName("OutlineCol");
	m_Prop[PROP_CARD_OUTCOL].SetToolID(ID_PROP_CARDOUTCOL);
}

///////////////////////////////////////////////////////////////////////////////
// render card symbol (xc, yc=coordinate of center)

#define CARDMM	87				// card base scale - height in [mm]

#define CARDH (real)1			// height
#define CARDW ((real)57/CARDMM)	// width
#define CARDC ((real)6/CARDMM)	// corners
#define CARDS ((real)13/CARDMM)	// symbol base size

void CFilterCard::CardSym(CColor* col, real x, real y, real xc, real yc, BOOL rot, BOOL mini /*= FALSE*/)
{
	real size = mini ? (CARDS*(real)0.5) : CARDS;
	xc -= size/2;
	yc -= size/2;

	// check hit
	if ((x < xc) || (x >= xc + size) || (y < yc) || (y >= yc + size)) return;

	// relative coordinates
	x = (x - xc)/size - (real)0.5;
	y = (y - yc)/size - (real)0.5;
	if (rot)
	{
		x = -x;
		y = -y;
	}
	x *= (real)1.1;

	// render symbol
	switch (m_CardCol)
	{
	// spade
	case 0:
		{
			// leaf
			real d = sqrt(sqr(x) + sqr(y));
			real a = atan2(y, x);
			if (a < 0) a += PI2;
			a = a / PI2 * SPADESHAPEN;
			int i = (int)a;
			if (i > SPADESHAPEN-1) i = SPADESHAPEN-1;
			a -= i;
			real r = SpadeShape[i]*(1-a) + SpadeShape[i+1]*a;
			if (d <= r) col->SetBlack();

			// stalk
			if ((y < 0) && (x >= -SPADESTALK) && (x <= SPADESTALK))
			{
				real k = (y + (real)0.51)*2;
				k = (1 - sqrt(k))*SPADESTALK;
				if ((x < k) && (x > -k)) col->SetBlack();
			}
		}
		break;

	// heart
	case 1:
		{
			real d = sqrt(sqr(x) + sqr(y));
			real a = atan2(y, x);
			if (a < 0) a += PI2;
			a = a / PI2 * HEARTSHAPEN;
			int i = (int)a;
			if (i > HEARTSHAPEN-1) i = HEARTSHAPEN-1;
			a -= i;
			real r = HeartShape[i]*(1-a) + HeartShape[i+1]*a;
			if (d <= r) col->Set(1, 0, 0, 1);
		}
		break;

	// diamond
	case 2:
		{
			x *= (real)1.1;
			real d = sqrt(sqr(DIAMONDXY - abs(x)) + sqr(DIAMONDXY - abs(y)));
			if (d >= DIAMONDR) col->Set(1, 0, 0, 1);
		}
		break;

	// club
	default:
		{
			// leafs
			real y4 = (real)0.5 - CLUBR1;
			real d = sqrt(sqr(x) + sqr(y - y4));
			if (d <= CLUBR1) col->SetBlack();

			real x4 = (real)0.5 - CLUBR1;
			y4 = -(real)0.13;
			d = sqrt(sqr(x - x4) + sqr(y - y4));
			if (d <= CLUBR1) col->SetBlack();

			x4 = (real)-0.5 + CLUBR1;
			d = sqrt(sqr(x - x4) + sqr(y - y4));
			if (d <= CLUBR1) col->SetBlack();

			// centre
			d = sqrt(sqr(x) + sqr(y + (real)0.05));
			if (d <= CLUBR2) col->SetBlack();

			// stalk
			if ((y < 0) && (x >= -SPADESTALK) && (x <= SPADESTALK))
			{
				real k = (y + (real)0.51)*2;
				k = (1 - sqrt(k))*SPADESTALK;
				if ((x < k) && (x > -k)) col->SetBlack();
			}
		}
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// render card digit (xc, yc=coordinate of center)

#define CARDDS ((real)8/CARDMM)		// digit small size
#define CARDDS2 ((real)30/CARDMM)	// digit big size

void CFilterCard::CardDig(CColor* col, real x, real y, int dig, real xc, real yc, BOOL rot, BOOL mini /*= TRUE*/)
{
	dig--;
	if ((DWORD)dig >= (DWORD)CARDDIGN) return;

	real sizeY = mini ? CARDDS : CARDDS2;
	real sizeX = sizeY*CARDDIGW/CARDDIGH;
	xc -= sizeX/2;
	yc -= sizeY/2;

	// check hit
	if ((x < xc) || (x >= xc + sizeX) || (y < yc) || (y >= yc + sizeY)) return;

	// relative coordinates
	x = (x - xc)/sizeX - (real)0.5;
	y = (y - yc)/sizeY - (real)0.5;
	if (rot)
	{
		x = -x;
		y = -y;
	}

	// prepare pixel coordinates
	x += 0.5;
	y += 0.5;
	x *= CARDDIGW;
	int xx = (int)x;
	if (xx >= CARDDIGW) xx = CARDDIGW - 1;
	x -= xx;
	y *= CARDDIGH;
	int yy = (int)y;
	if (yy >= CARDDIGH) yy = CARDDIGH - 1;
	y -= yy;
	int xx2 = xx + 1;
	if (xx2 >= CARDDIGW) xx2 = CARDDIGW - 1;
	int yy2 = yy + 1;
	if (yy2 >= CARDDIGH) yy2 = CARDDIGH - 1;

	// interpolate color
	u8 b11 = CardDigMap[dig*CARDDIGW + xx + yy*CARDDIGWT];
	u8 b12 = CardDigMap[dig*CARDDIGW + xx + yy2*CARDDIGWT];
	u8 b21 = CardDigMap[dig*CARDDIGW + xx2 + yy*CARDDIGWT];
	u8 b22 = CardDigMap[dig*CARDDIGW + xx2 + yy2*CARDDIGWT];
	real k = 1 - ((b11*(1-x) + b21*x)*(1-y) + (b12*(1-x) + b22*x)*y)/255;

	col->r = ((m_CardCol == 1) || (m_CardCol == 2)) ? 1 : k;
	col->g = k;
	col->b = k;
	col->a = 1;
}	

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

#define CARDMINIX ((real)5.5/CARDMM)// mini symbol X
#define CARDMINIY ((real)17/CARDMM)	// mini symbol Y
#define CARDDIGY ((real)8.5/CARDMM)	// digi symbol Y

#define CARDDX ((real)13/CARDMM)	// symbol column delta X
#define CARDX1 (CARDW/2 - CARDDX)	// symbol column 1 X
#define CARDX2 (CARDW/2)			// symbol column 2 X
#define CARDX3 (CARDW/2 + CARDDX)	// symbol column 3 X

#define CARDDY ((real)29/CARDMM)	// symbol heigh row delta Y
#define CARDY1 (CARDH/2 - CARDDY)	// symbol heigh row 1 Y
#define CARDY15 (CARDH/2 - CARDDY/2) // symbol heigh row 1.5 Y
#define CARDY2 (CARDH/2)			// symbol heigh row 2 Y
#define CARDY25 (CARDH/2 + CARDDY/2) // symbol heigh row 2.5 Y
#define CARDY3 (CARDH/2 + CARDDY)	// symbol heigh row 3 Y

#define CARDLDY ((real)19.33/CARDMM) // symbol low row delta Y
#define CARDLY1 (CARDH/2 - CARDLDY*(real)1.5)	// symbol low row 1 Y
#define CARDLY15 (CARDH/2 - CARDLDY)	// symbol low row 1.5 Y
#define CARDLY2 (CARDH/2 - CARDLDY/2)	// symbol low row 2 Y
#define CARDLY25 (CARDH/2)				// symbol low row 2.5 Y
#define CARDLY3 (CARDH/2 + CARDLDY/2)	// symbol low row 3 Y
#define CARDLY35 (CARDH/2 + CARDLDY)	// symbol low row 3.5 Y
#define CARDLY4 (CARDH/2 + CARDLDY*(real)1.5)	// symbol low row 4 Y

void CFilterCard::RenderCol(CColor* col, real x, real y)
{
	// get properties
	int card = (int)(CLAMP(m_Prop[PROP_CARD_CARD].RenderVal(x, y))*100 + (real)0.5);
	m_CardCol = (card + 3) & 0x3;
	int value = (card + 3) / 4;
	real outline = m_Prop[PROP_CARD_OUTLINE].RenderVal(x, y)/100;

	// render background
	bool in = false;
	real x1 = (real)0.5 - CARDW/2;
	real x2 = (real)0.5 + CARDW/2;
	real y1 = (real)0.5 - CARDH/2;
	real y2 = (real)0.5 + CARDH/2;

	// check card base dimension
	col->SetWhite();
	if ((x >= x1) && (x < x2) && (y >= y1) && (y < y2))
	{
		in = true;

		// distance to base outline
		real out = (x < 0.5) ? (x - x1) : (x2 - x);
		real out2 = (y < 0.5) ? (y - y1) : (y2 - y);
		if (out2 < out) out = out2;

		// corners
		real xx = x;
		if (xx < 0.5) xx = 1 - xx;
		real yy = y;
		if (yy < 0.5) yy = 1 - yy;
		if ((xx > x2 - CARDC) && (yy > y2 - CARDC))
		{
			real d = sqr(xx - x2 + CARDC) + sqr(yy - y2 + CARDC);
			in = (d <= CARDC*CARDC);
			if (in)
			{
				out2 = CARDC - sqrt(d);
				if (out2 < out) out = out2;
			}
		}

		// outline
		if (in && (out >= 0) && (out < outline))
			m_Prop[PROP_CARD_OUTCOL].RenderCol(col, x, y);

		// check empty card
		if (value > 0)
		{
			// render mini symbols
			this->CardSym(col, x, y, x1 + CARDMINIX, y2 - CARDMINIY, FALSE, TRUE);
			this->CardSym(col, x, y, x2 - CARDMINIX, y2 - CARDMINIY, FALSE, TRUE);
			this->CardSym(col, x, y, x1 + CARDMINIX, y1 + CARDMINIY, TRUE, TRUE);
			this->CardSym(col, x, y, x2 - CARDMINIX, y1 + CARDMINIY, TRUE, TRUE);

			// render digits
			this->CardDig(col, x, y, value, x1 + CARDMINIX, y2 - CARDDIGY, FALSE);
			this->CardDig(col, x, y, value, x2 - CARDMINIX, y2 - CARDDIGY, FALSE);
			this->CardDig(col, x, y, value, x1 + CARDMINIX, y1 + CARDDIGY, TRUE);
			this->CardDig(col, x, y, value, x2 - CARDMINIX, y1 + CARDDIGY, TRUE);

			// render inner symbols
			switch (value)
			{
			// Ace
			case 1:
				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDY2, FALSE);
				break;

			// 3
			case 3:
				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDY2, FALSE);
			// 2
			case 2:
				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDY1, FALSE);
				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDY3, TRUE);
				break;

			// 9
			case 9:
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDLY2, FALSE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDLY2, FALSE);
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDLY3, TRUE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDLY3, TRUE);
			// 5
			case 5:
				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDY2, FALSE);
			// 4
			case 4:
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDY1, FALSE);
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDY3, TRUE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDY1, FALSE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDY3, TRUE);
				break;

			// 8
			case 8:
				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDY15, FALSE);
			// 7
			case 7:
				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDY25, TRUE);
			// 6
			case 6:
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDY1, FALSE);
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDY2, FALSE);
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDY3, TRUE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDY1, FALSE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDY2, FALSE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDY3, TRUE);
				break;

			// 10
			case 10:
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDLY1, FALSE);
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDLY4, TRUE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDLY1, FALSE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDLY4, TRUE);
				
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDLY2, FALSE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDLY2, FALSE);
				this->CardSym(col, x, y, x1 + CARDX1, y2 - CARDLY3, TRUE);
				this->CardSym(col, x, y, x1 + CARDX3, y2 - CARDLY3, TRUE);

				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDLY15, FALSE);
				this->CardSym(col, x, y, x1 + CARDX2, y2 - CARDLY35, TRUE);
				break;

			// J, Q, K
			case 11:
			case 12:
			case 13:
				this->CardDig(col, x, y, value, 0.5, 0.5, FALSE, FALSE);
				break;
			}
		}
	}

	// render background
	if (!in) col->Set(0,0,0,0);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterCard::RenderVal(real x, real y)
{
	CColor col;
	CFilterCard::RenderCol(&col, x, y);
	return col.Gray();
}
