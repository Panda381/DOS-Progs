;--------------------------------------------------------------------------
; This is file SPARADIS.ASM
;
; Copyright (C) 1991 DJ Delorie, 24 Kirsten Ave, Rochester NH 03867-2954
; Copyright (C) 1992 Csaba Biegl, 820 Stirrup Dr, Nashville, TN 37221
;	# Modified June 1993 by Nick van der Merwe , Department of Surveying
;				University of Cape Town , South Africa
;	  changes made: SVGA support
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

;include grdriver.inc?
cseg	segment	byte public 'code'
	assume	cs:cseg, ds:cseg, es:cseg, ss:nothing

	dw	offset init_routine
	dw	offset paging_routine
	dw	0	; set to 1 if separate read & write windows or
			; only 64K of video RAM (ie: no paging)

def_tw	dw	80	; filled in by go32 if GO32 env. var. is set
def_th	dw	25
def_gw	dw	640
def_gh	dw	480
def_nc 	dw	16		;graphics colors
	dw	offset driver_init_routine
	dw	offset text_mode_table
	dw	offset graphics_mode_table

;
; Biggest text and graphics sizes
;

Max_TW  equ	132
Max_TH  equ	44
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
;--------------------------------------------------------------------------
text_mode_table		label word
	dw	80,	25,	2,	007h +  00000h
	dw	40,	25,	16,	001h +  00000h
	dw	80,	25,	16,	003h +  00000h
	dw	80,	30,	16,	012h +  00000h
	dw	80,	34,	16,	041h +  00000h
	;dw	80,	60,	16,	052h +  00000h
	dw	132,	25,	16,	055h +  00000h
	dw	132,	28,	16,	047h +  00000h
	dw	132,	44,	16,	021h +  00000h
	dw	40,	25,	256,	056h +  00000h
	dw	0,	0,	0,	000h +  00000h


;--------------------------------------------------------------------------
; TABLE OF SUPPORTED GRAPHICS MODES
;	- keep sorted first by colors then by size
;	- end with an all 0 entry
;	- BIOS field = 0xff disables it
;	- fields:
;		width,  height, colors, BIOS#+  setup_procedure_index*256
;--------------------------------------------------------------------------
graphics_mode_table	label word
	dw	320,	200,	16,	00dh +  00000h
	dw	640,	200,	16,	00eh +  00000h
	dw	640,	350,	16,	010h +  00000h
	dw	640,	480,	16,	012h +  00000h
	dw	800,	600,	16,	058h +  00000h
	dw	1024,	768,	16,	05dh +  00000h
	dw	320,	200,	256,	013h +  00000h
	dw	640,	400,	256,	05eh +  00000h
	dw	640,	480,	256,	05fh +  00000h
	dw	800,	600,	256,	05ch +  00000h
	dw	1024,	768,	256,	060h +  00000h
	dw	0,	0,	0,	000h +  00000h


;--------------------------------------------------------------------------
; TABLE OF SPECIAL SETUP PROCEDURES
;  You may need such procedures for:
;     -- reloading fonts on standard EGA or VGA for
;	 higher resolution text modes
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
	dw	0	; none here !!


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
	mov	ax,1
	ret
driver_init_routine	endp

;--------------------------------------------------------------------------
; Entry: AX=mode selection
;		0=80x25 text
;		1=default text
;		2=text CX cols by DX rows
;		3=biggest text
;		4=320x200 graphics
;		5=default graphics
;		6=graphics CX width by DX height
;		7=biggest non-interlaced graphics
;		8=biggest graphics
;
; NOTE: This runs in real mode, but don't mess with the segment registers.
;
; Exit:  CX=width (in pixels or characters)
;        DX=height

init_table	label	word
	dw	offset init_0
	dw	offset init_1
	dw	offset init_2
	dw	offset init_3
	dw	offset init_4
	dw	offset init_5
	dw	offset init_6
	dw	offset init_7
	dw	offset init_8

init_routine	proc	far
	cmp	ax,8
	jbe	valid_req
	ret
valid_req:
	shl	ax,1
	mov	bx,ax
	jmp	init_table[bx]

init_0: ; 80x25 text
	mov	ax,3
	int	10h
	mov	cx,80
	mov	dx,25
	ret

init_1: ; default text
	mov	cx,def_tw
	mov	dx,def_th
	jmp	init_2

init_2_table	label	word
	dw	01h, 40, 25
	dw	03h, 80, 25
init_2_tend	label	word

init_2: ; CX*DX text
	mov	si,offset init_2_table
init_2a:
	cmp	[si+2],cx
	jb	init_2b
	cmp	[si+4],dx
	jb	init_2b
	; got a big enough one!
	jmp	init_2c
init_2b:
	cmp	si,offset init_2_tend - 6
	je	init_2c
	add	si,6
	jmp	init_2a
init_2c:
	mov	ax,[si]
	push	si
	int	10h
	pop	si
	mov	cx,[si+2]
	mov	dx,[si+4]
	ret

init_3: ; biggest text
	mov	ax,[init_2_tend-6]
	int	10h
	mov	cx,[init_2_tend-4]
	mov	dx,[init_2_tend-2]
	ret

init_4: ; 320x200 graphics
	mov	ax,13h
	int	10h
	mov	cx,320
	mov	dx,200
	ret

init_5: ; default graphics - should be 640x480 if supported
	mov	cx,def_gw
	mov	dx,def_gh
	jmp	init_6

init_6_table	label	word
	dw	13h, 320, 200
	dw	5eh, 640, 400
	dw	5fh, 640, 480
init_6_tend	label	word

init_6: ; CX*DX graphics
	mov	si,offset init_6_table
init_6a:
	cmp	[si+2],cx
	jb	init_6b
	cmp	[si+4],dx
	jb	init_6b
	; got a big enough one!
	jmp	init_6c
init_6b:
	cmp	si,offset init_6_tend - 6
	je	init_6c
	add	si,6
	jmp	init_6a
init_6c:
	mov	ax,[si]
	push	si
	int	10h
	pop	si
	mov	cx,[si+2]
	mov	dx,[si+4]
	ret

init_7: ; biggest non-interlaced graphics
	mov	ax,5fh
	int	10h
	mov	cx,640
	mov	dx,480
	ret

init_8: ; biggest graphics
	mov	ax,5fh
	int	10h
	mov	cx,640
	mov	dx,480
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
;
; Derived from code from VGAKIT Version 3.4
;	Copyright 1988,89,90 John Bridges

	assume	ds:nothing, es:nothing

paging_routine	proc	far
	mov	cx,ax
	mov	dx,3ceh
	mov	ax,50fh		;turn off write protect on VGA registers
	out	dx,ax
	mov	ah,cl
	shl	ah,1
	shl	ah,1
	shl	ah,1
	shl	ah,1
	mov	al,9
	out	dx,ax

	ret
paging_routine	endp

;--------------------------------------------------------------------------

cseg	ends
	end
