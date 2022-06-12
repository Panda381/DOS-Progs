
#include "stdafx.h"
#include "peter.h"
#include "MainFrm.h"
#include "IconBuf.h"
#include "TextBuf.h"
#include "ProgBuf.h"
#include "Prog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

//////////////////////////////////////////////////////
//          !!!!!!!!!!!!!!!!!!!!!!!!!				//
//   Nastavit zarovnávání pøekladaèe na 4 Bajty,	//
//  aby souhlasilo zarovnávání struktur v souboru	//
//	        !!!!!!!!!!!!!!!!!!!!!!!!!				//
//////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// záhlaví pro uložení

const PETHEAD SaveHead = {
	'P','E','T',									// identifikace
	1,												// verze
	0,												// parametry
	3 + 1 + 4 + 4 + 4 + 13 * sizeof(PETINDEX),		// offset zaèátku dat
	13,												// poèet datových blokù
	0,0,'I','M','P','O','R','T',' ',' ',0,0,0,0,	// blok IMPORT
	0,0,'C','L','A','S','S',' ',' ',' ',0,0,0,0,	// blok CLASS
	0,0,'G','L','O','B','A','L',' ',' ',0,0,0,0,	// blok GLOBAL
	0,0,'L','O','C','A','L',' ',' ',' ',0,0,0,0,	// blok LOCAL
	0,0,'P','R','O','G','R','A','M',' ',0,0,0,0,	// blok PROGRAM
	0,0,'R','E','A','L',' ',' ',' ',' ',0,0,0,0,	// blok REAL
	0,0,'T','E','X','T',' ',' ',' ',' ',0,0,0,0,	// blok TEXT
	0,0,'P','A','L','E','T','T','E',' ',0,0,0,0,	// blok PALETTE
	0,0,'P','I','C','T','U','R','E',' ',16,16,0,0,	// blok PICTURE 16x16
	0,0,'P','I','C','T','U','R','E',' ',32,32,0,0,	// blok PICTURE 32x32
	0,0,'M','A','P',' ',' ',' ',' ',' ',0,0,0,0,	// blok MAP
	0,0,'S','O','U','N','D',' ',' ',' ',0,0,0,0,	// blok SOUND
	0,0,'M','U','S','I','C',' ',' ',' ',0,0,0,0,	// blok MUSIC
};

/////////////////////////////////////////////////////////////////////////////
// interní funkce

// Doplnìní nové funkce:
// ---------------------
//	 - doplnit obrázek do IDB_ICON16 a IDB_ICON32
//	 - doplnit text s ID funkce
//	 - doplnit jméno do importName[]
//	 - doplnit ID funkce do seznamu internalID[]
//	 - doplnit enum do FncTyp

char* importName[] = {
	"???",				// IDI_NONE,
	"group",			// IDI_GROUP
	"if",				// IDI_IF
	"if_cond",			// IDI_IF_COND
	"then",				// IDI_IF_YES
	"else",				// IDI_IF_NO
	"while",			// IDI_WHILE
	"while_cond",		// IDI_WHILE_COND
	"while_body",		// IDI_WHILE_BODY
	"break",			// IDI_WHILE_BREAK
	"minus",			// IDI_MINUS
	"case",				// IDI_CASE
	"case_expr",		// IDI_CASE_SUM
	"case_on",			// IDI_CASE_ON
	"case_equ",			// IDI_CASE_EQU
	"default",			// IDI_CASE_DEF
	"num",				// IDI_NUM
	"0",				// IDI_0
	"1",				// IDI_1
	"2",				// IDI_2
	"3",				// IDI_3
	"4",				// IDI_4
	"5",				// IDI_5
	"6",				// IDI_6
	"7",				// IDI_7
	"8",				// IDI_8
	"9",				// IDI_9
	".",				// IDI_DOT
	"e",				// IDI_EXP
	"=",				// IDI_EQU
	"<>",				// IDI_NEQU
	">=",				// IDI_EQGR
	"<=",				// IDI_EQLT
	">",				// IDI_GR
	"<",				// IDI_LT
	"and",				// IDI_AND
	"or",				// IDI_OR
	"xor",				// IDI_XOR
	"not",				// IDI_NOT
	"+",				// IDI_ADD,
	"-",				// IDI_SUB
	"*",				// IDI_MUL
	"/",				// IDI_DIV
	"real",				// IDI_INT
	"picture",			// IDI_PIC
	"sound",			// IDI_SND
	"music",			// IDI_MUS
	"prog",				// IDI_FNC
	"map",				// IDI_MAP
	"sprite",			// IDI_SPRITE
	"class",			// IDI_CLASS
	"text",				// IDI_TEXT
	"dialog",			// IDI_DIALOG
	"param",			// IDI_PAR
	"oparam",			// IDI_OUT
	"event",			// IDI_EVENT
	"list",				// IDI_LIST
	"operand",			// IDI_OPER
	"step",				// IDI_KROK
	"left",				// IDI_VLEVO
	"right",			// IDI_VPRAVO
	"back",				// IDI_VZAD
	"peter",			// IDI_PETRIK
	"logic",			// IDI_LOGIC
	"text_const",		// IDI_TEXT_CONST
	"true",				// IDI_TRUE
	"false",			// IDI_FALSE
	"pet2",				// IDI_PETRA
	"pet2_step",		// IDI_PETRA_KROK
	"pet2_left",		// IDI_PETRA_VLEVO
	"pet2_right",		// IDI_PETRA_VPRAVO
	"pet2_back",		// IDI_PETRA_VZAD
	"quick",			// IDI_RYCHLE
	"exit",				// IDI_EXIT
	"pet2_quick",		// IDI_PETRA_RYCHLE
	"pet2_slow",		// IDI_PETRA_POMALU // zrušeno !!!!!!!!
	"take",				// IDI_PREDMET
	"turn",				// IDI_SMER
	"posx",				// IDI_POZICEX
	"posy",				// IDI_POZICEY
	"pet2_take",		// IDI_PETRA_PREDMET
	"pet2_turn",		// IDI_PETRA_SMER
	"pet2_posx",		// IDI_PETRA_POZICEX
	"pet2_posy",		// IDI_PETRA_POZICEY
	"const",			// IDI_CONST
	"math",				// IDI_VYPOC
	"function",			// IDI_FUNC
	"compare",			// IDI_POROVNANI
	"log_oper",			// IDI_LOG_OPER
	"mod",				// IDI_MOD
	"sin",				// IDI_SIN
	"cos",				// IDI_COS
	"tg",				// IDI_TG
	"cotg",				// IDI_COTG
	"arcsin",			// IDI_ARCSIN
	"arccos",			// IDI_ARCCOS
	"arctg",			// IDI_ARCTG
	"arccotg",			// IDI_ARCCOTG
	"pi",				// IDI_PI
	"integer",			// IDI_INTEGER
	"frac",				// IDI_FRAC
	"abs",				// IDI_ABS
	"sqrt",				// IDI_SQRT
	"fact",				// IDI_FACT
	"random",			// IDI_RAND
	"eul",				// IDI_EUL
	"degrad",			// IDI_DEGRAD
	"raddeg",			// IDI_RADDEG
	"log",				// IDI_LOG
	"ln",				// IDI_LN
	"nexp",				// IDI_PEXP
	"power",			// IDI_MOCN
	"angle",			// IDI_UHEL
	"deg0",				// IDI_UHEL0
	"deg45",			// IDI_UHEL45
	"deg90",			// IDI_UHEL90
	"deg135",			// IDI_UHEL135
	"deg180",			// IDI_UHEL180
	"deg225",			// IDI_UHEL225
	"deg270",			// IDI_UHEL270
	"deg315",			// IDI_UHEL315
	"command",			// IDI_COMMAND
	"wait",				// IDI_WAIT
	"key",				// IDI_KLAV
	"key_test",			// IDI_KLAV_TEST
	"key_vkey",			// IDI_KLAV_VKEY
	"key_char",			// IDI_KLAV_CHAR
	"key_vk",			// IDI_KLAV_VK
	"key_fx",			// IDI_KLAV_FX
	"key_let",			// IDI_KLAV_PISM
	"key_num",			// IDI_KLAV_NUM
	"key_misc",			// IDI_KLAV_RUZNE
	"key_ctrl",			// IDI_KLAV_RID
	"key_shft",			// IDI_KLAV_SHIFT 	// zrušeno
	"vk_f1",			// IDI_F1
	"vk_f2",			// IDI_F2
	"vk_f3",			// IDI_F3
	"vk_f4",			// IDI_F4
	"vk_f5",			// IDI_F5
	"vk_f6",			// IDI_F6
	"vk_f7",			// IDI_F7
	"vk_f8",			// IDI_F8
	"vk_f9",			// IDI_F9
	"vk_f10",			// IDI_F10
	"vk_f11",			// IDI_F11
	"vk_f12",			// IDI_F12
	"vk_a",				// IDI_A
	"vk_b",				// IDI_B
	"vk_c",				// IDI_C
	"vk_d",				// IDI_D
	"vk_e",				// IDI_E
	"vk_f",				// IDI_F
	"vk_g",				// IDI_G
	"vk_h",				// IDI_H
	"vk_i",				// IDI_I
	"vk_j",				// IDI_J
	"vk_k",				// IDI_K
	"vk_l",				// IDI_L
	"vk_m",				// IDI_M
	"vk_n",				// IDI_N
	"vk_o",				// IDI_O
	"vk_p",				// IDI_P
	"vk_q",				// IDI_Q
	"vk_r",				// IDI_R
	"vk_s",				// IDI_S
	"vk_t",				// IDI_T
	"vk_u",				// IDI_U
	"vk_v",				// IDI_V
	"vk_w",				// IDI_W
	"vk_x",				// IDI_X
	"vk_y",				// IDI_Y
	"vk_z",				// IDI_Z
	"vk_num0",			// IDI_VK_NUM0
	"vk_num1",			// IDI_VK_NUM1
	"vk_num2",			// IDI_VK_NUM2
	"vk_num3",			// IDI_VK_NUM3
	"vk_num4",			// IDI_VK_NUM4
	"vk_num5",			// IDI_VK_NUM5
	"vk_num6",			// IDI_VK_NUM6
	"vk_num7",			// IDI_VK_NUM7
	"vk_num8",			// IDI_VK_NUM8
	"vk_num9",			// IDI_VK_NUM9
	"vk_num.",			// IDI_VK_NUMTECKA
	"vk_num+",			// IDI_VK_NUMPLUS
	"vk_num-",			// IDI_VK_NUMMINUS
	"vk_num*",			// IDI_VK_NUMKRAT
	"vk_num/",			// IDI_VK_NUMDELENO
	"vk_numenter",		// IDI_VK_NUMENTER
	"vk_numlock",		// IDI_VK_NUMLOCK
	"vk_1",				// IDI_VK_1
	"vk_2",				// IDI_VK_2
	"vk_3",				// IDI_VK_3
	"vk_4",				// IDI_VK_4
	"vk_5",				// IDI_VK_5
	"vk_6",				// IDI_VK_6
	"vk_7",				// IDI_VK_7
	"vk_8",				// IDI_VK_8
	"vk_9",				// IDI_VK_9
	"vk_0",				// IDI_VK_0
	"vk_`",				// IDI_VK_LCARKA
	"vk_-",				// IDI_VK_POMLCKA
	"vk_=",				// IDI_VK_ROVNITKO
	"vk_\\",			// IDI_VK_ZLOMITKO
	"vk_[",				// IDI_VK_LLOMENA
	"vk_]",				// IDI_VK_RLOMENA
	"vk_;",				// IDI_VK_STREDNIK
	"vk_'",				// IDI_VK_RCARKA
	"vk_,",				// IDI_VK_CARKA
	"vk_.",				// IDI_VK_TECKA
	"vk_/",				// IDI_VK_LOMITKO
	"vk_esc",			// IDI_VK_ESC
	"vk_tab",			// IDI_VK_TAB
	"vk_capslock",		// IDI_VK_CAPSLOCK
	"vk_win",			// IDI_VK_WIN
	"vk_bs",			// IDI_VK_BS
	"vk_enter",			// IDI_VK_ENTER
	"vk_menu",			// IDI_VK_MENU
	"vk_left",			// IDI_VK_LEFT
	"vk_right",			// IDI_VK_RIGHT
	"vk_up",			// IDI_VK_UP
	"vk_down",			// IDI_VK_DOWN
	"vk_insert",		// IDI_VK_INSERT
	"vk_delete",		// IDI_VK_DELETE
	"vk_home",			// IDI_VK_HOME
	"vk_end",			// IDI_VK_END
	"vk_pageup",		// IDI_VK_PAGEUP
	"vk_pagedown",		// IDI_VK_PAGEDOWN
	"vk_print",			// IDI_VK_PRINT
	"vk_scroll",		// IDI_VK_SCROLL
	"vk_pause",			// IDI_VK_PAUSE
	"vk_shift",			// IDI_VK_SHIFT
	"vk_ctrl",			// IDI_VK_CTRL
	"vk_alt",			// IDI_VK_ALT
	"vk_space",			// IDI_VK_SPACE
	"mouse",			// IDI_MOUSE
	"mouse_l",			// IDI_MOUSE_L
	"mouse_r",			// IDI_MOUSE_R
	"mouse_x",			// IDI_MOUSE_X
	"mouse_y",			// IDI_MOUSE_Y
	"equ_text",			// IDI_EQU_TEXT
	"equ_pic",			// IDI_EQU_PIC
};

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
// indexy interních funkcí

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

/////////////////////////////////////////////////////////////////////////////
// poèty položek v jednotlivých mapách obrázkù

const int INTERNALNUM = _FncLast_;

const int INTERNALNUM1 = 64;
const int INTERNALNUM2 = 64;
const int INTERNALNUM3 = 64;
const int INTERNALNUM4 = INTERNALNUM-INTERNALNUM3-INTERNALNUM2-INTERNALNUM1;

/////////////////////////////////////////////////////////////////////////////
// inicializaèní obsah tøíd
//
const INITBUF InitBufCls[] = {
//	FncClass,		0,	TYP_CLASS,		PR_EXP | PR_NOMOVE,
	FncFnc, 		0,	TYP_FUNC,		PR_AS_COMMAND | PR_AS_EXPRES | PR_FUNC,
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
};

/////////////////////////////////////////////////////////////////////////////
// inicializaèní obsah struktur

const INITBUF InitBufStr[] = {
	FncPetrik,		0,	TYP_NONE,		PR_NOMOVE,
	FncKrok,		1,	TYP_F,			PR_AS_COMMAND,
	FncVlevo,		1,	TYP_F,			PR_AS_COMMAND,
	FncVpravo,		1,	TYP_F,			PR_AS_COMMAND,
	FncVzad,		1,	TYP_F,			PR_AS_COMMAND,
	FncRychle,		1,	TYP_FBB,		PR_AS_COMMAND | PR_AS_BOOL | PR_GET_BOOL,
//	FncPomalu,		1,	TYP_F,			PR_AS_COMMAND,
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
//	FncPetraPomalu, 1,	TYP_F,			PR_AS_COMMAND,
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
//	FncKlavShift,	2,	TYP_NONE,		PR_NOMOVE,
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
// konstruktor a destruktor

IMPLEMENT_DYNCREATE(CProg, CFormView)

CProg::CProg()
	: CFormView(CProg::IDD)
{
	//{{AFX_DATA_INIT(CProg)
	//}}AFX_DATA_INIT

#ifdef _DEBUG
	ASSERT((sizeof(internalID)/sizeof(internalID[0])) == INTERNALNUM);
#endif

// vytvoøení seznamù ikon
	HIMAGELIST hImg;

	m_Ico16 = new CImageList();
	hImg = ImageList_Create(16,16,ILC_COLORDDB | ILC_MASK,INTERNALNUM,10);
	ASSERT(hImg != NULL);
	m_Ico16->Attach(hImg);

	m_Ico32 = new CImageList();
	hImg = ImageList_Create(32,32,ILC_COLORDDB | ILC_MASK,INTERNALNUM,10);
	ASSERT(hImg != NULL);
	m_Ico32->Attach(hImg);

// inicalizace bufferù ikon (pro jiné nastavení než implicitní)
	m_BufIco16Int.m_Width = 16;
	m_BufIco16Int.m_Height = 16;
	m_BufIco16.m_Width = 16;
	m_BufIco16.m_Height = 16;

// navázání stromù na buffery programu
	m_BufObj.m_Tree = &m_Object;	// strom objektù
	m_BufLoc.m_Tree = &m_Local; 	// strom lokálních objektù
	m_BufStr.m_Tree = &m_Struc; 	// strom struktur
	m_BufCls.m_Tree = &m_Class; 	// strom tøíd
	m_BufEdi.m_Tree = &m_Edit;		// strom editace

// navázání seznamu textù a odkaz na buffery programu
	for (int i = 0; i < PROGBUFNUM; i++)
	{
		m_Buf[i].m_ProgBuf = &(m_Buf[0]); // adresa všech bufferù
		m_Buf[i].m_Text = &m_Text;		// seznam textù
		m_Buf[i].m_BufID = i;			// identifikace bufferu
	}
	m_BufInt.m_Text = &m_TextInt;	// texty pro interní funkce

	m_Dragging = FALSE; 			// není tažení
	
	m_Saving = FALSE;				// není ukládání/naèítání

	m_AktBufID = BufEdiID;
	m_AktTree = &m_Edit;
	m_FilName = FALSE;
}

CProg::~CProg()
{
// zrušení seznamu ikon
	m_Ico16->DeleteImageList();
	delete m_Ico16;
	m_Ico32->DeleteImageList();
	delete m_Ico32;
}

void CProg::DoDataExchange(CDataExchange* pDX)
{
	CFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CProg)
	DDX_Control(pDX, IDC_PROG_REFER, m_Refer);
	DDX_Control(pDX, IDC_PROG_LOCK, m_Lock);
	DDX_Control(pDX, IDC_PROG_OFF, m_Off);
	DDX_Control(pDX, IDC_PROG_DEF, m_Def);
	DDX_Control(pDX, IDC_PROG_ICON, m_Icon);
	DDX_Control(pDX, IDC_PROG_EDIT, m_Name);
	DDX_Control(pDX, IDC_STATIC1, m_Nadpis1);
	DDX_Control(pDX, IDC_STATIC2, m_Nadpis2);
	DDX_Control(pDX, IDC_STATIC3, m_Nadpis3);
	DDX_Control(pDX, IDC_STATIC4, m_Nadpis4);
	DDX_Control(pDX, IDC_PROG_OBJECT, m_Object);
	DDX_Control(pDX, IDC_PROG_LOCAL, m_Local);
	DDX_Control(pDX, IDC_PROG_STRUC, m_Struc);
	DDX_Control(pDX, IDC_PROG_CLASS, m_Class);
	DDX_Control(pDX, IDC_PROG, m_Edit);
	DDX_Control(pDX, IDC_PROG_SPLIT1, m_Split1);
	DDX_Control(pDX, IDC_PROG_SPLIT2, m_Split2);
	DDX_Control(pDX, IDC_PROG_SPLIT3, m_Split3);
	DDX_Control(pDX, IDC_PROG_SPLIT4, m_Split4);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CProg, CFormView)
	//{{AFX_MSG_MAP(CProg)
	ON_WM_SIZE()
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG_OBJECT, OnBeginDragProgObj)
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG_LOCAL, OnBeginDragProgLoc)
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG_STRUC, OnBeginDragProgStr)
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG_CLASS, OnBeginDragProgCls)
	ON_NOTIFY(TVN_BEGINDRAG, IDC_PROG, OnBeginDragProgEdi)
	ON_WM_LBUTTONUP()
	ON_WM_RBUTTONUP()
	ON_WM_MOUSEMOVE()
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG_OBJECT, OnItemExpandedProgObj)
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG_LOCAL, OnItemExpandedProgLoc)
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG_STRUC, OnItemExpandedProgStr)
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG_CLASS, OnItemExpandedProgCls)
	ON_NOTIFY(TVN_ITEMEXPANDED, IDC_PROG, OnItemExpandedProgEdi)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG_OBJECT, OnSetFocusObject)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG_LOCAL, OnSetFocusLocal)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG_STRUC, OnSetFocusStruc)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG_CLASS, OnSetFocusClass)
	ON_NOTIFY(NM_SETFOCUS, IDC_PROG, OnSetFocusProg)
	ON_EN_CHANGE(IDC_PROG_EDIT, OnChangeName)
	ON_BN_CLICKED(IDC_PROG_DEF, OnProgDef)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG_OBJECT, OnSelChangedObject)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG_LOCAL, OnSelChangedLocal)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG_STRUC, OnSelChangedStruc)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG_CLASS, OnSelChangedClass)
	ON_NOTIFY(TVN_SELCHANGED, IDC_PROG, OnSelChangedEdit)
	ON_NOTIFY(NM_DBLCLK, IDC_PROG_OBJECT, OnDblclkProgObject)
	ON_NOTIFY(NM_DBLCLK, IDC_PROG_LOCAL, OnDblclkProgLocal)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG_OBJECT, OnBeginDragProgObj)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG_LOCAL, OnBeginDragProgLoc)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG_STRUC, OnBeginDragProgStr)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG_CLASS, OnBeginDragProgCls)
	ON_NOTIFY(TVN_BEGINRDRAG, IDC_PROG, OnBeginDragProgEdi)
	ON_COMMAND(ID_FILE_SAVE2, OnFileSave)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// diagnostika

#ifdef _DEBUG
void CProg::AssertValid() const
{
	CFormView::AssertValid();
}

void CProg::Dump(CDumpContext& dc) const
{
	CFormView::Dump(dc);
}
#endif //_DEBUG


/////////////////////////////////////////////////////////////////////////////
// inicializace

void CProg::InitPrgBuf(int num, const INITBUF* InitBuf, CProgBuf* ProgBuf)
{
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

// nastavení seznamù ikon pro stromy
	if (SelectWidth > 220)
	{
		m_Object.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Local.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Struc.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Class.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Edit.SetImageList(m_Ico32, TVSIL_NORMAL);
	}
	else
	{
		m_Object.SetImageList(m_Ico16, TVSIL_NORMAL);
		m_Local.SetImageList(m_Ico16, TVSIL_NORMAL);
		m_Struc.SetImageList(m_Ico16, TVSIL_NORMAL);
		m_Class.SetImageList(m_Ico16, TVSIL_NORMAL);
		if (SelectWidth > 190)
			m_Edit.SetImageList(m_Ico32, TVSIL_NORMAL);
		else
			m_Edit.SetImageList(m_Ico16, TVSIL_NORMAL);
	}

// pøíprava k inicializaci bufferù
	PROGITEM pri;
	CString txt;
	pri.param = PR_EXP;
	pri.model = TYP_NONE;
	pri.typ = -1;
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


// inicializace bufferu globálních objektù
	pri.typ = BufIntID;
	pri.refer = FncPetrik;
	pri.parent = -1;
	pri.param = PR_NOMOVE;
	pri.model = TYP_NONE;
	pri.icon = INTERNALNUM;
	pri.name = 0;
	m_BufObj.Insert(&pri);

// implicitní mapa (pozor - referuje na okno Class !)
	pri.typ = BufClsID;
	pri.refer = 5;
	pri.param = PR_ONE | PR_AS_COMMAND;
	pri.model = TYP_MAP;
	pri.icon = -1;
	pri.name = -1;
	m_BufObj.Insert(&pri);

// hlavní funkce (pozor - referuje na okno Object !)
	pri.typ = BufObjID;
	pri.refer = 0;
	pri.parent = -1;
	pri.param = PR_NOMOVE;
	pri.model = TYP_NONE;
	m_BufEdi.Insert(&pri);

// lokální objekty hlavní funkce (pozor - referuje na okno Object !)
	pri.param = PR_NOMOVE;
	pri.model = TYP_NONE;
	m_BufLoc.Insert(&pri);

// upøesnìní interních funkcí
	m_BufInt.m_Items[FncNone].param = PR_EXP | PR_GROUP | PR_GET_COMMAND | PR_AS_COMMAND | PR_GET_EXPRES 
										| PR_AS_EXPRES | PR_GET_BOOL | PR_AS_BOOL;
	m_BufInt.m_Items[FncNone].model = TYP_NONE;
	m_BufInt.m_Items[FncOut].param = PR_NOMOVE | PR_ONE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL;
	m_BufInt.m_Items[FncOut].model = TYP_OPARAM;
	m_BufInt.m_Items[FncOut].param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL;
	m_BufInt.m_Items[FncOut].model = TYP_IPARAM;

// naètení kurzorù myši
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
	DblclkObject(0);
	m_BufCls.ReDisp();
	m_BufEdi.m_First = 1;
	m_BufEdi.ReDisp();
	m_BufLoc.m_First = 1;
	m_BufLoc.ReDisp();
}

/////////////////////////////////////////////////////////////////////////////
// zmìna velikosti okna

void CProg::OnSize(UINT nType, int cx, int cy) 
{
	CFormView::OnSize(nType, cx, cy);
	
	CRect rect;
	CRect rect1;
	CRect rect2;
	CRect rect3;
	CRect rect4;
	CRect rectProg;
	CRect rectLocal;
	CRect rectObject;
	CRect rectClass;
	CRect rectInter;

	GetClientRect(&rect);

// levý vertikální rozdìlovaè
	rect1 = rect;
	rect1.left = SelectWidth;
	if (rect1.left > rect.right / 3)
		rect1.left = rect.right / 3;

	rect1.right = rect1.left + 6;

	if (m_Split1.m_hWnd != NULL)
	{
		m_Split1.MoveWindow(&rect1);
	}

// pravý vertikální rozdìlovaè
	rect4 = rect;
	rect4.left = rect.right - SelectWidth;
	if (rect4.left < rect.right * 2 / 3)
		rect4.left = rect.right * 2 / 3;
	rect4.right = rect4.left + 6;

	if (m_Split3.m_hWnd != NULL)
	{
		m_Split3.MoveWindow(&rect4);
	}

// pole editace
	rectProg = rect;
	rectProg.top = 24;
	rectProg.left = rect1.right;
	rectProg.right = rect4.left;
	
	if (m_Edit.m_hWnd != NULL)
	{
		m_Edit.MoveWindow(&rectProg);
	}

	rectProg.bottom = rectProg.top - 3;
	rectProg.top = 3;
	rectProg.left += 4;
	rectProg.right = rectProg.left + 40;
	if (m_Lock.m_hWnd != NULL)
	{
		m_Lock.MoveWindow(&rectProg);
	}

	rectProg.left = rectProg.right + 3;
	rectProg.right = rectProg.left + 40;
	if (m_Off.m_hWnd != NULL)
	{
		m_Off.MoveWindow(&rectProg);
	}

	rectProg.left = rectProg.right + 3;
	rectProg.right = rectProg.left + 40;
	if (m_Icon.m_hWnd != NULL)
	{
		m_Icon.MoveWindow(&rectProg);
	}

	rectProg.left = rectProg.right + 3;
	rectProg.right = rectProg.left + 40;
	if (m_Def.m_hWnd != NULL)
	{
		m_Def.MoveWindow(&rectProg);
	}

	rectProg.left = rectProg.right + 5;
	rectProg.right = rect4.left - 3 - 80;
	if (m_Name.m_hWnd != NULL)
	{
		m_Name.MoveWindow(&rectProg);
	}

	rectProg.left = rectProg.right + 5;
	rectProg.right = rect4.left - 3;
	if (m_Refer.m_hWnd != NULL)
	{
		m_Refer.MoveWindow(&rectProg);
	}

// levý horizontální rozdìlovaè
	rect2.left = 0;
	rect2.right = rect1.left;
	rect2.top = rect.bottom * 2 / 3;
	rect2.bottom = rect2.top + 6;

	if (m_Split2.m_hWnd != NULL)
	{
		m_Split2.MoveWindow(&rect2);
	}

// pole objektù
	rectObject.left = 0;
	rectObject.top = 15;
	rectObject.right = rect2.right;
	rectObject.bottom = rect2.top;
	if (m_Object.m_hWnd != NULL)
	{
		m_Object.MoveWindow(&rectObject);
	}

	rectObject.bottom = rectObject.top;
	rectObject.top = 0;
	if (m_Nadpis1.m_hWnd != NULL)
	{
		m_Nadpis1.MoveWindow(&rectObject);
	}

// pole lokálních objektù
	rectLocal = rect;
	rectLocal.right = rect2.right;
	rectLocal.top = rect2.bottom + 15;

	if (m_Local.m_hWnd != NULL)
	{
		m_Local.MoveWindow(&rectLocal);
	}

	rectLocal.bottom = rectLocal.top;
	rectLocal.top = rect2.bottom;
	if (m_Nadpis2.m_hWnd != NULL)
	{
		m_Nadpis2.MoveWindow(&rectLocal);
	}

// pravý horizontální rozdìlovaè
	rect3 = rect;
	rect3.left = rect4.right;
	rect3.top = rect.bottom * 2 / 3;
	rect3.bottom = rect3.top + 6;

	if (m_Split4.m_hWnd != NULL)
	{
		m_Split4.MoveWindow(&rect3);
	}

// pole struktur
	rectInter = rect;
	rectInter.bottom = rect3.top;
	rectInter.left = rect3.left;
	rectInter.top = 15;
	if (m_Struc.m_hWnd != NULL)
	{
		m_Struc.MoveWindow(&rectInter);
	}

	rectInter.bottom = rectInter.top;
	rectInter.top = 0;
	if (m_Nadpis3.m_hWnd != NULL)
	{
		m_Nadpis3.MoveWindow(&rectInter);
	}

// pole tøíd
	rectClass = rect;
	rectClass.left = rect3.left;
	rectClass.top = rect3.bottom + 15;

	if (m_Class.m_hWnd != NULL)
	{
		m_Class.MoveWindow(&rectClass);
	}

	rectClass.bottom = rectClass.top;
	rectClass.top = rect3.bottom;
	if (m_Nadpis4.m_hWnd != NULL)
	{
		m_Nadpis4.MoveWindow(&rectClass);
	}
}

/////////////////////////////////////////////////////////////////////////////
// aktualizace palet pøi pøekreslení okna

void CProg::OnDraw(CDC* pDC) 
{
	HPALETTE OldPal = ::SelectPalette(pDC->m_hDC, StdPalette, FALSE);
	::RealizePalette(pDC->m_hDC);
	::SelectPalette(pDC->m_hDC,OldPal,TRUE);
}

/////////////////////////////////////////////////////////////////////////////
// zahájení tažení

void CProg::OnBeginDragProgObj(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufObjID;
	m_TreeSrc = &m_Object;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProgLoc(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufLocID;
	m_TreeSrc = &m_Local;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProgStr(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufStrID;
	m_TreeSrc = &m_Struc;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProgCls(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufClsID;
	m_TreeSrc = &m_Class;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProgEdi(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufEdiID;
	m_TreeSrc = &m_Edit;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProg(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_TREEVIEW*	pnm = (NM_TREEVIEW*)pNMHDR; // notifikaèní zpráva
	CPoint			pt; 				// souøadnice kurzoru myši na obrazovce
	UINT			nFlags; 			// pøíznaky, kam bylo kliknuto
	RECT			rect;				// naètené souøadnice textu prvku
	int 			width, height;		// zjištìná velikost ikon stromu

// nesmí probíhat tažení
	*pResult = 0;
	if (m_Dragging) return;

// pøíprava taženého a cílového prvku
	m_itemDrag = m_TreeSrc->HitTest(pnm->ptDrag, &nFlags);
	if (m_itemDrag == NULL) return;
	m_itemDragN = m_Buf[m_DragSrc].SrcItem(m_itemDrag);
	if (m_itemDragN == -1) return;
	m_itemDragPar = m_Buf[m_DragSrc].m_Items[m_itemDragN].param;
	m_itemDragModel = m_Buf[m_DragSrc].m_Items[m_itemDragN].model;
	m_itemDrop = NULL;

// zakázaný prvek pro tažení
	if ((m_itemDragPar & PR_NOMOVE) != 0) return;

// zjíštìní souøadnic textu prvku
	if(!m_TreeSrc->GetItemRect(m_itemDrag,&rect,TRUE)) return;

// zjištìní velikosti ikony ve stromu
	ImageList_GetIconSize(
		m_TreeSrc->GetImageList(TVSIL_NORMAL)->m_hImageList,
		&width, 
		&height);

// výpoèet vzdálenosti kurzoru myši od poèátku prvku
	m_HotSpot = CPoint(pnm->ptDrag) - CPoint(rect.left-width-3, rect.top);
	m_TestSpot = CSize(width/2, 0);

// pøíprava seznamu obrázkù tažení
	m_DragList = m_TreeSrc->CreateDragImage(m_itemDrag);
	if (m_DragList == NULL) return;

// nastavení pøíznaku zahájení tažení (teï již se nesmí pøerušit)
	m_Dragging = TRUE;
	m_TreeDst = NULL;
	m_DropIndex = -1;
//	m_DropParent = -1;

// výbìr cílového prvku
	m_TreeSrc->SelectDropTarget(m_itemDrag);

// zapnutí zobrazení obrázku tažení (bez uzamykání okna)
	m_DragList->DragShowNolock(TRUE);

// rozlišení módu pøesunu nebo kopie podle tlaèítek myši
	if (pnm->hdr.code == TVN_BEGINRDRAG)	// je pravé tlaèítko ?
		m_DragRight = TRUE; 				// je pravé tlaèítko
	else
		m_DragRight = FALSE;				// není pravé tlaèítko

// korekce, které prvky budou vždy jen kopírovány
	if ((m_itemDragPar & PR_INTERNAL) != 0)
		m_DragRight = TRUE;

// pøíprava pøíznaku kopírování
	m_DragCopy = TRUE;						// bude se kopírovat
	m_DragDelete =	!m_DragRight;			// ruší se pøi pøesunu levým tlaèítkem

// zapnutí kurzoru pro tažení
	m_OldCursor = ::GetCursor();
	if (m_DragRight)
		m_CurAkt = m_CurCopy;
	else
		m_CurAkt = m_CurMove;
	::SetCursor(m_CurAkt);

// vytvoøení nového obrázku tažení
	m_DragList->SetDragCursorImage(0, CPoint(m_HotSpot));

// zahájení operace tažení
	m_DragList->BeginDrag(0, CPoint(0,0));

// naètení souøadnic kurzoru myši
	GetCursorPos(&pt);

// pro strom struktur zrušení výbìru cíle
//	if (m_DragSrc == BufStrID)
	m_TreeSrc->SelectDropTarget(NULL);

// zahájení operace tažení, zákaz aktualizace okna
	m_DragList->DragEnter(NULL, pt - m_HotSpot);

// pøetažení obrázku na aktuální pozici myši
	m_DragList->DragMove(pt - m_HotSpot);

// zahájení zachytávání myši
	SetCapture();
}

/////////////////////////////////////////////////////////////////////////////
// posun myší pøi tažení

void CProg::OnMouseMove(UINT nFlags, CPoint point) 
{
	UINT		flags;				// pøíznaky cílového prvku
	HCURSOR 	hCurNew = m_CurNoDrag; // nový kurzor myši
	CPoint		ptScreen, ptTree;	// pozice tažené ikony na obrazovce a ve stromu
	CTreeCtrl*	OldTree;			// pùvodní cílový strom
	int 		OldItem;			// pùvodní vybraná položka
	CRect		rect;				// souøadnice prvku pod kurzorem
	int 		width, height;		// zjištìná velikost ikon stromu
	UINT		indent; 			// odsazování položek v cílovém stromu
	int 		AlterDstN;			// alternativní cíl položení
	
// musí probíhat tažení
	if (m_Dragging)
	{
// pøednastavení neplatného cíle operace
		OldTree = m_TreeDst;		// úschova pùvodního cílového stromu
		OldItem = m_itemDropN;		// úschova pùvodní cílové položky
		m_TreeDst = NULL;			// není cílový strom
		m_DragDst = -1; 			// ID cílového stromu - není
		m_itemDrop = NULL;			// není cílová položka
		m_itemDropN = -1;			// není cílová položka
		m_DropIndex = -1;			// zákaz uložení
		m_DragCopy = FALSE; 		// není kopírování
		m_DragDelete = FALSE;		// není rušení

// pøetažení obrázku na novou pozici
		ptScreen = point - m_HotSpot;
		ClientToScreen(&ptScreen);
		m_DragList->DragMove(ptScreen);

// nalezení okna, nad kterým je taženo
		if (SrcDropWin(point))
		{

// pøi tažení do okna struktur bude odhození
			if ((m_DragDst == BufStrID) && 
				(m_DragSrc != BufStrID) &&
				!m_DragRight
				)
			{
				m_DragDelete = TRUE;
				hCurNew = m_CurDelete;
			}

			else

// test, zda je tažení pro cílové okno platné
//			if (TestDropWin())
			{			
	
// nastavení pøíznakù módu kopie nebo pøesunu
				m_DragCopy = TRUE;
				if (m_DragRight || (m_DragDst != m_DragSrc))
					m_DragDelete = FALSE;
				else
					m_DragDelete = TRUE;

// pøíprava kurzoru pro kopírování nebo pøesun
				if (m_DragDelete)
					hCurNew = m_CurMove;
				else
					hCurNew = m_CurCopy;

// pøepoèet støedu tažené ikony na klientské souøadnice
				ptTree = ptScreen + m_TestSpot;
				m_TreeDst->ScreenToClient(&ptTree);

// nalezení cílové položky pod kurzorem
				m_itemDrop = m_TreeDst->HitTest(ptTree, &flags);
				m_itemDropN = m_Buf[m_DragDst].SrcItem(m_itemDrop);

// pøíprava indexu k uložení položky
				if (m_itemDropN == -1)
				{
					if (TestDropItem(m_itemDragModel, m_itemDragPar,
							m_DragSrc, TYP_ROOT, PR_GET_COMMAND, m_DragDst, m_itemDropN))
					{
						m_DropIndex = m_Buf[m_DragDst].m_Next;
					}
					else
					{
						m_itemDrop = NULL;
						m_DropIndex = -1;
						hCurNew = m_CurNoDrag;
						m_DragCopy = FALSE;
						m_DragDelete = FALSE;
					}
				}
				else
				{
					m_DropIndex = m_itemDropN+1;

// zjištìní velikosti ikony v cílovém stromu
					ImageList_GetIconSize(
						m_TreeDst->GetImageList(TVSIL_NORMAL)->m_hImageList,
						&width, 
						&height);

// zjištìní odsazování potomkù
					indent = m_TreeDst->GetIndent();

// zjištìní pozice prvku pod kurzorem
					m_TreeDst->GetItemRect(m_itemDrop, &rect, TRUE);

// výpoèet støedu X ikony pod kurzorem
					rect.left = rect.left - width/2 + width/10;

// pøíprava alternativního cílového prvku
					AlterDstN = m_Buf[m_DragDst].m_Items[m_itemDropN].parent;

// zjištìní rodièe podle X polohy kurzoru
					while ((ptTree.x < rect.left) && (m_itemDropN != -1))
					{
						AlterDstN = m_itemDropN;
						m_itemDropN = m_Buf[m_DragDst].m_Items[m_itemDropN].parent;
						if (m_itemDropN != -1)
							m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
						else
							m_itemDrop = NULL;
						rect.left -= indent;
					}

// hlavní prvek -1 je povolen, alternativní tehdy není = -1
					if (m_itemDropN != -1)
					{

// naètení parametrù hlavního cílového prvku
						m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
						m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
						m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;

// est hlavního cílového prvku
						if (!TestDropItem(m_itemDragModel, m_itemDragPar, m_DragSrc,
							m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDropN))
						{

// jinak zmìna na vedlejší cílový prvek
							m_itemDropN = AlterDstN;

// naètení parametrù vedlejšího cílového prvku (nemùže být = -1)
							m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
							m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
							m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;

// est vedlejšího cílového prvku
							if (!TestDropItem(m_itemDragModel, m_itemDragPar, m_DragSrc,
							m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDropN))
							{
								hCurNew = m_CurNoDrag;
								m_DropIndex = -1;
								m_DragCopy = FALSE;
								m_DragDelete = FALSE;
								m_itemDropN = -1;
								m_itemDrop = NULL;
							}
						}
					} // if (m_itemDropN != -1)
				} // m_itemDropN != -1

// test, zda je operace platná
				if (m_DropIndex != -1)
				{

// kontrola, zda není cyklické kopírování uvnitø okna
					if (m_DragDst == m_DragSrc)
					{
						int xitem = m_itemDropN;

						while ((xitem >= 0) && (xitem < m_Buf[m_DragDst].m_Num))
							if (xitem == m_itemDragN)
							{
								hCurNew = m_CurNoDrag;
								m_itemDropN = -1;
								m_DropIndex = -1;
								xitem = -1;
								m_DragCopy = FALSE;
								m_itemDrop = NULL;
								m_DragDelete = FALSE;
							}
							else
								xitem = m_Buf[m_DragDst].m_Items[xitem].parent;
					}

// upøesnìní indexu a cíle, je-li hození za konec stromu
					if (m_itemDropN == -1)
					{
						if (m_Buf[m_DragDst].m_First > 0)
						{
							m_itemDropN = m_Buf[m_DragDst].m_First - 1;
							m_itemDrop = NULL; //m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
						}
						else
						{
							m_itemDrop = NULL;
						}
					}
					else
						m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;

					if (m_itemDrop == NULL)
					{
						m_itemDropModel = TYP_ROOT;
						m_itemDropPar = PR_GET_COMMAND;
					}
					else
					{
						m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;
						m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
					}

					if (!TestDropItem(m_itemDragModel, m_itemDragPar,
							m_DragSrc, m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDropN))
					{
						m_DropIndex = -1;
						hCurNew = m_CurNoDrag;
						m_DragCopy = FALSE;
						m_itemDrop = NULL;
						m_itemDropN = -1;
						m_DragDelete = FALSE;
					}

				} // if(m_DropIndex != -1)
			} // if(TestDropWin())
		} // if(SrcDropWin(point))

// nastavení nového kurzoru myši
		if (hCurNew != m_CurAkt)
		{
			m_CurAkt = hCurNew;
			::SetCursor(m_CurAkt);
		}

// zrušení výbìru staré cílové položky pøi zmìnì okna stromu
		if ((OldTree != NULL) && (OldTree != m_TreeDst))
		{
			m_DragList->DragLeave(NULL);
			OldTree->SelectDropTarget(NULL);
			m_DragList->DragEnter(NULL, ptScreen);
		}

// výbìr nové cílové položky
		if (((m_itemDropN != OldItem) || (OldTree != m_TreeDst))
			&& (m_TreeDst != NULL))
		{
			m_DragList->DragLeave(NULL);
			m_TreeDst->SelectDropTarget(m_itemDrop);
			m_DragList->DragEnter(NULL, ptScreen);
		}

	} // if(m_Dragging)
	CFormView::OnMouseMove(nFlags, point);
}

/////////////////////////////////////////////////////////////////////////////
// nalezení cílového okna pod kurzorem myši pøi tažení

BOOL CProg::SrcDropWin(CPoint point)
{
// pøednastavení neplatné operace
	m_TreeDst = NULL;
	m_DragDst = -1;

// nalezení okna, nad kterým je taženo
	CWnd* wnd = ChildWindowFromPoint(point - m_HotSpot + m_TestSpot,
					CWP_SKIPINVISIBLE | CWP_SKIPDISABLED);
	if (wnd == NULL) return FALSE;
	HWND hwnd = wnd->m_hWnd;

// test okna veøejných objektù
	if (hwnd == m_Object.m_hWnd)
	{
		m_TreeDst = &m_Object;
		m_DragDst = BufObjID;
		return TRUE;
	}

// test okna lokálních objektù
	if (hwnd == m_Local.m_hWnd)
	{
		m_TreeDst = &m_Local;
		m_DragDst = BufLocID;
		return TRUE;
	}

// test okna struktur
	if (hwnd == m_Struc.m_hWnd)
	{
		m_TreeDst = &m_Struc;
		m_DragDst = BufStrID;
		return TRUE;
	}

// test okna tøíd
	if (hwnd == m_Class.m_hWnd)
	{
		m_TreeDst = &m_Class;
		m_DragDst = BufClsID;
		return TRUE;
	}

// test okna editace
	if (hwnd == m_Edit.m_hWnd)
	{
		m_TreeDst = &m_Edit;
		m_DragDst = BufEdiID;
		return TRUE;
	}

// okno nenalezeno
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// test povolení cílového okna pøi tažení

//BOOL CProg::TestDropWin()
//{
/*
// testy pro shodná okna
	if (m_DragSrc == m_DragDst)
	{

// uvnitø v oknì struktur nelze tahat
		if (m_DragSrc == BufStrID) return FALSE;
		return TRUE;
	}

// testy pro rozdílná okna
	switch(m_DragSrc)
	{

// zdrojem okna objektù - jen tahání do editaèního okna
	case BufObjID:
	case BufLocID:
		if (m_DragDst != BufEdiID) return FALSE;
		break;

// zdrojem je okno struktur
	case BufStrID:
		if (m_DragDst != BufEdiID)
			if	(
				 !(
				  ((m_itemDragPar & PR_GROUP) != 0) ||
				  (((m_itemDragPar & PR_LIST) != 0) &&
				   ((m_DragDst == BufObjID) || (m_DragDst == BufLocID)))
				 )
				)
				return FALSE;
		break;

// z okna tøíd lze tahat jen do oken objektù
	case BufClsID:
		if ((m_DragDst != BufObjID) && (m_DragDst != BufLocID)) return FALSE;
		break;		
// z okna editace nelze tahat nikam
	case BufEdiID:
		return FALSE;

	}
*/	
//	return TRUE;
//}

/////////////////////////////////////////////////////////////////////////////
// test povolení spojení dvou prvkù

BOOL CProg::TestDropItem(int srcModel, int srcPar, int srcBuff, int dstModel,
						 int dstPar, int dstBuff, int dstItem)
{
	switch (dstBuff)
	{
///////////////////////// cílem okno objektù
	case BufObjID:
		if (srcBuff == BufEdiID) return FALSE;		// z editoru nelze nikdy táhnout

		if (srcBuff == BufLocID) return FALSE;		// z lokálních objektù nelze nikdy táhnout

		if ((srcBuff == BufStrID) && 
			(srcModel != TYP_GROUP) && 
			(srcModel != TYP_LIST)) return FALSE;	// z okna struktur jen skupinu a seznam

		if ((dstModel != TYP_GROUP) &&				// cílem jen skupina nebo ROOT
			(dstModel != TYP_ROOT)) return FALSE;

		switch (srcModel)
		{
		case TYP_GROUP:
		case TYP_LIST:
		case TYP_NUM:
		case TYP_FUNC:
		case TYP_REAL:
		case TYP_BOOL:
		case TYP_TEXT:
		case TYP_PIC:
		case TYP_MAP:
		case TYP_SND:
		case TYP_MUS:
		case TYP_SPRITE:
		case TYP_DIALOG:
		case TYP_EVENT:
		case TYP_TXT:
			return TRUE;
		}
		return FALSE;

////////////////////////// cílem okno editoru
	case BufEdiID:
// z tøíd nelze nikdy táhnout
		if (srcBuff == BufClsID) return FALSE;

// skupinu objektù nelze táhnout
		if (((srcBuff == BufObjID) || (srcBuff == BufLocID)) && 
			(srcModel == TYP_GROUP)) return FALSE;

// test, zda je povolen pouze jeden parametr
		if (((dstPar & PR_ONE) != 0) && (dstItem != -1))
		{
			if (m_Buf[dstBuff].m_Items[dstItem].items > 1)
			{
				return FALSE;
			}
		}

// pøetažení pøíkazu
		if (((srcPar & PR_AS_COMMAND) != 0) &&
			((dstPar & PR_GET_COMMAND) != 0)) return TRUE;

// pøetažení výrazu
		if (((srcPar & PR_AS_EXPRES) != 0) &&
			((dstPar & PR_GET_EXPRES) != 0)) return TRUE;

// pøetažení logického výrazu
		if (((srcPar & PR_AS_BOOL) != 0) &&
			((dstPar & PR_GET_BOOL) != 0)) return TRUE;

// pøetažení vìtve CASE
		if (srcModel == TYP_CASE_ON)
		{
			if (dstModel == TYP_CASE)
				return TRUE;
			else
				return FALSE;
		}

// pøetažení testu vìtve CASE
		if (srcModel == TYP_CASE_TEST)
		{
			if (dstModel == TYP_CASE_ON)
				return TRUE;
			else
				return FALSE;
		}

// pøetažení èíslice do èíselné konstanty
		if (dstModel == TYP_NUM)
		{
			switch (srcModel)
			{
			case TYP_CIS:
			case TYP_TECKA:
			case TYP_MINUS:
			case TYP_EXPONENT:
				return TRUE;
			}
			return FALSE;
		}

// pøetažení textu
		switch (srcModel)
		{
		case TYP_FTN:
		case TYP_FT:
		case TYP_TXT:
		case TYP_FTT:
		case TYP_FTNT:
		case TYP_TEXT:
			switch (dstModel)
			{
			case TYP_FTT:
			case TYP_FTNT:
			case TYP_FNT:
			case TYP_TEXT:
			case TYP_EQU_TEXT:
				return TRUE;
			}
			return FALSE;
		}

// pøetažení obrázku
		if (srcModel == TYP_PIC)
		{
			if ((dstModel == TYP_PIC) ||
					(dstModel == TYP_EQU_PIC))
				return TRUE;
			else
				return FALSE;
		}

// pøetažení promìnné
		switch (srcModel)
		{
		case TYP_TEXT:
		case TYP_PIC:
		case TYP_MAP:
		case TYP_SND:
		case TYP_MUS:
		case TYP_SPRITE:
		case TYP_DIALOG:
		case TYP_EVENT:
			if (srcModel == dstModel)
				return TRUE;
			else
				return FALSE;
		}



		return FALSE;

////////////////////////// cílem okno lokálních objektù
	case BufLocID:
		if (srcBuff == BufEdiID) return FALSE;		// z editoru nelze nikdy táhnout

		if (srcBuff == BufObjID) return FALSE;		// z objektù nelze nikdy táhnout

		if ((srcBuff == BufStrID) && 
			(srcModel != TYP_GROUP) && 
			(srcModel != TYP_LIST)) return FALSE;	// z okna struktur jen skupinu a seznam

		if ((dstModel != TYP_GROUP) &&				// cílem jen skupina, ROOT nebo parametr
			(dstModel != TYP_ROOT) &&
			(dstModel != TYP_IPARAM) &&
			(dstModel != TYP_OPARAM)) return FALSE;

// test, zda je povolen pouze jeden parametr
		if (((dstPar & PR_ONE) != 0) && (dstItem != -1))
		{
			if (m_Buf[dstBuff].m_Items[dstItem].items > 1)
			{
				return FALSE;
			}
		}

		switch (srcModel)
		{
		case TYP_GROUP:
		case TYP_LIST:
		case TYP_NUM:
		case TYP_FUNC:
		case TYP_REAL:
		case TYP_BOOL:
		case TYP_TEXT:
		case TYP_PIC:
		case TYP_MAP:
		case TYP_SND:
		case TYP_MUS:
		case TYP_SPRITE:
		case TYP_DIALOG:
		case TYP_EVENT:
		case TYP_TXT:
			return TRUE;
		}
		return FALSE;


	}
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// ukonèení tažení uvolnìním tlaèítka myši

void CProg::OnLButtonUp(UINT nFlags, CPoint point) 
{
	OnButtonUp();	
	CFormView::OnLButtonUp(nFlags, point);
}

void CProg::OnRButtonUp(UINT nFlags, CPoint point) 
{
	OnButtonUp();
	CFormView::OnRButtonUp(nFlags, point);
}

void CProg::OnButtonUp()
{
// test, zda probíhá tažení
	if (m_Dragging)
	{
// ukonèení pøíznaku tažení
		m_Dragging = FALSE;

// pozastavení tažení
		m_DragList->DragLeave(NULL);

// ukonèení tažení
		m_DragList->EndDrag();

// zrušení seznamu obrázkù tažení
		delete m_DragList;
		m_DragList = NULL;

// zrušení výbìru cíle operace u cílového okna
		if (m_TreeDst != NULL)
			m_TreeDst->SelectDropTarget(NULL);

// uvolnìní zachytávání myši
		ReleaseCapture();

// zrušení pøekreslení cílového prvku
		::SetCursor(m_OldCursor);

// test, zda není jen pøetažení na místì
		if (m_DragCopy || m_DragDelete)
		{
			if ((m_DragDst != m_DragSrc) ||
				((m_itemDragN != m_DropIndex) && (m_itemDragN != m_DropIndex-1)) ||
				(m_Buf[m_DragSrc].m_Items[m_itemDragN].parent != m_itemDropN) ||
				!m_DragDelete)
			{
				int newDst;
// kopie prvku
				if (m_DragCopy)
				{
					int nSrc = m_itemDragN; 	// opravováno pøi kopiích
					int nDst = m_DropIndex; 	// neopravováno pøi kopiích
					newDst = CopyItem(nSrc, nDst, m_itemDropN); // skuteèná první cílová položka

					m_TreeDst->SetFocus();
					if ((newDst != -1) && (newDst < m_Buf[m_DragDst].m_Num))
						m_TreeDst->Select(m_Buf[m_DragDst].m_Items[newDst].htree, TVGN_CARET | TVGN_DROPHILITE);
				}

// pøi pøetažení pøesmìrování referencí
				if ((m_DragSrc == m_DragDst) && m_DragCopy && m_DragDelete && (m_DragSrc != BufEdiID))
				{
					int nFirst = m_itemDragN;
					int nLast = nFirst + m_Buf[m_DragSrc].m_Items[m_itemDragN].items - 1;
					
					for (int b = 0; b < PROGBUFNUM; b++)
					{
						if (b != m_DragSrc)
						{
							CProgBuf* buf = &m_Buf[b];
							PROGITEM* item;
							for (int i = buf->m_Num-1; i >= 0; i--)
							{
								item = &(buf->m_Items[i]);

								if (item->typ == m_DragSrc)
								{
									if ((item->refer >= nFirst) &&
										(item->refer <= nLast))
									{
										m_Buf[m_DragSrc].m_Items[item->refer].counter--;
										item->refer = item->refer - nFirst + newDst;
										m_Buf[m_DragDst].m_Items[item->refer].counter++;
									}
								}
							}
						}
					}
				}

// zrušení taženého prvku
				if (m_DragDelete)
					m_Buf[m_DragSrc].Delete(m_itemDragN);

// založení deklarace (je kopie, ne pøesun)
				else
				{
					PROGITEM pri;
					pri.icon = -1;
					pri.name = -1;
					pri.childs = 0;
					pri.items = 1;
					pri.htree = NULL;
					pri.counter = 0;
					pri.parent = -1;
					pri.model = TYP_NONE;

					if (((m_DragDst == BufObjID) || (m_DragDst == BufLocID)) &&
						((m_itemDragPar & PR_FUNC) != 0))
					{
						pri.typ = m_DragDst;
						pri.refer = newDst;
						pri.param = PR_NOMOVE | PR_EXP;
						m_BufEdi.Insert(&pri);

						if (m_DragDst == BufLocID)
							DblclkLocal(newDst);
					}
		
					if ((m_DragDst == BufObjID) &&
						((m_itemDragPar & PR_FUNC) != 0))
					{
						int par;

						pri.typ = m_DragDst;
						pri.refer = newDst;
						pri.param = PR_NOMOVE | PR_EXP;
						par = m_BufLoc.Insert(&pri);

						pri.typ = BufIntID;
						pri.refer = FncOut;
						pri.parent = par;
						pri.model = TYP_OPARAM;
						pri.param = PR_NOMOVE | PR_ONE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL;
						m_BufLoc.Insert(&pri);

						pri.refer = FncPar;
						pri.model = TYP_IPARAM;
						pri.param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL;
						m_BufLoc.Insert(&pri);

						DblclkObject(newDst);
					}

				}

			}
		}

		DispName();
	}
}

/////////////////////////////////////////////////////////////////////////////
// kopie jedné vìtve prvkù z m_DragSrc/m_TreeSrc do m_DragDst/m_TreeDst

int CProg::CopyItem(int& nSrc, int& nDst, int nPar)
{
	int result;

// naètení zdrojového prvku
	PROGITEM prit;
	memcpy(&prit, &(m_Buf[m_DragSrc].m_Items[nSrc]), sizeof(PROGITEM));

// nastavení rodièe
	prit.parent = nPar;

// zrušení parametrù po kopírování
	prit.param &= ~PR_INTERNAL;

// èíslo se kopíruje bez obsahu
	if ((m_DragSrc == BufStrID) && (prit.refer == FncNum))
		prit.childs = 0;

// tìlo cyklu se kopíruje bez pøerušení cyklu (musí být jako poslední !!!!)
	if ((m_DragSrc == BufStrID) && (prit.refer == FncWhileBody))
		prit.childs = 0;

// tøída se kopíruje bez obsahu
	if (m_DragSrc == BufClsID)
		prit.childs = 0;

// zmìna reference na zdrojové okno
	if (m_DragSrc != m_DragDst)
	{
		prit.typ = m_DragSrc;
		prit.refer = nSrc;
		prit.name = -1;
		prit.icon = -1;
	}

// kopie textu
	if (prit.name != -1)
	{
		CString txt;
		txt = m_Buf[m_DragSrc].m_Text->Get(prit.name);
		prit.name = m_Buf[m_DragDst].m_Text->Add(txt);
	}

// textová konstanta se vyprázdní
	if ((m_DragSrc == BufStrID) && (prit.model == TYP_TXT))
	{
		prit.name = m_Buf[m_DragDst].m_Text->Add("");
	}

// vložení prvku do stromu (pøíp. se zajištìním viditelnosti)
	nDst = m_Buf[m_DragDst].Insert(&prit, nDst);
	result = nDst;

// zajištìní viditelnosti
	if ((m_DragSrc == BufStrID) || (nPar == m_itemDropN))
		m_TreeDst->EnsureVisible(m_Buf[m_DragDst].m_Items[nDst].htree);

// kopírování v jednom stromu
	if (m_DragSrc == m_DragDst)
	{
		if (nDst <= nSrc)
			nSrc++;
		if (nDst <= m_itemDragN)
			m_itemDragN++;
	}

// zvýšení ukazatelù položek
	nPar = nDst;
	nSrc++;
	nDst++;

// kopie potomkù
	for (int i = 0; i < prit.childs; i++)
	{
		CopyItem(nSrc, nDst, nPar);
	}

	return result;
}

/////////////////////////////////////////////////////////////////////////////
// zaznamenání zmìny v rozvinutí struktury stromu

void CProg::OnItemExpandedProgObj(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufObjID);
}

void CProg::OnItemExpandedProgLoc(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufLocID);
}

void CProg::OnItemExpandedProgStr(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufStrID);
}

void CProg::OnItemExpandedProgCls(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufClsID);
}

void CProg::OnItemExpandedProgEdi(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnItemExpandedProg(pNMHDR, pResult, BufEdiID);
}

void CProg::OnItemExpandedProg(NMHDR* pNMHDR, LRESULT* pResult, int buff) 
{
	NM_TREEVIEW* pnm = (NM_TREEVIEW*)pNMHDR;
	int index;

	if ((pnm->itemNew.mask & TVIF_STATE) != 0)
	{	
		index = m_Buf[buff].SrcItem(pnm->itemNew.hItem);
		if (index != -1)
		{
			if ((pnm->itemNew.state & TVIS_EXPANDED) != 0)
				m_Buf[buff].m_Items[index].param |= PR_EXP;
			else
				m_Buf[buff].m_Items[index].param &= ~PR_EXP;
		}
	}
	*pResult = 0;
}

/////////////////////////////////////////////////////////////////////////////
// zmìna aktivní položky nebo zmìna okna

void CProg::OnSelChangedObject(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnSelChanged(pNMHDR, pResult);
	RefSelChange(BufObjID, BufClsID);
}

void CProg::OnSelChangedLocal(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnSelChanged(pNMHDR, pResult);
	RefSelChange(BufLocID, BufClsID);
}

void CProg::OnSelChangedStruc(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnSelChanged(pNMHDR, pResult);
}

void CProg::OnSelChangedClass(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnSelChanged(pNMHDR, pResult);
}

void CProg::OnSelChangedEdit(NMHDR* pNMHDR, LRESULT* pResult) 
{
	OnSelChanged(pNMHDR, pResult);
	RefSelChange(BufEdiID, BufObjID);
	RefSelChange(BufEdiID, BufLocID);
}

void CProg::OnSelChanged(NMHDR* pNMHDR, LRESULT* pResult) 
{
	DispName();
	*pResult = 0;
}

void CProg::RefSelChange(int AktBuf, int RefBuf)
{
// pøíprava aktivní položky
	HTREEITEM AktItem = m_Buf[AktBuf].m_Tree->GetSelectedItem();
	int AktItemN = m_Buf[AktBuf].SrcItem(AktItem);
	if (AktItemN != -1)
	{
		PROGITEM* item = &(m_Buf[AktBuf].m_Items[AktItemN]);
		
// pøi zmìnì v editoru není odkaz na objekt - odznaèení objektù
		if ((AktBuf == BufEdiID) && 
			(item->typ != BufObjID) &&
			(item->typ != BufLocID))
		{
			m_Object.SelectItem(NULL);
			m_Local.SelectItem(NULL);
		}

// oznaèení odkazu
		if ((item->typ == RefBuf) && (item->refer != -1))
		{
			HTREEITEM RefItem = m_Buf[RefBuf].m_Items[item->refer].htree;
			m_Buf[RefBuf].m_Tree->SelectItem(RefItem);
			m_Buf[RefBuf].m_Tree->EnsureVisible(RefItem);

// pøi odkazu na objekty je druhý buffer neaktivní
			if (RefBuf == BufObjID)
				m_Local.SelectItem(NULL);
			if (RefBuf == BufLocID)
				m_Object.SelectItem(NULL);
		}
	}

// jsou-li oba objekty nevybrané, není vybraná ani tøída
	if ((m_Object.GetSelectedItem() == NULL) &&
		(m_Local.GetSelectedItem() == NULL))
		m_Class.SelectItem(NULL);
}


void CProg::OnSetFocusObject(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufObjID;
	m_AktTree = &m_Object;
	DispName();
}

void CProg::OnSetFocusLocal(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufLocID;
	m_AktTree = &m_Local;
	DispName();
}


void CProg::OnSetFocusStruc(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufStrID;
	m_AktTree = &m_Struc;
	DispName();
}

void CProg::OnSetFocusClass(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufClsID;
	m_AktTree = &m_Class;
	DispName();
}

void CProg::OnSetFocusProg(NMHDR* pNMHDR, LRESULT* pResult) 
{
	m_AktBufID = BufEdiID;
	m_AktTree = &m_Edit;
	DispName();
}

void CProg::DispName() 
{
	HTREEITEM item = m_AktTree->GetSelectedItem();
	m_AktItem = m_Buf[m_AktBufID].SrcItem(item);

	m_FilName = TRUE;

	if (m_AktItem == -1)
	{
		m_Name.SetWindowText(_T(""));
		m_Refer.SetWindowText(_T(""));
		m_Def.SetCheck(1);
	}
	else
	{
		TCHAR buff[50];
		PROGITEM* item = &(m_Buf[m_AktBufID].m_Items[m_AktItem]);
		int count = item->counter;
		if ((m_AktBufID == BufEdiID) && (item->typ != -1) && (item->refer != -1))
			count = m_Buf[item->typ].m_Items[item->refer].counter;

		if ((item->param & PR_FUNC) != 0)
		{
			if (m_AktBufID == BufObjID)
			{
				count--;
				count--;
			}
			if (m_AktBufID == BufLocID)
				count--;
		}

		wsprintf(buff, _T("Použito %d krát"), count);
		m_Refer.SetWindowText(buff);

		m_Name.SetWindowText(m_AktTree->GetItemText(m_Buf[m_AktBufID].m_Items[m_AktItem].htree));

		if (m_Buf[m_AktBufID].m_Items[m_AktItem].name == -1)
			m_Def.SetCheck(1);
		else
			m_Def.SetCheck(0);
	}

	m_FilName = FALSE;
}

void CProg::OnChangeName() 
{
	if ((m_AktItem != -1) && !m_FilName)
	{
		m_FilName = TRUE;

		CString text;
		m_Name.GetWindowText(text);

		PROGITEM* pit = &(m_Buf[m_AktBufID].m_Items[m_AktItem]);

		m_AktTree->SetItemText(pit->htree,text);

		if (pit->name == -1)
		{
			pit->name = m_Buf[m_AktBufID].m_Text->Add(text);
		}
		else
		{
			m_Buf[m_AktBufID].m_Text->Set(pit->name, text);
		}
		
		m_Def.SetCheck(0);

		if ((pit->counter != 0) && (pit->name != -1))
		{
			AktNameTree(&m_BufObj, &text, m_AktBufID, m_AktItem);
			AktNameTree(&m_BufLoc, &text, m_AktBufID, m_AktItem);
			AktNameTree(&m_BufCls, &text, m_AktBufID, m_AktItem);
			AktNameTree(&m_BufEdi, &text, m_AktBufID, m_AktItem);
		}

		m_FilName = FALSE;
	}
}

void CProg::AktNameTree(CProgBuf* buff, CString* text, int AktBuf, int AktItem)
{
	for (int i = 0; i < buff->m_Num; i++)
	{
		if (buff->m_Items[i].refer == AktItem)
		{
			if ((buff->m_Items[i].typ == AktBuf) &&
				(buff->m_Items[i].name == -1))
			{
				buff->m_Tree->SetItemText(buff->m_Items[i].htree,*text);

				if (buff == &m_BufObj)
					AktNameTree(&m_BufEdi, text, BufObjID, i);

				if (buff == &m_BufLoc)
					AktNameTree(&m_BufEdi, text, BufLocID, i);

				if (buff == &m_BufCls)
				{
					AktNameTree(&m_BufObj, text, BufClsID, i);
					AktNameTree(&m_BufLoc, text, BufClsID, i);
				}
			}
		}
	}
}


BOOL CProg::PreTranslateMessage(MSG* pMsg) 
{
	if (pMsg->message == WM_KEYDOWN)
	{
		if (pMsg->wParam == VK_RETURN)
		{
			CWnd* wnd = GetFocus();
			if (wnd != NULL)
			{
				if (wnd->m_hWnd == m_Name.m_hWnd)
				{
					m_AktTree->SetFocus();
				}
			}
		}
	}
	
	return CFormView::PreTranslateMessage(pMsg);
}

void CProg::OnProgDef() 
{
	if (!m_FilName)
	{

		if (m_Def.GetCheck() != 1)
			OnChangeName();

		else
			if (m_AktItem != -1)
			{
				m_FilName = TRUE;
		
				PROGITEM* pit = &(m_Buf[m_AktBufID].m_Items[m_AktItem]);
				PROGITEM* pit2;

				if (pit->name == -1) return;

				m_Buf[m_AktBufID].m_Text->ElementAt(pit->name).Empty();

				pit->name = -1;

				CString text = _T("");
				CProgBuf* pbuf;
				pit2 = pit;
				pbuf = &m_Buf[m_AktBufID];

				while ((pit2->name == -1) && (pit2->typ != -1) && (pit2->refer != -1))
				{
					pbuf = &m_Buf[pit2->typ];
					pit2 = &(pbuf->m_Items[pit2->refer]);
				}

				if (pit2->name != -1)
				{
					text = pbuf->m_Text->Get(pit2->name);
				}

				m_Name.SetWindowText(text);

				m_AktTree->SetItemText(pit->htree,text);

				if (pit->counter != 0)
				{
					AktNameTree(&m_BufObj, &text, m_AktBufID, m_AktItem);
					AktNameTree(&m_BufLoc, &text, m_AktBufID, m_AktItem);
					AktNameTree(&m_BufCls, &text, m_AktBufID, m_AktItem);
					AktNameTree(&m_BufEdi, &text, m_AktBufID, m_AktItem);
				}
	
				m_FilName = FALSE;

			}
	}
	m_AktTree->SetFocus();
}

/////////////////////////////////////////////////////////////////////////////
// dvojklik myší

void CProg::OnDblclkProgObject(NMHDR* pNMHDR, LRESULT* pResult) 
{
	UINT		nFlags;
	HTREEITEM	hItem;
	int 		item;
	CPoint		pt;
	
	::GetCursorPos(&pt);
	m_Object.ScreenToClient(&pt);
	hItem = m_Object.HitTest(pt, &nFlags);
	item = m_BufObj.SrcItem(hItem); 

	DblclkObject(item);

	*pResult = 0;
}


void CProg::DblclkObject(int item)
{
	PROGITEM*	pi;
	int 		i, srcItem;

	if ((item < 0) || (item >= m_BufObj.m_Num))
		return;

	m_Object.SelectItem(m_BufObj.m_Items[item].htree);

	CProgBuf*	buf = &(m_BufEdi);
	buf->m_First = 0;
	buf->m_Next = buf->m_Num;

	srcItem = -1;
	for (i = buf->m_Num - 1; i >= 0; i--)
	{
		pi = &(buf->m_Items[i]);

		if ((pi->typ == BufObjID) &&
			(pi->refer == item))
		{
			buf->m_First = i+1;
			buf->m_Next = pi->items + i;
			buf->ReDisp();
			break;
		}
	}

	buf = &(m_BufLoc);
	buf->m_First = 0;
	buf->m_Next = buf->m_Num;

	srcItem = -1;
	for (i = buf->m_Num - 1; i >= 0; i--)
	{
		pi = &(buf->m_Items[i]);

		if ((pi->typ == BufObjID) &&
			(pi->refer == item))
		{
			buf->m_First = i+1;
			buf->m_Next = pi->items + i;
			buf->ReDisp();
			break;
		}
	}
}

void CProg::OnDblclkProgLocal(NMHDR* pNMHDR, LRESULT* pResult) 
{
	UINT		nFlags;
	HTREEITEM	hItem;
	int 		item;
	CPoint		pt;
	
	::GetCursorPos(&pt);
	m_Local.ScreenToClient(&pt);
	hItem = m_Local.HitTest(pt, &nFlags);
	item = m_BufLoc.SrcItem(hItem); 

	DblclkLocal(item);
	
	*pResult = 0;
}

void CProg::DblclkLocal(int item)
{
	PROGITEM*	pi;
	int 		i, srcItem;

	if ((item < 0) || (item >= m_BufLoc.m_Num))
		return;

	m_Local.SelectItem(m_BufLoc.m_Items[item].htree);

	CProgBuf*	buf = &(m_BufEdi);
	buf->m_First = 0;
	buf->m_Next = buf->m_Num;

	srcItem = -1;
	for (i = buf->m_Num - 1; i >= 0; i--)
	{
		pi = &(buf->m_Items[i]);

		if ((pi->typ == BufLocID) &&
			(pi->refer == item))
		{
			buf->m_First = i+1;
			buf->m_Next = pi->items + i;
			buf->ReDisp();
			break;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// uložení souboru

void CProg::OnFileSave() 
{
	int			i;					// pracovní èítaèe

// kontrola, zda již operace neprobíhá
	if (m_Saving) return;			// probíhá již ukládání/naèítání - konec
	m_Saving = TRUE;				// pøíznak probíhající operace

// pøíprava záhlaví souboru
	m_Head = new PETHEAD;			// vytvoøení bufferu záhlaví souboru
	if (m_Head != NULL) *m_Head = SaveHead;	// pøíprava záhlaví souboru

// pøíprava bufferu textù importovaných funkcí
	m_tabImport = new int[INTERNALNUM]; // konverzní tabulka importovaných funkcí
	m_bufImport	= (char*) malloc(1024); // buffer textù importovaných funkcí
	m_maxImport = 1024;				// velikost bufferu importovaných funkcí
	m_numImport	= 0;				// poèet prvkù importovaných funkcí
	m_sizeImport = 0;				// velikost dat v bufferu importovaných funkcí

// vymazání konverzní tabulky importovaných funkcí
	if (m_tabImport != NULL)
		for (i = 0; i < INTERNALNUM; i++) m_tabImport[i] = -1;

// kontrola tabulky jmen importu
#ifdef	_DEBUG
	int j;
	ASSERT (sizeof(importName)/sizeof(importName[0]) == INTERNALNUM);
	for (i = 0; i < INTERNALNUM-1; i++)
		for (j = i+1; j < INTERNALNUM; j++)
			ASSERT(strcmp(importName[i], importName[j]) != 0);
#endif

// pøíprava bufferu textù
	m_bufText	= (char*) malloc(1024); // buffer textù
	m_maxText	= 1024;				// velikost bufferu textù
	m_numText	= 0;				// poèet prvkù textù
	m_sizeText	= 0;				// velikost dat v bufferu textù

// vytvoøení pracovních bufferù
	m_numClass	= m_BufCls.m_Num;	// poèet prvkù tøíd
	m_bufClass	= new PETPROG[m_numClass];
	m_numObject	= m_BufObj.m_Num;	// poèet prvkù globálních objektù
	m_bufObject	= new PETPROG[m_numObject];
	m_numLocal	= m_BufLoc.m_Num;	// poèet prvkù lokálních objektù
	m_bufLocal	= new PETPROG[m_numLocal];
	m_numEdit	= m_BufEdi.m_Num;	// poèet prvkù editoru
	m_bufEdit	= new PETPROG[m_numEdit];

// kontrola, zda jsou buffery vytvoøeny OK
	if (m_Head == NULL || m_tabImport == NULL || m_bufImport == NULL || m_bufText == NULL ||
		m_bufClass == NULL || m_bufObject == NULL || m_bufLocal == NULL || m_bufEdit == NULL) 
		m_OK = FALSE;
	else
		m_OK = TRUE;

// vytvoøení výstupního souboru
	m_FileName = Jmeno + ".PET";	// jméno výstupního souboru
	m_File = INVALID_HANDLE_VALUE;
	if (m_OK) m_File = ::CreateFile(m_FileName, GENERIC_WRITE, 0, NULL, 
				CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (m_File == INVALID_HANDLE_VALUE)
		m_OK = FALSE;

// pokraèování, pokud byl soubor vytvoøen OK
	if (m_OK)
	{

// vygenerování prvkù bufferù
		SavePrg(m_bufClass,  BufClsID);
		SavePrg(m_bufObject, BufObjID);
		SavePrg(m_bufLocal,  BufLocID);
		SavePrg(m_bufEdit,   BufEdiID);

// pøíprava záhlaví souboru
		m_Head->piImport.pocet = m_numImport;				// poèet interních prvkù
		m_Head->piImport.delka = m_sizeImport;				// velikost tabulky jmen prvkù
		m_Head->piClass.pocet = m_numClass;					// poèet prvkù okna tøíd
		m_Head->piClass.delka = sizeof(PETPROG)*m_numClass;	// velikost tabulky
		m_Head->piGlobal.pocet = m_numObject;				// poèet prvkù okna globálních objektù
		m_Head->piGlobal.delka = sizeof(PETPROG)*m_numObject;// velikost tabulky
		m_Head->piLocal.pocet = m_numLocal;					// poèet prvkù okna lokálních objektù
		m_Head->piLocal.delka = sizeof(PETPROG)*m_numLocal;	// velikost tabulky
		m_Head->piProgram.pocet = m_numEdit;					// poèet prvkù okna editoru
		m_Head->piProgram.delka = sizeof(PETPROG)*m_numEdit; // velikost tabulky
		m_Head->piText.pocet = m_numText;					// poèet prvkù textù
		m_Head->piText.delka = m_sizeText;					// velikost prvkù textù
		m_Head->piPalette.pocet = StdColors;					// poèet palet
		m_Head->piPalette.delka = StdColors * sizeof(RGBQUAD); // velikost dat
		m_Head->piPic16.pocet = m_BufIco16.m_Num;			// poèet ikon v bufferu 16*16
		m_Head->piPic16.delka = m_BufIco16.m_Height
			* ((m_BufIco16.m_Width*m_BufIco16.m_Num+3) & ~0x3); //`velikost dat ikon 16*16
		m_Head->piPic32.pocet = m_BufIco32.m_Num;			// poèet ikon v bufferu 32*32
		m_Head->piPic32.delka = m_BufIco32.m_Height
			* ((m_BufIco32.m_Width*m_BufIco32.m_Num+3) & ~0x3); //`velikost dat ikon 32*32

// zápis záhlaví souboru
		SaveWriteFile(m_Head, sizeof(SaveHead));

// zápis bufferù programu
		SaveWriteFile(m_bufImport, m_sizeImport);
		SaveWriteFile(m_bufClass,  sizeof(PETPROG)*m_numClass);
		SaveWriteFile(m_bufObject, sizeof(PETPROG)*m_numObject);
		SaveWriteFile(m_bufLocal,  sizeof(PETPROG)*m_numLocal);
		SaveWriteFile(m_bufEdit,   sizeof(PETPROG)*m_numEdit);
		SaveWriteFile(m_bufText, m_sizeText);
		SaveWriteFile(&(StdBitmapInfo->bmiColors[0]), StdColors*sizeof(RGBQUAD));
		SaveWriteFile(m_BufIco16.m_Data, m_Head->piPic16.delka);
		SaveWriteFile(m_BufIco32.m_Data, m_Head->piPic32.delka);

// uzavøení souboru
		::CloseHandle(m_File);
	}

// zrušení pracovních bufferù
	delete m_bufEdit;
	delete m_bufLocal;
	delete m_bufObject;
	delete m_bufClass;
	free(m_bufText);
	free(m_bufImport);
	delete m_tabImport;
	delete m_Head;

// pøíznak ukonèení operace
	m_Saving = FALSE;				// pøíznak konce operace
}

/////////////////////////////////////////////////////////////////////////////
// zápis dat do výstupního souboru

void CProg::SaveWriteFile(LPCVOID buf, DWORD bytes)
{
	m_Writen = 0;
	if (m_OK) 
		m_OK = ::WriteFile(m_File, buf, bytes,  &m_Writen, NULL);
	if (m_Writen != bytes)
		m_OK = FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// vygenerování tabulky programu

void CProg::SavePrg(PETPROG* buf, int buffID)
{
// pøíprava pomocných èítaèù
	int		i,j,len;				// pracovní èítaèe
	CString	txt;					// buffer textu
	char*	tb;						// meziúschova ukazatele pøi realokaci
	int num = m_Buf[buffID].m_Num;	// poèet prvkù ke konverzi

// byla již chyba - pøerušení
	if (!m_OK) return;

// pøíprava ukazate¾ù bufferù
	PETPROG* dst = buf;				// výstupní buffer
	PROGITEM* src = m_Buf[buffID].m_Items; // vstupní buffer

// konverze bufferù
	for (i = 0; i < num; i++)
	{

// pøíprava parametrù prvku
		dst->param = 0;
		if (src->items > 1) dst->param |= PETPROG_CHILDS;
		if ((src->param & PR_EXP) != 0) dst->param |= PETPROG_EXP;
		if ((src->param & PR_BOLD) != 0) dst->param |= PETPROG_BOLD;
		if ((src->param & PR_GRAY) != 0) dst->param |= PETPROG_GRAY;
		if ((src->param & PR_LOCK) != 0) dst->param |= PETPROG_LOCK;

// test, zda bude další prvek stejné úrovnì
		j = i + src->items;
		if (j < num)
			if (src->parent == m_Buf[buffID].m_Items[j].parent)
				dst->param |= PETPROG_NEXT;

// deklarace prvku
		dst->typ = src->typ;				// blok s deklarací prvku
		dst->refer = src->refer;			// index s deklarací prvku

// pøi odkazu na buffer struktur zmìna na interní prvek
		if (dst->typ == BufStrID)
		{
			dst->typ = m_BufStr.m_Items[dst->refer].typ;
			dst->refer = m_BufStr.m_Items[dst->refer].refer;
		}

// pøi odkazu na interní prvek doplnìní textu importu prvku
		if ((dst->typ == BufIntID) && (dst->refer >= 0))
		{
			if (m_tabImport[dst->refer] == -1)				// funkce není ještì definovaná
			{
				len = strlen(importName[dst->refer]) + 1;	// délka textu jména funkce + 1
				tb = m_bufImport;							// úschova adresy bufferu
				if (m_sizeImport + len > m_maxImport)		// je buffer dost veliký ?
				{
					tb = (char*) realloc(m_bufImport, m_sizeImport + len + 1024); // realokace bufferu
					if (tb != NULL)
					{
						m_bufImport = tb;					// úschova nové adresy
						m_maxImport = m_sizeImport + len + 1024;	// nová velikost bufferu
					}
					else
						m_OK = FALSE;						// jinak pøíznak chyby
				}
				if (tb != NULL)
				{
					memcpy(&m_bufImport[m_sizeImport], importName[dst->refer], len); // kopie textu
					m_tabImport[dst->refer] = m_numImport;	// úschova èísla textu
					m_sizeImport += len;					// zvýšení èítaèe délky dat
					m_numImport++;							// zvýšení èítaèe øetìzcù
				}
			}
			dst->refer = m_tabImport[dst->refer];			// konverze reference na importovanou funkci
		}

// pøi odkazu na text doplnìní textu do bufferu textu
		dst->name = src->name;								// text jména
		if (dst->name != -1)								// je platný text jména ?
		{
			txt = m_Buf[buffID].m_Text->Get(dst->name);		// naètení textu prvku
			len = txt.GetLength() + 1;						// délka textu jména funkce + 1
			tb = m_bufText;									// úschova adresy bufferu
			if (m_sizeText + len > m_maxText)				// je buffer dost veliký ?
			{
					tb = (char*) realloc(m_bufText, m_sizeText + len + 1024); // realokace bufferu
					if (tb != NULL)
					{
						m_bufText = tb;						// úschova nové adresy
						m_maxText = m_sizeText + len + 1024;	// nová velikost bufferu
					}
					else
						m_OK = FALSE;						// jinak pøíznak chyby
			}
			if (tb != NULL)
			{
				memcpy(&m_bufText[m_sizeText], txt.GetBuffer(1), len); // kopie textu
				m_sizeText += len;						// zvýšení èítaèe délky dat
				dst->name = m_numText;					// èíslo textu
				m_numText++;							// zvýšení èítaèe øetìzcù
			}
		}

// ostatní ukazatele prvku
		dst->index = src->index;			// index s daty prvku
		dst->icon = src->icon;				// ikona

// zvýšení ukazatelù v bufferech
		dst++;
		src++;
	}
}

/////////////////////////////////////////////////////////////////////////////
// naètení programu

void CProg::OnFileLoad()
{
	int i;
	m_tabImport = NULL;				// buffer konverzní tabulky importu
	m_bufImport = NULL;				// buffer importovaných funkcí neplatný
	m_bufText = NULL;				// buffer textù
	m_Head = NULL;					// buffer záhlaví
	m_bufEdit = NULL;				// buffer editace
	m_bufObject = NULL;				// buffer globálních objektù
	m_bufLocal = NULL;				// buffer lokálních objektù
	m_bufClass = NULL;				// buffer tøíd
	m_typImport = NULL;				// konverzní tabulka typù importu
	m_refImport = NULL;				// konverzní tabulka referencí importu
	m_numImport	= 0;				// poèet prvkù importovaných funkcí
	m_sizeImport = 0;				// velikost dat v bufferu importovaných funkcí

	m_OK = TRUE;

// otevøení vstupního souboru
	m_FileName = Jmeno + ".PET";	// jméno výstupního souboru
	m_File = INVALID_HANDLE_VALUE;
	if (m_OK) m_File = ::CreateFile(m_FileName, GENERIC_READ, 0, NULL, 
				OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (m_File == INVALID_HANDLE_VALUE)
		m_OK = FALSE;

// pokraèování, pokud byl soubor otevøen OK
	if (m_OK)
	{
// pøíprava konverzní tabulky importù
		FileLoadTab();			// pøíprava tabulek

// naètení záhlaví souboru
		FileLoadHead();			// naètení záhlaví souboru

// naètení textù
		FileLoadText();			// naètení textù

// naètení ikon
		FileLoadPic();			// naètení obrázkù

// naètení importovaných funkcí
		FileLoadImport();		// naètení importovaných funkcí

// naètení programových bufferù (zachovat poøadí !)
		FileLoadProg("CLASS   ", m_bufClass, m_numClass, &m_BufCls); 

// vygenerování bufferu tøíd
		for (i = 0; i < m_BufCls.m_Num; i++)
		{
			if (m_BufCls.m_Items[i].typ == BufIntID)
			{
				m_typImport[m_BufCls.m_Items[i].refer] = BufClsID;
				m_refImport[m_BufCls.m_Items[i].refer] = i;
			}
		}

		FileLoadProg("GLOBAL  ", m_bufObject, m_numObject, &m_BufObj);
		FileLoadProg("LOCAL   ", m_bufLocal, m_numLocal, &m_BufLoc);
		FileLoadProg("PROGRAM ", m_bufEdit, m_numEdit, &m_BufEdi);

// uzavøení souboru
		::CloseHandle(m_File);
	}

// zrušení pracovních bufferù
	if (m_bufEdit != NULL) delete m_bufEdit;
	if (m_bufLocal != NULL) delete m_bufLocal;
	if (m_bufObject != NULL) delete m_bufObject;
	if (m_bufClass != NULL) delete m_bufClass;
	if (m_Head != NULL)	free(m_Head);
	if (m_bufImport != NULL) delete m_bufImport;
	if (m_tabImport != NULL) delete m_tabImport;
	if (m_bufText != NULL) delete m_bufText;
	if (m_typImport != NULL) delete m_typImport;
	if (m_refImport != NULL) delete m_refImport;
}

/////////////////////////////////////////////////////////////////////////////
// naètení dat ze vstupního souboru

void CProg::LoadReadFile(LPVOID buf, DWORD bytes)
{
	m_Writen = 0;
	if (m_OK) 
		m_OK = ::ReadFile(m_File, buf, bytes,  &m_Writen, NULL);
	if (m_Writen != bytes)
		m_OK = FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// nalezení indexu v záhlaví souboru (jméno má 8 znakù !!!)

int CProg::LoadSrcIndex(LPCTSTR jm, int beg)
{
#ifdef _DEBUG
	ASSERT(strlen(jm) == 8);
#endif

// pøi chybì operace neplatná data
	if (!m_OK) return -1;

// inicializace ukazatelù
	int ret = -1;							// pøednastavení výsledku operace
	long int off = m_Head->data;			// zaèátek dat v souboru

// prohledání tabulky indexù
	for (int i = 0; i < m_Head->pocet; i++)
	{

// je to minimální položka ?
		if (i >= beg)
		{

// porovnání jména bloku
			if (memcmp(jm, &(m_Head->pi[i].jmeno[0]), 8) == 0)
			{

// nastavení ukazatele v souboru na blok
				ret = i;					// úschova indexu
				::SetFilePointer(m_File, off, NULL, FILE_BEGIN); // nastavení ukazatele v souboru
				break;						// konec cyklu
			}
		}

// zvýšení ukazatele dat v souboru
		off += m_Head->pi[i].delka;			// zvýšení ukazatele offsetu dat
	}
	return ret;
}

/////////////////////////////////////////////////////////////////////////////
// naètení záhlaví souboru

void CProg::FileLoadHead()
{
	PETHEAD* pt;				// pøechodný ukazatel na buffer

// pøerušení, je-li již chyba
	if (!m_OK) return;

// buffer pro minimální záhlaví
	m_Head = (PETHEAD*)malloc(SIZEOFPETHEAD);
	if (m_Head == NULL)
	{
		m_OK = FALSE;
		return;
	}

// naètení minimálního záhlaví
	LoadReadFile(m_Head, SIZEOFPETHEAD);

// kontrola záhlaví
	if ((m_Head->data != (signed)(m_Head->pocet*sizeof(PETINDEX) + SIZEOFPETHEAD)) ||
				(m_Head->pocet <= 0) || !m_OK)
	{
		m_OK = FALSE;
		return;
	}

// zvìtšení bufferu pro záhlaví
	pt = (PETHEAD*)realloc(m_Head, m_Head->data);
	if (pt == NULL)
	{
		m_OK = FALSE;
		return;
	}
	m_Head = pt;

// naètení zbytku záhlaví
	LoadReadFile(&(m_Head->pi[0]), m_Head->data - SIZEOFPETHEAD);		
}

/////////////////////////////////////////////////////////////////////////////
// naètení importovaných funkcí

void CProg::FileLoadImport()
{
	int inx;								// index bufferu dat
	int	i;									// pomocný èítaè
	int inximp;								// index importované funkce
	char* src;								// ukazatel v bufferu textu
	int len;								// délka vyhledávaného textu + 1

// pøerušení, je-li již chyba
	if (!m_OK) return;

// nalezení bufferu dat importu
	inx = LoadSrcIndex("IMPORT  ", 0);		// nalezení indexu
	if (inx < 0)
	{
		m_OK = FALSE;
		return;
	}

// pøíprava ukazatelù
	m_numImport = m_Head->pi[inx].pocet;	// poèet prvkù v tabulce importu
	m_sizeImport = m_Head->pi[inx].delka;	// délka dat bufferu

// vytvoøení bufferù
	m_tabImport = new int[m_numImport];		// konverzní tabulka importovaných funkcí
	m_bufImport = new char[m_sizeImport+20]; // vytvoøení bufferu
	if ((m_tabImport == NULL) || (m_bufImport == NULL))
	{
		m_OK = FALSE;
		return;
	}

// vymazání konverzní tabulky importovaných funkcí
	for (i = 0; i < m_numImport; i++) m_tabImport[i] = FncNone;

// naètení dat importu
	LoadReadFile(m_bufImport, m_sizeImport);
	if (!m_OK) return;

// vyhledání funkcí
	src = m_bufImport;			// ukazatel textu v bufferu
	for (inximp = 0; inximp < m_numImport; inximp++)
	{

// zjištìní délky vyhledávaného øetìzce
		len = strlen(src) + 1;	// délka øetìzce k vyhledání

// vyhledání textu v tabulce
		for (i = 0; i < INTERNALNUM; i++)
		{
			if (memcmp(src, importName[i], len) == 0)
			{
				m_tabImport[inximp] = i;		// èíslo funkce
				break;
			}
		}

// posun ukazatele na další øetìzec
		src += len;				// posun ukazatele dat
	}
}

/////////////////////////////////////////////////////////////////////////////
// naètení textù

void CProg::FileLoadText()
{
	int inx;								// index bufferu dat
 	int inxtxt;								// index textu
	char* src;								// ukazatel v bufferu textu
	CString txt;							// buffer textu

// pøerušení, je-li již chyba
	if (!m_OK) return;

// nalezení bufferu dat textù
	inx = LoadSrcIndex("TEXT    ", 0);		// nalezení indexu
	if (inx < 0)
	{
		m_OK = FALSE;
		return;
	}

// pøíprava ukazatelù
	m_numText = m_Head->pi[inx].pocet;	// poèet prvkù v tabulce textù
	m_sizeText = m_Head->pi[inx].delka;	// délka dat bufferu

// vytvoøení bufferu
	m_bufText = new char[m_sizeText+20]; // vytvoøení bufferu
	if (m_bufText == NULL)
	{
		m_OK = FALSE;
		return;
	}

// naètení dat textù
	LoadReadFile(m_bufText, m_sizeText);
	if (!m_OK) return;

// naètení textù
	if (m_numText > 0) m_Text.RemoveAll();	// vymazání všech starých textù
	src = m_bufText;			// ukazatel textu v bufferu
	for (inxtxt = 0; inxtxt < m_numText; inxtxt++)
	{
		txt = src;				// naètení textu
		m_Text.Add(txt);		// doplnìní textu
		src += txt.GetLength()+1; // zvýšení ukazatele textu
	}
}


/////////////////////////////////////////////////////////////////////////////
// naètení obrázkù

void CProg::FileLoadPic()
{


}

/////////////////////////////////////////////////////////////////////////////
// pøíprava konverzních tabulek pro konverzi importu

void CProg::FileLoadTab()
{
	int i;

// vytvoøení bufferù
	m_typImport = new signed short int[INTERNALNUM];
	m_refImport = new signed short int[INTERNALNUM];
	if ((m_typImport == NULL) || (m_refImport == NULL))
	{
		m_OK = FALSE;
		return;
	}

// vymazání bufferù
	for (i = 0; i < INTERNALNUM; i++)
	{
		m_typImport[i] = BufIntID;
		m_refImport[i] = i;
	}

// vygenerování bufferu pro struktury
	for (i = 0; i < m_BufStr.m_Num; i++)
	{
		if (m_BufStr.m_Items[i].typ == BufIntID)
		{
			m_typImport[m_BufStr.m_Items[i].refer] = BufStrID;
			m_refImport[m_BufStr.m_Items[i].refer] = i;
		}

	}

}
 
/////////////////////////////////////////////////////////////////////////////
// naètení programu

void CProg::FileLoadProg(LPCTSTR jm, PETPROG*& pbuf, int& pnum, CProgBuf* buf)
{
	int inx;						// index bufferu dat
	PROGITEM* pi;					// pomocný buffer programu
	PETPROG* src;					// vstupní buffer
	PROGITEM* dst;					// výstupní buffer
	int*	par;					// buffer odkazù na rodièe (-1 = není)
	BOOL*	nxt;					// buffer pøíznakù dalších prvkù
	int		parnum;					// poèet odkazù na rodièe
	int		parmax;					// velikost bufferu odkazù

// pøerušení, je-li již chyba
	if (!m_OK) return;

// nalezení bufferu programu
	inx = LoadSrcIndex(jm, 0);		// nalezení indexu
	if (inx < 0)
	{
		m_OK = FALSE;
		return;
	}

// pøíprava ukazatelù, kontrola velikosti bufferu
	pnum = m_Head->pi[inx].pocet;	// poèet prvkù v tabulce textù
	if ((signed)(pnum * sizeof(PETPROG)) != m_Head->pi[inx].delka)
	{
		m_OK = FALSE;
		return;
	}

// vytvoøení bufferu
	pbuf = new PETPROG[pnum]; // vytvoøení bufferu
	if (pbuf == NULL)
	{
		m_OK = FALSE;
		return;
	}

// naètení dat bufferu
	LoadReadFile(pbuf, m_Head->pi[inx].delka);
	if (!m_OK) return;

// vytvoøení bufferu programu
	pi = (PROGITEM*)realloc(buf->m_Items, sizeof(PROGITEM) * pnum);
	if (pi == NULL)
	{
		m_OK = FALSE;
		return;
	}
	buf->m_Items = pi;
	buf->m_Num = pnum;
	buf->m_Max = pnum;
	buf->m_First = 0;
	buf->m_Next = pnum;

// buffer odkazù na rodièe
	par = (int*)malloc(1000 * sizeof(int));
	nxt = (BOOL*)malloc(1000 * sizeof(BOOL));
	parnum = 0;
	par[0] = -1;
	parmax = 1000;
	nxt[0] = TRUE;

// konverze bufferù
	src = pbuf;
	dst = pi;
	for (int i = 0; i < pnum; i++)
	{

// pøíprava parametrù prvku
		dst->param = 0;
		if (src->param & PETPROG_EXP) dst->param |= PR_EXP;
		if (src->param & PETPROG_BOLD) dst->param |= PR_BOLD;
		if (src->param & PETPROG_GRAY) dst->param |= PR_GRAY;
		if (src->param & PETPROG_LOCK) dst->param |= PR_LOCK;

// rodiè prvku
		dst->parent = par[parnum];				// rodiè prvku
		if (dst->parent != -1)
			pi[dst->parent].childs++;

// èítaèe prvkù
		for (int j = parnum; j >= 0; j--)
			if (par[j] != -1)
				pi[par[j]].items++;

// ukonèení hladiny, není-li další stejný prvek
		if (!(src->param & PETPROG_NEXT))		// bude další prvek ?
			nxt[parnum] = FALSE;				// pøíznak, že nebude další prvek
		else
			nxt[parnum] = TRUE;					// bude další prvek

// zvýšení nebo snížení hladiny, jsou-li potomci
		if (src->param & PETPROG_CHILDS)		// budou potomci ?
		{
			parnum++;							// zvýšení èítaèe prvkù
			if (parnum >= parmax)
			{
				par = (int*)realloc(par, (parmax + 1000) * sizeof(int));
				nxt = (BOOL*)realloc(nxt, (parmax + 1000) * sizeof(BOOL));
				parmax += 1000;
			}
			par[parnum] = i;					// èíslo aktuálního prvku = rodiè
			nxt[parnum] = TRUE;					// pøíznak, že mùže být další prvek
		}
		else
		{
			while ((nxt[parnum] == FALSE) && (parnum > 0))
				parnum--;
		}

// deklarace prvku
		dst->typ = src->typ;				// blok s deklarací prvku
		dst->refer = src->refer;			// index s deklarací prvku

// pøi odkazu na interní prvek importování odkazu
		if (dst->typ == BufIntID)
		{
			if ((dst->refer >= 0) && (dst->refer < m_numImport))
				dst->refer = m_tabImport[dst->refer];
		}

// omezení hodnot typu a indexu
		if ((dst->typ < 0) || (dst->typ >= PROGBUFNUM))
		{
			dst->typ = -1;
			dst->refer = -1;
		}
		else
			if ((dst->refer < 0) || (dst->refer >= m_Buf[dst->typ].m_Num))
			{
				dst->typ = -1;
				dst->refer = -1;
			}

// pøi odkazu na interní prvek zmìna na buffer struktur
		if (dst->typ == BufIntID)
		{
			dst->typ = m_typImport[dst->refer];
			dst->refer = m_refImport[dst->refer];
		}

// ostatní ukazatele prvku
		dst->index = src->index;			// index s daty prvku
		dst->icon = src->icon;				// ikona
		dst->name = src->name;				// text jména
		if ((dst->name < 0) || (dst->name >= m_Text.GetSize()))
			dst->name = -1;
		dst->model = TYP_NONE;
		dst->htree = NULL;
		dst->counter = 0;					// èítaè odkazù na prvek
		dst->childs = 0;					// poèet pøímých potomkù
		dst->items = 1;						// poèet prvkù

// zdìdìné parametry, èítaè odkazù
		if (dst->typ != -1)
		{
			dst->model = m_Buf[dst->typ].m_Items[dst->refer].model;
			m_Buf[dst->typ].m_Items[dst->refer].counter++;
			dst->param |= (m_Buf[dst->typ].m_Items[dst->refer].param) & 
				~(PR_EXP | PR_BOLD | PR_GRAY | PR_LOCK | PR_INTERNAL);
		}

// pøíznak interního prvku
		if ((dst->typ == BufIntID) && (dst->model != TYP_NONE))
			dst->param |= PR_INTERNAL;

// zvýšení ukazatelù v bufferech
		dst++;
		src++;
	}

// zrušení bufferu odkazù na rodièe
	free(par);
	free(nxt);
}

