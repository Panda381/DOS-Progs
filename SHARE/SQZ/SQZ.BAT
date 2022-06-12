@echo off
if exist %0\..\SQZ.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo --- Vyvolavate sluzby sharewaroveho programu SQZ! ---
echo Program   SQZ   neni  dosud  nainstalovan.  Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po  instalaci  bude  program  SQZ pripraven k pouziti
echo v  podadresari   SQZ   programoveho adresare DOSMANu.
echo V   podadresari  SQZ\INSTALL  bude  ponechan  puvodni
echo distribucni balik programu SQZ.
echo.
echo UPOZORNENI - program  SQZ  je sharewarovy program  od
echo Jonas I Hammarberg  a   nevztahuji se na nej licencni
echo prava  programu  DOS  Manazer. Pri pouzivani programu
echo je potreba se zaregistrovat podle pokynu v SQZ.DOC.
echo.
pause

cd > %0\..\$DIR$.TMP
%0\..\setdir.com %0\..

INSTALL\sqz1083.exe

setdir.com @$DIR$.TMP
if exist %0\..\$DIR$.TMP del %0\..\$DIR$.TMP

:Start
%0\..\SQZ.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
