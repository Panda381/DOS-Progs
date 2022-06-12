
ICOSIZE  EQU       766                      ; velikost souboru ICO

TILSIRB  EQU       32/8                     ; ¨¡©ka kostky (bajt–)
TILSIR   EQU       TILSIRB*8                ; ¨¡©ka kostky (bod–)
TILVYS   EQU       32                       ; v˜¨ka kostky (linek)
TILBYTE  EQU       TILSIRB*TILVYS*4         ; velikost kostky v bajtech

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   cmp       sp,offset Zasob
         jbe       Konec

         call      InitVMod
         jc        Konec

         call      ReadFile
         jc        Konec

         call      ClrDisp

         mov       di,(200-32)/2*40 + (320-32)/2/8
         mov       si,offset Buffer + 126
         call      DispTil

         mov       ah,0
         int       16h


Konec1:  mov       ax,3
         int       10h

Konec:   int       20h

; -----------------------------------------------------------------------------
;        inicializace videom¢du
; -----------------------------------------------------------------------------

InitVMod PROC      NEAR

         push      ds
         mov       ax,0dh
         int       10h
         mov       ah,0fh
         int       10h
         pop       ds
         cmp       al,0dh
         je        InitVMd2
         stc
InitVMd2:ret

InitVMod ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ souboru
; -----------------------------------------------------------------------------

ReadFile PROC      NEAR

         mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0
         cld
ReadFil1:stc
         jcxz      ReadFil9
         mov       dx,si
         lodsb
         dec       cx
         cmp       al," "
         jbe       ReadFil1

ReadFil2:jcxz      ReadFil3
         lodsb
         dec       cx
         cmp       al," "
         ja        ReadFil2
         dec       si
ReadFil3:mov       byte ptr ds:[si],0

         mov       ax,3d00h
         int       21h
         jc        ReadFil9
         xchg      ax,bx

         mov       dx,offset Buffer
         mov       cx,ICOSIZE
         mov       ah,3fh
         int       21h

         mov       ah,3eh
         int       21h

ReadFil9:ret

ReadFile ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ obrazovky
; -----------------------------------------------------------------------------

ClrDisp  PROC      NEAR

         mov       ax,0a000h
         mov       es,ax                    ; ES <- segment videopamˆti
         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al
         xor       di,di
         mov       cx,40*200/2
         XOR       AX,AX
         dec       ax
         cld
         rep       stosw
         ret

ClrDisp  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kostky SI do DI
; -----------------------------------------------------------------------------

DispTil  PROC      NEAR

         call      KonvTil                  ; konverze kostky
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

         mov       ax,0a000h
         mov       es,ax                    ; ES <- segment videopamˆti
         mov       bh,4                     ; po‡et rovin
         mov       bl,1                     ; maska roviny 0

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx

         mov       si,offset BuffTile + TILSIRB*TILVYS-TILSIRB

DispTil2:mov       al,bl
         out       dx,al

         push      si
         push      di
         mov       cx,TILVYS
         cld
DispTil4:movsw
         movsw
         add       di,40-4
         sub       si,8
         loop      DispTil4
         pop       di
         pop       si
         add       si,TILSIRB*TILVYS

         shl       bl,1
         dec       bh
         jnz       DispTil2

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         add       si,TILBYTE
         add       di,7
         ret

DispTil  ENDP

; -----------------------------------------------------------------------------
;        konverze kostky SI do bufferu BUFFTILE
; -----------------------------------------------------------------------------
;þ
KonvTil  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

         push      ds
         pop       es
         mov       di,offset BuffTile
         mov       cx,TILBYTE/2
         xor       ax,ax
         cld
         push      di
         rep       stosw
         pop       di

         mov       ah,80h                    ; maska
         mov       cx,TILSIRB*TILVYS
KonvTil2:lodsb

         rol       al,1
         rol       al,1
         rol       al,1
         rol       al,1

         shr       al,1
         jnc       KonvTil3
         or        ds:[di+TILSIRB*TILVYS*2],ah

KonvTil3:shr       al,1
         jnc       KonvTil4
         or        ds:[di+TILSIRB*TILVYS],ah

KonvTil4:shr       al,1
         jnc       KonvTil5
         or        ds:[di],ah

KonvTil5:shr       al,1
         jnc       KonvTil6
         or        ds:[di+TILSIRB*TILVYS*3],ah

KonvTil6:ror       ah,1
         shr       al,1
         jnc       KonvTil7
         or        ds:[di+TILSIRB*TILVYS*2],ah

KonvTil7:shr       al,1
         jnc       KonvTil8
         or        ds:[di+TILSIRB*TILVYS],ah

KonvTil8:shr       al,1
         jnc       KonvTil9
         or        ds:[di],ah

KonvTil9:shr       al,1
         jnc       KonvTilA
         or        ds:[di+TILSIRB*TILVYS*3],ah

KonvTilA:ror       ah,1
         jnc       KonvTil2
         inc       di
         loop      KonvTil2

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KonvTil  ENDP

BuffTile db        TILSIRB*TILVYS*4 dup(?)  ; buffer pro konverzi kostky

Buffer   db        ICOSIZE dup(?)

         db        200h dup(?)              ; z sobn¡k
Zasob    label     byte

Code     ENDS
         END       Start
