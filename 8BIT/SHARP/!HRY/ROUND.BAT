@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ROUND SHOOT  -  rozst©elov n¡ UFO
echo -----------
echo.
echo Po startu stisknout kl vesu MEZERA.
echo.
echo Ovl d n¡: kurzory (¨ipky) - smˆr
echo                   (lze i ¨ikmo)
echo           Z - st©¡len¡
echo           C - bomba
echo.
..\sharpexe round.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
