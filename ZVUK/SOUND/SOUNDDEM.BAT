@echo off
sound sound1.sam
if errorlevel == 1 goto konec
sound sound2.snd
if errorlevel == 1 goto konec
sound sound3.voc
if errorlevel == 1 goto konec
sound sound4.sam
if errorlevel == 1 goto konec
sound sound5.spk
if errorlevel == 1 goto konec
sound sound4.sam
if errorlevel == 1 goto konec
sound sound6.nti /12000
if errorlevel == 1 goto konec
sound sound7.wav
if errorlevel == 1 goto konec
sound sound3.voc
:konec
