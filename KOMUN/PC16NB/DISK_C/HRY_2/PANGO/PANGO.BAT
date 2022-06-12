@echo off
cls
echo PANGO
echo -----
echo Ovl d n¡:     "O" ...... nahoru
echo               "L" ...... dol–
echo               "K" ...... vlevo
echo               ";" ...... vpravo
echo              mezera .... kopnut¡
echo               "Q" ...... volba zvuku (hudba-zvuk-ticho)
echo       ostatn¡ kl ves ... zastaven¡ pohybu
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

if not exist g:\pango\nul md g:\pango
g:
cd\pango

c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
c:\system\klavesn\inkey "NN"
c:pango\pango
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
c:pango\pango

:Konec
cd\
c:
