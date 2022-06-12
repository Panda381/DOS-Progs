;****************************************************************************
;*
;*                      MegaGraph Graphics Library
;*
;*                  Copyright (C) 1993 Kendall Bennett.
;*                          All rights reserved.
;*
;* Filename:    $RCSfile: sv_ports.asm $
;* Version:     $Revision: 1.1 $
;*
;* Language:    80386 Assembler
;* Environment: IBM PC (MS DOS)
;*
;* Description: Number of macros to simplify the coding required to read
;*              write and modify I/O ports. A little slower than doing
;*              it directly, but more readable.
;*
;* $Id: sv_ports.asm 1.1 1993/03/03 10:46:44 kjb Exp $
;*
;* Revision History:
;* -----------------
;*
;* $Log: sv_ports.asm $
;* Revision 1.1  1993/03/03  10:46:44  kjb
;* Initial revision
;*
;****************************************************************************

MACRO   inp     port
    mov     dx,port                 ;; Read a byte from port 'port' into al
    in      al,dx
ENDM

MACRO   outp    port, value
    mov     dx,port                 ;; Write a byte to port 'port'
    mov     al,value
    out     dx,al
ENDM

MACRO   rdinx   port, index
    mov     dx,port                 ;; Read register 'port' index 'index'
    mov     al,index
    out     dx,al
    inc     dx
    in      al,dx                   ;; Result in AL
ENDM

MACRO   wrinx   port, index, val
    mov     al,index                ;; Write 'port' index 'index' with 'val'
    mov     ah,val
    mov     dx,port
    out     dx,ax
ENDM

MACRO   modinx  port, index, mask, nvw
    mov     dx,port
    mov     al,index
    out     dx,al
    inc     dx
    in      al,dx                   ;; Read the old value
    and     al,not mask             ;; Mask out bits to be changed
    or      al,nvw                  ;; Or in the changed bits
    out     dx,al                   ;; Write the value back again
ENDM

MACRO   tstreg  port, mask
    mov     bl,mask                 ; Mask in BL
    mov     dx,port                 ; Port in DX
    call    TestPort                ; Test if the port is alive
ENDM

MACRO   tstinx  port, reg, mask
    mov     bl,mask                 ; Mask in BL
    mov     al,reg                  ; Index in AL
    mov     dx,port                 ; Port in DX
    call    TestPortIndexed         ; Test if the port is alive
ENDM

MACRO   DacToPel
        mov     dx,3C8h             ; Force DAC into PEL mode
        in      al,dx
        mov     dx,3C6h
ENDM

MACRO   DacToCommand                ; Force DAC into command mode
        DacToPel                    ; Force to PEL mode first
        in      al,dx               ; Read exactly four times!
        in      al,dx
        in      al,dx
        in      al,dx
ENDM

;----------------------------------------------------------------------------
; TestPort  Check to see if an I/O port is alive
;----------------------------------------------------------------------------
;
; Tests to see if the bits in the specified mask are readable and writable
; at the specified port.
;
; Entry:        BL  - Mask value
;               DX  - Port to check
;
; Exit:         ZF set if check passed
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    TestPort

        in      al,dx           ; Read old value from port
        mov     cl,al           ; CL := old value
        mov     bh,bl
        not     bh              ; BH := NOT mask
        and     al,bh           ; AL := old value AND (NOT mask)
        out     dx,al           ; Clear all the bits in the mask
        in      al,dx           ; Read value back
        and     al,bl           ; Mask out bits changed
        jnz     @@NoPort        ; Masked value should be all zeros if alive

        mov     al,cl
        or      al,bl           ; AL := old value OR mask
        out     dx,al           ; Set all bits in the mask
        in      al,dx           ; Read value back
        and     al,bl           ; Mask out bits changed
        cmp     al,bl           ; Set ZF (all bits should be set) if alive

@@NoPort:
        mov     al,cl
        out     dx,al           ; Restore old value
        ret

ENDP    TestPort

;----------------------------------------------------------------------------
; TestPortIndexed   Check to see if an indexed port is alive
;----------------------------------------------------------------------------
;
; Tests to see if the bits in the specified mask are readable and writeable
; at the indexed port.
;
; Entry:        AL  - Port register index
;               BL  - Mask value
;               DX  - Port to check
;
; Exit:         ZF set if check passed
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    TestPortIndexed

        out     dx,al           ; Index the specified register
        inc     dx              ; Increment to data register port
        call    TestPort        ; And test the port
        ret

ENDP    TestPortIndexed

