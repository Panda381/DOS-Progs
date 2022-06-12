Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

MaxMod   EQU       200                      ; maxim ln¡ po‡et videom¢d–

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       si,offset UvTxt
         call      DispTxt0

; ------ na‡ten¡ informac¡ VESA

         mov       al,0
         call      VESAInt                  ; test VESA
         jnc       Start1                   ; je VESA OK

; ------ chyba - nen¡ VESA

         mov       si,offset NeniTxt
         call      DispTxt0
         mov       ax,4c01h
         int       21h

; ------ dek¢dov n¡ verze

Start1:  mov       ax,word ptr ds:[VESA+4]
         mov       ds:[Verze],ax            ; verze VESA
         aam
         xchg      al,ah
         add       ax,"00"
         mov       word ptr ds:[JeTxt1+2],ax ; ni‘¨¡ ‡¡slo verze
         mov       al,ds:[VESA+5]
         add       al,"0"
         mov       ds:[JeTxt1],al           ; vy¨¨¡ ‡¡slo verze

; ------ zobrazen¡ hl ¨en¡, ‘e je karta VESA

         mov       si,offset JeTxt
         call      DispTxt0

; ------ zji¨tˆn¡ d‚lky textu ozna‡en¡

         les       di,dword ptr ds:[VESA+6] ; adresa OEM textu
         push      di
         xor       cx,cx                    ; ‡¡ta‡ d‚lky textu
Start21: cmp       byte ptr es:[di],0
         je        Start22
         cmp       byte ptr es:[di]," "
         ja        Start2
         pop       di
         inc       di
         push      di
         jnz       Start21

Start2:  cmp       byte ptr es:[di],7
         je        Start23
         cmp       byte ptr es:[di]," "
         jb        Start22
Start23: inc       di
         inc       cx
         cmp       cl,50
         jb        Start2
Start22: pop       si

; ------ zobrazen¡ textu OEM

         call      DispTxt                  ; zobrazen¡ ozna‡en¡ karty

; ------ zobrazen¡ textu PamˆŸ

         mov       si,offset PametTxt
         call      DispTxt0

; ------ zobrazen¡ cel‚ ‡ sti velikosti videopamˆti

         mov       ax,word ptr ds:[VESA+12h] ; velikost pamˆti v bloc¡ch 64 KB
         test      al,0fh
         jnz       Start24                  ; budou desetiny
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na MB
         jz        Start24                  ; je m‚nˆ ne‘ 1 MB
         call      DispNum                  ; zobrazen¡ cel‚ ‡ sti
         mov       si,offset PametTx0       ; text "MB
         jmp       short Start25

; ------ zobrazen¡ velikosti videopamˆti v KB

Start24: mov       ax,64                    ; n sobek pro p©epo‡et
         mul       word ptr ds:[VESA+12h]   ; p©epo‡et na KB
         call      DispNum                  ; velikost v KB
         mov       si,offset PametTx1       ; text "KB"
Start25: call      DispTxt0                 ; zobrazen¡ jednotky

; ------ £schova tabulky videom¢d–

         push      ds
         push      ds
         pop       es
         lds       si,dword ptr ds:[VESA+0eh]
         xor       cx,cx
         sub       cx,si
         shr       cx,1
         cmp       cx,MaxMod
         jbe       Start26
         mov       cx,MaxMod
Start26: mov       di,offset ListMod
         cld
         xor       bx,bx
         jcxz      Start28
Start27: lodsw
         stosw
         inc       ax
         jz        Start28
         inc       bx
         loop      Start27
Start28: pop       ds

; ------ korekce tabulky videom¢d–

         mov       cx,bx
         mov       si,offset ListMod
         mov       di,si
         mov       ds:[UkazMod],si
         jcxz      Start38
Start31: mov       ax,ds:[si]
         mov       ds:[di],ax
         push      si
         push      di
         push      cx
         call      VESAVMod                 ; test videom¢du
         pop       cx
         pop       di
         pop       si
         jc        Start34
         inc       word ptr ds:[NumVMod]
         inc       di
         inc       di
         add       word ptr ds:[UkazMod],2
Start34: inc       si
         inc       si
         loop      Start31
Start38: mov       word ptr ds:[di],-1

; ------ zobrazen¡ po‡tu videom¢d–

         mov       si,offset NumVMTxt
         call      DispTxt0
         mov       ax,ds:[NumVMod]
         call      DispNum
         call      DispCR

; ------ nalezen¡ znaku v p©¡kazov‚m © dku

         cld
         mov       si,81h
         mov       ch,0
         mov       cl,ds:[si-1]
         jcxz      Start5
Start4:  lodsb
         cmp       al," "
         loope     Start4

; ------ zobrazen¡ v¨ech videom¢d–

         cmp       al," "
         je        Start5
         cmp       word ptr ds:[ListMod],-1
         je        Start5                   ; nen¡ ‘ dn˜ videom¢d
         call      Zobraz
         jmp       short Start8

; ------ v˜pis v¨ech videom¢d–

Start5:  call      Vypis

Start8:  mov       ax,4c00h                 ; konec programu
         int       21h

; -----------------------------------------------------------------------------
;        zobrazen¡ v¨ech videom¢d–
; -----------------------------------------------------------------------------
;þ
Zobraz   PROC      NEAR

         mov       word ptr ds:[UkazMod],offset ListMod

; ------ na‡ten¡ informac¡ o videom¢du

Zobraz1: call      VESAVMod                 ; na‡ten¡ informac¡ o videom¢du

; ------ nastaven¡ videom¢du

         mov       bx,ds:[VideoMod]         ; aktivn¡ videom¢d
         mov       al,2
         call      VESAInt
         mov       word ptr ds:[AktMap],-1

; ------ zobrazen¡ testovac¡ho obrazce

         call      DispObr

; ------ ‡ek n¡ na stisk kl vesy

Zobraz3: mov       ah,1
         int       16h
         jz        Zobraz32
         mov       ah,0
         int       16h
         jmp       short Zobraz3
Zobraz32:mov       ah,0
         int       16h

; ------ p©eru¨en¡ programu

         cmp       al,13
         je        Zobraz42                 ; ENTER
         or        ax,ax
         jz        Zobraz4
         cmp       al,27
         jne       Zobraz5

; ------ nastaven¡ standardn¡ho videom¢du

Zobraz4: mov       ax,3
         int       10h
Zobraz42:ret

; ------ dal¨¡ videom¢d

Zobraz5: cmp       al," "
         je        Zobraz6
         cmp       ah,4dh
         je        Zobraz6                  ; vpravo
         cmp       ah,50h
         je        Zobraz6                  ; dol–
         cmp       ah,51h
         jne       Zobraz7                  ; PageDown
Zobraz6: mov       si,ds:[UkazMod]
         cmp       word ptr ds:[si+2],-1    ; je dal¨¡ videom¢d ?
         je        Zobraz3                  ; nen¡ dal¨¡ videom¢d
         add       word ptr ds:[UkazMod],2
Zobraz62:jmp       short Zobraz1

; ------ p©ede¨l˜ videom¢d

Zobraz7: cmp       ah,4bh
         je        Zobraz8                  ; vlevo
         cmp       ah,48h
         je        Zobraz8                  ; nahoru
         cmp       ah,49h
         jne       Zobraz82                 ; PageUp
Zobraz8: cmp       word ptr ds:[UkazMod],offset ListMod
         jbe       Zobraz3
         sub       word ptr ds:[UkazMod],2
         jmp       short Zobraz62

; ------ prvn¡ videom¢d

Zobraz82:cmp       ah,47h
         jne       Zobraz83
         mov       word ptr ds:[UkazMod],offset ListMod
         jmp       short Zobraz62

; ------ posledn¡ videom¢d

Zobraz83:cmp       ah,4fh
         jne       Zobraz86
Zobraz84:mov       si,ds:[UkazMod]
         cmp       word ptr ds:[si+2],-1    ; je dal¨¡ videom¢d ?
         je        Zobraz62                 ; nen¡ dal¨¡ videom¢d
         add       word ptr ds:[UkazMod],2
         jmp       short Zobraz84

Zobraz86:jmp       Zobraz3

Zobraz   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ testovac¡ho obrazce
; -----------------------------------------------------------------------------
;þ
DispObr  PROC      NEAR

; ------ maska barev

         mov       al,ds:[VESA+19h]         ; po‡et bit– na bod
         mov       ah,0
         mov       bl,3
         div       bl                       ; po‡et bit– na barvu
         mov       cl,al
         mov       ax,-1
         shl       ax,cl
         mov       ds:[BlueM],ax            ; maska modr‚
         rol       ax,cl
         mov       ds:[GreenM],ax           ; maska zelen‚
         rol       ax,cl
         mov       ds:[RedM],ax             ; maska ‡erven‚

         cmp       word ptr ds:[Verze],102h
         jb        DispOb1A
         test      byte ptr ds:[VESA+0],2
         jz        DispOb1A                 ; nejsou dopl¤kov‚ informace
         mov       ax,-1
         mov       cl,ds:[VESA+23h]         ; velikost modr‚
         shl       ax,cl                    ; maska modr‚
         mov       ds:[BlueM],ax            ; maska modr‚

         mov       ch,cl
         mov       ax,-1
         mov       cl,ds:[VESA+21h]         ; velikost zelen‚
         shl       ax,cl                    ; maska zelen‚
         xchg      cl,ch
         rol       ax,cl                    ; nastaven¡ zelen‚ na pozici
         mov       ds:[GreenM],ax           ; maska zelen‚
         add       ch,cl

         mov       ax,-1
         mov       cl,ds:[VESA+1fh]         ; velikost ‡erven‚
         shl       ax,cl                    ; maska ‡erven‚
         mov       cl,ch
         rol       ax,cl                    ; nastaven¡ ‡erven‚ na pozici
         mov       ds:[RedM],ax             ; maska ‡erven‚

; ------ p©edefinov n¡ palet EGA

DispOb1A:mov       dx,offset PalEGA
         push      ds
         pop       es
         mov       ax,1002h
         push      ds
         int       10h
         pop       ds

; ------ p©edefinov n¡ palet VGA

         push      ds
         pop       es
         mov       dx,offset PalVGA
         xor       bx,bx
         mov       cx,16
         mov       ax,1012h
         push      ds
         int       10h
         pop       ds

; ------ po‡et pozic na © dek

         mov       ax,word ptr ds:[VESA+12h]; ¨¡©ka
         test      byte ptr ds:[VESA+0],10h ; je grafick˜ m¢d ?
         jz        DispOb11                 ; je textov˜ m¢d
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na po‡et znak–
DispOb11:cmp       ax,255
         jbe       DispOb12
         mov       al,255
DispOb12:cmp       al,20
         jae       DispOb13
         mov       al,20
DispOb13:mov       ds:[Pozic],al            ; po‡et pozic na © dek

; ------ p©¡rustek adresy videopamˆti

;         mov       ah,0
;         shl       ax,1
;         test      byte ptr ds:[VESA+0],10h ; je grafick˜ m¢d ?
;         jz        DispO132                 ; je textov˜ m¢d
;         shl       ax,1
;         shl       ax,1                     ; pozice * 8
;         cmp       byte ptr ds:[VESA+19h],8
;         jbe       DispO132
;         mov       dx,2
;         cmp       byte ptr ds:[VESA+19h],16
;         jbe       DispO131
;         mov       dl,3
;         cmp       byte ptr ds:[VESA+19h],24
;         jbe       DispO131
;         mov       dl,4
;DispO131:mul       dx
         mov       ax,word ptr ds:[VESA+10h]
DispO132:mov       ds:[DispInc],ax          ; p©¡rustek adresy videopamˆti

; ------ po‡et bajt– na bod

         xor       dx,dx
         mov       bl,ds:[Pozic]
         mov       bh,0
         div       bx
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       ds:[BodBajtu],ax         ; po‡et bajt– na bod MCGA

; ------ po‡et © dk– displeje

         mov       ax,word ptr ds:[VESA+14h]; v˜¨ka
         test      byte ptr ds:[VESA+0],10h ; je grafick˜ m¢d ?
         jz        DispOb14                 ; je grafick˜ m¢d
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na po‡et znak–
DispOb14:cmp       ax,255
         jbe       DispOb15
         mov       al,255
DispOb15:cmp       al,10
         jae       DispOb16
         mov       al,10
DispOb16:mov       ds:[Radku],al            ; po‡et © dk– displeje

; ------ adresa obsluhy displeje

         mov       word ptr ds:[DispZnkC+1],offset(DispTex-DispZnk1)
         test      byte ptr ds:[VESA+0],10h ; je grafick˜ m¢d ?
         jz        DispOb17                 ; je textov˜ m¢d
         mov       word ptr ds:[DispZnkC+1],offset(DispTRU-DispZnk1)
         cmp       byte ptr ds:[VESA+1bh],6
         je        DispOb17                 ; TRUE-COLOR
         mov       word ptr ds:[DispZnkC+1],offset(DispEGA-DispZnk1)
         cmp       byte ptr ds:[VESA+1bh],3
         je        DispOb17                 ; EGA
         mov       word ptr ds:[DispZnkC+1],offset(DispMCG-DispZnk1)
DispOb17:
         call      DispRam

         mov       dh,ds:[Radku]
         shr       dh,1
         sub       dh,2
         mov       dl,ds:[Pozic]
         shr       dl,1
         sub       dl,(4*7)/2
         call      DispCols
         add       dh,2

         mov       dl,ds:[Pozic]
         shr       dl,1
         sub       dl,34/2
         call      DispVMd                  ; zobrazen¡ videom¢du

         add       dh,2
         mov       dl,ds:[Pozic]
         shr       dl,1
         sub       dl,25/2
         mov       si,offset Zmen2Txt
         call      Disp2Txt

         mov       dx,101h
         call      DispRoh                  ; zobrazen¡ rohu
         mov       dh,1
         mov       dl,ds:[Pozic]
         sub       dl,4
         call      DispRoh
         mov       dh,ds:[Radku]
         sub       dh,3
         mov       dl,1
         call      DispRoh
         mov       dh,ds:[Radku]
         sub       dh,3
         mov       dl,ds:[Pozic]
         sub       dl,4
         call      DispRoh


         ret

DispObr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ rohu
; -----------------------------------------------------------------------------

DispRoh  PROC      NEAR

         mov       ah,9
         mov       al,"1"
         call      DispZnak
         mov       ah,10
         mov       al,"2"
         call      DispZnak
         mov       ah,11
         mov       al,"3"
         call      DispZnak
         sub       dl,3
         inc       dh
         mov       ah,12
         mov       al,"4"
         call      DispZnak
         mov       ah,13
         mov       al,"5"
         call      DispZnak
         mov       ah,14
         mov       al,"6"
         call      DispZnak
         ret

DispRoh  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu
; -----------------------------------------------------------------------------
;þ
DispRam  PROC      NEAR

; ------ horn¡ linka

         mov       dh,0
         call      DispRam5                 ; horn¡ linka

; ------ prvn¡ ‡ st svisl‚ ‡ ry

         mov       dh,1
         mov       al,"º"
         mov       cl,ds:[Radku]
         sub       cl,3
         shr       cl,1
DispRam1:mov       dl,0
         call      DispZnak
         add       dl,ds:[Pozic]
         sub       dl,2
         call      DispZnak
         inc       dh
         loop      DispRam1

; ------ st©edn¡ bod

         mov       cl,ds:[Radku]
         xor       cl,1
         and       cl,1
         inc       cx
DispRam2:mov       dl,0
         mov       al,"Û"
         call      DispZnak
         add       dl,ds:[Pozic]
         sub       dl,2
         call      DispZnak
         inc       dh
         loop      DispRam2

; ------ druh  ‡ st svisl‚ ‡ ry

         mov       al,"º"
         mov       cl,ds:[Radku]
         sub       cl,3
         shr       cl,1
DispRam3:mov       dl,0
         call      DispZnak
         add       dl,ds:[Pozic]
         sub       dl,2
         call      DispZnak
         inc       dh
         loop      DispRam3

; ------ lev˜ horn¡/doln¡ roh

DispRam5:mov       dl,0
         mov       ah,0fh
         mov       al,"Û"
         call      DispZnak

; ------ prvn¡ ‡ st ‡ ry

         mov       ch,0
         mov       cl,ds:[Pozic]            ; po‡et pozic na © dek
         sub       cl,3                     ; bez okraj–
         shr       cl,1
         mov       al,"Í"
DispRam6:call      DispZnak
         loop      DispRam6

; ------ st©edn¡ horn¡/doln¡ roh

         mov       al,"Û"
         call      DispZnak
         mov       cl,ds:[Pozic]            ; po‡et pozic na © dek
         test      cl,1                     ; je lich˜ po‡et pozic ?
         jnz       DispRam7                 ; je lich˜ po‡et pozic
         call      DispZnak                 ; lich˜ st©edn¡ znak

; ------ druh  ‡ st ‡ ry

DispRam7:sub       cl,3                     ; bez okraj–
         shr       cl,1
         mov       al,"Í"
DispRam8:call      DispZnak
         loop      DispRam8

; ------ prav˜ horn¡/doln¡ roh

         mov       al,"Û"
         call      DispZnak
         ret

DispRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ barev
; -----------------------------------------------------------------------------
;þ
DispCols PROC      NEAR

         mov       al,"Û"
         mov       ah,9
DispCls2:call      DispZnak
         call      DispZnak
         call      DispZnak
         call      DispZnak
         inc       ah
         cmp       ah,16
         jb        DispCls2
         ret

DispCols ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla videom¢du
; -----------------------------------------------------------------------------

DispVMd  PROC      NEAR

         mov       si,offset VMod2Txt
         call      Disp2Txt

         mov       ax,ds:[VideoMod]
         call      Disp2Num
         call      Disp2Spc
         mov       al,"("
         call      DispZnk0
         mov       al,byte ptr ds:[VideoMod+1]
         call      Dsp2Hex
         mov       al,byte ptr ds:[VideoMod]
         call      Dsp2HByt
         mov       si,offset Hx2Txt
         call      Disp2Txt

         mov       ax,word ptr ds:[VESA+12h]
         call      Disp2Num
         mov       si,offset RozlTxt1+1
         call      Disp2Txt
         mov       ax,word ptr ds:[VESA+14h]
         call      Disp2Num

         test      byte ptr ds:[VESA+0],10h
         jnz       DispVMd3
         mov       si,offset Txt2Txt
         call      Disp2Txt
         jmp       short DispVMd9

DispVMd3:mov       al,"/"
         call      DispZnk0

         mov       ax,1
         mov       cl,ds:[VESA+19h]
         cmp       cl,10
         jb        DispVMd6

         sub       cl,10
         cmp       cl,10
         jb        DispVMd4
         sub       cl,10
         shl       ax,cl
         call      Disp2Num
         mov       al,"M"
         jmp       short DispVMd5

DispVMd4:shl       ax,cl
         call      Disp2Num
         mov       al,"K"
DispVMd5:call      DispZnk0
         jmp       short DispVMd9

DispVMd6:mov       ax,1
         shl       ax,cl
         call      Disp2Num

DispVMd9:ret

DispVMd  ENDP

;; -----------------------------------------------------------------------------
;;        zobrazen¡ podkladu
;; -----------------------------------------------------------------------------
;
;Podklad  PROC      NEAR
;
;         mov       dh,0
;         mov       ah,0fh
;Podklad1:mov       dl,0
;         mov       bl,10
;Podklad2:mov       al,"ú"
;         dec       bl
;         jnz       Podklad3
;         mov       al,"³"
;         mov       bl,10
;Podklad3:call      DispZnak
;         cmp       dl,ds:[Pozic]
;         jb        Podklad2
;         inc       dh
;         cmp       dh,ds:[Radku]
;         jb        Podklad1
;         ret
;
;Podklad  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ mezery
; -----------------------------------------------------------------------------

Disp2Spc PROC      NEAR

         push      ax
         mov       al," "
         call      DispZnk0
         pop       ax
         ret

Disp2Spc ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ASCIIZ
; -----------------------------------------------------------------------------

Disp2Txt PROC      NEAR

Disp2Tx2:cld
         lodsb
         cmp       al,0
         je        Disp2Tx3
         call      DispZnk0
         jmp       short Disp2Tx2

Disp2Tx3:ret

Disp2Txt ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ slova AX HEX
; -----------------------------------------------------------------------------

Dsp2HWrd PROC      NEAR

         push      ax
         mov       al,ah
         call      Dsp2HByt
         pop       ax

Dsp2HWrd ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu AL HEX
; -----------------------------------------------------------------------------

Dsp2HByt PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      Dsp2Hex
         pop       ax

Dsp2HByt ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL HEX
; -----------------------------------------------------------------------------

Dsp2Hex  PROC      NEAR

         push      ax
         and       al,0fh
         cmp       al,9
         jbe       Dsp2Hex1
         add       al,7
Dsp2Hex1:add       al,"0"
         call      DispZnk0
         pop       ax
         ret

Dsp2Hex  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

Disp2Num PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ dek¢dov n¡ ‡¡sla do z sobn¡ku

         mov       si,dx
         xor       cx,cx                    ; CX <- 0 ‡¡ta‡ znak–
         mov       bx,10
Disp2Nm1:xor       dx,dx
         div       bx                       ; vydˆlen¡ ‡¡sla
         push      dx                       ; £schova zbytku do z sobn¡ku
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–
         or        ax,ax
         jnz       Disp2Nm1

; ------ zobrazen¡ ‡¡sla

         mov       dx,si
Disp2Nm2:pop       ax
         add       al,"0"
         call      DispZnk0                 ; zobrazen¡ ‡¡slice
         loop      Disp2Nm2

; ------ n vrat registr–

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

Disp2Num ENDP

; -----------------------------------------------------------------------------
;        obsluha zobrazen¡ znaku AL (© dek DH, pozice DL, barva AH)
; -----------------------------------------------------------------------------

DispZnk0:push      ax
         mov       ah,0fh
         call      DispZnak
         pop       ax
         ret

DispZnak PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         cld
         push      ax
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1
         add       ax,offset Font
         xchg      ax,si                    ; SI <- adresa znaku
         pop       ax

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       cx,8                     ; po‡et linek na znak
DispZnkC:call      DispTex                  ; skok na obsluhu zobrazen¡ znaku
DispZnk1:

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       dx                       ; zv˜¨en¡ ukazatele pozice
         ret

DispZnak ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku v textov‚m m¢du
; -----------------------------------------------------------------------------

DispTex  PROC      NEAR

         push      ax
         mov       al,ds:[Pozic]            ; po‡et pozic na © dek
         mul       dh                       ; p©epo‡et © dku na pozice
         add       al,dl                    ; p©i‡ten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset ve videopamˆti
         xchg      ax,di                    ; DI <- absolutn¡ pozice znaku
         pop       ax
         stosw
         ret

DispTex  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku v m¢du EGA
; -----------------------------------------------------------------------------

DispEGA  PROC      NEAR

         push      ax

         push      dx
         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al                    ; z pis do v¨ech rovin

         mov       dl,0ceh
         mov       al,0
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; registr 0 = 0
         dec       dx

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,ah
         not       al
         out       dx,al

         pop       dx

         mov       bl,dl
         mov       bh,0
         mov       al,dh                    ; © dek
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; p©epo‡et na linku
         mul       word ptr ds:[DispInc]
         add       ax,bx
         adc       dx,0
         xchg      ax,di                    ; DI <- absolutn¡ pozice znaku
         pop       ax

DispEGA1:call      SetMap                   ; nastaven¡ mapy videopamˆti
         movsb
         dec       di
         add       di,ds:[DispInc]
         adc       dx,0
         loop      DispEGA1
DispEGA9:ret

DispEGA  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku v m¢du MCGA
; -----------------------------------------------------------------------------

DispMCG  PROC      NEAR

         push      ax
         mov       bl,dl
         mov       bh,0
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; p©epo‡et na bod
         mov       al,dh                    ; © dek
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; p©epo‡et na linku
         mul       word ptr ds:[DispInc]
         add       ax,bx
         adc       dx,0
         xchg      ax,di                    ; DI <- absolutn¡ pozice znaku
         pop       ax

DispMCG1:mov       bl,8                     ; po‡et bit– na linku
         lodsb
         mov       bh,al                    ; BH <- st©ada‡ bod–
DispMCG2:call      SetMap                   ; nastaven¡ mapy videopamˆti
         shl       bh,1
         mov       al,0
         jnc       DispMCG3
         mov       al,ah
DispMCG3:mov       es:[di],al
         add       di,1
         adc       dx,0
         dec       bl
         jnz       DispMCG2
         sub       di,8
         sbb       dx,0
         add       di,ds:[DispInc]
         adc       dx,0
         loop      DispMCG1
DispMCG9:ret

DispMCG  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku v m¢du TRUE-COLOR
; -----------------------------------------------------------------------------

DispTRU  PROC      NEAR

         push      ax
         mov       al,dl
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1
         push      dx
         mul       word ptr ds:[BodBajtu]
         xchg      ax,bx
         pop       dx

         mov       al,dh                    ; © dek
         mov       ah,0
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; p©epo‡et na linku
         mul       word ptr ds:[DispInc]
         add       ax,bx
         adc       dx,0
         xchg      ax,di                    ; DI <- absolutn¡ pozice znaku
         pop       ax

         cmp       byte ptr ds:[BodBajtu],3
         jbe       DispTR40                 ; 24 a m‚nˆ bit–

DispTR31:mov       bl,8                     ; po‡et bit– na linku
         lodsb
         mov       bh,al                    ; BH <- st©ada‡ bod–
DispTR32:call      SetMap                   ; nastaven¡ mapy videopamˆti
         shl       bh,1
         mov       al,0
         jnc       DispTR33
         mov       al,0ffh
DispTR33:mov       es:[di],al
         test      ah,1
         jnz       DispTR37
         mov       byte ptr es:[di],0
DispTR37:add       di,1
         adc       dx,0
         call      SetMap                   ; nastaven¡ mapy videopamˆti
         mov       byte ptr es:[di],al
         test      ah,2
         jnz       DispTR34
         mov       byte ptr es:[di],0
DispTR34:add       di,1
         adc       dx,0
         call      SetMap                   ; nastaven¡ mapy videopamˆti

         mov       byte ptr es:[di],al
         test      ah,4
         jnz       DispTR35
         mov       byte ptr es:[di],0
DispTR35:add       di,1
         adc       dx,0
         call      SetMap                   ; nastaven¡ mapy videopamˆti

         mov       byte ptr es:[di],al
         test      ah,8
         jnz       DispTR36
         mov       byte ptr es:[di],0
DispTR36:add       di,1
         adc       dx,0
         dec       bl
         jnz       DispTR32
         sub       di,4*8
         sbb       dx,0
         add       di,ds:[DispInc]
         adc       dx,0
         loop      DispTR31
DispTR39:ret


DispTR40:cmp       byte ptr ds:[BodBajtu],2
         jbe       DispTRU0                 ; 16 a m‚nˆ bit–

DispTR41:mov       bl,8                     ; po‡et bit– na linku
         lodsb
         mov       bh,al                    ; BH <- st©ada‡ bod–
DispTR42:call      SetMap                   ; nastaven¡ mapy videopamˆti
         shl       bh,1
         mov       al,0
         jnc       DispTR43
         mov       al,0ffh
DispTR43:mov       es:[di],al
         test      ah,1
         jnz       DispTR47
         mov       byte ptr es:[di],0
DispTR47:add       di,1
         adc       dx,0
         call      SetMap                   ; nastaven¡ mapy videopamˆti
         mov       byte ptr es:[di],al
         test      ah,2
         jnz       DispTR44
         mov       byte ptr es:[di],0
DispTR44:add       di,1
         adc       dx,0
         call      SetMap                   ; nastaven¡ mapy videopamˆti
         mov       byte ptr es:[di],al
         test      ah,4
         jnz       DispTR45
         mov       byte ptr es:[di],0
DispTR45:add       di,1
         adc       dx,0
         dec       bl
         jnz       DispTR42
         sub       di,3*8
         sbb       dx,0
         add       di,ds:[DispInc]
         adc       dx,0
         loop      DispTR41
DispTR49:ret

DispTRU0:

DispTRU1:mov       bl,8                     ; po‡et bit– na linku
         lodsb
         mov       bh,al                    ; BH <- st©ada‡ bod–
DispTRU2:call      SetMap                   ; nastaven¡ mapy videopamˆti
         shl       bh,1
         mov       al,0
         jnc       DispTRU3
         mov       al,0ffh
DispTRU3:mov       es:[di],al
         test      ah,1
         jnz       DispTRU4
         mov       ch,byte ptr ds:[BlueM]
         and       es:[di],ch
DispTRU4:test      ah,2
         jnz       DispTRU5
         mov       ch,byte ptr ds:[GreenM]
         and       es:[di],ch
DispTRU5:add       di,1
         adc       dx,0
         mov       byte ptr es:[di],al
         test      ah,2
         jnz       DispTRU6
         mov       ch,byte ptr ds:[GreenM+1]
         and       es:[di],ch
DispTRU6:test      ah,4
         jnz       DispTRU7
         mov       ch,byte ptr ds:[RedM+1]
         and       es:[di],ch
DispTRU7:add       di,1
         adc       dx,0
         dec       bl
         jnz       DispTRU2
         sub       di,16
         sbb       dx,0
         add       di,ds:[DispInc]
         adc       dx,0
         dec       cl
         jnz       DispTRU1
DispTRU9:ret

DispTRU  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ mapy videopamˆti DX
; -----------------------------------------------------------------------------

SetMap   PROC      NEAR

         cmp       dx,ds:[AktMap]
         je        SetMap9
         mov       ds:[AktMap],dx

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

         mov       ax,4f05h
         xor       bx,bx
         int       10h

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

SetMap9: ret

SetMap   ENDP

; -----------------------------------------------------------------------------
;        v˜pis v¨ech videom¢d–
; -----------------------------------------------------------------------------
;þ
Vypis    PROC      NEAR

         mov       word ptr ds:[UkazMod],offset ListMod
         mov       si,offset NadpTxt
         call      DispTxt0

; ------ ‡¡slo dal¨¡ho videom¢du

Vypis3:  mov       si,ds:[UkazMod]          ; ukazatel videom¢d–
         mov       ax,ds:[si]               ; ‡¡slo dal¨¡ho videom¢du
         inc       ax                       ; je konec tabulky ?
         jnz       Vypis33                  ; nen¡ je¨tˆ konec tabulky
Vypis32: ret

; ------ na‡ten¡ informac¡ o videom¢du

Vypis33: call      VESAVMod
         add       word ptr ds:[UkazMod],2  ; zv˜¨en¡ ukazatele

; ------ zobrazen¡ ‡¡sla videom¢du

         mov       ax,ds:[VideoMod]         ; ‡¡slo videom¢du
         call      DispNum                  ; zobrazen¡ ‡¡sla videom¢du
         call      DispSpc
         mov       al,"("
         call      DispChr
         mov       al,byte ptr ds:[VideoMod+1]
         call      DispHex
         mov       al,byte ptr ds:[VideoMod]
         call      DispHByt
         mov       al,"h"
         call      DispChr
         mov       al,")"
         call      DispChr

; ------ grafick˜/textov˜

         mov       al,10
         call      DispTab
         mov       si,offset GrafTxt
         test      byte ptr ds:[VESA],10h
         jnz       Vypis37
         mov       si,offset TextTxt
Vypis37: call      DispTxt0

; ------ rozli¨en¡ celkem

         mov       al,20
         call      DispTab
         mov       ax,word ptr ds:[VESA+12h]
         cmp       ax,1000
         jae       Vypis38
         call      DispSpc
Vypis38: cmp       ax,100
         jae       Vypis382
         call      DispSpc
Vypis382:call      DispNum
         mov       ax,word ptr ds:[VESA+14h]
         mov       si,offset RozlTxt2
         cmp       ax,1000
         jae       Vypis39
         mov       si,offset RozlTxt1
Vypis39: call      DispTxt0
         call      DispNum

; ------ po‡et barev

         mov       al,31
         call      DispTab
         test      byte ptr ds:[VESA+0],10h
         jnz       Vypis4A
         mov       si,offset TxtTxt
         call      DispTxt0
         jmp       short Vypis46            ; textov˜ m¢d

Vypis4A: mov       ax,1
         mov       cl,ds:[VESA+19h]
         cmp       cl,7
         jae       Vypis40
         call      DispSpc
         cmp       cl,4
         jae       Vypis40
         call      DispSpc
Vypis40: cmp       cl,10
         jb        Vypis43

         sub       cl,10
         cmp       cl,10
         jb        Vypis41
         sub       cl,10
         shl       ax,cl
         call      DispNum
         mov       al,"M"
         jmp       short Vypis42

Vypis41: shl       ax,cl
         cmp       cl,4
         jae       Vypis411
         call      DispSpc
Vypis411:call      DispNum
         mov       al,"K"
Vypis42: call      DispChr
         jmp       short Vypis44

Vypis43: mov       ax,1
         shl       ax,cl
         call      DispNum

; ------ po‡et bit– na barvu

Vypis44: call      DispSpc
         mov       al,"("
         call      DispChr
         mov       al,ds:[VESA+19h]
         mov       ah,0
         call      DispNum
         mov       si,offset Bit1Txt
         cmp       al,1
         je        Vypis45
         mov       si,offset Bit2Txt
         cmp       al,4
         jbe       Vypis45
         mov       si,offset Bit5Txt
Vypis45: call      DispTxt0

; ------ barevn˜/mono

Vypis46: mov       al,45
         call      DispTab

         mov       si,offset ColorTxt
         test      byte ptr ds:[VESA],8
         jnz       Vypis36
         mov       si,offset MonoTxt
Vypis36: call      DispTxt0

; ------ model videopamˆti

         mov       al,53
         call      DispTab
         mov       al,ds:[VESA+1bh]
         mov       ah,0
         mov       si,offset MTextTxt
         or        ax,ax
         jz        Vypis47
         mov       si,offset MCGATxt
         dec       ax
         jz        Vypis47
         mov       si,offset MHGCTxt
         dec       ax
         jz        Vypis47
         mov       si,offset MEGATxt
         dec       ax
         jz        Vypis47
         mov       si,offset MMCGTxt
         dec       ax
         jz        Vypis47
         mov       si,offset MSEQTxt
         dec       ax
         jz        Vypis47
         mov       si,offset MTRUTxt
         dec       ax
         jz        Vypis47
         mov       si,offset MYUVTxt
         dec       ax
         jz        Vypis47
         dec       ax
         mov       si,offset MVESTxt
         sub       al,16
         jb        Vypis47
         mov       si,offset MOEMTxt
Vypis47: call      DispTxt0

; ------ adresa videopamˆti

         mov       al,66
         call      DispTab
         call      DispSpc
         mov       ax,word ptr ds:[SegmVRAM]
         call      DispHWrd

; ------ podporov n v˜stup BIOS

         mov       al,73
         call      DispTab
         mov       si,offset AnoTxt
         test      byte ptr ds:[VESA],4
         jnz       Vypis35
         mov       si,offset NeTxt
Vypis35: call      DispTxt0

; ------ dal¨¡ videom¢d

         call      DispCR
         jmp       Vypis3

Vypis    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ slova AX HEX
; -----------------------------------------------------------------------------

DispHWrd PROC      NEAR

         push      ax
         mov       al,ah
         call      DispHByt
         pop       ax

DispHWrd ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu AL HEX
; -----------------------------------------------------------------------------

DispHByt PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHex
         pop       ax

DispHByt ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL HEX
; -----------------------------------------------------------------------------

DispHex  PROC      NEAR

         push      ax
         and       al,0fh
         cmp       al,9
         jbe       DispHex1
         add       al,7
DispHex1:add       al,"0"
         call      DispChr
         pop       ax
         ret

DispHex  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ dek¢dov n¡ ‡¡sla do z sobn¡ku

         xor       cx,cx                    ; CX <- 0 ‡¡ta‡ znak–
         mov       bx,10
DispNum1:xor       dx,dx
         div       bx                       ; vydˆlen¡ ‡¡sla
         push      dx                       ; £schova zbytku do z sobn¡ku
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–
         or        ax,ax
         jnz       DispNum1

; ------ zobrazen¡ ‡¡sla

DispNum2:pop       ax
         add       al,"0"
         call      DispChr                  ; zobrazen¡ ‡¡slice
         loop      DispNum2

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        tabul tor pozice AL
; -----------------------------------------------------------------------------

DispTab  PROC      NEAR

DispTab1:cmp       al,ds:[UkazPoz]
         jbe       DispTab2
         call      DispSpc
         jmp       short DispTab1

DispTab2:push      ax
         mov       al,"³"
         call      DispChr
         pop       ax
         ret

DispTab  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ mezery
; -----------------------------------------------------------------------------

DispSpc  PROC      NEAR

         push      ax
         mov       al," "
         call      DispChr
         pop       ax
         ret

DispSpc  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx

         cmp       al,13
         jne       DispChr1
         mov       byte ptr ds:[UkazPoz],0
         jmp       short DispChr4

DispChr1:cmp       al,10
         je        DispChr4
         inc       byte ptr ds:[UkazPoz]

DispChr4:xchg      ax,dx
         mov       ah,2
         int       21h

         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ od© dkov n¡ CR/LF
; -----------------------------------------------------------------------------

DispCR   PROC      NEAR

         push      si
         mov       si,offset CRTxt
         call      DispTxt0
         pop       si
         ret

DispCR   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:SI, 1. bajt = d‚lka
; -----------------------------------------------------------------------------

DispTxt0 PROC      NEAR

         push      cx
         push      es
         push      ds
         pop       es
         mov       cl,ds:[si]
         mov       ch,0
         inc       si
         call      DispTxt
         pop       es
         pop       cx
         ret

DispTxt0 ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ES:SI, CX=d‚lka
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         push      cx

DispTxt1:mov       al,es:[si]
         inc       si
         call      DispChr
         loop      DispTxt1

         pop       cx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ informac¡ o videom¢du AX
; -----------------------------------------------------------------------------

VESAVMod PROC      NEAR

; ------ vymaz n¡ bufferu

         mov       di,offset VESA
         mov       cx,300/2
         xor       ax,ax
         push      ds
         pop       es
         cld
         rep       stosw

; ------ na‡ten¡ informac¡ o videom¢du

         mov       si,ds:[UkazMod]          ; ukazatel videom¢d–
         mov       cx,ds:[si]               ; ‡¡slo dal¨¡ho videom¢du
         mov       ds:[VideoMod],cx         ; £schova ‡¡sla videom¢du
         mov       al,1
         call      VESAInt
         jc        VESAVMd9
         test      byte ptr ds:[VESA],1
         stc
         jz        VESAVMd9

; ------ korekce adresy videopamˆti

         mov       ax,word ptr ds:[VESA+8]
         test      byte ptr ds:[VESA+0],10h
         jnz       VESAVMd1                 ; grafick˜ m¢d
         cmp       ah,0b8h
         je        VESAVMd1
         cmp       ah,0b0h
         je        VESAVMd1
         mov       ax,0b800h
         test      byte ptr ds:[VESA+0],8
         jnz       VESAVMd1                 ; barevn˜ m¢d
         mov       ah,0b0h
VESAVMd1:mov       ds:[SegmVRAM],ax

; ------ kontrola adresy

         cmp       ax,0a000h
         jb        VESAVMd9
         cmp       ax,0f000h
         cmc
         jc        VESAVMd9

; ------ korekce po‡tu bit– na bod

         mov       al,ds:[VESA+19h]         ; po‡et bit– na bod
         cmp       word ptr ds:[Verze],102h
         jb        VESAVMd2
         test      byte ptr ds:[VESA+0],2
         jz        VESAVMd2                  ; nejsou dopl¤kov‚ informace
         cmp       byte ptr ds:[VESA+1bh],6
         jne       VESAVMd2                 ; nen¡ TRUE COLOR
         mov       al,ds:[VESA+1fh]         ; ‡erven 
         add       al,ds:[VESA+21h]         ; zelen 
         add       al,ds:[VESA+23h]         ; modr 
VESAVMd2:mov       ds:[VESA+19h],al
         clc

VESAVMd9:ret

VESAVMod ENDP

; -----------------------------------------------------------------------------
;        obsluha VESA
; -----------------------------------------------------------------------------

VESAInt  PROC      NEAR

         push      ax
         push      di
         push      es

         push      ds
         pop       es
         mov       di,offset VESA
         mov       ah,4fh
         call      Int10
         cmp       ax,4fh
         je        VESAInt9
         stc

VESAInt9:pop       es
         pop       di
         pop       ax
         ret

VESAInt  ENDP

; -----------------------------------------------------------------------------
;        vol n¡ INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10    ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------
;þ
Font     label     byte
INCLUDE  FONT08.ASM

UvTxt    db        UvTxt0-UvTxt-1
         db        'VESAINFO V1.0 - vypis informaci VESA; (c) Miroslav Nemecek (? = test)',13,10
UvTxt0   label     byte

NeniTxt  db        58,'Nedetekovana videokarta kompatibilni se standardem VESA.',13,10

CRTxt    db        2,13,10

JeTxt    db        JeTxt0-JeTxt-1
         db        13,10
         db        'Detekovana videokarta standardu VESA',13,10
         db        '------------------------------------',13,10
         db        'verze VESA ......... '
JeTxt1   db        '1.00',13,10
         db        'oznaceni karty ..... '
JeTxt0   label     byte

PametTxt db        23,13,10,'celkova pamet ...... '

NumVMTxt db        23,13,10,'pocet videomodu .... '

PametTx0 db        3,' MB'
PametTx1 db        3,' KB'

NadpTxt  db        NadpTxt0-NadpTxt-1
         db        13,10
         db        ' videomod ³graf/text³ rozliseni³    barev    ³barevny³model pameti³adresa³BIOS',13,10
         db        'ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄ',13,10
NadpTxt0 label     byte
         db        '256 (112h)³GRAFICKY ³1124 x 512³16M (24 bitu)³BAREVNY³ TRUE-COLOR ³ A000 ³ANO'

GrafTxt  db        8,'GRAFICKY'
TextTxt  db        8,' textovy'

RozlTxt1 db        3,' x ',0
RozlTxt2 db        2,' x'

Bit1Txt  db        5,' bit)'
Bit2Txt  db        6,' bity)'
Bit5Txt  db        6,' bitu)'

ColorTxt db        7,'BAREVNY'
MonoTxt  db        5,' mono'

MTextTxt db        8,'     TXT'
MCGATxt  db        8,'     CGA'
MHGCTxt  db        8,'     HGC'
MEGATxt  db        8,'     EGA'
MMCGTxt  db        8,'    MCGA'
MSEQTxt  db        9,'  SEQ-256'
MTRUTxt  db       11,' TRUE-COLOR'
MYUVTxt  db        8,'     YUV'
MVESTxt  db        8,'    VESA'
MOEMTxt  db        8,'     OEM'

AnoTxt   db        3,'ANO'
NeTxt    db        3,' ne'

VMod2Txt db        'videomod ',0
Zmen2Txt db        17,'ÄÄ  zmena videomodu  ÄÄ',16,0
Hx2Txt   db        'h): ',0

TxtTxt   db        8,'   '
Txt2Txt  db        ' text',0

PalEGA   db        0                        ; ‡ern 
         db        001001b                  ; modr 
         db        010010b                  ; zelen 
         db        011011b                  ; modrozelen 
         db        100100b                  ; ‡erven 
         db        101101b                  ; fialov 
         db        110110b                  ; ‘lut 
         db        111111b                  ; b¡l 
         db        0                        ; ‡ern 
         db        001001b                  ; modr 
         db        010010b                  ; zelen 
         db        011011b                  ; modrozelen 
         db        100100b                  ; ‡erven 
         db        101101b                  ; fialov 
         db        110110b                  ; ‘lut 
         db        111111b                  ; b¡l 
         db        0                        ; okol¡

PalVGA   db        0,0,0                    ; ‡ern 
         db        0,0,63                   ; modr 
         db        0,63,0                   ; zelen 
         db        0,63,63                  ; modrozelen 
         db        63,0,0                   ; ‡erven 
         db        63,0,63                  ; fialov 
         db        63,63,0                  ; ‘lut 
         db        63,63,63                 ; b¡l 
         db        0,0,0                    ; ‡ern 
         db        0,0,63                   ; modr 
         db        0,63,0                   ; zelen 
         db        0,63,63                  ; modrozelen 
         db        63,0,0                   ; ‡erven 
         db        63,0,63                  ; fialov 
         db        63,63,0                  ; ‘lut 
         db        63,63,63                 ; b¡l 

Radku    db        25                       ; po‡et zobrazen˜ch © dk– displeje
Pozic    db        80                       ; po‡et pozic na © dek displeje
DispInc  dw        160                      ; p©¡rustek adresy videopamˆti

BlueM    dw        -1                       ; maska modr‚
GreenM   dw        -1                       ; maska zelen‚
RedM     dw        -1                       ; maska ‡erven‚

AktMap   dw        0                        ; aktivn¡ mapa videopamˆti

SegmVRAM dw        0a000h                   ; segment videopamˆti

Verze    dw        0                        ; verze VESA
VideoMod dw        0                        ; ‡¡slo videom¢du
BodBajtu dw        1                        ; po‡et bajt– na bod MCGA

UkazPoz  db        0                        ; ukazatel pozice na © dku

NumVMod  dw        0                        ; po‡et videom¢d–
UkazMod  dw        ListMod                  ; ukazatel v tabulce videom¢d–
ListMod  dw        MaxMod+1 dup(-1)         ; tabulka videom¢d–
VESA     db        300 dup(0)               ; vstupn¡ buffer

Code     ENDS
         END       Start
