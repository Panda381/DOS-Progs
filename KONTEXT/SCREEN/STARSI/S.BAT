@echo off
:start
kontext screen.asm 
tasm screen.asm screen.obj /z/zi
if errorlevel == 1 goto chyba
tlink screen.obj, screen.exe, screen.map /l/s
if errorlevel == 1 goto chyba
del screen.ovl
exe2bin screen.exe screen.ovl
goto konec
:chyba
pause
goto start
:konec
del screen.map
del screen.obj
del screen.exe
pause
rem kontext demo.txt
rem pause
goto start
