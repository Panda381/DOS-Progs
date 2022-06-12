COMMENT %

 Driver pro obsluhu tisk rny FR-15 ‡esk˜m fontem znak– V 1.1

%
code     SEGMENT   page
         ASSUME    cs:code,ds:code

         org       100h

start:
         jmp       init
adrprt   dd        0                        ; adresa driveru tisk rny

                                            ; p©evodn¡ tabulka
tabulka  db        128,"C",8,"'",8,"`",0
         db        131,"d",8,"`",0
         db        133,"D",8,"'",8,"`",0
         db        134,"T",8,"'",8,"`",0
         db        135,"c",8,34,0
         db        136,"e",8,34,0
         db        137,"E",8,"'",8,"`",0
         db        138,"L",8,"'",0
         db        139,"I",8,"`",0
         db        140,"l",8,"'",8,"`",0
         db        141,"l",8,"`",0
         db        143,"A",8,34,0
         db        145,"z",8,34,0
         db        146,"Z",8,"`",8,"'",0
         db        150,"u",8,248,0
         db        151,"U",8,"'",0
         db        152,"y",8,"'",0
         db        155,"S",8,"'",8,"`",0
         db        156,"L",8,"'",8,"`",0
         db        157,"Y",8,"'",0
         db        158,"R",8,"'",8,"`",0
         db        159,"t",8,"'",0
         db        164,"n",8,34,0
         db        165,"N",8,"'",8,"`",0
         db        166,"U",8,248,0
         db        167,"O",8,"^",0
         db        168,"s",8,34,0
         db        169,"r",8,34,0
         db        170,"r",8,"'",0
         db        171,"R",8,"'",0
         db        173,21,0
         db        0

escape   db        0                        ; ‡¡ta‡ znak– ESC
citac    dw        0                        ; ‡¡ta‡ grafick˜ch znak–

pozice   db        0

paroff   db        1                        ; parametr zapnut¡ emul toru

zac:                                        ; program obsluhy tisk rny
         cmp       cs:[paroff],0            ; parametr zapnut¡ emul toru
         jz        vyst2                    ; nen¡ zapnut
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





init:
         mov       ax,3517h                 ; p©e‡ten¡ vektoru p©eru¨en¡ 17h
         int       21h
         mov       al,ds:[80h]              ; po‡et znak– parametr–
         push      cs
         pop       ds
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

nainst:
         cmp       al,0                     ; je nˆjak˜ znak ?
         mov       al,0
         jnz       nainst2                  ; je znak - vypnut¡
         inc       al                       ; al = 1
nainst2: mov       es:[bx-1],al             ; nastaven¡ emul toru
         push      ax
         mov       dx,offset text2
         mov       ah,9
         int       21h
         pop       ax
         cmp       al,0
         mov       dx,offset textzap
         jnz       nainst3
         mov       dx,offset textvyp
nainst3: mov       ah,9
         int       21h
         mov       ah,4ch
         int       21h

text     db        'Driver pro tisk rnu FR-15 V1.1 byl nainstalov n.'
         db        13,10,'$'

text2    db        'Driver pro tisk rnu FR-15 byl $'

textzap  db        'ZAPNUT.'
         db        13,10,'$'

textvyp  db        'VYPNUT'
         db        13,10,'$'

         db        100 dup (0)
konec:

code     ENDS

stack    SEGMENT   stack
         DW        256 DUP(?)               ; z sobn¡k 256 slov
stack    ENDS


         END       start                    ; startovac¡ adresa
