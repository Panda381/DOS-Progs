
///////////////////////////////////////////////////////////////////////////////
//
//                              Brick Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CText FilterBrickFillMode[] = {
	CText(_T("Image")),			// 0
	CText(_T("Random Image")),	// 1
	CText(_T("Solid")),			// 2
	CText(_T("Random Solid")),	// 3
	CText(_T("Rotated Image")),	// 4
	CText(_T("Whole Image")),	// 5

	CText(_T(""))
};

CText FilterFloorFillMode[] = {
	CText(_T("Image")),			// 0
	CText(_T("Random Image")),	// 1
	CText(_T("Solid")),			// 2
	CText(_T("Random Solid")),	// 3
	CText(_T("Whole Image")),	// 4

	CText(_T(""))
};

CText FilterPavingBondMode[] = {
	CText(_T("Stack")),			// 0
	CText(_T("Stretcher")),		// 1
	CText(_T("Basket Weave")),	// 2
	CText(_T("Half Basket")),	// 3
	CText(_T("Spanish")),		// 4
	CText(_T("Flanders")),		// 5
	CText(_T("Single Basket")),	// 6
	CText(_T("Boxed Basket")),	// 7
	CText(_T("Herring Bone")),	// 8
	CText(_T("Stack Running")),	// 9
	CText(_T("De La Robia")),	// 10
	CText(_T("De La Robia 2")),	// 11
	CText(_T("Dutch")),			// 12
	CText(_T("Dutch 2")),		// 13
	CText(_T("Tudor")),			// 14
	CText(_T("Knit")),			// 15

	CText(_T(""))
};

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBrick::CFilterBrick()
{
	m_Group = FGRP_PAT;
	m_Category = FCAT_BRICK;
	m_Class = _T("Brick");
	m_HelpID = HELP_FBRICK;
	m_PropNum = 15;

	this->SetList(_T("100"));

	m_PavMode = FALSE;

	m_Prop[PROP_BRICK_BRICK].SetCategory(PCAT_COLOR);
	m_Prop[PROP_BRICK_BRICK].SetName("Brick");
	m_Prop[PROP_BRICK_BRICK].SetColor((real)204/255, (real)76/255, (real)25/255);
	m_Prop[PROP_BRICK_BRICK].SetToolID(ID_PROP_BRICK);

	m_Prop[PROP_BRICK_MORTAR].SetCategory(PCAT_COLOR);
	m_Prop[PROP_BRICK_MORTAR].SetName("Mortar");
	m_Prop[PROP_BRICK_MORTAR].SetColor((real)76/255, (real)51/255, (real)25/255);
	m_Prop[PROP_BRICK_MORTAR].SetToolID(ID_PROP_MORTAR);

	m_Prop[PROP_BRICK_WIDTH].SetName("Width");
	m_Prop[PROP_BRICK_WIDTH].SetValue((real)0.02);
	m_Prop[PROP_BRICK_WIDTH].SetToolID(ID_PROP_BRICKWIDTH);

	m_Prop[PROP_BRICK_HEIGHT].SetName("Height");
	m_Prop[PROP_BRICK_HEIGHT].SetValue((real)0.06);
	m_Prop[PROP_BRICK_HEIGHT].SetToolID(ID_PROP_BRICKHEIGHT);

	m_Prop[PROP_BRICK_GAP].SetName("Gap");
	m_Prop[PROP_BRICK_GAP].SetValue((real)0.1);
	m_Prop[PROP_BRICK_GAP].SetToolID(ID_PROP_BRICKGAP);

	m_Prop[PROP_BRICK_BEVEL].SetName("Bevel");
	m_Prop[PROP_BRICK_BEVEL].SetValue((real)0.02);
	m_Prop[PROP_BRICK_BEVEL].SetToolID(ID_PROP_BRICKBEVEL);

	m_Prop[PROP_BRICK_CORNERS].SetName("Corners");
	m_Prop[PROP_BRICK_CORNERS].SetValue((real)0.05);
	m_Prop[PROP_BRICK_CORNERS].SetToolID(ID_PROP_BRICKCORNERS);

	m_Prop[PROP_BRICK_BOND].SetName("Bond");
	m_Prop[PROP_BRICK_BOND].SetValue((real)0.14);
	m_Prop[PROP_BRICK_BOND].SetToolID(ID_PROP_BRICKBOND);
	m_Prop[PROP_BRICK_BOND].SetMinVal((real)0.11);
	m_Prop[PROP_BRICK_BOND].SetMin(11);
	m_Prop[PROP_BRICK_BOND].SetMaxVal((real)0.99);
	m_Prop[PROP_BRICK_BOND].SetMax(99);

	m_Prop[PROP_BRICK_CHAOS].SetName("Chaos");
	m_Prop[PROP_BRICK_CHAOS].SetToolID(ID_PROP_BRICKCHAOS);

	m_Prop[PROP_BRICK_HUE].SetName("Hue");
	m_Prop[PROP_BRICK_HUE].SetToolID(ID_PROP_BRICKHUE);

	m_Prop[PROP_BRICK_SAT].SetName("Saturation");
	m_Prop[PROP_BRICK_SAT].SetToolID(ID_PROP_BRICKSAT);

	m_Prop[PROP_BRICK_LUM].SetName("Luminance");
	m_Prop[PROP_BRICK_LUM].SetToolID(ID_PROP_BRICKLUM);

	m_Prop[PROP_BRICK_FILL].SetCategory(PCAT_ENUM);
	m_Prop[PROP_BRICK_FILL].SetName("Fill");
	m_Prop[PROP_BRICK_FILL].SetValue((real)0.1);
	m_Prop[PROP_BRICK_FILL].SetMax(10);
	m_Prop[PROP_BRICK_FILL].SetEnum(FilterBrickFillMode);
	m_Prop[PROP_BRICK_FILL].SetToolID(ID_PROP_BRICKFILL);

	m_Prop[PROP_BRICK_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_BRICK_PROFILE].SetName("Profile");
	m_Prop[PROP_BRICK_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_BRICK_PROFILE].SetToolID(ID_PROP_BEVELPROFILE);

	m_Prop[PROP_BRICK_SEED].SetName("Seed");
	m_Prop[PROP_BRICK_SEED].SetMax(1000);
	m_Prop[PROP_BRICK_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// set list

void CFilterBrick::SetList(const CText& list)
{
	m_List = list;

	// split list to rows
	CTextList rows;
	rows.Split(list, TCHAR(';'));
	int rown = rows.Num();
	if (rown > BRICKMAX) rown = BRICKMAX;

	// split rows to columns
	m_RowNum = rown;
	m_ColMax = 0;
	CTextList cols;
	int i, j, coln;
	CText txt;
	for (i = 0; i < rown; i++)
	{
		cols.Split(rows[i], TCHAR(','));
		coln = cols.Num();
		if (coln > BRICKMAX) coln = BRICKMAX;
		m_RowLen[i] = coln;
		if (coln > m_ColMax) m_ColMax = coln;

		// decode pattern
		for (j = 0; j < coln; j++)
		{
			txt = cols[j];
			txt.Trim();
			m_Pattern[i][j] = CLAMP((real)txt.Double()/100);
		}

		if (m_RowLen[i] == 0)
		{
			m_RowLen[i] = 1;
			m_Pattern[i][0] = 1;
			if (m_ColMax < 1) m_ColMax = 1;
		}
	}

	// default pattern
	if (rown == 0)
	{
		m_RowNum = 1;
		m_ColMax = 1;
		m_RowLen[0] = 1;
		m_Pattern[0][0] = 1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

#define BRICK(xr,yr,wr,hr,dpos,drow) if ((x2>=w*xr)&&(x2<w*xr+w*wr)&&(y2>=h*yr)&&(y2<h*yr+h*hr)) \
{ x2-=w*xr; w*=(real)wr; pos=(int)(((((pos==0)&&((real)xr<0))?numX:pos)+(real)xr)/((real)wr) + 0.6); pos2+=dpos; \
	y2-=h*yr; h*=(real)hr; row=(int)(((((row==0)&&((real)yr<0))?numY:row)+(real)yr)/((real)hr) + 0.6); row2+=drow; } else

void CFilterBrick::RenderCol(CColor* col, real x, real y)
{
	// load properties
	int numX = (int)(m_Prop[PROP_BRICK_WIDTH].RenderVal(x, y)*100 + (real)0.5);
	int numX0 = numX;
	if (numX < 1) numX = 1;
	int numY = (int)(m_Prop[PROP_BRICK_HEIGHT].RenderVal(x, y)*100 + (real)0.5);
	int numY0 = numY;
	if (numY < 1) numY = 1;
	int numXY = 2*((2*numX > numY) ? 2*numX : numY);
	real gap = m_Prop[PROP_BRICK_GAP].RenderVal(x, y)/numXY;
	real bev = m_Prop[PROP_BRICK_BEVEL].RenderVal(x, y)/numXY;
	real corn = m_Prop[PROP_BRICK_CORNERS].RenderVal(x, y)/numXY;
	real chaos = m_Prop[PROP_BRICK_CHAOS].RenderVal(x, y);
	real hue = m_Prop[PROP_BRICK_HUE].RenderVal(x, y);
	real sat = m_Prop[PROP_BRICK_SAT].RenderVal(x, y);
	real lum = m_Prop[PROP_BRICK_LUM].RenderVal(x, y);
	int seed = (int)(m_Prop[PROP_BRICK_SEED].RenderVal(x, y)*1000 + (real)0.5);
	int fill = (int)(m_Prop[PROP_BRICK_FILL].RenderVal(x, y)*10 + (real)0.5);

	BOOL needmort = FALSE;

	real x2, y2, w, h, shft;
	int row, pos, row2, pos2;
	BOOL knit = FALSE;
	if (m_PavMode)
	{
		// PAVING mode
		int bond = (int)(m_Prop[PROP_BRICK_BOND].RenderVal(x, y)*20 + (real)0.5);

		// vertical position (row of blocks)
		h = (real)1/numY; // row height
		y2 = y * numY;
		row = (int)floor(y2);
		y2 -= row;
		y2 *= h; // Y coordinate in row (range 0..h)
		row %= numY;
		if (row < 0) row += numY; // row in window from bottom

		// horizontal position (brick in row)
		if ((bond == 8) || (bond >= 10)) chaos = 0; // Herring Bone, De La Robia, Dutch - disable chaos shift
		w = (real)1/numX; // brick width
		shft = Noise1D(row, seed)/2*chaos;
		if ((bond == 5) && ((row & 1) == 1)) shft += (real)1/3; // Flanders
		if ((bond == 1) && ((row & 1) == 1)) shft += (real)1/2; // Stretcher
		shft *= w; // row shift
		x2 = x - shft;
		x2 *= numX;
		pos = (int)floor(x2);
		x2 -= pos;
		x2 *= w; // X coordinate in brick (range 0..w)
		pos %= numX;
		if (pos < 0) pos += numX; // brick in window from left

		row2 = row;
		pos2 = pos;

		// bond
		switch (bond)
		{
		// basket
		case 2:
			pos2 *= 3;
			if (((pos + row) & 1) == 0)
			{
				// 3 horizontal bricks
				BRICK(0,0,1,1/3,0,0)
				BRICK(0,1/3,1,1/3,1,0)
				BRICK(0,2/3,1,1/3,2,0)
				{}
			}
			else
			{
				// 3 vertical bricks
				BRICK(0,0,1/3,1,0,0)
				BRICK(1/3,0,1/3,1,1,0)
				BRICK(2/3,0,1/3,1,2,0)
				{}
			}
			break;

		// half basket
		case 3:
			pos2 *= 2;
			if (((pos + row) & 1) == 0)
			{
				// 2 horizontal bricks
				BRICK(0,0,1,1/2,0,0)
				BRICK(0,1/2,1,1/2,1,0)
				{}
			}
			else
			{
				// 2 vertical bricks
				BRICK(0,0,1/2,1,0,0)
				BRICK(1/2,0,1/2,1,1,0)
				{}
			}
			break;

		// Spanish
		case 4:

		// Flanders
		case 5:
			pos2 *= 5;
			BRICK(0,0,2/3,1/3,0,0)
			BRICK(2/3,0,1/3,2/3,1,0)
			BRICK(1/3,2/3,2/3,1/3,2,0)
			BRICK(0,1/3,1/3,2/3,3,0)
			BRICK(1/3,1/3,1/3,1/3,4,0)
			{}
			break;

		// Single basket
		case 6:
			pos2 *= 6;
			BRICK(0,0,1/4,2/3,0,0)
			BRICK(0,2/3,2/4,1/3,1,0)
			BRICK(1/4,0,1/4,2/3,2,0)
			BRICK(2/4,1/3,1/4,2/3,3,0)
			BRICK(2/4,0,2/4,1/3,4,0)
			BRICK(3/4,1/3,1/4,2/3,5,0)
			{}
			break;

		// boxed basket
		case 7:
			pos2 *= 8;
			if (((pos + row) & 1) == 0)
			{
				BRICK(0,0,1/2,1/4,0,0)
				BRICK(1/2,0,1/2,1/4,1,0)
				BRICK(3/4,1/4,1/4,1/2,2,0)
				BRICK(1/2,3/4,1/2,1/4,3,0)
				BRICK(0,3/4,1/2,1/4,4,0)
				BRICK(0,1/4,1/4,1/2,5,0)
				BRICK(1/4,1/4,1/2,1/4,6,0)
				BRICK(1/4,2/4,1/2,1/4,7,0)
				{}
			}
			else
			{
				BRICK(0,0,1/4,1/2,0,0)
				BRICK(0,1/2,1/4,1/2,1,0)
				BRICK(1/4,3/4,1/2,1/4,2,0)
				BRICK(3/4,1/2,1/4,1/2,3,0)
				BRICK(3/4,0,1/4,1/2,4,0)
				BRICK(1/4,0,1/2,1/4,5,0)
				BRICK(1/4,1/4,1/4,1/2,6,0)
				BRICK(2/4,1/4,1/4,1/2,7,0)
				{}
			}
			break;

		// Herring Bone
		case 8:
			pos2 *= 8;
			BRICK(0,1/4,1/4,1/2,0,0)
			BRICK(0,3/4,1/2,1/4,1,0)
			BRICK(1/4,0,1/4,1/2,2,0)
			BRICK(1/4,1/2,1/2,1/4,3,0)
			BRICK(1/2,-1/4,1/4,1/2,4,-1)
			BRICK(1/2,3/4,1/4,1/2,4,0)
			BRICK(1/2,1/4,1/2,1/4,5,0)
			BRICK(3/4,1/2,1/4,1/2,6,0)
			BRICK(3/4,0,1/2,1/4,7,0)
			BRICK(-1/4,0,1/2,1/4,-1,0)
			{}
			break;

		// Stack Running
		case 9:
			pos2 *= 3;
			BRICK(0,0,1/2,2/3,0,0)
			BRICK(0,2/3,1,1/3,1,0)
			BRICK(1/2,0,1/2,2/3,2,0)
			{}
			break;

		// De La Robia
		case 10:
			pos2 *= 4;
			BRICK(1/8,0,3/8,5/8,0,0)
			BRICK(0,5/8,5/8,3/8,1,0)
			BRICK(5/8,4/8,3/8,5/8,2,0)
			BRICK(5/8,-4/8,3/8,5/8,2,-1)
			BRICK(4/8,1/8,5/8,3/8,3,0)
			BRICK(-4/8,1/8,5/8,3/8,-1,0)
			{ needmort = TRUE; }
			break;

		// De La Robia 2
		case 11:
			pos2 *= 8;
			BRICK(1/8,0,3/8,5/8,0,0)
			BRICK(0,5/8,5/8,3/8,1,0)
			BRICK(5/8,4/8,3/8,5/8,2,0)
			BRICK(5/8,-4/8,3/8,5/8,2,-1)
			BRICK(4/8,1/8,5/8,3/8,3,0)
			BRICK(-4/8,1/8,5/8,3/8,-5,0)
			BRICK(0,0,1/8,1/8,4,0)
			BRICK(0,4/8,1/8,1/8,5,0)
			BRICK(4/8,4/8,1/8,1/8,6,0)
			BRICK(4/8,0,1/8,1/8,7,0)
			{ }
			break;

		// Dutch
		case 12:
			pos2 *= 5;
			BRICK(0,0,2/5,2/5,0,0)
			BRICK(1/5,2/5,2/5,2/5,1,0)
			BRICK(2/5,4/5,2/5,2/5,2,1)
			BRICK(2/5,-1/5,2/5,2/5,2,0)
			BRICK(3/5,1/5,2/5,2/5,3,0)
			BRICK(4/5,3/5,2/5,2/5,4,0)
			BRICK(-1/5,3/5,2/5,2/5,-1,0)
			{ needmort = TRUE; }
			break;
			
		// Dutch 2
		case 13:
			pos2 *= 10;
			BRICK(0,0,2/5,2/5,0,0)
			BRICK(1/5,2/5,2/5,2/5,1,0)
			BRICK(2/5,4/5,2/5,2/5,2,1)
			BRICK(2/5,-1/5,2/5,2/5,2,0)
			BRICK(3/5,1/5,2/5,2/5,3,0)
			BRICK(4/5,3/5,2/5,2/5,4,0)
			BRICK(-1/5,3/5,2/5,2/5,-6,0)

			BRICK(0,2/5,1/5,1/5,5,0)
			BRICK(1/5,4/5,1/5,1/5,6,0)
			BRICK(2/5,1/5,1/5,1/5,7,0)
			BRICK(3/5,3/5,1/5,1/5,8,0)
			BRICK(4/5,0,1/5,1/5,9,0)
			{}
			break;

		// Tudor
		case 14:
			pos2 *= 21;
			BRICK(0,0,2/7,2/7,0,0)

			BRICK(0,5/7,1/7,1/7,1,0)
			BRICK(0,4/7,2/7,1/7,2,0)
			BRICK(1/7,3/7,1/7,1/7,3,0)
			BRICK(1/7,2/7,2/7,1/7,4,0)
			BRICK(2/7,1/7,1/7,1/7,5,0)
			BRICK(2/7,0,2/7,1/7,6,0)

			BRICK(1/7,5/7,2/7,2/7,7,0)
			BRICK(2/7,3/7,2/7,2/7,8,0)
			BRICK(3/7,1/7,2/7,2/7,9,0)
			BRICK(4/7,-1/7,2/7,2/7,10,0)

			BRICK(3/7,6/7,1/7,1/7,11,0)
			BRICK(3/7,5/7,2/7,1/7,12,0)
			BRICK(4/7,4/7,1/7,1/7,13,0)
			BRICK(4/7,3/7,2/7,1/7,14,0)
			BRICK(5/7,2/7,1/7,1/7,15,0)
			BRICK(5/7,1/7,2/7,1/7,16,0)
			BRICK(6/7,0,1/7,1/7,17,0)

			BRICK(4/7,6/7,2/7,2/7,10,1)
			BRICK(5/7,4/7,2/7,2/7,18,0)
			BRICK(6/7,2/7,2/7,2/7,19,0)
			BRICK(-1/7,2/7,2/7,2/7,-2,0)

			BRICK(6/7,6/7,2/7,1/7,20,0)
			BRICK(-1/7,6/7,2/7,1/7,-1,0)
			{}
			break;

		// Knit
		case 15:
			pos2 *= 4;
			BRICK(1/8,0,3/8,5/8,0,0)
			BRICK(0,5/8,5/8,3/8,1,0)
			BRICK(5/8,4/8,3/8,5/8,2,0)
			BRICK(5/8,-4/8,3/8,5/8,2,-1)
			BRICK(4/8,1/8,5/8,3/8,3,0)
			BRICK(-4/8,1/8,5/8,3/8,-1,0)
			{ needmort = TRUE; }
			knit = TRUE;
			break;


		// Stack, Stretcher
		default:
			break;
		}
	}
	else
	{
		// BRICK mode
		real bond = CLAMP(m_Prop[PROP_BRICK_BOND].RenderVal(x, y))+(real)0.0000001;

		// prepare bond table and number of rows in pattern
		int b[6]; // bond table (from top row to bottom row)
		int n,k;
		for (n = 0; n < 6; n++)
		{
			bond *= 10;
			k = (int)bond;
			if (k <= 0) break;
			b[n] = k;
			bond -= k;
		}
		if (n <= 0)
		{
			n = 1;
			b[0] = 1;
		}

		// prepare row (top pattern can be truncated)
		y2 = y * numY;
		row = (int)floor(y2);
		y2 -= row;
		h = (real)1/numY; // row height
		y2 *= h; // Y coordinate in row (range 0..h)
		row %= numY;
		if (row < 0) row += numY; // row in window from bottom
		int row22 = row % n; // row in pattern from bottom

		// prepare brick in row
		int bb = b[n - 1 - row22];
		shft = 0;
		switch (bb)
		{
		case 2: shft = (real)1/4; break;
		case 3: shft = (real)1/3; break;
		case 4: shft = (real)1/2; break;
		case 5: shft = (real)2/3; break;
		case 6: shft = (real)3/4; break;
		case 7: numX *= 2; break;
		case 8: numX *= 2; shft = (real)1/4*2; break;
		case 9: numX = numX * 2 / 3; if (numX <= 0) numX = 1; break;
		}
		w = (real)1/numX; // brick width
		shft += Noise1D(row,seed)/2*chaos; // chaos
		shft *= w; // row shift

		// horizontal position (brick in row)
		x2 = x - shft;
		x2 *= numX;
		pos = (int)floor(x2);
		x2 -= pos;
		x2 *= w; // X coordinate in brick (range 0..w)
		pos %= numX;
		if (pos < 0) pos += numX; // brick in window from left

		row2 = row;
		pos2 = pos;
	}

	real x3 = x2;
	real y3 = y2;
	if (x3 > w/2) x3 = w - x3;
	if (y3 > h/2) y3 = h - y3;

	// knit
	real mort = 1;
	if (knit && !needmort)
	{
		if (bev <= (real)0.000001) bev = (real)0.000001;
		real gap2 = gap + bev;
		mort = 0;
		real mort2 = 0;
		if (w > h)
		{
			if (y3 < gap2) mort = (gap2 - y3)/bev;
			mort2 = 1 - sqrt(1 - sqr((w/2-x3)/(w/2)));
		}
		else
		{
			if (x3 < gap2) mort = (gap2 - x3)/bev;
			mort2 = 1 - sqrt(1 - sqr((h/2-y3)/(h/2)));
		}
		mort = sqrt(sqr(mort)+sqr(mort2));
		if (mort > 1) mort = 1;
		needmort = TRUE;
	}

	// mortar and bevel, transform corners to one corner
	if (!needmort)
	{
		// bevel margins
		real gap2 = gap + bev;
		if (bev > 0)
		{
			// smooth margin
			mort = 0;
			real mort2 = 0;
			if ((y3 < gap2) && (numY0 > 0)) mort = (gap2 - y3)/bev;
			if ((x3 < gap2) && (numX0 > 0)) mort2 = (gap2 - x3)/bev;
			if (mort2 > mort) mort = mort2;
			if (mort > 1) mort = 1;
		}
		else
		{
			// no bevel, sharp margin
			mort = (real)((((y3 < gap2) && (numY0 > 0)) || ((x3 < gap2) && (numX0 > 0))) ? 1 : 0);
			bev = (real)0.000001;
		}

		// corners
		real gap3 = gap + corn;
		if ((corn > 0) && (numX0 > 0) && (numY0 > 0))
		{
			// corner is bigger than bevel, inner corner is small and round
			if (corn >= bev)
			{
				if ((x3 < gap3) && (y3 < gap3))
				{
					real y4 = gap3 - y3;
					real x4 = gap3 - x3;
					real d = (sqrt(y4*y4 + x4*x4) - (corn - bev))/bev;
					if (d > 1) d = 1;
					if (d > mort) mort = d;
				}
			}
			else
			{
				// corner is lower than bevel, inner corner is rectangular
				if ((x3 < gap2) && (y3 < gap2))
				{
					real a = atan((gap2-x3)/(gap2-y3));	// angle to this point
					real b = atan((bev-corn)/bev); // angle to last point of corner
					if ((a >= b) && (a <= PI/2 - b)) // line to point is withing range of corner
					{
						real c = (a - b) / (PI/2 - 2*b) * PI/2; // relative angle in corner circle
						real dx4 = cos(c)*corn + bev-corn; // delta from inner corner to outer corner
						real dy4 = sin(c)*corn + bev-corn;
						real dx = gap2 - x3; // delta from inner corner to point
						real dy = gap2 - y3;
						real d = sqrt((dx*dx + dy*dy)/(dx4*dx4 + dy4*dy4)); // relative distance from inner corner to point
						if (d > 1) d = 1;
						if (d > mort) mort = d;
					}
				}
			}
		}
	}
	mort = CLAMP(1 - m_Prop[PROP_BRICK_PROFILE].RenderVal(1 - mort, y));

	// fill mode
	real x0 = x;
	real y0 = y;
	switch (fill)
	{
	case 4: // Rotated Image
		if (h > w + (real)0.000001)
		{
			y = (Noise2D(pos, row, seed+5)+1)/2*(1-w) + x2;
			x = (Noise2D(pos, row, seed+10)+1)/2*(1-h) + y2;
			break;
		}

	case 1: // random image
		x = (Noise2D(pos, row, seed+5)+1)/2*(1-w) + x2;
		y = (Noise2D(pos, row, seed+10)+1)/2*(1-h) + y2;
		break;

	case 2: // solid
		x = (pos + (real)0.5)*w + shft;
		y = (row + (real)0.5)*h;
		break;

	case 3: // random solid
		x = (Noise2D(pos, row, seed+15)+1)/2*(1-w) + w/2;
		y = (Noise2D(pos, row, seed+20)+1)/2*(1-h) + h/2;
		break;

	case 5: // whole image
		if (gap >= w/2) gap=w/2-(real)0.00001;
		if (gap >= h/2) gap=h/2-(real)0.00001;
		x = (x2-gap)/(w-2*gap);
		y = (y2-gap)/(h-2*gap);
		break;
	}

	// render brick color
	if (mort < 1)
		m_Prop[PROP_BRICK_BRICK].RenderCol(col, x, y);
	else
		col->SetBlack();

	// color correction
	if ((hue > 0) || (sat > 0))
	{
		col->RGBToHSL();
		col->r += hue*(Noise2D(pos, row, seed+70)/2);
		if (col->r < 0) col->r += 1;
		if (col->r >= 1) col->r -= 1;
		col->g *= 1 + sat*Noise2D(pos, row, seed+113);
		col->HSLToRGB();
	}
	if (lum > 0) col->Brightness((real)0.5 + lum*(Noise2D(pos, row, seed+200)/2));

	// pattern
	while (row2 < 0) row2 += m_RowNum;
	int i = row2 % m_RowNum;
	while (pos2 < 0) pos2 += m_RowLen[i];
	int j = pos2 % m_RowLen[i];
	col->Mul(m_Pattern[i][j]);

	// render mortar color
	CColor c;
	if (mort > 0)
		m_Prop[PROP_BRICK_MORTAR].RenderCol(&c, x0, y0);
	else
		c.SetBlack();

	// transpose colors
	col->Trans(c, mort);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBrick::RenderVal(real x, real y)
{
	CColor col;
	CFilterBrick::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterPaving::CFilterPaving()
{
	m_Class = _T("Paving");
	m_HelpID = HELP_FPAVING;
	m_PavMode = TRUE;

	m_Prop[PROP_BRICK_WIDTH].SetValue((real)0.02);
	m_Prop[PROP_BRICK_WIDTH].SetToolID(ID_PROP_PAVINGWIDTH);

	m_Prop[PROP_BRICK_HEIGHT].SetValue((real)0.02);
	m_Prop[PROP_BRICK_HEIGHT].SetToolID(ID_PROP_PAVINGHEIGHT);

	m_Prop[PROP_BRICK_BOND].SetCategory(PCAT_ENUM);
	m_Prop[PROP_BRICK_BOND].SetMinVal(0);
	m_Prop[PROP_BRICK_BOND].SetMaxVal(1);
	m_Prop[PROP_BRICK_BOND].SetMin(0);
	m_Prop[PROP_BRICK_BOND].SetMax(20);
	m_Prop[PROP_BRICK_BOND].SetValue((real)8/20);
	m_Prop[PROP_BRICK_BOND].SetEnum(FilterPavingBondMode);
	m_Prop[PROP_BRICK_BOND].SetToolID(ID_PROP_PAVINGBOND);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterFloor::CFilterFloor()
{
	m_Group = FGRP_PAT;
	m_Category = FCAT_IMG;
	m_Class = _T("Floor");
	m_HelpID = HELP_FFLOOR;
	m_PropNum = 14;

	m_Prop[PROP_SOURCE].SetColor((real)105/255, (real)150/255, (real)149/255);
	m_Prop[PROP_SOURCE2].SetColor((real)231/255, (real)224/255, (real)190/255);
	m_Prop[PROP_SOURCE3].SetColor((real)103/255, (real)71/255, (real)52/255);

	m_Prop[PROP_FLOOR_MORTAR].SetCategory(PCAT_COLOR);
	m_Prop[PROP_FLOOR_MORTAR].SetName("Mortar");
	m_Prop[PROP_FLOOR_MORTAR].SetColor((real)200/255, (real)200/255, (real)190/255);
	m_Prop[PROP_FLOOR_MORTAR].SetToolID(ID_PROP_MORTAR);

	m_Prop[PROP_FLOOR_TILES].SetName("Tiles");
	m_Prop[PROP_FLOOR_TILES].SetValue((real)0.02);
	m_Prop[PROP_FLOOR_TILES].SetToolID(ID_PROP_FLOORTILES);
	m_Prop[PROP_FLOOR_TILES].SetMinVal((real)0.01);
	m_Prop[PROP_FLOOR_TILES].SetMin(1);

	m_Prop[PROP_FLOOR_DIAGONAL].SetName("Diagonal");
	m_Prop[PROP_FLOOR_DIAGONAL].SetValue((real)0.5);
	m_Prop[PROP_FLOOR_DIAGONAL].SetToolID(ID_PROP_FLOORDIAG);

	m_Prop[PROP_FLOOR_GAP].SetName("Gap");
	m_Prop[PROP_FLOOR_GAP].SetValue((real)0.05);
	m_Prop[PROP_FLOOR_GAP].SetToolID(ID_PROP_BRICKGAP);

	m_Prop[PROP_FLOOR_HUE].SetName("Hue");
	m_Prop[PROP_FLOOR_HUE].SetToolID(ID_PROP_BRICKHUE);

	m_Prop[PROP_FLOOR_SAT].SetName("Saturation");
	m_Prop[PROP_FLOOR_SAT].SetToolID(ID_PROP_BRICKSAT);

	m_Prop[PROP_FLOOR_LUM].SetName("Luminance");
	m_Prop[PROP_FLOOR_LUM].SetToolID(ID_PROP_BRICKLUM);

	m_Prop[PROP_FLOOR_FILL].SetCategory(PCAT_ENUM);
	m_Prop[PROP_FLOOR_FILL].SetName("Fill");
	m_Prop[PROP_FLOOR_FILL].SetValue((real)0.1);
	m_Prop[PROP_FLOOR_FILL].SetMax(10);
	m_Prop[PROP_FLOOR_FILL].SetEnum(FilterFloorFillMode);
	m_Prop[PROP_FLOOR_FILL].SetToolID(ID_PROP_FLOORFILL);

	m_Prop[PROP_FLOOR_BEVEL].SetName("Bevel");
	m_Prop[PROP_FLOOR_BEVEL].SetValue((real)0.05);
	m_Prop[PROP_FLOOR_BEVEL].SetToolID(ID_PROP_BRICKBEVEL);

	m_Prop[PROP_FLOOR_PROFILE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_FLOOR_PROFILE].SetName("Profile");
	m_Prop[PROP_FLOOR_PROFILE].SetFilter(&FLinear);
	m_Prop[PROP_FLOOR_PROFILE].SetToolID(ID_PROP_BEVELPROFILE);

	m_Prop[PROP_FLOOR_SEED].SetName("Seed");
	m_Prop[PROP_FLOOR_SEED].SetMax(1000);
	m_Prop[PROP_FLOOR_SEED].SetToolID(ID_PROP_SEED);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterFloor::RenderCol(CColor* col, real x, real y)
{
	// load properties
	int numXY = (int)(m_Prop[PROP_FLOOR_TILES].RenderVal(x, y)*100 + (real)0.5);
	if (numXY < 1) numXY = 1;
	real wh = (real)1/numXY;
	real diag = m_Prop[PROP_FLOOR_DIAGONAL].RenderVal(x, y)*(real)0.5;
	real gap = m_Prop[PROP_FLOOR_GAP].RenderVal(x, y)*(real)0.5;
	real hue = m_Prop[PROP_FLOOR_HUE].RenderVal(x, y);
	real sat = m_Prop[PROP_FLOOR_SAT].RenderVal(x, y);
	real lum = m_Prop[PROP_FLOOR_LUM].RenderVal(x, y);
	int fill = (int)(m_Prop[PROP_FLOOR_FILL].RenderVal(x, y)*10 + (real)0.5);
	real bev = m_Prop[PROP_FLOOR_BEVEL].RenderVal(x, y)*(real)0.5;
	int seed = (int)(m_Prop[PROP_FLOOR_SEED].RenderVal(x, y)*1000 + (real)0.5);

	// prepare row and column
	real x2 = x * numXY;
	int pos = (int)floor(x2);
	x2 -= pos;
	pos %= numXY;
	if (pos < 0) pos += numXY;

	real y2 = y * numXY;
	int row = (int)floor(y2);
	y2 -= row;
	row %= numXY;
	if (row < 0) row += numXY;

	// rhomb
	BOOL rhomb = FALSE;
	if (x2 + y2 < diag)
		rhomb = TRUE;
	else if (y2 > 1 - diag + x2)
	{
		rhomb = TRUE;
		row++;
		y2--;
	}
	else if (y2 + x2 > 2 - diag)
	{
		rhomb = TRUE;
		row++;
		pos++;
		y2--;
		x2--;
	}
	else if (y2 < x2 + diag - 1)
	{
		rhomb = TRUE;
		pos++;
		x2--;
	}
	if (row >= numXY) row -= numXY;
	if (pos >= numXY) pos -= numXY;

	// rotate corners
	real x3 = x2;
	real y3 = y2;
	if (x3 >= 1) x3--;
	if (y3 >= 1) y2--;
	if (x3 < 0) x3++;
	if (y3 < 0) y3++;
	if (x3 > (real)0.5) x3 = 1 - x3;
	if (y3 > (real)0.5) y3 = 1 - y3;

	// margin and bevel
	real mort = 0;
	if (bev > 0)
	{
		if (rhomb)
		{
			gap *= diag*SQRT2;
			mort = 1 - ((diag - (x3 + y3))*RSQRT2 - gap )/bev;
		}
		else
		{
			gap *= 1 - diag/2;
			real d = 1 - (x3 - gap)/bev;
			if (d > mort) mort = d;
			d = 1 - (y3 - gap)/bev;
			if (d > mort) mort = d;
			d = 1 - ((x3 + y3 - diag)*RSQRT2 - gap)/bev;
			if (d > mort) mort = d;
		}
	}
	else
	{
		if (rhomb)
		{
			gap *= diag*SQRT2;
			if ((x3 + y3 - diag)*RSQRT2 > - gap) mort = 1;
		}
		else
		{
			gap *= 1 - diag/2;
			if ((x3 < gap) || (y3 < gap) || ((x3 + y3 - diag)*RSQRT2 < gap)) mort = 1;
		}
	}
	mort = CLAMP(1 - m_Prop[PROP_FLOOR_PROFILE].RenderVal(1 - mort, y));

	// fill mode
	real x0 = x;
	real y0 = y;
	if (rhomb) seed += 529;
	switch (fill)
	{
	case 1: // random image
		if (rhomb)
		{
			x = (Noise2D(pos, row, seed+5)+1)/2*(1-wh) + (x2+(real)0.5)*wh;
			y = (Noise2D(pos, row, seed+10)+1)/2*(1-wh) + (y2+(real)0.5)*wh;
		}
		else
		{
			x = (Noise2D(pos, row, seed+5)+1)/2*(1-wh) + x2*wh;
			y = (Noise2D(pos, row, seed+10)+1)/2*(1-wh) + y2*wh;
		}
		break;

	case 2: // solid
		x = pos + (real)0.5;
		y = row + (real)0.5;
		if (rhomb)
		{
			x += (real)0.5;
			y += (real)0.5;
		}
		x *= wh;
		y *= wh;
		break;

	case 3: // random solid
		x = (Noise2D(pos, row, seed+15)+1)/2*(1-wh) + wh/2;
		y = (Noise2D(pos, row, seed+20)+1)/2*(1-wh) + wh/2;
		break;

	case 4: // whole image
		if (gap >= (real)0.49999) gap=(real)0.49999;
		x = (x2-gap)/(1-2*gap);
		y = (y2-gap)/(1-2*gap);
		if (rhomb)
		{
			x += gap/(1-2*gap);
			y += gap/(1-2*gap);
			x *= (1+gap);
			y *= (1+gap);
			if (diag > (real)0.0000001)
			{
				x /= diag*2;
				y /= diag*2;
			}
			x += (real)0.5;
			y += (real)0.5;
		}
		break;
	}

	// render brick color
	if (mort < 1)
		m_Prop[rhomb ? PROP_SOURCE3 : ((((pos + row) & 1) == 0) ? PROP_SOURCE : PROP_SOURCE2)].RenderCol(col, x, y);
	else
		col->SetBlack();

	// color correction
	if ((hue > 0) || (sat > 0))
	{
		col->RGBToHSL();
		col->r += hue*(Noise2D(pos, row, seed+70)/2);
		if (col->r < 0) col->r += 1;
		if (col->r >= 1) col->r -= 1;
		col->g *= 1 + sat*Noise2D(pos, row, seed+113);
		col->HSLToRGB();
	}
	if (lum > 0) col->Brightness((real)0.5 + lum*(Noise2D(pos, row, seed+200)/2));

	// render mortar color
	CColor c;
	if (mort > 0)
	{
		m_Prop[PROP_FLOOR_MORTAR].RenderCol(&c, x0, y0);
		col->Trans(c, mort);
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterFloor::RenderVal(real x, real y)
{
	CColor col;
	CFilterFloor::RenderCol(&col, x, y);
	return col.Gray();
}
