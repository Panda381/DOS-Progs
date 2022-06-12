@echo off
rem Prijem dat z videorekorderu

del pokus2.*
:s
echo konstanta 00
delay 9 > nul
streamer 3
copy pokus2 pokus2.00 > nul

echo zmˆna 00 - FF - 00 - FF
delay 9 > nul
streamer 3
copy pokus2 pokus2.0f > nul

echo konstanta 5A
delay 9 > nul
streamer 3
copy pokus2 pokus2.5a > nul

echo konstanta 11
delay 9 > nul
streamer 3
copy pokus2 pokus2.11 > nul

echo konstanta FF
delay 9 > nul
streamer 3
copy pokus2 pokus2.ff > nul

echo ruzna data
delay 9 > nul
streamer 3
copy pokus2 pokus2.ruz > nul

echo n hodn˜ ¨um
delay 9 > nul
streamer 3
copy pokus2 pokus2.sum > nul

echo text
delay 9 > nul
streamer 3
copy pokus2 pokus2.txt > nul

rem goto s
del pokus2.
