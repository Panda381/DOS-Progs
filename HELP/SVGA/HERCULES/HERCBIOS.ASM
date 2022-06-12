#!/bin/sh
# shar:	Shell Archiver
#	Run the following text with /bin/sh to create:
#	read.me
#	hercbios.doc
#	hercules.prg
#	gchar.asm
#	graph.asm
#	hcharset.asm
#	hercbios.asm
#	hercbios.aut
#	hercbios.h
#	hercdemo.asm
#	hercmake.att
#	hercmake.lcm
#	hercpixl.dc
#	hercpixl.lc
#	testpix.c
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > read.me
X
X                           H E R C U L E S
X                           ---------------
X
XThis .ARC file contains two sets of information:
X
X
X      - HERCULES.PRG is a memo from Bob Morse and a note from me 
X        explaining the programming parameters for the Hercules (and 
X        clone) graphics board.  His information is especially useful 
X        because he lists the internal parameters which must be 
X        programmed into the 6845 chip to get graphics mode to work 
X        correctly.  Please report any problems with this information to 
X        me at DECWET::BROWN or Bob at LEWS2::MORSE.
X
X        HERCDEMO.COM (source included as HERCDEMO.ASM) is a quick and
X        dirty demo program I wrote to help me understand the way the
X        HERCULES card works, and use graphics character generation.
X
X      
X      - HERCBIOS.COM plus support sofware.  HERCBIOS.COM is a terminate-
X        and-stay-resident program which takes over some functions from 
X        ROM BIOS INT 10h, providing IBM-compatible graphics modes 6 (640 
X        by 200) and 7 (monochrome text) and adding mode 8: Hercules 
X        graphics (720 by 348).  Other functions are just passed through 
X        to the existing ROM BIOS.
X      
X        HERCBIOS was written by Dave Tutelman at AT&T in New Jersey, and 
X        the software came to me via net.micro.pc, hot off the wire two 
X        days ago.  I've included his note and banner as HERCBIOS.AUT.
X      
X        HERCBIOS.DOC explains the operation of the program in detail.
X      
X        HCHARSET.ASM is a simple test program to demonstate IBM and 
X        HERCULES modes.
X      
X        There is also a C program which gives a more extended demo of 
X        the facility:  TESTPIX.C.  TESTPIX must be linked with another C 
X        module, HERCPIXL, which provides the actual linkages to INT 10h.
X        Since system calls are implementation specific, there are two 
X        versions of this module: HERCPIXL.DC and HERCPIXL.LC.  
X        HERCPIXL.DC is DeSmet C compatible and HERCPIXL.LC is Lattice C 
X        compatible.  I've included TESTPIX.EXE (build with Lattice) so 
X        you can test the software if you don't have C.
X      
X        Finally, there are two make files:  HERCMAKE.ATT and 
X        HERCMAKE.LCM.  HERCMAKE.ATT is a make file for a make program 
X        which looks UNIX compatible, so I called it ".ATT".  
X        HERCMAKE.LCM is a make file for the Larry Campbell MAKE program 
X        I use.  In either case, you will have to use the -f switch 
X        invocation of MAKE.  E.g: MAKE -f HERCMAKE.LCM HERCBIOS.COM.
X
X        HERCBIOS.COM seems to work quite nicely as advertised, but I 
X        must warn you that there are some functions which are not yet 
X        implemented -- scrolling in graphics mode, for one.  I'm sure 
X        Dave will continue to enhance it and hope to get future updates.  
X        In the meantime, if anyone gets brave and tackles scrolling, put 
X        the updates on PAR5!
X      
X      
X-Reid Brown
X 6-Sep-1986
X DECWET::BROWN
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercbios.doc
X
X
X                             *****   HERCBIOS   *****
X                        BIOS PATCH FOR THE HERCULES BOARD
X
X                               Dave Tutelman  1986
X
X
X
X          The accompanying program is a front end to the INT 10 (VIDEO)
X        functions of the DOS BIOS, so that the important functions work
X        on a Hercules graphics board or its clones. (It was developed on
X        a SuperComputer clone of a Hercules) It is a
X        terminate-and-stay-resident program, that is installed by being
X        called; it is NOT a DOS driver. If you want it installed at boot,
X        include it in AUTOEXEC.BAT, not CONFIG.SYS.
X
X        WHAT IT'S GOOD FOR
X
X        The major strength of this program is that it will allow you to
X        write programs for the Hercules board that run in graphics mode,
X        and still write text easily on the graphics screen. With it, you
X        can program in those higher-level language processors that use
X        the DOS or BIOS calls for display, using their standard I/O calls
X        to write text to the graphics screen. (For a list of known
X        compatible and incompatible languages, see the section later in
X        this manual.)
X
X        A second use of this program is to allow the running of existing
X        graphics programs that use the BIOS calls for ALL screen display.
X        It will NOT allow most commercial graphics programs written for
X        the the Color Graphics Adapter (CGA) to run on the Hercules
X        board. That is because most graphics programs write directly to
X        the video memory instead of using the BIOS calls. The only
X        existing graphics program that this has been tested against is
X        PC-LISP; that is the only graphics program I've encountered that
X        uses the BIOS exclusively.
X
X
X        HOW IT WORKS
X
X        HERCBIOS is a terminate-and-stay-resident program that intercepts
X        all calls to Interrupt 10H, the BIOS video services. It will
X        either process the interrupt or pass the call on to the real
X        BIOS, depending on whether something specific to the Hercules
X        board needs to be done. Specifically, HERCBIOS handles the
X        interrupt itself if (1) the board is in graphics mode, or (2) the
X        BIOS call is a request to enter graphics mode.
X
X        Two graphics modes are recognized and processed by HERCBIOS:
X
X             Mode 6 - IBM Hi-res mode:  This uses part of the 720x348
X             Hercules raster as a 640x200 IBM-compatible graphics screen.
X             It will work with programs for the IBM CGA and its clones,
X             provided they use the BIOS services for their graphics
X             display. (Note - such programs are rare.)
X
X             Mode 8 - Hercules-specific mode:  This uses the full
X
X                                      - 1 -
X
X
X             Hercules raster.
X
X        Actually, both modes are quite capable of putting a pixel
X        anywhere on the Hercules raster.  The major difference is that
X        Mode 6 draws characters in an 8x8 pixel box (like the CGA), while
X        Mode 8 uses the finer resolution of the Hercules board to improve
X        legibility by using a 12x8 pixel box for characters. In either
X        mode, more characters than 25x80 will fit on the screen. Mode 6
X        supports 43x90 characters on the screen (but 25x80 inside the
X        640x200-pixel sub-screen); Mode 8 supports 29x90 characters.
X
X        The functions implemented by HERCBIOS are:
X
X                Fn  0 - Set mode (6, 7, or 8)
X                Fn  2 - Set cursor position
X                Fn  3 - Read cursor position
X                Fn  5 - New display page
X                Fn  9 - Write character with attribute
X                Fn 10 - Write character
X                Fn 12 - Write pixel
X                Fn 13 - Read pixel
X                Fn 14 - Teletypewriter-style character write
X                Fn 15 - Get video status
X
X        Check your System Programmers' Guide for the use of these BIOS
X        functions.
X
X        A number of properties of the alphanumeric display are not
X        supported by the hardware when you enter graphics mode. For
X        instance, the cursor is not shown in graphics mode, nor are all
X        of the character attributes. HERCBIOS does its best to emulate
X        the alphanumeric mode, but it cannot implement a cursor or the
X        blinking or bold attributes. The table below shows the "best
X        shot" that HERCBIOS takes at character attributes:
X
X                CODE    USUALLY MEANS           IBM MODE        HERC MODE
X                00      invisible               invisible       invisible
X                01      underline               [normal]        underline
X                07      normal                  normal          normal
X                0F      hi-intens               [rev video]     [rev video]
X                70      rev video               rev video       rev video
X
X
X                Anything else displays as normal
X
X        The teletypewriter-style output protects the bottom line on the
X        screen as an unscrolled line, for status messages, function key
X        labels, etc. This is non-standard, but I like it. (And we do have
X        more rows than the CGA display. It's the 43rd line that isn't
X        scrolled.)
X
X
X
X
X
X
X
X                                      - 2 -
X
X
X        MAKING AND INSTALLING THE PROGRAM
X        Making the .COM File from Assembler Source
X
X        HERCBIOS was originally developed on ASM 1.0. The version
X        included with this uses MASM 4.0. I don't know for sure whether
X        it will assemble with other versions of assembler.
X
X        The commands for making HERCBIOS.COM from the source are in the
X        MAKEFILE included with the distribution. I run it with NDMAKE, an
X        excellent MS-DOS shareware MAKE from Don Knellers, but it should
X        be easy to adapt to your own favorite MAKE. If you make it by
X        hand, the commands are:
X
X                masm  hercbios;
X                masm  gchar;
X                masm  graph;
X                link  hercbios gchar graph,  hercbios.exe;
X                exe2bin  hercbios.exe hercbios.com
X                del  hercbios.exe
X
X        If you have a machine whose processor is an iAPX 286, 186, or
X        188, you may be able to get some increased performance and a
X        smaller .COM file by editing one character in the header file
X        hercbios.h. Simply remove the ";" that comments out the
X        definition of iAPX286. That will allow some non-8088 instructions
X        to assemble, as well as changing some code that was optimized for
X        speed (at the expense of storage and beauty) on the 8088. (This
X        option is known to assemble and link, but has not been tested; I
X        have no access to a 286 machine with Hercules graphics.)
X
X
X        Installing HERCBIOS.COM
X
X        Once you have HERCBIOS.COM, store it where your PATH will find it
X        and add the line
X
X                HERCBIOS
X
X        to your AUTOEXEC.BAT file somewhere after the PATH command. This
X        will cause it to be installed during boot, so it will be there
X        whenever you run your graphics programs. (Its presence won't
X        affect operation of your computer in alphanumeric mode, since it
X        passes on to the normal BIOS anything that's not in graphics
X        mode.)
X
X        I am including a couple of demonstration/test programs in this
X        distribution, so that you can:
X           - See how to write programs for HERCBIOS.
X           - Test to assure that it runs with your computer and monitor.
X        The programs can be run in their executable form and their source
X        can be examined.
X
X
X
X
X
X
X                                      - 3 -
X
X
X        COMPATIBILITY AND INCOMPATIBILITY
X
X        HERCBIOS has been tested on a Hercules board in an IBM PC-XT, a
X        Hercules-compatible board I built from a SuperComputer bare
X        board, and a Leading Edge XT clone. The current version works
X        with all of these, but I have a homebrew monitor that has trouble
X        syncing to the higher sweep rate of the monochrome display. If
X        you have trouble with the stability of your image, try fiddling
X        with the parameters for the 6845 display chip. They are in the
X        file HERCBIOS.ASM, in the "db" statement defining vid_parm_table
X        at the end of Function 0 (Set Video Mode). I have left in (but
X        commented out) the set of parameters that works on my homebrew
X        monitor.
X
X        I have written programs using HERCBIOS in a number of languages.
X        Here are some of the caveats I'd like to pass on:
X
X          - Things are fine using INT 10h calls in assembler.  (No big
X            surprise.)
X
X          - Turbo Pascal works with HERCBIOS, with one caveat (at least
X            for releases 1 and 2). The Pascal cursor function GoTOXY will
X            home the cursor if presented with x>80 or y>25. To make full
X            use of the 29x90 or 43x90 screen, you will have to write your
X            own version of GoTOXY, using Turbo's machine language escape
X            to issue the INT 10h.
X
X          - I've written a little in Microsoft C 3.0. No problems so far.
X
X          - The TESTPIX program was written in deSmet C 2.4. It worked
X            fine, with one caveat. The console I/O routine getchar()
X            seems to write to display memory (perhaps as part of keyboard
X            echo). This can interfere with what is displayed on the
X            Hercules board display page 1.  (I had no problems on page
X            0.)
X
X          - Forget about using it with BASICA or GWBASIC. Microsoft BASIC
X            graphics routines write directly to display memory,
X            completely bypassing the BIOS.
X
X
X        USE AND ENJOY!
X
X        Bug reports to:
X                            Dave Tutelman
X                            16 Tilton Drive
X                            Wayside, NJ 07712
X
X
X                            Currently receive EMail at ...!mtuxo!mtuxt!dmt
X
X
X        Flames to:
X                            /dev/null
X
X
X
X                                      - 4 -SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercules.prg
X              Hercules Monochrome Graphics Card Programming
X              ---------------------------------------------
X
X                             provided by
X
X                Robert Morse  MLO5-2/B6  LEWS2::MORSE
X
XThe board configuration is controlled by the write-only control register
Xat port 03BF.  All bits are set to zero upon power-up, which limits
Xthe board to text mode (it will pass IBM monochrome display adapter
Xdiagnostics only while all bits are zero).
X
XBit     Description
X---     -----------
X 0      0=disable setting of graphics mode; 1=allow graphics mode.
X 1      0=disable page one (allows coexistence with a color graphics
X               board); 1=enable page one (required to run Lotus 1-2-3).
X 2..7     (not used)
X
X
X
XModes are controlled by the write-only control register at port 03B8. All
Xbits are set to zero upon power-up. 
X
XBit     Description
X---     -----------
X 0        (not used)
X 1      0=text; 1=graphics.
X 2        (not used)
X 3      0=blank screen; 1=activate screen.
X 4        (not used)
X 5      0=disable text blink; 1=enable text blink.
X 6        (not used)
X 7      0=page zero at B0000h; 1=page one at B8000h.
X
X
X
XTable of 6845 values (all values in hexadecimal): 
X
XRegister                        Text    Graphics
X-------------------------       ----    --------
X 0  Total chars/row -1           61        35	
X 1  Visible chars/row            50        2D
X 2  Hsync position               52        2E
X 3  Hsync width                  0F        07
X 4  Total rows -1                19        5B
X 5  Additional scan lines        06        02
X 6  Visible rows                 19        57
X 7  Vsync position               19        57
X 8  Interlace control            02        02
X 9  Lines/row -1                 0D        03
X A  Top cursor scan              0B        00
X B  Bottom cursor scan           0C        00
X C  Display origin               00        00
X D  Display origin               00        00
X 
XIn text mode, each character time is 0.5625 microseconds and a character is
X9 dots wide and 14 dots high.  The controller is programmed for 25
Xdisplayed rows of 14 scan lines each.  There are 350 visible scan lines and
X370 total scan lines. 
X
X
XIn graphics mode, each character time is 1.000 microseconds and a character
Xis 16 dots wide and 4 dots high.  The controller is programmed for 87
Xdisplayed rows of 4 scan lines each.  There are 348 visible scan lines and
X370 total scan lines.  Each row has 45 displayed characters of 16 bits,
Xgiving 720 dots/row.
X
X
X<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
X                      Note on Addressing the Screen
X                      -----------------------------
X
XThe preceding paragraph gives a hint about pixel addresses in graphics 
Xmode.  I looked through the HERCBIOS sources and then wrote a program
X(HERCDEMO.ASM) to help me understand this.  Here's how screen addressing
Xworks:
X      
X      o Although you might think of graphics mode as pure bits, the 6845
X        chip always thinks in term of characters.  When you switch to
X        graphics mode, the characters are 16 bits wide by 4 bits high.
X        Thus, in graphics mode the screen has 87 rows of "characters"
X        and each row is 45 characters wide, for 720x348 pixels.
X      
X      o For a reason unknown to me (probably speed of memory access),
X        each of the four scan lines in a graphics character is stored in
X        a different "bank" or 2000h section of the screen buffer.  All
X        87 scan line 0s are stored from 0-2000h, all scan line 1s from
X        2000h-4000h, all scan line 2s from 4000h-6000h, and all scan
X        line 3s from 6000h-8000h.
X      
X      o Within a bank of memory (representing one set of scan lines),
X        each row is 45 words or 90 bytes wide.  Rows follow each other
X        with no intervening space. So, assuming row numbers from 0 to
X        86, the 5th graphics character in row 40 is composed of four
X        scan lines, each 16 bits wide, located at the following memory
X        addresses (offsets from the beginning of the screen buffer):
X                40*90 = 3600    (offset in any bank to row 40)
X                4*2=8           (5th graphics char = (n-1)*2 bytes/char)
X                Scan line 0:    locations 3608,3609
X                Scan line 1:    2000h (8192) + 3608,9 = 11800,11801
X                Scan line 3:    4000h (16384) + 3608,9 = 19992,19993
X                Scan line 4:    6000h (24576) + 3608,9 = 28184,28185
X      
X      o Computing a pixel location is a little harder, but still fairly
X        straightforward.  Say you want to address the bit at 300,300
X        with a point of origin at the upper left.  300 scan lines down
X        from the top is 300/4 = 75 (no remainder), which is scan line 0
X        of row 75.  300 bits into the line is 300/8 = 37 remainder 4.
X        The bit you want is in bank 0 (0-2000h) since it is scan line 0,
X        offset by 75*90 =6750 for the row, plus 37 for the byte within
X        the row, or byte offset 6787 from the beginning of that page in
X        screen memory.  Within that byte, you want to set/reset bit 4.
X      
X      
XWell, that should cover it.  If you should discover that I got any of
Xthis wrong, send me mail.
X      
X-Reid Brown
XDECWET::BROWN
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > gchar.asm
X;********************************************************************
X;*
X;*	GRAPHIC CHARACTER HANDLING
X;*
X;*		Dave Tutelman - 8/86
X;*
X;*-------------------------------------------------------------------
X;*
X;*	Fn 6	Scroll up - not yet implemented
X;*	Fn 7	Scroll down - not yet implemented
X;*	Fn 9	Write character with attribute
X;*	Fn 10	Write character normal
X;*	Fn 14	Write character Teletypewriter style
X;*
X;*	Also includes subroutines to:
X;*	get_address	convert page/row/col to display address
X;*	do_char		write a character to an address on display
X;*	do_attrib	change a display address to some attribute
X;*	full_screen_scroll	used by Fn 14, when it needs to scroll
X;*	flash		momentarily flash to reverse video and back
X;*
X;********************************************************************
X;
XINCLUDE	hercbios.h
X
X;-----------------------------------------------
Xextrn	exit_herc_bios:near
Xpublic	writechar,scroll_up,scroll_down,tty
Xpublic	scr_start,scr_length,num_rows
X;------------------------------------
Xcseg	segment	public
X	assume	cs:cseg,ds:bios_data
X;
X
X;**************************************************************
X;*
X;*	FUNCTION 6 & 7 - SCROLL UP & DOWN
X;*	(Placeholder only - not yet implemented)
X;*
X;*	AL = Number of rows to scroll (if 0, blank scroll area)
X;*	BH = Fill attribute (we ignore, since writechar destroys old attrib)
X;*	CX = Upper left corner      (CH=row, CL=col)
X;*	DX = Lower right corner     (DH=row, DL=col)
X;*
X;****************************************************************
X;
Xscroll_up:
Xscroll_down:
X;
X	jmp	exit_herc_bios
Xpage
X;********************************************************************
X;*
X;*	FUNCTION 9 & 10 - WRITE A CHARACTER AT CURRENT CURSOR
X;*
X;*	AL = character code to be written
X;*	AH = 9 (write char with attribute) or 10 (write char normal)
X;*	BL = new attribute (limited selection in graphics mode)
X;*	BH = display page number
X;*	CX = count of how many characters to write
X;*
X;********************************************************************
X;
Xwritechar:	
X;			; Get the address corresponding to cursor[page]
X	push	bx
X	mov	bl,bh		; page to BX
X	xor	bh,bh
X	shl	bx,1		; *2 for word pointer
X	mov	dx,curs_pos[bx]	; appropriate cursor position to DX
X	pop	bx
X	call	get_address	; get display address in DI
X;
Xwrchar_loop:
X;			; Write a character to that address
X	call	do_char		; arguments set up already
X;
X;			; If function 9, modify the character's attributes
X	cmp	ah,9		; Function 9?
X	jne	no_attrib	; no, don't do attributes
X	call	do_attrib	; yes, and arguments already set up
Xno_attrib:
X;
X	inc	di		; move to next position, without moving
X				;    the official cursor
X	loop	wrchar_loop	; continue until CX count exhausted
X	jmp	exit_herc_bios
Xpage
X;*****************************************************************
X;*
X;*	FUNCTION 14 - TELETYPEWRITER-STYLE CHARACTER WRITE
X;*
X;*	AL = Character to be written
X;*
X;******************************************************************
X;
Xtty:
X	assume	ds:bios_data
X	mov	bl,active_page	; active page to BX
X	xor	bh,bh
X	mov	dx,curs_pos[bx]	; get cursor for active page
X	push	bx
X	mov	bh,bl		; move page to BH
X	call	get_address	; address of character to DI
X	pop	bx
X;
X;			; process the character
X;			; check if CR
X	cmp	al,13		; carriage return?
X	jne	not_cr
X	mov	dl,0		; go to first column
X	jmp	fix_curs
X;			; check if LF
Xnot_cr:	cmp	al,10		; line feed?
X	jne	not_lf
X	inc	dh		; next line
X	jmp	fix_curs
X;			; check if BS
Xnot_lf:	cmp	al,8		; backspace?
X	jne	not_bs
X	cmp	dl,0		; already first column?
X	je	fix_curs	; yup. do nothing
X	dec	dl		; nope. move cursor left one
X	dec	di		; also move address pointer left one
X	mov	al,32		; set character to space
X	call	do_char		; and write the space, but don't move
X	jmp	fix_curs
X;			; check if BEL
Xnot_bs:	cmp	al,7		; bell character?
X	jne	not_bl
X	pop	es		; restore registers
X	pop	di
X	pop	si
X	pop	dx
X	pop	cx
X	pop	bx
X	pop	ds
X	jmp	vid_bios	; ... and use the normal BIOS to ring the bell
X;	call	flash		; can't do BEL standard. Blink display instead
X;	jmp	fix_curs
X;			; ordinary printing character, so display it
Xnot_bl:	call	do_char		; write it to screen
X	inc	dl		; cursor one to the right
X;
X;			; now look at the cursor, do what's necessary to
X;			; fix it up, and save it away.
Xfix_curs:
X	cmp	dl,89		; beyond last column?
X	jle	chk_scroll	; not yet
X	xor	dl,dl		; yes. do a CR
X	inc	dh		; ... and a LF
Xchk_scroll:
X	cmp	dh,cs:num_rows	; now see if we're beyond last row?
X	jl	exit_tty	; not yet
X	call	full_screen_scroll
X				; yes. Scroll the screen up one
X	dec	dh		; ... and scroll cursor, too.
X	jmp	chk_scroll
X;
Xexit_tty:
X	mov	curs_pos[bx],dx	; save cursor position
X	jmp	exit_herc_bios
Xpage
X;--------------------------------------------------------------------
X;
X;	GET_ADDRESS  SUBROUTINE
X;
X;	BH = display page
X;	DX = cursor position (DH=row, DL=col)
X;
X;	returns:
X;	DI = displacement of top row of pixels
X;
X;--------------------------------------------------------------------
X;
Xget_address:
X	push	cx		; save it
X
X;			; compute display address from cursor_pos
X	mov	cl,dh		; get row # in cx
X	xor	ch,ch
X	shl	cx,1		; begin fast multiply by 90 (1011010 B)
X	mov	di,cx
X	shl	cx,1
X	shl	cx,1
X	add	di,cx
X	shl	cx,1
X	add	di,cx
X	shl	cx,1
X	shl	cx,1
X	add	di,cx		; end fast multiply by 90
X	mov	cx,di		; copy answer back to cx
X	shl	di,1		; *2 for ibm graphics mode
X	cmp	video_mode,herc_mode
X	jne	ibm_ad		; not herc mode
X	add	di,cx		; *3 for herc mode
Xibm_ad:	xor	ch,ch		; columns in CX
X	mov	cl,dl
X	add	di,cx		; add in col. address in DI
X	cmp	bh,0		; if page 1, set high-order bit of address
X	je	pg0
X	or	di,8000H
Xpg0:
X;			; address now in DI
X;
X	pop	cx		; restore it
X	ret
Xpage
X;--------------------------------------------------------------------
X;
X;	DO_CHAR  SUBROUTINE
X;
X;	AL = character to write
X;	DI = diplacement (address) of top row of pixels
X;
X;	Note: SI and ES are destroyed
X;
X;--------------------------------------------------------------------
X;
Xdo_char:
X	push	ax
X	push	bx
X	push	cx
X	push	di
X	push	ds
X;
X;			; get scan pattern table pointer into BX
X	cmp	video_mode,herc_mode
X	je	herc_1
X	mov	bx,offset ibm_pattern
X				; IBM graphics mode - use appropriate table
X	jmp	c_1
Xherc_1:	mov	bx,offset herc_pattern
X				; herc graphics mode - use appropriate table
Xc_1:
X;
X;			; set up source address registers
X	xor	ah,ah		; character to SI
X	mov	si,ax
XIFDEF iAPX286
X	shl	si,3		; *8 for 8-byte table entry
XELSE
X	shl	si,1		; *8 for 8-byte table entry
X	shl	si,1
X	shl	si,1
XENDIF
X				; next, find beginning of table
X	cmp	al,7Fh		; ROM or user table?
X	jg	u_tbl
X				; ROM table
X	add	si,charbase	; character table base added to offset
X	mov	ax,mpx_bios	; BIOS code segment to DS
X	mov	ds,ax
X	jmp	c_2
Xu_tbl:				; user table
X	xor	ax,ax		; zero (interrupt vector) to DS
X	mov	ds,ax
X	mov	ax,si		; save table offset in AX
X	assume	ds:intvec
X	lds	si,user_table	; load DS:SI from interrupt vector
X	add	si,ax		; add offset into table base
Xc_2:
X;
X;			; set up destination address registers
X	mov	ax,pixbase	; get display segment in ES
X	mov	es,ax
X				; displacement already in DI
X;
X;
X;			; transfer the character
X	mov	ax,di		; save top-row displacement in AX
X	mov	cx,8		; transfer 8 rows
X	cld			; direction = up
Xc_loop:	mov	di,ax		; top-row displacement
X	add	di,cs:[bx]	; add entry from scan-pattern table
X	movsb			; actually transfer a byte and bump SI & DI
X	add	bx,2		; next entry in scan-pattern table
X	loop	c_loop
X;
X;			; if hercules mode, blank the extra rows
X	pop	ds		; restore DS to Bios data
X	assume	ds:bios_data
X	cmp	video_mode,herc_mode
X	jne	c_3
X				; Hercules mode
X	mov	si,ax		; don't need SI. Save top-row displacement
X	xor	ax,ax		; zero AX
X	mov	cx,4		; four rows to blank
X	cld
Xc_blnk: mov	di,si		; top-row displacement
X	add	di,cs:[bx]	; add entry from scan-pattern table
X	stosb			; transfer a zero byte
X	add	bx,2		; next entry in scan-pattern table
X	loop	c_blnk
Xc_3:
X;
X;			; clean up and return
X	pop	di
X	pop	cx
X	pop	bx
X	pop	ax
X	ret
Xpage
X;---------------------------------------------------------------------
X;
X;	DO_ATTRIB  SUBROUTINE
X;
X;	BL = attribute byte
X;	DI = displacement (address) of top row of pixels
X;	ES is destroyed
X;
X;	Because attributes don't "just happen" in graphics mode, here's
X;	what we have to transform them to.
X;
X;	CODE	USUALLY MEANS		IBM MODE	HERC MODE
X;	00	invisible		invisible	invisible
X;	01	underline		[normal]	underline
X;	07	normal			normal		normal
X;	0F	hi-intens		[rev video]	[rev video]
X;	70	rev video		rev video	rev video
X;
X;	Anything else displays as normal
X;	Note that there's no way to make blinking happen.
X;
X;-----------------------------------------------------------------------
X;
Xdo_attrib:
X	assume	ds:bios_data
X	push	ax
X	mov	ax,pixbase	; Display base to ES
X	mov	es,ax
X	pop	ax
X;
X;			; which attribute, if any?
X	and	bl,7Fh		; mask off blink bit
X	cmp	bl,0		; invisible?
X	je	invisible
X	cmp	bl,0Fh		; reverse video? (instead of bright)
X	je	reverse
X	cmp	bl,70H		; reverse video?
X	je	reverse
X	cmp	bl,01		; underline?
X	je	underline
X	ret			; none of the above. Display normal.
X;
X;			; underline the character
Xunderline:
X	cmp	video_mode,herc_mode
X	je	ul_1
X	ret			; don't do it for IBM mode
Xul_1:	mov	byte ptr es:[di+40B4h],0FFh
X				; move ones to 11th line of pixel array
X				; 40B4h is the 11th entry in herc_pattern
X	ret
X;
X;			; make it invisible
Xinvisible:
X	push	ax
X	push	bx
X	push	cx
X	push	dx
X	xor	ax,ax		; zero the AX
X	cmp	video_mode,herc_mode
X	je	herc_3
X	mov	bx,offset ibm_pattern
X				; point to scan pattern
X	jmp	inv_1
Xherc_3:	mov	bx,offset herc_pattern
X				; point to scan pattern
Xinv_1:	mov	dx,di		; save addr of top row of pixels in DX
X	mov	cx,8		; 8 bytes to be moved
X	cld			; direction = up
Xinvis_loop:
X	mov	di,dx		; top row address
X	add	di,cs:[bx]	; add scan-table offset
X	stosb			; move a zero byte
X	add	bx,2		; bump the scan-table pointer
X	loop	invis_loop
X	pop	dx
X	pop	cx
X	pop	bx
X	pop 	ax
X	ret
X;
X;			; reverse video
Xreverse:
X	push	bx
X	push	cx
X	push	dx
X	cmp	video_mode,herc_mode
X	je	herc_4
X	mov	bx,offset ibm_pattern
X				; point to scan pattern
X	mov	cx,8		; 8 scan lines for IBM mode
X	jmp	rev_1
Xherc_4:	mov	bx,offset herc_pattern
X				; point to scan pattern
X	mov	cx,12		; 12 scan lines for Hercules mode
Xrev_1:	mov	dx,di		; save addr of top row of pixels in DX
X	cld			; direction = up
Xrev_loop:
X	mov	di,dx		; top row address
X	add	di,cs:[bx]	; add scan-table offset
X	not	es:byte ptr[di]	; invert one scan line
X	add	bx,2		; bump the scan-table pointer
X	loop	rev_loop
X	pop	dx
X	pop	cx
X	pop	bx
X	ret
Xpage
X;--------------------------------------------------------------
X;
X;	SUBROUTINE  FULL_SCREEN_SCROLL
X;
X;	This scrolls the entire screen up one print line (8 or 12 pixels).
X;	Actually, we'll protect one line on the bottom (e.g.-function keys).
X;
X;-----------------------------------------------------------------
X;
X;			; A few constants, initialized by set_mode
Xnum_rows	db	?	; number of rows in display
X				;   = 42 (IBM)  or 28 (Herc)
Xscr_start	dw	?	; 2*90 or 3*90 depending on mode
Xscr_length	dw	?	; number of words to transfer in a sweep
X				;   = 41*start /2 = 3690	(IBM)
X				;   = 27*start /2 = 3645	(Herc)
X;
Xfull_screen_scroll:
X	assume	ds:bios_data
X	push	ds
X	push	ax
X	push	cx
X	mov	ax,pixbase	; start getting display segment
X	cmp	active_page,0	; page 0?
X	je	scr_pg0		
X	add	ax,800H		; page 1. bump by half of 64K
Xscr_pg0:
X	mov	ds,ax		; save display segment in DS
X	mov	es,ax		; ... and in ES
X;
X	xor	ax,ax		; zero AX
X	call	scr_shift
X	mov	ax,2000H	; bump interlace counter
X	call	scr_shift
X	mov	ax,4000H
X	call	scr_shift
X	mov	ax,6000H
X	call	scr_shift
X;
X	pop	cx
X	pop	ax
X	pop	ds
X	ret
X;
X;
X; scr_shift does the actual work of scrolling, one set of interlace
X;   lines at a time.
X;
Xscr_shift:
X	cld			; block moves will be UP
X	mov	di,ax		; interlace scan ID to DI
X	mov	si,ax		; ... and to SI
X	add	si,cs:scr_start
X				; but bump by "start"
X	mov	cx,cs:scr_length
X				; set counter for transfer
X	rep	movsw		; and scroll a set of lines
X	xor	ax,ax		; set up a zero word
X	mov	cx,cs:scr_start ; set counter for one more line
X	shr	cx,1		; /2 for word transfers
X	rep	stosw		; and blank the line
X	ret
Xpage
X;-----------------------------------------------------------
X;
X;	SUBROUTINE FLASH
X;
X;	Flashes the screen inverse video and back to normal.
X;	Used in place of an audible bell.
X;
X;-------------------------------------------------------------
X;
Xflash:
X	push	cx
X	push	di
X	push	es
X;
X	mov	di,pixbase	; get display area base
X	cmp	active_page,0	; page 0?
X	je	pg0_f
X	add	di,800H		; no, page 1
Xpg0_f:	mov	es,di		; put resulting pointer to display in ES
X;
X;			; loop to invert screen
X	xor	di,di		; point to beginning of display area
X	mov	cx,4000H	; number of words to invert
Xflash_loop_1:
X	not	word ptr es:[di]
X				; invert one location
X	add	di,2		; bump location pointer a word
X	loop	flash_loop_1
X;
X;			; and invert it back to normal
X	xor	di,di		; point to beginning of display area
X	mov	cx,4000H	; number of words to invert
Xflash_loop_2:
X	not	word ptr es:[di]
X				; invert one location
X	add	di,2		; bump location pointer a word
X	loop	flash_loop_2
X;
X	pop	es
X	pop	di
X	pop	cx
X	ret
Xpage
X;*****************************************************
X;*	Data areas for character handling
X;*****************************************************
X;
Xpixels		db	12 dup(?)	; 12 bytes for pixel pattern
Xibm_pattern	dw	0000h,2000h,4000h,6000h,005Ah,205Ah,405Ah,605Ah
Xherc_pattern	dw	4000h,6000h,005Ah,205Ah,405Ah,605Ah,00B4h,20B4h
Xblank_pattern	dw	0000h,2000h,40B4h,60B4h
X;
X;
Xcseg	ends
X	end
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > graph.asm
X;*******************************************************
X;*	
X;*	SET OF GRAPHICS ROUTINES FOR HERCULES BIOS
X;*
X;*		Dave Tutelman - 8/86
X;*
X;*-------------------------------------------------------
X;*
X;*	do_pixel:	draws, erases, or reads a pixel, given an
X;*			offset and mask.
X;*
X;**********************************************************
X;
XINCLUDE	hercbios.h
X
X;------------------------------------------
Xpublic	wr_pixel,end_herc
Xextrn	exit_herc_bios:near
X;-----------------------------------------
X;
Xcseg	segment	public
X	assume	cs:cseg,ds:bios_data
X;
X;
X;**********************************************
X;*
X;*	read or write a pixel:
X;*		DX = row # ( y )
X;*		CX = col # ( x )
X;*		AH = 12 for write, 13 for read
X;*		AL = value (0,1, if bit 7=1 EXOR the value)
X;*
X;**********************************************
X;
Xwr_pixel:
X	mov	bh,video_mode	; check for valid mode
X	cmp	bh,herc_mode
X	je	do_pixel
X	cmp	bh,ibm_mode
X	je	do_pixel
X	jmp	exit_herc_bios		; invalid mode. don't do it.
X;
Xdo_pixel:
X	push	ax		; save function and pixel value
X;
X;			; first compute the address of byte to be modified
X;			; = 90*[row/4] + [col/8] + 2^D*[row/4] + 2^F*page
X	mov	bh,cl		; col (low order) in BH
X	mov	bl,dl		; row (low order) in BL
X	and	bx,0703H	; mask the col & row remainders
XIFDEF iAPX286
X	shr	cx,3		; col / 8
X	shr	dx,2		; row / 4
X	mov	al,90
X	mul	dx		; AX = 90*[ row/4 ]
X	add	ax,cx		;  ... + col/8
X	shl	bl,5		; align row remainder
XELSE			; same as above, obscure but fast for 8086
X	shr	cx,1		; divide col by 8
X	shr	cx,1
X	shr	cx,1
X	shr	dx,1		; divide row by 4
X	shr	dx,1
X	shl	dx,1		; begin fast multiply by 90 (1011010 B)
X	mov	ax,dx
X	shl	dx,1
X	shl	dx,1
X	add	ax,dx
X	shl	dx,1
X	add	ax,dx
X	shl	dx,1
X	shl	dx,1
X	add	ax,dx		; end fast multiply by 90
X	add	ax,cx		; add on the col/8
X	shl	bl,1		; align row remainder
X	shl	bl,1
X	shl	bl,1
X	shl	bl,1
X	shl	bl,1
XENDIF
X	add	ah,bl		; use aligned row remainder
X	cmp	active_page,0	; page 0 active?
X	je	end_adr_calc	; yup
X	or	ah,80H		; page 1 active. Set MSB of address
Xend_adr_calc:		; address of byte is now in AX
X;
X	mov	dx,pixbase	; base of pixel display to DX
X	mov	es,dx		; ...and thence to segment reg
X	mov	si,ax		; address of byte w/ pixel to index reg
X	mov	cl,bh		; bit addr in byte
X	mov	al,80H		; '1000 0000' in AL 
X	shr	al,cl		; shift mask to line up with bit to read/write
X	mov	bl,al	
X;
X	pop	bx		; now retrieve original AX into BX
X				;      function=BH, pixel value=BL
X	cmp	bh,13		; what to do with the pixel?
X	je	read_pix	; read the pixel.
X	cmp	bl,0		; write the pixel. But how?
X	je	clr_pix		; clear the pixel
X	jl	exor_pix	; exclusive-or the pixel
X;
Xset_pix:		; set the pixel
X	or	es:[si],al	; or the mask with the right byte
X	jmp	exit_herc_bios
X;
Xclr_pix:		;clear the pixel
X	not	al		; invert the mask, so zero on bit to be cleared
X	and	es:[si],al	; and the mask with the right byte
X	jmp	exit_herc_bios
X;
Xexor_pix:		; exclusive-or the pixel
X	mov	ah,07fH		; mask to rid 7th bit
X	and	ah,bl		; pixval w/o XOR flag
X	jnz	do_exor		; ExOr with a 1?
X	jmp	exit_herc_bios	; no! XOR (0,x) = x. just return.
Xdo_exor:
X	xor	es:[si],al	; EXOR the pixel with the mask.
X	jmp	exit_herc_bios
X;
Xread_pix:		; read the pixel
X	and	al,es:[si]	; read the bit into AL
X	jz	rd_zro
X	mov	al,1		; if it ain't zero, it's one
Xrd_zro:	jmp	exit_herc_bios
X;
X;
Xend_herc:			; label for end of package. Used by hercbios
X				;    to install it.
X;
Xcseg	ends
X	end
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hcharset.asm
X;**************************************************************
X;*
X;*	Tests Hercules BIOS, specifically the functions 9 & 10
X;*	to put characters on the screen in graphics mode.
X;*
X;***************************************************************
XVIDI	equ	10H		; video interrupt, 10H (50H for debug)
Xcseg	segment	common
X	assume	cs:cseg,ds:cseg
XSTART	proc
X;			; prompt for IBM or Hercules graphics mode
X	mov	ah,9		; DOS 9 = display string
X	mov	dx,offset mode_prmt+100H
X				; display mode prompt
X	int	21H		; DOS function
X	mov	ah,1		; DOS 1 = kbd input
X	int	21H
X	mov	bl,al		; input char --> BL
X	mov	ax,6		; ibm graphics mode
X	cmp	bl,"h"		; input "h" for Hercules
X	jne	i_mode
X	add	ax,2		; hercules mode
Xi_mode:	int	VIDI
X;
X	xor	bh,bh		; page 0
X	mov	bl,7		; normal attribute
X	mov	dh,1		; cursor at <1,1> to start
X	mov	dl,1
X;
X	mov	cx,24		; do 24 rows
Xrow:	push	cx		; save row counter
X	inc	dh		; next row
X	mov	dl,0		; back to first column
X	mov	ah,2		; cursor move function
X	int	VIDI
X;			; compute video mode
X	mov	bl,dh		; row # to BL
X	xor	bh,bh
X	shr	bl,1		; 4 rows per mode
X	shr	bl,1
X	mov	bl,mode_seq[bx+100H]	; index into mode sequence for mode
X;
X;			; for debug, first print [row+64]
X	mov	al,dh
X	add	al,64
X	mov	ah,10		; fn 10 prints w/o attributes
X	mov	cx,1
X	int	VIDI
X;
X	xor	bh,bh		; page 0
X	mov	cx,64		; each row 64 characters
Xachar:	push	cx		; save char counter
X	mov	ah,9		; write_char function
X	mov	al,dh		; character = col + (row mod 2)*64
X	and	al,1		; row mod 2
X	ror	al,1		; *128
X	shr	al,1
X	add	al,dl		; + col
X	mov	cx,1		; write one of them
X	int	VIDI
X	inc	dl		; increment row counter
X	mov	ah,2		; cursor move function
X	int	VIDI
X	pop	cx		; restore character counter
X	loop	achar
X	pop	cx		; restore row counter
X	loop	row
X;
X;			; draw a line where it should start
X	mov	dx,5		; row 5
X	mov	cx,0		; col 0
Xline:	push	cx
X	push	dx
X	mov	ax,0C01H	; function 12=pixel
X	int 	VIDI
X	pop	dx
X	pop	cx
X	inc	cx		; step col
X	cmp	cx,700		; ...until 700
X	jle	line
X;
X;			; wait for a keystroke
X	mov	ah,1
X	int	21H
X;
X	mov	ax,7		; back to alpha mode
X	int 	VIDI
X;
X;	  		; Now return to system
X	xor	ax,ax		; zero --> AX
X	int	21H		; DOS function call 0 - terminate normally
X;
Xmode_prmt	db	"hercules or ibm mode? [ibm] $"
Xmode_seq	db	7,0Fh,1,70h,0,9	; sequence norm,hi,ul,rev,invis,norm
XSTART	endp
Xcseg	ends
X        end     START
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercbios.asm
X;*******************************************************
X;*
X;*	Main program file for HERCBIOS
X;*
X;*		Dave Tutelman - 8/86
X;*
X;*------------------------------------------------------
X;*	
X;*	INT10 -- acts as pre-handler for video interrupts
X;*	(BIOS calls) for Hercules & SuperComputer
X;*	monochrome graphics board.  Calls real BIOS
X;*	if not a Hercules special. Handled here are:
X;*
X;*	Fn 0	Set mode (only 6 & 8)
X;*	and all functions, when in mode 6 or 8.
X;*	Actually, we've only implemented:
X;*	Fn 2	Set cursor position
X;*	Fn 3	Read cursor position
X;*	Fn 5	New display page
X;*	Fn 9	Write character with attribute
X;*	Fn 10	Write character
X;*	Fn 12	Write pixel
X;*	Fn 13	Read pixel
X;*	Fn 14	Teletypewriter-style character write
X;*	Fn 15	Get video status
X;*
X;*	The only allowable modes for these boards are:
X;*	6	IBM graphics (we handle it, but poor aspect ratio).
X;*	7	Monochrome (with 2 pages)
X;*	8	Hercules graphics mode.
X;*
X;**********************************************************
X;
XINCLUDE	hercbios.h
X
Xextrn	writechar:near,tty:near,scroll_up:near,scroll_down:near
Xextrn	scr_start:word,scr_length:word,num_rows:byte
Xextrn	wr_pixel:near
Xextrn	end_herc:near
Xpublic	exit_herc_bios,int10,vid_vector
Xpublic	set_mode,set_curs,read_curs,new_page,status
X;-----------------------------------------
Xpage
X;************************************************************
X;*
X;*	Install the Hercules video handler
X;*
X;************************************************************
Xcseg	segment	public
X	assume	cs:cseg,ds:cseg
X
X	ORG	100h
X;
XSTART:
X;
X	push	ax
X	push	es
X	push	ds
X;
X	xor	ax,ax		; zero the acc
X	mov	es,ax		; ES points to zero (interrupt vector)
X    ; Get ROM BIOS video entry point, and save in "rom_bios"
X	mov	ax,es:[4*VIDI]
X	mov	word ptr cs:rom_bios,ax
X	mov	ax,es:[4*VIDI+2]
X	mov	word ptr cs:rom_bios+2,ax
X    ; Now plant the HERCBIOS entry point in interrupt vector
X	mov	ax,offset int10	; address of video handler to AX
X	mov	es:[4*VIDI],ax	; and store it in interrupt vector 10H
X	mov	ax,cs		; same for the segment of video handler
X	mov	es:[4*VIDI+2],ax	; ...
X;
X;   Leave the message that we're installed
X	mov	ax,cs		; DS:DX pointing to message
X	mov	ds,ax
X	mov	dx,offset install_msg
X	mov	ah,9		; display-string function
X	int	21h
X
X	pop	ds
X	pop	es
X	pop	ax
X;
X	mov	dx,offset end_herc	; set dx to end of this program
X	int	27H		; terminate, but stay resident
X;
Xinstall_msg	db	"BIOS for Hercules-compatible Graphics - "
X	db		"(DMT Aug 1986)",10,13,'$'
Xpage
X;************************************************************
X;*
X;*	Beginning of video interrupt handler
X;*
X;************************************************************
X;
X;
Xint10	proc	far
X;
X	sti			; allow further interrupts
X	push	ds		; save DS
X	push	ax		; save AX
X	mov	ax,bios_data	; bios data segment --> AX
X	mov	ds,ax		; now put bios data segment in DS
X	assume	ds:bios_data	; and tell assembler about it
X;			; check current mode
X	mov	ah,video_mode	; get current mode
X	cmp	ah,herc_mode	; test for a graphics mode
X	je	herc_bios
X	cmp	ah,ibm_mode
X	je	herc_bios
X;			; setmode to a graphics mode?
X	pop	ax		; restore AX
X	push	ax		; ...but leave it on stack
X	cmp	ax,0006		; Fn = set to IBM hi-res mode?
X	je	herc_bios
X	cmp	ax,0008		; Fn = set to Herc graphics mode?
X	je	herc_bios
X;
Xnorm_bios:		; if we get here, just go to real BIOS
X	pop	ax		; restore stack to pre-interrupt state
X	pop	ds
X	db	0EAh	; opcode for FAR JUMP to rom_bios
Xrom_bios	dd	?	; normal video bios address (in ROM)
X;
Xherc_bios:		; jump table for special Hercules BIOS
X;
X	pop	ax	; restore ax
X	push	bx	; save regs
X	push	cx
X	push	dx
X	push	si
X	push	di
X	push	es
X;
X	push	ax
X	mov	al,ah		; function # to AX
X	xor	ah,ah
X	shl	ax,1		; *2 for word vector
X	mov	si,ax		; put in SI to index into vector
X	pop	ax		; restore old AX
X	cmp	si,offset vid_vec_end-offset vid_vector
X				; function number within range?
X	jge	exit_herc_bios	; function number out of range
X	add	si,offset vid_vector
X	jmp	word ptr cs:[si]
X				; jump to routine via vector
X;
X
Xvid_vector:		; jump vector for hercules video routines
X	dw	offset set_mode			; 0 = set mode
X	dw	offset exit_herc_bios		; 1 = cursor type (NA)
X	dw	offset set_curs			; 2 = set cursor position
X	dw	offset read_curs		; 3 = read cursor position
X	dw	offset exit_herc_bios		; 4 = light pen (NA)
X	dw	offset new_page			; 5 = choose active page
X	dw	offset scroll_up		; 6 = scroll up
X	dw	offset scroll_down		; 7 = scroll down
X	dw	offset exit_herc_bios		; 8 = read character (NA)
X	dw	offset writechar		; 9 = write char & attribute
X	dw	offset writechar		;10 = write character
X	dw	offset exit_herc_bios		;11 = set color palette (NA)
X	dw	offset wr_pixel			;12 = write pixel
X	dw	offset wr_pixel			;13 = read pixel
X	dw	offset tty			;14 = teletype write
X	dw	offset status			;15 = return video state
Xvid_vec_end:
X;
Xexit_herc_bios:
X	pop	es	; restore regs
X	pop	di
X	pop	si
X	pop	dx
X	pop	cx
X	pop	bx
X	pop	ds
X	iret		; and return
Xpage
X;********************************************************************
X;*
X;*	FUNCTION 0 - SET VIDEO MODE
X;*
X;*	Only gets here to set a hi-res graphics mode
X;*		6=IBM
X;*		8=Hercules
X;*	[ AX destroyed ]
X;*
X;*******************************************************************
X;
Xset_mode:
X;			; is it a graphics mode?
X	cmp	al,herc_mode	; set to hercules mode?
X	je	g_mode
X	cmp	al,ibm_mode	; set to IBM mode?
X	je	g_mode
X				; Neither. Leave it to normal BIOS
X	pop	es		; restore regs
X	pop	di
X	pop	si
X	pop	dx
X	pop	cx
X	pop	bx
X	pop	ds
X	jmp	vid_bios	; and go to MPX-16 BIOS
X;
Xg_mode:	mov	video_mode,al	; save video mode in BIOS data area
X	mov	active_page,ah	; zero the active page in BIOS data
X	mov	n_cols,90	; 90 character columns in graphics mode
X;
X;*  clear display area
X	mov	ax,pixbase	; get starting address
X	mov	es,ax		; page base to ES
X	mov	cx,8000H	; word counter
X	mov	di,0		; start at beginning of display
X	cld			; direction "up"
X	xor	ax,ax		; zero AX
X	rep	stosw		; write zero to both pages
X;
X;*  load the 6845 internal registers
X;
X;			; first set up the loop
X	push	ds		; save DS
X	mov	ax,cs		; get cseg into DS
X	mov	ds,ax
X	assume	ds:cseg
X	mov	dx,vid_port	; 6845 index port address to DX
X	mov	si,offset vid_parm_table
X				; table pointer to SI
X	mov	cx,16		; 16 parameters in table
X	xor	ax,ax		; zero AX (AH will be index counter)
X;			; now execute the loop
Xinit_6845_loop:
X	mov	al,ah		; index counter to AL
X	out	dx,al		; output index to 6845
X	inc	dx		; point DX to data reg
X	mov	al,[si]		; get table entry
X	out	dx,al		; output to 6845 data reg
X	dec	dx		; point DX back to index reg
X	inc	ah		; bump index counter
X	inc	si		; bump table pointer
X	loop	init_6845_loop
X	pop	ds		; restore DS
X	assume	ds:bios_data	; restore DS assumed
X;
X;*  now set the 6845 control register
X	mov	dx,vid_port+4	; control port address
X	mov	al,0AH		; graphics control byte
X	cmp	active_page,0	; get current page
X	je	pg0_F0		; skip if zero
X	or	al,80H		; page 1 to control byte
Xpg0_F0:	out	dx,al		; and ship to 6845
X	mov	chip_ctrl,al	; also save in bios data area
X;
X;*  save cursor position (0,0) in bios data area
X	xor	ax,ax		; zero AX
X	mov	curs_pos,ax	; write zero to pg.0 cursor postion
X	mov	curs_pos+2,ax	; write zero to pg.1 cursor postion
X;
X;*  initialize scrolling parameters
X;
X	cmp	video_mode,herc_mode
X	je	h_parm
X	mov	cs:scr_start,180	; IBM parameters
X	mov	cs:scr_length,3690	;
X	mov	cs:num_rows,42		;
X	jmp	parm_done
Xh_parm:	mov	cs:scr_start,270	; Herc parameters
X	mov	cs:scr_length,3645	;
X	mov	cs:num_rows,28		;
Xparm_done:
X;
X	jmp	exit_herc_bios
X;
X;*  table of 6845 chip parameters
X;
Xvid_parm_table	db	53,45,46,7,91,2,87,87,2,3,62H,3,0,0,0,0
X;vid_parm_table	db	54,45,46,8,91,2,87,87,2,3,62H,3,0,0,0,0
X						;DMT's monitor
Xpage
X;********************************************************************
X;*
X;*	FUNCTION 2 - SET CURSOR POSITION
X;*
X;*	DX = new row (DH) and column (DL)
X;*	BH = display page number
X;*
X;********************************************************************
X;
Xset_curs:
X;
X; *   save in BIOS data area
X	mov	bl,bh		; page # to bl
X	xor	bh,bh		; zero bh (page # = BX)
X	shl	bx,1		; times 2 for word
X	mov	curs_pos[bx],dx	; store in data area
X;
X; *   if page # = active page, then we should actually move cursor
X; *  		However, cursor doesn't show in graphics mode, so we won't.
X;
X	jmp	exit_herc_bios
X;
Xpage
X;********************************************************************
X;*
X;*	FUNCTION 3 - READ CURSOR POSITION
X;*
X;*	on entry
X;*		BH = display page number
X;*
X;*	on exit
X;*		CX = cursor type/size
X;*		DX = current row (DH) and column (DL)
X;*
X;********************************************************************
X;
Xread_curs:
X;			; uncover the return portion of the stack
X	pop	es
X	pop	di
X	pop	si
X	pop	dx
X	pop	cx
X;			; now get the data and push onto stack
X	push	curs_mode	; cursor type to CX position in stack
X	mov	bl,bh		; page # to BX
X	xor	bh,bh
X	shl	bx,1		; *2 for word offset
X	push	curs_pos[bx]	; cursor position for specified page
X				;   to DX position in stack
X;			; refill the stack for return
X	push	si
X	push	di
X	push	es
X;
X	jmp	exit_herc_bios
Xpage
X;********************************************************************
X;*
X;*	FUNCTION 5 - SELECT NEW DISPLAY PAGE
X;*
X;*	AL = new display page number
X;*
X;********************************************************************
X;
Xnew_page:
X	cmp	al,2		; page < 2?
X	jl	f5_1		; yup
X	jmp	exit_herc_bios	; nope. can't do it.
X;
Xf5_1:	mov	active_page,al	; put away active page in bios data
X;  * put starting address in 6845 register 12
X	mov	ah,al		; save page number in AH
X	mov	dx,vid_port	; index pointer address
X	mov	al,12		; save in register 12
X	out	dx,al		; and set index pointer to 12
X	mov	al,ah		; restore page to AL
X	ror	al,1		; page to high-order bit
X	shr	al,1		; two bytes per word
X	inc	dx
X	out	dx,al		; ...and output it to register
X;  * put control byte in 6845 port
X	mov	al,ah		; get back page number
X	ror	al,1		; page to high-order bit
X	or	al,0AH		; create chip control byte
X	mov	chip_ctrl,al	; save it in data area
X	mov	dx,vid_port+4	; control port address
X	out	dx,al		; send control byte to chip
X;
X	jmp	exit_herc_bios
Xpage
X;***********************************************************************
X;*
X;*	FUNCTION 15 - RETURN VIDEO STATUS
X;*
X;*	On exit:
X;*		AL = current video mode
X;*		AH = number of active display columns
X;*		BH = current active page number
X;*
X;***********************************************************************
X;
Xstatus:
X;			; first uncover the stack
X	pop	es
X	pop	di
X	pop	si
X	pop	dx
X	pop	cx
X	pop	bx
X;			; now get the parameters needed
X	mov	al,video_mode
X	mov	ah,90		; all our graphics modes have 90 cols
X	mov	bh,active_page
X;			; and push back onto the stack for return
X	push	bx
X	push	cx
X	push	dx
X	push	si
X	push	di
X	push	es
X;
X	jmp	exit_herc_bios
X;
Xint10	endp
X;
Xcseg	ends
X	end	START
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercbios.aut
X
X================================================================================
X
XNewsgroups: net.sources
XPath: decwrl!pyramid!hplabs!hao!nbires!seismo!caip!clyde!cbatt!cbosgd!ihnp4!drutx!mtuxo!mtuxt!dmt
XSubject: Hercules graphics BIOS
XPosted: 28 Aug 86 02:47:07 GMT
XOrganization: AT&T Information Systems, Holmdel NJ
X 
X 
XWell, here's the promised Hercules driverfor the PC.  It's in SHAR format,
Xand the instructions for assembly and use are in "hercbios.doc".
XEnjoy!
X---------------------------------------------------------------
X       ---===		Dave Tutelman
X    -------=====	Physical - AT&T Information Systems
X  ----------======		Room 1H120
X ==--------========		Juniper Plaza, Route 9
X  ====---=========		Freehold, NJ 07728
X    ============	Logical  - ...ihnp4!mtuxo!mtuxt!dmt
X       ======		Audible  - (201)-577-4232
X---------------------------------------------------------------SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercbios.h
X.XLIST
X	page	66,132
X;************************************************************
X;
X;	Header file for inclusion in HERCBIOS assemblies
X;
X;		Dave Tutelman - 8/86
X;
X;*************************************************************
X
X;iAPX286	equ	1	; UN-COMMENT FOR A 186 or 286 MACHINE!
X				;   Some of the "ugly" constructs are for speed
X				;   on the 808X, while the "obvious" constructs
X				;   run faster on the 186 & 286.
XVIDI		equ	10H	; video interrupt, 10H for real, 50H for debug
Xpixbase		equ	0B000H	; beginning segment of graphics board
Xmpx_bios	equ	0F000H	; MPX-16 BIOS segment address
Xvid_offset	equ	0F065H	; MPX-16 video offset in BIOS
Xcharbase	equ	0FA6EH	; MPX-16 BIOS character table offset
Xherc_mode	equ	8	; Hercules graphics mode
Xibm_mode	equ	6	; IBM Hi-Res color graphics mode.
X				; we'll try to handle it.
Xvid_port	equ	03B4H	; 6845 index register (data reg = 3B5H )
X				;		      (control port = 3B8H )
X;------------------------------------------
Xbios	segment at	mpx_bios	; setup call to vid_bios
X		org	vid_offset
Xvid_bios	proc	far
Xvid_bios	endp
Xbios		ends
X;------------------------------------------------
Xbios_data    segment at 040h
X		org	049h
Xvideo_mode	db	?	; current video mode
Xn_cols		dw	?	; number of columns in video display
X		org	050h
Xcurs_pos	dw	8 dup(?) ; cursor for each of 8 pages
Xcurs_mode	dw	?	; cursor mode
Xactive_page	db	?	; current active display page
Xvideo_base	dw	?	; video port base
Xchip_ctrl	db	?	; current setting of 3X8 register
Xbios_data ends
X;------------------------------------
Xintvec	     segment at 0		; interrupt vector
X		org	4*1Fh		; interrupt 1FH
Xuser_table	dd	?
Xintvec	     ends
X;------------------------------------
X
XIFDEF	iAPX286
X	.286c			; allow 286/186-only instructions
XENDIF
X
X.LIST
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercdemo.asm
X        page    ,132
X	title	hercdemo - quick and dirty herc demo
X;
X; Hercdemo - (c) 1986 by Reid Brown, P.O. Box 1023, Issaquah, WA.  98027
X;
X;	This is a quick and dirty program to show off the Hercules
X;	board.  I place if freely into the public domain so others
X;	can diddle their Herc boards as well, so long as it is not
X;	used for any commercial purposes.
X;
X
Xmessage	macro	row,col,string
X	mov	cx,row
X	mov	bx,col
X	mov	si,offset string
X	call	print
X        endm
X
Xhdraw	macro	row,col,len
X	mov	cx,row
X	mov	bx,col
X	mov	dx,len
X	call	hline
X        endm
X
Xvdraw	macro	row,col,len
X	mov	cx,row
X	mov	bx,col
X	mov	dx,len
X	call	vline
X        endm
X
Xcode    segment
X	assume	cs:code, ds:code, es:code, ss:code
X        org     100h
Xstart:	jmp	begin
X
XIBMROM	equ	0F000h
XCHARTAB	equ	0FA6Eh
XHERCSEG	equ	0B800h
X
XMODEPORT equ	3B8h
X
XSTRING0 db      'HERCULES DEMO',0
XSTRING1	db	'A funny thing happened on the way to the forum.',0
XSTRING2	db	'You, too, can have a rewarding career in computers...',0
XSTRING3 db      'Strike any key to proceed...',0
X
X
XCON8	db	8
XCON180	db	180
X
Xbegin	proc	near
X	mov	dx, MODEPORT		; select herc mode port
X	mov	al, 08Ah
X	out	dx, al			; graphics mode, video on, page 1
X
X	call	graphics		; set 6845 for graphics
X        call    clear			; clear screen RAM
X
X        vdraw   10,5,20                 ; draw a vertical
X        vdraw   10,65,20                ; - hopefully, a box!
X        hdraw   10,6,60                 ; draw a line
X        hdraw   30,6,60                 ; and another
X
X        message 12,29,STRING0           ; 1st message
X        message 17,10,STRING1           ; 2nd message
X        message 23,10,STRING2           ; 3nd message
X        message 29,20,STRING3           ; ...
X        
X;
X; done - clean up and reset
X;
X        mov	ax, 0C07h		; flush buffer, read char
X	int	21h			; wait for any input
X
X        call    text                    ; reset 6845
X
X	mov	dx, MODEPORT		; select herc mode port
X	mov	al, 00001000B		; re-enable mono
X	out	dx, al
X        
X	mov	ax, 4C00h
X	int	21h			; exit
Xbegin	endp
X
X;
X; print - print text in graphics mode
X;
X;	cx = row
X;	bx = column
X;	si = address of string (null terminated) to print
X;
Xprint	proc	near
X
Xloop:	lodsb				; get next char
X	or	al, al			; end of display?
X	je	pdone
X	call	display
X	inc	bx			; bump to next column
X	jmp	loop
Xpdone:	ret
X
Xprint	endp
X
X;
X; display - output an 8x8 character from the IBM ROM to the Herc board
X;
X; AX = char, BX = column (0-89), CX = row(0-42)  ** all preserved **
X;
Xdisplay	proc near
X	push	ds			; save the lot
X	push	es
X	push	ax
X	push	bx
X	push	cx
X	push	dx
X	push	si
X	push	di
X
X; setup ds -> IBM ROM, and si -> index into IBM ROM character table located
X;	at 0fa6eh in the ROM
X
X	and	ax, 07fh
X	mul	CS:CON8			; mult by 8 bytes of table per char
X	mov	si, ax
X	mov	ax, IBMROM
X	mov	ds, ax
X	assume	ds:nothing
X	add	si, CHARTAB		; add offset of character table
X
X; compute index into Hercules screen memory for scan line 0.  The remaining
X;	seven scan lines are all at fixed offsets from the first.
X;
X;	Since graphics mode treats the screen as sets of 16x4 "characters",
X;	we need to map an 8x8 real character onto the front or back of
X;	a pair of graphics "characters".  The first four scan lines of our
X;	8x8 character will map to the top graphics "character", and the second
X;	four scan lines map to the graphics character on the "line" (4 scan
X;	lines high) below it.
X;
X;	For some exotic hardware reason (probably speed), all scan line 0
X;	bits (i.e. every fourth scan line) are stored in memory locations
X;	0-2000h in the screen buffer.  All scan line 1 bits are stored
X;	2000h-4000h.  Within these banks, they are stored by rows.  The first
X;	scan line on the screen (scan line 0 of graphics character row 0)
X;	is the first 45 words of memory in the screen buffer.  The next 45
X;	words are the first scan line graphics row 1, and since graphics
X;	"characters" are 4 bits high, this second scan line is physically
X;	the fifth scan line displayed on the screen.
X;
X;	SO, to display an 8x8 character, the 1st and 5th rows of dots are
X;	both scan line 0 of the graphics "character", the 2nd and 6th are
X;	scan line 1, and so on.
X;
X;	The column (0-89) tells which byte in a scan line we need to load.
X;	Since it takes two rows of graphics characters to hold one row of
X;	our characters, column+90 is a index to scan line 4 rows of pixels
X;	higher (n+4).  Thus 180 bytes of screen memory in any bank (0h, 2000h,
X;	4000h, 6000h) represent a row of 8x8 characters.
X;	
X;	The starting location in screen memory for the first scan line of
X;	a character to be displayed will be:  	(row*180)+column
X;	The 5th scan line will be at:		(row*180)+column+90
X;
X;	The second and 6th scan lines will be at the above offsets plus
X;	the bank offset of 2000h.  The third and 7th, add 4000h and finally
X;	the 4th and 8th, add 6000h.
X;
X	mov	ax, HERCSEG
X	mov	es, ax			; es = hercules page 0
X	mov	ax, cx			; get row
X	mul	CS:CON180		; mult by 180(10)
X	mov	di, ax			; di = index reg
X	cld				; insure right direction
X
X;output 8 segments of character to video ram
X
X	lodsb				; line 0
X	mov	es:[di+bx], al
X	lodsb
X	mov	es:[di+bx+2000h], al	; line 1
X	lodsb
X	mov	es:[di+bx+4000h], al	; line 2
X	lodsb
X	mov	es:[di+bx+6000h], al	; line 3
X	lodsb
X	mov	es:[di+bx+90], al	; line 4
X	lodsb
X	mov	es:[di+bx+2000h+90], al	; line 5
X	lodsb
X	mov	es:[di+bx+4000h+90], al	; line 6
X	lodsb
X	mov	es:[di+bx+6000h+90], al	; line 7
X
X	pop	di
X	pop	si
X	pop	dx
X	pop	cx
X	pop	bx
X	pop	ax
X	pop	es
X	pop	ds
X	ret
Xdisplay	endp
X
X;
X; clear - clear page 1 of the screen buffer to zero (effectively, blank
X;	the screen)
X;
Xclear   proc
X        push    es
X        push    ax
X        push    cx
X        push    di
X
X	mov	ax, HERCSEG
X	mov	es, ax
X	xor	di, di
X	mov	cx, 4000h
X	xor	ax, ax
X	cld
X
X	rep stosw			; zero out screen page
X	
X	pop	di
X	pop	cx
X	pop	ax
X	pop	es
X	ret
Xclear	endp
X
X;
X; hline - draw a horizontal line at scan line 0 of a specified 8x8 character
X;	cell sized row, for a specified no. of characters
X;
X;	cx = row
X;	bx = col
X;	dx = len
X;
Xhline    proc near
X        push    es
X        push    ax
X        push    cx
X        push    di
X
X	mov	ax,cx			; copy to accum for multiply
X	mul	cs:CON180		; mult by 180 to get offset
X	mov	di,ax			; copy to dest ptr
X	add	di,bx			; add column offset
X	mov	cx,dx			; put byte count in count reg
X	mov	ax, HERCSEG
X	mov	es, ax
X        mov     ax, 0ffh		; pattern = all bits ON
X	cld
X
X	rep stosb			; put bits on screen
X	
X	pop	di
X	pop	cx
X	pop	ax
X	pop	es
X	ret
X
Xhline    endp
X
X;
X; vline - draw a vertical line in the last bit position of a given char
X;	cell, extending downward for a specified no. of chars
X;
X;	cx = row
X;	bx = col
X;	dx = len
X;
Xvline    proc near
X        push    es
X        push    ax
X        push    cx
X        push    di
X
X	mov	ax,cx			; copy to accum for multiply
X	mul	cs:CON180		; mult by 180 to get offset
X	mov	di,ax			; copy to dest ptr
X	mov	cx,dx			; put byte count in count reg
X	mov	ax, HERCSEG
X	mov	es, ax
X        mov     ax, 1			; pattern = last bit on
X
Xvloop:	mov	es:[di+bx], al
X	mov	es:[di+bx+2000h], al	; line 1
X	mov	es:[di+bx+4000h], al	; line 2
X	mov	es:[di+bx+6000h], al	; line 3
X	mov	es:[di+bx+90], al	; line 4
X	mov	es:[di+bx+2000h+90], al	; line 5
X	mov	es:[di+bx+4000h+90], al	; line 6
X	mov	es:[di+bx+6000h+90], al	; line 7
X	add	di,180		        ; advance to next line
X	loop	vloop			; continue for all rows
X	
X	pop	di
X	pop	cx
X	pop	ax
X	pop	es
X	ret
X
Xvline    endp
X
Xgraphics proc near
X	mov	si, offset graph_parms
Xg_cont:	mov	dx, 3b4h		; point to index reg
X	mov	cx, 16
X	xor	ax, ax
Xg_loop:	mov	al, ah
X	out	dx, al
X	inc	dx
X	mov	al, [si]
X	out	dx, al
X	dec	dx
X	inc	ah
X	inc	si
X	loop	g_loop
X	ret
Xgraph_parms db	35h,2dh,2eh,7,5bh,2,57h,57h,2,3,0,0,0,0,0,0
Xgraphics endp
X
Xtext	proc	near
X	mov	si, offset text_parms
X	jmp	g_cont
Xtext_parms db	61h,50h,52h,0fh,19h,6,19h,19h,2,0dh,0bh,0ch,00,00,00,00
Xtext	endp
X
X
Xcode    ends
X
X	end	start
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercmake.att
X
X# Makefile for HERCBIOS.COM
XSRC=hercbios gchar graph
XDEST=a:
X
Xhercbios.com : hercbios.obj gchar.obj graph.obj
X	link hercbios gchar graph,,/MAP;
X	exe2bin  hercbios.exe  hercbios.com
X	del hercbios.exe
X
Xhercbios.obj : hercbios.asm hercbios.h
Xgchar.obj : gchar.asm hercbios.h
Xgraph.obj : graph.asm hercbios.h
X
X
X# Makes for the demo & test program, using deSmet C
X
Xtestpix.exe : testpix.o hercpixl.o
X	bind testpix hercpixl
X
Xtestpix.o : testpix.c
X	c88 testpix
X
Xhercpixl.o : hercpixl.c
X	c88 hercpixl
X
X# Make a backup or distribution disk
Xbackup :
X	for %f in ($(SRC)) do  copy %f.asm $(DEST)
X	copy hercbios.h   $(DEST)
X	copy hercbios.com $(DEST)
X	copy hercbios.doc $(DEST)
X	copy makefile $(DEST)
X
Xdistrib :
X	make backup
X	copy hercpixl.c $(DEST)
X	copy testpix.* $(DEST)
X	copy hcharset.* $(DEST)SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercmake.lcm
X#
X# Makefile for HERCBIOS.COM
X#       (designed for Larry Campbell's version of MAKE)
X#
X
Xhercbios.com : hercbios.obj gchar.obj graph.obj
X	link hercbios gchar graph,,/MAP;
X	exe2bin  hercbios.exe  hercbios.com
X	del hercbios.exe
X
Xhercbios.obj : hercbios.asm hercbios.h
X        masm hercbios,,;
X
Xgchar.obj : gchar.asm hercbios.h
X        masm gchar,,;
X
Xgraph.obj : graph.asm hercbios.h
X        masm graph,,;
X
X
X#
X# Makes for the demo & test program, using Lattice
X#       (Note: you may have to change the drive and path specs)
X#
X
Xtestpix.exe : testpix.obj hercpixl.obj
X	link g:\lc\s\c testpix hercpixl,testpix,testpix/m,g:\lc\s\lc
X
Xtestpix.obj : testpix.c
X	lc -ms -n -ig:\lc\ testpix
X
Xhercpixl.obj : hercpixl.c
X	lc -ms -n -ig:\lc\ hercpixl
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercpixl.dc
X/*
X *	HERCPIXL.C
X *	Dave Tutelman  -  last modified 8/86
X *
X *	This is a set of basic graphic routines for the Hercules
X *	Board (or at least the SuperComputer version of it; I assume
X * 	that they work with the real thing).
X *		alfa ()		puts us in alphanumeric mode.
X *		grafix (page)	puts us in graphics mode in page 0 or 1
X *		pixel (x,y,val)	puts a pixel at <x,y>. Bright dot if
X *				val=1, dark dot if val=0.
X * 		dchar (x,y,c)	puts character "c" at <x,y>. Note that
X *				character raster is 90 x 29.
X *		swpage (page)	switches to a different page.
X *	        waitkey ()	just waits till a key is pressed.
X *
X *	Actually, the routines should work with any board, since the
X *	BIOS calls are used throughout.  It's Hercules-specific only
X *	because I've defined the graphics and alpha modes for my
X *	Hercules BIOS.
X *
X *	Compile with deSmet C.
X */
X
X#define VIDI    0x10		/* video interrupt, normally 10H  */
X#define	KBD	0x16		/* keyboard interrupt */
X#define ALFA_MODE	7	/* monochrome alpha mode */
X#define GRAF_MODE	8	/* Hercules graphics mode */
X
Xint	page = 0;
Xextern unsigned _rax,_rbx,_rcx,_rdx;
X
X/*
X * This puts us back in alphanumeric mode 
X */
X
Xalfa (dummy)
X	unsigned int dummy;
X{
X	_rax = ALFA_MODE;	/* mono 80-col mode */
X	_doint ( VIDI );	/* set mode */
X}
X
X/*
X *	This one switches us to hercules graphics mode
X *		in page 0 or 1
X */
X
Xgrafix (newpage)
X	int newpage;
X{
X
X	_rax = GRAF_MODE;			/* herc grafix mode */
X	_doint ( VIDI );	/* set mode */
X
X	/*  now set the page */
X	swpage (newpage);
X}
X
X/*
X *   This writes a pixel at (x,y), where (0,0) is the upper-left
X *   corner of the screen.  If val = 0 then the pixel is erased.
X */
X
Xpixel (x, y, val)
X	int x, y, val;
X{
X
X	_rax = 0x0C00 + val;	/* function 12      */	
X	_rcx = x;
X	_rdx = y;
X	_doint ( VIDI );	/* set mode */
X
X}
X
X
X/*
X *	dchar (x,y,c)	puts character "c" at <x,y>. Note that
X *			character raster is 90 x 25.
X */
X
Xdchar (x,y,c)
X	int x,y;
X	char c;
X{
X
X	_rax = 2*256;		/* AH=Fn#2 */
X	_rdx = 256*y + x;		/* DH=row, DX=col */
X	_rbx = page * 256;		/* BH=page  */
X	_doint (VIDI);		/* set cursor */
X
X	_rax = 10*256 + (int) c;	/* AH=Fn#10, AL=char */
X	_rbx = page * 256;		/* BH=page */
X	_rcx = 1;			/* CX=count */
X	_doint (VIDI);		/* write character */
X}
X
X
X/*
X *	This one switches us to a different page, without changing
X *	the contents of that page.
X */
X
Xswpage (newpage)
X	int 	newpage;
X{
X	page = newpage;
X	_rax = 0x500 + page;		/* new page function */
X	_doint ( VIDI );	/* interrupt call */
X}
X
X
Xwaitkey ()
X{
X	_rax = 0;		/* keyboard blocking read function */
X	_doint (KBD);
X}
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > hercpixl.lc
X/*
X *	HERCPIXL.C
X *	Dave Tutelman  -  last modified 8/86
X *
X *	This is a set of basic graphic routines for the Hercules
X *	Board (or at least the SuperComputer version of it; I assume
X * 	that they work with the real thing).
X *		alfa ()		puts us in alphanumeric mode.
X *		grafix (page)	puts us in graphics mode in page 0 or 1
X *		pixel (x,y,val)	puts a pixel at <x,y>. Bright dot if
X *				val=1, dark dot if val=0.
X * 		dchar (x,y,c)	puts character "c" at <x,y>. Note that
X *				character raster is 90 x 29.
X *		swpage (page)	switches to a different page.
X *	        waitkey ()	just waits till a key is pressed.
X *
X *	Actually, the routines should work with any board, since the
X *	BIOS calls are used throughout.  It's Hercules-specific only
X *	because I've defined the graphics and alpha modes for my
X *	Hercules BIOS.
X *
X *      Modified for Lattice C: Reid L. Brown
X *                              9/4/86
X */
X
X#define VIDI    0x10		/* video interrupt, normally 10H  */
X#define	KBD	0x16		/* keyboard interrupt */
X#define ALFA_MODE	7	/* monochrome alpha mode */
X#define GRAF_MODE	8	/* Hercules graphics mode */
X
Xint	page = 0;
Xstruct {
X    unsigned ax,bx,cx,dx,si,di;
X        } _r;
X
X/*
X * This puts us back in alphanumeric mode 
X */
X
Xalfa (dummy)
X	unsigned int dummy;
X{
X	_r.ax = ALFA_MODE;	/* mono 80-col mode */
X	int86 ( VIDI, &_r, &_r);	/* set mode */
X}
X
X/*
X *	This one switches us to hercules graphics mode
X *		in page 0 or 1
X */
X
Xgrafix (newpage)
X	int newpage;
X{
X
X	_r.ax = GRAF_MODE;	/* herc grafix mode */
X	int86 ( VIDI, &_r, &_r);	/* set mode */
X
X	/*  now set the page */
X	swpage (newpage);
X}
X
X/*
X *   This writes a pixel at (x,y), where (0,0) is the upper-left
X *   corner of the screen.  If val = 0 then the pixel is erased.
X */
X
Xpixel (x, y, val)
X	int x, y, val;
X{
X
X	_r.ax = 0x0C00 + val;	/* function 12      */	
X	_r.cx = x;
X	_r.dx = y;
X	int86 ( VIDI, &_r, &_r);	/* set mode */
X
X}
X
X
X/*
X *	dchar (x,y,c)	puts character "c" at <x,y>. Note that
X *			character raster is 90 x 25.
X */
X
Xdchar (x,y,c)
X	int x,y;
X	char c;
X{
X
X	_r.ax = 2*256;		/* AH=Fn#2 */
X	_r.dx = 256*y + x;		/* DH=row, DX=col */
X	_r.bx = page * 256;		/* BH=page  */
X	int86 ( VIDI, &_r, &_r);	/* set cursor */
X
X	_r.ax = 10*256 + (int) c;	/* AH=Fn#10, AL=char */
X	_r.bx = page * 256;		/* BH=page */
X	_r.cx = 1;			/* CX=count */
X	int86 ( VIDI, &_r, &_r);	/* write character */
X}
X
X
X/*
X *	This one switches us to a different page, without changing
X *	the contents of that page.
X */
X
Xswpage (newpage)
X	int 	newpage;
X{
X	page = newpage;
X	_r.ax = 0x500 + page;		/* new page function */
X	int86 ( VIDI, &_r, &_r );	/* interrupt call */
X}
X
X
Xwaitkey ()
X{
X	_r.ax = 0;		/* keyboard blocking read function */
X	int86 (KBD, &_r, &_r );
X}
SHAR_EOF
echo x - extracting shar
sed 's/^X//' << 'SHAR_EOF' > testpix.c
X
X/*  MAIN tests PIXEL by drawing lines on the screen  */
X
X#include	"stdio.h"
X
Xmain ()
X{
X	int i,j;
X	char	line [90];
X
X	/* first clear screen */
X	grafix (0);
X
X	/* now draw a couple of lines */
X	for (i=0; i<696; i++)
X	{
X		pixel (i, i/2, 1);
X		pixel (i, 348 - i/2, 1);
X	}
X
X	waitkey();		/* wait for CR */
X
X	/* a different pattern on page 1 */
X	swpage (1);
X	for (i=0; i<720; i++)
X	for (j=0; j<348; j=j+50)
X		pixel (i,j,1);
X	for (i=0; i<720; i=i+90)
X	for (j=0; j<348; j++)
X		pixel (i,j,1);
X
X	/* switch back and forth a couple of times */
X	waitkey();
X	swpage (0);
X	waitkey();
X	swpage (1);
X	waitkey();
X	swpage (0);
X	waitkey();
X	swpage (1);
X	waitkey();
X
X#ifndef NOTONE
X	/* add some writing */
X	dline (10, 4, "Hello, there!");
X	dline (10, 5, "Second LINE of text.");
X	dline (10, 6, "all on display page 1.");
X
X	waitkey();
X	for (i=0; i<8; i++)
X		for (j=0; j<32; j++)
X			dchar (j+5, i+13, (char) (32*i+j));
X
X	waitkey();
X#endif
X	/* repeat for page 0 */
X	swpage (0);
X
X#ifndef NOTZERO
X	/* add some writing */
X	dline (10, 4, "Hello, there!");
X	dline (10, 5, "Second LINE of text.");
X	dline (10, 6, "this time on display page 0.");
X
X	waitkey();
X	for (i=0; i<8; i++)
X		for (j=0; j<32; j++)
X			dchar (j+5, i+13, (char) (32*i+j));
X#endif
X
X	waitkey();
X
X	/* back to alpha mode */
X	waitkey();
X	alfa();
X}
X
Xdline (x, y, chstr)	/* write character-string at x,y */
X	int 	x,y;
X	char	chstr [90];
X{
X	int	i;
X	char	*p;
X
X	i=0;
X	for ( p=chstr; *p != '\0'; p++ )
X	{
X		dchar ( x+i, y, *p );
X		i++;
X	}
X}
SHAR_EOF
exit
