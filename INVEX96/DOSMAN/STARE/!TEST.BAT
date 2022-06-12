@echo off
if "%1"=="" goto konec
call $genpov.bat
if exist gema_%1.tga del gema_%1.tga
call $rend.bat %1 -A
pause
alchemy gema_%1.tga --v -X640 -Y480
:konec