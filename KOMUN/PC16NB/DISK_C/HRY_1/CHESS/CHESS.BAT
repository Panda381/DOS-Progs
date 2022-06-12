@echo off
cls
echo Chess
echo -----
echo Po startu zvolte nejd©¡ve barvu:
echo    "W" = b¡l‚,  "B" = ‡ern‚,
echo potom zvolte obt¡‘nost "1" a‘ "6".
echo.
echo Figurku zvednete stiskem kl vesy "Del",
echo kl vesou "Ins" ji polo‘¡te na novou pozici.
echo Program ukon‡¡te stiskem Ctrl-Break.
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

c:\system\klavesn\setlock C > NUL
c:\system\klavesn\inkey "W1" > NUL
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
chess\chess
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
chess\chess

:Konec
