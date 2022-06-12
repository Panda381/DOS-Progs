
; -----------------------------------------------------------------------------
;
;                     Zobrazova‡ demonstrac¡
;
; -----------------------------------------------------------------------------

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

Start:
                                          ;* nastaven¡ grafick‚ho videom¢du
         mov       ax,13
         int       10h                      ; nastaven¡ videom¢du 16

                                          ;* instalace obsluhy p©eru¨en¡ Ctrl-C
         mov       ax,2523h
         mov       dx,offset Konec          ; konec programu
         int       21h                      ; p©edefinov n¡ INT 23h

                                          ;* na‡ten¡ dal¨¡ho souboru
         call      ReadScr                  ; na‡ten¡ dal¨¡ho souboru
         jc        Konec                    ; nen¡ ‘ dn˜ soubor

                                          ;* nastaven¡ nov‚ videostr nky
Start1:  xor       byte ptr ds:[Stranka],1  ; zmˆna aktivn¡ videostr nky
         mov       al,ds:[Stranka]          ; nov  videostr nka
         mov       ah,5
         int       10h                      ; nastaven¡ nov‚ videostr nky

                                          ;* na‡ten¡ dal¨¡ho souboru
         call      ReadScr                  ; na‡ten¡ dal¨¡ho souboru
         jc        Konec1                   ; nen¡ dal¨¡ soubor

                                          ;* ‡ek n¡ na kl vesu
         xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         cmp       al,27                    ; je Esc ?
         jne       Start1                   ; nen¡ Esc - dal¨¡ obrazovka
         jmp       short Konec


Konec1:  xor       ax,ax
         int       16h                      ; ‡ek n¡ na libovolnou kl vesu

                                          ;* konec programu - opˆt videom¢d 3
Konec:   mov       ax,3
         int       10h                      ; zpˆtn‚ nastaven¡ text. videom¢du

         int       20h                      ; konec programu

; -----------------------------------------------------------------------------
;        Na‡ten¡ souboru do videpamˆti (do neaktivn¡ videostr nky)
; -----------------------------------------------------------------------------

ReadScr:
                                          ;* otev©en¡ vstupn¡ho souboru
         mov       dx,offset Soubor
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru POUTAC.SCR
         jc        ReadScr3                 ; chyba - soubor nenalezen

         mov       ds:[Ident],ax            ; identifik tor souboru

                                          ;* p©esko‡en¡ £vodn¡ch bajt–
         mov       bx,ax                    ; identifik tor souboru
         mov       ax,4200h
         xor       cx,cx
         mov       dx,9
         int       21h                      ; ukazatel na offset 9

                                          ;* na‡ten¡ v¨ech barevn˜ch rovin
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

                                          ;* uzav©en¡ souboru
         mov       ah,3eh
         mov       bx,ds:[Ident]
         int       21h                      ; uzav©en¡ souboru

                                          ;* zv˜¨en¡ ‡¡sla souboru
         inc       byte ptr ds:[Soubor+6]   ; zv˜¨en¡ jednotek ‡¡sla souboru
         cmp       byte ptr ds:[Soubor+6],"9"+1
         jne       ReadScr2
         mov       byte ptr ds:[Soubor+6],"0"

         inc       byte ptr ds:[Soubor+5]   ; zv˜¨en¡ jednotek ‡¡sla souboru
         cmp       byte ptr ds:[Soubor+5],"9"+1
         jne       ReadScr2
         mov       byte ptr ds:[Soubor+5],"0"

         inc       byte ptr ds:[Soubor+4]   ; zv˜¨en¡ jednotek ‡¡sla souboru
         cmp       byte ptr ds:[Soubor+4],"9"+1
         jne       ReadScr2
         mov       byte ptr ds:[Soubor+4],"0"

ReadScr2:clc

ReadScr3:RET

; -----------------------------------------------------------------------------
;        €ten¡ jedn‚ barevn‚ roviny do videopamˆti (do neaktivn¡ videostr nky)
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
         push      ds
         xor       dx,dx                    ; adresa videostr nky 0
         cmp       byte ptr ds:[Stranka],1  ; je aktivn¡ videostr nka 1 ?
         je        ReadMap1                 ; je aktivn¡ videostr nka 1
         mov       dx,2000h                 ; adresa videostr nky 1
Readmap1:mov       cx,200*40                ; po‡et bajt– v jedn‚ rovinˆ
         mov       bx,ds:[Ident]            ; identifik tor souboru
         mov       ax,0a000h
         mov       ds,ax                    ; segment grafick‚ karty
         mov       ah,3fh
         int       21h                      ; na‡ten¡ barevn‚ roviny
         pop       ds

         ret

; -----------------------------------------------------------------------------
;        Tabulky dat
; -----------------------------------------------------------------------------

Stranka  db        0                        ; aktivn¡ videostr nka
Ident    dw        0                        ; identifik tor souboru

Soubor   db        'SHOW001.SCR',0          ; pracovn¡ soubor

code     ENDS
         END       Start
