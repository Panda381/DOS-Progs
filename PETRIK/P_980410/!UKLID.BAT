@echo off
if exist DEBUG\*.gid attrib -H DEBUG\*.gid
if exist DEBUG\*.gid del DEBUG\*.gid
if exist DEBUG\*.exe del DEBUG\*.exe
if exist DEBUG\*.obj del DEBUG\*.obj
if exist DEBUG\*.res del DEBUG\*.res
if exist DEBUG\*.pch del DEBUG\*.pch
if exist DEBUG\*.ilk del DEBUG\*.ilk
if exist DEBUG\*.pdb del DEBUG\*.pdb
if exist DEBUG\*.idb del DEBUG\*.idb
if exist DEBUG\*.cnt del DEBUG\*.cnt
if exist DEBUG\*.hlp del DEBUG\*.hlp
if exist DEBUG\*.tlb del DEBUG\*.tlb
if exist DEBUG\*.sbr del DEBUG\*.sbr
if exist DEBUG\*.bsc del DEBUG\*.bsc
if exist DEBUG\NUL rd DEBUG

if exist DEBUGU\*.gid attrib -H DEBUGU\*.gid
if exist DEBUGU\*.gid del DEBUGU\*.gid
if exist DEBUGU\*.exe del DEBUGU\*.exe
if exist DEBUGU\*.obj del DEBUGU\*.obj
if exist DEBUGU\*.res del DEBUGU\*.res
if exist DEBUGU\*.pch del DEBUGU\*.pch
if exist DEBUGU\*.ilk del DEBUGU\*.ilk
if exist DEBUGU\*.pdb del DEBUGU\*.pdb
if exist DEBUGU\*.idb del DEBUGU\*.idb
if exist DEBUGU\*.cnt del DEBUGU\*.cnt
if exist DEBUGU\*.hlp del DEBUGU\*.hlp
if exist DEBUGU\*.tlb del DEBUGU\*.tlb
if exist DEBUGU\*.sbr del DEBUGU\*.sbr
if exist DEBUGU\*.bsc del DEBUGU\*.bsc
if exist DEBUGU\NUL rd DEBUGU

if exist RELEASE\*.gid attrib -H RELEASE\*.gid
if exist RELEASE\*.gid del RELEASE\*.gid
if exist RELEASE\*.exe del RELEASE\*.exe
if exist RELEASE\*.obj del RELEASE\*.obj
if exist RELEASE\*.res del RELEASE\*.res
if exist RELEASE\*.pch del RELEASE\*.pch
if exist RELEASE\*.ilk del RELEASE\*.ilk
if exist RELEASE\*.pdb del RELEASE\*.pdb
if exist RELEASE\*.idb del RELEASE\*.idb
if exist RELEASE\*.cnt del RELEASE\*.cnt
if exist RELEASE\*.hlp del RELEASE\*.hlp
if exist RELEASE\*.tlb del RELEASE\*.tlb
if exist RELEASE\*.sbr del RELEASE\*.sbr
if exist RELEASE\*.bsc del RELEASE\*.bsc
if exist RELEASE\NUL rd RELEASE

if exist RELEASEU\*.gid attrib -H RELEASEU\*.gid
if exist RELEASEU\*.gid del RELEASEU\*.gid
if exist RELEASEU\*.exe del RELEASEU\*.exe
if exist RELEASEU\*.obj del RELEASEU\*.obj
if exist RELEASEU\*.res del RELEASEU\*.res
if exist RELEASEU\*.pch del RELEASEU\*.pch
if exist RELEASEU\*.ilk del RELEASEU\*.ilk
if exist RELEASEU\*.pdb del RELEASEU\*.pdb
if exist RELEASEU\*.idb del RELEASEU\*.idb
if exist RELEASEU\*.cnt del RELEASEU\*.cnt
if exist RELEASEU\*.hlp del RELEASEU\*.hlp
if exist RELEASEU\*.tlb del RELEASEU\*.tlb
if exist RELEASEU\*.sbr del RELEASEU\*.sbr
if exist RELEASEU\*.bsc del RELEASEU\*.bsc
if exist RELEASEU\NUL rd RELEASEU

if exist *.mdp del *.mdp
if exist *.ncb del *.ncb
if exist *.aps del *.aps
rem if exist *.clw del *.clw
echo.>PETER.MDP
