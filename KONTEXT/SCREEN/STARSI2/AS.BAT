@echo off
masm VGA,VGA/z/l;
if errorleve == 1 goto start
tlink VGA.obj, VGA.ovl /t
if errorleve == 1 goto start
del VGA.obj
del VGA.map
del VGA.lst

