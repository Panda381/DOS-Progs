@ECHO OFF
IF NOT EXIST G:\VSEMI10\NUL MD G:\VSEMI10
IF NOT EXIST G:\VSEMI10\VSEMI10.CNF COPY C:\VYUKA\VSEMI10\VSEMI10.CNF G:\VSEMI10\VSEMI10.CNF > NUL
IF NOT EXIST G:\VSEMI10\PROTOKOL\NUL MD G:\VSEMI10\PROTOKOL
C:\SYSTEM\KLAVESN\CSKEY 1 K > NUL
C:\VYUKA\VSEMI10\VSEMI10_ /C G:\VSEMI10\VSEMI10.CNF /P G:\VSEMI10\PROTOKOL
