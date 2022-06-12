@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo MZ-700 INVADERS  -  sest©elov n¡ pt k–
echo ---------------
echo.
echo —kolem je post©¡let kosmick‚ pt ky.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           MEZERA - st©¡len¡
echo.
echo Po skon‡en¡ hry zadat Y = znovu.
echo.
..\sharpexe invaders.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
