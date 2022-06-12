
; *****************************************************************************
;
;                   Aktualizace data a ‡asu pro XT
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ definice INT 24h

         mov       dx,offset INT24
         mov       ax,2524h
         int       21h

; ------ definice INT 23h

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h

; ------ zji¨tˆn¡ syst‚mov‚ho data

         mov       ah,2ah
         int       21h                      ; zji¨tˆn¡ syst‚mov‚ho data

; ------ konverze data na form t souboru

         sub       cx,1980                  ; korekce roku
         mov       ax,dx                    ; £schova mˆs¡ce
         mov       dh,cl                    ; rok
         shl       dh,1                     ; rok na spr vnou pozici
         mov       al,0
         mov       cl,3                     ; po‡et rotac¡
         shr       ax,cl                    ; rotace mˆs¡ce na pozici
         or        dx,ax                    ; v˜sledn˜ £daj
         mov       ds:[Date],dx             ; £schova data

; ------ zji¨tˆn¡ syst‚mov‚ho ‡asu

         mov       ah,2ch
         int       21h                      ; zji¨tˆn¡ syst‚mov‚ho ‡asu

; ------ konverze ‡asu na form t souboru

         mov       al,cl                    ; minuta
         mov       ah,0
         mov       cl,5                     ; po‡et rotac¡
         shl       ax,cl                    ; rotace minuty na pozici
         mov       cl,3                     ; po‡et rotac¡
         shl       ch,cl                    ; rotace hodiny na pozici
         or        ah,ch                    ; p©id n¡ hodiny
         shr       dh,1                     ; rotace sekundy na pozici
         or        al,dh                    ; p©id n¡ sekundy
         mov       ds:[Time],ax             ; £schova ‡asu

; ------ nalezen¡ jm‚na souboru v prost©ed¡

         xor       ax,ax
         mov       es,ds:[2ch]              ; prost©ed¡
         cld
         xor       di,di
         inc       di
Start1:  dec       di
         scasw                              ; je konec prost©ed¡ ?
         jne       Start1                   ; nalezen¡ konce prost©ed¡
         inc       di
         inc       di                       ; za‡ tek jm‚na souboru

; ------ otev©en¡ souboru

         push      ds
         push      es
         pop       ds
         mov       dx,di                    ; jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         pop       ds
         jc        Konec                    ; chyba - konec
         mov       bx,ax                    ; identifik tor souboru

; ------ poskytnut¡ data a ‡asu souboru

         mov       ax,5700h
         int       21h                      ; poskytnut¡ data a ‡asu souboru
         jc        Konec

; ------ porovn n¡ data a ‡asu

         mov       ax,ds:[Date]             ; syst‚mov‚ datum
         mov       di,ds:[Time]             ; syst‚mov˜ ‡as
         cmp       byte ptr ds:[80h],1      ; je nˆco zad no ?
         ja        Start4                   ; je nˆco zad no - plat¡ syst‚m
         cmp       dx,ax                    ; porovn n¡ data
         jne       Start3                   ; datum se neshoduje
         cmp       cx,di                    ; porovn n¡ ‡asu
Start3:  ja        Start5                   ; je men¨¡ datum a ‡as ne‘ v souboru

; ------ aktualizace data a ‡asu souboru

Start4:  mov       cx,di                    ; syst‚mov˜ ‡as
         mov       dx,ax                    ; syst‚mov‚ datum
         mov       ax,5701h
         int       21h                      ; nastaven¡ data a ‡asu souboru
         jmp       short Konec1

; ------ bude nastaven¡ data a ‡asu podle souboru

Start5:  mov       ax,dx                    ; datum souboru
         mov       di,cx                    ; ‡as souboru

; ------ konverze data souboru na syst‚mov‚ datum

         and       dl,1fh                   ; maska dne
         mov       cl,5                     ; po‡et rotac¡
         shr       ax,cl                    ; rotace mˆs¡ce
         mov       dh,al                    ; mˆs¡c
         and       dh,0fh                   ; maska mˆs¡ce
         mov       cl,4                     ; po‡et rotac¡
         shr       ax,cl                    ; rotace roku
         xchg      ax,cx                    ; CX <- rok - 1980
         add       cx,1980                  ; korekce £daje roku

; ------ nastaven¡ syst‚mov‚ho data

         mov       ah,2bh
         int       21h                      ; nastaven¡ syst‚mov‚ho data

; ------ konverze ‡asu souboru na syst‚mov˜ ‡as

         mov       ax,di                    ; syst‚mov˜ ‡as
         mov       dh,al                    ; dekunda/2
         and       dh,1fh                   ; maska sekundy
         shr       dh,1                     ; sekunda
         mov       cl,5                     ; po‡et rotac¡
         shr       ax,cl                    ; rotace minuty
         mov       dl,al                    ; £schova minuty
         mov       cl,6                     ; po‡et rotac¡
         shr       ax,cl                    ; rotace hodiny
         mov       ch,al                    ; hodina
         mov       cl,dl                    ; minuta
         and       cl,3fh                   ; maska minuty
         mov       dl,0                     ; setina sekundy

; ------ nastaven¡ syst‚mov‚ho ‡asu

         mov       ah,2dh
         int       21h                      ; nastaven¡ syst‚mov‚ho ‡asu

; ------ uzav©en¡ souboru

Konec1:  mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ n vrat z programu

INT23:
Konec:   int       20h                      ; konec programu

INT24:   mov       al,0                     ; ignorovat
         iret

UvTxt    db        'AKTDAT V 1.12 - aktualizace data XT; (c) Miroslav Nemecek',13,10,'$'

Date     dw        ?                        ; aktu ln¡ datum
                                            ;   bit 0-4: den
                                            ;   bit 5-8: mˆs¡c
                                            ;   bit 9-15: rok-1980

Time     dw        ?                        ; aktu ln¡ ‡as
                                            ;   bit 0-4: sekunda/2
                                            ;   bit 5-10: minuta
                                            ;   bit 11-15: hodina

code     ENDS      

         END       start
