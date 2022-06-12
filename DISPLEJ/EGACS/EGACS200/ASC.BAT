@echo off
egacs /k
vmod 3
echo Tento povelov˜ soubor v m umo‘n¡ prohl¡‘et a p©¡padnˆ vytisknou na
echo tisk rnˆ fonty instalovan‚ pomoc¡ programu EGACS.COM. K tomu je
echo zapot©eb¡ p©¡tomnost n sleduj¡c¡ch program–:
echo.
echo     GRAPHICS     - syst‚mov˜ program pro tisk obrazovky v grafick‚m re‘imu
echo     EGACS.COM    - instal tor n rodn¡ch font– displeje
echo     VMOD.COM     - nastaven¡ videom¢du displeje
echo     ASCII.COM    - zobrazen¡ tabulek font– displeje
echo.
echo Po zobrazen¡ font– na displeji m–‘ete obsah displeje vytisknout na
echo p©ipojen‚ tisk rnˆ stiskem kl vesy PrintScreen.
echo.
echo Pokud v m nˆkter˜ s program– chyb¡, p©eru¨te dal¨¡ ‡innost stiskem
echo kl ves Ctrl-Break.
echo.
echo.
pause
graphics graphics
vmod 16
egacs /0
echo.
echo Zobraz¡ se standardn¡ k¢d IBM
echo.
pause
ascii
egacs /k
echo.
echo Zobraz¡ se k¢d brat©¡ Kamenick˜ch
echo.
pause
ascii
egacs /l
echo.
echo Zobraz¡ se k¢d Latin 2
echo.
pause
ascii
egacs/k
