echo off
%3ASK "Zadejte volbu (""A""=Ano,""N""=Ne): "an
IF ERRORLEVEL == 2 GOTO ne
ECHO ANO
GOTO mezera
:ne
ECHO NE
:mezera
%3ASK "Stisknete mezernik ..."
ECHO.
IF ERRORLEVEL == 33 GOTO mezera
IF NOT ERRORLEVEL == 32 GOTO mezera
