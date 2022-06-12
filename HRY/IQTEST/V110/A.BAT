@echo off
:start
kontext iqtest.asm #2 iqtest.dat #1
tasm iqtest.asm iqtest.obj /z
if errorlevel == 1 goto chyba
tlink iqtest.obj, iqtest2.com /t/l/v/s
if not errorlevel == 1 goto konec
:chyba
pause
goto start
:konec

del iqtest2.map
del iqtest.obj

copy /b iqtest2.com + iqtest.dat pseudoiq.com
del iqtest2.com
