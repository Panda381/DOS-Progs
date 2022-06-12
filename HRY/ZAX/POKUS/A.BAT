@echo off
:start
\tasm\kontext zax.asm #2 zx.asm #1
\tasm\tasm zax.asm zax.obj /z/zi
if errorlevel == 1 goto chyba
\tasm\binobj zax.scr zaxscr.obj SCR
\tasm\tlink zax.obj+zaxscr.obj, zax.exe /l/v/x
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del zax.obj
