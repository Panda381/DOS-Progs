/****************************************************************************
*
*                                               MegaGraph Graphics Library
*
*                   Copyright (C) 1993 Kendall Bennett.
*                                                       All rights reserved.
*
* Filename:             $RCSfile: drivers.h $
* Version:              $Revision: 1.2 $
*
* Language:             ANSI C
* Environment:  IBM PC (MS DOS)
*
* Description:  Header file providing constant and definitions for the
*                               video drivers supported by the library. This is factorised
*                               out to make it easier to use the SuperVGA routines outside
*                               of the MGL (such as in the SuperVGA kit).
*
* $Id: drivers.h 1.2 1993/03/07 04:03:42 kjb Exp $
*
* Revision History:
* -----------------
*
* $Log: drivers.h $
* Revision 1.2  1993/03/07  04:03:42  kjb
* Numerous bug fixes and enhancements.
*
* Revision 1.1  1993/03/03  10:47:11  kjb
* Initial revision
*
****************************************************************************/

#ifndef __DRIVERS_H
#define __DRIVERS_H

#ifndef __DEBUG_H
#include "debug.h"
#endif

/*---------------------- Macros and type definitions ----------------------*/

/* Define the graphics subsystems available     */

typedef enum {
        grDETECT,                               /* Auto detect the graphics subsystem           */
        grCGA,                                  /* Standard CGA - not supported                         */
        grMCGA,                                 /* Standard MCGA - only 256 color mode          */
        grEGA,                                  /* Standard EGA                                                         */
        grEGA64,                                /* EGA with 64kb of RAM - not supported         */
        grEGAMONO,                              /* EGA with mono monitor - not supported        */
        grEGA64MONO,                    /* EGA 64k mono monitor - not supported         */
        grHERCMONO,                             /* Standard Hercules - not supported            */
        grVGA,                                  /* Standard VGA                                                         */
        grSVGA,                                 /* VESA Super VGA                                                       */
        grSVGA_ATI,                             /* ATI Technologies SuperVGA                            */
        grSVGA_AHEADA,                  /* AHEAD A SuperVGA                                                     */
        grSVGA_AHEADB,                  /* AHEAD B SuperVGA                                                     */
        grSVGA_CHIPS,                   /* Chips & Technologies SuperVGA                        */
        grSVGA_EVEREX,                  /* Everex SuperVGA                                                      */
        grSVGA_GENOA,                   /* Genoa Systems SuperVGA (GVGA chipset)        */
        grSVGA_OAKTECH,                 /* OAK Technologies SuperVGA                            */
        grSVGA_PARADISE,                /* Paradise SuperVGA                                            */
        grSVGA_TRIDENT88,               /* Trident 8800 SuperVGA                                        */
        grSVGA_TRIDENT89,               /* Trident 8900 SuperVGA                                        */
        grSVGA_VIDEO7,                  /* Video7 SuperVGA                                                      */
        grSVGA_ET3000,                  /* Tseng Labs ET3000 SuperVGA                           */
        grSVGA_ET4000,                  /* Tseng Labs ET4000 SuperVGA                           */
        grSVGA_NCR,                             /* NCR 77C22E SuperVGA                                          */
        grSVGA_S3,                              /* S3 SuperVGA                                                          */
        grSVGA_ACUMOS,                  /* Acumos SuperVGA                                                      */
        grSVGA_AL2101,                  /* Advance Logic AL2101 SuperVGA                        */
        grSVGA_MXIC,                    /* MXIC 68010 SuperVGA                                          */
        grSVGA_P2000,                   /* Primus 2000 SuperVGA                                         */
        grSVGA_RT3106,                  /* RealTek 3106 SuperVGA                                        */
        grSVGA_CIRRUS54,                /* Cirrus 5422 SuperVGA                                         */
        grUSER,                                 /* User drivers start here                                      */
        } MGL_driver;

/* First and last SuperVGA driver numbers       */

#define __FIRST_SVGA    grSVGA
#define __LAST_SVGA             grSVGA_CIRRUS54

/* Video DAC types */

typedef enum {
        grVGADAC,                               /* Normal DAC                                                           */
        grHCDAC,                                /* HiColor 15 bit DAC                                           */
        grHC2DAC,                               /* HiColor 15/16 bit DAC                                        */
        grTCDAC,                                /* TrueColor 24 bit DAC                                         */
        grDETECTDAC             = -1,   /* Auto detect the DAC type                                     */
        } MGL_dac;

/* Graphics modes supported     - the only video modes supported by this
 * graphics library are those that support at least 16 colors per pixel.
 */

typedef enum {
        /* 16 color EGA video modes */

        grEGA_320x200x16        = 0,    /* 320x200 16 color 8 page                              */
        grEGA_640x200x16        = 1,    /* 640x200 16 color 4 page                              */
        grEGA_640x350x16        = 2,    /* 640x350 16 color 2 page                              */

        /* 16 color VGA video modes */

        grVGA_640x400x16        = 3,    /* 640x400 16 color 2 page                              */
        grVGA_640x480x16        = 4,    /* 640x480 16 color 1 page                              */

        /* 256 color VGA video modes */

        grVGA_320x200x256       = 5,    /* 320x200 256 color 1 page                             */

        /* 256 color VGA ModeX video modes */

        grVGAX_320x200x256      = 6,    /* 320x200 256 color 4 page                             */
        grVGAX_320x240x256      = 7,    /* 320x240 256 color 3 page                             */
        grVGAX_320x400x256      = 8,    /* 320x400 256 color 2 page                             */
        grVGAX_320x480x256      = 9,    /* 320x480 256 color 1 page                             */
        grVGAX_360x200x256      = 10,   /* 360x200 256 color 3 page                             */
        grVGAX_360x240x256      = 11,   /* 360x240 256 color 3 page                             */
        grVGAX_360x400x256      = 12,   /* 360x400 256 color 1 page                             */
        grVGAX_360x480x256      = 13,   /* 360x480 256 color 1 page                             */

        /* 16 color Super VGA video modes */

        grSVGA_800x600x16       = 14,   /* 800x600 16 color 1 page                              */
        grSVGA_1024x768x16      = 15,   /* 1024x768 16 color 1 page                             */
        grSVGA_1280x1024x16     = 16,   /* 1280x1024 16 color 1 page                    */

        /* 256 color Super VGA video modes */

        grSVGA_640x350x256      = 17,   /* 640x250 256 color 1 page                             */
        grSVGA_640x400x256      = 18,   /* 640x400 256 color 1 page                             */
        grSVGA_640x480x256      = 19,   /* 640x480 256 color 1 page                             */
        grSVGA_800x600x256      = 20,   /* 800x600 256 color 1 page                             */
        grSVGA_1024x768x256     = 21,   /* 1024x768 256 color 1 page                    */
        grSVGA_1280x1024x256= 22,       /* 1280x1024 256 color 1 page                   */

        /* 32,768 color Super VGA video modes */

        grSVGA_320x200x32k      = 23,   /* 320x200 32,768 color 1 page                  */
        grSVGA_640x350x32k      = 24,   /* 640x350 32,768 color 1 page                  */
        grSVGA_640x400x32k      = 25,   /* 640x400 32,768 color 1 page                  */
        grSVGA_640x480x32k      = 26,   /* 640x480 32,768 color 1 page                  */
        grSVGA_800x600x32k      = 27,   /* 800x600 32,768 color 1 page                  */
        grSVGA_1024x768x32k     = 28,   /* 1024x768 32,768 color 1 page                 */
        grSVGA_1280x1024x32k= 29,       /* 1280x1024 32,768 color 1 page                */

        /* 16 million color Super VGA video modes */

        grSVGA_320x200x16m      = 30,   /* 320x200 16 million color 1 page              */
        grSVGA_640x350x16m      = 31,   /* 640x350 16 million color 1 page              */
        grSVGA_640x400x16m      = 32,   /* 640x400 16 million color 1 page              */
        grSVGA_640x480x16m      = 33,   /* 640x480 16 million color 1 page              */
        grSVGA_800x600x16m      = 34,   /* 800x600 16 million color 1 page              */
        grSVGA_1024x768x16m     = 35,   /* 1024x768 16 million color 1 page             */
        grSVGA_1280x1024x16m= 36,       /* 1280x1024 16 million color 1 page    */

        grMAXMODE                       = 36,   /* Maximum mode number                                  */
        } MGL_mode;

/*------------------------- Function Prototypes ---------------------------*/

#ifdef  __cplusplus
extern "C" {                    /* Use "C" linkage when in C++ mode     */
#endif

/* In detectgr.asm */

void    MGL_detectGraph(int far *graphdriver,int far *chipID,
                int far *memory,int far *dac,int far *graphmode);

/* In names.c */

char    * MGL_modeName(int mode);
char    * MGL_driverName(int driver);
char    * MGL_dacName(int dac);
char    * MGL_chipsetName(int driver,int chipset);

/* In modes.c */

int     * MGL_availableModes(int driver,int memory);
int             MGL_availablePages(int driver,int memory,int mode);

#ifdef  __cplusplus
}                                               /* End of "C" linkage for C++   */
#endif

#endif  /* __DRIVERS_H */
