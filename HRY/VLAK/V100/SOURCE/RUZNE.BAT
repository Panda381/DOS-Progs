@echo off
cd ruzne
copy /b             lokomot1.scr + lokomot2.scr + lokomot3.scr + lokomot4.scr  ruzne.scr
copy /b ruzne.scr + lokomot5.scr + lokomot6.scr + lokomot7.scr + lokomot8.scr  ruzne.scr
copy /b ruzne.scr + lokomot9.scr + lokomotA.scr + lokomotB.scr + lokomotC.scr  ruzne.scr
copy /b ruzne.scr + srazka1.scr  + srazka2.scr  + srazka3.scr  + srazka4.scr   ruzne.scr
copy /b ruzne.scr + srazka5.scr  + srazka6.scr  + srazka7.scr  + srazka8.scr   ruzne.scr
copy /b ruzne.scr + srazka9.scr  + srazkaA.scr                                 ruzne.scr

rem copy /b ruzne.scr + zed∫.scr     + zedÕ.scr     + zed .scr     + zedÀ.scr      ruzne.scr
rem copy /b ruzne.scr + zedÃ.scr     + zedπ.scr     + zedº.scr     + zed….scr      ruzne.scr
rem copy /b ruzne.scr + zed».scr     + zedª.scr     + vrata1.scr   + vrata2.scr    ruzne.scr

copy /b ruzne.scr + zed.scr      + vrata1.scr   + vrata2.scr    ruzne.scr
copy /b ruzne.scr + vrata3.scr   + vrata4.scr   + vrata5.scr   + vrata6.scr    ruzne.scr
copy ruzne.scr ..\ruzne.scr
del ruzne.scr
cd ..
