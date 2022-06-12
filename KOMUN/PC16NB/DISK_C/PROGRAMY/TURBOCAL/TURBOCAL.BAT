@ECHO OFF
if not exist g:\turbocal\nul md g:\turbocal
if not exist g:\turbocal\*.cal copy c:\programy\turbocal\demo.cal g:\turbocal\demo.cal > NUL
G:
CD\TURBOCAL
C:\PROGRAMY\TURBOCAL\TCALC DEMO.CAL
cd\
c:
