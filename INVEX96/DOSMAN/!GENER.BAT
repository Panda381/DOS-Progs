@echo off
for %%L in (0 1 2 3 4 5 6 7 8 9) do call $rend100.bat %%L
for %%L in (0 1 2 3 4 5) do call $rend100.bat 1%%L
