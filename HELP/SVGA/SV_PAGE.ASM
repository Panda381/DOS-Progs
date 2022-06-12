;****************************************************************************
;*
;*                      MegaGraph Graphics Library
;*
;*                  Copyright (C) 1993 Kendall Bennett.
;*                          All rights reserved.
;*
;* Filename:    $RCSfile: sv_page.asm $
;* Version:     $Revision: 1.1 $
;*
;* Language:    80386 Assembler
;* Environment: IBM PC (MS DOS)
;*
;* Description: This source file contains the code needed to change display
;*              pages on supported SuperVGA adapters, along with tables to
;*              find the correct routines for a specified video card.
;*
;*              Not all SuperVGA's support extended page flipping, so
;*              unsupported cards are marked in the table.
;*
;* $Id: sv_page.asm 1.1 1993/03/03 10:27:23 kjb Exp $
;*
;* Revision History:
;* -----------------
;*
;* $Log: sv_page.asm $
;* Revision 1.1  1993/03/03  10:27:23  kjb
;* Initial revision
;*
;****************************************************************************

; Table of SuperVGA page flipping routines by video card. Unsupported cards
; are marked with a NONE_page.

SVGAPage:       dw  VESA_page       ; VESA SuperVGA
                dw  ATI_page        ; ATI Technologies SuperVGA (NONE)
                dw  NONE_page       ; AHEAD A SuperVGA (NONE)
                dw  AHEADB_page     ; AHEAD B SuperVGA
CHIPSPageOfs    dw  CHIPS_page      ; Chips & Technologies SuperVGA
EVEREXPageOfs   dw  NONE_page       ; Everex SuperVGA (NONE)
                dw  NONE_page       ; Genoa Systems SuperVGA (NONE)
                dw  NONE_page       ; OAK Technologies SuperVGA (NONE)
                dw  PARADISE_page   ; Paradise SuperVGA
                dw  TRIDENT88_page  ; Trident 8800 SuperVGA
                dw  TRIDENT89_page  ; Trident 8900 SuperVGA
                dw  VIDEO7_page     ; Video7 SuperVGA
                dw  ET3000_page     ; Tseng Labs ET3000 SuperVGA
                dw  ET4000_page     ; Tseng Labs ET4000 SuperVGA
                dw  NCR_page        ; NCR 77C22E SuperVGA
                dw  S3_page         ; S3 SuperVGA
                dw  NONE_page       ; AcuMos SuperVGA
                dw  NONE_page       ; AL2101 SuperVGA
                dw  NONE_page       ; MXIC SuperVGA
                dw  P2000_page      ; P2000 SuperVGA
                dw  NONE_page       ; RT3106 SuperVGA
                dw  CIRRUS_page     ; Cirrus 5422 SuperVGA

NewPage     dw  NONE_page       ; Address of page flipping routine
BankOffset  dw  0               ; Current bank offset for visible page

;----------------------------------------------------------------------------
; SetupPaging   Setup the SuperVGA extended page flipping routines
;----------------------------------------------------------------------------
;
; Given the id of the SuperVGA card that is installed, this routine sets
; up the following extended page flipping code.
;
; Exit:         CF = 1 if paging not supported on adapter
;
; Registers:    AX,CX,SI,DI
;
;----------------------------------------------------------------------------
PROC    SetupPaging near

        mov     [NewPage],offset NONE_page
        mov     [BankOffset],0
        mov     ax,[CntDriver]
        cmp     ax,grSVGA
        jl      @@Invalid           ; Not a SuperVGA adapter
        je      @@VESASuperVGA      ; We have a VESA SuperVGA adapter

        mov     si,offset SVGAPage
        mov     ax,[CntDriver]      ; AX := number of current driver
        sub     ax,grSVGA           ; Adjust to start at 0 for SVGA's
        shl     ax,1
        add     si,ax               ; SI := index into table of SVGA banks
        mov     ax,[cs:si]          ; Load page flip routine address
        mov     [NewPage],ax        ; and save it for later

        cmp     ax,offset NONE_page
        jz      @@Invalid           ; Paging not supported on this adapter
        clc
        jmp     @@Exit

; We have a VESA SuperVGA adapter, so determine if extended page flipping
; is supported by the video BIOS.

@@VESASuperVGA:
        call    checkVESAPageFlip
        jc      @@Exit              ; No page flipping available

; Horrah! We have page flipping on a VESA board.

        mov     ax,offset VESA_page ; Setup for VESA page flipping
        mov     [NewPage],ax
        clc
        jmp     @@Exit

@@Invalid:
        stc

@@Exit:
        ret

ENDP    SetupPaging

;----------------------------------------------------------------------------
; NewPage   Set the visible page start address.
;----------------------------------------------------------------------------
;
; Program the start address for the appropriate video cards. If the card
; is not a SuperVGA, we simply set the lower 16 bits of the start address,
; otherwise we also set the top bits for the SuperVGA adapter.
;
; Note that interrupts will be off when these routines are called.
;
; These routines assumes that access to the SuperVGA's extended registers
; has already been set up (if required).
;
; Entry:        BL  - Index of start address low register
;               BH  - Bits 7-0 of new start address
;               CL  - Index of start address high register
;               CH  - Bits 15-8 of new start address
;               SI  - Bits 16+ for new start address
;
; Registers:    AX,BX,CX,DX,SI
;
;----------------------------------------------------------------------------

; Macro to set the low start address bits, and to load BX with the
; top bits for SuperVGA adapters.

MACRO   SetLowStartAddress
        mov     dx,03D4h            ; DX := CRTC I/O port (3D4h)
        mov     ax,bx
        out     dx,ax
        mov     ax,cx
        out     dx,ax
        mov     bx,si               ; BX := Bits 16+ for start address
ENDM

NONE_page:
        SetLowStartAddress
        ret

VESA_page:
        mov     cl,bh               ; CX := Bits 15-0 of start address
        mov     ax,cx
        mov     dx,si               ; DX:AX := start address
        div     [BytesPerLine]      ; Divide by bytes per line value
        mov     cx,dx
        cmp     [CntColors],gr16Color
        jne     @@V1
        shl     cx,3                ; CX := leftmost pixel in scanline
@@V1:   mov     dx,ax               ; DX := starting scanline number
        mov     ax,4F07h            ; Set display start service
        xor     bx,bx
        int     10h                 ; Set the display start address
        ret

ATI_page:
        SetLowStartAddress
        mov     dx,1CEh
        mov     al,0B0h             ; Index of start address register
        out     dx,al
        inc     dx
        in      al,dx               ; Read old value
        and     al,3Fh              ; Mask out old bits 7-6
        and     bl,3                ; Mask out bottom two bits
        shl     bl,6                ; Shift into position
        or      al,bl               ; Combine the values
        out     dx,al               ; Output the result
        ret

AHEADB_page:
        SetLowStartAddress
        mov     dx,03CEh
        mov     al,01Ch
        out     dx,al               ; Index the start address register
        inc     dx
        in      al,dx               ; Read current value
        and     al,0FCh             ; Mask out old address values
        and     bl,3                ; Mask out bottom two bits
        or      al,bl               ; Or in the new start address
        out     dx,al               ; Output the address
        ret

CHIPS_page:
        SetLowStartAddress
        mov     dx,03D6h
        mov     al,0Ch
        mov     ah,bl
        out     dx,ax               ; Set the extended start address
        mov     al,04h
        out     dx,al               ; Index memory map register
        inc     dx
        in      al,dx               ; Read register value
        or      al,4                ; Set bit 2 for extended paging
        out     dx,al               ; Set the value
        ret

PARADISE_page:
        SetLowStartAddress
        mov     dx,03CEh
        mov     al,0Dh
        out     dx,al               ; Index PR3 CRT Control register
        inc     dx
        in      al,dx               ; Read current value
        and     al,0E7h             ; Zero out bits 4-3
        and     bl,3                ; Mask out bottom 2 bits
        shl     bl,3                ; Shift into correct position
        or      al,bl               ; Or in the new start address
        out     dx,al               ; Output the address
        ret

TRIDENT88_page:
        SetLowStartAddress
        mov     dx,3D4h             ; DX := CRTC I/O port
        mov     al,01Eh
        out     dx,al               ; Index module testing register
        inc     dx
        in      al,dx               ; Read current value
        and     al,0DFh             ; Mask out start address bit 5
        and     bl,1                ; Only want one bit
        shl     bl,5                ; Put into correct position
        or      al,bl               ; Or in the new start address
        or      al,80h              ; Set bit 7 for enable bit 16
        out     dx,al               ; Output the address
        ret

TRIDENT89_page:
        SetLowStartAddress
        push    bx
        mov     dx,3D4h             ; DX := CRTC I/O port
        mov     al,01Eh
        out     dx,al               ; Index module testing register
        inc     dx
        in      al,dx               ; Read current value
        and     al,05Fh             ; Mask out start address
        and     bl,1                ; Only want one bit
        shl     bl,5                ; Put into correct position
        or      al,bl               ; Or in new start address values
        or      al,80h              ; Set bit 7 for enable bit 16
        out     dx,al               ; Output the address
        mov     dx,3C4h
        mov     al,0Bh
        out     dx,al
        inc     dl
        xor     al,al
        out     dx,al               ; Select old mode control registers
        dec     dl
        mov     al,0Eh              ; Index old mode control register
        out     dx,al
        inc     dl
        in      al,dx               ; Read old value
        and     al,0FEh             ; Mask out old value
        pop     bx
        shr     bl,1
        and     bl,1                ; Mask out only bit 17 of address
        or      al,bl               ; Combine with old value
        out     dx,al               ; Output the address
        ret

VIDEO7_page:
        SetLowStartAddress
        mov     dx,3C4h
        mov     al,0F6h
        out     dx,al               ; Index extended start address
        inc     dx
        in      al,dx               ; Read current value
        and     al,0CFh             ; Zero out start address 17-16 bit 5-4
        and     bl,3                ; Mask out all but bottom 2 bits
        shl     bl,4                ; Shift left into correct position
        or      al,bl               ; Or in the new start address
        out     dx,al               ; Output the address
        ret

ET3000_page:
        SetLowStartAddress
        mov     dx,3D4h             ; DX := CRTC I/O port
        mov     al,23h              ; Index extended start address
        out     dx,al
        inc     dx
        in      al,dx               ; Read current value
        and     al,0FDh             ; Zero out start address
        and     bl,1                ; Only one bit is valid
        shl     bl,1                ; Put bit into correct pos.
        or      al,bl               ; Or in the new start address
        out     dx,al               ; Output the address
        ret

ET4000_page:
        SetLowStartAddress
        mov     dx,3D4h             ; DX := CRTC I/O port
        mov     al,33h              ; Index extended start address
        out     dx,al
        inc     dx
        in      al,dx               ; Read current value
        and     al,0FCh             ; Zero out start address
        and     bl,3                ; Mask out all but bottom 2 bits
        or      al,bl               ; Or in new start address
        out     dx,al               ; Output the address
        ret

NCR_page:
        SetLowStartAddress
        mov     dx,3C4h
        mov     al,31h              ; Index of start address register
        out     dx,al
        inc     dx
        in      al,dx               ; Read old value
        and     al,0F0h             ; Clear bottom three bits
        and     bl,0Fh              ; Mask out bottom four bits
        or      al,bl
        out     dx,al               ; Set the new value
        ret

S3_page:
        SetLowStartAddress
        mov     dx,3D4h             ; DX := CRTC I/O port
        mov     ax,4838h            ; Enable extended registers
        out     dx,ax
        mov     al,31h              ; Index of S3R1
        out     dx,al
        inc     dl
        in      al,dx               ; Read old value of S3R1
        and     al,0CFh             ; Mask off bits 5-4
        shl     bl,4                ; Shift into bit pos 5-4
        or      al,bl               ; Or in starting address value
        out     dx,al               ; Set the new value
        dec     dl
        mov     ax,0038h            ; Disable extended registers
        out     dx,ax
        ret

P2000_page:
        SetLowStartAddress
        mov     dx,3CEh
        mov     al,21h              ; Index of start address register
        out     dx,al
        inc     dx
        in      al,dx               ; Read old value
        and     al,0F8h             ; Clear out bottom 3 bits
        and     bl,7                ; Mask off bottom three bits
        or      al,bl               ; Or in starting address value
        out     dx,al               ; Set the new value
        ret

CIRRUS_page:
        SetLowStartAddress
        mov     dx,3D4h             ; DX := CRTC I/O port
        mov     al,1Bh              ; Index of start address register
        out     dx,al
        inc     dx
        in      al,dx               ; Read old value
        and     al,0FAh             ; Clear out bits 0 and 2
        mov     bh,bl
        and     bh,2                ; BH := bit 17 of start address
        shl     bh,1                ; BH := bit 17 in bit pos 2
        and     bl,1                ; BL := bit 16 of start address
        or      bl,bh               ; BL := combined bit 16 and bit 17
        or      al,bl               ; Or in starting address value
        out     dx,al               ; Set the new value
        ret
