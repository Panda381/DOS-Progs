@echo off
if exist *.tga del *.tga
alchemy *.gif -a -X320 -Y200
dta /ogemahrad hrad_*.tga /s5
if exist *.tga del *.tga
rem echo 
