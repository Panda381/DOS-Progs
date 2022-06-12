@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo GALACTIC INVADER  -  odst©elov n¡ pt k–
echo ----------------
echo.
echo Po startu se stiskne kl vesa MEZERA
echo a zad  se obt¡‘nost 1 a‘ 3 (nap©. 1).
echo.
echo —kolem je st©¡let kosmick‚ pt ky.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           SHIFT - st©¡len¡
echo.
echo Po skon‡en¡ hry zadat Y = znovu.
echo.
..\sharpexe galinv.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
