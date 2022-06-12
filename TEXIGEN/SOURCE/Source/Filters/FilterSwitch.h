	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                           Switch Sources
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// 2-step color channel switch filter
class CFilterSwitchChan : public CFilterSource2
{
public:

	// constructor
	CFilterSwitchChan();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitchChan);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH2_SWITCH	2	// property - Switch (0..1; 0=src1..1=src2; default 0.5)

// 2-step switch filter
class CFilterSwitch2 : public CFilterSource2
{
public:

	// constructor
	CFilterSwitch2();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch2);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH3_SWITCH	3	// property - Switch (0..1; 0=src1,0.5=src2,1=src3; default 0.5)

// 3-step switch filter
class CFilterSwitch3 : public CFilterSource3
{
public:

	// constructor
	CFilterSwitch3();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch3);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH4_SWITCH	4	// property - Switch (0..1; 0=src1,0.33=src2,0.67=src3,1=src4; default 0.5)

// 4-step switch filter
class CFilterSwitch4 : public CFilterSource4
{
public:

	// constructor
	CFilterSwitch4();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch4);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH5_SWITCH	5	// property - Switch (0..1; 0=src1,0.25=src2,...1=src5; default 0.5)

// 5-step switch filter
class CFilterSwitch5 : public CFilterSource5
{
public:

	// constructor
	CFilterSwitch5();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch5);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH6_SWITCH	6	// property - Switch (0..1; 0=src1,0.2=src2,...1=src6; default 0.5)

// 6-step switch filter
class CFilterSwitch6 : public CFilterSource6
{
public:

	// constructor
	CFilterSwitch6();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch6);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH7_SWITCH	7	// property - Switch (0..1; 0=src1,0.17=src2,...1=src7; default 0.5)

// 7-step switch filter
class CFilterSwitch7 : public CFilterSource7
{
public:

	// constructor
	CFilterSwitch7();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch7);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH8_SWITCH	8	// property - Switch (0..1; 0=src1,0.14=src2,...1=src8; default 0.5)

// 8-step switch filter
class CFilterSwitch8 : public CFilterSource8
{
public:

	// constructor
	CFilterSwitch8();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch8);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH9_SWITCH	9	// property - Switch (0..1; 0=src1,0.125=src2,...1=src9; default 0.5)

// 9-step switch filter
class CFilterSwitch9 : public CFilterSource9
{
public:

	// constructor
	CFilterSwitch9();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch9);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};

#define PROP_SWITCH10_SWITCH	10	// property - Switch (0..1; 0.11=src1,0.22=src2,...1=src10; default 0.5)

// 10-step switch filter
class CFilterSwitch10 : public CFilterSource10
{
public:

	// constructor
	CFilterSwitch10();

	// duplicate filter
	FILTER_DUPLICATE(CFilterSwitch10);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
