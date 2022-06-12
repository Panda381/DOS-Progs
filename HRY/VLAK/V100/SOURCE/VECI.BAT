@echo off
cd veci
copy /b            krystal1.scr + krystal2.scr + krystal3.scr  veci.scr
copy /b veci.scr + koruna1.scr  + koruna2.scr  + koruna3.scr   veci.scr
copy /b veci.scr + strom1.scr   + strom2.scr   + strom3.scr    veci.scr
copy /b veci.scr + jablko1.scr  + jablko2.scr  + jablko3.scr   veci.scr
copy /b veci.scr + krava1.scr   + krava2.scr   + krava3.scr    veci.scr
copy /b veci.scr + tresne1.scr  + tresne2.scr  + tresne3.scr   veci.scr
copy /b veci.scr + rybnik1.scr  + rybnik2.scr  + rybnik3.scr   veci.scr
copy /b veci.scr + zirafa1.scr  + zirafa2.scr  + zirafa3.scr   veci.scr
copy /b veci.scr + zmrzlin1.scr + zmrzlin2.scr + zmrzlin3.scr  veci.scr
copy /b veci.scr + dort1.scr    + dort2.scr    + dort3.scr     veci.scr
copy /b veci.scr + pocitac1.scr + pocitac2.scr + pocitac3.scr  veci.scr
copy /b veci.scr + auto1.scr    + auto2.scr    + auto3.scr     veci.scr
copy /b veci.scr + balon1.scr   + balon2.scr   + balon3.scr    veci.scr
copy /b veci.scr + budik1.scr   + budik2.scr   + budik3.scr    veci.scr
copy /b veci.scr + slon1.scr    + slon2.scr    + slon3.scr     veci.scr
copy /b veci.scr + vino1.scr    + vino2.scr    + vino3.scr     veci.scr
copy /b veci.scr + penize1.scr  + penize2.scr  + penize3.scr   veci.scr
copy /b veci.scr + letadlo1.scr + letadlo2.scr + letadlo3.scr  veci.scr
copy veci.scr ..\veci.scr
del veci.scr
cd ..
