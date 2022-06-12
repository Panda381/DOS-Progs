@echo off

rem --------------------------------------------------
rem               Konverze TGA na 2D
rem --------------------------------------------------

if exist gema.0* del gema.0*
if exist gema.1* del gema.1*
if exist gema.2* del gema.2*
if exist gema.3* del gema.3*
if exist gema.4* del gema.4*
if exist gema.5* del gema.5*
if exist gema.6* del gema.6*
if exist gema.7* del gema.7*
if exist gema.8* del gema.8*
if exist gema.9* del gema.9*
exe\heckbert -T=1 -N=170 gema
