/*
 *  ibm8514a.c - Shell to initialize the 8514/A
 *		 Written by Jake Richter
 *		 Copyright (c) 1989,1990  Panacea Inc., Londonderry, NH
 *
 *		 This program may be freely distributed and modified.
 */

#include <dos.h>
#include "reg8514a.h"

int status_8514A = (-1);	/* -1: not present, 0: VGA, 1: enabled */

/*
 * check_8514A()
 * =============
 *  Check to see if an 8514/A is actually installed by
 *  writing to the ERR_TERM register, and reading back. The
 *  0x5A5A value is entirely arbitrary.
 */
int check_8514A(void)
{
	int status;

	outpw(ERR_TERM,0x5A5A);
	if(inpw(ERR_TERM) != 0x5A5A) return(0);
	outpw(ADVFUNC_CNTL,6);	    /* make sure we are in VGA mode */
	/*
	 * Reset the 8514/A, and disable all interrupts.
	 */
	outpw(SUBSYS_CNTL,GPCTRL_RESET | CHPTEST_NORMAL);
	outpw(SUBSYS_CNTL,GPCTRL_ENAB  | CHPTEST_NORMAL);
	/*
	 * Get board status information.
	 */
	status = inpw(SUBSYS_STAT);
	/*
	 * Check if we can do 1024x768 with 256 colors.
	 * If not, don't bother with 8514A modes.
	 */
	if((status & MONITORID_MASK) != MONITORID_8514) return(0);
	if((status & _8PLANE) == 0) return(0);
	/*
	 * OK, it's present and the modes we want are available
	 */
	status_8514A = 0;
	return(1);
}

/*
 * disable_8514A()
 * ===============
 *
 *  go back to VGA mode
 */
void disable_8514A(void)
{
	if(status_8514A > 0) {
	    outpw(ADVFUNC_CNTL,6);	/* Return to VGA Mode */
	    status_8514A = 0;
	}
}

/*
 * InitLUT()
 * =========
 *  Loads the Look-up Table with ramps of red, green, blue, and gray.
 *  Assumes 8-bit board is in use. If 4 bit board, then only the first
 *  16 entries in LUT will be used. Could be written more compact, but
 *  has been expanded for greater readability.
 */
LUTENTRY lutData[16] = {	/* approximate default VGA colors */
    0x00, 0x00, 0x00,		/* Black			  */
    0x00, 0x00, 0x7f,		/* Dark Blue			  */
    0x00, 0x7f, 0x00,		/* Dark Green			  */
    0x00, 0x7f, 0x7f,		/* Dark Cyan			  */
    0x7f, 0x00, 0x00,		/* Dark Red			  */
    0x7f, 0x00, 0x7f,		/* Dark Magenta			  */
    0x7f, 0x7f, 0x00,		/* Dark Yellow (Brown)		  */
    0x7f, 0x7f, 0x7f,		/* Gray				  */
    0x1f, 0x1f, 0x1f,		/* Dark Gray (Almost Black)	  */
    0x00, 0x00, 0xff,		/* Bright Blue			  */
    0x00, 0xff, 0x00,		/* Bright Green			  */
    0x00, 0xff, 0xff,		/* Bright Cyan			  */
    0xff, 0x00, 0x00,		/* Bright Red			  */
    0xff, 0x00, 0xff,		/* Bright Magenta		  */
    0xff, 0xff, 0x00,		/* Bright Yellow		  */
    0xff, 0xff, 0xff		/* White			  */
};

static void InitLUT(void)
{
	int ii,jj;

	/*
	 * Start by setting the DAC Write Index to 0.
	 */
	outp(DAC_W_INDEX,0);
	/*
	 * Load all 256 LUT entries (pattern repeats after every 16 colors)
	 */
	for(ii = 0; ii < 16; ii++) {
	    for(jj = 0; jj < 16; jj++) {
		outp(DAC_DATA,lutData[jj].r >> 2);
		outp(DAC_DATA,lutData[jj].g >> 2);
		outp(DAC_DATA,lutData[jj].b >> 2);
	    }
	}
}

/*
 * InitEnvironment()
 * =================
 *
 *  Initializes the 8514/A's drawing environment and clears the display.
 */
void InitEnvironment(void)
{
	/*
	 * Current mixes, replace, foreground active
	 */
	outpw(FRGD_MIX,FSS_FRGDCOL | MIX_REPLACE);
	outpw(BKGD_MIX,BSS_BKGDCOL | MIX_REPLACE);
	/*
	 * Clipping rectangle to full drawable space (0,0 to 1023, 1023).
	 */
	outpw(MULTIFUNC_CNTL,SCISSORS_T | 0x000);
	outpw(MULTIFUNC_CNTL,SCISSORS_L | 0x000);
	outpw(MULTIFUNC_CNTL,SCISSORS_B | 0x3FF);
	outpw(MULTIFUNC_CNTL,SCISSORS_R | 0x3FF);
	/*
	 * Enable writes to all planes and reset color compare
	 */
	outpw(WRT_MASK,0xFFFF);
	outpw(MULTIFUNC_CNTL,PIX_CNTL | 0x0000);      /* Clear lower bits */
	/*
	 * Clear the display. Need to set the color, origin, and size.
	 * Then draw. See Listing 7-5 for more information.
	 */
	WaitQueue(6);
	outpw(FRGD_COLOR,0);
	outpw(CUR_X,0);
	outpw(CUR_Y,0);
	outpw(MAJ_AXIS_PCNT,1023);
	outpw(MULTIFUNC_CNTL,MIN_AXIS_PCNT | 1023);
	outpw(CMD,CMD_RECT | INC_Y | INC_X | DRAW | PLANAR | WRTDATA);

	/*
	 * Reset current draw position
	 */
	WaitQueue(4);
	outpw(CUR_X,0x0000);
	outpw(CUR_Y,0x0000);
	/*
	 * Reset current colors, foreground is all on, background is 0.
	 */
	outpw(FRGD_COLOR,0xFFFF);
	outpw(BKGD_COLOR,0x0000);
}

/*
 * setup_8514A_256_color_mode()
 * ============================
 *  Initializes the 8514/A into the requested resolution. Valid input
 *  values are 0 for 640x480 and 1 for 1024x768.
 *
 *  No error checking on input value is performed. If an 8514/A is not
 *  found, or if the 1024 mode is selected, but an appropriate monitor
 *  is not available, this routine will print a message and exit to DOS.
 */

#define  MODE_640    0
#define  MODE_1024   1

int initRegs[] = {
    DISP_CNTL, ADVFUNC_CNTL, V_TOTAL, V_SYNC_STRT,
    V_DISP, H_TOTAL, H_SYNC_STRT, H_DISP,
    H_SYNC_WID, V_SYNC_WID, DISP_CNTL, 0
};

int mode640x8[] = {
    0x0043, 0x0003, 0x0418, 0x03D2,
    0x03BB, 0x0063, 0x0052, 0x004F,
    0x002C, 0x0022, 0x0023
};

int mode1024x8[] = {
    0x0053, 0x0007, 0x0660, 0x0600,
    0x05FB, 0x009D, 0x0081, 0x007F,
    0x0016, 0x0008, 0x0033
};

void setup_8514A_256_color_mode(int res)
{
	int ii;

	/*
	 * Blank the screen temporarily to display color 0 by turning
	 * the display of all planes off.
	 */
	outp(DAC_MASK,0x00);
	/*
	 * Reset the 8514/A, and disable all interrupts.
	 */
	outpw(SUBSYS_CNTL,GPCTRL_RESET | CHPTEST_NORMAL);
	outpw(SUBSYS_CNTL,GPCTRL_ENAB | CHPTEST_NORMAL);
	outpw(MULTIFUNC_CNTL,MEM_CNTL | VRTCFG_4 | HORCFG_8);
	/*
	 * Now initialize the display controller part of the 8514/A.
	 * We have set up the initialization values in two sets of
	 * tables: 4 bpp and 8 bpp. The "numPlanes" comparison below
	 * determines which set of values to use (dual indices).
	 */
	for(ii = 0; initRegs[ii] != 0; ii++) {
	    int regno = initRegs[ii];
	    outpw(regno,(res == MODE_1024) ? mode1024x8[ii] : mode640x8[ii]);
	}
	/*
	 * Now reenable the screen, but only the planes that actually exist.
	 * Otherwise, you end up with bus noise on the display.
	 */
	InitLUT();
	InitEnvironment();
	outpw(DAC_MASK,0xFF);		/* Enable all 8 planes for display */
	status_8514A = 1;
}

