; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CProg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "peter.h"
LastPage=0

ClassCount=18
Class1=CExec
Class2=CMainFrame
Class3=CPeterApp
Class4=CAboutDlg
Class5=CPeterDoc
Class6=CPeterView
Class7=CProg
Class8=CSelect

ResourceCount=14
Resource1=IDD_EDIT_ICON
Resource2=IDR_EDIT
Resource3=IDR_EDITICON
Resource4=IDD_ABOUTBOX
Resource5=IDR_MAINFRAME
Class9=CProgBuf
Class10=CIconBuf
Class11=CTextBuf
Resource6=IDR_PROP
Resource7=IDR_NAVIG
Resource8=IDR_EXEC
Class12=CEditDial
Resource9=IDD_EDIT_DIALOG
Class13=CEditSprite
Resource10=IDD_EDIT_SPRITE
Class14=CEditIcon
Resource11=IDR_SELECT
Class15=CRealBuf
Class16=CBoolBuf
Resource12=IDR_PROG
Class17=CEditMap
Class18=CMapBuf
Resource13=IDD_EDIT_MAP
Resource14=IDR_EDITMAP

[CLS:CExec]
Type=0
BaseClass=CFormView
HeaderFile=Exec.h
ImplementationFile=Exec.cpp
LastObject=CExec

[CLS:CMainFrame]
Type=0
BaseClass=CFrameWnd
HeaderFile=MainFrm.h
ImplementationFile=MainFrm.cpp
Filter=T
VirtualFilter=fWC
LastObject=CMainFrame

[CLS:CPeterApp]
Type=0
BaseClass=CWinApp
HeaderFile=Peter.h
ImplementationFile=Peter.cpp
LastObject=CPeterApp
Filter=N
VirtualFilter=AC

[CLS:CAboutDlg]
Type=0
BaseClass=CDialog
HeaderFile=Peter.cpp
ImplementationFile=Peter.cpp
LastObject=CAboutDlg

[CLS:CPeterDoc]
Type=0
BaseClass=CDocument
HeaderFile=PetrDoc.h
ImplementationFile=PetrDoc.cpp
Filter=N
VirtualFilter=DC
LastObject=CPeterDoc

[CLS:CPeterView]
Type=0
BaseClass=CFormView
HeaderFile=PetrView.h
ImplementationFile=PetrView.cpp
LastObject=CPeterView

[CLS:CProg]
Type=0
BaseClass=CFormView
HeaderFile=Prog.h
ImplementationFile=Prog.cpp
LastObject=IDC_PROG_OBJECT
Filter=D
VirtualFilter=VWC

[CLS:CSelect]
Type=0
BaseClass=CFormView
HeaderFile=Select.h
ImplementationFile=Select.cpp
LastObject=CSelect

[DLG:IDR_EXEC]
Type=1
Class=CExec
ControlCount=1
Control1=IDC_EXEC,SysAnimate32,1342242823

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAboutDlg
ControlCount=5
Control1=IDC_STATIC,static,1342177283
Control2=IDC_STATIC,static,1342308480
Control3=IDC_STATIC,static,1342308352
Control4=IDOK,button,1342373889
Control5=IDC_STATIC,static,1342308352

[DLG:IDD_PETER_FORM]
Type=1
Class=CPeterView

[DLG:IDR_PROG]
Type=1
Class=CSelect
ControlCount=18
Control1=IDC_PROG,SysTreeView32,1342242863
Control2=IDC_PROG_STRUC,SysTreeView32,1342242863
Control3=IDC_PROG_CLASS,SysTreeView32,1342242863
Control4=IDC_PROG_LOCAL,SysTreeView32,1342242863
Control5=IDC_PROG_OBJECT,SysTreeView32,1342242863
Control6=IDC_PROG_SPLIT1,static,1342177280
Control7=IDC_PROG_SPLIT2,static,1342177280
Control8=IDC_PROG_SPLIT4,static,1342177280
Control9=IDC_PROG_SPLIT3,static,1342177280
Control10=IDC_STATIC3,static,1342308353
Control11=IDC_STATIC4,static,1342308353
Control12=IDC_STATIC2,static,1342308353
Control13=IDC_STATIC1,static,1342308353
Control14=IDC_PROG_REAL,edit,1342242944
Control15=IDC_PROG_TEXT,edit,1342247108
Control16=IDC_PROG_SOUND,static,1342242819
Control17=IDC_PROG_MUSIC,static,1342242819
Control18=IDC_PROG_LOGIC,button,1342244099

[TB:IDR_SELECT]
Type=1
Class=?
Command1=ID_START
Command2=ID_FILE_NEW2
Command3=ID_FILE_OPEN2
CommandCount=3

[TB:IDR_EXEC]
Type=1
Class=?
Command1=ID_STOP
CommandCount=1

[TB:IDR_PROG]
Type=1
Class=?
Command1=ID_START
Command2=ID_FILE_SAVE2
Command3=ID_FILE_CLOSE2
CommandCount=3

[MNU:IDR_MAINFRAME]
Type=1
Class=?
Command1=ID_FILE_NEW2
Command2=ID_FILE_OPEN2
Command3=ID_FILE_SAVE2
Command4=ID_FILE_SAVE_AS2
Command5=ID_FILE_CLOSE2
Command6=ID_START
Command7=ID_APP_EXIT
Command8=ID_EDIT_UNDO
Command9=ID_EDIT_CUT
Command10=ID_EDIT_COPY
Command11=ID_EDIT_PASTE
Command12=ID_VIEW_TOOLBAR
Command13=ID_VIEW_STATUS_BAR
Command14=ID_HELP_FINDER
Command15=ID_APP_ABOUT
CommandCount=15

[MNU:IDR_EXEC]
Type=1
Class=?
Command1=ID_STOP
Command2=ID_APP_EXIT
Command3=ID_VIEW_TOOLBAR
Command4=ID_VIEW_STATUS_BAR
Command5=ID_HELP_FINDER
Command6=ID_APP_ABOUT
CommandCount=6

[MNU:IDR_PROG]
Type=1
Class=?
Command1=ID_FILE_SAVE2
Command2=ID_FILE_SAVE_AS2
Command3=ID_FILE_CLOSE2
Command4=ID_START
Command5=ID_APP_EXIT
Command6=IDC_PROG_UNDO
Command7=IDC_PROG_REDO
Command8=ID_EDIT_CUT
Command9=ID_EDIT_COPY
Command10=ID_EDIT_PASTE
Command11=ID_VIEW_TOOLBAR
Command12=ID_VIEW_STATUS_BAR
Command13=ID_HELP_FINDER
Command14=ID_APP_ABOUT
CommandCount=14

[MNU:IDR_SELECT]
Type=1
Class=?
Command1=ID_FILE_NEW2
Command2=ID_FILE_OPEN2
Command3=ID_START
Command4=ID_APP_EXIT
Command5=ID_VIEW_TOOLBAR
Command6=ID_VIEW_STATUS_BAR
Command7=ID_HELP_FINDER
Command8=ID_APP_ABOUT
CommandCount=8

[ACL:IDR_MAINFRAME]
Type=1
Class=?
Command1=ID_EDIT_COPY
Command2=ID_FILE_NEW
Command3=ID_FILE_OPEN
Command4=ID_FILE_SAVE
Command5=ID_EDIT_PASTE
Command6=ID_EDIT_UNDO
Command7=ID_EDIT_CUT
Command8=ID_HELP
Command9=ID_CONTEXT_HELP
Command10=ID_NEXT_PANE
Command11=ID_PREV_PANE
Command12=ID_EDIT_COPY
Command13=ID_EDIT_PASTE
Command14=ID_EDIT_CUT
Command15=ID_EDIT_UNDO
CommandCount=15

[ACL:IDR_SELECT]
Type=1
Class=?
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
Command3=ID_HELP
Command4=ID_CONTEXT_HELP
Command5=ID_FILE_OPEN
Command6=ID_START
Command7=ID_START
Command8=ID_FILE_OPEN
CommandCount=8

[ACL:IDR_EXEC]
Type=1
Class=?
Command1=ID_STOP
Command2=ID_HELP
Command3=ID_CONTEXT_HELP
CommandCount=3

[ACL:IDR_PROG]
Type=1
Class=?
Command1=IDC_PROG_EDIT2
Command2=ID_FILE_SAVE
Command3=ID_HELP
Command4=ID_CONTEXT_HELP
Command5=ID_START
Command6=IDC_PROG_REDO
Command7=IDC_PROG_UNDO
CommandCount=7

[DLG:IDR_SELECT]
Type=1
Class=?
ControlCount=1
Control1=IDC_SELECT,SysListView32,1342177364

[CLS:CProgBuf]
Type=0
HeaderFile=ProgBuf.h
ImplementationFile=ProgBuf.cpp
BaseClass=generic CWnd
Filter=W

[CLS:CIconBuf]
Type=0
HeaderFile=IconBuf.h
ImplementationFile=IconBuf.cpp
BaseClass=generic CWnd
Filter=W

[CLS:CTextBuf]
Type=0
HeaderFile=TextBuf.h
ImplementationFile=TextBuf.cpp
BaseClass=generic CWnd
Filter=W

[TB:IDR_PROP]
Type=1
Command1=IDC_PROG_LOCK
Command2=IDC_PROG_OFF
Command3=IDC_PROG_DEF
Command4=IDC_PROG_EDIT
Command5=IDC_PROG_ICON
CommandCount=5

[TB:IDR_NAVIG]
Type=1
Command1=IDC_PROG_FIND
Command2=IDC_PROG_PREV
Command3=IDC_PROG_NEXT
Command4=IDC_PROG_REFER
Command5=IDC_REF_DEF
Command6=IDC_REF_PREV
Command7=IDC_REF_NEXT
CommandCount=7

[TB:IDR_EDIT]
Type=1
Command1=IDC_PROG_DEL
Command2=IDC_PROG_CLIP
Command3=IDC_PROG_UNDO
Command4=IDC_PROG_REDO
CommandCount=4

[CLS:CEditDial]
Type=0
HeaderFile=EditDial.h
ImplementationFile=EditDial.cpp
BaseClass=CDialog
Filter=D
LastObject=CEditDial

[DLG:IDD_EDIT_DIALOG]
Type=1
Class=CEditDial
ControlCount=4
Control1=IDOK,button,1342242817
Control2=IDCANCEL,button,1342242816
Control3=IDC_STATIC,static,1342177283
Control4=IDC_STATIC,static,1342177287

[DLG:IDD_EDIT_SPRITE]
Type=1
Class=CEditSprite
ControlCount=9
Control1=IDC_STATIC,static,1342177283
Control2=IDC_STATIC,static,1342177287
Control3=IDC_EDIT1,edit,1350631552
Control4=IDC_LIST1,SysListView32,1350631424
Control5=IDC_PROGRESS1,msctls_progress32,1350565888
Control6=IDC_SPIN1,msctls_updown32,1342177312
Control7=IDC_SLIDER1,msctls_trackbar32,1342242840
Control8=IDC_SCROLLBAR1,scrollbar,1342177281
Control9=IDC_SCROLLBAR2,scrollbar,1342177280

[CLS:CEditSprite]
Type=0
HeaderFile=EditSprt.h
ImplementationFile=EditSprt.cpp
BaseClass=CDialog
Filter=D
LastObject=CEditSprite

[DLG:IDD_EDIT_ICON]
Type=1
Class=CEditIcon
ControlCount=0

[CLS:CEditIcon]
Type=0
HeaderFile=EditIcon.h
ImplementationFile=EditIcon.cpp
BaseClass=CDialog
Filter=D
LastObject=CEditIcon
VirtualFilter=dWC

[TB:IDR_EDITICON]
Type=1
Command1=IDC_EDITICON_PEN
Command2=IDC_EDITICON_PAINT
Command3=IDC_EDITICON_PIPE
Command4=IDC_EDITICON_FILL
Command5=IDC_EDITICON_SPRAY
Command6=IDC_EDITICON_LINE
Command7=IDC_EDITICON_RECT
Command8=IDC_EDITICON_ROUND
Command9=IDC_EDITICON_ELIP
Command10=IDC_EDITICON_SELECT
Command11=IDC_EDITICON_XFLIP
Command12=IDC_EDITICON_YFLIP
Command13=IDC_EDITICON_RROT
Command14=IDC_EDITICON_LROT
Command15=IDC_EDITICON_XCOL
Command16=IDC_EDITICON_XY
Command17=IDC_STATIC
CommandCount=17

[CLS:CRealBuf]
Type=0
HeaderFile=RealBuf.h
ImplementationFile=RealBuf.cpp
BaseClass=generic CWnd
Filter=W

[CLS:CBoolBuf]
Type=0
HeaderFile=BoolBuf.h
ImplementationFile=BoolBuf.cpp
BaseClass=generic CWnd
Filter=W

[DLG:IDD_EDIT_MAP]
Type=1
Class=CEditMap
ControlCount=2
Control1=IDC_EDITMAP_VSCROLL,scrollbar,1342177281
Control2=IDC_EDITMAP_HSCROLL,scrollbar,1342177280

[CLS:CEditMap]
Type=0
HeaderFile=EditMap.h
ImplementationFile=EditMap.cpp
BaseClass=CDialog
Filter=D
LastObject=CEditMap
VirtualFilter=dWC

[CLS:CMapBuf]
Type=0
HeaderFile=MapBuf.h
ImplementationFile=MapBuf.cpp
BaseClass=generic CWnd
Filter=W

[TB:IDR_EDITMAP]
Type=1
Command1=IDC_EDITMAP_SIRKA_TEXT
Command2=IDC_EDITMAP_SIRKA_EDIT
Command3=IDC_EDITMAP_VYSKA_TEXT
Command4=IDC_EDITMAP_VYSKA_EDIT
Command5=IDC_EDITMAP_XY
Command6=IDC_EDITMAP_XY2
CommandCount=6

