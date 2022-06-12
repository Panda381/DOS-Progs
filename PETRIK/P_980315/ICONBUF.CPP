
#include "stdafx.h"
#include "peter.h"
#include "IconBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

////////////////////////////////////////////////////////////////////
// Pozor - linky BMP pro 256 barev jsou zarovnávány na 4 bajty !
//       - linky BMP pro 2 barvy (maska) jsou zarovnány na bajt !
////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CIconBuf::CIconBuf()
{
	m_Data = (unsigned char*)malloc(5);		// data ikon
	ASSERT(m_Data != NULL);
	m_Mask = (unsigned char*)malloc(5);		// data masky ikon
	ASSERT(m_Mask != NULL);
	m_Num = 0;								// poèet ikon v bufferu
	m_Width = 32;							// implicitní šíøka jedné ikony
	m_Height = 32;							// implicitní výška jedné ikony
}

CIconBuf::~CIconBuf()
{
	free(m_Data);
	free(m_Mask);
}

/////////////////////////////////////////////////////////////////////////////
// pøidání ikon z resource (num = poèet, id = identifikátor)

BOOL CIconBuf::Load(int num, int id)
{
// pøíprava staré a nové délky linky
	int OldLine = (m_Width*m_Num+3) & ~0x3;			// pùvodní délka linky
	int AddLine = (m_Width*num+3) & ~0x3;			// délka pøidávané linky
	int NewLine = (m_Width*(m_Num+num)+3) & ~0x3;	// nová délka linky
	int i;											// èítaè

// nastavení velikosti bufferu dat ikon
	unsigned char* buff;
	buff = (unsigned char*)realloc(m_Data, NewLine*m_Height);
	if (buff == NULL) return FALSE;
	m_Data = buff;

// nalezení resource bitmapy
	HRSRC hRes = ::FindResource(AfxGetResourceHandle(),
		MAKEINTRESOURCE(id), RT_BITMAP);
	ASSERT(hRes != NULL);

// naètení bitmapy do pamìti
	HGLOBAL hData = ::LoadResource(AfxGetResourceHandle(), hRes);
	ASSERT(hData != NULL);

// naètení dat bitmapy do bufferu
	BITMAPINFO* bmp = (BITMAPINFO*) ::LockResource(hData);
	ASSERT((bmp->bmiHeader.biWidth) == (int)(m_Width*num));

// roztažení linek existujících ikon v bufferu
	if (m_Num > 0)
	{
		for (i = m_Height-1; i >= 0; i--)
			memmove(m_Data + i*NewLine, m_Data + i*OldLine, OldLine);
	}

// pøenesení dat linek bitmapy
	for (i = 0; i < m_Height; i++)
	{
		memcpy(m_Data + i*NewLine + m_Width*m_Num, 
			(unsigned char*)&(bmp->bmiColors[256]) + i*AddLine, AddLine);
	}
	m_Num += num;

// vygenerování masky ikon
	return GenerMask();
}

/////////////////////////////////////////////////////////////////////////////
// vygenerování masky ikon

BOOL CIconBuf::GenerMask()
{
	ASSERT(m_Data != NULL);
	int linka = (m_Width*m_Num+3) & ~0x3;	// délka linky barevné bitmapy
	int delka = m_Height*linka;				// délka dat barevné bitmapy
	unsigned char* buffsrc = m_Data;		// buffer dat barevné bitmapy
	unsigned char* buffdst;					// buffer dat masky bitmapy

// nastavení velikosti bufferu masky ikon
	buffdst = (unsigned char*)realloc(m_Mask, ((m_Width*m_Num+7)/8)*m_Height);
	if (m_Num == 0)
	{
		m_Mask = buffdst;
		return TRUE;
	}
	if (buffdst == NULL) return FALSE;
	m_Mask = buffdst;

// vygenerování dat masky
#ifdef _X86_
	_asm
	{
	push	eax
	push	ebx
	push	ecx
	push	esi
	push	edi

	cld
	mov		esi,buffsrc						// buffer dat barevné bitmapy
	mov		edi,buffdst						// buffer masky bitmapy
	mov		ebx,linka						// délka linky barevné bitmapy
	mov		ecx,delka						// délka dat barevné bitmapy celkem
	add		esi,ecx							// konec dat za barevnou bitmapou
	sub		esi,ebx							// adresa poslední linky bitmapy
	mov		ah,1							// støadaè bitù

X1:	lodsb									// naètení bajtu barevné bitmapy
	cmp		al,1							// je platná barva ?
	rcl		ah,1							// pøíznakový bit
	jnc		X2								// není ještì 8 bitù
	mov		al,ah							// støadaè bitù
	stosb									// uložení bajtu masky
	mov		ah,1							// nový støadaè masky

X2:	dec		ebx								// èítaè bajtù na lince
	jnz		X4								// není ještì konec linky
	mov		ebx,linka						// nový èítaè délky linky
	sub		esi,ebx							// návrat adresy zaèátku linky
	sub		esi,ebx							// adresa zaèátku pøedešlé linky

	cmp		ah,1							// je zapoèatý další bajt ?
	je		X4								// není zapoèatý další bajt
X3:	shl		ah,1							// rotace masky na další bitovou pozici
	jnc		X3								// není ještì konec masky
	stosb									// uložení bajtu masky
	mov		ah,1							// nový støadaè masky

X4:	loop	X1								// další bajt dat

	pop		edi
	pop		esi
	pop		ecx
	pop		ebx
	pop		eax
	}
#else
	unsigned char* src = buffsrc + delka - linka; // adresa poslední linky bitmapy
	unsigned char* dst = buffdst;			// buffer masky bitmapy
	unsigned char stradac = 0;				// støadaè bitù masky
	short cit8 = 8;							// èítaè bitù masky
	int citlin = linka;						// èítaè délky linky

	for (int citac = delka; citac != 0; citac--)
	{
		stradac <<= 1;						// rotace støadaèe na další pozici
		if (src[0] == 0)					// je platná barva ?
			stradac |= 1;					// pøíznak pozadí
		src++;								// zvýšení ukazatele dat bitmapy

		cit8--;								// èítaè bitù støadaèe
		if (cit8 == 0)						// jsou již všechny bity støadaèe ?
		{
			dst[0] = stradac;				// uložení støadaèe bitù masky
			dst++;							// zvýšení ukládací adresy masky
			cit8 = 8;						// nový èítaè bitù masky
		}

		citlin--;							// èitaè bajtù na lince
		if (citlin == 0)					// je již konec linky ?
		{
			citlin = linka;					// nový èítaè délky linky
			src -= citlin;					// návrat adresy zaèátku linky
			src -= citlin;					// adresa zaèátku pøedešlé linky
	
			if (cit8 < 8)					// je zapoèatý další bajt støaïaèe ?
			{
				while (cit8 != 0)			// cyklus pro chybìjící bity masky
				{
					cit8--;					// snížení bitù støadaèe
					stradac <<= 1;			// rotace støadaèe na další pozici
				}
				dst[0] = stradac;			// uložení støadaèe bitù masky
				dst++;						// zvýšení ukládací adresy masky
				cit8 = 8;					// nový èítaè bitù masky
			}

		}
	}
#endif

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// pøidání ikon do seznamu ikon

void CIconBuf::AddList(CImageList* list)
{
	HDC dc;
	HBITMAP bitmap;
	CBitmap bmp, bmpMono;
	HPALETTE OldPal;

// vytvoøení MONO bitmapy
	bmpMono.CreateBitmap(m_Width*m_Num, m_Height, 1, 1, m_Mask);

// otevøení DC displeje
	dc = ::GetDC(0);
	ASSERT(dc != NULL);

// výbìr a realizace vlastních palet 
	OldPal = ::SelectPalette(dc, StdPalette, FALSE);
	::RealizePalette(dc);

// pøíprava záhlaví BMP
	StdBitmapInfo->bmiHeader.biWidth = m_Width*m_Num;
	StdBitmapInfo->bmiHeader.biHeight = m_Height;

// vytvoøení bitmapy
	bitmap = ::CreateDIBitmap(dc,&(StdBitmapInfo->bmiHeader),
		CBM_INIT, m_Data,StdBitmapInfo,DIB_RGB_COLORS);
	ASSERT(bitmap != NULL);

// pøidání bitmapy k seznamu
	bmp.m_hObject = bitmap;
	list->Add(&bmp, &bmpMono);	
	
// uvolnìní palet a DC displeje
	::SelectPalette(dc,OldPal,TRUE);
	::ReleaseDC(0,dc);
}

