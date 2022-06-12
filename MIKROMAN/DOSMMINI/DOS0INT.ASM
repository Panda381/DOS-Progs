
; modul DOSMINT.ASM - obsluhy p©eru¨en¡

extrn    parint:byte
extrn    citachod:byte,citacexp:byte,color:byte,aktpage:byte,parbreak:word
extrn    buffail:byte,txtfail:byte,txtfai0:byte,txtfai2:byte,txtfai4:byte
extrn    txtfai7:byte,txtfai8:byte,txtfaid:byte,txtfaifa:byte,txtfaidi:byte
extrn    txtfaic:byte,txtfaic2:byte,volbfail:byte,verze:word,windret:near
extrn    transtxt:near,deknum:near,volbyh:near,flushkey:near
extrn    edikeym:word,outch1:near

; *****************************************************************************
;
;                          Obsluhy p©eru¨en¡
;
; *****************************************************************************
code     segment   public
         assume    cs:code,ds:code

public   int24

int24:                                    ;* obsluha kritick˜ch chyb
                                            ; VSTUP: DI=k¢d chyby 0 a‘ 0Ch

         cmp       byte ptr cs:[parbreak],0 ; je ji‘ nˆjak  chyba ?
         je        int241                   ; nen¡ je¨tˆ ‘ dn  chyba
         xor       al,al                    ; n vratov˜ k¢d - ignorov n¡ chyby
         iret

int241:
         or        byte ptr cs:[parint],4   ; p©¡znak INT 24h
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
                                          ;* hl ¨en¡ o chybˆ
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS

         mov       dl,ah                    ; typ chyby
         xor       dh,dh
         add       di,13h                   ; k¢d chyby DOS
         mov       cx,di                    ; k¢d chyby DOS
         push      cx                       ; k¢d chyby DOS
                                          ;* hl ¨en¡ chyby
         lea       di,[buffail]             ; buffer pro hl ¨en¡ chyby
         lea       si,[txtfail]             ; text "Chyba za©¡zen¡ !'
         call      transtxt                 ; p©enos textu
         lea       si,[txtfai0]             ; hl ¨en¡ - ochrana proti z pisu
         cmp       cx,13h                   ; je chyba 13h ?
         jz        int244                   ; je chyba 0
         lea       si,[txtfai2]             ; hl ¨en¡ - nen¡ vlo‘ena disketa
         cmp       cx,15h
         je        int244
         lea       si,[txtfai4]             ; hl ¨en¡ - vadn˜ sektor
         cmp       cx,17h
         je        int244
         lea       si,[txtfai7]             ; hl ¨en¡ - nezn m˜ form t
         cmp       cx,1ah
         je        int244
         lea       si,[txtfai8]             ; hl ¨en¡ - sektor nenalezen
         cmp       cx,1bh
         je        int244
         lea       si,[txtfaid]             ; hl ¨en¡ - poru¨eno sd¡len¡ soubor–
         cmp       cx,1dh
         je        int244
         lea       si,[txtfaifa]            ; hl ¨en¡ - vadn  tabulka FAT disku
         mov       al,dl                    ; typ chyby
         and       al,6
         cmp       al,2                     ; je chyba tabulky FAT ?
         je        int244                   ; je chyba tabulky FAT disku
         lea       si,[txtfaidi]            ; hl ¨en¡ - vadn˜ adres © diskety
         cmp       al,4                     ; je chyba adres ©e ?
         je        int244                   ; je vadn˜ adres © disku
                                          ;* v¨eobecn  chyba
         lea       si,[txtfaic]             ; hl ¨en¡ - nezn m  chyba
         call      transtxt                 ; p©enos textu hl ¨en¡
         push      dx                       ; £schova typu chyby
         mov       ax,cx                    ; k¢d chyby
         xor       dx,dx
         call      deknum                   ; dek¢dov n¡ ‡¡sla chyby
         lea       si,[txtfaic2]
         call      transtxt
         pop       ax                       ; typ chyby
         xor       dx,dx
         call      deknum
         jmp       short int245
int244:  call      transtxt                 ; p©enos textu chyby
int245:  lea       di,[buffail]             ; buffer pro hl ¨en¡ chyby
         lea       si,[volbfail]            ; volby pro chyby
         call      flushkey                 ; vypr zdnˆn¡ kl vesnice
         xor       al,al                    ; p©edvolba
         call      volbyh                   ; proveden¡ voleb
         jc        int248                   ; p©eru¨en¡ operace
         cmp       al,1                     ; p©eru¨en¡ operace ?
         cmc                                ; CY=p©eru¨en¡ nebo ignorov n¡
int248:  pop       cx                       ; k¢d chyby DOS
         mov       bl,1                     ; n vratov˜ k¢d - opakov n¡
         jnc       int249                   ; je opakov n¡
         xor       bl,bl                    ; n vratov˜ k¢d - ignorov n¡
         cmp       al,2                     ; je ignorov n¡ ?
         je        int249                   ; je ignorov n¡ chyby
         mov       word ptr cs:[parbreak],cx ; nastaven¡ k¢du chyby
         cmp       word ptr cs:[verze],3*256+20 ; minim ln¡ verze syst‚mu
         jb        int249                   ; je men¨¡ verze ne‘ 3.20
         mov       bl,3                     ; n vratov˜ k¢d - ohl ¨en¡ chyby
int249:  mov       al,bl                    ; n vratov˜ k¢d
         call      windret                  ; navr cen¡ oken
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         and       byte ptr cs:[parint],not 4; zru¨en¡ p©¡znaku INT 24h
         iret

code     ends

         end
