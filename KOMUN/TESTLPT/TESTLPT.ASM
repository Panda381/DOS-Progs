
; *****************************************************************************
;
;                         L P T  -  L I N K
;
;              P�enos soubor� pomoc� paraleln�ho portu - test
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

start:
                                          ;* nalezen� prvn�ho znaku
         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[80h]
         xor       bx,bx
startp1: jcxz      startp2
         lodsb
         cmp       al," "
         jbe       startp1
         cmp       al,"1"
         jc        startp3
         cmp       al,"4"
         jbe       startp4

                                          ;* chyba zad�n� ��sla portu LPT
startp3: mov       dx,offset errtxt
startp5: mov       ah,9
         int       21h
         int       20h

startp4: mov       ds:[insttxt0],al
         mov       ds:[uvtxt0],al
         sub       al,"1"
         mov       bl,al

startp2: add       bx,bx
         push      ds
         mov       ax,40h
         mov       ds,ax
         mov       si,ds:[bx+8]
         pop       ds

         mov       dx,offset insttxt
         or        si,si
         jz        startp5                  ; port nen� nainstalov�n

                                          ;* �vodn� text
         mov       dx,offset uvtxt
         mov       ah,9
         int       21h

         mov       dx,si                    ; adresa portu

         mov       bh,80h
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; nulov�n� v�stupn�ch sign�l�

start1:  mov       ah,1
         int       16h
         jz        start2                   ; nen� znak
         xor       ax,ax
         int       16h
         cmp       al,27
         je        start3

         xor       cl,cl
         cmp       ah,3bh                   ; F1
         je        start4
         dec       cl
         cmp       ah,3ch                   ; F2
         je        start4
         mov       cl,11h
         cmp       ah,3dh                   ; F3
         je        start4
         mov       cl,22h
         cmp       ah,3eh                   ; F4
         je        start4
         mov       cl,44h
         cmp       ah,3fh                   ; F5
         je        start4
         mov       cl,88h
         cmp       ah,40h                   ; F6
         jne       start5
start4:  mov       al,cl
start5:  call      zobr
         call      WritLPT

start2:  call      TestLPT
         jns       start1
         call      ReadLPT
         jcxz      start1

         call      zobr
         jmp       short start1

start3:
         int       20h




zobr:
         push      ax

         cmp       al,0ffh
         je        zobr2
         cmp       al," "
         jae       zobr3
                                          ;* zobrazen� znaku HEX
zobr2:   push      ax
         mov       al,"<"
         call      dispchar
         pop       ax
         call      bytehx
         mov       al,">"
zobr3:   call      dispchar
         pop       ax
         ret


bytehx:  push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      hex
         pop       ax

hex:     push      ax
         and       al,0fh
         add       al,"0"
         cmp       al,"9"
         jbe       hex2
         add       al,7
hex2:    call      dispchar
         pop       ax
         ret

dispchar:push      ax
         push      bx
         push      dx
         mov       ah,0eh
         mov       bx,7
         int       10h
         pop       dx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        V�stup bajtu na port LPT
; -----------------------------------------------------------------------------
; VSTUP: DX=adresa portu LPT
;        BH=bajt 80h
;        AL=znak k v�stupu
; V�STUP:AL=p�ijat� odpov��
;        CX=0: chyba TIME-OUT
; Zni�en� registry: BL
; -----------------------------------------------------------------------------

WritLPT  PROC      NEAR

         mov       bl,al                    ; �schova bajtu k v�stupu
         mov       ch,20                    ; doba pro TIME-OUT odpov�di

                                          ;* vysl�n� ni��� tetr�dy bajtu
         add       al,al                    ; AL << 1 (bity 1 a� 4)
         add       al,al                    ; AL << 1 (bity 2 a� 5)
         add       al,al                    ; AL << 1 (bity 3 a� 6)
         and       al,78h                   ; nulov�n� nepot�ebn�ch bit�
         out       dx,al                    ; vysl�n� ni��� tetr�dy bajtu

                                          ;* vysl�n� strobovac�ho impulsu
         or        al,bh                    ; nastaven� strobovac�ho bitu 7
         jmp       $+2                      ; prodleva
         jmp       $+2                      ; prodleva
         jmp       $+2                      ; prodleva
         out       dx,al                    ; vysl�n� strobovac�ho impulsu

                                          ;* �ek�n� na stav bitu 0 (v klidu = 1)
         inc       dx                       ; vstupn� port LPT
WritLPT1:in        al,dx                    ; �ten� stavu portu
         test      al,bh                    ; test bitu 7
         loopnz    WritLPT1                 ; �ek�n� na bit 0
         dec       dx                       ; v�stupn� port LPT
         jcxz      WritLPT4                 ; byl TIME-OUT

                                          ;* �schova ni��� tetr�dy znaku
         shr       al,1                     ; AL >> 1 (bity 2 a� 5)
         shr       al,1                     ; AL >> 1 (bity 1 a� 4)
         shr       al,1                     ; AL >> 1 (bity 0 a� 3)
         xchg      al,bl                    ; ni��� tetr�da znaku

                                          ;* vysl�n� vy��� tetr�dy bajtu
         shr       al,1                     ; AL >> 1 (bity 3 a� 6)
         or        al,bh                    ; nastaven� strobovac�ho bitu
         out       dx,al                    ; vysl�n� ni��� tetr�dy bajtu

                                          ;* vysl�n� strobovac�ho impulsu
         xor       al,bh                    ; nulov�n� strobovac�ho bitu 7
         jmp       $+2                      ; prodleva
         jmp       $+2                      ; prodleva
         jmp       $+2                      ; prodleva
         out       dx,al                    ; vysl�n� strobovac�ho impulsu

                                          ;* �ek�n� na stav bitu 1
         inc       dx                       ; vstupn� port LPT
WritLPT2:in        al,dx                    ; �ten� stavu portu
         test      al,bh                    ; test bity 7
         loopz     WritLPT2                 ; �ek�n� na bit 1
         dec       dx                       ; v�stupn� port LPT

                                          ;* sestaven� bajtu
         add       al,al                    ; rotace na spr�vnou pozici
         and       al,0f0h                  ; vy��� tetr�da bajtu
         or        al,bl                    ; slou�en� s ni��� tetr�dou znaku

WritLPT4:ret

WritLPT  ENDP

; -----------------------------------------------------------------------------
;        Vstup bajtu z portu LPT
; -----------------------------------------------------------------------------
; VSTUP: DX=adresa portu LPT
;        BH=bajt 80h
; V�STUP:AL=p�ijat� znak
;        CX=0: chyba TIME-OUT
; Zni�en� registry: BL
; -----------------------------------------------------------------------------

ReadLPT  PROC      NEAR

                                          ;* �ek�n� na stav bitu 0 (v klidu = 1)
         mov       ch,20                    ; doba pro TIME-OUT (asi 5000)
         inc       dx                       ; vstupn� port LPT
ReadLPT1:in        al,dx                    ; �ten� stavu portu
         test      al,bh                    ; test bitu 7
         loopnz    ReadLPT1                 ; �ek�n� na bit 0
         dec       dx                       ; v�stupn� port LPT

                                          ;* potvrzen� p��jmu tetr�dy
         mov       bl,al                    ; �schova ni��� tetr�dy znaku
         or        al,bh                    ; nastaven� strobovac�ho bitu
         out       dx,al                    ; potvrzen� p��jmu

                                          ;* �schova ni��� tetr�dy znaku
         shr       bl,1                     ; BL >> 1 (bity 2 a� 5)
         shr       bl,1                     ; BL >> 1 (bity 1 a� 4)
         shr       bl,1                     ; BL >> 1 (bity 0 a� 3)

                                          ;* �ek�n� na stav bitu 1
         inc       cx                       ; p�i TIME-OUT bude CX=1
         inc       dx                       ; vstupn� port LPT
ReadLPT2:in        al,dx                    ; �ten� stavu portu
         test      al,bh                    ; test bity 7
         loopz     ReadLPT2                 ; �ek�n� na bit 1
         dec       dx                       ; v�stupn� port LPT

                                          ;* potvrzen� p��jmu
         xor       al,bh                    ; nulov�n� strobovac�ho bitu
         out       dx,al                    ; potvrzen� p��jmu

                                          ;* sestaven� bajtu
         add       al,al                    ; rotace na spr�vnou pozici
         and       al,0f0h                  ; vy��� tetr�da bajtu
         or        al,bl                    ; slou�en� s ni��� tetr�dou znaku
         ret

ReadLPT  ENDP

; -----------------------------------------------------------------------------
;        Test, zda je zm�na p��znaku portu LPT
; -----------------------------------------------------------------------------
; VSTUP: DX=adresa portu
;        BH=p�vodn� stav bitu 7
; V�STUP:S=byla zm�na stavu portu LPT
; -----------------------------------------------------------------------------

TestLPT  PROC      NEAR

         inc       dx                       ; vstupn� port
         in        al,dx                    ; �ten� stavu portu
         dec       dx                       ; n�vrat datov�ho portu
         xor       al,bh                    ; test zm�ny stavu strobovac�ho bitu
         ret

TestLPT  ENDP

; -----------------------------------------------------------------------------
;                                 DATA
; -----------------------------------------------------------------------------

uvtxt    db        'LPTLINK - test spojeni; (c) Miroslav Nemecek',13,10
         db        'Test portu LPT'
uvtxt0   db        '1 ukoncite klavesou <Esc>',13,10,13,10
         db        'Vzorky: F1=<00>, F2=<FF>, F3(D0)=<11>',13,10
         db        '        F4(D1)=",  F5(D2)=D, F6(D3)=�',13,10,'$'

errtxt   db        'Zadejte cislo portu LPT (1 az 4) !',13,10,'$'

insttxt  db        'Port LPT'
insttxt0 db        '1 neni nainstalovan !',13,10,'$'

code     ENDS
         END       start
