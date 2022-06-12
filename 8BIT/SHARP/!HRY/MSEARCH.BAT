@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo MOVING SEARCHER  -  chyt n¡ zna‡ek "$"
echo ---------------
echo.
echo Po startu stisknout kl vesy S a Y.
echo.
echo —kolem je chytat zna‡ky $. Chycen¡m
echo p¡smen S a L se z¡sk vaj¡ dal¨¡ body.
echo.
..\sharpexe msearch.mzf > nul
..\delay 6 > nul
..\sharpexe msearch_.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
