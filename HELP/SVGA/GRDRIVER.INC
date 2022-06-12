;; This is file DRVDEFS.INC
;;
;; Copyright (c) 1991 DJ Delorie, 24 Kirsten Ave, Rochester NH 03867-2954
;; Copyright (C) 1992 Csaba Biegl, 820 Stirrup Dr, Nashville, TN 37221
;; Copyright (C) 1993 Grzegorz Mazur, gbm@ii.pw.edu.pl
;;
;; This file is distributed under the terms listed in the document
;; "copying.dj", available from DJ Delorie at the address above.
;; A copy of "copying.dj" should accompany this file; if not, a copy
;; should be available from where this file was obtained.  This file
;; may not be distributed without a verbatim copy of "copying.dj".
;;
;; This file is distributed WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;;


;; ==================================================================
;;                       DRIVER FLAG BITS
;; ==================================================================

GRD_NEW_DRIVER  equ 0008h       ;; NEW FORMAT DRIVER IF THIS IS SET
GRD_VESA_DRIVER equ 000fh

GRD_PAGING_MASK equ 0007h       ;; mask for paging modes
GRD_NO_RW       equ 0000h       ;; standard paging, no separate R/W
GRD_RW_64K      equ 0001h       ;; two separate 64K R/W pages
;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;; THE FOLLOWING THREE OPTIONS ARE NOT SUPPORTED AT THIS TIME !!!
;;
GRD_RW_32K      equ 0002h       ;; two separate 32Kb pages
GRD_MAP_128K    equ 0003h       ;; 128Kb memory map -- some Tridents do it
                                ;; (1024x768x16 without paging!!!)
GRD_MAP_EXTMEM  equ 0004h       ;; Can be mapped extended, above 1M.
                                ;; Some Tseng 4000-s can do it.
                                ;; NO PAGING AT ALL!!!!
;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GRD_TYPE_MASK   equ f000h       ;; adapter type mask
GRD_VGA         equ 0000h       ;; vga
GRD_EGA         equ 1000h       ;; ega
GRD_HERC        equ 2000h       ;; hercules
GRD_8514A       equ 3000h       ;; IBM 8514A or compatible
GRD_S3          equ 4000h       ;; S3 graphics accelerator

GRD_PLANE_MASK  equ 0f00h       ;; bitplane number mask
GRD_8_PLANES    equ 0000h       ;; 8 planes = 256 colors
GRD_4_PLANES    equ 0100h       ;; 4 planes = 16 colors
GRD_1_PLANE     equ 0200h       ;; 1 plane = 2 colors
GRD_16_PLANES   equ 0300h       ;; VGA with 32K colors
GRD_16X_PLANES  equ 0500h       ;; VGA with 64K colors
GRD_24_PLANES   equ 0600h       ;; VGA with 16M colors
GRD_8_X_PLANES  equ 0400h       ;; VGA in mode X w/ 256 colors

GRD_MEM_MASK    equ 00f0h       ;; memory size mask
GRD_64K         equ 0010h       ;; 64K display memory
GRD_128K        equ 0020h       ;; 128K display memory
GRD_256K        equ 0030h       ;; 256K display memory
GRD_512K        equ 0040h       ;; 512K display memory
GRD_1024K       equ 0050h       ;; 1MB display memory
GRD_192K        equ 0060h       ;; 192K -- some 640x480 EGA-s
GRD_M_NOTSPEC   equ 0000h       ;; memory amount not specified

