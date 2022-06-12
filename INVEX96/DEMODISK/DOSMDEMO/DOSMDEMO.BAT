@echo off
rem   -------------------------------------------------
rem   Startovaci povelovy soubor programu DOS Manazer 2
rem   -------------------------------------------------
rem   Tento  soubor  zajistuje provadeni prikazu pomoci
rem   modu BAT. Spustenim samotneho programu DOSMAN.EXE
rem   zpusobi  provedeni  prikazu  v  modu BAT ukonceni
rem   programu DOSMAN.EXE bez navratu !
rem   -------------------------------------------------
rem   Pozn.: Parametry programu DOSMAN.EXE se zobrazi
rem          po zadani prikazu:        DOSMAN /?
rem
rem  Pri spousteni v okne WINDOWS zadejte parametry:
rem      /WINDOWS /LAT

rem
rem =============== Potvrzeni instalace ==================
rem
if exist c:\gemasoft\dosmdemo\dosman.exe goto JeInst
cls
echo Program DOSMAN - DEMO neni nainstalovan v adresari C:\GEMASOFT\DOSMDEMO.
echo Provedte instalaci zadanim prikazu:
echo      INSTALL
echo.
goto Konec

:JeInst
rem
rem ============ Start programu DOS Manazer ==============
rem
if exist c:\gemasoft\dosmdemo\$dosman$.cfg del c:\gemasoft\dosmdemo\$dosman$.cfg
:Start
if exist c:\gemasoft\dosmdemo\$dosman$.bat del c:\gemasoft\dosmdemo\$dosman$.bat
c:\gemasoft\dosmdemo\dosman.exe %1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto Konec
if not exist c:\gemasoft\dosmdemo\$dosman$.bat goto Konec
call c:\gemasoft\dosmdemo\$dosman$.bat
goto Start

:Konec
