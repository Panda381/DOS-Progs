# ifndef __BALTAZAR__
///////////////////////////////////
//
//  Baltazar v5.00
//  (c)1995,1996,1997 SGP Systems
//
//
# define __BALTAZAR_VERSION__ 500 // v5.00

# pragma idchars = "ØçŸı§ì ¡‚£…¢Ôœå·æ¬ü¦íµÖéŞàÒ›Õ„‰”áÓš™ĞÑˆ’‘–•êè“â"

typedef long TypPıedmØt; // v4.00

// datum
typedef struct {
  int  Rok;   // 1980-2099
  unsigned char
    MØs¡c,    // 1-12
    Den,      // 1-28,29,30,31
    DenTìdne; // 0-6; 0=nedØle, 1=pondØl¡...
  } TypDatum;

// Ÿas
typedef struct {
  unsigned char Hodiny, Minuty, Sekundy, Setiny;
  } Typ¬as;

built_in(  3) void VytvoıProstor();
built_in(  4) void ZruçProstor();
built_in( 26) int  Ulo§Sc‚nu( char* jm‚no );
built_in( 27) int  NaŸtiSc‚nu( char* jm‚no );
built_in( 11) int  RychlostBaltazara( unsigned rychlost );
built_in(  5) void Popojdi( int pocet_policek );
built_in(  6) void ¬ekej( int zpozdeni );
built_in(  7) void VpravoVbok();
built_in(  8) void VlevoVbok();
built_in( 15) void Neviditelnì();
built_in( 16) void Viditelnì();
built_in(  9) int  NastavBarvu¬arov n¡( int barva );
built_in( 10) void ¬aruj( TypPıedmØt predmet );
built_in( 17) void N hodnØ¬aruj( TypPıedmØt predmet );
built_in( 41) void ¬arujNaPozici( TypPıedmØt predmet, int x, int y );
built_in( 39) void BezObl Ÿku();
built_in( 40) void SObl Ÿkem();

built_in( 25) int  ¬tiKl vesuZFronty();
built_in( 65) void Vypr zdniFrontuKl ves();
built_in( 57) int  BylaStisknutaKl vesa();
# define           ¬tiKl vesuZFrontyS¬ek n¡m() (¬ekej(NaKl vesu),¬tiKl vesuZFronty())
# define           ¬tiKl vesuS¬ek n¡m()        (Vypr zdniFrontuKl ves(),¬ekej(NaKl vesu),¬tiKl vesuZFronty())
# define           ¬ekejNaKl vesu()            (Vypr zdniFrontuKl ves(),¬ekej(NaKl vesu))
built_in(315) int  ¬tiKl vesuS¬ek n¡m2( int ¬as, int Kl vesa );

built_in( 28) void PıepniNaText();
built_in( 29) void PıepniNaBaltazara();

built_in( 76) void EscM¡nus();
built_in( 75) void EscPlus();

built_in( 12) int  SmØrBaltazara();
built_in( 18) int  PoziceBaltazaraX();
built_in( 19) int  PoziceBaltazaraY();
built_in( 13) TypPıedmØt PıedmØtPıedB();
built_in( 14) int  Barva¬tvercePıedB();
built_in( 20) int  Pr…chodnostPıedmØtuPıedB();
built_in( 21) int  Vzd lenostPıedmØtuPıedB( TypPıedmØt predmet );
built_in( 22) int  Vzd lenost¬tvercePıedB( int barva );
built_in( 23) int  Vzd lenostPıek §kyPıedB();
built_in( 24) TypPıedmØt Nejbli§ç¡PıedmØtPıedB();

built_in(  1) int   Txt¬tiZnak();
built_in( 34) int   Txt¬tiCüetØzec( char* retezec, int max_delka );
built_in( 36) int   Txt¬tiI¬¡slo( int& cele_cislo );
built_in( 37) int   Txt¬tiU¬¡slo( unsigned& prirozene_cislo );
built_in( 35) int   Txt¬tiD¬¡slo( double& realne_cislo );
built_in( 38) int   Txt¬tiNovìü dek();

built_in(  0) void  TxtPiçZnak( char c );
built_in( 30) char* TxtPiçüetØzec( char* retezec );
built_in( 32) int   TxtPiçL¬¡slo( long d, int delka );
built_in( 33) int   TxtPiçU¬¡slo( unsigned d, int delka );
built_in( 31) int   TxtPiçD¬¡slo( double d, int delka, int desetinna_delka );
# define            TxtPiçNovìü dek() (TxtPiçZnak('\n'))

built_in( 64) void  GrSma§Okno();
built_in( 67) void  GrNastavPozici( int x, int y );
built_in( 69) int   GrPoziceX();
built_in( 70) int   GrPoziceY();
built_in( 68) int   GrNastavBarvuPopıed¡( int barva );
built_in( 77) int   GrNastavBarvuPozad¡( int barva );
built_in( 74) void  GrPiçZnak( int z );
built_in( 66) void  GrPiçüetØzec( char* text );
built_in( 72) void  GrPiçL¬¡slo( long d, int delka );
built_in( 73) void  GrPiçU¬¡slo( int d, int delka );
built_in( 71) void  GrPiçD¬¡slo( double d, int delka, int desetinna_delka );

built_in( 58) Typ¬as&    Syst‚movì¬as( Typ¬as& cas );
built_in( 59) TypDatum&  Syst‚mov‚Datum( TypDatum& datum );

built_in( 60) void  StopkyNuluj();
built_in( 61) void  StopkyStart();
built_in( 62) void  StopkyStop();
built_in( 63) void  Stopky( Typ¬as& cas );

built_in( 78) void  PiçPort8( int port, unsigned char byte );
built_in( 79) int   ¬tiPort8( int port );
built_in( 80) void  PiçPort16( int port, int word );
built_in( 81) int   ¬tiPort16( int port );

built_in( 45) double sqrt( double r );
built_in( 46) double sqr( double r );
built_in( 47) double atan( double r );
built_in( 48) double abs( double r );
built_in( 49) double cos( double r );
built_in( 50) double sin( double r );
built_in( 51) double exp( double r );
built_in( 52) double frac( double r );
built_in( 53) double integer( double r );
built_in( 54) double log( double r );

built_in( 42) unsigned N hodn‚¬¡slo( unsigned rozsah );
built_in( 43) void     T¢n( unsigned vyska );
built_in( 44) void     VypniT¢n();
built_in(  2) unsigned D‚lkaüetØzce( char* s );

// makra pro cyklus # (for)
# define OdDoKrok(var,od,do,krok)            \
           (var)= (od); (var)<=(do); (var)+= (krok)
# define OdDol…DoKrok(var,od,do,krok)        \
           (var)= (od); (var)>=(do); (var)-= (krok)
# define Od0(var,kolikrat)                      \
           (var)= 0; (var)<(kolikrat); ++(var)
# define Dol…Do0(var,kolikrat)                  \
           (var)= ((kolikrat)-1); (var)>=0; --(var)

built_in(  0) void      putchar( char c );
built_in(  1) int       getchar();
built_in(  2) unsigned  strlen( char* s );

/////////////////////////////////
//
//  main() mus¡ m¡t tento tvar:
    extern void main();

///////////////
//
//  KONSTANTY
//

// pıedmØty
# define Okraj            0L
# define ¬tverec        (-1L)
# define ZeÔ              2L

// smØry
# define Vìchod           1
# define Jih              2
# define Z pad            3
# define Sever            4

// barvy
# define ¬ern             0
# define Tmavozelen       1
# define Modr             2
# define Tmavomodr        3
# define Fialovor…§ov     4
# define ¬ervenohnØd      5
# define Kr‚mov           6
# define SvØtloçed        7
# define Tmavoçed         8
# define SvØtlozelen      9
# define SvØtlomodr       10
# define Fialov           11
# define ¬erven           12
# define Oran§ov          13
# define ¦lut             14
# define B¡l              15

// vzd lenost
# define Nevid¡m          20

// Ÿek n¡
# define NaKl vesu        ((int)0x8001)
# define NaMyç            ((int)0x8002)

// kl vesy
# define KlNen¡           0
# define KlDol…           0x5000
# define KlDoleva         0x4b00
# define KlDoprava        0x4d00
# define KlNahoru         0x4800
# define KlEnd            0x4f00
# define KlHome           0x4700
# define KlPageUp         0x4900
# define KlPageDown       0x5100
# define KlEsc            27
# define KlEnter          '\r'
# define KlIns            0x5200
# define KlDel            0x5300
# define KlF1             0x3b00
# define KlF2             0x3c00
# define KlF3             0x3d00
# define KlF4             0x3e00
# define KlF5             0x3f00
# define KlF6             0x4000
# define KlF7             0x4100
# define KlF8             0x4200
# define KlF9             0x4300
# define KlF10            0x4400
# define KlF11            0x8500
# define KlF12            0x8600

// pr zdnì ukazatel
# define NULL             0

// grafick‚ ok‚nko
# define GrVìçkaZnaku                   10
# define Græ¡ıkaZnaku                   8
# define GrVìçkaOkna                    26
# define Græ¡ıkaOkna                    386

// prostor
# define æ¡ıkaProstoru                  15
# define VìçkaProstoru                  10
# define PoŸetPıedmØt…                  150

# define P¡                             3.1415926535897932385

////////////////
//
//  verze 3.08
//

built_in( 83) TypPıedmØt VyberPıedmØt( int cisla );
built_in( 84) TypPıedmØt PıedmØtNaPozici( int x, int y );
built_in( 85) int  Barva¬tverceNaPozici( int x, int y );
built_in( 86) int  NastavPoziciBaltazara( int x, int y );

built_in( 87) int  TxtNastavBarvuPopıed¡( int barva );
built_in( 88) int  TxtNastavBarvuPozad¡( int barva );
built_in( 89) void TxtNastavPozici( int x, int y );
built_in( 90) void TxtSma§Obrazovku();

////////////////
//
//  verze 3.10
//

// makra pro cyklus # (for)
# define OdDoKrok(var,od,do,krok) \
           (var)= (od); (var)<=(do); (var)+= (krok)
# define OdDol…DoKrok(var,od,do,krok) \
           (var)= (od); (var)>=(do); (var)-= (krok)
# define Od0(var,kolikrat) \
           (var)= 0; (var)<(kolikrat); ++(var)
# define Dol…Do0(var,kolikrat)\
           (var)= ((kolikrat)-1); (var)>=0; --(var)

built_in(105) int Grafick Karta();
# define KartaCGA   1
# define KartaEGA   3
# define KartaHerc  7
# define KartaVGA   9
# define KartaVESA 10

////////////////
//
//  verze 3.20
//

built_in(104) int  DOSProveÔ( char* radkovy_prikaz_DOSu );
built_in(106) void GrNastavP…vodn¡Paletu();
built_in(107) int  GrNaŸtiPaletu( char* jmeno_souboru );
built_in(108) TypPıedmØt Baltedit();

////////////////
//
//  verze 3.3+
//

// nov  synonyma pro testov n¡
# define Neplat¡               !
# define JeMenç¡Ne§            <
# define JeMenç¡NeboRovno      <=
# define JeVØtç¡Ne§            >
# define JeVØtç¡NeboRovno      >=
# define Je                    ==
# define Nen¡                  !=
# define ASouŸasnØ             &&
# define Nebo                  ||
# define Pravdivì              1
# define Nepravdivì            0

// barvy pro textovì m¢d
# define Txt¬ern                0
# define TxtModr                1
# define TxtZelen               2
# define TxtModrozelen          3
# define Txt¬erven              4
# define TxtFialov              5
# define TxtHnØd                6
# define TxtSvØtloçed           7
# define TxtTmavoçed            8
# define TxtSvØtlomodr          9
# define TxtSvØtlozelen        10
# define TxtSvØtlomodrozelen   11
# define TxtSvØtloŸerven       12
# define TxtSvØtlofialov       13
# define Txt¦lut               14
# define TxtB¡l                15
// blikaj¡c¡ popıed¡
# define TxtBlikat           0x80

built_in(109) int  Gr¬tiCüetØzec( char* prompt, char* retezec, int pocet_znaku, int edituj_obsah, int barvy );
built_in(110) int  Gr¬tiI¬¡slo( char* prompt, int& cislo, int pocet_znaku, int edituj_obsah, int barvy );
built_in(111) int  Gr¬tiU¬¡slo( char* prompt, unsigned& cislo, int pocet_znaku, int edituj_obsah, int barvy );
built_in(112) int  Gr¬tiL¬¡slo( char* prompt, long& cislo, int pocet_znaku, int edituj_obsah, int barvy );
built_in(113) int  Gr¬tiD¬¡slo( char* prompt, double& cislo, int pocet_znaku, int edituj_obsah, int barvy );
built_in(114) int  Gr¬tiZnak( char* prompt, char& znak, int edituj_obsah, int barvy );

built_in(115) int  GrNastavBarvy( int barvy );
built_in(116) int  GrBarvy();
built_in(117) int  GrBarvaPopıed¡();
built_in(118) int  GrBarvaPozad¡();
built_in(119) void GrPiçNovìü dek();

built_in(120) char* strcpy( char* üetØzec1, char* üetØzec2 );
built_in(121) char* strcpyn( char* üetØzec1, char* üetØzec2, unsigned n );
built_in(122) char* strcat( char* üetØzec1, char* üetØzec2 );
built_in(123) char* strcatn( char* üetØzec1, char* üetØzec2, unsigned n );
built_in(124) char* strchr( char* üetØzec, int Znak );
built_in(125) char* strrchr( char* üetØzec, int Znak );
built_in(126) char* strstr( char* üetØzec1, char* üetØzec2 );
built_in(127) char* strend( char* üetØzec );

built_in(128) int   strcmp( char* üetØzec1, char* üetØzec2 );
built_in(129) int   strncmp( char* üetØzec1, char* üetØzec2, unsigned n );

built_in(130) void* memcpy( void* Kam, void* Odkud, unsigned PoŸet );
built_in(130) void* memmove( void* Kam, void* Odkud, unsigned PoŸet );
built_in(131) void* memset( void* Co, int Hodnota, unsigned PoŸet );

built_in(132) int   TxtNastavBarvy( int barvy );
built_in(133) int   TxtBarvy();
built_in(134) int   TxtBarvaPopıed¡();
built_in(135) int   TxtBarvaPozad¡();
built_in(136) int   TxtPoziceX();
built_in(137) int   TxtPoziceY();
built_in(138) int   Txt¬tiL¬¡slo( long& number );

//////////////////////
//
//  verze 4.00, 5.00
//

// kl vesa
built_in(2)   int      gKl vesa;

// peek&poke
built_in( 91) unsigned DataSeg();
built_in( 92) int  peek(  unsigned seg, unsigned ofs );
built_in( 93) int  peekb( unsigned seg, unsigned ofs );
built_in( 94) void poke(  unsigned seg, unsigned ofs, int hodnota16);
built_in( 95) void pokeb( unsigned seg, unsigned ofs, int hodnota8 );

// registry procesoru 80x86
typedef struct {
  unsigned AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags;
  } TypRegistry;

// registr pı¡znak… (Flags)
# define FlagCarry     (1<<0)  // carry
# define FlagParity    (1<<2)  // parity
# define FlagAuxCarry  (1<<4)  // aux carry
# define FlagZero      (1<<6)  // zero
# define FlagSign      (1<<7)  // sign
# define FlagTrap      (1<<8)  // trap
# define FlagInterrupt (1<<9)  // interrupt
# define FlagDirection (1<<10) // direction
# define FlagOverflow  (1<<11) // overflow

// sw pıeruçen¡ (interrupt)
built_in( 96) void intr( int intr_cislo, TypRegistry& registry );

// pr ce s pamØt¡
built_in( 97) void fmemcpy( unsigned cil_seg,   unsigned cil_ofs,
                            unsigned zdroj_seg, unsigned zdroj_ofs,
                            unsigned Velikost   );
built_in( 97) void fmemmove( unsigned cil_seg,   unsigned cil_ofs,
                             unsigned zdroj_seg, unsigned zdroj_ofs,
                             unsigned Velikost   );
built_in( 98) void fmemset( unsigned cil_seg,   unsigned cil_ofs,
                            int hodnota8, unsigned Velikost );

// komunikace po COM lince
built_in(100) int COMPıipoj( unsigned char COM, unsigned char rychlost );
built_in(101) int COMOdpoj( unsigned char COM );
built_in(102) int COM¬ti( unsigned char COM );
built_in(103) int COMPiç( unsigned char COM, unsigned char hodnota );

# define COM110Bd	    0
# define COM150Bd	    1
# define COM300Bd	    2
# define COM600Bd	    3
# define COM1200Bd    4
# define COM2400Bd    5
# define COM4800Bd    6
# define COM9600Bd    7
# define COM19200Bd   8
# define COM38400Bd   9
# define COM115200Bd 10

// pr ce s ıetØzci - dokonŸen¡
built_in(139) int   stricmp( char* s1, char* s2 );
built_in(140) int   strnicmp( char* s1, char* s2, unsigned delka );
built_in(141) char* strlwr( char* s );
built_in(142) char* strupr( char* s );

built_in(143) int czchrupr( int znak );
built_in(144) int czchrlwr( int znak );
built_in(145) int czchrplain( int znak );

built_in(146) char* czstrupr( char* retezec );
built_in(147) char* czstrlwr( char* retezec );
built_in(148) char* czstrplain( char* retezec );

built_in(149) int czstrcmp( char* ret1, char* ret2 );
built_in(150) int czstricmp( char* ret1, char* ret2 );
built_in(151) int czstriicmp( char* ret1, char* ret2 );

built_in(153) long   StrNaL¬¡slo( char* retezec, int* chyba );
built_in(154) double StrNaD¬¡slo( char* retezec, int* chyba );

built_in(155) char* L¬¡sloNaüetØzec( char* retezec, long cislo, int delka );
built_in(156) char* D¬¡sloNaüetØzec( char* retezec, double cislo,
                                     int delka, int desetinna_delka );

built_in(159) int Pr…chodnostPıedmØtu( TypPıedmØt predm );
built_in(160) int NastavPr…chodnostPıedmØtu( TypPıedmØt predm,
                                                  int pruch );
built_in(161) TypPıedmØt NaŸtiPıedmØty( TypPıedmØt Prvn¡PıedmØt, int PoŸet );
built_in(162) int  NastavJm‚noBankyPıedmØt…( char* jmeno_souboru );
built_in(163) void GrNastavPaletu( TypPıedmØt cislo_predmetu );

built_in(332) void NastavZaŸ tekAnimaceBaltazara( TypPıedmØt prvn¡ );

built_in(164) int Transparentn¡BarvaPıedmØtu( TypPıedmØt predm );
built_in(165) int NastavTransparentn¡BarvuPıedmØtu( TypPıedmØt predm, int barva );

built_in(166) long RychlostCPU();
built_in(333) void ¬ekejNaVR();
built_in(167) int  Txtü dkovìEditor( string& ret, unsigned max_znaku,
                                     unsigned sirka, int pozice, int* ukonceni );
built_in(168) int  NastavViditelnostBaltazara( int Viditelnost );

// textovì re§im
# define TxtM¢d¬B40x25 0x001
# define TxtM¢dB40x25  0x002
# define TxtM¢d¬B80x25 0x003
# define TxtM¢dB80x25  0x004
# define TxtM¢dMono    0x005
# define TxtM¢d¬B80x50 0x103
# define TxtM¢dB80x50  0x104

built_in(170) int TxtNastavM¢d( int mod );
built_in(313) int TxtM¢d();

# define TxtKurzorNeviditelnì 0
# define TxtKurzorMalì        1
# define TxtKurzorVelkì       2

built_in(171) int TxtNastavTvarKurzoru( int tvar );
built_in(172) int TxtMaxX();
built_in(173) int TxtMaxY();
built_in(306) int Txt¬tiSüetØzec( string& üetØzec );

// grafika
# define Græ¡ıkaPol¡Ÿka  39
# define GrVìçkaPol¡Ÿka  29

built_in(175) void GrNastavPoziciRel( int x, int y );
built_in(176) int  GrNastavVìstup( int vystup, ...);

# define GrVìstupOk‚nko               0
# define GrVìstupOkno                 1
# define GrVìstupPlocha               2
# define GrVìstupU§ivatelskì1         3
# define GrVìstupU§ivatelskì2         4
# define GrVìstupU§ivatelskì3         5
# define GrVìstupU§ivatelskì4         6
# define GrVìstupU§ivatelskìNastaven¡ 8

# define GrVìstupOk‚nkoX 229
# define GrVìstupOk‚nkoY 310
# define GrVìstupOknoX    25
# define GrVìstupOknoY    11

typedef unsigned char TypGrVìplåVzorek[8];

built_in(177) void GrNastavVìplå( int druh, ...);

# define GrVìplåPln    0
# define GrVìplåVzorek 1

built_in(178) void GrNastavLinku( int druh, ...);

# define GrLinkaPln    1
# define GrLinkaVzorek 2
# define GrLinkaTenk   4
# define GrLinkaTlust  8

# define GrLinkaZp…sobKreslen¡Norm lnØ 0x10
# define GrLinkaZp…sobKreslen¡Xor      0x20
# define GrLinkaZp…sobKreslen¡Or       0x30
# define GrLinkaZp…sobKreslen¡And      0x40
# define GrLinkaZp…sobKreslen¡Not      0x50

built_in(179) int GrNastavText( int druh );

# define GrTextSPozad¡m  0
# define GrTextBezPozad¡ 1

built_in(180) void GrKresliObd‚ln¡k( int X1, int Y1, int X2, int Y2 );
built_in(181) void GrKresliVyplnØnìObd‚ln¡k( int X1, int Y1, int X2, int Y2 );
built_in(182) void GrKresliElipsu( int x, int y,
                                   double pocatecni_uhel, // radi ny
                                   double koncovy_uhel,   // radi ny
                                   unsigned x_polomer,
                                   unsigned y_polomer );
built_in(183) void GrKresliLinku( int X1, int Y1, int X2, int Y2 );
built_in(184) void GrKresliLinkuDo( int x, int y );
built_in(185) void GrKresliLinkuRel( int DX, int dy );
built_in(186) void GrKresliMnoho£heln¡k( unsigned pocet_bodu,
                                         int X1, int Y1, ...);
built_in(187) int  GrKresliVyplnØnìMnoho£heln¡k( unsigned pocet_bodu,
                                                 int X1, int Y1, ...);
built_in(188) int  GrVyplåPlochu( int x, int y, int barva_okraje );
built_in(189) int  GrBarvaBodu( int x, int y );
built_in(190) void GrKresliBod( int x, int y, int barva );
built_in(191) int  GrKresliPıedmØt( TypPıedmØt predm, int transparentnØ,
                                    int x, int y );
built_in(316) int  GrKresliPıedmØty( TypPıedmØt predm, int transparentnØ,
                                     int x, int y, int ç, int v );
built_in(192) int  GrNastavObrazPıedmØtu( TypPıedmØt predm,
                                          int x, int y,
                                          int pouze_z_plochy );
built_in(317) int  GrNastavObrazPıedmØt…( TypPıedmØt predm,
                                          int x, int y,
                                          int ç, int v,
                                          int pouze_z_plochy );
built_in(329) int  GrNaŸtiBMP( int x, int y, char* Jm‚noSouboru,
                               int BMPx, int BMPy, int BMPw, int BMPh,
                               int BMPPaleta );
built_in(330) int  GrUlo§BMP( int x, int y, int w, int h, char* Jm‚noSouboru );

typedef struct {
  long Velikost;
  long æ¡ıka;
  long Vìçka;
  unsigned PoŸetRovin;
  unsigned BityNaBod;
  long Komprese;
  long VelikostObr zku;
  long XBodyNaMetr, YBodyNaMetr;
  long PoŸetPou§itìchBarev;
  long PoŸetD…le§itìchBarev;
  } TypBMPInfo;

built_in(331) int  GrNaŸtiBMPInfo( char* Jm‚noSouboru, TypBMPInfo& BMPInfo );

typedef struct {
  int X, Y, X1, Y1, X2, Y2;
  } TypGrPoziceOblouku;

built_in(193) void GrPoziceOblouku( TypGrPoziceOblouku& obl_poz );

built_in(194) int  GrMaxX();
built_in(195) int  GrMaxY();

# define GrM¢dEGA           1
# define GrM¢dVGA           2
# define GrM¢dVESA800x600   3
# define GrM¢dVESA1024x768  4
# define GrM¢dVESA1280x1024 5
built_in(196) int  GrNastavM¢d( int M¢d );
built_in(312) int  GrM¢d();
built_in(314) void GrNastavBarvuPalety( int ¬¡slo, int R, int G, int B );
built_in(326) void GrBarvaPalety( int ¬¡slo, int& R, int& G, int& B );
built_in(307) int  Gr¬tiSüetØzec( char* prompt, string& retezec, int pocet_znaku, int edituj_obsah, int barvy );
built_in(320) int  Grü dkovìEditor( string& retezec, int pocet_znaku, int pozice, int blok_zacatek, int blok_konec, int barvy );

// argumenty a promØnn‚ DOSu
built_in(197) int      DOSPoŸetArgument…();
built_in(198) string   DOSArgument( int ¬¡slo );
built_in(199) string   DOSPromØnn ( char* Jm‚no );
built_in(200) unsigned DOSVerze();
built_in(201) int      DOSChyba();

// chyby DOSu
# define DOSChybaSoubor                 2
# define DOSChybaCesta                  3
# define DOSChybaMnohoSoubor…           4
# define DOSChybaPı¡stupOdepıen         5
# define DOSChybaJednotka              15
# define DOSChybaAktu ln¡Adres ı       16
# define DOSChybaPıejmenov n¡          17
# define DOSChybaDalç¡Polo§kaAdres ıe  18

// disk a adres ıe ( A=adres ı, AP=polo§ka adres ıe )
built_in(203) long DiskVoln‚M¡sto( int jednotka );
built_in(204) long DiskVelikost( int jednotka );

built_in(205) int    Adres ıVytvoı( char* cesta );
built_in(206) int    Adres ıSma§( char* cesta );
built_in(207) string Adres ıAktu ln¡( int Jednotka );
built_in(208) int    Adres ıNastavAktu ln¡( char* cesta );

typedef struct {
  char _reserved[21];
  unsigned char Atributy;
  long DatumA¬as;
  long Velikost;
  char Jm‚no[13];
  } TypPolo§kaAdres ıe;

built_in(209) int  Polo§kaAdres ıeNajdiPrvn¡( char* cesta, unsigned Atributy,
                                              TypPolo§kaAdres ıe& apol );
built_in(210) int  Polo§kaAdres ıeNajdiDalç¡( TypPolo§kaAdres ıe& apol );
built_in(211) void Polo§kaAdres ıeDek¢dujDatumA¬as( TypPolo§kaAdres ıe& apol,
                                                    TypDatum& datum, Typ¬as& cas );

// soubory ( S=soubor )
typedef long TypSoubor;

built_in(213) int    SouborNulujChybu( TypSoubor s );
built_in(221) int    SouborExistuje( char* Jm‚no );
built_in(214) string SouborAbsolutn¡Cesta( char* Jm‚no );
built_in(215) string SouborHledej( char* Jm‚no, char* SeznamAdres ı… );
built_in(216) int    SouborRozdØlCestu( char* Cesta,
                                        string& Adres ı, string& Jm‚no,
                                        string& Pı¡pona );
// atributy souboru
# define SouborAtributPouze¬ten¡ 0x01
# define SouborAtributSkrytì     0x02
# define SouborAtributSyst‚movì  0x04
# define SouborAtributSvazek     0x08
# define SouborAtributAdres ı    0x10
# define SouborAtributArchivn¡   0x20

built_in(217) unsigned SouborAtributy( char* Jm‚no );
built_in(218) int      SouborNastavAtributy( char* Jm‚no, unsigned Atributy );

built_in(219) int SouborSma§( char* Jm‚no );
built_in(220) int SouborPıejmenuj( char* stare_jmeno, char* nove_jmeno );

// pı¡stup k souboru
# define SouborPı¡stup¬ten¡ 0x01 // Ÿten¡
# define SouborPı¡stupZ pis 0x02 // z pis
// je-li instalov n SHARE.EXE
# define SouborPı¡stupOdepıi¬ten¡       0x30 // odepıi Ÿten¡
# define SouborPı¡stupOdepıiZ pis       0x20 // odepıi z pis
# define SouborPı¡stupOdepıi¬ten¡IZ pis 0x10 // odepıi Ÿten¡ a z pis
# define SouborPı¡stupPovolVçe          0x40 // neodepıi nic
# define SouborPı¡stupPriv tn¡          0x80
// form t
# define SouborPı¡stupTextovì 0x100
# define SouborPı¡stupBin rn¡ 0x200

built_in(222) TypSoubor SouborOtevıi( char* Jm‚no, unsigned pristup );
built_in(223) int SouborZapiçBuffer( TypSoubor s );
built_in(224) int SouborZavıi( TypSoubor& s );
built_in(225) int SouborUı¡zni( TypSoubor s );

built_in(226) unsigned Soubor¬tiBlok( TypSoubor s, void* blok, unsigned Velikost );
built_in(227) int      Soubor¬tiZnak( TypSoubor s );
built_in(228) unsigned Soubor¬tiCüetØzec( TypSoubor s, char* retezec, unsigned max_delka );
built_in(247) unsigned Soubor¬tiSüetØzec( TypSoubor s, string& retezec );

built_in(229) unsigned SouborPiçBlok( TypSoubor s, void* blok, unsigned Velikost );
built_in(230) int SouborPiçZnak( TypSoubor s, char c );
built_in(231) int SouborPiçüetØzec( TypSoubor s, char* retezec );

built_in(232) int SouborDataPlatn ( TypSoubor s );
built_in(321) int SouborKonec( TypSoubor s );
built_in(233) int SouborChyba( TypSoubor s );

built_in(322) unsigned SouborHandle( TypSoubor s );
built_in(323) int SouborJeZaı¡zen¡( TypSoubor s );
built_in(324) int SouborPıipravenPro¬ten¡( TypSoubor s );
built_in(325) int SouborPıipravenProZ pis( TypSoubor s );

// nastaven¡ pozice souboru odkud
# define SouborPoziceOdZaŸ tku  0
# define SouborPoziceOdAktu ln¡ 1
# define SouborPoziceOdKonce    2

built_in(234) long SouborPozice( TypSoubor s );
built_in(235) long SouborNastavPozici( TypSoubor s, long pozice, int odkud );
built_in(236) long SouborVelikost( TypSoubor s );

built_in(237) int SouborDatumA¬as( TypSoubor s, TypDatum& datum, Typ¬as& cas );
built_in(238) int SouborNastavDatumA¬as( TypSoubor s, TypDatum& datum, Typ¬as& cas );

built_in(239) int SouborPiçL¬¡slo( TypSoubor s, long d, int delka );
built_in(240) int SouborPiçU¬¡slo( TypSoubor s, unsigned d, int delka );
built_in(241) int SouborPiçD¬¡slo( TypSoubor s, double d, int delka, int desetinna_delka );
# define          SouborPiçNovìü dek(s) (SouborPiçZnak((s),'\n'))

built_in(242) int Soubor¬tiI¬¡slo( TypSoubor s, int& cele_cislo );
built_in(243) int Soubor¬tiU¬¡slo( TypSoubor s, unsigned& prirozene_cislo );
built_in(244) int Soubor¬tiD¬¡slo( TypSoubor s, double& realne_cislo );
built_in(245) int Soubor¬tiL¬¡slo( TypSoubor s, long& velke_cele_cislo );
built_in(246) int Soubor¬tiNovìü dek( TypSoubor s );

// myç
typedef struct {
  char Typ;
  char TlaŸ¡tka;
  int  X, Y;
  long ¬as;
  } TypMyçUd lost;

built_in(0) TypMyçUd lost gMyçUd lost;

typedef struct {
  int  X, Y;
  char TlaŸ¡tka;
  } TypMyçStav;

// ud lost myçi - Typ
#define MyçUd lost¦ dn                 0 // § dn  ud lost nebyla zaznamen na
#define MyçUd lostPohyb                1 // pohyb myçi - zmØna souıadnice
#define MyçUd lostLev‚TlDol…           2 // lev‚ tlaŸ¡tko dol… - dr§eno
#define MyçUd lostLev‚TlNahoru         4 // lev‚ tlaŸ¡tko nahoru - puçtØno
#define MyçUd lostPrav‚TlDol…          8 // prav‚ tlaŸ¡tko dol… - dr§eno
#define MyçUd lostPrav‚TlNahoru       16 // prav‚ tlaŸ¡tko nahoru - puçtØno
#define MyçUd lostProstıedn¡TlDol…    32 // stıedn¡ tlaŸ¡tko dol… - dr§eno
#define MyçUd lostProstıedn¡TlNahoru  64 // stıedn¡ tlaŸ¡tko nahoru - puçtØno

// tlaŸ¡tka myçi (maska)
#define MyçTlLev‚       1 // lev‚ tlaŸ¡tko dr§eno
#define MyçTlPrav‚      2 // prav‚ tlaŸ¡tko dr§eno
#define MyçTlProstıedn¡ 4 // stıedn¡ tlaŸ¡tko dr§eno
#define MyçTlShift      8 // Shift pıeıaÔovaŸ dr§en
#define MyçTlCtrl      16 // Ctrl pıeıaÔovaŸ dr§en
#define MyçTlAlt       32 // Alt pıeıaÔovaŸ dr§en

built_in(248) int MyçZaŸ tekObsluhy();
built_in(249) void MyçKonecObsluhy();
built_in(250) void MyçZobrazKurzor();
built_in(251) void MyçSchovejKurzor();
built_in(252) void MyçStav( TypMyçStav& stav );
built_in(253) void Myç¬tiUd lost( TypMyçUd lost& udalost );
built_in(254) void MyçNastavPozici( int x, int y );
built_in(255) void MyçNastavRozsah( int minx, int miny, int maxx, int maxy );
built_in(256) void MyçNastavGrKurzor( TypPıedmØt pıedmØt );
built_in(318) void MyçZmØåGrKurzor( TypPıedmØt pıedmØt );
built_in(257) void MyçNastavTxtKurzor( unsigned and_mask, unsigned xor_mask );
built_in(319) void MyçZmØåTxtKurzor( unsigned and_mask, unsigned xor_mask );
built_in(258) void MyçVypr zdniFrontuUd lost¡();


// obsluha kl vesnice
typedef struct {
  char Typ;
  char Kl vesa;
  unsigned PıeıaÔovaŸe;
  long ¬as;
  } TypKlUd lost;

built_in(1) TypKlUd lost gKlUd lost;

// ud lost kl vesnice - Typ
#define KlUd lost¦ dn      0 // § dn  ud lost nebyla zaznamen na
#define KlUd lostKlDol…    1 // kl vesa dol… - dr§ena
#define KlUd lostKlNahoru  2 // kl vesa nahoru - puçtØna

// pıeıaÔovaŸe kl vesnice
#define KlPıeıaÔovaŸPravìShift  (1<< 0) // prav  Shift stisknuta
#define KlPıeıaÔovaŸLevìShift   (1<< 1) // lev  Shift stisknuta
#define KlPıeıaÔovaŸShift       (KlPıeıaÔovaŸPravìShift|KlPıeıaÔovaŸLevìShift) // libovoln  Shift
#define KlPıeıaÔovaŸCtrl        (1<< 2) // libovoln  Ctrl stisknuta
#define KlPıeıaÔovaŸAlt         (1<< 3) // libovoln  Alt stisknuta
#define KlPıeıaÔovaŸLevìCtrl    (1<< 8) // lev  Ctrl stisknuta
#define KlPıeıaÔovaŸLevìAlt     (1<< 9) // lev  Alt stisknuta
#define KlPıeıaÔovaŸSysReq      (1<<10) // SysReq stisknuta
#define KlPıeıaÔovaŸScrollLock  (1<<12) // ScrollLock stisknuta
#define KlPıeıaÔovaŸNumLock     (1<<13) // NumLock stisknuta
#define KlPıeıaÔovaŸCapsLock    (1<<14) // CapsLock stisknuta
#define KlPıeıaÔovaŸInsert      (1<<15) // Insert stisknuta

#define KlPıeıaÔovaŸStavScrollLock (1<< 4) // pıep¡naŸ ScrollLock zapnut
#define KlPıeıaÔovaŸStavNumLock    (1<< 5) // pıep¡naŸ NumLock zapnut
#define KlPıeıaÔovaŸStavCapsLock   (1<< 6) // pıep¡naŸ CapsLock zapnut
#define KlPıeıaÔovaŸStavInsert     (1<< 7) // pıep¡naŸ Insert zapnut

built_in(260) void KlZaŸ tekObsluhy( int AutoOpakov n¡ );
built_in(261) void KlKonecObsluhy();
built_in(262) int  KlKl vesaStisknuta( int Kl vesa );
built_in(263) unsigned KlPıeıaÔovaŸe();
built_in(264) void Kl¬tiUd lost( TypKlUd lost& udalost );
built_in(265) void KlVypr zdniFrontuUd lost¡();

// p…vodn¡ kl vesnice XT/AT - 83 kl ves
# define KlScanEsc                      1
# define KlScan1                        2
# define KlScan2                        3
# define KlScan3                        4
# define KlScan4                        5
# define KlScan5                        6
# define KlScan6                        7
# define KlScan7                        8
# define KlScan8                        9
# define KlScan9                       10
# define KlScan0                       11
# define KlScanM¡nus                   12
# define KlScanRovn¡tko                13
# define KlScanBackspace               14
# define KlScanTab                     15
# define KlScanQ                       16
# define KlScanW                       17
# define KlScanE                       18
# define KlScanR                       19
# define KlScanT                       20
# define KlScanY                       21
# define KlScanU                       22
# define KlScanI                       23
# define KlScanO                       24
# define KlScanP                       25
# define KlScanLev Hranat Z vorka      26
# define KlScanPrav Hranat Z vorka     27
# define KlScanEnter                   28
# define KlScanLevìCtrl                29
# define KlScanA                       30
# define KlScanS                       31
# define KlScanD                       32
# define KlScanF                       33
# define KlScanG                       34
# define KlScanH                       35
# define KlScanJ                       36
# define KlScanK                       37
# define KlScanL                       38
# define KlScanStıedn¡k                39
# define KlScanApostrof                40
# define KlScanVlnovka                 41
# define KlScanLevìShift               42
# define KlScanZpØtn‚Lom¡tko           43
# define KlScanZ                       44
# define KlScanX                       45
# define KlScanC                       46
# define KlScanV                       47
# define KlScanB                       48
# define KlScanN                       49
# define KlScanM                       50
# define KlScan¬ rka                   51
# define KlScanTeŸka                   52
# define KlScanLom¡tko                 53
# define KlScanPravìShift              54
# define KlScanHvØzdiŸka               55
# define KlScanLevìAlt                 56
# define KlScanMezern¡k                57
# define KlScanCapsLock                58
# define KlScanF1                      59
# define KlScanF2                      60
# define KlScanF3                      61
# define KlScanF4                      62
# define KlScanF5                      63
# define KlScanF6                      64
# define KlScanF7                      65
# define KlScanF8                      66
# define KlScanF9                      67
# define KlScanF10                     68
# define KlScanNumLock                 69
# define KlScanScrollLock              70
# define KlScanNum7                    71
# define KlScanNum8                    72
# define KlScanNum9                    73
# define KlScanNumM¡nus                74
# define KlScanNum4                    75
# define KlScanNum5                    76
# define KlScanNum6                    77
# define KlScanNumPlus                 78
# define KlScanNum1                    79
# define KlScanNum2                    80
# define KlScanNum3                    81
# define KlScanNum0                    82
# define KlScanNumTeŸka                83
//  84 kl vesov  AT
# define KlScanSysRq                   84
// 101 kl vesov  AT
# define KlScanF11                     87
# define KlScanF12                     88
// specifick‚ pro Baltazara
# define KlScanPravìAlt                89
# define KlScanPravìCtrl               90
# define KlScanDoleva                  91
# define KlScanDoprava                 92
# define KlScanNahoru                  93
# define KlScanDol…                    94
# define KlScanIns                     95
# define KlScanDel                     96
# define KlScanHome                    97
# define KlScanEnd                     98
# define KlScanPageUp                  99
# define KlScanPageDown               100
# define KlScanNumEnter               101
# define KlScanNumLom¡tko             102

// animovan‚ objekty
typedef long TypAnimPıedmØt;

built_in(267) TypAnimPıedmØt AnimPıedmØtVytvoı( TypPıedmØt prvn¡_pıedmØt,
                               unsigned poŸet_pıedmØt…,
                               int m¢d_animace, int transparentn¡ );

built_in(268) void AnimPıedmØtZruç( TypAnimPıedmØt& objekt );
built_in(269) void AnimPıedmØtAnimuj( TypAnimPıedmØt objekt,
                     int x, int y, int Ÿ¡slo_f ze );
built_in(270) void AnimPıedmØtSchovej( TypAnimPıedmØt objekt );
built_in(271) int  AnimNastavGrVìstup( int vìstup );
built_in(272) int  AnimPıedmØtPoziceX( TypAnimPıedmØt objekt );
built_in(273) int  AnimPıedmØtPoziceY( TypAnimPıedmØt objekt );
built_in(274) int  AnimPıedmØtF ze( TypAnimPıedmØt objekt );
built_in(275) void AnimPıedmØtDejPıed( TypAnimPıedmØt objekt,
                                     TypAnimPıedmØt pıed_co );
built_in(276) void AnimPıedmØtDejZa( TypAnimPıedmØt objekt, TypAnimPıedmØt za_co );
built_in(277) int  AnimPıedmØtKolidujeS( TypAnimPıedmØt objekt, TypAnimPıedmØt s_kterìm );
built_in(278) int  AnimPıedmØtZobrazen( TypAnimPıedmØt objekt );

// heap
built_in(280) void* malloc( unsigned Velikost );
built_in(281) void  free( void* pamØœ );
built_in(282) void* realloc( void* pamØœ, unsigned nov _velikost );

built_in(280) void* HromadaAlokujPamØœ( unsigned Velikost );
built_in(281) void  HromadaUvolniPamØœ( void* pamØœ );
built_in(282) void* HromadaZnovuAlokujPamØœ( void* pamØœ, unsigned nov _velikost );

built_in(283) unsigned HromadaVoln PamØœ();
built_in(284) unsigned HromadaVoln Souvisl PamØœ();

// string
built_in(285) unsigned StrVelikost( string& Str );
built_in(286) string&  StrNastavVelikost( string& Str, unsigned Velikost );
built_in(  2) unsigned StrD‚lka( char* Str );

built_in(287) string&  StrVlo§( string& Str, string Str2, unsigned Pozice );
built_in(288) string&  StrSma§( string& Str, unsigned Pozice, unsigned PoŸet );
built_in(327) int      StrSma§PodıetØzec( string& Str, unsigned Pozice, char* SubStr );
built_in(328) unsigned StrPozicePodıetØzce( char* Str, unsigned Pozice, char* SubStr );
built_in(289) string   StrKopie( char* Str, unsigned Pozice, unsigned PoŸet );
built_in(290) string   StrL¬¡slo( long ¬¡slo, int D‚lka );
built_in(291) string   StrD¬¡slo( double ¬¡slo, int D‚lka, int Desetinn D‚lka );

built_in(292) string&  StrVytvoı( string& Str );
built_in(293) string&  StrZruç( string& Str );

built_in(308) string   StrNaMal ( char* Str );
built_in(309) string   StrNaVelk ( char* Str );
built_in(310) string   StrBezDiakritiky( char* Str );
built_in(311) string   StrZnak( int Znak, unsigned PoŸet );

built_in(294) string   ProgramCesta();

// joystick
typedef struct TypJoystickStav1 {
  int  X, Y;
  char TlaŸ¡tko[2];
  } TypJoystickStav[2];

built_in(295) void Joystick¬ti( struct TypJoystickStav1* Joystick );

built_in(296) long Syst‚movìTikot();

// datum
built_in(297) int       DatumPlatnì( TypDatum& Datum );
built_in(298) TypDatum& DatumPosuå( TypDatum& Datum, int Roky, int MØs¡ce, long Dny );
built_in(299) long      DatumRozd¡l( TypDatum& Datum1, TypDatum& Datum2 );
built_in(300) TypDatum& DatumNastavDenTìdne( TypDatum& Datum );
built_in(301) int       ¬asPlatnì( Typ¬as& ¬as );
built_in(302) Typ¬as&   ¬asPosuå( Typ¬as& ¬as, long Hodiny, long Minuty, long Sekundy, long Setiny );
built_in(303) long      ¬asRozd¡l( Typ¬as& ¬as1, Typ¬as& ¬as2 );
built_in(304) void      Datum¬asPosuå( TypDatum& Datum, Typ¬as& ¬as,
                          int Roky, int MØs¡ce, long Dny,
                          long Hodiny, long Minuty, long Sekundy, long Setiny );
built_in(305) void      Datum¬asRozd¡l( TypDatum& Datum1, Typ¬as& ¬as1,
                          TypDatum& Datum2, Typ¬as& ¬as2,
                          long& Dny, long& Setiny );

# define __BALTAZAR__
# endif
