COMMENT %

 Driver pro obsluhu kl†vesnice s áeskòm fontem znakñ

%
code     SEGMENT
         ASSUME    cs:code,ds:code

         org       100h

start:
         jmp       init                     ; instalace programu

ident    db        "CSKEY V 2.00 - driver pro áeskou kl†vesnici",13,10
         db        "(C) NMS áervenec 1990",13,10
ident0:

; -----------------------------------------------------------------------------
;               Obsluha p©eru®en° kl†vesnic° INT 09H
; -----------------------------------------------------------------------------

         dw        128 dup (0)              ; z†sobn°k pro p©eru®en° kl†vesnic°
stackk   dd        0                        ; £schova ukazatele z†sobn°ku
parrk    db        0                        ; parametr prob°haj°c°ho p©eru®en°

key:                                        ; program obsluhy kl†vesnice
         test      cs:[parrk],0ffh          ; prob°h† p©eru®en° od kl†vesnice ?
;         jz        keyno                    ; neprob°h† p©eru®en° od kl†vesnice
         pushf                              ; ignorov†n° poëadavku p©eru®en°
         jmp       dword ptr cs:[adrkey]    ; vyvol†n° p©eru®en° kl†vesnice

keyno:                                      ; zaá†tek obsluhy - £schova stavu
         mov       cs:[parrk],0ffh          ; nastaven° p©°znaku p©eru®en°
         mov       word ptr cs:[stackk],sp  ; £schova ukazatele z†sobn°ku
         mov       word ptr cs:[stackk+2],ss
         mov       sp,ax                    ; £schova registru AX
         mov       ax,cs                    ; segment programu
         mov       ss,ax                    ; nastaven° segmentu z†sobn°ku
         mov       ax,sp                    ; n†vrat registru AX
         mov       sp,offset stackk         ; adresa vlastn°ho z†sobn°ku
         push      ax
         push      bx
         push      cx
         push      es
         push      si
         push      bp
         push      ds
         push      di

         mov       bx,40h
         mov       ds,bx                    ; datovò segment 0040h
         mov       bx,cs
         mov       es,bx
         mov       bx,word ptr ds:[1ch]     ; ukl†dac° adresa znakñ
                                            ; standardn° obsluha p©eru®en°
         pushf
         call      dword ptr cs:[adrkey]    ; vyvol†n° p©eru®en° kl†vesnice
                                            ; obsluha ztmavovaáe
         cmp       byte ptr cs:[partim],0
         jz        palon80                  ; nen° zapnuta funkce áasovaáe
         cmp       cs:[count],10            ; nebylo je®tà ztmaven° displeje
         jnc       palon8
         cmp       cs:[count],5             ; á°taá ztmavnut°
         jnc       palon80
palon81: mov       word ptr ds:[1ch],bx     ; zru®en° znaku
         call      seton                    ; nastaven° palet
palon8:  mov       cs:[count],5455          ; á°taá 5 minut

palon80: mov       al,byte ptr ds:[17h]     ; p©eáten° statutu kl†vesnice
         mov       byte ptr cs:[status],al  ; uloëen° statutu
         mov       ax,[bx]                  ; p©eáten° znaku z bufferu
         cmp       bx,word ptr ds:[1ch]     ; byl p©ijat znak ?
         jnz       key1                     ; byl p©ijat
keynul:                                     ; nebyl p©ijat znak
         mov       al,byte ptr ds:[18h]     ; status kl†vesnice
         cmp       al,80h                   ; je kl†vesa INS ?
         jnz       keynl1                   ; nen° kl†vesa INS
         mov       al,cs:[parins]
         xor       al,1
         mov       cs:[parins],al           ; zmàna p©°znaku INS
         jz        keynl1                   ; je sudò znak
         mov       ax,52e0h                 ; k¢d INS
         call      inskey                   ; vloëen° znaku INS
keynl1:  jmp       konec                    ; konec programu
key1:
         cmp       ax,52e0h                 ; je znak INS ?
         jnz       keynl2
         mov       al,1
         mov       cs:[parins],al
         jmp       short keynl1

keynl2:
         mov       al,cs:[status]
         and       al,3                     ; p©°znaky SHIFT
         mov       al,cs:[status]
         jnz       keyes1                   ; je SHIFT
         jmp       keyes9                   ; neni SHIFT
keyes1:  and       al,0ch                   ; p©°znaky CTRL a ALT
         cmp       al,8                     ; je ALT ?
         mov       ax,[bx]                  ; znak
         jz        keyes0                   ; je ALT
         jmp       keynl9                   ; nen° pouze ALT

keyes0:  cmp       ax,9800h                 ; ®ipka nahoru
         jnz       keynl3
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,48e0h
         jmp       short keynl7
keynl3:  cmp       ax,0a000h                ; ®ipka dolñ
         jnz       keynl4
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,50e0h
         jmp       short keynl7
keynl4:  cmp       ax,9d00h                 ; ®ipka vpravo
         jnz       keynl5
         mov       ax,cs:[znakz]
         mov       [bx],ax
         jmp       short keynl8
keynl5:  cmp       ax,9b00h                 ; ®ipka vlevo
         jnz       keynl90
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,4be0h
keynl7:  call      inskey
keynl8:  jmp       konec
keynl90: jmp       keynl9
keyes9:
         and       al,0ch                   ; p©°znak CTRL a ALT
         cmp       al,0ch                   ; je CTRL i ALT ?
         mov       ax,[bx]
         jnz       keynl90                  ; nen° CTRL i ALT
         cmp       ax,01f0h                 ; kl†vesa <Esc>
         jnz       keyesc                   ; nen° <Esc>
         cli
         cld                                ; smàr p©enosu nahoru

         mov       cx,2*4                   ; poáet bajtñ k p©enosu
         mov       di,8*4                   ; adresa vektoru 09h
         mov       ax,0
         mov       es,ax                    ; segment tabulky p©eru®en°
         lea       si,intbuf                ; adresa bufferu tabulky p©eru®en°
         mov       ax,cs                    ; programovò segment
         mov       ds,ax                    ; segment bufferu vektoru
         rep       movsb                    ; p©enos tabulky vektorñ
         mov       cx,1*4
         mov       di,16*4
         rep       movsb
         mov       cx,1*4
         mov       di,22*4
         rep       movsb
         mov       cx,3*4
         mov       di,26*4
         rep       movsb
         mov       cx,8*4
         mov       di,32*4
         rep       movsb
         mov       cx,1*4
         mov       di,298*4
         rep       movsb                    ; ukazatel na parametry EGA
         mov       ax,0003                  ; textovò reëim
         int       10h                      ; nastaven° displeje
         mov       ah,4ch
         int       21h                      ; p©eru®en° aktivn°ho programu

keyesc:
         cmp       ax,9800h                 ; ®ipka nahoru
         jnz       keyes2
         mov       ax,48e0h
         jmp       short keyes8
keyes2:  cmp       ax,0a000h                ; ®ipka dolñ
         jnz       keyes3
         mov       ax,50e0h
         jmp       short keyes8
keyes3:  cmp       ax,9d00h                 ; ®ipka vpravo
         jnz       keyes4
         mov       ax,4de0h
         jmp       short keyes8
keyes4:  cmp       ax,9b00h                 ; ®ipka vlevo
         jnz       keynl9
         mov       ax,4be0h
keyes8:  mov       [bx],ax
         mov       cx,9
keyes7:  call      inskey
         loop      keyes7
         jmp       konec

keynl9:
         cmp       ah,0                     ; je to znak s ALT ?
         jnz       key5                     ; je ALT - konec
key10:   mov       word ptr cs:[extab],0    ; zru®en° tabulky
         jmp       keynul                   ; konec programu
key5:    cmp       al,60h                   ; je znak ` (áarka) ?
         jnz       key3                     ; nen°
         cmp       word ptr cs:[extab],0
         jnz       key3                     ; je podruhÇ
         mov       word ptr cs:[extab],offset tab3 ; nastaven° tabulky 2
zrus:    mov       word ptr ds:[1ch],bx     ; n†vrat ukazatele znakñ
konec1:  jmp       konec
key3:    cmp       word ptr cs:[extab],0    ; je roz®°©en† tabulka ?
         mov       di,word ptr cs:[extab]
         jnz       key4                     ; ano
         cmp       byte ptr cs:[swtab],0    ; je p©ep°naá tabulek ?
         jz        konec1                   ; tabulka IBM
         cmp       byte ptr cs:[swtab],1
         jnz       key30
         cmp       ah,2
         jc        konec1
         cmp       ah,12
         jnc       konec1
         mov       di,offset tab1
         test      byte ptr cs:[status],40h ; p©°znak CAPS LOCK
         jz        key320
         mov       di,offset tab2           ; jsou velk† p°smena
         jmp       short key320
key30:   mov       di,offset tab4
         cmp       byte ptr cs:[swtab],2
         jz        key33
         mov       di,offset tab5
key33:   cmp       ax,4e2bh
         jz        key320
         cmp       ax,4a2dh
         jz        key320
         cmp       ax,372ah
         jz        key320
         cmp       ax,0e02fh
         jz        key320
         cmp       ax,532eh
         jz        key320
         cmp       al,0f0h
         jz        key32
         cmp       al,0
         jnz       key31
key32:   mov       al,ah
key320:  jmp       key7
key31:   cmp       ah,13
         jc        gokon
         cmp       al,30h
         jc        gokon
         cmp       al,3ah
         jc        key320
gokon:   jmp       short konec1
key4:                                       ; p©ek¢dov†n° podle tabulky DI
         cmp       ax,0e08h
         jz        key43
         cmp       ax,53e0h
         jz        key43
         cmp       ax,0231h                 ; 1
         jnz       key41
         mov       byte ptr cs:[swtab],0
         jmp       short key43
key41:   cmp       ax,0332h                 ; 2
         jnz       key42
         mov       byte ptr cs:[swtab],1
key43:   mov       word ptr ds:[1ch],bx
         jmp       key6
key42:   cmp       ax,0433h                 ; 3
         jnz       key44
         mov       byte ptr cs:[swtab],2
         jmp       short key43
key44:   cmp       ax,0534h                 ; 4
         jnz       key401
         mov       byte ptr cs:[swtab],3
         jmp       short key43
key401:  cmp       ax,0938h                 ; 8
         jnz       key40
         cli
         mov       byte ptr cs:[partim],1
         mov       cs:[count],9
         call      setoff
         jmp       short key43
key40:   cmp       ax,0a39h                 ; 9
         jnz       key402
         mov       byte ptr cs:[partim],1
         jmp       short key43
key402:  cmp       ax,0b30h                 ; 0
         jnz       key403
         mov       byte ptr cs:[partim],0
         jmp       short key43
key403:  cmp       ax,011bh                 ; <Esc>
         jnz       key7
         call      loadint                  ; uloëen° vektorñ p©eru®en°
         jmp       short key43
key7:    cmp       al,cs:[di]
         jz        key8
         inc       di
         inc       di
         cmp       byte ptr cs:[di],0
         jnz       key7
         jmp       short key6
key8:    inc       di
         mov       al,cs:[di]
         mov       ah,0
         mov       [bx],ax
key6:    mov       word ptr cs:[extab],0    ; zru®en° p©echodnÇ tabulky

konec:                                      ; konec se z†znamem znaku
         mov       ax,[bx]                  ; p©eáten° znaku z bufferu
         cmp       bx,word ptr ds:[1ch]     ; byl p©ijat znak ?
         jz        konec3                   ; nebyl p©ijat
         test      ah,ah
         jz        konec2
         cmp       al,32
         jc        konec3
         cmp       al,7fh
         jz        konec3
         cmp       al,0e0h
         jz        konec3
         cmp       al,0f0h
         jz        konec3
konec2:  mov       cs:[znakz],ax            ; uloëen° poslednà zadanÇho znaku
konec3:
         pop       di
         pop       ds
         pop       bp
         pop       si
         pop       es
         pop       cx
         pop       bx
         pop       ax
         mov       ss,word ptr cs:[stackk+2]
         mov       sp,word ptr cs:[stackk]  ; n†vrat z†sobn°ku
         mov       cs:[parrk],0             ; ukonáen° p©°znaku p©eru®en°
         iret



inskey:                                     ; vloëen° znaku AX do bufferu
         mov       bx,word ptr ds:[1ch]     ; ukazatel pro uloëen° znaku
         push      bx
         inc       bx
         inc       bx                       ; zvò®en° pozice
         cmp       bx,3eh                   ; je p©ekroáen° konce bufferu ?
         jc        insk1                    ; nen°
         mov       bx,1eh                   ; zaá†tek bufferu
insk1:   cmp       bx,word ptr ds:[1ah]     ; ukazatel pro áten° znaku
         jz        insk2                    ; nen° volnÇ m°sto v bufferu
         mov       word ptr ds:[1ch],bx     ; novò ukazatel
         pop       bx                       ; pñvodn° ukazatel
         mov       ds:[bx],ax               ; uloëen° znaku
         mov       bx,word ptr ds:[1ch]
         ret
insk2:   pop       bx                       ; n†vrat ukazatele znakñ
         ret

tab1     db        "1ñ"
         db        "2à"
         db        "3®"
         db        "4á"
         db        "5©"
         db        "6ë"
         db        "7ò"
         db        "8†"
         db        "9°"
         db        "0Ç"
         db        0

tab2     db        "1¶"                     ; tabulka velkòch p°smen
         db        "2â"
         db        "3õ"
         db        "4Ä"
         db        "5û"
         db        "6í"
         db        "7ù"
         db        "8è"
         db        "9ã"
         db        "0ê"
         db        0


                                            ; tabulka pro `
tab3     db        "+Ò"
         db        "="
         db        "qÑ"
         db        "Qé"
         db        "wà"
         db        "Wâ"
         db        "eÇ"
         db        "Eê"
         db        "r©"
         db        "Rû"
         db        "tü"
         db        "TÜ"
         db        "yò"
         db        "Yù"
         db        "u£"
         db        "Uó"
         db        "i°"
         db        "Iã"
         db        "o¢"
         db        "Oï"
         db        "pî"
         db        "Pô"
         db        "a†"
         db        "Aè"
         db        "s®"
         db        "Sõ"
         db        "dÉ"
         db        "DÖ"
         db        "f™"
         db        "F´"
         db        "hÅ"
         db        "Hö"
         db        "jñ"
         db        "J¶"
         db        "kì"
         db        "Kß"
         db        "lç"
         db        "Lä"
         db        "zë"
         db        "Zí"
         db        "cá"
         db        "CÄ"
         db        "n§"
         db        "N•"
         db        "må"
         db        "Mú"
         db        ",Æ"
         db        "<Û"
         db        ".Ø"
         db        ">Ú"
         db        "\≠"
         db        0

tab4     db        "0",205
         db        "1",200
         db        "2",202
         db        "3",188
         db        "4",204
         db        "5",206
         db        "6",185
         db        "7",201
         db        "8",203
         db        "9",187
         db        ".",186

         db        52h,205
         db        4fh,212
         db        50h,207
         db        51h,190
         db        4bh,198
         db        4ch,216
         db        4dh,181
         db        47h,213
         db        48h,209
         db        49h,184
         db        53h,179
         db        "/",176
         db        "*",177
         db        "-",178
         db        "+",219
         db        0


tab5     db        "0",196
         db        "1",192
         db        "2",193
         db        "3",217
         db        "4",195
         db        "5",197
         db        "6",180
         db        "7",218
         db        "8",194
         db        "9",191
         db        ".",179

         db        52h,196
         db        4fh,211
         db        50h,208
         db        51h,189
         db        4bh,199
         db        4ch,215
         db        4dh,182
         db        47h,214
         db        48h,210
         db        49h,183
         db        53h,186
         db        "/",176
         db        "*",177
         db        "-",178
         db        "+",219
         db        0

paloff   db        0,0,0,0,0,0,38h,38h,0,0,38h,38h,38h,38h,38h,38h,0
palon    db        0,1,2,3,4,5,14h,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0

intbuf   db        16*4 DUP (0)             ; buffer pro z†znam p©eru®en°

         dw        64 dup (0)
stack1   dd        0                        ; pracovn° z†sobn°k pro áasovaá

segmint  dw        0                        ; segment programu

timer:                                      ; program obsluhy áasovaáe

;         mov       word ptr cs:[stack1],sp  ; £schova z†sobn°ku
;         mov       word ptr cs:[stack1+2],ss
;         mov       sp,offset stack1
;         mov       ss,cs:[segmint]          ; segment pro p©eru®en°
         pushf
         call      dword ptr cs:[adrtim]    ; obsluha áasovaáe INT 08h
;         cmp       byte ptr cs:[partim],0
;         jz        kontim                   ; nen° ztmavov†n°
;         cmp       cs:[count],0             ; á°taá ztmavnut°
;         jz        kontim0
;         dec       cs:[count]
;         jnz       kontim
;         mov       cs:[count],4
;         call      setoff

;kontim0: mov       cs:[count],4
;kontim:  mov       ss,word ptr cs:[stack1+2]
;         mov       sp,word ptr cs:[stack1]  ; n†vrat z†sobn°ku
         iret

setoff:  push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bx,cs
         mov       es,bx
         mov       ax,1002h
         mov       dx,offset paloff         ; paleta ztmavnut°
         cli
         int       10h
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret



;setoff:  push      ds
;         push      dx
;         push      ax
;         xor       ax,ax
;         mov       ds,ax
;         mov       dx,word ptr ds:[0463h]
;         add       dx,4
;         mov       al,byte ptr ds:[0465h]
;         and       al,0f7h
;         out       dx,al
;         mov       byte ptr ds:[0465h],al
;         pop       ax
;         pop       dx
;         pop       ds
;         ret
;

seton:   push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bx,cs
         mov       es,bx
         mov       ax,1002h
         mov       dx,offset palon          ; paleta rozsv°cen°
         cli
         int       10h
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

;seton:   push      ds
;         push      dx
;         push      ax
;         xor       ax,ax
;         mov       ds,ax
;         mov       dx,word ptr ds:[0463h]
;         add       dx,4
;         mov       al,byte ptr ds:[0465h]
;         or        al,8
;         out       dx,al
;         mov       byte ptr ds:[0465h],al
;         pop       ax
;         pop       dx
;         pop       ds
;         ret


setpal:  push      ax
         push      bx
         push      cx
         push      dx
         cli
         mov       dx,3dah
         in        al,dx                    ; nastaven° adresovÇho m¢du
         mov       dx,3c0h                  ; ©°d°c° port EGA
         mov       cx,16                    ; poáet registrñ palet
         mov       bl,0                     ; á°taá registrñ
setpal1: mov       al,bl
         out       dx,al                    ; registr palety
         mov       al,cs:[si]               ; barva palety
         out       dx,al                    ; nov† barva
         inc       si                       ; nov† barva
         inc       bl                       ; novò registr
         loop      setpal1                  ; dal®° paleta
         mov       al,11h
         out       dx,al
         mov       al,cs:[si]               ; barva okol°
         out       dx,al                    ; barva registru okol°
         mov       al,20h
         out       dx,al
         out       dx,al
         sti                                ; povolen° p©eru®en°
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


loadint:                                    ; uloëen° vektorñ p©eru®en°
                                            ; tento podprogram uschov† vektory
                                            ; p©eru®en° pro funkci p©eru®en°
                                            ; programu <Ctrl>-<Alt>-<Esc>
         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es
         cld                                ; smàr p©enosu nahoru
         cli                                ; z†kaz p©eru®en°
         mov       cx,2*4                   ; poáet bajtñ k p©enosu
         mov       si,8*4                   ; adresa vektoru 03h
         mov       ax,0
         mov       ds,ax                    ; segment tabulky p©eru®en°
         lea       di,intbuf                ; adresa bufferu tabulky p©eru®en°
         mov       ax,cs                    ; programovò segment
         mov       es,ax                    ; p©°jmovò segment
         rep       movsb                    ; p©enos vektorñ 03h az 27h
         mov       cx,1*4
         mov       si,16*4
         rep       movsb
         mov       cx,1*4
         mov       si,22*4
         rep       movsb
         mov       cx,3*4
         mov       si,26*4
         rep       movsb
         mov       cx,8*4
         mov       si,32*4
         rep       movsb
         mov       cx,1*4
         mov       si,298*4
         rep       movsb                    ; ukazatel na parametry EGA
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret



control:                                    ; ©°d°c° á†st programu
;         cmp       ah,63h                   ; funkce pro driver
         pushf
         jmp       dword ptr cs:[adrid]      ; pñvodn° obsluha
;         jz        contr1                   ; je tato funkce
;         iret                               ; n†vrat z p©eru®en°
;contr1:  mov       ax,cs
;         mov       bx,ax
;         mov       ax,4321h
;         mov       cx,0fedch
;         iret



adrid    dd        0                        ; adresa identifikaán° á†sti
adrkey   dd        0                        ; adresa obsluhy kl†vesnice INT 09
adrtim   dd        0                        ; adresa obsluhy áasovaáe INT 08

partim   db        0                        ; parametr ztmavov†n° displeje EGA
                                            ; (1=ztmavov†n° zapnuto, 0=vypnuto)
status   db        0                        ;
swtab    db        0
extab    dw        0
parins   db        0                        ; á°taá znakñ INSERT
znakz    dw        32                       ; poslednà vloëenò znak
count    dw        1091                     ; á°taá ztmavnut°
                                            ; tabulka norm. áe®tiny



; zde je konec rezidentn° á†sti programu

; ===========================================================================

                                            ; instalace rezid. á†sti programu

init:   ; mov       cs:[datseg],ds           ; datovò segment programu
        ; mov       cs:[segmint],cs
        ; mov       ax,cs
        ; mov       ds,ax                    ; nastaven° DS shodnà jako CS


                                            ; kontrola instalace programu
         clc                                ; vynulov†n° p©°znaku p©enosu CF
         mov       ax,6300h                 ; funkce 63h/00h - dotaz o stavu
         mov       cx,0abcdh                ; identifikaán° slovo
         int       16h                      ; dotaz na instalaci programu
         jc        init1                    ; nen° nainstalov†n OK
         cmp       ax,4321h                 ; identifikaán° slovo
         jnz       init1                    ; nen° nainstalov†n
         cmp       cx,0fedch                ; identifikaán° slovo
         jnz       init1                    ; nen° nainstalov†n

;         push      bx                       ; segment rezidentn°ho programu
;         mov       ax,3509h                 ; p©eáten° vektoru p©eru®en° 09h
;         int       21h
;         mov       word ptr [adrkey],bx     ; uloëen° pñvodn°ho vekt. p©eru®en°
;         mov       word ptr [adrkey+2],es   ; segment nad©azenÇ instalace
;         pop       es                       ; segment rezidentn°ho programu

;         mov       cx,ident0 - ident        ; dÇlka identifikaán° á†sti programu
;         xor       di,di                    ; c°lovò ©etàzec
;         xor       si,si                    ; zdrojovò ©etàzec
;         cld                                ; smàr operace nahoru
;         repe      cmpsb                    ; porovn†n° identifikaán°ho ©etàzce
init1:   pushf                              ; £schova p©°znaku ZF
         jz        init2                    ; program je nainstalov†n
;         mov       ax,cs
;         mov       es,ax                    ; segment tohoto programu

init2:                                      ; test zad†n° p©°kazovÇho ©†dku
;         mov       ds,cs:[datseg]           ; datovò segment programu
;         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
;         mov       cl,ds:[80h]              ; poáet znakñ p©°kazovÇho ©†dku
;         xor       ch,ch
;         or        cl,cl                    ; je nàjakò znak ?
;         jnz       init4                    ; je zad†n nàjakò znak v p©°kazu
init3:   popf                               ; n†vrat p©°znaku instalace ZF
         jz        init31
         jmp       instal0                  ; je instalace programu
init31:  mov       ax,cs
         mov       ds,ax
         mov       dx,offset textins        ; text, ëe je jië v pamàti
         mov       ah,9
         int       21h                      ; tisk textu
         mov       ax,4c01h                 ; n†vratovò k¢d 1
         int       21h                      ; ukonáen° programu s chybou 01

;init4:                                      ; nastaven° p©°kazovòm ©†dkem
;         jcxz      instal                   ; konec ©†dku - instalace
;         lodsb                              ; naáten° znaku
;         dec       cx                       ; á°taá znakñ
;         cmp       al," "                   ; je mezera ?
;         jbe       init4                    ; je ©°d°c° znak nebo mezera
;         cmp       al,"0"                   ; je men®° neë "0" ?
;         jb        init5                    ; chyba - men®° znak neë "0"
;         cmp       al,"9"                   ; je vàt®° neë "9" ?
;         ja        init5                    ; chyba - vàt®° znak neë "9"
;         jnz       init41                   ; nen° "9"
;         mov       al,1
;         mov       es:[partim],al           ; zapnut° ztmavov†n°
;         jmp       short init4              ; dal®° znak
;init41:  cmp       al,"0"                   ; je znak "0" ?
;         jnz       init42
;         cli
;         xor       al,al
;         mov       es:[partim],al           ; vypnut° ztmavov†n°
;         cmp       cs:[count],10
;         jnc       init412
;         cmp       cs:[count],5             ; á°taá ztmavnut°
;         jnc       init413
;         call      seton                    ; nastaven° palet
;init412: mov       cs:[count],5455          ; á°taá 5 minut
;init413: sti
;         jmp       short init4              ; dal®° znak
;init42:  cmp       al,"8"
;         jnz       init43
;         cli
;         mov       es:[partim],1            ; zapnut° ztmavov†n°
;         mov       es:[count],9             ; nastaven° kr†tkÇ á°tac° konstanty
;         call      setoff
;         sti
;         jmp       short init4
;init43:
;         jmp       short init4
;
;init5:                                      ; chyba zad†n° parametrñ programu
;         popf
;         sti                                ; povolen° p©eru®en°
;         mov       ax,cs
;         mov       ds,ax
;         mov       dx,offset texterr        ; text chyby zad†n° parametrñ
;         mov       ah,9
;         int       21h                      ; tisk textu chyby
;         mov       ax,4c02h                 ; n†vratovò k¢d 2
;         int       21h                      ; ukonáen° programu s chybou 02
;
instal:                                     ; instalace programu
         popf
         jnz       instal0                  ; nen° je®tà nainstalov†n
                                            ; n†vrat p©i spr†vnòch parametrech
         mov       ax,4c00h
         int       21h                      ; ukonáen° programu bez chyby

instal0: cli                                ; z†kaz p©eru®en°
         mov       ax,3516h
         int       21h                      ; p©eáten° starÇ adresy INT 16h
         mov       word ptr cs:[adrid],bx   ; uloëen° starÇ adresy INT 16H
         mov       word ptr cs:[adrid+2],es
;         mov       ax,cs
;         mov       ds,ax
         mov       dx,offset control        ; ©°d°c° á†st programu
         mov       ax,2516h
         int       21h                      ; nastaven° novÇ adresy INT 16H

;         mov       dx,offset key            ; adresa vlastn° obsluhy INT 09h
;         mov       ax,2509h
;         int       21h                      ; nastaven° novÇ adresy INT 09H
;         mov       ax,3508h                 ; p©eáten° vektoru p©eru®en° 08h
;         int       21h
;         mov       word ptr [adrtim],bx     ; uloëen° vektoru p©eru®en° 08h
;         mov       word ptr [adrtim+2],es
;         mov       dx,offset timer          ; adresa vlastn° obsluhy INT 08H
;         mov       ax,2508h
;         int       21h                      ; nastaven° novÇ adresy INT 08H
;         call      loadint                  ; £schova vektorñ p©eru®en°
         sti                                ; povolen° p©eru®en°
         mov       dx,offset textuv         ; £vodn° text
         mov       ah,9
         int       21h                      ; tisk £vodn°ho textu
         mov       ax,3100h                 ; n†vratovò k¢d
         mov       dx,(init-start+110H)/16  ; dÇlka programu (v segmentech)
         int       21h                      ; ukonáen° programu jako rezidentn°


textuv   db        'Driver pro ceskou klavesnici CSKEY V 2.00 byl nainstalovan.'
         db        13,10,'$'

textins  db        'Driver pro ceskou klavesnici CSKEY je jiz v pameti !'
         db        13,10,'$'

texterr  db        'CHYBA-zadejte:   CSKEY <seznam parametru>',13,10,10
         db        'parametry -  * 1 = normalni klavesnice',13,10
         db        '               2 = ceska klavesnice programatora',13,10
         db        '               3 = ceska klavesnice uplna',13,10
         db        '               4 = graficke pole - jednoducha cara',13,10
         db        '               5 = graficke pole - dvojita cara',13,10
         db        '             * 6 = cestina Kamenickych',13,10
         db        '               7 = cestina Latin 2',13,10
         db        '               8 = nucene ztmaveni displeje (EGA)',13,10
         db        '               9 = zapnuti funkce ztmavovani displeje',13,10
         db        '             * 0 = vypnuti funkce ztmavovani displeje',13,10
         db        10,'Pro rucni ovladani pouzijte klavesu <`> jako prefix.'
         db        13,10,10,'$'

datseg   dw        0                        ; datovò segment programu

code     ENDS

         END       start                    ; startovac° adresa
