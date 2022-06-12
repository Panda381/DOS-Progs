
///////////////////////////////////////////////////////////////////////////////
//
//                           Debug Filters
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterGraph::CFilterGraph()
{
	m_Group = FGRP_DEBUG;
	m_Class = _T("Graph");
	m_HelpID = HELP_FGRAPH;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterGraph::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterGraph::RenderVal(real x, real y)
{
	real val = m_Prop[PROP_SOURCE].RenderVal(x, y);
	return (real)((y >= val) ? 0 : 1);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterHistogram::CFilterHistogram()
{
	m_Group = FGRP_DEBUG;
	m_Class = _T("Histogram");
	m_HelpID = HELP_FHISTOGRAM;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterHistogram::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(RenderVal(x, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterHistogram::RenderVal(real x, real y)
{
	// restart filter
	if (m_Restart)
	{
		m_Restart = FALSE;

		// clear image statistic
		memset (m_Hist, 0, HISTVALS*sizeof(int));
		m_HistMax = 0;

		// get image statistic
		real x2, y2;
		real val;
		int n, k;
		for (y2 = HISTINC/2; y2 < 1; y2 += HISTINC)
		{
			for (x2 = HISTINC/2; x2 < 1; x2 += HISTINC)
			{
				val = m_Prop[PROP_SOURCE].RenderVal(x2, y2);
				n = (int)(val * HISTVALS);
				if (n < 0) n = 0;
				if (n > HISTVALS-1) n = HISTVALS-1;
				k = m_Hist[n] + 1;
				m_Hist[n] = k;
				if (k > m_HistMax) m_HistMax = k;
			}
		}
	}

	// render histogram
	int n = (int)(x * HISTVALS);
	if (n < 0) n = 0;
	if (n > HISTVALS-1) n = HISTVALS-1;
	return (real)(((int)(y * m_HistMax) > m_Hist[n]) ? 1 : 0);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterHistogramRGB::CFilterHistogramRGB()
{
	m_Group = FGRP_DEBUG;
	m_Class = _T("HistogramRGB");
	m_HelpID = HELP_FHISTOGRAMRGB;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterHistogramRGB::RenderCol(CColor* col, real x, real y)
{
	// restart filter
	if (m_Restart)
	{
		m_Restart = FALSE;

		// clear image statistic
		memset (m_HistR, 0, HISTVALS*sizeof(int));
		memset (m_HistG, 0, HISTVALS*sizeof(int));
		memset (m_HistB, 0, HISTVALS*sizeof(int));
		m_HistMax = 0;

		// get image statistic
		real x2, y2;
		CColor col;
		int n, k;
		for (y2 = HISTINC/2; y2 < 1; y2 += HISTINC)
		{
			for (x2 = HISTINC/2; x2 < 1; x2 += HISTINC)
			{
				m_Prop[PROP_SOURCE].RenderCol(&col, x2, y2);

				// Red
				n = (int)(col.r * HISTVALS);
				if (n < 0) n = 0;
				if (n > HISTVALS-1) n = HISTVALS-1;
				k = m_HistR[n] + 1;
				m_HistR[n] = k;
				if (k > m_HistMax) m_HistMax = k;

				// Green
				n = (int)(col.g * HISTVALS);
				if (n < 0) n = 0;
				if (n > HISTVALS-1) n = HISTVALS-1;
				k = m_HistG[n] + 1;
				m_HistG[n] = k;
				if (k > m_HistMax) m_HistMax = k;

				// Blue
				n = (int)(col.b * HISTVALS);
				if (n < 0) n = 0;
				if (n > HISTVALS-1) n = HISTVALS-1;
				k = m_HistB[n] + 1;
				m_HistB[n] = k;
				if (k > m_HistMax) m_HistMax = k;
			}
		}
	}

	// render histogram
	int n = (int)(x * HISTVALS);
	if (n < 0) n = 0;
	if (n > HISTVALS-1) n = HISTVALS-1;
	int k = (int)(y * m_HistMax);
	col->r = (real)((k > m_HistR[n]) ? 0 : 1);
	col->g = (real)((k > m_HistG[n]) ? 0 : 1);
	col->b = (real)((k > m_HistB[n]) ? 0 : 1);
	col->a = 1;
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterHistogramRGB::RenderVal(real x, real y)
{
	CColor col;
	CFilterHistogramRGB::RenderCol(&col, x, y);
	return col.Gray();
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterX::CFilterX()
{
	m_Group = FGRP_DEBUG;
	m_Category = FCAT_SYS;
	m_Class = _T("X");
	m_HelpID = HELP_FX;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterX::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CurRenderX);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterX::RenderVal(real x, real y)
{
	return CurRenderX;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterY::CFilterY()
{
	m_Group = FGRP_DEBUG;
	m_Category = FCAT_SYS;
	m_Class = _T("Y");
	m_HelpID = HELP_FY;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterY::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CurRenderY);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterY::RenderVal(real x, real y)
{
	return CurRenderY;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDX::CFilterDX()
{
	m_Group = FGRP_DEBUG;
	m_Category = FCAT_SYS;
	m_Class = _T("DX");
	m_HelpID = HELP_FDX;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDX::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CurRenderDX);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDX::RenderVal(real x, real y)
{
	return CurRenderDX;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDY::CFilterDY()
{
	m_Group = FGRP_DEBUG;
	m_Category = FCAT_SYS;
	m_Class = _T("DY");
	m_HelpID = HELP_FDY;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDY::RenderCol(CColor* col, real x, real y)
{
	col->SetGray(CurRenderDY);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDY::RenderVal(real x, real y)
{
	return CurRenderDY;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTime::CFilterTime()
{
	m_Group = FGRP_DEBUG;
	m_Category = FCAT_SYS;
	m_Class = _T("Time");
	m_HelpID = HELP_FTIME;
	m_PropNum = 1;

	m_Prop[PROP_SOURCE].SetCategory(PCAT_CURVE);
	m_Prop[PROP_SOURCE].SetName("Profile");
	m_Prop[PROP_SOURCE].SetFilter(&FLinear);
	m_Prop[PROP_SOURCE].SetToolID(ID_PROP_TIMEPROFILE);
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTime::RenderCol(CColor* col, real x, real y)
{
	real val;
	if (RenderMode)
		val = (RenderFrames > 0) ? ((real)RenderFrame/RenderFrames) : 0;
	else if (PreviewMode)
		val = PreviewTime;
	else
		val = 0;
	col->SetGray(m_Prop[PROP_SOURCE].RenderVal(val, y));
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTime::RenderVal(real x, real y)
{
	real val;
	if (RenderMode)
		val = (RenderFrames > 0) ? ((real)RenderFrame/RenderFrames) : 0;
	else if (PreviewMode)
		val = PreviewTime;
	else
		val = 0;
	return m_Prop[PROP_SOURCE].RenderVal(val, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTimeDelta::CFilterTimeDelta()
{
	m_Group = FGRP_DEBUG;
	m_Category = FCAT_SYS;
	m_Class = _T("TimeDelta");
	m_HelpID = HELP_FTIMEDELTA;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTimeDelta::RenderCol(CColor* col, real x, real y)
{
	if (RenderMode)
		col->SetGray((RenderFrames > 0) ? ((real)1/RenderFrames) : 0);
	else if (PreviewMode)
		col->SetGray((real)1/100);
	else
		col->SetGray(1);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTimeDelta::RenderVal(real x, real y)
{
	if (RenderMode)
		return (RenderFrames > 0) ? ((real)1/RenderFrames) : 0;
	else if (PreviewMode)
		return (real)1/100;
	else
		return 1;
}
