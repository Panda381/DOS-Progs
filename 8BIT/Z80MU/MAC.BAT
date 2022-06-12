@echo off
kontext %1.mac
echo c:\cpm\m80.com =%1.mac > autoexec.z80
echo c:\cpm\l80.com %1.rel,%1.cpm /N/E >> autoexec.z80
echo exit >> autoexec.z80
c:\cpm\z80mu
del autoexec.z80
rem del %1.rel
c:\cpm\cpm2mz8 %1
rem del %1.cpm
