
@ECHO OFF
CLS
ECHO ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
ECHO บ                                                                            บ
ECHO บ                  Mouse Software Installation Program                       บ
ECHO บ                                                                            บ
ECHO ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
echo ÿ
IF "%1" == "" GOTO HELPMSG
IF "%2" == "" GOTO HELPMSG
IF NOT EXIST %1\READ.ME GOTO WRONDISK
IF EXIST %2\MOUSE\READ.ME GOTO REINSTALL
ECHO          *   Create new directory for mouse software.
%2
CD \
MD MOUSE
CD MOUSE
ECHO          *   Install mouse software into new dircetory.
COPY %1\*.* %2\MOUSE >NUL
GOTO CHECKAUTO
:REINSTALL
%2
CD \MOUSE
DEL *.COM
ECHO          *   Install mouse software into subdircetory.
COPY %1\*.* %2\MOUSE >NUL
:CHECKAUTO
IF NOT EXIST C:\AUTOEXEC.BAT GOTO CREATE
ECHO          *   Modify AUTOEXEC.BAT to activate mouse at start up time.
ECHO %2\MOUSE\MOUSE.COM >> C:\AUTOEXEC.BAT
GOTO COMPLETE
:CREATE
ECHO          *   Create AUTOEXEC.BAT to activate mouse at start up time.
ECHO %2\MOUSE\MOUSE.COM > C:\AUTOEXEC.BAT
GOTO COMPLETE
:HELPMSG
ECHO    COMMAND FORMAT :
ECHO                     INSTALL  [SOURCE DISK DRIVE]  [DESTINATION DISK DRIVE]
ECHO    EXAMPLE :
ECHO                     INSTALL  A: C:
ECHO                       will install mouse software from A: drive to C: drive.
echo ÿ
echo ÿ
GOTO ENDINST
:WRONDISK
ECHO    Wrong disk drive specification.
GOTO ENDINST
:COMPLETE
ECHO ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
echo ÿ
echo ÿ
ECHO                          Installation has been completed.
echo ÿ
ECHO                  Please read READ.ME file for new information.
echo ÿ
:ENDINST
ECHO ON
