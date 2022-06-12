@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo GRAND  -  z vody F1 (star¨¡ LE MANS)
echo -----
echo.
echo Po startu zadat obt¡‘nost 1 a‘ 5
echo (1 nejsnadnˆj¨¡).
echo.
echo Ovl d n¡: Q - vlevo
echo           W - vpravo
echo.
echo Po skon‡en¡ hry zadat Y = znovu.
echo.
..\sharpexe grand.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
