@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo DEFENDER  -  raketa let¡ nad horami
echo --------
echo.
echo Po startu stisknout kl vesu N a
echo potom kl vesu MEZERA.
echo.
echo Ovl d n¡: U - nahoru
echo           M - dol–
echo           J - st©¡len¡
echo.
echo Po skon‡en¡ hry stisknout Y (znovu).
..\sharpexe defender.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
