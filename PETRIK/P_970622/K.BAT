@echo off
:Start
dosman petr.prg
petr
if not errorlevel 1 goto Start
pause
goto Start
