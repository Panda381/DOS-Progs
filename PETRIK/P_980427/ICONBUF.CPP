
#include "stdafx.h"
#include "peter.h"
#include "IconBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define ICONREZERVA 20				// rezerva p�i zv�t�ov�n� bufferu

////////////////////////////////////////////////////////////////////
// Pozor - linky BMP pro 256 barev jsou zarovn�v�ny na 4 bajty !
//       - linky BMP pro 2 barvy (maska) jsou zarovn�ny na bajt !
////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CIconBuf::CIconBuf()
{
	m_Num = 0;								// po�et ikon v bufferu
	m_Max = 0;								// velikost bufferu
	m_Width = 32;							// implicitn� ���ka jedn� ikony
	m_Height = 32;							// implicitn� v��ka jedn� ikony
	m_WidthByte = 32;						// d�lka jedn� linky v bajtech
	m_GenPal = FALSE;						// nejsou palety
	m_ItemSize = m_WidthByte * m_Height;	// velikost jedn� ikony v bajtech
	m_Data = NULL;							// nejsou data bufferu
}

CIconBuf::~CIconBuf()
{
	free(m_Data);
}


/////////////////////////////////////////////////////////////////////////////
// nastaven� nov� velikosti bufferu (v po�tech ikon)

void CIconBuf::SetSize(int NewSize)
{
// oprava po�adovan� velikosti
	if (NewSize < 0) NewSize = 0;

// test, zda je zv�t�en� bufferu
	if (NewSize > m_Max)
	{

// pro p��pad prvn�ho pou�it� inicializace
		m_WidthByte = (m_Width + 3) & ~0x3;	// d�lka linky v bajtech
		m_ItemSize = m_WidthByte * m_Height; // velikost prvku v bajtech

// nastaven� nov� velikosti bufferu
		m_Max = NewSize + ICONREZERVA;
		Aloc(m_Data, m_Max*m_ItemSize);
	}

// nov� po�et ikon
	m_Num = NewSize;
}


/////////////////////////////////////////////////////////////////////////////
// zru�en� ikon z bufferu (implicitn� 1 ikona)

void CIconBuf::Delete(int Index, int Count)
{
// korekce indexu
	if (Index >= m_Num)
		Index = m_Num - 1;		// maxim�ln� hodnota indexu
	if (Index < 0)
		Index = 0;				// minim�ln� hodnota indexu

// korekce po�tu polo�ek ke zru�en�
	if (Index + Count > m_Num)
		Count = m_Num - Index;

// kontrola, zda je co ru�it
	if (Count <= 0)
		return;

// p��sun zbyl�ch polo�ek
	if (m_Num > (Index + Count))
		memmove(&m_Data[m_ItemSize*Index],
			&m_Data[m_ItemSize*(Index+Count)],
			m_ItemSize*(m_Num - (Index + Count)));

// zm�na po�tu polo�ek
	m_Num -= Count;
}


/////////////////////////////////////////////////////////////////////////////
// p�id�n� ikon z resource (num = po�et, id = identifik�tor)

void CIconBuf::LoadRes(int id)
{
// lok�ln� prom�nn�
	HRSRC res;						// resource identifik�tor bitmapy
	HGLOBAL data;					// glob�ln� buffer dat bitmapy
	BITMAPINFO* bmp;				// ukazatel na data bitmapy
	int num;						// po�et ikon v bitmap�
	unsigned char* src;				// ukazatel zdrojov� adresy
	unsigned char* dst;				// ukazatel c�lov� adresy
	int srcinc;						// p��rustek zdrojov� adresy = d�lka linky
	int i,j;						// pracovn� ��ta�e

// nalezen� resource bitmapy
	res = ::FindResource(AfxGetResourceHandle(),
		MAKEINTRESOURCE(id), RT_BITMAP);
	ASSERT(res != NULL);

// na�ten� bitmapy do pam�ti
	data = ::LoadResource(AfxGetResourceHandle(), res);
	ASSERT(data != NULL);

// ukazatel na data bitmapy
	bmp = (BITMAPINFO*) ::LockResource(data);

// p��prava konverzn� tabulky palet
	if (!m_GenPal)
	{
		GenKonvPal(bmp);
		m_GenPal = TRUE;
	}

// p��prava zdrojov� adresy
	src = (unsigned char*) &(bmp->bmiColors[256]);

// p��prava po�tu ikon v bitmap�
	num = bmp->bmiHeader.biWidth / m_Width;

// p��prava p��rustku zdrojov� adresy
	srcinc = (bmp->bmiHeader.biWidth + 3) & ~0x3;

// nastaven� nov� velikosti bufferu dat
	SetSize(m_Num + num);

// p��prava ukl�dac� adresy
	dst = &m_Data[m_ItemSize*(m_Num-num)];

// cyklus p�es v�echny importovan� ikony
	for (i = num-1; i >= 0; i--)
	{

// cyklus p�es v�echny linky jedn� ikony
		for (j = m_Height-1; j >= 0; j--)
		{

// kopie jedn� linky ikony
//			memcpy(dst, src, m_Width);
			KonvCopy(dst, src, m_Width);

// zv��en� ukl�dac� a �tec� adresy
			dst += m_WidthByte;		// ukl�dac� adresa
			src += srcinc;			// �tec� adresa
		}

// posun �tec� adresy na dal�� ikonu (ukl�dac� adresa je OK)
		src -= m_Height*srcinc - m_Width;
	}
}

/////////////////////////////////////////////////////////////////////////////
// na�ten� ikony ze souboru (vrac� index ikony)

int CIconBuf::LoadFile(CString name)
{
// lok�ln� prom�nn�
	HANDLE hFile;						// handle souboru
	DWORD read;							// po�et na�ten�ch bajt�
	BITMAPINFO* bmp = NULL;				// ukazatel na data bitmapy
	unsigned char* item;				// adresa obr�zku

// buffer pro na�teni z�hlav�
	Aloc(bmp, 1078);

// zv��en� velikosti bufferu
	SetSize(m_Num+1);

// otev�en� souboru
	hFile = ::CreateFile(name, GENERIC_READ, 
		FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 
		FILE_ATTRIBUTE_NORMAL, NULL);

// test, zda byl soubor otev�en OK
	if (hFile != INVALID_HANDLE_VALUE)
	{

// nastaven� ukazatele v souboru na data
		::SetFilePointer(hFile, sizeof(BITMAPFILEHEADER), NULL, FILE_BEGIN);

// na�ten� z�hlav� souboru
		::ReadFile(hFile, bmp, 1078 - sizeof(BITMAPFILEHEADER), &read, NULL);

// p��prava konverzn� tabulky palet
//		GenKonvPal(bmp);
 
// adresa obr�zku v bufferu
		item = Get(m_Num-1);

// na�ten� souboru do bufferu
		::ReadFile(hFile, item, m_WidthByte*m_Height, &read, NULL);

// konverze palet
		KonvCopy(item, item, m_WidthByte*m_Height);

// uzav�en� souboru
		::CloseHandle(hFile);		// uzav�en� souboru
	}

// zru�en� bufferu
	Aloc(bmp, 0);

// navr�cen� indexu nov� ikony
	return m_Num-1;
}


/////////////////////////////////////////////////////////////////////////////
// vygenerov�n� dat bitmapy
// barevn� bitmapa m� na konci rezervu pro zarovn�n� linky na 8 bajt�

unsigned char* CIconBuf::GenerBitmap()
{
// lok�ln� prom�nn�
	unsigned char* data = NULL;		// adresa bufferu
	unsigned char* src;				// ukazatel zdrojov� adresy
	unsigned char* dst;				// ukazatel c�lov� adresy
	int dstinc;						// p��rustek c�lov� adresy = d�lka linky
	int i,j;						// pracovn� ��ta�e

// p��rustek c�lov� adresy = d�lka linky
	dstinc = (m_Num*m_Width + 3) & ~0x3;

// vytvo�en� bufferu (s rezervou pro zarovn�n� linky na 8 bajt�)
	Aloc(data, dstinc*m_Height + 7);

// ukazatele zdrojov� a c�lov� adresy
	dst = data;						// ukazatel c�lov� adresy
	src = m_Data;					// ukazatel zdrojov� adresy

// cyklus p�es v�echny exportovan� ikony
	for (i = m_Num-1; i >= 0; i--)
	{

// cyklus p�es v�echny linky jedn� ikony
		for (j = m_Height-1; j >= 0; j--)
		{

// kopie jedn� linky ikony
			memcpy(dst, src, m_Width);

// zv��en� ukl�dac� a �tec� adresy
			src += m_WidthByte;		// �tec� adresa
			dst += dstinc;			// ukl�dac� adresa
		}

// posun ukl�dac� adresy na dal�� ikonu (�tec� adresa je OK)
		dst -= m_Height*dstinc - m_Width;
	}

// n�vrat adresy bufferu
	return data;
}


/////////////////////////////////////////////////////////////////////////////
// vygenerov�n� masky ikon z dat barevn� bitmapy
// barevn� bitmapa mus� m�t na konci rezervu pro zarovn�n� linky na 8 bajt� !

unsigned char* CIconBuf::GenerMask(unsigned char* bitmapa)
{
// lok�ln� prom�nn�
	int width;							// d�lka linky (v bodech)
	int srcinc;							// p��rustek zdrojov� adresy 
	int dstinc;							// p��rustek c�lov� adresy
	unsigned char* src;					// ukazatel zdrojov� adresy
	unsigned char* dst;					// ukazatel c�lov� adresy
	unsigned char* data = NULL;			// adresa c�lov�ho bufferu
	unsigned char stradac;				// st�ada� bit� masky
	int i,j;							// pracovn� ��ta�e

// d�lka linky v bodech
	width = m_Num*m_Width;

// p��rustek zdrojov� adresy
	srcinc = (width + 3) & ~0x3;

// p��rustek c�lov� adresy
	dstinc = (width + 7) / 8;

// vytvo�en� bufferu pro masku
	Aloc(data, dstinc * m_Height);

// ukazatel c�lov� adresy
	dst = data;							// ukazatel c�lov� adresy

// cyklus p�es v�ecny linky
	for (i = m_Height-1; i >= 0; i--)
	{

// ukazatel zdrojov� adresy
		src = bitmapa + srcinc*i;

// cyklus p�es v�echny bajty c�lov� linky
		for (j = dstinc - 1; j >= 0; j--)
		{

// vygenerov�n� bajtu pro 8 bod� (m��e p�es�hnout za konec linky)
			stradac = 0;				// p��prava st�ada�e
			if (src[0] == 0)			// je platn� barva ?
				stradac = 0x80;			// p��znak pozad�
			src++;						// zv��en� ukazatele dat bitmapy

			if (src[0] == 0)			// je platn� barva ?
				stradac |= 0x40;		// p��znak pozad�
			src++;						// zv��en� ukazatele dat bitmapy

			if (src[0] == 0)			// je platn� barva ?
				stradac |= 0x20;		// p��znak pozad�
			src++;						// zv��en� ukazatele dat bitmapy

			if (src[0] == 0)			// je platn� barva ?
				stradac |= 0x10;		// p��znak pozad�
			src++;						// zv��en� ukazatele dat bitmapy

			if (src[0] == 0)			// je platn� barva ?
				stradac |= 0x08;		// p��znak pozad�
			src++;						// zv��en� ukazatele dat bitmapy

			if (src[0] == 0)			// je platn� barva ?
				stradac |= 0x04;		// p��znak pozad�
			src++;						// zv��en� ukazatele dat bitmapy

			if (src[0] == 0)			// je platn� barva ?
				stradac |= 0x02;		// p��znak pozad�
			src++;						// zv��en� ukazatele dat bitmapy

			if (src[0] == 0)			// je platn� barva ?
				stradac |= 0x01;		// p��znak pozad�
			src++;						// zv��en� ukazatele dat bitmapy

// ulo�en� c�lov�ho bajtu
			dst[0] = stradac;			// ulo�en� st�ada�e bit� masky
			dst++;						// zv��en� ukl�dac� adresy masky
		}
	}

// adresa bufferu s daty
	return data;
}


/////////////////////////////////////////////////////////////////////////////
// vygenerov�n� seznamu ikon

CImageList* CIconBuf::GenerList()
{
// lok�ln� prom�nn�
	HIMAGELIST himg;			// seznam ikon Windows
	CImageList* list;			// seznam ikon - objekt
	unsigned char* data;		// data barevn� bitmapy
	unsigned char* mono;		// data mono bitmapy (maska)
	CBitmap bmp, bmpMono;		// barevn� a mono bitmapa
	HDC dc;						// handle kontextu displeje
	HPALETTE OldPal;			// �schova p�vodn�ch palet
	HBITMAP bitmap;				// handle barevn� bitmapy

// vytvo�en� seznamu ikon
	list = new CImageList();
	himg = ImageList_Create(m_Width,m_Height, ILC_COLORDDB | ILC_MASK,m_Num,10);
	ASSERT(himg != NULL);		// vytvo�eno OK ?
	list->Attach(himg);			// p�ipojen� k objektu seznamu ikon

// vytvo�en� dat barevn� a mono bitmapy
	data = GenerBitmap();		// vygenerov�n� barevn� bitmapy
	mono = GenerMask(data);		// vygenerov�n� masky bitmapy

// vytvo�en� mono bitmapy (maska)
	bmpMono.CreateBitmap(m_Width*m_Num, m_Height, 1, 1, mono);

// otev�en� DC displeje
	dc = ::GetDC(0);
	ASSERT(dc != NULL);

// v�b�r a realizace vlastn�ch palet 
	OldPal = ::SelectPalette(dc, StdPalette, FALSE);
	::RealizePalette(dc);

// p��prava z�hlav� BMP
	StdBitmapInfo->bmiHeader.biWidth = m_Width*m_Num;
	StdBitmapInfo->bmiHeader.biHeight = m_Height;

// vytvo�en� barevn� bitmapy
	bitmap = ::CreateDIBitmap(dc,&(StdBitmapInfo->bmiHeader),
		CBM_INIT, data,StdBitmapInfo,DIB_RGB_COLORS);
	ASSERT(bitmap != NULL);

// p�id�n� bitmapy k seznamu
	bmp.m_hObject = bitmap;
	list->Add(&bmp, &bmpMono);	
	
// uvoln�n� palet a DC displeje
	::SelectPalette(dc,OldPal,TRUE);
	::ReleaseDC(0,dc);

// zru�en� pracovn�ch buffer� s daty
	Aloc(data, 0);
	Aloc(mono, 0);

// navr�cen� seznamu ikon
	return list;
}

