qfont
if not exist l goto konec
portrait
if not exist p.sfp goto konec
copy /b h12_uv10.bin + p.sfp + h12_zv10.bin hpljcs10.bin
:konec
