@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo LAND  -  proch zen¡ krajinou
echo ----
echo.
echo Po startu stisknout MEZERU.
echo.
echo —kolem je proj¡t krajinou. Mus¡ se
echo vyh˜bat p©ek ‘k m.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           MEZERA - sk k n¡
echo.
..\sharpexe land.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
