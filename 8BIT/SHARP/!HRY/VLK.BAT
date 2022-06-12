@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo VLK  -  vlk chytaj¡c¡ vejce
echo ---
echo.
echo Hra se odstartuje stiskem kl vesy
echo F1 (obt¡‘nˆj¨¡) nebo F2 (sna‘¨¡).
echo.
echo Ovl d n¡:   A    ]
echo              \  /
echo              /  \
echo             Z    ?
echo.
..\sharpexe vlk.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
