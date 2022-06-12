
#include "stdafx.h"
#include "peter.h"
#include "RealBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define REALREZERVA 100			// rezerva pøi zvìtšování bufferu

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CRealBuf::CRealBuf()
{
	m_pData = NULL;
	m_nSize = 0;				// není žádný prvek
	m_nMaxSize = 0;				// maximální velikost
}

CRealBuf::~CRealBuf()
{
	Aloc(m_pData, 0);			// zrušení bufferu
}


////////////////////////////////////////////////////////////////////
// nastavení nové velikosti bufferu

void CRealBuf::SetSize(int nNewSize)
{
// oprava požadované velikosti
	if (nNewSize < 0)			// je velikost záporná ?
		nNewSize = 0;			// oprava údaje

// test, zda je zvìtšení bufferu
	if (nNewSize > m_nMaxSize)
	{

// nastavení nové velikosti bufferu
		m_nMaxSize = nNewSize + REALREZERVA;	// nová velikost bufferu

// vytvoøení nového bufferu
		Aloc(m_pData, m_nMaxSize * sizeof(double));
	}

// nový poèet položek
	m_nSize = nNewSize;
}


////////////////////////////////////////////////////////////////////
// zrušení položky s daným indexem (implicitnì 1 položka)

void CRealBuf::Delete(int nIndex, int nCount)
{
// korekce indexu
	if (nIndex >= m_nSize)
		nIndex = m_nSize-1;		// maximální hodnota indexu
	if (nIndex < 0)
		nIndex = 0;				// minimální hodnota indexu

// korekce poètu položek ke zrušení
	if (nIndex + nCount > m_nSize)
		nCount = m_nSize - nIndex;

// kontrola, zda je co rušit
	if (nCount <= 0)
		return;

// pøísun zbylých položek
	if (m_nSize > (nIndex + nCount))
		memmove(&m_pData[nIndex], &m_pData[nIndex + nCount],
			(m_nSize - (nIndex + nCount)) * sizeof(double));

// zmìna poètu položek
	m_nSize -= nCount;
}

