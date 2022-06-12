@echo off
cls
echo C¡lem hry je p©em¡stit bedny na ozna‡en‚ pozice.
echo.
echo Po startu zvolte:     C:   IBM - CGA mode
echo          a potom:     K    KEYBOARD
echo.
echo Ovl d n¡ v˜tahu:
echo                   2 ‡¡slice ..... volba patra (=sc‚ny)
echo                   A ............. potvrzen¡ volby
echo                   C ............. vymaz n¡ volby
echo                   L ............. opu¨tˆn¡ v˜tahu
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

cd sokoban
c:\system\subst a: c:\hry_3\sokoban\sokoban
c:\system\subst b: c:\hry_3\sokoban\sokoban
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
sokoban
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
sokoban

:Konec
c:
c:\system\subst b: /d
c:\system\subst a: /d
cd ..
