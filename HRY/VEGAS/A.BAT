@echo off
tasm vegas.asm
if errorlevel == 1 goto chyba
tlink vegas.obj /t
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
:konec
del vegas.map
del vegas.obj
ren vegas.com v.com
copy /b v.com + vegas.scr vegas.com
del v.com

