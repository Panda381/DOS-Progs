Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   mov       ah,0fh
         int       10h                      ; poskytnutก videomขdu
         mov       bx,0b000h
         cmp       al,7
         je        Start2
         mov       bh,0b8h
         cmp       al,1
         jbe       Konec
         cmp       al,3
         ja        Konec
Start2:  xor       di,di
         mov       es,bx
         mov       si,offset Obraz
         mov       cx,80*12
         cld
         mov       ah,7
Start3:  lodsb
         stosw
         loop      Start3

         mov       al," "
         mov       cx,(25-12)*80
         rep       stosw

         xor       bx,bx
         mov       dx,12*256
         mov       ah,2
         int       10h                      ; nastavenก kurzoru

Konec:   int       20h

Obraz    label     byte
         db        'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป'
         db        'บ                                                                              บ'
         db        'บ    ÛÛÛÛÛฒฑฐ  ÛÛÛÛÛÛÛฒฑฐ ÛÛÛฒฑฐ  ÛÛÛฒฑฐ    ÛÛÛÛฒฑฐ                            บ'
         db        'บ   ÛÛฒฑฐÛÛฒฑฐ ÛÛฒฑฐ      ÛÛÛÛฒฑฐÛÛÛÛฒฑฐ   ÛÛฒฑÛÛฒฑฐ                           บ'
         db        'บ  ÛÛฒฑฐ       ÛÛฒฑฐ      ÛÛฒÛÛฒÛÛฒÛÛฒฑฐ  ÛÛฒฑฐ ÛÛฒฑฐ  ÜÛÛÛÛ         ÜÛÛ  ÜÛ   บ'
         db        'บ  ÛÛฒฑฐ       ÛÛÛÛฒฑฐ    ÛÛฒฑÛÛÛฒฑÛÛฒฑฐ ÛÛฒฑฐ   ÛÛฒฑฐ ÛÛ            ÛÛ   ÛÛ   บ'
         db        'บ  ÛÛฒฑฐÛÛÛฒฑฐ ÛÛฒฑฐ      ÛÛฒฑฐ    ÛÛฒฑฐ ÛÛÛÛÛÛÛÛÛÛฒฑฐ ฿ÛÛÛÜ ÜÛÛÛÛÜ ÛÛÛÛ ÛÛÛÛ  บ'
         db        'บ   ÛÛฒฑฐÛÛฒฑฐ ÛÛฒฑฐ      ÛÛฒฑฐ    ÛÛฒฑฐ ÛÛฒฑฐ   ÛÛฒฑฐ    ÛÛ ÛÛ  ÛÛ  ÛÛ   ÛÛ   บ'
         db        'บ    ÛÛÛÛÛฒฑฐ  ÛÛÛÛÛÛÛฒฑฐ ÛÛฒฑฐ    ÛÛฒฑฐ ÛÛฒฑฐ   ÛÛฒฑฐ ÛÛÛÛ฿ ฿ÛÛÛÛ฿  ÛÛ   ฿ÛÛ  บ'
         db        'บ                                                                              บ'
         db        'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ'
         db        '                              zav dก se program...                              '

Code     ENDS
         END       Start
