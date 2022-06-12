	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Blending Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// Some "Extra" filters formulas are taken from http://www.pegtop.net/delphi/articles/blendmodes/dodge.htm

// blend operations
#define BLEND_NORMAL(a,b)		(b)					// 0.00
// Darken
#define BLEND_DARKEN(a,b)		min((a),(b))		// 0.01 Darken (ztmavit)
#define BLEND_MULTIPLY(a,b)		((a)*(b))			// 0.02 Multiply (nasobit)
#define BLEND_COLORBURN(a,b)	(((b)<0.001)?(b):(1-(1-(a))/(b))) // 0.03 CLAMP Color Burn (ztmavit barvy)
#define BLEND_LINEARBURN(a,b)	((a)+(b)-1)			// 0.04 CLAMP Linear Burn (linearne ztmavit)
													// 0.05 Darker Color (tmavsi barva)
// Lighten
#define BLEND_LIGHTEN(a,b)		max((a),(b))		// 0.06 Lighten (zesvetlit)
#define BLEND_SCREEN(a,b)		(1-(1-(a))*(1-(b)))	// 0.07 Screen (zavoj)
#define BLEND_COLORDODGE(a,b)	(((b)>0.999)?(b):((a)/(1-(b)))) // 0.08 CLAMP Color Dodge (zesvetlit barvy)
#define BLEND_LINEARDODGE(a,b)	((a)+(b))			// 0.09 CLAMP Linear Dodge, Add (linearne zesvetlit)
													// 0.10 Lighter Color (svetlejsi barva)
// Darken and lighten
#define BLEND_OVERLAY(a,b)		(((a)<=0.5)?(2*(a)*(b)):(1-2*(1-(a))*(1-(b)))) // 0.11 Overlay (prekryt)
#define BLEND_SOFTLIGHT(a,b)	(((b)<=0.5)?((a)*(2*(b)*(1-(a))+(a))):(sqrt(a)*(2*(b)-1)+2*(a)*(1-(b)))) // 0.12 Soft Light (mekke svetlo)
#define BLEND_HARDLIGHT(a,b)	(((b)<=0.5)?(2*(a)*(b)):(1-2*(1-(b))*(1-(a)))) // 0.13 Hard Light (tvrde svetlo)
#define BLEND_VIVIDLIGHT(a,b)	(((b)<=0.5)?BLEND_COLORBURN((a),2*(b)):BLEND_COLORDODGE((a),2*((b)-(real)0.5))) // 0.14 CLAMP Vivid Light (jasne svetlo)
#define BLEND_LINEARLIGHT(a,b)	(((b)<=0.5)?BLEND_LINEARBURN((a),2*(b)):BLEND_LINEARDODGE((a),2*((b)-(real)0.5))) // 0.15 CLAMP Linear Light (linearni svetlo)
#define BLEND_PINLIGHT(a,b)		(((b)<=0.5)?BLEND_DARKEN((a),2*(b)):BLEND_LIGHTEN((a),2*((b)-(real)0.5))) // 0.16 Pin Light (bodove svetlo)
#define BLEND_HARDMIX(a,b)		(real)((BLEND_VIVIDLIGHT((a),(b))<=0.5)?0:1) // 0.17 Hard Mix (tvrde michani)
// Negation
#define BLEND_DIFFERENCE(a,b)	(abs((a)-(b)))		// 0.18 Difference (rozdil)
#define BLEND_EXCLUSION(a,b)	((a)+(b)-2*(a)*(b))	// 0.19 Exclusion (vyloucit)
#define BLEND_SUBTRACT(a,b)		((a)-(b))			// 0.20 CLAMP Subtract (odecteni)
#define BLEND_DIVIDE(a,b)		(((b)<0.001)?1:((a)/(b))) // 0.21 CLAMP Divide (deleni)
// HSV modes
													// 0.22 Hue
													// 0.23 Saturation
													// 0.24 Color
													// 0.25 ColorBlend
													// 0.26 Luminance
// Extra
#define BLEND_PSOFTLIGHT(a,b)	((a)-((real)0.5-(b))*((real)0.25+(a)-(a)*(a))) // 0.27 CLAMP Pegtop Soft Light
#define BLEND_AVERAGE(a,b)		(((a)+(b))/2)		// 0.28 Average
#define BLEND_NEGATION(a,b)		(1-abs(1-(a)-(b)))	// 0.29 Negation
#define BLEND_REFLECT(a,b)		(((b)>0.999)?(b):((a)*(a)/(1-(b)))) // 0.30 CLAMP Reflect
#define BLEND_GLOW(a,b)			BLEND_REFLECT((b),(a)) // 0.31 CLAMP Glow
#define BLEND_PHOENIX(a,b)		(min((a),(b))-max((a),(b))+1) // 0.32 Phoenix
#define BLEND_INVCOLORDODGE(a,b) BLEND_COLORDODGE((b),(a)) // 0.33 CLAMP Inverse Color Dodge
#define BLEND_INVCOLORBURN(a,b)	BLEND_COLORBURN((b),(a)) // 0.34 CLAMP Inverse Color Burn
#define BLEND_SOFTDODGE(a,b)	((((a)+(b))<1)?BLEND_COLORDODGE((a)/2,b):BLEND_COLORBURN(b,2*(a))) // 0.35 CLAMP Soft Dodge
#define BLEND_SOFTBURN(a,b)		((((a)+(b))<1)?BLEND_COLORDODGE((b)/2,a):BLEND_COLORBURN(a,2*(b))) // 0.36 CLAMP Soft Burn
#define BLEND_FREEZE(a,b)		(((b)<0.001)?1:(1-(1-(a))*(1-(a))/(b))) // 0.37 CLAMP Freeze
#define BLEND_HEAT(a,b)			BLEND_FREEZE((b),(a)) // 0.38 CLAMP Heat
#define BLEND_STAMP(a,b)		((a)+2*(b)-1)		// 0.39 CLAMP Stamp
													// 0.40 XOR
													// 0.41 Red
													// 0.42 Green
													// 0.43 Blue
CText FilterBlendModes[] = {
	CText(_T("Normal")),		// 0
	CText(_T("Darken")),		// 1
	CText(_T("Multiply")),		// 2
	CText(_T("Color Burn")),	// 3
	CText(_T("Linear Burn")),	// 4
	CText(_T("Darker Color")),	// 5
	CText(_T("Lighten")),		// 6
	CText(_T("Screen")),		// 7
	CText(_T("Color Dodge")),	// 8
	CText(_T("Linear Dodge")),	// 9
	CText(_T("Lighter Color")),	// 10
	CText(_T("Overlay")),		// 11
	CText(_T("Soft Light")),	// 12
	CText(_T("Hard Light")),	// 13
	CText(_T("Vivid Light")),	// 14
	CText(_T("Linear Light")),	// 15
	CText(_T("Pin Light")),		// 16
	CText(_T("Hard Mix")),		// 17
	CText(_T("Difference")),	// 18
	CText(_T("Exclusion")),		// 19
	CText(_T("Subtract")),		// 20
	CText(_T("Divide")),		// 21
	CText(_T("HSL")),			// 22
	CText(_T("Saturation")),	// 23
	CText(_T("Color")),			// 24
	CText(_T("ColorBlend")),	// 25
	CText(_T("Luminance")),		// 26
	CText(_T("Pegtop Soft Light")),	// 27
	CText(_T("Average")),		// 28
	CText(_T("Negation")),		// 29
	CText(_T("Reflect")),		// 30
	CText(_T("Glow")),			// 31
	CText(_T("Phoenix")),		// 32
	CText(_T("Inverse Color Dodge")), // 33
	CText(_T("Inverse Color Burn")), // 34
	CText(_T("Soft Dodge")),	// 35
	CText(_T("Soft Burn")),		// 36
	CText(_T("Freeze")),		// 37
	CText(_T("Heat")),			// 38
	CText(_T("Stamp")),			// 39
	CText(_T("XOR")),			// 40
	CText(_T("Red")),			// 41
	CText(_T("Green")),			// 42
	CText(_T("Blue")),			// 43

	CText(_T(""))				// 44
};

///////////////////////////////////////////////////////////////////////////////
// blending colors

void Blend(CColor* col, const CColor& src, real opacity, int mode, bool alphamod /*=false */)
{
	CColor c;
	c.Set(src);
	opacity *= c.a;
	CColor t;

	// combine colors
	switch(mode)
	{
	// Darken
	case 1:	// Darken: min((a),(b))
		c.r = BLEND_DARKEN(col->r, c.r);
		c.g = BLEND_DARKEN(col->g, c.g);
		c.b = BLEND_DARKEN(col->b, c.b);
		break;

	case 2:	// Multiply: ((a)*(b))
		c.r = BLEND_MULTIPLY(col->r, c.r);
		c.g = BLEND_MULTIPLY(col->g, c.g);
		c.b = BLEND_MULTIPLY(col->b, c.b);
		break;

	case 3: // Color burn: (((b)<=0.001)?(b):(1-(1-(a))/(b)))
		c.r = BLEND_COLORBURN(col->r, c.r);
		c.g = BLEND_COLORBURN(col->g, c.g);
		c.b = BLEND_COLORBURN(col->b, c.b);
		c.Clamp();
		break;

	case 4: // Linear burn: ((a)+(b)-1)
		c.r = BLEND_LINEARBURN(col->r, c.r);
		c.g = BLEND_LINEARBURN(col->g, c.g);
		c.b = BLEND_LINEARBURN(col->b, c.b);
		c.Clamp();
		break;

	case 5: // Darker Color
		if (col->Gray() < c.Gray()) c.Set(*col);
		break;

	// Lighten
	case 6:	// Lighten: max((a),(b))
		c.r = BLEND_LIGHTEN(col->r, c.r);
		c.g = BLEND_LIGHTEN(col->g, c.g);
		c.b = BLEND_LIGHTEN(col->b, c.b);
		break;

	case 7:	// Screen: (1-(1-(a))*(1-(b)))
		c.r = BLEND_SCREEN(col->r, c.r);
		c.g = BLEND_SCREEN(col->g, c.g);
		c.b = BLEND_SCREEN(col->b, c.b);
		break;

	case 8: // Color dodge: (((b)>0.999)?(b):((a)/(1-(b))))
		c.r = BLEND_COLORDODGE(col->r, c.r);
		c.g = BLEND_COLORDODGE(col->g, c.g);
		c.b = BLEND_COLORDODGE(col->b, c.b);
		c.Clamp();
		break;

	case 9: // Linear dodge: ((a)+(b))
		c.r = BLEND_LINEARDODGE(col->r, c.r);
		c.g = BLEND_LINEARDODGE(col->g, c.g);
		c.b = BLEND_LINEARDODGE(col->b, c.b);
		c.Clamp();
		break;

	case 10: // Lighter Color
		if (col->Gray() > c.Gray()) c.Set(*col);
		break;

	// Darken and lighten
	case 11: // Overlay: (((a)<=0.5)?(2*(a)*(b)):(1-2*(1-(a))*(1-(b))))
		c.r = BLEND_OVERLAY(col->r, c.r);
		c.g = BLEND_OVERLAY(col->g, c.g);
		c.b = BLEND_OVERLAY(col->b, c.b);
		break;

	case 12: // Soft light: (((b)<=0.5)?((a)*(2*(b)*(1-(a))+(a))):(sqrt(a)*(2*(b)-1)+2*(a)*(1-(b))))
		c.r = BLEND_SOFTLIGHT(col->r, c.r);
		c.g = BLEND_SOFTLIGHT(col->g, c.g);
		c.b = BLEND_SOFTLIGHT(col->b, c.b);
		break;

	case 13: // Hard light: (((b)<=0.5)?(2*(a)*(b)):(1-2*(1-(b))*(1-(a))))
		c.r = BLEND_HARDLIGHT(col->r, c.r);
		c.g = BLEND_HARDLIGHT(col->g, c.g);
		c.b = BLEND_HARDLIGHT(col->b, c.b);
		break;

	case 14: // Vivid Light: (((b)<0.5)?BLEND_COLORBURN((a),2*(b)):BLEND_COLORDODGE((a),2*((b)-(real)0.5)))
		c.r = BLEND_VIVIDLIGHT(col->r, c.r);
		c.g = BLEND_VIVIDLIGHT(col->g, c.g);
		c.b = BLEND_VIVIDLIGHT(col->b, c.b);
		c.Clamp();
		break;

	case 15: // Linear Light: (((b)<0.5)?BLEND_LINEARBURN((a),2*(b)):BLEND_LINEARDODGE((a),2*((b)-(real)0.5)))
		c.r = BLEND_LINEARLIGHT(col->r, c.r);
		c.g = BLEND_LINEARLIGHT(col->g, c.g);
		c.b = BLEND_LINEARLIGHT(col->b, c.b);
		c.Clamp();
		break;

	case 16: // Pin Light: (((b)<0.5)?BLEND_DARKEN((a),2*(b)):BLEND_LIGHTEN((a),2*((b)-(real)0.5)))
		c.r = BLEND_PINLIGHT(col->r, c.r);
		c.g = BLEND_PINLIGHT(col->g, c.g);
		c.b = BLEND_PINLIGHT(col->b, c.b);
		break;

	case 17: // Hard Mix: ((BLEND_VIVIDLIGHT((a),(b))<0.5)?0:1)
		c.r = BLEND_HARDMIX(col->r, c.r);
		c.g = BLEND_HARDMIX(col->g, c.g);
		c.b = BLEND_HARDMIX(col->b, c.b);
		break;

	// Negation
	case 18: // Difference: (abs((a)-(b)))
		c.r = BLEND_DIFFERENCE(col->r, c.r);
		c.g = BLEND_DIFFERENCE(col->g, c.g);
		c.b = BLEND_DIFFERENCE(col->b, c.b);
		break;

	case 19: // Exclusion: ((a)+(b)-2*(a)*(b))
		c.r = BLEND_EXCLUSION(col->r, c.r);
		c.g = BLEND_EXCLUSION(col->g, c.g);
		c.b = BLEND_EXCLUSION(col->b, c.b);
		break;

	case 20: // Subtract: ((a)-(b))
		c.r = BLEND_SUBTRACT(col->r, c.r);
		c.g = BLEND_SUBTRACT(col->g, c.g);
		c.b = BLEND_SUBTRACT(col->b, c.b);
		c.Clamp();
		break;

	case 21: // Divide: (((b)<0.001)?1:((a)/(b)))
		c.r = BLEND_DIVIDE(col->r, c.r);
		c.g = BLEND_DIVIDE(col->g, c.g);
		c.b = BLEND_DIVIDE(col->b, c.b);
		c.Clamp();
		break;

	// HSL
	case 22: // Hue
		t.Set(*col);
		t.RGBToHSL();
		c.RGBToHSL();
		c.g = t.g;
		c.b = t.b;
		c.HSLToRGB();
		break;

	case 23: // Saturation
		t.Set(*col);
		t.RGBToHSL();
		c.RGBToHSL();
		c.r = t.r;
		c.b = t.b;
		c.HSLToRGB();
		break;

	case 24: // Color
		t.Set(*col);
		t.RGBToHSL();
		c.RGBToHSL();
		c.b = t.b;
		c.HSLToRGB();
		break;

	case 25: // ColorBlend
		t.Set(*col);
		t.RGBToHSL();
		c.RGBToHSL();
		c.b *= t.b;
		c.HSLToRGB();
		break;

	case 26: // Luminance
		t.Set(*col);
		t.RGBToHSL();
		c.RGBToHSL();
		c.r = t.r;
		c.g = t.g;
		c.HSLToRGB();
		break;

	// Extra
	case 27: // Pegtop Soft Light: ((a)-((real)0.5-(b))*((real)0.25+(a)-(a)*(a)))
		c.r = BLEND_PSOFTLIGHT(col->r, c.r);
		c.g = BLEND_PSOFTLIGHT(col->g, c.g);
		c.b = BLEND_PSOFTLIGHT(col->b, c.b);
		c.Clamp();
		break;

	case 28: // Average: (((a)+(b))/2)
		c.r = BLEND_AVERAGE(col->r, c.r);
		c.g = BLEND_AVERAGE(col->g, c.g);
		c.b = BLEND_AVERAGE(col->b, c.b);
		break;

	case 29: // Negation: (1-abs(1-(a)-(b)))
		c.r = BLEND_NEGATION(col->r, c.r);
		c.g = BLEND_NEGATION(col->g, c.g);
		c.b = BLEND_NEGATION(col->b, c.b);
		break;

	case 30: // Reflect: (((b)>0.999)(b):((a)*(a)/(1-(b))))
		c.r = BLEND_REFLECT(col->r, c.r);
		c.g = BLEND_REFLECT(col->g, c.g);
		c.b = BLEND_REFLECT(col->b, c.b);
		c.Clamp();
		break;

	case 31: // Glow: BLEND_REFLECT((b),(a))
		c.r = BLEND_GLOW(col->r, c.r);
		c.g = BLEND_GLOW(col->g, c.g);
		c.b = BLEND_GLOW(col->b, c.b);
		c.Clamp();
		break;

	case 32: // Phoenix: (min((a),(b))-max((a),(b))+1)
		c.r = BLEND_PHOENIX(col->r, c.r);
		c.g = BLEND_PHOENIX(col->g, c.g);
		c.b = BLEND_PHOENIX(col->b, c.b);
		break;

	case 33: // Inverse Color Dodge: BLEND_COLORDODGE((b),(a))
		c.r = BLEND_INVCOLORDODGE(col->r, c.r);
		c.g = BLEND_INVCOLORDODGE(col->g, c.g);
		c.b = BLEND_INVCOLORDODGE(col->b, c.b);
		c.Clamp();
		break;

	case 34: // Inverse Color Burn: BLEND_COLORBURN((b),(a))
		c.r = BLEND_INVCOLORBURN(col->r, c.r);
		c.g = BLEND_INVCOLORBURN(col->g, c.g);
		c.b = BLEND_INVCOLORBURN(col->b, c.b);
		c.Clamp();
		break;

	case 35: // Soft Dodge: ((((a)+(b))<1)?BLEND_COLORDODGE((a)/2,b):BLEND_COLORBURN(b,2*(a)))
		c.r = BLEND_SOFTDODGE(col->r, c.r);
		c.g = BLEND_SOFTDODGE(col->g, c.g);
		c.b = BLEND_SOFTDODGE(col->b, c.b);
		c.Clamp();
		break;

	case 36: // Soft Burn: ((((a)+(b))<1)?BLEND_COLORDODGE((b)/2,a):BLEND_COLORBURN(a,2*(b)))
		c.r = BLEND_SOFTBURN(col->r, c.r);
		c.g = BLEND_SOFTBURN(col->g, c.g);
		c.b = BLEND_SOFTBURN(col->b, c.b);
		c.Clamp();
		break;

	case 37: // Freeze: (((b)<0.001)?1:(1-(1-(a))*(1-(a))/(b)))
		c.r = BLEND_FREEZE(col->r, c.r);
		c.g = BLEND_FREEZE(col->g, c.g);
		c.b = BLEND_FREEZE(col->b, c.b);
		c.Clamp();
		break;

	case 38: // Heat: BLEND_FREEZE((b),(a))
		c.r = BLEND_HEAT(col->r, c.r);
		c.g = BLEND_HEAT(col->g, c.g);
		c.b = BLEND_HEAT(col->b, c.b);
		c.Clamp();
		break;

	case 39: // Stamp: ((a)+2*(b)-1)
		c.r = BLEND_STAMP(col->r, c.r);
		c.g = BLEND_STAMP(col->g, c.g);
		c.b = BLEND_STAMP(col->b, c.b);
		c.Clamp();
		break;

	case 40: // XOR
		c.SetRGBA(c.GetR()^col->GetR(),c.GetG()^col->GetG(),
			c.GetB()^col->GetB(),c.GetA());			
		break;

	case 41: // Red
		c.g = col->g;
		c.b = col->b;
		break;

	case 42: // Green
		c.r = col->r;
		c.b = col->b;
		break;

	case 43: // Blue
		c.r = col->r;
		c.g = col->g;
		break;

	default: // blend normal
		break;
	}

	// blend images
	c.MulA(opacity);
	c.a = opacity;
	if (alphamod) c.a *= col->a;
	col->MulA(1 - opacity);
	col->AddA(c);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterBlend::CFilterBlend()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Blend");
	m_HelpID = HELP_FBLEND;
	m_PropNum = 5;

	m_Prop[PROP_BLEND_OPACITY].SetName("Opacity");
	m_Prop[PROP_BLEND_OPACITY].SetValue(1);
	m_Prop[PROP_BLEND_OPACITY].SetToolID(ID_PROP_OPACITY);

	m_Prop[PROP_BLEND_MODE].SetCategory(PCAT_ENUM);
	m_Prop[PROP_BLEND_MODE].SetName("Mode");
	m_Prop[PROP_BLEND_MODE].SetValue(0);
	m_Prop[PROP_BLEND_MODE].SetEnum(FilterBlendModes);
	m_Prop[PROP_BLEND_MODE].SetToolID(ID_PROP_BLENDMODE);

	m_Prop[PROP_BLEND_ALPHAMOD].SetCategory(PCAT_CHECK);
	m_Prop[PROP_BLEND_ALPHAMOD].SetName("AlphaMod");
	m_Prop[PROP_BLEND_ALPHAMOD].SetMax(1);
	m_Prop[PROP_BLEND_ALPHAMOD].SetToolID(ID_PROP_ALPHAMOD);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterBlend::RenderCol(CColor* col, real x, real y)
{
	// load properties
	real opacity = m_Prop[PROP_BLEND_OPACITY].RenderVal(x, y);
	if (abs(opacity) < (real)1e-5)
	{
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
		return;
	}
	int mode = (int)(m_Prop[PROP_BLEND_MODE].RenderVal(x, y)*100+0.5);
	bool alphamod = m_Prop[PROP_BLEND_ALPHAMOD].RenderVal(x, y) >= 0.5;

	// render colors
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	CColor c;
	m_Prop[PROP_SOURCE2].RenderCol(&c, x, y);

	// Blend
	Blend(col, c, opacity, mode, alphamod);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterBlend::RenderVal(real x, real y)
{
	CColor col;
	CFilterBlend::RenderCol(&col, x, y);
	return col.Gray();
}
