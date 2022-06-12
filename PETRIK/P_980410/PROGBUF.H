
#define	PROGBUFNUM 6				// poèet bufferù

// nemìnit poøadí - muselo by se zmìnit též pøi ukládání souboru !
#define BufIntID 0					// buffer interních funkcí (nemá strom)
#define BufClsID 1					// buffer tøíd objektù
#define BufObjID 2					// buffer veøejných objektù
#define BufLocID 3					// buffer lokálních objektù
#define BufEdiID 4					// buffer editace
#define BufStrID 5					// buffer základních prvkù a struktur

////////////////////////////////////////////////////////////////////
// zásady pro použití položek programu:
//
// - neplatný deklaraèní nebo definièní ukazatel se zjistí podle
//	 indexové položky = -1, ukazatel na blok se pøitom ignoruje,
//	 musí ukazovat buï na nìkterý (implicitní) datový blok nebo = -1.
// - funkce se identifikují modelem TYP_FUNC, tøídy modelem TYP_CLASS
// - ROOT položky GLOBAL/hlavní, LOCAL a EDIT maji vždy model funkce TYP_FUNC
//	 a nesmí ukazovat na žádnou deklaraci (pro správnou aktualizaci LOCK a OFF)
// - pøi neplatném deklaraèním ukazateli ukazuje jméno a ikona na
//   0 a INTERNALNUM, takže není potøeba ovìøovat platnost ukazatele
//   pøi hledání implicitního jména èi ikony
// - Definice funkce z GLOBAL ukazuje vždy do LOCAL (není potøeba
//	 kontrolovat), definice funkce (vèetnì ROOT) ukazuje vždy do EDIT,
//	 definice tøídy ukazuje vždy do LOCAL
// - pro index ukazatele jiný než -1 musí být i ukazatel bloku platný!
// - INTERN - definièní i deklaraèní ukazatele neplatné
// - STRUCT - definièní ukazatele neplatné, deklaraèní ukazují
//   na interní buffer
// - CLASS - deklaraèní ukazují na interní buffer, definièní
//	 ukazují do lokálních objektù (uživatelské tøídy) nebo do 
//   datových bufferù (inicializaèní nastavení - promìnné atd.)
// - GLOBAL - deklaraèní ukazatele do CLASS, INTERN nebo STRUC,
//	 definièní ukazatele do LOCAL (na ROOT položky) nebo do
//	 bufferù objektù (èísla, obrázky atd.)
// - LOCAL - deklaraèní ukazatele do CLASS, INTERN, STRUC, GLOBAL,
//	 definièní ukazatele do EDIT (na ROOT položky) nebo do
//	 bufferù objektù (èísla, obrázky atd.), ROOT položka neukazuje
//	 deklaraci nikam, definice ukazuje do EDIT (funkce)
// - EDIT - deklaraèní ukazatele do LOCAL, GLOBAL, INTERN, STRUC,
//	 definièní ukazatele neukazují nikam. ROOT položka neukazují
//	 oba ukazatele nikam.

////////////////////////////////////////////////////////////////////
// definice položky programu (32 bajtù, 4 bajty asi pøidává vždy ?)

typedef struct tagPROGITEM {
	unsigned short	param;	// parametry
	short int		model;	// model (typ) prvku

	short int		typ;	// blok s deklarací (-1 = není)
	short int 		refer;	// index deklarace (-1 = není)

	short int		data;	// blok s definicí (-1 = není)
	short int		index;	// index definice (-1 = není)

	short int		parent;	// index rodièe (-1 = není)
	short int		childs;	// poèet pøímých potomkù v podvìtvi (0 = nejsou)
	short int		items;	// poèet prvkù v podvìtvi vèetnì tohoto prvku
	short int		icon;	// index ikony položky (-1 = implicitní)
	short int		name;	// index textu jména položky (-1 = implicitní)
	HTREEITEM		htree;	// handle položky ve stromu (NULL = není)
	short int		counter; // èítaè odkazù použití na tento prvek
} PROGITEM;

// parametry položky programu
#define PR_EXP			0x0001	// parametr - pøíznak rozvinutí potomkù
#define PR_LOCK			0x0002	// parametr - uzamèeno (zvýraznìno)
#define PR_OFF			0x0004	// parametr - vypnuto (zešednuto)
#define PR_LOCK_DEP		0x0008	// parametr - uzamèeno s odvozením
#define PR_OFF_DEP		0x0010	// parametr - vypnuto s odvozením
#define PR_ONE			0x0020  // prvek mùže mít maximálnì 1 potomka
#define PR_INTERNAL		0x0040	// zákaz rušení a pøesunu - výchozí prvek (po kopii se nuluje)
#define PR_NOMOVE		0x0080	// zákaz rušení, kopírování a pøesouvání prvku
#define PR_GROUP		0x0100	// prvek je skupina - musí být prùchozí pro parametry
#define PR_LIST			0x0200	// prvek je seznam
#define PR_GET_COMMAND	0x0400	// pøijímá pøíkazy
#define PR_AS_COMMAND	0x0800	// mùže být použito jako pøíkaz
#define PR_GET_EXPRES	0x1000	// pøijímá výrazy
#define PR_AS_EXPRES	0x2000	// mùže být použito jako výraz
#define PR_GET_BOOL		0x4000	// pøijímá logický výraz
#define PR_AS_BOOL		0x8000	// mùže být použito jako logický výraz

// modely (typy) prvkù
#define	TYP_NONE		0			// neznámá funkce
#define TYP_IGROUP		TYP_NONE+1	// interní skupina (nelze kopírovat)
#define	TYP_GROUP		TYP_NONE+2	// skupina
#define	TYP_LIST		TYP_NONE+3	// seznam
#define TYP_ROOT		TYP_NONE+4	// fiktivní ROOT prvek okna
#define TYP_IPARAM		TYP_NONE+5	// vstupní parametr
#define TYP_OPARAM		TYP_NONE+6	// výstupní parametr
#define	TYP_NONE_		TYP_NONE+7

#define	TYP_IF			TYP_NONE_	// konstrukce IF
#define	TYP_IF_TEST		TYP_IF+1	// test podmínky IF
#define	TYP_IF_YES		TYP_IF+2	// podmínka IF splnìna
#define	TYP_IF_NO		TYP_IF+3	// podmínka IF nesplnìna
#define	TYP_IF_			TYP_IF+4

#define	TYP_WHILE		TYP_IF_		// konstrukce WHILE
#define	TYP_WHILE_TEST	TYP_WHILE+1	// test podmínky WHILE
#define	TYP_WHILE_BODY	TYP_WHILE+2	// tìlo WHILE
#define	TYP_WHILE_BREAK	TYP_WHILE+3	// pøerušení WHILE
#define	TYP_WHILE_		TYP_WHILE+4

#define	TYP_CASE		TYP_WHILE_	// konstrukce CASE
#define	TYP_CASE_EXPR	TYP_CASE+1	// výraz pro CASE
#define	TYP_CASE_ON		TYP_CASE+2	// vìtev CASE
#define	TYP_CASE_TEST	TYP_CASE+3	// test vìtve CASE
#define	TYP_CASE_DEF	TYP_CASE+4	// implicitní vìtev CASE
#define	TYP_CASE_		TYP_CASE+5

#define	TYP_NUM			TYP_CASE_	// èíselná konstanta
#define	TYP_CIS			TYP_NUM+1	// èíslice
#define	TYP_TECKA		TYP_NUM+2	// desetinná teèka
#define	TYP_MINUS		TYP_NUM+3	// znaménko v èísle
#define	TYP_EXPONENT	TYP_NUM+4	// exponent èísla
#define TYP_TXT			TYP_NUM+5	// textová konstanta
#define	TYP_NUM_		TYP_NUM+6

#define	TYP_OPER		TYP_NUM_	// matematický operátor
#define	TYP_COMP		TYP_OPER+1	// porovnávací operátor
#define	TYP_ANDOR		TYP_OPER+2	// logický operátor
#define TYP_EQU_TEXT	TYP_OPER+3	// shodnost textù
#define TYP_EQU_PIC		TYP_OPER+4	// shodnost obrázkù
#define	TYP_OPER_		TYP_OPER+5

// hodnoty TYP_FUNC a TYP_FUNC_ se používají jako interval
// k testu zobrazení pøíznaku nastavování hodnoty prvku u ikony
#define	TYP_FUNC		TYP_OPER_	// uživatelská funkce (!!!!)
#define	TYP_REAL		TYP_FUNC+1	// èíselná promìnná
#define	TYP_BOOL		TYP_FUNC+2	// logická promìnná
#define	TYP_TEXT		TYP_FUNC+3	// textová promìnná
#define	TYP_PIC			TYP_FUNC+4	// promìnná s obrázkem
#define TYP_MAP			TYP_FUNC+5	// promìnná s mapou
#define	TYP_SND			TYP_FUNC+6	// promìnná se zvukem
#define	TYP_MUS			TYP_FUNC+7	// promìnná s hudbou
#define	TYP_SPRITE		TYP_FUNC+8	// promìnná se sprajtem
#define	TYP_DIALOG		TYP_FUNC+9	// promìnná s dialogem
#define TYP_EVENT		TYP_FUNC+10	// promìnná s událostí
#define	TYP_CLASS		TYP_FUNC+11	// uživatelská tøída (!!!!)
#define	TYP_FUNC_		TYP_FUNC+12

#define	TYP_F			TYP_FUNC_	// interní funkce - jen jako pøíkaz bez parametrù
#define	TYP_FN			TYP_F+1		// interní funkce - vrací èíslo
#define	TYP_FNN			TYP_F+2		// interní funkce - vrací i pøijímá èíslo
#define	TYP_FNT			TYP_F+3		// interní funkce - vrací èíslo, pøijímá text
#define	TYP_F0N			TYP_F+4		// interní funkce - pøijímá èíslo
#define	TYP_FT			TYP_F+5		// interní funkce - vrací text
#define	TYP_FTN			TYP_F+6		// interní funkce - vrací text, pøijímá èíslo
#define	TYP_FTT			TYP_F+7		// interní funkce - vrací text, pøijímá text
#define	TYP_FTNT		TYP_F+8		// interní funkce - vrací text, pøijímá èíslo a text
#define	TYP_FB			TYP_F+9		// interní funkce - vrací logickou hodnotu
#define	TYP_FBN			TYP_F+10	// interní funkce - vrací logickou hodnotu, pøijímá èíslo
#define	TYP_FBB			TYP_F+11	// interní funkce - vrací i pøijímá logickou hodnotu
#define	TYP_F_			TYP_F+12

#define	TYP_			TYP_F_		// poèet typù celkem (ponechat poslední !!!!!)


/////////////////////////////////////////////////////////////////////////////
// indexy stavových ikon

#define STATE_NONE		0			// není stav
#define STATE_SELECT	1			// vybraná položka
#define STATE_SET		2			// nastavení hodnoty položky

/////////////////////////////////////////////////////////////////////////////
// indexy interních funkcí (pro referenci do seznamu vnitøních funkcí)

enum FncTyp
{
	FncNone = 0,	// neznámá funkce
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
	FncPetraPomalu, // IDI_PETRA_POMALU  // zrušeno !!!!!!!!!!
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
	FncKlavShift,	// IDI_KLAV_SHIFT  (zrušeno)
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

	_FncLast_		// poslední typ - udává poèet
};


////////////////////////////////////////////////////////////////////
// tøída bufferu programu

// Promìnné jsou typu "short int", protože není podporován vìtší poèet
// indexù než short (napø. omezení poètu textù v seznamu). Je tak možné
// lépe vnitønì optimalizovat funkce.

class CProgBuf : public CObject
{
public:
	CProgBuf();					// konstruktor
	virtual ~CProgBuf();		// destruktor

	short int	m_BufID;		// ID tohoto bufferu (= index bufferu v seznamu)
	PROGITEM*	m_Items;		// buffer položek
	short int	m_Num;			// poèet položek v bufferu
	short int	m_Max;			// maximálnì položek v bufferu
	short int	m_First;		// první zobrazená položka bufferu ve stromu
	short int	m_Next;			// následující (nezobrazená) položka bufferu
								//  m_Next = -1 zabrání zobrazování položek
	short int	m_AktDef;		// aktivní definovaná položka (-1 = není)
	CTreeCtrl*	m_Tree;			// odkaz na zobrazený strom (NULL = není)
	CProgBuf*	m_ProgBuf;		// mapa všech bufferù programu
	CTextBuf*	m_Text;			// seznam textù (sdílený)

// vložení položky do bufferu (vrací opravený skuteèný index nebo -1=chyba)
// požadované platné položky v PROGITEM:
//		parent - index rodièe, kterému položka patøí (-1 = bude v ROOT)
//				 Parametr Index udává místo, kam má být položka vložena.
//				 Index mùže být libovolný, je opravován aby skuteènì
//				 patøil do podvìtve požadovaného rodièe.
// nepoužité položky v PROGITEM (jsou doplnìny):
//		childs - poèet pøímých potomkù (je aktualizováno automaticky)
//		items - poèet prvkù ve vìtvi (je aktualizováno automaticky)
//		htree - identifikátor položky stromu (je doplnìno automaticky)
//		counter - èítaè odkazù na položku (je aktualizováno automaticky)
		
	short int Insert(PROGITEM* item, short int Index = -1);

// zrušení položky z bufferu (rekurzivní, se zrušením potomkù!)
// na rušené položky se nesmí nic odkazovat (counter = 0 !)
	void Delete(short int Index);

// nalezení položky podle handle (vrací index, -1 = nenalezeno)
	short int SrcItem(HTREEITEM hItem);

// pøekreslení (aktualizace) stromu
	void ReDisp();

/////////////////////////////////////////////////////////////////////////////
// kopie vìtve prvkù
//
// provádí korekce:
//		- nulování pøíznaku PR_INTERNAL
//		- zajištìní kopírování nìkterých položek bez potomkù
//		- zmìna reference na zdrojové okno
//		- rozvinutí vìtve pøi kopii ze stromu struktur
//		  nebo pøi kopii do nerozvinuté položky
//
// vstupní promìnné:
//		dst		- index cílové položky
//		parent	- index rodièe cílové položky
//		bufID	- ID zdrojového bufferu
//		src		- index zdrojové položky
//		move	- pøíznak módu pøesunu (nekopírovat definice funkcí)
//
// vrací opravený index cílové položky
	short int Copy(short int dst, short int parent, short int bufID, short int src, BOOL move);
	short int Copy2(short int& dst, short int parent, short int bufID, short int& src, BOOL move, BOOL first);

/////////////////////////////////////////////////////////////////////////////
// nastavení první zobrazené položky s pøípadným pøekreslením,
// požadovaný index mùže být ve vìtvi (nemusí být ROOT)
	BOOL SetFirst(short First);

/////////////////////////////////////////////////////////////////////////////
// nalezení textu k položce
	CString GetName(short Index);

/////////////////////////////////////////////////////////////////////////////
// nalezení položky odkazující se na požadovaná data (-1 = nenalezeno)
	short int SrcDat(short bufID, short Index);

/////////////////////////////////////////////////////////////////////////////
// hledání referenèní položky v bufferu od aktuální položky (-1 = nenalezeno)
//
// vstup:
//	bufID - èíslo bufferu hledané reference
//	Index - index hledané reference
//	Smer  - požadovaný smìr (od aktuální položky) 1 nebo -1
	short int SrcRef(short bufID, short Index, short Smer);

/////////////////////////////////////////////////////////////////////////////
// nalezení aktivní položky (-1 = není žádná položka)
	short int GetAkt();

/////////////////////////////////////////////////////////////////////////////
// nastavení aktivní položky (-1 = vypnuta)
	void SetAkt(short Index);

/////////////////////////////////////////////////////////////////////////////
// oznaèení definované položky (-1 = odznaèení)
	void SetDef(short int Index);
};
