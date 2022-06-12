@echo off
REM ************************************************************************
REM
REM                      Mini-manazer operacniho systemu DOS
REM
REM ************************************************************************

REM =================================
REM Definice domovskeho adresare DMIP
REM =================================
copy /b setdmip.dat setdmip.bat >nul
cd >> setdmip.bat
call setdmip.bat
del setdmip.bat

:MAIN
REM =================================
REM        Start hlavniho menu
REM =================================
%DMIP%\vyber %DMIP%\main.mnu /J80 "Zvolte operaci a stisknete ENTER..."
if errorlevel 255 goto KONEC
if errorlevel 5 goto KOPIE
if errorlevel 4 goto VYTVORENI
if errorlevel 3 goto ADRESAR
if errorlevel 2 goto DISK

:INFORM
REM =================================
REM       Informace o DOSMINI
REM =================================
%DMIP%\cti %DMIP%\dosmini.txt
goto MAIN

:DISK
REM =================================
REM       Zmˆna aktivn¡ho disku
REM =================================
%DMIP%\vyber %DMIP%\disk.mnu %DMIP%\disk.bat "Zvolte novy disk..."
if errorlevel 255 goto MAIN
call %DMIP%\disk.bat
del %DMIP%\disk.bat
goto MAIN

:ADRESAR
REM =================================
REM    Zobrazeni a zmena adresare
REM =================================
call %DMIP%\voldir.bat "Adresar..."
goto MAIN

:VYTVORENI
REM =================================
REM    Vytvoreni noveho adresare
REM =================================
set GET=
%DMIP%\get Zadejte novy adresar k vytvoreni (ENTER=konec): 
if "%GET%"=="" goto MAIN
md %GET%
goto MAIN

:KOPIE
REM =================================
REM       Kopirovani souboru
REM =================================
call %DMIP%\aktdir.bat

copy /b %DMIP%\kopie.dat + %DMIP%\adr.lst %DMIP%\file.lst >nul
del %DMIP%\adr.lst
%DMIP%\vyber %DMIP%\file.lst %DMIP%\file.tmp /E10/D28/C38/V19 " "
if errorlevel 255 goto MAIN
call %DMIP%\pushdir.bat
del %DMIP%\file.lst

:KOPDISK
%DMIP%\vyber %DMIP%\disk.mnu %DMIP%\disk.bat "Cilovy disk..."
if errorlevel 255 goto KOPKON
call %DMIP%\disk.bat
del %DMIP%\disk.bat

:KOPDIR
call %DMIP%\voldir.bat "ESC=start kopirovani"

%DMIP%\subpar %DMIP%\file.tmp "copy %SDIR%\@"
call %DMIP%\subpar@.bat

:KOPKON
call %DMIP%\popdir.bat
del %DMIP%\popdir.bat
del %DMIP%\file.tmp
goto MAIN


:KOPA
REM =================================
REM       Kopirovani adresare
REM =================================
call %DMIP%\aktdir.bat

copy /b %DMIP%\kopa.dat + %DMIP%\adr.lst %DMIP%\file.lst >nul
del %DMIP%\adr.lst
%DMIP%\vyber %DMIP%\file.lst %DMIP%\file.tmp /E10/D28/C38/V19 " "
if errorlevel 255 goto MAIN
call %DMIP%\pushdir.bat
del %DMIP%\file.lst

%DMIP%\vyber %DMIP%\disk.mnu %DMIP%\disk.bat "Cilovy disk..."
if errorlevel 255 goto KOPAKON
call %DMIP%\disk.bat
del %DMIP%\disk.bat

call %DMIP%\voldir.bat "ESC=start kopirovani"

%DMIP%\subpar %DMIP%\file.tmp "xcopy %SDIR%\@"
call %DMIP%\subpar@.bat

:KOPAKON
call %DMIP%\popdir.bat
del %DMIP%\popdir.bat
del %DMIP%\file.tmp
goto MAIN

:KONEC
set DMIP=
