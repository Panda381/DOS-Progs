@echo off
set TEMPDSZ=%DSZLOG%
set DSZLOG=%1
cexyz.exe %2 %3 %4 %5 %6 %7 %8 %9
set DSZLOG=%TEMPDSZ%
