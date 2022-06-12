@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BATTLE GAME  -  2 hr ‡i s m¡‡em
echo -----------
echo.
echo Po startu stisknout 2 x kl vesu S.
echo.
echo Hr ‡ 1:   W      Hr ‡ 2: kurzorov‚
echo           ³              kl vesy
echo         A- -D            (¨ipky)
echo           ³
echo           X
echo.
..\sharpexe battle.mzf > nul
..\delay 6 > nul
..\sharpexe battle_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!


