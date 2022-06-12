@echo off
echo.
echo ==== Compile %1 ====
echo.
masm %1,%1/z/l;
if errorleve == 1 goto start
tlink %1.obj, %1.ovl /t
if errorleve == 1 goto start
del %1.obj
del %1.map
del %1.lst

