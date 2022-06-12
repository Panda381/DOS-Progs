% ------------
% MAX-PROT.CTL
% ------------
%
% This file is used to define external protocols usable with Max 2.0.
% Both Opus-compatible and non-standard protocols can be used
% directly by Maximus.
%
% If you're running 4DOS (or any other alternate shell), you
% should replace all occurences of "command.com" with the name of
% your shell (such as 4dos.com).  Failure to do this may cause erratic
% results when calling external protocols.
%
% If you would like to replace the Maximus INTERNAL Zmodem with the one
% defined below, you will need to edit your batch file that calls Maximus
% to add a command line parameter.  -xz on the Maximus command line will
% DISABLE the internal Max-Zmodem and allow you to use the letter "Z"
% on the protocol screen for your own user-defined protocol driver.  You
% will then need to uncomment the section below pertaining to the Zmodem
% protocol driver.
%
% This sample PROTOCOL.CTL file also defines a ZedZap (8K Zmodem), Ymodem-1K,
% Ymodem-Batch and a Ymodem-G protocol selection entry.
%
% (Xmodem and Xmodem-1K are not supplied, as they are built into Maximus
% and cannot be disabled).
%
% To include these external protocols in your Maximus setup, edit MAX.CTL
% to include the line:
%
% Include "MAX-PROT.CTL"
%
% Then you should run SILT on your Maximus control file.  Of course, you
% can also import the pertinent sections of this file into an existing
% PROTOCOL.CTL file.
%
% You should then make sure that CEXYZ.EXE is in a directory defined in your
% DOS PATH.  If you do not wish to place CEXYZ.EXE in your path, you will
% need to place it into your \MAX installation directory.  The sample batch
% file (XYZBATCH.BAT) *shouldn't* need any editing.  This file must be placed
% in your \MAX BBS installation directory.
%
% Only uncomment this protocol definition if you are disabling Maximus's
% internal Zmodem.
% Protocol Zmodem
%          Type            Batch
%          LogFile         DSZ%K.Log
%          ControlFile     DSZ%K.Ctl
%          DownloadCmd     command.com /c xyzbatch DSZ%K.Log /P%P /B%W /sz @%x:DSZ%K.Ctl
%          UploadCmd       command.com /c xyzbatch DSZ%K.Log /P%P /B%W /rz %v
%          DownloadString  %s
%          UploadString
%          DownloadKeyword z
%          UploadKeyword   Z
%          FilenameWord    10
%          DescriptWord    0
% End Protocol
%
%
Protocol 8K Zmodem (ZedZap)
         Type            Batch
         LogFile         DSZ%K.Log
         ControlFile     DSZ%K.Ctl
         DownloadCmd     command.com /c xyzbatch DSZ%K.Log /P%P /B%W /szap @%x:DSZ%K.Ctl
         UploadCmd       command.com /c xyzbatch DSZ%K.Log /P%P /B%W /rzap %v
         DownloadString  %s
         UploadString
         DownloadKeyword z
         UploadKeyword   Z
         FilenameWord    10
         DescriptWord    0
End Protocol
%
%
Protocol Y Ymodem-Batch
         Type Batch
         LogFile         DSZ%K.Log
         ControlFile     DSZ%K.Ctl
         DownloadCmd     command.com /c xyzbatch DSZ%K.Log /P%P /B%W /sy @%x:DSZ%K.Ctl
         UploadCmd       command.com /c xyzbatch DSZ%K.Log /P%P /B%W /ry %v
         DownloadString  %s
         UploadString
         DownloadKeyword S
         UploadKeyword   R
         FilenameWord    10
         DescriptWord    0
End Protocol
%
%
Protocol G Ymodem-G
         Type Batch
         LogFile         DSZ%K.Log
         ControlFile     DSZ%K.Ctl
         DownloadCmd     command.com /c xyzbatch DSZ%K.Log /P%P /B%W /syg @%x:DSZ%K.Ctl
         UploadCmd       command.com /c xyzbatch DSZ%K.Log /P%P /B%W /ryg %v
         DownloadString  %s
         UploadString
         DownloadKeyword S
         UploadKeyword   R
         FilenameWord    10
         DescriptWord    0
End Protocol
%
%
Protocol K Ymodem-1K Batch
         Type Batch
         LogFile         DSZ%K.Log
         ControlFile     DSZ%K.Ctl
         DownloadCmd     command.com /c xyzbatch DSZ%K.Log /P%P /B%W /sy1k @%x:DSZ%K.Ctl
         UploadCmd       command.com /c xyzbatch DSZ%K.Log /P%P /B%W /ry1k %v
         DownloadString  %s
         UploadString
         DownloadKeyword S
         UploadKeyword   R
         FilenameWord    10
         DescriptWord    0
End Protocol
%
%
% Credit goes to Scott J. Dudley for the basis of this sample PROTOCOL.CTL
% file.
%
% --- END SAMPLE MAX-PROT.CTL ---
