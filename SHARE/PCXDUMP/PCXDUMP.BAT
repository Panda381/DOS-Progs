@echo off
if exist %0\..\PCXDUMP.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo - Vyvolavate sluzby sharewaroveho programu PCXDUMP! -
echo Program  PCXDUMP  neni  dosud nainstalovan. Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po instalaci bude program PCXDUMP pripraven k pouziti
echo v  podadresari PCXDUMP programoveho adresare DOSMANu.
echo V  podadresari  PCXDUMP\INSTALL bude ponechan puvodni
echo distribucni balik programu PCXDUMP.
echo.
echo UPOZORNENI  -  program PCXDUMP je sharewarovy program
echo autora Jesper Frandsen, nevztahuji se na nej licencni
echo prava  programu DOS Manazer. Program smi byt pouzivan
echo ve  zkusebnim  provozu  po  dobu maximalne 10 dnu. Po
echo uplynuti  teto  doby  musi byt program PCXDUMP zrusen
echo z  disku nebo se musi uzivatel programu zaregistrovat
echo u autora podle podminek v souboru PCXDUMP.DOC.

echo.
pause

cls
copy %0\..\INSTALL\POZNAMKA.TXT %0\..\POZNAMKA.TXT > NUL
%0\..\INSTALL\PCXDMP90.EXE %0\..\ -o
%0\..\PCXDUMP.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9
type %0\..\POZNAMKA.TXT
pause
goto Konec

:Start
%0\..\PCXDUMP.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
