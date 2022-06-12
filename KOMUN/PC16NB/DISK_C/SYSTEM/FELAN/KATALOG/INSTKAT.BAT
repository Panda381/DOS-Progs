echo off
echo      Instalace programoveho vybaveni pro katalog uzivatelu FELAN
echo      ----------------------------------------------------------
echo            Chcete-li protokol o instalaci, stisknete CTRL-P
pause
echo on
E:
cd \FELAN

rem Kopirovani programu
copy a:*.* e:\felan/v

rem Zalozeni a inicializace katalogu
del d:\katalog.dsk
crevd d:\katalog 360 [1,1] www 0
diskb mou q:=d:\katalog r/w
katini

rem Modifikace DSINI.CMD
del d.cmd
ren dsini.cmd d.cmd
copy d.cmd+d9.cmd/a dsini.cmd/a
del d.cmd
del d9.cmd

rem Modifikace FELAN.BAT
del f.bat
ren felan.bat f.bat
copy f.bat+f9.bat/a felan.bat/a
del f.bat
del f9.bat

rem Modifikace druhotneho AUTOEXEC.BAT
del e:\a.bat
ren e:\autoexec.bat a.bat
copy e:\a.bat+e:\felan\a9.bat/a e:\autoexec.bat/a
del e:\felan\a.bat
del e:\a9.bat
echo off
echo Istalace katalogu skoncena 
