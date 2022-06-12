@echo off
if exist %0\..\GWS.EXE goto Start
if not exist %0\..\INSTALL\*.zip goto Konec

cls
echo --- Vyvolavate sluzby sharewaroveho programu GWS! ---
echo Program   GWS   neni  dosud  nainstalovan.  Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po  instalaci  bude  program  GWS pripraven k pouziti
echo v  podadresari  GWS  programoveho  adresare  DOSMANu.
echo V   podadresari  GWS\INSTALL  bude  ponechan  puvodni
echo distribucni   balik  programu  GWS.  Pomoci  programu
echo GWSINSTL  muzete nastavovat konfiguraci programu GWS.
echo Klavesou "?" zobrazite v programu GWS napovedu.
echo.
echo UPOZORNENI  -  program GWS je sharewarovy program  od
echo firmy  Alchemy  Mindworks Inc. a nevztahuji se na nej
echo licencni  prava  programu  DOS Manazer. Firma Alchemy
echo Mindworks  Inc.  pouzivani  programu  GWS  neomezuje.
echo V  pripade, ze se Vam program zalibi, prosi o zaslani
echo registracniho  poplatku  na podporu shareware (blizsi
echo informace naleznete v souboru GWS.DOC).
echo.
pause

cd > %0\..\$DIR$.TMP
%0\..\setdir.com %0\..

INSTALL\zipper INSTALL\GWSDOS

inkey !
inkey F1 F10 F2 UP UP UP UP UP ENTER F10 F10
GWSINSTL.EXE

setdir.com @$DIR$.TMP
if exist %0\..\$DIR$.TMP del %0\..\$DIR$.TMP

:Start
%0\..\GWS.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
