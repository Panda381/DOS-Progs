@echo off
if not exist g:\pascal\nul md g:\pascal
if not exist g:\pascal\*.pas copy c:\programy\pascal\source\bgidemo.pas g:\pascal\bgidemo.pas > NUL
g:
cd\pascal
c:\system\append c:\programy\pascal;c:\programy\pascal\include;c:\programy\pascal\source;
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a e b5 > NUL
c:\system\displej\vmod 7
c:\programy\pascal\turbo
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL
goto Konec

:NHerc
c:\programy\pascal\turbo

:Konec
c:\system\klavesn\setlock cn > NUL
c:\system\append ;
cd\
c:
