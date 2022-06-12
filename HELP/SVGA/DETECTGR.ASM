;****************************************************************************
;*
;*                      MegaGraph Graphics Library
;*
;*          Copyright (C) 1993 Kendall Bennett.
;*                          All rights reserved.
;*
;* Filename:    $RCSfile: detectgr.asm $
;* Version:     $Revision: 1.2 $
;*
;* Language:    80386 Assembler
;* Environment: IBM PC (MS DOS)
;*
;* Description: This module contains the auto detection routines to detect
;*              the presence of all the standard graphics adapters
;*              supported by the MegaGraph graphics library.
;*
;* $Id: detectgr.asm 1.2 1993/03/07 04:03:22 kjb Exp $
;*
;* Revision History:
;* -----------------
;*
;* $Log: detectgr.asm $
;* Revision 1.2  1993/03/07  04:03:22  kjb
;* Numerous bug fixes and enhancements.
;*
;* Revision 1.1  1993/03/03  10:45:16  kjb
;* Initial revision
;*
;****************************************************************************

        IDEAL
        JUMPS                   ; Fix jumps out of range
        P386                    ; Use 80386 instructions

INCLUDE "model.mac"             ; Memory model macros

header  detectgr                ; Set up memory model

;****************************************************************************
;
; Equates used by detectgraph routine.
;
;****************************************************************************

CRTC        EQU 3D4h            ; Port of CRTC registers

INCLUDE "MGRAPH.EQU"            ; Include equates for Mgraph routines

begdataseg  detectgr

INCLUDE "MGRAPH.VAR"            ; Include variable references

enddataseg  detectgr

begcodeseg  detectgr            ; Start of code segment

;****************************************************************************
;
; Global variables used by detectgraph routines.
;
;****************************************************************************

SaveDS          dw  ?           ; Place to save the value of DS register

VesaBuf         db  256 dup (?) ; VESA Video information block
VideoChipID     dw  0           ; Internal SuperVGA chip ID
VideoMem        dw  256         ; Size of video memory (kb)
VideoModes      dw  DefModes    ; Pointer to list of available SuperVGA
PageFlip        dw  false       ; True if page flipping is available
                                ; Video modes.
DacType         dw  grVGADAC    ; Video DAC type
ForceDAC        dw  0           ; Value to force dac with
old             db  0           ; Scratch place to store values

;****************************************************************************
;
; Initialised data used by the detectgraph routines.
;
;****************************************************************************

; Delimited list of video modes for all supported video cards. This list
; may need to be modified depending on display memory restrictions etc.
;
; During chip identification, it may be found that the chipset detected
; does not support all of the specified modes. In this case, the
; unsupported video modes should be set to a zero (use the UnsupportedMode
; routine for this).
;
; HiColor and TrueColor modes should be specified after the particular
; chip in question. If the appropriate DAC is detected, a zero should
; be used to replace the -1 delimiter to add the list of HiColor or
; TrueColor video modes.

DefModes:       db  -1

AheadModes:     db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256,-1

ATIModes:       db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256
ATI32KModes:    db  -1,grSVGA_640x480x32k,grSVGA_800x600x32k,-1

ChipsModes:     db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256,-1

EverexModes:    db  grSVGA_800x600x16,grSVGA_1024x768x16,grSVGA_1280x1024x16
                db  grSVGA_640x350x256,grSVGA_640x400x256
                db  grSVGA_640x480x256,grSVGA_800x600x256
                db  grSVGA_1024x768x256
Everex32KModes: db  -1,grSVGA_320x200x32k,grSVGA_640x480x32k
EverexTCModes:  db  -1,grSVGA_640x480x16m,-1

GenoaModes:     db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x350x256,grSVGA_640x400x256
                db  grSVGA_640x480x256,grSVGA_800x600x256,-1

OAKModes:       db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x480x256,grSVGA_800x600x256
                db  grSVGA_1024x768x256
OAK32KModes:    db  -1,grSVGA_640x400x32k,grSVGA_640x480x32k,-1

ParadiseModes:  db  grSVGA_800x600x16,grSVGA_1024x768x16,grSVGA_1280x1024x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256
Parad32KModes:  db  -1,grSVGA_640x480x32k,grSVGA_800x600x32k,-1

Trident88Modes: db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x400x256,grSVGA_640x480x256,-1

Trident89Modes: db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256,-1

Video7Modes:    db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256,-1

ET3000Modes:    db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x350x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,-1

ET4000Modes:    db  grSVGA_800x600x16,grSVGA_1024x768x16,grSVGA_1280x1024x16
                db  grSVGA_640x350x256,grSVGA_640x400x256
                db  grSVGA_640x480x256,grSVGA_800x600x256
                db  grSVGA_1024x768x256
ET400032KModes: db  -1,grSVGA_320x200x32k,grSVGA_640x350x32k
                db  grSVGA_640x400x32k,grSVGA_640x480x32k,grSVGA_800x600x32k
ET4000TCModes:  db  -1,grSVGA_640x350x16m,grSVGA_640x400x16m
                db  grSVGA_640x480x16m,-1

NCRModes:       db  grSVGA_800x600x16,grSVGA_1024x768x16,grSVGA_1280x1024x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256
                db  grSVGA_1280x1024x256
NCR32KModes:    db  -1,grSVGA_640x480x32k,grSVGA_800x600x32k,-1

S3Modes:        db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x480x256,grSVGA_800x600x256
                db  grSVGA_1024x768x256
S332KModes:     db  -1,grSVGA_640x480x32k,-1
S3TCModes:      db  -1

CirrusModes:    db  grSVGA_800x600x16,grSVGA_1024x768x16,grSVGA_1280x1024x16
                db  grSVGA_640x480x256,grSVGA_800x600x256
                db  grSVGA_1024x768x256
Cirrus32kModes: db  -1,grSVGA_640x480x32k,grSVGA_800x600x32k,-1
CirrusTCModes:  db  -1,grSVGA_320x200x16m,grSVGA_640x480x16m,-1

AcuMosModes:    db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,-1

AL2101Modes:    db  grSVGA_800x600x16,grSVGA_1024x768x16,grSVGA_1280x1024x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256
                db  grSVGA_1280x1024x256,-1

MXICModes:      db  grSVGA_800x600x16,grSVGA_1024x768x16
                db  grSVGA_640x350x256,grSVGA_640x400x256
                db  grSVGA_640x480x256,grSVGA_800x600x256
                db  grSVGA_1024x768x256,-1

P2000Modes:     db  grSVGA_800x600x16,grSVGA_1024x768x16,grSVGA_1280x1024x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256
                db  grSVGA_1280x1024x256
P200032KModes:  db  -1,grSVGA_640x350x32k,grSVGA_640x400x32k
                db  grSVGA_640x480x32k,grSVGA_800x600x32k,-1

RT3106Modes:    db  grSVGA_800x600x16,grSVGA_1024x768x16,grSVGA_1280x1024x16
                db  grSVGA_640x400x256,grSVGA_640x480x256
                db  grSVGA_800x600x256,grSVGA_1024x768x256
                db  grSVGA_1280x1024x256,-1

VesaModes:      db  20 dup (-1)

; Table to translate EGA display types

EGADisplays     db  grEGA,grEGA_640x200x16  ; 0000b,0001b CGA Display
                db  grEGA,grEGA_640x350x16  ; 0010b,0011b EGA Display
                db  grEGAMONO,0             ; 0100b,0101b MDA Display
                db  grEGA,grEGA_640x200x16  ; 0110b,0111b CGA Display
                db  grEGA,grEGA_640x350x16  ; 1000b,1001b EGA Display
                db  grEGAMONO,0             ; 1010b,1011b MDA Display

; Table of possible VESA video mode numbers and display memory required
; rounded up to the nearest half megabyte or megabyte depending on
; resolution. Cards generally have 256k, 512k, 1M, 2M or 4M on board.

AllVesaModes:   dw  100h, 256,  grSVGA_640x400x256
                dw  101h, 512,  grSVGA_640x480x256
                dw  102h, 256,  grSVGA_800x600x16
                dw  103h, 512,  grSVGA_800x600x256
                dw  104h, 512,  grSVGA_1024x768x16
                dw  105h, 1024, grSVGA_1024x768x256
                dw  106h, 1024, grSVGA_1280x1024x16
                dw  107h, 2048, grSVGA_1280x1024x256
                dw  10Dh, 256,  grSVGA_320x200x32k
                dw  10Fh, 256,  grSVGA_320x200x16m
                dw  110h, 1024, grSVGA_640x480x32k
                dw  112h, 1024, grSVGA_640x480x16m
                dw  113h, 1024, grSVGA_800x600x32k
                dw  115h, 2048, grSVGA_800x600x16m
                dw  116h, 2048, grSVGA_1024x768x32k
                dw  118h, 4096, grSVGA_1024x768x16m
                dw  119h, 4096, grSVGA_1280x1024x32k
                dw  11Bh, 4096, grSVGA_1280x1024x16m
                dw  0

;****************************************************************************
;
; Set of macros to make the following code more readable, but probably
; less efficient. Efficiency here is not a major concern, but correctness
; definately is :-).
;
;****************************************************************************

MACRO   check   boardName
        call    Find&boardName      ; Check for a particular SuperVGA card
        jc      @@FoundOne
ENDM

; Macro to add the HiColor video modes for this video card to the mode
; table.

MACRO   Add32kColor ModeTable
        local   NoHiColor
        cmp     [DacType],grHCDAC
        jl      NoHiColor
        mov     bx,offset ModeTable
        mov     [BYTE cs:bx],0      ; Clear the -1 termination flag
NoHiColor:
ENDM

; Macro to add the TrueColor video modes for this video card to the mode
; table.

MACRO   AddTrueColor    ModeTable
        local   NoTrueColor
        cmp     [DacType],grTCDAC
        jl      NoTrueColor
        mov     bx,offset ModeTable
        mov     [BYTE cs:bx],0      ; Clear the -1 termination flag
NoTrueColor:
ENDM

MACRO   ClearMode   Mode, ModeTable
        mov     al,Mode
        mov     bx,offset ModeTable
        call    UnsupportedMode     ; Clear the unsupported video mode
ENDM

INCLUDE "SV_PORTS.ASM"
INCLUDE "SV_MAXPG.ASM"

;----------------------------------------------------------------------------
; void MGL_detectGraph(int far *graphdriver,int far *chipID,int far *memory,
;   int far *dac,int far *graphmode);
;----------------------------------------------------------------------------
; Autodetects the standard graphics adapters supported by the MegaGraph
; graphics library.
;----------------------------------------------------------------------------
procstart   _MGL_detectGraph

        ARG     driver:DWORD, chipID:DWORD, memory:DWORD, dac:DWORD,    \
                mode:DWORD

        enter   0,0
        pusha
        push    ds

        mov     ax,DGROUP       ; Save data segment for later use
        mov     [cs:SaveDS],ax

        lds     si,[dac]
        mov     ax,[si]
        mov     [ForceDAC],ax   ; Save value of forced dac type

        lds     di,[driver]     ; Load the address of driver in DS:DI
        les     si,[mode]       ; Load the address of mode in ES:SI

        push    ds
        mov     ds,[cs:SaveDS]  ; Address data segment
        mov     [__grResult],grOK
        pop     ds

; Look for the various subsystems using the subroutines in the order of
; highest performance first. Ie: look for PS/2's then EGA, CGA, then
; hercules monochrome.

        call    FindPS2         ; Is an MCGA or VGA out there?
        jc      @@Exit
        call    FindEGA         ; Is an EGA out there?
        jc      @@Exit
        call    FindCGA         ; Is a CGA out there?
        jc      @@Exit
        call    FindHGC         ; Is a Hercules out there?
        jc      @@Exit

        push    ds
        mov     ds,[cs:SaveDS]  ; Address data segment
        mov     [__grResult],grNotDetected
        pop     ds

@@Exit:
        lds     si,[chipID]     ; Load the address of chip ID in DS:SI
        mov     ax,[VideoChipID]; AX := value of internal chip ID
        mov     [si],ax         ; Store the chip ID value
        lds     si,[memory]
        mov     ax,[VideoMem]
        mov     [si],ax
        lds     si,[dac]
        mov     ax,[DacType]
        mov     [si],ax         ; Store dac type
        pop     ds
        popa
        leave
        ret

procend     _MGL_detectGraph

;----------------------------------------------------------------------------
; char far * _getSuperVGAModes(void)
;----------------------------------------------------------------------------
; Returns the address of the list of available video modes.
;----------------------------------------------------------------------------
procstart   __getSuperVGAModes

        mov     dx,seg DefModes
        mov     ax,[WORD VideoModes]
        ret

procend     __getSuperVGAModes

;----------------------------------------------------------------------------
; int _getSuperVGAPages(int mode,int memory,long *pagesize)
;----------------------------------------------------------------------------
; Returns the number of available video pages for a specific video mode.
; It also returns the size in bytes of each video page (rounded to the
; nearest bank value).
;----------------------------------------------------------------------------
procstart   __getSuperVGAPages

        ARG     mode:WORD, memory:WORD, pagesize:DWORD

        enter   0,0
        push    di

        mov     ax,[mode]
        mov     cx,ax
        and     ax,7Fh
        xor     ebx,ebx
        mov     bx,[memory]
        test    cx,80h
        jnz     @@ExtendedPageFlip
        cmp     [PageFlip],true
        je      @@ExtendedPageFlip

; Extended page flipping is not available, so calculate pages using only
; 256k of memory.

        cmp     ax,grVGA_320x200x256
        jl      @@VGAMode
        mov     ax,1
        jmp     @@Done

@@VGAMode:
        mov     bx,256

@@ExtendedPageFlip:
        shl     ebx,10
        call    numPages
        les     di,[pagesize]
        mov     [es:di],ebx         ; Store the page size for later

@@Done:
        pop     di
        leave
        ret

procend     __getSuperVGAPages

;****************************************************************************
;
; Internal routines used by the detectgraph routine.
;
;****************************************************************************

;----------------------------------------------------------------------------
; FindPS2   Determine if a PS2 is out there, and get susbsystem types
;----------------------------------------------------------------------------
;
; Routine calls INT10h function 1Ah to determine the video BIOS
; Display Combination Code (DCC) for each video subsystem. If the
; PS2 BIOS is not out there, then none of the regs are changed. If
; it is out there, then 1Ah comes back in AL. If there is a PS/2 BIOS, we
; only use it to detect the VGA and MCGA adapters.
;
; Entry:        DS:DI   ->  Address of driver variable
;               ES:SI   ->  Address of mode variable
;
; Exit:         Carry flag is set if an MCGA,VGA,SVGA was detected
;
; Registers:    AX,BX,CX
;
;----------------------------------------------------------------------------
PROC    FindPS2 near

        mov     ax,1A00h    ; call video BIOS for info
        int     10h

        cmp     al,1Ah          ; Is the BIOS out there (1Ah in AL)
        clc
        jne     @@Exit

; Determine if VGA,MCGA,SVGA present from BIOS DCC's

        mov     cl,bh           ; BL := active subsystem, BH := inactive
        xor     bh,bh           ; BX := DCC of active subsystem
        xor     ch,ch           ; CX := DCC of inactive subsystem

        cmp     bx,07h          ; Active VGA Mono?
        je      @@VGA
        cmp     cx,07h          ; Inactive VGA Mono?
        je      @@VGA
        cmp     bx,08h          ; Active VGA Color?
        je      @@VGA
        cmp     cx,08h          ; Inactive VGA Color?
        jne     @@CheckMCGA
@@VGA:
        mov     [WORD DS:DI],grVGA
        mov     [WORD ES:SI],grVGA_640x480x16

        push    ds
        mov     ds,[cs:SaveDS]  ; Address data segment
        cmp     [__ignoreSVGA],1
        pop     ds
        je      @@SkipSVGA

        call    FindSuperVGA    ; Check to see if a SuperVGA is out there

@@SkipSVGA:
        stc                 ; We at least found a VGA card
        jmp     @@Exit

@@CheckMCGA:
        cmp     bx,0Ch          ; Active MCGA color?
        je      @@MCGA
        cmp     cx,0Ch          ; Inactive MCGA color?
        clc
        jne     @@Exit

@@MCGA:
        mov     [WORD DS:DI],grMCGA
        mov     [WORD DS:SI],grVGA_320x200x256
        stc                     ; Set the carry flag

@@Exit:
        ret

ENDP    FindPS2

;----------------------------------------------------------------------------
; FindEGA   Determine if an EGA is out there and get system configuration
;----------------------------------------------------------------------------
;
; Routine calls INT10h function 12h to get the EGA BIOS to return system
; configuration info. If the EGA BIOS is not there, then the regs return
; unscathed. Specifically, if BH changes, then the EGA is out there.
;
; Entry:        DS:DI   ->  Address of driver variable
;               ES:SI   ->  Address of mode variable
;
; Exit:         Carry flag set if an EGA was detected
;
; Registers:    AX,BX,CX
;
;----------------------------------------------------------------------------
PROC    FindEGA near

        mov     bl,10h          ; BL := 10h (return ega info)
        mov     ah,12h          ; AH := INT10h function number
        int     10h             ; Call EGA BIOS for info.
                                ; If EGA is present, BL <> 10h and
                                ; CL = EGA switch settings
        cmp     bl,10h
        clc
        je      @@Exit          ; jump if EGA BIOS not present

        and     bl,3            ; Mask out the Video Ram bits
        push    bx              ; Save Video Ram bits on stack

        mov     al,cl           ; AL := configuration switches
        xor     ah,ah           ; AX := configuration switches
        and     al,11111110b    ; Mask bit 1
        mov     bx,offset cs:EGADisplays
        add     bx,ax           ; Index into table
        xor     ah,ah
        mov     al,[cs:bx]      ; Translate code
        mov     [WORD DS:DI],ax
        mov     al,[cs:bx + 1]
        mov     [WORD ES:SI],ax

        pop     cx              ; Restore Video Ram Bits
        or      cx,cx           ; 64kb of EGA RAM?
        stc
        jne     @@Exit          ; We are done...
        inc     [WORD DS:DI]    ; Convert to EGA64 and EGA64MONO
        stc

@@Exit:
        ret

ENDP    FindEGA

;----------------------------------------------------------------------------
; FindCGA   Determine if a CGA adapter is out there and get info
;----------------------------------------------------------------------------
;
; Routine checks for a CGA by looking for the CGA's 6845 CRTC at I/O port
; 3D4h.
;
; Entry:        DS:DI   ->  Address of driver variable
;               ES:SI   ->  Address of mode variable
;
; Exit:         Carry flag set if a CGA was detected
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    FindCGA     near

        mov     dx,3D4h         ; DX := CRTC address port
        call    Find6845
        jnc     @@Exit

        mov     [WORD DS:DI],grCGA
        mov     [WORD ES:SI],0
        stc                     ; Set carry flag

@@Exit:
        ret

ENDP    FindCGA

;----------------------------------------------------------------------------
; FindHGC   Determine if a Hercules card is out there.
;----------------------------------------------------------------------------
;
; This is done by looking for the MDA's 6845 CRTC at I/O port 3B4h. If
; a 6845 is found, the subroutine distinguishes between an MDA and a
; Hercules adapter by monitoring bit 7 of the CRT Staus byte. This bit
; changes on Hercules adapters but does not change on an MDA.
;
; Entry:        DS:DI   ->  Address of driver variable
;               ES:SI   ->  Address of mode variable
;
; Exit:         Carry flag set if an HGC was detected
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    FindHGC near

        mov     dx,3B4h         ; DX := CRTC address port
        call    Find6845
        jnc     @@Exit          ; jump if not present

        mov     dx,3BAh         ; DX := 3BAh (Status port)
        in      al,dx
        and     al,80h
        mov     ah,al           ; AH := bit 7 (Vertical sync on HGC)
        mov     cx,8000h        ; do this 32768 times

@@WaitForChange:
        in      al,dx
        and     al,80h          ; isolate bit 7
        cmp     ah,al
        loope   @@WaitForChange ; wait for bit 7 to change

        clc
        je      @@Exit          ; if bit 7 didn't change, it's an MDA

        mov     [WORD DS:DI],grHERCMONO
        mov     [WORD ES:SI],0
        stc

@@Exit:
        ret

ENDP    FindHGC

;----------------------------------------------------------------------------
; FindDAC   Routine to detect the presence of HiColor and TrueColor DAC's
;----------------------------------------------------------------------------
;
; This routine attempts to determine the type of RAM dac installed in the
; video card. This can be used by the following detection routines to
; determine if HiColor or TrueColor video mode support should be included
; in the video mode tables.
;
; Exit:         DacType updated with Video DAC type
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    FindDAC

        push    si
        push    di

; Test for the SS24 TrueColor DAC first.

        DacToPel
        in      al,dx               ; Wait for the same value twice
@@L1:   mov     bl,al
        in      al,dx
        cmp     al,bl
        jne     @@L1
        DacToCommand
        cmp     al,8Eh
        je      @@HaveSS24          ; We have an SS24 TrueColor DAC
        mov     cx,8
@@L2:   in      al,dx
        cmp     al,8Eh
        je      @@HaveSS24          ; Found an SS24 TrueColor DAC
        loop    @@L2

; Save the state of the command and PEL registers

        DacToCommand
        in      al,dx
        mov     si,ax               ; SI := Old value of command register
        DacToPel
        in      al,dx
        mov     di,ax               ; DI := Old value of PEL register

        mov     ax,si
        xor     al,0FFh             ; AL := old command reg XOR FFh
        mov     bl,al               ; Save value in BL
        out     dx,al               ; Write value to PEL register
        DacToCommand
        in      al,dx               ; Read value of command register
        cmp     al,bl               ; If value are the same, Normal DAC
        je      @@NormalDAC         ; Normal DAC, so reset PEL reg and exit

; We have a HiColor or TrueColor DAC of some type, so figure out what
; sort it is.

        DacToCommand
        mov     ax,si
        xor     al,60h              ; AL := Old command reg XOR 60h
        mov     bl,al               ; Save value in BL
        out     dx,al               ; Write to command register
        DacToCommand
        in      al,dx
        and     al,0E0h
        and     bl,0E0h
        cmp     al,bl
        jne     @@HaveHiColor       ; Found an SC11486 HiColor DAC

        in      al,dx
        mov     bl,al
        DacToPel
        in      al,dx
        cmp     al,bl
        je      @@HaveTrueColor     ; Must be an ATT 20c491/2 or some other DAC

; Fall through for Sierra 32k/64k DAC's

@@HaveHiColor:
        mov     ax,grHCDAC          ; DAC is HiColor
        mov     [DacType],ax
        jmp     @@ResetCommand

@@HaveTrueColor:
        mov     ax,grTCDAC          ; DAC is TrueColor
        mov     [DacType],ax

@@ResetCommand:
        DacToCommand
        mov     ax,si               ; AL := Old value of command register
        out     dx,al

@@NormalDAC:
        DacToPel
        mov     ax,di               ; AL := Old value of PEL register
        out     dx,al               ; Reset to old value
        jmp     @@Exit

@@HaveSS24:
        mov     ax,grTCDAC          ; SS24 is TrueColor DAC
        mov     [DacType],ax
        jmp     @@Exit

@@Exit:
        mov     ax,[ForceDAC]       ; Get value of forced DAC
        or      ax,ax               ; Negative if we dont want to force
        js      @@1
        mov     [DacType],ax        ; Force the dac type
@@1:    pop     si
        pop     di
        ret

ENDP    FindDAC

;----------------------------------------------------------------------------
; FindSuperVGA  Determine if a SuperVGA is out there, and get information
;----------------------------------------------------------------------------
;
; Routine performs a number of SuperVGA detection routines to determine
; if a SuperVGA video card is out there. If one is found, we set the driver
; variable to reflect this and exit. Note that we also detect how much
; memory is present on the card and what video modes are available.
;
; This code first appeared in John Bridges VGAKIT library, however it has
; been factorised into a number of independant functions to detect each
; video card.
;
; Entry:        DS:DI   ->  Address of driver variable
;
; Exit:         Carry flag is set if a SuperVGA was detected
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    FindSuperVGA    near

        push    ds
        push    es
        push    si
        push    di

        call    FindDAC             ; Detect the Video DAC installed

        mov     [PageFlip],false    ; Default to no page flipping

        push    ds
        mov     ds,[cs:SaveDS]      ; Address data segment
        cmp     [__VESAFirst],1     ; Check _VESAFirst flag
        pop     ds
        jne     @@SkipVESA

        check   VESA

@@SkipVESA:
        check   Chips
        check   Paradise
        check   Video7
        check   Genoa
        check   Everex
        check   Trident
        check   ATI
        check   Ahead
        check   NCR
        check   S3
        check   AL2101
        check   MXIC
        check   Cirrus
        check   AcuMos
        check   Tseng
        check   RT3106
        check   P2000
        check   Oaktech
        check   VESA

        pop     di
        pop     si
        pop     es
        pop     ds
        clc
        ret

@@FoundOne:
        pop     di
        pop     si
        pop     es
        pop     ds
        mov     [WORD ds:di],ax ; Store the SuperVGA card identifier
        stc
        ret

ENDP    FindSuperVGA

;----------------------------------------------------------------------------
; UnsupportedMode   Flags a video mode as unsupported for this card
;----------------------------------------------------------------------------
;
; Flags a video mode as unsupported for this video card, by writing a
; zero into the position where the mode is located.
;
; Entry:        AL  - Number of unsupported mode
;               BX  - Offset of video mode table
;
; Exit:         BX  - Offset of video mode table
;
; Registers:    AX,BX
;
;----------------------------------------------------------------------------
PROC    UnsupportedMode

; Find the index of the video mode

        push    bx
@@Loop:
        mov     ah,[BYTE cs:bx]
        cmp     ah,al               ; Found the video mode?
        je      @@FoundIt
        cmp     ah,-1
        je      @@Exit
        inc     bx
        jmp     @@Loop

@@FoundIt:
        mov     [BYTE cs:bx],0
@@Exit:
        pop     bx
        ret

ENDP    UnsupportedMode

;----------------------------------------------------------------------------
; FindVESA  Detect the presence of VESA Compatible SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;
;----------------------------------------------------------------------------
PROC    FindVESA    near

; Check to see if a VESA extended video BIOS is out there. If it is,
; we have a Super VGA card.

        mov     ax,seg VesaBuf
        mov     es,ax
        mov     di,offset VesaBuf
        mov     ax,04F00h
        int     10h             ; Call the VESA video BIOS
        cmp     ax,004Fh
        jne     @@NoVESA
        cmp     [WORD es:di],'EV'
        jne     @@NoVESA
        cmp     [WORD es:di+2],'AS'
        jne     @@NoVESA

; We have a VESA compatible SuperVGA, so determine how much memory must
; be on the video board by finding the amount of memory used by the
; highest resolution video mode supported.
;
; At the same time initialise the table of valid video modes for this
; SuperVGA, and bytes per line values for the video mode.

        push    ds
        push    bp
        mov     ax,[WORD es:di+16]
        mov     ds,ax
        mov     bp,[WORD es:di+14]  ; DS:BP -> List of valid VESA modes
        mov si,offset AllVesaModes
        mov     bx,offset VesaModes
        cld

@@VesaMemLoop:
        lods    [WORD cs:si]        ; Load VESA mode number
        mov     cx,ax
        jcxz    @@EndVESA           ; Finished when mode number is zero
        lods    [WORD cs:si]        ; Load amount of memory required for mode
        push    ax          ;   and save on stack
        lods    [WORD cs:si]        ; Load MGL video mode number
        push    ax                  ;   and save on stack

; First check to see if the mode is a valid VESA mode.

        mov     di,bp               ; DS:DI -> mode list
@@CheckMode:
        mov     ax,[WORD ds:di]
        inc     di
        inc     di
        cmp     ax,-1
        je      @@NotFound
        cmp     ax,cx
        je      @@FoundMode         ; Yes mode was found
        jmp     @@CheckMode         ; Loop for all valid modes

@@NotFound:
        pop     ax                  ; Restore stack
        pop     ax
        jmp     @@VesaMemLoop       ; Continue loop

@@FoundMode:
        mov     ax,seg VesaBuf
        mov     es,ax
        mov     di,offset VesaBuf
        mov     ax,4F01h            ; AX := Query Mode Information
        int     10h
        pop     dx                  ; DX := MGL Mode Number
        pop     cx                  ; CX := Video memory required
        or      ah,ah
        jnz     @@VesaMemLoop       ; Mode not supported, try next one
        test    [BYTE es:di],1
        jz      @@VesaMemLoop       ; Mode not supported, try next one

; Video mode is supported, so add to mode table.

        push    bx
        mov     bx,[WORD es:di+16]
        mov     ax,dx
        call    setBytesPerLine     ; Set the bytes per line value for mode
        pop     bx
        mov     [BYTE cs:bx],dl     ; Store the mode number
        inc     bx

        cmp     cx,[WORD VideoMem]
        jle     @@VesaMemLoop       ; Memory is less, try next mode
        mov     [WORD VideoMem],cx  ; Increase the memory size
        jmp     @@VesaMemLoop

@@EndVESA:
        pop     bp
        pop     ds
        call    checkVESAPageFlip   ; Does VESA support page flipping?
        jc      @@NoFlip
        mov     [PageFlip],true

@@NoFlip:
        mov     [WORD VideoModes],offset VesaModes
        mov     ax,grSVGA
        stc
        ret

@@NoVESA:
        clc
        ret

ENDP    FindVESA

;----------------------------------------------------------------------------
; FindS3    Detect the presence of an S3 based SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindS3  near

        wrinx   CRTC, 38h, 0    ; Lock S3 extended registers
        tstinx  CRTC, 35h, 0Fh  ; Check for locked S3 bank switch register
        jz      @@NoS3          ; Bank reg was writeable, not an S3

        wrinx   CRTC, 38h, 48h  ; Unlock S3 extended registers
        tstinx  CRTC, 35h, 0Fh  ; Check for unlocked S3 bank switch register
        jnz     @@NoS3          ; Test failed, not an S3

; Determine the chip ID for the video card and save it for later

        rdinx   CRTC, 30h       ; Read chip ID register
        mov     bx,grS3_928
        cmp     al,90h
        je      @@FindMem       ; We have an 86c928 chip
        mov     bx,grS3_801_805
        cmp     al,0A0h
        je      @@FindMem       ; We have an 86c801/86c805 chip
        mov     bx,grS3_924
        cmp     al,82h
        je      @@FindMem       ; We have an 86c924 chip
        mov     bx,grS3_911     ; Fall through for the 86c911 chip

; Determine how much video RAM is on the card

@@FindMem:
        mov     [VideoChipID],bx; Save the chip ID
        rdinx   CRTC, 36h       ; Read configuration register 1
        and     al,11100000b    ; Mask out bits 7-5
        cmp     bx,grS3_924
        jle     @@Mem911

; We have an 86c801/805/928 based S3.

        mov     [WORD VideoMem],512
        cmp     al,11100000b
        je      @@DoneMem       ; Card has 512k on board
        mov     [WORD VideoMem],1024
        cmp     al,11000000b
        je      @@DoneMem       ; Card has 1Mb on board
        mov     [WORD VideoMem],2048
        cmp     al,10000000b
        je      @@DoneMem       ; Card has 2Mb on board
        mov     [WORD VideoMem],3072
        cmp     al,01000000b
        je      @@DoneMem       ; Card has 3Mb on board
        mov     [WORD VideoMem],4096
        jmp     @@DoneMem       ; Card has 4Mb on board

; We have an 86c911/924.

@@Mem911:
        mov     [WORD VideoMem],512
        test    al,100000b      ; Bit 5 is set for 512k
        jnz     @@DoneMem
        mov     [WORD VideoMem],1024

@@DoneMem:
        wrinx   CRTC, 38h, 0    ; Lock S3 extended registers

        call    ModifyS3BytesPerLine
        mov     [PageFlip],true ; Card supports extended page flipping
        Add32kColor     S332KModes
        AddTrueColor    S3TCModes
        mov     [WORD VideoModes],offset S3Modes
        mov     ax,grSVGA_S3
        stc
        ret

@@NoS3:
        clc
        ret

ENDP    FindS3

;----------------------------------------------------------------------------
; FindATI   Detect the presence of an ATI Technologies SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindATI near

        mov     ax,0C000h
        mov     es,ax
        cmp     [WORD es:40h],'13'  ; ATI Signature for VGA cards
        jne     @@NoATI

; Check for the ATI product code string '761295520'

        cmp     [WORD es:31h],'67'
        jne     @@NoATI
        cmp     [WORD es:31h+2],'21'
        jne     @@NoATI
        cmp     [WORD es:31h+4],'59'
        jne     @@NoATI
        cmp     [WORD es:31h+6],'25'
        jne     @@NoATI
        cmp     [BYTE es:31h+8],'0'
        jne     @@NoATI

        mov     dx,1CEh             ; DX := port of ATI extended registers
        mov     bl,[BYTE es:43h]    ; BL := ATI Chip Version
        cmp     bl,'3'
        jae     @@Ver6up            ; Check for memory on later chip versions

        mov     [VideoChipID],grATI_18800_1
        cmp     bl,'1'
        jne     @@Not18800

; Remove unsupported video modes for (18800 chip)

        mov     [VideoChipID],grATI_18800
        ClearMode   grSVGA_1024x768x16, ATIModes

; Determine the memory size on chip versions 3-4 (18800, 18800-1)

@@Not18800:
        rdinx   1CEh, 0BBh          ; Get RamSize bits
        and     al,20h
        jz      @@DoneATI

        mov     [WORD VideoMem],512 ; Card has 512kb of memory
        jmp     @@DoneATI

; Determine memory size on chip versions 6+ (28800-2, 28800-4, 28800-5)

@@Ver6up:
        mov     [VideoChipID],grATI_28800_2
        rdinx   1CEh, 0B0h          ; Get RamSize bits
        test    al,10h              ; Check if RamSize is 256k or 512k
        jz      @@Ver7Check
        mov     [WORD VideoMem],512 ; Card has at least 512k of memory

@@Ver7Check:
        cmp     bl,'4'
        jb      @@DoneATI           ; Done for version 6 chips
        mov     [VideoChipID],grATI_28800_4
        cmp     bl,'5'
        jb      @@Not28800_5
        mov     [VideoChipID],grATI_28800_5

@@Not28800_5:
        test    al,8                ; Check version 7+ chip memory size
        jz      @@DoneATI
        mov     [WORD VideoMem],1024; Card has 1024k of memory

@@DoneATI:
        mov     [DacType],grVGADAC  ; Default to normal DAC
        test    [BYTE es:44h],8     ; Check bit 7 for HiColor DAC
        jz      @@NoHiColor

        mov     [DacType],grHCDAC   ; We have a 15 bit HiColor DAC
        Add32kColor ATI32KModes

@@NoHiColor:
        mov     [PageFlip],true     ; Card supports extended page flipping
        mov     [WORD VideoModes],offset ATIModes
        mov     ax,grSVGA_ATI
        stc
        ret

@@NoATI:
        clc
        ret

ENDP    FindATI

;----------------------------------------------------------------------------
; FindNCR   Detect the presence of the NCR 77C22E SuperVGA boards
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindNCR near

        tstinx  3C4h, 5, 5          ; Test for extended register enable chip
        jnz     @@NoNCR             ; Check failed, so not an NCR

        wrinx   3C4h, 5, 0          ; Disable extended registers
        tstinx  3C4h, 10h, 0FFh     ; Test Cursor location y register
        jz      @@NoNCR             ; Reg was writeable, so test failed

        wrinx   3C4h, 5, 1          ; Enable extended registers
        tstinx  3C4h, 10h, 0FFh     ; Test Cursor location y register
        jnz     @@NoNCR             ; Reg was not writeable, so not NCR

; Determine the chip revision

        rdinx   3C4h, 8             ; Get chip version number
        shr     al,4
        cmp     al,2
        jae     @@NCR77C22E

; We have an NCR77C20/21 chip. These do not support certain modes.

        ClearMode   grSVGA_1280x1024x16, NCRModes
        ClearMode   grSVGA_1024x768x256, NCRModes
        ClearMode   grSVGA_1280x1024x256, NCRModes

@@NCR77C22E:
        mov     ax,4096             ; Maximum of 4Mb memory
        mov     bx,offset NCRSwitch ; Offset of bank switch routine
        mov     cx,5Eh              ; Values to set 640x400x256
        xor     dx,dx
        call    CheckMem            ; Manually check amount of memory

        mov     [PageFlip],true     ; Card supports extended page flipping
        Add32kColor NCR32KModes
        mov     [WORD VideoModes],offset NCRModes
        mov     ax,grSVGA_NCR
        stc
        ret

@@NoNCR:
        clc
        ret

ENDP    FindNCR

;----------------------------------------------------------------------------
; FindTrident   Detect the presence of the Trident SuperVGA boards
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindTrident near

; When we force the old defintions on Trident TVGA's, they tend to hang up
; if you do it with a 16 bit port instruction. Doing it with 8 bit
; instructions fixes the problem (seems to happen on older cards).
;
; Note that the test in VGADOC that writes stuff to the bank switch
; registers causes some TVGA's to hang up severly (the one I tested it on
; it did). Seems that if you reset the card by setting a video mode before
; doing any bank switching, the problem goes away, but if you dont do this,
; the machine goes off into the never never ...

        mov     dx,3C4h
        mov     al,0Bh
        out     dx,al
        inc     dl
        xor     al,al
        out     dx,al               ; Force old definitions
        in      al,dx               ; Force new definitions
        and     al,0Fh
        cmp     al,2
        jb      @@NoTrident         ; Trident 8800BR only has 128k banks
        cmp     al,2
        je      @@Trident88         ; We have a Trident 8800CS

; Must be a Trident 8900, 8900C or 9000

        rdinx   CRTC, 1Fh           ; Read memory size register
        and     al,3
        cmp     al,1
        jb      @@LowMem
        mov     [WORD VideoMem],512     ; Card has 512kb of memory
        cmp     al,3
        jb      @@LowMem
        mov     [WORD VideoMem],1024    ; Card has 1Mb of memory

@@LowMem:
        mov     [PageFlip],true     ; Card supports extended page flipping
        mov     [WORD VideoModes],offset Trident89Modes
        mov     ax,grSVGA_TRIDENT89
        stc
        ret

@@Trident88:
        rdinx   CRTC, 1Fh           ; Read memory size register
        and     al,2
        jz      @@LowMem88
        mov     [WORD VideoMem],512     ; Card has 512kb of memory

@@LowMem88:
        mov     [PageFlip],true     ; Card supports extended page flipping
        mov     [WORD VideoModes],offset Trident88Modes
        mov     ax,grSVGA_TRIDENT88
        stc
        ret

@@NoTrident:
        clc
        ret

ENDP    FindTrident

;----------------------------------------------------------------------------
; FindVideo7    Detect the presence of a Video7 SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindVideo7  near

        mov     ax,6F00h
        xor     bx,bx
        int     10h
        cmp     bx,'V7'
        jnz     @@NoVideo7

        mov     ax,6F07h            ; Determine how much memory is present
        int     10h
        and     ah,7Fh
        cmp     ah,2
        jb      @@1
        mov     [WORD VideoMem],512     ; Card has 512kb of memory
@@1:    cmp     ah,4
        jb      @@2
        mov     [WORD VideoMem],1024
@@2:    mov     [WORD VideoModes],offset Video7Modes
        mov     [PageFlip],true     ; Card supports extended page flipping
        mov     ax,grSVGA_VIDEO7
        stc
        ret

@@NoVideo7:
        clc
        ret

ENDP    FindVideo7

;----------------------------------------------------------------------------
; FindGenoa Detect the presence of a Genoa GVGA SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindGenoa   near

        mov     ax,0C000h
        mov     es,ax
        mov     bx,[es:37h]         ; Get offset of information table
        cmp     [BYTE es:bx],77h
        jne     @@NoGenoa
        cmp     [WORD es:bx+2],6699h
        jne     @@NoGenoa

        mov     al,[BYTE es:bx+1]   ; Get card version number
        or      al,al
        jz      @@HaveGenoa256      ; Found a Genoa 62/300
        cmp     al,11h
        je      @@HaveGenoa512      ; Found a Genoa 64/600
        cmp     al,22h
        je      @@HaveGenoa256      ; Found a Genoa 6100
        jmp     @@NoGenoa           ; Other Genoa's have Tseng chips

@@HaveGenoa512:
        mov     [WORD VideoMem],512

@@HaveGenoa256:
        mov     [WORD VideoModes],offset GenoaModes
        mov     ax,grSVGA_GENOA
        stc
        ret

@@NoGenoa:
        clc
        ret

ENDP    FindGenoa

;----------------------------------------------------------------------------
; FindParadise  Detect the presence of a Paradise SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindParadise    near

        rdinx   3CEh, 0Fh           ; Read old register value
        mov     [old],al            ; Save old value
        modinx  3CEh, 0Fh, 17h, 0   ; Lock paradise registers
        tstinx  3CEh, 9, 7Fh        ; Test if bank register is there
        jz      @@NoParadise        ; Register wrote, so not paradise

        wrinx   3CEh, 0Fh, 5        ; Unlock paradise registers
        tstinx  3CEh, 9, 7Fh        ; Test if bank register is there
        jnz     @@NoParadise        ; Register wouldn't write, not paradise

; We have a Paradise SuperVGA, so determine what chip it is.

        rdinx   CRTC, 29h           ; Read value of WD90Cxx register lock
        mov     [old],al            ; Save old value
        modinx  CRTC, 29h, 8Fh, 85h ; Unlock WD90Cxx registers
        tstinx  CRTC, 2Bh, 0FFh     ; Test WD90Cxx scratch register
        jnz     @@HavePVGA          ; We have a PVGA1

        rdinx   3C4h, 6             ; Read value of WD90C1x register
        mov     [old],al            ; Save old value
        wrinx   3C4h, 6, 48h
        tstinx  3C4h, 7, 0F0h
        jnz     @@HaveWD90C00
        tstinx  3C4h, 10h, 0FFh
        jnz     @@HavePVGA          ; WD90C2x has same modes as PVGA

        tstinx  3C4h, 14h, 0Fh
        jnz     @@HaveWD90C1x

        rdinx   CRTC, 37h
        cmp     al,31h
        mov     [VideoChipID],grPARA_90c31
        je      @@MemCheck          ; Have a WD90C31

; Chip is a WD90C30.

        mov     [VideoChipID],grPARA_90c30
        wrinx   3C4h, 6, [old]      ; Restore register value
        ClearMode   grSVGA_1280x1024x16, ParadiseModes
        jmp     @@MemCheck

@@HaveWD90C1x:
        wrinx   3C4h, 6, [old]      ; Restore register value
        ClearMode   grSVGA_1280x1024x16, ParadiseModes
        ClearMode   grSVGA_1024x768x256, ParadiseModes
        mov     [VideoChipID],grPARA_90c10
        tstinx  3C4h, 0Ah, 04h
        jnz     @@MemCheck
        mov     [VideoChipID],grPARA_90c11
        jmp     @@MemCheck

@@HaveWD90C00:
        mov     [VideoChipID],grPARA_90c00
        wrinx   3C4h, 6, [old]      ; Restore register value
        ClearMode   grSVGA_1280x1024x16, ParadiseModes
        ClearMode   grSVGA_1024x768x256, ParadiseModes
        jmp     @@MemCheck

@@HavePVGA:
        mov     [VideoChipID],grPARA_PVGA1A
        wrinx   CRTC, 29h, [old]    ; Restore value of WD90Cxx register lock
        ClearMode   grSVGA_1024x768x16, ParadiseModes
        ClearMode   grSVGA_1280x1024x16, ParadiseModes
        ClearMode   grSVGA_800x600x256, ParadiseModes
        ClearMode   grSVGA_1024x768x256, ParadiseModes
        jmp     @@MemCheck

@@MemCheck:
        rdinx   3CEh, 0Bh           ; Read memory size register
        shr     al,6
        cmp     al,2
        jb      @@DoneMem
        mov     [WORD VideoMem],512 ; Card has 512kb of memory
        cmp     al,3
        jb      @@DoneMem
        mov     [WORD VideoMem],1024; Card has 1024kb of memory

@@DoneMem:
        mov     [PageFlip],true     ; Card supports extended page flipping
        Add32kColor Parad32KModes
        mov     [WORD VideoModes],offset ParadiseModes

; Ok, now check to see if the card is capable of 800x600x16 color mode. If
; it isn't, then the card is probably running on an LCD display, so we
; disable all modes above 640x480.

        call    saveMode
    mov ax,58h or 80h       ; Don't clear the memory!
        int     10h
        call    CheckGraphics
        jc      @@Have800x600

        ClearMode   grSVGA_800x600x16, ParadiseModes
        ClearMode   grSVGA_1024x768x16, ParadiseModes
        ClearMode   grSVGA_800x600x256, ParadiseModes
        ClearMode   grSVGA_1024x768x256, ParadiseModes
        ClearMode   grSVGA_800x600x32k, ParadiseModes

@@Have800x600:
        call    restoreMode
        mov     ax,grSVGA_PARADISE
        stc
        ret

@@NoParadise:
        wrinx   3CEh, 15, [old]     ; Restore old register value
        clc
        ret

ENDP    FindParadise

;----------------------------------------------------------------------------
; FindChips Detect the presence of a Chips & Technologies SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindChips   near

        mov     ax,5F00h            ; Get controller info servic
        xor     bx,bx
        int     10h
        cmp     al,5Fh              ; AL == 5F we have a Chips
        jnz     @@NoChips

; We have a Chips & Tech SuperVGA, so determine what chipset it is

        mov     [PageFlip],true     ; Card supports extended page flipping

        shr     bl,4
        cmp     bl,0
        je      @@Have82c451
        cmp     bl,1
        je      @@Have82c452
        cmp     bl,2
        je      @@Have82c451        ; 82c455 has same modes as 451
        cmp     bl,4
        je      @@Have82c451        ; 82c456 has same modes as 451
        mov     [VideoChipID],grCHIPS_82c453
        jmp     @@CheckMem          ; 82c453+ support all modes

@@Have82c451:
        mov     [PageFlip],false    ; No page flipping on this chip
        ClearMode   grSVGA_1024x768x16, ChipsModes
        ClearMode   grSVGA_640x480x256, ChipsModes
        ClearMode   grSVGA_800x600x256, ChipsModes
        ClearMode   grSVGA_1024x768x256, ChipsModes
        mov     [VideoChipID],grCHIPS_82c451
        jmp     @@CheckMem

@@Have82c452:
        ClearMode   grSVGA_800x600x256, ChipsModes
        ClearMode   grSVGA_1024x768x256, ChipsModes
        mov     [VideoChipID],grCHIPS_82c452
        jmp     @@CheckMem

; Determine memory size

@@CheckMem:
        cmp     bh,1
        jb      @@DoneMem
        mov     [WORD VideoMem],512
        cmp     bh,2
        jb      @@DoneMem
        mov     [WORD VideoMem],1024

@@DoneMem:
        mov     [WORD VideoModes],offset ChipsModes
        mov     ax,grSVGA_CHIPS
        stc
        ret

@@NoChips:
        clc
        ret

ENDP    FindChips

;----------------------------------------------------------------------------
; FindTseng Detect the presence of the ET3000 and ET4000 SuperVGA boards
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindTseng   near

        outp    3BFh, 3
        outp    3D8h, 0A0h          ; Enable ET4000 extensions
        tstreg  3CDh, 3Fh           ; Test bank switch register
        jnz     @@NoTseng           ; Test failed, not a Tseng

; We have a Tseng card, so determine if it is an ET3000 or ET4000

        tstinx  CRTC, 33h, 0Fh      ; Test for ET4000 extended start address
        jz      @@ET4000

; We have an ET3000 board, so check the amount of memory installed

        mov     ax,512              ; Maximum of 512k on board
        mov     bx,offset ET3000Switch
        mov     cx,2Dh              ; Values to set 640x350x256
        xor     dx,dx
        call    CheckMem

        mov     [PageFlip],true     ; Card supports extended page flipping
        mov     [WORD VideoModes],offset ET3000Modes
        mov     ax,grSVGA_ET3000
        stc
        ret

; We have an ET4000 board, so determine the amount of memory installed

@@ET4000:
        rdinx   CRTC, 37h           ; Read memory size bits
        and     al,0Bh
        cmp     al,0Ah
        jb      @@1
        mov     [WORD VideoMem],512
@@1:    cmp     al,0Bh
        jb      @@2
        mov     [WORD VideoMem],1024

; If the board has a 32k color DAC on board, check to see if we can set
; the 320x200 32k color mode which is not available on all boards.

@@2:
        mov     [VideoChipID],grET4000_MEGAEVA
        call    SaveMode
        cmp     [DacType],grHCDAC
        jl      @@Check1280
        mov     ax,10F0h
        mov     bx,13h or 80h
        int     10h
        cmp     ax,0010h
        je      @@CheckTC

        ClearMode   grSVGA_320x200x32k, ET400032KModes+1

; If the board has a 24 bit video DAC on board, determine what type of
; board it is (MegaEva/2, Speedstar 24, Genoa 7900), which all have
; different video mode numbers.

@@CheckTC:
        cmp     [DacType],grTCDAC
        jne     @@Check1280

; Assume board is a MegaEva/2, unless we find otherwise

        mov     ax,10E0h
        mov     bx,2Eh or 80h
        int     10h
        cmp     ax,0010h
        jne     @@CheckGenoa        ; Not speedstar, check for Genoa 7900

; Board is a Diamond Speedstar 24

        mov     [VideoChipID],grET4000_SPEEDSTAR
        ClearMode   grSVGA_640x350x16m, ET4000TCModes+1
        ClearMode   grSVGA_640x400x16m, ET4000TCModes+1
        jmp     @@Check1280

@@CheckGenoa:
        mov     ax,10F0h
        mov     bx,3Eh or 80h
        int     10h
        cmp     ax,0010h
        jne     @@Check1280         ; Not a Genoa, must be MegaEva/2...

; Board is a Genoa 7900

        mov     [VideoChipID],grET4000_GENOA
        ClearMode   grSVGA_640x350x16m, ET4000TCModes+1
        ClearMode   grSVGA_640x400x16m, ET4000TCModes+1

; Check to see if the 1280x1024x16 color video mode is available.

@@Check1280:
        mov     ax,03Dh or 80h      ; 1280x1024x16 color video mode
        int     10h
        call    CheckGraphics
        jc      @@DoneCheck         ; Yes, mode is available

        ClearMode   grSVGA_1280x1024x16, ET4000Modes

@@DoneCheck:
        call    RestoreMode

        mov     [PageFlip],true     ; Card supports extended page flipping
        Add32kColor     ET400032KModes
        AddTrueColor    ET4000TCModes
        mov     [WORD VideoModes],offset ET4000Modes
        mov     ax,grSVGA_ET4000
        stc
        ret

@@NoTseng:
        clc
        ret

ENDP    FindTseng

;----------------------------------------------------------------------------
; FindEverex    Detect the presence of an Everex SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindEverex  near

        mov     ax,7000h
        xor     bx,bx
        int     10h
        cmp     al,70h
        jnz     @@NoEverex

; Some Everex boards use Trident and ET4000 chipsets. These boards will be
; picked up by the low level INIT_everex routine. We do however determine
; the chipset type here, since all everex boards use the same video
; mode numbers.

        mov     [PageFlip],true     ; Default to page flipping
        shr     dx,4
        mov     [VideoChipID],grEVEREX_Ev236
        cmp     dx,236h             ; UltraGraphics - Trident Chip
        je      @@CheckMem
        mov     [VideoChipID],grEVEREX_Ev620
        cmp     dx,620h             ; Vision VGA - Trident Chip
        je      @@CheckMem
        mov     [VideoChipID],grEVEREX_Ev629
        cmp     dx,629h             ; ViewPoint TC - ET4000 Chip
        je      @@CheckMem
        mov     [VideoChipID],grEVEREX_Ev673
        cmp     dx,673h             ; EVGA - Trident Chip
        je      @@CheckMem
        mov     [VideoChipID],grEVEREX_Ev678
        cmp     dx,678h             ; Viewpoint - Trident Chip
        je      @@CheckMem

        mov     [VideoChipID],grEVEREX_EvNR
        mov     [PageFlip],false    ; No page flipping on this card

@@CheckMem:
        shr     ch,6
        cmp     ch,1
        jb      @@DoneMem
        mov     [WORD VideoMem],512     ; Card has 512kb of memory
        cmp     ch,2
        jb      @@DoneMem
        mov     [WORD VideoMem],1024    ; Card has 1024kb of memory
        cmp     ch,3
        jb      @@DoneMem
        mov     [WORD VideoMem],2048    ; Card has 2048kb of memory

@@DoneMem:
        Add32kColor     Everex32KModes
        AddTrueColor    EverexTCModes
        mov     [WORD VideoModes],offset EverexModes
        mov     ax,grSVGA_EVEREX
        stc
        ret

@@NoEverex:
        clc
        ret

ENDP    FindEverex

;----------------------------------------------------------------------------
; FindAhead Detect the presence of a Ahead A or B SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindAhead   near

        rdinx   3CEh, 0Fh
        mov     [old],al
        wrinx   3CEh, 0Fh, 0        ; Disable extended registers
        tstinx  3CEh, 0Dh, 0FFh     ; Test for bank switch register
        jz      @@NoAhead           ; Register wrote, so not Ahead

        wrinx   3CEh, 0Fh, 20h      ; Enable extended registers
        tstinx  3CEh, 0Dh, 0FFh     ; Test for bank switch register
        jnz     @@NoAhead           ; Register didn't write, so not Ahead

; SuperVGA is an Ahead, so determine type.

        rdinx   3CEh, 0Fh           ; Read chip version register
        and     al,0Fh
        jnz     @@AheadB            ; We have an Ahead B

        ClearMode   grSVGA_1024x768x256, AheadModes
        mov     ax,512              ; Maximum of 512k on board
        mov     bx,offset AHEADASwitch
        mov     cx,60h              ; Values to set 640x400x256
        xor     dx,dx
        call    CheckMem
        mov     [WORD VideoModes],offset AheadModes
        mov     ax,grSVGA_AHEADA
        stc
        ret

@@AheadB:
        mov     ax,1024             ; Maximum of 1024k on board
        mov     bx,offset AHEADBSwitch
        mov     cx,60h              ; Values to set 640x400x256
        xor     dx,dx
        call    CheckMem
        mov     [PageFlip],true     ; Card supports extended page flipping
        mov     [WORD VideoModes],offset AheadModes
        mov     ax,grSVGA_AHEADB
        stc
        ret

@@NoAhead:
        wrinx   3CEh, 0Fh, [old]    ; Restore register
        clc
        ret

ENDP    FindAhead

;----------------------------------------------------------------------------
; FindCirrus    Detect the presence of an Cirrus 54xx SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindCirrus  near

        rdinx   3C4h, 6
        mov     [old],al            ; Save of value of register
        wrinx   3C4h, 6, 12h        ; Enable extended registers
        rdinx   3C4h, 6
        cmp     al,12h              ; Check value in extended register lock
        jne     @@NoCirrus
        tstinx  3C4h, 1Eh, 3Fh
        jnz     @@NoCirrus          ; Reg wasn't writeable, test failed
        tstinx  CRTC, 1Bh, 0FFh
        jnz     @@NoCirrus          ; Reg wasn't writeable, test failed

; We have a Cirrus 54xx SuperVGA, so determine how much memory is on board

        rdinx   3C4h, 0Fh           ; Get value of memory size register
        shr     al,3
        and     al,3
        cmp     al,1
        jb      @@DoneCirrus
        mov     [WORD VideoMem],512
        cmp     al,2
        jb      @@DoneCirrus
        mov     [WORD VideoMem],1024
        cmp     al,3

@@DoneCirrus:
        Add32kColor     Cirrus32KModes
        AddTrueColor    CirrusTCModes
        mov     [PageFlip],true     ; Card supports page flipping
        mov     [WORD VideoModes],offset CirrusModes
        mov     [VideoChipID],grCIRRUS_5422
        mov     ax,grSVGA_CIRRUS54
        stc
        ret

@@NoCirrus:
        wrinx   3C4h, 6, [old]      ; Restore extended register enable
        clc
        ret

ENDP    FindCirrus

;----------------------------------------------------------------------------
; FindAcuMos    Detect the presence of an AcuMos SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindAcuMos  near

        rdinx   3C4h, 6
        mov     [old],al            ; Save of value of register
        wrinx   3C4h, 6, 12h        ; Enable extended registers
        tstinx  3CEh, 9, 30h        ; Test scratchpad 9 again
        jnz     @@NoAcuMos          ; Reg not wasn't writeable, test failed

; We have an AcuMos SuperVGA, so determine how much memory is on board

        rdinx   3C4h, 0Ah           ; Get scratchpad index 10
        and     al,3
        cmp     al,1
        jb      @@DoneAcuMos
        mov     [WORD VideoMem],512
        cmp     al,2
        jb      @@DoneAcuMos
        mov     [WORD VideoMem],1024
        cmp     al,3
        jb      @@DoneAcuMos
        mov     [WORD VideoMem],2048

@@DoneAcuMos:
        mov     [WORD VideoModes],offset AcuMosModes
        mov     ax,grSVGA_ACUMOS
        stc
        ret

@@NoAcuMos:
        wrinx   3C4h, 6, [old]      ; Restore extended register enable
        clc
        ret

ENDP    FindAcuMos

;----------------------------------------------------------------------------
; FindOaktech   Detect the presence of an Oak Technologies SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindOaktech near

        tstinx  3DEh, 0Dh, 38h      ; Test for memory size register
        jnz     @@NoOakTech         ; Do not have an OakTech board

; We have an Oak Technologies SuperVGA, so determine the type. The OTI-037C
; bank switching registers are read only, so the following test will fail
; for these cards.

        tstinx  3DEh, 11h, 0FFh     ; Look for R/W bank switch register
        jnz     @@Have037C          ; Have an OTI-037C

; We have an OAK SuperVGA, so determine what chipset it is

        rdinx   3DEh, 0Bh           ; Read Chip Revision register
        shr     al,5
        cmp     al,5
        mov     [VideoChipID],grOAK_077
        je      @@Have077           ; Chip is an OTI-077

        mov     [VideoChipID],grOAK_067
        ClearMode   grSVGA_1024x768x256, OAKModes

@@Have077:
        rdinx   3DEh, 0Dh           ; Read memory size register
        shr     al,6
        or      al,al
        jz      @@DoneMem                   ; Board has 256k
        mov     [WORD VideoMem],512
        cmp     al,2
        je      @@DoneMem
        mov     [WORD VideoMem],1024
        jmp     @@DoneMem

; We have an OTI-037C SuperVGA. The only supported video mode is 800x600x16
; with 256k of memory.

@@Have037C:
        mov     [VideoChipID],grOAK_037C
        rdinx   3DEh, 0Dh           ; Read memory size register
        shr     al,6
        or      al,al
        jz      @@DoneMem                   ; Board has 256k
        mov     [WORD VideoMem],512

@@DoneMem:
        Add32kColor OAK32KModes
        mov     [WORD VideoModes],offset OAKModes
        mov     ax,grSVGA_OAKTECH
        stc
        ret

@@NoOaktech:
        clc
        ret

ENDP    FindOaktech

;----------------------------------------------------------------------------
; FindAL2101    Detect the presence of an Advance Logic 2101 SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindAL2101  near

        tstreg  8286h, 0FFh         ; Check for Start Pixel Low register
        jnz     @@NoAL2101          ; Test failed, no AL2101
        tstinx  CRTC, 1Fh, 3Bh      ; Check for Emulation register
        jnz     @@NoAL2101          ; Test failed, no AL2101
        tstinx  3CEh, 0Dh, 0Fh      ; Check for Fill Color register
        jnz     @@NoAL2101          ; Test failed, no AL2101

; We have an AL2101 based SuperVGA

        rdinx   CRTC, 1Eh           ; Read memory size register
        and     al,3
        cmp     al,1
        jb      @@DoneMem
        mov     [WORD VideoMem],512
        cmp     al,2
        jb      @@DoneMem
        mov     [WORD VideoMem],1024
        cmp     al,3
        jb      @@DoneMem
        mov     [WORD VideoMem],2048

@@DoneMem:
        mov     [DacType],grHC2DAC  ; AL2101 has a 16 bit DAC
        mov     [WORD VideoModes],offset AL2101Modes
        mov     ax,grSVGA_AL2101
        stc
        ret

@@NoAL2101:
        clc
        ret

ENDP    FindAL2101

;----------------------------------------------------------------------------
; FindMXIC  Detect the presence of an MXIC 68010 SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindMXIC    near

        rdinx   3C4h, 0A7h          ; Read extend reg enable value
        mov     [old],al
        wrinx   3C4h, 0A7h, 0       ; Disable extended registers
        tstinx  3C4h, 0C5h, 0FFh    ; Test for bank switch register
        jz      @@NoMXIC            ; Test passed, so not MXIC

        wrinx   3C4h, 0A7h, 87h     ; Enable extended registers
        tstinx  3C4h, 0C5h, 0FFh    ; Test for bank switch register
        jnz     @@NoMXIC            ; Test failed, so not MXIC

; We have an MXIC SuperVGA.

        rdinx   3C4h, 0C2h          ; Read memory size register
        shr     al,2
        and     al,3
        cmp     al,1
        jb      @@DoneMem
        mov     [WORD VideoMem],512
        cmp     al,2
        jb      @@DoneMem
        mov     [WORD VideoMem],1024

@@DoneMem:
        mov     [WORD VideoModes],offset MXICModes
        mov     ax,grSVGA_MXIC
        stc
        ret

@@NoMXIC:
        wrinx   3C4h, 0A7h, [old]   ; Restore register
        clc
        ret

ENDP    FindMXIC

;----------------------------------------------------------------------------
; FindP2000 Detect the presence of a Primus 2000 SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindP2000   near

        tstinx  3CEh, 3Dh, 03Fh     ; Check for Status command register
        jnz     @@NoP2000           ; Test failed, not P2000
        tstreg  3D6h, 01Fh          ; Check for bank switch register
        jnz     @@NoP2000           ; Test failed, not P2000
        tstreg  3D7h, 01Fh          ; Check for bank switch register
        jnz     @@NoP2000           ; Test failed, not P2000

; We have a Primus P2000 SuperVGA card.

        mov     ax,2048             ; Maximum of 2048k on board
        mov     bx,offset P2000Switch
        mov     cx,2Ch              ; Values to set 640x400x256
        xor     dx,dx
        call    CheckMem

        Add32kColor P200032KModes
        mov     [PageFlip],true     ; Card supports extended page flipping
        mov     [WORD VideoModes],offset P2000Modes
        mov     ax,grSVGA_P2000
        stc
        ret

@@NoP2000:
        clc
        ret

ENDP    FindP2000

;----------------------------------------------------------------------------
; FindRT3106    Detect the presence of a RealTek 3106 SuperVGA board
;----------------------------------------------------------------------------
;
; Routine detects if the SuperVGA boards is present and determines how much
; memory is on it.
;
; Exit:         Carry flag is set if board was detected
;
;               AX              - Video card identifier
;               [VideoMem]      - Amount of video memory on board
;               [VideoChipID]   - Chip revision id
;
;----------------------------------------------------------------------------
PROC    FindRT3106  near

        tstinx  CRTC, 1Fh, 3h       ; Test for scratch register
        jnz     @@NoRT3106
        tstreg  3D6h, 0Fh           ; Test for bank switch register
        jnz     @@NoRT3106
        tstreg  3D7h, 0Fh           ; Test for bank switch register
        jnz     @@NoRT3106

; We have a RealTek 3106 SuperVGA

        rdinx   CRTC, 1Ah           ; Get chip version number
        mov     bl,al               ; Save chip version number
        shr     bl,6
        rdinx   CRTC, 1Eh           ; Get memory size register
        and     al,15
        cmp     al,1
        jb      @@DoneMem
        mov     [WORD VideoMem],512
        cmp     al,2
        jb      @@DoneMem
        or      bl,bl
        jz      @@Version0
        mov     [WORD VideoMem],1024
        cmp     al,3
        jb      @@DoneMem
        mov     [WORD VideoMem],2048
        jmp     @@DoneMem

@@Version0:
        cmp     al,3
        jb      @@DoneMem
        mov     [WORD VideoMem],1024

@@DoneMem:
        mov     [WORD VideoModes],offset RT3106Modes
        mov     ax,grSVGA_RT3106
        stc
        ret

@@NoRT3106:
        clc
        ret

ENDP    FindRT3106

OldBIOSMode     db  ?               ; Old BIOS mode
Old50Lines      db  ?
Oldx            db  ?               ; Old cursor position
Oldy            db  ?

;----------------------------------------------------------------------------
; SaveMode  - Saves the current video BIOS mode, for later restoration
;----------------------------------------------------------------------------
;
; Registers:    none.
;
;----------------------------------------------------------------------------
PROC    SaveMode

        pusha

; Find the current video mode so that we can restore it easily

        mov     ah,0Fh              ; Get current video mode service
        int     10h
        mov     [OldBIOSMode],al    ; Save old video mode
        mov     ah,03h              ; Get cursor position
        int     10h
        mov     [Oldx],dl
        mov     [Oldy],dh
        mov     [Old50Lines],0      ; Default to non-50 line mode

        mov     ax,1130h            ; AH := INT 10h function number
                                    ; AL := Get character gen information
        mov     bh,00               ; Get contents of INT 1Fh
        xor     dl,dl               ; Clear dl
        int     10h                 ; Determine number of lines (in dl)
        cmp     dl,49               ; 50 line mode?
        jne     @@Done              ; No, must have been 25 lines
        mov     [Old50Lines],1      ; Yes, 50 line mode was on

@@Done:
        popa
        ret

ENDP    SaveMode

;----------------------------------------------------------------------------
; RestoreMode   - Restores the VIDEO BIOS mode previously saved.
;----------------------------------------------------------------------------
;
; Registers:    none.
;
;----------------------------------------------------------------------------
PROC    RestoreMode

        pusha
        mov     ah,0                ; Set video mode service
        mov     al,[OldBIOSMode]    ; Get old BIOS mode number
        or      al,80h              ; Set the don't clear memory bit
        int     10h                 ; Set the video mode

        cmp     [Old50Lines],0      ; Was 50 line mode set?
        je      @@Exit              ; No, don't set it up

        mov     ax,1112h            ; AH := INT 10h function number
                                    ; AL := 8x8 character set load
        mov     bl,0                ; BL := block to load
        int     10h                 ; load 8x8 characters into RAM

@@Exit:
        mov     ah,02h
        mov     dl,[Oldx]
        mov     dh,[Oldy]
        xor     bh,bh
        int     10h                 ; Set cursor location
        popa
        ret

ENDP    RestoreMode

;----------------------------------------------------------------------------
; CheckGraphics - Check to see if graphics mode is currently active.
;----------------------------------------------------------------------------
;
; This routine checks to see if a graphics mode was successfully set,
; setting the carry flag if it was.
;
; Exit:         carry - Set if graphics mode is set.
;
; Registers:    None.
;
;----------------------------------------------------------------------------
PROC    CheckGraphics

        push    ax
        mov     ax,40h
        mov     es,ax
        xor     ax,ax
        cmp     [BYTE es:49h],3     ; Mode is still text mode, did not set
        ja      @@IsGraphics

        pop     ax
        clc
        ret

@@IsGraphics:
        pop     ax
        stc
        ret

ENDP    CheckGraphics

;----------------------------------------------------------------------------
; CheckMem  Performs a manual memory test
;----------------------------------------------------------------------------
;
; Does a manual memory test by attempting to read and write values at
; various places in memory, determining when they fail.
;
; Entry:        AX  - Maximum amount of memory installed
;               BX  - Offset of bank switching routine
;               CX  - Value in AX to set 256 color mode
;               DX  - Value in BX to set 256 color mode
;
; Exit:         [VideoMem] set to the correct value
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    CheckMem

        push    si
        push    di
        push    bp

        push    ax
        push    bx
        push    cx
        push    dx

; Find the current video mode so that we can restore it easily

        mov     ah,0Fh              ; Get current video mode service
        int     10h
        mov     [OldBIOSMode],al    ; Save old video mode
        mov     [Old50Lines],0      ; Default to non-50 line mode

        mov     ax,1130h            ; AH := INT 10h function number
                                    ; AL := Get character gen information
        mov     bh,00               ; Get contents of INT 1Fh
        xor     dl,dl               ; Clear dl
        int     10h                 ; Determine number of lines (in dl)
        cmp     dl,49               ; 50 line mode?
        jne     @@SetMode           ; No, must have been 25 lines
        mov     [Old50Lines],1      ; Yes, 50 line mode was on

@@SetMode:
        pop     bx                  ; Pop value for BX
        pop     ax                  ; Pop value for AX
        int     10h                 ; Set the video mode

; Now perform the memory check

        mov     ax,0A000h
        mov     es,ax
        pop     bx
        pop     bp
        shr     bp,6                ; BP := maximum number of 64k banks
        xor     di,di               ; ES:DI -> offset in video RAM

        mov     dx,4                ; Start by checking for 256k RAM

@@CheckLoop:
        mov     ax,dx
        dec     ax
        call    bx                  ; Setup to to read/write maxbank-1
        mov     cx,[es:di]          ; Read a value from memory
        mov     si,cx               ; Save the old value
        xor     cx,0AAAAh           ; Modify the value
        mov     [es:di],cx          ; Put the value back again
        mov     cx,[es:di]          ; Read the value back again
        mov     [es:di],si          ; Put the old value back
        xor     cx,0AAAAh           ; Attempt to get old value back
        cmp     cx,si               ; Old value the same?
        jne     @@TestFailed        ; The test failed, so we ran outa memory!

        mov     ax,dx
        shr     ax,1
        dec     ax
        call    bx                  ; Setup for (bank/2) - 1
        mov     ax,si
        xor     ax,5555h
        mov     [es:di],ax          ; Set modified value
        mov     ax,dx
        dec     ax
        call    bx                  ; Setup for bank-1
        mov     ax,[es:di]
        xor     ax,5555h
        cmp     ax,si
        je      @@TestFailed

        cmp     dx,bp               ; Have we reached maximum amount?
        je      @@FullMemory        ; Yes, so we have maximum memory...

        shl     dx,1                ; Keep on trying
        jmp     @@CheckLoop

@@FullMemory:
        shl     dx,1                ; Indicate that we would have failed
                                    ;  on next bank
@@TestFailed:
        shl     dx,5                ; DX := amount of video memory
        mov     [VideoMem],dx       ; Save the memory value found

; Restore the old video mode before leaving

        mov     ah,0                ; Set video mode service
        mov     al,[OldBIOSMode]    ; Get old BIOS mode number
        int     10h                 ; Set the video mode

        cmp     [Old50Lines],0      ; Was 50 line mode set?
        je      @@Exit              ; No, don't set it up

        mov     ax,1112h            ; AH := INT 10h function number
                                    ; AL := 8x8 character set load
        mov     bl,0                ; BL := block to load
        int     10h                 ; load 8x8 characters into RAM

@@Exit:
        pop     bp
        pop     di
        pop     si
        ret

ENDP    CheckMem

;----------------------------------------------------------------------------
; NCRSwitch NCR 77C22E bank switching routine
;----------------------------------------------------------------------------
;
; Entry:        AL  - Bank number to switch to
;
;----------------------------------------------------------------------------
PROC    NCRSwitch

        push    dx
        shl     al,2                ; Change 64k bank into 16k bank number
        mov     ah,al
        mov     al,18h
        mov     dx,3C4h
        out     dx,ax               ; Set write bank number
        mov     al,1Ch
        out     dx,ax               ; Set read bank number
        pop     dx
        ret

ENDP    NCRSwitch

;----------------------------------------------------------------------------
; ET3000Switch  ET3000 bank switching routine
;----------------------------------------------------------------------------
;
; Entry:        AL  - Bank number to switch to
;
;----------------------------------------------------------------------------
PROC    ET3000Switch

        push    dx
        and     al,7                ; Mask out bottom 3 bits
        mov     ah,al               ; Combine read and write bank values in al
        shl     ah,3
        or      al,ah
        or      al,40h              ; Set bit 6 to select 64k segments
        mov     dx,3CDh             ; Point to memory segment register
        out     dx,al               ; Set the new bank value
        pop     dx
        ret

ENDP    ET3000Switch

;----------------------------------------------------------------------------
; AHEADASwitch  Ahead A bank switching routine
;----------------------------------------------------------------------------
;
; Entry:        AL  - Bank number to switch to
;
;----------------------------------------------------------------------------
PROC    AHEADASwitch

        push    dx
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
        pop     dx
        ret

ENDP    AHEADASwitch

;----------------------------------------------------------------------------
; AHEADBSwitch  Ahead B bank switching routine
;----------------------------------------------------------------------------
;
; Entry:        AL  - Bank number to switch to
;
;----------------------------------------------------------------------------
PROC    AHEADBSwitch

        push    dx
        mov     ah,al               ; Combine read/write bank numbers
        shl     ah,4
        or      ah,al
        mov     al,0Dh              ; Index of Bank Switch register
        mov     dx,3CEh
        out     dx,ax               ; Set the register
        pop     dx
        ret

ENDP    AHEADBSwitch

;----------------------------------------------------------------------------
; P2000Switch   Primus P2000 bank switching routine
;----------------------------------------------------------------------------
;
; Entry:        AL  - Bank number to switch to
;
;----------------------------------------------------------------------------
PROC    P2000Switch

        push    dx
        mov     dx,3D6h
        out     dx,al               ; Set read bank
        inc     dx
        out     dx,al               ; Set write bank
        pop     dx
        ret

ENDP    P2000Switch

;----------------------------------------------------------------------------
; Find6845  Determine if a 6845 CRTC is at the required port
;----------------------------------------------------------------------------
;
; Routine detects the presence of the CRTC on an MDA, CGA, or HGC.
; The technique is to write and read register 0Fh of the chip (Cursor
; Location Low). If the same value is read as written, assume the chip
; is present at the specified location.
;
; Entry:        DX = port address of 6845 CRTC
;
; Exit:         Carry flag is set if 6845 is present
;
; Registers:    AX,CX,DX
;
;----------------------------------------------------------------------------
PROC    Find6845 near

        mov     al,0Fh
        out     dx,al           ; Select 6845 reg 0Fh (Cursor low)
        inc     dx

        in      al,dx           ; AL := current Cursor Low value
        mov     ah,al           ; Preserve in AH
        mov     al,66h          ; AL := arbitrary value
        out     dx,al           ; Try to write 6845

        mov     cx,100h
@@Wait:
        loop    @@Wait          ; wait for 6845 to respond

        in      al,dx
        xchg    ah,al           ; AH := returned value
                                ; AL := original value
        out     dx,al           ; Restore original value

        cmp     ah,66h          ; test whether 6845 responded
        jne     @@Exit          ; Jump if it didn't (cf is reset)

        stc                     ; Set carry if 6845 present

@@Exit:
        ret

ENDP    Find6845

endcodeseg  detectgr

        END                     ; End of module
