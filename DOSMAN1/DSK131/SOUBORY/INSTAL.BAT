echo off
echo.
echo Probiha instalace  DOS Manazeru V1.31  na pevny disk.
c:
if '%1' == '' goto ppp
%1
:ppp
copy a:*.* > nul:
copy a:cti.com dosman.exe > nul
copy a:\utility\*.* > nul:
hdinst a:dosman.exe
del insta*.bat > nul:
del odins*.bat > nul:
del hdinst.exe > nul:
del testdisk.com > nul:
