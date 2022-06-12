
//////////////////////////////////////////////////////
//          !!!!!!!!!!!!!!!!!!!!!!!!!				//
//   Nastavit zarovnávání pøekladaèe na 4 Bajty,	//
//  aby souhlasilo zarovnávání struktur v souboru	//
//	        !!!!!!!!!!!!!!!!!!!!!!!!!				//
//////////////////////////////////////////////////////

// Pøi zmìnì velikosti položek bude možná nutné zmìnit
// zarovnání až na 1 Bajt, proto radìji dodržet velikosti
// položek pro vìtší zarovnání.

/////////////////////////////////////////////////////////////////////////////
// inicializaèní tabulky obsahù polí (8 B)

typedef struct tagINITBUF {
	signed short int	refer;		// (2) index reference (-1 = není)
	signed short int	parent;		// (2) hladina prvku (k urèení rodièe)
	unsigned short int	model;		// (2) model (typ) prvku
	unsigned short int	param;		// (2) parametry (pøidat PR_INTERNAL !!!!)
} INITBUF;

/////////////////////////////////////////////////////////////////////////////
// definice indexu datového bloku (32 B)

typedef struct tagPETINDEX {
	long int			delka;		// (4) délka datového bloku
	long int			pocet;		// (4) poèet položek v datovém bloku
	char				jmeno[8];	// (8) jméno datového bloku (8 znakù)
	long int			extra1;		// (4) doplòující informace 1 (= 0)
									//      - poèátek okna, jazyk textù, ikony WIDTH
	long int			extra2;		// (4) doplòující informace 2 (= 0)
									//		- kurzor, kód znakù textù, ikony HEIGHT
	long int			extra3;		// (4) doplòující informace 3 (= 0)
	long int			extra4;		// (4) doplòující informace 4 (= 0)
} PETINDEX;

/////////////////////////////////////////////////////////////////////////////
// definice záhlaví souboru (16 + 13*32 B)

#define SIZEOFPETHEAD 16			// základní velikost záhlaví (bez indexù)

typedef struct tagPETHEAD {
	char				ident[3];	// (3) identifikace = "PET"
	unsigned char		verze;		// (1) verze = 1
	unsigned long int	param;		// (4) parametry = 0
	long int			data;		// (4) offset zaèátku dat v souboru (= délka záhlaví)
	long int			pocet;		// (4) poèet datových blokù
	PETINDEX			pi[13];		// tabulka indexù
#define	piImport		pi[0]		// (32) blok "IMPORT" - import interních prvkù (seznam ASCIIZ jmen)
#define	piClass			pi[1]		// (32) blok "CLASS" - tøídy
#define	piGlobal		pi[2]		// (32) blok "GLOBAL" - globální objekty
#define	piLocal			pi[3]		// (32) blok "LOCAL" - lokální objekty
#define	piProgram		pi[4]		// (32) blok "PROGRAM" - program (obsah funkcí)
#define	piReal			pi[5]		// (32) blok "REAL" - obsah èíselných promìnných
#define	piText			pi[6]		// (32) blok "TEXT" - texty (text 0 = jméno programu)
#define	piPalette		pi[7]		// (32) blok "PALETTE" - palety ve formátu BMP
#define	piPic16			pi[8]		// (32) blok "PICTURE" - obrázky 16*16 (obrázek 0 = ikona programu)
#define	piPic32			pi[9]		// (32) blok "PICTURE" - obrázky 32*32 (obrázek 0 = ikona programu)
#define	piMap			pi[10]		// (32) blok "MAP" - mapy ploch
#define	piSound			pi[11]		// (32) blok "SOUND" - zvuky
#define	piMusic			pi[12]		// (32) blok "MUSIC" - hudba
} PETHEAD;

/////////////////////////////////////////////////////////////////////////////
// definice položky programu nebo struktury (12 B) - pozor na zarovnání dat programu !!!

#define PETPROG_CHILDS	0x01		// pøíznak, že jsou potomci
#define PETPROG_NEXT	0x02		// pøíznak, že bude potomek stejné hladiny
#define PETPROG_EXP		0x04		// pøíznak rozvinutí potomkù
#define PETPROG_BOLD	0x08		// pøíznak zvýraznìní textu
#define PETPROG_GRAY	0x10		// pøíznak zešedlé položky
#define PETPROG_LOCK	0x20		// pøíznak uzamèení položky proti modifikaci

typedef struct tagPETPROG {
	unsigned short int	param;		// (2) parametry (viz výše)
	signed short int	typ;		// (2) blok s deklarací (-1 = není)
	signed short int	refer;		// (2) index s deklarací (-1 = není)
	signed short int	index;		// (2) index s daty (-1 = implicitní)
	signed short int	icon;		// (2) ikona (-1 = implicitní)
	signed short int	name;		// (2) text jména (-1 = implicitní)
} PETPROG;

////////////////////////////////////////////////////////////////////
// okno programování

class CProg : public CFormView
{
protected:
	CProg();
	DECLARE_DYNCREATE(CProg)

public:
	//{{AFX_DATA(CProg)
	enum { IDD = IDR_PROG };
	CStatic	m_Refer;
	CButton		m_Lock;			// uzamèení funkce
	CButton		m_Off;			// vypnutí funkce
	CButton		m_Def;			// implicitní obsah funkce
	CButton		m_Icon;			// editace ikony
	CEdit		m_Name;			// jméno funkce
	CStatic		m_Nadpis1;		// nadpis nad stromem veøejných objektù
	CStatic		m_Nadpis2;		// nadpis nad stromem lokálních objektù
	CStatic		m_Nadpis3;		// nadpis nad stromem základních prvkù
	CStatic		m_Nadpis4;		// nadpis nad stromem tøíd objektù
	CTreeCtrl	m_Object;		// strom veøejných objektù
	CTreeCtrl	m_Local;		// strom lokálních objektù
	CTreeCtrl	m_Struc;		// strom základních prvkù a struktur
	CTreeCtrl	m_Class;		// strom tøíd objektù
	CTreeCtrl	m_Edit;			// strom editace
	CStatic		m_Split1;		// levý vertikální rozdìlovaè
	CStatic		m_Split2;		// levý horizontální rozdìlovaè
	CStatic		m_Split3;		// pravý vertikální rozdìlovaè
	CStatic		m_Split4;		// pravý horizontální rozdìlovaè
	//}}AFX_DATA

// aktivní položka a aktivní strom
	int			m_AktItem;		// aktivní položka (v aktivním oknì) (-1 = není)
	int			m_AktBufID;		// ID aktivního bufferu
	CTreeCtrl*	m_AktTree;		// aktivní strom
	
	BOOL		m_FilName;		// probíhá plnìní eidtoru jména textem

// seznamy ikon k zobrazení pro stromy
	CImageList* m_Ico16;		// malé ikony 16x16
	CImageList* m_Ico32;		// velké ikony 32x32

// seznamy textù
	CTextBuf	m_Text;			// uživatelské texty
	CTextBuf	m_TextInt;		// texty interních funkcí

//	CStringArray m_Text;		// uživatelské texty
//	CStringArray m_TextInt;		// texty interních funkcí

// buffery ikon a obrázkù
	CIconBuf	m_BufIco16Int;	// buffer ikon 16x16 - interní funkce
	CIconBuf	m_BufIco32Int;	// buffer ikon 32x32 - interní funkce
	CIconBuf	m_BufIco16;		// buffer ikon 16x16 - uživatelské ikony
	CIconBuf	m_BufIco32;		// buffer ikon 32x32 - uživatelské ikony

// buffery struktury programu
	CProgBuf	m_Buf[PROGBUFNUM];	// buffery struktury programu

// nemìnit poøadí - muselo by se zmìnit též pøi ukládání souboru !
#define BufIntID 0					// buffer interních funkcí (nemá strom)
#define BufClsID 1					// buffer tøíd objektù
#define BufObjID 2					// buffer veøejných objektù
#define BufLocID 3					// buffer lokálních objektù
#define BufEdiID 4					// buffer editace
#define BufStrID 5					// buffer základních prvkù a struktur

#define m_BufInt m_Buf[BufIntID]	// buffer interních funkcí (nemá strom)
#define m_BufCls m_Buf[BufClsID]	// buffer tøíd objektù
#define m_BufObj m_Buf[BufObjID]	// buffer veøejných objektù
#define m_BufLoc m_Buf[BufLocID]	// buffer lokálních objektù
#define m_BufEdi m_Buf[BufEdiID]	// buffer editované funkce
#define m_BufStr m_Buf[BufStrID]	// buffer základních prvkù a struktur

// obsluha tažení
	BOOL		m_Dragging;			// pøíznak probíhajíciho tažení

	CTreeCtrl*	m_TreeSrc;			// ukazatel na strom zdroje tažení
	int			m_DragSrc;			// identifikátor ID stromu zdroje tažení
	HTREEITEM	m_itemDrag;			// tažený prvek
	int			m_itemDragN;		// index taženého prvku
	int			m_itemDragPar;		// parametry taženého prvku
	int			m_itemDragModel;	// model taženého prvku

	CTreeCtrl*	m_TreeDst;			// ukazatel na strom cíle tažení
	int			m_DragDst;			// identifikátor ID stromu cíle tažení (-1=neplatný)
	HTREEITEM	m_itemDrop;			// cílový prvek (rodiè)
	int			m_itemDropN;		// index cílového prvku (rodièe, -1=root)
	int			m_itemDropPar;		// parametry cílového prvku (rodièe)
	int			m_itemDropModel;	// model cílového prvku (rodièe)
	int			m_DropIndex;		// index pozice k uložení (-1 = zákaz uložení)

	CImageList*	m_DragList;			// seznam obrázkù pro tažení
	CSize		m_HotSpot;			// bod uchycení taženého prvku
	CSize		m_TestSpot;			// bod testu tažení prvku
	BOOL		m_DragRight;		// taženo pravým tlaèítkem (kopírování má pøednost)
	BOOL		m_DragCopy;			// je kopírování nebo pøesun (jinak jen rušení)
	BOOL		m_DragDelete;		// je rušení nebo pøesun (pøi pøesunu nebo rušení)
	HCURSOR		m_OldCursor;		// uschovaný kurzor pøed tažením
	HCURSOR		m_CurCopy;			// kurzor kopírování
	HCURSOR		m_CurMove;			// kurzor pøesunu
	HCURSOR		m_CurNoDrag;		// zákaz tažení
	HCURSOR		m_CurDelete;		// tažení se zrušením
	HCURSOR		m_CurAkt;			// aktivní kurzor pøi operaci

// obsluha ukládání/naèítání souboru
	BOOL		m_Saving;			// probíhá ukládání/naèítání souboru
	PETHEAD*	m_Head;				// záhlaví souboru
	DWORD		m_Writen;			// poèet uložených/naètených bajtù v jedné operaci
	HANDLE		m_File;				// handle souboru
	BOOL		m_OK;				// pøíznak operace OK
	CString		m_FileName;			// jméno souboru

	PETPROG*	m_bufClass;			// buffer prvkù tøíd
	int			m_numClass;			// poèet prvkù tøíd
	PETPROG*	m_bufObject;		// buffer prvkù globálních objektù
	int			m_numObject;		// poèet prvkù globálních objektù
	PETPROG*	m_bufLocal;			// buffer prvkù lokálních objektù
	int			m_numLocal;			// poèet prvkù lokálních objektù
	PETPROG*	m_bufEdit;			// buffer prvkù editoru funkcí
	int			m_numEdit;			// poèet prvkù editoru

	int*		m_tabImport;		// konverzní tabulka importovaných funkcí
	char*		m_bufImport;		// buffer textù importovaných funkcí
	int			m_maxImport;		// velikost bufferu importovaných funkcí
	int			m_numImport;		// poèet importovaných funkcí v bufferu
	int			m_sizeImport;		// velikost dat v bufferu importovaných funkcí

	char*		m_bufText;			// buffer textù
	int			m_maxText;			// velikost bufferu textù
	int			m_numText;			// poèet textù v bufferu textù
	int			m_sizeText;			// velikost dat v bufferu textù

	signed short int* m_typImport;	// konverzní tabulka typù importu
	signed short int* m_refImport;	// konverzní tabulka referencí importu

public:

	//{{AFX_VIRTUAL(CProg)
	public:
	virtual void OnInitialUpdate();
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);
	virtual void OnDraw(CDC* pDC);
	//}}AFX_VIRTUAL

protected:
	virtual ~CProg();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:
	//{{AFX_MSG(CProg)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnBeginDragProgObj(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnBeginDragProgLoc(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnBeginDragProgStr(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnBeginDragProgCls(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnBeginDragProgEdi(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnItemExpandedProgObj(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnItemExpandedProgLoc(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnItemExpandedProgStr(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnItemExpandedProgCls(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnItemExpandedProgEdi(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSetFocusObject(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSetFocusLocal(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSetFocusStruc(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSetFocusClass(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSetFocusProg(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnChangeName();
	afx_msg void OnProgDef();
	afx_msg void OnSelChangedObject(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSelChangedLocal(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSelChangedStruc(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSelChangedClass(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSelChangedEdit(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDblclkProgObject(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDblclkProgLocal(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnFileSave();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

	void OnButtonUp();
	void OnItemExpandedProg(NMHDR* pNMHDR, LRESULT* pResult, int buff);
	int CopyItem(int& nSrc, int& nDst, int nPar);
	void InitPrgBuf(int num, const INITBUF* InitBuf, CProgBuf* ProgBuf);
	BOOL SrcDropWin(CPoint point);
//	BOOL TestDropWin();
	BOOL TestDropItem(int srcModel, int srcPar, int srcBuff, int dstModel, 
		int dstPar, int dstBuff, int dstItem);
	void OnSetFocus(NMHDR* pNMHDR, LRESULT* pResult);
	void DispName();
	void OnBeginDragProg(NMHDR* pNMHDR, LRESULT* pResult);
	void AktNameTree(CProgBuf* buff, CString* text, int AktBuf, int AktItem);
	void OnSelChanged(NMHDR* pNMHDR, LRESULT* pResult);
	void RefSelChange(int AktBuf, int RefBuf);
	void DblclkObject(int item);
	void DblclkLocal(int item);
	void SavePrg(PETPROG* buf, int buffID);
	void SaveWriteFile(LPCVOID buf, DWORD bytes);
	void OnFileLoad();
	void LoadReadFile(LPVOID buf, DWORD bytes);
	int LoadSrcIndex(LPCTSTR jmeno, int beg);
	void FileLoadHead();
	void FileLoadImport();
	void FileLoadText();
	void FileLoadPic();
	void FileLoadProg(LPCTSTR jm, PETPROG*& pbuf, int& pnum, CProgBuf* buf);
	void FileLoadTab();
};
