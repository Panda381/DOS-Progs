
///////////////////////////////////////////////////////////////////////////////
//
//                               Duo Filter
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDuo::CFilterDuo()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Duo");
	m_HelpID = HELP_FDUO;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDuo::RenderCol(CColor* col, real x, real y)
{
	x *= 2;
	if (x < 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		m_Prop[PROP_SOURCE2].RenderCol(col, x - 1, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDuo::RenderVal(real x, real y)
{
	x *= 2;
	if (x < 1)
		return m_Prop[PROP_SOURCE].RenderVal(x, y);
	else
		return m_Prop[PROP_SOURCE2].RenderVal(x - 1, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterTrio::CFilterTrio()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Trio");
	m_HelpID = HELP_FTRIO;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterTrio::RenderCol(CColor* col, real x, real y)
{
	x *= 3;
	if (x < 1)
		m_Prop[PROP_SOURCE].RenderCol(col, x, y);
	else
		if (x < 2)
			m_Prop[PROP_SOURCE2].RenderCol(col, x - 1, y);
		else
			m_Prop[PROP_SOURCE3].RenderCol(col, x - 2, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterTrio::RenderVal(real x, real y)
{
	x *= 3;
	if (x < 1)
		return m_Prop[PROP_SOURCE].RenderVal(x, y);
	else
		if (x < 2)
			return m_Prop[PROP_SOURCE2].RenderVal(x - 1, y);
		else
			return m_Prop[PROP_SOURCE3].RenderVal(x - 2, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterDiaQuattro::CFilterDiaQuattro()
{
	m_Group = FGRP_MUX;
	m_Class = _T("DiaQuattro");
	m_HelpID = HELP_FDIAQUATTRO;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterDiaQuattro::RenderCol(CColor* col, real x, real y)
{
	if (x > 1 - y)
		if (y > x)
			m_Prop[PROP_SOURCE].RenderCol(col, x, y);
		else
			m_Prop[PROP_SOURCE2].RenderCol(col, x, y);
	else
		if (y < x)
			m_Prop[PROP_SOURCE3].RenderCol(col, x, y);
		else
			m_Prop[PROP_SOURCE4].RenderCol(col, x, y);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterDiaQuattro::RenderVal(real x, real y)
{
	if (x > 1 - y)
		if (y > x)
			return m_Prop[PROP_SOURCE].RenderVal(x, y);
		else
			return m_Prop[PROP_SOURCE2].RenderVal(x, y);
	else
		if (y < x)
			return m_Prop[PROP_SOURCE3].RenderVal(x, y);
		else
			return m_Prop[PROP_SOURCE4].RenderVal(x, y);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterQuattro::CFilterQuattro()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Quattro");
	m_HelpID = HELP_FQUATTRO;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterQuattro::RenderCol(CColor* col, real x, real y)
{
	x *= 2;
	y *= 2;
	if (x < 1)
		if (y < 1)
			m_Prop[PROP_SOURCE3].RenderCol(col, x, y);
		else
			m_Prop[PROP_SOURCE].RenderCol(col, x, y - 1);
	else
		if (y < 1)
			m_Prop[PROP_SOURCE4].RenderCol(col, x - 1, y);
		else
			m_Prop[PROP_SOURCE2].RenderCol(col, x - 1, y - 1);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterQuattro::RenderVal(real x, real y)
{
	x *= 2;
	y *= 2;
	if (x < 1)
		if (y < 1)
			return m_Prop[PROP_SOURCE3].RenderVal(x, y);
		else
			return m_Prop[PROP_SOURCE].RenderVal(x, y - 1);
	else
		if (y < 1)
			return m_Prop[PROP_SOURCE4].RenderVal(x - 1, y);
		else
			return m_Prop[PROP_SOURCE2].RenderVal(x - 1, y - 1);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterHexo::CFilterHexo()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Hexo");
	m_HelpID = HELP_FHEXO;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterHexo::RenderCol(CColor* col, real x, real y)
{
	x *= 3;
	y *= 2;
	if (x < 1)
		if (y < 1)
			m_Prop[PROP_SOURCE4].RenderCol(col, x, y);
		else
			m_Prop[PROP_SOURCE].RenderCol(col, x, y - 1);
	else
		if (x < 2)
			if (y < 1)
				m_Prop[PROP_SOURCE5].RenderCol(col, x - 1, y);
			else
				m_Prop[PROP_SOURCE2].RenderCol(col, x - 1, y - 1);
		else
			if (y < 1)
				m_Prop[PROP_SOURCE6].RenderCol(col, x - 2, y);
			else
				m_Prop[PROP_SOURCE3].RenderCol(col, x - 2, y - 1);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterHexo::RenderVal(real x, real y)
{
	x *= 3;
	y *= 2;
	if (x < 1)
		if (y < 1)
			return m_Prop[PROP_SOURCE4].RenderVal(x, y);
		else
			return m_Prop[PROP_SOURCE].RenderVal(x, y - 1);
	else
		if (x < 2)
			if (y < 1)
				return m_Prop[PROP_SOURCE5].RenderVal(x - 1, y);
			else
				return m_Prop[PROP_SOURCE2].RenderVal(x - 1, y - 1);
		else
			if (y < 1)
				return m_Prop[PROP_SOURCE6].RenderVal(x - 2, y);
			else
				return m_Prop[PROP_SOURCE3].RenderVal(x - 2, y - 1);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterOcto::CFilterOcto()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Octo");
	m_HelpID = HELP_FOCTO;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterOcto::RenderCol(CColor* col, real x, real y)
{
	x *= 4;
	y *= 2;
	if (x < 2)
		if (x < 1)
			if (y < 1)
				m_Prop[PROP_SOURCE5].RenderCol(col, x, y);
			else
				m_Prop[PROP_SOURCE].RenderCol(col, x, y - 1);
		else
			if (y < 1)
				m_Prop[PROP_SOURCE6].RenderCol(col, x - 1, y);
			else
				m_Prop[PROP_SOURCE2].RenderCol(col, x - 1, y - 1);
	else
		if (x < 3)
			if (y < 1)
				m_Prop[PROP_SOURCE7].RenderCol(col, x - 2, y);
			else
				m_Prop[PROP_SOURCE3].RenderCol(col, x - 2, y - 1);
		else
			if (y < 1)
				m_Prop[PROP_SOURCE8].RenderCol(col, x - 3, y);
			else
				m_Prop[PROP_SOURCE4].RenderCol(col, x - 3, y - 1);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterOcto::RenderVal(real x, real y)
{
	x *= 4;
	y *= 2;
	if (x < 2)
		if (x < 1)
			if (y < 1)
				return m_Prop[PROP_SOURCE5].RenderVal(x, y);
			else
				return m_Prop[PROP_SOURCE].RenderVal(x, y - 1);
		else
			if (y < 1)
				return m_Prop[PROP_SOURCE6].RenderVal(x - 1, y);
			else
				return m_Prop[PROP_SOURCE2].RenderVal(x - 1, y - 1);
	else
		if (x < 3)
			if (y < 1)
				return m_Prop[PROP_SOURCE7].RenderVal(x - 2, y);
			else
				return m_Prop[PROP_SOURCE3].RenderVal(x - 2, y - 1);
		else
			if (y < 1)
				return m_Prop[PROP_SOURCE8].RenderVal(x - 3, y);
			else
				return m_Prop[PROP_SOURCE4].RenderVal(x - 3, y - 1);
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CFilterNano::CFilterNano()
{
	m_Group = FGRP_MUX;
	m_Class = _T("Nano");
	m_HelpID = HELP_FNANO;
}

///////////////////////////////////////////////////////////////////////////////
// render color (coordinates and output are typically in range 0..1)

void CFilterNano::RenderCol(CColor* col, real x, real y)
{
	x *= 3;
	y *= 3;
	if (x < 1)
		if (y < 1)
			m_Prop[PROP_SOURCE7].RenderCol(col, x, y);
		else
			if (y < 2)
				m_Prop[PROP_SOURCE4].RenderCol(col, x, y - 1);
			else
				m_Prop[PROP_SOURCE].RenderCol(col, x, y - 2);
	else
		if (x < 2)
			if (y < 1)
				m_Prop[PROP_SOURCE8].RenderCol(col, x - 1, y);
			else
				if (y < 2)
					m_Prop[PROP_SOURCE5].RenderCol(col, x - 1, y - 1);
				else
					m_Prop[PROP_SOURCE2].RenderCol(col, x - 1, y - 2);
		else
			if (y < 1)
				m_Prop[PROP_SOURCE9].RenderCol(col, x - 2, y);
			else
				if (y < 2)
					m_Prop[PROP_SOURCE6].RenderCol(col, x - 2, y - 1);
				else
					m_Prop[PROP_SOURCE3].RenderCol(col, x - 2, y - 2);
}

///////////////////////////////////////////////////////////////////////////////
// render value (coordinates and output are typically in range 0..1)

real CFilterNano::RenderVal(real x, real y)
{
	x *= 3;
	y *= 3;
	if (x < 1)
		if (y < 1)
			return m_Prop[PROP_SOURCE7].RenderVal(x, y);
		else
			if (y < 2)
				return m_Prop[PROP_SOURCE4].RenderVal(x, y - 1);
			else
				return m_Prop[PROP_SOURCE].RenderVal(x, y - 2);
	else
		if (x < 2)
			if (y < 1)
				return m_Prop[PROP_SOURCE8].RenderVal(x - 1, y);
			else
				if (y < 2)
					return m_Prop[PROP_SOURCE5].RenderVal(x - 1, y - 1);
				else
					return m_Prop[PROP_SOURCE2].RenderVal(x - 1, y - 2);
		else
			if (y < 1)
				return m_Prop[PROP_SOURCE9].RenderVal(x - 2, y);
			else
				if (y < 2)
					return m_Prop[PROP_SOURCE6].RenderVal(x - 2, y - 1);
				else
					return m_Prop[PROP_SOURCE3].RenderVal(x - 2, y - 2);
}
