@echo off
if exist %0\..\NEOPAINT.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo - Vyvolavate sluzby sharewaroveho programu NEOPAINT! -
echo Program  NEOPAINT  neni  dosud nainstalovan. Chcete-li
echo provest  nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete   klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po instalaci bude program NEOPAINT pripraven k pouziti
echo v  podadresari NEOPAINT programoveho adresare DOSMANu.
echo V  podadresari  NEOPAINT\INSTALL bude ponechan puvodni
echo distribucni balik programu NEOPAINT.
echo.
echo UPOZORNENI  -  program NEOPAINT je sharewarovy program
echo firmy  NeoSoft Corp.  a  nevztahuji se na nej licencni
echo prava  programu  DOS Manazer. Program smi byt pouzivan
echo ve  zkusebnim  provozu  po  dobu  maximalne 30 dnu. Po
echo uplynuti  teto  doby  musi byt program NEOPAINT zrusen
echo z  disku  nebo se musi uzivatel programu zaregistrovat
echo u firmy NeoSoft podle podminek v souboru README.DOC.
echo.
type %0\..\INSTALL\POZNAMKA.TXT
echo.
pause
cd > %0\..\$DIR$.TMP
%0\..\setdir.com %0\.. > NUL
if not exist INSTALL\UNZIP.EXE goto Konec

cls
echo      Zvolte typ tiskarny (automaticky se instaluji tez ovladace EPSON a HP):
echo      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo      ³ 0 .... jina (neuvedena) tiskarna ³ I .... IDS                       ³
echo      ³ 1 .... AMT                       ³ J .... JDL                       ³
echo      ³ 2 .... Anadex                    ³ K .... Malibu                    ³
echo      ³ 3 .... Apple                     ³ L .... Mannesmann                ³
echo      ³ 4 .... Brother                   ³ M .... MPI                       ³
echo      ³ 5 .... Canon                     ³ N .... NEC                       ³
echo      ³ 6 .... Centronics                ³ O .... North Atlantic            ³
echo      ³ 7 .... C. Itoh                   ³ P .... Okidata                   ³
echo      ³ 8 .... Citizen                   ³ Q .... Panasonic                 ³
echo      ³ 9 .... Dataproducts              ³ R .... PostScript                ³
echo      ³ A .... Datasouth                 ³ S .... Quadram                   ³
echo      ³ B .... DEC                       ³ T .... Seikosha                  ³
echo      ³ C .... Diablo                    ³ U .... Sharp                     ³
echo      ³ D .... Facit                     ³ V .... Star                      ³
echo      ³ E .... Fujitsu                   ³ W .... Tandy                     ³
echo      ³ F .... Genicom                   ³ X .... TI                        ³
echo      ³ G .... Gorilla Banana            ³ Y .... Toshiba                   ³
echo      ³ H .... IBM                       ³ Z .... Xerox                     ³
echo      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ask.com "        Zvolte tiskarnu stiskem 0 - 9, A - Z, * = vse, Esc = preruseni:"*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ
cls
if errorlevel 38 goto XEROX
if errorlevel 37 goto TOSHIBA
if errorlevel 36 goto TI
if errorlevel 35 goto TANDY
if errorlevel 34 goto STAR
if errorlevel 33 goto SHARP
if errorlevel 32 goto SEI
if errorlevel 31 goto QUA
if errorlevel 30 goto POST
if errorlevel 29 goto PAN
if errorlevel 28 goto OKI
if errorlevel 27 goto NORTH
if errorlevel 26 goto NEC
if errorlevel 25 goto MPI
if errorlevel 24 goto MANES
if errorlevel 23 goto MALIBU
if errorlevel 22 goto JDL
if errorlevel 21 goto IDS
if errorlevel 20 goto IBM
if errorlevel 19 goto GORILLA
if errorlevel 18 goto GENICOM
if errorlevel 17 goto FUJITSU
if errorlevel 16 goto FACIT
if errorlevel 15 goto DIABLO
if errorlevel 14 goto DEC
if errorlevel 13 goto DATAS
if errorlevel 12 goto DATAP
if errorlevel 11 goto CITIZEN
if errorlevel 10 goto CITOH
if errorlevel  9 goto CENT
if errorlevel  8 goto CANON
if errorlevel  7 goto BROTHER
if errorlevel  6 goto APPLE
if errorlevel  5 goto ANADEX
if errorlevel  4 goto AMT
if errorlevel  3 goto Install
if errorlevel  2 goto VSE
goto Konec2

:VSE
INSTALL\unzip.exe -o INSTALL\NP7.CMP *.*
goto Install

:AMT
INSTALL\unzip.exe -o INSTALL\NP7.CMP AMT*.*
goto Install

:ANADEX
INSTALL\unzip.exe -o INSTALL\NP7.CMP ANDX*.*
goto Install

:APPLE
INSTALL\unzip.exe -o INSTALL\NP7.CMP APPLE*.*
goto Install

:BROTHER
INSTALL\unzip.exe -o INSTALL\NP7.CMP BRO*.*
goto Install

:CANON
INSTALL\unzip.exe -o INSTALL\NP7.CMP CANON*.*
goto Install

:CENT
INSTALL\unzip.exe -o INSTALL\NP7.CMP CENT*.*
goto Install

:CITOH
INSTALL\unzip.exe -o INSTALL\NP7.CMP CITOH*.*
goto Install

:CITIZEN
INSTALL\unzip.exe -o INSTALL\NP7.CMP CITZ*.*
goto Install

:DATAP
INSTALL\unzip.exe -o INSTALL\NP7.CMP DATAP*.* DP*.*
goto Install

:DATAS
INSTALL\unzip.exe -o INSTALL\NP7.CMP DATAS*.*
goto Install

:DEC
INSTALL\unzip.exe -o INSTALL\NP7.CMP DEC*.*
goto Install

:DIABLO
INSTALL\unzip.exe -o INSTALL\NP7.CMP DIAB*.*
goto Install

:FACIT
INSTALL\unzip.exe -o INSTALL\NP7.CMP FAC*.*
goto Install

:FUJITSU
INSTALL\unzip.exe -o INSTALL\NP7.CMP FUJI*.*
goto Install

:GENICOM
INSTALL\unzip.exe -o INSTALL\NP7.CMP GENI*.*
goto Install

:GORILLA
INSTALL\unzip.exe -o INSTALL\NP7.CMP GORI*.*
goto Install

:IBM
INSTALL\unzip.exe -o INSTALL\NP7.CMP IBM*.*
goto Install

:IDS
INSTALL\unzip.exe -o INSTALL\NP7.CMP IDS*.*
goto Install

:JDL
INSTALL\unzip.exe -o INSTALL\NP7.CMP JDL*.*
goto Install

:MALIBU
INSTALL\unzip.exe -o INSTALL\NP7.CMP MAL*.*
goto Install

:MANES
INSTALL\unzip.exe -o INSTALL\NP7.CMP MAN*.*
goto Install

:MPI
INSTALL\unzip.exe -o INSTALL\NP7.CMP MPI*.*
goto Install

:NEC
INSTALL\unzip.exe -o INSTALL\NP7.CMP NEC*.*
goto Install

:NORTH
INSTALL\unzip.exe -o INSTALL\NP7.CMP NOR*.*
goto Install

:OKI
INSTALL\unzip.exe -o INSTALL\NP7.CMP OKI*.*
goto Install

:PAN
INSTALL\unzip.exe -o INSTALL\NP7.CMP PAN*.*
goto Install

:POST
INSTALL\unzip.exe -o INSTALL\NP7.CMP PS*.*
goto Install

:QUA
INSTALL\unzip.exe -o INSTALL\NP7.CMP QUA*.*
goto Install

:SEI
INSTALL\unzip.exe -o INSTALL\NP7.CMP SEI*.*
goto Install

:SHARP
INSTALL\unzip.exe -o INSTALL\NP7.CMP SHA*.*
goto Install

:STAR
INSTALL\unzip.exe -o INSTALL\NP7.CMP STAR*.*
goto Install

:TANDY
INSTALL\unzip.exe -o INSTALL\NP7.CMP TAN*.*
goto Install

:TI
INSTALL\unzip.exe -o INSTALL\NP7.CMP TI*.*
goto Install

:TOSHIBA
INSTALL\unzip.exe -o INSTALL\NP7.CMP TOS*.*
goto Install

:XEROX
INSTALL\unzip.exe -o INSTALL\NP7.CMP XER*.*

:Install
INSTALL\unzip.exe -o INSTALL\NP7.CMP HP*.* EPS*.*
if not exist *.PRD goto Konec

md STAMPS
INSTALL\unzip.exe -o INSTALL\NP6.CMP STAMPS
if not exist STAMPS\*.ST goto Konec

md FONTS
INSTALL\unzip.exe -o INSTALL\NP5.CMP FONTS
if not exist FONTS\*.GFT goto Konec

INSTALL\unzip.exe -o INSTALL\NP4.CMP
INSTALL\unzip.exe -o INSTALL\NP3.CMP
INSTALL\unzip.exe -o INSTALL\NP2.CMP
if not exist NEOPAINT.EXE goto Konec

md PALETTE
INSTALL\unzip.exe -o INSTALL\NP1.CMP PALETTE *.PAL
if not exist PALETTE\*.PAL goto Konec

md PATTERNS
INSTALL\unzip.exe -o INSTALL\NP1.CMP PATTERNS *.PAT
if not exist PATTERNS\*.PAT goto Konec

INSTALL\unzip.exe -o -d INSTALL\EXAMPLES.ZIP

md TEXT

if exist NEOPAINT.SET goto Start2

if "%1"=="" goto Init2
if not exist %1INSTALL\*.* goto Init2

echo PCXDir=%1PCX >       NEOPAINT.SET
echo GIFDir=%1GIF >       NEOPAINT.SET
echo TIFDir=%1TIFF >>     NEOPAINT.SET
echo BMPDir=%1BMP >>      NEOPAINT.SET
echo PATDir=%1PATTERNS >> NEOPAINT.SET
echo PALDir=%1PALETTE >>  NEOPAINT.SET
echo FontDir=%1FONTS >>   NEOPAINT.SET
echo StampDir=%1STAMPS >> NEOPAINT.SET
echo TextDir=%1TEXT >>    NEOPAINT.SET
goto Start2

:Init2
echo PCXDir=%0\..\PCX >       NEOPAINT.SET
echo GIFDir=%0\..\GIF >       NEOPAINT.SET
echo TIFDir=%0\..\TIFF >>     NEOPAINT.SET
echo BMPDir=%0\..\BMP >>      NEOPAINT.SET
echo PATDir=%0\..\PATTERNS >> NEOPAINT.SET
echo PALDir=%0\..\PALETTE >>  NEOPAINT.SET
echo FontDir=%0\..\FONTS >>   NEOPAINT.SET
echo StampDir=%0\..\STAMPS >> NEOPAINT.SET
echo TextDir=%0\..\TEXT >>    NEOPAINT.SET
goto Start2

:Start
cd > %0\..\$DIR$.TMP
%0\..\setdir.com %0\..

:Start2
if exist %1NEOPAINT.EXE goto Start3
NEOPAINT.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9
goto Konec2

:Start3
NEOPAINT.EXE %2 %3 %4 %5 %6 %7 %8 %9

:Konec2
setdir.com @$DIR$.TMP
if exist %0\..\$DIR$.TMP del %0\..\$DIR$.TMP

:Konec
