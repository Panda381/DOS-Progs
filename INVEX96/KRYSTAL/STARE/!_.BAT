if exist gema0%1.TGA goto dale
del x.tga
c:\povray\povray +Igema.POV +Ogema0%1.TGA +LC:\povray\include +W320 +H200 +V -A +K%1
if errorlevel 1 goto dale
if not exist gema0%1.TGA goto dale
alchemy gema0%1.TGA x.tga /a1
if not exist x.tga goto dale
del gema0%1.tga
ren x.tga gema0%1.tga
:dale
