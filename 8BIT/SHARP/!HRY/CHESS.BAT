@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ADVANCED CHESS  -  ¨achy
echo --------------
echo.
echo Po startu stisknout C (hra).
echo Zad  se barva B (‡ern ) nebo W (b¡l )
echo a £rove¤ 1 a‘ 6 (nejleh‡¡ je 1).
echo.
echo Posun figurek se prov d¡ zad n¡m
echo sou©adnic P‹SMENO a €‹SLICE nejd©¡ve
echo sou‡asn‚ pozice a potom nov‚ c¡lov‚.
echo.
echo   X - z mˆna stran (po‡¡ta‡ provede
echo       tah nam¡sto hr ‡e)
echo   R - konec hry (nutno znovu zadat
echo       C, barvu B/W a £rove¤ 1 a‘ 6)
echo   L - zmˆna obt¡‘nosti
echo.
..\sharpexe chess.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
