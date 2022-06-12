
///////////////////////////////////////////////////////////////////////////////
//
//                               Color Vector
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// adjust separated brightness

void CColor::Brightness(real bright)
{
	if (bright == (real)0.5) return;

	if (bright <= (real)0.5)
	{
		bright *= 2;
		r *= bright;
		g *= bright;
		b *= bright;
	}
	else
	{
		bright = 2*(1 - bright);
		r = 1 - (1 - r)*bright;
		g = 1 - (1 - g)*bright;
		b = 1 - (1 - b)*bright;
	}
}

///////////////////////////////////////////////////////////////////////////////
// transposition between 4 BGR points (c11=[x,y], c21=[x+1,y], c12=[x,y+1], c22=[x+1,y+1])

void CColor::TransBGR(u32 c11, u32 c21, u32 c12, u32 c22, real dx, real dy)
{
	// interpolate blue
	int b11 = c11 & 0xff;
	int b21 = c21 & 0xff;
	real b1 = b11*(1-dx) + b21*dx;
	int b12 = c12 & 0xff;
	int b22 = c22 & 0xff;
	real b2 = b12*(1-dx) + b22*dx;
	b = (b1*(1-dy) + b2*dy)/255;

	// interpolate green
	int g11 = (c11 >> 8) & 0xff;
	int g21 = (c21 >> 8) & 0xff;
	real g1 = g11*(1-dx) + g21*dx;
	int g12 = (c12 >> 8) & 0xff;
	int g22 = (c22 >> 8) & 0xff;
	real g2 = g12*(1-dx) + g22*dx;
	g = (g1*(1-dy) + g2*dy)/255;

	// interpolate red
	int r11 = (c11 >> 16) & 0xff;
	int r21 = (c21 >> 16) & 0xff;
	real r1 = r11*(1-dx) + r21*dx;
	int r12 = (c12 >> 16) & 0xff;
	int r22 = (c22 >> 16) & 0xff;
	real r2 = r12*(1-dx) + r22*dx;
	r = (r1*(1-dy) + r2*dy)/255;

	// alpha
	a = 1;
}

///////////////////////////////////////////////////////////////////////////////
// transposition between 4 RGBA points (c11=[x,y], c21=[x+1,y], c12=[x,y+1], c22=[x+1,y+1])

void CColor::TransRGBA(u32 c11, u32 c21, u32 c12, u32 c22, real dx, real dy)
{
	// interpolate red
	int r11 = c11 & 0xff;
	int r21 = c21 & 0xff;
	real r1 = r11*(1-dx) + r21*dx;
	int r12 = c12 & 0xff;
	int r22 = c22 & 0xff;
	real r2 = r12*(1-dx) + r22*dx;
	r = (r1*(1-dy) + r2*dy)/255;

	// interpolate green
	int g11 = (c11 >> 8) & 0xff;
	int g21 = (c21 >> 8) & 0xff;
	real g1 = g11*(1-dx) + g21*dx;
	int g12 = (c12 >> 8) & 0xff;
	int g22 = (c22 >> 8) & 0xff;
	real g2 = g12*(1-dx) + g22*dx;
	g = (g1*(1-dy) + g2*dy)/255;

	// interpolate blue
	int b11 = (c11 >> 16) & 0xff;
	int b21 = (c21 >> 16) & 0xff;
	real b1 = b11*(1-dx) + b21*dx;
	int b12 = (c12 >> 16) & 0xff;
	int b22 = (c22 >> 16) & 0xff;
	real b2 = b12*(1-dx) + b22*dx;
	b = (b1*(1-dy) + b2*dy)/255;

	// interpolate alpha
	int a11 = (c11 >> 24);
	int a21 = (c21 >> 24);
	real a1 = a11*(1-dx) + a21*dx;
	int a12 = (c12 >> 24);
	int a22 = (c22 >> 24);
	real a2 = a12*(1-dx) + a22*dx;
	a = (a1*(1-dy) + a2*dy)/255;
}

///////////////////////////////////////////////////////////////////////////////
// transposition between 4 RGBA points (c11=[x,y], c21=[x+1,y], c12=[x,y+1], c22=[x+1,y+1])

void CColor::TransRGBA64(u64 c11, u64 c21, u64 c12, u64 c22, real dx, real dy)
{
	// interpolate red
	int r11 = (int)(c11 & 0xffff);
	int r21 = (int)(c21 & 0xffff);
	real r1 = r11*(1-dx) + r21*dx;
	int r12 = (int)(c12 & 0xffff);
	int r22 = (int)(c22 & 0xffff);
	real r2 = r12*(1-dx) + r22*dx;
	r = (r1*(1-dy) + r2*dy)/0xffff;

	// interpolate green
	int g11 = (int)((c11 >> 16) & 0xffff);
	int g21 = (int)((c21 >> 16) & 0xffff);
	real g1 = g11*(1-dx) + g21*dx;
	int g12 = (int)((c12 >> 16) & 0xffff);
	int g22 = (int)((c22 >> 16) & 0xffff);
	real g2 = g12*(1-dx) + g22*dx;
	g = (g1*(1-dy) + g2*dy)/0xffff;

	// interpolate blue
	int b11 = (int)((c11 >> 32) & 0xffff);
	int b21 = (int)((c21 >> 32) & 0xffff);
	real b1 = b11*(1-dx) + b21*dx;
	int b12 = (int)((c12 >> 32) & 0xffff);
	int b22 = (int)((c22 >> 32) & 0xffff);
	real b2 = b12*(1-dx) + b22*dx;
	b = (b1*(1-dy) + b2*dy)/0xffff;

	// interpolate alpha
	int a11 = (int)(c11 >> 48);
	int a21 = (int)(c21 >> 48);
	real a1 = a11*(1-dx) + a21*dx;
	int a12 = (int)(c12 >> 48);
	int a22 = (int)(c22 >> 48);
	real a2 = a12*(1-dx) + a22*dx;
	a = (a1*(1-dy) + a2*dy)/0xffff;
}

///////////////////////////////////////////////////////////////////////////////
// convert HUE to RGB channel

void CColor::HueToRGB(real m1, real m2, real hue, real* chan)
{
	if (hue < 0) hue++;
	if (hue >= 1) hue--;

	if ((6*hue) < 1)
		*chan = m1 + (m2 - m1)*hue*6;
	else
		if ((2*hue) < 1)
			*chan = m2;
		else
			if ((3*hue) < 2)
				*chan = m1 + (m2 - m1) * ((real)2/3 - hue) * 6;
			else
				*chan = m1;
}

///////////////////////////////////////////////////////////////////////////////
// adjust contrast (0.5=normal)

void CColor::Contrast(real contrast)
{
	contrast = contrast*contrast*4; // 0..4, middle 1
	real k = (1 - contrast)/2;
	r = r*contrast + k;
	g = g*contrast + k;
	b = b*contrast + k;
	Clamp();
}

///////////////////////////////////////////////////////////////////////////////
// adjust brightness level (controls are in range 0..1, 0.5=linear)

void CColor::Level(real brightness, real contrast, real gamma)
{
	// prepare control ranges
	contrast = contrast*contrast*4; // 0..4, middle 1
	gamma = (real)(1/(gamma*gamma*3+(real)0.25)); // 4..1/3.25, middle 1

	// set brightness and contrasst (new=(old-0.5)*contrast+0.5+(brightness-0.5)
	brightness -= contrast/2;
	r = r*contrast + brightness;
	g = g*contrast + brightness;
	b = b*contrast + brightness;

	// clamp range
	Clamp();

	// set gamma
	if (gamma != 1)
	{
		r = pow(r, gamma);
		g = pow(g, gamma);
		b = pow(b, gamma);
	}
}

///////////////////////////////////////////////////////////////////////////////
// convert RGB to HSL

void CColor::RGBToHSL()
{
	// normalize values
	Clamp();

	real max = max(max(r,g),b);
	real min = min(min(r,g),b);

	real hue = 0;
	real lum = (max + min)/2;
	real sat = 0;

	real delta = max - min;
	if (abs(delta)>0.001)
	{
		if (lum < 0.5)
			sat = delta / (max + min);
		else
			sat = delta / (2 - max - min);

		if (r >= max)
			hue = (g - b) / delta;
		else
			if (g >= max)
				hue = 2 + (b - r) / delta;
			else
				hue = 4 + (r - g) / delta;

		hue /= 6;
		if (hue < 0) hue += 1;
	}

	r = hue;
	g = sat;
	b = lum;
}

///////////////////////////////////////////////////////////////////////////////
// convert HSL to RGB

void CColor::HSLToRGB()
{
	// normalize values
	Clamp();

	real hue = r;
	real sat = g;
	real lum = b;
	real m1, m2;

	// gray color
	if (sat <= 0.001)
	{
		r = lum;
		g = lum;
		b = lum;
	}
	else
	{
		if (lum <= 0.5)
			m2 = lum*(1 + sat);
		else
			m2 = lum + sat - lum*sat;

		m1 = 2*lum - m2;

		HueToRGB(m1, m2, hue + (real)1/3, &r);
		HueToRGB(m1, m2, hue, &g);
		HueToRGB(m1, m2, hue - (real)1/3, &b);
	}
}

///////////////////////////////////////////////////////////////////////////////
// convert RGB to HSV

void CColor::RGBToHSV()
{
	// normalize values
	Clamp();

	// minimum and maximum value
	real max = max(max(r,g),b);
	real min = min(min(r,g),b);

	// black color
	real hue = 0;
	real sat = 0;
	real val = 0;

	// not black
	if (max > 0.001)
	{
		// set value
		val = max;

		// normalize saturation
		real chroma = max - min;
		sat = chroma / max;

		// not gray
		if (sat > 0.001)
		{
			// compute hue
			if (r >= max)
				hue = (g - b) / chroma;
			else
				if (g >= max)
					hue = 2 + (b - r) / chroma;
				else
					hue = 4 + (r - g) / chroma;
			hue /= 6;
			if (hue < 0) hue += 1;
		}
		else
			sat = 0;
	}

	r = hue;
	g = sat;
	b = val;
}

///////////////////////////////////////////////////////////////////////////////
// convert HSV to RGB

void CColor::HSVToRGB()
{
	// normalize values
	Clamp();

	// get HSV values
	real hue = r*6;
	real sat = g;
	real val = b;

	// preset gray color
	r = val;
	g = val;
	b = val;

	// valid color
	if (sat > 0.001)
	{
		// get color region and reminder in region
		int reg = (int)hue; // color region 0..5
		if (reg > 5) reg = 5;
		real rem = hue - reg;	// reminder in region

		// temporary coefficients
		real p = val*(1-sat);
		real q = val*(1-sat*rem);
		real t = val*(1-sat*(1-rem));

		// get RGB in region
		switch (reg)
		{
		case 0: g = t; b = p; break;
		case 1: r = q; b = p; break;
		case 2: r = p; b = t; break;
		case 3: r = p; g = q; break;
		case 4: r = t; g = p; break;
		default: g = p; b = q;
		}
	}
}
