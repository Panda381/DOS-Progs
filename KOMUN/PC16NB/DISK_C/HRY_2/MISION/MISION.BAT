@echo off
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
mision\mision
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
mision\mision
:Konec
