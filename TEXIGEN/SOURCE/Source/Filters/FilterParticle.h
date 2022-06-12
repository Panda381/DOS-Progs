
///////////////////////////////////////////////////////////////////////////////
//
//                            Particle Generator
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// particle generator
class CFilterParticle : public CFilterSource5
{
private:

	// current particle coordinates and band
	real	m_ParticleX;
	real	m_ParticleY;
	int		m_Band;

public:

	// constructor
	CFilterParticle();

	// duplicate filter
	FILTER_DUPLICATE(CFilterParticle);

	// current particle coordinates and band
	inline real ParticleX() const { return m_ParticleX; }
	inline real ParticleY() const { return m_ParticleY; }
	inline int Band() const { return m_Band; }

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// particle X filter
class CFilterParticleX : public CFilterSource
{
public:

	// constructor
	CFilterParticleX();

	// duplicate filter
	FILTER_DUPLICATE(CFilterParticleX);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

// particle Y filter
class CFilterParticleY : public CFilterSource
{
public:

	// constructor
	CFilterParticleY();

	// duplicate filter
	FILTER_DUPLICATE(CFilterParticleY);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define	PROP_PARTRND_MIN	1		// property - Min
#define	PROP_PARTRND_MAX	2		// property - Max
#define PROP_PARTRND_SEED	3		// property - Seed

// particle random filter
class CFilterParticleRnd : public CFilterSource
{
public:

	// constructor
	CFilterParticleRnd();

	// duplicate filter
	FILTER_DUPLICATE(CFilterParticleRnd);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
