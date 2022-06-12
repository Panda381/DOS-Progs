
///////////////////////////////////////////////////////////////////////////////
//
//                               Color Vector
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// color vector (color values are typically in range 0..1)
class CColor
{
protected:

	// convert HUE to RGB channel
	void HueToRGB(real m1, real m2, real hue, real* chan);

public:

	// color values (RGB, HSL or HSV)
	real r;		// Red or Hue
	real g;		// Green or Saturation
	real b;		// Blue or Lumination or Value
	real a;		// Alpha (0=transparent .. 1=opaque)

	// constructor
	CColor() {};

	// set value
	void Set(real rr, real gg, real bb, real aa) { r = rr; g = gg; b = bb; a = aa; }
	void Set(real rr, real gg, real bb) { r = rr; g = gg; b = bb; a = 1; }
	void Set(const CColor& src) { r = src.r; g = src.g; b = src.b; a = src.a; }

	// set black value
	void SetBlack() { r = 0; g = 0; b = 0; a = 1; }
	void SetBlackA() { r = 0; g = 0; b = 0; a = 0; }

	// set full transparent gray color
	void SetTransGray() { r = 0.5; g = 0.5; b = 0.5; a = 0; }

	// set white value
	void SetWhite() { r = 1; g = 1; b = 1; a = 1; }

	// set gray value
	void SetGray(real level) { r = level; g = level; b = level; a = 1; }

	// clamp color values to range 0..1
	void Clamp()
	{
		r = CLAMP(r);
		g = CLAMP(g);
		b = CLAMP(b);
		a = CLAMP(a);
	}

	// absolute values
	void AbsA()
	{
		if (r < 0) r = -r;
		if (g < 0) g = -g;
		if (b < 0) b = -b;
		if (a < 0) a = -a;
	}

	// get gray value from sRGB color
	real Gray() const
	{
		return (real)(0.2126*r + 0.7152*g + 0.0722*b);
	}

	void Decolorize()
	{
		real v = Gray();
		r = v;
		g = v;
		b = v;
	}

	// get linear gray value
	real GrayLin() const
	{
		return (r+g+b)/3;
	}

	// get gray as byte
	u8 GrayByte() const
	{
		real v = this->Gray();
		return CLAMPB((int)(v*255 + (real)0.5));
	}

	// transposition (k: 0=this,...1=src)
	void Trans(const CColor& src, real k)
	{
		r = r*(1-k) + src.r*k;
		g = g*(1-k) + src.g*k;
		b = b*(1-k) + src.b*k;
		a = a*(1-k) + src.a*k;
	}

	// transposition (k: 0=src1,...1=src2)
	void Trans(const CColor& src1, const CColor& src2, real k)
	{
		r = src1.r*(1-k) + src2.r*k;
		g = src1.g*(1-k) + src2.g*k;
		b = src1.b*(1-k) + src2.b*k;
		a = src1.a*(1-k) + src2.a*k;
	}

	// blend by src alpha (a: 0=this,...1=src)
	void Blend(const CColor& src)
	{
		real k = src.a;
		r = r*(1-k) + src.r*k;
		g = g*(1-k) + src.g*k;
		b = b*(1-k) + src.b*k;
	}

	// blend by dst alpha (a: 0=src,...1=this)
	void BlendInv(const CColor& src)
	{
		real k = a;
		r = r*k + src.r*(1-k);
		g = g*k + src.g*(1-k);
		b = b*k + src.b*(1-k);
		a = src.a;
	}

	// transposition between 4 BGR points (c11=[x,y], c21=[x+1,y], c12=[x,y+1], c22=[x+1,y+1])
	void TransBGR(u32 c11, u32 c21, u32 c12, u32 c22, real dx, real dy);

	// transposition between 4 RGBA points (c11=[x,y], c21=[x+1,y], c12=[x,y+1], c22=[x+1,y+1])
	void TransRGBA(u32 c11, u32 c21, u32 c12, u32 c22, real dx, real dy);
	void TransRGBA64(u64 c11, u64 c21, u64 c12, u64 c22, real dx, real dy);

	// cosinus transposition between 4 RGBA points (c11=[x,y], c21=[x+1,y], c12=[x,y+1], c22=[x+1,y+1])
/*	void TransCosRGBA(u32 c11, u32 c21, u32 c12, u32 c22, real dx, real dy)
	{
		//this->TransRGBA(c11, c21, c12, c22, (real)0.5 - cos(dx*PI)/2, (real)0.5 - cos(dy*PI)/2);
		this->TransRGBA(c11, c21, c12, c22, dx*dx*dx*(dx*(dx*6-15)+10), dy*dy*dy*(dy*(dy*6-15)+10));
	}

	void TransCosRGBA64(u64 c11, u64 c21, u64 c12, u64 c22, real dx, real dy)
	{
		//this->TransRGBA(c11, c21, c12, c22, (real)0.5 - cos(dx*PI)/2, (real)0.5 - cos(dy*PI)/2);
		this->TransRGBA64(c11, c21, c12, c22, dx*dx*dx*(dx*(dx*6-15)+10), dy*dy*dy*(dy*(dy*6-15)+10));
	}*/

	// invert
	void Invert() { r = 1 - r; g = 1 - g; b = 1 - b; }

	// negate
	void Negate() { r = -r; g = -g; b = -b; }

	// multiply
	void Mul(real k) { r *= k; g *= k; b *= k; }
	void MulA(real k) { r *= k; g *= k; b *= k; a *= k; }
	void Mul(const CColor& src) { r *= src.r; g *= src.g; b *= src.b; }
	void MulA(const CColor& src) { r *= src.r; g *= src.g; b *= src.b; a *= src.a; }
	void Mul(const CColor& src1, const CColor& src2)
		{ r = src1.r * src2.r; g = src1.g * src2.g; b = src1.b * src2.b; }
	void MulA(const CColor& src1, const CColor& src2)
		{ r = src1.r * src2.r; g = src1.g * src2.g; b = src1.b * src2.b; a = src1.a * src2.a; }

	// divide
	void Div(real k) { k = 1/k; r *= k; g *= k; b *= k; }
	void DivA(real k) { k = 1/k; r *= k; g *= k; b *= k; a *= k; }
	void Div(const CColor& src) { r /= src.r; g /= src.g; b /= src.b; }
	void DivA(const CColor& src) { r /= src.r; g /= src.g; b /= src.b; a /= src.a; }

	// inverse divide
	void InvDiv(real k) { r = k/r; g = k/g; b = k/b; }
	void InvDivA(real k) { r = k/r; g = k/g; b = k/b; a = k/a; }
	void InvDiv(const CColor& src) { r = src.r/r; g = src.g/g; b = src.b/b; }
	void InvDivA(const CColor& src) { r = src.r/r; g = src.g/g; b = src.b/b; a = src.a/a; }

	// reciprocal value
	void Recip() { r = 1/r; g = 1/g; b = 1/b; }
	void RecipA() { r = 1/r; g = 1/g; b = 1/b; a = 1/a; }

	// power color
	void PowCol(const CColor& src)
	{
		r = pow(r, src.r);
		g = pow(g, src.g);
		b = pow(b, src.b);
	}

	// sinus color (input 0..1=angle 0..360°, output 0..1 with middle 0.5)
	void SinCol()
	{
		r = SINNORM(r);
		g = SINNORM(g);
		b = SINNORM(b);
	}

	// cosinus color (input 0..1=angle 0..360°, output 0..1 with middle 0.5)
	void CosCol()
	{
		r = COSNORM(r);
		g = COSNORM(g);
		b = COSNORM(b);
	}

	// square color
	void Sqr() { r *= r; g *= g; b *= b; }
	void SqrA() { r *= r; g *= g; b *= b; a *= a; }

	// square root color
	void Sqrt() { r = sqrt(abs(r)); g = sqrt(abs(g)); b = sqrt(abs(b)); }
	void SqrtA() { r = sqrt(abs(r)); g = sqrt(abs(g)); b = sqrt(abs(b)); a = sqrt(abs(a)); }

	// granularity (Integer(this*src)/src)
	void Gran(const CColor& src)
		{ r = GRAN(r,src.r); g = GRAN(g,src.g); b = GRAN(b,src.b); }
	void Gran(real val)
		{ r = GRAN(r,val); g = GRAN(g,val); b = GRAN(b,val); }

	// modulo color (Integer(this*src)/src)
	void ModCol(const CColor& src)
	{
		r = MODUL(r,src.r);
		g = MODUL(g,src.g);
		b = MODUL(b,src.b);
	}

	// modulo color (Integer(this*src)/src)
	void ModCol(real val)
	{
		r = MODUL(r,val);
		g = MODUL(g,val);
		b = MODUL(b,val);
	}

	// interval
	void Interval(real min, real max)
	{
		real d = max - min;
		r = r*d + min;
		g = g*d + min;
		b = b*d + min;
	}

	// interval with alpha
	void IntervalA(real min, real max)
	{
		real d = max - min;
		r = r*d + min;
		g = g*d + min;
		b = b*d + min;
		a = a*d + min;
	}

	// Logarithm color (log10(9*Source+1))
	void LogCol()
	{
		r = log10(9*r + 1);
		g = log10(9*g + 1);
		b = log10(9*b + 1);
	}

	// Exponential color (exp10(Source)-1)/9
	void ExpCol()
	{
		r = (pow(10,r)-1)/9;
		g = (pow(10,g)-1)/9;
		b = (pow(10,b)-1)/9;
	}

	// add
	void Add(real k) { r += k; g += k; b += k; }
	void AddA(real k) { r += k; g += k; b += k; a += k; }
	void Add(const CColor& src) { r += src.r; g += src.g; b += src.b; }
	void AddA(const CColor& src) { r += src.r; g += src.g; b += src.b; a += src.a; }
	void Add(const CColor& src1, const CColor& src2)
		{ r = src1.r + src2.r; g = src1.g + src2.g; b = src1.b + src2.b; }
	void AddA(const CColor& src1, const CColor& src2)
		{ r = src1.r + src2.r; g = src1.g + src2.g; b = src1.b + src2.b; a = src1.a + src2.a; }

	// subtract
	void Sub(real k) { r -= k; g -= k; b -= k; }
	void SubA(real k) { r -= k; g -= k; b -= k; a -= k; }
	void Sub(const CColor& src) { r -= src.r; g -= src.g; b -= src.b; }
	void SubA(const CColor& src) { r -= src.r; g -= src.g; b -= src.b; a -= src.a; }

	// inverse subtract
	void InvSub(real k) { r = k - r; g = k - g; b = k - b; }
	void InvSubA(real k) { r = k - r; g = k - g; b = k - b; a = k - a; }
	void InvSub(const CColor& src) { r = src.r - r; g = src.g - g; b = src.b - b; }
	void InvSubA(const CColor& src) { r = src.r - r; g = src.g - g; b = src.b - b; a = src.a - a; }

	// average colors
	void Avr(const CColor& src)
	{
		r = (r + src.r)/2;
		g = (g + src.g)/2;
		b = (b + src.b)/2;
		a = (a + src.a)/2;
	}

	// minimum
	void Min(const CColor& src)
	{
		if (src.r < r) r = src.r;
		if (src.g < g) g = src.g;
		if (src.b < b) b = src.b;
		if (src.a < a) a = src.a;
	}

	// maximum
	void Max(const CColor& src)
	{
		if (src.r > r) r = src.r;
		if (src.g > g) g = src.g;
		if (src.b > b) b = src.b;
		if (src.a > a) a = src.a;
	}

	// adjust separated brightness
	void Brightness(real bright);

	// adjust contrast (0.5=normal)
	void Contrast(real contrast);

	// adjust brightness level (controls are in range 0..1, 0.5=linear)
	void Level(real brightness, real contrast, real gamma);

	// get R color (in byte range 0..255)
	u8 GetR() const
	{
		return CLAMPB((int)(r*255 + (real)0.5));
	}

	// get G color (in byte range 0..255)
	u8 GetG() const
	{
		return CLAMPB((int)(g*255 + (real)0.5));
	}

	// get B color (in byte range 0..255)
	u8 GetB() const
	{
		return CLAMPB((int)(b*255 + (real)0.5));
	}

	// get A value (in byte range 0..255)
	u8 GetA() const
	{
		return CLAMPB((int)(a*255 + (real)0.5));
	}

	// get R color (in word range 0..65535)
	u16 GetR16() const
	{
		return CLAMPW((int)(r*0xffff + (real)0.5));
	}

	// get G color (in word range 0..65535)
	u16 GetG16() const
	{
		return CLAMPW((int)(g*0xffff + (real)0.5));
	}

	// get B color (in word range 0..65535)
	u16 GetB16() const
	{
		return CLAMPW((int)(b*0xffff + (real)0.5));
	}

	// get A value (in word range 0..65535)
	u16 GetA16() const
	{
		return CLAMPW((int)(a*0xffff + (real)0.5));
	}

	// get RGBA color
	u32 GetRGBA() const
	{
		return GetR() | (GetG() << 8) | (GetB() << 16) | (GetA() << 24);
	}

	// get 64-bit RGBA color
	u64 GetRGBA64() const
	{
		return GetR16() | ((u64)GetG16() << 16) | ((u64)GetB16() << 32) | ((u64)GetA16() << 48);
	}

	// get RGB color
	u32 GetRGB() const
	{
		return GetR() | (GetG() << 8) | (GetB() << 16);
	}

	// set RGBA color (in byte range 0..255)
	void SetRGBA(u8 rr, u8 gg, u8 bb, u8 aa)
	{
		r = (real)rr/255;
		g = (real)gg/255;
		b = (real)bb/255;
		a = (real)aa/255;
	}

	// set RGBA color (in word range 0..65535)
	void SetRGBA64(u16 rr, u16 gg, u16 bb, u16 aa)
	{
		r = (real)rr/0xffff;
		g = (real)gg/0xffff;
		b = (real)bb/0xffff;
		a = (real)aa/0xffff;
	}

	// set RGB color (in byte range 0..255)
	void SetRGB(u8 rr, u8 gg, u8 bb)
	{
		r = (real)rr/255;
		g = (real)gg/255;
		b = (real)bb/255;
	}

	// set RGB color (in word range 0..65535)
	void SetRGB64(u16 rr, u16 gg, u16 bb)
	{
		r = (real)rr/0xffff;
		g = (real)gg/0xffff;
		b = (real)bb/0xffff;
	}

	// set RGB color (using DWORD)
	void SetRGB(u32 rgb)
	{
		SetRGB((u8)(rgb & 0xff), (u8)((rgb >> 8) & 0xff), (u8)((rgb >> 16) & 0xff));
	}

	// set RGBA color (using DWORD)
	void SetRGBA(u32 rgb)
	{
		SetRGBA((u8)(rgb & 0xff), (u8)((rgb >> 8) & 0xff), (u8)((rgb >> 16) & 0xff), (u8)((rgb >> 24)));
	}

	// set RGBA color (using QWORD)
	void SetRGBA64(u64 rgb)
	{
		SetRGBA64((u16)(rgb & 0xffff), (u16)((rgb >> 16) & 0xffff), (u16)((rgb >> 32) & 0xffff), (u16)(rgb >> 48));
	}

	// set BGR color (using DWORD)
	void SetBGR(u32 rgb)
	{
		SetRGB((u8)((rgb >> 16) & 0xff), (u8)((rgb >> 8) & 0xff), (u8)(rgb & 0xff));
	}

	// convert RGB to HSL
	void RGBToHSL();

	// convert HSL to RGB
	void HSLToRGB();

	// convert RGB to HSV
	void RGBToHSV();

	// convert HSV to RGB
	void HSVToRGB();
};
