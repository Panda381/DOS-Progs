code     segment
         assume    cs:code,ds:code
         org       100h

start:
         mov       si,81h                   ; jm‚no zadan‚ho souboru
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[80h]              ; po‡et znak– zad n¡

         call      spc
         jc        error

         mov       dx,si
strt2:   call      readch
         jc        strt3
         cmp       al," "
         ja        strt2                    ; nalezen¡ konce
         dec       si
         inc       cx
strt3:   mov       byte ptr ds:[si],0       ; konec jm‚na

         mov       ax,3d00h                 ; otev©en¡ souboru pro ‡ten¡
         int       21h                      ; otev©en¡ souboru
         jnc       strt4                    ; soubor otev©en OK

error:   mov       dx,offset errtxt
         mov       ah,9
         int       21h
         int       20h


strt4:
         mov       ds:[ident],ax            ; identifik tor souboru

strt5:   call      readch
         jc        strt7

         cmp       al,"/"
         je        strt5


         or        al,20h

         cmp       al,"f"
         jne       strt52

         call      readnum                  ; ‡ten¡ ‡¡sla
         mov       ds:[first],ax
         jmp       short strt5

strt52:
         cmp       al,"w"
         jne       strt53

         call      readnum                  ; ‡ten¡ ‡¡sla
         mov       ds:[width2],ax
         jmp       short strt5

strt53:
         cmp       al,"n"
         jne       strt54

         call      readnum                  ; ‡ten¡ ‡¡sla
         mov       ds:[num],ax              ; prvn¡ ‡¡slo
         mov       word ptr ds:[right],0
         jmp       short strt5

strt54:





         jmp       short strt5


strt7:

         mov       ax,ds:[right]
         inc       ax
         jz        strt72

         mov       ax,ds:[width2]
         mov       bx,4
         mul       bx
         mov       word ptr ds:[right],ax   ; prav˜ okraj

strt72:
         mov       cx,ds:[first]
         jcxz      strt82

strt74:  call      inpbyte
         jc        strt9
         loop      strt74




strt82:  mov       cx,ds:[width2]

strt8:
         call      inpbyte
         jc        strt9

         call      disphex

         mov       al," "
         call      dispch

;         cmp       cx,
;         jne       strt810
;
;         mov       al,13
;         call      dispch
;         mov       al,10
;         call      dispch
;
;strt810:
;
;         test      cl,1
;         jz        strt811
;         mov       al,"0"
;         call      dispch
;         mov       al," "
;         call      dispch
;         call      dispch
;
;strt811:
         loop      strt8


         mov       bx,ds:[right]
         inc       bx
         jz        strt83

strt84:
         cmp       bx,ds:[pozice]
         jbe       strt85
         mov       al," "
         call      dispch
         jmp       short strt84

strt85:  mov       al,";"
         call      dispch
         mov       al," "
         call      dispch
         mov       ax,ds:[num]
         call      dispdek
         mov       al," "
         call      dispch
         mov       ax,ds:[num]
         cmp       al," "
         jb        strt87
         call      dispasc3
strt87:  inc       word ptr ds:[num]

strt83:
         mov       al,13
         call      dispch
         mov       al,10
         call      dispch
         jmp       short strt82


strt9:   mov       ah,3eh
         mov       bx,ds:[ident]
         int       21h

         int       20h




inpbyte:                                  ;* vstup bajtu ze souboru

         push      si
         mov       si,ds:[ukazch]           ; ukazatel ‡ten˜ch znak–
         cmp       si,ds:[numch]
         jb        inpbyt3

         push      ax
         push      bx
         push      cx
         push      dx
         mov       dx,offset buffer
         mov       cx,512
         mov       ah,3fh
         mov       bx,ds:[ident]
         int       21h
         jnc       inpbyt2
         xor       ax,ax
inpbyt2: mov       ds:[numch],ax
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         xor       si,si
         cmp       si,ds:[numch]
         stc
         je        inpbyt4

inpbyt3: clc
         mov       al,ds:[si+buffer]
         inc       si
         mov       ds:[ukazch],si
inpbyt4: pop       si
         ret


dispspec:                                 ;* zobrazen¡ speci ln¡ho znaku
         push      ax
         mov       ah,"!"
         cmp       al,27                    ; ESC
         je        dispctr9
         mov       ah,"?"
         cmp       al,28                    ; FS
         jne       dispctr8
dispctr9:mov       al,ah
         call      dispch
         pop       ax
         ret

dispctr8:pop       ax

dispasc:                                  ;* zobrazen¡ znaku ASCII
         cmp       al,32
         jb        dispdek                  ; zobrazen¡ ©¡dic¡ho znaku
         cmp       al,34
         je        dispdek                  ; uvozovky
         cmp       al,"!"
         je        dispasc3
         cmp       al,"?"
         je        dispasc3
         cmp       al,"$"
         je        dispasc3
         cmp       al,";"
         je        dispasc3
         cmp       al,"{"
         je        dispasc3
         cmp       al,"}"
         je        dispasc3
         cmp       al,"#"
         je        dispasc3
         cmp       al,"/"
         je        dispasc3
         cmp       al,"0"
         jb        dispasc2
         cmp       al,"9"
         jb        dispasc3
dispasc2:call      dispch
         ret


dispasc3:push      ax
         mov       al,'"'
         call      dispch
         pop       ax
         call      dispch
         push      ax
         mov       al,'"'
         call      dispch
         pop       ax
         ret

disphex:                                  ;* zobrazen¡ hexadecim ln¡ho znaku
         cmp       al,10
         jb        disphx
         push      ax
         mov       al,"$"
         call      dispch
         pop       ax
         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         and       al,0fh
         jz        disphex2
         call      disphx
disphex2:pop       ax

disphx:  push      ax
         and       al,0fh
         cmp       al,10
         jb        disphx2
         add       al,7
disphx2: add       al,"0"
         call      dispch
         pop       ax
         ret


dispdek:                                  ;* zobraz. bajtu v dekadick‚m form tu
         push      ax
         push      dx
         xor       ah,ah
         mov       dl,al
         cmp       dl,100
         jb        dispdek3
         mov       al,"1"
         cmp       dl,200
         jb        dispdek2
         inc       al
         sub       dl,100
dispdek2:call      dispch
         sub       dl,100
         jmp       short dispdek4
dispdek3:cmp       dl,10
         jb        dispdek6
dispdek4:mov       al,dl
         mov       dl,10
         div       dl
         add       al,"0"
         call      dispch
         mov       dl,ah
dispdek6:mov       al,dl
         add       al,"0"
         call      dispch
         pop       dx
         pop       ax
         ret

dispch:                                   ;* zobrazen¡ znaku
         push      ax
         push      dx
         cmp       al,10
         je        dispch2
         inc       word ptr ds:[pozice]
         cmp       al,13
         jne       dispch2
         mov       word ptr ds:[pozice],0
dispch2: mov       dl,al
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret



spc:                                      ;* ignorov n¡ mezer
         call      readch
         jc        spc2
         cmp       al," "
         jbe       spc
         dec       si
         inc       cx
spc2:    ret


readch:                                   ;* ‡ten¡ znaku z p©¡kazov‚ho © dku
         stc
         jcxz      readch2
         lodsb
         dec       cx
         clc
readch2: ret


readnum: push      bx
         push      dx
         xor       bx,bx
readnum2:call      readch
         jc        readnum4
         sub       al,"0"
         jb        readnum3
         cmp       al,9
         ja        readnum3
         xor       ah,ah
         push      ax
         mov       ax,10
         mul       bx
         pop       bx
         add       bx,ax
         jmp       short readnum2
readnum3:dec       si
         inc       cx
readnum4:mov       ax,bx
         pop       dx
         pop       bx
         ret


pozice   dw        0                        ; ‡¡ta‡ pozice na © dku

errtxt   db        'Chyba zadani vstupniho souboru !',13,10
         db        'Zadejte: DUMPDWN soubor [prepinace] > vystupni_soubor',13,10
         db        'Prepinace: /F n - zobrazovani od bajtu n',13,10
         db        '           /W n - pevna sirka n bajtu na radek',13,10
         db        '           /N n - oznacovani fontu od cisla n',13,10
         db        '$'

first    dw        0                        ; adresa prvn¡ho bajtu
width2   dw        12                       ; ¨¡©ka © dku (bajt–)
right    dw        -1                       ; prav˜ okraj
num      dw        0                        ; ‡¡slov n¡ znak–


ident    dw        0                        ; identifik tor vstupn¡ho souboru

ukazch   dw        0                        ; ukazatel ‡ten‚ho znaku
numch    dw        0                        ; po‡et znak– v bufferu
buffer   label     byte                     ; buffer pro ‡ten¡ souboru


code     ends
         end       start
