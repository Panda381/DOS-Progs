@echo off
:start
kontext dcfa.asm #2 dcfb.asm #3 port_com.txt #4 dos_time.txt #1
tasm dcfa /z/t
if errorlevel 1 goto chyba
tasm dcfb /z/t
if errorlevel 1 goto chyba
tlink dcfa /t/x
if errorlevel 1 goto chyba
tlink dcfb /t/x
if not errorlevel 1 goto konec

:chyba
echo.
echo ***** CHYBA - navrat do editoru ****
pause
goto Start

:konec
if exist dcfa.obj del dcfa.obj
if exist dcfb.obj del dcfb.obj

