@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo ELECTRONIC  -  elektronick‚ varhany
echo ----------
echo.
echo Kl vesnice je jako 2 ©ady kl ves
echo varhan (1. a 3. ©ada jsou p–lt¢ny).
echo.
..\sharpexe electron.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
