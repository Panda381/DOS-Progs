@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo FLUGSIMULATOR  -  leteck˜ simul tor
echo -------------
echo.
echo Po startu se stiskne kl vesa
echo J = p©ist n¡ nebo N = vzl‚tnut¡.
echo.
echo Ovl d n¡: kurzory (¨ipky) - ©¡zen¡
echo           INST - sn¡‘en¡ tahu motoru
echo           DEL - zv˜¨en¡ tahu motoru
echo           B - brzdy
echo           K - klapky
echo           Shift-BREAK - p©eru¨en¡ letu
echo.
..\sharpexe flugsim.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
