@echo off
if "%1"=="" goto end
if exist %1\*.pch goto start
if not exist %1\*.obj goto end

:start
if exist %1\*.htm del %1\*.htm
if exist %1\*.dep del %1\*.dep
if exist %1\*.exe del %1\*.exe
if exist %1\*.ilk del %1\*.ilk
if exist %1\*.obj del %1\*.obj
if exist %1\*.pdb del %1\*.pdb
if exist %1\*.manifest del %1\*.manifest
if exist %1\*.res del %1\*.res
if exist %1\*.idb del %1\*.idb
if exist %1\*.pch del %1\*.pch
rd %1

:end

