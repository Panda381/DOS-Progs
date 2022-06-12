
; *****************************************************************************
;
;                                COMLINK.SYS
;            Program pro spojen¡ po‡¡ta‡– - syst‚mov˜ ovlada‡ disk–
;
; *****************************************************************************

; Soubor COMLINK.SYS slou‘¡ k instalaci d lkov‚ diskov‚ jednotky.
; Soubor se instaluje jako ovlada‡ diskov‚ho za©¡zen¡ do souboru CONFIG.SYS.
; Parametrem "@n" lze zvolit po‡et instalovan˜ch disk– 1 a‘ 26 (max. do
; disku "Z") - implicitnˆ 1. Nap©.: DEVICE=C:\DOS\COMLINK\COMLINK.SYS @4

code     segment
         assume    cs:code,ds:code
         org       0

                                          ;* z hlav¡ ovlada‡e za©¡zen¡
         dd        -1                       ; adresa n sleduj¡c¡ho za©¡zen¡
atribut  dw        0                        ; atributy za©¡zen¡ (blok. za©¡zen¡)
                                            ;   bit 1: p©¡znak "COMPAQ"
         dw        offset strateg           ; offset rutiny strategie
         dw        offset prerus            ; offset rutiny p©eru¨en¡
instdisk db        1                        ; 0ah: po‡et instalovan˜ch disk–
         db        7 dup (0)                ; rezervov no

         db        '$$COML$$'               ; 12h: identifik tor ovlada‡e
         db        '1'                      ; 1ah: "1"=p©¡znak, ‘e je nepou‘it
; -----------------------------------------------------------------------------

adrzahl  dd        0                        ; adresa z hlav¡ za©¡zen¡

; -----------------------------------------------------------------------------
;        Obsluha rutiny STRATEGIE
; -----------------------------------------------------------------------------

strateg  proc      far                    ;* obsluha rutiny strategie

         mov       word ptr cs:[adrzahl],bx ; offset adresy z hlav¡ za©¡zen¡
         mov       word ptr cs:[adrzahl+2],es ; segment adresy z hlav¡ za©¡zen¡
         ret

strateg  endp

; -----------------------------------------------------------------------------
;        Obsluha rutiny PžERU›EN‹
; -----------------------------------------------------------------------------

prerus   proc      far                    ;* obsluha rutiny p©eru¨en¡

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         les       bx,cs:[adrzahl]          ; adresa z hlav¡ za©¡zen¡

                                          ;* kontrola ‡¡sla povelu
         mov       word ptr es:[bx+3],8103h ; chyba - nezn m˜ povel
         cmp       byte ptr es:[bx+2],11    ; kontrola max. ‡¡sla povelu
         ja        prerus3                  ; chyba - nezn m˜ povel

                                          ;* kontrola, zda je inicializace
         mov       byte ptr es:[bx+3],1     ; chyba - nezn m  jednotka
         cmp       byte ptr es:[bx+2],0     ; je inicializace ?
         jne       prerus3                  ; nen¡ inicializace

         call      init                     ; inicializace ovlada‡e za©¡zen¡
prerus3:
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

prerus   endp

; -----------------------------------------------------------------------------

bpb      label     byte                   ;* blok parametr– BIOS BPB disku

         dw        512                      ; 00h: po‡et bajt– na sektor
         db        2                        ; 02h: po‡et sektor– na alok. blok
         dw        1                        ; 03h: zav dˆc¡ a rezerv. sektory
         db        2                        ; 05h: po‡et aloka‡n¡ch tabulek FAT
         dw        7*16                     ; 06h: max. po‡et pol. z kl. adres.
         dw        720                      ; 08h: celkov˜ po‡et sektor– disku
         db        0fdh                     ; 0ah: popisova‡ m‚dia
         dw        2                        ; 0bh: po‡et sektor– v jedn‚ FAT
                                          ;* od DOS 3.00
         dw        9                        ; 0dh: po‡et sektor– na stopu
         dw        2                        ; 0fh: po‡et hlav
         dd        0                        ; 11h: po‡et skryt˜ch sektor–
                                          ;* od DOS 3.31
         dd        720                      ; 15h: celkov˜ po‡et sektor– disku

konec    label     byte                     ; konec rezidentn¡ ‡ sti - 26*2

; *****************************************************************************
;
;                   Inicializace ovlada‡e za©¡zen¡
;
; *****************************************************************************

init     PROC      NEAR

                                          ;* nastaven¡ p©¡znaku COMPAQ
         push      bx
         mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         xchg      ah,al
         cmp       ax,3*256+30              ; je vy¨¨¡ verze ne‘ DOS 3.30 ?
         jbe       init1                    ; je n¡zk  verze syst‚mu
         or        byte ptr cs:[atribut],2  ; p©¡znak velk‚ho disku
init1:   pop       bx


         mov       word ptr es:[bx+3],100h  ; n vratov˜ k¢d - OK
         mov       byte ptr es:[bx+0dh],1   ; po‡et instalovan˜ch disk– = 1

         call      dekodpar                 ; dek¢dov n¡ zadan˜ch parametr–

                                          ;* korekce ozna‡en¡ disk–
         mov       al,es:[bx+16h]           ; po‡ te‡n¡ ‡¡slo disku
         add       cs:[disk1txt],al
         add       cs:[disk2txt],al
         add       cs:[disk3txt],al

                                          ;* zobrazen¡ £vodn¡ho textu
         mov       si,offset uvtxt          ; £vodn¡ text
         call      disptxt                  ; zobrazen¡ textu

                                          ;* zobrazen¡ instalovan˜ch disk–
         mov       si,offset disktxt0       ; text pro 1 disk
         cmp       byte ptr cs:[instdisk],1 ; je 1 disk ?
         je        init2                    ; je 1 disk
         mov       si,offset disktxt        ; text pro v¡ce disk–
init2:   call      disptxt                  ; zobrazen¡ textu

                                          ;* sestaven¡ tabulky BPB
         xor       cx,cx                    ; CX <- 0
         mov       cl,es:[bx+0dh]           ; po‡et instalovan˜ch disk–
         mov       si,offset konec          ; tabulka adres BPB
         mov       es:[bx+12h],si           ; tabulka BPB
         mov       word ptr es:[bx+14h],cs  ; segment adresy tabulky BPB
init3:   mov       word ptr cs:[si],offset bpb ; tabulka BPB
         add       si,2                     ; zv˜¨en¡ ukazatele
         loop      init3                    ; dal¨¡ adresa

                                          ;* nastaven¡ konce ovlada‡e
         mov       es:[bx+0eh],si           ; konec ovlada‡e
         mov       word ptr es:[bx+10h],cs  ; segment konce ovlada‡e
         ret

init     ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ zadan˜ch parametr–
; -----------------------------------------------------------------------------

dekodpar proc      near

         cld                                ; smˆr nahoru
         lds       si,es:[bx+12h]           ; adresa zadan˜ch parametr–

                                          ;* nen¡ ‡¡slo - dal¨¡ parametr
dekodpr1:call      readch                   ; p©esko‡en¡ chybn‚ho znaku
         jc        dekodpr9                 ; nen¡ dal¨¡ znak - konec textu
         cmp       al,"@"                   ; je po‡et disk– ?
         jne       dekodpr1                 ; nen¡ po‡et disk–

                                          ;* ‡ten¡ po‡tu disk–
dekodpr2:call      readnum                  ; na‡ten¡ po‡tu disk–
         jc        dekodpr1                 ; nen¡ platn‚ ‡¡slo

                                          ;* kontrola minim ln¡ho po‡tu disk–
dekodpr4:or        ax,ax                    ; je alespo¤ 1 disk ?
         jz        dekodpr1                 ; nen¡ ‘ dn˜ disk - chyba

                                          ;* kontrola max. po‡tu disk–
         cmp       ax,26                    ; p©ekro‡en po‡et disk– ?
         jbe       dekodpr5                 ; po‡et disk– nen¡ p©ekro‡en
         mov       ax,26                    ; omezen¡ po‡tu disk–

                                          ;* omezen¡ po‡tu disk–
dekodpr5:mov       dx,26                    ; maxim ln¡ ‡¡slo disku
         sub       dl,es:[bx+16h]           ; zbyl˜ po‡et disk–
         cmp       al,dl                    ; p©ekro‡en po‡et disk– ?
         jb        dekodpr6                 ; po‡et disk– nen¡ p©ekro‡en
         mov       al,dl                    ; omezen¡ po‡tu disk–

                                          ;* nastaven¡ po‡tu disk–
dekodpr6:or        al,al                    ; po‡et disk– = 0 ?
         jz        dekodpr1                 ; po‡et disk– = 0 - chyba
         mov       es:[bx+0dh],al           ; po‡et instalovan˜ch disk–
         mov       cs:[instdisk],al         ; po‡et instalovan˜ch disk–
         add       al,"A"-1                 ; ozna‡en¡ posledn¡ho disku
         mov       cs:[disk3txt],al         ; ozna‡en¡ posledn¡ho disku
         jmp       short dekodpr1           ; dal¨¡ test

dekodpr9:ret

dekodpar endp

; -----------------------------------------------------------------------------
;        €ten¡ ‡¡seln‚ho parametru
; -----------------------------------------------------------------------------

readnum  proc      near

         push      cx
         push      dx
         xor       cx,cx                    ; st©ada‡ ‡¡sla
         call      readnm                   ; ‡ten¡ prvn¡ ‡¡slice
         jc        readnum6                 ; nen¡ ‡¡slice
readnum1:push      ax
         mov       ax,10
         mul       cx                       ; st©ada‡ ‡¡sla * 10
         mov       cx,ax
         pop       ax
         xor       ah,ah
         add       cx,ax                    ; p©i‡ten¡ na‡ten‚ ‡¡slice
         call      readnm                   ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       readnum1                 ; p©i‡ten¡ ‡¡slice
         clc                                ; p©¡znak operace OK
readnum6:mov       ax,cx
         pop       dx
         pop       cx
         ret

readnum  endp

; -----------------------------------------------------------------------------
;        €ten¡ ‡¡slice
; -----------------------------------------------------------------------------

readnm   proc      near

         call      readch                   ; ‡ten¡ znaku z textu
         jc        readnm3                  ; nen¡ dal¨¡ znak
         cmp       al,"9"+1
         cmc
         jb        readnm2                  ; nen¡ ‡¡slice
         sub       al,"0"                   ; korekce na bin rn¡ ‡¡slo
         jnc       readnm3                  ; je ‡¡slice
readnm2: dec       si                       ; n vrat chybn‚ho znaku
readnm3: ret

readnm   endp

; -----------------------------------------------------------------------------
;        €ten¡ znaku z textu parametr–
; -----------------------------------------------------------------------------

readch   proc      near

         cld
         lodsb                              ; na‡ten¡ znaku z textu

;                                          ;* p©evod na velk‚ p¡smeno
;         cmp       al,"a"                   ; je mal‚ p¡smeno ?
;         jb        readch7                  ; nen¡ mal‚ p¡smeno
;         cmp       al,"z"                   ; je mal‚ p¡smeno ?
;         ja        readch7                  ; nen¡ mal‚ p¡smeno
;         sub       al,32                    ; p©evod na velk‚ p¡smeno
;
                                          ;* n hrada tabel toru mezerou
readch7: cmp       al,9                     ; je tabel tor ?
         jne       readch8                  ; nen¡ tabel tor
         mov       al," "                   ; n hrada tabel toru mezerou

                                          ;* kontrola, zda je konec © dku
readch8: cmp       al," "                   ; je konec © dku ?
         jae       readch9                  ; nen¡ konec © dku
         dec       si                       ; n vrat posledn¡ho znaku
readch9: ret

readch   endp

; -----------------------------------------------------------------------------
;        Zobrazen¡ textu CS:SI
; -----------------------------------------------------------------------------

disptxt  proc      near

         mov       al,cs:[si]               ; znak k zobrazen¡
         inc       si
         or        al,al
         jz        disptxt9                 ; konec textu
         call      dispch                   ; zobrazen¡ znaku
         jmp       short disptxt            ; dal¨¡ znak
disptxt9:ret

disptxt  endp

; -----------------------------------------------------------------------------
;        Zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

dispch   proc      near

         push      ax
         push      bx
         mov       ah,0eh
         mov       bx,7
         call      int10                    ; zobrazen¡ znaku na displej
         pop       bx
         pop       ax
         ret

dispch   endp

; -----------------------------------------------------------------------------
;        Obsluha INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

int10    proc      near

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

int10    endp

; -----------------------------------------------------------------------------
;        Data pro inicializaci ovlada‡e
; -----------------------------------------------------------------------------

uvtxt    db        13,10,'COMLINK verze 1.00; (c) Miroslav Nemecek; ',0

disktxt0 db        'rezervovany disk '
disk1txt db        'A:',13,10,0

disktxt  db        'rezervovane disky '
disk2txt db        'A: - '
disk3txt db        'A:',13,10,0

; -----------------------------------------------------------------------------

code     ends
         end
