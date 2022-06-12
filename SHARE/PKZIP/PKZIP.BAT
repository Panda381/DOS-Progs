@echo off
if exist %0\..\PKZIP.EXE goto Start
if not exist %0\..\INSTALL\*.exe goto Konec

cls
echo -- Vyvolavate sluzby sharewaroveho programu PKZIP! --
echo Program  PKZIP  neni  dosud  nainstalovan.  Chcete-li
echo provest nyni instalaci, stisknete libovolnou klavesu,
echo jinak   stisknete  klavesu  Ctrl-C  nebo  Ctrl-Break.
echo Po  instalaci  bude program PKZIP pripraven k pouziti
echo v  podadresari  PKZIP  programoveho adresare DOSMANu.
echo V  podadresari  PKZIP\INSTALL  bude  ponechan puvodni
echo distribucni balik programu PKZIP.
echo.
echo UPOZORNENI - program PKZIP je sharewarovy program  od
echo firmy  PKWARE  Inc.  a  nevztahuji se na nej licencni
echo prava  programu DOS Manazer. Program smi byt pouzivan
echo pouze  pro  vlastni soukromou potrebu. Pro pouziti na
echo vice  pocitacich  nebo pro distribuci dat je nutne se
echo zaregistrovat   u   firmy   PKWARE  podle  licencnich
echo podminek uvedenych v souboru LICENSE.DOC.
echo.
pause

cls
echo Poznamka
echo --------
echo Program  PKZIP umoznuje archivaci dat na vice disket.
echo Pri  vicedisketove  archivaci  se doporucuje pouzivat
echo nasledujici postupy: Archivovat vicedisketove lze jen
echo na diskety, tj. nelze vytvorit na pevnem disku soubor
echo rozdeleny na casti. Diskety s archivnim souborem jsou
echo programem  PKZIP oznaceny jmenem disku "PKBACK# nnn",
echo kde  "nnn"  je poradove cislo diskety 001 a vice. Pri
echo rozbalovani  obsahu  disket  se  zacina rozbalovat od
echo posledni  diskety, kde ma program PKZIP ulozen seznam
echo souboru na vsech disketach. Potom se vkladaji vsechny
echo diskety  postupne  od prvni diskety. Je-li z nejakeho
echo duvodu zmeneno jmeno nektere z disket (napr. je-li na
echo nekterou  z  disket  archivovan dalsi soubor ZIP), je
echo nutne  zrusit  nebo zmenit jmena vsech disket archivu
echo tak,  aby  neodpovidala  tvaru  pouzivanemu programem
echo PKZIP.  V tomto pripade program prestane kontrolovat,
echo zda je vlozena spravna disketa (podle jmena diskety).
echo.
pause

%0\..\INSTALL\PKZ204G.EXE %0\..\ -o

:Start
%0\..\PKZIP.EXE %1 %2 %3 %4 %5 %6 %7 %8 %9

:Konec
