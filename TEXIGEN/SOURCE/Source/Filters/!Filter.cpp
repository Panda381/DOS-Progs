
///////////////////////////////////////////////////////////////////////////////
//
//                              Base Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// filter template list
CFilter*		Template[TEMPLATENUM];
int			TemplateNum = 0;

// filter base image list
SCanvas*		FilterImageList[TEMPLATENUM];

// group list (0=all filters)
int			GroupNum[FGRP_NUM+1];			// number of filters in groups
CFilter*		GroupFilters[FGRP_NUM+1][TEMPLATENUM];	// group filters (Y=position in group image)
int			GroupFiltersY[FGRP_NUM+1][TEMPLATENUM];	// group filters Y position (from top) in group list
int			GroupFiltersH[FGRP_NUM+1][TEMPLATENUM];	// group filters height in group list
SCanvas*		GroupImageList[FGRP_NUM+1];	// group images
BITMAPINFO	GroupImageBMP[FGRP_NUM+1];	// group images bitmap info
int			GroupFiltersTop[FGRP_NUM+1];	// top of group filters

///////////////////////////////////////////////////////////////////////////////
// create filter base image

SCanvas* CreateFilterBase(CFilter* f)
{
	// filter width and height
	int w = f->BaseW();
	int h = f->BaseH();

	// create canvas
	SCanvas* dst = NewCanvas(w, h + FILTERTH);
	if (dst == NULL) return NULL;

	// title
	u32 c = FiltCol[(int)f->Category()];
	DrawRect(dst, 1, h, w - 2, FILTERTH - 1, c);
	DrawText(dst, f->Class(), 10, h + 1, FILTERTFG);

	// body
	if (f->Category() != FCAT_PIN)
		DrawRect(dst, 1, 1, w - 2, h - 1, FILTERBG);
	else
		// pin input arrow
		DrawArrow(dst, 1, FILTERTH - 13, FILTERIMGCOL);

	// frame
	DrawFrame(dst, 0, 0, w, h + FILTERTH, FILTERF);

	// value filter frame
	if (f->Category() == FCAT_INVALUE)
		DrawFrame(dst, w - FPREVWH - GRID, h - 3*GRID, FPREVWH, 2*GRID, FILTERVFCOL);

	// properties
	if (f->Category() != FCAT_PIN)
	{
		int i;
		CProperty* p;
		int y;
		for (i = 0; i < f->PropNum(); i++)
		{
			// property name
			p = f->Prop(i);
			y = h - i*FILTERDY - 13;
			if ((f->Category() == FCAT_OUT) ||
				(f->Category() == FCAT_TABLE) ||
				(f->Category() == FCAT_BRICK))
				y -= FILTERDY;
			DrawText(dst, p->Name(), 10, y, FILTERFG);

			// input arrow
			DrawArrow(dst, 1, y + 1, PropCol[(int)p->Category()]);
		}
	}
	return dst;
}

///////////////////////////////////////////////////////////////////////////////
// fill up filter template list

#define TEMPADD(x) Template[TemplateNum++] = new x

void TempFillUp()
{
	TemplateNum = 0;

	// create templates

	// group: color
	TEMPADD(CFilterLevel);
	TEMPADD(CFilterRecolor);
	TEMPADD(CFilterBright);
	TEMPADD(CFilterThreshold);
	TEMPADD(CFilterColorize);
	TEMPADD(CFilterDecolorize);
	TEMPADD(CFilterAmplifier);
	TEMPADD(CFilterRed);
	TEMPADD(CFilterGreen);
	TEMPADD(CFilterBlue);
	TEMPADD(CFilterAlpha);
	TEMPADD(CFilterSetAlpha);
	TEMPADD(CFilterRGB);
	TEMPADD(CFilterHue);
	TEMPADD(CFilterSaturation);
	TEMPADD(CFilterLuminance);
	TEMPADD(CFilterHSL);
	TEMPADD(CFilterColorizeChan);
	TEMPADD(CFilterMixer);

	// group: mathematics
	TEMPADD(CFilterInvert);
	TEMPADD(CFilterAdd);
	TEMPADD(CFilterSub);
	TEMPADD(CFilterSubInv);
	TEMPADD(CFilterMul);
	TEMPADD(CFilterDiv);
	TEMPADD(CFilterDivInv);
	TEMPADD(CFilterClamp);
	TEMPADD(CFilterInterval);
	TEMPADD(CFilterAbs);
	TEMPADD(CFilterNegate);
	TEMPADD(CFilterSqr);
	TEMPADD(CFilterSqrt);
	TEMPADD(CFilterGranularity);
	TEMPADD(CFilterMod);
	TEMPADD(CFilterPow);
	TEMPADD(CFilterSin);
	TEMPADD(CFilterCos);
	TEMPADD(CFilterLog);
	TEMPADD(CFilterExp);
	TEMPADD(CFilterRandom);

	// group: combinations
	TEMPADD(CFilterBlend);
	TEMPADD(CFilterSwitch2);
	TEMPADD(CFilterSwitch3);
	TEMPADD(CFilterSwitch4);
	TEMPADD(CFilterSwitch5);
	TEMPADD(CFilterSwitch6);
	TEMPADD(CFilterSwitch7);
	TEMPADD(CFilterSwitch8);
	TEMPADD(CFilterSwitch9);
	TEMPADD(CFilterSwitch10);
	TEMPADD(CFilterThreshold2);
	TEMPADD(CFilterThreshold3);
	TEMPADD(CFilterThreshold4);
	TEMPADD(CFilterThreshold5);
	TEMPADD(CFilterThreshold6);
	TEMPADD(CFilterThreshold7);
	TEMPADD(CFilterThreshold8);
	TEMPADD(CFilterThreshold9);
	TEMPADD(CFilterThreshold10);
	TEMPADD(CFilterInject);
	TEMPADD(CFilterCut);
	TEMPADD(CFilterSwitchChan);
	TEMPADD(CFilterDuo);
	TEMPADD(CFilterTrio);
	TEMPADD(CFilterQuattro);
	TEMPADD(CFilterDiaQuattro);
	TEMPADD(CFilterHexo);
	TEMPADD(CFilterOcto);
	TEMPADD(CFilterNano);

	// group: transformations
	TEMPADD(CFilterShift);
	TEMPADD(CFilterScale);
	TEMPADD(CFilterRotate);
	TEMPADD(CFilterRotate90);
	TEMPADD(CFilterRotate180);
	TEMPADD(CFilterRotate270);
	TEMPADD(CFilterDiagonal);
	TEMPADD(CFilterDiagonal2);
	TEMPADD(CFilterSeamlessRotate);
	TEMPADD(CFilterTileX);
	TEMPADD(CFilterTileY);
	TEMPADD(CFilterTile);
	TEMPADD(CFilterFlipX);
	TEMPADD(CFilterFlipY);
	TEMPADD(CFilterMirrorX);
	TEMPADD(CFilterMirrorY);
	TEMPADD(CFilterMirror);
	TEMPADD(CFilterShearX);
	TEMPADD(CFilterShearY);
	TEMPADD(CFilterLookup);
	TEMPADD(CFilterSeamless);

	// group: patterns
	TEMPADD(CFilterPerlin);
	TEMPADD(CFilterCellular);
	TEMPADD(CFilterParticle);
	TEMPADD(CFilterBox);
	TEMPADD(CFilterRound);
	TEMPADD(CFilterStar);
	TEMPADD(CFilterBrick);
	TEMPADD(CFilterPaving);
	TEMPADD(CFilterFloor);
	TEMPADD(CFilterHexacomb);
	TEMPADD(CFilterCheck);
	TEMPADD(CFilterCheckSolid);
	TEMPADD(CFilterRhomb);
	TEMPADD(CFilterRhombSolid);
	TEMPADD(CFilterMosaic);
	TEMPADD(CFilterShape);
	TEMPADD(CFilterTriangle);
	TEMPADD(CFilterSpade);
	TEMPADD(CFilterHeart);
	TEMPADD(CFilterDiamond);
	TEMPADD(CFilterClub);
	TEMPADD(CFilterDroplet);
	TEMPADD(CFilterJinJang);
	TEMPADD(CFilterRose);
	TEMPADD(CFilterDandelion);
	TEMPADD(CFilterBlade);
	TEMPADD(CFilterTussock);
	TEMPADD(CFilterSewingButton);
	TEMPADD(CFilterClip);
	TEMPADD(CFilterDollar);
	TEMPADD(CFilterSnowflake);
	TEMPADD(CFilterCard);
	TEMPADD(CFilterEaster);
	TEMPADD(CFilterFractal);
	TEMPADD(CFilterParticleX);
	TEMPADD(CFilterParticleY);
	TEMPADD(CFilterParticleRnd);

	// group: materials
	TEMPADD(CFilterMaterial);
	TEMPADD(CFilterWood);
	TEMPADD(CFilterMetal);
	TEMPADD(CFilterGlass);
	TEMPADD(CFilterMalachite);
	TEMPADD(CFilterMarble);
	TEMPADD(CFilterGranite);
	TEMPADD(CFilterCracks);
	TEMPADD(CFilterFabric);

	// group: curves
	TEMPADD(CFilterLinear);
	TEMPADD(CFilterSquare);
	TEMPADD(CFilterSquareRoot);
	TEMPADD(CFilterArc);
	TEMPADD(CFilterInvArc);
	TEMPADD(CFilterPower);
	TEMPADD(CFilterGaussian);
	TEMPADD(CFilterBias);
	TEMPADD(CFilterGain);
	TEMPADD(CFilterImpulse);
	TEMPADD(CFilterBezier2);
	TEMPADD(CFilterBezier3);
	TEMPADD(CFilterStairs);
	TEMPADD(CFilterNoise);
	TEMPADD(CFilterWave);
	TEMPADD(CFilterSaw);
	TEMPADD(CFilterRectangle);
	TEMPADD(CFilterCity);
	TEMPADD(CFilterTable);

	// group: gradients
	TEMPADD(CFilterGradient2);
	TEMPADD(CFilterGradient3);
	TEMPADD(CFilterGradient4);
	TEMPADD(CFilterGradient5);
	TEMPADD(CFilterGradient6);
	TEMPADD(CFilterGradient7);
	TEMPADD(CFilterGradient8);
	TEMPADD(CFilterGradient9);
	TEMPADD(CFilterGradient10);
	TEMPADD(CFilterRadial);
	TEMPADD(CFilterAngular);
	TEMPADD(CFilterColorNoise);
	TEMPADD(CFilterSpectrum);
	TEMPADD(CFilterThermo);

	// group: processing
	TEMPADD(CFilterEmboss);
	TEMPADD(CFilterSmooth);
	TEMPADD(CFilterBlur);
	TEMPADD(CFilterHighPass);
	TEMPADD(CFilterPercentile);
	TEMPADD(CFilterNormal);
	TEMPADD(CFilterContour);

	// group: deformations
	TEMPADD(CFilterWarp);
	TEMPADD(CFilterTaper);
	TEMPADD(CFilterLens);
	TEMPADD(CFilterPolar);
	TEMPADD(CFilterCartes);
	TEMPADD(CFilterKaleidoscope);
	TEMPADD(CFilterDeform);
	TEMPADD(CFilterEnform);

	// group: inputs/outputs
	TEMPADD(CFilterOut);
	TEMPADD(CFilterValue);
	TEMPADD(CFilterColor);
	TEMPADD(CFilterImage);
	TEMPADD(CFilterImageData);
	TEMPADD(CFilterVideo);

	// group: support
	TEMPADD(CFilterPin);
	TEMPADD(CFilterLoopBegin);
	TEMPADD(CFilterLoopIndex);
	TEMPADD(CFilterLoopEnd);
	TEMPADD(CFilterTime);
	TEMPADD(CFilterTimeDelta);
	TEMPADD(CFilterX);
	TEMPADD(CFilterY);
	TEMPADD(CFilterDX);
	TEMPADD(CFilterDY);
	TEMPADD(CFilterGraph);
	TEMPADD(CFilterHistogram);
	TEMPADD(CFilterHistogramRGB);

	// load preview images
	int i;
	CFilter* f;
	CText txt;
	for (i = 0; i < TemplateNum; i++)
	{
		f = Template[i];
		memset(f->Preview()->d, 0xc0, FPREVWH*FPREVWH*3);
		txt = _T("F") + f->Class();
		HRSRC res = ::FindResource(Instance, txt, "PREVIEW");
		if (res != NULL)
		{
			HGLOBAL glob = ::LoadResource(Instance, res);
			if (glob != NULL)
			{
				u8* a = (u8*)::LockResource(glob);
				if (a != NULL) memcpy(f->Preview()->d, a + TGAHEADSIZE, FPREVWH*FPREVWH*3);
			}
		}
	}

	// create filter base images
	SCanvas* c;
	for (i = 0; i < TemplateNum; i++)
	{
		f = Template[i];
		f->InitBaseH();
		c = CreateFilterBase(f);
		FilterImageList[i] = c;
		f->SetImage(c);
	}

	// clear group lists
	int gh[FGRP_NUM+1];
	for (i = 0; i < FGRP_NUM+1; i++)
	{
		GroupNum[i] = 0;
		GroupFiltersTop[i] = 0;
		gh[i] = 0;
	}

	// create group lists
	int g, n;
	for (i = 0; i < TemplateNum; i++)
	{
		f = Template[i]; 
		c = f->Image();
		g = (int)f->Group();
		GroupFilters[g+1][GroupNum[g+1]++] = f;
		GroupFilters[0][GroupNum[0]++] = f;
	}

	// sort filters by name in group All
	for (i = 0; i < GroupNum[0]-1; i++)
	{
		f = GroupFilters[0][i];
		if (f->Class() > GroupFilters[0][i+1]->Class())
		{
			GroupFilters[0][i] = GroupFilters[0][i+1];
			GroupFilters[0][i+1] = f;
			i = -1;
		}
	}

	// set Y in group lists
	for (g = 0; g <= FGRP_NUM; g++)
	{
		for (i = 0; i < GroupNum[g]; i++)
		{
			f = GroupFilters[g][i]; 
			c = f->Image();
			GroupFiltersY[g][i] = gh[g];
			GroupFiltersH[g][i] = c->h + FGRPGAP;
			gh[g] += c->h + FGRPGAP;
		}
	}

	// create filter base images
	BITMAPINFO* b;
	for (i = 0; i < FGRP_NUM+1; i++)
	{
		c = NewCanvas(FGRPW, gh[i]);
		DrawRect(c, 0, 0, FGRPW, gh[i], FGRPBG);
		GroupImageList[i] = c;
		b = &GroupImageBMP[i];
		memset(b, 0, sizeof(BITMAPINFO));
		b->bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
		b->bmiHeader.biHeight = gh[i];
		b->bmiHeader.biWidth = FGRPW;
		b->bmiHeader.biPlanes = 1;
		b->bmiHeader.biBitCount = 24;
		b->bmiHeader.biCompression = BI_RGB;
		gh[i] = 0;
	}

	// draw filter base images
	int y;
	for (g = 0; g <= FGRP_NUM; g++)
	{
		for (i = 0; i < GroupNum[g]; i++)
		{
			f = GroupFilters[g][i]; 
			n = GroupFiltersY[g][i];
			c = GroupImageList[g];
			y = c->h - (n + FGRPGAP/2) - f->Image()->h;
			DrawImage(c, f->Image(), FGRPGAP/2, y);
			if ((f->Category() != FCAT_INVALUE) && (f->Category() != FCAT_PIN))
			{
				if (f->Category() == FCAT_INCOLOR)
					DrawImage(c, f->Preview(), FGRPGAP/2 + f->BaseW() - FPREVWH - GRID,
						y + f->Image()->h - FILTERTH - 3*GRID + 1, 2*GRID); 
				else
					DrawImage(c, f->Preview(), FGRPGAP/2 + f->BaseW() - FPREVWH - GRID,
						y + f->Image()->h - FILTERTH - FPREVWH - GRID + 1); 
			}
		}
	}

	// save filters to files F(class).tga
#if 0  // set 1=write to files, 0=exclude from code
	TGAHEADER tga;
	for (i = 0; i < GroupNum[0]; i++)
	{
		f = GroupFilters[0][i];
		SCanvas* img = f->Image();
		int w = img->w;
		int h = img->h;
		SCanvas* c = NewCanvas(w, h);
		u8* s = c->d;
		memcpy(s, img->d, w*h*3);

		if ((f->Category() != FCAT_INVALUE) && (f->Category() != FCAT_PIN))
		{
			if (f->Category() == FCAT_INCOLOR)
				DrawImage(c, f->Preview(), f->BaseW() - FPREVWH - GRID,
					f->Image()->h - FILTERTH - 3*GRID + 1, 2*GRID); 
			else
				DrawImage(c, f->Preview(), f->BaseW() - FPREVWH - GRID,
					f->Image()->h - FILTERTH - FPREVWH - GRID + 1); 
		}

		txt = _T("F") + f->Class() + _T(".tga");

		FILE* file = _tfopen((LPCTSTR)txt, _T("wb"));
		if (file != NULL)
		{
			memset(&tga, 0, sizeof(TGAHEADER));
			tga.DataTypeCode = 2;
			tga.Width = (WORD)w;
			tga.Height = (WORD)h;
			tga.BitsPerPixel = 24;
			fwrite(&tga, 1, sizeof(TGAHEADER), file);
			fwrite(s, 1, w*h*3, file);
			fclose(file);
		}
		free(c);
	}
#endif
}

///////////////////////////////////////////////////////////////////////////////
// constructors

CFilter::CFilter()
{
	m_Category = FCAT_IMG;
	m_Group = FGRP_COL;
	m_Class = _T("");
	m_HelpID = HELP_FILTERS;
	m_X = 0;
	m_Y = 0;
	m_PropNum = 0;
	m_Image = NULL;
	Preview()->h = FPREVWH;
	Preview()->w = FPREVWH;
	m_ReqPrev = TRUE;
	m_Restart = TRUE;
	m_Selected = FALSE;
	m_BaseH = FILTERH;
	m_BaseW = FILTERW;
	m_BaseOutY = (FILTERH + FILTERTH)/2;
	int i;
	for (i = 0; i < MAXPROP; i++) m_Prop[i].SetParent(this);
}

///////////////////////////////////////////////////////////////////////////////
// initialize filter base height

void CFilter::InitBaseH()
{
	m_BaseW = FILTERW;
	if (m_Category == FCAT_PIN)
	{
		m_BaseH = 0;
		m_BaseW = FILTERPINW;
	}
	else if ((m_Category == FCAT_INVALUE) || (m_Category == FCAT_INCOLOR))
	{
		m_BaseH = FILTERVALH;
	}
	else
	{
		m_BaseH = FILTERDY * m_PropNum;
		if ((this->Category() == FCAT_BRICK) ||
			(this->Category() == FCAT_TABLE) ||
			(this->Category() == FCAT_OUT)) 
			m_BaseH += FILTERDY;
		if (m_BaseH < FILTERH) m_BaseH = FILTERH;
	}
	m_BaseOutY = (m_BaseH + FILTERTH)/2;
}

///////////////////////////////////////////////////////////////////////////////
// filter input pic Y cooordinate

int CFilter::PropY(int inx) const
{
	int y = m_Y;
	if (m_Category == FCAT_PIN)
		y += FILTERTH/2;
	else
	{
		y += BaseH() - inx*FILTERDY - FILTERDY/2;
		if ((m_Category == FCAT_OUT) ||
			(m_Category == FCAT_TABLE) ||
			(m_Category == FCAT_BRICK))
			y -= FILTERDY;
	}
	return y;
}

CFilterSource::CFilterSource()
{
	m_Class = _T("Source");
	m_PropNum = 1;
	
	m_Prop[PROP_SOURCE].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE].SetName("Source");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_SOURCE);
}

CFilterPin::CFilterPin()
{
	m_Group = FGRP_DEBUG;
	m_Class = _T("Pin");
	m_Category = FCAT_PIN;
	m_HelpID = HELP_FPIN;
}

CFilterSource2::CFilterSource2()
{
	m_Class = _T("Source2");
	m_PropNum = 2;
	
	m_Prop[PROP_SOURCE2].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE2].SetName("Source2");
	m_Prop[PROP_SOURCE2].SetToolID(ID_PROP_SOURCE2);
}

CFilterSource3::CFilterSource3()
{
	m_Class = _T("Source3");
	m_PropNum = 3;
	
	m_Prop[PROP_SOURCE3].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE3].SetName("Source3");
	m_Prop[PROP_SOURCE3].SetToolID(ID_PROP_SOURCE3);
}

CFilterSource4::CFilterSource4()
{
	m_Class = _T("Source4");
	m_PropNum = 4;
	
	m_Prop[PROP_SOURCE4].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE4].SetName("Source4");
	m_Prop[PROP_SOURCE4].SetToolID(ID_PROP_SOURCE4);
}

CFilterSource5::CFilterSource5()
{
	m_Class = _T("Source5");
	m_PropNum = 5;
	
	m_Prop[PROP_SOURCE5].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE5].SetName("Source5");
	m_Prop[PROP_SOURCE5].SetToolID(ID_PROP_SOURCE5);
}

CFilterSource6::CFilterSource6()
{
	m_Class = _T("Source6");
	m_PropNum = 6;
	
	m_Prop[PROP_SOURCE6].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE6].SetName("Source6");
	m_Prop[PROP_SOURCE6].SetToolID(ID_PROP_SOURCE6);
}

CFilterSource7::CFilterSource7()
{
	m_Class = _T("Source7");
	m_PropNum = 7;
	
	m_Prop[PROP_SOURCE7].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE7].SetName("Source7");
	m_Prop[PROP_SOURCE7].SetToolID(ID_PROP_SOURCE7);
}

CFilterSource8::CFilterSource8()
{
	m_Class = _T("Source8");
	m_PropNum = 8;
	
	m_Prop[PROP_SOURCE8].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE8].SetName("Source8");
	m_Prop[PROP_SOURCE8].SetToolID(ID_PROP_SOURCE8);
}

CFilterSource9::CFilterSource9()
{
	m_Class = _T("Source9");
	m_PropNum = 9;
	
	m_Prop[PROP_SOURCE9].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE9].SetName("Source9");
	m_Prop[PROP_SOURCE9].SetToolID(ID_PROP_SOURCE9);
}

CFilterSource10::CFilterSource10()
{
	m_Class = _T("Source10");
	m_PropNum = 10;
	
	m_Prop[PROP_SOURCE10].SetCategory(PCAT_COLOR);
	m_Prop[PROP_SOURCE10].SetName("Source10");
	m_Prop[PROP_SOURCE10].SetToolID(ID_PROP_SOURCE10);
}
