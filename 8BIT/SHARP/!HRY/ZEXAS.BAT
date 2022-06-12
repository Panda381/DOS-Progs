@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ZEXAS  -  prostorov‚ st©¡len¡ lod¡
echo -----
echo.
echo Po startu zvolit rychlost 1 a‘ 5
echo (nap©. 1 = nejpomalej¨¡).
echo.
echo Ovl d n¡: kurzorov‚ kl vesy - pohyb
echo           mezera - st©¡len¡
echo.
..\sharpexe zexas.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
