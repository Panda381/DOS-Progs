
; -----------------------------------------------------------------------------
;
;                          Pouta‡
;
; -----------------------------------------------------------------------------

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

Start:   jmp       init

Par      db        0                        ; parametry:
                                            ;  bit 0=prob¡h  obsluha zobrazen¡

citac    db        0                        ; ‡¡ta‡ ‡asu
citac0   db        0                        ; ‡¡ta‡ pro 1 impuls

old08    dd        0
old10    dd        0

; -----------------------------------------------------------------------------
;        Obsluha INT 10h
; -----------------------------------------------------------------------------

Int10p:  pushf
         call      dword ptr cs:[old10]
         ret

; -----------------------------------------------------------------------------
;        Obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR


         cmp       byte ptr cs:[citac0],0
         je        int080
         dec       byte ptr cs:[citac0]


Int080:  cmp       byte ptr cs:[citac],0
         je        int081
         dec       byte ptr cs:[citac]
         jnz       int082

Int081:  test      byte ptr cs:[par],1
         jnz       int082                   ; prob¡h  ji‘ obsluha - konec

         pushf
         call      dword ptr cs:[old08]

         inc       byte ptr cs:[par]        ; nastaven¡ p©¡znaku obsluhy
         sti
         call      zobraz
         cli
         dec       byte ptr cs:[par]        ; zru¨en¡ p©¡znaku obsluhy
         iret

Int082:  jmp       dword ptr cs:[Old08]

Int08    ENDP


; -----------------------------------------------------------------------------
;        Zobrazen¡
; -----------------------------------------------------------------------------

zobraz:  pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

                                          ;* £schova parametr– displeje
         mov       ah,0fh
         call      int10p                   ; poskytnut¡ videostr nky
         mov       ah,3
         call      int10p                   ; poskytnut¡ pozice kurzoru
         push      dx                       ; £schova pozice kurzoru
         push      cx                       ; £schova rozmˆr– kurzoru
         mov       ah,0fh
         call      int10p                   ; poskytnut¡ videom¢du
         push      bx                       ; £schova aktivn¡ videostr nky

         xor       cx,cx
         mov       ds,cx
         push      word ptr ds:[485h]       ; £schova v˜¨ky znaku

         push      ax                       ; £schova videom¢du



         mov       ax,8dh
         call      int10p                   ; nastaven¡ videom¢du 13

                                          ;* £schova obsahu obrazovky
         mov       di,offset Init           ; buffer k £schovˆ

         mov       dx,3dah
         in        al,dx
         mov       dx,3c0h
         mov       al,0
         out       dx,al

         mov       ah,1
         xor       bx,bx
         call      ctimap                  ; na‡ten¡ modr‚ roviny
         mov       ah,2
         mov       bx,1
         call      ctimap                  ; na‡ten¡ zelen‚ roviny
         mov       ah,4
         mov       bx,2
         call      ctimap                  ; na‡ten¡ ‡erven‚ roviny
         mov       ah,8
         mov       bx,3
         call      ctimap                  ; na‡ten¡ jasov‚ roviny


         mov       si,offset Init+32000
         call      Disp

         push      cs
         pop       ds

         mov       byte ptr ds:[citac],1*18
Cekej:
         mov       byte ptr ds:[citac0],2   ; ‡ek  se 2 takty

                                          ;* za‡ tek cyklu p©edefinov n¡ palet
Pals3:   mov       si,ds:[UkazPal]          ; ukazatel palet
         mov       cx,14                    ; po‡et palet k p©edefinov n¡
         mov       ah,1                     ; ‡¡slo registru 1

                                          ;* ‡ek n¡ na vertik ln¡ synchroimpuls
         sti
         mov       dx,3dah
Pals4:   in        al,dx
         test      al,8
         jnz       Pals4                    ; ‡ek n¡ na konec synchroimpulsu
Pals5:   in        al,dx
         test      al,8
         jz        Pals5                    ; ‡ek n¡ na za‡ tek synchoimpulsu

                                          ;* definice jednoho registru
         mov       dx,3c0h                  ; adresa portu
Pals6:   mov       al,ah                    ; ‡¡slo registru
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         mov       al,ds:[si+Palety]        ; po‘adovan  paleta registru
         out       dx,al                    ; definice palety
         inc       si                       ; zv˜¨en¡ ukazatele registr–
         inc       ah                       ; zv˜¨en¡ ‡¡sla registru
         loop      Pals6                    ; definice dal¨¡ho registru

         mov       al,20h                   ; ukon‡ovac¡ bajt
         out       dx,al                    ; zapnut¡ videosign lu

         sti
         dec       word ptr ds:[UkazPal]    ; sn¡‘en¡ ukazatele
         jns       Pals7
         mov       word ptr ds:[UkazPal],14 ; nastaven¡ opˆt na konec tabulky

                                          ;* synchonizace na takt hodin
Pals7:   cmp       byte ptr ds:[Citac0],0
         jne       pals7

         cmp       byte ptr ds:[citac],0
         jne       cekej


         mov       si,offset Init
         call      Disp                     ; navr cen¡ obsahu

         xor       cx,cx
         mov       ds,cx

                                          ;* n vrat parametr– displeje
         pop       ax                       ; n vrat videom¢du

         push      ax
         mov       ah,0
         or        al,80h
         call      int10p                   ; navr cen¡ videom¢du
         pop       ax

         pop       dx                       ; n vrat po‡tu linek na znak
         cmp       al,7
         je        pals9
         cmp       al,3
         ja        pals8                    ; jsou grafick‚ m¢dy

Pals9:   and       byte ptr ds:[487h],not 1

         mov       al,14h                   ; 8x16
         cmp       dl,16
         je        palsa

         mov       al,11h                   ; 8x14
         cmp       dl,14
         je        palsa

         mov       al,12h
         or        byte ptr ds:[487h],1

Palsa:   mov       ah,11h
         mov       bl,0
         call      int10p                   ; n vrat hustoty © dkov n¡

Pals8:
         pop       bx                       ; p–vodn¡ aktivn¡ videostr nka
         mov       al,bh                    ; p–vodn¡ aktivn¡ videostr nka
         mov       ah,5
         call      int10p                   ; n vrat videostr nky
         pop       cx                       ; p–vodn¡ rozmˆry kurzoru
         mov       ah,1
         call      int10p                   ; n vrat rozmˆr– kurzoru
         pop       dx                       ; p–vodn¡ pozice kurzoru
         mov       ah,2
         call      int10p                   ; n vrat pozice kurzoru

         and       byte ptr ds:[487h],not 80h
         and       byte ptr ds:[449h],not 80h

         mov       byte ptr cs:[citac],10*18

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
         ret


Disp:

         mov       dx,3dah
         in        al,dx
         mov       dx,3c0h
         mov       al,0
         out       dx,al

         mov       ah,1
         xor       bx,bx
         call      zobrmap                  ; na‡ten¡ modr‚ roviny
         mov       ah,2
         mov       bx,1
         call      zobrmap                  ; na‡ten¡ zelen‚ roviny
         mov       ah,4
         mov       bx,2
         call      zobrmap                  ; na‡ten¡ ‡erven‚ roviny
         mov       ah,8
         mov       bx,3
         call      zobrmap                  ; na‡ten¡ jasov‚ roviny

         mov       dx,3dah
         in        al,dx
         mov       dx,3c0h
         mov       al,20h
         out       dx,al
         ret


; -----------------------------------------------------------------------------
;        —schova jedn‚ barevn‚ roviny z videopamˆti
; -----------------------------------------------------------------------------

                                          ;* £schova roviny AH
ctimap:

         mov       dx,03c4h
         mov       al,2
         out       dx,al                    ; registr 2 - volba rovin pro z pis
         inc       dx
         mov       al,ah
         out       dx,al                    ; nastaven¡ roviny pro z pis

                                          ;* nastaven¡ ‡tec¡ roviny
         mov       dx,03ceh
         mov       al,4
         out       dx,al                    ; registr 4 - volba ‡tec¡ roviny
         inc       dx
         mov       al,bl
         out       dx,al                    ; nastaven¡ ‡tec¡ roviny

                                          ;* £schova obrazovky
         push      cs
         pop       es
         mov       ax,0a000h
         mov       ds,ax                    ; segment grafick‚ karty
         xor       si,si
         mov       cx,200*40                ; po‡et bajt– v jedn‚ rovinˆ
         cld
         rep       movsb

         ret

; -----------------------------------------------------------------------------
;        €ten¡ jedn‚ barevn‚ roviny do videopamˆti
; -----------------------------------------------------------------------------

                                          ;* zobrazen¡ roviny AH
zobrmap:
         mov       dx,03c4h
         mov       al,2
         out       dx,al                    ; registr 2 - volba rovin pro z pis
         inc       dx
         mov       al,ah
         out       dx,al                    ; nastaven¡ roviny pro z pis

                                          ;* nastaven¡ ‡tec¡ roviny
         mov       dx,03ceh
         mov       al,4
         out       dx,al                    ; registr 4 - volba ‡tec¡ roviny
         inc       dx
         mov       al,bl
         out       dx,al                    ; nastaven¡ ‡tec¡ roviny

                                          ;* z pis obrazovky
         push      cs
         pop       ds
         mov       ax,0a000h
         mov       es,ax                    ; segment grafick‚ karty
         mov       cx,200*40                ; po‡et bajt– v jedn‚ rovinˆ
         cld
         xor       di,di
         rep       movsb

         ret


; -----------------------------------------------------------------------------
;        Tabulky dat
; -----------------------------------------------------------------------------

Palety   label     byte
;        db        9                        ; 0 modr 
         db        57                       ; 1 (modr )
         db        11                       ; 2 (svˆtle modr )
         db        27                       ; 3 (blankytn  mod©)
         db        19                       ; 4 (modrozelen )
         db        26                       ; 5 (namodrale zelen )
         db        50                       ; 6 (zelen )
         db        22                       ; 7 (‘lutozelen )
         db        54                       ; 8 (‘lut )
         db        38                       ; 9 (oran‘ov )
         db        52                       ; 10 (oran‘ovˆ ‡erven )
         db        60                       ; 11 (‡erven )
         db        37                       ; 12 (r–‘ov )
         db        45                       ; 13 (svˆtle r–‘ov )
         db        29                       ; 14 (nar–‘ovˆle modr )
;         db        9                        ; 15 modr 

;         db        9                        ; 0 modr 
         db        57                       ; 1 (modr )
         db        11                       ; 2 (svˆtle modr )
         db        27                       ; 3 (blankytn  mod©)
         db        19                       ; 4 (modrozelen )
         db        26                       ; 5 (namodrale zelen )
         db        50                       ; 6 (zelen )
         db        22                       ; 7 (‘lutozelen )
         db        54                       ; 8 (‘lut )
         db        38                       ; 9 (oran‘ov )
         db        52                       ; 10 (oran‘ovˆ ‡erven )
         db        60                       ; 11 (‡erven )
         db        37                       ; 12 (r–‘ov )
         db        45                       ; 13 (svˆtle r–‘ov )
         db        29                       ; 14 (nar–‘ovˆle modr )
;         db        9                        ; 15 modr 

UkazPal  dw        0                        ; ukazatel palet


; -----------------------------------------------------------------------------
;        Instalace programu do pamˆti
; -----------------------------------------------------------------------------

Init:
                                          ;* sestaven¡ jm‚na souboru
         mov       si,81h
         mov       cl,ds:[80h]
         mov       ch,0
         cld

                                          ;* nalezen¡ za‡ tku jm‚na
start01: jcxz      Start0                   ; chyba zad n¡
         mov       dx,si
         lodsb
         dec       cx
         cmp       al," "
         jbe       start01

                                          ;* nalezen¡ konce jm‚na
start02: jcxz      start03
         lodsb
         dec       cx
         cmp       al," "
         ja        start02
         dec       si
start03: mov       byte ptr ds:[si],0

                                          ;* otev©en¡ vstupn¡ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru POUTAC.SCR
         mov       bx,ax                    ; identifik tor souboru
         jnc       Start2

                                          ;* chyba - soubor nenalezen
Start0:  mov       dx,offset ErrTxt
Start1:  mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         int       20h                      ; n vrat z programu


                                          ;* p©esko‡en¡ £vodn¡ch bajt–
start2:
         mov       ax,4200h
         xor       cx,cx
         mov       dx,9
         int       21h                      ; ukazatel na offset 9

                                          ;* na‡ten¡ souboru do pamˆti
         mov       cx,32000                 ; d‚lka souboru
         mov       dx,offset(init + 32000)  ; adresa k na‡ten¡ souboru
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru do bufferu

                                          ;* uzav©en¡ souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

                                          ;* instalace obsluh p©eru¨en¡
         mov       ax,3508h
         int       21h
         mov       word ptr ds:[old08],bx
         mov       word ptr ds:[old08+2],es
         mov       dx,offset int08
         mov       ax,2508h
         int       21h

         mov       ax,3510h
         int       21h
         mov       word ptr ds:[old10],bx
         mov       word ptr ds:[old10+2],es
;         mov       dx,offset int10
;         mov       ax,2510h
;         int       21h

                                          ;* instalace programu
         mov       dx,offset(init + 32000 + 32000)
         int       27h

ErrTxt   db        'Chybne zadani vstupniho souboru !',13,10,'$'

code     ENDS
         END       Start
