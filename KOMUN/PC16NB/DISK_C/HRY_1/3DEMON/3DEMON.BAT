@echo off
if not exist g:\3demon\nul md g:\3demon
g:
cd\3demon
cls
echo 3-D bludi¨tˆ
echo ------------
echo Po startu hry zvolte kl vesou "1" a‘ "9" obt¡‘nost.
echo —kolem je sb¡rat zna‡ky na cestˆ a p©itom se vyhnout
echo lovc–m. Sebr n¡m k©¡‘ov‚ zna‡ky p©estanou b˜t lovci
echo na chv¡li nebezpe‡n¡ a lze je "se‘rat". 
echo.
echo Ovl d n¡:    ¨ipka nahoru [8] ...... krok vp©ed
echo              ¨ipka vlevo  [4] ...... oto‡en¡ vlevo
echo              ¨ipka vpravo [6] ...... oto‡en¡ vpravo
echo              ¨ipka dol–   [2] ...... nulov n¡ ‡¡ta‡e
echo                           [5] ...... oto‡en¡
echo              Scroll Lock ........... pauza zap/vyp
echo              Num Lock .............. zvuk zap/vyp
echo              ESC ................... konec hry
echo              [+] £plnˆ vpravo ...... zobrazen¡ mapy
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\klavesn\inkey "B"
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc
c:\system\displej\emucga /a /b0 > NUL
c:\system\displej\vmod 3
c:3-demon
c:\system\displej\vmod 7
c:\system\displej\emucga /b5 > NUL
c:\system\displej\emucga /d > NUL
goto Konec

:NHerc
c:3-demon

:Konec
cd\
c:
