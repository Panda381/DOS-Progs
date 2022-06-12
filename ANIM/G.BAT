@echo off
:start
c:\assemb\kontext GA.ASM
cd\nem\anim
masm ga,ga/z;
if errorlevel == 1 goto chyba
link ga,ga;
if errorlevel == 1 goto chyba

goto konec

:chyba
pause
goto start

:konec
