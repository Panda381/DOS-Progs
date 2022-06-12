@echo off
:start
kontext mac80.asm
tasm mac80,mac80/z/zi;
if errorlevel == 1 goto chyba
tlink20 mac80,mac80/l/v;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del mac80.map
del mac80.obj
