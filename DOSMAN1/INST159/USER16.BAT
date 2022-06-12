@echo off
if "%1" == "" goto UPLKO
del %3$sez$.lst > nul:
del $test_z$.$$$ > nul:
cls
copy %3user16.bat %2$test_z$.$$$ > nul:
if exist $test_z$.$$$ goto KONEC
del %2$test_z$.$$$ > nul:
echo.
echo FUNKCE:     +++  ARCHIVUJ DO ARJ z neaktu†ln°ho okna specifikovanÇ soubory  +++
echo.
echo áinnost:    podle zadanÇ specifikace se hledaj°  v neaktu†ln°m oknà  soubory  a
echo             jejich kopie se ukl†daj° do  archivn°ho souboru  v  aktu†ln°m oknà.
echo konvence:   maska1 maska2 ..... /parametry
echo maska:      maska specifikace souboru, lze pouë°t n†hradn° znaky "?" "*"
echo parametry:  n†sleduj° za oddàlovac°m znakem "/", lze zad†vat intervaly od-do
echo D datum     podm°nkou hled†n° bude datum souboru, tvar dd.mm.rr
echo T áas       podm°nkou hled†n° bude áas souboru, tvar hh:mm:ss
echo N á°slo     podm°nkou hled†n° bude velikost souboru
echo R R+ r+     podm°nkou hled†n° je, ëe soubor m† nastaven atribut R/O
echo r R- r-     podm°nkou hled†n° je, ëe soubor m† vynulov†n atribut R/O
echo H H+ h+     podm°nkou hled†n° je, ëe soubor m† nastaven atribut HID
echo h H- h-     podm°nkou hled†n° je, ëe soubor m† vynulov†n atribut HID
echo S S+ s+     podm°nkou hled†n° je, ëe soubor m† nastaven atribut SYS
echo s S- s-     podm°nkou hled†n° je, ëe soubor m† vynulov†n atribut SYS
echo A A+ a+     podm°nkou hled†n° je, ëe soubor m† nastaven atribut ARC
echo a A- a-     podm°nkou hled†n° je, ëe soubor m† vynulov†n atribut ARC
echo z Z         nebudou prohled†v†ny podadres†©e
echo "text"      podm°nkou hled†n° bude text obsaëenò v souboru
echo.
echo neaktu†ln° okno  : %2
set get=DEJ_MI
if "%4" == "" goto CIL
if "%4" == "*" goto CIL
if "%4" == ".." goto CIL
set get=%4
:CIL
echo archivn° soubor  : %get%.ARJ
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
%3sharewar\arj a -a -vva -y %get%.ARJ !%3$sez$.lst > nul:    
echo.
%3utility\wait "stisknàte libovolnou kl†vesu: "
goto UPLKO

:KONEC
del $test_z$.$$$ > nul:
echo.
echo U tÇto funkce mus° ZAPNUTê NEAKTUèLNã OKNO zobrazovat jinò (zdrojovò) adres†©.
%3utility\wait "Stisknàte libovolnou kl†vesu: "

:UPLKO
