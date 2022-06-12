
INCLUDE  KDEF.ASM

Code     SEGMENT   BYTE PUBLIC
         ASSUME    cs:Code, ds:Data

; -----------------------------------------------------------------------------
;        zaokrouhlen° á°sla v bufferu (AL=poáet á°slic v bufferu, CL=dekad. ©†d)
; -----------------------------------------------------------------------------

l_2080   PROC      NEAR

; ------ rozli®en° posledn° á°slice, zda se zaokrouhl° nahoru nebo dolñ

         xor       ah,ah                    ; AH <- 0
         mov       bx,offset d_0226         ; buffer k dek¢dov†n° mantisy á°sla
         add       bx,ax                    ; adresa posledn° á°slice
         cmp       byte ptr [bx],"5"        ; je posledn° á°slice "5" ?
         mov       byte ptr [bx],0          ; zru®en° posledn° á°slice
         jb        l_20A9                   ; men®° neë "5" - nezaokrouhl° se

; ------ zaokrouhlen° p©edposledn° á°slice nahoru

l_208F:  dec       al                       ; sn°ëen° ukazatele á°slic
         js        l_20A0                   ; nen° dal®° á°slice
         dec       bx                       ; sn°ëen° ukazatele á°slic
         inc       byte ptr [bx]            ; zvò®en° á°sla-zaokrouhlen° nahoru
         cmp       byte ptr [bx],"9"+1      ; je p©enos p©es "9" ?
         jb        l_20A9                   ; nen° p©enos p©es "9"
         mov       byte ptr [bx],0          ; zru®en° á°slice (je to "0")
         jmp       short l_208F             ; zvò®en° dal®° á°slice

; ------ p©i p©eteáen° bude á°slo "1" a zvò®° se ©†d

l_20A0:  mov       byte ptr [bx],"1"        ; p©eteáen° na á°slo "1"
         mov       byte ptr [bx+1],0        ; oznaáen° konce textu
         inc       cl                       ; zvò®en° ukazatele ©†du
l_20A9:  ret

l_2080   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_20AA   PROC      NEAR

; ------ p©eskoáen° znamÇnka "-" na zaá†tku á°sla

         mov       cl,[bx]
         cmp       cl,"-"
         jne       l_20B2
         inc       bx


l_20B2:  push      cx
         call      l_20C9
         pop       cx
         jc        l_20C8
         cmp       cl,2Dh             ; '-'
         jne       l_20C7
         cmp       byte ptr [di],0
         je        l_20C7
         xor       byte ptr [di+5],80h
l_20C7:  clc
l_20C8:  ret

l_20AA   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_20C9   PROC      NEAR

         mov       si,bx
         xor       ax,ax
         xor       bx,bx
         xor       dx,dx
         xor       cx,cx
         mov       byte ptr ds:[d_0225],0

; ------ naáten° znaku z bufferu a jeho p©evod na velkÇ p°smeno

l_20D8:  mov       cl,[si]
         cmp       cl,"a"
         jb        l_20E7
         cmp       cl,"z"
         ja        l_20E7
         sub       cl,32


l_20E7:  call      l_218F
         jc        l_2112
         call      l_2225
         jc        l_2123
         push      di
         push      si
         push      cx
         push      dx
         push      bx
         push      ax
         mov       al,cl
         xor       ah,ah
         call      l_18BB
         pop       cx
         pop       si
         pop       di
         call      l_162F
         pop       cx
         pop       si
         pop       di
         test      ch,40h             ; '@'
         jz        l_2120
         dec       byte ptr ds:[d_0225]
         jmp       short l_2120
l_2112:  cmp       cl,2Eh             ; '.'
         jne       l_2126
         test      ch,40h             ; '@'
         stc       
         jnz       l_2123
         or        ch,40h             ; '@'
l_2120:  inc       si
         jmp       short l_20D8
l_2123:  mov       bx,si
         ret

l_2126:  cmp       cl,45h             ; 'E'
         mov       cl,ds:[d_0225]
         jnz       l_216A
         call      l_2177
         jc        l_2123
         inc       si
         mov       cl,[si]
         cmp       cl,2Bh             ; '+'
         je        l_2144
         cmp       cl,2Dh             ; '-'
         jne       l_2145
         or        ch,20h             ; ' '
l_2144:  inc       si
l_2145:  call      l_218D                   ; naáten° dekad. á°slice z bufferu
         jc        l_2123
         push      ax
         mov       al,cl
         inc       si
         call      l_218D                   ; naáten° dekad. á°slice z bufferu
         jc        l_2160
         mov       ah,al
         shl       al,1
         shl       al,1
         add       al,ah
         shl       al,1
         add       al,cl
         inc       si
l_2160:  mov       cl,al
         pop       ax
         test      ch,20h             ; ' '
         jz        l_216A
         neg       cl
l_216A:  call      l_2177
         mov       [di],ax
         mov       [di+2],bx
         mov       [di+4],dx
         jmp       short l_2123

l_20C9   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2177   PROC      NEAR

         cmp       cl,0DAh
         jl        l_218B
         cmp       cl,26h             ; '&'
         jg        l_218B
         push      cx
         push      si
         push      di
         call      l_219E
         pop       di
         pop       si
         pop       cx
         ret

l_218B:  stc
         ret

l_2177   ENDP

; -----------------------------------------------------------------------------
;        naáten° dekadickÇ á°slice z bufferu
; -----------------------------------------------------------------------------

l_218D   PROC      NEAR

         mov       cl,[si]                  ; znak z bufferu
l_218F:  cmp       cl,"0"                   ; je to platn† á°slice >= "0" ?
         jb        l_219D                   ; nen° to platn† á°slice
         cmp       cl,"9"+1                 ; je to platn† á°slice <= "9" ?
         cmc
         jc        l_219D                   ; nen° to platn† á°slice
         sub       cl,"0"                   ; korekce na á°slo
l_219D:  ret

l_218D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_219E   PROC      NEAR

         push      dx
         push      bx
         push      ax
         mov       ds:[d_0224],cl
         or        cl,cl
         jns       l_21AB
         neg       cl
l_21AB:  mov       bl,cl
         and       bl,0FCh
         mov       bh,bl
         shr       bl,1
         add       bl,bh
         xor       bh,bh
         lea       di,[bx+21E9h]
         mov       ax,cs:[di]
         mov       bx,cs:[di+2]
         mov       dx,cs:[di+4]
         and       cl,3
         jz        l_21D3
l_21CC:  call      l_2225
         dec       cl
         jnz       l_21CC
l_21D3:  mov       cx,ax
         mov       si,bx
         mov       di,dx
         pop       ax
         pop       bx
         pop       dx
         test      byte ptr ds:[d_0224],80h
         jnz       l_21E6
         jmp       l_1722
l_21E6:  jmp       l_179C

l_219E   ENDP

l_21E9   db        81h,0,0,0,0,0,8Eh,0,0,0,40h,1Ch,9Bh,0,0,20h
l_21F9   db        0BCh,3Eh,0A8h,0,10h,0A5h,0D4h,68h,0B6h,4,0BFh,0C9h,1Bh,0Eh,0C3h,0ACh
l_2209   db        0C5h,0EBh,78h,2Dh,0D0h,0CDh,0CEh,1Bh,0C2h,53h,0DEh,0F9h,78h,39h,3Fh,1
l_2219   db        0EBh,2Bh,0A8h,0ADh,0C5h,1Dh,0F8h,0C9h,7Bh,0CEh,97h,40h

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2225   PROC      NEAR

         or        al,al
         jnz       l_222A
         ret

l_222A:  or        dh,80h
         push      cx
         push      dx
         push      bx
         push      ax
                                          ;* vydàlen° / 2
         shr       dx,1
         rcr       bx,1
         rcr       ah,1                     ; á°slo / 2
                                          ;* vydàlen° / 2
         shr       dx,1
         rcr       bx,1
         rcr       ah,1                     ; á°slo / 4
                                          ;* p©iáten° pñvodn°ho á°sla
         pop       cx
         add       ah,ch
         pop       cx
         adc       bx,cx
         pop       cx
         adc       dx,cx                    ; á°slo * 1.25

         pop       cx
         jnc       l_2255
         rcr       dx,1
         rcr       bx,1
         rcr       ah,1
         inc       al
         jnz       l_2255
         stc       
         ret

l_2255:  and       dh,7Fh
         add       al,3
         ret

l_2225   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_225B   PROC      NEAR

         pop       si
         pop       di
         pop       dx
         pop       cx
         pop       bx
         push      di
         push      si
         test      bh,80h
         jnz       l_2285
         or        bh,80h
         mov       al,0A0h
         sub       al,dl
         jc        l_228A
         cmp       al,20h             ; ' '
         jae       l_2285
l_2274:  or        al,al
         jz        l_2280
         shr       bx,1
         rcr       cx,1
         dec       al
         jmp       short l_2274

l_2280:  mov       ax,cx
         mov       dx,bx
         ret

l_2285:  xor       ax,ax
         xor       dx,dx
         ret

l_228A:  mov       ax,0FFFFh
         mov       dx,0FFFFh
         ret

l_225B   ENDP

; -----------------------------------------------------------------------------
;        p©°prava jmÇna souboru k operaci
; -----------------------------------------------------------------------------

l_2291   PROC      NEAR

         mov       bx,dx
         mov       cx,ax
         or        ax,dx
         jz        l_22AC
         mov       dx,0A0h
l_229C:  test      bh,80h
         jnz       l_22A9
         shl       cx,1
         rcl       bx,1
         dec       dl
         jmp       short l_229C

l_22A9:  and       bh,7Fh
l_22AC:  pop       ax
         push      bx
         push      cx
         push      dx
         jmp       ax

; ------ p©°prava jmÇna souboru k vytvo©en°

l_22B2:  mov       al,1
l_22B4:  mov       byte ptr ds:[d_0238],al  ; bit 0:1=vytvo©en°/0=otev©en° soub.
         pop       bx
         call      l_0EC7                   ; p©enos ©etàzce ze z†sob.do bufferu
         pop       di
         pop       es
         push      bx
         mov       ax,es
         mov       dx,ds
         cmp       ax,dx
         jne       l_22CC
         cmp       di,offset d_0166
         jbe       l_2301
l_22CC:  push      di
         mov       si,offset d_00B6
         lea       di,[di+0Ch]
         mov       cx,20h
         cld       
         rep       movsw
         pop       di
         call      l_241C                   ; test, zda je standardn° za©°zen°
         jnc       l_22E4
         mov       al,0
         mov       bx,0FFFFh
l_22E4:  mov       es:[di],bx
         cmp       byte ptr ds:[d_0238],0   ; bit 0:1=vytvo©en°/0=otev©en° soub.
         je        l_22FA
         mov       es:[di+2],al
         lea       ax,[di+4Ch]
         mov       es:[di+4],ax
         ret

l_22FA:  mov       word ptr es:[di+2],0
         ret

l_2301:  mov       byte ptr ds:[d_0180],22h
         ret

l_2291   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2307   PROC      NEAR

         xor       al,al
         jmp       short l_2311

l_2307   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_230B   PROC      NEAR

         mov       al,1
         jmp       short l_2311

l_230B   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_230F   PROC      NEAR

         mov       al,2
l_2311:  mov       byte ptr ds:[d_0238],al  ; bit 0:1=vytvo©en°/0=otev©en° soub.
         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       al,es:[di+2]
         and       al,0Fh
         jnz       l_2398
         mov       es:[di+6],cx
         call      l_23ED
         cmp       byte ptr ds:[d_0180],0   ; n†vrat. k¢d chyby diskovÇ operace
         jne       l_239D                   
         call      l_2486                   ; vytvo©en°/otev©en° souboru
         cmp       byte ptr ds:[d_0180],0   ; n†vrat. k¢d chyby diskovÇ operace
         jne       l_239D                   

; ------ test, zda je to za©°zen° nebo soubor

         test      word ptr ds:[d_0172],2   ; pracuje se se sluëbami 44h ?
         jz        l_235A                   ; nejsou povoleny sluëby 44h
         mov       ax,4400h                 ; funkce poskytnut° informac° o za©.
         mov       bx,es:[di]               ; identifik†tor za©°zen°
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         test      dx,80h                   ; jedn† se o znakovÇ za©°zen° ?
         jz        l_235A                   ; je to blokovÇ za©°zen°
         mov       word ptr es:[di+6],1     ; nastaven° p©°znaku znakovÇho za©.

; ------

l_235A:  cmp       byte ptr ds:[d_0238],1   ; bit 0:1=vytvo©en°/0=otev©en° soub.
         jae       l_2373                   ; je p©°kaz 2
         mov       byte ptr es:[di+2],80h
         mov       bx,es:[di+4]
         mov       es:[di+8],bx
         mov       es:[di+10],bx
         ret

; ------ p©em°stàn° ukazatele na konec souboru

l_2373:  jz        l_2382                   ; je p©°kaz 1
                                            ; je p©°kaz 0 - ukazatel na konec s.
         mov       ax,4202h                 ; p©em°stàn° ukazatele souboru
         mov       bx,es:[di]               ; identifik†tor souboru
         xor       cx,cx                    ; offset 0 od konce souboru
         xor       dx,dx                    ; offset 0 od konce souboru
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)

; ------

l_2382:  mov       byte ptr es:[di+2],40h           ; '@'
         mov       ax,es:[di+4]
         mov       es:[di+8],ax
         add       ax,es:[di+6]
         mov       es:[di+10],ax
         ret

l_2398:  and       byte ptr es:[di+2],0DFh
l_239D:  ret

l_230F   ENDP

; -----------------------------------------------------------------------------
;        o©ez†n° konce souboru (NEPOUíãVè SE !)
; -----------------------------------------------------------------------------

l_239E   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es                       ; segment definice souboru
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         cmp       byte ptr es:[di+2],80h
         jne       l_239D

; ------ p©esun zpàt od souáasnÇ pozice

         mov       dx,es:[di+8]             ; souáasnò ukazatel
         sub       dx,es:[di+10]            ; velikost souboru
         jz        l_23C4                   ; ukazatel je na konci souboru
         mov       ax,4201h                 ; povel - p©esun zpàt
         mov       bx,es:[di]               ; identifik†tor souboru
         mov       cx,0FFFFh                ; p©esun zpàt
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)

; ------ o©ez†n° konce souboru

l_23C4:  mov       ah,40h                   ; sluëba - z†pis do souboru
         mov       bx,es:[di]               ; identifik†tor souboru
         xor       cx,cx                    ; ë†dnò bajt - o©ez†n° souboru
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         jmp       short l_2382

l_239E   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_23D0   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_23D9:  cmp       byte ptr es:[di+2],40h
         jne       l_23E3
         jmp       l_27EF
l_23E3:  ret

l_23D0   ENDP

; -----------------------------------------------------------------------------
;        uzav©en° souboru
; -----------------------------------------------------------------------------

l_23E4   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_23ED:  mov       al,es:[di+2]
         and       al,0Fh
         jnz       l_241B
         call      l_23D9
         mov       byte ptr es:[di+2],0

; ------ uzav©en° souboru

l_23FD:  mov       bx,es:[di]               ; identifik†tor za©°zen°
         cmp       bx,2                     ; je standardn° za©°zen° ?
         jbe       l_241B                   ; standardn° za©°zen° se neuzav°r†
         cmp       bx,0FFFFh                ; je soubor jië uzav©en ?
         je        l_241B                   ; soubor je jië uzav©en
         mov       word ptr es:[di],0FFFFh  ; oznaáen°, ëe soubor je uzav©en
         mov       ah,3Eh                   ; funkce - uzav©en° souboru
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         jnc       l_241B                   ; soubor uzav©en OK
         mov       byte ptr ds:[d_0180],0FFh ; p©°znak chyby uzav©en° souboru
l_241B:  ret

l_23E4   ENDP

; -----------------------------------------------------------------------------
;        test, zda se jedn† o standardn° za©°zen° (CY=nen° stand. za©°zen°)
; -----------------------------------------------------------------------------

l_241C   PROC      NEAR

         mov       cx,9                     ; poáet za©°zen° v tabulce
         mov       bx,offset l_2450         ; tabulka jmen za©°zen°
l_2422:  push      cx                       ; £schova á°taáe za©°zen°
         push      bx                       ; £schova ukazatele za©°zen°
         mov       si,offset d_00B6         ; ©etàzec p©°stupovÇ cesty k soub.
         mov       cx,3                     ; dÇlka jmÇna za©°zen°
l_242A:  mov       al,[si]                  ; znak ©etàzce p©°stup. cesty
         call      l_0A81                   ; p©evod na velkÇ p°smeno v AL
         cmp       al,cs:[bx]               ; je za©°zen° ?
         je        l_243D                   ; je - dal®° znak
         pop       bx                       ; nen° - dal®° za©°zen°
         pop       cx                       ; á°taá za©°zen° v tabulce
         add       bx,6                     ; adresa dal®°ho za©°zen°
         loop      l_2422                   ; test dal®°ho za©°zen°
l_243B:  stc                                ; chyba - za©°zen° nenalezeno
         ret                                

l_243D:  inc       si                       ; zvò®en° adresy ©etàzce
         inc       bx                       ; zvò®en° ukazatele znakñ
         loop      l_242A                   ; test dal®°ho znaku
         pop       cx                       ; zru®en° ukazatele znakñ
         pop       cx                       ; n†vrat á°taáe za©°zen°
         cmp       byte ptr [si],":"        ; n†sleduje oddàlovaá ":" ?
         jne       l_243B                   ; nen° oddàlovaá ":" - chyba
         mov       al,cs:[bx]               ; atribut za©°zen°
         mov       bx,cs:[bx+1]             ; identifik†tor za©°zen°
         ret

l_241C   ENDP

; ------ tabulka standardn°ch za©°zen°
                                          ;* konzola
l_2450               db     'CON'           ; jmÇno za©°zen°
                     db     0c1h            ; atribut za©°zen°
                     dw     0ffffh          ; identifik†tor za©°zen°
                                          ;* termin†l
l_2456               db     'TRM'           ; jmÇno za©°zen°
                     db     0c1h            ; atribut za©°zen°
                     dw     0ffffh          ; identifik†tor za©°zen°
                                          ;* kl†vesnice
l_245C               db     'KBD'           ; jmÇno za©°zen°
                     db     082h            ; atribut za©°zen°
                     dw     0ffffh          ; identifik†tor za©°zen°
                                          ;* vòpisovÇ za©°zen°
l_2462               db     'LST'           ; jmÇno za©°zen°
                     db     043h            ; atribut za©°zen°
                     dw     0ffffh          ; identifik†tor za©°zen°
                                          ;* p©°davnÇ za©°zen°
l_2468               db     'AUX'           ; jmÇno za©°zen°
                     db     0c4h            ; atribut za©°zen°
                     dw     0ffffh          ; identifik†tor za©°zen°
                                          ;* uëivatelskÇ za©°zen°
l_246E               db     'USR'           ; jmÇno za©°zen°
                     db     0c5h            ; atribut za©°zen°
                     dw     0ffffh          ; identifik†tor za©°zen°
                                          ;* vstupn° za©°zen°
l_2474               db     'INP'           ; jmÇno za©°zen°
                     db     0               ; atribut za©°zen°
                     dw     0               ; identifik†tor za©°zen°
                                          ;* vòstupn° za©°zen°
l_247A               db     'OUT'           ; jmÇno za©°zen°
                     db     0               ; atribut za©°zen°
                     dw     1               ; identifik†tor za©°zen°
                                          ;* chybovÇ za©°zen°
l_2480               db     'ERR'           ; jmÇno za©°zen°
                     db     0               ; atribut za©°zen°
                     dw     2               ; identifik†tor za©°zen°

; -----------------------------------------------------------------------------
;        vytvo©en°/otev©en° souboru
; -----------------------------------------------------------------------------

l_2486   PROC      NEAR

         cmp       word ptr es:[di],0FFFFh  ; je soubor jië otev©en ?
         jne       l_24B9                   ; soubor je jië otev©en
         mov       ax,3D02h                 ;
         mov       dl,1                     ; p©°znak chyby otev©en° souboru
         test      byte ptr ds:[d_0238],1   ; m† se soubor vytvo©it ?
         jz        l_249E                   ; soubor se m† jen otev©°t
         mov       ah,3Ch                   ; funkce vytvo©en° souboru
         xor       cx,cx                    ; atributy souboru
         mov       dl,0F1h                  ; p©°znak chyby vytvo©en° souboru
l_249E:  push      dx                       
         lea       dx,[di+12]               ; ukazatel jmÇna souboru
         call      l_093A                   ; otev©en°/vytvo©en° novÇho souboru
         pop       dx
         jc        l_24AC                   ; byla chyba otev©en° souboru
         mov       es:[di],ax               ; identifik†tor souboru
         ret                                

l_24AC:  mov       ds:[d_0180],dl           ; n†vrat. k¢d chyby diskovÇ operace
         cmp       al,4                     ; chyba-nen° volnò identifik†tor ?
         jne       l_24B9                   ; nen° chyba 04
         mov       byte ptr ds:[d_0180],0F3h ; chyba-nen° volnò identifik†tor
l_24B9:  ret

l_2486   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_24BA   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       word ptr ds:[d_0232],offset d_015A ; stand. vstup. za©°zen°
         mov       word ptr ds:[d_0232+2],ds
         jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_24BA   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_24CC   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         mov       word ptr ds:[d_0232],di  ; offset definice za©°zen°
         mov       word ptr ds:[d_0232+2],es
         test      byte ptr es:[di+2],80h
         jnz       l_24E5
         mov       byte ptr ds:[d_0180],2
l_24E5:  jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_24CC   ENDP

; -----------------------------------------------------------------------------
;        nastaven° standardn°ho vòstupn°ho za©°zen°
; -----------------------------------------------------------------------------

l_24E9   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       word ptr ds:[d_0232],offset d_0166 ; stand. vòstup. za©°zen°
         mov       word ptr ds:[d_0232+2],ds
         jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_24E9   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_24FB   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         mov       word ptr ds:[d_0232],di  ; adresa definice za©°zen°
         mov       word ptr ds:[d_0232+2],es
         test      byte ptr es:[di+2],40h
         jnz       l_2514
         mov       byte ptr ds:[d_0180],3
l_2514:  jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_24FB   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2518   PROC      NEAR

         mov       al,0FFh
         jmp       short l_251E

l_2518   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_251C   PROC      NEAR

         xor       al,al
l_251E:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       word ptr ds:[d_0232],offset d_015A ; stand. vstup. za©°zen°
         mov       word ptr ds:[d_0232+2],ds
         and       byte ptr ds:[d_015C],0DFh
         push      es
         push      di
         push      ax
         call      l_2545
         pop       ax
         or        al,al
         jz        l_253F
         call      l_0A7A
l_253F:  pop       di
         pop       es
         jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_251C   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2545   PROC      NEAR

         xor       dh,dh
l_2547:  mov       ch,ds:[d_0181]
         cmp       ch,7Eh
         jb        l_2552
         mov       ch,7Eh
l_2552:  mov       byte ptr ds:[d_0181],7Eh
         mov       bx,36h
         mov       ds:[d_0182],bx
l_255E:  xor       cl,cl
l_2560:  call      l_0A56
         mov       dl,1
         cmp       al,8
         je        l_25A2
         cmp       al,7Fh
         je        l_25A2
         cmp       al,4
         je        l_25B4
         dec       dl
         cmp       al,18h
         je        l_25A2
         cmp       al,1Bh
         je        l_25A2
         cmp       al,12h
         je        l_25B4
         cmp       al,1Ah
         je        l_25C6
         cmp       al,0Dh
         je        l_25CC
         cmp       al,20h             ; ' '
         jb        l_2560
         cmp       cl,ch
         je        l_2560
         mov       ah,[bx]
         mov       [bx],al
         inc       cl
         inc       bx
         cmp       ah,20h             ; ' '
         jae       l_259D
         mov       [bx],ah
l_259D:  call      l_0A44
         jmp       short l_2560

l_25A2:  dec       cl
         js        l_255E
         call      l_0A62
         or        [bx+si],ah
         or        [bx+si],al
         dec       bx
         dec       dl
         jnz       l_25A2
         jmp       short l_2560

l_25B4:  mov       al,[bx]
         cmp       al,20h
         jb        l_2560
         call      l_0A44
         inc       cl
         inc       bx
         dec       dl
         jnz       l_25B4
         jmp       short l_2560

l_25C6:  or        dh,dh
         jz        l_2560
         jmp       short l_25D0

l_25CC:  or        dh,dh
         jnz       l_25D5
l_25D0:  mov       byte ptr [bx],1Ah
         jmp       short l_25DD

l_25D5:  call      l_0A7A
         mov       word ptr [bx],0A0Dh
         inc       bx
l_25DD:  inc       bx
         mov       ds:[d_0184],bx
         ret

l_2545   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_25E3   PROC      NEAR

         les       di,dword ptr ds:[d_0232] ; adresa definice stand. za©°zen°
l_25E7:  cmp       byte ptr ds:[d_0180],0
         jne       l_2663
         mov       al,es:[di+2]
         test      al,20h
         jnz       l_265E
         and       al,0Fh
         jnz       l_2615
         mov       bx,es:[di+8]
         cmp       bx,es:[di+0Ah]
         jb        l_260B
         call      l_2666
         mov       bx,es:[di+8]
l_260B:  mov       al,es:[bx]
         inc       bx
         mov       es:[di+8],bx
         jmp       short l_2654

l_2615:  push      es
         push      di
         cmp       al,1
         jne       l_2637
         mov       bx,ds:[d_0182]
         cmp       bx,ds:[d_0184]
         jb        l_262E
         mov       dh,al
         call      l_2547
         mov       bx,ds:[d_0182]
l_262E:  mov       al,[bx]
         inc       bx
         mov       ds:[d_0182],bx
         jmp       short l_2652

l_2637:  cmp       al,2
         jne       l_2642
         dec       sp
         call      word ptr ds:[d_0138]
         jmp       short l_2652

l_2642:  cmp       al,4
         jne       l_264D
         dec       sp
         call      word ptr ds:[d_0140]
         jmp       short l_2652

l_264D:  dec       sp
         call      word ptr ds:[d_0144]
l_2652:  pop       di
         pop       es
l_2654:  mov       es:[di+3],al
         or        byte ptr es:[di+2],20h
         ret

l_265E:  mov       al,es:[di+3]
         ret

l_2663:  mov       al,1Ah
         ret

l_25E3   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2666   PROC      NEAR

         mov       ah,3Fh
         mov       bx,es:[di]
         mov       cx,es:[di+6]
         mov       dx,es:[di+4]
         push      ds
         push      es
         pop       ds
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       ds
         jnc       l_267E
         xor       ax,ax
l_267E:  mov       bx,es:[di+4]
         or        ax,ax
         jnz       l_268B
         mov       byte ptr es:[bx],1Ah
         inc       ax
l_268B:  mov       es:[di+8],bx
         add       bx,ax
         mov       es:[di+0Ah],bx
         ret

l_2666   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2696   PROC      NEAR

         push      es
         push      di
         mov       bx,offset d_00B6
l_269B:  push      bx
         call      l_25E3
         pop       bx
         cmp       al,1Ah
         je        l_26C6
         and       byte ptr es:[di+2],0DFh
         cmp       al,20h
         jbe       l_269B
l_26AD:  mov       [bx],al
         inc       bx
         cmp       bx,offset d_00B60 - 1
         je        l_26C6
         push      bx
         call      l_25E3
         pop       bx
         cmp       al,20h
         jbe       l_26C6
         and       byte ptr es:[di+2],0DFh
         jmp       short l_26AD

l_26C6:  mov       byte ptr [bx],0
         mov       bx,offset d_00B6
         cmp       byte ptr [bx],0
         pop       di
         pop       es
         ret

l_2696   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_26D2   PROC      NEAR

         jc        l_26D9
         cmp       byte ptr [bx],0
         je        l_26DF
l_26D9:  mov       byte ptr ds:[d_0180],10h
         stc       
l_26DF:  ret

l_26D2   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_26E0   PROC      NEAR

         push      di
         call      l_25E3
         and       byte ptr es:[di+2],0DFh
         pop       di
         pop       bx
         pop       es
         mov       es:[di],al
         jmp       bx

l_26E0   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_26F1   PROC      NEAR

         clc
         jmp       short l_26F5

l_26F1   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_26F4   PROC      NEAR

         stc
l_26F5:  pop       bx
         pop       es
         push      bx
         pushf
         call      l_2696
         jz        l_2711
         call      l_1188
         call      l_26D2
         jc        l_2711
         popf
         jnc       l_270D
         mov       es:[di],ax
         ret

l_270D:  mov       es:[di],al
         ret

l_2711:  popf
         ret

l_26F4   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2713   PROC      NEAR

         pop       bx
         pop       es
         push      bx
         call      l_2696
         jz        l_272E
         push      di
         mov       di,offset d_023A
         call      l_20AA
         mov       si,di
         pop       di
         call      l_26D2
         jc        l_272E
         cld       
         movsw     
         movsw     
         movsw     
l_272E:  ret

l_2713   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_272F   PROC      NEAR

         pop       bx
         pop       es
         push      bx
         xor       bx,bx
         xor       ch,ch
l_2736:  push      es
         push      di
         push      bx
         push      cx
         call      l_25E3
         pop       cx
         pop       bx
         cmp       al,0Dh
         je        l_2756
         cmp       al,1Ah
         je        l_2756
         and       byte ptr es:[di+2],0DFh
         pop       di
         pop       es
         inc       bx
         mov       es:[bx+di],al
         loop      l_2736
         jmp       short l_2758

l_2756:  pop       di
         pop       es
l_2758:  mov       es:[di],bl
         ret

l_272F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_275C   PROC      NEAR

         pop       bx
         pop       es
         push      bx
         xor       ch,ch
l_2761:  push      es
         push      di
         push      cx
         call      l_25E3
         pop       cx
         cld       
         cmp       al,0Dh
         je        l_277C
         cmp       al,1Ah
         je        l_277C
         and       byte ptr es:[di+2],0DFh
         pop       di
         pop       es
         stosb     
         loop      l_2761
         ret

l_277C:  pop       di
         pop       es
         mov       al,20h
         rep       stosb
         ret

l_275C   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2783   PROC      NEAR

         call      l_25E3
         cmp       al,1Ah
         je        l_27A3
         and       byte ptr es:[di+2],0DFh
         cmp       al,0Ah
         je        l_27A3
         cmp       al,0Dh
         jne       l_2783
         call      l_25E3
         cmp       al,0Ah
         jne       l_27A3
         and       byte ptr es:[di+2],0DFh
l_27A3:  ret

l_2783   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° znaku na displeji DOS
; -----------------------------------------------------------------------------

l_27A4   PROC      NEAR

         les       di,dword ptr ds:[d_0232] ; adresa definice stand. za©°zen°
         cmp       byte ptr ds:[d_0180],0
         jne       l_27EE
         mov       cl,es:[di+2]
         and       cl,0Fh
         jnz       l_27CB
         mov       bx,es:[di+8]
         mov       es:[bx],al
         inc       bx
         mov       es:[di+8],bx
         cmp       bx,es:[di+0Ah]
         je        l_27EF
         ret

l_27CB:  push      ax
         cmp       cl,1
         je        l_27E0
         cmp       cl,3
         je        l_27E5
         cmp       cl,4
         je        l_27EA
         call      word ptr ds:[d_0142]
         ret

l_27E0:  call      word ptr ds:[d_013A]     ; vòstup textu na displej DOS
         ret

l_27E5:  call      word ptr ds:[d_013C]
         ret

l_27EA:  call      word ptr ds:[d_013E]
l_27EE:  ret

l_27EF:  mov       cx,es:[di+8]
         sub       cx,es:[di+4]
         jz        l_2818
         mov       ah,40h             ; '@'
         mov       bx,es:[di]
         mov       dx,es:[di+4]
         mov       es:[di+8],dx
         push      ds
         push      es
         pop       ds
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       ds
         jc        l_2813
         cmp       ax,cx
         je        l_2818
l_2813:  mov       byte ptr ds:[d_0180],0F0h
l_2818:  ret

l_27A4   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2819   PROC      NEAR

         or        ax,ax
         jz        l_282F
         call      l_0AAA
         cmp       al,1
         jbe       l_282F
         xchg      ax,cx
         dec       cx
l_2826:  mov       al,20h
         push      cx
         call      l_27A4                   ; zobrazen° znaku na displeji DOS
         pop       cx
         loop      l_2826
l_282F:  pop       bx
         pop       ax
         push      bx
         jmp       l_27A4                   ; zobrazen° znaku na displeji DOS

l_2819   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2835   PROC      NEAR

         xchg      ax,cx
         pop       bx
         pop       ax
         push      bx
         push      cx
         mov       bx,offset d_00B6
         call      l_10FC
l_2840:  pop       ax
         call      l_0AAA                   ; omezen° á°sla na bajt bez znamÇnka
         sub       bx,offset d_00B6
         sub       ax,bx
         jbe       l_2858
         xchg      ax,cx
         push      bx
l_284E:  mov       al,20h
         push      cx
         call      l_27A4                   ; zobrazen° znaku na displeji DOS
         pop       cx
         loop      l_284E
         pop       bx
l_2858:  mov       cx,bx
         mov       bx,offset d_00B6
l_285D:  mov       al,[bx]
         push      bx
         push      cx
         call      l_27A4                   ; zobrazen° znaku na displeji DOS
         pop       cx
         pop       bx
         inc       bx
         loop      l_285D
         ret

l_2835   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_286A   PROC      NEAR

         xchg      ax,dx
         pop       bx
         pop       cx
         mov       di,offset d_023A
         pop       word ptr [di]
         pop       word ptr [di+2]
         pop       word ptr [di+4]
         push      bx
         push      cx
         mov       bx,offset d_00B6
         call      l_1F22
         jmp       short l_2840

l_286A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2882   PROC      NEAR

         pop       bx
         pop       cx
         push      bx
         mov       di,offset l_2897
         or        cx,cx
         jnz       l_288F
         mov       di,offset l_289C
l_288F:  push      cs
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_28A2
         ret

l_2882   ENDP

l_2897   db        4,'TRUE'
l_289C   db        5,'FALSE'

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_28A2   PROC      NEAR

         call      l_0AAA                   ; omezen° á°sla na bajt bez znamÇnka
         mov       bx,sp
         inc       bx
         inc       bx
         sub       al,ss:[bx]
         jbe       l_28BD
         mov       cl,al
         xor       ch,ch
         push      bx
l_28B3:  mov       al,20h
         push      cx
         call      l_27A4                   ; zobrazen° znaku na displeji DOS
         pop       cx
         loop      l_28B3
         pop       bx
l_28BD:  mov       cl,ss:[bx]
         xor       ch,ch
         inc       bx
         or        cx,cx
         jz        l_28D4
l_28C7:  mov       al,ss:[bx]
         push      bx
         push      cx
         call      l_27A4                   ; zobrazen° znaku na displeji DOS
         pop       cx
         pop       bx
         inc       bx
         loop      l_28C7
l_28D4:  pop       dx
         mov       sp,bx
         jmp       dx

l_28A2   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textovÇho ©etàzce DOS
; -----------------------------------------------------------------------------

l_28D9   PROC      NEAR

         pop       bx                       ; n†vratov† adresa
         mov       cl,cs:[bx]               ; dÇlka textovÇho ©etàzce
         xor       ch,ch                    ; CH <- 00
         inc       bx                       ; zaá†tek textovÇho ©etàzce
         jcxz      l_28EF                   ; nen° ë†dnò bajt
l_28E2:  mov       al,cs:[bx]               ; znak k tisku
         push      bx                       ; £schova ukazatele textu
         push      cx                       ; £schova á°taáe znakñ
         call      l_27A4                   ; zobrazen° znaku na displeji DOS
         pop       cx
         pop       bx
         inc       bx
         loop      l_28E2
l_28EF:  jmp       bx

l_28D9   ENDP

; -----------------------------------------------------------------------------
;        od©†dkov†n° textu DOS
; -----------------------------------------------------------------------------

l_28F1   PROC      NEAR

         mov       al,0Dh
         call      l_27A4                   ; zobrazen° znaku na displeji DOS
         mov       al,0Ah
         jmp       l_27A4                   ; zobrazen° znaku na displeji DOS

l_28F1   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_28FB   PROC      NEAR

         mov       dx,10Dh
         jmp       short l_290D

l_28FB   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2900   PROC      NEAR

         mov       dx,0Dh
         jmp       short l_290D

l_2900   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2905   PROC      NEAR

         mov       dx,11Ah
         jmp       short l_290D

l_2905   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_290A   PROC      NEAR

         mov       dx,1ah
l_290D:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         test      byte ptr es:[di+2],80h
         jz        l_293D
l_291D:  push      dx
         call      l_25E7
         pop       dx
         cmp       al,dl
         je        l_2939
         cmp       al,1Ah
         je        l_2939
         cmp       al,20h             ; ' '
         ja        l_293D
         or        dh,dh
         jz        l_293D
         and       byte ptr es:[di+2],0DFh
         jmp       short l_291D

l_2939:  xor       ax,ax
         inc       ax
         ret

l_293D:  xor       ax,ax
         ret

l_290A   ENDP

; -----------------------------------------------------------------------------
;        p©°prava jmÇna souboru k otev©en°
; -----------------------------------------------------------------------------

l_2940   PROC      NEAR

         xor       al,al
         jmp       l_22B4

l_2940   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2945   PROC      NEAR

         xor       al,al
         jmp       short l_294B

l_2945   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2949   PROC      NEAR

         mov       al,1
l_294B:  mov       byte ptr ds:[d_0238],al  ; bit 0:1=vytvo©en°/0=otev©en° soub.
         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         push      cx
         call      l_2993
         pop       cx
         cmp       byte ptr ds:[d_0180],0
         jne       l_2973
         push      cx
         call      l_2486                   ; vytvo©en°/otev©en° souboru
         pop       cx
         cmp       byte ptr ds:[d_0180],0
         jne       l_2973
         mov       es:[di+2],cx
l_2973:  ret

l_2949   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2974   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ah,40h
         mov       bx,es:[di]
         xor       cx,cx
         jmp       l_093A                   ; vol†n° sluëby DOS AH (soubory)
         ret       2

l_2974   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_298A   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
l_2993:  mov       word ptr es:[di+2],0
         jmp       l_23FD

l_298A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_299C   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         mov       word ptr ds:[d_0232],di  ; adresa definice stand. za©°zen°
         mov       word ptr ds:[d_0232+2],es
         cmp       word ptr es:[di+2],0
         jne       l_29B5
         mov       byte ptr ds:[d_0180],4
l_29B5:  jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_299C   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_29B9   PROC      NEAR

         mov       word ptr ds:[d_0238],993Fh ; bit 0:1=vytvo©en°/0=otev©en° soub.
         jmp       short l_29C7

l_29B9   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_29C1   PROC      NEAR

         mov       word ptr ds:[d_0238],0F040h ; bit 0:1=vytvo©en°/0=otev©en° soub.
l_29C7:  pop       bx
         pop       si
         push      bx
         cmp       byte ptr ds:[d_0180],0
         jne       l_29F5
         mov       dx,di
         les       di,dword ptr ds:[d_0232] ; adresa definice stand. za©°zen°
         mov       ah,byte ptr ds:[d_0238]  ; bit 0:1=vytvo©en°/0=otev©en° soub.
         mov       bx,es:[di]
         mov       cx,es:[di+2]
         push      ds
         mov       ds,si
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       ds
         jc        l_29EF
         cmp       ax,cx
         je        l_29F5
l_29EF:  mov       al,byte ptr ds:[d_0238+1]; bit 0:1=vytvo©en°/0=otev©en° soub.
         mov       ds:[d_0180],al
l_29F5:  ret

l_29C1   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_29F6   PROC      NEAR

         xor       dx,dx
l_29F8:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       di
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       cx,es:[di+2]
         call      l_2ABE
         mov       cx,dx
         mov       dx,ax
         mov       ax,4200h
         mov       bx,es:[di]
         push      cx
         push      dx
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       cx
         pop       bx
         jc        l_2A24
         cmp       ax,cx
         jne       l_2A24
         cmp       dx,bx
         je        l_2A29
l_2A24:  mov       byte ptr ds:[d_0180],91h
l_2A29:  ret

l_29F6   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2A2A   PROC      NEAR

         call      l_225B
         jmp       short l_29F8

l_2A2A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2A2F   PROC      NEAR

         pop       bx
         pop       es
         push      bx
         mov       ax,4406h
         mov       bx,es:[di]
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         or        al,al
         mov       ax,0
         jnz       l_2A43
         inc       ax
l_2A43:  or        ax,ax
         ret

l_2A2F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2A46   PROC      NEAR

         pop       bx
         pop       es
         push      bx
l_2A49:  mov       ax,4201h
         mov       bx,es:[di]
         xor       cx,cx
         xor       dx,dx
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
l_2A56:  mov       cx,es:[di+2]
         jmp       short l_2AA1
         nop

l_2A46   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2A5D   PROC      NEAR

         pop       bx
         pop       es
         push      bx
         call      l_2A49
         jmp       l_2291                   ; p©°prava jmÇna souboru k operaci

l_2A5D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2A66   PROC      NEAR

         pop       bx
         pop       es
         push      bx
l_2A69:  mov       ax,4201h
         mov       bx,es:[di]
         xor       cx,cx
         xor       dx,dx
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         push      ax
         push      dx
         mov       ax,4202h
         mov       bx,es:[di]
         xor       cx,cx
         xor       dx,dx
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       cx
         pop       bx
         push      ax
         push      dx
         mov       dx,bx
         mov       ax,4200h
         mov       bx,es:[di]
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       dx
         pop       ax
         jmp       short l_2A56

l_2A66   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2A98   PROC      NEAR

         pop       bx
         pop       es
         push      bx
         call      l_2A69
         jmp       l_2291

l_2A98   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2AA1   PROC      NEAR

         cmp       cx,1
         je        l_2ABD
         mov       si,cx
         xor       bx,bx
         mov       cx,21h
l_2AAD:  rcl       bx,1
         sbb       bx,si
         jnc       l_2AB6
         add       bx,si
         stc       
l_2AB6:  cmc
         rcl       ax,1
         rcl       dx,1
         loop      l_2AAD
l_2ABD:  ret

l_2AA1   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2ABE   PROC      NEAR

         mov       bx,ax
         mov       ax,dx
         mul       cx
         xchg      ax,bx
         mul       cx
         add       dx,bx
         ret

l_2ABE   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2ACA   PROC      NEAR

         xchg      ax,cx
         pop       bx
         pop       di
         push      bx
         jmp       l_2945

l_2ACA   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2AD1   PROC      NEAR

         xchg      ax,cx
         pop       bx
         pop       di
         push      bx
         jmp       l_2949

l_2AD1   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2AD8   PROC      NEAR

         mov       word ptr ds:[d_0238],993Fh ; bit 0:1=vytvo©en°/0=otev©en° soub.
         jmp       short l_2AE6

l_2AD8   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2AE0   PROC      NEAR

         mov       word ptr ds:[d_0238],0F040h ; bit 0:1=vytvo©en°/0=otev©en° soub.
l_2AE6:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       dx
         pop       si
         pop       di
         pop       es
         push      ax
         call      l_2B30
         pop       cx
         cmp       byte ptr ds:[d_0180],0
         jne       l_2B04
         cmp       ax,cx
         je        l_2B04
         mov       al,byte ptr ds:[d_0238+1] ; bit 0:1=vytvo©en°/0=otev©en° soub.
         mov       byte ptr ds:[d_0180],al
l_2B04:  jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_2AE0   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2B08   PROC      NEAR

         mov       word ptr ds:[d_0238],993Fh ; bit 0:1=vytvo©en°/0=otev©en° soub.
         jmp       short l_2B16

l_2B08   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2B10   PROC      NEAR

         mov       word ptr ds:[d_0238],0F040h ; bit 0:1=vytvo©en°/0=otev©en° soub.
l_2B16:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       cx,di
         pop       bx
         pop       ax
         pop       dx
         pop       si
         pop       di
         pop       es
         push      bx
         push      cx
         call      l_2B30
         pop       di
         pop       es
         mov       es:[di],ax
         jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_2B10   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2B30   PROC      NEAR

         cmp       word ptr es:[di+2],0
         je        l_2B6B
         cmp       word ptr es:[di+2],1
         je        l_2B44
         push      dx
         mul       word ptr es:[di+2]
         pop       dx
l_2B44:  xchg      ax,cx
         mov       ah,byte ptr ds:[d_0238]  ; bit 0:1=vytvo©en°/0=otev©en° soub.
         mov       bx,es:[di]
         push      ds
         mov       ds,si
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       ds
         jnc       l_2B5D
         mov       al,byte ptr ds:[d_0238+1]; bit 0:1=vytvo©en°/0=otev©en° soub.
         mov       ds:[d_0180],al
         xor       ax,ax
l_2B5D:  cmp       word ptr es:[di+2],1
         je        l_2B6A
         xor       dx,dx
         div       word ptr es:[di+2]
l_2B6A:  ret

l_2B6B:  mov       byte ptr ds:[d_0180],4
         ret

l_2B30   ENDP

; -----------------------------------------------------------------------------
;        zru®en° souboru
; -----------------------------------------------------------------------------

l_2B71   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ah,41h
         lea       dx,[di+0Ch]
         push      ds
         push      es
         pop       ds
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       ds
         jnc       l_2B8D
l_2B88:  mov       byte ptr ds:[d_0180],1   ; p©°znak chyby operace
l_2B8D:  ret

l_2B71   ENDP

; -----------------------------------------------------------------------------
;        p©ejmenov†n° souboru
; -----------------------------------------------------------------------------

l_2B8E   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         call      l_0EC7                   ; p©enos ©etàzce ze z†sob.do bufferu
         pop       di
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ah,56h                   ; sluëba p©ejmenov†n° souboru
         lea       dx,[di+0Ch]
         push      di
         mov       di,offset d_00B6
         push      ds
         push      es
         pop       ds
         pop       es
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         push      ds
         push      es
         pop       ds
         pop       es
         pop       di
         jc        l_2B88
         mov       si,offset d_00B6
         lea       di,[di+0Ch]
         mov       cx,20h
         cld       
         rep       movsw                    ; p©enos jmÇna souboru
         ret

l_2B8E   ENDP      

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2BBF   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         call      l_0EC7                   ; p©enos ©etàzce ze z†sob.do bufferu
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ax,word ptr ds:[d_00B6]
         or        al,al
         jz        l_2BF9
         cmp       ah,3Ah
         jne       l_2BEF
         call      l_0A81
         sub       al,41h
         jc        l_2B88
         cmp       al,0Fh
         jae       l_2B88
         mov       ah,0Eh
         mov       dl,al
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         cmp       byte ptr ds:[d_00B6+2],0
         je        l_2BF9
l_2BEF:  mov       ah,3Bh
l_2BF1:  mov       dx,offset d_00B6
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         jc        l_2B88
l_2BF9:  ret

l_2BBF   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2BFA   PROC      NEAR

         mov       bh,39h
         jmp       short l_2C00

l_2BFA   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2BFE   PROC      NEAR

         mov       bh,3ah
l_2C00:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         call      l_0EC7                   ; p©enos ©etàzce ze z†sob.do bufferu
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ah,bh
         jmp       short l_2BF1

l_2BFE   ENDP

; -----------------------------------------------------------------------------
;        poskytnut° aktivn°ho disku a adres†©e
; -----------------------------------------------------------------------------
                                          ;* poskytnut° aktiv. disku a adres†©e
                                          ;* VSTUP: [SP+2]:DI = ukl†dac° adresa
                                          ;*        [SP+4] = poëadovanò disk
                                          ;*        CX = maxim†ln° dÇlka ©etàzce

l_2C0F   PROC      NEAR

         pop       word ptr ds:[d_0186]        ; p©echodn† £schova n†vratovÇ adresy
         pop       es                          ; segment ukl†dac° adresy
         pop       ax                          ; poëadovanò disk
         push      word ptr ds:[d_0186]        ; n†vrat n†vratovÇ adresy
         or        al,al                       ; je zad†n disk ?
         jnz       l_2C24                      ; je zad†n disk (jinak implicitn°)
         mov       ah,19h                      ; funkce poskytnut° aktivn°ho disku
         call      l_093A                      ; poskytnut° aktivn°ho disku
         inc       al                          ; aktivn° disk + 1
l_2C24:  mov       dl,al                       ; poëadovanò disk
         add       al,40h                      ; p©evod aktiv. disku na znak ASCII
         mov       ds:[d_00B6],al              ; uloëen° aktivn°ho disku
         mov       word ptr ds:[d_00B6+1],5C3Ah; oddàlovac° text ":\"
         mov       ah,47h                      ; funkce poskytnut° aktiv. adres†©e
         mov       si,offset d_00B6+3          ; adresa k uloëen° aktiv. adres†©e
         call      l_093A                      ; vyvol†n° sluëby BDOS
         jnc       l_2C3E                      ; operace OK
         mov       byte ptr [si],0             ; chyba - vynulov†n° ©etàzce
l_2C3E:  mov       si,offset d_00B6            ; ©etàzec aktivn°ho disku a adres†©e
         xor       bx,bx                       ; BX <- 0000 á°taá dÇlky ©etàzce
l_2C43:  mov       al,[si]                     ; znak ©etàzce
         or        al,al                       ; je konec ©etàzce ?
         jz        l_2C52                      ; je konec ©etàzce
         inc       si                          ; zvò®en° adresy znaku v ©etàzci
         inc       bx                          ; zvò®en° á°taáe znakñ
         mov       es:[bx+di],al               ; uloëen° znaku ©etàzce
         dec       cl                          ; á°taá max. poátu znakñ
         jnz       l_2C43                      ; p©enos dal®°ho znaku
l_2C52:  mov       es:[di],bl                  ; uloëen° dÇlky ©etàzce cesty
         ret

l_2C0F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2C56   PROC      NEAR

         mov       bx,2BB6h
         jmp       short l_2C5D

l_2C56   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_2C5B   PROC      NEAR

         xor       bx,bx
l_2C5D:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       es
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         test      word ptr ds:[d_0172],1
         jnz       l_2CB0
         push      bx
         mov       ax,3D00h
         lea       dx,[di+0Ch]
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       dx
         jc        l_2CAB
         mov       bx,ax
         mov       ax,4200h
         xor       cx,cx
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         jc        l_2CAB
         push      ds
         push      cs
         pop       ds
         mov       ah,3Fh
         mov       cx,0FFFFh
         mov       dx,offset l_2CB6
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         pop       ds
         mov       ah,3Eh
         call      l_093A                   ; vol†n° sluëby DOS AH (soubory)
         mov       sp,ds:[d_0174]
         call      l_09D9
         mov       word ptr ds:[d_017E],offset l_10B1
         ;jmp       l_2CCD
         db        0e9h
         dw        l_2CCD-$-2

l_2CAB:  mov       dl,1
         jmp       l_24AC

l_2CB0:  mov       byte ptr ds:[d_0180],21h
         ret

l_2C5B   ENDP

; *****************************************************************************
;
;                              START PROGRAMU
;                           uëivatelskò program
;
; *****************************************************************************

l_2CB6:  call      l_0AB7                   ; inicializace programu

                                            ; n†sleduj° data

l_2CB9   dw        2                        ; [SI+00] p©°znaky
                                            ; bit 0 = max. pamàü se nemodifikuje
                                            ; bit 3 = je obsluha INT 3
         dw        4ca5h                    ; [SI+02]
         dw        5658h                    ; [SI+04]
         dw        0fbfh                    ; [SI+06] dÇlka programu v segment.
         dw        0fe6h                    ; [SI+08] dÇlka datovÇho segmentu
         dw        0400h                    ; [SI+0A] dÇlka z†sobn°ku
         dw        0a000h                   ; [SI+0C] max. pot©ebn† velikost dat
         dw        16                       ; [SI+0E] max.poáet identifik. soub.
         dw        0                        ; [SI+10]
         dw        0                        ; [SI+12]

l_2CCD:  mov       bp,sp                    ; nastaven° ukazatele dat
         call      l_0CAD                   ; (neuplatn° se)
         dw        0,l_2CD6

l_2cd6:  jmp       l_faa0                   ; start hlavn°ho programu

                                          ;* datov† á†st programu
                                          ;* tato á†st se ukl†d† na disk p©i
                                          ;* uloëen° nastaven°

                                          ;* tabulka makrokl†ves (makrobuffer)
                                          ;* celkov† kapacita 1000 bajtñ
                                          ;* STRUKTURA:
                                          ; 1 bajt - SCAN k¢d kl†vesy (0=konec)
                                          ; 1 bajt - dÇlka makrodefinice (n)
                                          ; n bajtñ - makrodefinice

;l_2CD9   db        1000 dup(0)

; *****************************************************************************
;
;                         Konfigurace programu
;
; *****************************************************************************

l_2CD9   label     byte                     ; buffer makrokl†ves (1000 bajtñ)

         db        4bh,1,13h
         db        4dh,1,4
         db        48h,1,5
         db        50h,1,18h
         db        4fh,2,11h,44h
         db        51h,1,3
         db        35h,2,10h,38h
         db        73h,1,1
         db        74h,1,6
         db        52h,1,16h
         db        53h,1,7
         db        77h,2,11h,45h
         db        75h,2,11h,58h
         db        76h,2,11h,43h
         db        43h,2,11h,54h
         db        84h,2,11h,52h
         db        44h,4,0bh,53h,0bh,51h
         db        47h,2,11h,53h
         db        49h,1,12h
         db        5eh,2,0bh,31h
         db        5fh,2,0bh,32h
         db        60h,2,0bh,33h
         db        61h,2,0bh,34h
         db        62h,2,0bh,35h
         db        3dh,1,0fah
         db        54h,2,10h,35h
         db        55h,2,10h,34h
         db        3bh,2,0fh,41h
         db        3ch,2,0fh,55h
         db        66h,1,1dh
         db        67h,1,1eh
         db        56h,2,10h,33h
         db        5ah,2,10h,36h
         db        5bh,2,10h,38h
         db        68h,2,10h,46h
         db        69h,2,10h,55h
         db        6ah,2,10h,4bh
         db        6bh,2,10h,42h
         db        6ch,2,10h,48h
         db        6dh,2,10h,54h
         db        6eh,2,10h,4eh
         db        42h,2,0fh,49h
         db        3fh,2,0fh,4dh
         db        40h,2,0fh,56h
         db        41h,2,0fh,54h
         db        5dh,2,1ch,0dh
         db        57h,16,0bh,4eh,42h,0bh,4eh,4bh,10h,42h
         db               0bh,54h,10h,42h,4,4,0bh,48h
         db        3eh,3,13h,10h,37h
         db        63h,2,0bh,43h
         db        64h,9,0bh,42h,0bh,4bh,5,0bh,56h,0bh,48h
         db        65h,10,0bh,42h,0bh,4bh,18h,18h,0bh,56h,0bh,48h
         db        58h,2,10h,31h
         db        59h,2,10h,32h
         db        5ch,3,0ah,47h,0dh
         db        6fh,4,0feh,13h,10h,36h
         db        70h,6,11h,46h,0feh,0dh,42h,0dh
         db        71h,6,11h,46h,0feh,0dh,19h,0dh
         db        0fh,5,'     '
         db        12h,85,CtrlQ,'S',CtrlN,'; ', 77 dup('∞'),CtrlQ,'S',CtrlX
         db        10h,85,CtrlQ,'S',CtrlN,'; ', 77 dup('-'),CtrlQ,'S',CtrlX
         db        11h,85,CtrlQ,'S',CtrlN,'; ', 77 dup('*'),CtrlQ,'S',CtrlX
         db        0

         db        2ah,11h,53h,18h,0,2ah,2ah,2ah
         db        2ah,2ah,2ah,2ah,2ah,2ah,2ah,2ah    ; 2EF0
         db        2ah,11h,53h,18h,0,4eh,0,2
         db        10h,48h,6dh,2,10h,54h,6eh,2        ; 2F00
         db        10h,4eh,0,6dh,2,10h,54h,6eh
         db        2,10h,4eh,0,42h,6ch,2,10h          ; 2F10
         db        48h,6dh,2,10h,54h,6eh,2,10h
         db        4eh,0,2,10h,54h,6eh,2,10h          ; 2F20
         db        4eh,0,6ch,2,10h,48h,6dh,2
         db        10h,54h,6eh,2,10h,4eh,0,10h        ; 2F30
         db        54h,6eh,2,10h,4eh,0,5,5
         db        5,5                                ; 2F40

         db        30c1h-2F42h dup(0)

                                          ;* tabulka definic pro tisk
                                          ;* struktura:
                                          ;*   1 bajt - dÇlka poloëky
                                          ;*   8 bajtñ dat (maxim†lnà)

; ------ tiskovÇ efekty

l_30C1   db        3,ESCP,'S',0,0,0,0,0,0   ; nadsazen° zap.
l_30CA   db        2,ESCP,'T',0,0,0,0,0,0   ; nadsazen° vyp.
l_30D3   db        3,ESCP,'S',1,0,0,0,0,0   ; podsazen° zap.
l_30DC   db        2,ESCP,'T',0,0,0,0,0,0   ; podsazen° vyp.
l_30E5   db        2,ESCP,'4',0,0,0,0,0,0   ; kurz°va zap.
l_30EE   db        2,ESCP,'5',0,0,0,0,0,0   ; kurz°va vyp.
l_30F7   db        3,ESCP,'-1',0,0,0,0,0    ; podtrëen° zap.
l_3100   db        3,ESCP,'-0',0,0,0,0,0    ; podtrëen° vyp.
l_3109   db        2,ESCP,'E',0,0,0,0,0,0   ; zvòraznàn° zap.
l_3112   db        2,ESCP,'F',0,0,0,0,0,0   ; zvòraznàn° vyp.
l_311B   db        3,ESCP,'W',1,0,0,0,0,0   ; ®irokÇ p°smo zap.
l_3124   db        3,ESCP,'W',0,0,0,0,0,0   ; ®irokÇ p°smo vyp.

; ------ typ p°sma

l_312D   db        6,ESCP,'U',1,ESCP,'x',1,0,0 ; vy®®° kvalita zap.
l_3136   db        6,ESCP,'U',0,ESCP,'x',0,0,0 ; vy®®° kvalita vyp.
l_313F   db        2,ESCP,'M',0,0,0,0,0,0   ; ELITE zap.
l_3148   db        2,ESCP,'P',0,0,0,0,0,0   ; ELITE vyp.
l_3151   db        2,ESCP,15,0,0,0,0,0,0    ; kondenzovanÇ zap.
l_315A   db        1,12h,0,0,0,0,0,0,0      ; kondenzovanÇ vyp.
l_3163   db        3,ESCP,'p',1,0,0,0,0,0   ; proporcion†ln° zap.
l_316C   db        3,ESCP,'p',0,0,0,0,0,0   ; proporcion†ln° vyp.
l_3175   db        2,ESCP,'G',0,0,0,0,0,0   ; uëiv. volba 1 zap. (p©etisk)
l_317E   db        2,ESCP,'H',0,0,0,0,0,0   ; uëiv. volba 1 vyp. (p©etisk)
l_3187   db        3,ESCP,'3',27,0,0,0,0,0  ; uëiv. volba 2 zap. (©†dkov†n°)
l_3190   db        3,ESCP,'3',36,0,0,0,0,0  ; uëiv. volba 2 vyp. (©†dkov†n°)

; ------ uëivatelskÇ funkce

l_3199   db        2,ESCP,15,0,0,0,0,0,0    ; uëiv. funkce 0
l_31A2   db        1,12h,0,0,0,0,0,0,0      ; uëiv. funkce 1
l_31AB   db        3,ESCP,'p',1,0,0,0,0,0   ; uëiv. funkce 2
l_31B4   db        3,ESCP,'p',0,0,0,0,0,0   ; uëiv. funkce 3
l_31BD   db        3,ESCP,'w',1,0,0,0,0,0   ; uëiv. funkce 4
l_31C6   db        3,ESCP,'w',0,0,0,0,0,0   ; uëiv. funkce 5
l_31CF   db        0,ESCP,'k',7,0,0,0,0,0   ; uëiv. funkce 6
l_31D8   db        0,ESCP,'k',0,0,0,0,0,0   ; uëiv. funkce 7

; ------ ovl†d†n° z†kladn°ch funkcñ tisku

l_31E1   db        1,13,0,0,0,0,0,0,0       ; zaá†tek ©†dku
l_31EA   db        2,13,10,0,0,0,0,0,0      ; novò ©†dek
l_31F3   db        0,0,0,0,0,0,0,0,0
l_31FC   db        0,0,0,0,0,0,0,0,0
l_3205   db        6,ESCP,'!',0,ESCP,'3',36,0,0  ; zah†jen° tisku
l_320E   db        7,ESCP,'!',0,ESCP,'3',36,7,0  ; ukonáen° tisku
l_3217   db        0,ESCP,'3','Z',0,0,0,0,0

; ------ tabulka n†hradn°ch znakñ

l_3220   db        2                        ; poáet nahrazovanòch k¢dñ v tabulce
         db        250,127,14 dup(0)        ; nahrazovanÇ k¢dy

l_3231   db        2                        ; poáet n†hradn°ch k¢dñ v tabulce
         db        32,8,14 dup(0)           ; n†hradn° k¢dy

; ------ konfigurace
;˛
l_3242   db        84h,0,0,0,0,40h
l_3248   db        84h,0
l_324A   db        0,0,0,28h
l_324E   db        0
l_324F   db        0                        ; á°slo portu tisk†rny LPT
l_3250   db        0b4h
l_3251   db        0                        ; vy®®° kvalita (1=zap., 0=vyp.)
l_3252   db        0                        ; p°smo ELITE (1=zap., 0=vyp.)
l_3253   db        0                        ; £zkÇ p°smo (1=zap., 0=vyp.)
l_3254   db        0                        ; proporcion. tisk (1=zap., 0=vyp.)
l_3255   db        0                        ; dvojitò p©etisk (1=zap., 0=vyp.)
l_3256   db        0                        ; hustÇ ©†dkov†n° (1=zap., 0=vyp.)
l_3257   db        0                        ; samostatnò list (1=zap., 0=vyp.)
l_3258   db        0                        ; vòmàna pap°ru (1=zap., 0=vyp.)

; ------ konfigurace editovanÇho prostoru (màn° se pro kaëdò prostor)

l_3259   db        0                        ; poá†teán° pozice (levò okraj)
l_325a   db        80                       ; ®°©ka ©†dku textu (znakñ)
l_325b   db        2                        ; poáet ©†dkñ z†hlav°
l_325c   db        3                        ; poáet ©†dkñ paty
l_325d   db        72                       ; poáet ©†dkñ na str†nku
l_325e   db        1                        ; zarovn†v†n° (1=zap., 0=vyp.)
l_325f   db        1                        ; rozdàlov†n° (1=zap., 0=vyp.)
l_3260   db        1                        ; rozdàl. s dotaz.(1=zap., 0=vyp.)
l_3261   db        0                        ; auto-tabel†tor (1=zap., 0=vyp.)
l_3262   db        1                        ; konec odstavce (1=zap., 0=vyp.)
l_3263   db        1                        ; zobraz. str†nk. (1=zap., 0=vyp.)
l_3264   db        0                        ; zobr. line†lu ©†d.(1=zap., 0=vyp.)
l_3265   db        0                        ; nedokumentn° m¢d (1=zap., 0=vyp.)

; ------

l_3266   db        0
l_3267   db        1                        ; p©°znak INSERT (1=zap., 0=vyp.)
l_3268   db        7                        ; rychlost blik†n° kurzoru
l_3269   db        25h                      
l_326a   db        1                        
l_326b   db        24h                      
l_326c   db        10                       
l_326d   db        3                        
l_326e   db        31h                      
l_326f   db        90h                      ; korekce stavu tisk†rny (0=netest.)
l_3270   db        4                        
l_3271   db        2                        ; form†t(0=KonText,1=LAYOUT,2=ASCII)
l_3272   db        0                        ; z†loha BAK (1=zap., 0=vyp.)
l_3273   db        1                        ; ©†dkov.(1=©°dkÇ,2=st©edn°,3=hustÇ)
l_3274   db        11                       ; barva p°sma-pop©ed° (0 aë 15)
l_3275   db        1                        ; barva podkladu-pozad° (0 aë 15)
l_3276   db        1                        ; blik†n° kurzoru (1=zap., 0=vyp.)
l_3277   db        1                        ; n†povàda (1=zap., 0=vyp.)

l_3278   db        255                      ; dÇlka line†lu ©†dku
         db        51 dup ('----',31)       ; line†l ©†dku (dÇlka 255 bajtñ)

; ------ tabulka masek znakñ pro povolen° znakñ p©i editaci parametru
;  bit 0: 1=v®echny znaky

;  bit 3: 1=jmÇno souboru
;  bit 4: 1=á°slice
;  bit 5: 1=volba sÇriovÇho tisku (J,j,N,n)

;  bit 7: 1=parametry hled†n°

l_3378   db        1,1,1,1,1,1,1,1                    ; 0 aë 7
         db        1,1,1,1,1,1,1,1                    ; 8 aë 15
         db        1,1,1,1,1,1,1,1                    ; 16 aë 23
         db        1,1,1,1,1,1,1,1                    ; 24 aë 31
         db        9,9,1,9,9,9,9,9                    ;  !"#$%&'
         db        9,9,1,1,1,9,9,9                    ; ()*+,-./
         db        1Bh,1Bh,1Bh,1Bh,1Bh,1Bh,1Bh,1Bh    ; 01234567
         db        1Bh,1Bh,9,1,1,1,1,1                ; 89:;<=>?
         db        9,4Fh,8Fh,0Fh,0Fh,4Fh,0Fh,8Fh      ; @ABCDEFG
         db        0Fh,4Fh,2Fh,0Fh,8Fh,0Fh,0AFh,4Fh   ; HIJKLMNO
         db        0Fh,0Fh,0Fh,0Fh,0Fh,0CFh,0Fh,8Fh   ; PQRSTUVW
         db        0Fh,4Fh,0Fh,1,9,1,9,9              ; XYZ[\]^_
         db        9,4Fh,8Fh,0Fh,0Fh,4Fh,0Fh,8Fh      ; `abcdefg
         db        0Fh,4Fh,2Fh,0Fh,8Fh,0Fh,0AFh,4Fh   ; hijklmno
         db        0Fh,0Fh,0Fh,0Fh,0Fh,0CFh,0Fh,8Fh   ; pqrstuvw
         db        0Fh,4Fh,0Fh,1,1,1,1,1              ; xyz{|}~

         db        7,47h,47h,47h,47h,47h,47h,47h      ; ÄÅÇÉÑÖÜá
         db        47h,47h,47h,47h,47h,47h,47h,47h    ; àâäãåçéè
         db        47h,47h,47h,47h,47h,47h,47h,47h    ; êëíìîïñó
         db        47h,47h,47h,7,7,7,7,7              ; òôöõúùûü
         db        7,7,7,7,7,7,7,7                    ; †°¢£§•¶ß
         db        1,1,1,1,1,1,1,1                    ; ®©™´¨≠ÆØ
         db        1,1,1,1,1,1,1,1                    ; ∞±≤≥¥µ∂∑
         db        1,1,1,1,1,1,1,1                    ; ∏π∫ªºΩæø
         db        1,1,1,1,1,1,1,1                    ; ¿¡¬√ƒ≈∆«
         db        1,1,1,1,1,1,1,1                    ; »… ÀÃÕŒœ
         db        1,1,1,1,1,1,1,1                    ; –—“”‘’÷◊
         db        1,1,1,1,1,1,1,1                    ; ÿŸ⁄€‹›ﬁﬂ
         db        1,7,1,1,1,1,1,1                    ; ‡·‚„‰ÂÊÁ
         db        1,1,1,1,1,1,1,1                    ; ËÈÍÎÏÌÓÔ
         db        1,1,1,1,1,1,1,1                    ; ÒÚÛÙıˆ˜
         db        1,1,1,1,1,1,1,1                    ; ¯˘˙˚¸˝˛

l_3478   db        44h
         db         45h, 46h, 89h, 09h, 06h, 8Ah
         db         88h, 0Ah, 82h, 81h, 42h, 05h
         db         50h, 51h, 15h, 54h, 11h, 55h
         db         64h, 98h,0A0h, 28h,0A2h, 2Ah
         db        0A8h, 22h,0AAh, 62h, 91h, 26h
         db         19h, 90h, 60h, 24h, 18h, 99h
         db         66h, 41h, 14h
l_34A0   db        0B3h
         db        0BAh, 20h,0B0h,0B1h,0B2h,0DBh
         db        0DCh,0DFh,0DDh,0DEh, 2Dh,0FBh
l_34AD   dw        320h
l_34AF   dw        0                        ; chyba INT 24h - informaán° registr
l_34B1   dw        0                        ; chyba INT 24h - k¢d chyby

; ------ tabulka pro konverzi systÇmovòch chyb DOS na chyby KonTextu

l_34B3   db        0
         db        0FFh, 01h, 04h,0FFh,0F1h, 03h
         db        0FFh, 05h,0FFh,0FFh, 02h,0FFh
         db        0FFh,0FFh, 09h,0FFh,0FFh,0FFh
         db        0FFh

; -----------------------------------------------------------------------------
;        vòstup znaku na displej
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] ©†dek
;        [SP+4] pozice
;        [SP+6] znak
; -----------------------------------------------------------------------------

l_34C7   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_34CE
         db        0e9h,0,0

l_34CE:  xor       bx,bx                    ; funkce vòstupu znaku na displej
         mov       ah,ds:[d_FE56]           ; m¢d zobrazen° znaku
         call      dword ptr ds:[d_FDC7]    ; vòstupu znaku na displej
         ;jmp       l_34DB
         db        0e9h,0,0

l_34DB:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      6                         ; n†vrat se zru®en°m parametrñ

l_34C7   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru, okna
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] parametr (0=normal, 1=invertovanÇ, 2=kurzor)
;        [SP+4] (2) koncov† linka
;        [SP+6] (2) koncov† pozice
;        [SP+8] (2) poá†teán° linka
;        [SP+10] (2) poá†teán° pozice
; -----------------------------------------------------------------------------

l_34E1   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_34E8
         db        0e9h,0,0

l_34E8:  mov       bx,1                     ; vykreslen° kurzoru, vymaz. okna
         call      dword ptr ds:[d_FDC7]    ; vykreslen° kurzoru, vymaz. okna
         ;jmp       l_34F2
         db        0e9h,0,0

l_34F2:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      0Ah                       ; n†vrat se zru®en°m parametrñ

l_34E1   ENDP

; -----------------------------------------------------------------------------
;        vykreslen° okna
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] parametr (0=normal, 1=invertovanÇ, 2=kurzor)
;        [SP+4] (2) koncovò ©†dek
;        [SP+6] (2) koncov† pozice
;        [SP+8] (2) poá†teán° ©†dek
;        [SP+10] (2) poá†teán° pozice
; -----------------------------------------------------------------------------

l_34F8   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_34FF
         db        0e9h,0,0

l_34FF:  dec       sp                       ; rezerva pro lok. promànnou 1 bajt
         mov       ax,[bp+0Ch]              ; poá†teán° pozice okna
         push      ax                       ; poá†teán° pozice okna
         mov       ax,[bp+0Ah]              ; poá†teán° ©†dek okna
         imul      word ptr ds:[d_FDCB]     ; poáet graf. linek na ©†dek textu
         push      ax                       ; poá†teán° graf. linka okna
         mov       ax,[bp+8]                ; koncov† pozice okna
         push      ax                       ; koncov† pozice okna
         mov       ax,[bp+6]                ; koncovò ©†dek okna
         inc       ax                       ; koncovò ©†dek + 1
         imul      word ptr ds:[d_FDCB]     ; poáet graf. linek na ©†dek textu
         dec       ax                       ; koncov† linka - 1
         push      ax                       ; koncov† graf. linka okna
         mov       ax,[bp+4]                ; parametr pro vykreslen° okna
         push      ax                       ; parametr pro vykreslen° okna
         call      l_34E1                   ; zobrazen° kurzoru, okna
         ;jmp       l_3524
         db        0e9h,0,0

l_3524:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      0Ah                       ; n†vrat se zru®en°m parametrñ

l_34F8   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] ©†dek
;        [SP+4] pozice
; -----------------------------------------------------------------------------

l_352A   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3531
         db        0e9h,0,0

l_3531:  mov       ax,[bp+6]                ; pozice s kurzorem
         sub       ax,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         mov       [bp+6],ax                ; pozice s kurzorem
         mov       ax,[bp+6]                ; pozice s kurzorem
         push      ax                       ; poá†teán° pozice okna
         mov       ax,[bp+4]                ; ©†dek s kurzorem
         push      ax                       ; poá†teán° ©†dek okna
         mov       ax,[bp+6]                ; pozice s kurzorem
         push      ax                       ; koncov† pozice okna
         mov       ax,[bp+4]                ; ©†dek s kurzorem
         push      ax                       ; koncovò ©†dek okna
         mov       ax,2                     ; p©°znak kurzoru
         push      ax                       ; p©°znak kurzoru
         call      l_34F8                   ; vykreslen° okna (kurzoru)
         ;jmp       l_3555
         db        0e9h,0,0

l_3555:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_352A   ENDP

; -----------------------------------------------------------------------------
;        rolov†n° okna nahoru
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] koncovò ©†dek okna
;        [SP+4] koncov† pozice okna
;        [SP+6] poá†teán° ©†dek okna
;        [SP+8] poá†teán° pozice okna
; -----------------------------------------------------------------------------

l_355B   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3562
         db        0e9h,0,0

l_3562:  mov       bx,2                     ; funkce rolov†n° okna nahoru
         call      dword ptr ds:[d_FDC7]    ; rolov†n° okna nahoru
         mov       ax,[bp+0Ah]              ; poá†teán° pozice okna
         push      ax                       ; poá†teán° pozice okna
         mov       ax,[bp+4]                ; koncovò ©†dek okna
         push      ax                       ; = poá†teán° ©†dek okna
         mov       ax,[bp+6]                ; koncov† pozice okna
         push      ax                       ; koncov† pozice okna
         mov       ax,[bp+4]                ; koncovò ©†dek okna
         push      ax                       ; koncovò ©†dek okna
         mov       ax,0                     ; atribut - norm†ln° okno
         push      ax                       ; atribut - norm†ln° okno
         call      l_34F8                   ; vymaz†n° spodn°ho ©†dku
         ;jmp       l_3583
         db        0e9h,0,0

l_3583:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      8                         ; n†vrat se zru®en°m parametrñ

l_355B   ENDP

; -----------------------------------------------------------------------------
;        rolov†n° okna dolñ
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] koncovò ©†dek okna
;        [SP+4] koncov† pozice okna
;        [SP+6] poá†teán° ©†dek okna
;        [SP+8] poá†teán° pozice okna
; -----------------------------------------------------------------------------

l_3589   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3590
         db        0e9h,0,0

l_3590:  mov       bx,3                     ; funkce rolov†n° okna dolñ
         call      dword ptr ds:[d_FDC7]    ; rolov†n° okna dolñ
         mov       ax,[bp+0Ah]              ; poá†teán° pozice okna
         push      ax                       ; poá†teán° pozice okna
         mov       ax,[bp+8]                ; poá†teán° ©†dek okna
         push      ax                       ; poá†teán° ©†dek okna
         mov       ax,[bp+6]                ; koncov† pozice okna
         push      ax                       ; koncov† pozice okna
         mov       ax,[bp+8]                ; poá†teán° ©†dek okna
         push      ax                       ; = koncovò ©†dek okna
         mov       ax,0                     ; atribut - norm†ln° okno
         push      ax                       ; atribut - norm†ln° okno
         call      l_34F8                   ; vymaz†n° horn°ho ©†dku
         ;jmp       l_35B1
         db        0e9h,0,0

l_35B1:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      8                         ; n†vrat se zru®en°m parametrñ

l_3589   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° okraje (á†ry)
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] maska pro zobrazen° á†ry
;        [SP+4] posledn° ©†dek k zobrazen° á†ry
;        [SP+6] prvn° ©†dek k zobrazen° á†ry
;        [SP+8] pozice na ©†dku
; -----------------------------------------------------------------------------

l_35B7   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_35BE
         db        0e9h,0,0

l_35BE:  mov       bx,4                     ; funkce vykreslen° okraje
         call      dword ptr ds:[d_FDC7]    ; vykreslen° okraje (á†ry)
         ;jmp       l_35C8
         db        0e9h,0,0

l_35C8:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      8                         ; n†vrat se zru®en°m parametrñ

l_35B7   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* inicializace displeje
                                          ;* VSTUP: [SP+4] barva podkladu
                                          ;*        [SP+6] barva p°sma
                                          ;*        [SP+8] poëadovanò m¢d 1 aë 3

l_35CE   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_35D5
         db        0e9h,0,0

l_35D5:  mov       bx,5                     ; funkce inicializace displeje
         call      dword ptr ds:[d_FDC7]    ; inicializace displeje
         mov       ds:[d_FDCD],ax           ; poáet znakñ na ©†dek
         mov       ds:[d_FDCB],bx           ; poáet graf.linek na ©†dek textu
         mov       ds:[d_FDCF],cx           ; poáet zobrazenòch textovòch ©†dkñ
         mov       di,offset d_FDD1         ; identifikaán° ©etàzec graf. karty
         mov       cx,3                     ; poáet znakñ identifikaán°ho textu
         mov       [di],cl                  ; uloëen° poátu znakñ ©etàzce
         mov       es,word ptr ds:[d_FDC7+2]; segment s uloëenòm SCREEN.OVL
l_35F3:  inc       di                       ; zvò®en° ukl†dac° adresy
         mov       al,es:[si]               ; znak k p©enosu
         inc       si                       ; zvò®en° zdrojovÇ adresy
         mov       [di],al                  ; uloëen° znaku
         loop      l_35F3                   ; p©enos dal®°ho znaku
         mov       ax,1                     ; poá†teán° pozice okna
         push      ax                       ; poá†teán° pozice okna
         mov       ax,0                     ; poá†teán° ©†dek okna
         push      ax                       ; poá†teán° ©†dek okna
         mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         push      ax                       ; koncov† pozice okna
         mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         push      ax                       ; koneánò ©†dek okna
         mov       ax,0                     ; parametr - norm†ln° okno
         push      ax                       ; parametr - norm†ln° okno
         call      l_34F8                   ; vymaz†n° obrazovky
         ;jmp       l_3616
         db        0e9h,0,0

l_3616:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      6                         ; n†vrat se zru®en°m parametrñ

l_35CE   ENDP

; -----------------------------------------------------------------------------
;        nastaven° textovÇho m¢du displeje
; -----------------------------------------------------------------------------
                                          ;* nastaven° textovÇho m¢du displeje

l_361C   PROC      NEAR

         push      bp                        ; £schova BP
         mov       bp,sp                     ; BP <- SP ukazatel dat
         push      bp                        ; £schova BP (stav SP)
         ;jmp       l_3623
         db        0e9h,0,0

l_3623:  mov       bx,6                      ; funkce nastaven° textovÇho m¢du
         call      dword ptr ds:[d_FDC7]     ; nastaven° textovÇho m¢du
         ;jmp       l_362D
         db        0e9h,0,0

l_362D:  mov       sp,bp                     ; n†vrat SP
         pop       bp                        ; n†vrat BP
         ret

l_361C   ENDP

; -----------------------------------------------------------------------------
;        p©ek¢dov†n° ©etàzce na velk† p°smena
; -----------------------------------------------------------------------------
                                          ;* p©ek¢d. ©etàzce na velk† p°smena
                                          ;* VSTUP: [SP+4] offset adresy ©etàzce
                                          ;*        [SP+6] segment adresy ©et.

l_3631   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3638
         db        0e9h,0,0

l_3638:  push      ds                       ; £schova DS
;         lds       di,dword ptr [bp+4]      ; adresa ©etàzce k p©evodu
         db        0C5h,0BEh,4,0            ;!
         mov       cl,[di]                  ; dÇlka ©etàzce
         inc       cl                       ; dÇlka + 1
l_3641:  dec       cl                       ; sn°ëen° á°taáe dÇlky ©etàzce
         jz        l_3671                   ; je jië konec ©etàzce
         inc       di                       ; zvò®en° ukazatele ©etàzce
         mov       al,[di]                  ; znak k p©evodu
         cmp       al,61h                   ; je znak men®° neë "a" ?
         jb        l_3641                   ; je znak men®° - dal®° znak
         mov       bl,al                    ; £schova znaku
         sub       bl,20h                   ; p©evod na velkÇ p°smeno
         cmp       al,7Ah                   ; je znak vàt®° neë "z" ?
         jbe       l_366D                   ; nen° vàt®° - je malÇ p°smeno
         cmp       al,80h                   ; je znak vàt®° neë 80h ?
         jbe       l_3641                   ; nen° znak vàt®° neë 80h
         mov       bl,8Eh                   ; znak "é"
         cmp       al,84h                   ; je znak "Ñ" ?
         je        l_366D                   ; je znak "Ñ" - p©evod
         mov       bl,99h                   ; znak "ô"
         cmp       al,94h                   ; je znak "î" ?
         je        l_366D                   ; je znak "î"
         mov       bl,9Ah                   ; znak "ö"
         cmp       al,81h                   ; je znak "Å" ?
         je        l_366D                   ; je znak "Å"
         mov       bl,al                    ; znak nen° zmànàn
l_366D:  mov       [di],bl                  ; uloëen° p©ek¢dovanÇho znaku
         jmp       short l_3641             ; dal®° znak k p©evodu

l_3671:  pop       ds                       ; n†vrat DS
         ;jmp       l_3675
         db        0e9h,0,0

l_3675:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_3631   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* o©ez†n° ©et. od mezer z obou stran
                                          ;* VSTUP: [SP+4] offset adresy ©etàzce
                                          ;*        [SP+6] segment adresy ©et.
                                          ;* (pouë°v† se p©i zad†n° jmÇna soub.)

l_367B   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3682
         db        0e9h,0,0

l_3682:  push      ds                       ; £schova DS
         cld                                ; smàr p©enosu dat nahoru
         ;lds       di,dword ptr [bp+4]      ; adresa ©etàzce
         db        0C5h,0BEh,4,0            ;!
         mov       bx,di                    ; adresa ©etàzce
         push      ds                       ; DS -> stack
         pop       es                       ; ES <- DS segment ©etàzce
         mov       cl,[di]                  ; dÇlka ©etàzce
         mov       ch,0                     ; CH <- 00
         jcxz      l_36AF                   ; je konec ©etàzce
         add       di,cx                    ; konec ©etàzce
                                           ;* nejd©°ve se o©eëou mezery na konci
l_3694:  cmp       byte ptr [di],20h        ; je mezera ?
         jne       l_369E                   ; nen° mezera - dal®° operace
         dec       di                       ; sn°ëen° ukazatele textu
         loop      l_3694                   ; test dal®°ho znaku
         jmp       short l_36AF             ; konec ©etàzce
                                           ;* zde se o©eëou mezeru na zaá†tku
l_369E:  mov       di,bx                    ; zaá†tek ©etàzce
         inc       di                       ; zaá†tek ©etàzce + 1 (prvn° znak)
         mov       si,di                    ; zaá†tek ©etàzce
         inc       si                       ; zaá†tek ©etàzce + 2 (druhò znak)
         cmp       byte ptr [di],20h        ; je znak mezery ?
         jne       l_36AF                   ; nen° znak mezery - konec
         push      cx                       ; £schova á°taáe znakñ
         repne     movsb                    ; vypu®tàn° mezery
         pop       cx                       ; n†vrat á°taáe znakñ
         loop      l_369E                   ; vypu®tàn° dal®° mezery
l_36AF:  mov       [bx],cl                  ; uloëen° novÇ dÇlky ©etàzce
         pop       ds                       ; n†vrat DS
         ;jmp       l_36B5
         db        0e9h,0,0

l_36B5:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_367B   ENDP

; -----------------------------------------------------------------------------
;        p©evod á°sla INTEGER na ©etàzec
; -----------------------------------------------------------------------------
                                          ;* p©evod á°sla INT na dekad. ©etàzec
                                          ;* VSTUP: [SP+4]=á°slo k dek¢dov†n°
                                          ;*        SP+6=ukl†dac° adresa ©etàzce

l_36BB   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_36C2
         db        0e9h,0,0

l_36C2:  sub       sp,9                     ; rezerva prostoru pro promànnÇ
         mov       ax,[bp+4]                ; á°slo k dek¢dov†n°
         push      ax                       ; á°slo k dek¢dov†n°
         mov       ax,0                     ; form†tovan† dÇlka ©etàzce
         push      ax                       ; form†tovan† dÇlka ©etàzce
         lea       di,[bp-0Bh]              ; offset ukl†dac° adresy
         push      ss                       ; segment ukl†dac° adresy
         mov       cl,8                     ; maxim†ln° moën† dÇlka ©etàzce
         call      l_0DF3                   ; p©evod á°sla INT na dekadickò tvar
         lea       di,[bp+6]                ; vòstupn° ukl†dac° adresa
         push      ss                       ; segment vòstupn° adresy
         push      di                       ; offset ukl†dac° adresy
         lea       di,[bp-0Bh]              ; offset adresy dek¢dovanÇho ©etàzce
         push      ss                       ; segment adresy dek¢d. ©etàzce
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,8                     ; dÇlka vòstupn°ho ©etàzce
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         ;jmp       l_36EA
         db        0e9h,0,0

l_36EA:  mov       dx,2                     ; offset ©etàzce v z†sobn°ku od SP
         mov       cl,8                     ; dÇlka ©etàzce
         mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         jmp       l_1475                   ; redukce dÇlky bufferu na minimum

l_36BB   ENDP

; -----------------------------------------------------------------------------
;        p©evod znaku na velkÇ p°smeno
; -----------------------------------------------------------------------------

l_36F5   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_36FC
         db        0e9h,0,0

l_36FC:  ;mov       al,[bp+4]                ; znak k p©evodu
         db        8Ah,86h,4,0              ;!
         cmp       al,ESCP                  ; je men®° znak meë <Esc> ?
         jb        l_370C                   ; je ©°dic° znak (men®° neë <Esc>)
         cmp       al,"a"-1                 ; je znak men®° neë "a" ?
         jbe       l_3714                   ; je znak men®° neë "a"
         cmp       al,"z"+1                 ; je znak vàt®° neë "z" ?
         jae       l_3714                   ; je znak vàt®° neë "z"

l_370C:  and       al,5Fh                   ; zru®en° p©°znaku malÇho p°smene
         or        al,40h                   ; p©evod na velkÇ p°smeno
         ;mov       [bp+4],al                ; uloëen° p©evedenÇho znaku
         db        88h,86h,4,0              ;!

l_3714:  mov       al,[bp+4]                ; p©evedenò znak
         xor       ah,ah                    ; AH <- 0
         mov       [bp+6],al                ; p©eveden° znak
         ;jmp       l_371F
         db        0e9h,0,0

l_371F:  mov       al,[bp+6]                ; p©evedenò znak
         xor       ah,ah                    ; AH <- 0
         mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      3                         ; n†vrat se zru®en°m parametrñ

l_36F5   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* doplnàn° editovanÇho ©†dku mezerami
                                          ;* VSTUP: [SP+4] poáet doplnànòch poz.
                                          ;*        [SP+6] pozice kurzoru

l_372A   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3731
         db        0e9h,0,0

l_3731:  push      ds                       ; DS -> stack
         pop       es                       ; ES <- DS datovò segment
         cld                                ; smàr p©enosu dat nahoru
                                           ;* doplnàn° bufferu znakñ mezerami
         mov       al,20h                   ; inicializaán° znak
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       bl,[di]                  ; skuteán† dÇlka textu v buff. ©†dku
         mov       bh,0                     ; BH <- 0
         ;mov       dx,[bp+6]                ; pozice kurzoru
         db        8Bh,96h,6,0              ;!
         add       di,dx                    ; pozice kurzoru v bufferu
         ;mov       cx,[bp+4]                ; poáet doplnànòch mezer
         db        8Bh,8Eh,4,0              ;!
         push      cx                       ; £schova poátu pozic k doplnàn°
         repne     stosb                    ; doplnàn° mezer do ©†dku
         pop       cx                       ; n†vrat poátu pozic k doplnàn°
                                           ;* doplnàn° bufferu atributñ znakñ
         mov       di,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         add       di,dx                    ; pozice kurzoru v bufferu
         mov       al,[di-1]                ; p©edchoz° atribut znakñ
         mov       ah,0                     ; AH <- 0
         add       dx,cx                    ; nov† pozice textu
         cmp       dx,bx                    ; je kurzor za koncem ©†dku ?
         ja        l_375E                   ; kurzor je za koncem ©†dku
         mov       ah,[di+1]                ; n†sleduj°c° atribut znaku
l_375E:  and       al,ah                    ; atribut souáinem sousedn°ch atr.
         repne     stosb                    ; doplnàn° atributñ ©†dku
         ;jmp       l_3765
         db        0e9h,0,0

l_3765:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_372A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* nastaven° novÇ dÇlky editov. ©†dku
                                          ;* VSTUP: [SP+4] nov† dÇlka ©†dku

l_376B   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3772
         db        0e9h,0,0

l_3772:  mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       bl,[di]                  ; poáet znakñ uloëenòch v text.©†dku
         mov       bh,0                     ; BH <- 0
         cmp       byte ptr [bx+di],11h     ; posledn° znak=11h (konec odst.) ?
         je        l_377F                   ; je konec odstavce - vymaëe se
         inc       bx                       ; nen° konec odstavce
l_377F:  ;mov       ax,[bp+4]                ; nov† dÇlka textovÇho ©†dku
         db        8Bh,86h,4,0              ;!
         dec       ax                       ; dÇlka - 1
         mov       [di],al                  ; novò poáet znakñ textu v bufferu
         inc       ax                       ; nov† dÇlka textu v bufferu
         sub       ax,bx                    ; rozd°l dÇlky novÇho a starÇho ©et.
         jbe       l_3790                   ; nen° del®° neë starò ©et.
         push      bx                       ; pozice pro doplnàn°
         push      ax                       ; poáet znakñ pro doplnàn°
         call      l_372A                   ; doplnàn° editov. ©†dku mezerami
l_3790:  ;jmp       l_3793
         db        0e9h,0,0

l_3793:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      2                         ; n†vrat se zru®en°m parametrñ

l_376B   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* odsun zbytku ©†dku INSERT
                                          ;* VSTUP: [SP+4]=poáet vloëenòch pozic
                                          ;*        [SP+6]=pozice v ©†dku

l_3799   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_37A0
         db        0e9h,0,0

l_37A0:  mov       ax,ds                    ; AX <- DS
         mov       es,ax                    ; ES <- DS
         std                                ; smàr posunu ukazatele dolñ
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       dl,[di]                  ; poáet znakñ v textovÇm ©†dku
         mov       dh,0                     ; DH <- 0
         mov       cx,dx                    ; poáet znakñ v textovÇm ©†dku
         mov       bx,dx                    ; poáet znakñ v textovÇm ©†dku
         ;add       bx,[bp+4]                ; BX+poáet vloëenòch pozic=nov† poz.
         db        3,9Eh,4,0                ;!
         cmp       bx,0FEh                  ; kontrola poátu znakñ v ©†dku
         jbe       l_37C1                   ; poáet znakñ nen° vàt®° neë 254
         mov       byte ptr ds:[d_F79D],8   ; p©°znak chyby-p©°li® dlouhò ©†dek
         jmp       short l_37EA             ; n†vrat p©i chybà

l_37C1:  ;sub       cx,[bp+6]                ; CX-pozice=poáet zbylòch znakñ
         db        2Bh,8Eh,6,0              ;!
         js        l_37EA                   ; konec - nen° ë†dnò znak k posunu
         inc       cx                       ; poáet znakñ k odsunu
         mov       [di],bl                  ; nov† dÇlka ©†dku
         mov       si,di                    ; buffer textovÇho ©†dku
         add       si,dx                    ; starò konec ©†dku
         add       di,bx                    ; novò konec ©†dku
         push      cx                       ; £schova poátu znakñ k odsunu
         repne     movsb                    ; odsun textu - funkce INSERT
         pop       cx                       ; n†vrat poátu znakñ k odsunu
         mov       di,offset d_ED59         ; buffer atributñ znakñ ©†dku
         mov       si,di                    ; buffer atributñ znakñ ©†dku
         add       si,dx                    ; starò konec ©†dku
         add       di,bx                    ; novò konec ©†dku
         repne     movsb                    ; odsun atributñ - funkce INSERT
         ;push      word ptr [bp+6]          ; pozice pro doplnàn° mezer
         db        0FFh,0B6h,6,0            ;!
         ;push      word ptr [bp+4]          ; poáet vloëenòch mezer
         db        0FFh,0B6h,4,0            ;!
         call      l_372A                   ; doplnàn° editov. ©†dku mezerami
l_37EA:  ;jmp       l_37ED
         db        0e9h,0,0

l_37ED:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_3799   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* p©°sun zbytku ©†dku DELETE
                                          ;* VSTUP: [SP+4]=poáet ru®enòch pozic
                                          ;*        [SP+6]=pozice v ©†dku

l_37F3   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_37FA
         db        0e9h,0,0

l_37FA:  mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       bl,[di]                  ; dÇlka textu v bufferu
         mov       bh,0                     ; BH <- 0
         ;mov       ax,[bp+6]                ; pozice v ©†dku
         db        8Bh,86h,6,0              ;!
         mov       cx,bx                    ; dÇlka textu v bufferu
         sub       cx,ax                    ; poáet znakñ za kurzorem
         js        l_3842                   ; nen° ë†dnò znak k posunu - konec
         ;mov       dx,[bp+4]                ; poáet ru®enòch pozic
         db        8Bh,96h,4,0              ;!
         mov       si,di                    ; zaá†tek bufferu textovÇho ©†dku
         add       si,ax                    ; adresa znaku v bufferu
         dec       si                       ; adresa znaku v bufferu - 1
         cmp       byte ptr [si],0FFh       ; je prefix dvojn†sobnÇ ®°©ky znaku?
         jne       l_381C                   ; nen° prefix dvojn†. ®°©ky znaku
         dec       ax                       ; sn°ëen° adresy znaku v bufferu
         inc       dx                       ; zvò®en° poátu ru®enòch pozic
         inc       cx                       ; zvò®en° poátu znakñ v bufferu
l_381C:  sub       cx,dx                    ; poáet p©isouvanòch znakñ
         jge       l_3825                   ; jsou nàjakÇ znaky k p©°sunu
         dec       ax                       ; nov† dÇlka textu
         mov       [di],al                  ; uloëen° novÇ dÇlky textu v bufferu
         jmp       short l_3842             ; n†vrat z obsluhy

l_3825:  push      ds                       ; DS -> stack
         pop       es                       ; ES <- DS
         cld                                ; smàr posunu nahoru
         sub       bx,dx                    ; nov† dÇlka textu v bufferu
         mov       [di],bl                  ; nov† dÇlka textu v bufferu
         inc       cx                       ; poáet posouvanòch znakñ
         add       di,ax                    ; adresa kurzoru v bufferu
         mov       si,di                    ; zdrojov† adresa
         add       si,dx                    ; adresa zaá†tku textu k p©°sunu
         push      cx                       ; £schova poátu p©isouvanòch znakñ
         repne     movsb                    ; p©°sun zbytku textu
         pop       cx                       ; n†vrat poátu p©isouvanòch znakñ
         mov       di,offset d_ED59         ; buffer atributñ znakñ textu
         add       di,ax                    ; adresa kurzoru v bufferu
         mov       si,di                    ; zdrojov† adresa
         add       si,dx                    ; adresa zaá†tku textu k p©°sunu
         repne     movsb                    ; p©°sun zbytku textu
l_3842:  ;jmp       l_3845
         db        0e9h,0,0

l_3845:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_37F3   ENDP

; -----------------------------------------------------------------------------
;        nalezen° zaá†tku slova (VSTUP: [SP+2] (4) adresa pozice kurzoru)
; -----------------------------------------------------------------------------

l_384B   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3852
         db        0e9h,0,0

l_3852:  ;les       si,dword ptr [bp+4]      ; adresa ukazatele ©†dku
         db        0C4h,0B6h,4,0            ;!
         mov       ax,es:[si]               ; ukazatel textu v textovÇm ©†dku
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       cl,[di]                  ; dÇlka text v ©†dkovÇm bufferu
         dec       ax                       ; ukazatel znakñ - 1
         add       di,ax                    ; pozice znaku v bufferu ©†dku
l_3861:  inc       ax                       ; zvò®en° ukazatele znakñ
         inc       di                       ; zvò®en° adresy znaku v bufferu
         cmp       byte ptr [di],20h        ; je platnò znak ?                             ; ' '
         ja        l_3871                   ; je platnò znak (vàt®° neë mezera)
         cmp       byte ptr [di],15h        ; je znak "≠" ? (platnò znak)
         je        l_3871                   ; je znak "≠"
         cmp       al,cl                    ; dosaëeno jië konce textu ?
         jbe       l_3861                   ; nejsou je®tà v®echny znaky
l_3871:  mov       es:[si],ax               ; uloëen° novÇ pozice textu
         ;jmp       l_3877
         db        0e9h,0,0

l_3877:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_384B   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* nalezen° konce slova
                                          ;* VSTUP: [SP+4] pozice kurzoru

l_387D   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3884
         db        0e9h,0,0

l_3884:  ;les       si,dword ptr [bp+4]      ; adresa ukazatele ©†dku
         db        0C4h,0B6h,4,0            ;!
         mov       ax,es:[si]               ; ukazatel textu v textovÇm ©†dku
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       cl,[di]                  ; dÇlka text v ©†dkovÇm bufferu
         dec       ax                       ; ukazatel znakñ - 1
         add       di,ax                    ; pozice znaku v bufferu ©†dku
l_3893:  inc       ax                       ; zvò®en° ukazatele znakñ
         inc       di                       ; zvò®en° adresy znaku v bufferu
         cmp       byte ptr [di],15h        ; je znak "≠" ? (platnò znak)
         je        l_389F                   ; je znak "≠"
         cmp       byte ptr [di],20h        ; je platnò znak ?
         jbe       l_38A3                   ; nen° - je ©°dic° znak
l_389F:  cmp       al,cl                    ; dosaëeno jië konce textu ?
         jbe       l_3893                   ; nejsou je®tà v®echny znaky
l_38A3:  mov       es:[si],ax               ; uloëen° novÇ pozice textu
         ;jmp       l_38A9
         db        0e9h,0,0

l_38A9:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_387D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* nalezen° konce p©ede®lÇho slova
                                          ;* VSTUP: [SP+4] pozice kurzoru

l_38AF   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_38B6
         db        0e9h,0,0

l_38B6:  ;les       si,dword ptr [bp+4]      ; adresa ukazatele ©†dku
         db        0C4h,0B6h,4,0            ;!
         mov       cx,es:[si]               ; ukazatel textu v textovÇm ©†dku
         jcxz      l_38D1                   ; nen° poëadovanò ë†dnò znak
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         add       di,cx                    ; adresa konce textu
l_38C4:  cmp       byte ptr [di],15h        ; je znak "≠" ? (platnò znak)
         je        l_38D1                   ; je znak "≠" - konec
         cmp       byte ptr [di],20h        ; je platnò znak ?
         ja        l_38D1                   ; je platnò znak - konec
         dec       di                       ; sn°ëen° ukazatele textu
         loop      l_38C4                   ; test dal®°ho znaku
l_38D1:  mov       es:[si],cx               ; uloëen° novÇho poátu znakñ
         ;jmp       l_38D7
         db        0e9h,0,0

l_38D7:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_38AF   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* nalezen° zaá†tku slova
                                          ;* VSTUP: [SP+4] pozice kurzoru

l_38DD   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_38E4
         db        0e9h,0,0

l_38E4:  ;les       si,dword ptr [bp+4]      ; adresa ukazatele ©†dku
         db        0C4h,0B6h,4,0            ;!
         mov       cx,es:[si]               ; ukazatel textu v textovÇm ©†dku
         jcxz      l_38FF                   ; nen° poëadovanò ë†dnò znak
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         add       di,cx                    ; adresa konce textu
l_38F2:  cmp       byte ptr [di],15h        ; je znak "≠" ? (platnò znak)
         je        l_38FC                   ; je znak "≠" - dal®° znak
         cmp       byte ptr [di],20h        ; je platnò znak ?
         jbe       l_38FF                   ; nen° platnò znak - konec
l_38FC:  dec       di                       ; sn°ëen° ukazatele textu
         loop      l_38F2                   ; test dal®°ho znaku
l_38FF:  mov       es:[si],cx               ; uloëen° novÇho poátu znakñ
         ;jmp       l_3905
         db        0e9h,0,0

l_3905:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      4                         ; n†vrat se zru®en°m parametrñ

l_38DD   ENDP

; -----------------------------------------------------------------------------
;        rozdàlen° textovÇho ©†dku ([SP+2] (2) pozice k rozdàlen° ©†dku)
; -----------------------------------------------------------------------------

l_390B   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3912
         db        0e9h,0,0

l_3912:  push      ds                       ; DS -> stack
         pop       es                       ; ES <- DS
         cld                                ; smàr posunu ukazatele nahoru
         mov       si,offset d_EC59         ; buffer textovÇho ©†dku
         mov       di,offset d_F059         ; druh† á†st ©†dku
         mov       cl,[si]                  ; dÇlka textu v ©†dkovÇm bufferu
         mov       ch,0                     ; CH <- 0
         mov       [di],ch                  ; vynulov†n° bufferu 2
         ;mov       bx,[bp+4]                ; pozice kurzoru
         db        8Bh,9Eh,4,0              ;!
         sub       cx,bx                    ; poáet zbylòch znakñ do konce ©†dku
         jc        l_3947                   ; kurzor je za koncem textu
         cmp       byte ptr [bx+si-1],0FFh  ; je znak dvojn†sobnÇ ®°©ky ?
         jne       l_3930                   ; nen° znak dvojn†sobnÇ ®°©ky
         dec       bx                       ; sn°ëen° ukazatele na p©ede®lò znak
l_3930:  inc       cx                       ; poáet znakñ + 1
         mov       [di],cl                  ; dÇlka druhÇ á†sti ©†dku
         mov       [si],bl                  ; dÇlka prvn° á†sti ©†dku
         dec       byte ptr [si]            ; sn°ëen° dÇlky prvn° á†sti ©†dku
         add       si,bx                    ; konec prvn° á†sti ©†dku
         inc       di                       ; zaá†tek druhÇ á†sti ©†dku
         push      cx                       ; £schova dÇlky druhÇ á†sti ©†dku
         repne     movsb                    ; p©enos druhÇ á†sti ©†dku
         pop       cx                       ; n†vrat dÇlky druhÇ á†sti ©†dku
         lea       si,[bx+d_ED59]           ; buffer atributñ znakñ ©†dku
         mov       di,offset d_F159+1       ; druh† á†st atributñ ©†dku po rozd.
         repne     movsb                    ; p©enos druhÇ á†sti atributñ
l_3947:  ;jmp       l_394A
         db        0e9h,0,0

l_394A:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      2                         ; n†vrat se zru®en°m parametrñ

l_390B   ENDP

; -----------------------------------------------------------------------------
;        spojen° textovòch ©†dkñ ([SP+2] (2) pozice k p©ipojen° druhÇ á†sti)
; -----------------------------------------------------------------------------

l_3950   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_3957
         db        0e9h,0,0

l_3957:  push      ds                       ; DS -> stack
         pop       es                       ; ES <- DS
         cld                                ; smàr posunu ukazatele nahoru
         mov       si,offset d_F059         ; druh† á†st ©†dku
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       cl,[si]                  ; dÇlka p©ipojovanÇho textu
         mov       ch,0                     ; CH <- 0
         ;mov       bx,[bp+4]                ; pozice kurzoru
         db        8Bh,9Eh,4,0              ;!
         sub       cx,bx                    ; poáet zbylòch znakñ do konce ©†dku
         js        l_3995                   ; kurzor je za koncem textu
         inc       cx                       ; poáet znakñ
         mov       ax,cx                    ; poáet znakñ
         mov       dl,[di]                  ; poáet znakñ v ©†dkovÇm bufferu
         mov       dh,0                     ; DH <- 0
         inc       dx                       ; poáet znakñ + 1
         add       al,dl                    ; souáet á†st° ©†dku
         jnc       l_3980                   ; nen° p©eteáen° ©†dku
         mov       word ptr ds:[d_F79D],8   ; chyba p©eteáen° ©†dku
         jmp       short l_3995             ; n†vrat

l_3980:  add       [di],cl                  ; zvàt®en° dÇlky ©†dku
         add       si,bx                    ; adresa kurzoru (odkud se p©ipoj°)
         add       di,dx                    ; konec textu v ©†dkovÇm bufferu
         push      cx                       ; £schova dÇlky p©en†®enòch dat
         repne     movsb                    ; p©enos zbytku ©†dku - spojen°
         pop       cx                       ; n†vrat dÇlky p©en†®enòch dat
         lea       si,[bx+d_F159]           ; adresa atributñ druhÇ á†sti
         mov       di,offset d_ED59         ; buffer atributñ znakñ
         add       di,dx                    ; konec textu v bufferu atributñ
         repne     movsb                    ; p©enso zbytku atributñ - spojen°
l_3995:  ;jmp       l_3998
         db        0e9h,0,0

l_3998:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret      2                         ; n†vrat se zru®en°m parametrñ

l_3950   ENDP

; -----------------------------------------------------------------------------
;        test, zda m† soubor nàjakò ©†dek
; -----------------------------------------------------------------------------

l_399E   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_39A5
         db        0e9h,0,0

l_39A5:  mov       di,offset d_0274         ; tabulka definic ©†dkñ
         mov       cx,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         jcxz      l_39C4
         mov       bx,cx
         add       bx,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         shl       bx,1
         shl       bx,1
l_39B8:  mov       dx,[bx+di]
         or        dx,[bx+di+2]
         jnz       l_39C9
         sub       bx,4
         loop      l_39B8
l_39C4:  mov       byte ptr ds:[d_E6A8],1   ; 0=p©°znak modifikace textu
l_39C9:  mov       word ptr ds:[d_F7A3],cx  ; skuteánò poáet ©†dkñ prostoru
         ;jmp       l_39D0
         db        0e9h,0,0

l_39D0:  mov       sp,bp
         pop       bp
         ret

l_399E   ENDP

; -----------------------------------------------------------------------------
;        uvolnàn° ©†dku z pamàti (VSTUP: [SP+2] (4) adresa ukazatele ©†dku)
; -----------------------------------------------------------------------------

l_39D4   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_39DB
         db        0e9h,0,0

; ------ kontrola, zda je ©†dek volnò

l_39DB:  les       di,dword ptr [bp+4]      ; adresa ukazatele ©†dku
         les       ax,dword ptr es:[di]     ; adresa ©†dku v pamàti
         mov       dx,es
         push      dx
         push      ax
         xor       ax,ax                    ; AX <- 0
         xor       dx,dx                    ; DX <- 0
         pop       bx
         pop       cx
         call      l_1618                   ; test neshody DX:AX/CX:BX(ZY=shoda)
         jne       l_39F3                   ; adresa nen° 0
         ;jmp       l_3A25                  ; ©†dek je jië uvolnàn
         db        0e9h
         dw        l_3A25-$-2

; ------ uvolnàn° ©†dku z pamàti

l_39F3:  les       di,dword ptr [bp+4]      ; adresa ukazatele adresy ©†dku
         push      es
         push      di
         les       di,dword ptr [bp+4]      ; adresa ukazatele adresy ©†dku
         les       di,dword ptr es:[di]     ; adresa ©†dku k uvolnàn°
         mov       ax,es                    ; segment adresy ©†dku k uvolnàn°
         push      ax
         les       di,dword ptr [bp+4]      ; adresa ukazatele adresy ©†dku
         les       di,dword ptr es:[di]     ; adresa ©†dku k uvolnàn°
         xchg      ax,di                    ; offset adresy ©†dku
         xchg      ax,di                    ; DI <- offset adresy ©†dku
         pop       es                       ; ES <- segment adresy ©†dku
         mov       al,es:[di]               ; pñvodn° dÇlka ©†dku
         xor       ah,ah
         inc       ax                       ; váetnà bajtu dÇlky
         call      l_06A4                   ; uvolnàn° pamàüovÇho bloku

; ------ nulov†n° ukazatele adresy ©†dku

         les       di,dword ptr [bp+4]      ; adresa ukazatele adresy ©†dku
         push      es
         push      di
         xor       ax,ax                    ; AX <- 0
         xor       dx,dx                    ; DX <- 0
         pop       di
         pop       es
         mov       es:[di],ax               ; nulov†n° ukazatele adresy ©†dku
         mov       es:[di+2],dx

l_3A25:  ;jmp       l_3A28
         db        0e9h,0,0

l_3A28:  mov       sp,bp
         pop       bp
         ret      4

l_39D4   ENDP

; -----------------------------------------------------------------------------
;        uvolnàn° ©†dku z pamàti (VSTUP: [SP+2] (2) á°slo ©†dku ke zru®en°)
; -----------------------------------------------------------------------------

l_3A2E   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3A35
         db        0e9h,0,0

l_3A35:  mov       ax,[bp+4]                ; á°slo ©†dku ke zru®en°
         add       ax,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic ©†dkñ
         push      ds
         push      di
         call      l_39D4                   ; uvolnàn° ©†dku z pamàti
         ;jmp       l_3A4D
         db        0e9h,0,0

l_3A4D:  mov       sp,bp
         pop       bp
         ret       2

l_3A2E   ENDP

; -----------------------------------------------------------------------------
;        stanoven° adresy pro uloëen° ©†dku
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (2) nov† dÇlka ©†dku
;        [SP+4] (4)
;        [SP+8] (4) adresa definice ©†dku v tabulce ©†dkñ
; -----------------------------------------------------------------------------

l_3A53   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3A5A
         db        0e9h,0,0

l_3A5A:  sub       sp,5
         lea       di,[bp-7]
         push      ss
         push      di
         mov       ax,[bp+4]                ; poëadovan† nov† dÇlka ©†dku
         call      l_05AD                   ; p©idàlen° novÇho pamàüovÇho bloku
         mov       ax,ss
         mov       bx,word ptr ds:[d_F7AB]  ; uschovanò ukazatel z†sobn°ku SP
         mov       cl,4
         shr       bx,cl
         or        bx,bx
         jnz       l_3A78
         mov       bh,10h
l_3A78:  add       ax,bx
         sub       ax,word ptr ds:[d_018A+2]; adresa zaá†tku volnÇ pamàti
         cmp       ax,80h
         mov       al,0
         jnc       l_3A86
         inc       ax
l_3A86:  ;mov       [bp-3],al
         db        88h,86h,0FDh,0FFh        ;!
         mov       al,[bp-3]
         xor       ah,ah
         or        ax,ax
         jnz       l_3A96
         ;jmp       l_3AB1
         db        0e9h
         dw        l_3AB1-$-2

; ------ p©i chybà opàt uvolnàn° ©†dku z pamàti

l_3A96:  lea       di,[bp-7]
         push      ss
         push      di                       ; adresa ukazatele pamàü. bloku
         mov       ax,[bp+4]                ; pñvodn° velikost pamàü. bloku
         call      l_06A4                   ; uvolnàn° pamàüovÇho bloku
         xor       ax,ax
         xor       dx,dx
         mov       [bp-7],ax                ; nulov†n° ukazatele ©†dku
         mov       [bp-5],dx
         mov       ax,5                     ; chyba - nedostatek pamàti
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu


l_3AB1:  les       ax,dword ptr [bp-7]
         mov       dx,es
         mov       [bp+6],ax
         mov       [bp+8],dx
         ;jmp       l_3ABF
         db        0e9h,0,0

l_3ABF:  les       ax,dword ptr [bp+6]
         mov       dx,es
         mov       sp,bp
         pop       bp
         ret       6

l_3A53   ENDP

; -----------------------------------------------------------------------------
;        p©esun bloku definic ©†dkñ
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] poáet ©†dkñ k p©esunu
;        [SP+4] novò poá†tek bloku ©†dkñ (á°slo ©†dku)
;        [SP+6] starò poá†tek bloku ©†dkñ (á°slo ©†dku)
; -----------------------------------------------------------------------------

l_3ACA   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3AD1
         db        0e9h,0,0

; ------ kontrola, zda jsou nàjakÇ ©†dky

l_3AD1:  dec       sp
         dec       sp
         mov       ax,[bp+4]                ; poáet ©†dkñ
         cmp       ax,0
         jle       l_3ADE
         ;jmp       l_3AE1
         db        0e9h
         dw        l_3AE1-$-2

l_3ADE:  jmp       l_3B61

; ------ p©esun bloku ©†dkñ

l_3AE1:  mov       ax,[bp+8]                ; starò poá†tek bloku ©†dkñ
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic ©†dkñ
         push      ds
         push      di                       ; zdrojov† adresa
         mov       ax,[bp+6]                ; novò poá†tek bloku ©†dkñ
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic ©†dkñ
         push      ds
         push      di                       ; c°lov† adresa
         mov       ax,[bp+4]                ; poáet ©†dkñ
         mov       cx,2
         shl       ax,cl                    ; p©evod na poáet bajtñ
         call      l_0F2E                   ; posun dat (s p©ekryvem)

; ------ vòpoáet poátu ©†dkñ k nulov†n°

         mov       ax,[bp+8]                ; starò poá†tek bloku ©†dkñ
         mov       [bp-4],ax
         mov       ax,[bp+4]                ; poáet ©†dkñ k p©esunu
         push      ax
         mov       ax,[bp+8]                ; starò poá†tek bloku ©†dkñ
         sub       ax,[bp+6]                ; offset posunu bloku ©†dkñ
         call      l_10B4                   ; absolutn° hodnota á°sla AX
         pop       cx
         xchg      ax,cx
         cmp       ax,cx                    ;
         jg        l_3B24
         ;jmp       l_3B44
         db        0e9h
         dw        l_3B44-$-2

l_3B24:  mov       ax,[bp+8]
         cmp       ax,[bp+6]
         jg        l_3B2F
         ;jmp       l_3B38
         db        0e9h
         dw        l_3B38-$-2

; ------ vynulov†n° novòch volnòch ©†dkñ

l_3B2F:  mov       ax,[bp+6]
         add       ax,[bp+4]
         mov       [bp-4],ax
l_3B38:  mov       ax,[bp+8]
         sub       ax,[bp+6]
         call      l_10B4                   ; absolutn° hodnota á°sla AX
         mov       [bp+4],ax                ; poáet ©†dkñ k nulov†n°
l_3B44:  mov       ax,[bp-4]                ; á°slo poá†teán°ho ©†dku
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic ©†dkñ
         push      ds
         push      di                       ; adresa
         mov       ax,[bp+4]                ; poáet ©†dkñ k nulov†n°
         mov       cx,2
         shl       ax,cl
         push      ax                       ; dÇlka
         mov       ax,0                     ; konstanta
         call      l_0F25                   ; vynulov†n° bufferu konstantou
l_3B61:  ;jmp       l_3B64
         db        0e9h,0,0

l_3B64:  mov       sp,bp
         pop       bp
         ret       6

l_3ACA   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_3B6A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3B71
         db        0e9h,0,0

l_3B71:  ;mov       ax,[bp+6]
         db        8Bh,86h,6,0              ;!
         ;mov       bx,[bp+4]
         db        8Bh,9Eh,4,0              ;!
         mov       di,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         mov       si,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         mov       cx,si
         add       cx,bx
         cmp       cx,di
         ja        l_3B91
         mov       cx,ax
         add       cx,bx
         cmp       cx,di
         jbe       l_3B99
l_3B91:  mov       word ptr ds:[d_F79D],6   ; k¢d chyby - p©ekroáen poáet ©†dkñ
         jmp       short l_3BF7

l_3B99:  mov       dx,word ptr ds:[d_E6A0]  ; ©†dek uschovanÇ znaáky v textu
         cmp       dx,ax
         jb        l_3BA9
         add       dx,bx
         cmp       dx,di
         jbe       l_3BA9
         mov       dx,di
l_3BA9:  mov       word ptr ds:[d_E6A0],dx  ; ©†dek uschovanÇ znaáky v textu
         mov       cx,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
         mov       dx,word ptr ds:[d_E692]  ; ©†dek konce bloku
         cmp       cx,ax
         jb        l_3BBB
         add       cx,bx
l_3BBB:  cmp       dx,ax
         jb        l_3BC1
         add       dx,bx
l_3BC1:  cmp       cx,di
         jbe       l_3BC7
         mov       cx,di
l_3BC7:  cmp       dx,di
         jbe       l_3BCD
         mov       dx,di
l_3BCD:  mov       word ptr ds:[d_E690],cx  ; ©†dek zaá†tku bloku
         mov       word ptr ds:[d_E692],dx  ; ©†dek konce bloku
         cmp       ax,si
         jbe       l_3BE0
         add       ax,bx
         dec       ax
         mov       si,ax
         jmp       short l_3BF7

l_3BE0:  push      bx
         push      si
         mov       dx,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         add       dx,ax
         push      dx                       ; starò poá†tek bloku
         add       dx,bx
         push      dx                       ; novò poá†tek bloku
         sub       si,ax
         inc       si
         push      si                       ; poáet ©†dkñ
         call      l_3ACA                   ; p©esun bloku definic ©†dkñ
         pop       si
         pop       bx
         add       si,bx
l_3BF7:  mov       word ptr ds:[d_F7A3],si  ; skuteánò poáet ©†dkñ prostoru
         ;jmp       l_3BFE
         db        0e9h,0,0

l_3BFE:  mov       sp,bp
         pop       bp
         ret       4

l_3B6A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_3C04   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3C0B
         db        0e9h,0,0

l_3C0B:  ;mov       ax,[bp+6]
         db        8Bh,86h,6,0              ;!
         mov       cx,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         ;mov       bx,[bp+4]
         db        8Bh,9Eh,4,0              ;!
         mov       si,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
         cmp       si,ax
         jbe       l_3C25
         sub       si,bx
         mov       word ptr ds:[d_E690],si  ; ©†dek zaá†tku bloku
l_3C25:  mov       di,word ptr ds:[d_E692]  ; ©†dek konce bloku
         cmp       di,ax
         jb        l_3C33
         sub       di,bx
         mov       word ptr ds:[d_E692],di  ; ©†dek konce bloku
l_3C33:  cmp       di,si
         jge       l_3C3C
         mov       byte ptr ds:[d_E6A9],0   ; 1=p©°znak zapnut° zobrazen° bloku
l_3C3C:  cmp       ax,cx
         ja        l_3C84
         mov       dx,ax
         add       dx,bx
         cmp       word ptr ds:[d_E6A0],dx  ; ©†dek uschovanÇ znaáky v textu
         jb        l_3C4E
         sub       word ptr ds:[d_E6A0],bx  ; ©†dek uschovanÇ znaáky v textu
l_3C4E:  push      ax
         push      bx
         push      cx
l_3C51:  push      dx
         push      ax
         push      ax
         call      l_3A2E                   ; uvolnàn° ©†dku z pamàti
         pop       ax
         pop       dx
         inc       ax
         cmp       ax,dx
         jb        l_3C51
         pop       cx
         pop       bx
         pop       ax
         cmp       dx,cx
         jbe       l_3C6B
         dec       ax
         mov       word ptr ds:[d_F7A3],ax  ; skuteánò poáet ©†dkñ prostoru
         jmp       short l_3C84

l_3C6B:  mov       si,cx
         sub       si,bx
         mov       word ptr ds:[d_F7A3],si  ; skuteánò poáet ©†dkñ prostoru
         sub       cx,dx
         inc       cx
         mov       di,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         add       dx,di
         push      dx
         add       ax,di
         push      ax
         push      cx
         call      l_3ACA                   ; p©esun bloku definic ©†dkñ
l_3C84:  ;jmp       l_3C87
         db        0e9h,0,0

l_3C87:  mov       sp,bp
         pop       bp
         ret       4

l_3C04   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_3C8D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3C94
         db        0e9h,0,0

; ------ test, zda je ©†dek definov†n

l_3C94:  les       di,dword ptr [bp+8]      ; adresa definice ©†dku
         les       ax,dword ptr es:[di]     ; adresa ©†dku v pamàti
         mov       dx,es
         push      dx
         push      ax
         xor       ax,ax                    ; AX <- 0
         xor       dx,dx                    ; DX <- 0
         pop       bx
         pop       cx
         call      l_1609                   ; test shody DX:AX/CX:BX (NZ=shoda)
         jnz       l_3CAC                   ; ©†dek nen° definov†n
         ;jmp       l_3CC1
         db        0e9h
         dw        l_3CC1-$-2

; ------ zru®en° definice ©†dku

l_3CAC:  les       di,dword ptr [bp+4]
         push      es
         push      di
         xor       ax,ax                    ; AX <- 0
         xor       dx,dx                    ; DX <- 0
         pop       di
         pop       es
         mov       es:[di],ax
         mov       es:[di+2],dx
         ;jmp       l_3D13
         db        0e9h
         dw        l_3D13-$-2

l_3CC1:  les       di,dword ptr [bp+4]
         push      es
         push      di
         sub       sp,4
         les       di,dword ptr [bp+8]
         les       di,dword ptr es:[di]
         push      es
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku

         call      l_135F
         inc       ax
         push      ax
         call      l_3A53                   ; stanoven° adresy pro uloëen° ©†dku
         pop       di
         pop       es
         mov       es:[di],ax
         mov       es:[di+2],dx
         les       di,dword ptr [bp+4]
         les       ax,dword ptr es:[di]
         mov       dx,es
         push      dx
         push      ax
         xor       ax,ax
         xor       dx,dx
         pop       bx
         pop       cx
         call      l_1618                   ; test neshody DX:AX/CX:BX(ZY=shoda)
         jnz       l_3CFC
         ;jmp       l_3D13
         db        0e9h
         dw        l_3D13-$-2

l_3CFC:  les       di,dword ptr [bp+4]
         les       di,dword ptr es:[di]
         push      es
         push      di
         les       di,dword ptr [bp+8]
         les       di,dword ptr es:[di]
         push      es
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
l_3D13:  ;jmp       l_3D16
         db        0e9h,0,0

l_3D16:  mov       sp,bp
         pop       bp
         ret       8

l_3C8D   ENDP

; -----------------------------------------------------------------------------
;        test, zda je ©†dek definov†n (ZY=je)
; -----------------------------------------------------------------------------

l_3D1C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3D23
         db        0e9h,0,0

l_3D23:  mov       ax,[bp+4]
         add       ax,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         les       ax,ds:[d_0274+di]        ; adresa ©†dku
         mov       dx,es
         push      dx
         push      ax
         xor       ax,ax                    ; AX <- 0
         xor       dx,dx                    ; DX <- 0
         pop       bx
         pop       cx
         call      l_1609                   ; test shody DX:AX/CX:BX (NZ=shoda)
         mov       [bp+6],al
         ;jmp       l_3D46
         db        0e9h,0,0

l_3D46:  mov       al,[bp+6]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       3

l_3D1C   ENDP

; -----------------------------------------------------------------------------
;        uloëen° ©†dku do souboru
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa textu ©†dku k uloëen° do souboru
;        [SP+6] (4) adresa ukazatele definice ©†dku
; -----------------------------------------------------------------------------

l_3D53   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3D5A
         db        0e9h,0,0

l_3D5A:  les       di,dword ptr [bp+8]
         push      es
         push      di
         call      l_39D4                   ; uvolnàn° ©†dku z pamàti

         les       di,dword ptr [bp+4]      ; adresa textu ©†dku k uloëen°
         mov       al,es:[di]               ; dÇlka textu ©†dku
         xor       ah,ah
         cmp       ax,0                     ; je ©†dek definov†n ?
         jg        l_3D72                   ; ©†dek je platnò
         ;jmp       l_3DBC
         db        0e9h
         dw        l_3DBC-$-2

l_3D72:  les       di,dword ptr [bp+8]      ; adresa definice ©†dku
         push      es                       ; adresa definice ©†dku
         push      di
         sub       sp,4
         les       di,dword ptr [bp+4]      ; adresa textu ©†dku k uloëen°
         mov       al,es:[di]               ; dÇlka textu ©†dku
         xor       ah,ah
         inc       ax
         push      ax                       ; nov† dÇlka ©†dku
         call      l_3A53                   ; stanoven° adresy pro uloëen° ©†dku
         pop       di                       ; adresa definice ©†dku
         pop       es
         mov       es:[di],ax               ; nov† adresa ©†dku
         mov       es:[di+2],dx

; ------ test, zda je ©†dek volnò (adresa = 0, jinak nedostatek pamàti)

         les       di,dword ptr [bp+8]      ; adresa definice ©†dku
         les       ax,dword ptr es:[di]     ; adresa ©†dku
         mov       dx,es
         push      dx
         push      ax
         xor       ax,ax                    ; AX <- 0
         xor       dx,dx                    ; DX <- 0
         pop       bx
         pop       cx
         call      l_1618                   ; test neshody DX:AX/CX:BX(ZY=shoda)
         jnz       l_3DA8                   ; adresa je platn†
         ;jmp       l_3DBC                  ; jinak chyba nedostatku pamàti
         db        0e9h
         dw        l_3DBC-$-2

; ------ p©enesen° textu ©†dku do souboru

l_3DA8:  les       di,dword ptr [bp+8]      ; adresa definice ©†dku
         les       di,dword ptr es:[di]     ; adresa ©†dku
         push      es
         push      di
         les       di,dword ptr [bp+4]      ; adresa textu ©†dku k uloëen°
         push      es
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
l_3DBC:  ;jmp       l_3DBF
         db        0e9h,0,0

l_3DBF:  mov       sp,bp
         pop       bp
         ret       8

l_3D53   ENDP

; -----------------------------------------------------------------------------
;        uloëen° textu ©†dku do aktivn°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa bufferu s textem ©†dku
;        [SP+6] (2) á°slo poëadovanÇho ©†dku
; -----------------------------------------------------------------------------

l_3DC5   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3DCC
         db        0e9h,0,0

l_3DCC:  mov       ax,[bp+8]                ; á°slo ©†dku
         add       ax,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic ©†dkñ
         push      ds
         push      di
         les       di,dword ptr [bp+4]      ; adresa bufferu s textem ©†dku
         push      es
         push      di
         call      l_3D53                   ; uloëen° ©†dku do souboru
         ;jmp       l_3DE9
         db        0e9h,0,0

l_3DE9:  mov       sp,bp
         pop       bp
         ret       6

l_3DC5   ENDP

; -----------------------------------------------------------------------------
;        uloëen° editovanÇho ©†dku do souboru (zad†n adresou ukazatele)
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa bufferu atributñ
;        [SP+6] (4) adresa bufferu textu
;        [SP+10] (4) adresa ukazatele definice ©†dku
; -----------------------------------------------------------------------------

l_3DEF   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3DF6
         db        0e9h,0,0

; ------ p©°prava registrñ k dek¢dov†n° ©†dku

l_3DF6:  sub       sp,100h
         push      ds
         push      bp
         ;lds       di,dword ptr [bp+8]     ; buffer textu ©†dku
         db        0C5h,0BEh,8,0            ;!
         ;lds       si,dword ptr [bp+4]     ; buffer atributñ ©†dku
         db        0C5h,0B6h,4,0            ;!
         lea       bp,[bp-102h]             ; pracovn° buffer k dek¢dov†n° textu
         push      bp
         xor       bx,bx                    ; á°taá dÇlky ©†dku a p©°znak atrib.
         mov       cl,[di]                  ; poáet znakñ textu
         mov       ch,0                     ; st©adaá p©°znakñ
         jcxz      l_3E66                   ; nen° ë†dnò znak

; ------ test, zda byla zmàna atributñ textu

l_3E11:  inc       si                       ; zvò®en° ukazatele atributñ
         inc       di                       ; zvò®en° ukazatele textu
         inc       bp                       ; zvò®en° ukazatele v bufferu
         mov       al,[si]                  ; znak atributu
         xor       al,bh                    ; je zmàna atributu ?
         jz        l_3E50                   ; nen° zmàna atributu

; ------ uloëen° bajtñ p©ep°naáñ pro zapnut° p©ep°naáe

         and       al,bh                    ; bit zmàny atributu
         mov       ah,0                     ; á°taá znaku p©ep°naáe
l_3E1E:  shr       al,1                     ; rotov†n° p©°znakñ p°sma
         jnc       l_3E2D                   ; nen° p©°znak p°sma
         cmp       bl,255                   ; je ©†dek jië plnò ?
         je        l_3E60                   ; chyba - ©†dek p©°li® dlouhò
         mov       [bp],ah                  ; uloëen° znaku
         inc       bp                       ; zvò®en° ukazatele bufferu
         inc       bl                       ; zvò®en° á°taáe bajtñ v bufferu
l_3E2D:  inc       ah                       ; zvò®en° znaku
         or        al,al                    ; jsou jië v®echny znaky ?
         jnz       l_3E1E                   ; rotace dal®°ho atributu

; ------ uloëen° bajtñ p©ep°naáñ pro vypnut° p©ep°naáe

         xor       bh,[si]                  ; zmàna atributu
         and       bh,[si]                  ; aktu†ln° stav atributñ
         mov       ah,0                     ; á°taá znaku p©ep°naáe
l_3E39:  shr       bh,1                     ; rotov†n° p©°znakñ p°sma
         jnc       l_3E48                   ; nen° p©°znak p°sma
         cmp       bl,255                   ; je ©†dek jië plnò ?
         je        l_3E60                   ; chyba - ©†dek p©°li® dlouhò
         mov       [bp],ah                  ; uloëen° znaku
         inc       bp                       ; zvò®en° ukazatele bufferu
         inc       bl                       ; zvò®en° á°taáe bajtñ v bufferu
l_3E48:  inc       ah                       ; zvò®en° znaku
         or        bh,bh                    ; jsou jië v®echny znaky ?
         jnz       l_3E39                   ; rotace dal®°ho atributu
         mov       bh,[si]                  ; novò stav atributñ

; ------ uloëen° platnÇho znaku do textu

l_3E50:  cmp       bl,255                   ; je buffer jië plnò ?
         je        l_3E60                   ; chyba - ©†dek p©°li® dlouhò
         mov       al,[di]                  ; znak textu
         mov       [bp],al                  ; uloëen° znaku do bufferu
         inc       bl                       ; zvò®en° á°taáe bajtñ v bufferu
         loop      l_3E11                   ; dek¢dov†n° dal®°ho znaku
         jmp       short l_3E66

; ------ chyba - ©†dek p©°li® dlouhò

l_3E60:  mov       word ptr ds:[d_F79D],8   ; k¢d chyby KonTextu

; ------ uloëen° dÇlky ©†dku

l_3E66:  pop       bp
         mov       [bp],bl                  ; nov† dÇlka ©†dku

; ------ uloëen° ©†dku do bufferu

         pop       bp
         pop       ds
         les       di,dword ptr [bp+0Ch]    ; adresa ukazatele definice ©†dku
         push      es
         push      di
         lea       di,[bp-102h]             ; buffer ©†dku k uloëen°
         push      ss
         push      di
         call      l_3D53                   ; uloëen° ©†dku do souboru
         ;jmp       l_3E7D
         db        0e9h,0,0

l_3E7D:  mov       sp,bp
         pop       bp
         ret       0Ch

l_3DEF   ENDP

; -----------------------------------------------------------------------------
;        uloëen° editovanÇho ©†dku aktivn°ho prostoru do textu (zad†n á°slem)
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa bufferu atributñ
;        [SP+6] (4) adresa bufferu textu
;        [SP+10] (2) á°slo ©†dku
; -----------------------------------------------------------------------------

l_3E83   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3E8A
         db        0e9h,0,0

l_3E8A:  mov       ax,[bp+0Ch]              ; á°slo ©†dku v aktivn°m prostoru
         add       ax,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di                    ; DI <- offset definice ©†dku
         add       di,offset d_0274         ; adresa definice ©†dku
         push      ds
         push      di
         les       di,dword ptr [bp+8]      ; adresa bufferu textu
         push      es
         push      di
         les       di,dword ptr [bp+4]      ; adresa bufferu atributñ
         push      es
         push      di
         call      l_3DEF                   ; uloëen° edit. ©†dku do souboru
         ;jmp       l_3EAC
         db        0e9h,0,0

l_3EAC:  mov       sp,bp
         pop       bp
         ret       0Ah

l_3E83   ENDP

; -----------------------------------------------------------------------------
;        naáten° textu ©†dku zadanÇho ukazatele do bufferu
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa bufferu k uloëen° textu ©†dku
;        [SP+6] (4) adresa ukazatele ©†dku v souboru
; -----------------------------------------------------------------------------

l_3EB2   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3EB9
         db        0e9h,0,0

l_3EB9:  push      ds
         ;les       di,dword ptr [bp+4]     ; adresa bufferu k uloëen° ©†dku
         db        0C4h,0BEh,4,0            ;!
         ;lds       si,dword ptr [bp+8]     ; adresa ukazatele ©†dku v souboru
         db        0C5h,0B6h,8,0            ;!
         lds       si,dword ptr [si]        ; adresa ©†dku
         mov       ax,ds
         or        ax,si                    ; je ©†dek definovanò ?
         mov       es:[di],al               ; dÇlka = 0, nen°-li ©†dek definov†n
         jz        l_3ED5                   ; ©†dek nen° definovanò
         mov       cl,[si]                  ; dÇlka textu ©†dku
         mov       ch,0
         inc       cx                       ; váetnà bajtu dÇlky
         cld
         repne     movsb                    ; p©enesen° textu ©†dku do bufferu
l_3ED5:  pop       ds
         ;jmp       l_3ED9
         db        0e9h,0,0

l_3ED9:  mov       sp,bp
         pop       bp
         ret       8

l_3EB2   ENDP

; -----------------------------------------------------------------------------
;        naáten° ©†dku zadanÇho á°sla v aktivn°m prostoru do bufferu
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa bufferu k naáten° ©†dku
;        [SP+6] (2) á°slo poëadovanÇho ©†dku
; -----------------------------------------------------------------------------

l_3EDF   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3EE6
         db        0e9h,0,0

l_3EE6:  mov       ax,[bp+8]                ; poëadovanò ©†dek
         add       ax,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic ©†dkñ
         push      ds
         push      di                       ; adresa definice (adresy) ©†dku
         les       di,dword ptr [bp+4]
         push      es
         push      di                       ; adresa bufferu k naáten° ©†dku
         call      l_3EB2                   ; naáten° textu ©†dku do bufferu
         ;jmp       l_3F03
         db        0e9h,0,0

l_3F03:  mov       sp,bp
         pop       bp
         ret       6

l_3EDF   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° ©†dku (zadanÇho ukazatelem) do editaán°ho bufferu ©†dku
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa bufferu atributñ ©†dku
;        [SP+6] (4) adresa bufferu textu ©†dku
;        [SP+10] (4) adresa ukazatele zaá†tku ©†dku
; -----------------------------------------------------------------------------

l_3F09   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3F10
         db        0e9h,0,0

; ------ p©°prava ukazatelñ

l_3F10:  push      ds
         ;lds       di,dword ptr [bp+0Ch]   ; adresa ukazatele ©†dku
         db        0C5h,0BEh,0Ch,0          ;!
         lds       si,dword ptr [di]        ; adresa zaá†tku ©†dku
         ;les       di,dword ptr [bp+8]     ; adresa bufferu textu ©†dku
         db        0C4h,0BEh,8,0            ;!
         ;mov       bx,[bp+4]               ; adresa bufferu atributñ ©†dku
         db        8Bh,9Eh,4,0              ;!
         mov       ax,ds
         or        ax,si
         jz        l_3F41                   ; nen° platnò ©†dek

; ------ p©°prava k dek¢dov†n° ©†dku

         cld
         mov       cl,[si]                  ; dÇlka ©†dku (bajtñ)
         mov       ch,0                     ; vòchoz° bajt m¢du zobrazen°
         push      di
         inc       di                       ; zaá†tek bufferu textu
         inc       si                       ; zaá†tek textu ©†dku
         mov       ah,ch                    ; bajt m¢du zobrazen°

; ------ p©enos bàënòch znakñ textu

l_3F2F:  lodsb
         cmp       al,8
         jb        l_3F45
         stosb                              ; uloëen° platnÇho znaku
         inc       bx
         mov       es:[bx],ah               ; uloëen° bajtu m¢du zobrazen° znaku
l_3F39:  loop      l_3F2F

; ------ uloëen° bajtu dÇlky textu

         mov       ax,di                    ; adresa konce textu
         pop       di                       ; adresa zaá†tku textu
         sub       ax,di                    ; dÇlka textu
         dec       ax                       ; korekce
l_3F41:  stosb                              ; dÇlka textu
         pop       ds
         jmp       short l_3F51

; ------ p©ep°naáe - modifikace bajtu m¢du zobrazen° znaku

l_3F45:  push      cx
         mov       cl,al                    ; ©°dic° k¢d p©ep°naáe
         mov       ch,1                     ; maska
         shl       ch,cl                    ; rotace masky na pozici
         xor       ah,ch                    ; modifikace bajtu m¢du zobrazen°
         pop       cx
         jmp       short l_3F39             ; dal®° znak

l_3F51:  ;jmp       l_3F54
         db        0e9h,0,0

l_3F54:  mov       sp,bp
         pop       bp
         ret       0Ch

l_3F09   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° ©†dku v aktivn°m prostoru do editaán°ho bufferu ©†dku
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa bufferu atributñ ©†dku
;        [SP+6] (4) adresa bufferu textu ©†dku
;        [SP+10] (2) á°slo poëadovanÇho ©†dku
; -----------------------------------------------------------------------------

l_3F5A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3F61
         db        0e9h,0,0

l_3F61:  mov       ax,[bp+0Ch]              ; á°slo poëadovanÇho ©†dku
         add       ax,word ptr ds:[d_F7A5]  ; + á°slo poá†teán°ho ©†dku prostoru
         shl       ax,1
         shl       ax,1                     ; offset ukazatele v tabulce
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic ©†dkñ = ukazatel
         push      ds
         push      di
         les       di,dword ptr [bp+8]      ; adresa bufferu textu ©†dku
         push      es
         push      di
         les       di,dword ptr [bp+4]      ; adresa bufferu atributñ ©†dku
         push      es
         push      di
         call      l_3F09                   ; dek¢dov†n° ©†dku do edit. bufferu
         ;jmp       l_3F83
         db        0e9h,0,0

l_3F83:  mov       sp,bp
         pop       bp
         ret       0Ah

l_3F5A   ENDP

; -----------------------------------------------------------------------------
;        n†vrat line†lu ©†dkñ pod okraji
; -----------------------------------------------------------------------------

l_3F89   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3F90
         db        0e9h,0,0

; ------ n†vrat znaku pod levòm okrajem

l_3F90:  mov       di,offset l_3278         ; line†l ©†dku
         mov       bl,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         mov       bh,0
         inc       bx
         mov       cl,byte ptr ds:[d_F79B]  ; uschovanò znak line†lu-levò okraj
         mov       cs:[bx+di],cl            ; n†vrat pñvodn°ho znaku

; ------ n†vrat znaku pod pravòm okrajem

         add       bl,byte ptr cs:[l_325A]  ; ®°©ka ©†dku textu (znakñ)
         dec       bx
         dec       bx                       ; pravò okraj
         mov       cl,byte ptr ds:[d_F79C]  ; uschovanò znak line†lu-pravò okraj
         mov       cs:[bx+di],cl            ; n†vrat pñvodn°ho znaku
         ;jmp       l_3FB3
         db        0e9h,0,0

l_3FB3:  mov       sp,bp
         pop       bp
         ret       

l_3F89   ENDP

; -----------------------------------------------------------------------------
;        oznaáen° okrajñ v line†lu ©†dkñ
; -----------------------------------------------------------------------------

l_3FB7   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3FBE
         db        0e9h,0,0

; ------ oznaáen° levÇho okraje v line†lu ©†dkñ

l_3FBE:  mov       di,offset l_3278         ; line†l ©†dku
         mov       bl,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         mov       bh,0
         inc       bx
         mov       cl,cs:[bx+di]            ; pñvodn° znak v line†lu ©†dku
         mov       byte ptr ds:[d_F79B],cl  ; £schova pñvodn°ho znaku
         mov       byte ptr cs:[bx+di],"L"  ; oznaáen° levÇho okraje

; ------ oznaáen° pravÇho okraje v line†lu ©†dkñ

         add       bl,byte ptr cs:[l_325A]  ; ®°©ka ©†dku textu (znakñ)
         dec       bx
         dec       bx                       ; pozice pravÇho okraje
         mov       cl,cs:[bx+di]            ; pñvodn° znak v line†lu ©†dkñ
         mov       byte ptr ds:[d_F79C],cl  ; £schova pñvodn°ho znaku
         mov       byte ptr cs:[bx+di],"R"  ; oznaáen° pravÇho okraje
         ;jmp       l_3FE9
         db        0e9h,0,0

l_3FE9:  mov       sp,bp
         pop       bp
         ret       

l_3FB7   ENDP

; -----------------------------------------------------------------------------
;        £schova parametrñ editovanÇho prostoru
; -----------------------------------------------------------------------------

l_3FED   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_3FF4
         db        0e9h,0,0

l_3FF4:  mov       ax,word ptr ds:[d_E692]  ; ©†dek konce bloku
         cmp       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         jg        l_4000
         ;jmp       l_4006
         db        0e9h
         dw        l_4006-$-2
l_4000:  mov       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         mov       word ptr ds:[d_E692],ax  ; ©†dek konce bloku


l_4006:  mov       ax,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
         cmp       ax,word ptr ds:[d_E692]  ; ©†dek konce bloku
         jg        l_4012
         ;jmp       l_4018
         db        0e9h
         dw        l_4018-$-2
l_4012:  mov       ax,0
         mov       byte ptr ds:[d_E6A9],al  ; 1=p©°znak zapnut° zobrazen° bloku

; ------ £schova parametrñ aktu†ln°ho editovanÇho prostoru (do bufferu param.)

l_4018:  mov       ax,[bp+4]                ; editovanò prostor
         mov       cx,13                    ; poáet bajtñ k uschov†n°
         mul       cx                       ; vòpoáet offsetu v tabulce param.
         xchg      ax,di                    ; DI <- offset v tabulce
         add       di,offset d_EC18 - 13    ; uschovanÇ parametry edit. prostorñ
         push      ds                       ; segment bufferu
         push      di                       ; offset bufferu
         mov       di,offset l_3259         ; parametry editovanÇho prostoru
         push      cs                       ; segment parametrñ
         mov       cx,13                    ; poáet bajtñ k p©enesen°
         call      l_0F03                   ; p©enesen° bloku dat (CX bajtñ)

; ------ £schova ukazatelñ aktu†ln°ho prostoru

         mov       ax,[bp+4]                ; editovanò prostor
         mov       cx,PARSIZU               ; velikost pole ukazatelñ
         mul       cx                       ; offset v bufferu
         xchg      ax,di
         add       di,offset d_E77C - PARSIZU ; uschovanÇ ukazatele edit. prost.
         push      ds
         push      di
         mov       di,offset d_E690         ; pole ukazatelñ aktiv. prostoru
         push      ds
         mov       cx,PARSIZU               ; poáet bajtñ k £schovà
         call      l_0F03                   ; p©enesen° bloku dat (CX bajtñ)
         ;jmp       l_404D
         db        0e9h,0,0

l_404D:  mov       sp,bp
         pop       bp
         ret       2

l_3FED   ENDP

Code     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           Datovò segment
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Data     SEGMENT   BYTE PUBLIC

Data     ENDS
         END
