@echo off
:start
kontext xform.asm #2 xflop.asm #3 typflop.asm #4 oemdisk.asm #1

tasm xform.asm xform.obj /z/t
if errorlevel == 1 goto chyba
tasm xflop.asm xflop.obj /z/t
if errorlevel == 1 goto chyba
tasm typflop.asm typflop.obj /z/t
if errorlevel == 1 goto chyba
tasm oemdisk.asm oemdisk.obj /z/t
if errorlevel == 1 goto chyba

tlink xform.obj, xform.com /t/x
if errorlevel == 1 goto chyba
tlink xflop.obj, xflop.com /t/x
if errorlevel == 1 goto chyba
tlink typflop.obj, typflop.com /t/x
if errorlevel == 1 goto chyba
tlink oemdisk.obj, oemdisk.com /t/x
if errorlevel == 1 goto chyba

goto konec
:chyba
pause
goto start
:konec

del xform.obj
del xflop.obj
del typflop.obj
del oemdisk.obj

if exist xform.tds del xform.tds
if exist xflop.tds del xflop.tds
if exist typflop.tds del typflop.tds
if exist oemdisk.tds del oemdisk.tds
