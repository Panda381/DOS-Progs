@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo SEND-1  -  sest©elov n¡ UFO
echo ------
echo.
echo Po startu stisknout MEZERU.
echo.
echo Ovl d n¡: VLEVO a VPRAVO = posun
echo           MEZERA - st©¡len¡
..\sharpexe send.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
