@echo off
if not exist %1 goto konec
if "%5" == "DBF" goto _DBF
if "%5" == "ARC" goto _ARC
if "%5" == "ZIP" goto _ZIP
if "%5" == "602" goto _602

%3cti.com %1
goto konec

:_ARC
pkxarc -v %1 > %3view.lst
%3cti.com %3view.lst
goto konec

:_ZIP
pkunzip -v %1 > %3view.lst
%3cti.com %3view.lst
goto konec

:_602
%3qview602 %1
goto konec

:_DBF
%3dbview %1

:konec
