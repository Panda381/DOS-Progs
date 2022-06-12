@echo off
:start

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
:konec

del xform.obj
del xflop.obj
del typflop.obj
del oemdisk.obj

if exist xform.tds del xform.tds
if exist xflop.tds del xflop.tds
if exist typflop.tds del typflop.tds
if exist oemdisk.tds del oemdisk.tds

md xform_l > nul
copy ask.com xform_l\ask.com
copy ask.txt xform_l\ask.txt
copy xformat.bat xform_l\xformat.bat
copy xform.com xform_l\xform.com
copy xform.txt xform_l\xform.txt
copy xflop.com xform_l\xflop.com
copy xflop.txt xform_l\xflop.txt
copy typflop.com xform_l\typflop.com
copy typflop.txt xform_l\typflop.txt
copy oemdisk.com xform_l\oemdisk.com
copy oemdisk.txt xform_l\oemdisk.txt
