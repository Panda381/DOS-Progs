@echo off
if "%1" == "" goto UPLKO
del %3$sez$.lst > nul:
del $test_z$.$$$ > nul:
cls
copy %3user10.bat %2$test_z$.$$$ > nul:
if exist $test_z$.$$$ goto KONEC
del %2$test_z$.$$$ > nul:
echo.
echo funkce:     ---  DEJ MI z neaktu�ln�ho okna kopie specifikovan�ch soubor�  ---
echo.
echo �innost:    podle zadan� specifikace se hledaj� v neaktu�ln�m okn�  soubory  a
echo             kop�ruj� se do aktu�ln�ho okna. Plat� omezen� konvence pro HLEDEJ,
echo             nenaleznou se soubory s atributy Hidden a System.
echo.
echo konvence:   maska1 maska2 ..... /parametry
echo.
echo maska:      maska specifikace souboru, lze pou��t n�hradn� znaky "?" "*"
echo.
echo parametry:  n�sleduj� za odd�lovac�m znakem "/", lze zad�vat intervaly od-do
echo D datum     podm�nkou hled�n� bude datum souboru, tvar dd.mm.rr
echo T �as       podm�nkou hled�n� bude �as souboru, tvar hh:mm:ss
echo N ��slo     podm�nkou hled�n� bude velikost souboru
echo R R+ r+     podm�nkou hled�n� je, �e soubor m� nastaven atribut R/O
echo r R- r-     podm�nkou hled�n� je, �e soubor m� vynulov�n atribut R/O
echo A A+ a+     podm�nkou hled�n� je, �e soubor m� nastaven atribut ARC
echo a A- a-     podm�nkou hled�n� je, �e soubor m� vynulov�n atribut ARC
echo z Z         nebudou prohled�v�ny podadres��e
echo "text"      podm�nkou hled�n� bude text obsa�en� v souboru
echo.
echo neaktu�ln� okno  : %2
echo.
%3utility\get specifikace      : 
if "%get%" == "" goto UPLKO
%3utility\hledej %2%get% /c /h /s > %3$sez$.lst
if not exist %3$sez$.lst goto ULPKO
echo.
echo kop�ruji ...
%3utility\subpar %3$sez$.lst "copy @ > nul:" > nul:
call %3utility\subpar@.bat x x %3
echo.
%3utility\wait "stiskn�te libovolnou kl�vesu: "
goto UPLKO

:KONEC
del $test_z$.$$$ > nul:
echo.
echo U t�to funkce mus� ZAPNUT� NEAKTU�LN� OKNO zobrazovat jin� (zdrojov�) adres��.
%3utility\wait "Stiskn�te libovolnou kl�vesu: "

:UPLKO
