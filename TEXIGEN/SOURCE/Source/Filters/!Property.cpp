
///////////////////////////////////////////////////////////////////////////////
//
//                              Base Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// get derivation in X and Y directiony (returns average height level)

real CProperty::Derive(real x, real y, real* dx, real* dy)
{
#define DDERIV	(real)(1.0/10000)	// delta of derivation

	//real v0 = this->RenderVal(x, y);
	//real vx = this->RenderVal(x + DDERIV, y);
	//real vy = this->RenderVal(x, y + DDERIV);

	//*dx = (vx - v0)*2;
	//*dy = (vy - v0)*2;

	real v11 = this->RenderVal(x - DDERIV, y - DDERIV);
	real v12 = this->RenderVal(x - DDERIV, y + DDERIV);
	real v21 = this->RenderVal(x + DDERIV, y - DDERIV);
	real v22 = this->RenderVal(x + DDERIV, y + DDERIV);

	real vx1 = (v11 + v12)/2;
	real vx2 = (v21 + v22)/2;
	real vy1 = (v11 + v21)/2;
	real vy2 = (v12 + v22)/2;

	*dx = (vx2 - vx1)/2;
	*dy = (vy2 - vy1)/2;
	real v0 = (vx2 + vx1)/2;

	return v0;
}

///////////////////////////////////////////////////////////////////////////////
// render color with default value (if m_Filter = NULL)

void CProperty::_RenderColD(CColor* col, real x, real y)
{
	col->Set(m_Color);
}

///////////////////////////////////////////////////////////////////////////////
// render color with filter (coordinates and output are typically in range 0..1)

void CProperty::_RenderColF(CColor* col, real x, real y)
{
	m_Filter->RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value with default value (if m_Filter = NULL)

real CProperty::_RenderValD(real x, real y)
{
	return m_Value;
}

///////////////////////////////////////////////////////////////////////////////
// render value with filter (coordinates and output are typically in range 0..1)

real CProperty::_RenderValF(real x, real y)
{
	return m_Filter->RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CProperty::CProperty()
{
	m_Parent = NULL;
	m_Category = PCAT_VAL;
	m_ToolID = -1;
	m_Filter = NULL;
	m_Color.SetBlack();
	m_Value = 0;
	m_Min = 0;
	m_MinVal = 0;
	m_Max = 100;
	m_MaxVal = 1;
	m_EnumNum = 0;
	m_Enum = NULL;
	pRenderCol = &CProperty::_RenderColD;
	pRenderVal = &CProperty::_RenderValD;
}

///////////////////////////////////////////////////////////////////////////////
// set source filter (NULL=use default value)

void CProperty::SetFilter(CFilter* filter)
{
	if ((filter == NULL) && ((m_Category == PCAT_CURVE) || (m_Category == PCAT_GRAD))) filter = &FLinear;

	m_Filter = filter;
	if (filter == NULL)
	{
		pRenderCol = &CProperty::_RenderColD;
		pRenderVal = &CProperty::_RenderValD;
	}
	else
	{
		pRenderCol = &CProperty::_RenderColF;
		pRenderVal = &CProperty::_RenderValF;
	}
}

///////////////////////////////////////////////////////////////////////////////
// set list of enumeration entries (list is terminated with empty string)

void CProperty::SetEnum(CText* list)
{
	m_Enum = list;
	int n = 0;
	while (list[n].IsNotEmpty()) n++;
	m_EnumNum = n;
}
