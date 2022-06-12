@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo SLAP FIGHT -  letadlo let¡c¡ mˆstem
echo ----------
echo.
echo Po startu stisknout 4.
echo.
echo Ovl d n¡: kurzory (¨ipky) - pohyb
echo           SHIFT - st©¡len¡
echo.
..\sharpexe slap.mzf > nul
..\delay 6 > nul
..\sharpexe slap_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
