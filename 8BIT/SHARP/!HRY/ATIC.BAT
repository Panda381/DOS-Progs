@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ATIC ATAC - proch zen¡ hradem
echo ---------
echo.
echo Po startu stisknout kl vesu 0.
echo.
echo Pohyb pomoc¡ kurzorov˜ch kl ves,
echo st©¡len¡ mezerou.
echo.
..\sharpexe atic.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
