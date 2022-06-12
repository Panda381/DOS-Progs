@echo off
cls
echo  %1  %2 %3 %4  (0 min  0 sek)
echo.
echo.
echo REVERSI  -  ¨achovnice (reverz)
echo -------
echo.
echo Po startu stisknout 2 (za‡¡n  hr ‡)
echo nebo 3 (za‡¡n  po‡¡ta‡). Za‡¡naj¡c¡
echo m  b¡lou barvu. C¡lem hry je z¡skat
echo maximum kamen– sv‚ barvy. Pozice
echo se zad v  jako sou©adnice P‹SMENO a
echo €‹SLICE a kl vesa CR. P©ed tahem
echo po‡¡ta‡e je nutno stisknout kl vesu CR.
echo.
echo P©i polo‘en¡ kamene se p©ebarv¡ v¨echny
echo soupe©ovy kameny mezi polo‘en˜m kamenem
echo a kameny vlastn¡ barvy (ve v¨ech 8
echo smˆrech). Je povolen jen takov˜ tah,
echo kdy se p©ebarv¡ alespo¤ 1 k men na
echo vlastn¡ barvu.
echo.
..\sharpexe reversi.mzf > nul
call ..\konec.bat
..\play "ceg+c3rrrr" /!
