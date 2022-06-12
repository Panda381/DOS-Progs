@echo off
if "%1" == "" goto konec
if exist %1.mal goto pripona
attrib -r %1
goto konec
:pripona
attrib -r %1.mal
:konec
