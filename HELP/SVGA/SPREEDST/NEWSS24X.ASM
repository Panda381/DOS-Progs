;--------------------------------------------------------------------------
; This is file NEW24X.ASM
;
; Copyright (C) 1993 Denis Bos, Einsteinstr 37, 6533 NG
;                               Nijmegen, The Netherlands
;
; Just kidding about the copyright, but the adres is correct
;
; A friend of mine (actually a roomy) had the 'normal' version of
; this driver, but it didn't work for 24-bit, so I looked at a few
; drivers and the book (that came with the Speedstar 24x), and came
; up with this driver, which looks remarkebly the same as the 'nor-
; mal' version (ss24x.asm), but with an additional mode for 24-bit
;
; I hope it works with all the other modes as well, haven't had time
; to test them all (just most of the graphics-modes).
;
; This file is distributed WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. (??!)
;
; I added the 24-bit mode (mode 72h) support on 24-10-93
; Compiled with MASM it should work (it did on my computer)
;
; PS2: I removed the req_... stuff, because i didn't have any (include)
;    file in which was described what val_... was, but I don'd think those
;    modes are that important. 24-bit is!! (You probably can just add them
;    again..)  :-)
;--------------------------------------------------------------------------

	.386
include grdriver.inc
cseg    segment byte public use16 'code'
	assume  cs:cseg, ds:cseg, es:cseg, ss:nothing

;--------------------------------------------------------------------------
; DRIVER HEADER
;  The following entries MUST match the structure and constant
;  declarations in the file 'grdriver.h' of the GRX graphics library
;  The mode word should contain the following bitfields:
;     - the GRD_NEW_DRIVER bit set for any new format driver
;     - the adapter type field should be specified
;     - the memory size field should be specified
;     - the paging mode field should be specified
;  The mode set routine will OR in the plane bitfield as it will
;  change when different color number modes are requested.
;--------------------------------------------------------------------------

	dw      offset mode_set_routine
	dw      offset paging_routine
mode_W  dw      GRD_NEW_DRIVER+GRD_VGA+GRD_1024K+GRD_RW_64K
;
; The 'def_xx' fields are filled in by go32 from the corresponding
; fields of the 'GO32' environment variable
;
def_tw  dw      80              ; text width
def_th  dw      25              ; text height
def_gw  dw      640             ; graphics width
def_gh  dw      480             ; graphics height
def_nc  dw      16              ; graphics colors
	dw      offset driver_init_routine
	dw      offset text_mode_table
	dw      offset graphics_mode_table

;
; Biggest text and graphics sizes
;
Max_TW  equ     132
Max_TH  equ     50
Max_GWn equ     1024            ; non interlaced!!!
Max_GHn equ     768
Max_GW  equ     1280            ; may be interlaced
Max_GH  equ     1024

;--------------------------------------------------------------------------
; TABLE OF SUPPORTED TEXT MODES
;       - keep sorted by size
;       - end with an all 0 entry
;       - BIOS field = 0xff disables it
;       - fields:
;               width,  height, colors, BIOS#+  setup_procedure_index*256
;--------------------------------------------------------------------------
text_mode_table         label word
	dw      80,     25,     2,      007h +  00000h
	dw      40,     25,     16,     001h +  00000h
	dw      80,     25,     16,     003h +  00000h
	dw      80,     34,     16,     041h +  00000h
	dw      80,     43,     16,     067h +  00000h
	dw      80,     50,     16,     066h +  00000h
	dw      132,    25,     16,     055h +  00000h
	dw      132,    28,     16,     047h +  00000h
	dw      132,    43,     16,     054h +  00000h
	dw      132,    44,     16,     021h +  00000h
	dw      132,    50,     16,     069h +  00000h
	dw      0,      0,      0,      000h +  00000h

;--------------------------------------------------------------------------
; TABLE OF SUPPORTED GRAPHICS MODES
;       - keep sorted first by colors then by size
;       - end with an all 0 entry
;       - BIOS field = 0xff disables it
;       - fields:
;               width,  height, colors, BIOS#+  setup_procedure_index*256
;--------------------------------------------------------------------------
graphics_mode_table     label word
	dw      320,    200,    16,     00dh +  00000h
	dw      640,    200,    16,     00eh +  00000h
	dw      640,    350,    16,     010h +  00000h
	dw      640,    480,    16,     012h +  00000h
	dw      800,    600,    16,     058h +  00000h
	dw      1024,   768,    16,     05dh +  00000h
	dw      1280,   960,    16,     06ch +  00000h
	dw      1280,   1024,   16,     064h +  00000h
	
	dw      320,    200,    256,    013h +  00000h
	dw      640,    400,    256,    05eh +  00000h
	dw      640,    480,    256,    05fh +  00000h
	dw      800,    600,    256,    05ch +  00000h
	dw      1024,   768,    256,    060h +  00000h
	
	dw      640,    480,    32768,  062h +  00000h
	dw      800,    600,    32768,  063h +  00000h
	
	dw      640,    480,    0c018h, 072h +  00000h  ; The extra mode         
	
	dw      0,      0,      0,      000h +  00000h


;--------------------------------------------------------------------------
; TABLE OF SPECIAL SETUP PROCEDURES
;  You may need such procedures for:
;     -- reloading fonts on standard EGA or VGA for
;        higher resolution text modes
;     -- enable HiColor mode of some Super VGAs
;     -- Handle the parameter passing conventions of the VESA BIOS
;     -- put VGA into 256 color plane mode ("MODE X")
;     -- etc...
;  There should be one entry in the table for every non-zero
;  'setup_procedure_index' in the text and graphics mode tables.
;  The first entry in the table belongs to index 100h, and so on.
;  The special setup procedure is invoked via a near call.
;
;  Entry: DI=address of the mode record from the text or graphics
;         table to set up.
;
;  Exit:  Adapter configured
;         BX=driver mode word as it should be returned by the mode set
;            routine. Typically it involves picking up the mode word
;            from the header and OR-ing in the appropriate bitplane mode
;            bitfield. (This is not needed for text modes)
;         AX, CX, DX, SI can be trashed, PRESERVE DI!!!!
;
;  NOTE: This runs in real mode, but don't mess with the segment registers.
;--------------------------------------------------------------------------
special_setup_table     label word
	dw      offset  VGA_50row_mode_set
;
; Routine to set up VGA 50 row mode
; interface is described above
;
VGA_50row_mode_set      proc    near
	mov     ax,03h                  ; set 80x25 mode
	int     10h
	xor     bx,bx
	mov     ax,1112h                ; load 8x8 font
	int     10h
	ret
VGA_50row_mode_set      endp

;--------------------------------------------------------------------------
; DRIVER INIT ROUTINE
;  called once after the driver is loaded
;  may do one or more of the followings:
;    - check for proper board type
;    - check amount of RAM on board, and:
;       -- update word in header to reflect correct amount
;       -- disable modes in the tables for which there is not enough RAM
;    - check for special equipment (HiColor DAC, etc...)
;
;  Entry: nothing
;
;  Exit:  AX=status:
;          non-zero: OK,
;          0: something went wrong (e.g. wrong adapter, etc..)
;         BX,CX,DX may be trashed
;
;  NOTE: This runs in real mode, but don't mess with the segment registers.
;--------------------------------------------------------------------------
driver_init_routine     proc    far
	mov     dx,03ceh
	mov     ax,0e0bh
	out     dx,ax                   ; enable second bank register
	mov     dx,03c5h
	mov     ax,0ff11h               ; set bank registers for R/W banking
	out     dx,ax                   ;  at B000:0000 - B000:FFFF
	ret
driver_init_routine     endp

;--------------------------------------------------------------------------
; MODE SET ROUTINE
;  sets up a text or graphics mode as close as possible to the one
;  reguested by the user with regard to number of colors and size.
;
;  Entry: AX=mode selection
;     0 = 80x25 text
;     1 = default text
;     2 = text CX cols by DX rows
;     3 = biggest text
;     4 = 320x200 graphics
;     5 = default graphics
;     6 = graphics CX width by DX height
;     7 = biggest non-interlaced graphics
;     8 = biggest graphics
;     9 = graphics BX colors, CX width by DX height
;
;  Exit: BX=driver mode flag
;        CX=width (in pixels or characters)
;        DX=height
;
;  NOTE: This runs in real mode, but don't mess with the segment registers.
;        YOU SHOULD NOT NEED TO CHANGE THIS ROUTINE AS IT IS PRETTY
;        MUCH TABLE DRIVEN
;--------------------------------------------------------------------------
mode_set_routine        proc    far
	push    ds
	push    di
	push    si
	mov     si,cs
	mov     ds,si
	cmp     ax,9
	jbe     DoIt
	jmp     Exit
DoIt:   add     ax,ax
	mov     si,ax
	jmp     WORD PTR mode_set_table[si]
mode_set_table  label   word
	dw      offset mode_0
	dw      offset mode_1
	dw      offset mode_2
	dw      offset mode_3
	dw      offset mode_4
	dw      offset mode_5
	dw      offset mode_6
	dw      offset mode_7
	dw      offset mode_8
	dw      offset mode_9
mode_0: mov     si,offset text_mode_table       ; 80x25 text
	mov     bx,def_nc
	mov     cx,80
	mov     dx,25
	jmp     Lookup
mode_1: mov     si,offset text_mode_table       ; default text
	mov     bx,def_nc
	mov     cx,def_tw
	mov     dx,def_th
	jmp     Lookup
mode_2: mov     si,offset text_mode_table       ; CX*DX text
	mov     bx,def_nc
	jmp     Lookup
mode_3: mov     si,offset text_mode_table       ; biggest text
	mov     bx,def_nc
	mov     cx,Max_TW
	mov     dx,Max_TH
	jmp     Lookup
mode_4: mov     si,offset graphics_mode_table   ; 320x200 graphics
	mov     bx,def_nc
	mov     cx,320
	mov     dx,200
	jmp     Lookup
mode_5: mov     si,offset graphics_mode_table   ; default graphics
	mov     bx,def_nc
	mov     cx,def_gw
	mov     dx,def_gh
	jmp     Lookup
mode_6: mov     si,offset graphics_mode_table   ; CX*DX graphics
	mov     bx,def_nc
	jmp     Lookup
mode_7: mov     si,offset graphics_mode_table   ; biggest non-interlaced gr
	mov     bx,def_nc
	mov     cx,Max_GWn
	mov     dx,Max_GHn
	jmp     Lookup
mode_8: mov     si,offset graphics_mode_table   ; biggest graphics
	mov     bx,def_nc
	mov     cx,Max_GW
	mov     dx,Max_GH
	jmp     Lookup
mode_9: mov     si,offset graphics_mode_table   ; CX*DX graphics w/ BX colors
;
; At this point:
;   SI points to the table to search (text or graphics)
;   BX has colors
;   CX has width
;   DX has height
;
Lookup: xor     ax,ax                           ; last color number seen
Find_C: cmp     [si+4],ax                       ; last color number == this?
	je      Same_C
	jb      Prev_C                          ; end of table -- use last color
	cmp     BYTE PTR [si+6],0ffh            ; valid entry ?
	je      Prev_C                          ; not -- use last color
	mov     ax,[si+4]                       ; record color number
	mov     di,si                           ; start of entries w/ this color
	cmp     ax,bx                           ; enough colors ?
	jae     Find_S
Same_C: add     si,8
	jmp     Find_C
Prev_C: or      ax,ax                           ; found any color at all?
	je      Exit
;
; At this point:
;   DI points into the table to the first entry with the desired color
;      number (either it has enough colors or it is the highest color
;      number supported by the driver). Additionally, at least the
;      first (= smallest size) entry for this color is valid (has a
;      valid BIOS number).
;   AX has the color number adjusted for the driver
;   CX has width
;   DX has height
;
Find_S: cmp     [di+4],ax                       ; still the same color #?
	jne     Prev_S
	cmp     BYTE PTR [di+6],0ffh            ; valid entry ?
	je      Prev_S
	cmp     [di],cx
	jb      Next_S
	cmp     [di+2],dx
	jae     GotIt
Next_S: add     di,8
	jmp     Find_S
Prev_S: sub     di,8
;
; At this point:
;   DI points to the table entry we want to set up
;
GotIt:  mov     ax,[di+6]                       ; BIOS mode number
	or      ah,ah                           ; special ?
	je      doBIOS
	mov     al,ah
	xor     ah,ah
	dec     ax
	add     ax,ax
	mov     si,ax
	call    WORD PTR special_setup_table[si]
	jmp     RetVal
doBIOS: int     10h
	mov     bx,GRD_1_PLANE
	cmp     WORD PTR [di+4],2               ; 2 colors ?
	je      doFLAG
	mov     bx,GRD_4_PLANES
	cmp     WORD PTR [di+4],16              ; 16 colors ?
	je      doFLAG
	mov     bx,GRD_8_PLANES
	cmp     WORD PTR [di+4],256             ; 256 colors ?
	je      doFLAG
	mov     bx,GRD_16_PLANES
	cmp     WORD PTR [di+4],32768           ; 32K colors ?
	je      doFLAG
	mov     bx,GRD_24_PLANES
	cmp     WORD PTR [di+4],0c018h          ; 16M colors ?
	je      doFLAG
	mov     bx,GRD_PLANE_MASK               ; something is wrong!!
doFLAG: or      bx,mode_W
RetVal: mov     cx,[di]
	mov     dx,[di+2]
Exit:   pop     si
	pop     di
	pop     ds
	ret
mode_set_routine        endp

;--------------------------------------------------------------------------
; PAGING ROUTINE
;
;  Entry: AH=read page
;         AL=write page
;
;  Exit: VGA configured.
;        AX,BX,CX,DX,SI,DI may be trashed
;
;  NOTE: This runs in protected mode!  Don't mess with the segment registers!
;        This code must be relocatable and may not reference any data!
;--------------------------------------------------------------------------
	assume  ds:nothing, es:nothing

paging_routine  proc    far
	mov     cl,4
	shl     ah,cl ; WD90C3x offset registers have 4k granularity
	shl     al,cl ; => multiply by 16 to get normal VGA 64k bank granularity
	mov     bh,al
	mov     bl,0ah                  ; write bank gets PR0B index code
	mov     al,09h                  ; read bank gets PR0A index code
	mov     dx,03ceh                ; load graphics index register number
	out     dx,ax                   ; set PR0A (read bank)
	mov     ax,bx
	out     dx,ax                   ; set PR0B (write bank)
	ret
paging_routine  endp


cseg    ends
	end


