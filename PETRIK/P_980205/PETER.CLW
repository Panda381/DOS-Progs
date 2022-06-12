; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CProg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "peter.h"
LastPage=0

ClassCount=8
Class1=CExec
Class2=CMainFrame
Class3=CPeterApp
Class4=CAboutDlg
Class5=CPeterDoc
Class6=CPeterView
Class7=CProg
Class8=CSelect

ResourceCount=7
Resource1=IDR_MAINFRAME
Resource2=IDR_OBJECT
Resource3=IDR_SELECT
Resource4=IDR_EXEC
Resource5=IDD_ABOUTBOX
Resource6=IDR_STRUC
Resource7=IDR_PROG

[CLS:CExec]
Type=0
BaseClass=CFormView
HeaderFile=Exec.h
ImplementationFile=Exec.cpp

[CLS:CMainFrame]
Type=0
BaseClass=CFrameWnd
HeaderFile=MainFrm.h
ImplementationFile=MainFrm.cpp

[CLS:CPeterApp]
Type=0
BaseClass=CWinApp
HeaderFile=Peter.h
ImplementationFile=Peter.cpp

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

[CLS:CPeterView]
Type=0
BaseClass=CFormView
HeaderFile=PetrView.h
ImplementationFile=PetrView.cpp

[CLS:CProg]
Type=0
BaseClass=CFormView
HeaderFile=Prog.h
ImplementationFile=Prog.cpp
LastObject=CProg
Filter=D
VirtualFilter=VWC

[CLS:CSelect]
Type=0
BaseClass=CFormView
HeaderFile=Select.h
ImplementationFile=Select.cpp
LastObject=IDC_PROG

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
ControlCount=3
Control1=IDC_PROG_SELECT,SysTreeView32,1342242855
Control2=IDC_PROG,SysTreeView32,1342242855
Control3=IDC_PROG_SPLIT,static,1342177280

[TB:IDR_MAINFRAME]
Type=1
Class=?
Command1=ID_START
Command2=ID_FILE_OPEN
Command3=ID_FILE_SAVE
Command4=ID_EDIT_CUT
Command5=ID_EDIT_COPY
Command6=ID_EDIT_PASTE
Command7=ID_FILE_PRINT
Command8=ID_APP_ABOUT
Command9=ID_CONTEXT_HELP
Command10=IDR_SELECT
Command11=IDR_EXEC
Command12=IDR_PROG
CommandCount=12

[TB:IDR_SELECT]
Type=1
Class=?
Command1=ID_START
Command2=ID_FILE_OPEN
CommandCount=2

[TB:IDR_EXEC]
Type=1
Class=?
Command1=ID_STOP
CommandCount=1

[TB:IDR_PROG]
Type=1
Class=?
Command1=ID_START
Command2=ID_FILE_CLOSE2
Command3=ID_FILE_SAVE
Command4=ID_FILE_PRINT
Command5=ID_EDIT_CUT
Command6=ID_EDIT_COPY
Command7=ID_EDIT_PASTE
Command8=ID_CONTEXT_HELP
CommandCount=8

[TB:IDR_STRUC]
Type=1
Class=?
Command1=ID_START
Command2=ID_START
Command3=ID_START
Command4=ID_START
Command5=ID_START
Command6=ID_START
Command7=ID_START
Command8=ID_START
Command9=ID_START
Command10=ID_START
Command11=ID_START
Command12=ID_START
Command13=ID_START
Command14=ID_START
Command15=ID_START
CommandCount=15

[TB:IDR_OBJECT]
Type=1
Class=?
Command1=ID_START
Command2=ID_START
Command3=ID_START
Command4=ID_START
Command5=ID_START
CommandCount=5

[MNU:IDR_MAINFRAME]
Type=1
Class=?
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
Command3=ID_FILE_SAVE
Command4=ID_FILE_SAVE_AS
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
Command1=ID_FILE_SAVE
Command2=ID_FILE_SAVE_AS
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
Command1=ID_FILE_NEW
Command2=ID_FILE_OPEN
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
Command1=ID_EDIT_COPY
Command2=ID_FILE_NEW
Command3=ID_FILE_SAVE
Command4=ID_EDIT_PASTE
Command5=ID_EDIT_UNDO
Command6=ID_EDIT_CUT
Command7=ID_FILE_CLOSE2
Command8=ID_HELP
Command9=ID_CONTEXT_HELP
Command10=ID_START
Command11=ID_NEXT_PANE
Command12=ID_PREV_PANE
Command13=ID_EDIT_COPY
Command14=ID_EDIT_PASTE
Command15=ID_EDIT_CUT
Command16=ID_EDIT_UNDO
CommandCount=16

[DLG:IDR_SELECT]
Type=1
Class=?
ControlCount=1
Control1=IDC_SELECT,SysListView32,1342177364

