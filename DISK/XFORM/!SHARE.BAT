@echo off
:start

tasm xform.asm xform.obj /z/t/dSHARE
if errorlevel == 1 goto chyba
tasm xflop.asm xflop.obj /z/t/dSHARE
if errorlevel == 1 goto chyba
tasm typflop.asm typflop.obj /z/t/dSHARE
if errorlevel == 1 goto chyba
tasm oemdisk.asm oemdisk.obj /z/t/dSHARE
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

md xform_s > nul
copy ask.com xform_s\ask.com
copy ask.txt xform_s\ask.txt
copy xformat.bat xform_s\xformat.bat
copy xform.com xform_s\xform.com
copy xform.txt xform_s\xform.txt
copy xflop.com xform_s\xflop.com
copy xflop.txt xform_s\xflop.txt
copy typflop.com xform_s\typflop.com
copy typflop.txt xform_s\typflop.txt
copy oemdisk.com xform_s\oemdisk.com
copy oemdisk.txt xform_s\oemdisk.txt
copy file_ids.diz xform_s\file_id.diz
