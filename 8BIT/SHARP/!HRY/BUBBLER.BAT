@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BUBBLER - bublina
echo -------
echo.
echo Po startu stisknout kl vesy MEZERA a 0.
echo.
echo Ovl d n¡: Z - ot ‡en¡ vlevo
echo           X - ot ‡en¡ vpravo
echo           L - posun vp©ed
echo           P - st©¡len¡
echo           O - v˜skok
echo.
..\sharpexe bubbler.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!


