@echo off
del gdemo*.scr
gdemo /i /n /c- /e- /v+
c:\dpaint\dpaint f
del *.$$$
del dp_prefs
gdemo /!
if not exist gdemo000.scr goto konec
echo.
echo Generuji obrazek panelu...
panel > panelobr.asm
del gdemo000.scr
:konec
