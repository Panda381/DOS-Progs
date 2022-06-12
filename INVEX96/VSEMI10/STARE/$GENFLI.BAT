@echo off

rem --------------------------------------------------
rem               Konverze 2D na FLI
rem --------------------------------------------------

if exist gemavsem.fli del gemavsem.fli
exe\animfli gema gemavsem
