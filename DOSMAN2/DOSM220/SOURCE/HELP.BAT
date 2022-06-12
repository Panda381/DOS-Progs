@echo off
rem Pri zmene poctu nebo poradi stranek preloz DOSMAN cely znovu !!!!

:znovu
exec\egacs k > NUL
exec\cskey k > NUL
cd help
kontext help.txt
cd..
exec\cskey ! > NUL
exec\egacs ! > NUL

hlp_comp\hlp_comp.com
if not errorlevel 1 goto konec
echo.
exec\wait "Esc=preruseni, jina klavesa opakovani..."
echo.
if errorlevel 1 goto konec
goto znovu

:konec
