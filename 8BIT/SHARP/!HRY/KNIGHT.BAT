@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo KNIGHT'S CASTLE  -  proch zen¡ hradem
echo ---------------
echo.
echo —kolem je proj¡t kr lovsk˜m hradem.
echo.
echo Ovl d n¡: VPRAVO - vp©ed o krok
echo           NAHORU - skok vp©ed
echo.
..\sharpexe knight.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
