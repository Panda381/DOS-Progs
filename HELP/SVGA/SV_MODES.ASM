;****************************************************************************
;*
;*                      MegaGraph Graphics Library
;*
;*          Copyright (C) 1993 Kendall Bennett.
;*                          All rights reserved.
;*
;* Filename:    $RCSfile: sv_modes.asm $
;* Version:     $Revision: 1.1 $
;*
;* Language:    80386 Assembler
;* Environment: IBM PC (MS DOS)
;*
;* Description: Module to load AX and BX with the appropriate values to
;*              set a specified video mode for a specified SuperVGA
;*              video card.
;*
;* $Id: sv_modes.asm 1.1 1993/03/03 10:27:09 kjb Exp $
;*
;* Revision History:
;* -----------------
;*
;* $Log: sv_modes.asm $
;* Revision 1.1  1993/03/03  10:27:09  kjb
;* Initial revision
;*
;****************************************************************************

; Table of SuperVGA mode numbers by video card. The first word is the value
; stored in AX, the second is the value stored in BX for the INT 10h
; BIOS call. Don't change the order of the drivers in this table!!

VGAModes:           dw  0Dh, 0          ; 320x200 16 color
                    dw  0Eh, 0          ; 640x200 16 color
                    dw  10h, 0          ; 640x350 16 color
                    dw  0, 0            ; 640x400 16 color (non standard)
                    dw  12h, 0          ; 640x480 16 color
                    dw  13h, 0          ; 320x200 256 color

SVGAModes:          ;   AX:    BX:        Video Mode:

VESAModeNums:       dw  4F02h, 102h     ; 800x600 16 color
                    dw  4F02h, 104h     ; 1024x768 16 color
                    dw  4F02h, 106h     ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  4F02h, 100h     ; 640x400 256 color
                    dw  4F02h, 101h     ; 640x480 256 color
                    dw  4F02h, 103h     ; 800x600 256 color
                    dw  4F02h, 105h     ; 1024x768 256 color
                    dw  4F02h, 107h     ; 1280x1024 256 color
                    dw  4F02h, 10Dh     ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  4F02h, 110h     ; 640x480 32k color
                    dw  4F02h, 113h     ; 800x600 32k color
                    dw  4F02h, 116h     ; 1024x768 32k color
                    dw  4F02h, 119h     ; 1280x1024 32k color
                    dw  4F02h, 10Fh     ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  4F02h, 112h     ; 640x480 16m color
                    dw  4F02h, 115h     ; 800x600 16m color
                    dw  4F02h, 118h     ; 1024x768 16m color
                    dw  4F02h, 11Bh     ; 1280x1024 16m color

SVGAModeSize        =   ($-VESAModeNums); Size of table in bytes

ATIModes:           dw  54h, 0          ; 800x600 16 color
                    dw  55h, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x340 256 color
                    dw  61h, 0          ; 640x400 256 color
                    dw  62h, 0          ; 640x480 256 color
                    dw  63h, 0          ; 800x600 256 color
                    dw  64h, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x340 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  72h, 0          ; 640x480 32k color
                    dw  73h, 0          ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x340 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

AHEADAModes:        dw  71h, 0          ; 800x600 16 color
                    dw  74h, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  60h, 0          ; 640x400 256 color
                    dw  61h, 0          ; 640x480 256 color
                    dw  62h, 0          ; 800x600 256 color
                    dw  0, 0            ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

AHEADBModes:        dw  71h, 0          ; 800x600 16 color
                    dw  74h, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  60h, 0          ; 640x400 256 color
                    dw  61h, 0          ; 640x480 256 color
                    dw  62h, 0          ; 800x600 256 color
                    dw  63h, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

CHIPSModes:         dw  70h, 0          ; 800x600 16 color
                    dw  72h, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  78h, 0          ; 640x400 256 color
                    dw  79h, 0          ; 640x480 256 color
                    dw  7Bh, 0          ; 800x600 256 color
                    dw  7Eh, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

EVEREXModes:        dw  70h, 02h        ; 800x600 16 color
                    dw  70h, 20h        ; 1024x768 16 color
                    dw  70h, 21h        ; 1280x1024 16 color
                    dw  70h, 13h        ; 640x350 256 color
                    dw  70h, 14h        ; 640x400 256 color
                    dw  70h, 30h        ; 640x480 256 color
                    dw  70h, 31h        ; 800x600 256 color
                    dw  70h, 32h        ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  70h, 62h        ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  70h, 71h        ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  70h, 77h        ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

GENOAModes:         dw  79h, 0          ; 800x600 16 color
                    dw  5Fh, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  5Bh, 0          ; 640x350 256 color
                    dw  7Eh, 0          ; 640x400 256 color
                    dw  5Ch, 0          ; 640x480 256 color
                    dw  5Eh, 0          ; 800x600 256 color
                    dw  0, 0            ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

OAKModes:           dw  52h, 0          ; 800x600 16 color
                    dw  56h, 0          ; 1024x768 16 color
                    dw  58h, 0          ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  0, 0            ; 640x400 256 color
                    dw  53h, 0          ; 640x480 256 color
                    dw  54h, 0          ; 800x600 256 color
                    dw  59h, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  5Bh, 0          ; 640x400 32k color
                    dw  5Ch, 0          ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

PARADISEModes:      dw  58h, 0          ; 800x600 16 color
                    dw  5Dh, 0          ; 1024x768 16 color
                    dw  64h, 0          ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  5Eh, 0          ; 640x400 256 color
                    dw  5Fh, 0          ; 640x480 256 color
                    dw  5Ch, 0          ; 800x600 256 color
                    dw  60h, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  62h, 0          ; 640x480 32k color
                    dw  63h, 0          ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

TRIDENT88Modes:     dw  5Bh, 0          ; 800x600 16 color
                    dw  5Fh, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  5Ch, 0          ; 640x400 256 color
                    dw  5Dh, 0          ; 640x480 256 color
                    dw  5Eh, 0          ; 800x600 256 color
                    dw  0, 0            ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

TRIDENT89Modes:     dw  5Bh, 0          ; 800x600 16 color
                    dw  5Fh, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  5Ch, 0          ; 640x400 256 color
                    dw  5Dh, 0          ; 640x480 256 color
                    dw  5Eh, 0          ; 800x600 256 color
                    dw  62h, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

VIDEO7Modes:        dw  6F05h, 62h      ; 800x600 16 color
                    dw  6F05h, 65h      ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  6F05h, 66h      ; 640x400 256 color
                    dw  6F05h, 67h      ; 640x480 256 color
                    dw  6F05h, 69h      ; 800x600 256 color
                    dw  6F05h, 6Ah      ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

ET3000Modes:        dw  29h, 0          ; 800x600 16 color
                    dw  37h, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  2Dh, 0          ; 640x350 256 color
                    dw  0, 0            ; 640x400 256 color
                    dw  2Eh, 0          ; 640x480 256 color
                    dw  30h, 0          ; 800x600 256 color
                    dw  0, 0            ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

ET4000Modes:        dw  29h, 0          ; 800x600 16 color
                    dw  37h, 0          ; 1024x768 16 color
                    dw  3Dh, 0          ; 1280x1024 16 color
                    dw  2Dh, 0          ; 640x350 256 color
                    dw  2Fh, 0          ; 640x400 256 color
                    dw  2Eh, 0          ; 640x480 256 color
                    dw  30h, 0          ; 800x600 256 color
                    dw  38h, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  10F0h, 13h      ; 320x200 32k color
                    dw  10F0h, 2Dh      ; 640x350 32k color
                    dw  10F0h, 2Fh      ; 640x400 32k color
                    dw  10F0h, 2Eh      ; 640x480 32k color
                    dw  10F0h, 30h      ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
ET4_640x350x16m:    dw  10F0h, 2DFFh    ; 640x350 16m color
ET4_640x400x16m:    dw  10F0h, 2FFFh    ; 640x400 16m color
ET4_640x480x16m:    dw  10F0h, 2EFFh    ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

NCRModes:           dw  58h, 0          ; 800x600 16 color
                    dw  5Dh, 0          ; 1024x768 16 color
                    dw  67h, 0          ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  5Eh, 0          ; 640x400 256 color
                    dw  5Fh, 0          ; 640x480 256 color
                    dw  5Ch, 0          ; 800x600 256 color
                    dw  61h, 0          ; 1024x768 256 color
                    dw  6Ah, 0          ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  71h, 0          ; 640x480 32k color
                    dw  72h, 0          ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

S3Modes:            dw  4F02h, 102h     ; 800x600 16 color
                    dw  4F02h, 104h     ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  0, 0            ; 640x400 256 color
                    dw  4F02h, 101h     ; 640x480 256 color
                    dw  4F02h, 103h     ; 800x600 256 color
                    dw  4F02h, 105h     ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  4F02h, 301h     ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

ACUMOSModes:        dw  58h, 0          ; 800x600 16 color
                    dw  5Dh, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  5Eh, 0          ; 640x400 256 color
                    dw  5Fh, 0          ; 640x480 256 color
                    dw  5Ch, 0          ; 800x600 256 color
                    dw  0, 0            ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

AL2101Modes:        dw  2Bh, 0          ; 800x600 16 color
                    dw  30h, 0          ; 1024x768 16 color
                    dw  36h, 0          ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  29h, 0          ; 640x400 256 color
                    dw  2Ah, 0          ; 640x480 256 color
                    dw  2Ch, 0          ; 800x600 256 color
                    dw  31h, 0          ; 1024x768 256 color
                    dw  37h, 0          ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

MXICModes:          dw  55h, 0          ; 800x600 16 color
                    dw  56h, 0          ; 1024x768 16 color
                    dw  0, 0            ; 1280x1024 16 color
                    dw  57h, 0          ; 640x350 256 color
                    dw  58h, 0          ; 640x400 256 color
                    dw  59h, 0          ; 640x480 256 color
                    dw  5Ah, 0          ; 800x600 256 color
                    dw  5Bh, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

P2000Modes:         dw  2Ah, 0          ; 800x600 16 color
                    dw  30h, 0          ; 1024x768 16 color
                    dw  36h, 0          ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  2Ch, 0          ; 640x400 256 color
                    dw  2Dh, 0          ; 640x480 256 color
                    dw  2Bh, 0          ; 800x600 256 color
                    dw  31h, 0          ; 1024x768 256 color
                    dw  37h, 0          ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  42h, 0          ; 640x350 32k color
                    dw  43h, 0          ; 640x400 32k color
                    dw  44h, 0          ; 640x480 32k color
                    dw  45h, 0          ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

RT3106Modes:        dw  1Fh, 0          ; 800x600 16 color
                    dw  21h, 0          ; 1024x768 16 color
                    dw  2Ah, 0          ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  25h, 0          ; 640x400 256 color
                    dw  26h, 0          ; 640x480 256 color
                    dw  27h, 0          ; 800x600 256 color
                    dw  28h, 0          ; 1024x768 256 color
                    dw  37h, 0          ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  0, 0            ; 640x480 32k color
                    dw  0, 0            ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  0, 0            ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  0, 0            ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

CirrusModes:        dw  58h, 0          ; 800x600 16 color
                    dw  5Dh, 0          ; 1024x768 16 color
                    dw  6Ch, 0          ; 1280x1024 16 color
                    dw  0, 0            ; 640x350 256 color
                    dw  0, 0            ; 640x400 256 color
                    dw  5Fh, 0          ; 640x480 256 color
                    dw  5Ch, 0          ; 800x600 256 color
                    dw  60h, 0          ; 1024x768 256 color
                    dw  0, 0            ; 1280x1024 256 color
                    dw  0, 0            ; 320x200 32k color
                    dw  0, 0            ; 640x350 32k color
                    dw  0, 0            ; 640x400 32k color
                    dw  66h, 0          ; 640x480 32k color
                    dw  67h, 0          ; 800x600 32k color
                    dw  0, 0            ; 1024x768 32k color
                    dw  0, 0            ; 1280x1024 32k color
                    dw  70h, 0          ; 320x200 16m color
                    dw  0, 0            ; 640x350 16m color
                    dw  0, 0            ; 640x400 16m color
                    dw  71h, 0          ; 640x480 16m color
                    dw  0, 0            ; 800x600 16m color
                    dw  0, 0            ; 1024x768 16m color
                    dw  0, 0            ; 1280x1024 16m color

;----------------------------------------------------------------------------
; loadSVGAMode  Loads AX and BX with values for the specified video mode
;----------------------------------------------------------------------------
;
; Looks up the appropriate values to place into AX and BX to set the
; specified video mode on the specified video adapter.
;
; Entry:        AX      - Video driver number
;               BX      - Video mode number
;
; Exit:         AX,BX   - Ready to call INT 10h to set the mode
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    loadSVGAMode

        cmp     bx,grVGA_320x200x256
        jle     @@VGAMode

; Mode is a SuperVGA video mode

        sub     ax,grSVGA           ; Relative to zero
        mov     cx,SVGAModeSize     ; CX := Size of video mode table
        mul     cx
        add     ax,offset SVGAModes ; AX -> start of video mode table
        sub     bx,grSVGA_800x600x16
        shl     bx,2
        add     bx,ax               ; BX -> video mode numbers to use
        jmp     @@LoadMode

; Mode is a standard VGA video mode

@@VGAMode:
        sub     bx,grEGA_320x200x16
        shl     bx,2                ; BX := mode * 4
        add     bx,offset VGAModes

@@LoadMode:
        mov     ax,[cs:bx]
        mov     bx,[cs:bx+2]
        ret

ENDP    loadSVGAMode
