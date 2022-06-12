@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo DIZZY 4 - vaj¡‡ko
echo -------
echo.
echo Ovl d n¡: VLEVO a VPRAVO - chozen¡
echo           MEZERA - sk k n¡
echo           CR - zvednut¡/pou‘it¡ vˆci
echo.
..\sharpexe defender.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
