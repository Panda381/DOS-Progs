exe\inkey ?
if errorlevel 1 goto konec
if "%1"=="0" goto nula
if not exist gema_%100.pov goto konec
for %%M IN (0 1 2 3 4 5 6 7 8 9) DO call $rend10.bat %1%%M
goto konec

:nula
for %%M IN (0 1 2 3 4 5 6 7 8 9) DO call $rend10.bat %%M
:konec