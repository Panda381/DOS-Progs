@echo off
cd box
c:\system\displej\detcard > NUL
if errorlevel 4 goto VGA
if errorlevel 3 goto EGA
if errorlevel 2 goto CGA

c:\system\displej\emucga /a > NUL
c:\system\displej\vmod 3
box CGA
c:\system\displej\vmod 7
c:\system\displej\emucga /d > NUL
goto Konec

:CGA
box CGA
goto Konec

:EGA
box EGA
goto Konec

:VGA
box VGA

:Konec
cd ..
