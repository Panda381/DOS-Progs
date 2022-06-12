@echo off
if not exist g:\historik\nul md g:\historik
g:
cd\historik
c:\system\displej\detcard > NUL
if errorlevel 4 goto VGA
if errorlevel 3 goto EGA
if errorlevel 2 goto CGA

copy c:grawaga.hgc g:\historik\grawaga.cfg > NUL
goto Start

:CGA
copy c:grawaga.cga g:\historik\grawaga.cfg > NUL
goto Start

:EGA
copy c:grawaga.ega g:\historik\grawaga.cfg > NUL
goto Start

:VGA
copy c:grawaga.vga g:\historik\grawaga.cfg > NUL

:Start
c:\system\append c:\hry_2\historik\historik;
c:historik\historik
c:\system\append ;
cd\
c:
