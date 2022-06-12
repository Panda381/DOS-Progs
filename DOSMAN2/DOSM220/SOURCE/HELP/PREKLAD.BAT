@echo off
:start
..\exec\egacs k > NUL
..\exec\cskey k > NUL
..\exec\kontext screen.asm 
..\exec\egacs ! > NUL
..\exec\cskey ! > NUL

..\exec\tasm screen.asm screen.obj /z/zi/m5/t
if errorlevel == 1 goto chyba

..\exec\tlink screen.obj, screen.ovl /t/l/s/x
if not errorlevel == 1 goto konec

:chyba
..\exec\wait "CHYBA: Esc=preruseni, jina klavesa opakovani..."
if not errorlevel 1 goto start

:konec
del screen.obj
