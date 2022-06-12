@echo off
REM -- First make map file from Microsoft Visual C++ generated resource.h
echo // MAKEHELP.BAT generated Help Map file.  Used by PETER.HPJ. >"hlp\Peter.hm"
echo. >>"hlp\Peter.hm"
echo // Commands (ID_* and IDM_*) >>"hlp\Peter.hm"
makehm ID_,HID_,0x10000 IDM_,HIDM_,0x10000 resource.h >>"hlp\Peter.hm"
echo. >>"hlp\Peter.hm"
echo // Prompts (IDP_*) >>"hlp\Peter.hm"
makehm IDP_,HIDP_,0x30000 resource.h >>"hlp\Peter.hm"
echo. >>"hlp\Peter.hm"
echo // Resources (IDR_*) >>"hlp\Peter.hm"
makehm IDR_,HIDR_,0x20000 resource.h >>"hlp\Peter.hm"
echo. >>"hlp\Peter.hm"
echo // Dialogs (IDD_*) >>"hlp\Peter.hm"
makehm IDD_,HIDD_,0x20000 resource.h >>"hlp\Peter.hm"
echo. >>"hlp\Peter.hm"
echo // Frame Controls (IDW_*) >>"hlp\Peter.hm"
makehm IDW_,HIDW_,0x50000 resource.h >>"hlp\Peter.hm"
REM -- Make help for Project PETER


echo Building Win32 Help files
start /wait hcrtf -x "hlp\Peter.hpj"
echo.
if exist Debug\nul copy "hlp\Peter.hlp" Debug
if exist Debug\nul copy "hlp\Peter.cnt" Debug
if exist Release\nul copy "hlp\Peter.hlp" Release
if exist Release\nul copy "hlp\Peter.cnt" Release
echo.


