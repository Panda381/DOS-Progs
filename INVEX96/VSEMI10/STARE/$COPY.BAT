if not exist gema_%1.tga goto Konec
if not exist gema_%2.tga copy gema_%1.tga gema_%2.tga > nul
:Konec
