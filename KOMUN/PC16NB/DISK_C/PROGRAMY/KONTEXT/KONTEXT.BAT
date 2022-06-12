@ECHO OFF
C:\SYSTEM\APPEND C:\PROGRAMY\KONTEXT\KONTEXT;
C:\SYSTEM\KLAVESN\CSKEY 3 K > NUL
IF "%2"=="" GOTO JEDEN
C:\PROGRAMY\KONTEXT\KONTEXT\KONTEXT %1 #2 %2 #3 %3 #4 %4 #5 %5 #1
GOTO KONEC

:JEDEN
IF "%1"=="" GOTO NIC
C:\PROGRAMY\KONTEXT\KONTEXT\KONTEXT %1
GOTO KONEC

:NIC
if not exist g:\kontext\nul md g:\kontext
if not exist g:\kontext\*.txt copy c:\programy\kontext\demo.txt g:\kontext\demo.txt > NUL
G:
CD\KONTEXT
C:\PROGRAMY\KONTEXT\KONTEXT\KONTEXT
cd\
c:

:KONEC
C:\SYSTEM\KLAVESN\CSKEY 1 K > NUL
C:\SYSTEM\APPEND ;
