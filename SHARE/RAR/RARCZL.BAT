@echo off
if exist %0\..\RAR.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo --- Vyvolavate sluzby sharewaroveho programu RAR! ---
echo Program   RAR   neni  dosud  nainstalovan.  Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po  instalaci  bude  program  RAR pripraven k pouziti
echo v  podadresari  RAR  programoveho  adresare  DOSMANu.
echo V   podadresari  RAR\INSTALL  bude  ponechan  puvodni
echo distribucni balik programu RAR. Soubory *.CZ obsahuji
echo cesky  popis  programu  RAR  verze 1.54 (zobrazite je
echo stiskem klavesy ENTER na tectho souborech).
echo.
echo UPOZORNENI - program  RAR  je sharewarovy program  od
echo autora  Eugene Roshal a nevztahuji se na nej licencni
echo prava  programu DOS Manazer. Program smi byt pouzivan
echo ve  zkusebnim  provozu  po  dobu maximalne 40 dnu. Po
echo uplynuti  teto  doby  musi byt program RAR bud zrusen
echo z disku, nebo se musi uzivatel programu zaregistrovat
echo u autora RAR podle podminek v souboru LICENSE.TXT.

echo.
pause

copy %0\..\INSTALL\RARCZK.EXE %0\..\RARCZK.EXE > NUL
copy %0\..\INSTALL\RARCZL.EXE %0\..\RARCZL.EXE > NUL
copy %0\..\INSTALL\*.CZ %0\..\*.* > NUL

cd > %0\..\$DIR$.TMP
%0\..\setdir.com %0\..\..
RAR\inkey.com !
RAR\inkey.com SPACE SPACE DOWN DOWN ENTER
RAR\INSTALL\RAR200.EXE
RAR\setdir.com @RAR\$DIR$.TMP
if exist %0\..\$DIR$.TMP del %0\..\$DIR$.TMP

:Start
%0\..\RARCZL.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
