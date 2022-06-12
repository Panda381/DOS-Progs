
code     segment
         assume    cs:code,ds:code
         org       100h
start:
         mov       ax,351eh
         int       21h
         mov       word ptr ds:[old1e],bx
         mov       word ptr ds:[old1e+2],es
         push      cs
         pop       es
         mov       dx,offset disk7
         mov       ax,251eh
         int       21h


         mov       dx,offset konec
         mov       ax,2523h
         int       21h

         cld
         mov       di,offset fat1+2
         mov       cx,256*9
         xor       ax,ax
         rep       stosw

                                          ;* zobrazen¡ textu v˜zvy
         mov       dx,offset uvtxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

                                          ;* ‡ek n¡ na vstup z kl vesnice
         mov       ax,0c08h
         int       21h                      ; ‡ek n¡ na vstup znaku z kl vesnice
         cmp       al,13                    ; je potvrzen¡ operace ?
         jne       konec

                                          ;* resetov n¡ diskov‚ho syst‚mu
         mov       ah,0dh
         int       21h                      ; resetov n¡ diskov‚ho syst‚mu

                                          ;* nastaven¡ typu m‚dia
         call      settyp
         jnc       start1                   ; typ m‚dia nastaven OK

                                          ;* resetov n¡ disku p©i chybˆ
         call      reset

         call      settyp

         mov       dx,offset formtxt        ; text chyby
         jc        chyba                    ; chyba nastaven¡ form tu

                                          ;* zobrazen¡ informa‡n¡ho textu
start1:  mov       dx,offset inftxt
         mov       ah,9
         int       21h

                                          ;* zform tov n¡ jedn‚ stopy
start2:  sti
         mov       dx,offset inftxt0        ; ‡¡slo stopy
         mov       ah,9
         int       21h                      ; zobrazen¡ ‡¡sla stopy
         mov       ah,0bh
         int       21h


         call      format                   ; zform tov n¡ jedn‚ stopy
         jnc       start3                   ; operace OK
         call      reset
         call      format
         jnc       start3                   ; operace OK
         call      reset
         call      format
         jnc       start3

         mov       dl,ds:[inftxt0]
         mov       ah,2
         int       21h
         mov       dl,ds:[inftxt0+1]
         mov       ah,2
         int       21h
         mov       dx,offset inftxt0-1      ; ‡¡slo stopy
         mov       ah,9
         int       21h                      ; zobrazen¡ ‡¡sla stopy

start3:
         call      posun                    ; posun ukazatel–
         jnc       start2                   ; je je¨tˆ dal¨¡ stopa


         xor       dh,dh
         mov       bx,offset bootbeg
         call      zapis
         jnc       start4
         call      reset
         call      zapis
start4:  inc       dh
         mov       bx,offset fat1+2
         call      zapis
         jnc       start5
         call      reset
         call      zapis
start5:
         jmp       short konec


chyba:   mov       ah,9
         int       21h

konec:   push      cs
         pop       ds
         mov       dx,offset kontxt
         mov       ah,9
         int       21h
         lds       dx,ds:[old1e]
         mov       ax,251eh
         int       21h
         int       20h


reset:                                    ;* reset diskov‚ho syst‚mu
         xor       ax,ax
         xor       dx,dx
         int       13h                      ; resetov n¡ diskov‚ho syst‚mu
         call      settyp
                                          ;* nastaven¡ typu m‚dia znovu
         ret


settyp:  push      ds
         push      es

         mov       ah,18h
         mov       cx,4f09h
         xor       dl,dl
         int       13h
         jc        settyp2

         push      es
         pop       ds
         mov       dx,di
         mov       ax,251eh
         int       21h
         clc
         jmp       short settyp3

settyp2: mov       ax,1704h                 ; funkce nastaven¡ m‚dia 720 KB
         xor       dl,dl                    ; disketov  mechanika A:
         int       13h                      ; nastaven¡ typu m‚dia

settyp3:
         pop       es
         pop       ds
         ret


                                          ;* form tov n¡ jedn‚ stopy
format:  mov       ax,509h                  ; funkce form tov n¡ 9 sektor–
         mov       ch,ds:[field]            ; form tovan  stopa
         mov       cl,1                     ; po‡ te‡n¡ ‡¡slo sektoru
         mov       dh,ds:[field+1]          ; form tovan  hlava
         xor       dl,dl                    ; form tuje se disk A:
         mov       bx,offset field          ; tabulka adresov‚ho pole
         push      cs
         pop       es
         int       13h                      ; form tov n¡ stopy
         jc        format2
         push      es
         mov       ax,409h
         xor       bx,bx
         mov       es,bx
         mov       ch,ds:[field]
         xor       dl,dl
         mov       dh,ds:[field+1]          ; form tovan  hlava
         int       13h
         pop       es
         jnc       uloz1
format2:
         ret


uloz1:   cmp       byte ptr ds:[field],0
         clc
         jne       format2
         cmp       byte ptr ds:[field+1],0
         jne       uloz2

         xor       dh,dh
         mov       bx,offset bootbeg
         call      zapis
         jnc       uloz0
         call      reset
         call      zapis
         jnc       uloz0
         call      reset
         call      zapis
uloz0:   ret

uloz2:   mov       dh,1
         mov       bx,offset fat1+2
         call      zapis
         jnc       uloz3
         call      reset
         call      zapis
         jnc       uloz3
         call      reset
         call      zapis
uloz3:   ret

                                          ;* z pis stopy (adresa BX, hlava DH)
zapis:   push      dx
         push      bx
         mov       ax,309h
         mov       cx,1
         xor       dl,dl
         push      cs
         pop       es
         int       13h
         pop       bx
         pop       dx
         ret



                                          ;* posun ukazatel–
posun:   test      byte ptr ds:[field+1],1
         jz        posun6
         mov       ax,word ptr ds:[inftxt0] ; ‡¡slo stopy
         inc       ah
         cmp       ah,"9"
         jbe       posun2
         mov       ah,"0"
         cmp       al," "
         jne       posun21
         mov       al,"0"
posun21: inc       al
posun2:  mov       word ptr ds:[inftxt0],ax

posun6:  mov       cx,9
         mov       si,offset field
posun3:  xor       byte ptr ds:[si+1],1     ; zmˆna ‡¡sla hlavy
         jnz       posun4                   ; nebyla hlava 0
         inc       byte ptr ds:[si]         ; zv˜¨en¡ ‡¡sla stopy
         cmp       byte ptr ds:[si],80      ; jsou ji‘ v¨echny stopy ?
         cmc
         jc        posun5                   ; jsou ji‘ v¨echny stopy
posun4:  add       si,4
         loop      posun3                   ; dal¨¡ sektor
         clc
posun5:  ret

field    db        0,0,1,2                 ; sektor 1
         db        0,0,2,2                 ; sektor 2
         db        0,0,3,2                 ; sektor 3
         db        0,0,4,2                 ; sektor 4
         db        0,0,5,2                 ; sektor 5
         db        0,0,6,2                 ; sektor 6
         db        0,0,7,2                 ; sektor 7
         db        0,0,8,2                 ; sektor 8
         db        0,0,9,2                 ; sektor 9

old1e    dd        0

Disk7:                                      ; mechanika 1.2 MB, disketa 720 KB
                                            db   0dfh      ; 0: rychlost krokov n¡, zvednut¡ hlavy
                                            db   2         ; 1: spu¨tˆn¡ p©¡tlaku hlavy
                                            db   37        ; 2: ‡as pro vypnut¡ motoru
                                            db   2         ; 3: velikost sektoru
                                            db   9         ; 4: po‡et sektor– na stopu
                                            db   42        ; 5: mezisekt. mezera ‡ten¡/z pis
                                            db   255       ; 6: d‚lka p©en ¨en˜ch dat
                                            db   80        ; 7: mezisekt. mezera form tov n¡
                                            db   0f6h      ; 8: plnic¡ znak form tov n¡
                                            db   15        ; 9: doba ust len¡ hlav
                                            db   8         ; 10: doba pro rozbˆh motoru
                                            db   79        ; 11: posledn¡ stopa
                                            db   40h       ; 12: p©enosov  rychlost 500K/s


inftxt   db        13,10,'Formatuji stopu: '
inftxt0  db        ' 0',8,8,'$'

uvtxt    db        13,10
         db        'VAROVANI: Zformatuji disketu v mechanice A: na 720 KB !',13,10
         db        '          Veskera data na diskete budou ZNICENA !',13,10
         db        13,10
         db        'Potvrdte stiskem <Enter>, jina klavesa prerusi operaci. $'

formtxt  db        13,10,'Neni nainstalovan rozsireny ovladac disket !$'

kontxt   db        '  ',13,10,'$'


; -----------------------------------------------------------------------------

bootbeg  label     byte
         jmp       boot1                    ; start zavadˆ‡e syst‚mu

Identif  db        'FORM 4.0'               ; identifikace zavadˆ‡e

SektSize dw        200h                     ; (7C0B) velikost sektoru
SektBlok db        2                        ; (7C0D) po‡et sektor– na alok. blok
RezSekt  dw        1                        ; (7C0E) po‡et rezervovan˜ch sektor–
NumFAT   db        2                        ; (7C10) po‡et tabulek FAT
MaxRoot  dw        70h                      ; (7C11) max. po‡et polo‘ek ROOT
;MaxSekt  dw        2d0h                     ; (7C13) max. po‡et sektor– disku
MaxSekt  dw        5a0h                     ; (7C13) max. po‡et sektor– disku
;IdentMed db        0fdh                     ; (7C15) popisova‡ m‚dia
IdentMed db        0f9h                     ; (7C15) popisova‡ m‚dia
;SektFAT  dw        2                        ; (7C16) po‡et sektor– na FAT
SektFAT  dw        3                        ; (7C16) po‡et sektor– na FAT
SektTrck dw        9                        ; (7C18) po‡et sektor– na stopu
NumHead  dw        2                        ; (7C1A) po‡et hlav disku
HidSekt  dd        0                        ; (7C1C) po‡et skryt˜ch sektor–
MaxSektH dd        0                        ; (7C20) po‡et sektor– na disku

BootDisk db        0                        ; (7C24) aktivn¡ disk
BootHead db        0                        ; (7C25) aktivn¡ hlava

IdentExt db        29h                      ; (7C26) identif. roz¨¡©. informac¡
SerNum   dw        0,0                      ; (7C27) s‚riov‚ ‡¡slo

Jmeno    db        'NO NAME    '            ; jm‚no disku
Fat      db        'FAT12   '               ; jm‚no tabulky FAT

boot1:   xor       ax,ax
         mov       ss,ax
         mov       sp,7c00h
         mov       si,offset(text-bootbeg)+7c00h
         mov       cx,offset(text0-text)
boot2:   mov       al,cs:[si]
         inc       si
         push      si
         push      cx
         mov       ah,0eh
         mov       bx,7
         int       10h
         pop       cx
         pop       si
         loop      boot2

         xor       ax,ax
         int       16h

         int       19h


text     db        'Nesystemovy disk - stisknete libovolnou klavesu ...',13,10
text0    label     byte

         db        510 - (text0-bootbeg) dup(0)

         db        55h,0aah

bootend  label     byte

fat1     db        0ffh,0ffh

; -----------------------------------------------------------------------------

code     ends
         end       start
