@echo off
for %%L in (0 1 2) do call $rend100.bat %%L
for %%L in (0 1 2 3) do call $rend10.bat 3%%L
