@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ASTEROIDS  -  rozst�elov�n� meteorit�
echo ---------
echo.
echo Po startu se stiskne CR.
echo.
echo "St��len�: Q  W  E   Pohyb: <  > <-"
echo "           \ � /            \ � / "
echo "          A-   -D          -   -"
echo "           / � \            / � \ "
echo "          Z  X  C          ->   �"
echo.
echo Mezera = hyperprostor
echo.
..\sharpexe asteroid.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
