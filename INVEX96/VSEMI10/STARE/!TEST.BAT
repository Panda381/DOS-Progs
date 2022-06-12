@echo off
del gema_%1.tga
call $genpov.bat
call $rend.bat %1
