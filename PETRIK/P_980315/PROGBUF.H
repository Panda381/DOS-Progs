
#define	PROGBUFNUM 6				// po�et buffer�

////////////////////////////////////////////////////////////////////
// definice polo�ky programu (28 bajt�)

typedef struct tagPROGITEM {
	unsigned short int	param;	// parametry
	unsigned short int	model;	// model (typ) prvku
	signed short int	typ;	// blok s deklarac� (-1 = nen�)
	signed short int 	refer;	// index deklarace (-1 = nen�)
	signed short int	data;	// blok s daty (-1 = nen�)
	signed short int	index;	// index dat (-1 = nen�)
	signed short int	parent;	// index rodi�e ve stromu (-1 = nen�)
	signed short int	childs;	// po�et p��m�ch potomk� v podv�tvi (0 = nejsou)
	signed short int	items;	// po�et prvk� v podv�tvi v�etn� tohoto prvku
	signed short int	icon;	// index ikony polo�ky (-1 = implicitn�)
	signed short int	name;	// index textu jm�na polo�ky (-1 = implicitn�)
	HTREEITEM			htree;	// handle polo�ky ve stromu (NULL = nen�)
	signed short int	counter; // ��ta� odkaz� na tento prvek
} PROGITEM;

// p��znaky
#define PR_EXP			0x0001	// parametr - p��znak rozvinut� potomk�
#define PR_BOLD			0x0002	// parametr - zv�razn�n� p�smo
#define PR_GRAY			0x0004	// parametr - ze�ednut�
#define PR_LOCK			0x0008	// parametr - uzam�eno proti modifikaci
#define PR_ONE			0x0010  // prvek m��e m�t maxim�ln� 1 potomka (log. negace)
#define PR_INTERNAL		0x0020	// z�kaz ru�en� a p�esunu - v�choz� prvek (po kopii se nuluje)
#define PR_NOMOVE		0x0040	// z�kaz ru�en�, kop�rov�n� a p�esouv�n� prvku (potomek struktury)
#define PR_GROUP		0x0080	// prvek je skupina - mus� b�t pr�choz� pro parametry
#define PR_LIST			0x0100	// prvek je seznam
#define PR_FUNC			0x0200	// funkce (obsah je v bufferu funkc�)
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
#define	TYP_NONE_		TYP_NONE+7

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

#define	TYP_FUNC		TYP_OPER_	// u�ivatelsk� funkce
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
#define	TYP_CLASS		TYP_FUNC+11	// obecn� t��da
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

////////////////////////////////////////////////////////////////////
// t��da bufferu programu

class CProgBuf : public CObject
{
public:
	CProgBuf();
	virtual ~CProgBuf();

	int			m_BufID;		// ID bufferu
	PROGITEM*	m_Items;		// buffer polo�ek
	int			m_Num;			// po�et polo�ek v bufferu
	int			m_Max;			// maxim�ln� polo�ek v bufferu
	int			m_First;		// prvn� zobrazen� polo�ka bufferu
	int			m_Next;			// n�sleduj�c� (nezobrazen�) polo�ka bufferu
	CTreeCtrl*	m_Tree;			// odkaz na zobrazen� strom (NULL = nen�)
	CProgBuf*	m_ProgBuf;		// mapa v�ech buffer� programu
	CTextBuf*	m_Text;			// seznam text� (sd�len�)

// vlo�en� polo�ky do bufferu (vrac� opraven� index)
	int Insert(PROGITEM* item, int Index = -1);

// nalezen� polo�ky podle handle (vrac� index)
	int SrcItem(HTREEITEM hItem);

// zru�en� polo�ky z bufferu
	void Delete(int Index);

// p�ekreslen� stromu
	void ReDisp();

};
