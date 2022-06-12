
/////////////////////////////////////////////////////////////////////////////
//																		   //
//					inicializace programu a bufferù						   //
//																		   //
/////////////////////////////////////////////////////////////////////////////

// Doplnìní nové funkce:
// ---------------------
//	 - doplnit obrázek do IDB_ICON16 a IDB_ICON32
//	 - doplnit text s ID funkce
//	 - doplnit jméno do importName[]
//	 - doplnit ID funkce do seznamu internalID[]
//	 - doplnit enum do FncTyp
//   - doplnit ikonu do pøíslušného okna


/////////////////////////////////////////////////////////////////////////////
// tabulka identifikátorù funkcí (pro naètení textu z resource)

const int internalID[] = {
	IDI_NONE,
	IDI_GROUP,
	IDI_IF,
	IDI_IF_COND,
	IDI_IF_YES,
	IDI_IF_NO,
	IDI_WHILE,
	IDI_WHILE_COND,
	IDI_WHILE_BODY,
	IDI_WHILE_BREAK,
	IDI_MINUS,
	IDI_CASE,
	IDI_CASE_SUM,
	IDI_CASE_ON,
	IDI_CASE_EQU,
	IDI_CASE_DEF,
	IDI_NUM,
	IDI_0,
	IDI_1,
	IDI_2,
	IDI_3,
	IDI_4,
	IDI_5,
	IDI_6,
	IDI_7,
	IDI_8,
	IDI_9,
	IDI_DOT,
	IDI_EXP,
	IDI_EQU,
	IDI_NEQU,
	IDI_EQGR,
	IDI_EQLT,
	IDI_GR,
	IDI_LT,
	IDI_AND,
	IDI_OR,
	IDI_XOR,
	IDI_NOT,
	IDI_ADD,
	IDI_SUB,
	IDI_MUL,
	IDI_DIV,
	IDI_INT,
	IDI_PIC,
	IDI_SND,
	IDI_MUS,
	IDI_FNC,
	IDI_MAP,
	IDI_SPRITE,
	IDI_CLASS,
	IDI_TEXT,
	IDI_DIALOG,
	IDI_PAR,
	IDI_OUT,
	IDI_EVENT,
	IDI_LIST,
	IDI_OPER,
	IDI_KROK,
	IDI_VLEVO,
	IDI_VPRAVO,
	IDI_VZAD,
	IDI_PETRIK,
	IDI_LOGIC,
	IDI_TEXT_CONST,
	IDI_TRUE,
	IDI_FALSE,
	IDI_PETRA,
	IDI_PETRA_KROK,
	IDI_PETRA_VLEVO,
	IDI_PETRA_VPRAVO,
	IDI_PETRA_VZAD,
	IDI_RYCHLE,
	IDI_EXIT,
	IDI_PETRA_RYCHLE,
	IDI_PETRA_POMALU,		// zrušeno !!!!!!!!
	IDI_PREDMET,
	IDI_SMER,
	IDI_POZICEX,
	IDI_POZICEY,
	IDI_PETRA_PREDMET,
	IDI_PETRA_SMER,
	IDI_PETRA_POZICEX,
	IDI_PETRA_POZICEY,
	IDI_CONST,
	IDI_VYPOC,
	IDI_FUNC,
	IDI_POROVNANI,
	IDI_LOG_OPER,
	IDI_MOD,
	IDI_SIN,
	IDI_COS,
	IDI_TG,
	IDI_COTG,
	IDI_ARCSIN,
	IDI_ARCCOS,
	IDI_ARCTG,
	IDI_ARCCOTG,
	IDI_PI,
	IDI_INTEGER,
	IDI_FRAC,
	IDI_ABS,
	IDI_SQRT,
	IDI_FACT,
	IDI_RAND,
	IDI_EUL,
	IDI_DEGRAD,
	IDI_RADDEG,
	IDI_LOG,
	IDI_LN,
	IDI_PEXP,
	IDI_MOCN,
	IDI_UHEL,
	IDI_UHEL0,
	IDI_UHEL45,
	IDI_UHEL90,
	IDI_UHEL135,
	IDI_UHEL180,
	IDI_UHEL225,
	IDI_UHEL270,
	IDI_UHEL315,
	IDI_COMMAND,
	IDI_WAIT,
	IDI_KLAV,
	IDI_KLAV_TEST,
	IDI_KLAV_VKEY,
	IDI_KLAV_CHAR,
	IDI_KLAV_VK,
	IDI_KLAV_FX,
	IDI_KLAV_PISM,
	IDI_KLAV_NUM,
	IDI_KLAV_RUZNE,
	IDI_KLAV_RID,
	IDI_KLAV_SHIFT, 	// zrušeno
	IDI_F1,
	IDI_F2,
	IDI_F3,
	IDI_F4,
	IDI_F5,
	IDI_F6,
	IDI_F7,
	IDI_F8,
	IDI_F9,
	IDI_F10,
	IDI_F11,
	IDI_F12,
	IDI_A,
	IDI_B,
	IDI_C,
	IDI_D,
	IDI_E,
	IDI_F,
	IDI_G,
	IDI_H,
	IDI_I,
	IDI_J,
	IDI_K,
	IDI_L,
	IDI_M,
	IDI_N,
	IDI_O,
	IDI_P,
	IDI_Q,
	IDI_R,
	IDI_S,
	IDI_T,
	IDI_U,
	IDI_V,
	IDI_W,
	IDI_X,
	IDI_Y,
	IDI_Z,
	IDI_VK_NUM0,
	IDI_VK_NUM1,
	IDI_VK_NUM2,
	IDI_VK_NUM3,
	IDI_VK_NUM4,
	IDI_VK_NUM5,
	IDI_VK_NUM6,
	IDI_VK_NUM7,
	IDI_VK_NUM8,
	IDI_VK_NUM9,
	IDI_VK_NUMTECKA,
	IDI_VK_NUMPLUS,
	IDI_VK_NUMMINUS,
	IDI_VK_NUMKRAT,
	IDI_VK_NUMDELENO,
	IDI_VK_NUMENTER,
	IDI_VK_NUMLOCK,
	IDI_VK_1,
	IDI_VK_2,
	IDI_VK_3,
	IDI_VK_4,
	IDI_VK_5,
	IDI_VK_6,
	IDI_VK_7,
	IDI_VK_8,
	IDI_VK_9,
	IDI_VK_0,
	IDI_VK_LCARKA,
	IDI_VK_POMLCKA,
	IDI_VK_ROVNITKO,
	IDI_VK_ZLOMITKO,
	IDI_VK_LLOMENA,
	IDI_VK_RLOMENA,
	IDI_VK_STREDNIK,
	IDI_VK_RCARKA,
	IDI_VK_CARKA,
	IDI_VK_TECKA,
	IDI_VK_LOMITKO,
	IDI_VK_ESC,
	IDI_VK_TAB,
	IDI_VK_CAPSLOCK,
	IDI_VK_WIN,
	IDI_VK_BS,
	IDI_VK_ENTER,
	IDI_VK_MENU,
	IDI_VK_LEFT,
	IDI_VK_RIGHT,
	IDI_VK_UP,
	IDI_VK_DOWN,
	IDI_VK_INSERT,
	IDI_VK_DELETE,
	IDI_VK_HOME,
	IDI_VK_END,
	IDI_VK_PAGEUP,
	IDI_VK_PAGEDOWN,
	IDI_VK_PRINT,
	IDI_VK_SCROLL,
	IDI_VK_PAUSE,
	IDI_VK_SHIFT,
	IDI_VK_CTRL,
	IDI_VK_ALT,
	IDI_VK_SPACE,
	IDI_MOUSE,
	IDI_MOUSE_L,
	IDI_MOUSE_R,
	IDI_MOUSE_X,
	IDI_MOUSE_Y,
	IDI_EQU_TEXT,
	IDI_EQU_PIC,
};


/////////////////////////////////////////////////////////////////////////////
// poèty položek v jednotlivých mapách obrázkù

const int INTERNALNUM = _FncLast_;	// celkový poèet interních položek

const int INTERNALNUM1 = 64;
const int INTERNALNUM2 = 64;
const int INTERNALNUM3 = 64;
const int INTERNALNUM4 = INTERNALNUM-INTERNALNUM3-INTERNALNUM2-INTERNALNUM1;


/////////////////////////////////////////////////////////////////////////////
// inicializaèní obsah okna tøíd

#define CLASSMAPINDEX	5			// index mapy v bufferu tøíd
#define CLASSCLASSINDEX	11			// index hlavní tøídy v bufferu tøíd

const INITBUF InitBufCls[] = {
	FncFnc, 		0,	TYP_FUNC,		PR_AS_COMMAND | PR_AS_EXPRES,
	FncInt, 		0,	TYP_REAL,		PR_ONE | PR_AS_COMMAND | PR_GET_EXPRES | PR_AS_EXPRES,
	FncBool,		0,	TYP_BOOL,		PR_ONE | PR_AS_COMMAND | PR_GET_BOOL | PR_AS_BOOL,
	FncText,		0,	TYP_TEXT,		PR_ONE | PR_AS_COMMAND,
	FncPic, 		0,	TYP_PIC, 		PR_ONE | PR_AS_COMMAND,
	FncMap, 		0,	TYP_MAP,		PR_ONE | PR_AS_COMMAND,
	FncSnd, 		0,	TYP_SND,		PR_ONE | PR_AS_COMMAND,
	FncMus, 		0,	TYP_MUS,		PR_ONE | PR_AS_COMMAND,
	FncSprite,		0,	TYP_SPRITE,		PR_ONE | PR_AS_COMMAND,
	FncDialog,		0,	TYP_DIALOG,		PR_ONE | PR_AS_COMMAND,
	FncEvent,		0,	TYP_EVENT,		PR_ONE | PR_AS_COMMAND,
	FncClass,		0,	TYP_CLASS,		PR_AS_COMMAND,
};

/////////////////////////////////////////////////////////////////////////////
// inicializaèní obsah okna struktur

const INITBUF InitBufStr[] = {
	FncPetrik,		0,	TYP_NONE,		PR_NOMOVE,
	FncKrok,		1,	TYP_F,			PR_AS_COMMAND,
	FncVlevo,		1,	TYP_F,			PR_AS_COMMAND,
	FncVpravo,		1,	TYP_F,			PR_AS_COMMAND,
	FncVzad,		1,	TYP_F,			PR_AS_COMMAND,
	FncRychle,		1,	TYP_FBB,		PR_AS_COMMAND | PR_AS_BOOL | PR_GET_BOOL,
	FncPredmet, 	1,	TYP_PIC,		PR_ONE | PR_AS_COMMAND,
	FncSmer,		1,	TYP_FNN,		PR_ONE | PR_AS_COMMAND | PR_GET_EXPRES | PR_AS_EXPRES,
	FncPoziceX, 	1,	TYP_FNN,		PR_ONE | PR_AS_COMMAND | PR_GET_EXPRES | PR_AS_EXPRES,
	FncPoziceY, 	1,	TYP_FNN,		PR_ONE | PR_AS_COMMAND | PR_GET_EXPRES | PR_AS_EXPRES,
	FncPetra,		0,	TYP_NONE,		PR_NOMOVE,
	FncPetraKrok,	1,	TYP_F,			PR_AS_COMMAND,
	FncPetraVlevo,	1,	TYP_F,			PR_AS_COMMAND,
	FncPetraVpravo, 1,	TYP_F,			PR_AS_COMMAND,
	FncPetraVzad,	1,	TYP_F,			PR_AS_COMMAND,
	FncPetraRychle, 1,	TYP_FBB,		PR_AS_COMMAND | PR_AS_BOOL | PR_GET_BOOL,
	FncPetraPredmet,1,	TYP_PIC,		PR_ONE | PR_AS_COMMAND,
	FncPetraSmer,	1,	TYP_FNN,		PR_ONE | PR_AS_COMMAND | PR_GET_EXPRES | PR_AS_EXPRES,
	FncPetraPoziceX,1,	TYP_FNN,		PR_ONE | PR_AS_COMMAND | PR_GET_EXPRES | PR_AS_EXPRES,
	FncPetraPoziceY,1,	TYP_FNN,		PR_ONE | PR_AS_COMMAND | PR_GET_EXPRES | PR_AS_EXPRES,
	FncIf,			0,	TYP_IF,			PR_ONE | PR_AS_COMMAND,
	FncIfCond,		1,	TYP_IF_TEST,	PR_ONE | PR_NOMOVE | PR_GET_BOOL,
	FncIfYes,		1,	TYP_IF_YES,		PR_NOMOVE | PR_GET_COMMAND,
	FncIfNo,		1,	TYP_IF_NO,		PR_NOMOVE | PR_GET_COMMAND,
	FncWhile,		0,	TYP_WHILE,		PR_AS_COMMAND,
	FncWhileCond,	1,	TYP_WHILE_TEST,	PR_ONE | PR_GET_BOOL | PR_NOMOVE,
	FncWhileBody,	1,	TYP_WHILE_BODY,	PR_NOMOVE | PR_GET_COMMAND,
	FncWhileBreak,	2,	TYP_WHILE_BREAK,PR_AS_COMMAND,
	FncCase,		0,	TYP_CASE,		PR_AS_COMMAND,
	FncCaseSum, 	1,	TYP_CASE_EXPR,	PR_ONE | PR_NOMOVE | PR_GET_EXPRES,
	FncCaseOn,		1,	TYP_CASE_ON,	PR_GET_COMMAND,
	FncCaseEqu, 	2,	TYP_CASE_TEST,	PR_ONE | PR_GET_EXPRES,
	FncCaseDef, 	1,	TYP_CASE_DEF,	PR_NOMOVE | PR_GET_COMMAND,
	FncOper,		0,	TYP_NONE,		PR_NOMOVE,
	FncVypoc,		1,	TYP_NONE,		PR_NOMOVE,
	FncAdd, 		2,	TYP_OPER,		PR_GET_EXPRES | PR_AS_EXPRES,
	FncSub, 		2,	TYP_OPER,		PR_GET_EXPRES | PR_AS_EXPRES,
	FncMul, 		2,	TYP_OPER,		PR_GET_EXPRES | PR_AS_EXPRES,
	FncDiv, 		2,	TYP_OPER,		PR_GET_EXPRES | PR_AS_EXPRES,
	FncMod, 		2,	TYP_OPER,		PR_GET_EXPRES | PR_AS_EXPRES,
	FncMocn,		2,	TYP_OPER,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncFunc,		1,	TYP_NONE,		PR_NOMOVE,
	FncRand,		2,	TYP_FN,			PR_AS_EXPRES,
	FncSqrt,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncAbs, 		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncInteger, 	2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncFrac,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncSin, 		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncCos, 		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncTg,			2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncCoTg,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncArcSin,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncArcCos,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncArcTg,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncArcCoTg, 	2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncDegRad,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncRadDeg,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncLogar,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncLn,			2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncPExp,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncFact,		2,	TYP_FNN,		PR_ONE | PR_GET_EXPRES | PR_AS_EXPRES,
	FncPorovnani,	1,	TYP_NONE,		PR_NOMOVE,
	FncEqu, 		2,	TYP_COMP,		PR_AS_BOOL | PR_GET_EXPRES,
	FncNEqu,		2,	TYP_COMP,		PR_AS_BOOL | PR_GET_EXPRES,
	FncGr,			2,	TYP_COMP,		PR_AS_BOOL | PR_GET_EXPRES,
	FncLt,			2,	TYP_COMP,		PR_AS_BOOL | PR_GET_EXPRES,
	FncEqGr,		2,	TYP_COMP,		PR_AS_BOOL | PR_GET_EXPRES,
	FncEqLt,		2,	TYP_COMP,		PR_AS_BOOL | PR_GET_EXPRES,
	FncEquText,		2,	TYP_EQU_TEXT,	PR_AS_BOOL,
	FncEquPic,		2,	TYP_EQU_PIC,	PR_AS_BOOL,
	FncLogOper, 	1,	TYP_NONE,		PR_NOMOVE,
	FncAnd, 		2,	TYP_ANDOR,		PR_AS_BOOL | PR_GET_BOOL,
	FncOr,			2,	TYP_ANDOR,		PR_AS_BOOL | PR_GET_BOOL,
	FncNot, 		2,	TYP_ANDOR,		PR_ONE | PR_AS_BOOL | PR_GET_BOOL,
	FncConst,		0,	TYP_NONE,		PR_NOMOVE,
	FncNum, 		1,	TYP_NUM,		PR_AS_EXPRES,
	FncNum0,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum1,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum2,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum3,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum4,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum5,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum6,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum7,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum8,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncNum9,		2,	TYP_CIS,		PR_AS_EXPRES,
	FncDot, 		2,	TYP_TECKA,		0,
	FncMinus,		2,	TYP_MINUS,		0,
	FncExp, 		2,	TYP_EXPONENT,	0,
	FncUhel,		1,	TYP_NONE,		PR_NOMOVE,
	FncUhel0,		2,	TYP_FN,			PR_AS_EXPRES,
	FncUhel90,		2,	TYP_FN,			PR_AS_EXPRES,
	FncUhel180, 	2,	TYP_FN,			PR_AS_EXPRES,
	FncUhel270, 	2,	TYP_FN,			PR_AS_EXPRES,
	FncUhel45,		2,	TYP_FN,			PR_AS_EXPRES,
	FncUhel135, 	2,	TYP_FN,			PR_AS_EXPRES,
	FncUhel225, 	2,	TYP_FN,			PR_AS_EXPRES,
	FncUhel315, 	2,	TYP_FN,			PR_AS_EXPRES,
	FncKlavVK,		1,	TYP_NONE,		PR_NOMOVE,
	FncKlavFX,		2,	TYP_NONE,		PR_NOMOVE,
	FncF1,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF2,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF3,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF4,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF5,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF6,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF7,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF8,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF9,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF10, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncF11, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncF12, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncKlavPism,	2,	TYP_NONE,		PR_NOMOVE,
	FncA,			3,	TYP_FN,			PR_AS_EXPRES,
	FncB,			3,	TYP_FN,			PR_AS_EXPRES,
	FncC,			3,	TYP_FN,			PR_AS_EXPRES,
	FncD,			3,	TYP_FN,			PR_AS_EXPRES,
	FncE,			3,	TYP_FN,			PR_AS_EXPRES,
	FncF,			3,	TYP_FN,			PR_AS_EXPRES,
	FncG,			3,	TYP_FN,			PR_AS_EXPRES,
	FncH,			3,	TYP_FN,			PR_AS_EXPRES,
	FncI,			3,	TYP_FN,			PR_AS_EXPRES,
	FncJ,			3,	TYP_FN,			PR_AS_EXPRES,
	FncK,			3,	TYP_FN,			PR_AS_EXPRES,
	FncL,			3,	TYP_FN,			PR_AS_EXPRES,
	FncM,			3,	TYP_FN,			PR_AS_EXPRES,
	FncN,			3,	TYP_FN,			PR_AS_EXPRES,
	FncO,			3,	TYP_FN,			PR_AS_EXPRES,
	FncP,			3,	TYP_FN,			PR_AS_EXPRES,
	FncQ,			3,	TYP_FN,			PR_AS_EXPRES,
	FncR,			3,	TYP_FN,			PR_AS_EXPRES,
	FncS,			3,	TYP_FN,			PR_AS_EXPRES,
	FncT,			3,	TYP_FN,			PR_AS_EXPRES,
	FncU,			3,	TYP_FN,			PR_AS_EXPRES,
	FncV,			3,	TYP_FN,			PR_AS_EXPRES,
	FncW,			3,	TYP_FN,			PR_AS_EXPRES,
	FncX,			3,	TYP_FN,			PR_AS_EXPRES,
	FncY,			3,	TYP_FN,			PR_AS_EXPRES,
	FncZ,			3,	TYP_FN,			PR_AS_EXPRES,
	FncKlavNum, 	2,	TYP_NONE,		PR_NOMOVE,
	FncVKNum0,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum1,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum2,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum3,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum4,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum5,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum6,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum7,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum8,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNum9,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNumTecka,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNumPlus,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNumMinus,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNumKrat,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNumDeleno, 3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNumEnter,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKNumLock,	3,	TYP_FN,			PR_AS_EXPRES,
	FncKlavRuzne,	2,	TYP_NONE,		PR_NOMOVE,
	FncVKSpace, 	3,	TYP_FN,			PR_AS_EXPRES,
	FncVK1, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK2, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK3, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK4, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK5, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK6, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK7, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK8, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK9, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVK0, 		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKLCarka,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKPomlcka,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKRovnitko,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKZLomitko,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKLLomena,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKRLomena,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKStrednik,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKRCarka,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKCarka, 	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKTecka, 	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKLomitko,	3,	TYP_FN,			PR_AS_EXPRES,
	FncKlavRid, 	2,	TYP_NONE,		PR_NOMOVE,
	FncVKEsc,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKTab,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKCapsLock,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKWin,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKBS,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKEnter, 	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKMenu,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKLeft,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKRight, 	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKUp,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKDown,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKInsert,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKDelete,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKHome,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKEnd,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKPageUp,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKPageDown,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKPrint, 	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKScroll,	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKPause, 	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKShift, 	3,	TYP_FN,			PR_AS_EXPRES,
	FncVKCtrl,		3,	TYP_FN,			PR_AS_EXPRES,
	FncVKAlt,		3,	TYP_FN,			PR_AS_EXPRES,
	FncPi,			1,	TYP_FN,			PR_AS_EXPRES,
	FncEul, 		1,	TYP_FN,			PR_AS_EXPRES,
	FncTrue,		1,	TYP_FB,			PR_AS_BOOL,
	FncFalse,		1,	TYP_FB,			PR_AS_BOOL,
	FncTextConst,	1,	TYP_TXT,		0,
	FncCommand, 	0,	TYP_NONE,		PR_NOMOVE,
	FncWait,		1,	TYP_F0N,		PR_ONE | PR_AS_COMMAND | PR_GET_EXPRES,
	FncExit,		1,	TYP_F,			PR_AS_COMMAND,
	FncKlav,		1,	TYP_NONE,		PR_NOMOVE,
	FncKlavTest,	2,	TYP_FBN,		PR_ONE | PR_GET_EXPRES | PR_AS_BOOL,
	FncKlavVKey,	2,	TYP_FN,			PR_AS_EXPRES,
	FncKlavChar,	2,	TYP_FT,			0,
	FncMouse,		1,	TYP_NONE,		PR_NOMOVE,
	FncMouseL,		2,	TYP_FB,			PR_AS_BOOL,
	FncMouseR,		2,	TYP_FB,			PR_AS_BOOL,
	FncMouseX,		2,	TYP_FN,			PR_AS_EXPRES,
	FncMouseY,		2,	TYP_FN,			PR_AS_EXPRES,
	FncGroup,		0,	TYP_GROUP,		PR_GROUP | PR_GET_COMMAND | PR_AS_COMMAND | PR_GET_EXPRES 
										| PR_AS_EXPRES | PR_GET_BOOL | PR_AS_BOOL,
	FncList,		0,	TYP_LIST,		PR_AS_COMMAND | PR_AS_EXPRES | PR_AS_BOOL | PR_GET_EXPRES | PR_GET_BOOL,
};

/////////////////////////////////////////////////////////////////////////////
// inicializace

void CProg::InitPrgBuf(int num, const INITBUF* InitBuf, CProgBuf* ProgBuf)
{
//	CEdit* name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

//	if (name != NULL)
//		m_LabelhWnd = name->m_hWnd;

	int i;

	int ParentBuf[20];
	for (i = 0; i < 20; i++)
		ParentBuf[i] = -1;

	PROGITEM pri;
	pri.typ = BufIntID;
	pri.childs = 0;
	pri.items = 1;
	pri.htree = NULL;
	pri.counter = 0;
	pri.data = -1;
	pri.index = -1;

	for (i = 0; i < num; i++)
	{
		pri.refer = InitBuf[i].refer;
		pri.parent = ParentBuf[InitBuf[i].parent];
		pri.param = InitBuf[i].param | PR_INTERNAL;
		pri.model = InitBuf[i].model;
		pri.icon = -1;
		pri.name = -1;
		ParentBuf[InitBuf[i].parent + 1] = ProgBuf->Insert(&pri);
		m_BufInt.m_Items[pri.refer].param = pri.param;
		m_BufInt.m_Items[pri.refer].model = pri.model;
	}
}


void CProg::OnInitialUpdate() 
{

	CFormView::OnInitialUpdate();

// inicializace ikon interních a uživatelských funkcí
	m_BufIco16Int.Load(INTERNALNUM1, IDB_ICON16);
	m_BufIco16Int.Load(INTERNALNUM2, IDB_ICON162);
	m_BufIco16Int.Load(INTERNALNUM3, IDB_ICON163);
	m_BufIco16Int.Load(INTERNALNUM4, IDB_ICON164);
	m_BufIco16Int.AddList(m_Ico16);

	m_BufIco32Int.Load(INTERNALNUM1, IDB_ICON32);
	m_BufIco32Int.Load(INTERNALNUM2, IDB_ICON322);
	m_BufIco32Int.Load(INTERNALNUM3, IDB_ICON323);
	m_BufIco32Int.Load(INTERNALNUM4, IDB_ICON324);
	m_BufIco32Int.AddList(m_Ico32);

	m_BufIco16.Load(1,IDB_USER16);
	m_BufIco16.AddList(m_Ico16);

	m_BufIco32.Load(1,IDB_USER32);
	m_BufIco32.AddList(m_Ico32);

	m_BufState16.Load(4,IDB_STATE16);
	m_BufState16.AddList(m_State16);
	m_BufState32.Load(4,IDB_STATE32);
	m_BufState32.AddList(m_State32);

// nastavení seznamù ikon pro stromy
//	if (SelectWidth > 220)
//	{
		m_Object.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Local.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Struc.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Class.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Edit.SetImageList(m_Ico32, TVSIL_NORMAL);

		m_Object.SetImageList(m_State32, TVSIL_STATE);
		m_Local.SetImageList(m_State32, TVSIL_STATE);
		m_Struc.SetImageList(m_State32, TVSIL_STATE);
		m_Class.SetImageList(m_State32, TVSIL_STATE);
		m_Edit.SetImageList(m_State32, TVSIL_STATE);

//	}
//	else
//	{
//		m_Object.SetImageList(m_Ico16, TVSIL_NORMAL);
//		m_Local.SetImageList(m_Ico16, TVSIL_NORMAL);
//		m_Struc.SetImageList(m_Ico16, TVSIL_NORMAL);
//		m_Class.SetImageList(m_Ico16, TVSIL_NORMAL);
//		if (SelectWidth > 190)
//			m_Edit.SetImageList(m_Ico32, TVSIL_NORMAL);
//		else
//			m_Edit.SetImageList(m_Ico16, TVSIL_NORMAL);
//	}

// pøíprava k inicializaci bufferù
	PROGITEM pri;
	CString txt;
	pri.param = PR_EXP;
	pri.model = TYP_NONE;
	pri.typ = -1;
	pri.data = -1;
	pri.index = -1;
	pri.parent = -1;
	pri.childs = 0;
	pri.refer = -1;
	pri.items = 1;
	pri.htree = NULL;
	pri.counter = 0;

// inicializace bufferu interních funkcí
	m_TextInt.RemoveAll();

	for (int i = 0; i < INTERNALNUM; i++)
	{
		txt.LoadString(internalID[i]);
		ASSERT(txt.GetLength() != 0);
		pri.name = m_TextInt.Add(txt);
		ASSERT(pri.name == i);
		pri.icon = i;
		m_BufInt.Insert(&pri);
	}

	m_Text.RemoveAll();
	i = m_Text.Add(Jmeno);
	ASSERT(i == 0);

// inicializace bufferù programu
	InitPrgBuf(sizeof(InitBufStr)/sizeof(INITBUF), &InitBufStr[0], &m_BufStr);
	InitPrgBuf(sizeof(InitBufCls)/sizeof(INITBUF), &InitBufCls[0], &m_BufCls);

// hlavní funkce a hlavní tøída
	pri.param = PR_EXP | PR_GET_COMMAND;
	pri.model = TYP_FUNC;
	pri.typ = -1;
	pri.refer = -1;
	pri.data = -1;
	pri.index = -1;
	pri.parent = -1;
	pri.icon = INTERNALNUM;
	pri.name = 0;
	m_BufEdi.Insert(&pri);			// hlavní funkce
	m_BufEdi.Insert(&pri);			// hlavní tøída (inicializace)

// lokální objekty hlavní funkce a hlavní tøídy
	pri.data = BufEdiID;
	pri.index = 0;
	m_BufLoc.Insert(&pri);			// hlavní funkce
	pri.index  = 1;
	m_BufLoc.Insert(&pri);			// hlavní tøída

// globální objekty
	pri.param = PR_NOMOVE | PR_EXP | PR_GET_COMMAND;
	pri.index = 0;
	pri.refer = FncPetrik;
	pri.typ = BufIntID;
	pri.data = BufLocID;
	m_BufObj.Insert(&pri);

// implicitní mapa
	pri.param = PR_ONE | PR_AS_COMMAND;
	pri.model = TYP_MAP;
	pri.typ = BufClsID;
	pri.refer = CLASSMAPINDEX;
	pri.icon = -1;
	pri.name = -1;
	pri.index = -1;
	pri.data = -1;
	m_BufObj.Insert(&pri);

// definice hlavní tøídy
	m_BufCls.m_Items[CLASSCLASSINDEX].data = BufLocID;
	m_BufCls.m_Items[CLASSCLASSINDEX].index = 1;

// upøesnìní interních funkcí
	m_BufInt.m_Items[FncNone].param = PR_EXP | PR_GROUP | PR_GET_COMMAND | PR_AS_COMMAND | PR_GET_EXPRES 
										| PR_AS_EXPRES | PR_GET_BOOL | PR_AS_BOOL;
	m_BufInt.m_Items[FncNone].model = TYP_NONE;
	m_BufInt.m_Items[FncOut].param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL | PR_ONE;
	m_BufInt.m_Items[FncOut].model = TYP_OPARAM;
	m_BufInt.m_Items[FncPar].param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL;
	m_BufInt.m_Items[FncPar].model = TYP_IPARAM;

// naètení kurzorù myši
	m_CurArrow = ::LoadCursor(0, MAKEINTRESOURCE(IDC_ARROW));
	ASSERT(m_CurArrow != NULL);
	m_CurHSize = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_SPLITH));
	ASSERT(m_CurHSize != NULL);
	m_CurVSize = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_SPLITV));
	ASSERT(m_CurVSize != NULL);

	m_CurCopy = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_COPY));
	ASSERT(m_CurCopy != NULL);
	m_CurMove = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_MOVE));
	ASSERT(m_CurMove != NULL);
	m_CurNoDrag = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_NODRAG));
	ASSERT(m_CurNoDrag != NULL);
	m_CurDelete = ::LoadCursor(AfxGetResourceHandle(), MAKEINTRESOURCE(IDC_DELETE));
	ASSERT(m_CurDelete != NULL);

// naètení souboru
	OnFileLoad();

// aktualizace zobrazení stromù
	m_BufObj.ReDisp();
//	DblclkObject(0);
	m_BufCls.ReDisp();
	m_BufStr.ReDisp();
	m_BufObj.m_Tree->SetFocus();
	DblclkObject(0);
}



