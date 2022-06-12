	   				   
///////////////////////////////////////////////////////////////////////////////
//
//                              Loop Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLoopBegin::CFilterLoopBegin()
{
	m_Group = FGRP_DEBUG;
	m_Class = _T("LoopBegin");
	m_HelpID = HELP_FLOOPBEGIN;
	m_Category = FCAT_LOOPBEGIN;
	m_PropNum = 3;

	m_LoopNum = 10;
	m_LoopInc = (real)1/9;
	m_LoopMin = m_LoopInc/2;
	m_LoopMax = 1 + m_LoopInc/2;
	m_LoopInx = 0;

	m_Prop[PROP_LOOP_END].SetCategory(PCAT_LOOPEND);
	m_Prop[PROP_LOOP_END].SetName("LoopEnd");
	m_Prop[PROP_LOOP_END].SetToolID(ID_PROP_LOOPEND);

	m_Prop[PROP_LOOP_NUM].SetName("Loops");
	m_Prop[PROP_LOOP_NUM].SetValue((real)0.1);
	m_Prop[PROP_LOOP_NUM].SetToolID(ID_PROP_LOOPNUM);
	m_Prop[PROP_LOOP_NUM].SetMinVal((real)0.01);
	m_Prop[PROP_LOOP_NUM].SetMin(1);
}

///////////////////////////////////////////////////////////////////////////////
// initialize loop number

void CFilterLoopBegin::InitLoopNum(real x, real y)
{
	int num = (int)(m_Prop[PROP_LOOP_NUM].RenderVal(x, y)*100 + (real)0.5);
	if (num < 1) num = 1;
	if (num > LOOPMAX) num = LOOPMAX;
	m_LoopNum = num;
	if (num <= 1)
	{
		m_LoopInc = 1;
		m_LoopMax = 1 - m_LoopInc/2;
	}
	else
	{
		m_LoopInc = (real)1/(num-1);
		m_LoopMax = 1 + m_LoopInc/2;
	}
	m_LoopMin = m_LoopInc/2;
	m_LoopInx = 0;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLoopBegin::RenderCol(CColor* col, real x, real y)
{
	// restart counter
	if (m_Restart)
	{
		m_Restart = FALSE;
		this->InitLoopNum(x, y);
	}

	// first iteration
	CFilter* f = m_Prop[PROP_LOOP_END].Filter();
	if ((m_LoopInx < m_LoopMin) || (f == NULL) || (f->Category() != FCAT_LOOPEND) ||
		(((CFilterLoopEnd*)f)->LoopBegin() != this))
	{
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	}

	// repeat loop iterations
	else
	{
		((CFilterLoopEnd*)f)->SetLoopEnter(TRUE);
		m_Prop[PROP_LOOP_END].RenderCol(col, x, y);
	}
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLoopBegin::RenderVal(real x, real y)
{
	// restart counter
	if (m_Restart)
	{
		m_Restart = FALSE;
		this->InitLoopNum(x, y);
	}

	// end of loop
	CFilter* f = m_Prop[PROP_LOOP_END].Filter();
	if ((m_LoopInx < m_LoopMin) || (f == NULL) || (f->Category() != FCAT_LOOPEND) ||
		(((CFilterLoopEnd*)f)->LoopBegin() != this))
	{
		return m_Prop[PROP_SOURCE].RenderVal(x, y);
	}

	// repeat loop
	else
	{
		((CFilterLoopEnd*)f)->SetLoopEnter(TRUE);
		return m_Prop[PROP_LOOP_END].RenderVal(x, y);
	}
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLoopEnd::CFilterLoopEnd()
{
	m_Group = FGRP_DEBUG;
	m_Class = _T("LoopEnd");
	m_HelpID = HELP_FLOOPEND;
	m_Category = FCAT_LOOPEND;

	m_LoopBegin = NULL;
	m_LoopEnter = FALSE;
	m_LoopPrevCol.SetBlack();
	m_LoopPrevVal = 0;
}

///////////////////////////////////////////////////////////////////////////////
// recursion find start filter (returns TRUE=break)

BOOL CFilterLoopEnd::FindLoopBegin(CFilter* f, int* level)
{
	(*level)++;
	if (*level > 100)
	{
		(*level)--;
		return FALSE;
	}
	int i;
	CFilter* f2;
	CProperty* p = f->Prop(0);
	for (i = f->PropNum(); i > 0; i--)
	{
		f2 = p->Filter();
		if ((f2 != NULL) && (f2 != &FLinear) && (f2 != this))
		{
			if ((f2->Category() == FCAT_LOOPBEGIN) &&
				(f2->Prop(PROP_LOOP_END)->Filter() == this))
			{
				m_LoopBegin = (CFilterLoopBegin*)f2;
				(*level)--;
				return TRUE;
			}
			if (this->FindLoopBegin(f2, level))
			{
				(*level)--;
				return TRUE;
			}
		}
		p++;
	}
	(*level)--;
	return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLoopEnd::RenderCol(CColor* col, real x, real y)
{
	// find linked loop stop filter
	if (m_Restart)
	{
		m_Restart = FALSE;
		m_LoopBegin = NULL;
		m_LoopEnter = FALSE;
		m_LoopPrevCol.SetBlack();
		m_LoopPrevVal = 0;
		int level = 0;
		this->FindLoopBegin(this, &level);
		if (m_LoopBegin != NULL) m_LoopBegin->InitLoopNum(x, y);
	}

	// loop
	if (m_LoopBegin != NULL)
	{
		if (!m_LoopEnter)
		{
			m_LoopBegin->InitLoopNum(x, y);
			while (m_LoopBegin->LoopInx() < m_LoopBegin->LoopMax())
			{
				m_Prop[PROP_SOURCE].RenderCol(&m_LoopPrevCol, x, y);
				m_LoopPrevVal = m_LoopPrevCol.Gray();
				if (m_Restart || (m_LoopBegin == NULL)) break;
				m_LoopBegin->AddLoopInx();
			}
		}
		m_LoopEnter = FALSE;
		col->Set(m_LoopPrevCol);
		return;
	}
	m_LoopEnter = FALSE;

	// render color
	m_Prop[PROP_SOURCE].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLoopEnd::RenderVal(real x, real y)
{
	// find linked loop stop filter
	if (m_Restart)
	{
		m_Restart = FALSE;
		m_LoopBegin = NULL;
		m_LoopEnter = FALSE;
		m_LoopPrevCol.SetBlack();
		m_LoopPrevVal = 0;
		int level = 0;
		this->FindLoopBegin(this, &level);
		if (m_LoopBegin != NULL) m_LoopBegin->InitLoopNum(x, y);
	}

	// loop
	if (m_LoopBegin != NULL)
	{
		if (!m_LoopEnter)
		{
			m_LoopBegin->InitLoopNum(x, y);
			while (m_LoopBegin->LoopInx() < m_LoopBegin->LoopMax())
			{
				m_LoopPrevVal = m_Prop[PROP_SOURCE].RenderVal(x, y);
				m_LoopPrevCol.SetGray(m_LoopPrevVal);
				if (m_Restart || (m_LoopBegin == NULL)) break;
				m_LoopBegin->AddLoopInx();
			}
		}
		m_LoopEnter = FALSE;
		return m_LoopPrevVal;
	}
	m_LoopEnter = FALSE;

	// render value
	return m_Prop[PROP_SOURCE].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterLoopIndex::CFilterLoopIndex()
{
	m_Group = FGRP_DEBUG;
	m_Class = _T("LoopIndex");
	m_HelpID = HELP_FLOOPINDEX;

	m_Prop[PROP_SOURCE].SetCategory(PCAT_LOOPBEGIN);
	m_Prop[PROP_SOURCE].SetName("LoopBegin");
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_LOOPBEGIN);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterLoopIndex::RenderCol(CColor* col, real x, real y)
{
	CFilter* f = m_Prop[PROP_SOURCE].Filter();
	if ((f != NULL) && (f->Category() == FCAT_LOOPBEGIN))
		col->SetGray(((CFilterLoopBegin*)f)->LoopInx());
	else
		col->SetBlack();
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterLoopIndex::RenderVal(real x, real y)
{
	CFilter* f = m_Prop[PROP_SOURCE].Filter();
	if ((f != NULL) && (f->Category() == FCAT_LOOPBEGIN))
		return ((CFilterLoopBegin*)f)->LoopInx();
	else
		return 0;
}
