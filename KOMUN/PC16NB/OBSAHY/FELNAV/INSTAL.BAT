echo off
echo          Instalace programoveho vybaveni FELAN
echo          -------------------------------------
echo    Chcete-li protokol o instalaci, stisknete CTRL-P
pause
echo on
E:
cd \
MD SYS
MD FELAN
MD FELNAV 
copy a:instal2.bat e:\felan/v
copy a:instal3.bat e:\felan/v
e:\felan\instal2
