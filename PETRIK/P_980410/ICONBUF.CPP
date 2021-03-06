
#include "stdafx.h"
#include "peter.h"
#include "IconBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

////////////////////////////////////////////////////////////////////
// Pozor - linky BMP pro 256 barev jsou zarovn�v�ny na 4 bajty !
//       - linky BMP pro 2 barvy (maska) jsou zarovn�ny na bajt !
////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CIconBuf::CIconBuf()
{
	m_Data = (unsigned char*)malloc(5);		// data ikon
	ASSERT(m_Data != NULL);
	m_Mask = (unsigned char*)malloc(5);		// data masky ikon
	ASSERT(m_Mask != NULL);
	m_Num = 0;								// po�et ikon v bufferu
	m_Width = 32;							// implicitn� ���ka jedn� ikony
	m_Height = 32;							// implicitn� v��ka jedn� ikony
}

CIconBuf::~CIconBuf()
{
	free(m_Data);
	free(m_Mask);
}

/////////////////////////////////////////////////////////////////////////////
// p�id�n� ikon z resource (num = po�et, id = identifik�tor)

BOOL CIconBuf::Load(int num, int id)
{
// p��prava star� a nov� d�lky linky
	int OldLine = (m_Width*m_Num+3) & ~0x3;			// p�vodn� d�lka linky
	int AddLine = (m_Width*num+3) & ~0x3;			// d�lka p�id�van� linky
	int NewLine = (m_Width*(m_Num+num)+3) & ~0x3;	// nov� d�lka linky
	int i;											// ��ta�

// nastaven� velikosti bufferu dat ikon
	unsigned char* buff;
	buff = (unsigned char*)realloc(m_Data, NewLine*m_Height);
	if (buff == NULL) return FALSE;
	m_Data = buff;

// nalezen� resource bitmapy
	HRSRC hRes = ::FindResource(AfxGetResourceHandle(),
		MAKEINTRESOURCE(id), RT_BITMAP);
	ASSERT(hRes != NULL);

// na�ten� bitmapy do pam�ti
	HGLOBAL hData = ::LoadResource(AfxGetResourceHandle(), hRes);
	ASSERT(hData != NULL);

// na�ten� dat bitmapy do bufferu
	BITMAPINFO* bmp = (BITMAPINFO*) ::LockResource(hData);
	ASSERT((bmp->bmiHeader.biWidth) == (int)(m_Width*num));

// rozta�en� linek existuj�c�ch ikon v bufferu
	if (m_Num > 0)
	{
		for (i = m_Height-1; i >= 0; i--)
			memmove(m_Data + i*NewLine, m_Data + i*OldLine, OldLine);
	}

// p�enesen� dat linek bitmapy
	for (i = 0; i < m_Height; i++)
	{
		memcpy(m_Data + i*NewLine + m_Width*m_Num, 
			(unsigned char*)&(bmp->bmiColors[256]) + i*AddLine, AddLine);
	}
	m_Num += num;

// vygenerov�n� masky ikon
	return GenerMask();
}

/////////////////////////////////////////////////////////////////////////////
// vygenerov�n� masky ikon

BOOL CIconBuf::GenerMask()
{
	ASSERT(m_Data != NULL);
	int linka = (m_Width*m_Num+3) & ~0x3;	// d�lka linky barevn� bitmapy
	int delka = m_Height*linka;				// d�lka dat barevn� bitmapy
	unsigned char* buffsrc = m_Data;		// buffer dat barevn� bitmapy
	unsigned char* buffdst;					// buffer dat masky bitmapy

// nastaven� velikosti bufferu masky ikon
	buffdst = (unsigned char*)realloc(m_Mask, ((m_Width*m_Num+7)/8)*m_Height);
	if (m_Num == 0)
	{
		m_Mask = buffdst;
		return TRUE;
	}
	if (buffdst == NULL) return FALSE;
	m_Mask = buffdst;

// vygenerov�n� dat masky
#ifdef _X86_
	_asm
	{
	push	eax
	push	ebx
	push	ecx
	push	esi
	push	edi

	cld
	mov		esi,buffsrc						// buffer dat barevn� bitmapy
	mov		edi,buffdst						// buffer masky bitmapy
	mov		ebx,linka						// d�lka linky barevn� bitmapy
	mov		ecx,delka						// d�lka dat barevn� bitmapy celkem
	add		esi,ecx							// konec dat za barevnou bitmapou
	sub		esi,ebx							// adresa posledn� linky bitmapy
	mov		ah,1							// st�ada� bit�

X1:	lodsb									// na�ten� bajtu barevn� bitmapy
	cmp		al,1							// je platn� barva ?
	rcl		ah,1							// p��znakov� bit
	jnc		X2								// nen� je�t� 8 bit�
	mov		al,ah							// st�ada� bit�
	stosb									// ulo�en� bajtu masky
	mov		ah,1							// nov� st�ada� masky

X2:	dec		ebx								// ��ta� bajt� na lince
	jnz		X4								// nen� je�t� konec linky
	mov		ebx,linka						// nov� ��ta� d�lky linky
	sub		esi,ebx							// n�vrat adresy za��tku linky
	sub		esi,ebx							// adresa za��tku p�ede�l� linky

	cmp		ah,1							// je zapo�at� dal�� bajt ?
	je		X4								// nen� zapo�at� dal�� bajt
X3:	shl		ah,1							// rotace masky na dal�� bitovou pozici
	jnc		X3								// nen� je�t� konec masky
	stosb									// ulo�en� bajtu masky
	mov		ah,1							// nov� st�ada� masky

X4:	loop	X1								// dal�� bajt dat

	pop		edi
	pop		esi
	pop		ecx
	pop		ebx
	pop		eax
	}
#else
	unsigned char* src = buffsrc + delka - linka; // adresa posledn� linky bitmapy
	unsigned char* dst = buffdst;			// buffer masky bitmapy
	unsigned char stradac = 0;				// st�ada� bit� masky
	short cit8 = 8;							// ��ta� bit� masky
	int citlin = linka;						// ��ta� d�lky linky

	for (int citac = delka; citac != 0; citac--)
	{
		stradac <<= 1;						// rotace st�ada�e na dal�� pozici
		if (src[0] == 0)					// je platn� barva ?
			stradac |= 1;					// p��znak pozad�
		src++;								// zv��en� ukazatele dat bitmapy

		cit8--;								// ��ta� bit� st�ada�e
		if (cit8 == 0)						// jsou ji� v�echny bity st�ada�e ?
		{
			dst[0] = stradac;				// ulo�en� st�ada�e bit� masky
			dst++;							// zv��en� ukl�dac� adresy masky
			cit8 = 8;						// nov� ��ta� bit� masky
		}

		citlin--;							// �ita� bajt� na lince
		if (citlin == 0)					// je ji� konec linky ?
		{
			citlin = linka;					// nov� ��ta� d�lky linky
			src -= citlin;					// n�vrat adresy za��tku linky
			src -= citlin;					// adresa za��tku p�ede�l� linky
	
			if (cit8 < 8)					// je zapo�at� dal�� bajt st�a�a�e ?
			{
				while (cit8 != 0)			// cyklus pro chyb�j�c� bity masky
				{
					cit8--;					// sn�en� bit� st�ada�e
					stradac <<= 1;			// rotace st�ada�e na dal�� pozici
				}
				dst[0] = stradac;			// ulo�en� st�ada�e bit� masky
				dst++;						// zv��en� ukl�dac� adresy masky
				cit8 = 8;					// nov� ��ta� bit� masky
			}

		}
	}
#endif

	return TRUE;
}


/////////////////////////////////////////////////////////////////////////////
// p�id�n� ikon do seznamu ikon

void CIconBuf::AddList(CImageList* list)
{
	HDC dc;
	HBITMAP bitmap;
	CBitmap bmp, bmpMono;
	HPALETTE OldPal;

// vytvo�en� MONO bitmapy
	bmpMono.CreateBitmap(m_Width*m_Num, m_Height, 1, 1, m_Mask);

// otev�en� DC displeje
	dc = ::GetDC(0);
	ASSERT(dc != NULL);

// v�b�r a realizace vlastn�ch palet 
	OldPal = ::SelectPalette(dc, StdPalette, FALSE);
	::RealizePalette(dc);

// p��prava z�hlav� BMP
	StdBitmapInfo->bmiHeader.biWidth = m_Width*m_Num;
	StdBitmapInfo->bmiHeader.biHeight = m_Height;

// vytvo�en� bitmapy
	bitmap = ::CreateDIBitmap(dc,&(StdBitmapInfo->bmiHeader),
		CBM_INIT, m_Data,StdBitmapInfo,DIB_RGB_COLORS);
	ASSERT(bitmap != NULL);

// p�id�n� bitmapy k seznamu
	bmp.m_hObject = bitmap;
	list->Add(&bmp, &bmpMono);	
	
// uvoln�n� palet a DC displeje
	::SelectPalette(dc,OldPal,TRUE);
	::ReleaseDC(0,dc);
}

