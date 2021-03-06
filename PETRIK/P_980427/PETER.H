// Peter.h : main header file for the PETER application
//

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// glob�ln� prom�nn�

extern CString	Jmeno;				// jm�no editovan�ho programu (bez cesty a bez p��pony)

// parametry obrazovky
extern int ScreenWidth;				// ���ka obrazovky
extern int ScreenHeight;			// v��ka obrazovky

// konfigura�n� prom�nn�
extern int Profile;					// ��slo profilu (z p��kazov�ho ��dku)
extern CString ProfName;			// jm�no profilu

extern int Scale;					// m���tko pro relativn� rozm�ry okna

extern int MainLeft;				// relativn� pozice hlavn�ho okna vlevo
extern int MainTop;					// relativn� pozice hlavn�ho okna naho�e
extern int MainWidth;				// relativn� ���ka hlavn�ho okna
extern int MainHeight;				// relativn� v��ka hlavn�ho okna

extern int LeftWidth;				// relativn� ���ka lev�ho pole (objekty)
extern int LeftHeight;				// relativn� v��ka lev�ho horn�ho okna (glob�ln� objekty)
extern int RightWidth;				// relativn� ���ka prav�ho pole (t��dy)
extern int RightHeight;				// relativn� v��ka prav�ho horn�ho okna (struktury)

extern BOOL Maximized;				// p��znak maximalizace okna

extern CString FindString;			// hledan� text

// glob�ln� objekty
class CMainFrame;
extern	CMainFrame*	MainFrame;		// hlavn� okno aplikace
class CPeterApp;
extern	CPeterApp theApp;			// hlavn� objekt aplikace
class CProg;
extern CProg* Prog;					// hlavn� okno programov�n�

//extern int		SelectWidth;		// ���ka pole pro v�b�r objektu a t�idy
extern BITMAPINFO* StdBitmapInfo;	// standardn� z�hlav� BMP
extern HPALETTE StdPalette;			// vlastn� palety

extern unsigned char KonvPal[256];	// konverzn� tabulka palet
extern void GenKonvPal(BITMAPINFO* bmp); // generov�n� konverzn� tabulky

extern const int ColCol;			// po�et barev standardn�ch palet
extern const int ColLev;			// po�et �rovn� standardn�ch palet
extern const int StdColors;			// po�et vlastn�ch palet (za��naj� od 0)

// konverze barev
inline void KonvCopy(unsigned char* dst, unsigned char* src, int num)
{
	for (; num > 0; num--)
	{
		dst[0] = KonvPal[src[0]];
		dst++;
		src++;
	}
}

/////////////////////////////////////////////////////////////////////////////
// CPeterApp:
// See Peter.cpp for the implementation of this class
//

class CPeterApp : public CWinApp
{
public:
	CPeterApp();
	~CPeterApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPeterApp)
	public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CPeterApp)
	afx_msg void OnAppAbout();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

public:
	void ReadIni();
	void ReadIniInt(int& result, LPCTSTR entry, int deflt);
	void WriteIni();
};


/////////////////////////////////////////////////////////////////////////////
// m�d editace ikony

enum EditMode
{ 
	EditModeElip,					// elipsa
	EditModeFill,					// v�pl�
	EditModeLine,					// ��ra
	EditModePaint,					// �t�tec
	EditModePen,					// pero
	EditModePipe,					// kap�tko
	EditModeRect,					// obd�ln�k
	EditModeRound,					// kruh
	EditModeSelect,					// blok
	EditModeSpray,					// sprej
	EditModeXFlip,					// horizont�ln� p�evr�cen�
	EditModeYFlip,					// vertik�ln� p�evr�cen�
	EditModeRRot,					// oto�en� R
	EditModeLRot,					// oto�en� L
	EditModeXCol,					// z�m�na barev
};


/////////////////////////////////////////////////////////////////////////////
// realokace velk�ch buffer� (adr = NULL vytvo�en�, size = 0 zru�en�)

void* _Aloc(void* adr, int size);

inline void Aloc(char*& adr, int size)
	{ adr = (char*)_Aloc(adr, size); }

inline void Aloc(unsigned char*& adr, int size)
	{ adr = (unsigned char*)_Aloc(adr, size); }

inline void Aloc(BITMAPINFO*& adr, int size)
	{ adr = (BITMAPINFO*)_Aloc(adr, size); }

inline void Aloc(double*& adr, int size)
	{ adr = (double*)_Aloc(adr, size); }

inline void Aloc(int*& adr, int size)				// velikost ud�na v po�tu polo�ek int !
	{ adr = (int*)_Aloc(adr, size*sizeof(int)); }
