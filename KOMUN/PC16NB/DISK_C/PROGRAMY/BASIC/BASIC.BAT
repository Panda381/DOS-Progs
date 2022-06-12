@echo off
if not exist g:\basic\nul md g:\basic
if not exist g:\basic\demo.bas copy c:\programy\basic\demo.bas g:\basic\demo.bas > NUL
g:
cd \basic
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc
c:\system\displej\emucga a e > NUL
c:\system\displej\vmod 3 > NUL
c:\programy\basic\gwbasic c:\programy\basic\init.bas
c:\system\displej\vmod 7 > NUL
c:\system\displej\emucga n > NUL
goto Konec

:NHerc
c:\programy\basic\gwbasic c:\programy\basic\init.bas

:Konec
cd\
c:
