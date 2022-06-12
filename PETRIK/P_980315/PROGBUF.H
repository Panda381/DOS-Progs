
#define	PROGBUFNUM 6				// poèet bufferù

////////////////////////////////////////////////////////////////////
// definice položky programu (28 bajtù)

typedef struct tagPROGITEM {
	unsigned short int	param;	// parametry
	unsigned short int	model;	// model (typ) prvku
	signed short int	typ;	// blok s deklarací (-1 = není)
	signed short int 	refer;	// index deklarace (-1 = není)
	signed short int	data;	// blok s daty (-1 = není)
	signed short int	index;	// index dat (-1 = není)
	signed short int	parent;	// index rodièe ve stromu (-1 = není)
	signed short int	childs;	// poèet pøímých potomkù v podvìtvi (0 = nejsou)
	signed short int	items;	// poèet prvkù v podvìtvi vèetnì tohoto prvku
	signed short int	icon;	// index ikony položky (-1 = implicitní)
	signed short int	name;	// index textu jména položky (-1 = implicitní)
	HTREEITEM			htree;	// handle položky ve stromu (NULL = není)
	signed short int	counter; // èítaè odkazù na tento prvek
} PROGITEM;

// pøíznaky
#define PR_EXP			0x0001	// parametr - pøíznak rozvinutí potomkù
#define PR_BOLD			0x0002	// parametr - zvýraznìné písmo
#define PR_GRAY			0x0004	// parametr - zešednutí
#define PR_LOCK			0x0008	// parametr - uzamèeno proti modifikaci
#define PR_ONE			0x0010  // prvek mùže mít maximálnì 1 potomka (log. negace)
#define PR_INTERNAL		0x0020	// zákaz rušení a pøesunu - výchozí prvek (po kopii se nuluje)
#define PR_NOMOVE		0x0040	// zákaz rušení, kopírování a pøesouvání prvku (potomek struktury)
#define PR_GROUP		0x0080	// prvek je skupina - musí být prùchozí pro parametry
#define PR_LIST			0x0100	// prvek je seznam
#define PR_FUNC			0x0200	// funkce (obsah je v bufferu funkcí)
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

#define	TYP_FUNC		TYP_OPER_	// uživatelská funkce
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
#define	TYP_CLASS		TYP_FUNC+11	// obecná tøída
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

////////////////////////////////////////////////////////////////////
// tøída bufferu programu

class CProgBuf : public CObject
{
public:
	CProgBuf();
	virtual ~CProgBuf();

	int			m_BufID;		// ID bufferu
	PROGITEM*	m_Items;		// buffer položek
	int			m_Num;			// poèet položek v bufferu
	int			m_Max;			// maximálnì položek v bufferu
	int			m_First;		// první zobrazená položka bufferu
	int			m_Next;			// následující (nezobrazená) položka bufferu
	CTreeCtrl*	m_Tree;			// odkaz na zobrazený strom (NULL = není)
	CProgBuf*	m_ProgBuf;		// mapa všech bufferù programu
	CTextBuf*	m_Text;			// seznam textù (sdílený)

// vložení položky do bufferu (vrací opravený index)
	int Insert(PROGITEM* item, int Index = -1);

// nalezení položky podle handle (vrací index)
	int SrcItem(HTREEITEM hItem);

// zrušení položky z bufferu
	void Delete(int Index);

// pøekreslení stromu
	void ReDisp();

};
