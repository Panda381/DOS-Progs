@echo off
REM =================================
REM     Obsah aktivniho adresare
REM =================================

call %DMIP%\delexist.bat %DMIP%\adr.lst
dir *.* /A /OGN > %DMIP%\adr.lst
if exist %DMIP%\adr.lst goto ADROK
dir *.* > %DMIP%\adr.lst
:ADROK
