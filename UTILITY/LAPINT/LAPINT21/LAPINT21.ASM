
code     segment
         assume    cs:code,ds:code
         org       100h

start:   jmp       init

numint   db        0

aktiv    db        1                        ; priznak aktivity

old10    dd        0
old09    dd        0

old21    dd        0

IdentOut dw        0                        ; identifik tor v˜stupn¡ho souboru

oldint   dd        0

parodd   db        0                        ; p©¡znak oddˆlova‡e

param    db        0                   ; p©¡znak:1=prvn¡ pr–chod, 2=druh˜ pr–ch.

regax    dw        0
regbx    dw        0
regcx    dw        0
regdx    dw        0
regsi    dw        0
regdi    dw        0
regbp    dw        0
regds    dw        0
reges    dw        0
regf     dw        0

regss    dw        0
regsp    dw        0                        ; SP -

int09:   push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         test      byte ptr ds:[417h],8
         jz        int092
         test      byte ptr ds:[417h],4
         jz        int092
         in        al,[60h]

         cmp       al,2
         jne       int093
         mov       byte ptr cs:[aktiv],1
         mov       byte ptr cs:[parodd],1
         jmp       short int091

int093:  cmp       al,11
         jne       int092
         mov       byte ptr cs:[aktiv],0
         mov       byte ptr cs:[parodd],1

int091:  mov       ax,ds:[41ch]
         pushf
         call      dword ptr cs:[old09]
         mov       ds:[41ch],ax
         pop       ds
         pop       ax
         iret

int092:  pop       ds
         pop       ax
         jmp       dword ptr cs:[Old09]



intret:  popf
         jmp       dword ptr cs:[oldint]

intint:  pushf
         cmp       byte ptr cs:[aktiv],0
         je        intret
         cmp       ah,4bh
         jne       intint1
         cmp       byte ptr cs:[numint],21h
         je        intret
intint1: popf

         call      dek1reg

         pushf
         call      dword ptr cs:[oldint]

         call      dek2reg

         mov       byte ptr cs:[parodd],0

         push      bp
         mov       bp,sp
         push      ax
         pushf
         pop       ax
         mov       byte ptr ss:[bp+6],al
         pop       ax
         pop       bp

         iret



dek1reg: mov       byte ptr cs:[param],1 ; 1. pr–chod
         jmp       short dekreg

dek2reg: mov       byte ptr cs:[param],2 ; 2. pr–chod

dekreg:  mov       cs:[Regss],ss
         mov       cs:[regsp],sp            ; SP - 2

         call      Otevri

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       cs:[regax],ax
         mov       cs:[regbx],bx
         mov       cs:[regcx],cx
         mov       cs:[regdx],dx
         mov       cs:[regsi],si
         mov       cs:[regdi],di
         mov       cs:[regbp],bp
         mov       cs:[regds],ds
         mov       cs:[reges],es
         pushf
         pop       ax
         mov       cs:[regf],ax

         mov       si,offset regax
         mov       di,offset regaxh
         cmp       byte ptr cs:[param],1
         je        dekreg0
         mov       di,offset reg0axh
dekreg0: mov       cx,10
dekdath1:mov       ax,cs:[si]
         call      dekword
         add       si,2
         add       di,4
         loop      dekdath1



         mov       es,cs:[reges]
         mov       si,cs:[regbx]
         mov       bx,offset regasc
         mov       di,offset regdat
         cmp       byte ptr cs:[param],1
         je        dekreg2
         mov       bx,offset reg0asc
         mov       di,offset reg0dat
dekreg2: call      dekdat

         mov       es,cs:[regds]
         mov       si,cs:[regdx]
         mov       bx,offset regdasc
         mov       di,offset regddat
         cmp       byte ptr cs:[param],1
         je        dekreg5
         mov       bx,offset regd0asc
         mov       di,offset regd0dat
dekreg5: call      dekdat

         mov       es,cs:[regss]
         mov       si,cs:[regsp]
         inc       si
         inc       si
         mov       bx,offset regsasc
         mov       di,offset regsdat
         cmp       byte ptr cs:[param],1
         je        dekreg4
         mov       bx,offset regs0asc
         mov       di,offset regs0dat
dekreg4: call      dekdat

         cmp       byte ptr cs:[param],1
         je        dekreg6

         mov       si,offset regs
         cmp       byte ptr cs:[parodd],0
         je        dekreg7
         mov       si,offset regs0
dekreg7: call      disptxt

dekreg6:
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf

         call      Zavri
         ret


dekdat:  mov       cx,18
dekdat1: mov       al,es:[si]
         call      dekbyte
         inc       si
         inc       di
         cmp       al," "
         jae       dekdat3
         mov       al,"."
dekdat3: mov       cs:[bx],al
         inc       bx
         loop      dekdat1
         ret


dekword: xchg      ah,al
         call      dekbyte
         xchg      ah,al


dekbyte: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      dekhex
         pop       ax

dekhex:  push      ax
         and       al,0fh
         cmp       al,10
         jb        dekhex1
         add       al,7
dekhex1: add       al,"0"
         mov       cs:[di],al
         inc       di
         pop       ax
         ret

disptxt: push      ax
         push      si
disptxt1:mov       al,cs:[si]
         inc       si
         or        al,al
         jz        disptxt2
         call      dispch
         jmp       short disptxt1
disptxt2:pop       si
         pop       ax
         ret


dispch:  push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         push      cs
         pop       ds
         mov       dx,offset DispBuff
         mov       ds:[DispBuff],al
         mov       cx,1
         mov       bx,ds:[IdentOut]
         mov       ah,40h
         call      Int21

         pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

;         push      ax
;         push      bx
;         push      di
;         push      bp
;         push      ds
;         push      es
;         mov       ah,0eh
;         mov       bx,7
;         pushf
;         call      dword ptr cs:[old10]
;         pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       bx
;         pop       ax
;         ret

DispBuff db        0

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

Otevri   PROC      NEAR

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         push      cs
         pop       ds

         cmp       word ptr ds:[IdentOut],1
         ja        Otevri3

         mov       dx,offset Soubor
         mov       ax,3d01h
         call      Int21

         jnc       Otevri1

         mov       ah,3ch
         xor       cx,cx
         call      Int21
         jnc       Otevri1

         mov       ax,1
         jmp       short Otevri2

Otevri1: xchg      ax,bx
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         call      Int21
         xchg      ax,bx

Otevri2: mov       ds:[IdentOut],ax

Otevri3: pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

Otevri   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

Zavri    PROC      NEAR

         pushf
         push      ax
         push      bx

         mov       bx,cs:[IdentOut]
         cmp       bx,1
         jbe       Zavri2
         mov       ah,3eh
         call      Int21

Zavri2:  mov       word ptr cs:[IdentOut],0
         pop       bx
         pop       ax
         popf
         ret

Zavri    ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

Int21    PROC      NEAR

         pushf
         call      dword ptr cs:[Old21]
         ret

Int21    ENDP


Soubor   db        'C:\LAPINT.OUT',0

regs0    db        13,10,'==============================================================================='
         db        13,10
regs     db        13,10,'AX='
regaxh   db        '0000 BX='
regbxh   db        '0000 CX='
regcxh   db        '0000 DX='
regdxh   db        '0000 SI='
regsih   db        '0000 DI='
regdih   db        '0000 BP='
regbph   db        '0000 DS='
regdsh   db        '0000 ES='
regesh   db        '0000  F='
regfh    db        '0000',13,10

reg0s    db        'AX='
reg0axh  db        '0000 BX='
reg0bxh  db        '0000 CX='
reg0cxh  db        '0000 DX='
reg0dxh  db        '0000 SI='
reg0sih  db        '0000 DI='
reg0dih  db        '0000 BP='
reg0bph  db        '0000 DS='
reg0dsh  db        '0000 ES='
reg0esh  db        '0000  F='
reg0fh   db        '0000',13,10

         db        ' ES:BX='
regdat   db        '00-00-00-00 00-00-00-00 00-00-00-00 00-00-00-00 00-00|'
regasc   db        '                  '
         db        13,10

         db        ' ES:BX='
reg0dat  db        '00-00-00-00 00-00-00-00 00-00-00-00 00-00-00-00 00-00|'
reg0asc  db        '                  '
         db        13,10

         db        ' DS:DX='
regddat  db        '00-00-00-00 00-00-00-00 00-00-00-00 00-00-00-00 00-00|'
regdasc  db        '                  '
         db        13,10

         db        ' DS:DX='
regd0dat db        '00-00-00-00 00-00-00-00 00-00-00-00 00-00-00-00 00-00|'
regd0asc db        '                  '
         db        13,10

         db        ' SS:SP='
regsdat  db        '00-00-00-00 00-00-00-00 00-00-00-00 00-00-00-00 00-00|'
regsasc  db        '                  '
         db        13,10

         db        ' SS:SP='
regs0dat db        '00-00-00-00 00-00-00-00 00-00-00-00 00-00-00-00 00-00|'
regs0asc db        '                  '
         db        13,10,0

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

init:
         mov       ah,19h
         int       21h
         add       al,"A"
         mov       ds:[Soubor],al

         push      es
         mov       ax,3521h
         int       21h
         mov       word ptr ds:[Old21],bx
         mov       word ptr ds:[Old21+2],es
         pop       es

         mov       dx,offset uvtxt
         mov       ah,9
         int       21h

         xor       cx,cx
         mov       cl,ds:[80h]
         mov       si,81h
init7:   jcxz      init5
         lodsb
         dec       cx
         cmp       al,13
         je        init5
         cmp       al," "
         jbe       init7
         mov       ax,ds:[si-1]
         or        cl,cl
         jnz       init6


init5:   mov       dx,offset vyzva
         mov       ah,9
         int       21h

         mov       dx,offset buffer
         mov       ah,0ah
         int       21h

         mov       dx,offset textcr
         mov       ah,9
         int       21h

         cmp       byte ptr ds:[buffer+1],2
         je        init1

chyba:   mov       dx,offset prerus
         mov       ah,9
         int       21h
         int       20h

init1:   mov       ax,word ptr ds:[buffer+2]
init6:   xchg      ah,al

         cmp       al,"a"
         jb        Init62
         cmp       al,"z"
         ja        Init62
         sub       al,32
init62:
         cmp       ah,"a"
         jb        Init64
         cmp       ah,"z"
         ja        Init64
         sub       ah,32
init64:
         sub       al,"0"
         jc        chyba
         sub       ah,"0"
         jc        chyba

         cmp       al,9
         jbe       init2
         sub       al,7
init2:   cmp       al,16
         jae       chyba

         cmp       ah,9
         jbe       init3
         sub       ah,7
init3:   cmp       ah,16
         jae       chyba

         mov       cl,4
         shl       ah,cl
         or        al,ah
         mov       ds:[numint],al

         mov       dx,offset insttxt
         mov       ah,9
         int       21h

         mov       ax,3510h
         int       21h
         mov       word ptr ds:[old10],bx
         mov       word ptr ds:[Old10+2],es

         mov       ah,35h
         mov       al,ds:[numint]
         int       21h
         mov       word ptr ds:[oldint],bx
         mov       word ptr ds:[Oldint+2],es
         mov       ah,25h
         mov       al,ds:[numint]
         mov       dx,offset intint
         int       21h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[old09],bx
         mov       word ptr ds:[Old09+2],es
         mov       ax,2509h
         mov       dx,offset int09
         int       21h


         mov       dx,offset init
         int       27h

uvtxt    db        'LAPINT V1.20 - monitor preruseni; (c) Miroslav Nemecek',13,10,'$'

vyzva    db        'Zadejte cislo preruseni (2 znaky HEX): $'

prerus   db        'Chyba zadani - program nenainstalovan.'
textcr   db        13,10,'$'

insttxt  db        'Ctrl-Alt-1 zap, Ctrl-Alt-0 vyp',13,10,'$'

buffer   db        3,0

code     ENDS

         end       start
