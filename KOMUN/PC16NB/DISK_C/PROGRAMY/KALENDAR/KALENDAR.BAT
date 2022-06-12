@echo off
if not exist g:\kalendar\nul md g:\kalendar
if not exist g:\kalendar\kalend.com copy c:\programy\kalendar\kalend.com g:\kalendar\kalend.com > NUL
G:
CD\KALENDAR
KALEND /!
CD\
C:
