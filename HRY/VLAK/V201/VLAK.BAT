@echo off
%0\..\detcard > nul
if errorlevel 2 goto COLOR

copy %0\..\vlak$mon.pcx %0\..\vlak$.pcx > nul
goto START

:COLOR
copy %0\..\vlak$col.pcx %0\..\vlak$.pcx > nul

:START
%0\..\vlak$.com %0\..\vlak$.exe
