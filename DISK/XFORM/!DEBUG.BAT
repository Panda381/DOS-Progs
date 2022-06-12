@echo off
:start

tasm xform.asm xform.obj /z/zi/t/DDEBUG
if errorlevel == 1 goto chyba
tasm xflop.asm xflop.obj /z/zi/t/DDEBUG
if errorlevel == 1 goto chyba
tasm typflop.asm typflop.obj /z/zi/t/DDEBUG
if errorlevel == 1 goto chyba
tasm oemdisk.asm oemdisk.obj /z/zi/t/DDEBUG
if errorlevel == 1 goto chyba

tlink xform.obj, xform.com, xform.map /m/t/l
if errorlevel == 1 goto chyba
tlink xflop.obj, xflop.com, xflop.map /m/t/l
if errorlevel == 1 goto chyba
tlink typflop.obj, typflop.com, typflop.map /m/t/l
if errorlevel == 1 goto chyba
tlink oemdisk.obj, oemdisk.com, oemdisk.map /m/t/l
if errorlevel == 1 goto chyba

tdmap xform.map xform.tds > nul
tdmap xflop.map xflop.tds > nul
tdmap typflop.map typflop.tds > nul
tdmap oemdisk.map oemdisk.tds > nul

goto konec
:chyba
pause
goto start
:konec

del xform.obj
del xflop.obj
del typflop.obj
del oemdisk.obj

del xform.map
del xflop.map
del typflop.map
del oemdisk.map

