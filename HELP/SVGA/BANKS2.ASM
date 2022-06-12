
        .model  large,c                ; Orig. small,c

;
;       Copyright 1988,89,90 John Bridges
;       Free for use in commercial, shareware or freeware applications
;
;       SVGAMODE.ASM
;
.data

OSEG    equ     SS:                     ;segment override for variable access

bankadr dw      offset $nobank
if @codesize
bankseg dw      seg $nobank
endif

        public  curbk,maxx,maxy

curbk   dw      0
maxx    dw      640
maxy    dw      480

        public  vga512

vga512  dw      0

        public  cirrus,video7,tseng,paradise,chipstech,trident
        public  ativga,everex,aheada,aheadb

cirrus  dw      0
video7  dw      0
tseng   dw      0
paradise dw     0
chipstech dw    0
trident dw      0
ativga  dw      0
everex  dw      0
aheada  dw      0
aheadb  dw      0

.code

newbank proc                    ;bank number is in AX
        cli
        mov     OSEG[curbk],ax
if @codesize
        jmp     dword ptr OSEG[bankadr]
else
        jmp     word ptr OSEG[bankadr]
endif
newbank endp

$tseng  proc            ;Tseng
        push    ax
        push    dx
        and     al,7
        mov     ah,al
        shl     ah,1
        shl     ah,1
        shl     ah,1
        or      al,ah
        or      al,01000000b
        mov     dx,3cdh
        out     dx,al
        sti
        pop     dx
        pop     ax
        ret
$tseng  endp

$trident proc           ;Trident
        push    ax
        push    dx
        mov     dx,3ceh         ;set page size to 64k
        mov     al,6
        out     dx,al
        inc     dl
        in      al,dx
        dec     dl
        or      al,4
        mov     ah,al
        mov     al,6
        out     dx,ax
                
        mov     dl,0c4h         ;switch to BPS mode
        mov     al,0bh
        out     dx,al
        inc     dl
        in      al,dx
        dec     dl

        mov     ah,byte ptr OSEG[curbk]
        xor     ah,2
        mov     dx,3c4h
        mov     al,0eh
        out     dx,ax
        sti
        pop     dx
        pop     ax
        ret
$trident endp

$video7 proc            ;Video 7
        push    ax
        push    dx
        push    cx
        and     ax,15
        mov     ch,al
        mov     dx,3c4h
        mov     ax,0ea06h
        out     dx,ax
        mov     ah,ch
        and     ah,1
        mov     al,0f9h
        out     dx,ax
        mov     al,ch
        and     al,1100b
        mov     ah,al
        shr     ah,1
        shr     ah,1
        or      ah,al
        mov     al,0f6h
        out     dx,al
        inc     dx
        in      al,dx
        dec     dx
        and     al,not 1111b
        or      ah,al
        mov     al,0f6h
        out     dx,ax
        mov     ah,ch
        mov     cl,4
        shl     ah,cl
        and     ah,100000b
        mov     dl,0cch
        in      al,dx
        mov     dl,0c2h
        and     al,not 100000b
        or      al,ah
        out     dx,al
        sti
        pop     cx
        pop     dx
        pop     ax
        ret
$video7 endp
        
$paradise proc          ;Paradise
        push    ax
        push    dx
        mov     dx,3ceh
        mov     ax,50fh         ;turn off write protect on VGA registers
        out     dx,ax
        mov     ah,byte ptr OSEG[curbk]
        shl     ah,1
        shl     ah,1
        shl     ah,1
        shl     ah,1
        mov     al,9
        out     dx,ax
        sti
        pop     dx
        pop     ax
        ret
$paradise endp

$chipstech proc         ;Chips & Tech
        push    ax
        push    dx
        mov     dx,46e8h        ;place chip in setup mode
        mov     ax,1eh
        out     dx,ax
        mov     dx,103h         ;enable extended registers
        mov     ax,0080
        out     dx,ax
        mov     dx,46e8h        ;bring chip out of setup mode
        mov     ax,0eh
        out     dx,ax
        mov     ah,byte ptr OSEG[curbk]
        shl     ah,1            ;change 64k bank number into 16k bank number
        shl     ah,1
        mov     al,10h
        mov     dx,3d6h
        out     dx,ax
        sti
        pop     dx
        pop     ax
        ret
$chipstech endp

$ativga proc            ;ATI VGA Wonder
        push    ax
        push    dx
        mov     ah,al
        mov     dx,1ceh
        mov     al,0b2h
        out     dx,al
        inc     dl
        in      al,dx
        shl     ah,1
        and     al,0e1h
        or      ah,al
        mov     al,0b2h
        dec     dl
        out     dx,ax
        sti
        pop     dx
        pop     ax
        ret
$ativga endp

$everex proc            ;Everex
        push    ax
        push    dx
        push    cx
        mov     cl,al
        mov     dx,3c4h
        mov     al,8
        out     dx,al
        inc     dl
        in      al,dx
        dec     dl
        shl     al,1
        shr     cl,1
        rcr     al,1
        mov     ah,al
        mov     al,8
        out     dx,ax
        mov     dl,0cch
        in      al,dx
        mov     dl,0c2h
        and     al,0dfh
        shr     cl,1
        jc      nob2
        or      al,20h
nob2:   out     dx,al
        sti
        pop     cx
        pop     dx
        pop     ax
        ret
$everex endp

$aheada proc
        push    ax
        push    dx
        push    cx
        mov     ch,al
        mov     dx,3ceh         ;Enable extended registers
        mov     ax,200fh
        out     dx,ax
        mov     dl,0cch         ;bit 0
        in      al,dx
        mov     dl,0c2h
        and     al,11011111b
        shr     ch,1
        jnc     @@1             ; Orig @f
        or      al,00100000b
@@1:    out     dx,al           ; Orig @@:
        mov     dl,0cfh         ;bits 1,2,3
        mov     al,0
        out     dx,al
        inc     dx
        in      al,dx
        dec     dx
        and     al,11111000b
        or      al,ch
        mov     ah,al
        mov     al,0
        out     dx,ax
        sti
        pop     cx
        pop     dx
        pop     ax
        ret
$aheada endp

$aheadb proc
        push    ax
        push    dx
        push    cx
        mov     ch,al
        mov     dx,3ceh         ;Enable extended registers
        mov     ax,200fh
        out     dx,ax
        mov     ah,ch
        mov     cl,4
        shl     ah,cl
        or      ah,ch
        mov     al,0dh
        out     dx,ax
        sti
        pop     cx
        pop     dx
        pop     ax
        ret
$aheadb endp

$nobank proc
        sti
        ret
$nobank endp


whichvga proc   uses si
        mov     si,1
        mov     ax,0c000h
        mov     es,ax
        cmp     word ptr es:[40h],'13'
        jnz     noati
        mov     [ativga],1
        mov     [bankadr],offset $ativga
if @codesize
        mov     [bankseg],seg $ativga
endif
        cli
        mov     dx,1ceh
        mov     al,0bbh
        out     dx,al
        inc     dl
        in      al,dx
        sti
        and     al,20h
        jz      no512
        mov     [vga512],1
no512:  jmp     fini

noati:  mov     ax,7000h                ;Test for Everex
        xor     bx,bx
        cld
        int     10h
        cmp     al,70h
        jnz     noev
        mov     [everex],1
        mov     [bankadr],offset $everex
if @codesize
        mov     [bankseg],seg $everex
endif
        and     ch,11000000b
        jz      @@2                      ; orig @f      
        mov     [vga512],1
@@2:    and     dx,0fff0h                ; Orig @@:
        cmp     dx,6780h
        jz      yeste
        cmp     dx,2360h
        jnz     note
yeste:  mov     [trident],1
        mov     [bankadr],offset $trident
if @codesize
        mov     [bankseg],seg $trident
endif
note:   jmp     fini

noev:   mov     dx,3c4h                 ;Test for Trident
        mov     al,0bh
        out     dx,al
        inc     dl
        in      al,dx
        cmp     al,0fh
        ja      notri
        cmp     al,2
        jb      notri
        mov     [trident],1
        mov     [bankadr],offset $trident
if @codesize
        mov     [bankseg],seg $trident
endif
        mov     [vga512],1
        jmp     fini

notri:  mov     ax,6f00h                ;Test for Video 7
        xor     bx,bx
        cld
        int     10h
        cmp     bx,'V7'
        jnz     nov7
        mov     [video7],1
        mov     [bankadr],offset $video7
if @codesize
        mov     [bankseg],seg $video7
endif
        mov     ax,6f07h
        cld
        int     10h
        and     ah,7fh
        cmp     ah,1
        jbe     @@3                     ; Orig. @f
        mov     [vga512],1
@@3:    jmp     fini                    ; Orig. @@:

nov7:   call    $cirrus                 ;Test for Cirrus
        cmp     [cirrus],0
        je      noci
        jmp     fini

noci:   mov     dx,3ceh                 ;Test for Paradise
        mov     al,9                    ;check Bank switch register
        out     dx,al
        inc     dx
        in      al,dx
        dec     dx
        or      al,al
        jnz     nopd

        mov     ax,50fh                 ;turn off write protect on VGA registers
        out     dx,ax
        mov     dx,offset $pdrsub
        mov     cx,1
        call    $chkbk
        jc      nopd                    ;if bank 0 and 1 same not paradise
        mov     [paradise],1
        mov     [bankadr],offset $paradise
if @codesize
        mov     [bankseg],seg $paradise
endif
;       mov     cx,64                   ; |
;       call    $chkbk                  ; V Orig. @f
;       jc      @@4                     ;if bank 0 and 64 same only 256k
        mov     [vga512],1
@@4:    jmp     fini                    ; Orig. @@:

nopd:   mov     ax,5f00h                ;Test for Chips & Tech
        xor     bx,bx
        cld
        int     10h
        cmp     al,5fh
        jnz     noct
        mov     [chipstech],1
        mov     [bankadr],offset $chipstech
if @codesize
        mov     [bankseg],seg $chipstech
endif
        cmp     bh,1
        jb      fini
        mov     [vga512],1
        jmp     short fini

noct:   mov     dx,3cdh                 ;Test for Tseng
        in      al,dx
        and     al,00111111b            ;check bank switch register
        jnz     nots

        mov     [tseng],1
        mov     [bankadr],offset $tseng
if @codesize
        mov     [bankseg],seg $tseng
endif
        mov     [vga512],1
        jmp     short fini
nots:   
        mov     dx,3ceh         ;Test for Above A or B chipsets
        mov     ax,200fh
        out     dx,ax
        inc     dx
        in      al,dx
        cmp     al,21h
        jz      verb
        cmp     al,20h
        jnz     noab
        mov     [aheada],1
        mov     [bankadr],offset $aheada
if @codesize
        mov     [bankseg],seg $aheada
endif
        mov     [vga512],1
        jmp     short fini

verb:   mov     [aheadb],1
        mov     [bankadr],offset $aheadb
if @codesize
        mov     [bankseg],seg $aheadb
endif
        mov     [vga512],1
        jmp     short fini
noab:   mov     si,0

fini:   mov     ax,si
        ret
whichvga endp


$cirrus proc    near
        mov     dx,3d4h         ; assume 3dx addressing
        mov     al,0ch          ; screen a start address hi
        out     dx,al           ; select index
        inc     dx              ; point to data
        mov     ah,al           ; save index in ah
        in      al,dx           ; get screen a start address hi
        xchg    ah,al           ; swap index and data
        push    ax              ; save old value
        push    dx              ; save crtc address
        xor     al,al           ; clear crc
        out     dx,al           ; and out to the crtc

        mov     al,1fh          ; Eagle ID register
        dec     dx              ; back to index
        out     dx,al           ; select index
        inc     dx              ; point to data
        in      al,dx           ; read the id register
        mov     bh,al           ; and save it in bh

        mov     cl,4            ; nibble swap rotate count
        mov     dx,3c4h         ; sequencer/extensions
        mov     bl,6            ; extensions enable register

        ror     bh,cl           ; compute extensions disable value
        mov     ax,bx           ; extensions disable
        out     dx,ax           ; disable extensions
        inc     dx              ; point to data
        in      al,dx           ; read enable flag
        or      al,al           ; disabled ?
        jnz     exit            ; nope, not an cirrus

        ror     bh,cl           ; compute extensions enable value
        dec     dx              ; point to index
        mov     ax,bx           ; extensions enable
        out     dx,ax           ; enable extensions
        inc     dx              ; point to data
        in      al,dx           ; read enable flag
        cmp     al,1            ; enabled ?
        jne     exit            ; nope, not an cirrus
        mov     [cirrus],1
        mov     [bankadr],offset $nobank
if @codesize
        mov     [bankseg],seg $nobank
endif
exit:   pop     dx              ; restore crtc address
        dec     dx              ; point to index
        pop     ax              ; recover crc index and data
        out     dx,ax           ; restore crc value
        ret
$cirrus endp

$chkbk  proc    near            ;paradise bank switch check
        mov     di,0b800h
        mov     es,di
        xor     di,di
        mov     bx,1234h
        call    $gochk
        jnz     nopd2           ; Orig. nopd
        mov     bx,4321h
        call    $gochk
        jnz     nopd2           ; Orig. nopd
        clc
        ret
nopd2:  stc
        ret
$chkbk  endp

$gochk  proc    near
        push    si
        mov     si,bx

        mov     al,cl
        call    dx
        xchg    bl,es:[di]
        mov     al,ch
        call    dx
        xchg    bh,es:[di]

        xchg    si,bx

        mov     al,cl
        call    dx
        xor     bl,es:[di]
        mov     al,ch
        call    dx
        xor     bh,es:[di]

        xchg    si,bx

        mov     al,ch
        call    dx
        mov     es:[di],bh
        mov     al,cl
        call    dx
        mov     es:[di],bl

        mov     al,0
        call    dx
        or      si,si
        pop     si
        ret
$gochk  endp


$pdrsub proc    near            ;Paradise
        push    dx
        mov     ah,al
        mov     dx,3ceh
        mov     al,9
        out     dx,ax
        pop     dx
        ret
$pdrsub endp

        end

