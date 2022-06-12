@echo off
rem Vyslani dat na videorekorder

:s
copy pokus1.00 pokus1 > nul
echo konstanta 00
delay 9 > nul
streamer

copy pokus1.0f pokus1 > nul
echo zmˆna 00 - FF - 00 - FF
delay 9 > nul
streamer

copy pokus1.5a pokus1 > nul
echo konstanta 5A
delay 9 > nul
streamer

copy pokus1.11 pokus1 > nul
echo konstanta 11
delay 9 > nul
streamer

copy pokus1.ff pokus1 > nul
echo konstanta FF
delay 9 > nul
streamer

copy pokus1.ruz pokus1 > nul
echo ruzna data
delay 9 > nul
streamer

copy pokus1.sum pokus1 > nul
echo n hodn˜ ¨um
delay 9 > nul
streamer

copy pokus1.txt pokus1 > nul
echo text
delay 9 > nul
streamer

rem goto s
