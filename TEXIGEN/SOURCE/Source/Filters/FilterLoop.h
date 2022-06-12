	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                              Loop Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define LOOPMAX	100			// max. loops

#define PROP_LOOP_END		1	// property - LoopEnd
#define PROP_LOOP_NUM		2	// property - Loops

// loop start filter
class CFilterLoopBegin : public CFilterSource2
{
protected:

	// number of loops
	int		m_LoopNum;

	// loop increment (= 1/(m_LoopNum-1))
	real	m_LoopInc;

	// loop minimum (= m_LoopInc/2)
	real	m_LoopMin;

	// loop maximum (= 1 - m_LoopInc/2)
	real	m_LoopMax;

	// loop index (in range 0..1)
	real	m_LoopInx;

public:

	// constructor
	CFilterLoopBegin();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLoopBegin);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);

	// number of loops
	inline int LoopNum() const { return m_LoopNum; }
	void InitLoopNum(real x, real y);

	// loop index (in range 0..1)
	inline real LoopInx() const { return m_LoopInx; }
	inline void AddLoopInx() { m_LoopInx += m_LoopInc; }
	inline real LoopMax() const { return m_LoopMax; }
};

// loop stop filter
class CFilterLoopEnd : public CFilterSource
{
protected:

	// linked loop start filter
	CFilterLoopBegin*	m_LoopBegin;

	// flag - re-enter from loop
	BOOL				m_LoopEnter;

	// recursion find start filter (returns TRUE=break)
	BOOL FindLoopBegin(CFilter* f, int* level);

	// previous accumulated value
	CColor				m_LoopPrevCol;
	real				m_LoopPrevVal;

public:

	// constructor
	CFilterLoopEnd();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLoopEnd);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);

	// linked loop start filter
	inline CFilterLoopBegin* LoopBegin() const { return m_LoopBegin; }
	inline void SetLoopBegin(CFilterLoopBegin* f) { m_LoopBegin = f; }

	// flag - re-entered from loop
	inline BOOL LoopEnter() const { return m_LoopEnter; }
	inline void SetLoopEnter(BOOL set) { m_LoopEnter = set; }

};

// loop index filter
class CFilterLoopIndex : public CFilterSource
{
public:

	// constructor
	CFilterLoopIndex();

	// duplicate filter
	FILTER_DUPLICATE(CFilterLoopIndex);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
