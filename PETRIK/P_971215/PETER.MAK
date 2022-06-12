# Microsoft Visual C++ generated build script - Do not modify

PROJ = PETER
DEBUG = 1
PROGTYPE = 0
CALLER = 
ARGS = 
DLLS = 
D_RCDEFINES = -d_DEBUG
R_RCDEFINES = -dNDEBUG
ORIGIN = MSVC
ORIGIN_VER = 1.00
PROJPATH = C:\PROGRA~1\MSVC\PROJECTS\PETER\
USEMFC = 0
CC = cl
CPP = cl
CXX = cl
CCREATEPCHFLAG = 
CPPCREATEPCHFLAG = 
CUSEPCHFLAG = 
CPPUSEPCHFLAG = 
FIRSTC =             
FIRSTCPP =             
RC = rc
CFLAGS_D_WEXE = /nologo /W3 /FR /G2 /Zi /D_DEBUG /Od /AM /GA /Fd"PETER.PDB"
CFLAGS_R_WEXE = /nologo /W3 /FR /O1 /DNDEBUG /AM /GA
LFLAGS_D_WEXE = /NOLOGO /ONERROR:NOEXE /NOD /PACKC:61440 /CO /ALIGN:16 /STACK:10240
LFLAGS_R_WEXE = /NOLOGO /ONERROR:NOEXE /NOD /PACKC:61440 /ALIGN:16 /STACK:10240
LIBS_D_WEXE = oldnames libw commdlg shell olecli olesvr mlibcew
LIBS_R_WEXE = oldnames libw commdlg shell olecli olesvr mlibcew
RCFLAGS = /nologo
RESFLAGS = /nologo
RUNFLAGS = 
DEFFILE = PETER.DEF
OBJS_EXT = 
LIBS_EXT = 
!if "$(DEBUG)" == "1"
CFLAGS = $(CFLAGS_D_WEXE)
LFLAGS = $(LFLAGS_D_WEXE)
LIBS = $(LIBS_D_WEXE)
MAPFILE = nul
RCDEFINES = $(D_RCDEFINES)
!else
CFLAGS = $(CFLAGS_R_WEXE)
LFLAGS = $(LFLAGS_R_WEXE)
LIBS = $(LIBS_R_WEXE)
MAPFILE = nul
RCDEFINES = $(R_RCDEFINES)
!endif
!if [if exist MSVC.BND del MSVC.BND]
!endif
SBRS = APP.SBR \
		MAINFRM.SBR


APP_DEP = c:\progra~1\msvc\projects\peter\include.h \
	c:\progra~1\msvc\projects\peter\app.h \
	c:\progra~1\msvc\projects\peter\mainfrm.h


MAINFRM_DEP = c:\progra~1\msvc\projects\peter\include.h \
	c:\progra~1\msvc\projects\peter\app.h \
	c:\progra~1\msvc\projects\peter\mainfrm.h


PETER_RCDEP = c:\progra~1\msvc\projects\peter\peter.ico


all:	$(PROJ).EXE $(PROJ).BSC

APP.OBJ:	APP.C $(APP_DEP)
	$(CC) $(CFLAGS) $(CUSEPCHFLAG) /c APP.C

MAINFRM.OBJ:	MAINFRM.C $(MAINFRM_DEP)
	$(CC) $(CFLAGS) $(CUSEPCHFLAG) /c MAINFRM.C

PETER.RES:	PETER.RC $(PETER_RCDEP)
	$(RC) $(RCFLAGS) $(RCDEFINES) -r PETER.RC


$(PROJ).EXE::	PETER.RES

$(PROJ).EXE::	APP.OBJ MAINFRM.OBJ $(OBJS_EXT) $(DEFFILE)
	echo >NUL @<<$(PROJ).CRF
APP.OBJ +
MAINFRM.OBJ +
$(OBJS_EXT)
$(PROJ).EXE
$(MAPFILE)
c:\progra~1\msvc\lib\+
c:\progra~1\msvc\mfc\lib\+
$(LIBS)
$(DEFFILE);
<<
	link $(LFLAGS) @$(PROJ).CRF
	$(RC) $(RESFLAGS) PETER.RES $@
	@copy $(PROJ).CRF MSVC.BND

$(PROJ).EXE::	PETER.RES
	if not exist MSVC.BND 	$(RC) $(RESFLAGS) PETER.RES $@

run: $(PROJ).EXE
	$(PROJ) $(RUNFLAGS)


$(PROJ).BSC: $(SBRS)
	bscmake @<<
/o$@ $(SBRS)
<<
