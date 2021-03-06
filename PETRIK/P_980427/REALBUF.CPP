
#include "stdafx.h"
#include "peter.h"
#include "RealBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define REALREZERVA 100			// rezerva p�i zv�t�ov�n� bufferu

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CRealBuf::CRealBuf()
{
	m_pData = NULL;
	m_nSize = 0;				// nen� ��dn� prvek
	m_nMaxSize = 0;				// maxim�ln� velikost
}

CRealBuf::~CRealBuf()
{
	Aloc(m_pData, 0);			// zru�en� bufferu
}


////////////////////////////////////////////////////////////////////
// nastaven� nov� velikosti bufferu

void CRealBuf::SetSize(int nNewSize)
{
// oprava po�adovan� velikosti
	if (nNewSize < 0)			// je velikost z�porn� ?
		nNewSize = 0;			// oprava �daje

// test, zda je zv�t�en� bufferu
	if (nNewSize > m_nMaxSize)
	{

// nastaven� nov� velikosti bufferu
		m_nMaxSize = nNewSize + REALREZERVA;	// nov� velikost bufferu

// vytvo�en� nov�ho bufferu
		Aloc(m_pData, m_nMaxSize * sizeof(double));
	}

// nov� po�et polo�ek
	m_nSize = nNewSize;
}


////////////////////////////////////////////////////////////////////
// zru�en� polo�ky s dan�m indexem (implicitn� 1 polo�ka)

void CRealBuf::Delete(int nIndex, int nCount)
{
// korekce indexu
	if (nIndex >= m_nSize)
		nIndex = m_nSize-1;		// maxim�ln� hodnota indexu
	if (nIndex < 0)
		nIndex = 0;				// minim�ln� hodnota indexu

// korekce po�tu polo�ek ke zru�en�
	if (nIndex + nCount > m_nSize)
		nCount = m_nSize - nIndex;

// kontrola, zda je co ru�it
	if (nCount <= 0)
		return;

// p��sun zbyl�ch polo�ek
	if (m_nSize > (nIndex + nCount))
		memmove(&m_pData[nIndex], &m_pData[nIndex + nCount],
			(m_nSize - (nIndex + nCount)) * sizeof(double));

// zm�na po�tu polo�ek
	m_nSize -= nCount;
}

