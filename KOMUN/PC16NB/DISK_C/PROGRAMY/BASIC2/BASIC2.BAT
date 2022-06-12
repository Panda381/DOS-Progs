@echo off
if not exist g:\basic2\nul md g:\basic2
if not exist g:\basic2\*.bas copy c:\programy\basic2\*.bas g:\basic2\*.bas > NUL
g:
cd\basic2
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc
c:\system\displej\emucga a e b5 > NUL
c:\system\displej\vmod 3
c:\programy\basic2\qbasic
c:\system\displej\vmod 7
c:\system\displej\emucga n > NUL
goto Konec

:NHerc
c:\programy\basic2\qbasic

:Konec
c:\system\klavesn\setlock nc > NUL
cd \
c:
