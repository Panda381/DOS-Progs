@echo off
if exist %0\..\ALCHEMY.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo --- Vyvolavate sluzby demoverze programu ALCHEMY! ---
echo Program  ALCHEMY  neni  dosud nainstalovan. Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po instalaci bude program ALCHEMY pripraven k pouziti
echo v  podadresari ALCHEMY programoveho adresare DOSMANu.
echo V  podadresari  ALCHEMY\INSTALL bude ponechan puvodni
echo distribucni balik programu ALCHEMY.
echo.
echo Demoverze programu ALCHEMY je plne funkcni s omezenim
echo maximalni  velikosti grafickych souboru na 640 x 480.
echo Program  ALCHEMY  vyzaduje  k  zobrazovani grafickych
echo souboru  videokartu  SVGA  se standardem VESA. Pomoci
echo programu  VESAINFO  muzete  otestovat, zda Vase karta
echo tento   standard   splnuje.  Pokud  ne,  nainstalujte
echo ovladac  pro VESA z diskety dodane k Vasi videokarte.
echo.
pause

cd > %0\..\$DIR$.TMP
%0\..\setdir.com %0\..

INSTALL\alch191d.exe

setdir.com @$DIR$.TMP
if exist %0\..\$DIR$.TMP del %0\..\$DIR$.TMP

:Start
%0\..\ALCHEMY.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
