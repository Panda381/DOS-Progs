echo off
echo Cekejte, probiha test pocitace ......
echo. > inform.out
echo     같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� >> inform.out
echo     같같같같같같같같같같     Systemove informace     같같같같같같같같같같 >> inform.out
echo     같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같� >> inform.out
echo. >> inform.out
ver >> inform.out
echo. >> inform.out
%3utility\sysinfo /s/m/i/c/w/bc >> inform.out
echo. >> inform.out
%3utility\vmod >> inform.out
echo. >> inform.out
%3utility\setcom >> inform.out
echo. >> inform.out
echo Prostredi systemu: >> inform.out
echo -------------------------------------------------------- >> inform.out
set >> inform.out
echo. >> inform.out
echo CONFIG.SYS : >> inform.out
echo -------------------------------------------------------- >> inform.out
type \config.sys >> inform.out
echo. >> inform.out
echo AUTOEXEC.BAT : >> inform.out
echo -------------------------------------------------------- >> inform.out
type \autoexec.bat >> inform.out
echo. >> inform.out
tree \ >> inform.out
dir \ >> inform.out
