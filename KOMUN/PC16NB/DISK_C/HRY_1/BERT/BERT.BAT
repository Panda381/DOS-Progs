@echo off
cls
echo Bert
echo ----
echo —kolem hry je p©esk kat p©es v¨echna pol¡‡ka pyramidy.
echo P©itom je nutno se vyh˜bat lovc–m - jablko a had.
echo.
echo Ovl d n¡:     [7] ....... vlevo nahoru
echo               [4] ....... vlevo dol–
echo               [8] ....... vpravo nahoru
echo               [5] ....... vpravo dol–
echo               mezera .... start hry
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

if not exist g:\bert\nul md g:\bert
g:
cd\bert
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
c:bert\bert
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
c:bert\bert

:Konec
cd\
c:
