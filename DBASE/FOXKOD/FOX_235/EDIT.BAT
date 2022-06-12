@echo off

if "%1"=="" goto konec

clock

makro /!
makro b 5000 t 800

kontext %1

clock

echo.

wait "Odinstalovati MAKRO ? (Esc = ne): "
if errorlevel 1 goto konec

makro /!

:konec
