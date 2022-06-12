
///////////////////////////////////////////////////////////////////////////////
//
//                              Easter Egg Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROP_EGG_MIRROR			1		// property - Mirror

#define PROP_EGG_COL1			2		// property - Color1
#define PROP_EGG_SHAPE1			3		// property - Shape1
#define PROP_EGG_SIZE1			4		// property - Size1
#define PROP_EGG_SHIFT1			5		// property - Shift1

#define PROP_EGG_COL2			6		// property - Color2
#define PROP_EGG_SHAPE2			7		// property - Shape2
#define PROP_EGG_SIZE2			8		// property - Size2
#define PROP_EGG_SHIFT2			9		// property - Shift2

#define PROP_EGG_COL3			10		// property - Color3
#define PROP_EGG_SHAPE3			11		// property - Shape3
#define PROP_EGG_SIZE3			12		// property - Size3
#define PROP_EGG_SHIFT3			13		// property - Shift3

#define PROP_EGG_COL4			14		// property - Color4
#define PROP_EGG_SHAPE4			15		// property - Shape4
#define PROP_EGG_SIZE4			16		// property - Size4
#define PROP_EGG_SHIFT4			17		// property - Shift4

#define PROP_EGG_COL5			18		// property - Color5
#define PROP_EGG_SHAPE5			19		// property - Shape5
#define PROP_EGG_SIZE5			20		// property - Size5
#define PROP_EGG_SHIFT5			21		// property - Shift5

#define PROP_EGG_COL6			22		// property - Color6
#define PROP_EGG_SHAPE6			23		// property - Shape6
#define PROP_EGG_SIZE6			24		// property - Size6
#define PROP_EGG_SHIFT6			25		// property - Shift6

#define PROP_EGG_COL7			26		// property - Color6
#define PROP_EGG_SHAPE7			27		// property - Shape6
#define PROP_EGG_SIZE7			28		// property - Size6
#define PROP_EGG_SHIFT7			29		// property - Shift6

#define PROP_EGG_COL8			30		// property - Color6
#define PROP_EGG_SHAPE8			31		// property - Shape6
#define PROP_EGG_SIZE8			32		// property - Size6
#define PROP_EGG_SHIFT8			33		// property - Shift6

CText FilterEggShape[] = {
	CText(_T("- none -")),	// 0: none
	CText(_T("Line")),		// 1
	CText(_T("Wave 1")),	// 2
	CText(_T("Wave 2")),	// 3
	CText(_T("Wave 3")),	// 4
	CText(_T("Wave Up")),	// 5
	CText(_T("Wave Dn")),	// 6
	CText(_T("Wave Dbl")),	// 7
	CText(_T("Ripple Up")),	// 8
	CText(_T("Ripple Dn")),	// 9
	CText(_T("Ripple Dbl")),// 10
	CText(_T("Moon Up")),	// 11
	CText(_T("Moon Dn")),	// 12
	CText(_T("Point")),		// 13
	CText(_T("Ring 1")),	// 14
	CText(_T("Ring 2")),	// 15
	CText(_T("Ring 3")),	// 16
	CText(_T("Zigzag 1")),	// 17
	CText(_T("Zigzag 2")),	// 18
	CText(_T("Zigzag 3")),	// 19
	CText(_T("Zigzag Up")),	// 20
	CText(_T("Zigzag Dn")),	// 21
	CText(_T("Zigzag Dbl")), // 22
	CText(_T("Heart Up")),	// 23
	CText(_T("Heart Dn")),	// 24
	CText(_T("Triangle Up")),	// 25
	CText(_T("Triangle Dn")),	// 26
	CText(_T("Star Up")),	// 27
	CText(_T("Star Dn")),	// 28
	CText(_T("Egg Up")),	// 29
	CText(_T("Egg Dn")),	// 30
	CText(_T("Box 1")),		// 31
	CText(_T("Box 2")),		// 32
	CText(_T("Box 3")),		// 33
	CText(_T("Crenelation 1")), // 34
	CText(_T("Crenelation 2")), // 35
	CText(_T("Crenelation 3")), // 36
	CText(_T("Crenelation Up")), // 37
	CText(_T("Crenelation Dn")), // 38
	CText(_T("Sun")),		// 39
	CText(_T("Droplet 1 Up")), // 40
	CText(_T("Droplet 1 Dn")), // 41
	CText(_T("Droplet 1B Up")), // 42
	CText(_T("Droplet 1B Dn")), // 43
	CText(_T("Droplet 2 Up")), // 44
	CText(_T("Droplet 2 Dn")), // 45
	CText(_T("Droplet 2B Up")), // 46
	CText(_T("Droplet 2B Dn")), // 47
	CText(_T("Droplet 3 Up")), // 48
	CText(_T("Droplet 3 Dn")), // 49
	CText(_T("Flower 1")), // 50
	CText(_T("Flower 2")), // 51
	CText(_T("Flower 3")), // 52

	CText(_T(""))
};

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterEaster::CFilterEaster()
{
	m_Group = FGRP_PAT;
	m_Class = _T("Easter");
	m_HelpID = HELP_FEASTER;
	m_PropNum = 34;

	m_Prop[PROP_SOURCE].SetName("Background");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_BACKGROUND);
	m_Prop[PROP_SOURCE].SetColorRGB(0xFFFFFF);

	m_Prop[PROP_EGG_MIRROR].SetCategory(PCAT_CHECK);
	m_Prop[PROP_EGG_MIRROR].SetName("Symmetric");
	m_Prop[PROP_EGG_MIRROR].SetMax(1);
	m_Prop[PROP_EGG_MIRROR].SetToolID(ID_PROP_EGGMIRROR);

	// pattern 1
	m_Prop[PROP_EGG_COL1].SetCategory(PCAT_COLOR);
	m_Prop[PROP_EGG_COL1].SetName("Color1");
	m_Prop[PROP_EGG_COL1].SetToolID(ID_PROP_SOURCE);
	m_Prop[PROP_EGG_COL1].SetColorRGB(0x0000FF);

	m_Prop[PROP_EGG_SHAPE1].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EGG_SHAPE1].SetName("Shape1");
	m_Prop[PROP_EGG_SHAPE1].SetValue((real)0.01);
	m_Prop[PROP_EGG_SHAPE1].SetEnum(FilterEggShape);
	m_Prop[PROP_EGG_SHAPE1].SetToolID(ID_PROP_EGGSHAPE);

	m_Prop[PROP_EGG_SIZE1].SetName("Size1");
	m_Prop[PROP_EGG_SIZE1].SetValue((real)0.5);
	m_Prop[PROP_EGG_SIZE1].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_EGG_SHIFT1].SetName("Shift1");
	m_Prop[PROP_EGG_SHIFT1].SetValue((real)0.85);
	m_Prop[PROP_EGG_SHIFT1].SetMin(-50);
	m_Prop[PROP_EGG_SHIFT1].SetMax(50);
	m_Prop[PROP_EGG_SHIFT1].SetToolID(ID_PROP_EGGSHIFT);

	// pattern 2
	m_Prop[PROP_EGG_COL2].SetCategory(PCAT_COLOR);
	m_Prop[PROP_EGG_COL2].SetName("Color2");
	m_Prop[PROP_EGG_COL2].SetToolID(ID_PROP_SOURCE2);
	m_Prop[PROP_EGG_COL2].SetColorRGB(0x00FFFF);

	m_Prop[PROP_EGG_SHAPE2].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EGG_SHAPE2].SetName("Shape2");
	m_Prop[PROP_EGG_SHAPE2].SetValue((real)0.02);
	m_Prop[PROP_EGG_SHAPE2].SetEnum(FilterEggShape);
	m_Prop[PROP_EGG_SHAPE2].SetToolID(ID_PROP_EGGSHAPE);

	m_Prop[PROP_EGG_SIZE2].SetName("Size2");
	m_Prop[PROP_EGG_SIZE2].SetValue((real)0.5);
	m_Prop[PROP_EGG_SIZE2].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_EGG_SHIFT2].SetName("Shift2");
	m_Prop[PROP_EGG_SHIFT2].SetValue((real)0.75);
	m_Prop[PROP_EGG_SHIFT2].SetMin(-50);
	m_Prop[PROP_EGG_SHIFT2].SetMax(50);
	m_Prop[PROP_EGG_SHIFT2].SetToolID(ID_PROP_EGGSHIFT);

	// pattern 3
	m_Prop[PROP_EGG_COL3].SetCategory(PCAT_COLOR);
	m_Prop[PROP_EGG_COL3].SetName("Color3");
	m_Prop[PROP_EGG_COL3].SetToolID(ID_PROP_SOURCE3);
	m_Prop[PROP_EGG_COL3].SetColorRGB(0x00FF00);

	m_Prop[PROP_EGG_SHAPE3].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EGG_SHAPE3].SetName("Shape3");
	m_Prop[PROP_EGG_SHAPE3].SetValue((real)0.03);
	m_Prop[PROP_EGG_SHAPE3].SetEnum(FilterEggShape);
	m_Prop[PROP_EGG_SHAPE3].SetToolID(ID_PROP_EGGSHAPE);

	m_Prop[PROP_EGG_SIZE3].SetName("Size3");
	m_Prop[PROP_EGG_SIZE3].SetValue((real)0.5);
	m_Prop[PROP_EGG_SIZE3].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_EGG_SHIFT3].SetName("Shift3");
	m_Prop[PROP_EGG_SHIFT3].SetValue((real)0.65);
	m_Prop[PROP_EGG_SHIFT3].SetMin(-50);
	m_Prop[PROP_EGG_SHIFT3].SetMax(50);
	m_Prop[PROP_EGG_SHIFT3].SetToolID(ID_PROP_EGGSHIFT);

	// pattern 4
	m_Prop[PROP_EGG_COL4].SetCategory(PCAT_COLOR);
	m_Prop[PROP_EGG_COL4].SetName("Color4");
	m_Prop[PROP_EGG_COL4].SetToolID(ID_PROP_SOURCE4);
	m_Prop[PROP_EGG_COL4].SetColorRGB(0xFF0000);

	m_Prop[PROP_EGG_SHAPE4].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EGG_SHAPE4].SetName("Shape4");
	m_Prop[PROP_EGG_SHAPE4].SetValue((real)0.04);
	m_Prop[PROP_EGG_SHAPE4].SetEnum(FilterEggShape);
	m_Prop[PROP_EGG_SHAPE4].SetToolID(ID_PROP_EGGSHAPE);

	m_Prop[PROP_EGG_SIZE4].SetName("Size4");
	m_Prop[PROP_EGG_SIZE4].SetValue((real)0.5);
	m_Prop[PROP_EGG_SIZE4].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_EGG_SHIFT4].SetName("Shift4");
	m_Prop[PROP_EGG_SHIFT4].SetValue((real)0.55);
	m_Prop[PROP_EGG_SHIFT4].SetMin(-50);
	m_Prop[PROP_EGG_SHIFT4].SetMax(50);
	m_Prop[PROP_EGG_SHIFT4].SetToolID(ID_PROP_EGGSHIFT);

	// pattern 5
	m_Prop[PROP_EGG_COL5].SetCategory(PCAT_COLOR);
	m_Prop[PROP_EGG_COL5].SetName("Color5");
	m_Prop[PROP_EGG_COL5].SetToolID(ID_PROP_SOURCE5);
	m_Prop[PROP_EGG_COL5].SetColorRGB(0xFF00FF);

	m_Prop[PROP_EGG_SHAPE5].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EGG_SHAPE5].SetName("Shape5");
	m_Prop[PROP_EGG_SHAPE5].SetValue((real)0.05);
	m_Prop[PROP_EGG_SHAPE5].SetEnum(FilterEggShape);
	m_Prop[PROP_EGG_SHAPE5].SetToolID(ID_PROP_EGGSHAPE);

	m_Prop[PROP_EGG_SIZE5].SetName("Size5");
	m_Prop[PROP_EGG_SIZE5].SetValue((real)0.5);
	m_Prop[PROP_EGG_SIZE5].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_EGG_SHIFT5].SetName("Shift5");
	m_Prop[PROP_EGG_SHIFT5].SetValue((real)0.45);
	m_Prop[PROP_EGG_SHIFT5].SetMin(-50);
	m_Prop[PROP_EGG_SHIFT5].SetMax(50);
	m_Prop[PROP_EGG_SHIFT5].SetToolID(ID_PROP_EGGSHIFT);

	// pattern 6
	m_Prop[PROP_EGG_COL6].SetCategory(PCAT_COLOR);
	m_Prop[PROP_EGG_COL6].SetName("Color6");
	m_Prop[PROP_EGG_COL6].SetToolID(ID_PROP_SOURCE6);
	m_Prop[PROP_EGG_COL6].SetColorRGB(0xFFFF00);

	m_Prop[PROP_EGG_SHAPE6].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EGG_SHAPE6].SetName("Shape6");
	m_Prop[PROP_EGG_SHAPE6].SetValue((real)0.06);
	m_Prop[PROP_EGG_SHAPE6].SetEnum(FilterEggShape);
	m_Prop[PROP_EGG_SHAPE6].SetToolID(ID_PROP_EGGSHAPE);

	m_Prop[PROP_EGG_SIZE6].SetName("Size6");
	m_Prop[PROP_EGG_SIZE6].SetValue((real)0.5);
	m_Prop[PROP_EGG_SIZE6].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_EGG_SHIFT6].SetName("Shift6");
	m_Prop[PROP_EGG_SHIFT6].SetValue((real)0.35);
	m_Prop[PROP_EGG_SHIFT6].SetMin(-50);
	m_Prop[PROP_EGG_SHIFT6].SetMax(50);
	m_Prop[PROP_EGG_SHIFT6].SetToolID(ID_PROP_EGGSHIFT);

	// pattern 7
	m_Prop[PROP_EGG_COL7].SetCategory(PCAT_COLOR);
	m_Prop[PROP_EGG_COL7].SetName("Color7");
	m_Prop[PROP_EGG_COL7].SetToolID(ID_PROP_SOURCE7);
	m_Prop[PROP_EGG_COL7].SetColorRGB(0x006080);

	m_Prop[PROP_EGG_SHAPE7].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EGG_SHAPE7].SetName("Shape7");
	m_Prop[PROP_EGG_SHAPE7].SetValue((real)0.07);
	m_Prop[PROP_EGG_SHAPE7].SetEnum(FilterEggShape);
	m_Prop[PROP_EGG_SHAPE7].SetToolID(ID_PROP_EGGSHAPE);

	m_Prop[PROP_EGG_SIZE7].SetName("Size7");
	m_Prop[PROP_EGG_SIZE7].SetValue((real)0.5);
	m_Prop[PROP_EGG_SIZE7].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_EGG_SHIFT7].SetName("Shift7");
	m_Prop[PROP_EGG_SHIFT7].SetValue((real)0.25);
	m_Prop[PROP_EGG_SHIFT7].SetMin(-50);
	m_Prop[PROP_EGG_SHIFT7].SetMax(50);
	m_Prop[PROP_EGG_SHIFT7].SetToolID(ID_PROP_EGGSHIFT);

	// pattern 8
	m_Prop[PROP_EGG_COL8].SetCategory(PCAT_COLOR);
	m_Prop[PROP_EGG_COL8].SetName("Color8");
	m_Prop[PROP_EGG_COL8].SetToolID(ID_PROP_SOURCE8);
	m_Prop[PROP_EGG_COL8].SetColorRGB(0xFFA060);

	m_Prop[PROP_EGG_SHAPE8].SetCategory(PCAT_ENUM);
	m_Prop[PROP_EGG_SHAPE8].SetName("Shape8");
	m_Prop[PROP_EGG_SHAPE8].SetValue((real)0.08);
	m_Prop[PROP_EGG_SHAPE8].SetEnum(FilterEggShape);
	m_Prop[PROP_EGG_SHAPE8].SetToolID(ID_PROP_EGGSHAPE);

	m_Prop[PROP_EGG_SIZE8].SetName("Size8");
	m_Prop[PROP_EGG_SIZE8].SetValue((real)0.5);
	m_Prop[PROP_EGG_SIZE8].SetToolID(ID_PROP_EGGSIZE);

	m_Prop[PROP_EGG_SHIFT8].SetName("Shift8");
	m_Prop[PROP_EGG_SHIFT8].SetValue((real)0.15);
	m_Prop[PROP_EGG_SHIFT8].SetMin(-50);
	m_Prop[PROP_EGG_SHIFT8].SetMax(50);
	m_Prop[PROP_EGG_SHIFT8].SetToolID(ID_PROP_EGGSHIFT);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterEaster::RenderCol(CColor* col, real x, real y)
{
	// tiles
	if (x >= 1) x -= (int)x;
	if (x < 0) x += (int)(1 - x);
	real x2 = x;

	// symmetric
	real y2 = CLAMP(y);
	BOOL sym = (m_Prop[PROP_EGG_MIRROR].RenderVal(x, y) >= (real)0.5);
	if (sym)
	{
		y2 = y2 * 2 - 1;
		if (y2 < 0) y2 = -y2;
	}

	// render background
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);

	// render patterns
	//real k;
	CColor c;
	int i;
	for (i = 0; i < 4*8; i += 4)
	{
		real x3 = x2;
		real y3 = y2;

		// get shape
		int shape = (int)(m_Prop[PROP_EGG_SHAPE1 + i].RenderVal(x, y)*100 + (real)0.5);
		if (shape > 0)
		{
			// shift
			y3 -= m_Prop[PROP_EGG_SHIFT1 + i].RenderVal(x, y);
			if (sym) y3 /= 2;

			// scale
			int sizeN = (int)((m_Prop[PROP_EGG_SIZE1 + i].RenderVal(x, y)+1)*100 + 0.5); // 0..200
			int sizeX = 1;
			real w = (real)0.1;
			real sizeY;
			if (shape > 1)
			{
				sizeN--;
				if (sizeN < 0) sizeN = 0;
				if (sizeN > 199) sizeN = 199;

				sizeX = 20 - sizeN/10;
				sizeY = (real)sizeN*sizeN/(200*200*pow((real)2, (7 - (sizeN % 5))*(real)0.5));

				switch (shape)
				{
				// wave 1, zigzag 1
				case 2:
				case 17:
					w = (real)0.1;
					break;

				// wave 2, zigzag 2
				case 3:
				case 18:
					w = (real)0.3;
					break;

				// wave 3, zigzag 3
				case 4:
				case 19:
					w = (real)0.6;
					break;

				// ring 1, 2, 3
				case 14: w = (real)0.2; break;
				case 15: w = (real)0.6; break;
				case 16: w = 1; break;

				// box 1, 2, 3
				case 31: w = (real)0.1; break;
				case 32: w = (real)0.25; break;
				case 33: w = (real)0.4; break;

				// crenelation 1, 2, 3
				case 34: w = (real)0.1; break;
				case 35: w = (real)0.25; break;
				case 36: w = (real)0.5; break;

				// droplet
				case 40:
				case 41: w = (real)1.75; break;
				case 48:
				case 49:
				case 42:
				case 43: w = 4; break;

				// droplet 2
				case 44:
				case 45: w = (real)3.2; break;
				case 46:
				case 47: w = 6; break;
				}
				x3 *= sizeX;

				switch (shape)
				{
				// wave
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
					x3 += (real)0.25;
					break;

				case 1:
					break;

				default:
					x3 += (real)0.5;
				}

				// down
				switch (shape)
				{
				case 6:
				case 9:
				case 12:
				case 21:
				case 24:
				case 26:
				case 28:
				case 30:
				case 38:
				case 40:
				case 42:
				case 44:
				case 46:
				case 48:
					y3 = -y3;
				}

				// odd
				if (((sizeN/5) & 1) != 0) x3 += (real)0.5;

				if (x3 >= 1) x3 -= (int)x3;
				if (x3 < 0) x3 += (int)(1 - x3);
			}
			else
				sizeY = (sizeN-100)*(real)0.01;

			sizeY = CLAMP(sizeY);
			sizeY += (real)0.0000001;
			y3 /= sizeY;

			// draw shape
			if ((y3 >= -(real)0.5) && (y3 < (real)0.5))
			{
				BOOL cc = FALSE;
				int n;
				real d, a, dx, da, sx, r;
				switch (shape)
				{
				// line
				case 1:
					cc = TRUE;
					break;

				// wave 1, 2, 3
				case 2:
				case 3:
				case 4:
					sx = ((real)0.5 - w/2)*sin(x3*PI2);
					cc = ((y3 >= sx-(real)w/2) && (y3 < sx+(real)w/2));
					break;

				// wave up, down
				case 5:
				case 6:
					sx = (real)0.4*sin(x3*PI2) + (real)0.1;
					cc = (y3 < sx);
					break;

				// wave double
				case 7:
					sx = (real)0.2*sin(x3*PI2);
					cc = ((y3 >= - sx - (real)0.3) && (y3 < sx + (real)0.3));
					break;

				// ripple up, down
				case 8:
				case 9:
					cc = ((y3 <= -0.4) || ((sqr((y3 + (real)0.4)/(real)0.9) + sqr((x3 - (real)0.5)/(real)0.5)) <= 1));
					break;

				// ripple double
				case 10:
					cc = (((y3 >= (real)-0.1) && (y3 <= (real)0.1)) ||
						((sqr((y3 + (real)0.1)/(real)0.4) + sqr((x3 - (real)0.5)/(real)0.5)) <= 1) ||
						((sqr((y3 - (real)0.1)/(real)0.4) + sqr((x3 - (real)0.5)/(real)0.5)) <= 1));
					break;

				// moon up, down
				case 11:
				case 12:
					cc = ((sqr(y3 + (real)0.5) + sqr((x3 - (real)0.5)/(real)0.5)) <= 1) && ((sqr((y3 + (real)0.5)*2) + sqr((x3 - (real)0.5)/(real)0.5)) >= 1);
					break;

				// point
				case 13:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;
					cc = (sqr(y3*4) + sqr(x3*4)) <= 1;
					break;

				// ring
				case 14:
				case 15:
				case 16:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;
					cc = ((sqr(y3*(3-w)) + sqr(x3*(3-w))) <= 1) && ((sqr(y3*(3+w)) + sqr(x3*(3+w))) >= 1);
					break;

				// zigzag 1, 2, 3
				case 17:
				case 18:
				case 19:
					x3 = ((1 - ((x3 >= (real)0.5) ? (x3 - (real)0.5) : ((real)0.5 - x3))/(real)0.5) - (real)0.5)*(1 - w);
					cc = (y3 <= (x3 + w/2)) && (y3 >= (x3 - w/2));
					break;

				// zigzag up, down
				case 20:
				case 21:
					x3 = ((1 - ((x3 >= (real)0.5) ? (x3 - (real)0.5) : ((real)0.5 - x3))/(real)0.5) - (real)0.5);
					cc = (y3 <= x3);
					break;

				// zigzag doouble
				case 22:
					x3 = (1 - ((x3 >= (real)0.5) ? (x3 - (real)0.5) : ((real)0.5 - x3))/(real)0.5)*(real)0.5;
					cc = (y3 >= -x3) && (y3 <= x3);
					break;

				// heart up, down
				case 23:
				case 24:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;
					x3 *= 1.25;
					y3 *= 1.25;
					d = sqrt(sqr(x3) + sqr(y3));
					a = atan2(y3, x3);
					if (a < 0) a += PI2;
					a = a / PI2 * HEARTSHAPEN;
					n = (int)a;
					if (n > HEARTSHAPEN-1) n = HEARTSHAPEN-1;
					a -= n;
					r = HeartShape[n]*(1-a) + HeartShape[n+1]*a;
					cc = (d <= r);
					break;

				// triangle up, down
				case 25:
				case 26:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;
					x3 *= 4;
					y3 *= 2;
					cc = y3 < ((x3 >= 0) ? (1 - x3) : (x3 + 1));
					break;

				// sun
				case 39:
					n = 32;
					w = (real)0.7;
					goto VIEWSTAR;

				// star up, down
				case 27:
				case 28:
					n = 5;
					w = (real)0.4;
VIEWSTAR:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;
					x3 *= 2;
					y3 *= 2;
					d = sqr(x3) + sqr(y3);
					if (d <= 1)
					{
						a = atan2(-x3, y3);
						if (a < 0) a += PI2;
						da = PI2/n;
						a /= da;
						n = (int)a;
						a -= n;

						// edge
						real xx1, xx2, yy1, yy2;
						if (a < (real)0.5)
						{
							xx1 = -sin(n*da);
							yy1 = cos(n*da);
							xx2 = -w*sin(n*da+da/2);
							yy2 = w*cos(n*da+da/2);
						}
						else
						{
							xx1 = -w*sin(n*da+da/2);
							yy1 = w*cos(n*da+da/2);
							xx2 = -sin(n*da+da);
							yy2 = cos(n*da+da);
						}

						// detect intersection with edge
						//   edge line: y = (x - xx1)/(xx2 - xx1)*(yy2 - yy1) + yy1
						//   point line: y = x/x3*y3
						//   intersection: x/x3*y3 = (x - xx1)/(xx2 - xx1)*(yy2 - yy1) + yy1
						// or:
						//   edge line: x = (y - yy1)/(yy2 - yy1)*(xx2 - xx1) + xx1
						//   point line: x = y/y3*x3
						//   intersection: y/y3*x3 = (y - yy1)/(yy2 - yy1)*(xx2 - xx1) + xx1
						real xs, ys;
						if ((abs(x3) > (real)0.00001) && (abs(xx2 - xx1) > (real)0.00001) && (abs(y3/x3 + (yy1 - yy2)/(xx2 - xx1)) > (real)0.00001))
						{
							xs = (xx2*yy1 - xx1*yy2)/((yy1 - yy2) + y3/x3*(xx2 - xx1));
							ys = xs/x3*y3;
						}
						else
						{
							ys = (xx1*yy2 - xx2*yy1)/(x3/y3*(yy2 - yy1) + (xx1 - xx2));
							xs = ys/y3*x3;
						}
						cc = (d <= (xs*xs + ys*ys));
					}
					break;

				// egg
				case 29:
				case 30:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;
					x3 *= (real)1.5 + y3*(real)0.6;
					cc = (sqr(y3*2) + sqr(x3*2)) <= 1;
					break;

				// box
				case 31:
				case 32:
				case 33:
					cc = (x3 > (real)0.5 - w) && (x3 < (real)0.5 + w);
					break;

				// crenelation 1, 2, 3
				case 34:
				case 35:
				case 36:
					if ((y3 >= -w*(real)0.5 - (real)0.3) && (y3 <= (real)0.3 + w*(real)0.5))
					{
						cc = (((x3 <= (real)0.25) || (x3 >= (real)0.75)) && (y3 < w*(real)0.5 - (real)0.3)) ||
							((x3 >= (real)0.25) && (x3 <= (real)0.75) && (y3 > (real)0.3 - w*(real)0.5)) ||
							((x3 >= (real)0.25 - w*(real)0.35) && (x3 <= (real)0.25 + w*(real)0.35)) ||
							((x3 >= (real)0.75 - w*(real)0.35) && (x3 <= (real)0.75 + w*(real)0.35));
					}
					break;

				// crenelation up, down
				case 37:
				case 38:
					cc = (y3 < 0) || ((x3 >= (real)0.25) && (x3 < (real)0.75));
					break;

				// droplet 1 up, down
				case 40:
				case 41:
				case 42:
				case 43:
				case 48:
				case 49:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;
					x3 *= w;
					d = sqrt(sqr(x3) + sqr(y3));
					a = atan2(y3, x3);
					if (a < 0) a += PI2;
					a = a / PI2 * DROPLETSHAPEN;
					n = (int)a;
					if (n > DROPLETSHAPEN-1) n = DROPLETSHAPEN-1;
					a -= n;
					r = DropletShape[n]*(1-a) + DropletShape[n+1]*a;
					cc = (d <= r);

					if (!cc && ((shape == 48) || (shape == 49)))
					{
						x3 /= w;
						a = (real)-0.3;
						dx = (real)0.25;
						r = (real)1.2;
						goto DRAWDROP3;
					}
					break;

				// droplet 2 up, down
				case 44:
				case 45:
				case 46:
				case 47:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;

					a = (real)-0.55;
					dx = (real)0.16;
					r = (real)1.6;
DRAWDROP3:
					if (x3 > 0)
						x3 -= dx;
					else
					{
						x3 += dx;
						a = -a;
					}

					sx = x3*cos(a) - y3*sin(a);
					y3 = y3*cos(a) + x3*sin(a);
					x3 = sx;

					x3 *= w;
					y3 *= r;

					d = sqrt(sqr(x3) + sqr(y3));
					a = atan2(y3, x3);
					if (a < 0) a += PI2;
					a = a / PI2 * DROPLETSHAPEN;
					n = (int)a;
					if (n > DROPLETSHAPEN-1) n = DROPLETSHAPEN-1;
					a -= n;
					r = DropletShape[n]*(1-a) + DropletShape[n+1]*a;
					cc = (d <= r);
					break;

				// flower
				case 50:
				case 51:
				case 52:
					x3 -= (real)0.5;
					x3 /= sizeX;
					x3 /= sizeY;
					d = sqrt(sqr(x3) + sqr(y3));
					if (d < (real)0.15)
					{
						if (shape == 51) break;
						if (shape == 52)
						{
							m_Prop[PROP_EGG_COL1 + i].RenderCol(col, x, y);
							col->g = 1 - col->g;
							break;
						}
					}
					a = atan2(-x3, y3);
					if (a < 0) a += PI2;
					a = a / PI2 * 6;
					n = (int)a;
					a -= n;
					a -= (real)0.5;
					a *= PI2/6;
					x3 = -d*sin(a)*(real)3.3;
					y3 = ((real)0.24 - d*cos(a))*(real)2.4;
					d = sqrt(sqr(x3) + sqr(y3));
					a = atan2(y3, x3);
					if (a < 0) a += PI2;

					a = a / PI2 * DROPLETSHAPEN;
					n = (int)a;
					if (n > DROPLETSHAPEN-1) n = DROPLETSHAPEN-1;
					a -= n;
					r = DropletShape[n]*(1-a) + DropletShape[n+1]*a;
					cc = (d <= r);
					break;
				}

				if (cc) m_Prop[PROP_EGG_COL1 + i].RenderCol(col, x, y);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterEaster::RenderVal(real x, real y)
{
	CColor col;
	CFilterEaster::RenderCol(&col, x, y);
	return col.Gray();
}
