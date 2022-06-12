if exist gema%1.tga goto dale
del x.tga
..\exec\povray +I..\gema.pov +Ogema%1.tga +L..\include +W320 +H200 +A +V +K%1
if errorlevel 1 goto dale

..\exec\alchemy gema%1.tga x.tga -a1
if not exist x.tga goto dale
copy x.tga gema%1.tga

:dale

