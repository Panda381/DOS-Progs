qfont
if not exist l goto konec
portrait
if not exist p.sfp goto konec
copy /b h12_uv20.bin + p.sfp + h12_zv20.bin hpljcs2v.bin
:konec
