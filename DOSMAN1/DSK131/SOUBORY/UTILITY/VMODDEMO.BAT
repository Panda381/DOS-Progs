echo off
%3vmod >nul:
if errorlevel == 8 goto neni_MDA
if not errorlevel == 7 goto neni_MDA
echo Je nainstalovana graficka karta Hercules,MDA.
goto konec
:neni_MDA
echo Je nainstalovana graficka karta EGA/VGA/CGA.
%3vmod
echo.
%3wait
%3vmod 1
echo Nyni je textovy mod 40x25.
echo.
%3wait
%3vmod 3
echo A nyni je textovy mod 80x25.
:konec
echo.
%3wait
%3vmod ?
