
//////////////////////////////////////////////////////
//          !!!!!!!!!!!!!!!!!!!!!!!!!				//
//   Nastavit zarovn�v�n� p�eklada�e na 4 Bajty,	//
//  aby souhlasilo zarovn�v�n� struktur v souboru	//
//	        !!!!!!!!!!!!!!!!!!!!!!!!!				//
//////////////////////////////////////////////////////

// P�i zm�n� velikosti polo�ek bude mo�n� nutn� zm�nit
// zarovn�n� a� na 1 Bajt, proto rad�ji dodr�et velikosti
// polo�ek pro v�t�� zarovn�n�.

/////////////////////////////////////////////////////////////////////////////
// inicializa�n� tabulky obsah� pol� (8 B)

typedef struct tagINITBUF {
	signed short int	refer;		// (2) index reference (-1 = nen�)
	signed short int	parent;		// (2) hladina prvku (k ur�en� rodi�e)
	unsigned short int	model;		// (2) model (typ) prvku
	unsigned short int	param;		// (2) parametry (p�idat PR_INTERNAL !!!!)
} INITBUF;

/////////////////////////////////////////////////////////////////////////////
// definice indexu datov�ho bloku (32 B)

typedef struct tagPETINDEX {
	long int			delka;		// (4) d�lka datov�ho bloku
	long int			pocet;		// (4) po�et polo�ek v datov�m bloku
	char				jmeno[8];	// (8) jm�no datov�ho bloku (8 znak�)
	long int			extra1;		// (4) dopl�uj�c� informace 1 (= 0)
									//      - po��tek okna, jazyk text�, ikony WIDTH
	long int			extra2;		// (4) dopl�uj�c� informace 2 (= 0)
									//		- kurzor, k�d znak� text�, ikony HEIGHT
	long int			extra3;		// (4) dopl�uj�c� informace 3 (= 0)
	long int			extra4;		// (4) dopl�uj�c� informace 4 (= 0)
} PETINDEX;

/////////////////////////////////////////////////////////////////////////////
// definice z�hlav� souboru (16 + 13*32 B)

#define SIZEOFPETHEAD 16			// z�kladn� velikost z�hlav� (bez index�)

typedef struct tagPETHEAD {
	char				ident[3];	// (3) identifikace = "PET"
	unsigned char		verze;		// (1) verze = 1
	unsigned long int	param;		// (4) parametry = 0
	long int			data;		// (4) offset za��tku dat v souboru (= d�lka z�hlav�)
	long int			pocet;		// (4) po�et datov�ch blok�
	PETINDEX			pi[13];		// tabulka index�
#define	piImport		pi[0]		// (32) blok "IMPORT" - import intern�ch prvk� (seznam ASCIIZ jmen)
#define	piClass			pi[1]		// (32) blok "CLASS" - t��dy
#define	piGlobal		pi[2]		// (32) blok "GLOBAL" - glob�ln� objekty
#define	piLocal			pi[3]		// (32) blok "LOCAL" - lok�ln� objekty
#define	piProgram		pi[4]		// (32) blok "PROGRAM" - program (obsah funkc�)
#define	piReal			pi[5]		// (32) blok "REAL" - obsah ��seln�ch prom�nn�ch
#define	piText			pi[6]		// (32) blok "TEXT" - texty (text 0 = jm�no programu)
#define	piPalette		pi[7]		// (32) blok "PALETTE" - palety ve form�tu BMP
#define	piPic16			pi[8]		// (32) blok "PICTURE" - obr�zky 16*16 (obr�zek 0 = ikona programu)
#define	piPic32			pi[9]		// (32) blok "PICTURE" - obr�zky 32*32 (obr�zek 0 = ikona programu)
#define	piMap			pi[10]		// (32) blok "MAP" - mapy ploch
#define	piSound			pi[11]		// (32) blok "SOUND" - zvuky
#define	piMusic			pi[12]		// (32) blok "MUSIC" - hudba
} PETHEAD;

/////////////////////////////////////////////////////////////////////////////
// definice polo�ky programu nebo struktury (12 B) - pozor na zarovn�n� dat programu !!!

#define PETPROG_CHILDS	0x01		// p��znak, �e jsou potomci
#define PETPROG_NEXT	0x02		// p��znak, �e bude potomek stejn� hladiny
#define PETPROG_EXP		0x04		// p��znak rozvinut� potomk�
#define PETPROG_BOLD	0x08		// p��znak zv�razn�n� textu
#define PETPROG_GRAY	0x10		// p��znak ze�edl� polo�ky
#define PETPROG_LOCK	0x20		// p��znak uzam�en� polo�ky proti modifikaci

typedef struct tagPETPROG {
	unsigned short int	param;		// (2) parametry (viz v��e)
	signed short int	typ;		// (2) blok s deklarac� (-1 = nen�)
	signed short int	refer;		// (2) index s deklarac� (-1 = nen�)
	signed short int	index;		// (2) index s daty (-1 = implicitn�)
	signed short int	icon;		// (2) ikona (-1 = implicitn�)
	signed short int	name;		// (2) text jm�na (-1 = implicitn�)
} PETPROG;

////////////////////////////////////////////////////////////////////
// okno programov�n�

class CProg : public CFormView
{
protected:
	CProg();
	DECLARE_DYNCREATE(CProg)

public:
	//{{AFX_DATA(CProg)
	enum { IDD = IDR_PROG };
	CStatic	m_Refer;
	CButton		m_Lock;			// uzam�en� funkce
	CButton		m_Off;			// vypnut� funkce
	CButton		m_Def;			// implicitn� obsah funkce
	CButton		m_Icon;			// editace ikony
	CEdit		m_Name;			// jm�no funkce
	CStatic		m_Nadpis1;		// nadpis nad stromem ve�ejn�ch objekt�
	CStatic		m_Nadpis2;		// nadpis nad stromem lok�ln�ch objekt�
	CStatic		m_Nadpis3;		// nadpis nad stromem z�kladn�ch prvk�
	CStatic		m_Nadpis4;		// nadpis nad stromem t��d objekt�
	CTreeCtrl	m_Object;		// strom ve�ejn�ch objekt�
	CTreeCtrl	m_Local;		// strom lok�ln�ch objekt�
	CTreeCtrl	m_Struc;		// strom z�kladn�ch prvk� a struktur
	CTreeCtrl	m_Class;		// strom t��d objekt�
	CTreeCtrl	m_Edit;			// strom editace
	CStatic		m_Split1;		// lev� vertik�ln� rozd�lova�
	CStatic		m_Split2;		// lev� horizont�ln� rozd�lova�
	CStatic		m_Split3;		// prav� vertik�ln� rozd�lova�
	CStatic		m_Split4;		// prav� horizont�ln� rozd�lova�
	//}}AFX_DATA

// aktivn� polo�ka a aktivn� strom
	int			m_AktItem;		// aktivn� polo�ka (v aktivn�m okn�) (-1 = nen�)
	int			m_AktBufID;		// ID aktivn�ho bufferu
	CTreeCtrl*	m_AktTree;		// aktivn� strom
	
	BOOL		m_FilName;		// prob�h� pln�n� eidtoru jm�na textem

// seznamy ikon k zobrazen� pro stromy
	CImageList* m_Ico16;		// mal� ikony 16x16
	CImageList* m_Ico32;		// velk� ikony 32x32

// seznamy text�
	CTextBuf	m_Text;			// u�ivatelsk� texty
	CTextBuf	m_TextInt;		// texty intern�ch funkc�

//	CStringArray m_Text;		// u�ivatelsk� texty
//	CStringArray m_TextInt;		// texty intern�ch funkc�

// buffery ikon a obr�zk�
	CIconBuf	m_BufIco16Int;	// buffer ikon 16x16 - intern� funkce
	CIconBuf	m_BufIco32Int;	// buffer ikon 32x32 - intern� funkce
	CIconBuf	m_BufIco16;		// buffer ikon 16x16 - u�ivatelsk� ikony
	CIconBuf	m_BufIco32;		// buffer ikon 32x32 - u�ivatelsk� ikony

// buffery struktury programu
	CProgBuf	m_Buf[PROGBUFNUM];	// buffery struktury programu

// nem�nit po�ad� - muselo by se zm�nit t� p�i ukl�d�n� souboru !
#define BufIntID 0					// buffer intern�ch funkc� (nem� strom)
#define BufClsID 1					// buffer t��d objekt�
#define BufObjID 2					// buffer ve�ejn�ch objekt�
#define BufLocID 3					// buffer lok�ln�ch objekt�
#define BufEdiID 4					// buffer editace
#define BufStrID 5					// buffer z�kladn�ch prvk� a struktur

#define m_BufInt m_Buf[BufIntID]	// buffer intern�ch funkc� (nem� strom)
#define m_BufCls m_Buf[BufClsID]	// buffer t��d objekt�
#define m_BufObj m_Buf[BufObjID]	// buffer ve�ejn�ch objekt�
#define m_BufLoc m_Buf[BufLocID]	// buffer lok�ln�ch objekt�
#define m_BufEdi m_Buf[BufEdiID]	// buffer editovan� funkce
#define m_BufStr m_Buf[BufStrID]	// buffer z�kladn�ch prvk� a struktur

// obsluha ta�en�
	BOOL		m_Dragging;			// p��znak prob�haj�ciho ta�en�

	CTreeCtrl*	m_TreeSrc;			// ukazatel na strom zdroje ta�en�
	int			m_DragSrc;			// identifik�tor ID stromu zdroje ta�en�
	HTREEITEM	m_itemDrag;			// ta�en� prvek
	int			m_itemDragN;		// index ta�en�ho prvku
	int			m_itemDragPar;		// parametry ta�en�ho prvku
	int			m_itemDragModel;	// model ta�en�ho prvku

	CTreeCtrl*	m_TreeDst;			// ukazatel na strom c�le ta�en�
	int			m_DragDst;			// identifik�tor ID stromu c�le ta�en� (-1=neplatn�)
	HTREEITEM	m_itemDrop;			// c�lov� prvek (rodi�)
	int			m_itemDropN;		// index c�lov�ho prvku (rodi�e, -1=root)
	int			m_itemDropPar;		// parametry c�lov�ho prvku (rodi�e)
	int			m_itemDropModel;	// model c�lov�ho prvku (rodi�e)
	int			m_DropIndex;		// index pozice k ulo�en� (-1 = z�kaz ulo�en�)

	CImageList*	m_DragList;			// seznam obr�zk� pro ta�en�
	CSize		m_HotSpot;			// bod uchycen� ta�en�ho prvku
	CSize		m_TestSpot;			// bod testu ta�en� prvku
	BOOL		m_DragRight;		// ta�eno prav�m tla��tkem (kop�rov�n� m� p�ednost)
	BOOL		m_DragCopy;			// je kop�rov�n� nebo p�esun (jinak jen ru�en�)
	BOOL		m_DragDelete;		// je ru�en� nebo p�esun (p�i p�esunu nebo ru�en�)
	HCURSOR		m_OldCursor;		// uschovan� kurzor p�ed ta�en�m
	HCURSOR		m_CurCopy;			// kurzor kop�rov�n�
	HCURSOR		m_CurMove;			// kurzor p�esunu
	HCURSOR		m_CurNoDrag;		// z�kaz ta�en�
	HCURSOR		m_CurDelete;		// ta�en� se zru�en�m
	HCURSOR		m_CurAkt;			// aktivn� kurzor p�i operaci

// obsluha ukl�d�n�/na��t�n� souboru
	BOOL		m_Saving;			// prob�h� ukl�d�n�/na��t�n� souboru
	PETHEAD*	m_Head;				// z�hlav� souboru
	DWORD		m_Writen;			// po�et ulo�en�ch/na�ten�ch bajt� v jedn� operaci
	HANDLE		m_File;				// handle souboru
	BOOL		m_OK;				// p��znak operace OK
	CString		m_FileName;			// jm�no souboru

	PETPROG*	m_bufClass;			// buffer prvk� t��d
	int			m_numClass;			// po�et prvk� t��d
	PETPROG*	m_bufObject;		// buffer prvk� glob�ln�ch objekt�
	int			m_numObject;		// po�et prvk� glob�ln�ch objekt�
	PETPROG*	m_bufLocal;			// buffer prvk� lok�ln�ch objekt�
	int			m_numLocal;			// po�et prvk� lok�ln�ch objekt�
	PETPROG*	m_bufEdit;			// buffer prvk� editoru funkc�
	int			m_numEdit;			// po�et prvk� editoru

	int*		m_tabImport;		// konverzn� tabulka importovan�ch funkc�
	char*		m_bufImport;		// buffer text� importovan�ch funkc�
	int			m_maxImport;		// velikost bufferu importovan�ch funkc�
	int			m_numImport;		// po�et importovan�ch funkc� v bufferu
	int			m_sizeImport;		// velikost dat v bufferu importovan�ch funkc�

	char*		m_bufText;			// buffer text�
	int			m_maxText;			// velikost bufferu text�
	int			m_numText;			// po�et text� v bufferu text�
	int			m_sizeText;			// velikost dat v bufferu text�

	signed short int* m_typImport;	// konverzn� tabulka typ� importu
	signed short int* m_refImport;	// konverzn� tabulka referenc� importu

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
