@echo off
if not exist g:\tetrix\nul md g:\tetrix
if not exist g:\tetrix\tetrix.exe copy tetrix\tetrix.exe g:\tetrix\tetrix.exe > NUL
g:
cd\tetrix
tetrix
cd\
c:
