
; modul DOSM.ASM - hlavn¡ ‡ st programu

; *****************************************************************************
;
;                          Hlavn¡ ‡ st programu
;
; *****************************************************************************
code     segment   public
         assume    cs:code,ds:code

extrn    deinit:near,storecnf:near,datarez:byte,execx:near,segrez:word
extrn    parrez:byte,conf2e:byte,init:near,old22:dword,loadpath:near
extrn    aktdir:near,dekfile:near,iniedis:near,aktedis:near,deledis:near
extrn    getmax:near,createseg:near,delseg:near,getseg:near,getssize:near
extrn    nextseg:near,predseg:near,modiseg:near,tisknm2s:near,tisknm20:near
extrn    tisknm0:near,setspc:near,setnul:near,setfre:near,deknumx:near
extrn    deknum:near,deknum0:near,deknum9:near,deknum8:near,deknum7:near
extrn    deknum6:near,deknum5:near,deknum4:near,deknum3:near,deknum2:near
extrn    center:near,lensi0:near,lensi:near,lendi:near,konvfnt:near
extrn    lowcase0:near,lowcase:near,highcase0:near,highcase:near,transtxt:near
extrn    comptxt:near,setkonc:near,testkonc:near,testexe:near,testakt:near
extrn    getakt:near,testaktw:near,testaktwn:near,testakth:near,testsetw:near
extrn    testsetwn:near,getnumf:near,getnuml:near,getendl:near,getpocl:near
extrn    getdispl:near,getdispcx:near,getnakt:near
extrn    wrolldnup:near,wrollup:near,wrolldown:near,outtx0:near,outtxt:near
extrn    flushkey:near,inpkeyf:near,testkey:near,inpkey:near,mouseon:near
extrn    mouseoff:near,mouseget:near,mousemen:near,kurzout:near,outhexw:near
extrn    outhexb:near,outch1:near,outch10:near,outch01:near,outch02:near
extrn    outch:near,outch0:near


public   main,mainx,konec0

         include   dmuse.asm                ; z kladn¡ ovl d n¡ programu

main:                                     ;* hlavn¡ obsluha programu
         sti
         call      uziv                     ; hlavn¡ program - povely
mainx:                                    ;* proveden¡ p©¡kazu, n vrat

         sti
         call      deinit                   ; odinstalov n¡ programu
         call      storecnf                 ; ulo‘en¡ konfigurace

         push      ax
         or        byte ptr cs:[parrez],2   ; p©¡znak opakovan‚ho startu
         mov       al,cs:[conf2]
         mov       cs:[conf2e],al
         pop       ax

         or        al,al                    ; je operace OK ?
         jz        konec001
         jmp       konec0                   ; nen¡ operace OK
                                          ;* zobrazen¡ p©¡kazu
konec001:push      cs
         pop       ds                       ; DS <- CS
         mov       es,ds:[segrez]           ; segment rezidentn¡ch dat
         push      ax

         test      byte ptr cs:[conf7],20h  ; p©¡kaz povel. souborem
         jz        mainx22
         mov       byte ptr es:[80h],1
mainx22:
         cmp       byte ptr es:[80h],4      ; je nˆjak˜ p©¡kaz ?
         jb        mainx2                   ; nen¡ ‘ dn˜ p©¡kaz

         or        dx,dx                    ; m  se text zobrazit ?
         jz        mainx2                   ; text se nem  zobrazit

         call      getakt                   ; poskytnut¡ aktivn¡ho okna
         mov       si,ds:[bp+4]             ; adresa cesty
mainx1:  lodsb
         or        al,al
         jz        mainx3
         call      mainout                  ; zobrazen¡ znaku
         jmp       short mainx1
mainx3:  mov       al,">"
         call      mainout
         mov       cl,es:[80h]              ; d‚lka textu
         xor       ch,ch
         sub       cl,4
         mov       si,84h                   ; text p©¡kazu
         jcxz      mainx7                   ; nen¡ ‘ dn˜ znak p©¡kazu
mainx4:  mov       al,es:[si]
         inc       si
         call      mainout                  ; v˜stup znaku
         loop      mainx4
mainx5:
         mov       al,13
         call      mainout
         mov       al,10
         call      mainout
mainx2:                                   ;* p©enesen¡ dat na rezidentn¡ modul
         test      byte ptr cs:[flags],8    ; je rezidentn¡ re‘im ?
         jz        mainx8                   ; nen¡ rezidentn¡ re‘im
         or        byte ptr cs:[parrez],1   ; p©¡znak rezidentn¡ho re‘imu
         jmp       short mainx6             ; je rezidentn¡ provoz
mainx8:  lea       di,[datarez]             ; za‡ tek rezidentn¡ch dat
         lea       si,[inidata]             ; za‡ tek inicializa‡n¡ch dat
         lea       cx,[inidend]             ; konec inicializa‡n¡ch dat
         sub       cx,si                    ; d‚lka inicializa‡n¡ch dat
         rep       movsb                    ; ulo‘en¡ rezidentn¡ch dat
mainx6:  mov       ax,es                    ; segment pro ulo‘en¡ dat
         mov       bx,cs                    ; tento segment
         cmp       ax,bx                    ; je tento segment ?
         pop       ax                       ; AL=n vratov˜ k¢d
         jne       konec002                 ; je ji‘ v pamˆti

         test      byte ptr cs:[conf7],20h  ; p©¡kaz povel. souborem
         jnz       konec002

         jmp       execx                    ; proveden¡ povelu v p©¡kaz. © dku

konec002:
         test      byte ptr cs:[conf7],20h  ; p©¡kaz povel. souborem
         jz        konec0
         push      ax
         call      ulozhist                 ; ulo‘en¡ historie
         pop       ax

konec0:                                   ;* konec programu (AL=n vratov˜ k¢d)
         push      ax
         mov       ax,2522h
         lds       dx,cs:[old22]
         int       21h                      ; n vrat obsluhy INT 22h
         pop       ax
         mov       ah,4ch                   ; funkce pro n vrat z programu
         int       21h                      ; ukon‡en¡ programu

mainx7:  mov       ds:[80h],ch              ; vynulov n¡ p©¡kazu
         jmp       init                     ; nov  inicializace programu

public   mainout
mainout:                                  ;* v˜stup znaku
                                            ; VSTUP: AL=znak
         push      dx
         push      ax
         mov       dl,al
         mov       ah,2
         int       21h
;         int       29h
         pop       ax
         pop       dx
         ret

public   prodldem
prodldem:                                 ;* prodleva pro DEMO
IFDEF    demo
         pushf
         push      cx
         push      bx
         mov       bh,3
prodld2: xor       cx,cx
         loop      $
         dec       bh
         jnz       prodld2
         pop       bx
         pop       cx
         popf
ENDIF
         ret


         include   dmdat.asm                ; data programu

public   endshell
endshell label     word                      ; adresa konce programu

code     ends

         END
