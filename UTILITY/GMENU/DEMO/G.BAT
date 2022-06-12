@echo off
:Start
gmenu
if errorlevel == 254 goto konec
if errorlevel == 18 goto Vlak
if errorlevel == 14 goto Vejce
if errorlevel == 13 goto DosMan
if errorlevel == 12 goto Tetrix
if errorlevel == 8 goto Abeceda
goto Start

:Vlak
echo vlak
pause
goto Start

:Vejce
echo vejce
pause
goto Start

:DosMan
echo call dosm
pause
goto Start

:Tetrix
echo tetrix
pause
goto Start

:Abeceda
echo abeceda
pause
goto Start

:konec
