@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo MOTY GAME  -  p©em¡sŸov n¡ koul¡
echo ---------
echo.
echo Po startu stisknout MEZERU a S.
echo.
echo —kolem je p©em¡stit ‘lut‚ koule do
echo sloupce na sebe.
echo.
..\sharpexe moty.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
