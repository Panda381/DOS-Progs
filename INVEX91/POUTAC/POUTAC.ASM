
; -----------------------------------------------------------------------------
;
;                         Pouta‡ pro INVEX 91
;
; -----------------------------------------------------------------------------

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

                                          ;* otev©en¡ vstupn¡ho souboru
Start:   mov       dx,offset Soubor
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru POUTAC.SCR
         mov       ds:[Ident],ax            ; identifik tor souboru
         jnc       Start2

                                          ;* chyba - soubor nenalezen
         mov       dx,offset ErrTxt
Start1:  mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         int       20h                      ; n vrat z programu

                                          ;* nastaven¡ grafick‚ho videom¢du
Start2:  mov       ax,16
         int       10h                      ; nastaven¡ videom¢du 16
         mov       ah,0fh
         int       10h                      ; poskytnut¡ videom¢du
         mov       dx,offset KartTxt        ; hl ¨en¡ - nespr vn˜ typ graf.karty
         cmp       al,16                    ; je videom¢d 16 ?
         jne       Start1                   ; videom¢d nenastaven - chyba

                                          ;* vypnut¡ videosign lu
         mov       dx,3dah
         in        al,dx
         mov       dx,3c0h                  ; adresa portu
         xor       al,al
         out       dx,al

                                          ;* instalace obsluhy p©eru¨en¡ Ctrl-C
         mov       ax,2523h
         mov       dx,offset Konec          ; konec programu
         int       21h                      ; p©edefinov n¡ INT 23h

                                          ;* p©esko‡en¡ £vodn¡ch bajt–
         mov       bx,ds:[Ident]            ; identifik tor souboru
         mov       ax,4200h
         xor       cx,cx
         mov       dx,9
         int       21h                      ; ukazatel na offset 9

                                          ;* na‡ten¡ v¨ech barevn˜ch rovin
         mov       ax,0a000h
         mov       ds,ax                    ; segment grafick‚ karty

         mov       ah,1
         xor       bx,bx
         call      readmap                  ; na‡ten¡ modr‚ roviny
         mov       ah,2
         mov       bx,1
         call      readmap                  ; na‡ten¡ zelen‚ roviny
         mov       ah,4
         mov       bx,2
         call      readmap                  ; na‡ten¡ ‡erven‚ roviny
         mov       ah,8
         mov       bx,3
         call      readmap                  ; na‡ten¡ jasov‚ roviny

         push      cs
         pop       ds                       ; n vrat DS

                                          ;* uzav©en¡ souboru
         mov       ah,3eh
         mov       bx,ds:[Ident]
         int       21h                      ; uzav©en¡ souboru

                                          ;* inicializace ‡asov n¡ f z¡
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       bp,ds:[46ch]             ; ‡asova‡
         pop       ds

                                          ;* za‡ tek cyklu p©edefinov n¡ palet
Start3:  mov       si,ds:[UkazPal]          ; ukazatel palet
         mov       cx,14                    ; po‡et palet k p©edefinov n¡
         mov       ah,1                     ; ‡¡slo registru 1

                                          ;* ‡ek n¡ na vertik ln¡ synchroimpuls
         mov       dx,3dah
Start4:  in        al,dx
         test      al,8
         jnz       Start4                   ; ‡ek n¡ na konec synchroimpulsu
Start5:  in        al,dx
         test      al,8
         jz        Start5                   ; ‡ek n¡ na za‡ tek synchoimpulsu

                                          ;* definice jednoho registru
         mov       dx,3c0h                  ; adresa portu
Start6:  mov       al,ah                    ; ‡¡slo registru
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         mov       al,ds:[si+Palety]        ; po‘adovan  paleta registru
         out       dx,al                    ; definice palety
         inc       si                       ; zv˜¨en¡ ukazatele registr–
         inc       ah                       ; zv˜¨en¡ ‡¡sla registru
         loop      Start6                   ; definice dal¨¡ho registru

         mov       al,20h                   ; ukon‡ovac¡ bajt
         out       dx,al                    ; zapnut¡ videosign lu

         dec       word ptr ds:[UkazPal]    ; sn¡‘en¡ ukazatele
         jns       Start7
         mov       word ptr ds:[UkazPal],13 ; nastaven¡ opˆt na konec tabulky

                                          ;* synchonizace na takt hodin
Start7:  push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
Start8:  cmp       bp,ds:[46ch]             ; ‡asova‡
         je        Start8                   ; ‡ek n¡ na zmˆnu stavu hodin
         mov       bp,ds:[46ch]
;Start9:  cmp       bp,ds:[46ch]             ; ‡asova‡
;         je        Start9                   ; ‡ek n¡ na zmˆnu stavu hodin
;         mov       bp,ds:[46ch]
         pop       ds

                                          ;* nen¡-li nic stisknuto, pokra‡ov n¡
         mov       ah,1
         int       16h                      ; je p©ipravena nˆjak  kl vesa ?
         jz        Start3                   ; nen¡ nic stisknuto - pokra‡ov n¡

         xor       ax,ax
         int       16h                      ; zru¨en¡ kl vesy z bufferu kl ves


                                          ;* konec programu - opˆt videom¢d 3
Konec:   mov       ax,3
         int       10h                      ; zpˆtn‚ nastaven¡ text. videom¢du

         int       20h                      ; konec programu


; -----------------------------------------------------------------------------
;        €ten¡ jedn‚ barevn‚ roviny do videopamˆti
; -----------------------------------------------------------------------------

                                          ;* nastaven¡ roviny AH pro z pis
readmap: mov       dx,03c4h
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

                                          ;* na‡ten¡ barevn‚ roviny
         mov       cx,350*80                ; po‡et bajt– v jedn‚ rovinˆ
         xor       dx,dx                    ; ukl dac¡ adresa
         mov       ah,3fh
         mov       bx,cs:[Ident]            ; identifik tor souboru
         int       21h                      ; na‡ten¡ barevn‚ roviny

         ret


; -----------------------------------------------------------------------------
;        Tabulky dat
; -----------------------------------------------------------------------------

Palety   db        57                       ; 1 (modr )
         db        11                       ; 2 (svˆtle modr )
         db        27                       ; 3 (blankytn  mod©)
         db        19                       ; 4 (modrozelen )
         db        26                       ; 5 (namodrale zelen )
         db        18;50                       ; 6 (zelen )
         db        22                       ; 7 (‘lutozelen )
         db        54                       ; 8 (‘lut )
         db        38                       ; 9 (oran‘ov )
         db        52                       ; 10 (oran‘ovˆ ‡erven )
         db        60                       ; 11 (‡erven )
         db        37                       ; 12 (r–‘ov )
         db        45                       ; 13 (svˆtle r–‘ov )
         db        29                       ; 14 (nar–‘ovˆle modr )

         db        57                     ; 1 (modr )
         db        11                       ; 2 (svˆtle modr )
         db        27                       ; 3 (blankytn  mod©)
         db        19                       ; 4 (modrozelen )
         db        26                       ; 5 (namodrale zelen )
         db        18;50                       ; 6 (zelen )
         db        22                       ; 7 (‘lutozelen )
         db        54                       ; 8 (‘lut )
         db        38                       ; 9 (oran‘ov )
         db        52                       ; 10 (oran‘ovˆ ‡erven )
         db        60                       ; 11 (‡erven )
         db        37                       ; 12 (r–‘ov )
         db        45                       ; 13 (svˆtle r–‘ov )
         db        29                       ; 14 (nar–‘ovˆle modr )

UkazPal  dw        0                        ; ukazatel palet

Ident    dw        0                        ; identifik tor souboru

Soubor   db        'POUTAC.SCR',0           ; pracovn¡ soubor

ErrTxt   db        'Nenalezen soubor POUTAC.SCR !',13,10,'$'
KartTxt  db        'Nespravny typ graficke karty - musi byt EGA nebo VGA !',13,10,'$'

code     ENDS
         END       Start
