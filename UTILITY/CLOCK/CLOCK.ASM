
; *****************************************************************************
;
;                         CLOCK - rezidentn¡ hodiny
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h

start:   jmp       init                     ; start - inicializace programu

old1c    dd        0                        ; adresa p–vodn¡ obsluhy INT 1ch
param    db        0                        ; p©¡znak zapnut¡ (1=hodiny zapnuty)
citac    db        18                       ; ‡¡ta‡ pro zobrazen¡

ident    label     near                     ; za‡ tek identifika‡n¡ ‡ sti progr.

int1c:                                    ;* obsluha p©eru¨en¡ INT 08H
         dec       byte ptr cs:[citac]      ; je po‘adavek obsluhy hodin ?
         je        int1c0                   ; je ji‘ po‘adavek hodin
         jmp       int1c9                   ; nen¡ je¨tˆ po‘adavek obsluhy hodin

int1c0:  test      byte ptr cs:[param],1    ; je povoleno zobrazen¡ hodin ?
         jnz       int1c1                   ; je povoleno zobrazen¡
         jmp       int1c8                   ; zobrazen¡ nen¡ povoleno
                                          ;* zobraz¡ se ‡as
int1c1:  push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         cld                                ; smˆr nahoru
                                          ;* zji¨tˆn¡ parametr– podle videom¢du
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       bx,0b800h                ; segment videopamˆti CGA
         mov       al,ds:[449h]             ; sou‡asn˜ videom¢d
         and       al,7fh                   ; zru¨en¡ p©¡znaku maz n¡ displeje
         cmp       al,3                     ; je textov˜ videom¢d CGA ?
         jbe       int1c2                   ; je textov˜ videom¢d CGA
         mov       bx,0b000h                ; segment videopamˆti MDA
         cmp       al,7                     ; je textov˜ videom¢d MDA ?
         jne       int1c7                   ; nen¡ povolen˜ videom¢d
int1c2:  mov       es,bx                    ; segment displeje
         mov       di,ds:[44eh]             ; po‡ te‡n¡ adresa bufferu
         add       di,ds:[44ah]
         add       di,ds:[44ah]             ; adresa konce © dku
         sub       di,16                    ; adresa za‡ tku textu hodin
                                          ;* p©¡pravn˜ v˜po‡et
         mov       ax,ds:[046ch]            ; ‡ten¡ ni‘¨¡ ‡ sti ‡¡ta‡e ‡asu
         mov       dx,ds:[046eh]            ; ‡ten¡ vy¨¨¡ ‡ sti ‡¡ta‡e ‡asu
         mov       cl,4                     ; po‡et rotac¡
         shl       dx,cl                    ; DX * 4
         mov       bx,ax
         mov       cl,12
         shr       bx,cl
         add       dx,bx
         mov       cl,4
         shl       ax,cl
         mov       bx,4446h
         div       bx
         push      dx
         mov       bx,3ch
         xor       dx,dx
         div       bx
                                          ;* zobrazen¡ £daje hodin
         push      dx
         aam
         add       ax,3030h
         call      outch2
         mov       ah,":"
         call      outch
         pop       ax
                                          ;* zobrazen¡ £daje minut
         aam
         add       ax,3030h
         call      outch2
         mov       ah,":"
         call      outch
         pop       ax
                                          ;* zobrazen¡ £daje sekund
         xor       dx,dx
         mov       bx,3ch
         mul       bx
         mov       bx,4446h
         div       bx
         aam
         add       ax,3030h
         call      outch2

int1c7:  pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
int1c8:  mov       byte ptr cs:[citac],18   ; ‡¡ta‡ pro obsluhu hodin
int1c9:  jmp       dword ptr cs:[old1c]     ; p–vodn¡ obsluha INT 1ch

outch2:  call      outch
outch:                                    ;* zobrazen¡ jednoho znaku
         xchg      ah,al
         push      ax
         mov       ah,70h                   ; atribut barvy
         stosw                              ; z pis znaku
         pop       ax
         ret

ident0   label     near                     ; konec identifika‡n¡ ‡ sti programu
; *****************************************************************************
;
;                             Instalace programu
;
; *****************************************************************************
init:                                     ;* nalezen¡ programu v pamˆti
         mov       ax,60h                   ; po‡ te‡n¡ segment ke kontrole
init1:   push      cs
         pop       es                       ; p©ednastaven¡ na vlastn¡ segment
         cmp       ah,0a0h
         jae       init2                    ; rezidentn¡ program nenalezen
         mov       es,ax
         inc       ax                       ; zv˜¨en¡ ‡¡sla segmentu
         cmp       byte ptr es:[0],"M"      ; je vnit©n¡ aloka‡n¡ blok ?
         jne       init1                    ; nen¡ vnit©n¡ aloka‡n¡ blok - dal¨¡
         cmp       ax,es:[1]                ; souhlas¡ vlastn¡k (=je program) ?
         jne       init1                    ; nen¡ program - dal¨¡ blok
         mov       es,ax                    ; ukazatel segmentu
         mov       si,offset ident          ; identifikace programu
         mov       di,si
         mov       cx,offset (ident0-ident) ; d‚lka identifika‡n¡ ‡ sti
         repe      cmpsb                    ; porovn n¡ ©etˆzc–
         jne       init1                    ; ©etˆzec nenalezen - dal¨¡ adresa
         mov       bx,word ptr es:[old1c]   ; p–vodn¡ adresa INT 1ch
         or        bx,word ptr es:[old1c+2] ; je nastavena nˆjak  adresa ?
         jz        init1                    ; je to neplatn˜ program
         call      rozbor                   ; rozbor p©¡kazov‚ho © dku
         int       20h                      ; konec bez instalace

init2:                                    ;* prvn¡ instalace programu
         call      rozbor                   ; rozbor p©¡kazov‚ho © dku
         mov       ax,351ch
         int       21h                      ; poskytnut¡ adresy INT 1ch
         mov       word ptr ds:[old1c],bx   ; £schova offsetu obsluhy
         mov       word ptr ds:[old1c+2],es ; £schova segmentu obsluhy
         mov       dx,offset int1c          ; vlastn¡ obsluha INT 1ch
         mov       ax,251ch
         int       21h                      ; instalace vlastn¡ obsluhy INT 1ch
         push      cs
         pop       es
         mov       dx,offset uvtxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu
         mov       dx,offset init           ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace jako rezidentn¡

rozbor:                                   ;* rozbor zad n¡ z p©¡kaz. © dku
         xor       byte ptr es:[param],1    ; zmˆna p©¡znaku zapnut¡ hodin
         mov       si,81h                   ; za‡ tek parametr– p©¡kaz. © dku
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak–
         jcxz      rozbor3
rozbor2: lodsb
         sub       al,"0"
         jnc       rozbor4                  ; je nˆjak˜ znak
         loop      rozbor2                  ; dal¨¡ znak
rozbor3: ret

rozbor4: mov       byte ptr es:[param],al   ; nov˜ p©¡znak nastaven¡
         ret

uvtxt    db        'CLOCK V1.0 - zobrazeni casu (1=zap, 0=vyp); (c) Miroslav Nemecek'
         db        13,10,'$'

code     ENDS
         END       start
