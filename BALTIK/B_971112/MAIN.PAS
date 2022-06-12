
{ ======================================================================= }
{                                CHYBY                                    }
{ ======================================================================= }
{ Pozor - v Delphi 1 se špatnì pøedává jako parametr funkcí typ LongInt ! }
{ viz funkce TStream.Seek nebo DispMaskIcon - nelze pøedat èíslo pøedmìtu }
{ (pøedáva se pouze nižší slovo jako Smallint)                            }
{                                                                         }
{ Pozor - v Delphi 1 nefunguje pøíkaz CASE pro promìnnou Longint !        }
{                                                                         }
{ Má-li být výsledkem èíselné operace Longint, je nutno pøetypovat        }
{ promìnné Integer na Longint(x), jinak se výpoèet provádí pouze jako     }
{ Integer a mùže pøetéct.                                                 }
{                                                                         }
{ Obrázky napø. pro GLYPH tlaèítek nesmí mít 16 barev - Delphi            }
{ nepoužívají pro nì palety. Musí být míò nebo víc - zde se používá       }
{ 17 palet.                                                               }
{ ======================================================================= }

{ ======================================================================= }
{                                 Udìlat
{ ======================================================================= }
{ - Pøi ukládání scény a programu ukládat pøi zmìnì jména i banky         }
{   pøedmìtù.                                                             }
{ - Ve verzi 32-bitù (Delphi 3) nefunguje pøekrývání pøedmìtù             }
{ - dodìlat úplnou podporu klávesnice (i posun ikonkou)                   }
{ - zabránit výbìru neexistujícího pøedmìtu pro jiné režimy než editace   }
{ ======================================================================= }

unit Main;

{$IFDEF WIN32}
 {$DEFINE PROTECT_MODE}
{$ELSE}
 {$DEFINE REAL_MODE}
{$ENDIF}

interface


uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, ExtCtrls, TabNotBk, Buttons, Select, Ikona,
{$IFDEF PROTECT_MODE}
  ComCtrls,
{$ENDIF}
  StdCtrls, Exec, About, About0, Edit, Org, IniFiles, Spin, Yes, Help;

const
  Verze = '2.0';
{ definice plochy s ikonami }
  IconWidth = 39;                        { šíøka jedné ikony }
  IconWidthL = (IconWidth+7) and not 7;  { zaokrouhlená šíøka }
  IconHeight = 29;                       { výška ikony }
  IconXNum = 15;                         { poèet ikon horizontálnì }
  IconYNum = 10;                         { poèet ikon vertikálnì }
  IconPageNum = IconXNum * IconYNum;     { celkový poèet ikon }

  SubColors = 17;                        { poèet náhradních barev }
  MaxBank = 200;                         { max. poèet bank }
  MaxProgSize = 16000;                   { maximálnì instrukcí programu }
  MaxZasob = 1000;                       { maximální velikost zásobníku }
  HighLongint = 100000000;               { max. èislo }

  SizeHeadBank = 4 + 3*16;               { velikost záhlaví banky }

  DefName = 'Balti';         { implicitní jméno programu a souborù }
  DefBanka = 'BALTBANK';     { implicitní jméno banky }

{ Definice kurzorù }
  ID_LUPAMINSCURSOR = 30500;
  ID_LUPAPLUSCURSOR = 30501;
  ID_RUKACURSOR     = 30502;
  ID_RUKADRZICURSOR = 30503;
  ID_RUKAPLUSCURSOR = 30504;
  ID_RUKAUKAZCURSOR = 30505;
  ID_TUZKACURSOR    = 30506;

{ Definice identifikátorù RESOURCE textù }
  ID_CZ = 1000;
  ID_EN = 2000;

  IDS_CAPTION              = 0;

  IDS_MENU_SKLADEJ_SCENA  = 20;
  IDS_MENU_SKLADEJ_UPRAV  = 40;
  IDS_MENU_SKLADEJ_ZOBRAZ = 50;
  IDS_MENU_SKLADEJ_VOLBY  = 60;
  IDS_MENU_SKLADEJ_HELP   = 70;

  IDS_MENU_CARUJ_SCENA    = 80;
  IDS_MENU_CARUJ_UPRAV    = 100;
  IDS_MENU_CARUJ_ZOBRAZ   = 120;
  IDS_MENU_CARUJ_VOLBY    = 130;
  IDS_MENU_CARUJ_HELP     = 140;

  IDS_MENU_PROGR_PROGRAM  = 150;
  IDS_MENU_PROGR_UPRAV    = 170;
  IDS_MENU_PROGR_ZOBRAZ   = 270;
  IDS_MENU_PROGR_VOLBY    = 280;
  IDS_MENU_PROGR_HELP     = 290;

  IDS_MAINFORM            = 300;
  IDS_TABBED_0            = 320;
  IDS_TABBED_1            = 330;
  IDS_TABBED_2            = 345;
  IDS_PROGRAM_ICON        = 360;

  IDS_ABOUT               = 400;
  IDS_SELECT              = 410;
  IDS_EDIT                = 420;
  IDS_HLAS                = 450;

type
  TypSmer = (smerVychod, smerJih, smerZapad, smerSever);

  PScenFile = ^TScenFile;
  TScenFile = packed record
    sfIdent:   array [0..3] of Char;   { = "2w#E" }
    sfXXX1:    Smallint;               { = 5 }
    sfSmer:    Smallint;               { 1=vpravo, 2=dolù,
                                         3=vlevo, 4=nahoru }
    sfXXX2:    Smallint;               { = 0 }
    sfSloupec: Smallint;               { = 1 až 15 }
    sfRadek:   Smallint;               { = 1 až 10 }
    sfXXX3:    Byte;                   { = 0 }
    sfSloupcu: Smallint;               { = 15 }
    sfRadku:   Smallint;               { = 10 }
    sfData: array [0..(IconPageNum-1)] of Longint;
     { data jsou ukládána postupnì po sloupcích shora dolù !!! }
  end;

  PSceneBuff = ^TSceneBuff;
  TSceneBuff = packed record
    sbScenes: array [0..99] of TScenFile;
  end;

  TProgFile = packed record
    pfIdent: array [0..2] of Char;
    pfVerze: Byte;
    pfProgSize: Smallint;
    pfData: array [0..(MaxProgSize-1)] of Longint;
  end;

  TZasobnik = packed record
    zasCitac: array [0..(MaxZasob-1)] of Longint;
    zasIndex: array [0..(MaxZasob-1)] of Integer;
    zasCitProg: array [0..(MaxZasob-1)] of Integer;
    zasRadek: array [0..(MaxZasob-1)] of Integer;
  end;

  TBankIcon = packed record
    biLastX: Byte;   { 38, horizontálnì poslední bod }
    biPruchod: Byte; { prùchodnost, 1=je, 0=není }
    biLastY: Byte;   { 28, vertikálnì poslední bod }
    biMaskCol: Shortint; { maskovací barva, -1=není }
    biData: array [0..(IconWidthL*IconHeight*4 div 8 - 1)] of Byte;
    biRes3: Byte;    { $D8 }
    biRes4: Byte;    { $D3 }
  end;

  TBankBitmap = packed record     { jeden øádek obrázkù banky }
    BankIcon: array [0..IconXNum - 1] of TBankIcon;
  end;

  TBMPBitmap = packed record      { jeden øádek obrázkù bitmapy }
    bmFileHeader: TBitmapFileHeader;
    bmInfoHeader: TBitmapInfoHeader;
    bmPalette: array [0..SubColors-1] of TRGBQuad;
    bmData: array [0..((IconWidth*IconXNum+3) and not 3)*IconHeight-1] of Byte;
  end;

  PBank = ^TBank;
  TBank = packed record          { popisovaè banky pøedmìtù }
    bnBitmap: TBitmap;
    bnColor:  array [0..IconPageNum-1] of Shortint;  { index masky, -1=není }
    bnPruchod: array [0..IconPageNum-1] of Byte;    { 1=prùchodný, 0=není }
  end;

  PBanks = ^TBanks;
  TBanks = array [0..MaxBank-1] of PBank;

  EResourceError = class(Exception);

  TMainForm = class(TForm)
    MainMenuScene: TMainMenu;
    MenuSceneSoubor: TMenuItem;
    MenuSceneSouborNovy: TMenuItem;
    MenuSceneSouborOtevrit: TMenuItem;
    MenuSceneSouborUlozit: TMenuItem;
    N1: TMenuItem;
    MenuSceneSouborKonec: TMenuItem;
    MenuSceneZobraz: TMenuItem;
    MenuSceneZobrazSkladej: TMenuItem;
    MenuSceneZobrazCaruj: TMenuItem;
    MenuSceneZobrazProgramuj: TMenuItem;
    MenuSceneHelp: TMenuItem;
    MenuSceneHelpAbout: TMenuItem;
    Tabbed: TTabbedNotebook;
    PanelStatus: TPanel;
    PanelScene: TPanel;
    PanelSpeedScene: TPanel;
    ButtonLoadScene: TSpeedButton;
    ButtonSaveScene: TSpeedButton;
    ButtonNewScene: TSpeedButton;
    ButtonSelectScene: TSpeedButton;
    ButtonEditScene: TSpeedButton;
    ButtonHelpScene: TSpeedButton;
    ButtonExitScene: TSpeedButton;
    OpenDialogScene: TOpenDialog;
    PanelSpeedScene2: TPanel;
    ButtonLoadScene2: TSpeedButton;
    ButtonSaveScene2: TSpeedButton;
    ButtonNewScene2: TSpeedButton;
    ButtonKrokScene2: TSpeedButton;
    ButtonEditScene2: TSpeedButton;
    ButtonHelpScene2: TSpeedButton;
    ButtonExitScene2: TSpeedButton;
    ButtonVlevoScene2: TSpeedButton;
    ButtonVpravoScene2: TSpeedButton;
    ButtonCarujScene2: TSpeedButton;
    ButtonSelectScene2: TSpeedButton;
    PanelScene2: TPanel;
    PanelProgramSpeed: TPanel;
    PanelSpeedProgram: TPanel;
    ButtonLoadProgram: TSpeedButton;
    ButtonSaveProgram: TSpeedButton;
    ButtonNewProgram: TSpeedButton;
    ButtonStartProgram: TSpeedButton;
    ButtonEditProgram: TSpeedButton;
    ButtonHelpProgram: TSpeedButton;
    ButtonExitProgram: TSpeedButton;
    ButtonPauseProgram: TSpeedButton;
    ButtonSelectProgram: TSpeedButton;
    MainMenuProgram: TMainMenu;
    MenuProgramSoubor: TMenuItem;
    MenuProgramSouborNovy: TMenuItem;
    MenuProgramSouborOtevrit: TMenuItem;
    MenuProgramSouborUlozit: TMenuItem;
    MenuItem5: TMenuItem;
    MenuProgramSouborKonec: TMenuItem;
    MenuProgramHelp: TMenuItem;
    MenuProgramHelpAbout: TMenuItem;
    MainMenuScene2: TMainMenu;
    MenuScene2Soubor: TMenuItem;
    MenuScene2SouborNovy: TMenuItem;
    MenuScene2SouborOtevrit: TMenuItem;
    MenuScene2SouborUlozit: TMenuItem;
    MenuItem6: TMenuItem;
    MenuScene2SouborKonec: TMenuItem;
    MenuScene2Help: TMenuItem;
    MenuScene2HelpAbout: TMenuItem;
    MenuSceneUprav: TMenuItem;
    MenuSceneUpravPredmet: TMenuItem;
    MenuSceneUpravKresli: TMenuItem;
    MenuScene2Uprav: TMenuItem;
    MenuScene2UpravKresli: TMenuItem;
    MenuScene2UpravPredmet: TMenuItem;
    MenuScene2UpravKrok: TMenuItem;
    N2: TMenuItem;
    MenuScene2UpravVlevo: TMenuItem;
    MenuScene2UpravVpravo: TMenuItem;
    MenuScene2UpravZnovu: TMenuItem;
    PanelSceneX: TPanel;
    ImageScene: TImage;
    PanelScene2X: TPanel;
    ImageScene2: TImage;
    SaveDialogScene: TSaveDialog;
    TimerScene: TTimer;
    MenuScene2Zobraz: TMenuItem;
    MenuScene2ZobrazProgramuj: TMenuItem;
    MenuScene2ZobrazCaruj: TMenuItem;
    MenuScene2ZobrazSkladej: TMenuItem;
    MenuProgramZobraz: TMenuItem;
    MenuProgramZobrazProgramuj: TMenuItem;
    MenuProgramZobrazCaruj: TMenuItem;
    MenuProgramZobrazSkladej: TMenuItem;
    PanelProgramImage: TPanel;
    ImageProgram: TImage;
    PanelProgramHScroll: TPanel;
    ScrollBarProgramH: TScrollBar;
    PanelProgramH: TPanel;
    ScrollBarProgramV: TScrollBar;
    OpenDialogProgram: TOpenDialog;
    SaveDialogProgram: TSaveDialog;
    ImageProgramMenu: TImage;
    MenuProgramUprav: TMenuItem;
    MenuProgramUpravKresli: TMenuItem;
    MenuProgramUpravPredmet: TMenuItem;
    N3: TMenuItem;
    MenuProgramUpravKrok: TMenuItem;
    MenuProgramUpravCislice: TMenuItem;
    MenuProgramUpravCislice0: TMenuItem;
    MenuProgramUpravCislice1: TMenuItem;
    MenuProgramUpravCislice2: TMenuItem;
    MenuProgramUpravCislice3: TMenuItem;
    MenuProgramUpravCislice4: TMenuItem;
    MenuProgramUpravCislice5: TMenuItem;
    MenuProgramUpravCislice6: TMenuItem;
    MenuProgramUpravCislice7: TMenuItem;
    MenuProgramUpravCislice8: TMenuItem;
    MenuProgramUpravCislice9: TMenuItem;
    MenuProgramUpravMezera: TMenuItem;
    MenuProgramUpravNevidit: TMenuItem;
    MenuProgramUpravCekat: TMenuItem;
    MenuProgramUpravKlavesa: TMenuItem;
    MenuProgramUpravVymazat: TMenuItem;
    MenuProgramUpravPipnout: TMenuItem;
    MenuProgramUpravNeplatny: TMenuItem;
    MenuProgramUpravOblak: TMenuItem;
    MenuProgramUpravOblakVyp: TMenuItem;
    MenuProgramUpravOblakZap: TMenuItem;
    MenuProgramUpravNeviditZap: TMenuItem;
    MenuProgramUpravNeviditVyp: TMenuItem;
    MenuProgramUpravOtocit: TMenuItem;
    MenuProgramUpravOtocitVlevo: TMenuItem;
    MenuProgramUpravOtocitVpravo: TMenuItem;
    MenuProgramUpravOtocitJih: TMenuItem;
    MenuProgramUpravOtocitVychod: TMenuItem;
    MenuProgramUpravOtocitZapad: TMenuItem;
    MenuProgramUpravOtocitSever: TMenuItem;
    MenuProgramUpravRychlost: TMenuItem;
    MenuProgramUpravOpakovat: TMenuItem;
    MenuProgramUpravZavorka: TMenuItem;
    MenuProgramUpravZavorkaLeva: TMenuItem;
    MenuProgramUpravZavorkaPrava: TMenuItem;
    MenuProgramUpravKonec: TMenuItem;
    MenuSceneVolby: TMenuItem;
    MenuSceneVolbyEN: TMenuItem;
    MenuSceneVolbyCZ: TMenuItem;
    MenuScene2Volby: TMenuItem;
    MenuScene2VolbyCZ: TMenuItem;
    MenuScene2VolbyEN: TMenuItem;
    MenuProgramVolby: TMenuItem;
    MenuProgramVolbyCZ: TMenuItem;
    MenuProgramVolbyEN: TMenuItem;
    MenuProgramSouborStart: TMenuItem;
    MenuProgramSouborPause: TMenuItem;
    EditScene: TEdit;
    SpinScene: TSpinButton;
    LabelNum2: TLabel;
    MenuSceneHelpHelp: TMenuItem;
    MenuScene2HelpHelp: TMenuItem;
    MenuProgramHelpHelp: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ButtonLoadSceneClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SetSceneName(Jmeno: string);
    procedure SetProgramName(Jmeno: string);
    procedure CaptionInit;
    function NovaScena(Sender: TObject): Boolean;
    function TestSceneModi(Sender: TObject): Boolean;
    procedure ShowHint(Sender: TObject);
    procedure TabbedClick(Sender: TObject);
    procedure ButtonNewSceneClick(Sender: TObject);
    procedure LoadScene(JmenoSceny: string);
    procedure SceneInit;
    function InitPal: HPalette;
    procedure ButtonExitClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DispScene;
    procedure DispIconScene(Cislo: Longint; Pozice,Radek: Integer);
    procedure ButtonSelectSceneClick(Sender: TObject);
    procedure ImageSceneMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageSceneDrop(X, Y: Integer);
    procedure ButtonSaveSceneClick(Sender: TObject);
    function SaveSceneClick(Sender: TObject): Boolean;
    procedure ImageSceneMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DispBaltScene;
    procedure ButtonVlevoScene2Click(Sender: TObject);
    procedure ButtonVpravoScene2Click(Sender: TObject);
    procedure ButtonKrokScene2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TimerSceneTimer(Sender: TObject);
    procedure ButtonSelectScene2Click(Sender: TObject);
    procedure ButtonCarujScene2Click(Sender: TObject);
    procedure MenuSceneZobrazSkladejClick(Sender: TObject);
    procedure MenuSceneZobrazCarujClick(Sender: TObject);
    procedure MenuSceneZobrazProgramujClick(Sender: TObject);
    procedure ButtonNewProgramClick(Sender: TObject);
    procedure ButtonLoadProgramClick(Sender: TObject);
    procedure ButtonSaveProgramClick(Sender: TObject);
    function NovyProgram(Sender: TObject): Boolean;
    function SaveProgramClick(Sender: TObject): Boolean;
    function TestProgramModi(Sender: TObject): Boolean;
    procedure DispProgram;
    procedure LoadProgram;
    procedure DispIconProgram(Cislo: Longint;Pozice,Radek: Integer;
                  Zruseno: Boolean);
    procedure ProgInitLines;
    procedure ScrollInit;
    procedure SetProgramTopLine(Radek: Integer);
    procedure ScrollBarProgramVChange(Sender: TObject);
    procedure ScrollBarProgramHChange(Sender: TObject);
    procedure SetProgramTopPoz(Pozice: Integer);
    procedure ImageProgramMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageProgramDrop(X, Y: Integer);
    procedure ImageProgramMenuMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageProgramMenuMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonSelectProgramClick(Sender: TObject);
    procedure ImageProgramMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MenuProgramUpravMezeraClick(Sender: TObject);
    procedure ProgramVlozPredmet(Predmet: Longint);
    procedure MenuProgramUpravKrokClick(Sender: TObject);
    procedure MenuProgramUpravCekatClick(Sender: TObject);
    procedure MenuProgramUpravKlavesaClick(Sender: TObject);
    procedure MenuProgramUpravOblakVypClick(Sender: TObject);
    procedure MenuProgramUpravOblakZapClick(Sender: TObject);
    procedure MenuProgramUpravVymazatClick(Sender: TObject);
    procedure MenuProgramUpravPipnoutClick(Sender: TObject);
    procedure MenuProgramUpravOtocitVlevoClick(Sender: TObject);
    procedure MenuProgramUpravOtocitVpravoClick(Sender: TObject);
    procedure MenuProgramUpravOtocitVychodClick(Sender: TObject);
    procedure MenuProgramUpravOtocitJihClick(Sender: TObject);
    procedure MenuProgramUpravOtocitZapadClick(Sender: TObject);
    procedure MenuProgramUpravOtocitSeverClick(Sender: TObject);
    procedure MenuProgramUpravNeviditZapClick(Sender: TObject);
    procedure MenuProgramUpravNeviditVypClick(Sender: TObject);
    procedure MenuProgramUpravNeplatnyClick(Sender: TObject);
    procedure MenuProgramUpravRychlostClick(Sender: TObject);
    procedure MenuProgramUpravCislice0Click(Sender: TObject);
    procedure MenuProgramUpravCislice1Click(Sender: TObject);
    procedure MenuProgramUpravCislice2Click(Sender: TObject);
    procedure MenuProgramUpravCislice3Click(Sender: TObject);
    procedure MenuProgramUpravCislice4Click(Sender: TObject);
    procedure MenuProgramUpravCislice5Click(Sender: TObject);
    procedure MenuProgramUpravCislice6Click(Sender: TObject);
    procedure MenuProgramUpravCislice7Click(Sender: TObject);
    procedure MenuProgramUpravCislice8Click(Sender: TObject);
    procedure MenuProgramUpravCislice9Click(Sender: TObject);
    procedure MenuProgramUpravOpakovatClick(Sender: TObject);
    procedure MenuProgramUpravZavorkaLevaClick(Sender: TObject);
    procedure MenuProgramUpravZavorkaPravaClick(Sender: TObject);
    procedure MenuProgramUpravKonecClick(Sender: TObject);
    procedure ButtonStartProgramClick(Sender: TObject);
    procedure ButtonPauseProgramClick(Sender: TObject);
    procedure MenuSceneHelpAboutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ButtonEditProgramClick(Sender: TObject);
    procedure ButtonEditSceneClick(Sender: TObject);
    procedure LoadResTxt;
    procedure MenuSceneVolbyENClick(Sender: TObject);
    procedure MenuSceneVolbyCZClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure SpinSceneDownClick(Sender: TObject);
    procedure SpinSceneUpClick(Sender: TObject);
    procedure EditSceneKeyPress(Sender: TObject; var Key: Char);
    procedure LabelNum2Click(Sender: TObject);
    procedure MenuSceneHelpHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure LoadBanka(Jmeno: string; Cislo: Integer; Banka: PBank);
  function LoadResBitmap(Jmeno: string): HBitmap;
  procedure DispMaskIcon(DestCanvas: TCanvas; DestX,DestY: Integer;
       SrcBanks: PBanks; Banka, Predmet: Integer);

  function LoadResString(Cislo: Integer): string;

const
{ èísla ikonek Baltíka }
  BAL_PODKLAD = 000001;
  BAL_ZED = 000002;
  BAL_CARUJ_FAZE1 = 100031;
  BAL_KONEC_CERVENY = 101009;
  BAL_VOLBA_IKONY = 101010;
  BAL_EDITACE = 101011;
  BAL_NACTI_OTAZNIK = 101012;
  BAL_ULOZ_OTAZNIK = 101013;
  BAL_KONEC = 101014;
  BAL_RYCHLOST = 101015;
  BAL_VLEVO_SEDY = 101016;
  BAL_KROK_SEDY = 101017;
  BAL_VPRAVO_SEDY = 101018;
  BAL_CARUJ_SEDY = 101019;
  BAL_CARUJ = BAL_CARUJ_SEDY;
  BAL_VYMAZ_SEDY = 101020;
  BAL_0 = 101021;
  BAL_1 = 101022;
  BAL_2 = 101023;
  BAL_3 = 101024;
  BAL_4 = 101025;
  BAL_5 = 101026;
  BAL_6 = 101027;
  BAL_7 = 101028;
  BAL_8 = 101029;
  BAL_9 = 101030;
  BAL_NIC_SEDA = 101032;
  BAL_NACTI = 101035;
  BAL_ULOZ = 101036;
  BAL_KROK = 101037;
  BAL_VLEVO = 101038;
  BAL_VPRAVO = 101039;
  BAL_NEVID_ZAP = 101040;
  BAL_NEVID_VYP = 101041;
  BAL_CEKEJ_CAS = 101042;
  BAL_CEKEJ_KLAV = 101043;
  BAL_VYMAZ = 101044;
  BAL_PIPNI = 101045;
  BAL_KRAT = 101068;
  BAL_LEVA_ZAVORKA = 101069;
  BAL_PRAVA_ZAVORKA = 101070;
  BAL_NEPLATNE = 101071;
  BAL_VYCHOD = 101072;
  BAL_JIH = 101073;
  BAL_ZAPAD = 101074;
  BAL_SEVER = 101075;
  BAL_START_STRANKY = 101076;
  BAL_NIC = 101082;
  BAL_CR = 101083;
  BAL_NEPLATNE_SEDE = 101084;
  BAL_DISKETA_OTAZNIK = 101086;
  BAL_CARUJ_VYBER_SEDY = 101087;
  BAL_CARUJ_VYP = 101088;
  BAL_CARUJ_ZAP = 101089;
  BAL_START = 101112;

  DefPalette: array [0..4*SubColors-1] of Byte = (
     0,   0,   0,  0,    {  0: èerná }
     0, 170,   0,  0,    {  1: zelená }
     0,   0, 255,  0,    {  2: svìtle modrá }
     0,   0, 170,  0,    {  3: modrá }
   170,   0,  85,  0,    {  4: fialová }
   170,   0,   0,  0,    {  5: èervená }
   170, 170,  85,  0,    {  6: hnìdá }
   170, 170, 170,  0,    {  7: šedá }
    85,  85,  85,  0,    {  8: tmavì šedá }
     0, 255,   0,  0,    {  9: svìtle zelená }
     0, 255, 255,  0,    { 10: svìtle modrozelená }
   170,  85, 255,  0,    { 11: svìtle fialová }
   255,  85,  85,  0,    { 12: svìtle èervená }
   255, 170,   0,  0,    { 13: oranžová }
   255, 255,   0,  0,    { 14: žlutá }
   255, 255, 255,  0,    { 15: bílá }
     3,   3,   3,  0);   { 16: nutný doplnìk kvùli Delphi }

  MenuPredmet: array [0..31] of Longint = (
   BAL_NIC,       BAL_KROK,         BAL_VLEVO,         BAL_VPRAVO,
   BAL_NEVID_ZAP, BAL_NEVID_VYP,    BAL_CEKEJ_CAS,     BAL_CEKEJ_KLAV,
   BAL_CARUJ_VYP, BAL_CARUJ_ZAP,    BAL_VYMAZ,         BAL_PIPNI,
   BAL_VYCHOD,    BAL_JIH,          BAL_ZAPAD,         BAL_SEVER,

   BAL_NEPLATNE,  BAL_RYCHLOST,     BAL_0,             BAL_1,
   BAL_2,         BAL_3,            BAL_4,             BAL_5,
   BAL_6,         BAL_7,            BAL_8,             BAL_9,
   BAL_KRAT,      BAL_LEVA_ZAVORKA, BAL_PRAVA_ZAVORKA, BAL_CR);

var
  MainForm: TMainForm;
  AboutBoxOK: Boolean;
  HomeDir: string;
  EditName: string;
  EditAktDir: string;
  IniFile: TIniFile;

{ skládání a èarování scény }
  AktDirScene: string;
  SceneName: string;
  ScenBuff: ^TScenFile;
  SceneModi: Boolean;
  SceneBank: TBanks;
  SceneSubX: Real;
  SceneSubY: Real;
  SceneSubC: Integer;
  SceneNext: Word;
  SceneNum: Word;

{ výbìr pøedmìtù }
  PosledniPredmet: Longint;
  SelBanks: PBanks;
  SelIndex: Integer;
  IkonBanks: PBanks;

{ editace programu }
  AktDirProgram: string;
  ProgramName: string;
  ProgBuff: ^TProgFile;
  ProgramModi: Boolean;
  ProgramBank: TBanks;
  ProgSceneBuff: PSceneBuff;

  ProgTopLine: Integer;
  ProgTopIndex: Integer;
  ProgLeftPoz: Integer;
  ProgLines: Integer;
  ProgXPage: Integer;
  ProgYPage: Integer;
  ProgXMax: Integer;
  ProgOldIndex: Integer;

{ bìh programu }
  ExecBuff: ^TScenFile;
  ExecSubX: Real;          { èást kroku ve smìru X, 0=není }
  ExecSubXX: Integer;      { pøíští souøadnice X, -1=není }
  ExecSubY: Real;          { èást kroku ve smìru Y, 0=není }
  ExecSubYY: Integer;      { pøíští souøadnice Y, -1=není }
  ExecSubC: Integer;       { ukazatel fáze èarování, 0=není }
  ExecSubCX: Integer;      { souøadnice èarování X, -1=není }
  ExecSubCY: Integer;      { souøadnice èarování Y, -1=není }
  ExecCitac: Integer;
  ExecIndex: Integer;
  BeziProgram: Boolean;
  ExecBitmap: TBitmap;
  ExecTempBitmap: TBitmap;
  ExecVidit: Boolean;
  ExecRychlost: Integer;
  ExecPredmet: Longint;
  ExecOblak: Boolean;
  ExecLine: Integer;
  ExecTopLine: Integer;
  ExecFast: Boolean;

  Zasobnik: ^TZasobnik;
  ZasobPocet: Integer;
  ZasobNeniZavorka: Integer;

{ texty }
  JazykID: Integer;           { ID jazyka pro Resource }

  TextCaptScen1: string;      { - Baltík }
  TextCaptScen2: string;      { nová scéna - Baltík }
  TextCaptScen3: string;      { (scéna) - Baltík }
  TextCaptProg1: string;      { - Baltík }
  TextCaptProg2: string;      { nový program - Baltík }
  TextCaptProg3: string;      { (program) - Baltík }

  TextCekImpl: string;        { èekejte .... implicitní }
  TextCekScen: string;        { èekejte .... scénu }
  TextCekProg: string;        { èekejte .... program }

  TextModiScen1: string;      { scéna byla zmìnìna - 1 }
  TextModiScen2: string;      { scéna byla zmìnìna - 2 }
  TextModiProg1: string;      { program byla zmìnìn - 1 }
  TextModiProg2: string;      { program byla zmìnìn - 2 }

  TextNepruch: string;        { (neprùchodný) }
  TextPredmet: string;        { Pøedmìt }

  TextPrikaz: array[0..31] of string;  { popisy pøíkazù }

implementation

{$R *.DFM}

{ ================================================================ }
{                                                                  }
{                          Hlavní formuláø                         }
{                                                                  }
{ ================================================================ }

procedure TMainForm.FormCreate(Sender: TObject);
var Bitmap: TBitmap;
    I,J: Integer;
    Text0: array[0..4095] of Char;
    Text1: string;
begin
{ pøíprava systémových ukazatelù }
  HomeDir := ExtractFilePath(ExpandFileName(ParamStr(0)));

{ naètení konfigurace }
  GetProfileString('intl','sLanguage','ENU',Text0,SizeOf(Text0));
  Text1 := AnsiUpperCase(StrPas(Text0));
  if Text1 = 'CSY' then I := 1
    else I := 0;

  IniFile := TIniFile.Create(DefName+'.INI');
  I := IniFile.ReadInteger(DefName,'Language',I);
  Case I of
    1: JazykID := ID_CZ;
  else JazykID := ID_EN;
  end;

  SceneNum := 200;

  SetSceneName(ExpandFileName(
    IniFile.ReadString(DefName,'Scene',HomeDir + DefName)));
  SetProgramName(ExpandFileName(
    IniFile.ReadString(DefName,'Program',HomeDir + DefName)));

  IniFile.Free;

  SceneModi := False;
  ProgramModi := False;
  Tabbed.PageIndex := 0;
  AboutBoxOK := False;

{ naètení kurzorù }
  Screen.Cursors[ID_LUPAMINSCURSOR] := LoadCursor(HInstance,'LUPAMINSCURSOR');
  Screen.Cursors[ID_LUPAPLUSCURSOR] := LoadCursor(HInstance,'LUPAPLUSCURSOR');
  Screen.Cursors[ID_RUKACURSOR] := LoadCursor(HInstance,'RUKACURSOR');
  Screen.Cursors[ID_RUKADRZICURSOR] := LoadCursor(HInstance,'RUKADRZICURSOR');
  Screen.Cursors[ID_RUKAPLUSCURSOR] := LoadCursor(HInstance,'RUKAPLUSCURSOR');
  Screen.Cursors[ID_RUKAUKAZCURSOR] := LoadCursor(HInstance,'RUKAUKAZCURSOR');
  Screen.Cursors[ID_TUZKACURSOR] := LoadCursor(HInstance,'TUZKACURSOR');

  MenuSceneVolbyEN.Checked := JazykID = ID_EN;
  MenuSceneVolbyCZ.Checked := JazykID = ID_CZ;
  MenuScene2VolbyEN.Checked := JazykID = ID_EN;
  MenuScene2VolbyCZ.Checked := JazykID = ID_CZ;
  MenuProgramVolbyEN.Checked := JazykID = ID_EN;
  MenuProgramVolbyCZ.Checked := JazykID = ID_CZ;

  LoadResTxt;

  ScrollBarProgramH.Align := alClient;
  ScrollBarProgramV.Align := alRight;
  ImageProgram.Align := alClient;

  SelBanks := @SceneBank;
  IkonBanks := @SceneBank;
  SelIndex := 0;
  PosledniPredmet := BAL_ZED;
  BeziProgram := False;
  SceneSubX := 0;
  SceneSubY := 0;
  SceneSubC := 0;
  SceneNext := 0;
  ExecCitac := 0;
  ZasobPocet := 0;

{  Application.HelpFile := HomeDir + DefName + '.hlp';}
  Application.OnHint := ShowHint;
{  Application.HintPause := 800;}

{ pøíprava bufferù }
  New(ScenBuff);
  New(ExecBuff);
  New(ProgBuff);
  New(Zasobnik);
  New(ProgSceneBuff);

  with ProgBuff^ do
  begin
    pfIdent[0] := 'B';
    pfIdent[1] := 'P';
    pfIdent[2] := 'R';
    pfVerze := 1;
    pfProgSize := 0;
  end;
  ProgTopLine := 0;
  ProgTopIndex := 0;
  ProgLeftPoz := 0;
  ProgLines := 0;
  ProgXMax := 0;
  ScrollInit;

  for I := 0 to MaxBank-1 do
  begin
    New(SceneBank[I]);
    with SceneBank[I]^ do
    begin
      bnBitmap := nil;
      for J := 0 to IconPageNum-1 do
      begin
        if I = 100 then
          bnColor[J] := 4
        else
          bnColor[J] := -1;
        bnPruchod[J] := 1;
      end;
    end; { with SceneBank[I]^ }
    New(ProgramBank[I]);
    with ProgramBank[I]^ do
    begin
      bnBitmap := nil;
      for J := 0 to IconPageNum-1 do
      begin
        if I = 100 then
          bnColor[J] := 4
        else
          bnColor[J] := -1;
        bnPruchod[J] := 1;
      end;
    end; { with ProgramBank[I]^ }
  end; { for I }

{ pøíprava plochy ke skládání scény }
  Bitmap := TBitmap.Create;
  Bitmap.Width := IconXNum*IconWidth;
  Bitmap.Height := IconYNum*IconHeight;
  ImageScene.Picture.Graphic := Bitmap;
  ImageScene.Picture.Bitmap.Palette := InitPal;

{ pøíprava plochy k èarování scény }
  Bitmap := TBitmap.Create;
  Bitmap.Width := IconXNum*IconWidth;
  Bitmap.Height := IconYNum*IconHeight;
  ImageScene2.Picture.Graphic := Bitmap;
  ImageScene2.Picture.Bitmap.Palette := InitPal;

{ pøíprava plochy k programování }
  Bitmap := TBitmap.Create;
  Bitmap.Width := ImageProgram.Width;  { IconXNum*IconWidth;}
  Bitmap.Height := ImageProgram.Height;  { IconYNum*IconHeight;}
  ImageProgram.Picture.Graphic := Bitmap;
  ImageProgram.Picture.Bitmap.Palette := InitPal;

{ pøíprava plochy k bìhu programu }
  Bitmap := TBitmap.Create;
  Bitmap.Width := IconXNum*IconWidth;
  Bitmap.Height := IconYNum*IconHeight;
  ExecBitmap := Bitmap;
  ExecBitmap.Palette := InitPal;

  Bitmap := TBitmap.Create;
  Bitmap.Width := IconXNum*IconWidth;
  Bitmap.Height := IconYNum*IconHeight;
  ExecTempBitmap := Bitmap;
  ExecTempBitmap.Palette := InitPal;

{ inicializace palet tlaèítek }
  ButtonLoadScene.Glyph.Palette := InitPal;
  ButtonSaveScene.Glyph.Palette := InitPal;
  ButtonNewScene.Glyph.Palette := InitPal;
  ButtonSelectScene.Glyph.Palette := InitPal;
  ButtonEditScene.Glyph.Palette := InitPal;
  ButtonHelpScene.Glyph.Palette := InitPal;
  ButtonExitScene.Glyph.Palette := InitPal;

  ButtonLoadScene2.Glyph.Palette := InitPal;
  ButtonSaveScene2.Glyph.Palette := InitPal;
  ButtonNewScene2.Glyph.Palette := InitPal;
  ButtonKrokScene2.Glyph.Palette := InitPal;
  ButtonVlevoScene2.Glyph.Palette := InitPal;
  ButtonVpravoScene2.Glyph.Palette := InitPal;
  ButtonSelectScene2.Glyph.Palette := InitPal;
  ButtonCarujScene2.Glyph.Palette := InitPal;
  ButtonEditScene2.Glyph.Palette := InitPal;
  ButtonHelpScene2.Glyph.Palette := InitPal;
  ButtonExitScene2.Glyph.Palette := InitPal;

  ButtonLoadProgram.Glyph.Palette := InitPal;
  ButtonSaveProgram.Glyph.Palette := InitPal;
  ButtonNewProgram.Glyph.Palette := InitPal;
  ButtonStartProgram.Glyph.Palette := InitPal;
  ButtonPauseProgram.Glyph.Palette := InitPal;
  ButtonSelectProgram.Glyph.Palette := InitPal;
  ButtonEditProgram.Glyph.Palette := InitPal;
  ButtonHelpProgram.Glyph.Palette := InitPal;
  ButtonExitProgram.Glyph.Palette := InitPal;
{  ImageProgramMenu.Picture.Bitmap.Palette := InitPal;}

{ naètení banky pøedmìtù }
  Screen.Cursor := crHourGlass;

  with ScenBuff^ do
  begin
    for J := 0 to (IconYNum-1) do
     for I := 0 to (IconXNum-1) do
       sfData[J+I*IconYNum] := BAL_PODKLAD;
    sfIdent[0] := '2'; sfIdent[1] := 'w';
    sfIdent[2] := '#'; sfIdent[3] := 'E';
    sfXXX1 := 5;
    sfSmer := 1;
    sfXXX2 := 0;
    sfSloupec := 1;
    sfRadek := 10;
    sfXXX3 := 0;
    sfSloupcu := 15;
    sfRadku := 10;
  end;
{  BaltikX := 0;
  BaltikY := IconYNum-1;}

  Case SceneNum of
    200: if FileExists(AktDirScene+SceneName+'.S00') then
           LoadScene(AktDirScene+SceneName+'.S00')
         else
           LoadScene(AktDirScene+SceneName+'.BSC');
    201..209: LoadScene(AktDirScene+SceneName+'.S0'+IntToStr(SceneNum-200));
  else        LoadScene(AktDirScene+SceneName+'.S'+IntToStr(SceneNum-200));
  end;
  LoadProgram;
  Screen.Cursor := crDefault;
  FormResize(Sender);
  TabbedClick(Sender);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var I: Integer;
begin
  Dispose(ScenBuff);
  ScenBuff := nil;
  Dispose(ExecBuff);
  ExecBuff := nil;
  Dispose(ProgBuff);
  ProgBuff := nil;
  Dispose(Zasobnik);
  Zasobnik := nil;
  Dispose(ProgSceneBuff);
  ProgSceneBuff := nil;
  ExecBitmap.Free;
  ExecTempBitmap.Free;

  for I := 0 to MaxBank-1 do
  begin
    with SceneBank[I]^ do
      if Assigned(bnBitmap) then
      begin
        bnBitmap.Free;
        bnBitmap := nil;
      end;

    Dispose(SceneBank[I]);
    SceneBank[I] := nil;

    with ProgramBank[I]^ do
      if Assigned(bnBitmap) then
      begin
        bnBitmap.Free;
        bnBitmap := nil;
      end;

    Dispose(ProgramBank[I]);
    ProgramBank[I] := nil;

  end;   { for I }

end;

procedure TMainForm.LoadResTxt;
var I: Integer;
begin
  Application.Title := LoadResString(IDS_CAPTION+1);

  TextCaptScen1 := LoadResString(IDS_CAPTION+2); { - Baltík }
  TextCaptScen2 := LoadResString(IDS_CAPTION+3); { nová scéna - Baltík }
  TextCaptScen3 := LoadResString(IDS_CAPTION+4); { (scéna) - Baltík }
  TextCaptProg1 := LoadResString(IDS_CAPTION+5); { - Baltík }
  TextCaptProg2 := LoadResString(IDS_CAPTION+6); { nový program - Baltík }
  TextCaptProg3 := LoadResString(IDS_CAPTION+7); { (program) - Baltík }

  OpenDialogScene.Title := LoadResString(IDS_MAINFORM+0);
  OpenDialogScene.Filter := LoadResString(IDS_MAINFORM+1);
  SaveDialogScene.Title := LoadResString(IDS_MAINFORM+2);
  SaveDialogScene.Filter := LoadResString(IDS_MAINFORM+3);
  OpenDialogProgram.Title := LoadResString(IDS_MAINFORM+4);
  OpenDialogProgram.Filter := LoadResString(IDS_MAINFORM+5);
  SaveDialogProgram.Title := LoadResString(IDS_MAINFORM+6);
  SaveDialogProgram.Filter := LoadResString(IDS_MAINFORM+7);

  TextCekImpl := LoadResString(IDS_MAINFORM+8);{ èekejte .... implicitní }
  TextCekScen := LoadResString(IDS_MAINFORM+9); { èekejte .... scénu }
  TextCekProg := LoadResString(IDS_MAINFORM+10); { èekejte .... program }

  TextModiScen1 := LoadResString(IDS_MAINFORM+11); { scéna zmìnìna }
  TextModiScen2 := LoadResString(IDS_MAINFORM+12); { scéna zmìnìna }
  TextModiProg1 := LoadResString(IDS_MAINFORM+13); { program zmìnìn }
  TextModiProg2 := LoadResString(IDS_MAINFORM+14); { program zmìnìn }

  TextNepruch:= LoadResString(IDS_MAINFORM+15);  { neprùchodný }
  TextPredmet:= LoadResString(IDS_MAINFORM+16);  { Pøedmìt }


  MenuSceneSoubor.Caption := LoadResString(IDS_MENU_SKLADEJ_SCENA+0);
  MenuSceneSoubor.Hint := LoadResString(IDS_MENU_SKLADEJ_SCENA+1);
  MenuSceneSouborNovy.Caption := LoadResString(IDS_MENU_SKLADEJ_SCENA+2);
  MenuSceneSouborNovy.Hint := LoadResString(IDS_MENU_SKLADEJ_SCENA+3);
  MenuSceneSouborOtevrit.Caption := LoadResString(IDS_MENU_SKLADEJ_SCENA+4);
  MenuSceneSouborOtevrit.Hint := LoadResString(IDS_MENU_SKLADEJ_SCENA+5);
  MenuSceneSouborUlozit.Caption := LoadResString(IDS_MENU_SKLADEJ_SCENA+6);
  MenuSceneSouborUlozit.Hint := LoadResString(IDS_MENU_SKLADEJ_SCENA+7);
  MenuSceneSouborKonec.Caption := LoadResString(IDS_MENU_SKLADEJ_SCENA+8);
  MenuSceneSouborKonec.Hint := LoadResString(IDS_MENU_SKLADEJ_SCENA+9);

  MenuSceneUprav.Caption := LoadResString(IDS_MENU_SKLADEJ_UPRAV+0);
  MenuSceneUprav.Hint := LoadResString(IDS_MENU_SKLADEJ_UPRAV+1);
  MenuSceneUpravPredmet.Caption := LoadResString(IDS_MENU_SKLADEJ_UPRAV+2);
  MenuSceneUpravPredmet.Hint := LoadResString(IDS_MENU_SKLADEJ_UPRAV+3);
  MenuSceneUpravKresli.Caption := LoadResString(IDS_MENU_SKLADEJ_UPRAV+4);
  MenuSceneUpravKresli.Hint := LoadResString(IDS_MENU_SKLADEJ_UPRAV+5);

  MenuSceneZobraz.Caption := LoadResString(IDS_MENU_SKLADEJ_ZOBRAZ+0);
  MenuSceneZobraz.Hint := LoadResString(IDS_MENU_SKLADEJ_ZOBRAZ+1);
  MenuSceneZobrazSkladej.Caption := LoadResString(IDS_MENU_SKLADEJ_ZOBRAZ+2);
  MenuSceneZobrazSkladej.Hint := LoadResString(IDS_MENU_SKLADEJ_ZOBRAZ+3);
  MenuSceneZobrazCaruj.Caption := LoadResString(IDS_MENU_SKLADEJ_ZOBRAZ+4);
  MenuSceneZobrazCaruj.Hint := LoadResString(IDS_MENU_SKLADEJ_ZOBRAZ+5);
  MenuSceneZobrazProgramuj.Caption := LoadResString(IDS_MENU_SKLADEJ_ZOBRAZ+6);
  MenuSceneZobrazProgramuj.Hint := LoadResString(IDS_MENU_SKLADEJ_ZOBRAZ+7);

  MenuSceneVolby.Caption := LoadResString(IDS_MENU_SKLADEJ_VOLBY+0);
  MenuSceneVolby.Hint := LoadResString(IDS_MENU_SKLADEJ_VOLBY+1);
  MenuSceneVolbyEN.Caption := LoadResString(IDS_MENU_SKLADEJ_VOLBY+2);
  MenuSceneVolbyEN.Hint := LoadResString(IDS_MENU_SKLADEJ_VOLBY+3);
  MenuSceneVolbyCZ.Caption := LoadResString(IDS_MENU_SKLADEJ_VOLBY+4);
  MenuSceneVolbyCZ.Hint := LoadResString(IDS_MENU_SKLADEJ_VOLBY+5);

  MenuSceneHelp.Caption := LoadResString(IDS_MENU_SKLADEJ_HELP+0);
  MenuSceneHelp.Hint := LoadResString(IDS_MENU_SKLADEJ_HELP+1);
  MenuSceneHelpHelp.Caption := LoadResString(IDS_MENU_SKLADEJ_HELP+2);
  MenuSceneHelpHelp.Hint := LoadResString(IDS_MENU_SKLADEJ_HELP+3);
  MenuSceneHelpAbout.Caption := LoadResString(IDS_MENU_SKLADEJ_HELP+4);
  MenuSceneHelpAbout.Hint := LoadResString(IDS_MENU_SKLADEJ_HELP+5);


  MenuScene2Soubor.Caption := LoadResString(IDS_MENU_CARUJ_SCENA+0);
  MenuScene2Soubor.Hint := LoadResString(IDS_MENU_CARUJ_SCENA+1);
  MenuScene2SouborNovy.Caption := LoadResString(IDS_MENU_CARUJ_SCENA+2);
  MenuScene2SouborNovy.Hint := LoadResString(IDS_MENU_CARUJ_SCENA+3);
  MenuScene2SouborOtevrit.Caption := LoadResString(IDS_MENU_CARUJ_SCENA+4);
  MenuScene2SouborOtevrit.Hint := LoadResString(IDS_MENU_CARUJ_SCENA+5);
  MenuScene2SouborUlozit.Caption := LoadResString(IDS_MENU_CARUJ_SCENA+6);
  MenuScene2SouborUlozit.Hint := LoadResString(IDS_MENU_CARUJ_SCENA+7);
  MenuScene2SouborKonec.Caption := LoadResString(IDS_MENU_CARUJ_SCENA+8);
  MenuScene2SouborKonec.Hint := LoadResString(IDS_MENU_CARUJ_SCENA+9);

  MenuScene2Uprav.Caption := LoadResString(IDS_MENU_CARUJ_UPRAV+0);
  MenuScene2Uprav.Hint := LoadResString(IDS_MENU_CARUJ_UPRAV+1);
  MenuScene2UpravKrok.Caption := LoadResString(IDS_MENU_CARUJ_UPRAV+2);
  MenuScene2UpravKrok.Hint := LoadResString(IDS_MENU_CARUJ_UPRAV+3);
  MenuScene2UpravVlevo.Caption := LoadResString(IDS_MENU_CARUJ_UPRAV+4);
  MenuScene2UpravVlevo.Hint := LoadResString(IDS_MENU_CARUJ_UPRAV+5);
  MenuScene2UpravVpravo.Caption := LoadResString(IDS_MENU_CARUJ_UPRAV+6);
  MenuScene2UpravVpravo.Hint := LoadResString(IDS_MENU_CARUJ_UPRAV+7);
  MenuScene2UpravPredmet.Caption := LoadResString(IDS_MENU_CARUJ_UPRAV+8);
  MenuScene2UpravPredmet.Hint := LoadResString(IDS_MENU_CARUJ_UPRAV+9);
  MenuScene2UpravZnovu.Caption := LoadResString(IDS_MENU_CARUJ_UPRAV+10);
  MenuScene2UpravZnovu.Hint := LoadResString(IDS_MENU_CARUJ_UPRAV+11);
  MenuScene2UpravKresli.Caption := LoadResString(IDS_MENU_CARUJ_UPRAV+12);
  MenuScene2UpravKresli.Hint := LoadResString(IDS_MENU_CARUJ_UPRAV+13);

  MenuScene2Zobraz.Caption := LoadResString(IDS_MENU_CARUJ_ZOBRAZ+0);
  MenuScene2Zobraz.Hint := LoadResString(IDS_MENU_CARUJ_ZOBRAZ+1);
  MenuScene2ZobrazSkladej.Caption := LoadResString(IDS_MENU_CARUJ_ZOBRAZ+2);
  MenuScene2ZobrazSkladej.Hint := LoadResString(IDS_MENU_CARUJ_ZOBRAZ+3);
  MenuScene2ZobrazCaruj.Caption := LoadResString(IDS_MENU_CARUJ_ZOBRAZ+4);
  MenuScene2ZobrazCaruj.Hint := LoadResString(IDS_MENU_CARUJ_ZOBRAZ+5);
  MenuScene2ZobrazProgramuj.Caption := LoadResString(IDS_MENU_CARUJ_ZOBRAZ+6);
  MenuScene2ZobrazProgramuj.Hint := LoadResString(IDS_MENU_CARUJ_ZOBRAZ+7);

  MenuScene2Volby.Caption := LoadResString(IDS_MENU_CARUJ_VOLBY+0);
  MenuScene2Volby.Hint := LoadResString(IDS_MENU_CARUJ_VOLBY+1);
  MenuScene2VolbyEN.Caption := LoadResString(IDS_MENU_CARUJ_VOLBY+2);
  MenuScene2VolbyEN.Hint := LoadResString(IDS_MENU_CARUJ_VOLBY+3);
  MenuScene2VolbyCZ.Caption := LoadResString(IDS_MENU_CARUJ_VOLBY+4);
  MenuScene2VolbyCZ.Hint := LoadResString(IDS_MENU_CARUJ_VOLBY+5);

  MenuScene2Help.Caption := LoadResString(IDS_MENU_CARUJ_HELP+0);
  MenuScene2Help.Hint := LoadResString(IDS_MENU_CARUJ_HELP+1);
  MenuScene2HelpHelp.Caption := LoadResString(IDS_MENU_CARUJ_HELP+2);
  MenuScene2HelpHelp.Hint := LoadResString(IDS_MENU_CARUJ_HELP+3);
  MenuScene2HelpAbout.Caption := LoadResString(IDS_MENU_CARUJ_HELP+4);
  MenuScene2HelpAbout.Hint := LoadResString(IDS_MENU_CARUJ_HELP+5);


  MenuProgramSoubor.Caption := LoadResString(IDS_MENU_PROGR_PROGRAM+0);
  MenuProgramSoubor.Hint := LoadResString(IDS_MENU_PROGR_PROGRAM+1);
  MenuProgramSouborNovy.Caption := LoadResString(IDS_MENU_PROGR_PROGRAM+2);
  MenuProgramSouborNovy.Hint := LoadResString(IDS_MENU_PROGR_PROGRAM+3);
  MenuProgramSouborOtevrit.Caption := LoadResString(IDS_MENU_PROGR_PROGRAM+4);
  MenuProgramSouborOtevrit.Hint := LoadResString(IDS_MENU_PROGR_PROGRAM+5);
  MenuProgramSouborUlozit.Caption := LoadResString(IDS_MENU_PROGR_PROGRAM+6);
  MenuProgramSouborUlozit.Hint := LoadResString(IDS_MENU_PROGR_PROGRAM+7);
  MenuProgramSouborStart.Caption := LoadResString(IDS_MENU_PROGR_PROGRAM+8);
  MenuProgramSouborStart.Hint := LoadResString(IDS_MENU_PROGR_PROGRAM+9);
  MenuProgramSouborPause.Caption := LoadResString(IDS_MENU_PROGR_PROGRAM+10);
  MenuProgramSouborPause.Hint := LoadResString(IDS_MENU_PROGR_PROGRAM+11);
  MenuProgramSouborKonec.Caption := LoadResString(IDS_MENU_PROGR_PROGRAM+12);
  MenuProgramSouborKonec.Hint := LoadResString(IDS_MENU_PROGR_PROGRAM+13);

  MenuProgramUprav.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+0);
  MenuProgramUprav.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+1);
  MenuProgramUpravMezera.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+2);
  MenuProgramUpravMezera.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+3);
  MenuProgramUpravKrok.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+4);
  MenuProgramUpravKrok.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+5);
  MenuProgramUpravOtocit.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+6);
  MenuProgramUpravOtocit.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+7);
  MenuProgramUpravOtocitVlevo.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+8);
  MenuProgramUpravOtocitVlevo.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+9);
  MenuProgramUpravOtocitVpravo.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+10);
  MenuProgramUpravOtocitVpravo.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+11);
  MenuProgramUpravOtocitVychod.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+12);
  MenuProgramUpravOtocitVychod.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+13);
  MenuProgramUpravOtocitJih.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+14);
  MenuProgramUpravOtocitJih.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+15);
  MenuProgramUpravOtocitZapad.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+16);
  MenuProgramUpravOtocitZapad.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+17);
  MenuProgramUpravOtocitSever.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+18);
  MenuProgramUpravOtocitSever.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+19);
  MenuProgramUpravNevidit.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+20);
  MenuProgramUpravNevidit.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+21);
  MenuProgramUpravNeviditZap.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+22);
  MenuProgramUpravNeviditZap.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+23);
  MenuProgramUpravNeviditVyp.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+24);
  MenuProgramUpravNeviditVyp.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+25);
  MenuProgramUpravCekat.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+26);
  MenuProgramUpravCekat.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+27);
  MenuProgramUpravKlavesa.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+28);
  MenuProgramUpravKlavesa.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+29);
  MenuProgramUpravOblak.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+30);
  MenuProgramUpravOblak.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+31);
  MenuProgramUpravOblakZap.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+32);
  MenuProgramUpravOblakZap.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+33);
  MenuProgramUpravOblakVyp.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+34);
  MenuProgramUpravOblakVyp.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+35);
  MenuProgramUpravVymazat.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+36);
  MenuProgramUpravVymazat.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+37);
  MenuProgramUpravPipnout.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+38);
  MenuProgramUpravPipnout.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+39);
  MenuProgramUpravNeplatny.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+40);
  MenuProgramUpravNeplatny.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+41);
  MenuProgramUpravRychlost.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+42);
  MenuProgramUpravRychlost.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+43);
  MenuProgramUpravCislice.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+44);
  MenuProgramUpravCislice.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+45);
  MenuProgramUpravCislice0.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+46);
  MenuProgramUpravCislice0.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+47);
  MenuProgramUpravCislice1.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+48);
  MenuProgramUpravCislice1.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+49);
  MenuProgramUpravCislice2.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+50);
  MenuProgramUpravCislice2.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+51);
  MenuProgramUpravCislice3.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+52);
  MenuProgramUpravCislice3.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+53);
  MenuProgramUpravCislice4.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+54);
  MenuProgramUpravCislice4.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+55);
  MenuProgramUpravCislice5.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+56);
  MenuProgramUpravCislice5.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+57);
  MenuProgramUpravCislice6.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+58);
  MenuProgramUpravCislice6.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+59);
  MenuProgramUpravCislice7.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+60);
  MenuProgramUpravCislice7.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+61);
  MenuProgramUpravCislice8.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+62);
  MenuProgramUpravCislice8.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+63);
  MenuProgramUpravCislice9.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+64);
  MenuProgramUpravCislice9.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+65);
  MenuProgramUpravOpakovat.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+66);
  MenuProgramUpravOpakovat.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+67);
  MenuProgramUpravZavorka.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+68);
  MenuProgramUpravZavorka.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+69);
  MenuProgramUpravZavorkaLeva.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+70);
  MenuProgramUpravZavorkaLeva.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+71);
  MenuProgramUpravZavorkaPrava.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+72);
  MenuProgramUpravZavorkaPrava.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+73);
  MenuProgramUpravKonec.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+74);
  MenuProgramUpravKonec.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+75);
  MenuProgramUpravPredmet.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+76);
  MenuProgramUpravPredmet.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+77);
  MenuProgramUpravKresli.Caption := LoadResString(IDS_MENU_PROGR_UPRAV+78);
  MenuProgramUpravKresli.Hint := LoadResString(IDS_MENU_PROGR_UPRAV+79);

  MenuProgramZobraz.Caption := LoadResString(IDS_MENU_PROGR_ZOBRAZ+0);
  MenuProgramZobraz.Hint := LoadResString(IDS_MENU_PROGR_ZOBRAZ+1);
  MenuProgramZobrazSkladej.Caption := LoadResString(IDS_MENU_PROGR_ZOBRAZ+2);
  MenuProgramZobrazSkladej.Hint := LoadResString(IDS_MENU_PROGR_ZOBRAZ+3);
  MenuProgramZobrazCaruj.Caption := LoadResString(IDS_MENU_PROGR_ZOBRAZ+4);
  MenuProgramZobrazCaruj.Hint := LoadResString(IDS_MENU_PROGR_ZOBRAZ+5);
  MenuProgramZobrazProgramuj.Caption := LoadResString(IDS_MENU_PROGR_ZOBRAZ+6);
  MenuProgramZobrazProgramuj.Hint := LoadResString(IDS_MENU_PROGR_ZOBRAZ+7);

  MenuProgramVolby.Caption := LoadResString(IDS_MENU_PROGR_VOLBY+0);
  MenuProgramVolby.Hint := LoadResString(IDS_MENU_PROGR_VOLBY+1);
  MenuProgramVolbyEN.Caption := LoadResString(IDS_MENU_PROGR_VOLBY+2);
  MenuProgramVolbyEN.Hint := LoadResString(IDS_MENU_PROGR_VOLBY+3);
  MenuProgramVolbyCZ.Caption := LoadResString(IDS_MENU_PROGR_VOLBY+4);
  MenuProgramVolbyCZ.Hint := LoadResString(IDS_MENU_PROGR_VOLBY+5);

  MenuProgramHelp.Caption := LoadResString(IDS_MENU_PROGR_HELP+0);
  MenuProgramHelp.Hint := LoadResString(IDS_MENU_PROGR_HELP+1);
  MenuProgramHelpHelp.Caption := LoadResString(IDS_MENU_PROGR_HELP+2);
  MenuProgramHelpHelp.Hint := LoadResString(IDS_MENU_PROGR_HELP+3);
  MenuProgramHelpAbout.Caption := LoadResString(IDS_MENU_PROGR_HELP+4);
  MenuProgramHelpAbout.Hint := LoadResString(IDS_MENU_PROGR_HELP+5);

  Tabbed.Pages[0] := '     '+LoadResString(IDS_TABBED_0+0)+'     ';
  ButtonLoadScene.Hint := LoadResString(IDS_TABBED_0+1);
  ButtonSaveScene.Hint := LoadResString(IDS_TABBED_0+2);
  ButtonNewScene.Hint := LoadResString(IDS_TABBED_0+3);
  ButtonSelectScene.Hint := LoadResString(IDS_TABBED_0+4);
  EditScene.Hint := LoadResString(IDS_TABBED_0+5);
  SpinScene.Hint := LoadResString(IDS_TABBED_0+6);
  ButtonEditScene.Hint := LoadResString(IDS_TABBED_0+7);
  ButtonHelpScene.Hint := LoadResString(IDS_TABBED_0+8);
  ButtonExitScene.Hint := LoadResString(IDS_TABBED_0+9);

  Tabbed.Pages[1] := '     '+LoadResString(IDS_TABBED_1+0)+'     ';
  ButtonLoadScene2.Hint := LoadResString(IDS_TABBED_1+1);
  ButtonSaveScene2.Hint := LoadResString(IDS_TABBED_1+2);
  ButtonNewScene2.Hint := LoadResString(IDS_TABBED_1+3);
  ButtonKrokScene2.Hint := LoadResString(IDS_TABBED_1+4);
  ButtonVlevoScene2.Hint := LoadResString(IDS_TABBED_1+5);
  ButtonVpravoScene2.Hint := LoadResString(IDS_TABBED_1+6);
  ButtonSelectScene2.Hint := LoadResString(IDS_TABBED_1+7);
  ButtonCarujScene2.Hint := LoadResString(IDS_TABBED_1+8);
  ButtonEditScene2.Hint := LoadResString(IDS_TABBED_1+9);
  ButtonHelpScene2.Hint := LoadResString(IDS_TABBED_1+10);
  ButtonExitScene2.Hint := LoadResString(IDS_TABBED_1+11);

  Tabbed.Pages[2] := '     '+LoadResString(IDS_TABBED_2+0)+'     ';
  ButtonLoadProgram.Hint := LoadResString(IDS_TABBED_2+1);
  ButtonSaveProgram.Hint := LoadResString(IDS_TABBED_2+2);
  ButtonNewProgram.Hint := LoadResString(IDS_TABBED_2+3);
  ButtonStartProgram.Hint := LoadResString(IDS_TABBED_2+4);
  ButtonPauseProgram.Hint := LoadResString(IDS_TABBED_2+5);
  ButtonSelectProgram.Hint := LoadResString(IDS_TABBED_2+6);
  ButtonEditProgram.Hint := LoadResString(IDS_TABBED_2+7);
  ButtonHelpProgram.Hint := LoadResString(IDS_TABBED_2+8);
  ButtonExitProgram.Hint := LoadResString(IDS_TABBED_2+9);
  ScrollBarProgramH.Hint := LoadResString(IDS_TABBED_2+10);
  ScrollBarProgramV.Hint := LoadResString(IDS_TABBED_2+11);

  for I := 0 to 31 do
    TextPrikaz[I] := '|' + LoadResString(IDS_PROGRAM_ICON+I);

end;

function LoadResString(Cislo: Integer): string;
begin
  Result := LoadStr(Cislo+JazykID);
  if Result = '' then
    Raise EResourceError.Create('Missing RESOURCE string '+IntToStr(Cislo));
end;

function TMainForm.InitPal: HPalette;
var Palety: PLogPalette;
    I: Integer;
begin
  Result := 0;
  GetMem(Palety, SizeOf(TLogPalette)+ SubColors*SizeOf(TPaletteEntry));
  try
    Palety^.palVersion := $300;
    Palety^.palNumEntries := SubColors;
    for I := 0 to SubColors-1 do
    begin
      Palety^.palPalEntry[I].peRed := DefPalette[I*4];
      Palety^.palPalEntry[I].peGreen := DefPalette[I*4+1];
      Palety^.palPalEntry[I].peBlue := DefPalette[I*4+2];
      Palety^.palPalEntry[I].peFlags := DefPalette[I*4+3];
    end;
    Result := CreatePalette(Palety^);
  finally
    FreeMem(Palety, SizeOf(TLogPalette)+ SubColors*SizeOf(TPaletteEntry));
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
var I:Integer;
begin
{ umístìní panelù pro skládání a èarování scény }
  I := (Tabbed.Width - 8 - PanelScene.Width) div 2;
  if I < 0 then I := 0;
  PanelScene.Left := I;
  PanelSpeedScene.Left := I;
  PanelScene2.Left := I;
  PanelSpeedScene2.Left := I;

  I := (Tabbed.Height - 30 - PanelScene.Height
                   - PanelSpeedScene.Height) div 2;
  if I < 0 then I := 0;
  PanelSpeedScene.Top := I;
  PanelScene.Top := I + PanelSpeedScene.Height;
  PanelSpeedScene2.Top := I;
  PanelScene2.Top := PanelScene.Top;

{ umístìní panelù programování }
  I := (Tabbed.Width - 8 - PanelSpeedProgram.Width) div 2;
  if I < 0 then I := 0;
  PanelSpeedProgram.Left := I;

  ScrollInit;
  DispProgram;
end;

procedure TMainForm.MenuSceneZobrazSkladejClick(Sender: TObject);
begin
  Tabbed.PageIndex := 0;
  TabbedClick(Sender);
end;

procedure TMainForm.MenuSceneZobrazCarujClick(Sender: TObject);
begin
  Tabbed.PageIndex := 1;
  TabbedClick(Sender);
end;

procedure TMainForm.MenuSceneZobrazProgramujClick(Sender: TObject);
begin
  Tabbed.PageIndex := 2;
  TabbedClick(Sender);
end;

procedure TMainForm.TabbedClick(Sender: TObject);
begin
  case Tabbed.PageIndex of
    0: Menu := MainMenuScene;
    1: Menu := MainMenuScene2;
    2: Menu := MainMenuProgram;
  end;
  CaptionInit;
  ShowHint(Sender);
  DispScene;
end;

procedure TMainForm.CaptionInit;
begin
  if Tabbed.PageIndex = 2 then
    if ProgramName = '' then
      Caption := TextCaptProg2                 { nový program - Baltík }
    else
      if (ProgramName = SceneName) and (AktDirProgram = AktDirScene) then
        Caption := ProgramName + TextCaptProg1   { - Baltík }
      else
        Caption := ProgramName + TextCaptProg3   { (program) - Baltík }
  else
    if SceneName = '' then
      Caption := TextCaptScen2               { nová scéna - Baltík }
    else
      if (ProgramName = SceneName) and (AktDirProgram = AktDirScene) then
        Caption := SceneName + TextCaptScen1     { - Baltík }
      else
        Caption := SceneName + TextCaptScen3;      { (scéna) - Baltík }
end;

procedure TMainForm.ShowHint(Sender: TObject);
begin
  if Assigned(SelForm) and Assigned(EditForm) and Assigned(OrgForm) then
    if SelForm.Visible or BeziProgram or EditForm.Visible or OrgForm.Visible then
    begin
      if EditForm.Visible then
      begin
        EditForm.PanelStatus.Caption := ' ' + Application.Hint;
        OrgForm.PanelStatus.Caption := '';
      end
      else
        if SelForm.Visible then
        begin
          SelForm.PanelStatus.Caption := ' ' + Application.Hint;
          OrgForm.PanelStatus.Caption := '';
        end
        else
          OrgForm.PanelStatus.Caption := ' ' + Application.Hint;
      PanelStatus.Caption := '';
    end
    else
      PanelStatus.Caption := ' ' + Application.Hint
  else
    PanelStatus.Caption := ' ' + Application.Hint;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := TestSceneModi(Sender);
  if CanClose then
    CanClose := TestProgramModi(Sender);
end;

procedure TMainForm.ButtonExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    VK_LEFT:  begin
                if ActiveControl = EditScene then Exit;
                Key := 0;
                if Tabbed.PageIndex = 1 then
                  ButtonVlevoScene2Click(Sender);
                if Tabbed.PageIndex = 2 then
                  if Shift = [ssCtrl] then
                    SetProgramTopPoz(ProgLeftPoz-ProgXPage+2)
                  else
                    SetProgramTopPoz(ProgLeftPoz-1);
              end;
    VK_RIGHT: begin
                if ActiveControl = EditScene then Exit;
                Key := 0;
                if Tabbed.PageIndex = 1 then
                  ButtonVpravoScene2Click(Sender);
                if Tabbed.PageIndex = 2 then
                  if Shift = [ssCtrl] then
                    SetProgramTopPoz(ProgLeftPoz+ProgXPage-2)
                  else
                    SetProgramTopPoz(ProgLeftPoz+1);
              end;
    VK_UP:    begin
                Key := 0;
                if Tabbed.PageIndex = 1 then
                  ButtonKrokScene2Click(Sender);
                if Tabbed.PageIndex = 2 then
                  SetProgramTopLine(ProgTopLine-1);
              end;
    VK_PRIOR: begin
                Key := 0;
                if Tabbed.PageIndex = 2 then
                  SetProgramTopLine(ProgTopLine-ProgYPage+2);
              end;
    VK_HOME: begin
                if ActiveControl = EditScene then Exit;
                Key := 0;
                if Tabbed.PageIndex = 2 then
                  if ProgLeftPoz = 0 then
                    SetProgramTopLine(0)
                  else
                    SetProgramTopPoz(0);
              end;
    VK_DOWN,VK_SPACE:  begin
                if ActiveControl = EditScene then Exit;
                Key := 0;
                if Tabbed.PageIndex = 1 then
                  ButtonCarujScene2Click(Sender);
                if Tabbed.PageIndex = 2 then
                  SetProgramTopLine(ProgTopLine+1);
              end;
    VK_NEXT: begin
                Key := 0;
                if Tabbed.PageIndex = 2 then
                  SetProgramTopLine(ProgTopLine+ProgYPage-2);
              end;
    VK_END:   begin
                if ActiveControl = EditScene then Exit;
                Key := 0;
                if Tabbed.PageIndex = 2 then
                begin
                  SetProgramTopLine(ProgLines-ProgYPage+3);
                  SetProgramTopPoz(0);
                end;
              end;
    VK_RETURN: begin
                 if ActiveControl = EditScene then Exit;
                 Key := 0;
                 if Tabbed.PageIndex = 1 then
                   ButtonSelectScene2Click(Sender);
               end;
  end;
end;


{ ================================================================ }
{                                                                  }
{                           Obsluha scény                          }
{                                                                  }
{ ================================================================ }

procedure TMainForm.ButtonNewSceneClick(Sender: TObject);
var I: Integer;
begin
  if NovaScena(Sender) then
  begin
    Screen.Cursor := crHourGlass;
    PanelStatus.Caption := TextCekImpl;
    Refresh;
    for I := 0 to MaxBank-1 do
      LoadBanka(HomeDir + DefBanka, I, SceneBank[I]);
    ShowHint(Sender);
    DispScene;
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.ButtonLoadSceneClick(Sender: TObject);
begin
  Case SceneNum of
    200..209: OpenDialogScene.DefaultExt := 's0'+IntToStr(SceneNum-200);
  else        OpenDialogScene.DefaultExt := 's'+IntToStr(SceneNum-200);
  end;
  OpenDialogScene.InitialDir := AktDirScene;
  OpenDialogScene.FileName := SceneName;
  if OpenDialogScene.Execute then
    if NovaScena(Sender) then
    begin
      SetSceneName(OpenDialogScene.FileName);
      Screen.Cursor := crHourGlass;
      PanelStatus.Caption := TextCekScen + SceneName + '...';
      Refresh;
      LoadScene(OpenDialogScene.Filename);
      ShowHint(Sender);
      Screen.Cursor := crDefault;
    end;
end;

procedure TMainForm.ButtonSaveSceneClick(Sender: TObject);
begin
  SaveSceneClick(Sender);
end;

function TMainForm.SaveSceneClick(Sender: TObject): Boolean;
var FileHandle: Integer;
begin
  Result := False;

  Case SceneNum of
    200..209: SaveDialogScene.DefaultExt := 's0'+IntToStr(SceneNum-200);
  else        SaveDialogScene.DefaultExt := 's'+IntToStr(SceneNum-200);
  end;

  SaveDialogScene.InitialDir := AktDirScene;
  SaveDialogScene.FileName := SceneName;
  if SaveDialogScene.Execute then
  begin
    SetSceneName(SaveDialogScene.FileName);
    Screen.Cursor := crHourGlass;
    FileHandle := FileCreate(SaveDialogScene.FileName);
    if FileHandle > 0 then
    try
      FileWrite(FileHandle,ScenBuff^,SizeOf(TScenFile));
      Result := True;
      {ButtonSaveScene.Enabled := False;
      ButtonSaveScene2.Enabled := False;}
      SceneModi := False;
    finally
      FileClose(FileHandle);
    end;
    Screen.Cursor := crDefault;
  end;
end;

function TMainForm.NovaScena(Sender: TObject): Boolean; { True = pokraèovat }
var I,J: Integer;
begin
  if TestSceneModi(Sender) then
  begin
    Result := True;
    {ButtonSaveScene.Enabled := False;
    ButtonSaveScene2.Enabled := False;}
    SceneModi := False;
    SetSceneName(AktDirScene);
    SceneNum := 200;
    with ScenBuff^ do
    begin
      for J := 0 to (IconYNum-1) do
       for I := 0 to (IconXNum-1) do
         sfData[J+I*IconYNum] := BAL_PODKLAD;
      sfIdent[0] := '2'; sfIdent[1] := 'w';
      sfIdent[2] := '#'; sfIdent[3] := 'E';
      sfXXX1 := 5;
      sfSmer := 1;
      sfXXX2 := 0;
      sfSloupec := 1;
      sfRadek := 10;
      sfXXX3 := 0;
      sfSloupcu := 15;
      sfRadku := 10;
    end;
    SceneInit;
    DispScene;
  end
  else
    Result := False;
end;

procedure TMainForm.LoadScene(JmenoSceny: string); { scéna musí být vymazaná !!! }
var FileHandle: Integer;
    I: Integer;
begin
  FileHandle := FileOpen(JmenoSceny,fmOpenRead);
  if FileHandle > 0 then
  try
    FileRead(FileHandle,ScenBuff^,SizeOf(TScenFile));
  finally
    FileClose(FileHandle);
  end;
  for I := 0 to MaxBank-1 do
    LoadBanka(AktDirScene + SceneName, I, SceneBank[I]);
  DispScene;
end;

procedure TMainForm.SceneInit;
{var I,J: Integer;}
begin
{  with ScenBuff^ do
    for J := 0 to IconYNum-1 do
      for I := 0 to IconXNum-1 do
      begin
        Mapa[I,J] := sfData[J+I*IconYNum];
        GridRoom.Cells[I,J] := IntToStr(Mapa[I,J]);
        GridExec.Cells[I,J] := IntToStr(Mapa[I,J]);
        DispIcon(MapaBit.Canvas,Mapa[I,J],
                I*IconWidth,J*IconHeight);
      end;
  BaltikX := 0;
  BaltikY := IconYNum-1;
  BaltikSubX := 0;
  BaltikSubY := 0;
  BaltikVidit := True;
  BaltikSmer := smerVychod;
  BaltikRychlost := 6;
  Oblacek := True;
  ZasobPocet := 0;
  ZasobNeniZavorka := 0;
  CekaKlavesu := False; }
end;

function TMainForm.TestSceneModi(Sender: TObject): Boolean; { True = pokraèovat }
var I: Integer;
begin
  Result := True;
  if SceneModi then
  begin
{    I := MessageDlg(TextModiScen,mtConfirmation, mbYesNoCancel,0);}
    I := Hlaseni(TextModiScen1,TextModiScen2);
    if I = mrCancel then Result := False;
    if I = mrYes then Result := SaveSceneClick(Sender);
  end;
end;

procedure TMainForm.SetSceneName(Jmeno: string);
var SubText: string;
begin
  AktDirScene := ExtractFilePath(Jmeno);
  SceneName := ExtractFileName(Jmeno);
  SceneNum := 200;
  if Pos('.',SceneName) > 0 then
  begin
    SubText := Copy(SceneName,Pos('.',SceneName)+2,2);
    SceneNum := StrToIntDef(SubText,0)+200;
    if SceneNum < 200 then SceneNum := 200;
    if SceneNum > 299 then SceneNum := 299;
    Delete(SceneName,Pos('.',SceneName),200);
  end;
  EditScene.Text := IntToStr(SceneNum-200);
  if Length(EditScene.Text) = 1 then
    EditScene.Text := '0'+EditScene.Text;
  CaptionInit;
end;

procedure TMainForm.DispScene;
var I,J: Integer;
begin
  for I := 0 to IconXNum-1 do
    for J := 0 to IconYNum-1 do
      DispIconScene(ScenBuff^.sfData[J+I*IconYNum],I,J);
  DispBaltScene;
  EditScene.Text := IntToStr(SceneNum-200);
  if Length(EditScene.Text) = 1 then
    EditScene.Text := '0'+EditScene.Text;
end;

procedure TMainForm.DispIconScene(Cislo: Longint;
                               Pozice,Radek: Integer);
var Banka: Integer;
    DRect, SRect: TRect;
begin
  DRect := Rect(Pozice*IconWidth,Radek*IconHeight,
     (Pozice+1)*IconWidth,(Radek+1)*IconHeight);

  Cislo := Cislo - 1;
  if Cislo < 0 then Cislo := BAL_PODKLAD;
  Banka := Cislo div 1000;
  Cislo := Cislo mod 1000;
  Pozice := Cislo mod IconXNum;
  Radek := Cislo div IconXNum;

  SRect := Rect(Pozice*IconWidth,Radek*IconHeight,
     (Pozice+1)*IconWidth,(Radek+1)*IconHeight);

  if Assigned(SceneBank[Banka]^.bnBitmap) then
  begin
    ImageScene.Canvas.CopyRect(DRect,
        SceneBank[Banka]^.bnBitmap.Canvas,SRect);
    ImageScene2.Canvas.CopyRect(DRect,
        SceneBank[Banka]^.bnBitmap.Canvas,SRect);
  end
  else
  begin
    ImageScene.Canvas.Brush.Color := clBlack;
    ImageScene.Canvas.FillRect(DRect);
    ImageScene2.Canvas.Brush.Color := clBlack;
    ImageScene2.Canvas.FillRect(DRect);
  end;
end;

procedure TMainForm.ImageSceneMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var Poz,Rad: Integer;
    Predmet: Longint;
begin
  if (X >= 0) and (X < IconWidth*IconXNum) and
     (Y >= 0) and (Y < IconHeight*IconYNum) then
  begin
    Poz := X div IconWidth;
    Rad := Y div IconHeight;
    Predmet := ScenBuff^.sfData[Rad+Poz*IconYNum];
    if Predmet <> BAL_PODKLAD then
    begin
      ImageScene.Hint := TextPredmet + IntToStr(Predmet);
      if SceneBank[(Predmet-1) div 1000]^.bnPruchod[(Predmet-1) mod 1000] <> 1 then
        ImageScene.Hint := ImageScene.Hint + TextNepruch;
    end

    else
      ImageScene.Hint := '';
  end
  else
    ImageScene.Hint := '';
    ImageScene2.Hint := ImageScene.Hint;
end;

procedure TMainForm.ImageSceneMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Poz, Rad: Integer;
    Bod: TPoint;
begin
  IkonBanks := @SceneBank;
  if (X < 0) or (Y < 0) then Exit;

  Poz := X div IconWidth;
  Rad := Y div IconHeight;

  if (Poz < IconXNum) and (Rad < IconYNum) then
    if ScenBuff^.sfData[Rad+Poz*IconYNum] <> BAL_PODKLAD then
    begin
      IkonForm.Tag := ScenBuff^.sfData[Rad+Poz*IconYNum];
      if not (Button = mbRight) then
      begin
        SceneModi := True;
        {ButtonSaveScene.Enabled := True;
        ButtonSaveScene2.Enabled := True;}
        ScenBuff^.sfData[Rad+Poz*IconYNum] := BAL_PODKLAD;
        DispIconScene(BAL_PODKLAD,Poz,Rad);
        IkonForm.Cursor := ID_RUKADRZICURSOR;
      end
      else
        IkonForm.Cursor := ID_RUKAPLUSCURSOR;

      Update;

      Bod.X := X;
      Bod.Y := Y;
      Bod := Tabbed.ScreenToClient(ImageScene.ClientToScreen(Bod));
      IkonForm.Left := Bod.X - IkonForm.Width div 2;
      IkonForm.Top := Bod.Y - IkonForm.Height div 2;
      IkonForm.ShowModal2;
    end;
end;

procedure TMainForm.ImageSceneDrop(X, Y: Integer);
var Poz, Rad: Integer;
    Predmet: Longint;
begin
  Predmet := IkonForm.Tag;
  if Predmet = -1 then Exit;

  if (X >=0) and (Y >= 0) then
  begin
    Poz := X div IconWidth;
    Rad := Y div IconHeight;
    if Poz >= IconXNum then Exit;
    if Rad >= IconYNum then Exit;

    SceneModi := True;
    {ButtonSaveScene.Enabled := True;
    ButtonSaveScene2.Enabled := True;}
    ScenBuff^.sfData[Rad+Poz*IconYNum] := Predmet;
    DispIconScene(Predmet,Poz,Rad);
  end;
end;

{
procedure TMainForm.DispBalt;
var Cislo: Longint;
    Krok: Integer;
    PozX, PozY: Integer;
begin
  PozX := BaltikX*IconWidth+Round(BaltikSubX);
  PozY := BaltikY*IconHeight+Round(BaltikSubY);

  if BaltikSubX > 0 then
    PaletteCopyRect(GridExec.Canvas,BaltikX*IconWidth,PozY,
     MapaBit,BaltikX*IconWidth,PozY,Round(BaltikSubX),IconHeight);
  if BaltikSubY > 0 then
    PaletteCopyRect(GridExec.Canvas,PozX,BaltikY*IconHeight,
     MapaBit,PozX,BaltikY*IconHeight,IconWidth,Round(BaltikSubY));
  if BaltikSubX < 0 then
    PaletteCopyRect(GridExec.Canvas,PozX+IconWidth,PozY,
     MapaBit,PozX+IconWidth,PozY,-Round(BaltikSubX),IconHeight);
  if BaltikSubY < 0 then
    PaletteCopyRect(GridExec.Canvas,PozX,PozY+IconHeight,
     MapaBit,PozX,PozY+IconHeight,IconWidth,-Round(BaltikSubY));

  Case BaltikSmer of
    smerVychod: Cislo := 100001;
    smerJih:    Cislo := 100006;
    smerZapad:  Cislo := 100011;
    else  Cislo := 100016;
  end;

  Case BaltikSmer of
    smerVychod, smerZapad: Krok := Round(Abs(BaltikSubX)/IconWidth*8);
    else Krok := Round(Abs(BaltikSubY)/IconHeight*8);
  end;

  if BaltikRychlost = 7 then Krok := Krok div 2;
  if BaltikRychlost > 7 then Krok := Krok div 4;

  Case Krok of
    1,5: Inc(Cislo);
    3,7: Inc(Cislo,2);
  end;

  if CekaKlavesu then
    if Frac(Time*24*60*60*4) > 0.5 then Inc(Cislo,3);

  if FazeCaruj > 0 then Inc(Cislo,4);

  if BaltikVidit then
    DispMask(GridExec.Canvas,Cislo,PozX,PozY)
  else
    PaletteCopyRect(GridExec.Canvas,PozX,PozY,
     MapaBit,PozX, PozY, IconWidth, IconHeight);
end;
}



{ ================================================================ }
{                                                                  }
{                           Obsluha pøedmìtù                       }
{                                                                  }
{ ================================================================ }

procedure TMainForm.ButtonSelectSceneClick(Sender: TObject);
begin
  SelBanks := @SceneBank;
  EditName := SceneName;
  EditAktDir := AktDirScene;
  IkonBanks := @SceneBank;
  SelForm.ShowModal;
  if SelForm.Tag <> -1 then
  begin
    Update;
    PosledniPredmet := SelForm.Tag;
    IkonForm.Tag := PosledniPredmet;
    IkonForm.Cursor := ID_RUKAPLUSCURSOR;
    IkonForm.ShowModal2;
  end;
end;

procedure LoadBanka(Jmeno: string; Cislo: Integer; Banka: PBank);
var
  I,J: Integer;
  StreamIn, StreamOut: TMemoryStream;
  BankBitmap: ^TBankBitmap;
  BMPBitmap: ^TBMPBitmap;

{$IFDEF REAL_MODE}
  procedure KonvIcon(Dest, Src: pointer);
  begin
    asm
      push ax
      push bx
      push cx
      push dx
      push si
      push di
      push ds
      push es

      cld
      lds  si,Src
      les  di,Dest
      add  di,((IconWidth*IconXNum+3) and not 3)*(IconHeight-1)
      mov  dx,IconXNum

@@0:  push di
      mov  bh,IconHeight

@@1:  push di
      mov  bl,IconWidthL/8

@@2:  mov  cx,8007h
@@3:  mov  al,ds:[si]
      and  al,ch
      shr  al,cl
      mov  ah,al
      shl  ah,1

      mov  al,ds:[si+IconWidthL/8]
      and  al,ch
      shr  al,cl
      or   ah,al
      shl  ah,1

      mov  al,ds:[si+2*(IconWidthL/8)]
      and  al,ch
      shr  al,cl
      or   ah,al
      shl  ah,1

      mov  al,ds:[si+3*(IconWidthL/8)]
      and  al,ch
      shr  al,cl
      or   al,ah

      stosb

      dec  cl
      shr  ch,1
      jnz  @@3

      inc  si
      dec  bl
      jnz  @@2

      pop  di
      sub  di,(IconWidth*IconXNum+3) and not 3
      add  si,IconWidthL*3/8
      dec  bh
      jnz  @@1

      pop  di
      add  di,IconWidth

      add  si,6
      dec  dx
      jnz  @@0

      pop  es
      pop  ds
      pop  di
      pop  si
      pop  dx
      pop  cx
      pop  bx
      pop  ax
    end;
  end;
{$ENDIF}
{$IFDEF PROTECT_MODE}
  procedure KonvIcon(Dest, Src: pointer);
  begin
    asm
      push eax
      push ebx
      push ecx
      push edx
      push esi
      push edi

      cld
      mov  esi,Src
      mov  edi,Dest
      add  edi,((IconWidth*IconXNum+3) and not 3)*(IconHeight-1)
      mov  dx,IconXNum

@@0:  push edi
      mov  bh,IconHeight

@@1:  push edi
      mov  bl,IconWidthL/8

@@2:  mov  cx,8007h
@@3:  mov  al,[esi]
      and  al,ch
      shr  al,cl
      mov  ah,al
      shl  ah,1

      mov  al,[esi+IconWidthL/8]
      and  al,ch
      shr  al,cl
      or   ah,al
      shl  ah,1

      mov  al,[esi+2*(IconWidthL/8)]
      and  al,ch
      shr  al,cl
      or   ah,al
      shl  ah,1

      mov  al,[esi+3*(IconWidthL/8)]
      and  al,ch
      shr  al,cl
      or   al,ah

      stosb

      dec  cl
      shr  ch,1
      jnz  @@3

      inc  esi
      dec  bl
      jnz  @@2

      pop  edi
      sub  edi,(IconWidth*IconXNum+3) and not 3
      add  esi,IconWidthL*3/8
      dec  bh
      jnz  @@1

      pop  edi
      add  edi,IconWidth

      add  esi,6
      dec  dx
      jnz  @@0

      pop  edi
      pop  esi
      pop  edx
      pop  ecx
      pop  ebx
      pop  eax
    end;
  end;
{$ENDIF}

begin
  with Banka^ do
  begin
    if Assigned(bnBitmap) then bnBitmap.Free;
    bnBitmap := nil;
    for I := 0 to IconPageNum-1 do
    begin
      if Cislo = 100 then
        bnColor[I] := 4
      else
        bnColor[I] := -1;
      bnPruchod[I] := 1;
    end;

    StreamIn := TMemoryStream.Create;
    StreamOut := TMemoryStream.Create;
    try { except }
      New(BankBitmap);
      try { finaly }
        New(BMPBitmap);
        try { finaly }
{ inicializace záhlaví BMP souboru }
          with BMPBitmap^ do
          begin
            with bmFileHeader do
            begin
              bfType := $4d42;
              bfSize := ((IconWidth*IconXNum+3) and not 3)
                            * IconHeight*IconYNum
                            + SizeOf(TBitmapFileHeader)
                            + SizeOf(TBitmapInfoHeader)
                            + SubColors*SizeOf(TRGBQuad);
              bfReserved1 := 0;
              bfReserved2 := 0;
              bfOffBits := SizeOf(TBitmapFileHeader)
                            + SizeOf(TBitmapInfoHeader)
                            + SubColors*SizeOf(TRGBQuad);
            end;

            with bmInfoHeader do
            begin
              biSize := SizeOf(TBitmapInfoHeader);
              biWidth := IconWidth*IconXNum;
              biHeight := IconHeight*IconYNum;
              biPlanes := 1;
              biBitCount := 8;
              biCompression := 0;
              biSizeImage := ((IconWidth*IconXNum+3) and not 3)
                                   * IconHeight*IconYNum;
              biXPelsPerMeter := 640;
              biYPelsPerMeter := 480;
              biClrUsed := SubColors;
              biClrImportant := 0;
            end;

            for I := 0 to SubColors-1 do
            begin
              bmPalette[I].rgbRed := DefPalette[I*4];
              bmPalette[I].rgbGreen := DefPalette[I*4+1];
              bmPalette[I].rgbBlue := DefPalette[I*4+2];
              bmPalette[I].rgbReserved := DefPalette[I*4+3];
            end;
          end;

{ pøíprava jména souboru banky a otevøení souboru banky }
          case Cislo of
            0..9:     Jmeno := Jmeno + '.B0' + IntToStr(Cislo);
            10..99:   Jmeno := Jmeno + '.B'  + IntToStr(Cislo);
            100..109: Jmeno := Jmeno + '.C0' + IntToStr(Cislo-100);
            else      Jmeno := Jmeno + '.C'  + IntToStr(Cislo-100);
          end;

          if not FileExists(Jmeno) then
              Jmeno := HomeDir + DefBanka +
                  ExtractFileExt(ExtractFileName(Jmeno));

          if FileExists(Jmeno) then with BankBitmap^ do
          begin
            StreamIn.LoadFromFile(Jmeno);
            StreamIn.Position := SizeHeadBank;
            StreamOut.Clear;
            StreamOut.SetSize(((IconWidth*IconXNum+3) and not 3)
                                 * IconHeight*IconYNum
                                  + SizeOf(TBitmapFileHeader)
                                  + SizeOf(TBitmapInfoHeader)
                                  + SubColors*SizeOf(TRGBQuad));
            StreamOut.WriteBuffer(BMPBitmap^,
                              SizeOf(TBitmapFileHeader)
                               + SizeOf(TBitmapInfoHeader)
                               + SubColors*SizeOf(TRGBQuad));
            StreamOut.Seek(-SizeOf(BMPBitmap^.bmData),2);
{ Pozor - v Delphi 1 nefunguje absolutní nastaveni Position > 64 KB ! }
            for I := IconYNum-1 downto 0 do
            begin
              StreamIn.ReadBuffer(BankIcon[0],SizeOf(TBankBitmap));
              for J := 0 to IconXNum - 1 do
              begin
                bnColor[(IconYNum-I-1)*IconXNum+J] := BankIcon[J].biMaskCol;
                bnPruchod[(IconYNum-I-1)*IConXNum+J] := BankIcon[J].biPruchod;
              end;
              KonvIcon(@(BMPBitmap^.bmData[0]),@(BankIcon[0].biData[0]));
              StreamOut.WriteBuffer(BMPBitmap^.bmData,
                                    SizeOf(BMPBitmap^.bmData));
              StreamOut.Seek(-SizeOf(BMPBitmap^.bmData)*2,1);
            end; { for IconYNum }
            StreamOut.Position := 0;
            bnBitmap := TBitmap.Create;
            bnBitmap.LoadFromStream(StreamOut);
          end { if FileExists(Jmeno) }
          else
          begin
            Case Cislo of
              0:
                begin
                  bnBitmap := TBitmap.Create;
                  bnBitmap.Handle := LoadResBitmap(
                          'BANKA00'+IntToStr(Cislo)+'BITMAP');
                  bnBitmap.Palette := MainForm.InitPal;
                end;
              100,101:
                begin
                  bnBitmap := TBitmap.Create;
                  bnBitmap.Handle := LoadResBitmap(
                           'BANKA'+IntToStr(Cislo)+'BITMAP');
                  bnBitmap.Palette := MainForm.InitPal;
                end;
            end;  { Case Cislo }
          end; { if FileExists(Jmeno) else }
        finally
          Dispose(BMPBitmap);
        end;  { try }
      finally
        Dispose(BankBitmap);
      end;  { try }
    except
    end; { try }
    StreamOut.Free;
    StreamIn.Free;
  end; { with Banka^ }
end;

function LoadResBitmap(Jmeno: string): HBitmap;
var HRes: THandle;
    HGlob: THandle;
    PBitmapInfo: ^TBitmapInfo;
    DC: HDC;
    HPalOld: HPalette;
    Palety: HPalette;
    Barev: Integer;
    JmenoChar: array[0..256] of Char;
begin
  Result := 0;
  StrPCopy(JmenoChar,Jmeno);
  HRes := FindResource(HInstance,JmenoChar,RT_BITMAP);
  if HRes <> 0 then
  begin
    HGlob := LoadResource(HInstance,HRes);
    if HGlob <> 0 then
    try
      PBitmapInfo := LockResource(HGlob);
      DC := GetDC(0);
      if DC <> 0 then
      try
        Palety := MainForm.InitPal;
        HPalOld := SelectPalette(DC,Palety,TRUE);
        RealizePalette(DC);
        with PBitmapInfo^ do
        begin
         Barev := bmiHeader.biClrUsed;
         if Barev = 0 then Barev := 1 shl bmiHeader.biBitCount;
         Result := CreateDIBitmap(DC,PBitmapInfo^.bmiHeader,
           CBM_INIT, @(PBitmapInfo^.bmiColors[Barev]),
           PBitmapInfo^,DIB_RGB_COLORS);
        end;
        SelectPalette(DC,HPalOld,TRUE);
        DeleteObject(Palety);
      finally
        ReleaseDC(0,DC);
      end;
      GlobalUnlock(HGlob);
    finally
      FreeResource(HGlob);
    end;
  end;
end;

procedure DispMaskIcon(DestCanvas: TCanvas; DestX,DestY: Integer;
       SrcBanks: PBanks; Banka, Predmet: Integer);
var DRect, LRect, SRect: TRect;
    OldCopyMode: TCopyMode;
    OldBkColor: TColorRef;
    OldBrushColor: TColor;
    Barva: TColorRef;
    TempBitmap: TBitmap;
    MaskBitmap: TBitmap;
begin
{ pøíprava ukazatelù rámù }
  DRect := Rect(DestX, DestY, DestX+IconWidth, DestY+IconHeight);
  LRect := Rect(0,0,IconWidth,IconHeight);
  SRect := Rect((Predmet mod IconXNum)*IconWidth,
                (Predmet div IconXNum)*IconHeight,
                (Predmet mod IconXNum + 1)*IconWidth,
                (Predmet div IconXNum + 1)*IconHeight);

  with SrcBanks^[Banka]^ do
    if Assigned(bnBitmap) then
      if (bnColor[Predmet] >= 0) and (bnColor[Predmet] < SubColors) then
      begin
{ pøíprava pracovních bitmap }
        TempBitmap := TBitmap.Create;
        TempBitmap.Width := IconWidth;
        TempBitmap.Height := IconHeight;
        TempBitmap.Palette := MainForm.InitPal;

        MaskBitmap := TBitmap.Create;
        MaskBitmap.Width := IconWidth;
        MaskBitmap.Height := IconHeight;
        MaskBitmap.Palette := MainForm.InitPal;

{ pøíprava obrázku s oøezaným pozadím }
        Barva := bnColor[Predmet] + $1000000;
{        Barva := $2000000 + DefPalette[Barva*4]
            + 256*DefPalette[Barva*4+1] + 65536*DefPalette[4*4+2];}
        TempBitmap.Canvas.Brush.Color := clBlack;
        TempBitmap.Canvas.BrushCopy(LRect,bnBitmap,
          SRect,Barva);

{ pøíprava masky obrázku }
{$IFDEF PROTECT_MODE}
        MaskBitmap.Canvas.CopyRect(LRect,bnBitmap.Canvas,SRect);
        MaskBitmap.Mask(Barva);
{$ELSE}
        MaskBitmap.Monochrome := True;
        OldBkColor := SetBkColor(bnBitmap.Canvas.Handle,Barva);
        BitBlt(MaskBitmap.Canvas.Handle,0,0,IconWidth,IconHeight,
          bnBitmap.Canvas.Handle,SRect.Left,SRect.Top, SRCCOPY);
        SetBkColor(bnBitmap.Canvas.Handle,OldBkColor);
{$ENDIF}

{ zamaskování pùvodního podkladu }
        OldBrushColor := DestCanvas.Brush.Color;
        OldCopyMode := DestCanvas.CopyMode;
        DestCanvas.Brush.Color := clWhite;
        DestCanvas.CopyMode :=  cmSrcAnd;
        DestCanvas.Draw(DRect.Left,DRect.Top,MaskBitmap);

{ doplnìní kresleného obrázku }
        DestCanvas.CopyMode := cmSrcPaint;
        DestCanvas.Draw(DRect.Left,DRect.Top,TempBitmap);
        DestCanvas.CopyMode := OldCopyMode;
        DestCanvas.Brush.Color := OldBrushColor;

{ uvolnìní pracovních bitmap }
        MaskBitmap.Free;
        TempBitmap.Free;
      end  { if bnColor[Predmet] }
      else
        DestCanvas.CopyRect(DRect,bnBitmap.Canvas,SRect)
    else  { if Assigned(bnBitmap) }
    begin
      OldBrushColor := DestCanvas.Brush.Color;
      DestCanvas.Brush.Color := clBlack;
      DestCanvas.FillRect(DRect);
      DestCanvas.Brush.Color := OldBrushColor;
    end;
end;


{ ================================================================ }
{                                                                  }
{                       Obsluha Baltíka - scéna                    }
{                                                                  }
{ ================================================================ }

procedure TMainForm.ButtonVlevoScene2Click(Sender: TObject);
begin
  if (SceneSubX + SceneSubY + SceneSubC) = 0 then
  begin
    with ScenBuff^ do
      Case sfSmer of
        1: sfSmer := 4;
        2..4: sfSmer := sfSmer - 1;
      end;
    SceneModi := True;
    {ButtonSaveScene.Enabled := True;
    ButtonSaveScene2.Enabled := True;}
    DispBaltScene;
  end
  else
    SceneNext := VK_LEFT;
end;

procedure TMainForm.ButtonVpravoScene2Click(Sender: TObject);
begin
  if (SceneSubX + SceneSubY + SceneSubC) = 0 then
  begin
    with ScenBuff^ do
      Case sfSmer of
        4: sfSmer := 1;
        1..3: sfSmer := sfSmer + 1;
      end;
    SceneModi := True;
    {ButtonSaveScene.Enabled := True;
    ButtonSaveScene2.Enabled := True;}
    DispBaltScene;
  end
  else
    SceneNext := VK_RIGHT;
end;

procedure TMainForm.ButtonKrokScene2Click(Sender: TObject);
var NewPoz, NewRad: Integer;
    Predmet: Longint;
begin
  if (SceneSubX + SceneSubY + SceneSubC) = 0 then
  begin
    with ScenBuff^ do
    begin
      NewPoz := sfSloupec;
      NewRad := sfRadek;
      Case sfSmer of
        1: Inc(NewPoz);
        2: Inc(NewRad);
        3: Dec(NewPoz);
        4: Dec(NewRad);
      end;
      if (NewPoz < 1) or (NewPoz > IconXNum) or
         (NewRad < 1) or (NewRad > IconYNum) then Exit;

      Predmet := sfData[NewRad-1+(NewPoz-1)*IconYNum];
      if SceneBank[(Predmet-1) div 1000]^.bnPruchod[(Predmet-1) mod 1000] <> 1 then Exit;

      Case sfSmer of
        1: SceneSubX := IconWidth/8;
        2: SceneSubY := IconHeight/8;
        3: SceneSubX := -IconWidth/8;
        4: SceneSubY := -IconHeight/8;
      end;
      TimerScene.Enabled := True;
    end;
    SceneModi := True;
    {ButtonSaveScene.Enabled := True;
    ButtonSaveScene2.Enabled := True;}
  end
  else
    SceneNext := VK_UP;
end;

procedure TMainForm.DispBaltScene;
var Cislo: Longint;
begin
  with ScenBuff^ do
  begin
    if (sfSmer < 1) or (sfSmer > 4) then sfSmer := 1;
    Case sfSmer of
      1: Cislo := 100001;
      2: Cislo := 100006;
      3: Cislo := 100011;
      else Cislo := 100016;
    end;
    if (sfSloupec < 1) or (sfSloupec > IconXNum) then sfSloupec := 1;
    if (sfRadek < 1) or (sfRadek > IconYNum) then sfRadek := IconYNum;

    DispIconScene(sfData[sfRadek-1+(sfSloupec-1)*IconYNum],
           sfSloupec-1,sfRadek-1);

    if SceneSubX > 0 then
      DispIconScene(sfData[sfRadek-1+(sfSloupec-1+1)*IconYNum],
           sfSloupec-1+1,sfRadek-1);

    if SceneSubX < 0 then
      DispIconScene(sfData[sfRadek-1+(sfSloupec-1-1)*IconYNum],
           sfSloupec-1-1,sfRadek-1);

    if SceneSubY > 0 then
      DispIconScene(sfData[sfRadek-1+1+(sfSloupec-1)*IconYNum],
           sfSloupec-1,sfRadek-1+1);

    if SceneSubY < 0 then
      DispIconScene(sfData[sfRadek-1-1+(sfSloupec-1)*IconYNum],
           sfSloupec-1,sfRadek-1-1);

    Case Round(Abs(SceneSubX)/IconWidth*8) +
         Round(Abs(SceneSubY)/IconHeight*8) of
      1,5: Inc(Cislo,2);
      3,7: Inc(Cislo);
    end;

    if (SceneSubC > 0) and (SceneSubC < 6) then Inc(Cislo,4);

    DispMaskIcon(ImageScene2.Canvas,(sfSloupec-1)*IconWidth+Round(SceneSubX),
      (sfRadek-1)*IconHeight+Round(SceneSubY),@SceneBank,
      (Cislo-1) div 1000, (Cislo-1) mod 1000);
  end;
end;

procedure TMainForm.TimerSceneTimer(Sender: TObject);
var NextPoz, NextRad: Integer;
begin
  DispBaltScene;

  if SceneSubC > 0 then with ScenBuff^ do
  begin
    NextPoz := sfSloupec;
    NextRad := sfRadek;
    Case sfSmer of
      1: Inc(NextPoz);
      2: Inc(NextRad);
      3: Dec(NextPoz);
      4: Dec(NextRad);
    end;

    if SceneSubC = 5 then
      sfData[NextRad-1+(NextPoz-1)*IconYNum] := PosledniPredmet;

    DispIconScene(sfData[NextRad-1+(NextPoz-1)*IconYNum],NextPoz-1,NextRad-1);

    if SceneSubC <= 8 then
    begin
      DispMaskIcon(ImageScene2.Canvas,(NextPoz-1)*IconWidth,
        (NextRad-1)*IconHeight,@SceneBank,BAL_CARUJ_FAZE1 div 1000,
        (BAL_CARUJ_FAZE1+SceneSubC-1) mod 1000);
      Inc(SceneSubC);
    end;

    if SceneSubC > 8 then
    begin
      SceneSubC := 0;
      FormKeyDown(Sender, SceneNext, []);
    end;

  end

  else

  if (SceneSubX + SceneSubY) <> 0 then with ScenBuff^ do
  begin
    if SceneSubX > 0 then SceneSubX := SceneSubX + IconWidth/8;
    if SceneSubY > 0 then SceneSubY := SceneSubY + IconHeight/8;
    if SceneSubX < 0 then SceneSubX := SceneSubX - IconWidth/8;
    if SceneSubY < 0 then SceneSubY := SceneSubY - IconHeight/8;

    if SceneSubX > IconWidth+1 then
    begin
      Inc(sfSloupec);
      SceneSubX := 0;
    end;

    if SceneSubX < -IconWidth-1 then
    begin
      Dec(sfSloupec);
      SceneSubX := 0;
    end;

    if SceneSubY > IconHeight+1 then
    begin
      Inc(sfRadek);
      SceneSubY := 0;
    end;

    if SceneSubY < -IconHeight-1 then
    begin
      Dec(sfRadek);
      SceneSubY := 0;
    end;

    if ((SceneSubX + SceneSubY) = 0) then
      FormKeyDown(Sender, SceneNext, []);

  end;

  if ((SceneSubX + SceneSubY + SceneSubC) = 0) then
      TimerScene.Enabled := False
end;

procedure TMainForm.ButtonSelectScene2Click(Sender: TObject);
begin
  if (SceneSubX + SceneSubY + SceneSubC) = 0 then
  begin
    SelBanks := @SceneBank;
    EditName := SceneName;
    EditAktDir := AktDirScene;
    SelForm.ShowModal;
    if SelForm.Tag <> -1 then
    begin
      PosledniPredmet := SelForm.Tag;
      ButtonCarujScene2Click(Sender);
    end;
  end
  else
    SceneNext := VK_RETURN;
end;

procedure TMainForm.ButtonCarujScene2Click(Sender: TObject);
var NextPoz, NextRad: Integer;
begin
  if (SceneSubX + SceneSubY + SceneSubC) = 0 then with ScenBuff^ do
  begin
    NextPoz := sfSloupec;
    NextRad := sfRadek;
    Case sfSmer of
      1: Inc(NextPoz);
      2: Inc(NextRad);
      3: Dec(NextPoz);
      4: Dec(NextRad);
    end;
    if (NextPoz < 1) or (NextPoz > IconXNum) or
       (NextRad < 1) or (NextRad > IconYNum) then Exit;

    SceneSubC := 1;
    TimerScene.Enabled := True;
    SceneModi := True;
    {ButtonSaveScene.Enabled := True;
    ButtonSaveScene2.Enabled := True;}
  end
  else
    SceneNext := VK_SPACE;
end;

{ ================================================================ }
{                                                                  }
{                          Editace programu                        }
{                                                                  }
{ ================================================================ }

procedure TMainForm.ButtonNewProgramClick(Sender: TObject);
var I: Integer;
begin
  if NovyProgram(Sender) then
  begin
    Screen.Cursor := crHourGlass;
    PanelStatus.Caption := TextCekImpl;
    Refresh;
    for I := 0 to MaxBank-1 do
      LoadBanka(HomeDir + DefBanka, I, ProgramBank[I]);
    ShowHint(Sender);
    DispProgram;
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.SetProgramName(Jmeno: string);
begin
  AktDirProgram := ExtractFilePath(Jmeno);
  ProgramName := ExtractFileName(Jmeno);
  if Pos('.',ProgramName) > 0 then
    Delete(ProgramName,Pos('.',ProgramName),200);
  CaptionInit;
end;

procedure TMainForm.ButtonLoadProgramClick(Sender: TObject);
begin
  OpenDialogProgram.InitialDir := AktDirProgram;
  OpenDialogProgram.FileName := ProgramName;
  if OpenDialogProgram.Execute then
    if NovyProgram(Sender) then
    begin
      SetProgramName(OpenDialogProgram.FileName);
      Screen.Cursor := crHourGlass;
      PanelStatus.Caption := TextCekProg + ProgramName + '...';
      Refresh;
      LoadProgram;
      ShowHint(Sender);
      Screen.Cursor := crDefault;
    end;
end;

procedure TMainForm.ButtonSaveProgramClick(Sender: TObject);
begin
  SaveProgramClick(Sender);
end;

function TMainForm.SaveProgramClick(Sender: TObject): Boolean;
var FileHandle: Integer;
begin
  Result := False;
  SaveDialogProgram.InitialDir := AktDirProgram;
  SaveDialogProgram.FileName := ProgramName;
  if SaveDialogProgram.Execute then
  begin
    SetProgramName(SaveDialogProgram.FileName);
    Screen.Cursor := crHourGlass;
    FileHandle := FileCreate(AktDirProgram + ProgramName + '.BPR');
    if FileHandle > 0 then with Progbuff^ do
    try
      pfIdent[0] := 'B';
      pfIdent[1] := 'P';
      pfIdent[2] := 'R';
      pfVerze := 1;
      FileWrite(FileHandle,ProgBuff^,pfProgSize*4+6);
      Result := True;
      {ButtonSaveProgram.Enabled := False;}
      ProgramModi := False;
    finally
      FileClose(FileHandle);
    end;
    Screen.Cursor := crDefault;
  end;
end;

function TMainForm.NovyProgram(Sender: TObject): Boolean; { True = pokraèovat }
begin
  if TestProgramModi(Sender) then
  begin
    Result := True;
    {ButtonSaveProgram.Enabled := False;}
    ProgramModi := False;
    SetProgramName(AktDirProgram);
    with ProgBuff^ do
    begin
      pfIdent[0] := 'B';
      pfIdent[1] := 'P';
      pfIdent[2] := 'R';
      pfVerze := 1;
      pfProgSize := 0;
    end;
    ProgTopLine := 0;
    ProgTopIndex := 0;
    ProgLeftPoz := 0;
    ProgLines := 0;
    ProgXMax := 2;
    ScrollInit;
    DispProgram;
  end
  else
    Result := False;
end;

procedure TMainForm.LoadProgram;  { buffer programu musí být vymazaný }
var FileHandle: Integer;
    Nacteno: Integer;
    I,J: Integer;
    Soubor: string;
begin
  FileHandle := FileOpen(AktDirProgram + ProgramName + '.BPR',
                       fmOpenRead);
  if FileHandle > 0 then with ProgBuff^ do
  try { finaly FileClose }
    Nacteno := (FileRead(FileHandle,ProgBuff^,
                SizeOf(TProgFile)) - 6) div 4;
    if Nacteno < 0 then Nacteno := 0;
    if Nacteno < pfProgSize then pfProgSize := Nacteno;

    if (pfIdent[0] <> 'B') or
       (pfIdent[1] <> 'P') or
       (pfIdent[2] <> 'R') then
    begin
      pfIdent[0] := 'B';
      pfIdent[1] := 'P';
      pfIdent[2] := 'R';
      pfVerze := 1;
      pfProgSize := 0;
    end;
  finally
    FileClose(FileHandle);
  end;
  ProgInitLines;
  for I := 0 to MaxBank-1 do
    LoadBanka(AktDirProgram + ProgramName, I, ProgramBank[I]);

  for I := 0 to 99 do with ProgSceneBuff^.sbScenes[I] do
  try  { except }
    for J := 0 to IconPageNum-1 do sfData[J] := BAL_PODKLAD;

    Case I of
      0: if FileExists(AktDirProgram+ProgramName+'.S00') then
           Soubor :=  AktDirProgram+ProgramName+'.S00'
         else
           Soubor :=  AktDirProgram+ProgramName+'.BSC';
      1..9: Soubor :=  AktDirProgram+ProgramName+'.S0'+IntToStr(I);
      else Soubor :=  AktDirProgram+ProgramName+'.S'+IntToStr(I);
    end;

    if FileExists(Soubor) then
    begin
      FileHandle := FileOpen(Soubor,fmOpenRead);
      if FileHandle > 0 then
      try  { finally }
        FileRead(FileHandle,ProgSceneBuff^.sbScenes[I],SizeOf(TScenFile));
        for J := 0 to IconPageNum-1 do
          if (sfData[J] < 0) or (sfData[J] >= MaxBank*1000) or
            ((sfData[J] mod 1000) < 1) or ((sfData[J] mod 1000) > 150) then
              sfData[J] := BAL_PODKLAD;
      finally
        FileClose(FileHandle);
      end;
    end;
  except
  end;

  DispProgram;
end;

procedure TMainForm.ProgInitLines;
var I: Integer;
    Predmet: Longint;
    Pozice: Integer;
begin
  ProgLines := 0;
  ProgXMax := 0;
  Pozice := 0;
  with ProgBuff^ do
    if pfProgSize > 0 then
      for I := 0 to pfProgSize-1 do
      begin
        Predmet := pfData[I];
        if (Predmet <= 0 ) or
           ((Predmet-1) div 1000 >= MaxBank) or
           ((Predmet-1) mod 1000 >= IconPageNum) then
          pfData[I] := BAL_PODKLAD;
        if Predmet = BAL_CR then
        begin
          Inc(ProgLines);
          Pozice := 0;
        end
        else
        begin
          Inc(Pozice);
          if Pozice > ProgXMax then ProgXMax := Pozice;
        end;
      end;
  if ProgXMax < 2 then ProgXMax := 2;

  SetProgramTopLine(ProgTopLine);
  SetProgramTopPoz(ProgLeftPoz);

  ScrollInit;
end;

function TMainForm.TestProgramModi(Sender: TObject): Boolean; { True = pokraèovat }
var I: Integer;
begin
  Result := True;
  if ProgramModi then
  begin
{    I := MessageDlg(TextModiProg,mtConfirmation, mbYesNoCancel,0);}
    I := Hlaseni(TextModiProg1,TextModiProg2);
    if I = mrCancel then Result := False;
    if I = mrYes then Result := SaveProgramClick(Sender);
  end;
end;

procedure TMainForm.DispProgram;
var I,J,Cislo: Integer;
    Konec: Boolean;
    Zruseno: Boolean;
begin
  ImageProgram.Canvas.Brush.Color := clBlack;
  Cislo := ProgTopIndex;
  if Assigned(ProgBuff) then with ProgBuff^ do
    for J := 0 to ProgYPage-1 do
    begin
      Zruseno := False;
      if Cislo < pfProgSize then
        Konec := False
      else
        Konec := True;

      I := 0;
      while (I < ProgLeftPoz) and not Konec do
      begin
        Inc(I);
        Inc(Cislo);
        if pfData[Cislo-1] = BAL_NEPLATNE then
          Zruseno := True;
        if (pfData[Cislo-1] = BAL_CR) or
          (Cislo >= pfProgSize) then Konec := True;
      end;

      for I := 0 to ProgXPage-1 do
        if not Konec then
        begin
          DispIconProgram(pfData[Cislo],I,J,
               Zruseno and (pfData[Cislo] <> BAL_CR));
          Inc(Cislo);
          if pfData[Cislo-1] = BAL_NEPLATNE then
            Zruseno := True;
          if (pfData[Cislo-1] = BAL_CR) or
            (Cislo >= pfProgSize) then Konec := True;
        end
        else
          ImageProgram.Canvas.FillRect(Rect(I*IconWidth,J*IconHeight,
              (I+1)*IconWidth,(J+1)*IconHeight));

      while not Konec do
      begin
        Inc(Cislo);
        if (pfData[Cislo-1] = BAL_CR) or
          (Cislo >= pfProgSize) then Konec := True;
      end;

    end;
end;

procedure TMainForm.ScrollInit;
var I: Integer;
begin
  ProgYPage := 1 + ImageProgram.Height div IconHeight;
  if ProgYPage < 2 then ProgYPage := 2;

  if ProgLines >= ProgYPage-1 then
    ScrollBarProgramV.Visible := True
  else
    ScrollBarProgramV.Visible := False;

  ProgXPage := 1 + ImageProgram.Width div IconWidth;
  if ProgXPage < 2 then ProgXPage := 2;

  if ProgXMax >= ProgXPage-1 then
    PanelProgramHScroll.Visible := True
  else
    PanelProgramHScroll.Visible := False;

  with ScrollBarProgramV do
  begin
    I := ProgYPage - 2;
    if I < 1 then I := 1;
    LargeChange := I;
    I := ProgLines-ProgYPage+4;
    if I < 0 then I := 0;
    Max := I;
    Min := 0;
    SmallChange := 1;
    Position := ProgTopLine;
  end;

  with ScrollBarProgramH do
  begin
    I := ProgXPage - 2;
    if I < 1 then I := 1;
    LargeChange := I;
    I := ProgXMax-ProgXPage+3;
    if I < 0 then I := 0;
    Max := I;
    Min := 0;
    SmallChange := 1;
    Position := ProgLeftPoz;
  end;

  with ImageProgram do
  begin
    Picture.Bitmap.Width := Width;
    Picture.Bitmap.Height := Height;
  end;

end;

procedure TMainForm.DispIconProgram(Cislo: Longint;
                       Pozice,Radek: Integer; Zruseno: Boolean);
var Banka: Integer;
    DRect, SRect: TRect;
begin
  DRect := Rect(Pozice*IconWidth,Radek*IconHeight,
     (Pozice+1)*IconWidth,(Radek+1)*IconHeight);

  Cislo := Cislo - 1;
  if Cislo < 0 then Cislo := BAL_PODKLAD;
  Banka := Cislo div 1000;
  Cislo := Cislo mod 1000;
  Pozice := Cislo mod IconXNum;
  Radek := Cislo div IconXNum;

  SRect := Rect(Pozice*IconWidth,Radek*IconHeight,
     (Pozice+1)*IconWidth,(Radek+1)*IconHeight);

  ImageProgram.Canvas.Brush.Color := clBlack;

  if (Banka >= 0) and (Banka < MaxBank) then
    if Assigned(ProgramBank[Banka]^.bnBitmap) then
    begin
      ImageProgram.Canvas.CopyRect(DRect,
          ProgramBank[Banka]^.bnBitmap.Canvas,SRect);
      if Zruseno then with ImageProgram.Canvas do
      begin
        Pen.Color := $1000008;
        Pen.Width := 2;
        Pen.Style := psSolid;
        Pen.Mode := pmCopy;
        MoveTo(DRect.Left+1,DRect.Top+1);
        LineTo(DRect.Left+IconWidth-1,DRect.Top+IconHeight-1);
        MoveTo(DRect.Left+1,DRect.Top+IconHeight-1);
        LineTo(DRect.Left+IconWidth-1,DRect.Top+1);
      end;
    end
    else
      ImageProgram.Canvas.FillRect(DRect)
  else
    ImageProgram.Canvas.FillRect(DRect);
end;

procedure TMainForm.SetProgramTopLine(Radek: Integer);
begin
  if Radek > ProgLines-ProgYPage+4 then Radek := ProgLines-ProgYPage+4;
  if Radek < 0 then Radek := 0;
  if (Radek <> ProgTopLine) and Assigned(ProgBuff) then
  begin
    ProgTopLine := 0;
    ProgTopIndex := 0;
    while (ProgTopLine < Radek) and
      (ProgTopIndex < ProgBuff^.pfProgSize-1) do
    begin
      Inc(ProgTopIndex);
      if ProgBuff^.pfData[ProgTopIndex-1] = BAL_CR then
        Inc(ProgTopLine);
    end;
    ScrollBarProgramV.Position := ProgTopLine;
    DispProgram;
  end;
end;

procedure TMainForm.ScrollBarProgramVChange(Sender: TObject);
begin
  SetProgramTopLine(ScrollBarProgramV.Position);
end;

procedure TMainForm.ScrollBarProgramHChange(Sender: TObject);
begin
  SetProgramTopPoz(ScrollBarProgramH.Position);
end;

procedure TMainForm.SetProgramTopPoz(Pozice: Integer);
begin
  if Pozice > ProgXMax-ProgXPage+3 then Pozice := ProgXMax-ProgXPage+3;
  if Pozice < 0 then Pozice := 0;
  if Pozice <> ProgLeftPoz then
  begin
    ProgLeftPoz := Pozice;
    ScrollBarProgramH.Position := ProgLeftPoz;
    DispProgram;
  end;
end;

procedure TMainForm.ImageProgramMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var I,J,N: Integer;
    Bod: TPoint;
begin
  if (X < 0) or (X >= ImageProgram.Width) or
     (Y < 0) or (Y >= ImageProgram.Height) then Exit;

  Bod := Tabbed.ScreenToClient(ImageProgram.ClientToScreen(Point(X,Y)));

  X := (X div IconWidth) * IconWidth;
  Y := (Y div IconHeight) * IconHeight;

  N := ProgTopIndex;
  I := -ProgLeftPoz;
  J := 0;
  while (I*IconWidth <> X) or (J*IconHeight <> Y) do
  begin
    if N >= ProgBuff^.pfProgSize then Exit;
    Inc(I);
    Inc(N);
    if ProgBuff^.pfData[N-1] = BAL_CR then
    begin
      I := -ProgLeftPoz;
      Inc(J);
    end;
    if J*IconHeight > Y then Exit;
  end;

  if N >= ProgBuff^.pfProgSize then Exit;

  if Button = mbRight then
  begin
    ProgOldIndex := -1;
    IkonForm.Cursor := ID_RUKAPLUSCURSOR;
  end
  else
  begin
    ProgOldIndex := N;
    DispIconProgram(ProgBuff^.pfData[N],I,J,TRUE);
    IkonForm.Cursor := ID_RUKADRZICURSOR;
  end;
  Update;

  IkonBanks := @ProgramBank;
  IkonForm.Tag := ProgBuff^.pfData[N];
  IkonForm.Left := Bod.X - IkonForm.Width div 2;
  IkonForm.Top := Bod.Y - IkonForm.Height div 2;
  IkonForm.ShowModal2;
  DispProgram;
end;

procedure TMainForm.ImageProgramDrop(X, Y: Integer);
var Predmet: Longint;
    I, J, K, N: Integer;
begin
  Predmet := IkonForm.Tag;
  if Predmet = -1 then Exit;

  if (X >= 0) and (X < ImageProgram.Width) and
     (Y >= 0) and (Y < ImageProgram.Height) and
     (ProgBuff^.pfProgSize < MaxProgSize) then
  begin
    X := Round(X/IconWidth) * IconWidth;
    Y := (Y div IconHeight) * IconHeight;

    N := ProgTopIndex;
    I := -ProgLeftPoz;
    J := 0;

    while (J*IconHeight < Y) or
          ((J*IconHeight = Y) and (I*IconWidth < X)) do
    begin
      if N >= ProgBuff^.pfProgSize then Break;
      if (J*IconHeight = Y) and (ProgBuff^.pfData[N] = BAL_CR) then Break;
      Inc(I);
      Inc(N);
      if ProgBuff^.pfData[N-1] = BAL_CR then
      begin
        I := -ProgLeftPoz;
        Inc(J);
      end;
    end;

    with ProgBuff^ do
    begin
      if (N >= pfProgSize) and (J*IconHeight < Y) then
      begin
        pfData[N] := BAL_CR;
        Inc(pfProgSize);
        I := -ProgLeftPoz;
        Inc(N);
        Inc(J);
      end;

      if N < pfProgSize then
        for K := pfProgSize downto N+1 do
          pfData[K] := pfData[K-1];
      pfData[N] := Predmet;
      Inc(pfProgSize);
    end;

    if N <= ProgOldIndex then Inc(ProgOldIndex);

    ProgramModi := True;
    {ButtonSaveProgram.Enabled := True;}
    ProgInitLines;
    DispProgram;

    if I < 2 then SetProgramTopPoz(ProgLeftPoz+I-2);
    if J < 1 then SetProgramTopLine(ProgTopLine+J-1);
    if I > ProgXPage-3 then SetProgramTopPoz(ProgLeftPoz+I-ProgXPage+3);
    if J > ProgYPage-2 then SetProgramTopLine(ProgTopLine+J-ProgYPage+2);
  end;

  if ProgOldIndex >= 0 then with ProgBuff^ do
  begin
    if ProgOldIndex < pfProgSize-1 then
      for K := ProgOldIndex to pfProgSize-2 do
        pfData[K] := pfData[K+1];
    Dec(pfProgSize);
    ProgramModi := True;
    {ButtonSaveProgram.Enabled := True;}
    ProgInitLines;
    DispProgram;
  end;

end;

procedure TMainForm.ImageProgramMenuMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Y >= 0) and (Y < 2*IconHeight) and
     (X >= 0) and (X < 16*(IconWidth-2)) then
       ImageProgramMenu.Hint := TextPrikaz[
         (Y div IconHeight)*16 + X div (IconWidth-2)]
  else
    ImageProgramMenu.Hint := '';
end;

procedure TMainForm.ImageProgramMenuMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Bod: TPoint;
    Predmet: Longint;
begin
  if (Y >= 0) and (Y < 2*IconHeight) and
     (X >= 0) and (X < 16*(IconWidth-2)) then
       Predmet := MenuPredmet[
          (Y div IconHeight)*16 + X div (IconWidth-2)]
  else
    Exit;

  Update;

  IkonBanks := @ProgramBank;
  Bod := Tabbed.ScreenToClient(ImageProgramMenu.ClientToScreen(Point(X,Y)));
  ProgOldIndex := -1;
  IkonForm.Cursor := ID_RUKAPLUSCURSOR;
  IkonForm.Tag := Predmet;
  IkonForm.Left := Bod.X - IkonForm.Width div 2;
  IkonForm.Top := Bod.Y - IkonForm.Height div 2;
  IkonForm.ShowModal2;
  DispProgram;
end;

procedure TMainForm.ButtonSelectProgramClick(Sender: TObject);
begin
  SelBanks := @ProgramBank;
  EditName := ProgramName;
  EditAktDir := AktDirProgram;
  SelForm.ShowModal;
  if SelForm.Tag <> -1 then
  begin
    IkonBanks := @ProgramBank;
    ProgOldIndex := -1;
    IkonForm.Cursor := ID_RUKAPLUSCURSOR;
    IkonForm.Tag := SelForm.Tag;
    IkonForm.ShowModal2;
    DispProgram;
  end;
end;

procedure TMainForm.ImageProgramMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var I,J,N: Integer;
    Predmet: Longint;
    Txt: string;
begin
  X := (X div IconWidth) * IconWidth;
  Y := (Y div IconHeight) * IconHeight;

  N := ProgTopIndex;
  I := -ProgLeftPoz;
  J := 0;
  while (I*IconWidth <> X) or (J*IconHeight <> Y) do
  begin
    if N >= ProgBuff^.pfProgSize then Break;
    Inc(I);
    Inc(N);
    if ProgBuff^.pfData[N-1] = BAL_CR then
    begin
      I := -ProgLeftPoz;
      Inc(J);
    end;
  end;

  if N < ProgBuff^.pfProgSize then
    Predmet := ProgBuff^.pfData[N]
  else
    Predmet := -1;

  Txt := '';

  if Predmet <> -1 then
  begin
    Txt := TextPredmet + IntToStr(Predmet);
    if ProgramBank[(Predmet-1) div 1000]^.
         bnPruchod[(Predmet-1) mod 1000] <> 1 then
       Txt := Txt + TextNepruch;
  end;

  for I := 0 to 31 do
    if Predmet = MenuPredmet[I] then
      Txt := TextPrikaz[I];

  ImageProgram.Hint := Txt;
end;

procedure TMainForm.ProgramVlozPredmet(Predmet: Longint);
begin
  Update;
  IkonBanks := @ProgramBank;
  ProgOldIndex := -1;
  IkonForm.Cursor := ID_RUKAPLUSCURSOR;
  IkonForm.Tag := Predmet;
  IkonForm.ShowModal2;
end;

procedure TMainForm.MenuProgramUpravMezeraClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_NIC);
end;

procedure TMainForm.MenuProgramUpravKrokClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_KROK);
end;

procedure TMainForm.MenuProgramUpravOtocitVlevoClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_VLEVO);
end;

procedure TMainForm.MenuProgramUpravOtocitVpravoClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_VPRAVO);
end;

procedure TMainForm.MenuProgramUpravOtocitVychodClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_VYCHOD);
end;

procedure TMainForm.MenuProgramUpravOtocitJihClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_JIH);
end;

procedure TMainForm.MenuProgramUpravOtocitZapadClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_ZAPAD);
end;

procedure TMainForm.MenuProgramUpravOtocitSeverClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_SEVER);
end;

procedure TMainForm.MenuProgramUpravNeviditZapClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_NEVID_ZAP);
end;

procedure TMainForm.MenuProgramUpravNeviditVypClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_NEVID_VYP);
end;

procedure TMainForm.MenuProgramUpravCekatClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_CEKEJ_CAS);
end;

procedure TMainForm.MenuProgramUpravKlavesaClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_CEKEJ_KLAV);
end;

procedure TMainForm.MenuProgramUpravOblakZapClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_CARUJ_ZAP);
end;

procedure TMainForm.MenuProgramUpravOblakVypClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_CARUJ_VYP);
end;

procedure TMainForm.MenuProgramUpravVymazatClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_VYMAZ);
end;

procedure TMainForm.MenuProgramUpravPipnoutClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_PIPNI);
end;

procedure TMainForm.MenuProgramUpravNeplatnyClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_NEPLATNE);
end;

procedure TMainForm.MenuProgramUpravRychlostClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_RYCHLOST);
end;

procedure TMainForm.MenuProgramUpravCislice0Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_0);
end;

procedure TMainForm.MenuProgramUpravCislice1Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_1);
end;

procedure TMainForm.MenuProgramUpravCislice2Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_2);
end;

procedure TMainForm.MenuProgramUpravCislice3Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_3);
end;

procedure TMainForm.MenuProgramUpravCislice4Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_4);
end;

procedure TMainForm.MenuProgramUpravCislice5Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_5);
end;

procedure TMainForm.MenuProgramUpravCislice6Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_6);
end;

procedure TMainForm.MenuProgramUpravCislice7Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_7);
end;

procedure TMainForm.MenuProgramUpravCislice8Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_8);
end;

procedure TMainForm.MenuProgramUpravCislice9Click(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_9);
end;

procedure TMainForm.MenuProgramUpravOpakovatClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_KRAT);
end;

procedure TMainForm.MenuProgramUpravZavorkaLevaClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_LEVA_ZAVORKA);
end;

procedure TMainForm.MenuProgramUpravZavorkaPravaClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_PRAVA_ZAVORKA);
end;

procedure TMainForm.MenuProgramUpravKonecClick(Sender: TObject);
begin
  ProgramVlozPredmet(BAL_CR);
end;

procedure TMainForm.ButtonStartProgramClick(Sender: TObject);
begin
  ExecForm.Caption := ProgramName;
  ExecTopLine := 0;
  ExecForm.ShowModal2;
  SetProgramTopLine(ExecLine);
end;

procedure TMainForm.ButtonPauseProgramClick(Sender: TObject);
begin
  ExecForm.Caption := ProgramName;
  ExecTopLine := ProgTopLine;
  ExecForm.ShowModal2;
  SetProgramTopLine(ExecLine);
end;

procedure TMainForm.MenuSceneHelpAboutClick(Sender: TObject);
begin
  AboutBox.Show;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  if Assigned(About0Box) then
    if not AboutBoxOK then
    begin
      About0Box.Show;
      About0Box.BringToFront;
      AboutBoxOK := True;
    end
    else
      if About0Box.Visible then
      begin
        About0Box.Close;
        Refresh;
      end;
  if BeziProgram then ExecForm.Close;
end;

procedure TMainForm.MenuSceneVolbyENClick(Sender: TObject);
begin
  JazykID := ID_EN;

  LoadResTxt;
  SelForm.LoadResTxt;
  EditForm.LoadResTxt;
  OrgForm.LoadResTxt;
  YesForm.LoadResTxt;
  AboutBox.LoadResTxt;
  About0Box.LoadResTxt;
  HelpForm.LoadResTxt;

  MenuSceneVolbyEN.Checked := True;
  MenuSceneVolbyCZ.Checked := False;
  MenuScene2VolbyEN.Checked := True;
  MenuScene2VolbyCZ.Checked := False;
  MenuProgramVolbyEN.Checked := True;
  MenuProgramVolbyCZ.Checked := False;
  CaptionInit;
end;

procedure TMainForm.MenuSceneVolbyCZClick(Sender: TObject);
begin
  JazykID := ID_CZ;

  LoadResTxt;
  SelForm.LoadResTxt;
  EditForm.LoadResTxt;
  OrgForm.LoadResTxt;
  YesForm.LoadResTxt;
  AboutBox.LoadResTxt;
  About0Box.LoadResTxt;
  HelpForm.LoadResTxt;

  MenuSceneVolbyEN.Checked := False;
  MenuSceneVolbyCZ.Checked := True;
  MenuScene2VolbyEN.Checked := False;
  MenuScene2VolbyCZ.Checked := True;
  MenuProgramVolbyEN.Checked := False;
  MenuProgramVolbyCZ.Checked := True;
  CaptionInit;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Tabbed.PageIndex := 2;
  FormResize(Sender);
  Tabbed.PageIndex := 0;
end;

procedure TMainForm.FormHide(Sender: TObject);
var I: Integer;
begin
{ uložení konfigurace }
  IniFile := TIniFile.Create(DefName + '.INI');
  Case JazykID of
    ID_CZ: I := 1;
  else I := 0;
  end;
  IniFile.WriteInteger(DefName,'Language',I);

  Case SceneNum of
    200: IniFile.WriteString(DefName,'Scene',AktDirScene+SceneName);
    201..209: IniFile.WriteString(DefName,'Scene',
         AktDirScene+SceneName+'.S0'+IntToStr(SceneNum-200));
    else   IniFile.WriteString(DefName,'Scene',
            AktDirScene+SceneName+'.S'+IntToStr(SceneNum-200));
  end;
  IniFile.WriteString(DefName,'Program',AktDirProgram+ProgramName);

  IniFile.Free;

end;

procedure TMainForm.SpinSceneDownClick(Sender: TObject);
begin
  SceneNum := StrToIntDef(EditScene.Text,SceneNum-200)-1+200;
  if SceneNum < 200 then SceneNum := 200;
  if SceneNum > 299 then SceneNum := 299;
  EditScene.Text := IntToStr(SceneNum-200);
  if Length(EditScene.Text) = 1 then
    EditScene.Text := '0'+EditScene.Text;
  ActiveControl := Tabbed;
  SceneModi := True;
  {ButtonSaveScene.Enabled := True;
  ButtonSaveScene2.Enabled := True;}
end;

procedure TMainForm.SpinSceneUpClick(Sender: TObject);
begin
  SceneNum := StrToIntDef(EditScene.Text,SceneNum-200)+1+200;
  if SceneNum < 200 then SceneNum := 200;
  if SceneNum > 299 then SceneNum := 299;
  EditScene.Text := IntToStr(SceneNum-200);
  if Length(EditScene.Text) = 1 then
    EditScene.Text := '0'+EditScene.Text;
  ActiveControl := Tabbed;
  SceneModi := True;
  {ButtonSaveScene.Enabled := True;
  ButtonSaveScene2.Enabled := True;}
end;

procedure TMainForm.EditSceneKeyPress(Sender: TObject; var Key: Char);
begin
  Case Key of
    #13: begin
          SceneNum := StrToIntDef(EditScene.Text,SceneNum-200)+200;
          if SceneNum < 200 then SceneNum := 200;
          if SceneNum > 299 then SceneNum := 299;
          EditScene.Text := IntToStr(SceneNum-200);
          if Length(EditScene.Text) = 1 then
            EditScene.Text := '0'+EditScene.Text;
          ActiveControl := Tabbed;
          Key := #0;
          SceneModi := True;
          {ButtonSaveScene.Enabled := True;
          ButtonSaveScene2.Enabled := True;}
        end;
    #27: begin
          EditScene.Text := IntToStr(SceneNum-200);
          if Length(EditScene.Text) = 1 then
            EditScene.Text := '0'+EditScene.Text;
          ActiveControl := Tabbed;
          Key := #0;
        end;
  end;
end;

procedure TMainForm.ButtonEditProgramClick(Sender: TObject);
begin
  SelBanks := @ProgramBank;
  EditName := ProgramName;
  EditAktDir := AktDirProgram;
  OrgForm.ShowModal;
{
  repeat
    SelForm.ShowModal;
    if SelForm.Tag <> -1 then
    begin
      EditForm.Tag := SelForm.Tag;
      EditForm.ShowModal;
    end;
  until SelForm.Tag = -1;}
end;

procedure TMainForm.ButtonEditSceneClick(Sender: TObject);
begin
  SelBanks := @SceneBank;
  EditName := SceneName;
  EditAktDir := AktDirScene;
  OrgForm.ShowModal;
{
  repeat
    SelForm.ShowModal;
    if SelForm.Tag <> -1 then
    begin
      EditForm.Tag := SelForm.Tag;
      EditForm.ShowModal;
    end;
  until SelForm.Tag = -1; }
end;

procedure TMainForm.LabelNum2Click(Sender: TObject);
begin
  ActiveControl := EditScene;
  EditScene.SelectAll;
end;

procedure TMainForm.MenuSceneHelpHelpClick(Sender: TObject);
begin
  HelpForm.Show;
end;

end.

