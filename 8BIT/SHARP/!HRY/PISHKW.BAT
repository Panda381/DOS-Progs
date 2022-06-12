@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo PR.PISHKWORKS  -  prostorov‚ pi¨kvorky
echo -------------
echo.
echo Po startu se stiskne MEZERA a kl vesa
echo F (= t hne 1.) nebo S (= t hne 2.).
echo.
echo —kolem je v krychli 4x4x4 um¡stit ©adu
echo 4 b¡l˜ch kamen– v kter‚mkoliv smˆru.
echo Pozice se zad v  jako sou©adnice X Y Z
echo a kl vesa CR.
echo.
..\sharpexe pishkw.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
