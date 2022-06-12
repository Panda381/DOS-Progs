@echo off
kontext sharp.mac
echo c:\cpm\m80.com =sharp.mac > autoexec.z80
echo c:\cpm\l80.com /P:3000,sharp.rel,font08.rel/S,sharp.cpm/N/E >> autoexec.z80
echo exit >> autoexec.z80
c:\cpm\z80mu
del autoexec.z80
rem del sharp.rel
c:\cpm\cpm2mz8 sharp
rem del sharp.cpm
