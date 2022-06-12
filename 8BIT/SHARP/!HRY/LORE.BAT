@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo KNIGHT LORE  -  proch zen¡ hradem
echo -----------
echo.
echo Po startu stisknout nejd©¡ve kl vesu
echo 3 a potom kl vesu 0.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - ot ‡en¡
echo           NAHORU - pohyb vp©ed
echo           DOL¦ - sb¡r n¡ p©edmˆt–
echo           DEL - v˜skok vp©ed
echo.
..\sharpexe lore.mzf > nul
..\delay 6 > nul
..\sharpexe lore_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
