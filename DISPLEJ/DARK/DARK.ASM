code     segment
         assume    cs:code,ds:code
         org       100h

start:   jmp       init

param    db        0                        ; bit 0: 1=je ztmaven¡
                                            ; bit 1: 1=je ztmavov n¡
                                            ; bit 2: 1=funkce je vypnuta

old09    dd        0                        ; p–vodn¡ adresa INT 09h
old10    dd        0                        ; p–vodn¡ adresa INT 10h
old1c    dd        0                        ; p–vodn¡ adresa INT 1ch
delka    dw        0800h                    ; d‚lka videostr nky/2
segvram  dw        0b800h                   ; adresa segmentu VRAM
randomr  dd        0                        ; registr n hodn‚ho ‡¡sla
citac    dw        5*60*18                  ; ‡¡ta‡ ‡asu
znak     dw        0                        ; aktu ln¡ znak
kurzor   dw        0                        ; £schova kurzoru
stranka  db        0                        ; aktivn¡ str nka displeje

int10:   test      byte ptr cs:[param],1    ; je ztmaven¡ ?
         jz        int101                   ; nen¡ ztmaven¡
         or        ah,ah
         jz        int102                   ; zmˆna videom¢du
         cmp       ah,0fh
         je        Int101                   ; poskytnut¡ videom¢du
         cmp       ah,5
         jb        int101
int102:  call      darkoff                  ; rozsv¡cen¡ displeje
int101:  jmp       dword ptr cs:[old10]

int09:
         mov       word ptr cs:[citac],5*60*18 + 60 ; doba pro ztmaven¡
         push      ax
         push      ds
         push      bx
         in        al,[60h]
         test      al,80h
         jnz       int092
         test      byte ptr cs:[param],1    ; je ztmaven¡ ?
         jz        int092                   ; nen¡ ztmaven¡
         call      darkoff                  ; rozsv¡cen¡ displeje
int092:  mov       bx,40h
         mov       ds,bx
         mov       bx,ds:[1ch]
         pushf
         call      dword ptr cs:[old09]
         cmp       bx,ds:[1ch]
         je        int093
         test      byte ptr ds:[17h],3      ; je SHIFT ?
         jz        int093
         cmp       byte ptr ds:[bx+1],62h   ; je Ctrl-F5 ?
         je        int096                   ; je Ctrl-Shift-F5
         cmp       byte ptr ds:[bx+1],63h   ; je Ctrl-F6 ?
         jne       int093                   ; nen¡ Ctrl-Shift-F6
         or        byte ptr cs:[param],4    ; vypnut¡ funkce
         jmp       short int095             ; ignorov n¡ kl vesy
int096:  and       byte ptr cs:[param],not 4 ; zapnut¡ funkce
         call      darkon                   ; ztmaven¡ displeje
int095:  mov       ds:[1ch],bx              ; zru¨en¡ kl vesy
int093:
         pop       bx
         pop       ds
         pop       ax
         iret


int1c:
         cmp       word ptr cs:[citac],0
         je        int1c2
         dec       word ptr cs:[citac]
         jnz       int1c2
         call      darkon
int1c2:
         test      byte ptr cs:[param],1    ; je displej ztmaven˜ ?
         jz        int1c1                   ; displej nen¡ ztmaven˜
         call      darkin                   ; obsluha ztmaven‚ho displeje
int1c1:
         jmp       dword ptr cs:[old1c]


darkon:
         test      byte ptr cs:[param],5         ; m–‘e se ztmaven¡ prov‚st ?
         jnz       darkon3
         pushf
;         sti                                     ; povolen¡ p©eru¨en¡
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       bx,40h
         mov       ds,bx

         mov       ax,0b800h
         cmp       byte ptr ds:[49h],3      ; je videom¢d CGA ?
         jbe       darkon2
         cmp       byte ptr ds:[49h],7
         jne       darkon4                  ; nen¡ textov˜ videom¢d
         mov       ax,0b000h
darkon2: mov       cs:[segvram],ax
         mov       bh,ds:[62h]              ; aktivn¡ str nka displeje
         mov       cs:[stranka],bh          ; aktivn¡ str nka displeje
         mov       ds,ax

         mov       ah,3
         pushf
         call      dword ptr cs:[old10]     ; poskytnut¡ pozice kurzoru
         mov       cs:[kurzor],dx           ; £schova pozice kurzoru
         mov       dx,52*256                ; pozice za rohem
         mov       ah,2
         pushf
         call      dword ptr cs:[old10]     ; nastaven¡ pozice kurzoru

         push      cs
         pop       es
         mov       cx,cs:[delka]
         xor       si,si
         mov       di,offset init
         cld
         rep       movsw                    ; £schova obrazovky
darkon4:
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         or        byte ptr cs:[param],1    ; p©¡znak, ‘e je displej ztmaven
         popf
darkon3:
         ret





darkoff: test      byte ptr cs:[param],1
         jz        darkoff3
         and       byte ptr cs:[param],not 1     ; vypnut¡ p©¡znaku ztmaven¡
         pushf
;         sti                                     ; povolen¡ p©eru¨en¡
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         push      cs
         pop       ds
         mov       es,ds:[segvram]          ; segment VRAM
         mov       cx,ds:[delka]
         xor       di,di
         mov       si,offset init
         cld
         rep       movsw                    ; n vrat obrazovky

         mov       bh,cs:[stranka]          ; aktivn¡ str nka
         mov       dx,cs:[kurzor]           ; uschovan  pozice kurzoru
         mov       ah,2
         pushf
         call      dword ptr cs:[old10]     ; nastaven¡ pozice kurzoru

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
darkoff3:
         ret

darkin:                                   ;* obsluha ztmaven‚ho displeje

         test      byte ptr cs:[param],2
         jnz       darkin9                  ; prob¡h  ji‘ obsluha

         or        byte ptr cs:[param],2
         pushf
;         sti
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
darkin1:
         xor       ax,ax
         mov       ds,ax
         mov       dx,ds:[44ch]             ; d‚lka videostr nky (bajty)
         mov       si,ds:[44eh]             ; adresa videostr nky
         mov       ds,cs:[segvram]          ; segment videopamˆti
         mov       cx,600
darkin2: call      random0
         and       bx,3ffeh
         cmp       bx,dx
         jae       darkin3
         mov       byte ptr ds:[bx+si+1],0
darkin3: loop      darkin2
darkin8: call      random0
         and       bx,3ffeh
         cmp       bx,dx
         jae       darkin88
         mov       ax,cs:[znak]
         mov       ds:[bx+si],ax
darkin88:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         and       byte ptr cs:[param],not 2
darkin9:
         ret



random0  proc      near

         push      ax
         push      cx
         push      dx

         mov       ax,word ptr cs:[randomr]
         mov       bx,word ptr cs:[randomr+2]
         mov       cx,ax
         mul       word ptr cs:[randomd]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       ch,cl
         add       dx,cx
         add       dx,bx
         shl       bx,1
         shl       bx,1
         add       dx,bx
         add       dh,bl
         mov       cl,5
         shl       bx,cl
         add       dh,bl
         add       ax,1
         adc       dx,0
         mov       word ptr cs:[randomr],ax
         mov       word ptr cs:[randomr+2],dx

         mov       bx,dx

         pop       dx
         pop       cx
         pop       ax
         ret

random0  endp

randomd  dw        8405h

; -----------------------------------------------------------------------------
even

init:
         mov       dx,offset uvtxt
         mov       ah,9
         int       21h

         mov       ah,2ah
         int       21h                      ; poskytnut¡ syst‚mov‚ho data
         mov       ax,070fh                 ; b¡l  vlo‡ka
         cmp       dh,12
         jae       init1
         cmp       dh,2
         jbe       init1
         mov       ax,205h                  ; zelen˜ list
         cmp       dh,5
         jbe       init1
         mov       ax,0403h                 ; ‡erven‚ srdce
         cmp       dh,8
         jbe       init1
         mov       ax,606h                  ; hnˆd˜ list
init1:   mov       ds:[znak],ax             ; znak

         cli
         mov       ax,3510h
         int       21h
         mov       word ptr ds:[old10],bx
         mov       word ptr ds:[old10+2],es
         mov       ax,3509h
         int       21h
         mov       word ptr ds:[old09],bx
         mov       word ptr ds:[old09+2],es
         mov       ax,351ch
         int       21h
         mov       word ptr ds:[old1c],bx
         mov       word ptr ds:[old1c+2],es

         mov       dx,offset int10
         mov       ax,2510h
         int       21h
         mov       dx,offset int09
         mov       ax,2509h
         int       21h
         mov       dx,offset int1c
         mov       ax,251ch
         int       21h
         sti

         mov       ah,12h
         mov       bl,10h
         int       10h
         cmp       bl,6
         mov       dx,offset init + 1000h
         jae       init2
         mov       ds:[delka],1000h
         mov       dx,offset init + 2000h
init2:   int       27h


uvtxt    db        'DARK V1.10 - ztmavovac displeje; (c) Miroslav Nemecek',13,10
         db        'okamzite ztmaveni ...... Ctrl-Shift-F5',13,10
         db        'vypnuti ztmavovani ..... Ctrl-Shift-F6',13,10
         db        '$'


code     ends
         end       start
