
//////////////////////////////////////////////////////
//          !!!!!!!!!!!!!!!!!!!!!!!!!				//
// Nastavit zarovnávání pøekladaèe na max. 8 bajtù, //
//  aby souhlasilo zarovnávání struktur v souboru	//
//	        !!!!!!!!!!!!!!!!!!!!!!!!!				//
//////////////////////////////////////////////////////

// Pøi zmìnì velikosti položek bude možná nutné zmìnit
// zarovnání až na 1 Bajt, proto radìji dodržet velikosti
// položek pro vìtší zarovnání.


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
// definice záhlaví souboru (16 + NUMOFINDEX*32 B)

#define NUMOFINDEX 14

#define SIZEOFPETHEAD 16			// základní velikost záhlaví (bez indexù)

typedef struct tagPETHEAD {
	char				ident[3];	// (3) identifikace = "PET"
	unsigned char		verze;		// (1) verze = 1
	unsigned long int	param;		// (4) parametry = 0
	long int			data;		// (4) offset zaèátku dat v souboru (= délka záhlaví)
	long int			pocet;		// (4) poèet datových blokù
	PETINDEX			pi[NUMOFINDEX];	// tabulka indexù
#define	piImport		pi[0]		// (32) blok "IMPORT" - import interních prvkù (seznam ASCIIZ jmen)
#define	piClass			pi[1]		// (32) blok "CLASS" - tøídy
#define	piGlobal		pi[2]		// (32) blok "GLOBAL" - globální objekty
#define	piLocal			pi[3]		// (32) blok "LOCAL" - lokální objekty
#define	piProgram		pi[4]		// (32) blok "PROGRAM" - program (obsah funkcí)
#define	piStruc			pi[5]		// (32) blok "STRUC" - základní struktury
#define	piReal			pi[6]		// (32) blok "REAL" - obsah èíselných promìnných
#define	piText			pi[7]		// (32) blok "TEXT" - texty (text 0 = jméno programu)
#define	piBool			pi[8]		// (32) blok "BOOL" - logické hodnoty (bajty)
#define	piPic32			pi[9]		// (32) blok "PICTURE" - obrázky 32*32 (obrázek 0 = ikona programu)
#define	piMap			pi[10]		// (32) blok "MAP" - mapy ploch
#define	piSound			pi[11]		// (32) blok "SOUND" - zvuky
#define	piMusic			pi[12]		// (32) blok "MUSIC" - hudba
#define	piPalette		pi[13]		// (32) blok "PALETTE" - palety ve formátu BMP
} PETHEAD;


/////////////////////////////////////////////////////////////////////////////
// definice položky programu nebo struktury (16 B) - pozor na zarovnání dat programu !!!

#define PETPROG_CHILDS	0x0001		// pøíznak, že jsou potomci
#define PETPROG_NEXT	0x0002		// pøíznak, že bude potomek stejné hladiny
#define PETPROG_EXP		0x0004		// pøíznak rozvinutí potomkù
#define PETPROG_LOCK	0x0008		// pøíznak uzamknutí (zvýraznìní)
#define PETPROG_OFF		0x0010		// pøíznak vypnutí (zešednutí)
#define PETPROG_NOMOVE	0x0020		// pøíznak zákazu pøesunu položky
#define PETPROG_INTERN	0x0040		// pøíznak interní položky (nerušit)

typedef struct tagPETPROG {
	unsigned short	param;			// (2) parametry (viz výše)
	short			typ;			// (2) blok s deklarací (-1 = není)
	short			refer;			// (2) index s deklarací (-1 = není)
	short			data;			// (2) blok s daty (-1 = není)
	short			index;			// (2) index s daty (-1 = není)
	short			icon;			// (2) ikona (-1 = implicitní)
	short			name;			// (2) text jména (-1 = implicitní)
	short			rez;			// (2) rezerva
} PETPROG;


/////////////////////////////////////////////////////////////////////////////
// inicializaèní tabulky obsahù polí (8 B)

typedef struct tagINITBUF {
	signed short int	refer;		// (2) index reference (-1 = není)
	signed short int	parent;		// (2) hladina prvku (k urèení rodièe)
	unsigned short int	model;		// (2) model (typ) prvku
	unsigned short int	param;		// (2) parametry (pøidat PR_INTERNAL !!!!)
} INITBUF;


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
	CButton	m_ProgLogic;
	CStatic	m_ProgMusic;
	CStatic	m_ProgSound;
	CEdit	m_ProgText;
	CEdit	m_ProgReal;
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
//	int			m_AktItem;		// aktivní položka (v aktivním oknì) (-1 = není)
	int			m_AktBufID;		// ID aktivního bufferu
//	CTreeCtrl*	m_AktTree;		// aktivní strom

	BOOL		m_Checking;		// nastavuje se hodnota tlaèítka

// editace jména položky
	BOOL		m_FilName;		// probíhá plnìní editoru jména textem
	BOOL		m_Editing;		// probíhá "inplace" editace jména položky
	CString		m_OldName;		// pùvodní jméno položky (pøed zahájením inplace editace)
//	CEdit		m_Label;		// "inplace" editor jména položky

//	HWND		m_LabelhWnd;	// handle okna editoru jména položky

// aktuální stavy pøepínaèù
	int			m_OldRef;		// aktuálnì zobrazený referenèní èítaè (-1=vymazán, -2=neznámý)
//	int			m_AktDef;		// pøepínaè "implicitní text" (0, 1, 2, -1=vyp)

// seznamy ikon k zobrazení pro stromy
//	CImageList* m_Ico16;		// malé ikony 16x16
	CImageList* m_Ico32;		// velké ikony 32x32
//	CImageList* m_State16;		// stavové ikony 8x16
	CImageList* m_State32;		// stavové ikony 12*32

// seznamy textù
	CTextBuf	m_Text;			// uživatelské texty (identifikace BufTxtID)
//	CTextBuf	m_TextInt;		// texty interních funkcí

	CRealBuf	m_Real;			// buffer èísel (identifikace BufNumID)
	CBoolBuf	m_Bool;			// buffer logických hodnot (identifikace BufLogID)
	CMapBuf		m_Map;			// buffer map

	BOOL		m_FilDat;		// probíhá plnìní dat pøi aktivaci editované položky

//	CStringArray m_Text;		// uživatelské texty
//	CStringArray m_TextInt;		// texty interních funkcí

// buffery ikon a obrázkù
//	CIconBuf	m_BufIco16Int;	// buffer ikon 16x16 - interní funkce
//	CIconBuf	m_BufIco32Int;	// buffer ikon 32x32 - interní funkce
//	CIconBuf	m_BufIco16;		// buffer ikon 16x16 - uživatelské ikony

	CIconBuf	m_Icon;			// buffer ikon

//	CIconBuf	m_BufIco32;		// buffer ikon 32x32 - uživatelské ikony
//	CIconBuf	m_BufState16;	// buffer ikon 8x16 - stavové
	CIconBuf	m_BufState32;	// buffer ikon 16x32 - stavové

	int			m_EditBufN;		// èíslo aktivního editaèního bufferu
	int			m_EditItem;		// èíslo editované aktivní položky

	CEditDial	m_ProgDialog;	// editor dialogu
	CEditSprite	m_ProgSprite;	// editor sprajtù
	CEditIcon	m_ProgPic;		// editor ikon
	CEditMap	m_ProgMap;		// editor map

	short		m_OldEditX;		// aktuálnì zobrazená souøadnice X editoru
	short		m_OldEditY;		// aktuálnì zobrazená souøadnice Y editoru

	int 		m_OldEditMapX;	// aktuálnì zobrazená souøadnice X editoru map
	int			m_OldEditMapY;	// aktuálnì zobrazená souøadnice Y editoru map

// buffery struktury programu
	CProgBuf	m_Buf[PROGBUFNUM];	// buffery struktury programu

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
//	HCURSOR		m_OldCursor;		// uschovaný kurzor pøed tažením
	HCURSOR		m_CurArrow;			// standardní kurzor šipky (IDC_ARROW)
	HCURSOR		m_CurHSize;			// horizontální kurzor (IDC_SIZEWE)
	HCURSOR		m_CurVSize;			// vertikální kurzor (IDC_SIZENS)
	HCURSOR		m_CurCopy;			// kurzor kopírování
	HCURSOR		m_CurMove;			// kurzor pøesunu
	HCURSOR		m_CurNoDrag;		// zákaz tažení
	HCURSOR		m_CurDelete;		// tažení se zrušením
	HCURSOR		m_CurAkt;			// aktivní kurzor pøi operaci

// obsluha hledání textu
//	CFindReplaceDialog* m_FindDialog; // hledací dialog
//	BOOL		m_FindDisp;			// pøíznak zobrazení hledacího okna

// obsluha tažení pøedìlù oken
	BOOL		m_Tracking;			// pøíznak probíhajícího tažení pøedìlù
	BOOL		m_HTracking;		// pøíznak tažení horizontálního pøedìlu
	BOOL		m_TrackDisp;		// pøíznak, že pøedìl tažení je zobrazen
	CRect		m_TrackRect;		// klientské souøadnice taženého pøedìlu
	int			m_TrackSpot;		// bod uchycení taženého pøedìlu
	CStatic*	m_TrackSplit;		// tažené rozdìlovací okno
	int			m_ReDispCount;		// èítaè pro pøekreslení zobrazení
	UINT		m_TrackTimer;		// handle èasovaèe

// obsluha ukládání/naèítání souboru
	BOOL		m_Saving;			// probíhá ukládání/naèítání souboru
	PETHEAD*	m_Head;				// záhlaví souboru
	DWORD		m_Writen;			// poèet uložených/naètených bajtù v jedné operaci
	HANDLE		m_File;				// handle souboru
	BOOL		m_OK;				// pøíznak operace OK
	CString		m_FileName;			// jméno souboru

//	PETPROG*	m_bufClass;			// buffer prvkù tøíd
//	int			m_numClass;			// poèet prvkù tøíd
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
	int			m_korigText;		// korekce indexu textu (pøièítá se)
	int			m_korigPic;			// korekce indexu obrázkù (pøièítá se)

	CRealBuf	m_bufReal;			// buffer èísel
	CBoolBuf	m_bufBool;			// buffer logických hodnot
	CIconBuf	m_bufIcon;			// buffer obrázkù

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

public:
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
	afx_msg void OnSelChangedObject(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSelChangedLocal(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSelChangedStruc(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSelChangedClass(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSelChangedEdit(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDblclkProgObject(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDblclkProgLocal(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnFileSave();
	afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnBeginLabelEdit(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnEndLabelEdit(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnProgLock();
	afx_msg void OnUpdateProgLock(CCmdUI* pCmdUI);
	afx_msg void OnProgOff();
	afx_msg void OnUpdateProgOff(CCmdUI* pCmdUI);
	afx_msg void OnProgIcon();
	afx_msg void OnProgClip();
	afx_msg void OnProgDel();
	afx_msg void OnUpdateProgRefer(CCmdUI* pCmdUI);
	afx_msg void OnUpdateProgDef(CCmdUI* pCmdUI);
	afx_msg void OnProgDef();
	afx_msg void OnChangeName();
	afx_msg void OnKeyDownProg(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnProgRedo();
	afx_msg void OnProgUndo();
	afx_msg void OnRefDef();
	afx_msg void OnRefNext();
	afx_msg void OnRefPrev();
	afx_msg void OnChangeFind();
	afx_msg void OnFindNext();
	afx_msg void OnFindPrev();
	afx_msg void OnProgEdit();
	afx_msg void OnChangeProgText();
	afx_msg void OnChangeProgReal();
	afx_msg void OnProgLogic();
	afx_msg void OnUpdateProgUndo(CCmdUI* pCmdUI);
	afx_msg void OnUpdateProgRedo(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditiconXy(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditmapXy(CCmdUI* pCmdUI);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

public:
	void OnButtonUp();
	void OnItemExpandedProg(NMHDR* pNMHDR, LRESULT* pResult, int buff);
	void InitPrgBuf(int num, const INITBUF* InitBuf, CProgBuf* ProgBuf);
	BOOL SrcDropWin(CPoint point);
//	BOOL TestDropWin();
	BOOL TestDropItem(int srcModel, int srcPar, int srcBuff, int dstModel, 
		int dstPar, int dstBuff, int srcItem,  int dstItem);
	void OnSetFocus(NMHDR* pNMHDR, LRESULT* pResult);
	void DispName();
	void OnBeginDragProg(NMHDR* pNMHDR, LRESULT* pResult);
//	void AktNameTree(CProgBuf* buff, CString* text, int AktBuf, int AktItem);
	void AktNameTree(short bufID, CString& txt, short bufrefID, short itemref);
	void AktIconTree(short bufID, int icon, short bufrefID, short itemref);
//	void OnSelChanged(NMHDR* pNMHDR, LRESULT* pResult);
	void RefSelChange(int AktBuf, int RefBuf);
	void DblclkObject(int item);
	void DblclkLocal(int item);
	void DblclkClass(int item);
	void SavePrg(PETPROG* buf, int buffID);
	void SaveWriteFile(LPCVOID buf, DWORD bytes);
	void OnFileLoad();
	void LoadReadFile(LPVOID buf, DWORD bytes);
	int LoadSrcIndex(LPCTSTR jmeno, int beg);
	void FileLoadHead();
	void FileLoadImport();
	void FileLoadReal();
	void FileLoadText();
	void FileLoadBool();
	void FileLoadPic();
	void FileLoadProg(LPCTSTR jm, PETPROG*& pbuf, int& pnum, CProgBuf* buf);
	void LoadLibPicDir(CString cesta, PROGITEM& item);
	void FileLoadTab();
	void LoadLibPic();						// naètení knihovny obrázkù
	BOOL WndHitTest(CWnd& wnd, POINT& pt);
	BOOL BegTrack(CStatic& wnd, POINT& pt, BOOL HTrack);
	void InvertTrack();
	void EndTrack();
	void MoveTrack(CPoint pt);
	void ReSize();
	short DragItem(short srcID, short src, short dstID, short dst, short parent, short mode);
//	void ItemDepLock(int bufID, int itemN);
//	void ItemDepOff(int bufID, int itemN);
	void UpdateLock();
	void UpdateLockBuf(short bufID);
	void UpdateLockItem(CTreeCtrl* tree, PROGITEM* item, int state);
	void OnFind(short inc);
	void DispItem(short bufID, short itemN);
	void OnRefNextPrev(short smer);
	BOOL AktRef(short bufID, short bufref, short itemref, short smer);
	void AktAllDef();
	void SetEditMode(short model);
};
