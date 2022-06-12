@echo off
if "%1" == "" goto UPLKO
if "%4" == ".." goto VSE

:DVA
echo Porovn m soubory: %1 %2%1

%3utility\wait "Bin rnˆ ?   Esc = ne "
if errorlevel 1 goto BINE

:BIANO
@echo on
fc %1 %2%1 /b
@echo off
goto KON

:BINE
@echo on
fc %1 %2%1 /l
@echo off
goto KON

:VSE
echo Porovn m v¨echny soubory aktu ln¡ho okna se soubory neaktu ln¡ho okna.

%3utility\wait "Bin rnˆ ?   Esc = ne "
if errorlevel 1 goto BINNE

:BINANO
%3utility\wait "V˜sledek do souboru ..\-VYSLED-.TXT ?   Esc = ne "
if errorlevel 1 goto SOUNE

:SOUANO
@echo on
fc *.* %2*.* /b > ..\-VYSLED-.TXT
@echo off
goto UPLKO

:SOUNE
@echo on
fc *.* %2*.* /b
@echo off
goto KON

:BINNE
%3utility\wait "V˜sledek do souboru ..\-VYSLED-.TXT ?   Esc = ne "
if errorlevel 1 goto SOUBNE

:SOUBANO
@echo on
fc *.* %2*.* /l > ..\-VYSLED-.TXT
@echo off
goto UPLKO

:SOUBNE
@echo on
fc *.* %2*.* /l
@echo off
goto KON

:KON
%3utility\wait "Stisknˆte libovolnou kl vesu: "
:UPLKO
