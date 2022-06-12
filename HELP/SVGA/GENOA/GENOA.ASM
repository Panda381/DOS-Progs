; This is file c:\djgpp\drivers\genoa.asm
;
; Copyright (C) 1991 DJ Delorie, 24 Kirsten Ave, Rochester NH 03867-2954
;
; This file is distributed under the terms listed in the document
; "copying.dj", available from DJ Delorie at the address above.
; A copy of "copying.dj" should accompany this file; if not, a copy
; should be available from where this file was obtained.  This file
; may not be distributed without a verbatim copy of "copying.dj".
;
; This file is distributed WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;

; Adaption to Genoa Series 6000 SVGA by D. Wilmer 04-Jun-1991

cseg    segment byte public 'code'
        assume  cs:cseg, ds:cseg, es:cseg, ss:nothing

        dw      offset init_routine
        dw      offset paging_routine
        dw      1       ; set to 1 if separate read & write windows or
                        ; only 64K of video RAM (ie: no paging)

def_tw  dw      80      ; filled in by go32 if GO32 env. var. is set
def_th  dw      25
def_gw  dw      640
def_gh  dw      480

;--------------------------------------------------------------------------
; Entry: AX=mode selection
;               0=80x25 text
;               1=default text
;               2=text CX cols by DX rows
;               3=biggest text
;               4=320x200 graphics
;               5=default graphics
;               6=graphics CX width by DX height
;               7=biggest non-interlaced graphics
;               8=biggest graphics
;
; NOTE: This runs in real mode, but don't mess with the segment registers.
;
; Exit:  CX=width (in pixels or characters)
;        DX=height

init_table      label   word
        dw      offset init_0
        dw      offset init_1
        dw      offset init_2
        dw      offset init_3
        dw      offset init_4
        dw      offset init_5
        dw      offset init_6
        dw      offset init_7
        dw      offset init_8

init_routine    proc    far
        cmp     ax,8
        jbe     valid_req
        ret
valid_req:
        shl     ax,1
        mov     bx,ax
        jmp     init_table[bx]

init_0: ; 80x25 text
        mov     ax,3
        int     10h
        mov     cx,80
        mov     dx,25
        ret

init_1: ; default text
        mov    cx,def_tw
        mov     dx,def_th
        jmp     init_2

init_2_table    label   word
        dw      01h, 40, 25
        dw      03h, 80, 25
        dw      60h, 132, 25
        dw      61h, 132, 29
        dw      62h, 132, 32
        dw      63h, 132, 44
        dw      64h, 132, 60
init_2_tend     label   word

init_2: ; CX*DX text
        mov     si,offset init_2_table
init_2a:
        cmp     [si+2],cx
        jb      init_2b
        cmp     [si+4],dx
        jb      init_2b
        ; got a big enough one!
        jmp     init_2c
init_2b:
        cmp     si,offset init_2_tend - 6
        je      init_2c
        add     si,6
        jmp     init_2a
init_2c:
        mov     ax,[si]
        push    si
        int     10h
        pop     si
        mov     cx,[si+2]
        mov     dx,[si+4]
        ret

init_3: ; biggest text
        mov     ax,[init_2_tend-6]
        int     10h
        mov     cx,[init_2_tend-4]
        mov     dx,[init_2_tend-2]
        ret

init_4: ; 320x200 graphics
        mov     ax,13h
        int     10h
        mov     cx,320
        mov     dx,200
        ret

init_5: ; default graphics - should be 640x480 if supported
        mov     cx,def_gw
        mov     dx,def_gh
        jmp     init_6

init_6_table    label   word
        dw      13h, 320, 200
        dw      5Ch, 640, 480
        dw      6Ch, 800, 600
init_6_tend     label   word

init_6: ; CX*DX graphics
        mov     si,offset init_6_table
init_6a:
        cmp     [si+2],cx
        jb      init_6b
        cmp     [si+4],dx
        jb      init_6b
        ; got a big enough one!
        jmp     init_6c
init_6b:
        cmp     si,offset init_6_tend - 6
        je      init_6c
        add     si,6
        jmp     init_6a
init_6c:
        mov     ax,[si]
        push    si
        int     10h
        pop     si
        mov     cx,[si+2]
        mov     dx,[si+4]
        ret

init_7: ; biggest non-interlaced graphics
        mov     ax,6Ch
        int     10h
        mov     cx,800
        mov     dx,600
        ret

init_8: ; biggest graphics
        mov     ax,6Ch
        int     10h
        mov     cx,800
        mov     dx,600
        ret

init_routine	endp

;--------------------------------------------------------------------------
; Entry: AH=read page
;        AL=write page
;
; NOTE: This runs in protected mode!  Don't mess with the segment registers!
; This code must be relocatable and may not reference any data!
;
; Exit: VGA configured.
;       AX,BX,CX,DX,SI,DI may be trashed

        assume  ds:nothing, es:nothing

; 24-May-1991 D. Wilmer
; Genoa 6000 series bank switching:
; issue the following byte  x1wwwrrr (binary)
; with      x: Don't care
;           1: Don't change
;           w: 3-bit write segment
;           r: 3-bit read segment
;
; to the port 3c5.06 (memory select register)

paging_routine  proc    far
        .386
        shl     al,3
        or      ah,al
        or      ah,40h
        mov     al,6
        mov     dx,3C4h
        out     dx,ax
        ret
paging_routine  endp

;--------------------------------------------------------------------------

cseg    ends
        end
