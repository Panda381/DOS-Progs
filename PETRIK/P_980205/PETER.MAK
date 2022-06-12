# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

!IF "$(CFG)" == ""
CFG=Peter - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to Peter - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Peter - Win32 Release" && "$(CFG)" != "Peter - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "Peter.mak" CFG="Peter - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Peter - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Peter - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "Peter - Win32 Debug"
F90=fl32.exe
CPP=cl.exe
RSC=rc.exe
MTL=mktyplib.exe

!IF  "$(CFG)" == "Peter - Win32 Release"

# PROP BASE Use_MFC 5
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 5
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\Peter.exe" "$(OUTDIR)\Peter.hlp"

CLEAN : 
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Peter.hlp"
	-@erase "$(INTDIR)\Peter.obj"
	-@erase "$(INTDIR)\Peter.pch"
	-@erase "$(INTDIR)\Peter.res"
	-@erase "$(INTDIR)\PetrDoc.obj"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(OUTDIR)\Peter.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE F90 /Ox /I "Release/" /c /nologo
# ADD F90 /Ox /I "Release/" /c /nologo
F90_PROJ=/Ox /I "Release/" /c /nologo /Fo"Release/" 
F90_OBJS=.\Release/
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
CPP_PROJ=/nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "_MBCS" /Fp"$(INTDIR)/Peter.pch" /Yu"stdafx.h" /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE RSC /l 0x405 /d "NDEBUG"
# ADD RSC /l 0x405 /d "NDEBUG"
RSC_PROJ=/l 0x405 /fo"$(INTDIR)/Peter.res" /d "NDEBUG" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /machine:I386
# ADD LINK32 /nologo /subsystem:windows /machine:I386
LINK32_FLAGS=/nologo /subsystem:windows /incremental:no\
 /pdb:"$(OUTDIR)/Peter.pdb" /machine:I386 /out:"$(OUTDIR)/Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Peter.obj" \
	"$(INTDIR)\Peter.res" \
	"$(INTDIR)\PetrDoc.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\StdAfx.obj"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"

# PROP BASE Use_MFC 5
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 5
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\Peter.exe" "$(OUTDIR)\Peter.hlp"

CLEAN : 
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Peter.hlp"
	-@erase "$(INTDIR)\Peter.obj"
	-@erase "$(INTDIR)\Peter.pch"
	-@erase "$(INTDIR)\Peter.res"
	-@erase "$(INTDIR)\PetrDoc.obj"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\Peter.exe"
	-@erase "$(OUTDIR)\Peter.ilk"
	-@erase "$(OUTDIR)\Peter.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE F90 /Zi /I "Debug/" /c /nologo
# ADD F90 /Zi /I "Debug/" /c /nologo
F90_PROJ=/Zi /I "Debug/" /c /nologo /Fo"Debug/" /Fd"Debug/Peter.pdb" 
F90_OBJS=.\Debug/
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /D "_MBCS" /Fp"$(INTDIR)/Peter.pch" /Yu"stdafx.h" /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\.
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE RSC /l 0x405 /d "_DEBUG"
# ADD RSC /l 0x405 /d "_DEBUG"
RSC_PROJ=/l 0x405 /fo"$(INTDIR)/Peter.res" /d "_DEBUG" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386
# ADD LINK32 /nologo /subsystem:windows /debug /machine:I386
LINK32_FLAGS=/nologo /subsystem:windows /incremental:yes\
 /pdb:"$(OUTDIR)/Peter.pdb" /debug /machine:I386 /out:"$(OUTDIR)/Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Peter.obj" \
	"$(INTDIR)\Peter.res" \
	"$(INTDIR)\PetrDoc.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\StdAfx.obj"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.for{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f90{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Target

# Name "Peter - Win32 Release"
# Name "Peter - Win32 Debug"

!IF  "$(CFG)" == "Peter - Win32 Release"

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\Peter.cpp
DEP_CPP_PETER=\
	".\Exec.h"\
	".\MainFrm.h"\
	".\Peter.h"\
	".\PetrDoc.h"\
	".\Prog.h"\
	".\Select.h"\
	".\StdAfx.h"\
	

"$(INTDIR)\Peter.obj" : $(SOURCE) $(DEP_CPP_PETER) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\StdAfx.cpp
DEP_CPP_STDAF=\
	".\StdAfx.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"

# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS"\
 /Fp"$(INTDIR)/Peter.pch" /Yc"stdafx.h" /Fo"$(INTDIR)/" /c $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\Peter.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"

# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /D "_MBCS" /Fp"$(INTDIR)/Peter.pch" /Yc"stdafx.h" /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\Peter.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\MainFrm.cpp
DEP_CPP_MAINF=\
	".\Exec.h"\
	".\MainFrm.h"\
	".\Peter.h"\
	".\Prog.h"\
	".\Select.h"\
	".\StdAfx.h"\
	

"$(INTDIR)\MainFrm.obj" : $(SOURCE) $(DEP_CPP_MAINF) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\PetrDoc.cpp
DEP_CPP_PETRD=\
	".\Peter.h"\
	".\PetrDoc.h"\
	".\StdAfx.h"\
	

"$(INTDIR)\PetrDoc.obj" : $(SOURCE) $(DEP_CPP_PETRD) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\Peter.rc
DEP_RSC_PETER_=\
	".\res\case.ico"\
	".\res\case_def.ico"\
	".\res\case_equ.ico"\
	".\res\case_on.ico"\
	".\res\case_sum.ico"\
	".\res\edit.bmp"\
	".\res\exec.bmp"\
	".\res\ico00001.ico"\
	".\res\ico00002.ico"\
	".\res\icon1.ico"\
	".\res\if_cond.ico"\
	".\res\if_no.ico"\
	".\res\if_yes.ico"\
	".\res\mainfram.bmp"\
	".\res\object.bmp"\
	".\res\Peter.ico"\
	".\res\Peter.rc2"\
	".\res\PetrDoc.ico"\
	".\res\struc.bmp"\
	".\res\Toolbar.bmp"\
	".\res\while_bo.ico"\
	".\res\while_br.ico"\
	".\res\while_co.ico"\
	

"$(INTDIR)\Peter.res" : $(SOURCE) $(DEP_RSC_PETER_) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\hlp\Peter.hpj

!IF  "$(CFG)" == "Peter - Win32 Release"

# Begin Custom Build - Making help file...
OutDir=.\Release
ProjDir=.
TargetName=Peter
InputPath=.\hlp\Peter.hpj

"$(OutDir)\$(TargetName).hlp" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   "$(ProjDir)\makehelp.bat"

# End Custom Build

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"

# Begin Custom Build - Making help file...
OutDir=.\Debug
ProjDir=.
TargetName=Peter
InputPath=.\hlp\Peter.hpj

"$(OutDir)\$(TargetName).hlp" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   "$(ProjDir)\makehelp.bat"

# End Custom Build

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\Select.cpp
DEP_CPP_SELEC=\
	".\MainFrm.h"\
	".\Peter.h"\
	".\Select.h"\
	".\StdAfx.h"\
	

"$(INTDIR)\Select.obj" : $(SOURCE) $(DEP_CPP_SELEC) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\Exec.cpp
DEP_CPP_EXEC_=\
	".\Exec.h"\
	".\Peter.h"\
	".\StdAfx.h"\
	

"$(INTDIR)\Exec.obj" : $(SOURCE) $(DEP_CPP_EXEC_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\Prog.cpp
DEP_CPP_PROG_=\
	".\Peter.h"\
	".\Prog.h"\
	".\StdAfx.h"\
	

"$(INTDIR)\Prog.obj" : $(SOURCE) $(DEP_CPP_PROG_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


# End Source File
# End Target
# End Project
################################################################################
