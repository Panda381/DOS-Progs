@echo off
cls
rem ========================================================================
rem            Ovˆ©en¡, zda byl zad n zdrojov˜ disk A: nebo B:
rem ========================================================================

if "%1"=="A:" goto ZADANO
if "%1"=="a:" goto ZADANO
if "%1"=="B:" goto ZADANO
if "%1"=="b:" goto ZADANO

echo Zadejte, prosim, jako parametr oznaceni disku A: nebo B:, z ktereho
echo je program VSEMI10 instalovan (zadejte "A:INST A:" nebo "B:INST B:").
echo.
goto KONEC

:ZADANO
rem ========================================================================
rem                Ovˆ©en¡, zda je vlo‘ena spr vn  disketa
rem ========================================================================

if not exist %1\VSEMI10.EXE goto NESPRAVNA
if not exist %1\GET.COM goto NESPRAVNA
if not exist %1\ASK.COM goto NESPRAVNA
if not exist %1\READ0.COM goto NESPRAVNA
if not exist %1\CTI.COM goto NESPRAVNA
if not exist %1\CTI_MNE.TXT goto NESPRAVNA
if exist %1\HDINST.EXE goto SPRAVNA

:NESPRAVNA
echo V disketove mechanice %1 neni vlozena spravna
echo disketa s instalacni verzi programu VSEMI10 !
echo.
goto KONEC

:SPRAVNA
rem ========================================================================
rem              Kontrola voln‚ho m¡sta v syst‚mov‚m prost©ed¡
rem ========================================================================

set CIL=C:\VSEMI10
if not "%CIL%" == "C:\VSEMI10" goto NESTACI 
set GET=C:\VSEMI10
if "%GET%" == "C:\VSEMI10" goto ZADANI
:NESTACI
echo.
echo Lituji, systemove prostredi neni dost velke k zadani ciloveho adresare.
echo Zkuste  uvolnit prostredi prikazem SET nebo prostredi zvetste prikazem
echo SHELL popripade provedte instalaci programu rucne:
echo.
echo         1.- zkopirujte vsechny soubory s disku %1 do ciloveho adresare
echo             (vcetne podadresare TESTY) - napr. do adresare C:\VSEMI10
echo         2.- provedte prikaz %1HDINST %1 cilovy_adresar
echo         3.- zadejte prikaz CTI - zobrazi se uvodni informace k programu
echo         4.- zadejte prikaz VSEMI10 - spusti se hlavni program   
echo.
goto KONEC

:ZADANI
rem ========================================================================
rem                     V˜zva k zad n¡ c¡lov‚ho adres ©e
rem ========================================================================

set GET=
echo ------------------------------------------------------
echo Program VSEMI10 bude nainstalovan do adresare %CIL%
echo Potvrdte instalaci stiskem klavesy ENTER nebo zadejte
%1\get jiny cilovy adresar (nesmi byt znak "\" na konci !): 
echo.
if "%GET%" == "" goto TESTCILE 
set CIL=%GET%
if not "%CIL%" == "%GET%" goto NESTACI
goto ZADANI

:TESTCILE
rem ========================================================================
rem                    Test spr vn‚ho zad n¡ adres ©e
rem ========================================================================

if not exist %CIL%\nul md %CIL%
if not exist %CIL%\nul goto CHYBAADR
if not exist %CIL%\protokol\nul md %CIL%\protokol
if not exist %CIL%\testy\nul md %CIL%\testy
if exist %CIL%\testy\nul goto VYTVOREN
:CHYBAADR
echo.
echo #########################################################
echo.
echo Chybne zadani ciloveho adresare, adresar nelze vytvorit !
echo.
echo #########################################################
echo.
goto SPRAVNA 

:VYTVOREN
rem ========================================================================
rem                  Test, zda je ji‘ program nainstalov n
rem ========================================================================
if exist %CIL%\VSEMI10i.EXE goto STARA 
if not exist %CIL%\VSEMI10.EXE goto INSTALACE 

:STARA
echo.
echo V adresari %CIL% je jiz nainstalovana stara verze programu VSEMI10.
echo Chcete starou verzi prepsat touto instalovanou novou verzi ?
%1\ask "Zadejte A=ANO (instalovat), N=NE (prerusit instalaci)"an
if errorlevel 2 goto PRERUSENI  
echo.

if exist %CIL%\VSEMI10i.EXE %1\read0.com %CIL%\VSEMI10i.EXE
if exist %CIL%\VSEMI10i.EXE del %CIL%\VSEMI10i.EXE
if exist %CIL%\VSEMI10.EXE %1\read0.com %CIL%\VSEMI10.EXE
if exist %CIL%\VSEMI10.EXE del %CIL%\VSEMI10.EXE

:INSTALACE
rem ========================================================================
rem                  Instalace programu do c¡lov‚ho adres ©e
rem ========================================================================
echo Cekejte, probiha instalace programu...
copy %1\*.* %CIL%\*.* > nul
copy %1\testy\*.* %CIL%\testy\*.* > nul
del %CIL%\inst.bat
del %CIL%\hdinst.exe
echo.
%1\hdinst %1 %CIL%
if not errorlevel 1 goto VSEOK

copy %1\VSEMI10.EXE %CIL%\VSEMI10.EXE
if exist %CIL%\VSEMI10.EXE goto INSTCAST

echo.
echo Chyba instalace programu VSEMI10 - zrejme plny cilovy disk !
echo.
goto KONEC

:INSTCAST
echo.
echo Instalaci hlavniho programu VSEMI10 nebyla uspesna.
echo Program byl nainstalovan, ale k jeho provozu bude
echo nutna pritomnost licencni diskety v mechanice %1 !
echo.

:VSEOK
cd %CIL%
cti
echo.
echo.
echo Instalace programu VSEMI10 dokoncena. Informacni text znovu zobrazite
echo zadanim prikazu CTI. Program VSEMI10 nyni spustite zadanim prikazu:
echo.
echo   VSEMI10
echo.
goto KONEC

:PRERUSENI
echo.
echo Instalace programu VSEMI10 prerusena !
echo.

:KONEC
set GET=
set CIL=