
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Complex Numbers                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

//typedef float real;
//typedef double real;

class complex
{
public:

	real m_Re;	// real part
	real m_Im;	// imaginary part

	// constructor
	inline complex() {}
	inline complex(real re, real im) { m_Re = re; m_Im = im; }
	inline complex(real re) { m_Re = re; m_Im = 0; }
	inline complex(const complex* src) { m_Re = src->m_Re; m_Im = src->m_Im; }
	inline complex(const complex& src) { m_Re = src.m_Re; m_Im = src.m_Im; }

	// clear
	inline void Clear() { m_Re = 0; m_Im = 0; }

	// negate
	inline void Neg() { m_Re = -m_Re; m_Im = -m_Im; }

	// get/set component
	inline real Re() const { return m_Re; }
	inline real Im() const { return m_Im; }
	inline void SetRe(real re) { m_Re = re; }
	inline void SetIm(real im) { m_Im = im; }

	// get modulus (Modulus2 = square modulus)
	inline real Modulus() const { return (real)sqrt(m_Re*m_Re + m_Im*m_Im); }
	inline real Modulus2() const { return m_Re*m_Re + m_Im*m_Im; }

	// set value
	inline void Set(real re, real im) { m_Re = re; m_Im = im; }
	inline void Set(real re) { m_Re = re; m_Im = 0; }
	inline void Set(const complex* src) { m_Re = src->m_Re; m_Im = src->m_Im; }
	inline void Set(const complex& src) { m_Re = src.m_Re; m_Im = src.m_Im; }
	inline complex& operator= (const complex& src) { m_Re = src.m_Re; m_Im = src.m_Im; return *this; }
	inline complex& operator= (real re) { m_Re = re; m_Im = 0; return *this; }

	// compare
	inline bool Equ(const complex& src) const { return (m_Re == src.m_Re) && (m_Im == src.m_Im); }
	inline bool Equ(real re) const { return (m_Re == re) && (m_Im == 0); }
	inline bool operator== (const complex& src) const { return (m_Re == src.m_Re) && (m_Im == src.m_Im); }
	inline bool operator== (real re) const { return (m_Re == re) && (m_Im == 0); }
	inline bool operator!= (const complex& src) const { return (m_Re != src.m_Re) || (m_Im != src.m_Im); }
	inline bool operator!= (real re) const { return (m_Re != re) || (m_Im != 0); }
	inline friend bool operator== (const complex& src1, const complex& src2)
		{ return (src1.m_Re == src2.m_Re) && (src1.m_Im == src2.m_Im); }
	inline friend bool operator!= (const complex& src1, const complex& src2)
		{ return (src1.m_Re != src2.m_Re) || (src1.m_Im != src2.m_Im); }

	// power of 2 (Z^2)
	// (re+im*i)*(re+im*i) = (re*re-im*im) + 2*re*im*i
	inline void Pow2()
	{
		real re = m_Re;
		m_Re = re*re - m_Im*m_Im;
		m_Im = 2*re*m_Im;
	}

	// power of 3 (Z^3)
	// (re+im*i)*(re+im*i)*(re+im*i) = (re*re - im*im + 2*re*im*i)*(re+im*i) =
	// = re*re*re - re*im*im + 2*re*re*im*i + re*re*im*i - im*im*im*i - 2*re*im*im =
	// = (re*re*re - 3*re*im*im) + (3*re*re*im - im*im*im)*i
	inline void Pow3()
	{
		real re2 = m_Re*m_Re;
		real im2 = m_Im*m_Im;
		m_Re = (re2 - 3*im2)*m_Re;
		m_Im = (3*re2 - im2)*m_Im;
	}

	// power of 4 (Z^4)
	inline void Pow4()
	{
		real re = m_Re;
		real im = m_Im;

		// Z^2
		real re2 = re*re - im*im;
		real im2 = 2*re*im;

		// Z^2
		m_Re = re2*re2 - im2*im2;
		m_Im = 2*re2*im2;
	}

	// power of 5 (Z^5)
	inline void Pow5()
	{
		real re = m_Re;
		real im = m_Im;

		// Z^2
		real re2 = re*re - im*im;
		real im2 = 2*re*im;

		// Z^2
		real re3 = re2*re2 - im2*im2;
		real im3 = 2*re2*im2;

		// Z*Z0
		m_Re = re3*re - im3*im;
		m_Im = re3*im + im3*re;
	}

	// power of 6 (Z^6)
	inline void Pow6()
	{
		// Z^3
		real re2 = m_Re*m_Re;
		real im2 = m_Im*m_Im;
		real re3 = (re2 - 3*im2)*m_Re;
		real im3 = (3*re2 - im2)*m_Im;

		// Z^2
		m_Re = re3*re3 - im3*im3;
		m_Im = 2*re3*im3;
	}

	// power of 7 (Z^7)
	inline void Pow7()
	{
		real re = m_Re;
		real im = m_Im;

		// Z^3
		real re2 = re*re;
		real im2 = im*im;
		real re3 = (re2 - 3*im2)*re;
		real im3 = (3*re2 - im2)*im;

		// Z^2
		re2 = re3*re3 - im3*im3;
		im2 = 2*re3*im3;

		// Z*Z0
		m_Re = re2*re - im2*im;
		m_Im = re2*im + im2*re;
	}

	// power of 8 (Z^8)
	inline void Pow8()
	{
		real re = m_Re;
		real im = m_Im;

		// Z^2
		real re2 = re*re - im*im;
		real im2 = 2*re*im;

		// Z^2
		re = re2*re2 - im2*im2;
		im = 2*re2*im2;

		// Z^2
		m_Re = re*re - im*im;
		m_Im = 2*re*im;
	}

	// power of 9 (Z^9)
	inline void Pow9()
	{
		// Z^3
		real re2 = m_Re*m_Re;
		real im2 = m_Im*m_Im;
		real re3 = (re2 - 3*im2)*m_Re;
		real im3 = (3*re2 - im2)*m_Im;

		// Z^3
		re2 = re3*re3;
		im2 = im3*im3;
		m_Re = (re2 - 3*im2)*re3;
		m_Im = (3*re2 - im2)*im3;
	}

	// power of 10 (Z^10)
	inline void Pow10()
	{
		real re = m_Re;
		real im = m_Im;

		// Z^2
		real re2 = re*re - im*im;
		real im2 = 2*re*im;

		// Z^2
		real re3 = re2*re2 - im2*im2;
		real im3 = 2*re2*im2;

		// Z*Z0
		re2 = re3*re - im3*im;
		im2 = re3*im + im3*re;

		// Z^2
		m_Re = re2*re2 - im2*im2;
		m_Im = 2*re2*im2;
	}

	// power of 11 (Z^11)
	inline void Pow11()
	{
		real re = m_Re;
		real im = m_Im;

		// Z^2
		real re2 = re*re - im*im;
		real im2 = 2*re*im;

		// Z^2
		real re3 = re2*re2 - im2*im2;
		real im3 = 2*re2*im2;

		// Z*Z0
		re2 = re3*re - im3*im;
		im2 = re3*im + im3*re;

		// Z^2
		re3 = re2*re2 - im2*im2;
		im3 = 2*re2*im2;

		// Z*Z0
		m_Re = re3*re - im3*im;
		m_Im = re3*im + im3*re;
	}

	// power of 12 (Z^12)
	inline void Pow12()
	{
		real re = m_Re;
		real im = m_Im;

		// Z^2
		real re2 = re*re - im*im;
		real im2 = 2*re*im;

		// Z^2
		re = re2*re2 - im2*im2;
		im = 2*re2*im2;

		// Z^3
		re2 = re*re;
		im2 = im*im;
		m_Re = (re2 - 3*im2)*re;
		m_Im = (3*re2 - im2)*im;
	}

	// add value
	inline void Add(real re, real im) { m_Re += re; m_Im += im; }
	inline void Add(real re) { m_Re += re; }
	inline void Add(const complex* src) { m_Re += src->m_Re; m_Im += src->m_Im; }
	inline void Add(const complex& src) { m_Re += src.m_Re; m_Im += src.m_Im; }
	inline void Add(const complex& src1, const complex& src2)
		{ m_Re = src1.m_Re + src2.m_Re; m_Im = src1.m_Im + src2.m_Im; }
	inline complex& operator+= (const complex& src) { m_Re += src.m_Re; m_Im += src.m_Im; return *this; }
	inline complex& operator+= (real re) { m_Re += re; return *this; }
	inline friend complex operator+ (const complex& src1, const complex& src2)
		{ return complex(src1.m_Re + src2.m_Re, src1.m_Im + src2.m_Im); }
	inline friend complex operator+ (const complex& src, real re)
		{ return complex(src.m_Re + re, src.m_Im); }

	// subtract value
	inline void Sub(real re, real im) { m_Re -= re; m_Im -= im; }
	inline void Sub(real re) { m_Re -= re; }
	inline void Sub(const complex* src) { m_Re -= src->m_Re; m_Im -= src->m_Im; }
	inline void Sub(const complex& src) { m_Re -= src.m_Re; m_Im -= src.m_Im; }
	inline void Sub(const complex& src1, const complex& src2)
		{ m_Re = src1.m_Re - src2.m_Re; m_Im = src1.m_Im - src2.m_Im; }
	inline complex& operator-= (const complex& src) { m_Re -= src.m_Re; m_Im -= src.m_Im; return *this; }
	inline complex& operator-= (real re) { m_Re -= re; return *this; }
	inline friend complex operator- (const complex& src1, const complex& src2)
		{ return complex(src1.m_Re - src2.m_Re, src1.m_Im - src2.m_Im); }
	inline friend complex operator- (const complex& src, real re)
		{ return complex(src.m_Re - re, src.m_Im); }

	// inverse subtract value
	inline void InvSub(real re, real im) { m_Re = re - m_Re; m_Im = im - m_Im; }
	inline void InvSub(real re) { m_Re = re - m_Re; m_Im = -m_Im; }
	inline void InvSub(const complex* src) { m_Re = src->m_Re - m_Re; m_Im = src->m_Im - m_Im; }
	inline void InvSub(const complex& src) { m_Re = src.m_Re - m_Re; m_Im = src.m_Im - m_Im; }

	// multiply value
	// (re1+im1*i)*(re2+im2*i) = (re1*re2-im1*im2) + (re1*im2+im1*re2)*i
	inline void Mul(real re, real im)
		{ real re0 = m_Re; m_Re = m_Re*re - m_Im*im; m_Im = re0*im + m_Im*re; }
	inline void Mul(real re) { m_Re *= re; m_Im *= re; }
	inline void Mul(const complex* src)
	{
		real re0 = m_Re;
		m_Re = m_Re*src->m_Re - m_Im*src->m_Im;
		m_Im = re0*src->m_Im + m_Im*src->m_Re;
	}
	inline void Mul(const complex& src)
	{
		real re0 = m_Re;
		m_Re = m_Re*src.m_Re - m_Im*src.m_Im;
		m_Im = re0*src.m_Im + m_Im*src.m_Re;
	}
	inline void Mul(const complex& src1, const complex& src2)
	{
		m_Re = src1.m_Re*src2.m_Re - src1.m_Im*src2.m_Im;
		m_Im = src1.m_Re*src2.m_Im + src1.m_Im*src2.m_Re;
	}
	inline complex& operator*= (const complex& src)
	{
		real re0 = m_Re;
		m_Re = m_Re*src.m_Re - m_Im*src.m_Im;
		m_Im = re0*src.m_Im + m_Im*src.m_Re;
		return *this;
	}
	inline complex& operator*= (real re) { m_Re *= re; m_Im *= re; return *this; }
	inline friend complex operator* (const complex& src1, const complex& src2)
		{ return complex(src1.m_Re*src2.m_Re - src1.m_Im*src2.m_Im,
				src1.m_Re*src2.m_Im + src1.m_Im*src2.m_Re); }
	inline friend complex operator* (const complex& src, real re)
		{ return complex(src.m_Re*re, src.m_Im*re); }

	// divide value
	// (re1+im1*i)/(re2+im2*i)=((re1+im1*i)*(re2-im2*i))/((re2+im2*i)*(re2-im2*i))=
	// =(re1*re2+re2*im1*i-re1*im2*i+im1*im2)/(re2*re2+re2*im2*i-re2*im2*i+im2*im2)=
	// =(re1*re2+im1*im2)/(re2*re2+im2*im2) + i*(re2*im1-re1*im2)/(re2*re2+im2*im2)
	inline void Div(real re, real im)
	{ 
		real d = 1/(re*re + im*im);
		real r = m_Re;
		m_Re = (m_Re*re + m_Im*im)*d;
		m_Im = (re*m_Im - r*im)*d;
	}
	inline void Div(real re) { m_Re /= re; m_Im /= re; }
	inline void Div(const complex* src)
	{ 
		real d = 1/(src->m_Re*src->m_Re + src->m_Im*src->m_Im);
		real r = m_Re;
		m_Re = (m_Re*src->m_Re + m_Im*src->m_Im)*d;
		m_Im = (src->m_Re*m_Im - r*src->m_Im)*d;
	}
	inline void Div(const complex& src)
	{ 
		real d = 1/(src.m_Re*src.m_Re + src.m_Im*src.m_Im);
		real r = m_Re;
		m_Re = (m_Re*src.m_Re + m_Im*src.m_Im)*d;
		m_Im = (src.m_Re*m_Im - r*src.m_Im)*d;
	}
	inline void Div(const complex& src1, const complex& src2)
	{ 
		real d = 1/(src2.m_Re*src2.m_Re + src2.m_Im*src2.m_Im);
		m_Re = (src1.m_Re*src2.m_Re + src1.m_Im*src2.m_Im)*d;
		m_Im = (src2.m_Re*src1.m_Im - src1.m_Re*src2.m_Im)*d;
	}
	inline complex& operator/= (const complex& src)
	{ 
		real d = 1/(src.m_Re*src.m_Re + src.m_Im*src.m_Im);
		real r = m_Re;
		m_Re = (m_Re*src.m_Re + m_Im*src.m_Im)*d;
		m_Im = (src.m_Re*m_Im - r*src.m_Im)*d;
		return *this;
	}
	inline friend complex operator/ (const complex& src1, const complex& src2)
	{ 
		real d = 1/(src2.m_Re*src2.m_Re + src2.m_Im*src2.m_Im);
		return complex((src1.m_Re*src2.m_Re + src1.m_Im*src2.m_Im)*d,
				(src2.m_Re*src1.m_Im - src1.m_Re*src2.m_Im)*d);
	}
	inline friend complex operator/ (const complex& src, real re)
		{ real d = 1/re; return complex(src.m_Re*d, src.m_Im*d); }

	// inverse divide value
	inline void InvDiv(real re, real im)
	{ 
		real d = 1/(m_Re*m_Re + m_Im*m_Im);
		real r = m_Re;
		m_Re = (m_Re*re + m_Im*im)*d;
		m_Im = (r*im - re*m_Im)*d;
	}
	inline void InvDiv(const complex* src)
	{ 
		real d = 1/(m_Re*m_Re + m_Im*m_Im);
		real r = m_Re;
		m_Re = (m_Re*src->m_Re + m_Im*src->m_Im)*d;
		m_Im = (r*src->m_Im - src->m_Re*m_Im)*d;
	}
	inline void InvDiv(const complex& src)
	{ 
		real d = 1/(m_Re*m_Re + m_Im*m_Im);
		real r = m_Re;
		m_Re = (m_Re*src.m_Re + m_Im*src.m_Im)*d;
		m_Im = (r*src.m_Im - src.m_Re*m_Im)*d;
	}

	// reciprocal value 1/Z
	// 1/(re+im*i)=(re-im*i)/((re+im*i)*(re-im*i))=
	// =(re-im*i)/(re*re+re*im*i-re*im*i+im*im)=
	// =re/(re*re+im*im) - i*im/(re*re+im*im)
	inline void Recip()
	{ 
		real d = 1/(m_Re*m_Re + m_Im*m_Im);
		m_Re *= d;
		m_Im *= -d;
	}
};
