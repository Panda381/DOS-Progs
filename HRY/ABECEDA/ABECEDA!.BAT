@echo off
tasm abeceda /z;
tlink abeceda.obj, a.$$$ /t;
copy /b a.$$$ + abeceda.scr abeceda.com > nul
del abeceda.obj
del a.map
del a.$$$
