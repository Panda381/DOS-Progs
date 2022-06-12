# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

!IF "$(CFG)" == ""
CFG=Peter - Win32 Debug Unicode
!MESSAGE No configuration specified.  Defaulting to Peter - Win32 Debug\
 Unicode.
!ENDIF 

!IF "$(CFG)" != "Peter - Win32 Release" && "$(CFG)" != "Peter - Win32 Debug" &&\
 "$(CFG)" != "Peter - Win32 Debug Unicode" && "$(CFG)" !=\
 "Peter - Win32 Release Unicode"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "Peter.mak" CFG="Peter - Win32 Debug Unicode"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Peter - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Peter - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "Peter - Win32 Debug Unicode" (based on "Win32 (x86) Application")
!MESSAGE "Peter - Win32 Release Unicode" (based on "Win32 (x86) Application")
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
CPP=cl.exe
MTL=mktyplib.exe
F90=fl32.exe
RSC=rc.exe

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
	-@erase "$(INTDIR)\IconBuf.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Peter.hlp"
	-@erase "$(INTDIR)\Peter.obj"
	-@erase "$(INTDIR)\Peter.pch"
	-@erase "$(INTDIR)\Peter.res"
	-@erase "$(INTDIR)\Petrdoc.obj"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\ProgBuf.obj"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\TextBuf.obj"
	-@erase "$(OUTDIR)\Peter.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE F90 /Ox /I "Release/" /c /nologo
# ADD F90 /Ox /I "Release/" /c /nologo
F90_PROJ=/Ox /I "Release/" /c /nologo /Fo"Release/" 
F90_OBJS=.\Release/
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /Zp4 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
CPP_PROJ=/nologo /Zp4 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
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
	"$(INTDIR)\IconBuf.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Peter.obj" \
	"$(INTDIR)\Peter.res" \
	"$(INTDIR)\Petrdoc.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\ProgBuf.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\TextBuf.obj"

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

ALL : "$(OUTDIR)\Peter.exe" "$(OUTDIR)\Peter.bsc" "$(OUTDIR)\Peter.hlp"

CLEAN : 
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\Exec.sbr"
	-@erase "$(INTDIR)\IconBuf.obj"
	-@erase "$(INTDIR)\IconBuf.sbr"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\MainFrm.sbr"
	-@erase "$(INTDIR)\Peter.hlp"
	-@erase "$(INTDIR)\Peter.obj"
	-@erase "$(INTDIR)\Peter.pch"
	-@erase "$(INTDIR)\Peter.res"
	-@erase "$(INTDIR)\Peter.sbr"
	-@erase "$(INTDIR)\Petrdoc.obj"
	-@erase "$(INTDIR)\Petrdoc.sbr"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\Prog.sbr"
	-@erase "$(INTDIR)\ProgBuf.obj"
	-@erase "$(INTDIR)\ProgBuf.sbr"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\Select.sbr"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\StdAfx.sbr"
	-@erase "$(INTDIR)\TextBuf.obj"
	-@erase "$(INTDIR)\TextBuf.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\Peter.bsc"
	-@erase "$(OUTDIR)\Peter.exe"
	-@erase "$(OUTDIR)\Peter.ilk"
	-@erase "$(OUTDIR)\Peter.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE F90 /Zi /I "Debug/" /c /nologo
# ADD F90 /FR /Zi /I "Debug/" /c /nologo
F90_PROJ=/FR"Debug/" /Zi /I "Debug/" /c /nologo /Fo"Debug/"\
 /Fd"Debug/Peter.pdb" 
F90_OBJS=.\Debug/
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /Zp4 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /FR /Yu"stdafx.h" /c
CPP_PROJ=/nologo /Zp4 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_WINDOWS" /D "_MBCS" /FR"$(INTDIR)/" /Fp"$(INTDIR)/Peter.pch" /Yu"stdafx.h"\
 /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
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
	"$(INTDIR)\Exec.sbr" \
	"$(INTDIR)\IconBuf.sbr" \
	"$(INTDIR)\MainFrm.sbr" \
	"$(INTDIR)\Peter.sbr" \
	"$(INTDIR)\Petrdoc.sbr" \
	"$(INTDIR)\Prog.sbr" \
	"$(INTDIR)\ProgBuf.sbr" \
	"$(INTDIR)\Select.sbr" \
	"$(INTDIR)\StdAfx.sbr" \
	"$(INTDIR)\TextBuf.sbr"

"$(OUTDIR)\Peter.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386
# ADD LINK32 /nologo /subsystem:windows /debug /machine:I386
LINK32_FLAGS=/nologo /subsystem:windows /incremental:yes\
 /pdb:"$(OUTDIR)/Peter.pdb" /debug /machine:I386 /out:"$(OUTDIR)/Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\IconBuf.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Peter.obj" \
	"$(INTDIR)\Peter.res" \
	"$(INTDIR)\Petrdoc.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\ProgBuf.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\TextBuf.obj"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"

# PROP BASE Use_MFC 5
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Peter___"
# PROP BASE Intermediate_Dir "Peter___"
# PROP BASE Target_Dir ""
# PROP Use_MFC 5
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "DebugU"
# PROP Intermediate_Dir "DebugU"
# PROP Target_Dir ""
OUTDIR=.\DebugU
INTDIR=.\DebugU

ALL : "$(OUTDIR)\Peter.exe" "$(OUTDIR)\Peter.hlp"

CLEAN : 
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\IconBuf.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Peter.hlp"
	-@erase "$(INTDIR)\Peter.obj"
	-@erase "$(INTDIR)\Peter.pch"
	-@erase "$(INTDIR)\Peter.res"
	-@erase "$(INTDIR)\Petrdoc.obj"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\ProgBuf.obj"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\TextBuf.obj"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\Peter.exe"
	-@erase "$(OUTDIR)\Peter.ilk"
	-@erase "$(OUTDIR)\Peter.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE F90 /Zi /I "Peter___/" /c /nologo
# ADD F90 /Zi /I "DebugU/" /c /nologo
F90_PROJ=/Zi /I "DebugU/" /c /nologo /Fo"DebugU/" /Fd"DebugU/Peter.pdb" 
F90_OBJS=.\DebugU/
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /Zp4 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_UNICODE" /Yu"stdafx.h" /c
CPP_PROJ=/nologo /Zp4 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_WINDOWS" /D "_MBCS" /D "_UNICODE" /Fp"$(INTDIR)/Peter.pch" /Yu"stdafx.h"\
 /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\DebugU/
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
# ADD LINK32 /nologo /entry:"wWinMainCRTStartup" /subsystem:windows /debug /machine:I386
LINK32_FLAGS=/nologo /entry:"wWinMainCRTStartup" /subsystem:windows\
 /incremental:yes /pdb:"$(OUTDIR)/Peter.pdb" /debug /machine:I386\
 /out:"$(OUTDIR)/Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\IconBuf.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Peter.obj" \
	"$(INTDIR)\Peter.res" \
	"$(INTDIR)\Petrdoc.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\ProgBuf.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\TextBuf.obj"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"

# PROP BASE Use_MFC 5
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Peter__0"
# PROP BASE Intermediate_Dir "Peter__0"
# PROP BASE Target_Dir ""
# PROP Use_MFC 5
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "ReleaseU"
# PROP Intermediate_Dir "ReleaseU"
# PROP Target_Dir ""
OUTDIR=.\ReleaseU
INTDIR=.\ReleaseU

ALL : "$(OUTDIR)\Peter.exe" "$(OUTDIR)\Peter.hlp"

CLEAN : 
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\IconBuf.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Peter.hlp"
	-@erase "$(INTDIR)\Peter.obj"
	-@erase "$(INTDIR)\Peter.pch"
	-@erase "$(INTDIR)\Peter.res"
	-@erase "$(INTDIR)\Petrdoc.obj"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\ProgBuf.obj"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\TextBuf.obj"
	-@erase "$(OUTDIR)\Peter.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE F90 /Ox /I "Peter__0/" /c /nologo
# ADD F90 /Ox /I "ReleaseU/" /c /nologo
F90_PROJ=/Ox /I "ReleaseU/" /c /nologo /Fo"ReleaseU/" 
F90_OBJS=.\ReleaseU/
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /Zp4 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_UNICODE" /Yu"stdafx.h" /c
CPP_PROJ=/nologo /Zp4 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "_MBCS" /D "_UNICODE" /Fp"$(INTDIR)/Peter.pch" /Yu"stdafx.h" /Fo"$(INTDIR)/" /c\
 
CPP_OBJS=.\ReleaseU/
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
# ADD LINK32 /nologo /entry:"wWinMainCRTStartup" /subsystem:windows /machine:I386
LINK32_FLAGS=/nologo /entry:"wWinMainCRTStartup" /subsystem:windows\
 /incremental:no /pdb:"$(OUTDIR)/Peter.pdb" /machine:I386\
 /out:"$(OUTDIR)/Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\IconBuf.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Peter.obj" \
	"$(INTDIR)\Peter.res" \
	"$(INTDIR)\Petrdoc.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\ProgBuf.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\TextBuf.obj"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

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

.for{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f90{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

################################################################################
# Begin Target

# Name "Peter - Win32 Release"
# Name "Peter - Win32 Debug"
# Name "Peter - Win32 Debug Unicode"
# Name "Peter - Win32 Release Unicode"

!IF  "$(CFG)" == "Peter - Win32 Release"

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"

!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\Peter.cpp
DEP_CPP_PETER=\
	".\Exec.h"\
	".\IconBuf.h"\
	".\Mainfrm.h"\
	".\Peter.h"\
	".\PetrDoc.h"\
	".\Prog.h"\
	".\ProgBuf.h"\
	".\Select.h"\
	".\Stdafx.h"\
	".\TextBuf.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\Peter.obj" : $(SOURCE) $(DEP_CPP_PETER) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\Peter.obj" : $(SOURCE) $(DEP_CPP_PETER) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\Peter.sbr" : $(SOURCE) $(DEP_CPP_PETER) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\Peter.obj" : $(SOURCE) $(DEP_CPP_PETER) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\Peter.obj" : $(SOURCE) $(DEP_CPP_PETER) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\StdAfx.cpp
DEP_CPP_STDAF=\
	".\Stdafx.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"

# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /Zp4 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "_MBCS" /Fp"$(INTDIR)/Peter.pch" /Yc"stdafx.h" /Fo"$(INTDIR)/" /c $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\Peter.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"

# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /Zp4 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_WINDOWS" /D "_MBCS" /FR"$(INTDIR)/" /Fp"$(INTDIR)/Peter.pch" /Yc"stdafx.h"\
 /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\StdAfx.sbr" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\Peter.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"

# ADD BASE CPP /Yc"stdafx.h"
# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /Zp4 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_WINDOWS" /D "_MBCS" /D "_UNICODE" /Fp"$(INTDIR)/Peter.pch" /Yc"stdafx.h"\
 /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\Peter.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"

# ADD BASE CPP /Yc"stdafx.h"
# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /Zp4 /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "_MBCS" /D "_UNICODE" /Fp"$(INTDIR)/Peter.pch" /Yc"stdafx.h" /Fo"$(INTDIR)/" /c\
 $(SOURCE) \
	

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
	".\IconBuf.h"\
	".\Mainfrm.h"\
	".\Peter.h"\
	".\Prog.h"\
	".\ProgBuf.h"\
	".\Select.h"\
	".\Stdafx.h"\
	".\TextBuf.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\MainFrm.obj" : $(SOURCE) $(DEP_CPP_MAINF) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\MainFrm.obj" : $(SOURCE) $(DEP_CPP_MAINF) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\MainFrm.sbr" : $(SOURCE) $(DEP_CPP_MAINF) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\MainFrm.obj" : $(SOURCE) $(DEP_CPP_MAINF) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\MainFrm.obj" : $(SOURCE) $(DEP_CPP_MAINF) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\Peter.rc
DEP_RSC_PETER_=\
	".\RES\COPY.cur"\
	".\res\delete.cur"\
	".\res\edit.bmp"\
	".\Res\Exec.bmp"\
	".\RES\Icon16.bmp"\
	".\RES\Icon162.BMP"\
	".\RES\Icon163.BMP"\
	".\RES\Icon164.BMP"\
	".\RES\Icon32.bmp"\
	".\RES\Icon322.BMP"\
	".\RES\Icon323.BMP"\
	".\RES\Icon324.BMP"\
	".\Res\Move.cur"\
	".\res\navig.bmp"\
	".\RES\NODRAG.cur"\
	".\RES\Palety.bmp"\
	".\Res\Peter.ico"\
	".\Res\Peter.rc2"\
	".\Res\Petrdoc.ico"\
	".\res\Prog.bmp"\
	".\res\prop.bmp"\
	".\res\select.bmp"\
	".\RES\Splith.cur"\
	".\RES\Splitv.cur"\
	".\res\state16.bmp"\
	".\res\state32.bmp"\
	".\RES\User16.bmp"\
	".\RES\User32.bmp"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\Peter.res" : $(SOURCE) $(DEP_RSC_PETER_) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\Peter.res" : $(SOURCE) $(DEP_RSC_PETER_) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\Peter.res" : $(SOURCE) $(DEP_RSC_PETER_) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\Peter.res" : $(SOURCE) $(DEP_RSC_PETER_) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


!ENDIF 

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

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"

# Begin Custom Build - Making help file...
OutDir=.\DebugU
ProjDir=.
TargetName=Peter
InputPath=.\hlp\Peter.hpj

"$(OutDir)\$(TargetName).hlp" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   "$(ProjDir)\makehelp.bat"

# End Custom Build

!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"

# Begin Custom Build - Making help file...
OutDir=.\ReleaseU
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
	".\Mainfrm.h"\
	".\Peter.h"\
	".\Select.h"\
	".\Stdafx.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\Select.obj" : $(SOURCE) $(DEP_CPP_SELEC) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\Select.obj" : $(SOURCE) $(DEP_CPP_SELEC) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\Select.sbr" : $(SOURCE) $(DEP_CPP_SELEC) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\Select.obj" : $(SOURCE) $(DEP_CPP_SELEC) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\Select.obj" : $(SOURCE) $(DEP_CPP_SELEC) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\Exec.cpp
DEP_CPP_EXEC_=\
	".\Exec.h"\
	".\Peter.h"\
	".\Stdafx.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\Exec.obj" : $(SOURCE) $(DEP_CPP_EXEC_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\Exec.obj" : $(SOURCE) $(DEP_CPP_EXEC_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\Exec.sbr" : $(SOURCE) $(DEP_CPP_EXEC_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\Exec.obj" : $(SOURCE) $(DEP_CPP_EXEC_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\Exec.obj" : $(SOURCE) $(DEP_CPP_EXEC_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\Prog.cpp
DEP_CPP_PROG_=\
	".\IconBuf.h"\
	".\Mainfrm.h"\
	".\Peter.h"\
	".\Prog.h"\
	".\ProgBuf.h"\
	".\ProgDrag.cpp"\
	".\ProgFile.cpp"\
	".\ProgInit.cpp"\
	".\ProgNav.cpp"\
	".\ProgProp.cpp"\
	".\ProgTrak.cpp"\
	".\Stdafx.h"\
	".\TextBuf.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\Prog.obj" : $(SOURCE) $(DEP_CPP_PROG_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\Prog.obj" : $(SOURCE) $(DEP_CPP_PROG_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\Prog.sbr" : $(SOURCE) $(DEP_CPP_PROG_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\Prog.obj" : $(SOURCE) $(DEP_CPP_PROG_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\Prog.obj" : $(SOURCE) $(DEP_CPP_PROG_) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ProgBuf.cpp
DEP_CPP_PROGB=\
	".\Peter.h"\
	".\ProgBuf.h"\
	".\Stdafx.h"\
	".\TextBuf.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\ProgBuf.obj" : $(SOURCE) $(DEP_CPP_PROGB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\ProgBuf.obj" : $(SOURCE) $(DEP_CPP_PROGB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\ProgBuf.sbr" : $(SOURCE) $(DEP_CPP_PROGB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\ProgBuf.obj" : $(SOURCE) $(DEP_CPP_PROGB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\ProgBuf.obj" : $(SOURCE) $(DEP_CPP_PROGB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\IconBuf.cpp
DEP_CPP_ICONB=\
	".\IconBuf.h"\
	".\Peter.h"\
	".\Stdafx.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\IconBuf.obj" : $(SOURCE) $(DEP_CPP_ICONB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\IconBuf.obj" : $(SOURCE) $(DEP_CPP_ICONB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\IconBuf.sbr" : $(SOURCE) $(DEP_CPP_ICONB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\IconBuf.obj" : $(SOURCE) $(DEP_CPP_ICONB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\IconBuf.obj" : $(SOURCE) $(DEP_CPP_ICONB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\TextBuf.CPP
DEP_CPP_TEXTB=\
	".\Peter.h"\
	".\Stdafx.h"\
	".\TextBuf.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\TextBuf.obj" : $(SOURCE) $(DEP_CPP_TEXTB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\TextBuf.obj" : $(SOURCE) $(DEP_CPP_TEXTB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\TextBuf.sbr" : $(SOURCE) $(DEP_CPP_TEXTB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\TextBuf.obj" : $(SOURCE) $(DEP_CPP_TEXTB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\TextBuf.obj" : $(SOURCE) $(DEP_CPP_TEXTB) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\Petrdoc.cpp
DEP_CPP_PETRD=\
	".\Peter.h"\
	".\PetrDoc.h"\
	".\Stdafx.h"\
	

!IF  "$(CFG)" == "Peter - Win32 Release"


"$(INTDIR)\Petrdoc.obj" : $(SOURCE) $(DEP_CPP_PETRD) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"


"$(INTDIR)\Petrdoc.obj" : $(SOURCE) $(DEP_CPP_PETRD) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"

"$(INTDIR)\Petrdoc.sbr" : $(SOURCE) $(DEP_CPP_PETRD) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Unicode"


"$(INTDIR)\Petrdoc.obj" : $(SOURCE) $(DEP_CPP_PETRD) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ELSEIF  "$(CFG)" == "Peter - Win32 Release Unicode"


"$(INTDIR)\Petrdoc.obj" : $(SOURCE) $(DEP_CPP_PETRD) "$(INTDIR)"\
 "$(INTDIR)\Peter.pch"


!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
