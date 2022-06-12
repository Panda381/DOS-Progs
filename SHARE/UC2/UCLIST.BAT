@echo off
if exist %0\..\UC.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo --- Vyvolavate sluzby sharewaroveho programu UC2! ---
echo Program   UC2   neni  dosud  nainstalovan.  Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo V   podadresari   UC2\INSTALL  programoveho  adresare
echo DOS Manazeru bude  ponechan puvodni distribucni balik
echo programu UC2.
echo.
echo UPOZORNENI   -  program UC2 je sharewarovy program od
echo firmy   AIP-NL   a  nevztahuji  se  na  nej  licencni
echo prava  programu DOS Manazer. Program smi byt pouzivan
echo ve  zkusebnim  provozu  po  dobu maximalne 30 dnu. Po
echo uplynuti  teto  doby  musi byt program UC2 bud zrusen
echo z disku, nebo se musi uzivatel programu zaregistrovat
echo u firmy AIP-NL podle podminek v souboru LICENSE.DOC.
echo.
pause

%0\..\INSTALL\uc2pro.exe -o %0\..

:Start
%0\..\UC.EXE VS %2 %3 %4 %5 %6 %7 %8 %9 > %1

:Konec
