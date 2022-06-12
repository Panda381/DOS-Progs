Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ nadefinov n¡ INT 23h

Start:   mov       dx,offset INT23
         mov       ax,2523h
         int       21h

; ------ nadefinov n¡ INT 24h

         mov       dx,offset INT24
         mov       ax,2524h
         int       21h

; ------ £schova aktivn¡ho disku

         mov       ah,19h
         int       21h
         mov       ds:[OldDisk],al          ; £schova aktivn¡ho disku

; ------ na‡ten¡ jm‚na disku

         mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0
         cld
Start1:  jcxz      Chyba                    ; nen¡ nic zad no
         lodsb
         dec       cx
         cmp       al," "
         jbe       Start1

; ------ ‡¡slo disku

         and       al,not 20h
         mov       ds:[VolTxt1],al          ; ozna‡en¡ disku
         sub       al,"A"

; ------ nastaven¡ disku jako aktivn¡

         xchg      ax,dx
         mov       ah,0eh
         int       21h

; ------ test, zda byl disk nastaven

         mov       ah,19h
         int       21h                      ; na‡ten¡ ‡¡sla disku
         cmp       al,dl                    ; souhlas¡ disk ?
         jne       Chyba1                   ; disk nesouhlas¡

; ------ na‡ten¡ informac¡ o disku

         xor       bx,bx                    ; prednastaveni pro chybu
         mov       ah,36h
         inc       dx                       ; po‘adovan˜ disk
         int       21h                      ; na‡ten¡ informac¡ o disku
         cmp       byte ptr ds:[ErrKod],0   ; byla chyba ?
         jne       Navrat                   ; byla chyba

; ------ musi byt volne misto (kvuli CD disku)

         or        bx,bx                    ; je volne misto ?
         jz        Chyba1                   ; neni volne misto - asi CD disk
         cmp       dx,25                    ; jsou alokacni bloky ?
         jb        Chyba1                   ; to je take blbost

; ------ v˜po‡et velikosti voln‚ho m¡sta disku

         mul       cx                       ; DX:AX <- po‡et bajt– na alok. blok
         xchg      ax,si                    ; SI <- bajt– na blok LOW
         xchg      ax,dx                    ; AX <- bajt– na blok HIGH
         mul       bx                       ; AX <- voln˜ch bajt– HIGH
         xchg      ax,si                    ; SI <- voln˜ch bajt– HIGH
                                            ; AX <- bajt– na blok LOW
         mul       bx                       ; DX:AX <- voln˜ch bajt– LOW
         add       dx,si                    ; p©enos z HIGH

; ------ dek¢dov n¡ voln‚ho m¡sta disku

         mov       di,offset VolTxt2
         mov       bx,"."
         call      DekNumD                  ; dek¢dov n¡ voln‚ho m¡sta

; ------ zobrazen¡ voln‚ho m¡sta

         mov       dx,offset VolTxt
         mov       ah,9
         int       21h
         jmp       short Navrat

; ------ chyba zad n¡ parametr–

Chyba:   mov       dx,offset HelpTxt
         mov       ah,9
         int       21h

Chyba1:  mov       byte ptr ds:[ErrKod],1   ; p©¡znak chyby

; ------ n vrat p–vodn¡ho aktivn¡ho disku

Navrat:  mov       dl,ds:[OldDisk]          ; p–vodn¡ aktivn¡ disk
         mov       ah,0eh
         int       21h                      ; n vrat aktivn¡ho disku

; ------ konec programu s n vratov˜m k¢dem AL

         mov       al,ds:[ErrKod]           ; n vratov˜ k¢d
         mov       ah,4ch
         int       21h

OldDisk  db        2                        ; uschovan˜ aktivn¡ disk

; ------ obsluha INT 24h a INT 23h

INT24:   mov       al,0                     ; ignorov n¡ chyby
INT23:   mov       byte ptr cs:[ErrKod],1   ; p©¡znak chyby
         iret

; *****************************************************************************
;                                 DekNumD
;                   Dek¢dov n¡ ‡¡sla od prav‚ho okraje
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo k dek¢dov n¡
;        DS:DI=ukl dac¡ adresa (konec za ‡¡slem)
;        BH=atribut barev (0=atribut barev se neukl d )
;        BL=znak oddˆlova‡e © d– (0=oddˆlova‡ © d– se neukl d )
; *****************************************************************************

DekNumD  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©¡prava registr–

         mov       bp,10                    ; ‡¡seln  soustava
         mov       cx,4                     ; ‡¡ta‡ ‡¡slic © du
         or        bl,bl                    ; ukl d  se oddˆlova‡ © du ?
         jnz       DekNumD1                 ; oddˆlova‡ © du se ukl d 
         mov       ch,0ffh                  ; neplatn˜ ‡¡ta‡ © du

; ------ v˜po‡et jedn‚ ‡¡slice

DekNumD1:xchg      ax,si                    ; SI <- £schova ni‘¨¡ho slova ‡¡sla
         xchg      ax,dx                    ; AX <- vy¨¨¡ slovo ‡¡sla
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; vydˆlen¡ vy¨¨¡ho slova ‡¡sla
         xchg      ax,si                    ; AX <- n vrat ni‘¨¡ho slova
         div       bp                       ; vydˆlen¡ ni‘¨¡ho slova ‡¡sla

; ------ ulo‘en¡ oddˆlova‡e © d–

         dec       cx                       ; ‡¡ta‡ ‡¡slic © du
         jnz       DekNumD3                 ; nen¡ oddˆlova‡ © du
         or        bh,bh                    ; ukl d  se atribut barev ?
         jz        DekNumD2                 ; atribut barev se neukl d 
         dec       di                       ; posun adresy
         mov       ds:[di],bh               ; ulo‘en¡ atributu barvy
DekNumD2:dec       di                       ; posun adresy
         mov       ds:[di],bl               ; ulo‘en¡ oddˆlova‡e tis¡c–
         mov       cl,3                     ; nov˜ ‡¡ta‡ © du

; ------ ulo‘en¡ nov‚ ‡¡slice

DekNumD3:or        bh,bh                    ; ukl d  se atribut barev ?
         jz        DekNumD4                 ; atribut barev se neukl d 
         dec       di                       ; posun adresy
         mov       ds:[di],bh               ; ulo‘en¡ atributu barev
DekNumD4:dec       di                       ; posun adresy
         add       dl,"0"                   ; korekce na znak ASCII
         mov       ds:[di],dl               ; ulo‘en¡ ‡¡slice

; ------ test, zda je je¨tˆ nˆjak‚ ‡¡slo

         mov       dx,si                    ; n vrat vy¨¨¡ho slova ‡¡sla
         or        si,ax                    ; je ‡¡slo ji‘ = 0 ?
         jnz       DekNumD1                 ; ‡¡slo je¨tˆ nen¡ = 0 - pokra‡ov n¡

; ------ n vrat registr–

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNumD  ENDP

ErrKod   db        0                        ; n vratov˜ k¢d

HelpTxt  db        'FREEDISK v1.02 - volne misto disku; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr oznaceni disku, jehoz volne misto',13,10
         db        'chcete zobrazit (nelze zvolit sitovy disk ani CD-ROM).',13,10
         db        'Nepristupny ci neplatny disk navrati ERRORLEVEL = 1.',13,10
         db        13,10
         db        '$'

VolTxt   db        'Volne misto disku '
VolTxt1  db        'A:              '
VolTxt2  db        ' Bajtu',13,10,'$'

Code     ENDS
         END       Start
