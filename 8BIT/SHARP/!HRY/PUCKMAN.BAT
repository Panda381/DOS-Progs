@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo PUCKMAN  -  po‘¡r n¡ bod–
echo -------
echo.
echo —kolem je sb¡rat body. Pohyb pomoc¡
echo kurzorov˜ch kl ves (¨ipky). Po skon‡en¡
echo hry se stiskne kl vesa S.
echo.
..\sharpexe puckman.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
