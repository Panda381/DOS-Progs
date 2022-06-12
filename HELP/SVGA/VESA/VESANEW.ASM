;--------------------------------------------------------------------------
; This is file VESA0.ASM
;
; Copyright (C) 1991 DJ Delorie, 24 Kirsten Ave, Rochester NH 03867-2954
; Copyright (C) 1992 Csaba Biegl, 820 Stirrup Dr, Nashville, TN 37221
; Copyright (C) 1993 Grzegorz Mazur, gbm@ii.pw.edu.pl
;
; This file is distributed under the terms listed in the document
; "copying.dj", available from DJ Delorie at the address above.
; A copy of "copying.dj" should accompany this file; if not, a copy
; should be available from where this file was obtained.  This file
; may not be distributed without a verbatim copy of "copying.dj".
;
; This file is distributed WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;--------------------------------------------------------------------------

	.386
include grdriver.inc
cseg	segment use16 byte public 'code'
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

	dw	offset mode_set_routine
	dw	offset paging_routine
mode_W  dw	GRD_VESA_DRIVER+GRD_VGA+GRD_1024K
;
; The 'def_xx' fields are filled in by go32 from the corresponding
; fields of the 'GO32' environment variable
;
def_tw  dw	80		; text width
def_th  dw	25		; text height
def_gw  dw	640		; graphics width
def_gh  dw	480		; graphics height
def_nc  dw	256		; graphics colors
	dw	offset driver_init_routine
	dw	offset text_mode_table
	dw	offset graphics_mode_table

;
; Biggest text and graphics sizes
;
Max_TW  equ	132
Max_TH  equ	43
Max_GWn equ	800		; non interlaced!!!
Max_GHn equ	600
Max_GW  equ	1024		; may be interlaced
Max_GH  equ	768


;--------------------------------------------------------------------------
; TABLE OF SUPPORTED TEXT MODES
;	- keep sorted by size
;	- end with an all 0 entry
;	- BIOS field = 0xff disables it
;	- fields:
;		width,  height, colors, BIOS#+  setup_procedure_index*256
; COLORS:
;	for modes with > 32768 colors, the value in color field
;	is equal to no. of active bits per pixel + 0c000h
; MODE #:
;	it is either basic mode no (< 80h) or VESA mode (>= 100h)
;	if special setup is needed after basic modeset call,
;	the mode number is ORed with (setup_procedure_index << 12)
;--------------------------------------------------------------------------
text_mode_table	   	label word
; standard VGA modes
	dw	80,	25,	2,	007h
	dw	40,	25,	16,	001h
	dw	80,	25,	16,	003h
	dw	80,	50,	16,	003h +  01000h
text_mode_check	label	word
; VESA mode
	dw	80,	60,	16,	108h
; XGA mode
;	dw	132,	25,	16,	014h
; VESA modes
	dw	132,	25,	16,	109h
	dw	132,	43,	16,	10ah
	dw	132,	50,	16,	10bh
	dw	132,	60,	16,	10ch
	dw	0,	0,	0,	000h


;--------------------------------------------------------------------------
; TABLE OF SUPPORTED GRAPHICS MODES
;	- keep sorted first by colors then by size
;	- end with an all 0 entry
;	- BIOS field = 0xff disables it
;	- fields:
;		width,  height, colors, mode#
; COLORS:
;	for modes with > 32768 colors, the value in color field
;	is equal to no. of active bits per pixel + 0c000h
; MODE #:
;	it is either basic mode no (< 80h) or VESA mode (>= 100h)
;	if special setup is needed after basic modeset call,
;	the mode number is ORed with (setup_procedure_index << 12)
;--------------------------------------------------------------------------
graphics_mode_table	label word
	dw	320,	200,	16,	00dh +  00000h
	dw	640,	200,	16,	00eh +  00000h
	dw	640,	350,	16,	010h +  00000h
	dw	640,	480,	16,	012h +  00000h
graphics_mode_check	label	word
	dw	800,	600,	16,	102h
	dw	1024,	768,	16,	104h
	dw	1280,	1024,	16,	106h

	dw	320,	200,	256,	013h
        dw	640,	350,	256,	11ch
	dw	640,	400,	256,	100h
	dw	640,	480,	256,	101h
	dw	800,	600,	256,	103h
	dw	1024,	768,	256,	105h
        dw	1280,	1024,	256,	107h

	dw	320,	200,	32768,	10dh
	dw	512,	480,	32768,	170h	; Trident
        dw	640,	350,	32768,	11dh
        dw	640,	400,	32768,	11eh
	dw	640,	480,	32768,	110h
	dw	800,	600,	32768,	113h
        dw	1024,	768,	32768,	116h
        dw	1280,	1024,	32768,	119h

	dw	320,	200,	0c010h,	10eh
	dw	512,	480,	0c010h,	171h	; Trident
        dw	640,	350,	0c010h,	11fh
        dw	640,	400,	0c010h,	120h
	dw	640,	480,	0c010h,	111h
	dw	800,	600,	0c010h,	114h
        dw	1024,	768,	0c010h,	117h
        dw	1280,	1024,	0c010h,	11ah

	dw	320,	200,	0c018h,	10fh
        dw	640,	350,	0c018h,	121h
        dw	640,	400,	0c018h,	122h
	dw	640,	480,	0c018h,	112h
	dw	800,	600,	0c018h,	115h
        dw	1024,	768,	0c018h,	118h
        dw	1280,	1024,	0c018h,	11bh

	dw	0,	0,	0,	0


;--------------------------------------------------------------------------
; TABLE OF SPECIAL SETUP PROCEDURES
;  You may need such procedures for:
;     -- reloading fonts on standard EGA or VGA for
;	 higher resolution text modes
;     -- etc...
;  There should be one entry in the table for every non-zero
;  'setup_procedure_index' in the text and graphics mode tables.
;  The first entry in the table belongs to index 1, and so on.
;  The special setup procedure is invoked via a near call.
;
;  Entry: DI=address of the mode record from the text or graphics
;	  table to set up.
;
;  Exit:  Adapter configured
;	  BX=driver mode word as it should be returned by the mode set
;	     routine. Typically it involves picking up the mode word
;	     from the header and OR-ing in the appropriate bitplane mode
;	     bitfield. (This is not needed for text modes)
;	  AX, CX, DX, SI can be trashed, PRESERVE DI!!!!
;
;  NOTE: This runs in real mode, but don't mess with the segment registers.
;--------------------------------------------------------------------------
special_setup_table	label word
	dw	offset  VGA_50row_mode_set

;
; Routine to set up VGA 50 row mode
; interface is described above
;
VGA_50row_mode_set 	proc	near
	mov	ax,03h			; set 80x25 mode
	int	10h
	xor	bx,bx
	mov	ax,1112h		; load 8x8 font
	int	10h
	ret
VGA_50row_mode_set    	endp

;--------------------------------------------------------------------------
; DRIVER INIT ROUTINE
;  called once after the driver is loaded
;  may do one or more of the followings:
;    - check for proper board type
;    - check amount of RAM on board, and:
;	-- update word in header to reflect correct amount
;	-- disable modes in the tables for which there is not enough RAM
;    - check for special equipment (HiColor DAC, etc...)
;
;  Entry: nothing
;
;  Exit:  AX=status:
;	   non-zero: OK,
;	   0: something went wrong (e.g. wrong adapter, etc..)
;	  BX,CX,DX may be trashed
;
;  NOTE: This runs in real mode, but don't mess with the segment registers.
;--------------------------------------------------------------------------
driver_init_routine	proc	far
	push	es
	push	si
	push	di
	push	bp
	mov	bp, sp
	mov	ax, ss
	mov	es, ax
	sub	sp, 256		; make space for VESA info
	mov	di, sp
	mov	ax, 4f00h	; call VESA info with es:di @buffer
	int	10h
	cmp	ax, 4fh
	jne	di_error
	mov	bx, sp
	cmp	word ptr ss:[bx], 'EV'
	jne	di_error
	cmp	word ptr ss:[bx + 2], 'AS'
	jne	di_error
	; OK, it is VESA - now check available modes
	les	bx, ss:[bx + 14]	; get pointer to video mode table
		mov	si, offset text_mode_check + 6
di_ms00:	mov   	ax, word ptr [si]  	; load mode no into ax
		cmp	ax, 0		   	; end of table ?
		je	di_ms1a
		; check if vesa mode valid
		mov	di, bx
di_ms01:	cmp	word ptr es:[di], 0ffffh
		je	di_ms08		   	; end of vesa mode table
		cmp	ax, word ptr es:[di]
		je	di_ms09		; mode is valid
		add	di, 2
		jmp	di_ms01
di_ms08:	; mode not found in vesa modes table
		mov	byte ptr [si], 0ffh
di_ms09:	add	si, 8		; get next mode
		jmp	di_ms00
di_ms1a:	mov	si, offset graphics_mode_check + 6
di_ms10:	mov	ax, word ptr [si]  	; load mode no into ax
		cmp	ax, 0		   	; end of table ?
		je    	di_ms20
		cmp	ax, 100h	   	; is vesa mode ?
		jb	di_ms19		   	; no, assume valid
		; check if vesa mode valid
		mov	di, bx
di_ms11:	cmp	word ptr es:[di], 0ffffh
		je	di_ms18		   	; end of vesa mode table
		cmp	ax, word ptr es:[di]
		je	di_ms19		; mode is valid
		add	di, 2
		jmp	di_ms11
di_ms18:	; mode not found in vesa modes table
		mov	byte ptr [si], 0ffh
di_ms19:	add	si, 8		; get next mode
		jmp	di_ms10
di_ms20:	; modes checked

		; Extra check for special DAC
		; This is needed because some BIOSes do not check
		; the type of DAC, and enable HiColor modes even
		; if no HiColor DAC is present.
if 0
    		mov	dx, 3c6h	; load DAC address
    		cli
    		mov   	al, 0ffh
    		out	dx, al
    		in	al, dx	; read four times
    		in	al, dx
    		in	al, dx
    		in	al, dx
    		mov	ah, al
    		in	al, dx	; fifth read - can be from hidden reg
    		sti
    		cmp	al, ah
    		jne	di_ms30		; jump if Hidden register present
    		; if we got here, no special DAC is installed
    		; - disable direct color modes
     		mov	si, offset graphics_mode_table + 6
di_ms22:	mov	ax, [si]
    		cmp	ax, 0
    		je	di_ms30		; end of mode table
    		cmp	ax, 10eh	; check if direct color
    		jb    	di_ms29
    		cmp	ax, 171h
    		ja	di_ms29
    		mov   	byte ptr [si], 0ffh	; direct color mode - disable
di_ms29:	add	si, 8
    		jmp	di_ms22
endif

di_ms30:
     	mov	ax,1
di_exit:
     	leave
     	pop	di
     	pop	si
     	pop	es
     	ret
di_error:
     	xor	ax, ax
     	jmp	di_exit
driver_init_routine	endp

; Page switch granularity
pg_gran	dw	0
pg_off	dw	0
pg_seg	dw	0



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
;	 CX=width (in pixels or characters)
;	 DX=height
; Following added for VESA driver:
;	AX = page granularity
;	SI = line offset
;	DI = page switching routine offset
;	ES = page switching routine segment
;
;  NOTE: This runs in real mode, but don't mess with the segment registers.
;	 YOU SHOULD NOT NEED TO CHANGE THIS ROUTINE AS IT IS PRETTY
;	 MUCH TABLE DRIVEN
;--------------------------------------------------------------------------
mode_set_routine	proc	far
	push	ds
	mov	si,cs
	mov	ds,si
	cmp	ax,9
	jbe	DoIt
	jmp	Exit
DoIt:	add	ax,ax
	mov	si,ax
	jmp	WORD PTR mode_set_table[si]
mode_set_table  label	word
	dw	offset mode_0
	dw	offset mode_1
	dw	offset mode_2
	dw	offset mode_3
	dw	offset mode_4
	dw	offset mode_5
	dw	offset mode_6
	dw	offset mode_7
	dw	offset mode_8
	dw	offset mode_9
mode_0: mov	si,offset text_mode_table	; 80x25 text
	mov	bx,def_nc
	mov	cx,80
	mov	dx,25
	jmp	Lookup
mode_1: mov	si,offset text_mode_table	; default text
	mov	bx,def_nc
	mov	cx,def_tw
	mov	dx,def_th
	jmp	Lookup
mode_2: mov	si,offset text_mode_table	; CX*DX text
	mov	bx,def_nc
	jmp	Lookup
mode_3: mov	si,offset text_mode_table	; biggest text
	mov	bx,def_nc
	mov	cx,Max_TW
	mov	dx,Max_TH
	jmp	Lookup
mode_4: mov	si,offset graphics_mode_table	; 320x200 graphics
	mov	bx,def_nc
	mov	cx,320
	mov	dx,200
	jmp	Lookup
mode_5: mov	si,offset graphics_mode_table	; default graphics
	mov	bx,def_nc
	mov	cx,def_gw
	mov	dx,def_gh
	jmp	Lookup
mode_6: mov	si,offset graphics_mode_table	; CX*DX graphics
	mov	bx,def_nc
	jmp	Lookup
mode_7: mov	si,offset graphics_mode_table	; biggest non-interlaced gr
	mov	bx,def_nc
	mov	cx,Max_GWn
	mov	dx,Max_GHn
	jmp	Lookup
mode_8: mov	si,offset graphics_mode_table	; biggest graphics
	mov	bx,def_nc
	mov	cx,Max_GW
	mov	dx,Max_GH
	jmp	Lookup
mode_9: mov	si,offset graphics_mode_table	; CX*DX graphics w/ BX colors
;
; At this point:
;   SI points to the table to search (text or graphics)
;   BX has colors
;   CX has width
;   DX has height
;
Lookup: xor	ax,ax				; last color number seen
Find_C: cmp	[si+4],ax			; last color number == this?
	je	Same_C
	jb	Prev_C				; end of table -- use last color
	cmp	BYTE PTR [si+6],0ffh		; valid entry ?
	je	Same_C				; not -- use last color
	mov	ax,[si+4]			; record color number
	mov	di,si				; start of entries w/ this color
	cmp	ax,bx				; enough colors ?
	jae	Find_S0
Same_C: add	si,8
	jmp	Find_C
Prev_C: or	ax,ax				; found any color at all?
	je	Exit
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
Find_S0:xor	si, si
Find_S: cmp	[di+4],ax			; still the same color #?
	jne	Prev_S
	cmp	BYTE PTR [di+6],0ffh		; valid entry ?
	je	Next_S
	mov	si, di			; record last good color
	cmp	[di],cx
	jb	Next_S
	cmp	[di+2],dx
	jae	GotIt
Next_S: add	di,8
	jmp	Find_S
Prev_S: ;sub	di,8
	mov	di, si
;
; At this point:
;   DI points to the table entry we want to set up
;
GotIt:
	mov	pg_gran, 0
	mov	ax,[di+6]			; BIOS mode number
	cmp	ax,1000h				; special ?
	jb	doBIOS
	shr	ax, 11
	sub	ax, 2
	mov	si,ax
	call	WORD PTR special_setup_table[si]
	jmp	RetVal
doBIOS:	cmp	ax, 100h
	jb	doINT
	; it is VESA mode, so get VESA info for it
	push	di
	push	ax
	push	bp
	mov	bp, sp
	sub	sp, 256
	mov	cx, ax		; get mode no into cx
	mov	ax, ss
	mov	es, ax
	mov	di, sp		; es:di @ answer buffer
	mov	ax, 4f01h	; call vesa mode info
	int	10h
	mov	di, sp
	mov	ax, ss:[di + 4]		; pg_gran
	mov	pg_gran, ax
	mov	ax, ss:[di + 12]
	mov	pg_off, ax
	mov	ax, ss:[di + 14]	; pg_seg
	mov	pg_seg, ax
; Set bank 0 - ? needed to overcome Trident BIOS problem ?
;	mov	bx, 0
;	mov	dx, 0
;	call	dword ptr [pg_off]

	mov	es, pg_seg
	mov	si, ss:[di + 16]	; linelen
	leave
	pop	bx  			; get mode no into bx
	pop	di
	mov	ax, 4f02h		; call VESA mode switch
        int	10h
        cmp	ax,4fh
        je	doINT_ok
	mov	bx,GRD_PLANE_MASK
        jmp	doFLAG
doINT:	int	10h
doINT_ok:
	mov	bx,GRD_1_PLANE
	cmp	WORD PTR [di+4],2		; 2 colors ?
	je	doFLAG
	mov	bx,GRD_4_PLANES
	cmp	WORD PTR [di+4],16		; 16 colors ?
	je	doFLAG
	mov	bx,GRD_8_PLANES
	cmp	WORD PTR [di+4],256		; 256 colors ?
	je	doFLAG
	mov	bx,GRD_16_PLANES
	cmp	WORD PTR [di+4],32768		; 32K colors ?
	je	doFLAG
	mov	bx,GRD_16X_PLANES
	cmp	WORD PTR [di+4],0c010h		; 64K colors ?
	je	doFLAG
	mov	bx,GRD_24_PLANES
	cmp	WORD PTR [di+4],0c018h		; 16M colors ?
	je	doFLAG
	mov	bx,GRD_PLANE_MASK		; something is wrong!!
doFLAG: or 	bx,mode_W
RetVal: mov	cx,[di]
	mov	dx,[di+2]
Exit:
	mov	di, pg_off
	mov	ax, pg_gran
	pop	ds
	ret
mode_set_routine   	endp


;--------------------------------------------------------------------------
; PAGING ROUTINE
;
;  Entry: AH=read page
;	  AL=write page
;
;  Exit: VGA configured.
;	 AX,BX,CX,DX,SI,DI may be trashed
;
;  NOTE: This runs in protected mode!  Don't mess with the segment registers!
;	 This code must be relocatable and may not reference any data!
;--------------------------------------------------------------------------
	assume  ds:nothing, es:nothing

; The routine is empty for VESA driver - the actual routine is
; determined during mode switch and configured by GO32.

paging_routine  proc	far
	ret
paging_routine  endp


cseg	ends
	end

