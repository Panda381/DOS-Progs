@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ATTACK  -  loƒ prol‚t  krajinou
echo ------
echo.
echo Po startu stisknout MEZERU a ‡¡slo
echo 1 a‘ 9 (rychlost, nap©. 1).
echo.
echo Ovl d n¡: ¨ipky - ovl d n¡ pohybu
echo           Z - bomba
echo           X - st©¡len¡
echo.
..\sharpexe attack.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
