@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo MAN-HUNT  -  sb¡r n¡ bod–
echo --------
echo.
echo Po startu stisknout kl vesu MEZERA.
echo.
echo —kolem je posb¡rat co nejv¡ce bod–
echo (p©ejet p©es hnˆd  pol¡‡ka). Je nutno
echo se vyh˜bat zelen˜m lovc–m. Ovl d n¡
echo pohybu kurzorov˜mi kl vesami (¨ipky).
echo.
..\sharpexe manhunt.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
