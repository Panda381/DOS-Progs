/*
	REG8514.H

   Written by Jake Richter
   Copyright (c) 1989,1990 Panacea Inc., Londonderry, NH - All Rights Reserved

   This code may be freely incorporated in any program without
   royalty, as long as the copyright notice stays intact.

	This include file contains the standard definitions necessary for
   programming the IBM 8514/A.

	The following definitions are used in all the listings to reference
   certain data types. This is done to help make the code more readable,
   and to assist later translation and communication with assembly language.
*/

/*
   VESA Approved Register Definitions
*/
#define  DAC_MASK	0x02EA
#define  DAC_R_INDEX	0x02EB
#define  DAC_W_INDEX	0x02EC
#define  DAC_DATA	0x02ED
#define  DISP_STAT	0x02E8
#define  H_TOTAL	0x02E8
#define  H_DISP		0x06E8
#define  H_SYNC_STRT	0x0AE8
#define  H_SYNC_WID	0x0EE8
#define  V_TOTAL	0x12E8
#define  V_DISP		0x16E8
#define  V_SYNC_STRT	0x1AE8
#define  V_SYNC_WID	0x1EE8
#define  DISP_CNTL	0x22E8
#define  ADVFUNC_CNTL	0x4AE8
#define  SUBSYS_STAT	0x42E8
#define  SUBSYS_CNTL	0x42E8
#define  ROM_PAGE_SEL	0x46E8
#define  CUR_Y		0x82E8
#define  CUR_X		0x86E8
#define  DESTY_AXSTP	0x8AE8
#define  DESTX_DIASTP	0x8EE8
#define  ERR_TERM	0x92E8
#define  MAJ_AXIS_PCNT  0x96E8
#define  GP_STAT	0x9AE8
#define  CMD		0x9AE8
#define  SHORT_STROKE	0x9EE8
#define  BKGD_COLOR	0xA2E8
#define  FRGD_COLOR	0xA6E8
#define  WRT_MASK	0xAAE8
#define  RD_MASK	0xAEE8
#define  COLOR_CMP	0xB2E8
#define  BKGD_MIX	0xB6E8
#define  FRGD_MIX	0xBAE8
#define  MULTIFUNC_CNTL 0xBEE8
#define  MIN_AXIS_PCNT  0x0000
#define  SCISSORS_T	0x1000
#define  SCISSORS_L	0x2000
#define  SCISSORS_B	0x3000
#define  SCISSORS_R	0x4000
#define  MEM_CNTL	0x5000
#define  PATTERN_L	0x8000
#define  PATTERN_H	0x9000
#define  PIX_CNTL	0xA000
#define  PIX_TRANS	0xE2E8

/* Display Status Bit Fields */
#define  HORTOG		0x0004
#define  VBLANK		0x0002
#define  SENSE		0x0001

/* Horizontal Sync Width Bit Field */
#define  HSYNCPOL_NEG	0x0020
#define  HSYNCPOL_POS	0x0000

/* Vertical Sync Width Bit Field */
#define  VSYNCPOL_NEG	0x0020
#define  VSYNCPOL_POS	0x0000

/* Display Control Bit Field */
#define  DISPEN_NC	0x0000
#define  DISPEN_DISAB	0x0040
#define  DISPEN_ENAB	0x0020
#define  INTERLACE	0x0010
#define  DBLSCAN	0x0008
#define  MEMCFG_2	0x0000
#define  MEMCFG_4	0x0002
#define  MEMCFG_6	0x0004
#define  MEMCFG_8	0x0006
#define  ODDBNKENAB	0x0001

/* Subsystem Status Register */
#define  _8PLANE	0x0080
#define  MONITORID_8503 0x0050
#define  MONITORID_8507 0x0010
#define  MONITORID_8512 0x0060
#define  MONITORID_8513 0x0060
#define  MONITORID_8514 0x0020
#define  MONITORID_NONE 0x0070
#define  MONITORID_MASK 0x0070
#define  GPIDLE		0x0008
#define  INVALIDIO	0x0004
#define  PICKFLAG	0x0002
#define  VBLNKFLG	0x0001

/* Subsystem Control Register */
#define  GPCTRL_NC	0x0000
#define  GPCTRL_ENAB	0x4000
#define  GPCTRL_RESET	0x8000
#define  CHPTEST_NC	0x0000
#define  CHPTEST_NORMAL 0x1000
#define  CHPTEST_ENAB	0x2000
#define  IGPIDLE	0x0800
#define  IINVALIDIO	0x0400
#define  IPICKFLAG	0x0200
#define  IVBLNKFLG	0x0100
#define  RGPIDLE	0x0008
#define  RINVALIDIO	0x0004
#define  RPICKFLAG	0x0002
#define  RVBLNKFLG	0x0001

/* Current X, Y & Dest X, Y Mask */
#define  COORD_MASK	0x07FF

/* Advanced Function Control Register */
#define  CLKSEL		0x0004
#define  DISABPASSTHRU  0x0001

/* Graphics Processor Status Register */
#define  GPBUSY		0x0200
#define  DATARDY	0x0100

/* Command Register */
#define  CMD_NOP	0x0000
#define  CMD_LINE	0x2000
#define  CMD_RECT	0x4000
#define  CMD_RECTV1	0x6000
#define  CMD_RECTV2	0x8000
#define  CMD_LINEAF	0xA000
#define  CMD_BITBLT	0xC000
#define  CMD_OP_MSK	0xF000
#define  BYTSEQ		0x1000
#define  _16BIT		0x0200
#define  PCDATA		0x0100
#define  INC_Y		0x0080
#define  YMAJAXIS	0x0040
#define  INC_X		0x0020
#define  DRAW		0x0010
#define  LINETYPE	0x0008
#define  LASTPIX	0x0004
#define  PLANAR		0x0002
#define  WRTDATA	0x0001

/*
   Short Stroke Vector Transfer Register
   (The angular defs also apply to the Command Register)
*/
#define  VECDIR_000	0x0000
#define  VECDIR_045	0x0020
#define  VECDIR_090	0x0040
#define  VECDIR_135	0x0060
#define  VECDIR_180	0x0080
#define  VECDIR_225	0x00A0
#define  VECDIR_270	0x00C0
#define  VECDIR_315	0x00E0
#define  SSVDRAW	0x0010

/* Background Mix Register */
#define  BSS_BKGDCOL	0x0000
#define  BSS_FRGDCOL	0x0020
#define  BSS_PCDATA	0x0040
#define  BSS_BITBLT	0x0060

/* Foreground Mix Register */
#define  FSS_BKGDCOL	0x0000
#define  FSS_FRGDCOL	0x0020
#define  FSS_PCDATA	0x0040
#define  FSS_BITBLT	0x0060

/*
   The Mixes (Note that some are duplicated for ease
   of use.
*/
#define  MIX_MASK		     0x001F

#define  MIX_NOT_DST		     0x0000
#define  MIX_0			     0x0001
#define  MIX_1			     0x0002

#define  MIX_DST		     0x0003
#define  MIX_LEAVE_ALONE	     0x0003

#define  MIX_NOT_SRC		     0x0004

#define  MIX_SRC_XOR_DST	     0x0005
#define  MIX_XOR		     0x0005

#define  MIX_NOT__SRC_XOR_DST	     0x0006
#define  MIX_XNOR		     0x0006

#define  MIX_SRC		     0x0007
#define  MIX_REPLACE		     0x0007
#define  MIX_PAINT		     0x0007

#define  MIX_NOT_SRC_OR_NOT_DST	     0x0008
#define  MIX_NAND		     0x0008

#define  MIX_NOT_SRC_OR_DST	     0x0009
#define  MIX_SRC_OR_NOT_DST	     0x000A

#define  MIX_SRC_OR_DST		     0x000B
#define  MIX_OR			     0x000B

#define  MIX_SRC_AND_DST	     0x000C
#define  MIX_AND		     0x000C

#define  MIX_SRC_AND_NOT_DST	     0x000D
#define  MIX_NOT_SRC_AND_DST	     0x000E

#define  MIX_NOT_SRC_AND_NOT_DST     0x000F
#define  MIX_NOR		     0x000F

#define  MIX_MIN		     0x0010
#define  MIX_DST_MINUS_SRC	     0x0011
#define  MIX_SRC_MINUS_DST	     0x0012
#define  MIX_PLUS		     0x0013
#define  MIX_MAX		     0x0014
#define  MIX_HALF__DST_MINUS_SRC     0x0015
#define  MIX_HALF__SRC_MINUS_DST     0x0016
#define  MIX_AVERAGE		     0x0017
#define  MIX_DST_MINUS_SRC_SAT	     0x0018
#define  MIX_SRC_MINUS_DST_SAT	     0x001A
#define  MIX_PLUS_SAT		     0x001B
#define  MIX_HALF__DST_MINUS_SRC_SAT 0x001C
#define  MIX_HALF__SRC_MINUS_DST_SAT 0x001E
#define  MIX_AVERAGE_SAT	     0x001F

/* Memory Control Register */
#define  BUFSWP		0x0010
#define  VRTCFG_2	0x0000
#define  VRTCFG_4	0x0004
#define  VRTCFG_6	0x0008
#define  VRTCFG_8	0x000C
#define  HORCFG_4	0x0000
#define  HORCFG_5	0x0001
#define  HORCFG_8	0x0002
#define  HORCFG_10	0x0003

/* Pixel Control Register */
#define  MIXSEL_FRGDMIX 0x0000
#define  MIXSEL_PATT	0x0040
#define  MIXSEL_EXPPC	0x0080
#define  MIXSEL_EXPBLT  0x00C0
#define  COLCMPOP_F	0x0000
#define  COLCMPOP_T	0x0008
#define  COLCMPOP_GE	0x0010
#define  COLCMPOP_LT	0x0018
#define  COLCMPOP_NE	0x0020
#define  COLCMPOP_EQ	0x0028
#define  COLCMPOP_LE	0x0030
#define  COLCMPOP_GT	0x0038
#define  PLANEMODE	0x0004


/*
     This makes it easier to use the palette.
*/
typedef struct {
    unsigned char r;
    unsigned char g;
    unsigned char b;
} LUTENTRY;

/*
     Macro to aid in waiting for the command queue to empty.
     The parameter 'v' specifies the number of queue entries
     that you are waiting to be free.
*/
#define  WaitQueue(v)	{while (inpw(GP_STAT) & (0x0100 >> (v)));}
#define  WaitBusy()	{while (inpw(GP_STAT) & GPBUSY); }

/*
 * missing "in" and "out" stuff for various compilers
 */

#ifdef __TURBOC__
/*
 * TCC has byte size "inp" and "outp"
 */
#pragma inline

#define outpw(port,value) do {				\
	_AX = (value);					\
	_DX = (port);					\
	asm out dx,ax;					\
} while(0)

static int inpw(int port)
{
	_DX = port;
	asm in  ax,dx;
	return(_AX);
}

#endif /* __TURBOC__ */

#ifdef __GNUC__
/*
 * gcc needs both byte and word size ones
 */

#define outp(port,value) do {				\
    asm volatile("                                    \n\
	movl	%1,%%eax			      \n\
	movl	%0,%%edx			      \n\
	outb	%%al,%%dx			       "\
	: /* no output */				\
	: "g" (port), "g" (value)			\
	: "ax", "dx"					\
    );							\
} while(0)

#define outpw(port,value) do {				\
    asm volatile("                                    \n\
	movl	%1,%%eax			      \n\
	movl	%0,%%edx			      \n\
	outw	%%ax,%%dx			       "\
	: /* no output */				\
	: "g" (port), "g" (value)			\
	: "ax", "dx"					\
    );							\
} while(0)

static inline int inp(int port)
{
	register int value;

	asm volatile("                                \n\
	    movl    %1,%%edx			      \n\
	    inb	    %%dx,%%al			      \n\
	    movzbl  %%al,%0			       "\
	    : "=g" (value)				\
	    : "g" (port)				\
	    : "ax", "dx"				\
	);
	return(value);
}

static inline int inpw(int port)
{
	register int value;

	asm volatile("                                \n\
	    movl    %1,%%edx			      \n\
	    inw	    %%dx,%%ax			      \n\
	    movzwl  %%ax,%0			       "\
	    : "=g" (value)				\
	    : "g" (port)				\
	    : "ax", "dx"				\
	);
	return(value);
}

#endif /* __GCC__ */

