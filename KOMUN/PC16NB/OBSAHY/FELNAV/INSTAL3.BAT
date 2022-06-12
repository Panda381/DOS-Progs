pause "Chcete-li protokol o instalaci, stisknete CTRL-P"
echo on
del c:\autoexec.bat
ren c:\a1.bat autoexec.bat
path=e:\sys;e:\felan
D:
cd \
MD PRAC
MD ZACI
crevd @e:\felan\instdisk.cmd
disk mou t:=d:\boot sys
pause Uzavrete dvirka disketove jednotky !
rem bcopy a: t:
a:
sys t:
d:
copy e:\felan\felan.sys t:/v
copy e:\felan\a4.bat t:\autoexec.bat/v
copy e:\felan\c4.sys t:\config.sys/v
del e:\felan\a4.bat
del e:\felan\c4.sys
disk dmo t:

del E:\felan\instal2.bat
del E:\felan\instdisk.cmd
del E:\felan\boot.com
echo off
echo Istalace skoncena 
del E:\felan\instal3.bat