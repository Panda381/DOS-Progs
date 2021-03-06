

/////////////////////////////////////////////////////////////////////////////
//																		   //
//					obsluha ukl�d�n� a na��t�n� programu				   //
//																		   //
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// jm�na funkc� p�i importu z na��tan�ho souboru

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
	"pet2_slow",		// IDI_PETRA_POMALU // zru�eno !!!!!!!!
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
	"key_shft",			// IDI_KLAV_SHIFT 	// zru�eno
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


/////////////////////////////////////////////////////////////////////////////
// z�hlav� pro ulo�en� (po�et polo�ek NUMOFINDEX)

const PETHEAD SaveHead = {
	'P','E','T',									// identifikace
	1,												// verze
	0,												// parametry
	3 + 1 + 4 + 4 + 4 + NUMOFINDEX * sizeof(PETINDEX),	// offset za��tku dat
	NUMOFINDEX,											// po�et datov�ch blok�
	0,0,'I','M','P','O','R','T',' ',' ',0,0,0,0,	// blok IMPORT
	0,0,'C','L','A','S','S',' ',' ',' ',0,0,0,0,	// blok CLASS
	0,0,'G','L','O','B','A','L',' ',' ',0,0,0,0,	// blok GLOBAL
	0,0,'L','O','C','A','L',' ',' ',' ',0,0,0,0,	// blok LOCAL
	0,0,'P','R','O','G','R','A','M',' ',0,0,0,0,	// blok PROGRAM
	0,0,'S','T','R','U','C',' ',' ',' ',0,0,0,0,	// blok STRUC
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
// ulo�en� souboru

void CProg::OnFileSave() 
{
	int			i;					// pracovn� ��ta�e

// kontrola, zda ji� operace neprob�h�
	if (m_Saving) return;			// prob�h� ji� ukl�d�n�/na��t�n� - konec
	m_Saving = TRUE;				// p��znak prob�haj�c� operace

// p��prava z�hlav� souboru
	m_Head = new PETHEAD;			// vytvo�en� bufferu z�hlav� souboru
	if (m_Head != NULL) *m_Head = SaveHead;	// p��prava z�hlav� souboru

// p��prava bufferu text� importovan�ch funkc�
	m_tabImport = new int[INTERNALNUM]; // konverzn� tabulka importovan�ch funkc�
	m_bufImport	= (char*) malloc(1024); // buffer text� importovan�ch funkc�
	m_maxImport = 1024;				// velikost bufferu importovan�ch funkc�
	m_numImport	= 0;				// po�et prvk� importovan�ch funkc�
	m_sizeImport = 0;				// velikost dat v bufferu importovan�ch funkc�

// vymaz�n� konverzn� tabulky importovan�ch funkc�
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

// p��prava bufferu text�
	m_bufText	= (char*) malloc(1024); // buffer text�
	m_maxText	= 1024;				// velikost bufferu text�
	m_numText	= 0;				// po�et prvk� text�
	m_sizeText	= 0;				// velikost dat v bufferu text�

// vytvo�en� pracovn�ch buffer�
	m_numClass	= m_BufCls.m_Num;	// po�et prvk� t��d
	m_bufClass	= new PETPROG[m_numClass];
	m_numObject	= m_BufObj.m_Num;	// po�et prvk� glob�ln�ch objekt�
	m_bufObject	= new PETPROG[m_numObject];
	m_numLocal	= m_BufLoc.m_Num;	// po�et prvk� lok�ln�ch objekt�
	m_bufLocal	= new PETPROG[m_numLocal];
	m_numEdit	= m_BufEdi.m_Num;	// po�et prvk� editoru
	m_bufEdit	= new PETPROG[m_numEdit];

// kontrola, zda jsou buffery vytvo�eny OK
	if (m_Head == NULL || m_tabImport == NULL || m_bufImport == NULL || m_bufText == NULL ||
		m_bufClass == NULL || m_bufObject == NULL || m_bufLocal == NULL || m_bufEdit == NULL) 
		m_OK = FALSE;
	else
		m_OK = TRUE;

// vytvo�en� v�stupn�ho souboru
	m_FileName = Jmeno + ".PET";	// jm�no v�stupn�ho souboru
	m_File = INVALID_HANDLE_VALUE;
	if (m_OK) m_File = ::CreateFile(m_FileName, GENERIC_WRITE, 0, NULL, 
				CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (m_File == INVALID_HANDLE_VALUE)
		m_OK = FALSE;

// pokra�ov�n�, pokud byl soubor vytvo�en OK
	if (m_OK)
	{

// vygenerov�n� prvk� buffer�
		SavePrg(m_bufClass,  BufClsID);
		SavePrg(m_bufObject, BufObjID);
		SavePrg(m_bufLocal,  BufLocID);
		SavePrg(m_bufEdit,   BufEdiID);

// p��prava z�hlav� souboru
		m_Head->piImport.pocet = m_numImport;				// po�et intern�ch prvk�
		m_Head->piImport.delka = m_sizeImport;				// velikost tabulky jmen prvk�
		m_Head->piClass.pocet = m_numClass;					// po�et prvk� okna t��d
		m_Head->piClass.delka = sizeof(PETPROG)*m_numClass;	// velikost tabulky
		m_Head->piGlobal.pocet = m_numObject;				// po�et prvk� okna glob�ln�ch objekt�
		m_Head->piGlobal.delka = sizeof(PETPROG)*m_numObject;// velikost tabulky
		m_Head->piLocal.pocet = m_numLocal;					// po�et prvk� okna lok�ln�ch objekt�
		m_Head->piLocal.delka = sizeof(PETPROG)*m_numLocal;	// velikost tabulky
		m_Head->piProgram.pocet = m_numEdit;					// po�et prvk� okna editoru
		m_Head->piProgram.delka = sizeof(PETPROG)*m_numEdit; // velikost tabulky
		m_Head->piText.pocet = m_numText;					// po�et prvk� text�
		m_Head->piText.delka = m_sizeText;					// velikost prvk� text�
		m_Head->piPalette.pocet = StdColors;					// po�et palet
		m_Head->piPalette.delka = StdColors * sizeof(RGBQUAD); // velikost dat
		m_Head->piPic16.pocet = m_BufIco16.m_Num;			// po�et ikon v bufferu 16*16
		m_Head->piPic16.delka = m_BufIco16.m_Height
			* ((m_BufIco16.m_Width*m_BufIco16.m_Num+3) & ~0x3); //`velikost dat ikon 16*16
		m_Head->piPic32.pocet = m_BufIco32.m_Num;			// po�et ikon v bufferu 32*32
		m_Head->piPic32.delka = m_BufIco32.m_Height
			* ((m_BufIco32.m_Width*m_BufIco32.m_Num+3) & ~0x3); //`velikost dat ikon 32*32

// z�pis z�hlav� souboru
		SaveWriteFile(m_Head, sizeof(SaveHead));

// z�pis buffer� programu
		SaveWriteFile(m_bufImport, m_sizeImport);
		SaveWriteFile(m_bufClass,  sizeof(PETPROG)*m_numClass);
		SaveWriteFile(m_bufObject, sizeof(PETPROG)*m_numObject);
		SaveWriteFile(m_bufLocal,  sizeof(PETPROG)*m_numLocal);
		SaveWriteFile(m_bufEdit,   sizeof(PETPROG)*m_numEdit);
		SaveWriteFile(m_bufText, m_sizeText);
		SaveWriteFile(&(StdBitmapInfo->bmiColors[0]), StdColors*sizeof(RGBQUAD));
		SaveWriteFile(m_BufIco16.m_Data, m_Head->piPic16.delka);
		SaveWriteFile(m_BufIco32.m_Data, m_Head->piPic32.delka);

// uzav�en� souboru
		::CloseHandle(m_File);
	}

// zru�en� pracovn�ch buffer�
	delete m_bufEdit;
	delete m_bufLocal;
	delete m_bufObject;
	delete m_bufClass;
	free(m_bufText);
	free(m_bufImport);
	delete m_tabImport;
	delete m_Head;

// p��znak ukon�en� operace
	m_Saving = FALSE;				// p��znak konce operace
}


/////////////////////////////////////////////////////////////////////////////
// z�pis dat do v�stupn�ho souboru

void CProg::SaveWriteFile(LPCVOID buf, DWORD bytes)
{
	m_Writen = 0;
	if (m_OK) 
		m_OK = ::WriteFile(m_File, buf, bytes,  &m_Writen, NULL);
	if (m_Writen != bytes)
		m_OK = FALSE;
}


/////////////////////////////////////////////////////////////////////////////
// vygenerov�n� tabulky programu

void CProg::SavePrg(PETPROG* buf, int buffID)
{
// p��prava pomocn�ch ��ta��
	int		i,j,len;				// pracovn� ��ta�e
	CString	txt;					// buffer textu
	char*	tb;						// mezi�schova ukazatele p�i realokaci
	int num = m_Buf[buffID].m_Num;	// po�et prvk� ke konverzi

// byla ji� chyba - p�eru�en�
	if (!m_OK) return;

// p��prava ukazate�� buffer�
	PETPROG* dst = buf;				// v�stupn� buffer
	PROGITEM* src = m_Buf[buffID].m_Items; // vstupn� buffer

// konverze buffer�
	for (i = 0; i < num; i++)
	{

// p��prava parametr� prvku
		dst->param = 0;
		if (src->items > 1) dst->param |= PETPROG_CHILDS;
		if ((src->param & PR_EXP) != 0) dst->param |= PETPROG_EXP;
		if ((src->param & PR_LOCK) != 0) dst->param |= PETPROG_LOCK;
		if ((src->param & PR_OFF) != 0) dst->param |= PETPROG_OFF;

// test, zda bude dal�� prvek stejn� �rovn�
		j = i + src->items;
		if (j < num)
			if (src->parent == m_Buf[buffID].m_Items[j].parent)
				dst->param |= PETPROG_NEXT;

// deklarace prvku
		dst->typ = src->typ;				// blok s deklarac� prvku
		dst->refer = src->refer;			// index s deklarac� prvku

// p�i odkazu na buffer struktur zm�na na intern� prvek
		if (dst->typ == BufStrID)
		{
			dst->typ = m_BufStr.m_Items[dst->refer].typ;
			dst->refer = m_BufStr.m_Items[dst->refer].refer;
		}

// p�i odkazu na intern� prvek dopln�n� textu importu prvku
		if ((dst->typ == BufIntID) && (dst->refer >= 0))
		{
			if (m_tabImport[dst->refer] == -1)				// funkce nen� je�t� definovan�
			{
				len = strlen(importName[dst->refer]) + 1;	// d�lka textu jm�na funkce + 1
				tb = m_bufImport;							// �schova adresy bufferu
				if (m_sizeImport + len > m_maxImport)		// je buffer dost velik� ?
				{
					tb = (char*) realloc(m_bufImport, m_sizeImport + len + 1024); // realokace bufferu
					if (tb != NULL)
					{
						m_bufImport = tb;					// �schova nov� adresy
						m_maxImport = m_sizeImport + len + 1024;	// nov� velikost bufferu
					}
					else
						m_OK = FALSE;						// jinak p��znak chyby
				}
				if (tb != NULL)
				{
					memcpy(&m_bufImport[m_sizeImport], importName[dst->refer], len); // kopie textu
					m_tabImport[dst->refer] = m_numImport;	// �schova ��sla textu
					m_sizeImport += len;					// zv��en� ��ta�e d�lky dat
					m_numImport++;							// zv��en� ��ta�e �et�zc�
				}
			}
			dst->refer = m_tabImport[dst->refer];			// konverze reference na importovanou funkci
		}

// p�i odkazu na text dopln�n� textu do bufferu textu
		dst->name = src->name;								// text jm�na
		if (dst->name != -1)								// je platn� text jm�na ?
		{
			txt = m_Buf[buffID].m_Text->Get(dst->name);		// na�ten� textu prvku
			len = txt.GetLength() + 1;						// d�lka textu jm�na funkce + 1
			tb = m_bufText;									// �schova adresy bufferu
			if (m_sizeText + len > m_maxText)				// je buffer dost velik� ?
			{
					tb = (char*) realloc(m_bufText, m_sizeText + len + 1024); // realokace bufferu
					if (tb != NULL)
					{
						m_bufText = tb;						// �schova nov� adresy
						m_maxText = m_sizeText + len + 1024;	// nov� velikost bufferu
					}
					else
						m_OK = FALSE;						// jinak p��znak chyby
			}
			if (tb != NULL)
			{
				memcpy(&m_bufText[m_sizeText], txt.GetBuffer(1), len); // kopie textu
				m_sizeText += len;						// zv��en� ��ta�e d�lky dat
				dst->name = m_numText;					// ��slo textu
				m_numText++;							// zv��en� ��ta�e �et�zc�
			}
		}

// ostatn� ukazatele prvku
		dst->index = src->index;			// index s daty prvku
		dst->data = src->data;				// blok s daty prvku
		dst->icon = src->icon;				// ikona

// zv��en� ukazatel� v bufferech
		dst++;
		src++;
	}
}


/////////////////////////////////////////////////////////////////////////////
// na�ten� programu

void CProg::OnFileLoad()
{
	int i;
	m_tabImport = NULL;				// buffer konverzn� tabulky importu
	m_bufImport = NULL;				// buffer importovan�ch funkc� neplatn�
	m_bufText = NULL;				// buffer text�
	m_Head = NULL;					// buffer z�hlav�
	m_bufEdit = NULL;				// buffer editace
	m_bufObject = NULL;				// buffer glob�ln�ch objekt�
	m_bufLocal = NULL;				// buffer lok�ln�ch objekt�
	m_bufClass = NULL;				// buffer t��d
	m_typImport = NULL;				// konverzn� tabulka typ� importu
	m_refImport = NULL;				// konverzn� tabulka referenc� importu
	m_numImport	= 0;				// po�et prvk� importovan�ch funkc�
	m_sizeImport = 0;				// velikost dat v bufferu importovan�ch funkc�

	m_OK = TRUE;

// otev�en� vstupn�ho souboru
	m_FileName = Jmeno + ".PET";	// jm�no v�stupn�ho souboru
	m_File = INVALID_HANDLE_VALUE;
	if (m_OK) m_File = ::CreateFile(m_FileName, GENERIC_READ, 0, NULL, 
				OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (m_File == INVALID_HANDLE_VALUE)
		m_OK = FALSE;

// pokra�ov�n�, pokud byl soubor otev�en OK
	if (m_OK)
	{
// p��prava konverzn� tabulky import�
		FileLoadTab();			// p��prava tabulek

// na�ten� z�hlav� souboru
		FileLoadHead();			// na�ten� z�hlav� souboru

// na�ten� text�
		FileLoadText();			// na�ten� text�

// na�ten� ikon
		FileLoadPic();			// na�ten� obr�zk�

// na�ten� importovan�ch funkc�
		FileLoadImport();		// na�ten� importovan�ch funkc�

// na�ten� programov�ch buffer� (zachovat po�ad� !)
		FileLoadProg("CLASS   ", m_bufClass, m_numClass, &m_BufCls); 

// vygenerov�n� bufferu t��d
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

// uzav�en� souboru
		::CloseHandle(m_File);
	}

// zru�en� pracovn�ch buffer�
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
// na�ten� dat ze vstupn�ho souboru

void CProg::LoadReadFile(LPVOID buf, DWORD bytes)
{
	m_Writen = 0;
	if (m_OK) 
		m_OK = ::ReadFile(m_File, buf, bytes,  &m_Writen, NULL);
	if (m_Writen != bytes)
		m_OK = FALSE;
}


/////////////////////////////////////////////////////////////////////////////
// nalezen� indexu v z�hlav� souboru (jm�no m� 8 znak� !!!)

int CProg::LoadSrcIndex(LPCTSTR jm, int beg)
{
#ifdef _DEBUG
	ASSERT(strlen(jm) == 8);
#endif

// p�i chyb� operace neplatn� data
	if (!m_OK) return -1;

// inicializace ukazatel�
	int ret = -1;							// p�ednastaven� v�sledku operace
	long int off = m_Head->data;			// za��tek dat v souboru

// prohled�n� tabulky index�
	for (int i = 0; i < m_Head->pocet; i++)
	{

// je to minim�ln� polo�ka ?
		if (i >= beg)
		{

// porovn�n� jm�na bloku
			if (memcmp(jm, &(m_Head->pi[i].jmeno[0]), 8) == 0)
			{

// nastaven� ukazatele v souboru na blok
				ret = i;					// �schova indexu
				::SetFilePointer(m_File, off, NULL, FILE_BEGIN); // nastaven� ukazatele v souboru
				break;						// konec cyklu
			}
		}

// zv��en� ukazatele dat v souboru
		off += m_Head->pi[i].delka;			// zv��en� ukazatele offsetu dat
	}
	return ret;
}


/////////////////////////////////////////////////////////////////////////////
// na�ten� z�hlav� souboru

void CProg::FileLoadHead()
{
	PETHEAD* pt;				// p�echodn� ukazatel na buffer

// p�eru�en�, je-li ji� chyba
	if (!m_OK) return;

// buffer pro minim�ln� z�hlav�
	m_Head = (PETHEAD*)malloc(SIZEOFPETHEAD);
	if (m_Head == NULL)
	{
		m_OK = FALSE;
		return;
	}

// na�ten� minim�ln�ho z�hlav�
	LoadReadFile(m_Head, SIZEOFPETHEAD);

// kontrola z�hlav�
	if ((m_Head->data != (signed)(m_Head->pocet*sizeof(PETINDEX) + SIZEOFPETHEAD)) ||
				(m_Head->pocet <= 0) || !m_OK)
	{
		m_OK = FALSE;
		return;
	}

// zv�t�en� bufferu pro z�hlav�
	pt = (PETHEAD*)realloc(m_Head, m_Head->data);
	if (pt == NULL)
	{
		m_OK = FALSE;
		return;
	}
	m_Head = pt;

// na�ten� zbytku z�hlav�
	LoadReadFile(&(m_Head->pi[0]), m_Head->data - SIZEOFPETHEAD);		
}


/////////////////////////////////////////////////////////////////////////////
// na�ten� importovan�ch funkc�

void CProg::FileLoadImport()
{
	int inx;								// index bufferu dat
	int	i;									// pomocn� ��ta�
	int inximp;								// index importovan� funkce
	char* src;								// ukazatel v bufferu textu
	int len;								// d�lka vyhled�van�ho textu + 1

// p�eru�en�, je-li ji� chyba
	if (!m_OK) return;

// nalezen� bufferu dat importu
	inx = LoadSrcIndex("IMPORT  ", 0);		// nalezen� indexu
	if (inx < 0)
	{
		m_OK = FALSE;
		return;
	}

// p��prava ukazatel�
	m_numImport = m_Head->pi[inx].pocet;	// po�et prvk� v tabulce importu
	m_sizeImport = m_Head->pi[inx].delka;	// d�lka dat bufferu

// vytvo�en� buffer�
	m_tabImport = new int[m_numImport];		// konverzn� tabulka importovan�ch funkc�
	m_bufImport = new char[m_sizeImport+20]; // vytvo�en� bufferu
	if ((m_tabImport == NULL) || (m_bufImport == NULL))
	{
		m_OK = FALSE;
		return;
	}

// vymaz�n� konverzn� tabulky importovan�ch funkc�
	for (i = 0; i < m_numImport; i++) m_tabImport[i] = FncNone;

// na�ten� dat importu
	LoadReadFile(m_bufImport, m_sizeImport);
	if (!m_OK) return;

// vyhled�n� funkc�
	src = m_bufImport;			// ukazatel textu v bufferu
	for (inximp = 0; inximp < m_numImport; inximp++)
	{

// zji�t�n� d�lky vyhled�van�ho �et�zce
		len = strlen(src) + 1;	// d�lka �et�zce k vyhled�n�

// vyhled�n� textu v tabulce
		for (i = 0; i < INTERNALNUM; i++)
		{
			if (memcmp(src, importName[i], len) == 0)
			{
				m_tabImport[inximp] = i;		// ��slo funkce
				break;
			}
		}

// posun ukazatele na dal�� �et�zec
		src += len;				// posun ukazatele dat
	}
}

/////////////////////////////////////////////////////////////////////////////
// na�ten� text�

void CProg::FileLoadText()
{
	int inx;								// index bufferu dat
 	int inxtxt;								// index textu
	char* src;								// ukazatel v bufferu textu
	CString txt;							// buffer textu

// p�eru�en�, je-li ji� chyba
	if (!m_OK) return;

// nalezen� bufferu dat text�
	inx = LoadSrcIndex("TEXT    ", 0);		// nalezen� indexu
	if (inx < 0)
	{
		m_OK = FALSE;
		return;
	}

// p��prava ukazatel�
	m_numText = m_Head->pi[inx].pocet;	// po�et prvk� v tabulce text�
	m_sizeText = m_Head->pi[inx].delka;	// d�lka dat bufferu

// vytvo�en� bufferu
	m_bufText = new char[m_sizeText+20]; // vytvo�en� bufferu
	if (m_bufText == NULL)
	{
		m_OK = FALSE;
		return;
	}

// na�ten� dat text�
	LoadReadFile(m_bufText, m_sizeText);
	if (!m_OK) return;

// na�ten� text�
	if (m_numText > 0) m_Text.RemoveAll();	// vymaz�n� v�ech star�ch text�
	src = m_bufText;			// ukazatel textu v bufferu
	for (inxtxt = 0; inxtxt < m_numText; inxtxt++)
	{
		txt = src;				// na�ten� textu
		m_Text.Add(txt);		// dopln�n� textu
		src += txt.GetLength()+1; // zv��en� ukazatele textu
	}
}


/////////////////////////////////////////////////////////////////////////////
// na�ten� obr�zk�

void CProg::FileLoadPic()
{


}

/////////////////////////////////////////////////////////////////////////////
// p��prava konverzn�ch tabulek pro konverzi importu

void CProg::FileLoadTab()
{
	int i;

// vytvo�en� buffer�
	m_typImport = new signed short int[INTERNALNUM];
	m_refImport = new signed short int[INTERNALNUM];
	if ((m_typImport == NULL) || (m_refImport == NULL))
	{
		m_OK = FALSE;
		return;
	}

// vymaz�n� buffer�
	for (i = 0; i < INTERNALNUM; i++)
	{
		m_typImport[i] = BufIntID;
		m_refImport[i] = i;
	}

// vygenerov�n� bufferu pro struktury
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
// na�ten� programu

void CProg::FileLoadProg(LPCTSTR jm, PETPROG*& pbuf, int& pnum, CProgBuf* buf)
{
	int inx;						// index bufferu dat
	PROGITEM* pi;					// pomocn� buffer programu
	PETPROG* src;					// vstupn� buffer
	PROGITEM* dst;					// v�stupn� buffer
	int*	par;					// buffer odkaz� na rodi�e (-1 = nen�)
	BOOL*	nxt;					// buffer p��znak� dal��ch prvk�
	int		parnum;					// po�et odkaz� na rodi�e
	int		parmax;					// velikost bufferu odkaz�

// p�eru�en�, je-li ji� chyba
	if (!m_OK) return;

// nalezen� bufferu programu
	inx = LoadSrcIndex(jm, 0);		// nalezen� indexu
	if (inx < 0)
	{
		m_OK = FALSE;
		return;
	}

// p��prava ukazatel�, kontrola velikosti bufferu
	pnum = m_Head->pi[inx].pocet;	// po�et prvk� v tabulce text�
	if ((signed)(pnum * sizeof(PETPROG)) != m_Head->pi[inx].delka)
	{
		m_OK = FALSE;
		return;
	}

// vytvo�en� bufferu
	pbuf = new PETPROG[pnum]; // vytvo�en� bufferu
	if (pbuf == NULL)
	{
		m_OK = FALSE;
		return;
	}

// na�ten� dat bufferu
	LoadReadFile(pbuf, m_Head->pi[inx].delka);
	if (!m_OK) return;

// vytvo�en� bufferu programu
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

// buffer odkaz� na rodi�e
	par = (int*)malloc(1000 * sizeof(int));
	nxt = (BOOL*)malloc(1000 * sizeof(BOOL));
	parnum = 0;
	par[0] = -1;
	parmax = 1000;
	nxt[0] = TRUE;

// konverze buffer�
	src = pbuf;
	dst = pi;
	for (int i = 0; i < pnum; i++)
	{

// p��prava parametr� prvku
		dst->param = 0;
		if (src->param & PETPROG_EXP) dst->param |= PR_EXP;
		if (src->param & PETPROG_LOCK) dst->param |= PR_LOCK;
		if (src->param & PETPROG_OFF) dst->param |= PR_OFF;

// rodi� prvku
		dst->parent = par[parnum];				// rodi� prvku
		if (dst->parent != -1)
			pi[dst->parent].childs++;

// ��ta�e prvk�
		for (int j = parnum; j >= 0; j--)
			if (par[j] != -1)
				pi[par[j]].items++;

// ukon�en� hladiny, nen�-li dal�� stejn� prvek
		if (!(src->param & PETPROG_NEXT))		// bude dal�� prvek ?
			nxt[parnum] = FALSE;				// p��znak, �e nebude dal�� prvek
		else
			nxt[parnum] = TRUE;					// bude dal�� prvek

// zv��en� nebo sn�en� hladiny, jsou-li potomci
		if (src->param & PETPROG_CHILDS)		// budou potomci ?
		{
			parnum++;							// zv��en� ��ta�e prvk�
			if (parnum >= parmax)
			{
				par = (int*)realloc(par, (parmax + 1000) * sizeof(int));
				nxt = (BOOL*)realloc(nxt, (parmax + 1000) * sizeof(BOOL));
				parmax += 1000;
			}
			par[parnum] = i;					// ��slo aktu�ln�ho prvku = rodi�
			nxt[parnum] = TRUE;					// p��znak, �e m��e b�t dal�� prvek
		}
		else
		{
			while ((nxt[parnum] == FALSE) && (parnum > 0))
				parnum--;
		}

// deklarace prvku
		dst->typ = src->typ;				// blok s deklarac� prvku
		dst->refer = src->refer;			// index s deklarac� prvku

// p�i odkazu na intern� prvek importov�n� odkazu
		if (dst->typ == BufIntID)
		{
			if ((dst->refer >= 0) && (dst->refer < m_numImport))
				dst->refer = m_tabImport[dst->refer];
		}

// omezen� hodnot typu a indexu
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

// p�i odkazu na intern� prvek zm�na na buffer struktur
		if (dst->typ == BufIntID)
		{
			dst->typ = m_typImport[dst->refer];
			dst->refer = m_refImport[dst->refer];
		}

// ostatn� ukazatele prvku
		dst->index = src->index;			// index s daty prvku
		dst->data = src->data;				// blok s daty prvku
		dst->icon = src->icon;				// ikona
		dst->name = src->name;				// text jm�na
		if ((dst->name < 0) || (dst->name >= m_Text.GetSize()))
			dst->name = -1;
		dst->model = TYP_NONE;
		dst->htree = NULL;
		dst->counter = 0;					// ��ta� odkaz� na prvek
		dst->childs = 0;					// po�et p��m�ch potomk�
		dst->items = 1;						// po�et prvk�

// ur�en� bloku s daty
	
//		dst->data = -1;						// nejsou data
//		if (dst->index != -1)
//		{
//			if (buf == &m_BufLoc) 
//				dst->data = BufEdiID;
//			else
//				if (buf == &m_BufObj)
//					dst->data = BufLocID;
//		}

// zd�d�n� parametry, ��ta� odkaz�
		if (dst->typ != -1)
		{
			dst->model = m_Buf[dst->typ].m_Items[dst->refer].model;
			m_Buf[dst->typ].m_Items[dst->refer].counter++;
			dst->param |= (m_Buf[dst->typ].m_Items[dst->refer].param) & 
				~(PR_EXP | PR_LOCK | PR_OFF | PR_INTERNAL);
		}

// p��znak intern�ho prvku
		if ((dst->typ == BufIntID) && (dst->model != TYP_NONE))
			dst->param |= PR_INTERNAL;

// zv��en� ukazatel� v bufferech
		dst++;
		src++;
	}

// zru�en� bufferu odkaz� na rodi�e
	free(par);
	free(nxt);
}
