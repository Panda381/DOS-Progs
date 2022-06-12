@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ZAVOD F-1  -  z vody formule F1
echo ---------
echo.
echo Po startu stisknout kl vesu S.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - ©¡zen¡
echo           X - zrychlen¡
echo           Z - zastaven¡
echo.
..\sharpexe zavodf1.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
