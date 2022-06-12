@echo off

call !clear1.bat Debug
call !clear1.bat Release
call !clear1.bat Debug_x64
call !clear1.bat Release_x64

if exist *.pdb del *.pdb
if exist *.ncb del *.ncb
if exist *.user del *.user
if exist TexiGen_deb.exe del TexiGen_deb.exe
if exist TexiGen_deb64.exe del TexiGen_deb64.exe
if exist Resource\TexiGen.aps del Resource\TexiGen.aps

if exist !MOJE\*.bak del !MOJE\*.bak
if exist Images\*.bak del Images\*.bak
if exist Integrated\*.bak del Integrated\*.bak
if exist Metal\*.bak del Metal\*.bak
if exist Natural\*.bak del Natural\*.bak
if exist Organics\*.bak del Organics\*.bak
if exist Patterns\*.bak del Patterns\*.bak
if exist Stone\*.bak del Stone\*.bak
if exist Tiles\*.bak del Tiles\*.bak
if exist Video\*.bak del Video\*.bak
if exist Wood\*.bak del Wood\*.bak

attrib -H TexiGen.suo > nul
if exist TexiGen.suo del TexiGen.suo
