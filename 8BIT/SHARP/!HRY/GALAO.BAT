@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo GALAO  -  sest©elov n¡ £to‡nick‚ letky
echo -----
echo.
echo Po startu stisknout kl vesu S.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           MEZERA - st©¡len¡
echo             (lze znovu vyst©elit a‘
echo              dolet¡ star  st©ela)
echo.
echo Po skon‡en¡ hry zadat Y - znovu.
echo.
..\sharpexe galao.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
