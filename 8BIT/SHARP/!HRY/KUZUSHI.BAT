@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo KUZUSHI  - tenis
echo -------
echo.
echo Po startu stisknout kl vesu S a
echo zvolit obt¡‘nost H, M nebo L
echo (L je nejsna‘¨¡).
echo.
echo Ovl d n¡: U - nahoru
echo           0 - dol–
echo           MEZERA - odp len¡ m¡‡ku
echo.
echo Po skon‡en¡ hry stisknout 1.
echo.
..\sharpexe kuzushi.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
