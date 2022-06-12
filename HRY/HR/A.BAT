@echo off
:start
tasm hr,hr/z/zi;
if errorlevel == 1 goto chyba
tlink hr/l/v;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
rem goto start
:konec
