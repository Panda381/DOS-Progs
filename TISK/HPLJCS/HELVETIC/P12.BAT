qfont
if not exist l goto konec
portrait
if not exist p.sfp goto konec
copy /b h12_uv12.bin + p.sfp + h12_zv12.bin hpljcs12.bin
:konec
