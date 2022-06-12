@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo MAD SLALOM 800  -  slalom na ly‘¡ch
echo --------------
echo.
echo Po startu stisknout MEZERU.
echo.
echo ž¡d¡ se kl vesami VLEVO a VPRAVO.
echo.
..\sharpexe slalom.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!


