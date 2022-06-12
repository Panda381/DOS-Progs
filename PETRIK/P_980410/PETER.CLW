; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CProg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "peter.h"
LastPage=0

ClassCount=11
Class1=CExec
Class2=CMainFrame
Class3=CPeterApp
Class4=CAboutDlg
Class5=CPeterDoc
Class6=CPeterView
Class7=CProg
Class8=CSelect

ResourceCount=8
Resource1=IDR_SELECT
Resource2=IDR_EDIT
Resource3=IDR_EXEC
Resource4=IDD_ABOUTBOX
Resource5=IDR_MAINFRAME
Class9=CProgBuf
Class10=CIconBuf
Class11=CTextBuf
Resource6=IDR_PROP
Resource7=IDR_NAVIG
Resource8=IDR_PROG

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
LastObject=IDC_PROG_REFER

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
LastObject=IDC_PROG_EDIT
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
ControlCount=13
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
Command6=ID_EDIT_UNDO
Command7=ID_EDIT_CUT
Command8=ID_EDIT_COPY
Command9=ID_EDIT_PASTE
Command10=ID_VIEW_TOOLBAR
Command11=ID_VIEW_STATUS_BAR
Command12=ID_HELP_FINDER
Command13=ID_APP_ABOUT
CommandCount=13

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
CommandCount=5

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

