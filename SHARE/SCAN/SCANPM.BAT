@echo off
if exist %0\..\SCANPM.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo -- Vyvolavate sluzby sharewaroveho programu SCAN ! --
echo Program  SCAN  neni  dosud  nainstalovan.   Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po  instalaci  bude  program SCAN pripraven k pouziti
echo v  podadresari  SCAN  programoveho  adresare DOSMANu.
echo V  podadresari  SCAN\INSTALL  bude  ponechan  puvodni
echo distribucni balik programu SCAN.
echo.
echo UPOZORNENI - program SCAN je sharewarovy  program  od
echo firmy  McAfee  Inc.  a  nevztahuji se na nej licencni
echo prava  programu DOS Manazer. Program smi byt pouzivan
echo ve  zkusebnim  provozu  po  dobu maximalne 30 dnu. Po
echo uplynuti  teto  doby musi byt program SCAN bud zrusen
echo z disku, nebo se musi uzivatel programu zaregistrovat
echo u firmy McAfee podle podminek v souboru README.1ST.
echo.
pause

%0\..\INSTALL\pkunzip -o -d %0\..\INSTALL\PM-253E.ZIP %0\..\

:Start
%0\..\SCANPM.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
