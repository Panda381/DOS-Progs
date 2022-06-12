@echo off
if "%1" == ".." goto K
if "%3" == "" goto K
%3utility\filt %1 filt_.$$$ /%2
del %1 > nul:
ren filt_.$$$ %1
:K
