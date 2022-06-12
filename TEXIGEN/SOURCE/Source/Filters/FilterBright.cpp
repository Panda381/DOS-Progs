				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Brightness Level Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBright::CFilterBright()
{
	m_Group = FGRP_COL;
	m_Class = _T("Bright");
	m_HelpID = HELP_FBRIGHT;
	m_PropNum = 2;

	m_Prop[PROP_BRIGHT_BRIGHT].SetName("Brightness");
	m_Prop[PROP_BRIGHT_BRIGHT].SetValue(0.5);
	m_Prop[PROP_BRIGHT_BRIGHT].SetToolID(ID_PROP_BRIGHT);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterBright::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real bright = m_Prop[PROP_BRIGHT_BRIGHT].RenderVal(x, y);

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);

	// brightness correction
	col->Brightness(bright);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBright::RenderVal(real x, real y)
{
	// load properties
	real bright = m_Prop[PROP_BRIGHT_BRIGHT].RenderVal(x, y);

	// render value
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);

	// set brightness
	if (bright <= 0.5f)
		val *= bright*2;
	else
		val = 1 - (1 - val)*2*(1 - bright);

	return val;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLevel::CFilterLevel()
{
	m_Group = FGRP_COL;
	m_Class = _T("Level");
	m_HelpID = HELP_FLEVEL;
	m_PropNum = 4;

	m_Prop[PROP_LEVEL_BRIGHT].SetName("Brightness");
	m_Prop[PROP_LEVEL_BRIGHT].SetValue(0.5);
	m_Prop[PROP_LEVEL_BRIGHT].SetToolID(ID_PROP_BRIGHT);

	m_Prop[PROP_LEVEL_CONTRAST].SetName("Contrast");
	m_Prop[PROP_LEVEL_CONTRAST].SetValue(0.5);
	m_Prop[PROP_LEVEL_CONTRAST].SetToolID(ID_PROP_CONTRAST);

	m_Prop[PROP_LEVEL_GAMMA].SetName("Gamma");
	m_Prop[PROP_LEVEL_GAMMA].SetValue(0.5);
	m_Prop[PROP_LEVEL_GAMMA].SetToolID(ID_PROP_GAMMA);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLevel::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real bright = m_Prop[PROP_LEVEL_BRIGHT].RenderVal(x, y);
	real contrast = m_Prop[PROP_LEVEL_CONTRAST].RenderVal(x, y);
	real gamma = m_Prop[PROP_LEVEL_GAMMA].RenderVal(x, y);

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);

	// level correction
	col->Level(bright, contrast, gamma);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLevel::RenderVal(real x, real y)
{
	// load properties
	real bright = m_Prop[PROP_LEVEL_BRIGHT].RenderVal(x, y);
	real contrast = m_Prop[PROP_LEVEL_CONTRAST].RenderVal(x, y);
	real gamma = m_Prop[PROP_LEVEL_GAMMA].RenderVal(x, y);

	// render value
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);

	// prepare control ranges
	contrast = contrast*contrast*4; // 0..4, middle 1
	gamma = (real)(1/(gamma*gamma*3+(real)0.25)); // 4..1/3.25, middle 1

	// set brightness and contrast (new=(old-0.5)*contrast+0.5+(bright-0.5)
	val = val*contrast - contrast/2 + bright;

	// clamp range
	if (val <= 0) val = 0;
	if (val >= 1) val = 1;

	// set gamma
	val = pow(val, gamma);

	return val;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterAmplifier::CFilterAmplifier()
{
	m_Group = FGRP_COL;
	m_Class = _T("Amplifier");
	m_HelpID = HELP_FAMPLIFIER;
	m_PropNum = 2;

	m_Prop[PROP_AMPLIF_GAIN].SetName("Gain");
	m_Prop[PROP_AMPLIF_GAIN].SetMin(-500);
	m_Prop[PROP_AMPLIF_GAIN].SetMax(500);
	m_Prop[PROP_AMPLIF_GAIN].SetUserValue(100);
	m_Prop[PROP_AMPLIF_GAIN].SetToolID(ID_PROP_GAIN);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterAmplifier::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real gain = (m_Prop[PROP_AMPLIF_GAIN].RenderVal(x, y) - (real)0.5)*10;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);

	// gain correction
	real k = (1 - gain)/2;
	col->r = col->r*gain + k;
	col->g = col->g*gain + k;
	col->b = col->b*gain + k;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterAmplifier::RenderVal(real x, real y)
{
	// load properties
	real gain = (m_Prop[PROP_AMPLIF_GAIN].RenderVal(x, y) - (real)0.5)*10;

	// render value
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);

	// set gain
	return (val - (real)0.5)*gain + (real)0.5;
}
