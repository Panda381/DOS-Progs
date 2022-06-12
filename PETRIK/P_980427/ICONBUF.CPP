
#include "stdafx.h"
#include "peter.h"
#include "IconBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define ICONREZERVA 20				// rezerva pøi zvìtšování bufferu

////////////////////////////////////////////////////////////////////
// Pozor - linky BMP pro 256 barev jsou zarovnávány na 4 bajty !
//       - linky BMP pro 2 barvy (maska) jsou zarovnány na bajt !
////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CIconBuf::CIconBuf()
{
	m_Num = 0;								// poèet ikon v bufferu
	m_Max = 0;								// velikost bufferu
	m_Width = 32;							// implicitní šíøka jedné ikony
	m_Height = 32;							// implicitní výška jedné ikony
	m_WidthByte = 32;						// délka jedné linky v bajtech
	m_GenPal = FALSE;						// nejsou palety
	m_ItemSize = m_WidthByte * m_Height;	// velikost jedné ikony v bajtech
	m_Data = NULL;							// nejsou data bufferu
}

CIconBuf::~CIconBuf()
{
	free(m_Data);
}


/////////////////////////////////////////////////////////////////////////////
// nastavení nové velikosti bufferu (v poètech ikon)

void CIconBuf::SetSize(int NewSize)
{
// oprava požadované velikosti
	if (NewSize < 0) NewSize = 0;

// test, zda je zvìtšení bufferu
	if (NewSize > m_Max)
	{

// pro pøípad prvního použití inicializace
		m_WidthByte = (m_Width + 3) & ~0x3;	// délka linky v bajtech
		m_ItemSize = m_WidthByte * m_Height; // velikost prvku v bajtech

// nastavení nové velikosti bufferu
		m_Max = NewSize + ICONREZERVA;
		Aloc(m_Data, m_Max*m_ItemSize);
	}

// nový poèet ikon
	m_Num = NewSize;
}


/////////////////////////////////////////////////////////////////////////////
// zrušení ikon z bufferu (implicitnì 1 ikona)

void CIconBuf::Delete(int Index, int Count)
{
// korekce indexu
	if (Index >= m_Num)
		Index = m_Num - 1;		// maximální hodnota indexu
	if (Index < 0)
		Index = 0;				// minimální hodnota indexu

// korekce poètu položek ke zrušení
	if (Index + Count > m_Num)
		Count = m_Num - Index;

// kontrola, zda je co rušit
	if (Count <= 0)
		return;

// pøísun zbylých položek
	if (m_Num > (Index + Count))
		memmove(&m_Data[m_ItemSize*Index],
			&m_Data[m_ItemSize*(Index+Count)],
			m_ItemSize*(m_Num - (Index + Count)));

// zmìna poètu položek
	m_Num -= Count;
}


/////////////////////////////////////////////////////////////////////////////
// pøidání ikon z resource (num = poèet, id = identifikátor)

void CIconBuf::LoadRes(int id)
{
// lokální promìnné
	HRSRC res;						// resource identifikátor bitmapy
	HGLOBAL data;					// globální buffer dat bitmapy
	BITMAPINFO* bmp;				// ukazatel na data bitmapy
	int num;						// poèet ikon v bitmapì
	unsigned char* src;				// ukazatel zdrojové adresy
	unsigned char* dst;				// ukazatel cílové adresy
	int srcinc;						// pøírustek zdrojové adresy = délka linky
	int i,j;						// pracovní èítaèe

// nalezení resource bitmapy
	res = ::FindResource(AfxGetResourceHandle(),
		MAKEINTRESOURCE(id), RT_BITMAP);
	ASSERT(res != NULL);

// naètení bitmapy do pamìti
	data = ::LoadResource(AfxGetResourceHandle(), res);
	ASSERT(data != NULL);

// ukazatel na data bitmapy
	bmp = (BITMAPINFO*) ::LockResource(data);

// pøíprava konverzní tabulky palet
	if (!m_GenPal)
	{
		GenKonvPal(bmp);
		m_GenPal = TRUE;
	}

// pøíprava zdrojové adresy
	src = (unsigned char*) &(bmp->bmiColors[256]);

// pøíprava poètu ikon v bitmapì
	num = bmp->bmiHeader.biWidth / m_Width;

// pøíprava pøírustku zdrojové adresy
	srcinc = (bmp->bmiHeader.biWidth + 3) & ~0x3;

// nastavení nové velikosti bufferu dat
	SetSize(m_Num + num);

// pøíprava ukládací adresy
	dst = &m_Data[m_ItemSize*(m_Num-num)];

// cyklus pøes všechny importované ikony
	for (i = num-1; i >= 0; i--)
	{

// cyklus pøes všechny linky jedné ikony
		for (j = m_Height-1; j >= 0; j--)
		{

// kopie jedné linky ikony
//			memcpy(dst, src, m_Width);
			KonvCopy(dst, src, m_Width);

// zvýšení ukládací a ètecí adresy
			dst += m_WidthByte;		// ukládací adresa
			src += srcinc;			// ètecí adresa
		}

// posun ètecí adresy na další ikonu (ukládací adresa je OK)
		src -= m_Height*srcinc - m_Width;
	}
}

/////////////////////////////////////////////////////////////////////////////
// naètení ikony ze souboru (vrací index ikony)

int CIconBuf::LoadFile(CString name)
{
// lokální promìnné
	HANDLE hFile;						// handle souboru
	DWORD read;							// poèet naètených bajtù
	BITMAPINFO* bmp = NULL;				// ukazatel na data bitmapy
	unsigned char* item;				// adresa obrázku

// buffer pro naèteni záhlaví
	Aloc(bmp, 1078);

// zvýšení velikosti bufferu
	SetSize(m_Num+1);

// otevøení souboru
	hFile = ::CreateFile(name, GENERIC_READ, 
		FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 
		FILE_ATTRIBUTE_NORMAL, NULL);

// test, zda byl soubor otevøen OK
	if (hFile != INVALID_HANDLE_VALUE)
	{

// nastavení ukazatele v souboru na data
		::SetFilePointer(hFile, sizeof(BITMAPFILEHEADER), NULL, FILE_BEGIN);

// naètení záhlaví souboru
		::ReadFile(hFile, bmp, 1078 - sizeof(BITMAPFILEHEADER), &read, NULL);

// pøíprava konverzní tabulky palet
//		GenKonvPal(bmp);
 
// adresa obrázku v bufferu
		item = Get(m_Num-1);

// naètení souboru do bufferu
		::ReadFile(hFile, item, m_WidthByte*m_Height, &read, NULL);

// konverze palet
		KonvCopy(item, item, m_WidthByte*m_Height);

// uzavøení souboru
		::CloseHandle(hFile);		// uzavøení souboru
	}

// zrušení bufferu
	Aloc(bmp, 0);

// navrácení indexu nové ikony
	return m_Num-1;
}


/////////////////////////////////////////////////////////////////////////////
// vygenerování dat bitmapy
// barevná bitmapa má na konci rezervu pro zarovnání linky na 8 bajtù

unsigned char* CIconBuf::GenerBitmap()
{
// lokální promìnné
	unsigned char* data = NULL;		// adresa bufferu
	unsigned char* src;				// ukazatel zdrojové adresy
	unsigned char* dst;				// ukazatel cílové adresy
	int dstinc;						// pøírustek cílové adresy = délka linky
	int i,j;						// pracovní èítaèe

// pøírustek cílové adresy = délka linky
	dstinc = (m_Num*m_Width + 3) & ~0x3;

// vytvoøení bufferu (s rezervou pro zarovnání linky na 8 bajtù)
	Aloc(data, dstinc*m_Height + 7);

// ukazatele zdrojové a cílové adresy
	dst = data;						// ukazatel cílové adresy
	src = m_Data;					// ukazatel zdrojové adresy

// cyklus pøes všechny exportované ikony
	for (i = m_Num-1; i >= 0; i--)
	{

// cyklus pøes všechny linky jedné ikony
		for (j = m_Height-1; j >= 0; j--)
		{

// kopie jedné linky ikony
			memcpy(dst, src, m_Width);

// zvýšení ukládací a ètecí adresy
			src += m_WidthByte;		// ètecí adresa
			dst += dstinc;			// ukládací adresa
		}

// posun ukládací adresy na další ikonu (ètecí adresa je OK)
		dst -= m_Height*dstinc - m_Width;
	}

// návrat adresy bufferu
	return data;
}


/////////////////////////////////////////////////////////////////////////////
// vygenerování masky ikon z dat barevné bitmapy
// barevná bitmapa musí mít na konci rezervu pro zarovnání linky na 8 bajtù !

unsigned char* CIconBuf::GenerMask(unsigned char* bitmapa)
{
// lokální promìnné
	int width;							// délka linky (v bodech)
	int srcinc;							// pøírustek zdrojové adresy 
	int dstinc;							// pøírustek cílové adresy
	unsigned char* src;					// ukazatel zdrojové adresy
	unsigned char* dst;					// ukazatel cílové adresy
	unsigned char* data = NULL;			// adresa cílového bufferu
	unsigned char stradac;				// støadaè bitù masky
	int i,j;							// pracovní èítaèe

// délka linky v bodech
	width = m_Num*m_Width;

// pøírustek zdrojové adresy
	srcinc = (width + 3) & ~0x3;

// pøírustek cílové adresy
	dstinc = (width + 7) / 8;

// vytvoøení bufferu pro masku
	Aloc(data, dstinc * m_Height);

// ukazatel cílové adresy
	dst = data;							// ukazatel cílové adresy

// cyklus pøes všecny linky
	for (i = m_Height-1; i >= 0; i--)
	{

// ukazatel zdrojové adresy
		src = bitmapa + srcinc*i;

// cyklus pøes všechny bajty cílové linky
		for (j = dstinc - 1; j >= 0; j--)
		{

// vygenerování bajtu pro 8 bodù (mùže pøesáhnout za konec linky)
			stradac = 0;				// pøíprava støadaèe
			if (src[0] == 0)			// je platná barva ?
				stradac = 0x80;			// pøíznak pozadí
			src++;						// zvýšení ukazatele dat bitmapy

			if (src[0] == 0)			// je platná barva ?
				stradac |= 0x40;		// pøíznak pozadí
			src++;						// zvýšení ukazatele dat bitmapy

			if (src[0] == 0)			// je platná barva ?
				stradac |= 0x20;		// pøíznak pozadí
			src++;						// zvýšení ukazatele dat bitmapy

			if (src[0] == 0)			// je platná barva ?
				stradac |= 0x10;		// pøíznak pozadí
			src++;						// zvýšení ukazatele dat bitmapy

			if (src[0] == 0)			// je platná barva ?
				stradac |= 0x08;		// pøíznak pozadí
			src++;						// zvýšení ukazatele dat bitmapy

			if (src[0] == 0)			// je platná barva ?
				stradac |= 0x04;		// pøíznak pozadí
			src++;						// zvýšení ukazatele dat bitmapy

			if (src[0] == 0)			// je platná barva ?
				stradac |= 0x02;		// pøíznak pozadí
			src++;						// zvýšení ukazatele dat bitmapy

			if (src[0] == 0)			// je platná barva ?
				stradac |= 0x01;		// pøíznak pozadí
			src++;						// zvýšení ukazatele dat bitmapy

// uložení cílového bajtu
			dst[0] = stradac;			// uložení støadaèe bitù masky
			dst++;						// zvýšení ukládací adresy masky
		}
	}

// adresa bufferu s daty
	return data;
}


/////////////////////////////////////////////////////////////////////////////
// vygenerování seznamu ikon

CImageList* CIconBuf::GenerList()
{
// lokální promìnné
	HIMAGELIST himg;			// seznam ikon Windows
	CImageList* list;			// seznam ikon - objekt
	unsigned char* data;		// data barevné bitmapy
	unsigned char* mono;		// data mono bitmapy (maska)
	CBitmap bmp, bmpMono;		// barevná a mono bitmapa
	HDC dc;						// handle kontextu displeje
	HPALETTE OldPal;			// úschova pùvodních palet
	HBITMAP bitmap;				// handle barevné bitmapy

// vytvoøení seznamu ikon
	list = new CImageList();
	himg = ImageList_Create(m_Width,m_Height, ILC_COLORDDB | ILC_MASK,m_Num,10);
	ASSERT(himg != NULL);		// vytvoøeno OK ?
	list->Attach(himg);			// pøipojení k objektu seznamu ikon

// vytvoøení dat barevné a mono bitmapy
	data = GenerBitmap();		// vygenerování barevné bitmapy
	mono = GenerMask(data);		// vygenerování masky bitmapy

// vytvoøení mono bitmapy (maska)
	bmpMono.CreateBitmap(m_Width*m_Num, m_Height, 1, 1, mono);

// otevøení DC displeje
	dc = ::GetDC(0);
	ASSERT(dc != NULL);

// výbìr a realizace vlastních palet 
	OldPal = ::SelectPalette(dc, StdPalette, FALSE);
	::RealizePalette(dc);

// pøíprava záhlaví BMP
	StdBitmapInfo->bmiHeader.biWidth = m_Width*m_Num;
	StdBitmapInfo->bmiHeader.biHeight = m_Height;

// vytvoøení barevné bitmapy
	bitmap = ::CreateDIBitmap(dc,&(StdBitmapInfo->bmiHeader),
		CBM_INIT, data,StdBitmapInfo,DIB_RGB_COLORS);
	ASSERT(bitmap != NULL);

// pøidání bitmapy k seznamu
	bmp.m_hObject = bitmap;
	list->Add(&bmp, &bmpMono);	
	
// uvolnìní palet a DC displeje
	::SelectPalette(dc,OldPal,TRUE);
	::ReleaseDC(0,dc);

// zrušení pracovních bufferù s daty
	Aloc(data, 0);
	Aloc(mono, 0);

// navrácení seznamu ikon
	return list;
}

