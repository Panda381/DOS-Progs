@echo off
:start
\assemb\kontext hexaedi.asm #2 hexadat.asm #3 hexadis.asm #1
tasm hexa.asm hexa.obj /z/zi
if errorlevel == 1 goto chyba
tlink hexa.obj, hexa.com, hexa.map /t/l/v/s/m
if errorlevel == 1 goto chyba
tdmap hexa.map hexa.com
goto konec
:chyba
pause
goto start
:konec
del hexa.map
del hexa.obj
