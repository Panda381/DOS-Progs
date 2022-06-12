if exist gema.TGA goto dale
..\exec\povray +Igema.POV +Ogema.TGA +L..\include +W640 +H480 +A +D
goto konv

:dale
..\exec\povray +Igema.POV +Ogema.TGA +L..\include +W640 +H480 +A +C +D

:konv
if not exist gema.TGA goto konec
if exist gema.GIF DEL gema.GIF
..\exec\alchemy gema.TGA gema.GIF -g

:konec

