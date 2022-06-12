@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo PLANETOIDS  -  rozst©elov n¡ planetoid–
echo ----------
echo.
echo Po nata‘en¡ programu je nutno
echo prov‚st RESET po‡¡ta‡e a zadat M
echo (monitor), zapsat G3F00 a stisknout CR.
echo Hra se odstartuje stiskem C.
echo.
echo Ovl d n¡: Z - ot ‡en¡ vlevo
echo           X - ot ‡en¡ vpravo
echo           MEZERA - st©¡len¡
echo           CR - popoj¡‘dˆn¡
echo           C - hyperprostor
echo.
..\sharpexe planet.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
