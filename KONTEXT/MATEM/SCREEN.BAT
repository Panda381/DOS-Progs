@echo off
:start
cd screen
kontext screen19.asm
tasm screen.asm screen.obj /z/zi
if errorlevel == 1 goto chyba
tlink screen.obj, screen.exe, screen.map /l/s
if errorlevel == 1 goto chyba
del screen.ovl
exe2bin screen.exe screen.ovl
goto konec
:chyba
echo chyba !
pause
goto start
:konec
del screen.map
del screen.obj
del screen.exe
rem pause
rem kontext demo.txt
rem pause
rem goto start
cd..
copy screen\screen.ovl screen.ovl
