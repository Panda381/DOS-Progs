echo off
echo.
echo Probiha odinstalace  DOS Manazeru V1.31  z pevneho disku.
c:
if '%1' == '' goto ppp
%1
:ppp
copy b:hdinst.exe > nul:
hdinst dosman.exe b:
del hdinst.exe > nul:
