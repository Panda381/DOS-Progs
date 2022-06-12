
; *****************************************************************************
;
;                             kontroln¡ monoskop
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h

; ------ inicializace videom¢du

start:   mov       ah,0fh
         int       10h
         cmp       al,7
         je        start1
         mov       al,3
         mov       byte ptr ds:[SegVRAM+1],0b8h  ; segment VRAM pro CGA
start1:  xor       ah,ah
         int       10h

; ------ zobrazen¡ spodn¡ho rastru

         mov       ah,7                     ; barva podkladov‚ho rastru
         mov       bl,176                   ; alternativn¡ znak
         mov       al,178                   ; prvn¡ znak
         mov       cl,2                     ; 2 znaky
         mov       dh,0
start21: mov       dl,0                     ; po‡ te‡n¡ pozice
Start22: call      dispch
         xchg      al,bl
         cmp       dl,80
         jb        start22
         xchg      al,bl
         inc       dh
         cmp       dh,25
         jb        start21

; ------ zobrazen¡ orienta‡n¡ch ¨ipek

         mov       ah,0fh
         mov       dh,0                     ; po‡ te‡n¡ © dek
Start31: mov       dl,0
STart32: mov       al,16
         call      Disp1Ch
         mov       al,17
         call      Disp1Ch
         add       dl,37
         cmp       dl,80
         jb        Start32
         add       dh,12
         cmp       dh,25
         jb        Start31

; ------ zobrazen¡ vnit©n¡ho r mu

         mov       ah,0ah                   ; barva r mu
         mov       al,177
         mov       cx,36
         mov       dh,4
start41: mov       dl,22
         call      DispCh
         inc       dh
         cmp       dh,20
         jbe       start41

; ------ zobrazen¡ barevn˜ch pruh–

         mov       al,219
         mov       dh,6                     ; po‡ te‡n¡ © dek
         mov       cl,2
start51: mov       dl,24
         mov       ah,0
start52: call      dispch
         inc       ah
         cmp       ah,16
         jb        start52
         inc       dh
         cmp       dh,19
         jbe       start51

; ------ zobrazen¡ ASCII tabulky

         mov       ax,700h
         mov       dh,9                     ; po‡ te‡n¡ © dek
start61: mov       dl,24
start62: call      disp1ch
         inc       ax
         cmp       dl,24+32
         jb        start62
         inc       dh
         cmp       dh,17
         jb        start61

; ------ zobrazen¡ stupnice ¨ed‚

         mov       si,offset seda
         mov       cx,4
         mov       dx,5*256+24
start71: cld
         lodsw
         call      dispch
         cmp       dl,24+32
         jb        start71

; ------ zobrazen¡ ‡tvercov˜ch barevn˜ch pol¡

         mov       al,220
         mov       bx,101h
         mov       dx,102h
         call      DColC                    ; pole vlevo naho©e
         mov       dx,1*256+77
         mov       bl,-1
         call      DColC                    ; pole vpravo naho©e
         mov       al,223
         mov       dx,23*256+77
         mov       bh,-1
         call      DColC                    ; pole vpravo dole
         mov       dx,23*256+2
         mov       bl,1
         call      DColC                    ; pole vlevo dole

; ------ zobrazen¡ horn¡ho a spodn¡ho barevn‚ho pole

         mov       al,220
         mov       dh,1
start83: mov       dl,36
         mov       ah,8
start84: call      disp1ch
         add       ah,11h
         cmp       ah,7fh
         jbe       start84
         mov       al,223
         add       dh,22
         cmp       dh,25
         jb        start83

; ------ zobrazen¡ lev‚ho a prav‚ho barevn‚ho pole

         mov       dl,2
         mov       bl,1
         call      dcolb                    ; zobrazen¡ lev‚ho pole

         mov       dl,77
         mov       bl,-1
         call      dcolb                    ; zobrazen¡ prav‚ho pole

; ------ vypnut¡ kurzoru

         mov       dx,25*256
         mov       ah,2
         mov       bh,0
         int       10h

; ------ ‡ek n¡ na stisk kl vesy

         xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk kl vesy

; ------ vymaz n¡ displeje, konec

         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h
         int       20h

; -----------------------------------------------------------------------------
;        zobrazen¡ bo‡n¡ho barevn‚ho pole
; -----------------------------------------------------------------------------

DColB:   mov       ax,8*256+220
         mov       dh,12
         call      disp0ch
         call      disp0ch
         dec       dh

         mov       cx,3
dcolb1:  push      dx
         call      disp0ch
         call      disp0ch
         pop       dx
         inc       dh
         loop      dcolb1
         ret

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡tvercov‚ho barevn‚ho pole
; -----------------------------------------------------------------------------

DColC:
         mov       ah,8

dcolc1:  push      dx

DColC2:  call      Disp0Ch
         test      ah,3
         jnz       dcolc2

         pop       dx
         add       dh,bh
         test      ah,7
         jnz       dcolc1
         ret

Disp0Ch: push      dx
         call      disp1ch
         pop       dx
         add       ah,11h
         add       dl,bl
         ret

; -----------------------------------------------------------------------------
;   v˜stup znaku na displej (DH=© dek, DL=pozice, AX=znak, DS=datov˜ segment)
; -----------------------------------------------------------------------------

disp1ch: push      cx
         mov       cl,1
         call      DispCh
         pop       cx
         ret

dispch:  push      cx
         push      dx
         push      di
         push      es

         mov       ch,0
         push      ax
         mov       al,160                   ; po‡et bajt– na © dek
         mul       dh                       ; p©epo‡et © dku na bajty
         mov       dh,0
         add       ax,dx                    ; p©i‡ten¡ pozice
         add       ax,dx                    ; p©i‡ten¡ pozice v bajtech
         mov       di,ax                    ; adresa ve videopamˆti
         pop       ax
         mov       es,ds:[SegVRAM]
         cld
         rep       stosw                    ; ulo‘en¡ znaku

         pop       es
         pop       di
         pop       dx
         pop       cx
         add       dl,cl
         ret

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

SegVRAM  dw        0b000h                   ; segment videopamˆti

Seda     db        ' ',7,'°',8,'°',7,'±',7,'²',7,'±',0fh,'²',0fh,'Û',0fh

code     ends
         end       start
