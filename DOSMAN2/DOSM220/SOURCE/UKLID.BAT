if not exist obj\*.obj goto NOBJ
del obj\*.obj
rd obj
:NOBJ

if exist $DOSMAN$.HIS del $DOSMAN$.HIS
if exist $DOSMAN$.TRE del $DOSMAN$.TRE
if exist $DOSMAN$.LST del $DOSMAN$.LST
if exist DOSMAN.EXE del DOSMAN.EXE
if exist DOSMAN.HLP del DOSMAN.HLP
if exist DOSMAN.MAP del DOSMAN.MAP
if exist DOSMAN.TR del DOSMAN.TR
if exist TD.TR del TD.TR
if exist TDCONFIG.TD del TDCONFIG.TD
