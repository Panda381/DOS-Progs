@echo off
if exist %0\..\PAK.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo --- Vyvolavate sluzby sharewaroveho programu PAK! ---
echo Program   PAK   neni  dosud  nainstalovan.  Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po  instalaci  bude  program  PAK pripraven k pouziti
echo v  podadresari  PAK  programoveho  adresare  DOSMANu.
echo V   podadresari  PAK\INSTALL  bude  ponechan  puvodni
echo distribucni balik programu PAK.
echo.
echo UPOZORNENI  -  program PAK je sharewarovy program  od
echo firmy NoGate Consult  a nevztahuji se na nej licencni
echo prava  programu DOS Manazer.
echo.
pause

%0\..\INSTALL\PAK251.EXE %0\..\ /w

:Start
%0\..\PAK.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
