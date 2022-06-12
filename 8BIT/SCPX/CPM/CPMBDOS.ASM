
setdma:                                   ;* nastaven¡ adresy DMA
         push      ds                       ; £schova DS
         push      es                       ; ES -> stack
         pop       ds                       ; DS <- ES segment programu CP/M
         mov       ah,1ah                   ; funkce nastaven¡ adresy DTA
         int       21h                      ; nastaven¡ adresy DTA na ES:80h
         pop       ds                       ; n vrat DS
         ret

sluzby:                                   ;* slu‘by modulu CP/M - BDOS
         cmp       bp,offset(adrbdos-mem000)+1 ; je obsluha slu‘eb BDOS ?
         je        sluzby1                  ; jsou slu‘by BDOS
         cmp       bp,offset(bios-mem000)+3 ; obsluha WBOOT ?
         jne       sluzby0
         jmp       navrat                   ; n vrat z programu CP/M
sluzby0: ret

sluzby1: mov       ah,ds:[regc]             ; ‡¡slo slu‘by opera‡n¡ho syst‚mu
         cmp       ah,36                    ; maxim ln¡ ‡¡slo funkce CP/M BDOS
         ja        sluzby0                  ; je p©¡li¨ velk‚ ‡¡slo funkce
                                          ;* funkce BDOS 7 - ‡ten¡ slabiky V/V
         cmp       ah,7                     ; je BDOS 07 ?
         jne       sluzby2
         mov       al,es:[3]                ; slabika V/V
         mov       ds:[rega],al             ; ulo‘en¡ do registru A
         ret
sluzby2:                                  ;* funkce BDOS 8 - nastav. slab. V/V
         cmp       ah,8                     ; je BDOS 08 ?
         jne       sluzby3
         mov       al,ds:[rege]             ; registr E
         mov       es:[3],dl                ; nastaven¡ slabiky V/V
         ret
sluzby3:                                  ;* funkce BDOS 12 - ‡ten¡ verze CP/M
         cmp       ah,12
         jne       sluzby4
         mov       word ptr ds:[reghl],22h  ; ‡¡slo verze opera‡n¡ho syst‚mu 2.2
         ret
sluzby4:                                  ;* funkce BDOS 13 - reset disku
         cmp       ah,13
         jne       sluzby5
         int       21h
         mov       dx,80h
         call      setdma                   ; nastaven¡ adresy DMA
         ret
sluzby5:
         mov       cx,ds:[regbc]            ; vstupn¡ parametry - B a C
         mov       dx,ds:[regde]            ; vstupn¡ parametry - D a E
         mov       bx,ds:[reghl]            ; vstupn¡ parametry - H a L
         mov       al,ds:[rega]             ; vstupn¡ parametr - A
         push      ds                       ; £schova DS
         push      es                       ; ES -> stack
         pop       ds                       ; DS <- ES segment modulu CP/M
         int       21h                      ; vyvol n¡ funkce CP/M
         pop       ds                       ; n vrat DS
         lahf                               ; p©evod registru p©¡znak– do AH
         mov       ds:[regf],ah             ; registr p©¡znak–
         mov       ds:[rega],al             ; n vratov˜ k¢d ze slu‘by
         mov       ds:[reghl],bx            ; v˜stupn¡ parametr - HL
         mov       ds:[regde],dx            ; v˜stupn¡ parametr - DE
         mov       ds:[regbc],cx            ; v˜stupn¡ parametr - BC
         ret
