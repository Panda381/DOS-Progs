
; *****************************************************************************
;
;                  Nastaven¡ form tu diskety na 720 KB
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h
start:
         xor       cx,cx
         mov       cl,ds:[80h]
         mov       si,81h
         cld
         mov       dx,offset zadtxt

start1:  jcxz      chyba
         lodsb
         dec       cx
         cmp       al," "
         jbe       start1

         and       al,not 20h
         sub       al,"A"-1
         jbe       chyba
         cmp       al,26
         ja        chyba

         mov       bl,al
         mov       ax,4408h
         int       21h                      ; je za©¡zen¡ v˜mˆnn‚ ?
         jc        chyba1
         or        al,al
         jnz       chyba1
         mov       ax,4409h
         int       21h
         jc        chyba1
         test      dh,10h
         jnz       chyba1

         mov       ax,440dh
         mov       cx,840h
         mov       dx,offset tabl
         int       21h
         jnc       konec


chyba1:  mov       dx,offset errtxt

chyba:   mov       ah,9
         int       21h
konec:
         int       20h


zadtxt   db        'Zadejte disk A, B, ... !',13,10,'$'
errtxt   db        'Format disku 720 KB nelze nastavit !',13,10,'$'

tabl     label     byte

spec     db        4
; 00h    BYTE    special functions
;                bit 0 set if function to use current BPB, clear if Device BIOS
;                        Parameter Block field contains new default BPB
;                bit 1 set if function to use track layout fields only
;                        must be clear if CL=60h
;                bit 2 set if all sectors in track same size (should be set)
;                bits 3-7 reserved

devtyp   db        2
; 01h    BYTE    device type
;                00h  320K/360K disk
;                01h  1.2M disk
;                02h  720K disk
;                03h  single-density 8-inch disk
;                04h  double-density 8-inch disk
;                05h  fixed disk
;                06h  tape drive
;                07h  1.44M disk
;                08h  other type of block device

devatr   dw        2
; 02h    WORD    device attributes
;                bit 0 set if nonremovable medium
;                bit 1 set if door lock supported
;                bits 2-15 reserved

valcu    dw        80
; 04h    WORD    number of cylinders

medtyp   db        0
; 06h    BYTE    media type
;                00h 1.2M disk (default)
;                01h 320K/360K disk

; 07h 31 BYTEs   device BPB (see AH=53h)
bajtsekt dw        200h
;                07h (2) bajt– na sektor

sektclus db        2
;                09h (1) sektor– na aloka‡n¡ blok

rezsekt  dw        1
;                0ah (2) zav dˆc¡ a rezervovan‚ sektory

numfat   db        2
;                0cH (1) po‡et tabulek FAT

maxroot  dw        70h
;                0dh (2) max. po‡et polo‘ek ROOT

maxsekt  dw        5a0h
;                0fh (2) po‡et sektor– na m‚diu celkem

popisov  db        0f9h
;                11h (1) popisova‡ m‚dia

sektfat  dw        3
;                12h (2) sektor– na jednu FAT

numsekt  dw        9
;                14h (2) sektor– na stopu

numhead  dw        2
;                16h (2) po‡et stran

         dw        0
;                18h (2)

         dw        0
;                1ah (2)

maxsekth dd        0
;                1ch (4) sektor– na m‚diu (kdy‘ je polo‘ka 08h = 0)

         db        6 dup (0)
;                20h (6)

sekttrck dw        0
; 26h    WORD    number of sectors per track (start of track layout field)

         db        18 dup(0,0)
; 28h  N word pairs: number,size of each sector in track

tabl2    label     byte


code     ends
         end       start
