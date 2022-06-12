@echo off
cls
echo —kolem hry TAPPER je ‡epovat p–llitry z kazn¡k–m.
echo.
echo Ovl d n¡:    nahoru [8] ..... posun nahoru
echo              dol–   [2] ..... posun dol–
echo              mezera ......... ‡epov n¡ (chv¡li dr‘et)
echo              1 .............. konec programu
echo.
echo.
if "%1" == "" c:\system\klavesn\wait

cd tapper
c:\system\displej\detcard > NUL
if errorlevel 2 goto NHerc

c:\system\displej\emucga a > NUL
c:\system\displej\vmod 3
tapper
c:\system\displej\vmod 7
c:\system\displej\emucga d > NUL

:NHerc
tapper

:Konec
cd ..
