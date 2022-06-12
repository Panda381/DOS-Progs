echo off
echo.
echo Probiha instalace  DOS Manazeru V1.31  na pevny disk.
c:
if '%1' == '' goto ppp
%1
:ppp
copy b:*.* > nul:
copy b:cti.com dosman.exe > nul
copy b:\utility\*.* > nul:
hdinst b:dosman.exe
del insta*.bat > nul:
del odins*.bat > nul:
del hdinst.exe > nul:
del testdisk.com > nul:
