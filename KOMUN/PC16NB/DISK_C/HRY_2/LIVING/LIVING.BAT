@echo off
cls
echo LIVING
echo ------
echo Ovl d n¡:    "O" .......... doleva
echo              "P" .......... doprava
echo              "Q" .......... nahoru
echo              "A" .......... dol–
echo              "1" a‘ "4" ... volba zbranˆ
echo              mezera ....... pou‘it¡ zbranˆ (s¡la z vis¡
echo                             na d‚lce dr‘en¡ kl vesy)
echo              Enter ........ pauza zap/vyp
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
living\living
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
living\living

:Konec
