	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                                Material Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define PROP_MAT_MATERIAL	1		// property - Material
#define PROP_MAT_CONTRAST	2		// property - Contrast
#define PROP_MAT_ROUGH		3		// property - Roughness
#define PROP_MAT_ROTATE		4		// property - Rotate
#define PROP_MAT_SEED		5		// property - Seed (seed for random generator 0..1; in 0.001 steps, default 0)

// material filter
class CFilterMaterial : public CFilterSource
{
protected:

	CFilterMul		m_Mul;
	CFilterInterval	m_Interval;
	CFilterAdd		m_Add;
	CFilterSub		m_Sub;
	CFilterRecolor	m_Recolor1;
	CFilterRecolor	m_Recolor2;
	CFilterMul		m_Mul2;
	CFilterWood		m_Wood;
	CFilterMetal	m_Metal;
	CFilterGlass	m_Glass;
	CFilterMalachite m_Malachite;
	CFilterMarble	m_Marble;
	CFilterGranite	m_Granite;
	CFilterCracks	m_Cracks;
	CFilterFabric	m_Fabric;
	CFilterAdd		m_Add2;
	CFilterThreshold10 m_Threshold10;
	CFilterSeamlessRotate m_SeamlessRotate;

public:

	// constructor
	CFilterMaterial();

	// duplicate filter
	FILTER_DUPLICATE(CFilterMaterial);

	// render color (coordinates and output are typically in range 0..1)
	virtual void RenderCol(CColor* col, real x, real y);

	// render value (coordinates and output are typically in range 0..1)
	virtual real RenderVal(real x, real y);
};
