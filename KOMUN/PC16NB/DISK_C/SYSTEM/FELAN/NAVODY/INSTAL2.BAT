REM kopirovani navodu a vyroba jejich ruznych verzi
COPY A:\NAVODY\*.* \FELNAV/v
E:
CD \FELNAV
NAVODY
CD \


REM autoexec,config,felan.sys a swu pro centralni pocitac
COPY A:A1.BAT C:\ /v
COPY A:A3.BAT C:\AUTOEXEC.BAT /v
COPY A:C1.SYS C:\CONFIG.SYS /v
COPY A:INSTDISK.CMD E:\FELAN /v

REM Druhotny autoexec, command.com pro zavedeni systemu do site
COPY A:A2.BAT E:\AUTOEXEC.BAT /v
COPY C:\COMMAND.COM E:\ /v

REM autoexec.bat a config.sys pro bootovaci disketu (zatim \FELAN)
COPY A:a4.bat e:\felan /v
copy a:c4.sys e:\felan /v

REM Startovaci davka site
COPY A:FELAN.BAT E:\FELAN /v

REM Nastaveni vlastnosti diskoveho a tiskoveho serveru
COPY A:D1.CMD    E:\FELAN\DSINI.CMD /v
COPY A:T1.CMD    E:\FELAN\PSINI.CMD /v

REM Odpojeni vzd. disku A:, pripojeni disketove jednotky
COPY A:D2.CMD    E:\FELAN\DISK.CMD /v

pause Zalozte distribucni disketu s programy FELAN
COPY A:*.* e:\FELAN /v
COPY E:\FELAN\FELAN.SYS C:\ /v
COPY E:\FELAN\SWU.EXE C:\ /v

pause Zalozte disketu s operacnim systemem 
COPY A:*.* e:\SYS /v

rem Pouzivate-li operacni system na vice disketach, dokopirujte
rem zbyvajici cast po ukonceni instalace na disk E:\SYS

pause Otevrete dvirka diskety, disketu s operacnim systemem nechte zalozenu !
e:\felan\BOOT
 