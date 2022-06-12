@echo off
:start
tasm mac80,mac80/z;
if errorlevel == 1 goto chyba
tlink20 mac80,mac80;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del mac80.map
del mac80.obj
