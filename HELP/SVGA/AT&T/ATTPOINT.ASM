


;		    TURBO PASCAL CALLABLE
;	       AT&T 640*400 POINT SETTING ROUTINE
;
;Author: Rob Alexander
;	 13217 Emily Lane
;	 Dallas,Tx 75240
;	 214-644-9359
;
;Comments:  I have heavily documented what I have learned about the
;	    AT&T 6300 640*400 graphics and handling the Turbo Pascal
;	    assembly language "interface"; parameter passing etc...
;	    I did this primarily as a reference for future work so
;           I wouldn't have to fight the same battle twice. I hope
;	    others may benefit also.
;
;********************** STACK MEMORY MAP **************************
;
; PROCEDURE Point( X,Y:INTEGER;VAR Test: INTEGER) sets up the stack as
; follows
;  < Top of Stack before Call		>		    {Increasing addr}
;  < X value		       (2 bytes)>  {SP+8}    {BP+10}	^
;  < Y value		       (2 bytes)>  {SP+6}    {BP+8}	*
;  < Test value Segment addr   (2 bytes)>			*
;  < Test value Offset	addr   (2 bytes)>  {SP+2}    {BP+4}	*
;  < Return Address	       (2 bytes)>  {SP}      {BP+2}	*
;  < BP register	       (2 bytes)>  {SP-2}    {BP}	*
;
;*********************************************************************
;
; Define Point Procedure
;
; CONSTANTS DEFINITION
;
    GraphSeg = 0B800H		   ;Graphics Memory Segment Address
;
CODE   SEGMENT
       Assume CS:Code
;
Point  PROC  NEAR
       push  bp 		     ;Save Base pointer
       mov bp,sp		     ;Initialize Base pointer
;      les di,[bp+4]		     ;For test value passing
;****************** 8k BLOCK CALCULATION*****************************
;
;DISCUSSION: In 640 by 400 mode, the 32K graphics memory is divided into
;	  four 8000 byte long blocks. Each block contains the pixel
;	  definitions for 100 rows. According to the AT&T system programmers
;	  guide, the memory map looks like:
;
;     ----------------	  B800:7F3F
;    * Rows	      *
;    * 3,7,11..399    *
;    ------------------   B800:6000
;    ------------------   B800:5F3F
;    * Rows	      *
;    * 2,6,10,..398   *
;    ------------------   B800:4000
;    ------------------   B800:3F3F
;    * Rows	      *
;    * 1,5,9..397     *
;    ------------------   B800:2000  {there are 192 unused bytes between
;    ------------------   B800:1F3F   blocks}
;    * Rows	      *
;    * 0,4,8,..396    *
;    ------------------   B800:0000
;
;
; CALCULATION METHOD:
;
;  1) Read Y (row number) passed from Turbo Pascal
;  2) Determine remainder of Y/4. This is accomplished by masking upper 14
;     bits of Y value so that
;      LSB+1   LSB	  Action
;	0	0	 Y value divisible by 4. Pixel in first 8 k block.
;	0	1	 Remainder of 1/4. Pixel in second 8K block
;	1	0	 Remainder of 1/2. Pixel in third 8K block
;	1	1	 Remainder of 3/4. Pixel in fourth 8K block.
;
;  3) Multiply remainder by 2000H to obtain correct 8K page offset
;
;  CONSTANTS DEFINITION
;
     OffsetMult =  20H		      ;8K offset
     Ymask	=  03H		      ;Row number mask
     OffsetShift = 08		      ;shift count for result of offset calc.
;
; Algorithm: The offset calculation is done as
;
;    a)   ax<----8K_OffsetMult
;    b)   bx<----Row number
;    c)   bx<----Row number (AND) Ymask   {Result is 8K_Block#}
;    d)   ax<----20H*Remainder	{want result in AX register}
;    e)   ax<----20H*256	{Perform shift to obtain proper bit level
;
;    Perform Calculation
;
	mov ax,OffsetMult	     ;Offset multiplier
	mov bx,[bp+8]		     ;Y value passed from Turbo
	mov cl,OffsetShift	     ;Load CL register with shift count
	and bl,Ymask		     ;mask off higher order bits
	mul bl			     ;Find Bank offset
	shl ax,cl		     ;Bring offset to correct bit level
	mov dx,ax		     ;Save 8K_BlockOffset in DX
;
; ************************ Row Block Calculation ***********************
;
; Discussion: According to Systems Programmer guide, each 8K block contains
;	      the pixel values for 100 rows as follows;
;
;					 Row Number    Offset
;   /byte 0/byte 1/......./byte 79/	   99	      8K_BlockOffset+99*80
;   /byte 0/byte 1/......./byte 79/	   98	      8K_BlockOffset+98*80
;
;
;   /byte 0/byte 1/......./byte 79/	    1	      8K_BlockOffset+1*80
;   /byte 0/byte 1/......./byte 79/	    0	      8K_Block#+0*80
;
; CALCULATION METHOD:
;
;   1)	Read Y {row number} from stack
;   2)	Row_Block# = Row Number/4
;   3)	Row_Offset=Row_Block# * 80
;   4)	Offset = 8K_Block Offset + Row_Offset
;
; ALGORITHM
;   a)	ax<---- Row_OffsetMult
;   b)	bx<---- Y value {Row number} passed from Turbo Pascal
;   c)	cl<---- Row_RmdrShift
;   d)	bx<---- Row number/4
;   e)	ax<---- (Row number/4)*80
;   f)	dx<---- 8K_BlockOffset + Row_BlockOffset
;
;  CONSTANTS DEFINITION
;
    Row_RmdrShift  = 80
    Row_BlockShift = 2
;
;  Perform Calculation
;
	mov al,Row_RmdrShift		 ;
	mov bx,[BP+8]			 ;Read Y value passed from Turbo Pascal
	mov cl,Row_BlockShift		 ;
	shr bx,cl			 ;Divide Row number by 4
	mul bl				 ;Find Row_Offset
	add dx,ax			 ;Calculate offset
;
;*********************** COLUMN OFFSET CALCULATION ***********************
;
; Discussion: The pixel values for each row {640 pixels} are stored in
;	      80 bytes. {1 bit per pixel} as shown below
;     /byte 0/byte 1/......./byte n/...../byte 79/
;      ^		      ^
;      |.. Row base address   |..Column Address/8
;
; CALCULATION METHOD:
;
;   1) Column_byte_Addr=X value/8
;
;  CONSTANTS DEFINITION
;
     Column_Shift = 3
;
;  PERFORM CALCULATION
;
     mov ax,[bp+10]		  ;Read X value passed from Turbo Pascal
     mov bx,ax			  ;Save X value for next calculation stage
     mov cl,Column_Shift	  ;Initialize Shift count
     shr ax,cl			  ;Divide X value by 8
     add dx,ax			  ;Save Offset
;
;************************ PIXEL MASK GENERATION **************************
;
;  Discussion: Finally, we're ready to set the pixel. The pixel bit map
;	       looks like
;
;	      /bit 7/ bit 6/......../bit 1/bit 0/
;      pixel 0...^			    ^..pixel 7
;
;	    {the bit map is the reverse from what you would expect}
;
;  CALCULATION METHOD
;
;   1) Pixel No<----- Remainder{Column address,8}
;   2) Pixel Mask<---- 1 shifted by pixel number
;   3) Reg <---- Current Pixel Byte
;   4) Updated Pixel Byte<----Pixel Mask (OR) Pixel Settings
;   5) Mem<----- Pixel Byte
;
;   CONSTANTS DEFINITION
;
     Const= 128
     Pixel_Rmdr_Mask = 0007
;
;  PERFORM CALCULATION
;
	mov ax,GraphSeg
	mov es,ax
	mov di,dx
	and bl,Pixel_Rmdr_Mask		    ;Find remainder of Col#/8
	mov cl,bl			    ;Generate Pixel Mask
	mov bx,Const			    ;
	shr bx,cl
	mov al,byte ptr es:[di] 	    ;Read Current Pixel Setting
	or al,bl			    ;Set pixel
	mov byte ptr es:[di],al
;	mov word ptr es:[di],bx
;
;	restore registers and return to Turbo
;
	mov sp,bp
	pop bp
;************************************************************************
;************************************************************************
;************************************************************************
;********* ATTENTION, ATTENTION, ATTENTION, ATTENTION *******************
;********* In order for External procedure to work,   *******************
;********* you must figure out how many parameters    *******************
;********* were passed on stack {in bytes} and	      *******************
;********* and include that number in return statemt. *******************
;********* In the case of this program; 	      *******************
;*********					      *******************
;*********   X co-ordinate value = 2 bytes	      *******************
;*********   Y co-ordinate value = 2 bytes	      *******************
;*********    Test value address = 4 bytes	      *******************
;*********			   -------	      *******************
;*********			   8 bytes	      *******************
;*********					      *******************
;********* It took me a hell of a long time to figure *******************
;********* that out.- Rob Alexander		      *******************
;************************************************************************
;************************************************************************
;************************************************************************
	ret  08H			     ;Release Stack used for Call
Point	ENDP
Code	ENDS
END
