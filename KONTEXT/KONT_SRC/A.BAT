@echo off
:start
kontext k2.asm #2 #3 kdat.asm #4 kdef.asm #1 
tasm k1.asm /z > aaa
if errorlevel == 1 goto chyba
tasm k2.asm /z > aaa
if errorlevel == 1 goto chyba
tasm k3.asm /z > aaa
if errorlevel == 1 goto chyba
tasm k4.asm /z > aaa
if errorlevel == 1 goto chyba
tasm k5.asm /z > aaa
if errorlevel == 1 goto chyba
tasm k6.asm /z > aaa
if errorlevel == 1 goto chyba
tasm k7.asm /z > aaa
if errorlevel == 1 goto chyba
tasm k8.asm /z > aaa
if errorlevel == 1 goto chyba
tlink k1+k2+k3+k4+k5+k6+k7+k8,k /m/t/l/s/v > aaa
if errorlevel == 1 goto chyba
del k.com
ren k.exe k.com
tdmap k.map
del k.map
goto konec

:chyba
del *.obj
rem pause
goto start

:konec
del *.obj

fc /b k.com k_.com > aaa
type aaa
rem goto start
