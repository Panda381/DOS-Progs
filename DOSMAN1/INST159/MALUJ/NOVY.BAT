@echo off
if "%1" == "" goto konec
if exist %1.mal goto konec
copy novy.000 %1.mal > nul
if exist %1.mal goto konec
if exist %1 goto konec
copy novy.000 %1 > nul
:konec
