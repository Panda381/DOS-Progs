@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo S  -  st©¡len¡ l‚taj¡c¡ch tal¡©–
echo -
echo.
echo Po startu ‡ekat (a‘ nebudou hvˆzdy)
echo a potom stisknout N.
echo.
echo Ovl d n¡: X - vlevo
echo           C - vpravo
echo           M - st©¡len¡
echo           1 - p©eru¨en¡ hry
echo.
echo Po skon‡en¡ hry stisknout J = znovu.
..\sharpexe s.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
