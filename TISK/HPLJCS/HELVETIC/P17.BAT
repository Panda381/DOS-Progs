qfont
if not exist l goto konec
portrait
if not exist p.sfp goto konec
copy /b h12_uv17.bin + p.sfp + h12_zv17.bin hpljcs17.bin
:konec
