
; *****************************************************************************
;
;        Nastaven¡ p©enosov‚ rychlosti portu COM
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h

start:
         mov       si,offset uvtxt
         call      outtxt                   ; zobrazen¡ £vodn¡ho textu
         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak–

                                          ;* vstup ‡¡sla portu
         call      readnum                  ; ‡ten¡ ‡¡sla portu
         jz        start3                   ; ‡¡slo portu nezad no
         cmp       ax,4
         ja        start4                   ; chyba zad n¡
         mov       byte ptr ds:[portcom],al ; ‡¡slo portu COM
                                          ;* vstup dˆlic¡ho pomˆru
         call      readnum                  ; ‡ten¡ dˆlic¡ho pomˆru
         jz        start3                   ; dˆlic¡ pomˆr nezad n nebo chyba
         mov       ds:[konstcom],ax         ; zadan˜ dˆlic¡ pomˆr

start3:                                   ;* test, zda nˆco zbylo v zad n¡
         call      outspc                   ; vypu¨tˆn¡ koncov˜ch mezer
         jcxz      start5                   ; nezbyl ‘ dn˜ znak
start4:                                   ;* chyba zad n¡
         mov       si,offset errtxt
         call      outtxt                   ; zobrazen¡ chybov‚ho textu
         int       20h

start5:                                   ;* parametry portu jsou ji‘ zad ny



                                          ;* nastaven¡ parametr– portu
         mov       ax,ds:[konstcom]         ; zadan  p©enosov  rychlost
         or        ax,ax                    ; byla rychlost zad na ?
         jz        start6                   ; rychlost nebyla zad na

         mov       dx,ds:[portcom]          ; ‡¡slo portu COM
         call      getport                  ; zji¨tˆn¡ adresy portu COM
         jc        start7

         cli
         call      setdlab                  ; nastaven¡ DLAB
         out       dx,al                    ; nastaven¡ ni‘¨¡ho bajtu dˆli‡ky
         xchg      ah,al
         inc       dx
         out       dx,al                    ; nastaven¡ vy¨¨¡ho bajtu dˆli‡ky
         call      resdlab                  ; nulov n¡ DLAB
         sti


start6:





start7:                                   ;* zobrazen¡ informac¡ o portech
         mov       cx,1                     ; je jen 1 port
         mov       dx,ds:[portcom]          ; ‡¡slo portu COM
         or        dx,dx                    ; byl port zad n ?
         jnz       start8                   ; je pouze 1 port
         mov       dx,1
         mov       cx,4
start8:  call      zobrport
         inc       dx
         loop      start8




         int       20h


public   zobrport
zobrport:                                 ;* zobrazen¡ informac¡ o portu
                                            ; VSTUP: DX=‡¡slo portu
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         mov       si,offset txtcom1
         call      outtxt                   ; text "COM"
         mov       al,dl
         add       al,"0"
         call      outch                    ; zobrazen¡ ‡¡sla portu
         mov       ax,": "
         call      out2ch                   ; zobrazen¡ textu ": "

         call      getport                  ; poskytnut¡ adresy portu
         mov       si,offset txtcom0
         jc        zobrp8                   ; port nen¡ nainstalov n


                                          ;* zobrazen¡ p©enosov‚ rychlosti
         call      getx                     ; zji¨tˆn¡ dˆlic¡ho pomˆru
         jc        zobrp7                   ; nestandardn¡ port
         cmp       ax,1                     ; je 115 200 Baud ?
         jne       zobrp2                   ; nen¡ 115 200 Baud
         mov       si,offset txtcom2
         call      outtxt                   ; text 115 200
         jmp       short zobrp3
zobrp2:
         call      outmez
         push      dx
         mov       bx,ax
         mov       dx,1
         mov       ax,49664                 ; zbytek do 115200
         div       bx                       ; p©enosov  rychlost
         pop       dx
         call      outnum                   ; zobrazen¡ p©enosov‚ rychlosti
zobrp3:  mov       si,offset txtcom22
         call      outtxt                   ; text "Baud"

         push      dx
         add       dx,3
         in        al,dx                    ; ©¡dic¡ registr linky
         pop       dx

                                          ;* zobrazen¡ parity
         mov       si,offset txtcom33       ; text "bez parity"
         test      al,8                     ; je parita ?
         jz        zobrp4                   ; nen¡ parita
         mov       si,offset txtcom31       ; parita licha
         test      al,10h                   ; parita lich  ?
         jz        zobrp4                   ; parita lich 
         mov       si,offset txtcom32       ; je parita sud 
zobrp4:  call      outtxt                   ; zobrazen¡ textu parity

                                          ;* zobrazen¡ po‡tu bit–
         push      ax
         and       al,3
         add       al,"5"
         call      outch                    ; zobrazen¡ po‡tu datov˜ch bit–
         pop       ax
         mov       si,offset txtcom4        ; text "bit–"
         call      outtxt

                                          ;* zobrazen¡ STOP-bit–
         mov       si,offset txtcom51       ; 1 stop bit
         test      al,4
         jz        zobrp5                   ; je 1 stop bit
         mov       si,offset txtcom52       ; 1.5 stop bitu
         test      al,3                     ; je 5 datov˜ch bit– ?
         jz        zobrp5                   ; je 5 datov˜ch bit–
         mov       si,offset txtcom53       ; 2 stop bity
zobrp5:  call      outtxt

         jmp       short zobrp9
                                          ;* chyba - nestandardn¡ port
zobrp7:  mov       si,offset txtcom11
zobrp8:  call      outtxt
zobrp9:  mov       ax,0d0ah
         call      out2ch
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret







getx:                                     ;* zji¨tˆn¡ p©enos. rychlosti portu DX
         cli
         call      setdlab                  ; nastaven¡ DLAB
         jc        getx9

         push      dx
         in        al,dx
         xchg      ah,al                    ; ni‘¨¡ bajt dˆli‡ky
         inc       dx
         in        al,dx
         xchg      ah,al
         pop       dx

         call      resdlab                  ; nulov n¡ DLAB
getx9:
         sti
         ret









setdlab: push      dx
         push      ax
         add       dx,3
         in        al,dx
         and       al,1fh
         or        al,80h
         out       dx,al                    ; nastaven¡ DLAB
         mov       ah,al
         in        al,dx
         cmp       al,ah
         je        setdlab2
         stc
setdlab2:pop       ax
         pop       dx
         ret







resdlab: push      dx
         push      ax
         add       dx,3
         in        al,dx
         and       al,1fh
         out       dx,al                    ; nastaven¡ DLAB
         mov       ah,al
         in        al,dx
         cmp       al,ah
         je        resdlab2
         stc
resdlab2:pop       ax
         pop       dx
         ret






getport:                                  ;* zji¨tˆn¡ adresy portu COM (DX)
         push      ax
         push      bx
         push      ds
         mov       ax,40h
         mov       ds,ax
         mov       bx,dx
         dec       bx
         add       bx,bx
         mov       dx,ds:[bx]
         or        dx,dx
         jnz       getport2
         stc
getport2:pop       ds
         pop       bx
         pop       ax
         ret





outnum:                                   ;* zobrazen¡ ‡¡sla AX

         push      ax
         push      bx
         push      cx
         push      dx
         xor       cx,cx                    ; CL = p©¡znak 0

         mov       bx,10000
         call      deknum

         mov       bx,1000
         call      deknum

         call      outmez

         mov       bx,100
         call      deknum

         mov       bl,10
         call      deknum

         inc       cl

         mov       bl,1
         call      deknum

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret




deknum:
         mov       ch,2fh

deknum2: inc       ch
         sub       ax,bx
         jnc       deknum2
         add       ax,bx
         push      ax
         mov       al,ch
         cmp       al,"0"
         jne       deknum3
         or        cl,cl
         jnz       deknum4
         mov       al," "
         jmp       short deknum4
deknum3: inc       cl
deknum4: call      outch
         pop       ax
         ret


outmez:  push      ax
         mov       al," "
         call      outch
         pop       ax
         ret


outtxt:                                   ;* v˜stup textu ASCIIZ DS:SI
         push      ax
outtxt2: lodsb
         or        al,al
         jz        outtxt3
         call      outch
         jmp       short outtxt2
outtxt3: pop       ax
         ret

                                          ;* zobrazen¡ 2 znak–
out2ch:  xchg      ah,al
         call      outch
         xchg      ah,al
outch:                                    ;* v˜stup znaku
         push      ax
         push      dx
         mov       dl,al
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret



readnum:                                  ;* ‡ten¡ zadan‚ho ‡¡sla -> AX

         push      bx
         push      dx
         push      di
         call      outspc
         xor       bx,bx
readnum1:call      readch
         jc        readnum3
         sub       al,"0"
         jc        readnum2
         cmp       al,9
         ja        readnum2
         xor       ah,ah
         xchg      ax,bx
         mov       di,10
         mul       di
         add       ax,bx
         xchg      ax,bx
         jmp       short readnum1
readnum2:dec       si
         inc       cx
readnum3:mov       ax,bx
         or        ax,ax
         pop       di
         pop       dx
         pop       bx
         ret


outspc:  call      readch                 ;* vypustˆn¡ mezer
         jc        outspc2
         cmp       al," "
         jbe       outspc
         dec       si
         inc       cx
outspc2: ret



readch:                                   ;* ‡ten¡ znaku
         stc
         jcxz      readch2
         lodsb
         dec       cx
         clc
readch2: ret


portcom  dw        0                        ; ‡¡slo zadan‚ho portu COM
konstcom dw        0                        ; zadan  konstanta portu COM


uvtxt    db        'Nastaveni portu COM (?=napoveda); (c) Miroslav Nemecek'
         db        13,10
         db        '------------------------------------------------------'
         db        13,10,0

txtcom0  db        'nenainstalovan',0
txtcom1  db        ' COM',0
txtcom11 db        'nestandardni port',0
txtcom2  db        '115 200',0
txtcom22 db        ' Baud, ',0


txtcom31 db        'parita licha, ',0
txtcom32 db        ' parita suda, ',0
txtcom33 db        '  bez parity, ',0

txtcom4  db        ' bitu, ',0

txtcom51 db        '1 stop-bit',0
txtcom52 db        '1.5 stop-bitu',0
txtcom53 db        '2 stop-bity',0


errtxt   db  'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍ SETCOM port delici_pomer ÍÍÍÍÍÍÍÍÍÍÍÍÍ»',13,10
         db  'º - port: cislo portu COM (1 az 4)                   º',13,10
         db  'º - delici_pomer: koeficient prenosove rychlosti     º',13,10
         db  'º      1 = 115 200 Baud                  115 200     º',13,10
         db  'º      2 =  57 600 Baud  delici_pomer = ÄÄÄÄÄÄÄÄÄÄ   º',13,10
         db  'º      3 =  38 400 Baud                  rychlost    º',13,10
         db  'º     48 =   2 400 Baud ....                         º',13,10
         db  'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼',13,10
         db  0


code     ends
         end       start


;   Nastaven¡ MODE:
;
;   mode COMm[:]b,[,p[,d[,s[,r]]]]
;        m = 1,2,3,4
;        b = rychlost 110,150,300,600,1200,2400,4800,9600,19200
;        p = parita N (‘ dn ), O (lich ), E (sud ), M (zna‡ka), S (mezera)
;        d = datov˜ch bit– 5,6,7,8
;        s = stop-bit– 1, 1.5, 2
;        r = opakov n¡ E (chyba), B (zanepr zdnˆn), R (p©ipraven), NONE (neop.)
;
;  mode COM1:110,E,7,1,NONE
