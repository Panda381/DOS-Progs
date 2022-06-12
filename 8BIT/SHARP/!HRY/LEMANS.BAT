@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo LE MANS  -  z vody F1
echo -------
echo.
echo Po startu zvolit obt¡‘nost 1 a‘ 9
echo (1 nejsna‘¨¡).
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           Q - konec
echo.
echo Po skon‡en¡ hry stisknout Y = znovu.
echo.
..\sharpexe lemans.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
