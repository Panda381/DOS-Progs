@echo off
if exist kontext.com goto existuje
c:\edit\kontext\kontext %1 #2 %2 #3 %3 #4 %4 #5 %5 #1
goto konec
:existuje
kontext %1 #2 %2 #3 %3 #4 %4 #5 %5 #1
:konec
