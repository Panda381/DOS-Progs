
@ECHO OFF
CLS
ECHO 浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
ECHO �                                                                            �
ECHO �                  Mouse Software Installation Program                       �
ECHO �                                                                            �
ECHO 藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
echo �
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
echo �
echo �
GOTO ENDINST
:WRONDISK
ECHO    Wrong disk drive specification.
GOTO ENDINST
:COMPLETE
ECHO 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
echo �
echo �
ECHO                          Installation has been completed.
echo �
ECHO                  Please read READ.ME file for new information.
echo �
:ENDINST
ECHO ON
