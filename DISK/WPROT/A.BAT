@echo off
:start
kontext wprot.asm
tasm wprot.asm wprot.obj /z/zi/m5/t
if errorlevel == 1 goto chyba
tasm wprot.asm wprotx.obj /z/zi/m5/t/dPARX
if errorlevel == 1 goto chyba
tlink20 wprot.obj, wprot.com, wprot.map /t/l/s
if errorlevel == 1 goto chyba
tlink20 wprotx.obj, wprotx.com, wprotx.map /t/l/s
if errorlevel == 1 goto chyba
tdmap wprot.map wprot.tds -q
tdmap wprotx.map wprotx.tds -q
goto konec
:chyba
pause
goto start
:konec
del wprot.map
del wprot.obj
del wprotx.map
del wprotx.obj

