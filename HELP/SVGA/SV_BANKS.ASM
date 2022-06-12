;****************************************************************************
;*
;*                      MegaGraph Graphics Library
;*
;*          Copyright (C) 1993 Kendall Bennett.
;*                          All rights reserved.
;*
;* Filename:    $RCSfile: sv_banks.asm $
;* Version:     $Revision: 1.2 $
;*
;* Language:    80386 Assembler
;* Environment: IBM PC (MS DOS)
;*
;* Description: This source file contains the code needed to change banks
;*              on supported SuperVGA adapters, along with tables to find
;*              the correct routines for a specified video card.
;*
;*              The code in here originally appeared in John Bridges
;*              VGAKIT library, and has been modified to work with the
;*              MGL. Specifically support for individually setting the
;*              read and write banks has been included, along with adapter
;*              initialisation code (such as accessing extended registers
;*              etc).
;*
;*              To set up separate read/write banks, you must first call
;*              NewBank to set the read/write banks to the same value,
;*              then call ReadBank to change the read bank value.
;*
;* $Id: sv_banks.asm 1.2 1993/03/07 04:05:36 kjb Exp $
;*
;* Revision History:
;* -----------------
;*
;* $Log: sv_banks.asm $
;* Revision 1.2  1993/03/07  04:05:36  kjb
;* Bug fixes.
;*
;* Revision 1.1  1993/03/03  10:26:52  kjb
;* Initial revision
;*
;****************************************************************************

; Table of SuperVGA bank switching routines by video card.

SVGAInfoTable:
    dw  false,  VESA_bank,      VESA_bank,      VESA_init,      NONE_exit
    dw  true,   ATI_bank,       ATI_rbank,      ATI_init,       NONE_exit
    dw  false,  AHEADA_bank,    AHEADA_bank,    AHEAD_init,     AHEAD_exit
    dw  true,   AHEADB_bank,    AHEADB_rbank,   AHEAD_init,     AHEAD_exit
    dw  false,  CHIPS451_bank,  CHIPS451_bank,  CHIPS_init,     CHIPS_exit
    dw  false,  EVEREX_bank,    EVEREX_bank,    EVEREX_init,    NONE_exit
    dw  true,   GENOA_bank,     GENOA_rbank,    NONE_init,      NONE_exit
    dw  true,   OAK_bank,       OAK_rbank,      NONE_init,      NONE_exit
    dw  true,   PARADISE_bank,  PARADISE_rbank, PARADISE_init,  PARADISE_exit
    dw  false,  TRIDENT_bank,   TRIDENT_bank,   TRIDENT_init,   NONE_exit
    dw  false,  TRIDENT_bank,   TRIDENT_bank,   TRIDENT_init,   NONE_exit
    dw  true,   VIDEO7V5_bank,  VIDEO7V5_rbank, VIDEO7_init,    VIDEO7_exit
    dw  true,   ET3000_bank,    ET3000_rbank,   NONE_init,      NONE_exit
    dw  true,   ET4000_bank,    ET4000_rbank,   ET4000_init,    NONE_exit
    dw  true,   NCR_bank,       NCR_rbank,      NCR_init,       NONE_exit
    dw  false,  S3_bank,        S3_bank,        S3_init,        NONE_exit
    dw  false,  ACUMOS_bank,    ACUMOS_bank,    ACUMOS_init,    ACUMOS_exit
    dw  false,  AL2101_bank,    AL2101_bank,    AL2101_init,    NONE_exit
    dw  true,   MXIC_bank,      MXIC_rbank,     MXIC_init,      MXIC_exit
    dw  true,   P2000_bank,     P2000_rbank,    NONE_init,      NONE_exit
    dw  true,   RT3106_bank,    RT3106_rbank,   RT3106_init,    NONE_exit
    dw  false,  CIRRUS_bank,    CIRRUS_bank,    CIRRUS_init,    CIRRUS_exit

SVGAInfo:
TwoBanks    dw  0               ; Flags if two banks available
NewBank     dw  NONE_bank       ; Address of read/write bank switch routine
ReadBank    dw  NONE_bank       ; Address of read bank routine
InitSVGA    dw  NONE_init       ; Address of card Init routine
ExitSVGA    dw  NONE_exit       ; Address of card close routine
SVGAInfoSize    = ($-SVGAInfo)  ; Size of the above table

CurBank     dw  0FFh            ; Currently active read/write bank
VesaGran    db  0               ; VESA Granularity
VesaBank    dd  0               ; Address of VESA bank switch routine
VesaBuf     db  256 dup (?)     ; Place to store VESA Info

VesaModes:  dw  100h, grSVGA_640x400x256
            dw  101h, grSVGA_640x480x256
            dw  102h, grSVGA_800x600x16
            dw  103h, grSVGA_800x600x256
            dw  104h, grSVGA_1024x768x16
            dw  105h, grSVGA_1024x768x256
            dw  106h, grSVGA_1280x1024x16
            dw  107h, grSVGA_1280x1024x256
            dw  10Dh, grSVGA_320x200x32k
            dw  10Fh, grSVGA_320x200x16m
            dw  110h, grSVGA_640x480x32k
            dw  112h, grSVGA_640x480x16m
            dw  113h, grSVGA_800x600x32k
            dw  115h, grSVGA_800x600x16m
            dw  116h, grSVGA_1024x768x32k
            dw  118h, grSVGA_1024x768x16m
            dw  119h, grSVGA_1280x1024x32k
            dw  11Bh, grSVGA_1280x1024x16m
            dw  0

;----------------------------------------------------------------------------
; SetupBanks    Setup the SuperVGA bank switching routines
;----------------------------------------------------------------------------
;
; Given the id of the SuperVGA card that is installed, this routine sets
; up the following bank switching code.
;
; Registers:    AX,CX,SI,DI
;
;----------------------------------------------------------------------------
PROC    SetupBanks  near

        mov     [ReadBank],offset NONE_bank
        mov     [InitSVGA],offset NONE_init
        mov     ax,[CntDriver]
        cmp     ax,grSVGA
        jl      @@Exit              ; Not a SuperVGA adapter

        mov     si,offset SVGAInfoTable
        mov     ax,[CntDriver]      ; AX := number of current driver
        sub     ax,grSVGA           ; Adjust to start at 0 for SVGA's
        mov     cx,SVGAInfoSize
        mul     cx
        add     si,ax               ; SI := index into table of SVGA banks
        mov     di,offset SVGAInfo
        push    cs
        pop     es
    rep movs    [BYTE es:di],[BYTE es:si]

@@Exit:
        mov     [CurBank],0FFh      ; Set the bank to nothing to start with
        ret

ENDP    SetupBanks

;----------------------------------------------------------------------------
; NewBank   Change to a new 64k bank on a SuperVGA card (reading and writing)
;----------------------------------------------------------------------------
;
; Changes to a new 64k bank given the specified index. The global variable
; CurBank is updated to reflect the current bank number and can be used
; to avoid unnecessary bank switching.
;
; These routines should set both the read and write bank for cards that
; support multiple banks to the same bank number.
;
; Note that the value of all regs MUST be preserved across this call.
;
; Entry:        AX  - Number of 64k bank (0-15 for 1Mb cards)
;
; Registers:    None.
;
;----------------------------------------------------------------------------

NONE_bank:
        ret

VESA_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        push    ax
        push    bx
        push    dx
        mul     [VesaGran]          ; Adjust with granularity factor
        push    ax
        mov     dx,ax               ; Select window position
        xor     bx,bx               ; BH := 0 (Select SVGA memory window)
                                    ; BL := 0 (window to set)
        call    [VesaBank]          ; Change bank A
        pop     dx                  ; Select window position
        inc     bx                  ; BL := 1 (window to set)
        call    [VesaBank]          ; Change bank B
        pop     dx
        pop     bx
        pop     ax
        ret

ATI_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        and     al,0Fh              ; Mask out bottom four bits
        mov     ah,al
        shl     ah,4                ; Shift read bank into position
        or      ah,al               ; AH := combined read/write register numbers
        rol     ah,1                ; Shift banks numbers in position
        mov     dx,1CEh             ; Port of extended registers
        mov     al,0B2h
        out     dx,ax               ; Set the ATI Bank Register
        pop     dx
        pop     ax
        sti
        ret

AHEADA_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        push    cx
        mov     ch,al
        mov     dx,03CCh            ; bit 0 in bit 5 of Misc Output reg
        in      al,dx               ; Read Misc output register
        mov     dl,0C2h
        and     al,11011111b
        shr     ch,1                ; Need to set the bit?
        jnc     @@SkpA              ; No, so skip it
        or      al,00100000b
@@SkpA: out     dx,al               ; Set the new value
        mov     dx,3CEh             ; bits 3-1 in bits 2-0 of Segment Reg
        mov     al,0Dh              ; Index 0Dh for segment reg
        mov     ah,ch               ; ch contains top three bits shr 1
        out     dx,ax               ; Set the new value
        pop     cx
        pop     dx
        pop     ax
        sti
        ret

AHEADB_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     ah,al               ; Combine read/write bank numbers
        shl     ah,4
        or      ah,al
        mov     al,0Dh              ; Index of Bank Switch register
        mov     dx,3CEh
        out     dx,ax               ; Set the register
        pop     dx
        pop     ax
        sti
        ret

CHIPS451_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     ah,al
        mov     al,0Bh              ; Index of Single/Low Map register
        mov     dx,3D6h
        out     dx,ax               ; Set the register value
        pop     dx
        pop     ax
        sti
        ret

CHIPS452_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     ah,al
        shl     ah,2                ; Change 64k bank into 16k bank number
        mov     al,10h              ; Index of Single/Low Map register
        mov     dx,3D6h
        out     dx,ax               ; Set the register value
        pop     dx
        pop     ax
        sti
        ret

CHIPS453_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     ah,al
        shl     ah,4                ; Change 64k bank into 4k bank number
        mov     al,10h              ; Index of Single/Low Map register
        mov     dx,3D6h
        out     dx,ax               ; Set the register value
        pop     dx
        pop     ax
        sti
        ret

EVEREX_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        push    cx
        mov     cl,al
        mov     dx,3C4h
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
        out     dx,ax               ; Bit 0 stored in 3C4 index 8 bit 7
        mov     dl,0CCh
        in      al,dx
        mov     dl,0C2h
        and     al,0DFh
        shr     cl,1
        jc      @@Nob2
        or      al,20h
@@Nob2: out     dx,al               ; Bit 1 stored in 3C2 bit 5
        pop     cx
        pop     dx
        pop     ax
        sti
        ret

GENOA_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     ah,al               ; Put read bank in bits 2-0 ...
        shl     al,3                ; ...  write bank in bits 5-3
        or      ah,al
        or      ah,40h              ; Set MEM bit
        mov     al,6                ; Index of Memory Segment Register
        mov     dx,3C4h
        out     dx,ax               ; Set the read/write banks
        pop     dx
        pop     ax
        sti
        ret

OAK_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        and     al,15
        mov     ah,al               ; Combine read/write bank numbers
        shl     al,4
        or      ah,al
        mov     al,11h              ; Index of bank switch register
        mov     dx,3DEh
        out     dx,ax               ; Set the register value
        pop     dx
        pop     ax
        sti
        ret

PARADISEPVGA_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     dx,3CEh
        shl     al,4                ; change 64k bank into 4k bank number
        mov     ah,al
        mov     al,9                ; Index of PROA register
        out     dx,ax               ; Program PROA register
        pop     dx
        pop     ax
        sti
        ret

PARADISE_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     dx,3CEh
        shl     al,4                ; change 64k bank into 4k bank number
        mov     ah,al
        mov     al,9                ; Index of PROA register (read bank)
        out     dx,ax               ; Program PROA register
        mov     al,0Ah              ; Index of PROB register (write bank)
        out     dx,ax               ; Program PROB register
        pop     dx
        pop     ax
        sti
        ret

TRIDENT_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        xor     al,2                ; Adjust page bit
        mov     ah,al
        mov     dx,3C4h
        mov     al,0Bh              ; Index of Chip Version register
        out     dx,al               ; Program index
        inc     dl
        xor     al,al
        out     dx,al               ; Force old definitions
        in      al,dx               ; Force new definitions
        dec     dl
        mov     al,0Eh              ; Index of New Mode Control Reg
        out     dx,ax               ; Program the page value
        pop     dx
        pop     ax
        sti
        ret

NCR_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        shl     al,2                ; Change 64k bank into 16k bank number
        cmp     [CntColors],gr16Color
        jne     @@NCR1
        shl     al,2                ; Change 64k bank into 4k bank number
@@NCR1: mov     ah,al
        mov     al,18h
        mov     dx,3C4h
        out     dx,ax               ; Set write bank number
        mov     al,1Ch
        out     dx,ax               ; Set read bank number
        pop     dx
        pop     ax
        sti
        ret

VIDEO7_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    cx
        push    dx
        and     al,0Fh              ; Mask to 4 bits
        mov     ch,al
        mov     dx,3C4h
        mov     ah,ch
        and     ah,1
        mov     al,0F9h             ; Index of Extended Page Select register
        out     dx,ax               ; Program PS bit in register
        mov     al,ch
        and     al,1100b            ; Bits 3-2 for read field
        mov     ah,al
        shr     ah,2                ; Bits 1-0 for write field
        or      ah,al               ; Combine two values
        mov     al,0F6h
        out     dx,al               ; Index the bank select register
        inc     dl
        in      al,dx               ; Read old value
        and     al,11110000b        ; Zero out old bits
        or      al,ah               ; Combine with new values
        out     dx,al               ; Program the values
        mov     ah,ch
        and     ah,10b              ; Mask out bit 2
        shl     ah,4                ; Put into bit 5
        mov     dx,3CCh             ; Address Miscellaneous register
        in      al,dx               ; Read old value
        and     al,0DFh             ; Zero bit 5
        mov     dx,3C2h
        or      al,ah               ; Or in the page bit
        out     dx,al               ; Program the new value
        pop     dx
        pop     cx
        pop     ax
        sti
        ret

VIDEO7V5_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        and     al,0Fh              ; Mask to 4 bits
        shl     al,4                ; Shift into bits 7-4
        mov     ah,al
        mov     dx,3C4h
        mov     al,0E8h             ; Index of write bank register
        out     dx,ax               ; Program the write bank
        mov     al,0E9h             ; Index of read bank register
        out     dx,ax               ; Program the read bank
        pop     dx
        pop     ax
        sti
        ret

ET3000_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        and     al,7                ; Mask out bottom 3 bits
        mov     ah,al               ; Combine read and write bank values in al
        shl     ah,3
        or      al,ah
        or      al,40h              ; Set bit 6 to select 64k segments
        mov     dx,3CDh             ; Point to memory segment register
        out     dx,al               ; Set the new bank value
        pop     dx
        pop     ax
        sti
        ret

ET4000_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        and     al,0Fh              ; Mask out bottom 4 bits
        mov     ah,al               ; Combine read and write values in al
        shl     ah,4
        or      al,ah
        mov     dx,3CDh             ; Point to memory segment register
        out     dx,al               ; Set the new bank value
        pop     dx
        pop     ax
        sti
        ret

S3_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    cx
        push    dx
        mov     dx,3D4h
        cmp     [CntColors],gr16Color
        jne     @@S31
        shl     al,2                ; bank = bank * 4 in 16 color modes
@@S31:  and     al,0Fh              ; Mask off all but bottom 4 bits
        mov     cl,al
        mov     ax,4838h            ; Enable extended registers
        out     dx,ax
        mov     al,31h              ; Index of S3R1
        out     dx,al
        inc     dl
        in      al,dx               ; Read value of S3R1
        or      al,9                ; Set bits 0 and 3
        or      al,1001b
        out     dx,al               ; Write value back again
        dec     dl
        mov     al,35h              ; Index of S3R5
        out     dx,al
        inc     dl
        in      al,dx               ; Read value of S3R5
        and     al,0F0h             ; Mask off low nybble
        or      al,cl               ; Or in new bank number
        out     dx,al               ; Write the value back again
        dec     dl
        mov     ax,0038h            ; Disable extended registers
        out     dx,ax
        pop     dx
        pop     cx
        pop     ax
        sti
        ret

CIRRUS_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     dx,3CEh
        shl     al,4                ; Convert to 4k bank number
        mov     ah,al
        mov     al,9
        out     dx,ax
        pop     dx
        pop     ax
        sti
        ret

ACUMOS_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     dx,3CEh
        shl     al,4                ; Convert to 4k bank number
        mov     ah,al
        mov     al,9
        out     dx,ax
        pop     dx
        pop     ax
        sti
        ret

AL2101_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     dx,3D6h
        out     dx,al               ; Set read bank register
        inc     dx
        out     dx,al               ; Set write bank
        pop     dx
        pop     ax
        sti
        ret

MXIC_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        and     al,0Fh              ; Mask out all but 4 bottom bits
        mov     ah,al               ; Combine read/write bank numbers
        shl     al,4
        or      ah,al
        mov     al,0C5h             ; Index of bank switch register
        mov     dx,3C4h
        out     dx,ax               ; Set the register value
        pop     dx
        pop     ax
        sti
        ret

P2000_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     dx,3D6h
        out     dx,al               ; Set write bank register
        inc     dx
        out     dx,al               ; Set read bank
        pop     dx
        pop     ax
        sti
        ret

RT3106_bank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     dx,3D6h
        out     dx,al               ; Set write bank register
        inc     dx
        out     dx,al               ; Set read bank
        pop     dx
        pop     ax
        sti
        ret

;----------------------------------------------------------------------------
; ReadBank  Change to a new 64k read bank on a SuperVGA card
;----------------------------------------------------------------------------
;
; Changes to a new 64k bank for reading given the specified index. The write
; bank should be preserved across this call.We also trash the value in
; CurBank to indicate that bank switching needs to be done again to set
; the read and write banks to the same value.
;
; Note that the value of all regs MUST be preserved across this call.
;
; Entry:        AX  - Number of 64k bank (0-15 for 1Mb cards)
;
; Registers:    None.
;
;----------------------------------------------------------------------------

VESA_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        push    ax
        push    bx
        push    dx
        mul     [VesaGran]          ; Adjust with granularity factor
        mov     dx,ax               ; Select window position
        xor     bh,bh               ; BH := 0 (Select SVGA memory window)
        mov     bl,1                ; Window to set
        call    [VesaBank]          ; Change bank
        pop     dx
        pop     bx
        pop     ax
        ret

ATI_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        and     al,0Fh              ; Mask out bottom four bits
        rol     al,5                ; Shift read bank into position
        mov     ah,al
        mov     dx,1CEh             ; Port of extended registers
        mov     al,0B2h
        out     dx,al               ; Index ATI bank register
        inc     dl
        in      al,dx
        and     al,01Eh             ; Zero out bits 7-5 and bit 0
        or      ah,al               ; AL := combined value
        mov     al,0B2h
        out     dx,ax               ; Ouput the new value
        pop     dx
        pop     ax
        sti
        ret

AHEADB_rbank:
        mov     [CurBank],ax        ; Save the new bank number for later
        cli
        push    ax
        push    dx
        mov     ah,al               ; Read bank number in bits 3-0
        mov     al,0Dh              ; Index of Bank Switch register
        mov     dx,3CEh
        out     dx,al
        inc     dl
        in      al,dx               ; Read old register value
        and     al,0F0h             ; Mask out bits 3-0
        or      al,ah               ; Combine with new value
        out     dx,al               ; Set the new register value
        pop     dx
        pop     ax
        sti
        ret

GENOA_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        and     al,7                ; Mask out bottom three bits
        mov     ah,al
        mov     dx,3C4h
        mov     al,6                ; Index of Memory Segment Register
        out     dx,al               ; Output index
        inc     dl
        in      al,dx               ; Read current value
        and     al,0F8h             ; Zero bits 2-0
        or      al,ah               ; Or in new value
        out     dx,al               ; Output the new bank
        pop     dx
        pop     ax
        sti
        ret

OAK_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        and     al,15
        mov     ah,al               ; AH := read bank number
        mov     al,11h              ; Index of bank switch register
        mov     dx,3DEh
        out     dx,al
        inc     dl
        in      al,dx               ; Read old value
        and     al,0F0h             ; Mask out read bank value
        or      al,ah               ; Or in new value
        out     dx,al               ; Program the new value
        pop     dx
        pop     ax
        sti
        ret

PARADISE_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        mov     dx,3CEh
        shl     al,4                ; change 64k bank into 4k bank number
        mov     ah,al
        mov     al,09h              ; Index of PROA register (read bank)
        out     dx,ax               ; Program PROA register
        pop     dx
        pop     ax
        sti
        ret

NCR_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        shl     al,2                ; Change 64k bank into 16k bank number
        cmp     [CntColors],gr16Color
        jne     @@NCR2
        shl     al,2                ; Change 64k bank into 4k bank number
@@NCR2: mov     ah,al
        mov     al,1Ch
        mov     dx,3C4h
        out     dx,ax               ; Set read bank number
        pop     dx
        pop     ax
        sti
        ret

VIDEO7V5_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        and     al,0Fh              ; Mask to 4 bits
        shl     al,4                ; Shift into bits 7-4
        mov     ah,al
        mov     dx,3C4h
        mov     al,0E9h             ; Index of read bank register
        out     dx,al               ; Program the value
        pop     dx
        pop     ax
        sti
        ret

ET3000_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        mov     ah,bl               ; Save value of bl
        and     al,7                ; Mask out bottom 3 bits
        shl     al,3                ; Shift into position
        mov     bl,al
        mov     dx,3CDh
        in      al,dx               ; Read current value
        and     al,0C7h             ; Mask out read bank select value
        or      al,bl               ; Or in the new read bank value
        out     dx,al               ; Set the new bank value
        mov     bl,ah               ; Restore value of bl
        pop     dx
        pop     ax
        sti
        ret

ET4000_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        mov     ah,bl               ; Save value of bl
        and     al,0Fh              ; Mask out bottom 4 bits
        shl     al,4                ; Shift into position
        mov     bl,al
        mov     dx,3CDh
        in      al,dx               ; Read current value
        and     al,00Fh             ; Mask out read bank select bits 7-4
        or      al,bl               ; Or in the new read bank value
        out     dx,al               ; Set the new bank value
        mov     bl,ah               ; Restore value of bl
        pop     dx
        pop     ax
        sti
        ret

AL2101_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        mov     dx,3D6h
        out     dx,al               ; Set read bank register
        pop     ax
        pop     dx
        sti
        ret

MXIC_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        and     al,0Fh              ; Mask out all but 4 bottom bits
        shl     al,4
        mov     ah,al
        mov     al,0C5h             ; Index of bank switch register
        mov     dx,3C4h
        out     dx,al
        inc     dx
        in      al,dx               ; Read old value
        and     al,0Fh              ; Mask out old read bank values
        or      al,ah
        out     dx,al               ; Set the register value
        pop     dx
        pop     ax
        sti
        ret

P2000_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        mov     dx,3D7h
        out     dx,al               ; Set read bank
        pop     dx
        pop     ax
        sti
        ret

RT3106_rbank:
        mov     [CurBank],0FFh      ; Trash CurBank with invalid value
        cli
        push    ax
        push    dx
        mov     dx,3D6h
        out     dx,al               ; Set read bank register
        pop     ax
        pop     dx
        sti
        ret

;----------------------------------------------------------------------------
; InitBank  Initialise the SuperVGA card for bank switching if required
;----------------------------------------------------------------------------
;
; Peforms any initialisations required by the SuperVGA card prior to bank
; switching (accessing extended registers, setting the mode etc).
;
; Note: All register may be used without concern for saving their values
;
; Registers:    All.
;
;----------------------------------------------------------------------------

PROC    NONE_init   near
        ret
ENDP    NONE_init

;----------------------------------------------------------------------------
; VESA_init
;----------------------------------------------------------------------------
; We have a VESA SuperVGA adapter, so determine the granularity and address
; of the VESA bank switching routine. We simply determine whether we are
; in 16 or 256 color video modes, and get information about these modes.
;----------------------------------------------------------------------------
PROC    VESA_init   near

        push    cs
        pop     es
        mov     di,offset VesaBuf   ; ES:DI -> Buffer for VESA info
        mov     bx,[CntMode]
        mov     si,offset VesaModes ; CS:SI -> Table of VESA video modes

        mov     cx,102h             ; 800 x 600 16 color
        cmp     bx,grVGA_640x480x16
        jle     @@NonVESA
        mov     cx,101h             ; 640 x 480 256 color
        cmp     bx,grVGA_320x200x256
        je      @@NonVESA

@@ModeLoop:
        lods    [WORD cs:si]
        mov     cx,ax               ; CX := VESA Mode Number
        jcxz    @@Exit              ; Fall through if no match
        lods    [WORD cs:si]
        cmp     ax,bx
        jne     @@ModeLoop

        mov     ax,4F01h
        int     10h                 ; Call the video BIOS to get info

        mov     ax,[CntMode]
        mov     bx,[WORD VesaBuf+16]
        call    setBytesPerLine
        mov     [BytesPerLine],bx
        jmp     @@SaveValues

@@NonVESA:
        mov     ax,4F01h
        int     10h

@@SaveValues:
        mov     ax,[WORD VesaBuf+12]; Save pointer to bank switching routine
        mov     [WORD VesaBank],ax
        mov     ax,[WORD VesaBuf+14]
        mov     [WORD VesaBank+2],ax

        mov     cx,[WORD VesaBuf+4] ; Load VESA granularity value
        mov     al,1
        cmp     cx,0                ; Some BIOS'S fuck this up!
        je      @@NoDivide
        mov     ax,64
        div     cl
@@NoDivide:
        mov [VesaGran],al       ; Save the granularity scale factor

; Now determine if this video card supports multiple banks

        mov     ax,[WORD VesaBuf+2] ; Get Window attributes
        and     ah,0111b            ; Mask out appropriate bits
        cmp     ah,0011b            ; Check if second window is only readable
        jne     @@Exit              ; No, so we are done

        mov     [TwoBanks],true
        mov     [ReadBank],offset VESA_rbank

@@Exit:
        ret

ENDP    VESA_init

;----------------------------------------------------------------------------
; ATI_init
;----------------------------------------------------------------------------
; We have an ATI video card. The 18800-1 and 28800 chips support the dual
; paging mode, but the old 18800 chip does not.
;----------------------------------------------------------------------------
PROC    ATI_init near

        push    bp

        cmp     [CntChipID],grATI_18800
        jne     @@Not18800

; We have an 18800 based ATI SuperVGA, so modify to not use separate read
; write banks.

        mov     [TwoBanks],false
        mov     [ReadBank],offset ATI_bank
        jmp     @@Exit

; We have an 18800-1 or 28800 Chip, so setup for dual bank mode

@@Not18800:
        modinx  1CEh, 0BEh, 01000b, 01000b  ; Set bit 3 ATI Register E

@@Exit:
        pop     bp
        ret

ENDP    ATI_init

;----------------------------------------------------------------------------
; AHEAD_init
;----------------------------------------------------------------------------
; We have an Ahead A or B SuperVGA. We simply enable the extended registers
; to save time during bank switching.
;----------------------------------------------------------------------------
PROC    AHEAD_init  near

        outp    3CEh, 0Fh, 20h      ; Enable extended registers
        modinx  3CEh, 0Ch, 20h, 20h ; Enable enhanced mode
        ret

ENDP    AHEAD_init

;----------------------------------------------------------------------------
; CHIPS_init
;----------------------------------------------------------------------------
; We have a Chips & Technologies 82c451/452/453. To save time during
; bank switching, we enable the SuperVGA extended registers here.
; We also determine the type of chipset installed and setup bank switching
; and page flipping according to the chip type.
;----------------------------------------------------------------------------
PROC    CHIPS_init  near

        outp    46E8h, 1Eh          ; Place chip in setup mode
        outp    103h, 80h           ; Enable extended registers
        outp    46E8h, 0Eh          ; Bring chip out of setup mode
        modinx  3D6h, 4, 4, 4       ; Enable bank access and extended CRTC
        modinx  3D6h, 0Dh, 3, 1     ; Enable extended paging

; Set the bank switching code according to the C&T chipset type

        mov     bx,[CntChipID]      ; BX := chip id

        cmp     bx,grCHIPS_82c451
        je      @@Chips451          ; Done for 82c451
        cmp     bx,grCHIPS_82c452
        je      @@Chips452

        mov     [NewBank],offset CHIPS453_bank
        mov     [ReadBank],offset CHIPS453_bank
        jmp     @@Exit

@@Chips452:
        mov     [NewBank],offset CHIPS452_bank
        mov     [ReadBank],offset CHIPS452_bank
        jmp     @@Exit

; Extended page flipping is not available on 82c451 chips, so disable it

@@Chips451:
        mov     [WORD cs:CHIPSPageOfs],offset NONE_page

@@Exit:
        ret

ENDP    CHIPS_init

;----------------------------------------------------------------------------
; EVEREX_init
;----------------------------------------------------------------------------
; Some Everex video boards are based on Trident or ET4000 chips. Detect
; them here, and setup to use the correct bank switching and page flipping
; routines.
;----------------------------------------------------------------------------
PROC    EVEREX_init     near

        mov     ax,[CntChipID]      ; AX := chipset ID
        cmp     ax,grEVEREX_Ev236   ; UltraGraphics - Trident Chip
        je      @@TridentChip
        cmp     ax,grEVEREX_Ev620   ; Vision VGA - Trident Chip
        je      @@TridentChip
        cmp     ax,grEVEREX_Ev629   ; ViewPoint TC - ET4000 Chip
        je      @@ET4000Chip
        cmp     ax,grEVEREX_Ev673   ; EVGA - Trident Chip
        je      @@TridentChip
        cmp     ax,grEVEREX_Ev678   ; Viewpoint - Trident Chip
        jne     @@Exit              ; Normal Everex chip, all done

; Based on Trident chip, so determine the type (8800 or 8900).

@@TridentChip:
        mov     [TwoBanks],false
        mov     [NewBank],offset TRIDENT_bank
        mov     [ReadBank],offset TRIDENT_bank
        mov     [WORD cs:EVEREXPageOfs],offset TRIDENT88_page

        wrinx   3C4h, 0Bh, 0        ; Force old definitions
        inp     3C5h                ; Force new definitions
        and     al,0Fh
        cmp     al,2
        je      @@Exit              ; Done for Trident 8800
        mov     [WORD cs:EVEREXPageOfs],offset TRIDENT89_page
        jmp     @@Exit

@@ET4000Chip:
        mov     [TwoBanks],true
        mov     [NewBank],offset ET4000_bank
        mov     [ReadBank],offset ET4000_rbank
        mov     [WORD cs:EVEREXPageOfs],offset ET4000_page
        jmp     @@Exit

@@Exit:
        ret

ENDP    EVEREX_init

;----------------------------------------------------------------------------
; PARADISE_init
;----------------------------------------------------------------------------
; We have a Paradise PVGA1A or WD90Cxx SuperVGA. We simply enable access
; to the extended registers to save time during bank switching.
;----------------------------------------------------------------------------
PROC    PARADISE_init   near

; Enable paradise extensions

        wrinx   3CEh, 0Fh, 5        ; Turn off write protect on VGA registers
        wrinx   3C4h, 6h, 48h       ; Unlock extended sequencer regs
        wrinx   3D4h, 29h, 85h      ; Turn on access to PR10-17

; Turn off the standard VGA mem bit, to allow access to all of the SuperVGA
; video memory for extended page flipping.

        modinx  3D4h, 2Fh, 2, 0     ; Clear out the VGA MEM bit

; Now determine the Paradise Chipset type. The WD90C10 and above chipsets
; support the dual banking mode.

        cmp     [CntChipID],grPARA_90C10
        jge     @@HaveDualMode

; Have an old PVGA1 or WD90C00 video card without dual banking support

        mov     [TwoBanks],false
        mov     [NewBank],offset PARADISEPVGA_bank
        mov     [ReadBank],offset PARADISEPVGA_bank
        jmp     @@Exit

; We have a WD90C1x/3x chipset, so set up for dual banking
; operation (read/write operation).

@@HaveDualMode:
        modinx  3CEh, 0Bh, 8, 8     ; Enable both PROA and PROB
        modinx  3C4h, 11h, 80h, 80h ; Set PROA for read, PROB for write

@@Exit:
        ret

ENDP    PARADISE_init

;----------------------------------------------------------------------------
; TRIDENT_init
;----------------------------------------------------------------------------
; We have a Trident 8800 or 8900 SuperVGA. Setup for a pagesize of 64k
; before doing bank switching.
;----------------------------------------------------------------------------
PROC    TRIDENT_init

        modinx  3CEh, 6, 4, 4       ;  Set pagesize to 64k
        ret

ENDP    TRIDENT_init

;----------------------------------------------------------------------------
; VIDEO7_init
;----------------------------------------------------------------------------
; We have a Video7 V7VGA SuperVGA. Enable access to the extended registers
; to save time during bank switching.
;----------------------------------------------------------------------------
PROC    VIDEO7_init

        outp    3C4h, 6, 0EAh       ; Enable extended registers

; Determine if the chip is revision five or later, so we can support
; dual read/write bank operation.

        rdinx   3C4h, 08Eh          ; Read Chip Revision register
        cmp     al,05Ah             ; Is this a version 5 chip?
        jl      @@HaveV5            ; We have a version 5 or later chip

; If the card is a 1024i, I am not sure if it has a version 4 or version 5
; chip in it. I assume here that it has a version 5 chip. If it does not,
; (or does not seem to work), uncomment the following code and replace
; the above line:
;
;       jg      @@NotV5             ; version 1-3 V7VGA's
;       cmp     al,050h
;       jge     @@HaveV5            ; Yes, version 5 chip

@@NotV5:
        mov     [TwoBanks],false
        mov     [NewBank],offset VIDEO7_bank
        mov     [ReadBank],offset VIDEO7_bank
        jmp     @@Exit

; We have a V7VGA revision 5 or later chip, so setup for dual paging
; mode

@@HaveV5:
        modinx  3C4h, 0E0h, 80h, 80h    ; Set split bank mode

@@Exit:
        ret

ENDP    VIDEO7_init

;----------------------------------------------------------------------------
; ET4000_init
;----------------------------------------------------------------------------
; We have an ET4000 video card, so enable access to extended registers
; before bank switching.
;----------------------------------------------------------------------------
PROC    ET4000_init

        outp    3BFh, 3
        outp    3D8h, 0A0h          ; Enable ET4000 extensions

; Check the type of video board, modifying the 24 bit mode tables if
; we have a Speedstar 24 or Genoa 7900 board.

        cmp     [CntChipID],grET4000_MEGAEVA
        je      @@Done

; We have a Speedstar 24 or Genoa 7900, both which only support the
; 640x480 video modes. Note that on both these cards, the bytes per line
; value for the mode is 2048, not 1920 (so you don't have problems with
; pixels crossing bank boundaries!!).

        mov     [DWORD cs:ET4_640x350x16m],0
        mov     [DWORD cs:ET4_640x400x16m],0
        mov     bx,2048
        mov     ax,grSVGA_640x480x16m
        call    setBytesPerLine

        cmp     [CntChipID],grET4000_SPEEDSTAR
        jne     @@HaveGenoa

        mov     [DWORD cs:ET4_640x480x16m],02E10E0h
        jmp     @@Done

@@HaveGenoa:
        mov     [DWORD cs:ET4_640x480x16m],03E10F0h

@@Done:
        ret

ENDP

;----------------------------------------------------------------------------
; NCR_init
;----------------------------------------------------------------------------
; We have an NCR 77C22E SuperVGA, so set up for dual banking mode of
; operation. We also program the low portions of the bank switching
; registers with zeroes.
;----------------------------------------------------------------------------
PROC    NCR_init

        modinx  3C4h, 1Eh, 010100b, 010100b
        wrinx   3C4h, 19h, 0    ; Set primary offset low to 0
        wrinx   3C4h, 1Dh, 0    ; Set secondary offset low to 0
        ret

ENDP

;----------------------------------------------------------------------------
; S3_init
;----------------------------------------------------------------------------
; We have an S3 based video card, so set up a few things specific to this
; card.
;----------------------------------------------------------------------------
PROC    S3_init

; The S3 Chipset uses large bytes per line values in 256, 32k and 64k
; color video modes to make the copper's life a little easier (and ours
; a little harder :-). Change the bytes per line values in the table
; to the correct values.

        call    ModifyS3BytesPerLine
        ret

ENDP    S3_init

;----------------------------------------------------------------------------
; CIRRUS_init
;----------------------------------------------------------------------------
; We have a Cirrus 5422 SuperVGA, so enable access to extended registers.
;----------------------------------------------------------------------------
PROC    CIRRUS_init

        wrinx   3C4h, 6, 12h        ; Enable extended registers
        ret

ENDP    CIRRUS_init

;----------------------------------------------------------------------------
; ACUMOS_init
;----------------------------------------------------------------------------
; We have an AcuMos SuperVGA, so enable access to extended registers.
;----------------------------------------------------------------------------
PROC    ACUMOS_init

        wrinx   3C4h, 6, 12h        ; Enable extended registers
        ret

ENDP    ACUMOS_init

;----------------------------------------------------------------------------
; AL2101_init
;----------------------------------------------------------------------------
; We have an Advance Logic 2101 SuperVGA, so set up for separate read
; write bank switching. This is supposed to work according to the
; docs on the AL2101, but it doesn't (it works for the RealTek instead!)
; Very wierd!!
;----------------------------------------------------------------------------
PROC    AL2101_init

;       modinx  3CEh, 0Fh, 4, 4 ; Set bit 2 of Extended function register
        ret

ENDP    AL2101_init

;----------------------------------------------------------------------------
; MXIC_init
;----------------------------------------------------------------------------
; We have an MXIC SuperVGA, so enable access to extended registers.
;----------------------------------------------------------------------------
PROC    MXIC_init

        wrinx   3C4h, 0A7h, 087h    ; Enable extended registers
        ret

ENDP    MXIC_init

;----------------------------------------------------------------------------
; RT3106_init
;----------------------------------------------------------------------------
; We have a RealTek 3106 SuperVGA. This code is supposed to work on the
; advance logic's ALG2101 chip, but apparantly works on the RT3106!
;----------------------------------------------------------------------------
PROC    RT3106_init

        modinx  3CEh, 0Fh, 4, 4 ; Set bit 2 of Extended function register
        ret

ENDP    RT3106_init

;----------------------------------------------------------------------------
; ExitBank  Deinitialises the SuperVGA card back to normal operation.
;----------------------------------------------------------------------------
;
; Returns the SuperVGA card back to it's default state, such as turning
; off access to all extended registers that were set by the initialisation
; routines.
;
; Note: All register may be used without concern for saving their values
;
; Registers:    All.
;
;----------------------------------------------------------------------------

PROC    NONE_exit   near
        ret
ENDP    NONE_exit

PROC    AHEAD_exit  near

        outp    3CEh, 0Fh, 0        ; Disable extended registers
        ret

ENDP    AHEAD_exit

PROC    CHIPS_exit  near

        outp    46E8h, 1Eh          ; Place chip in setup mode
        outp    103h, 0             ; Disable extended registers
        outp    46E8h, 0Eh          ; Bring chip out of setup mode
        ret

ENDP    CHIPS_exit

PROC    PARADISE_exit   near

        wrinx   3CEh, 0Fh, 0        ; Turn on write protect on VGA registers
        wrinx   3CEh, 6h, 0         ; Turn on write protect on extended seq
        ret

ENDP    PARADISE_exit

PROC    VIDEO7_exit

        outp    3C4h, 6, 0AEh       ; Disable extended registers
        ret

ENDP    VIDEO7_exit

PROC    CIRRUS_exit

        wrinx   3C4h, 6, 0          ; Disable extended registers
        ret

ENDP    CIRRUS_exit

PROC    ACUMOS_exit

        wrinx   3C4h, 6, 0          ; Disable extended registers
        ret

ENDP    ACUMOS_exit

PROC    MXIC_exit

        wrinx   3C4h, 0A7h, 0       ; Disable extended registers
        ret

ENDP    MXIC_exit
