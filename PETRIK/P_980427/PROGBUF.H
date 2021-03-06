
#define	PROGBUFNUM 6				// po�et buffer�

// nem�nit po�ad� - muselo by se zm�nit t� p�i ukl�d�n� souboru !
#define BufIntID 0					// buffer intern�ch funkc� (nem� strom)
#define BufClsID 1					// buffer t��d objekt�
#define BufObjID 2					// buffer ve�ejn�ch objekt�
#define BufLocID 3					// buffer lok�ln�ch objekt�
#define BufEdiID 4					// buffer editace
#define BufStrID 5					// buffer z�kladn�ch prvk� a struktur

// datov� buffery
#define BufNumID PROGBUFNUM			// ��seln� buffer
#define	BufTxtID PROGBUFNUM+1		// textov� buffer
#define BufLogID PROGBUFNUM+2		// logick� buffer
#define BufPicID PROGBUFNUM+3		// buffer s ikonami
#define BufMapID PROGBUFNUM+4		// buffer map

////////////////////////////////////////////////////////////////////
// z�sady pro pou�it� polo�ek programu:
//
// - ROOT polo�ky LOCAL a EDIT nesm� referovat na ��dnou deklaraci,
//   definice LOCAL ukazuje do EDIT nebo do datov�ch buffer�
// - vstupn� parametry lok�ln� definice mus� b�t jako prvn� potomek
//   (vy�aduje funkce CProgBuf::Copy)
// - v�stupn� parametr lok�ln� definice mus� b�t jako druh� potomek
//	 (pot�ebn� p�i testov�n� ta�en� lok�ln� funkce)
// - parametry funkc� a vlastnosti objekt� nelze �lenit do skupin !
//	 (pro mo�nost rozli�en�, zda se jedn� o parametr nebo o prom�nnou)
// - obr�zky maj� ikonu shodnou s daty

////////////////////////////////////////////////////////////////////
// deklara�n� ukazatele REFERENCE:
// -------------------------------
//
//    +--------------------------------------------->
//    |       +------------------------------------->
//    |       |        +---------------------------->
//    |       |        |         +------------------>
//	  |		  |		   |		 |		  +--------->
//  EDIT -> LOCAL -> GLOBAL -> CLASS -> STRUC -> INTERNAL
//    |       +-----------------> 
//    |       |        +------------------>
//    |       +--------------------------->
//    +----------------------------------->

////////////////////////////////////////////////////////////////////
// defini�n� ukazatele DATA (ukazuj� na ROOT polo�ky):
// ---------------------------------------------------
//
//			   +--------------> data
//			   |
// GLOBAL -> LOCAL -> EDIT
// CLASS ------>

////////////////////////////////////////////////////////////////////
// definice polo�ky programu (32 bajt�, 4 bajty asi p�id�v� v�dy ?)

typedef struct tagPROGITEM {
	unsigned short	param;	// parametry
	short int		model;	// model (typ) prvku

	short int		typ;	// blok s deklarac� (-1 = nen�)
	short int 		refer;	// index deklarace (-1 = nen�)

	short int		data;	// blok s definic� (-1 = nen�)
	short int		index;	// index definice (-1 = nen�)

	short int		parent;	// index rodi�e (-1 = nen�)
	short int		childs;	// po�et p��m�ch potomk� v podv�tvi (0 = nejsou)
	short int		items;	// po�et prvk� v podv�tvi v�etn� tohoto prvku
	short int		icon;	// index ikony polo�ky (-1 = implicitn�)
	short int		name;	// index textu jm�na polo�ky (-1 = implicitn�)
	HTREEITEM		htree;	// handle polo�ky ve stromu (NULL = nen�)
	short int		counter; // ��ta� odkaz� pou�it� na tento prvek
} PROGITEM;

// parametry polo�ky programu
#define PR_EXP			0x0001	// parametr - p��znak rozvinut� potomk�
#define PR_LOCK			0x0002	// parametr - uzam�eno (zv�razn�no)
#define PR_OFF			0x0004	// parametr - vypnuto (ze�ednuto)
#define PR_LOCK_DEP		0x0008	// parametr - uzam�eno s odvozen�m
#define PR_OFF_DEP		0x0010	// parametr - vypnuto s odvozen�m
#define PR_ONE			0x0020  // prvek m��e m�t maxim�ln� 1 potomka
#define PR_INTERNAL		0x0040	// z�kaz ru�en� a p�esunu - v�choz� prvek (po kopii se nuluje)
#define PR_NOMOVE		0x0080	// z�kaz ru�en�, kop�rov�n� a p�esouv�n� prvku
#define PR_GROUP		0x0100	// prvek je skupina - mus� b�t pr�choz� pro parametry
#define PR_LIST			0x0200	// prvek je seznam
#define PR_GET_COMMAND	0x0400	// p�ij�m� p��kazy
#define PR_AS_COMMAND	0x0800	// m��e b�t pou�ito jako p��kaz
#define PR_GET_EXPRES	0x1000	// p�ij�m� v�razy
#define PR_AS_EXPRES	0x2000	// m��e b�t pou�ito jako v�raz
#define PR_GET_BOOL		0x4000	// p�ij�m� logick� v�raz
#define PR_AS_BOOL		0x8000	// m��e b�t pou�ito jako logick� v�raz

// modely (typy) prvk�
#define	TYP_NONE		0			// nezn�m� funkce
#define TYP_IGROUP		TYP_NONE+1	// intern� skupina (nelze kop�rovat)
#define	TYP_GROUP		TYP_NONE+2	// skupina
#define	TYP_LIST		TYP_NONE+3	// seznam
#define TYP_ROOT		TYP_NONE+4	// fiktivn� ROOT prvek okna
#define TYP_IPARAM		TYP_NONE+5	// vstupn� parametr
#define TYP_OPARAM		TYP_NONE+6	// v�stupn� parametr
#define TYP_PROPERTIES	TYP_NONE+7	// vlastnosti
#define TYP_PROP_WRITE	TYP_NONE+8	// z�pis do vlastnosti
#define TYP_PROP_READ	TYP_NONE+9	// �ten� z vlastnosti
#define	TYP_NONE_		TYP_NONE+10

#define	TYP_IF			TYP_NONE_	// konstrukce IF
#define	TYP_IF_TEST		TYP_IF+1	// test podm�nky IF
#define	TYP_IF_YES		TYP_IF+2	// podm�nka IF spln�na
#define	TYP_IF_NO		TYP_IF+3	// podm�nka IF nespln�na
#define	TYP_IF_			TYP_IF+4

#define	TYP_WHILE		TYP_IF_		// konstrukce WHILE
#define	TYP_WHILE_TEST	TYP_WHILE+1	// test podm�nky WHILE
#define	TYP_WHILE_BODY	TYP_WHILE+2	// t�lo WHILE
#define	TYP_WHILE_BREAK	TYP_WHILE+3	// p�eru�en� WHILE
#define	TYP_WHILE_		TYP_WHILE+4

#define	TYP_CASE		TYP_WHILE_	// konstrukce CASE
#define	TYP_CASE_EXPR	TYP_CASE+1	// v�raz pro CASE
#define	TYP_CASE_ON		TYP_CASE+2	// v�tev CASE
#define	TYP_CASE_TEST	TYP_CASE+3	// test v�tve CASE
#define	TYP_CASE_DEF	TYP_CASE+4	// implicitn� v�tev CASE
#define	TYP_CASE_		TYP_CASE+5

#define	TYP_NUM			TYP_CASE_	// ��seln� konstanta
#define	TYP_CIS			TYP_NUM+1	// ��slice
#define	TYP_TECKA		TYP_NUM+2	// desetinn� te�ka
#define	TYP_MINUS		TYP_NUM+3	// znam�nko v ��sle
#define	TYP_EXPONENT	TYP_NUM+4	// exponent ��sla
#define TYP_TXT			TYP_NUM+5	// textov� konstanta
#define	TYP_NUM_		TYP_NUM+6

#define	TYP_OPER		TYP_NUM_	// matematick� oper�tor
#define	TYP_COMP		TYP_OPER+1	// porovn�vac� oper�tor
#define	TYP_ANDOR		TYP_OPER+2	// logick� oper�tor
#define TYP_EQU_TEXT	TYP_OPER+3	// shodnost text�
#define TYP_EQU_PIC		TYP_OPER+4	// shodnost obr�zk�
#define	TYP_OPER_		TYP_OPER+5

// hodnoty TYP_FUNC a TYP_FUNC_ se pou��vaj� jako interval
// k testu zobrazen� p��znaku nastavov�n� hodnoty prvku u ikony
#define	TYP_FUNC		TYP_OPER_	// u�ivatelsk� funkce (!!!!)
#define	TYP_REAL		TYP_FUNC+1	// ��seln� prom�nn�
#define	TYP_BOOL		TYP_FUNC+2	// logick� prom�nn�
#define	TYP_TEXT		TYP_FUNC+3	// textov� prom�nn�
#define	TYP_PIC			TYP_FUNC+4	// prom�nn� s obr�zkem
#define TYP_MAP			TYP_FUNC+5	// prom�nn� s mapou
#define	TYP_SND			TYP_FUNC+6	// prom�nn� se zvukem
#define	TYP_MUS			TYP_FUNC+7	// prom�nn� s hudbou
#define	TYP_SPRITE		TYP_FUNC+8	// prom�nn� se sprajtem
#define	TYP_DIALOG		TYP_FUNC+9	// prom�nn� s dialogem
#define TYP_EVENT		TYP_FUNC+10	// prom�nn� s ud�lost�
#define	TYP_CLASS		TYP_FUNC+11	// u�ivatelsk� t��da (!!!!)
#define	TYP_FUNC_		TYP_FUNC+12

#define	TYP_F			TYP_FUNC_	// intern� funkce - jen jako p��kaz bez parametr�
#define	TYP_FN			TYP_F+1		// intern� funkce - vrac� ��slo
#define	TYP_FNN			TYP_F+2		// intern� funkce - vrac� i p�ij�m� ��slo
#define	TYP_FNT			TYP_F+3		// intern� funkce - vrac� ��slo, p�ij�m� text
#define	TYP_F0N			TYP_F+4		// intern� funkce - p�ij�m� ��slo
#define	TYP_FT			TYP_F+5		// intern� funkce - vrac� text
#define	TYP_FTN			TYP_F+6		// intern� funkce - vrac� text, p�ij�m� ��slo
#define	TYP_FTT			TYP_F+7		// intern� funkce - vrac� text, p�ij�m� text
#define	TYP_FTNT		TYP_F+8		// intern� funkce - vrac� text, p�ij�m� ��slo a text
#define	TYP_FB			TYP_F+9		// intern� funkce - vrac� logickou hodnotu
#define	TYP_FBN			TYP_F+10	// intern� funkce - vrac� logickou hodnotu, p�ij�m� ��slo
#define	TYP_FBB			TYP_F+11	// intern� funkce - vrac� i p�ij�m� logickou hodnotu
#define	TYP_F_			TYP_F+12

#define	TYP_			TYP_F_		// po�et typ� celkem (ponechat posledn� !!!!!)


/////////////////////////////////////////////////////////////////////////////
// indexy stavov�ch ikon

#define STATE_NONE		0			// nen� stav
#define STATE_SELECT	1			// vybran� polo�ka
#define STATE_SET		2			// nastaven� hodnoty polo�ky

/////////////////////////////////////////////////////////////////////////////
// indexy intern�ch funkc� (pro referenci do seznamu vnit�n�ch funkc�)

enum FncTyp
{
	FncNone = 0,	// nezn�m� funkce
	FncGroup,		// skupina
	FncIf,			// IDI_IF
	FncIfCond,		// IDI_IF_COND
	FncIfYes,		// IDI_IF_YES
	FncIfNo,		// IDI_IF_NO
	FncWhile,		// IDI_WHILE
	FncWhileCond,	// IDI_WHILE_COND
	FncWhileBody,	// IDI_WHILE_BODY
	FncWhileBreak,	// IDI_WHILE_BREAK
	FncMinus,		// IDI_MINUS
	FncCase,		// IDI_CASE
	FncCaseSum, 	// IDI_CASE_SUM
	FncCaseOn,		// IDI_CASE_ON
	FncCaseEqu, 	// IDI_CASE_EQU
	FncCaseDef, 	// IDI_CASE_DEF
	FncNum, 		// IDI_NUM
	FncNum0,		// IDI_0
	FncNum1,		// IDI_1
	FncNum2,		// IDI_2
	FncNum3,		// IDI_3
	FncNum4,		// IDI_4
	FncNum5,		// IDI_5
	FncNum6,		// IDI_6
	FncNum7,		// IDI_7
	FncNum8,		// IDI_8
	FncNum9,		// IDI_9
	FncDot, 		// IDI_DOT
	FncExp, 		// IDI_EXP
	FncEqu, 		// IDI_EQU
	FncNEqu,		// IDI_NEQU
	FncEqGr,		// IDI_EQGR
	FncEqLt,		// IDI_EQLT
	FncGr,			// IDI_GR
	FncLt,			// IDI_LT
	FncAnd, 		// IDI_AND
	FncOr,			// IDI_OR
	FncXor, 		// IDI_XOR
	FncNot, 		// IDI_NOT
	FncAdd, 		// IDI_ADD
	FncSub, 		// IDI_SUB
	FncMul, 		// IDI_MUL
	FncDiv, 		// IDI_DIV
	FncInt, 		// IDI_INT
	FncPic, 		// IDI_PIC
	FncSnd, 		// IDI_SND
	FncMus, 		// IDI_MUS
	FncFnc, 		// IDI_FNC
	FncMap, 		// IDI_MAP
	FncSprite,		// IDI_SPRITE
	FncClass,		// IDI_CLASS
	FncText,		// IDI_TEXT
	FncDialog,		// IDI_DIALOG
	FncPar, 		// IDI_PAR
	FncOut, 		// IDI_OUT
	FncEvent,		// IDI_EVENT
	FncList,		// IDI_LIST
	FncOper,		// IDI_OPER
	FncKrok,		// IDI_KROK
	FncVlevo,		// IDI_VLEVO
	FncVpravo,		// IDI_VPRAVO
	FncVzad,		// IDI_VZAD
	FncPetrik,		// IDI_PETRIK
	FncBool,		// IDI_LOGIC
	FncTextConst,	// IDI_TEXT_CONST
	FncTrue,		// IDI_TRUE
	FncFalse,		// IDI_FALSE
	FncPetra,		// IDI_PETRA
	FncPetraKrok,	// IDI_PETRA_KROK
	FncPetraVlevo,	// IDI_PETRA_VLEVO
	FncPetraVpravo, // IDI_PETRA_VPRAVO
	FncPetraVzad,	// IDI_PETRA_VZAD
	FncRychle,		// IDI_RYCHLE
	FncExit,		// IDI_EXIT
	FncPetraRychle, // IDI_PETRA_RYCHLE
	FncPetraPomalu, // IDI_PETRA_POMALU  // zru�eno !!!!!!!!!!
	FncPredmet, 	// IDI_PREDMET
	FncSmer,		// IDI_SMER
	FncPoziceX, 	// IDI_POZICEX
	FncPoziceY, 	// IDI_POZICEY
	FncPetraPredmet,	// IDI_PETRA_PREDMET
	FncPetraSmer,		// IDI_PETRA_SMER
	FncPetraPoziceX,	// IDI_PETRA_POZICEX
	FncPetraPoziceY,	// IDI_PETRA_POZICEY
	FncConst,		// IDI_CONST
	FncVypoc,		// IDI_VYPOC
	FncFunc,		// IDI_FUNC
	FncPorovnani,	// IDI_POROVNANI
	FncLogOper, 	// IDI_LOG_OPER
	FncMod, 		// IDI_MOD
	FncSin, 		// IDI_SIN
	FncCos, 		// IDI_COS
	FncTg,			// IDI_TG
	FncCoTg,		// IDI_COTG
	FncArcSin,		// IDI_ARCSIN
	FncArcCos,		// IDI_ARCCOS
	FncArcTg,		// IDI_ARCTG
	FncArcCoTg, 	// IDI_ARCCOTG
	FncPi,			// IDI_PI
	FncInteger, 	// IDI_INTEGER
	FncFrac,		// IDI_FRAC
	FncAbs, 		// IDI_ABS
	FncSqrt,		// IDI_SQRT
	FncFact,		// IDI_FACT
	FncRand,		// IDI_RAND
	FncEul, 		// IDI_EUL
	FncDegRad,		// IDI_DEGRAD
	FncRadDeg,		// IDI_RADDEG
	FncLogar,		// IDI_LOG
	FncLn,			// IDI_LN
	FncPExp,		// IDI_PEXP
	FncMocn,		// IDI_MOCN
	FncUhel,		// IDI_UHEL
	FncUhel0,		// IDI_UHEL0
	FncUhel45,		// IDI_UHEL45
	FncUhel90,		// IDI_UHEL90
	FncUhel135, 	// IDI_UHEL135,
	FncUhel180, 	// IDI_UHEL180
	FncUhel225, 	// IDI_UHEL225
	FncUhel270, 	// IDI_UHEL270
	FncUhel315, 	// IDI_UHEL315
	FncCommand, 	// IDI_COMMAND
	FncWait,		// IDI_WAIT
	FncKlav,		// IDI_KLAV
	FncKlavTest,	// IDI_KLAV_TEST
	FncKlavVKey,	// IDI_KLAV_VKEY
	FncKlavChar,	// IDI_KLAV_CHAR
	FncKlavVK,		// IDI_KLAV_VK
	FncKlavFX,		// IDI_KLAV_FX
	FncKlavPism,	// IDI_KLAV_PISM
	FncKlavNum, 	// IDI_KLAV_NUM
	FncKlavRuzne,	// IDI_KLAV_RUZNE
	FncKlavRid, 	// IDI_KLAV_RID
	FncKlavShift,	// IDI_KLAV_SHIFT  (zru�eno)
	FncF1,			// IDI_F1
	FncF2,			// IDI_F2
	FncF3,			// IDI_F3
	FncF4,			// IDI_F4
	FncF5,			// IDI_F5
	FncF6,			// IDI_F6
	FncF7,			// IDI_F7
	FncF8,			// IDI_F8
	FncF9,			// IDI_F9
	FncF10, 		// IDI_F10
	FncF11, 		// IDI_F11
	FncF12, 		// IDI_F12
	FncA,			// IDI_A
	FncB,			// IDI_B
	FncC,			// IDI_C
	FncD,			// IDI_D
	FncE,			// IDI_E
	FncF,			// IDI_F
	FncG,			// IDI_G
	FncH,			// IDI_H
	FncI,			// IDI_I
	FncJ,			// IDI_J
	FncK,			// IDI_K
	FncL,			// IDI_L
	FncM,			// IDI_M
	FncN,			// IDI_N
	FncO,			// IDI_O
	FncP,			// IDI_P
	FncQ,			// IDI_Q
	FncR,			// IDI_R
	FncS,			// IDI_S
	FncT,			// IDI_T
	FncU,			// IDI_U
	FncV,			// IDI_V
	FncW,			// IDI_W
	FncX,			// IDI_X
	FncY,			// IDI_Y
	FncZ,			// IDI_Z
	FncVKNum0,		// IDI_VK_NUM0
	FncVKNum1,		// IDI_VK_NUM1
	FncVKNum2,		// IDI_VK_NUM2
	FncVKNum3,		// IDI_VK_NUM3
	FncVKNum4,		// IDI_VK_NUM4
	FncVKNum5,		// IDI_VK_NUM5
	FncVKNum6,		// IDI_VK_NUM6
	FncVKNum7,		// IDI_VK_NUM7
	FncVKNum8,		// IDI_VK_NUM8
	FncVKNum9,		// IDI_VK_NUM9
	FncVKNumTecka,	// IDI_VK_NUMTECKA
	FncVKNumPlus,	// IDI_VK_NUMPLUS
	FncVKNumMinus,	// IDI_VK_NUMMINUS
	FncVKNumKrat,	// IDI_VK_NUMKRAT
	FncVKNumDeleno, // IDI_VK_NUMDELENO
	FncVKNumEnter,	// IDI_VK_NUMENTER
	FncVKNumLock,	// IDI_VK_NUMLOCK
	FncVK1, 		// IDI_VK_1
	FncVK2, 		// IDI_VK_2
	FncVK3, 		// IDI_VK_3
	FncVK4, 		// IDI_VK_4
	FncVK5, 		// IDI_VK_5
	FncVK6, 		// IDI_VK_6
	FncVK7, 		// IDI_VK_7
	FncVK8, 		// IDI_VK_8
	FncVK9, 		// IDI_VK_9
	FncVK0, 		// IDI_VK_0
	FncVKLCarka,	// IDI_VK_LCARKA
	FncVKPomlcka,	// IDI_VK_POMLCKA
	FncVKRovnitko,	// IDI_VK_ROVNITKO
	FncVKZLomitko,	// IDI_VK_ZLOMITKO
	FncVKLLomena,	// IDI_VK_LLOMENA
	FncVKRLomena,	// IDI_VK_RLOMENA
	FncVKStrednik,	// IDI_VK_STREDNIK
	FncVKRCarka,	// IDI_VK_RCARKA
	FncVKCarka, 	// IDI_VK_CARKA
	FncVKTecka, 	// IDI_VK_TECKA
	FncVKLomitko,	// IDI_VK_LOMITKO
	FncVKEsc,		// IDI_VK_ESC
	FncVKTab,		// IDI_VK_TAB
	FncVKCapsLock,	// IDI_VK_CAPSLOCK
	FncVKWin,		// IDI_VK_WIN
	FncVKBS,		// IDI_VK_BS
	FncVKEnter, 	// IDI_VK_ENTER
	FncVKMenu,		// IDI_VK_MENU
	FncVKLeft,		// IDI_VK_LEFT
	FncVKRight, 	// IDI_VK_RIGHT
	FncVKUp,		// IDI_VK_UP
	FncVKDown,		// IDI_VK_DOWN
	FncVKInsert,	// IDI_VK_INSERT
	FncVKDelete,	// IDI_VK_DELETE
	FncVKHome,		// IDI_VK_HOME
	FncVKEnd,		// IDI_VK_END
	FncVKPageUp,	// IDI_VK_PAGEUP
	FncVKPageDown,	// IDI_VK_PAGEDOWN
	FncVKPrint, 	// IDI_VK_PRINT
	FncVKScroll,	// IDI_VK_SCROLL
	FncVKPause, 	// IDI_VK_PAUSE
	FncVKShift, 	// IDI_VK_SHIFT
	FncVKCtrl,		// IDI_VK_CTRL
	FncVKAlt,		// IDI_VK_ALT
	FncVKSpace, 	// IDI_VK_SPACE
	FncMouse,		// IDI_MOUSE
	FncMouseL,		// IDI_MOUSE_L
	FncMouseR,		// IDI_MOUSE_R
	FncMouseX,		// IDI_MOUSE_X
	FncMouseY,		// IDI_MOUSE_Y
	FncEquText,		// IDI_EQU_TEXT
	FncEquPic,		// IDI_EQU_PIC
	FncPropWrite,	// IDI_PROP_WRITE
	FncPropRead,	// IDI_PROP_READ
	FncProperties,	// IDI_PROPERTIES
	FncCommandLine,	// IDI_COMMAND_LINE
	FncReturnCode,	// IDI_RETURN_CODE

	_FncLast_		// posledn� typ - ud�v� po�et
};


////////////////////////////////////////////////////////////////////
// t��da bufferu programu

// Prom�nn� jsou typu "short int", proto�e nen� podporov�n v�t�� po�et
// index� ne� short (nap�. omezen� po�tu text� v seznamu). Je tak mo�n�
// l�pe vnit�n� optimalizovat funkce.

class CProgBuf : public CObject
{
public:
	CProgBuf();					// konstruktor
	virtual ~CProgBuf();		// destruktor

	short int	m_BufID;		// ID tohoto bufferu (= index bufferu v seznamu)
	PROGITEM*	m_Items;		// buffer polo�ek
	short int	m_Num;			// po�et polo�ek v bufferu
	short int	m_Max;			// maxim�ln� polo�ek v bufferu
	short int	m_First;		// prvn� zobrazen� polo�ka bufferu ve stromu
	short int	m_Next;			// n�sleduj�c� (nezobrazen�) polo�ka bufferu
								//  m_Next = -1 zabr�n� zobrazov�n� polo�ek
	short int	m_AktDef;		// aktivn� definovan� polo�ka (-1 = nen�)
	CTreeCtrl*	m_Tree;			// odkaz na zobrazen� strom (NULL = nen�)
	CProgBuf*	m_ProgBuf;		// mapa v�ech buffer� programu
	CRealBuf*	m_Real;			// ��seln� buffer BufNumID
	CBoolBuf*	m_Bool;			// logick� buffer BufLogID
	CTextBuf*	m_Text;			// seznam text� (sd�len�) - krom� BufIntID je to
								//   buffer u�ivatelsk�ch text� BufTxtID
	CIconBuf*	m_Icon;			// buffer obr�zk�

	BOOL		m_ReIcon;		// po�adavek aktualizace zobrazen� ikon a strom�

// vlo�en� polo�ky do bufferu (vrac� opraven� skute�n� index nebo -1=chyba)
// po�adovan� platn� polo�ky v PROGITEM:
//		parent - index rodi�e, kter�mu polo�ka pat�� (-1 = bude v ROOT)
//				 Parametr Index ud�v� m�sto, kam m� b�t polo�ka vlo�ena.
//				 Index m��e b�t libovoln�, je opravov�n aby skute�n�
//				 pat�il do podv�tve po�adovan�ho rodi�e.
// nepou�it� polo�ky v PROGITEM (jsou dopln�ny):
//		childs - po�et p��m�ch potomk� (je aktualizov�no automaticky)
//		items - po�et prvk� ve v�tvi (je aktualizov�no automaticky)
//		htree - identifik�tor polo�ky stromu (je dopln�no automaticky)
//		counter - ��ta� odkaz� na polo�ku (je aktualizov�no automaticky)
		
	short int Insert(PROGITEM* item, short int Index = -1);

// zru�en� polo�ky z bufferu (rekurzivn�, se zru�en�m potomk�!)
// na ru�en� polo�ky se nesm� nic odkazovat (counter = 0 !)
	void Delete(short int Index);

////////////////////////////////////////////////////////////////////
// zru�en� v�tve stromu (v�etn� z�visl�ch prvk� a dat)
//
// - zru�� referen�n� polo�ky, kter� referuj� na n�kter� prvek ve v�tvi
// - zru�� datov� buffery, na kter� ukazuj� polo�ky ve v�tvi
	void DeleteTre(short Index);

// nalezen� polo�ky podle handle (vrac� index, -1 = nenalezeno)
	short int SrcItem(HTREEITEM hItem);

// p�ekreslen� (aktualizace) stromu
	void ReDisp();

/////////////////////////////////////////////////////////////////////////////
// kopie v�tve prvk�
//
// prov�d� korekce:
//		- nulov�n� p��znaku PR_INTERNAL
//		- zaji�t�n� kop�rov�n� n�kter�ch polo�ek bez potomk�
//		- zm�na reference na zdrojov� okno
//		- rozvinut� v�tve p�i kopii ze stromu struktur
//		  nebo p�i kopii do nerozvinut� polo�ky
//
// vstupn� prom�nn�:
//		dst		- index c�lov� polo�ky
//		parent	- index rodi�e c�lov� polo�ky
//		bufID	- ID zdrojov�ho bufferu
//		src		- index zdrojov� polo�ky
//
// vrac� opraven� index c�lov� polo�ky
	short int Copy(short int dst, short int parent, short int bufID, short int src);
	short int Copy2(short int& dst, short int parent, short int bufID, short int& src);

/////////////////////////////////////////////////////////////////////////////
// nastaven� prvn� zobrazen� polo�ky s p��padn�m p�ekreslen�m,
// po�adovan� index m��e b�t ve v�tvi (nemus� b�t ROOT)
	BOOL SetFirst(short First);

/////////////////////////////////////////////////////////////////////////////
// nalezen� textu k polo�ce
	CString GetName(short Index);

/////////////////////////////////////////////////////////////////////////////
// nalezen� ikony k polo�ce
	short GetIcon(short Index);

/////////////////////////////////////////////////////////////////////////////
// nalezen� polo�ky odkazuj�c� se na po�adovan� data (-1 = nenalezeno)
	short int SrcDat(short bufID, short Index);

/////////////////////////////////////////////////////////////////////////////
// hled�n� referen�n� polo�ky v bufferu od aktu�ln� polo�ky (-1 = nenalezeno)
//
// vstup:
//	bufID - ��slo bufferu hledan� reference
//	Index - index hledan� reference
//	Smer  - po�adovan� sm�r (od aktu�ln� polo�ky) 1 nebo -1
	short int SrcRef(short bufID, short Index, short Smer);

/////////////////////////////////////////////////////////////////////////////
// nalezen� aktivn� polo�ky (-1 = nen� ��dn� polo�ka)
	short int GetAkt();

/////////////////////////////////////////////////////////////////////////////
// nastaven� aktivn� polo�ky (-1 = vypnuta)
	void SetAkt(short Index);

/////////////////////////////////////////////////////////////////////////////
// nastaven� zam��en� na okno
	void SetFocus();

/////////////////////////////////////////////////////////////////////////////
// ozna�en� definovan� polo�ky (-1 = odzna�en�)
	void SetDef(short int Index);

/////////////////////////////////////////////////////////////////////////////
// p�esun v�tve stromu uvnit� bufferu (v�etn� zm�n referenc�), vrac� c�lov� index
//
// - p�esm�ruje reference na polo�ky ve v�tvi
// - p�id� nebo ubere parametry funkc� v programu
// - p�id� nebo ubere vlastnosti t��d 
	short MoveTre(short dst, short parent, short src);

/////////////////////////////////////////////////////////////////////////////
// vytvo�en� dat polo�ky (nejsou-li vytvo�ena)
	void InitDat(short Index);

};

inline void Aloc(PROGITEM*& adr, int size)
	{ adr = (PROGITEM*)_Aloc(adr, size); }

