@echo off
if exist %0\..\JAR.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo ----------- Vyvolavate sluzby sharewaroveho programu JAR ! -----------
echo Program JAR neni dosud nainstalovan. Chcete-li provest nyni instalaci,
echo stisknete  libovolnou  klavesu,  jinak  stisknete  klavesu Ctrl-C nebo
echo Ctrl-Break.  Po  nainstalovani  bude  program  JAR pripraven k pouziti
echo v   podadresari  JAR  programoveho  adresare  DOSMANu.  V  podadresari
echo JAR\INSTALL  bude  ponechan  puvodni  distribucni  balik programu JAR.
echo.
echo UPOZORNENI - program JAR je sharewarovy program od firmy  ARJ Software
echo a  nevztahuji  se  na nej licencni prava programu DOS Manazer. Program
echo smi  byt  pouzivan  pouze  pro  vlastni soukromou potrebu. Ve firmach,
echo obchodech  a institucich  smi byt provozovan pouze za ucelem seznameni
echo a  to  po  dobu  max.  30 dnu. Pro uplynuti teto doby nebo pro vyuziti
echo ke  komercnim  ucelum  je  nutne se zaregistrovat u firmu ARJ Software
echo podle licencnich podminek uvedenych v souboru LICENSE.DOC.
echo.
pause

%0\..\INSTALL\jar101bx.exe -w -o -m %0\..\
rd %0\..\JAR

:Start
%0\..\JAR.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
