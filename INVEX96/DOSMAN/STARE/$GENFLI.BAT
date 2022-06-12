@echo off

rem --------------------------------------------------
rem               Konverze 2D na FLI
rem --------------------------------------------------

if exist gemadosm.fli del gemadosm.fli
exe\animfli gema gemadosm
