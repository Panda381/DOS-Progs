COMMENT %

 Driver pro obsluhu tisk rny K6314 s ‡esk˜m fontem znak–

%
code     SEGMENT   page
         ASSUME    cs:code,ds:code

         org       100h

start:
         jmp       init
adrprt   dd        0                        ; adresa driveru tisk rny

                                            ; p©evodn¡ tabulka
tabulka  db        24h,14,24h,15,0
         db        127,0
         db        128,14,63h,15,0
         db        129,14,48h,15,0
         db        130,14,57h,15,0
         db        131,14,44h,15,0
         db        132,14,51h,15,0
         db        133,14,64h,15,0
         db        134,14,74h,15,0
         db        135,14,43h,15,0
         db        136,14,45h,15,0
         db        137,14,65h,15,0
         db        138,14,6bh,15,0
         db        139,14,69h,15,0
         db        140,14,4ch,15,0
         db        141,14,4bh,15,0
         db        142,14,71h,15,0
         db        143,14,61h,15,0
         db        144,14,77h,15,0
         db        145,14,5ah,15,0
         db        146,14,7ah,15,0
         db        147,14,50h,15,0
         db        148,14,4dh,15,0
         db        149,14,6fh,15,0
         db        150,14,4ah,15,0
         db        151,14,75h,15,0
         db        152,14,59h,15,0
         db        153,14,6dh,15,0
         db        154,14,68h,15,0
         db        155,14,73h,15,0
         db        156,14,6ch,15,0
         db        157,14,79h,15,0
         db        158,14,72h,15,0
         db        159,14,54h,15,0
         db        160,14,41h,15,0
         db        161,14,49h,15,0
         db        162,14,4fh,15,0
         db        163,14,55h,15,0
         db        164,14,4eh,15,0
         db        165,14,6eh,15,0
         db        166,14,6ah,15,0
         db        167,14,70h,15,0
         db        168,14,53h,15,0
         db        169,14,52h,15,0
         db        170,14,46h,15,0
         db        171,14,66h,15,0
         db        172,27,"S",2,"1",8,27,"S",1,"4",27,"T",0
         db        173,"i",0
         db        174,"<",0
         db        175,">",0
         db        176,22h,0
         db        177,"#",0
         db        178,14,22h,15,0
         db        179,"|",0
         db        180,"+",0
         db        181,"+",0
         db        182,"+",0
         db        183,"+",0
         db        184,"+",0
         db        185,"+",0
         db        186,"|",0
         db        187,"+",0
         db        188,"+",0
         db        189,"+",0
         db        190,"+",0
         db        191,"+",0
         db        192,"+",0
         db        193,"+",0
         db        194,"+",0
         db        195,"+",0
         db        196,"-",0
         db        197,"+",0
         db        198,"+",0
         db        199,"+",0
         db        200,"+",0
         db        201,"+",0
         db        202,"+",0
         db        203,"+",0
         db        204,"+",0
         db        205,"-",0
         db        206,"+",0
         db        207,"+",0
         db        208,"+",0
         db        209,"+",0
         db        210,"+",0
         db        211,"+",0
         db        212,"+",0
         db        213,"+",0
         db        214,"+",0
         db        215,"+",0
         db        216,"+",0
         db        217,"+",0
         db        218,"+",0
         db        219,14,22h,15,0
         db        220,14,3fh,15,0
         db        221,14,3dh,15,0
         db        222,14,3ch,15,0
         db        223,14,3eh,15,0
         db        224,32,0
         db        225,14,5fh,15,0
         db        226,32,0
         db        227,14,7bh,15,0
         db        228,32,0
         db        229,32,0
         db        230,14,5bh,15,0
         db        231,32,0
         db        232,"O",8,"|",0
         db        233,"O",8,"-",0
         db        234,14,7ch,15,0
         db        235,32,0
         db        236,32,0
         db        237,"O",8,"/",0
         db        238,32,0
         db        239,32,0
         db        240,"=",8,5fh,0
         db        241,"+",8,5fh,0
         db        242,">",8,5fh,0
         db        243,"<",8,5fh,0
         db        244,32,0
         db        245,32,0
         db        246,":",8,"-",0
         db        247,32,0
         db        248,14,27h,15,0
         db        249,2eh,0
         db        250,2eh,0
         db        251,32,0
         db        252,27,"S",2,"n",27,"T",0
         db        253,27,"S",2,"2",27,"T",0
         db        254,14,21h,15,0
         db        255,32,0
         db        0

escape   db        0                        ; ‡¡ta‡ znak– ESC
citac    dw        0                        ; ‡¡ta‡ grafick˜ch znak–

pozice   db        0

zac:                                        ; program obsluhy tisk rny
         cmp       ah,0
         jnz       vyst2
         cmp       dx,0
         jnz       vyst2
         cmp       cs:[escape],0
         jnz       zac2
         cmp       cs:[citac],0
         jz        zac2
         dec       cs:[citac]
vyst2:   jmp       vystup
zac2:    cmp       cs:[escape],5
         jz        zac12
         cmp       cs:[escape],4            ; je p t˜ bajt grafiky
         jnz       zac3
         mov       byte ptr cs:[citac+1],al
zac12:   mov       cs:[escape],0
         jmp       short vyst2
zac3:    cmp       cs:[escape],3            ; je ‡tvrt˜ bajt grafiky
         jnz       zac4
         mov       byte ptr cs:[citac],al
         mov       cs:[escape],4
         jmp       short vyst2
zac4:    cmp       cs:[escape],2            ; je t©et¡ bajt grafiky
         jnz       zac5
         mov       cs:[escape],3
         jmp       short vyst2
zac5:    cmp       cs:[escape],1            ; je druh˜ bajt grafiky
         jnz       zac6
         cmp       al,"K"
         jz        zac7                     ; grafika 480 b/8"
         cmp       al,"L"
         jz        zac7                     ; grafika 960 b/8"
         cmp       al,"Y"
         jz        zac7                     ; grafika 960 b/8"
         cmp       al,"Z"
         jz        zac7                     ; grafika 1920 b/8"
         cmp       al,"*"
         jz        zac9
         cmp       al,"S"
         jz        zac10
         cmp       al,"W"
         jz        zac10
         cmp       al,"!"
         jz        zac10
         cmp       al,"-"
         jz        zac10
         cmp       al,"3"
         jz        zac10
         cmp       al,"A"
         jz        zac10
         cmp       al,"J"
         jz        zac10
         cmp       al,"j"
         jz        zac10
         cmp       al,"N"
         jz        zac10
         cmp       al,"B"
         jz        zac10
         cmp       al,"C"
         jz        zac10
         cmp       al,"Q"
         jz        zac10
         cmp       al,"R"
         jz        zac10
         cmp       al,"U"
         jz        zac10
         cmp       al,"x"
         jnz       vyst3
zac10:   mov       cs:[escape],5
         jmp       vyst2
zac9:    mov       cs:[escape],2
         jmp       vyst2
zac7:    mov       cs:[escape],3
         jmp       vyst2
zac6:    cmp       al,1bh
         jnz       zac8
         mov       cs:[escape],1
         jmp       vyst2

vyst3:   mov       cs:[escape],0
         jmp       vyst2

zac8:    push      bx
         mov       bx,offset cs:tabulka
hledej:  cmp       byte ptr cs:[bx],0
         jz        vyst                     ; neni znak v tabulce
         cmp       byte ptr cs:[bx],al      ; je hledan˜ znak ?
         jz        prevod                   ; znak nalezen

dalsi:   inc       bx
         cmp       byte ptr cs:[bx],0
         jnz       dalsi
         inc       bx
         jmp       short hledej
prevod:  inc       bx
         mov       al,byte ptr cs:[bx]
         cmp       al,0
         jz        kon
         mov       ah,0
         call      tisk
         jmp       short prevod
kon:     pop       bx
         iret


vyst:    pop       bx

vystup:
         call      tisk
         iret

tisk:    pushf                              ; tisk jednoho znaku
         call      dword ptr cs:[adrprt]
         ret





init:    push      cs
         pop       ds
         mov       ax,3517h                 ; p©e‡ten¡ vektoru p©eru¨en¡ 17h
         int       21h
         cmp       bx,offset zac            ; obsluha tisk rny
         je        nainst                   ; hl ¨en¡, ‘e je ji‘ nainstalov n
         mov       word ptr [adrprt],bx     ; nastaven¡ vektoru p©eru¨en¡ tisk rny
         mov       word ptr [adrprt+2],es
         mov       dx,offset zac
         mov       ax,2517h
         int       21h                      ; nastaven¡ nov‚ adresy p©eru¨en¡
         mov       dx,offset text           ; uvodn¡ text
         mov       ah,9
         int       21h                      ; tisk £vodn¡ho textu
         mov       dx,word ptr konec-start + 200h ; d‚lka programu
         int       27h                      ; ukon‡en¡ programu jako rezidentn¡

nainst:  mov       dx,offset text2
         mov       ah,9
         int       21h
         mov       ah,4ch
         int       21h

text     db        'Driver pro tisk rnu K6314 byl nainstalov n.'
         db        13,10,'$'

text2    db        'Driver pro tisk rnu K6314 je ji‘ nainstalov n v pamˆti !'
         db        13,10,'$'

         db        100 dup (0)
konec:

code     ENDS

stack    SEGMENT   stack
         DW        256 DUP(?)               ; z sobn¡k 256 slov
stack    ENDS


         END       start                    ; startovac¡ adresa
