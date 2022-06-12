@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo OLLI & LISSA  -  duchov‚ na hradˆ
echo ------------
echo.
echo Po startu stisknout kl vesu S.
echo.
echo Ovl d n¡: VLEVO a VPRAVO - pohyb
echo           SHIFT - skok
..\sharpexe olli.mzf > nul
..\delay 6 > nul
..\sharpexe olli_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
