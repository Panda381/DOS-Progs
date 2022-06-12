@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo BACKGAMMON  -  p©esouv n¡ kuli‡ek
echo ----------
echo.
echo Po startu se stiskne CR a £rove¤ 1
echo a‘ 9 (nap©. 1).
echo.
echo Kuli‡ky se p©esouvaj¡ z pole A do X.
echo Domovsk˜mi pol¡‡ky jsou pole S a‘ X.
echo K proveden¡ tahu se stiskne p¡smeno,
echo z kter‚ho m  b˜t tah proveden a pak
echo p¡smeno, kam m  b˜t kuli‡ka p©esunuta.
echo Kl vesou MEZERA lze kuli‡ku p©esm¡stit
echo ven do z sobn¡ku nebo zpˆt. Tah ze
echo ukon‡¡ stiskem CR. S zku lze zdvojit
echo stiskem *.
echo.
..\sharpexe backgamm.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
