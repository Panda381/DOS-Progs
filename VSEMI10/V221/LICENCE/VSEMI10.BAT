@echo off

:Znovu
set %GET%=
get Zadejte adresar (aktualni disk) pro VSEMI10 + Enter (samotny Enter=konec): 
if "%GET%"=="" goto Konec

cd %GET%

:Start
VSEMI10.EXE /C VSEMI10.CNF /T TESTY /P PROTOKOL
goto Znovu

:Konec
