@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo TAPEWORM  -  rozst©elov n¡ hada
echo --------
echo.
echo Po startu stisknout kl vesy N a CR.
echo C¡lem hry je rozst©¡let hada v lese.
echo.
echo Ovl d n¡: kurzory (¨ipky) - pohyb
echo           MEZERA - st©¡len¡
echo.
echo Po skon‡en¡ hry stisknout Y = znovu.
..\sharpexe tapeworm.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
