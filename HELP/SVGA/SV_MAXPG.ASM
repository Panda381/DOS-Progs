;****************************************************************************
;*
;*                      MegaGraph Graphics Library
;*
;*          Copyright (C) 1993 Kendall Bennett.
;*                          All rights reserved.
;*
;* Filename:    $RCSfile: sv_maxpg.asm $
;* Version:     $Revision: 1.2 $
;*
;* Language:    80386 Assembler
;* Environment: IBM PC (MS DOS)
;*
;* Description: Module to compute the maximum number of available video
;*              pages for specific video mode.
;*
;* $Id: sv_maxpg.asm 1.2 1993/03/07 04:04:13 kjb Exp $
;*
;* Revision History:
;* -----------------
;*
;* $Log: sv_maxpg.asm $
;* Revision 1.2  1993/03/07  04:04:13  kjb
;* Bug fixes.
;*
;* Revision 1.1  1993/03/03  10:46:57  kjb
;* Initial revision
;*
;****************************************************************************

; Table of standard video mode information (bytesPerLine,
; vertical resolution and number of colors) used to compute the number of
; pages and page size for the specified video mode. This table can be
; modified at initialisation time for video cards that have non-standard
; bytes per line values (S3 cards and VESA cards).

PageInfo:       dw  grEGA_320x200x16,       40, 200
                dw  grEGA_640x200x16,       80, 200
                dw  grEGA_640x350x16,       80, 350
                dw  grVGA_640x400x16,       80, 400
                dw  grVGA_640x480x16,       80, 480
                dw  grSVGA_800x600x16,      100, 600
                dw  grSVGA_1024x768x16,     128, 768
                dw  grSVGA_1280x1024x16,    160, 1024
                dw  grVGA_320x200x256,      320, 200
                dw  grSVGA_640x350x256,     640, 350
                dw  grSVGA_640x400x256,     640, 400
                dw  grSVGA_640x480x256,     640, 480
                dw  grSVGA_800x600x256,     800, 600
                dw  grSVGA_1024x768x256,    1024, 768
                dw  grSVGA_1280x1024x256,   1280, 1024
                dw  grSVGA_320x200x32k,     640, 200
                dw  grSVGA_640x350x32k,     1280, 350
                dw  grSVGA_640x400x32k,     1280, 400
                dw  grSVGA_640x480x32k,     1280, 480
                dw  grSVGA_800x600x32k,     1600, 600
                dw  grSVGA_1024x768x32k,    2048, 768
                dw  grSVGA_1280x1024x32k,   2560, 1024
                dw  grSVGA_320x200x16m, 960, 200
                dw  grSVGA_640x350x16m,     1920, 350
                dw  grSVGA_640x400x16m,     1920, 400
                dw  grSVGA_640x480x16m,     1920, 480
                dw  grSVGA_800x600x16m,     2400, 600
                dw  grSVGA_1024x768x16m,    3072, 768
                dw  grSVGA_1280x1024x16m,   3840, 1024
                dw  -1

;----------------------------------------------------------------------------
; numPages
;----------------------------------------------------------------------------
;
; Computes the number of pages in a specified video mode
;
; Entry:        AX      - Video mode number
;               EBX     - Video memory size
;
; Exit:         AX      - Number of video pages
;               EBX     - Page size for video mode
;               CX      - BytesPerLine value
;
; Registers:    EAX,EBX,ECX,EDX
;
;----------------------------------------------------------------------------
PROC    numPages

        mov     edx,ebx             ; EDX := video memory size
        mov     bx,offset PageInfo - 6

@@FindMode:
        add     bx,6
        mov     cx,[WORD cs:bx]
        cmp     cx,-1
        je      @@NotFound
        cmp     cx,ax
        jne     @@FindMode          ; Loop till desired mode is found

        push    edx
        xor     eax,eax
        mov     ax,[WORD cs:bx+2]
        mul     [WORD cs:bx+4]      ; DX:AX := bytesPerLine * yres
        shl     edx,16
        or      eax,edx             ; EAX := bytesPerLine * yre
        pop     edx

        cmp     cx,grSVGA_640x350x256
        jge     @@Colors256
        cmp     cx,grVGA_320x200x256
        je      @@Colors256

; We have a 16 color video mode. We round up the page size depending on
; how large it is, either to 8k, 16k, 32k or 64k boundaries.

@@Colors16:
        shr     edx,2               ; EDX := video memory / 4
        add     eax,1FFFh           ; Round to next 8k
        and     eax,0FFFFE000h
        cmp     eax,2000h           ; Page size = 8k?
        je      @@Done              ; Yes, we are done
        add     eax,3FFFh           ; Round to next 16k
        and     eax,0FFFFC000h
        cmp     eax,4000h           ; Page size = 16k?
        je      @@Done              ; Yes, we are done
        add     eax,7FFFh           ; Round to next 32k
        and     eax,0FFFF8000h
        cmp     eax,8000h           ; Page size = 32k?
        je      @@Done              ; Yes, we are done

; We have a 16 color video mode with > 64k per page, or a 256, 32k or
; 16 million color video mode. We thus ensure that the video page size is
; rounded up to the nearest 64k, to ensure pages always begin on bank
; boundaries.

@@Colors256:
        add     eax,0FFFFh          ; Round to next 64k
        and     eax,0FFFF0000h

@@Done:
        mov     cx,[WORD cs:bx+2]   ; Load bytes per line value
        mov     ebx,eax             ; EBX := video page size
        mov     eax,edx
        xor     edx,edx             ; EDX:EAX := video memory size
        div     ebx                 ; EAX := number of video pages
        ret

@@NotFound:
        xor     ax,ax
        xor     ebx,ebx
        ret

ENDP    numPages

;----------------------------------------------------------------------------
; setBytesPerLine
;----------------------------------------------------------------------------
;
; Changes the bytesPerLine value for a specified video mode.
;
; Entry:        AX      - Video mode number
;               BX      - New bytes per line value
;
; Exit:         BX      - New bytes per line value
;
; Registers:    AX,BX
;
;----------------------------------------------------------------------------
PROC    setBytesPerLine

        push    cx
        push    dx
        mov     dx,bx               ; BX := new bytesPerLine value
        mov     bx,offset PageInfo - 6

@@FindMode:
        add     bx,6
        mov     cx,[WORD cs:bx]
        cmp     cx,-1
        je      @@NotFound
        cmp     cx,ax
        jne     @@FindMode          ; Loop till desired mode is found

; Change the bytesPerLine value for the mode.
;
; Some VESA Video BIOS's are screwed and return invalid values for the
; bytes per line (Such as S3 based boards like the STB WIND/X). Generally
; they give us half the expected value, which is naturally less than the
; amount that is _physically_ required for the mode to operate. If this
; is the case we double the specified value :-)

        cmp     dx,[WORD cs:bx+2]
        jge     @@1
        shl     dx,1                ; Value is too small, so double it!
@@1:    mov     [WORD cs:bx+2],dx
        mov     bx,dx               ; Restore value in BX

@@NotFound:
        pop     dx
        pop     cx
        ret

ENDP    setBytesPerLine

;----------------------------------------------------------------------------
; checkVESAPageFlip
;----------------------------------------------------------------------------
;
; Checks to see if the VESA board supports extended page flipping.
;
; Exit:         carry   - Clear if VESA page flipping is supported
;
; Registers:    AX,BX,CX,DX
;
;----------------------------------------------------------------------------
PROC    checkVESAPageFlip

        mov     ax,4F07h            ; Set display start service
        xor     bx,bx               ; BH := 0, BL := 0 (set display start)
        xor     cx,cx               ; Left most pixel in line
        xor     dx,dx               ; First displayed scan line
        int     10h
        cmp     al,4Fh
        jne     @@Invalid           ; Function not supported, no page flip
        or      ah,ah
        jnz     @@Invalid           ; Function not successful, no page flip

        mov     ax,4F07h            ; Get display start service
        mov     bx,1                ; BH := 0, BL := 1 (get display start)
        int     10h
        cmp     al,4Fh
        jne     @@Invalid           ; Function not supported, no page flip
        or      ah,ah
        jnz     @@Invalid           ; Function not successful, no page flip
        or      bh,bh
        jnz     @@Invalid           ; BH should be zero if supported also
        or      cx,cx
        jnz     @@Invalid           ; CX should be zero (from above call)
        or      dx,dx
        jnz     @@Invalid           ; DX should be zero (from above call)

; Horrah! We have page flipping on a VESA board.

        clc
        ret

@@Invalid:
        stc
        ret

ENDP    checkVESAPageFlip

;----------------------------------------------------------------------------
; GetVESABytesPerLine   - Gets the VESA bytes per line value for a mode
;----------------------------------------------------------------------------
;
; Calls a VESA compatible BIOS to get the bytes per line value for a mode,
; and updates the internal tables accordingly.
;
; Entry:        AX      - MGL Mode number
;               CX      - VESA Mode Number
;
; Registers:    None.
;
;----------------------------------------------------------------------------
PROC    GetVESABytesPerLine

        pusha

        push    ax
        push    cs
        pop     es
        mov     di,offset VesaBuf   ; ES:DI -> Buffer for VESA info
        mov     ax,4F01h
        int     10h                 ; Call the video BIOS to get info
        pop     bx
        cmp     ax,004Fh
        jne     @@Exit              ; Call failed

        mov     ax,bx
        mov     bx,[WORD VesaBuf+16]
        call    setBytesPerLine

@@Exit: popa
        ret

ENDP    GetVESABytesPerLine

;----------------------------------------------------------------------------
; ModifyS3BytesPerLine  - Modifies the BytesPerLine for S3 cards.
;----------------------------------------------------------------------------
PROC    ModifyS3BytesPerLine

        mov     ax,grSVGA_800x600x16
        mov     cx,102h
        call    GetVESABytesPerLine
        mov     ax,grSVGA_1024x768x16
        mov     cx,104h
        call    GetVESABytesPerLine
        mov     ax,grSVGA_640x480x256
        mov     cx,101h
        call    GetVESABytesPerLine
        mov     ax,grSVGA_800x600x256
        mov     cx,103h
        call    GetVESABytesPerLine
        mov     ax,grSVGA_1024x768x256
        mov     cx,105h
        call    GetVESABytesPerLine
        mov     ax,grSVGA_640x480x32k
        mov     bx,2048
        call    setBytesPerLine
        ret

ENDP    ModifyS3BytesPerLine
