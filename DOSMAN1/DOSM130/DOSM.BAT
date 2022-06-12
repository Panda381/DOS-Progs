@echo off
%0\..\utility\egacs k
%0\..\utility\cskey k 3
%0\..\dosman.exe /dc /fk /l
%0\..\utility\cskey !
%0\..\utility\egacs !
