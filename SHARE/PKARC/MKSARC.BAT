@echo off
if exist %0\..\MKSARC.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo -- Vyvolavate sluzby sharewaroveho programu PKARC! --
echo Program  PKARC  neni  dosud  nainstalovan.  Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po  instalaci  bude program PKARC pripraven k pouziti
echo v  podadresari  PKARC  programoveho adresare DOSMANu.
echo V  podadresari  PKARC\INSTALL  bude  ponechan puvodni
echo distribucni balik programu PKARC.
echo.
echo UPOZORNENI - program PKARC je sharewarovy program  od
echo firmy  PKWARE  Inc.  a  nevztahuji se na nej licencni
echo prava  programu DOS Manazer. Program smi byt pouzivan
echo pouze  pro  vlastni soukromou potrebu. Pro pouziti na
echo vice  pocitacich  nebo pro distribuci dat je nutne se
echo zaregistrovat   u   firmy   PKWARE  podle  licencnich
echo podminek uvedenych v souboru MANUAL.DOC.
echo.
pause

%0\..\INSTALL2\ARC712.EXE %0\..\ /o
%0\..\INSTALL\PK36.EXE -r %0\..\
copy %0\..\INSTALL\PKARC.CZ %0\.. > NUL
copy %0\..\INSTALL\PKSFX.PGM %0\.. > NUL

:Start
%0\..\MKSARC.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
