if "%1"=="0" goto nula
if not exist gem_%10.pov goto konec
for %%N IN (0 1 2 3 4 5 6 7 8 9) DO call $rend.bat %1%%N
goto konec

:nula
for %%N IN (0 1 2 3 4 5 6 7 8 9) DO call $rend.bat %%N
:konec