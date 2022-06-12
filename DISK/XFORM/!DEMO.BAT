@echo off
:start

tasm xform.asm xform.obj /z/t/dDEMO
if errorlevel == 1 goto chyba
tasm xflop.asm xflop.obj /z/t/dDEMO
if errorlevel == 1 goto chyba
tasm typflop.asm typflop.obj /z/t/dDEMO
if errorlevel == 1 goto chyba
tasm oemdisk.asm oemdisk.obj /z/t/dDEMO
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

md xform_d > nul
copy ask.com xform_d\ask.com
copy ask.txt xform_d\ask.txt
copy xformat.bat xform_d\xformat.bat
copy xform.com xform_d\xform.com
copy xform.txt xform_d\xform.txt
copy xflop.com xform_d\xflop.com
copy xflop.txt xform_d\xflop.txt
copy typflop.com xform_d\typflop.com
copy typflop.txt xform_d\typflop.txt
copy oemdisk.com xform_d\oemdisk.com
copy oemdisk.txt xform_d\oemdisk.txt
copy file_idd.diz xform_d\file_id.diz
