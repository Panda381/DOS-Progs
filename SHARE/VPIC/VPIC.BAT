@echo off
if exist %0\..\VPIC.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo -- Vyvolavate sluzby sharewaroveho programu VPIC ! --
echo Program   VPIC  neni  dosud  nainstalovan.  Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po  instalaci  bude  program VPIC pripraven k pouziti
echo v  podadresari  VPIC  programoveho  adresare DOSMANu.
echo V  podadresari  VPIC\INSTALL  bude  ponechan  puvodni
echo distribucni balik programu VPIC.
echo.
echo UPOZORNENI  -  program VPIC je sharewarovy program od
echo autora Bob Montgomery a nevztahuji se na nej licencni
echo prava  programu DOS Manazer. Program smi byt pouzivan
echo pouze  za  ucelem seznameni se s programem. Pro dalsi
echo pouziti  je nutne se zaregistrovat u autora programu.
echo.
pause

cd > %0\..\$DIR$.TMP
%0\..\setdir.com %0\..

INSTALL\vpic61.exe

setdir.com @$DIR$.TMP
if exist %0\..\$DIR$.TMP del %0\..\$DIR$.TMP

:Start
%0\..\VPIC.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
