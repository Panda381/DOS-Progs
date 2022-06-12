@echo off
rem Komparace prijatych a vyslanych dat

echo konstanta 00
fc /b pokus1.00 pokus2.00

echo zmˆna 00 - FF - 00 - FF
fc /b pokus1.0f pokus2.0f

echo konstanta 5A
fc /b pokus1.5a pokus2.5a

echo konstanta 11
fc /b pokus1.11 pokus2.11

echo konstanta FF
fc /b pokus1.ff pokus2.ff

echo ruzna data
fc /b pokus1.ruz pokus2.ruz

echo n hodn˜ ¨um
fc /b pokus1.sum pokus2.sum

echo text
fc /b pokus1.txt pokus2.txt
