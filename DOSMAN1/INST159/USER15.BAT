@echo off
if "%1" == "" goto UPLKO
del %3$sez$.lst > nul:
del $test_z$.$$$ > nul:
cls
copy %3user15.bat %2$test_z$.$$$ > nul:
if exist $test_z$.$$$ goto KONEC
del %2$test_z$.$$$ > nul:
echo.
echo FUNKCE:     ***  ARCHIVUJ DO ZIP z neaktu�ln�ho okna specifikovan� soubory  ***
echo.
echo �innost:    podle zadan� specifikace se hledaj�  v neaktu�ln�m okn�  soubory  a
echo             jejich kopie se ukl�daj� do  archivn�ho souboru  v  aktu�ln�m okn�.
echo konvence:   maska1 maska2 ..... /parametry
echo maska:      maska specifikace souboru, lze pou��t n�hradn� znaky "?" "*"
echo parametry:  n�sleduj� za odd�lovac�m znakem "/", lze zad�vat intervaly od-do
echo D datum     podm�nkou hled�n� bude datum souboru, tvar dd.mm.rr
echo T �as       podm�nkou hled�n� bude �as souboru, tvar hh:mm:ss
echo N ��slo     podm�nkou hled�n� bude velikost souboru
echo R R+ r+     podm�nkou hled�n� je, �e soubor m� nastaven atribut R/O
echo r R- r-     podm�nkou hled�n� je, �e soubor m� vynulov�n atribut R/O
echo H H+ h+     podm�nkou hled�n� je, �e soubor m� nastaven atribut HID
echo h H- h-     podm�nkou hled�n� je, �e soubor m� vynulov�n atribut HID
echo S S+ s+     podm�nkou hled�n� je, �e soubor m� nastaven atribut SYS
echo s S- s-     podm�nkou hled�n� je, �e soubor m� vynulov�n atribut SYS
echo A A+ a+     podm�nkou hled�n� je, �e soubor m� nastaven atribut ARC
echo a A- a-     podm�nkou hled�n� je, �e soubor m� vynulov�n atribut ARC
echo z Z         nebudou prohled�v�ny podadres��e
echo "text"      podm�nkou hled�n� bude text obsa�en� v souboru
echo.
echo neaktu�ln� okno  : %2
set get=DEJ_MI
if "%4" == "" goto CIL
if "%4" == "*" goto CIL
if "%4" == ".." goto CIL
set get=%4
:CIL
echo archivn� soubor  : %get%.ZIP
%3utility\get specifikace      : 
if "%get%" == "" goto UPLKO
%3utility\hledej %2%get% /c > %3$sez$.lst
if not exist %3$sez$.lst goto UPLKO
set get=DEJ_MI
if "%4" == "" goto ARCH
if "%4" == "*" goto ARCH
if "%4" == ".." goto ARCH
set get=%4
:ARCH
echo.
echo archivuji ...
%3sharewar\pkzip -a -ex -P -whs %get%.ZIP @%3$sez$.lst > nul:
echo.
%3utility\wait "stiskn�te libovolnou kl�vesu: "
goto UPLKO

:KONEC
del $test_z$.$$$ > nul:
echo.
echo U t�to funkce mus� ZAPNUT� NEAKTU�LN� OKNO zobrazovat jin� (zdrojov�) adres��.
%3utility\wait "Stiskn�te libovolnou kl�vesu: "

:UPLKO
