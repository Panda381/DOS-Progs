CD\
IF NOT EXIST AUTOEXEC.BAT GOTO A
IF EXIST HSDB.$$$ GOTO A
COPY AUTOEXEC.BAT HSDB.$$$
:A
COPY FIHS.BAT AUTOEXEC.BAT
HSRST
