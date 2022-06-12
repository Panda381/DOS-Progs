@echo off

call $genpov.bat
call $gentga.bat

exe\inkey ?
if not errorlevel 1 goto dale
echo Preruseni klavesou 
pause
goto konec

:dale
call $uklid.bat
call $gen2d.bat
call $genfli.bat

echo 
exe\aaplay gemavsem.fli
:konec
