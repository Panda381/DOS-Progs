qfont
if not exist l goto konec
portrait
if not exist p.sfp goto konec
copy /b h12_uv.bin + p.sfp + h12_zv.bin hpljcs.bin
:konec
