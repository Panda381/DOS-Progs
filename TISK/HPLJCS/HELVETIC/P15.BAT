qfont
if not exist l goto konec
portrait
if not exist p.sfp goto konec
copy /b h12_uv15.bin + p.sfp + h12_zv15.bin hpljcs15.bin
:konec
