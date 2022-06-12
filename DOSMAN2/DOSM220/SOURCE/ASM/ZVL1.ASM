
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Z V L è õ T N ã
;
;          Zvl†®tn° funkce - CD disk, Nastaven°, Hodiny, Kalkul†tor
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


INCLUDE  ASM\DEF.ASM

CodeZvl  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeZvl,ds:Data

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         hlavn° menu Zvl†®tn°
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;; *****************************************************************************
;;
;;                       volba INFORMACE
;;
;; *****************************************************************************
;
;AWZMnu1  PROC      FAR
;
;         call      far ptr ClosMnuA         ; uzav©en° v®ech oken
;
;         ret
;
;
;
;AWZMnu1  ENDP
;
;AWZMnu2  PROC      FAR
;
;         ret
;
;AWZMnu2  ENDP

AWZMnu3  PROC      FAR

         ret

AWZMnu3  ENDP

; *****************************************************************************
;
;                          menu CD disk
;
; *****************************************************************************
;˛
CDDisk   PROC      FAR

; ------ uzav©en° menu

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° menu

; ------ vytvo©en° bufferu mapy stop

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        CDDisk02
         mov       ds:[CDSegm],ax           ; segment s mapou stop
         mov       bx,101*4                 ; velikost bufferu
         call      far ptr ModiSegS         ; nastaven° velikosti bufferu
         jnc       CDDisk04                 ; operace OK
CDDisk02:call      far ptr MemErr           ; chyba pamàti
         jmp       short CDDisk0

; ------ detekce verze CD-ROM

CDDisk04:
;         mov       al,0ch                   ; poskytnut° verze
;         xor       bx,bx                    ; p©ednastaven° verze 1.0
;         call      far ptr IntCD            ; detekce verze CD-ROM
;         mov       ds:[CDVerz],bx           ; verze CD-ROM
;         cmp       bh,2                     ; minim†ln° verze 2.00
;         jb        CDDisk08                 ; nen° ovladaá

; ------ detekce disku CD-ROM (postaá° prvn°ho disku CD)

         mov       bx,offset PozadCD        ; buffer k naáten° seznamu CD
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       byte ptr ds:[bx],-1      ; disk neplatnò
         mov       al,0dh                   ; sluëba naáten° seznamu diskñ
         call      far ptr IntCD            ; naáten° seznamu diskñ
         mov       al,ds:[PozadCD]          ; naátenò disk
         mov       ds:[CDDsk],al            ; detekovanò CD disk
         cmp       al,DiskMax               ; je to platnÇ á°slo disku ?
         jb        CDDisk1                  ; á°slo disku je OK

; ------ chyba - nen° nainstalov†n ovladaá CD-ROM

CDDisk08:mov       si,offset CDErDMnu
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
CDDisk0: mov       ax,ds:[CDSegm]           ; segment s mapou stop
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[CDSegm],ax
         jmp       far ptr Main0

; ------ otev©en° menu CD-disku

CDDisk1: call      CDNul                    ; vynulov†n° dat
         mov       byte ptr ds:[CDStav],1   ; nen° disk
         call      CDPDek                   ; dek¢dov†n° parametrñ pro hl†®en°
         mov       si,offset CDROMMnu
         call      far ptr OpenMnu          ; otev©en° menu
         mov       word ptr ds:[CDCitRad],0 ; nen° uschovan† pozice
         or        byte ptr ds:[CDDParam],bit1 ; disk vymànàn

; ------ naáten° informac° o aktu†ln°m stavu disku

CDDisk2: call      CDGStav                  ; naáten° aktu†ln°ho stavu

; ------ dek¢dov†n° parametrñ pro hl†®en°

         call      CDPDek                   ; dek¢dov†n° parametrñ pro hl†®en°

; ------ zobrazen° aktu†ln°ho stavu menu

         mov       si,offset CDROMMnu
         call      far ptr DispMnu          ; zobrazen° menu

         call      far ptr DispTime         ; zobrazen° áasu
         call      far ptr DarkNul          ; nulov†n° stm°vaáe
         call      far ptr KurzOff          ; vypnut° kurzoru

         call      far ptr MouseInt         ; obsluha p©eru®en° od my®i
         call      far ptr MouseGet         ; vstup k¢du my®i
         jnc       CDDisk22                 ; je k¢d my®i
         call      far ptr TestChar         ; test kl†vesnice
         jc        CDDisk2                  ; nen° p©ipraven† kl†vesa

; ------ vstup znaku z kl†vesnice

         call      far ptr InpChar          ; vstup znaku z kl†vesnice
CDDisk22:call      far ptr JumpBX

         dw        4800h,CDDisk3            ; nahoru
         dw        7300h,CDDisk3            ; Ctrl-vlevo
         dw        5000h,CDDisk4            ; dolñ
         dw        7400h,CDDisk4            ; Ctrl-vpravo
         dw        4700h,CDDisk42           ; Home
         dw        4f00h,CDDisk32           ; End

         dw        4b00h,CDDisk5            ; vlevo
         dw        4d00h,CDDisk6            ; vpravo

         dw        3920h,CDDisk7            ; mezera
         dw        5300h,CDDisk76           ; DELETE
         dw        5200h,CDDisk77           ; INSERT

         dw        MousXKod+MousXRP,CDDisk9 ; stisk pravÇho tlaá°tka my®i
         dw        MousXKod+MousXLP,CDDisk24 ; stisk levÇho tlaá°tka my®i

         dw        11bh,CDDisk9             ; ESC
         dw        0,CDDisk8                ; jin† kl†vesa

; ------ obsluha my®°

CDDisk24:call      far ptr MouseMnu         ; test, zda je okno menu
         jnc       CDDisk25                 ; kurzor my®i je v oknà
         jmp       CDDisk9                  ; je p©eru®en° operace

CDDisk25:mov       bh,byte ptr ds:[MousePoz+1] ; ©†dek s my®°
         sub       bh,ds:[si+MnuRad]        ; ©†dek relativnà
         mov       ah,0
         mov       al,byte ptr ds:[MousePoz] ; pozice s my®°
         sub       al,ds:[si+MnuPoz]        ; pozice relativnà
         cmp       bh,9                     ; je mapa ?
         jae       CDDisk28                 ; nen° mapa

         dec       ax
         sub       al,ds:[CDMapPoz]         ; pozice v mapà
         jns       CDDisk26
         mov       al,0
CDDisk26:mov       ah,0
         mov       dx,75*60                 ; poáet r†meákñ na minutu
         mul       dx                       ; vòpoáet pozice
         cmp       bh,6                     ; je horn° polovina ?
         ja        CDDisk27                 ; je horn° polovina
         add       ax,75*30                 ; p©iáten° 1/2 minuty
         adc       dx,0
CDDisk27:add       ax,75*3                  ; je®tà mal† korekce (p†r sekund)
         adc       dx,0

         cmp       bh,5                     ; je volba nahr†vky ?
         ja        CDDsk274                 ; nen° volba nahr†vky

         add       ax,75*30
         adc       dx,0

         push      ax
         mov       ax,ds:[CDSegm]           ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu -> ES
         pop       ax
         xor       bx,bx                    ; ukazatel v bufferu
CDDsk272:add       bx,4
         js        CDDsk274
         cmp       dx,es:[bx+2]
         jne       CDDsk273
         cmp       ax,es:[bx]
CDDsk273:jae       CDDsk272
         mov       ax,es:[bx-4]             ; korekce na zaá†tek nahr†vky
         mov       dx,es:[bx-2]
CDDsk274:call      CDGOmez                  ; omezen° mezi poá†tek a konec
         jmp       CDDisk67                 ; start p©ehr†v†n°

CDDisk28:inc       ax                       ; korekce (aby souhlasily pozice)
         mov       bl,5
         div       bl
         mov       bl,al                    ; BX <- kurzor my®i relativnà
         call      far ptr JumpBX           ; skok na obsluhu pozice

         dw        10*HI+7,CDDisk7          ; indikace PLAY - jako mezera
         dw        10*HI+8,CDDisk7          ; indikace PLAY - jako mezera

         dw        12*HI+2,CDDisk3          ; Ctrl-vlevo
         dw        12*HI+3,CDDisk4          ; Ctrl-vpravo
         dw        12*HI+8,CDDisk3          ; nahoru
         dw        12*HI+9,CDDisk4          ; dolñ
         dw        12*HI+10,CDDisk7         ; mezera
         dw        12*HI+11,CDDisk7         ; mezera

         dw        13*HI+2,CDDisk5          ; vlevo
         dw        13*HI+3,CDDisk6          ; vpravo
         dw        13*HI+10,CDDisk76        ; DELETE
         dw        13*HI+11,CDDisk76        ; DELETE

         dw        14*HI+2,CDDisk42         ; Home
         dw        14*HI+3,CDDisk32         ; End
         dw        14*HI+10,CDDisk77        ; INSERT
         dw        14*HI+11,CDDisk77        ; INSERT

         dw        15*HI+2,CDDisk42         ; 1-9 (jako Home)
         dw        15*HI+3,CDDisk32         ; A-Z (jako End)

         dw        0,CDDisk8                ; jin† kl†vesa

; ------ nahoru a Ctrl-vlevo - nahr†vka zpàt

CDDisk3: mov       al,ds:[CDATrack]         ; aktu†ln° stopa
         dec       ax                       ; posun stopy zpàt
         cmp       al,ds:[CDBTrack]         ; je jië poá†teán° stopa ?
         jae       CDDisk34                 ; nen° je®tà podteáen°
CDDisk32:mov       al,ds:[CDETrack]         ; posledn° stopa
CDDisk34:call      CDGTrack                 ; naáten° poá†tku stopy AL
         jmp       short CDDisk66           ; posun na poá†tek stopy AL

; ------ Ctrl-vpravo - nahr†vka vp©ed

CDDisk4: mov       al,ds:[CDATrack]         ; aktu†ln° stopa
         inc       ax                       ; zvò®en° á°sla stopy
         cmp       al,ds:[CDETrack]         ; je jië koncov† stopa ?
         jbe       CDDisk34                 ; je to je®tà OK
CDDisk42:mov       al,ds:[CDBTrack]         ; poá†teán° stopa
         jmp       short CDDisk34           ; nastaven° stopy

; ------ vlevo - 15 sekund zpàt

CDDisk5: mov       ax,word ptr ds:[CDFAkt]  ; aktu†ln° r†meáek
         mov       dx,word ptr ds:[CDFAkt+2]
         sub       ax,75*15                 ; posun o 15 sekund zpàt
         sbb       dx,0
         jc        CDDisk54

         cmp       dx,word ptr ds:[CDFBeg+2] ; je p©ed poá†tkem ?
         jne       CDDisk52
         cmp       ax,word ptr ds:[CDFBeg]
CDDisk52:jae       CDDisk66
CDDisk54:add       ax,word ptr ds:[CDFDelk]
         adc       dx,word ptr ds:[CDFDelk+2]
         jmp       short CDDisk66

; ------ vpravo - 15 sekund vp©ed

CDDisk6: mov       ax,word ptr ds:[CDFAkt]  ; aktu†ln° pozice
         mov       dx,word ptr ds:[CDFAkt+2]
         add       ax,75*15                 ; posun o 15 sekund vp©ed
         adc       dx,0

         cmp       dx,word ptr ds:[CDFEnd+2]
         jne       CDDisk62
         cmp       ax,word ptr ds:[CDFEnd]
CDDisk62:jbe       CDDisk66
         sub       ax,word ptr ds:[CDFDelk]
         sbb       dx,word ptr ds:[CDFDelk+2]

; ------ posun na pozici DX:AX

CDDisk66:mov       word ptr ds:[CDCitRad],0 ; nen° uschovan† pozice
         call      CDGOmez                  ; omezen° mezi poá†tek a konec
         cmp       byte ptr ds:[CDStav],1   ; je disk ?
         jbe       CDDisk69                 ; nen° disk
         cmp       byte ptr ds:[CDStav],4   ; je PLAY ?
         je        CDDisk67                 ; je PLAY
         call      CDPlay0                  ; start od danÇ pozice
         call      CDStop                   ; zastaven°
         jmp       short CDDisk69

; ------ p©ehr†v†n° od pozice DX:AX

CDDisk67:mov       word ptr ds:[CDCitRad],0 ; nen° uschovan† pozice
         cmp       byte ptr ds:[CDStav],4   ; je PLAY ?
         jne       CDDisk68                 ; nen° je PLAY
         call      CDStop                   ; nejd©°ve zastaven° p©ehr†v†n°
CDDisk68:cmp       byte ptr ds:[CDStav],1   ; je disk ?
         jbe       CDDisk69                 ; nen° disk
         call      CDPlay0                  ; start od danÇ pozice
CDDisk69:jmp       CDDisk2

; ------ mezera - START/STOP

CDDisk7: mov       word ptr ds:[CDCitRad],0 ; nen° uschovan† pozice
         cmp       byte ptr ds:[CDStav],4   ; je PLAY ?
         jne       CDDisk72                 ; nen° PLAY
         call      CDStop                   ; zastaven° PLAY
         jmp       short CDDisk73

CDDisk72:cmp       byte ptr ds:[CDStav],3   ; je PAUSE ?
         jne       CDDisk74                 ; nen° PAUSE
         call      CDCont                   ; pokraáov†n°
CDDisk73:jmp       CDDisk2

CDDisk74:mov       ax,word ptr ds:[CDFBeg]  ; poá†tek disku
         mov       dx,word ptr ds:[CDFBeg+2]
         jmp       short CDDisk68           ; p©ehr†v†n° od pozice DX:AX

; ------ DELETE - STOP

CDDisk76:mov       word ptr ds:[CDCitRad],0 ; nen° uschovan† pozice
         call      CDStop
         call      CDStop
         call      CDStop
         jmp       CDDisk2

; ------ INSERT - EJECT

CDDisk77:cmp       byte ptr ds:[CDStav],0   ; je EJECT ?
         je        CDDisk78                 ; je EJECT
         call      CDEject                  ; vysunut° disku
         jmp       short CDDisk79

CDDisk78:call      CDClose                  ; zasunut° disku
CDDisk79:jmp       CDDisk2

; ------ start od zadanÇ nahr†vky

CDDisk8: xchg      ax,bx                    ; AX <- kl†vesa
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         sub       al,"0"                   ; je á°slice ?
         jbe       CDDisk79                 ; nen° platnò znak
         cmp       al,9
         jbe       CDDisk82                 ; je platn† á°slice
         sub       al,7                     ; korekce
         cmp       al,9
         jbe       CDDisk79                 ; neplatnò znak
CDDisk82:cmp       al,ds:[CDBTrack]         ; platn† poá†teán° stopa ?
         jb        CDDisk79                 ; neplatn†
         cmp       al,ds:[CDETrack]         ; platn† koncov† stopa ?
         ja        CDDisk79                 ; neplatn†
         call      CDGTrack                 ; naáten° poá†tku stopy AL
         jmp       CDDisk67                 ; start p©ehr†v†n°

; ------ konec ESC

CDDisk9: call      far ptr ClosMnu          ; uzav©en° menu
         jmp       CDDisk0

CDDisk   ENDP

; -----------------------------------------------------------------------------
;        naáten° aktu†ln°ho stavu o CD
; -----------------------------------------------------------------------------

CDGStav  PROC      NEAR

; ------ test, zda je stav EJECT nebo NO DISC

         mov       byte ptr ds:[CDStav],0   ; je stav EJECT
         mov       al,6                     ; funkce zji®tàn° stavu disku
         mov       cl,4                     ; dÇlka poëadavku
         call      CDInpIO                  ; naáten° stavu disku
         mov       ax,word ptr ds:[ZahlCD+1]; stav disku
         test      al,bit0                  ; dv°©ka otev©ena ?
         jnz       CDGStav0                 ; dv°©ka jsou otev©ena - je EJECT
         inc       byte ptr ds:[CDStav]     ; nen° disk
         test      ah,bit11/bit8            ; je vloëen disk ?
         jnz       CDGStav0                 ; v mechanice nen° CD disk

; ------ test, zda je STOP, PAUSE nebo PLAY

         mov       al,0fh                   ; funkce zji®tàn° stavu
         mov       cl,10                    ; poáet bajtñ
         call      CDInpIO                  ; naáten° stavu AUDIO
         mov       byte ptr ds:[CDStav],3   ; PAUSE
         test      byte ptr ds:[ZahlCD+1],bit0 ; je PAUSE ?
         jnz       CDGStv02                 ; je PAUSE
         dec       byte ptr ds:[CDStav]     ; je stav STOP
         mov       ax,word ptr ds:[ZahlCD+3] ; je p©ehr†vac° adresa ?
         or        ax,word ptr ds:[ZahlCD+5]
         jz        CDGStv02
         mov       byte ptr ds:[CDStav],4   ; jinak stav PLAY
         mov       word ptr ds:[CDCitRad],0 ; nen° uschovan† pozice

; ------ naáten° celkovòch informac° o disku

CDGStv02:mov       al,10                    ; funkce poskytnut° parametrñ disku
         mov       word ptr ds:[ZahlCD+1],0 ; neplatnÇ hodnoty
         mov       cl,6                     ; poáet bajtñ k naáten°
         call      CDInpIO                  ; naáten° informac° o disku

; ------ kontrola prvn° a posledn° stopy

         mov       ax,word ptr ds:[ZahlCD+1] ; navr†cen† prvn° a posledn° stopa
         or        al,al
         jz        CDGStav0                 ; neplatnò £daj
         or        ah,ah
         jz        CDGStav0                 ; neplatnò £daj
         cmp       ah,al                    ; po©ad° stop OK ?
         jb        CDGStav0                 ; chyba
         cmp       ah,100                   ; maxim†lnà stop
         jae       CDGStav0                 ; chyba
         mov       ds:[CDBTrack],al         ; prvn° stopa
         mov       ds:[CDETrack],ah         ; posledn° stopa
         sub       ah,al                    ; poáet stop - 1
         cmp       ah,99                    ; je á°slo OK ?
         jb        CDGStav1                 ; je to OK
CDGStav0:or        byte ptr ds:[CDDParam],bit1 ; disk vymànàn
         jmp       CDGStav9                 ; chyba nebo dv°©ka otev©ena

; ------ konec disku

CDGStav1:mov       si,offset ZahlCD+3       ; koncov† stopa
         push      cs
         call      near ptr GetRBook        ; naáten° á°sla stopy

         cmp       dx,word ptr ds:[CDFEnd+2]
         jne       CDGStv11
         cmp       ax,word ptr ds:[CDFEnd]
         je        CDGStv12                 ; nebyl vymànàn
CDGStv11:or        byte ptr ds:[CDDParam],bit1 ; disk vymànàn

CDGStv12:mov       word ptr ds:[CDFEnd],ax  ; r†meáek konce disku
         mov       word ptr ds:[CDFEnd+2],dx
         mov       word ptr ds:[CDFDelk],ax ; dÇlka disku
         mov       word ptr ds:[CDFDelk+2],dx

; ------ poá†tek disku

         mov       word ptr ds:[CDFBeg],0   ; nulov†n° poá†tku kvñli omezen°
         mov       word ptr ds:[CDFBeg+2],0
         mov       al,ds:[CDBTrack]         ; poá†teán° stopa
         call      CDGTrack                 ; naáten° r†meáku prvn° stopy
         mov       word ptr ds:[CDFBeg],ax  ; r†meáek poá†tku disku
         mov       word ptr ds:[CDFBeg+2],dx

; ------ kontrola, zda je konec disku za poá†tkem

         sub       word ptr ds:[CDFDelk],ax ; vòpoáet dÇlky disku
         sbb       word ptr ds:[CDFDelk+2],dx
         jc        CDGStav0                 ; chyba - zaá†ten nen° p©ed koncem

; ------ naáten° seznamu stop

         test      byte ptr ds:[CDDParam],bit1 ; byl disk vymànàn ?
         jz        CDGStv17                 ; nebyl vymànàn

         mov       ax,ds:[CDSegm]           ; segment bufferu stop
         call      far ptr GetDat           ; adresa bufferu stop -> ES
         mov       cx,101                   ; poáet stop k naáten°
         mov       al,0                     ; ukazatel á°sla stopy
         xor       di,di                    ; DI <- ukl†dac° adresa
CDGStv15:push      ax
         call      CDGTrack                 ; naáten° á°sla stopy
         cld
         stosw                              ; uloëen° offsetu LOW
         xchg      ax,dx
         stosw                              ; uloëen° offsetu HIGH
         pop       ax
         inc       ax                       ; zvò®en° ukazatele á°sla stopy
         loop      CDGStv15                 ; dal®° stopa
         and       byte ptr ds:[CDDParam],not bit1 ; zru®en° p©°znaku vòmàny

; ------ naáten° aktu†ln° pozice

CDGStv17:xor       ax,ax                    ; AX <- pozice pro STOP
         xor       dx,dx
         cmp       byte ptr ds:[CDStav],2   ; je STOP ?
         je        CDGStv19                 ; je STOP

         mov       al,1                     ; funkce navr†cen° aktu†ln° pozice
         mov       ds:[ZahlCD+1],al         ; adresovac° m¢d Red Book
         mov       cl,5                     ; dÇlka poëadavku
         call      CDInpIO                  ; naáten° absolutn° pozice hlav
         mov       si,offset ZahlCD+2
         push      cs
         call      near ptr GetRBook        ; naáten° aktu†ln° pozice hlav

; ------ filtrace

         xchg      ax,cx                    ; CX <- pozice LOW
         mov       bx,dx                    ; BX <- pozice HIGH

         mov       ax,ds:[CDCitRad]         ; AX <- á°taá ©†du
         push      ax
         mul       word ptr ds:[CDFAktO+2]  ; vyn†soben° starÇ pozice HIGH
         add       bx,ax                    ; BX <- £schova starÇ pozice HIGH
         pop       ax                       ; á°taá ©†du
         mul       word ptr ds:[CDFAktO]    ; vyn†soben° starÇ pozice LOW
         add       cx,ax                    ; p©iáten° k souátu
         adc       bx,dx

         inc       byte ptr ds:[CDCitRad]   ; zvò®en° á°taáe ©†du

         xor       dx,dx                    ; DX <- 0
         xchg      ax,bx                    ; AX <- souáet HIGH
         div       word ptr ds:[CDCitRad]   ; vydàlen° souátu HIGH
         xchg      ax,cx                    ; AX <- starÇ LOW, CX <- novÇ HIGH
         div       word ptr ds:[CDCitRad]   ; vydàlen° souátu LOW
         mov       dx,cx                    ; DX <- novÇ HIGH

         mov       bx,ax                    ; BX <- LOW
         shl       bx,1
         rcl       cx,1                     ; pozice * 2
         shl       bx,1
         rcl       cx,1                     ; pozice * 4
         add       cx,10                    ; minim†lnà filtrac° pro stopu 1

; Na vy®®°ch stop†ch je del®° ot†áka a tedy vàt®° rozkmit -> vàt®° filtrace

         cmp       ds:[CDCitRad],cx         ; asi tak maximum
         jbe       CDGStv19                 ; nen° maximum
         dec       word ptr ds:[CDCitRad]   ; omezen° á°taáe

;         cmp       byte ptr ds:[CDStav],3   ; je PAUSE ?
;         jne       CDGStv11                 ; nen° PAUSE
;
;         mov       cx,word ptr ds:[CDFAkt]
;         mov       bx,word ptr ds:[CDFAkt+2]
;         shl       cx,1
;         rcl       bx,1                     ; * 2
;         shl       cx,1
;         rcl       bx,1                     ; * 4
;         shl       cx,1
;         rcl       bx,1                     ; * 8
;         shl       cx,1
;         rcl       bx,1                     ; * 16
;         sub       cx,word ptr ds:[CDFAkt]
;         sbb       bx,word ptr ds:[CDFAkt+2] ; * 15
;
;         add       ax,cx
;         adc       dx,bx                    ; * 16
;
;         shr       dx,1
;         rcr       ax,1                     ; * 8
;         shr       dx,1
;         rcr       ax,1                     ; * 4
;         shr       dx,1
;         rcr       ax,1                     ; * 2
;         shr       dx,1
;         rcr       ax,1                     ; * 1

; ------ omezen° mezi poá†teán° a koncovou hodnotu

CDGStv19:call      CDGOmez                  ; omezen° mezi poá†tek a konec
         mov       word ptr ds:[CDFAkt],ax  ; aktu†ln° absolutn° pozice
         mov       word ptr ds:[CDFAkt+2],dx
         mov       word ptr ds:[CDFAktO],ax ; uschovan† star† pozice
         mov       word ptr ds:[CDFAktO+2],dx

; ------ p©°prava k nalezen° aktu†ln° stopy

         mov       ax,word ptr ds:[CDFBeg]  ; r†meáek poá†tku disku
         mov       word ptr ds:[CDFNext],ax ; r†meáek poá†tku p©°®t° stopy
         mov       ax,word ptr ds:[CDFBeg+2]
         mov       word ptr ds:[CDFNext+2],ax
         mov       al,ds:[CDBTrack]         ; poá†teán° stopa

; ------ nov† adresa aktu†ln° stopy AL

CDGStav2:mov       ds:[CDATrack],al         ; aktu†ln° stopa
         mov       ax,word ptr ds:[CDFNext] ; r†meáek poá†tku p©°®t° stopy
         mov       word ptr ds:[CDFTrack],ax ; je to r†meáek aktu†ln° stopy
         mov       ax,word ptr ds:[CDFNext+2]
         mov       word ptr ds:[CDFTrack+2],ax

; ------ naáten° informac° p©°®t° stopy

         mov       al,ds:[CDATrack]         ; aktu†ln° stopa
         inc       ax                       ; p©°®t° stopa
         push      ax
         call      CDGTrack                 ; naáten° informac° o stopà AL
         mov       word ptr ds:[CDFNext],ax ; r†meáek poá†tku p©°®t° stopy
         mov       word ptr ds:[CDFNext+2],dx

; ------ test, zda je ukazatel v tÇto stopà

         cmp       dx,word ptr ds:[CDFAkt+2] ; nalezena aktu†ln° stopa ?
         jne       CDGStv22
         cmp       ax,word ptr ds:[CDFAkt]
CDGStv22:pop       ax                       ; p©°®t° stopa
         jb        CDGStav2                 ; nen° to hledan† stopa - dal®°

; ------ korekce áasu v nahr†vce, je-li zastaven na zaá†tku nahr†vky

         cmp       byte ptr ds:[CDStav],3   ; je PAUSE ?
         jne       CDGStv24                 ; nen° PAUSE
         mov       ax,word ptr ds:[CDFAkt]  ; aktu†ln° pozice
         mov       dx,word ptr ds:[CDFAkt+2]
         sub       ax,word ptr ds:[CDFTrack] ; offset v aktu†ln° stopà
         sbb       dx,word ptr ds:[CDFTrack+2]
         jnz       CDGStv23
         cmp       ax,35                    ; asi tak rezerva
         jae       CDGStv23                 ; je jië daleko
         sub       word ptr ds:[CDFAkt],ax  ; korekce aktu†ln° pozice
         sbb       word ptr ds:[CDFAkt+2],dx
         jmp       short CDGStv24

CDGStv23:mov       ax,word ptr ds:[CDFNext] ; p©°®t° pozice
         mov       dx,word ptr ds:[CDFNext+2]
         sub       ax,word ptr ds:[CDFAkt]  ; offset od aktu†ln° pozice
         sbb       dx,word ptr ds:[CDFAkt+2]
         jnz       CDGStv24                 ; nen° bl°zko
         cmp       ax,35
         jae       CDGStv24
         add       word ptr ds:[CDFAkt],ax
         adc       word ptr ds:[CDFAkt+2],dx
         mov       al,ds:[CDATrack]         ; aktu†ln° stopa
         cmp       al,ds:[CDETrack]         ; je to koncov† stopa ?
         jae       CDGStv24                 ; je to jië koncov† stopa
         inc       byte ptr ds:[CDATrack]   ; zvò®en° aktu†ln° stopy

         inc       ax
         push      ax
         call      CDGTrack                 ; naáten° informac° o stopà AL
         mov       word ptr ds:[CDFTrack],ax ; je to r†meáek aktu†ln° stopy
         mov       word ptr ds:[CDFTrack+2],dx
         pop       ax

         inc       ax                       ; p©°®t° stopa
         call      CDGTrack                 ; naáten° informac° o stopà AL
         mov       word ptr ds:[CDFNext],ax ; r†meáek poá†tku p©°®t° stopy
         mov       word ptr ds:[CDFNext+2],dx

CDGStv24:ret

; ------ nedefinovanò stav - nen° disk

CDGStav9:call      CDNul                    ; vynulov†n°
         ret

CDGStav  ENDP

; -----------------------------------------------------------------------------
;        vynulov†n° dat p©i chybà
; -----------------------------------------------------------------------------

CDNul    PROC      NEAR

         xor       ax,ax                    ; AX <- 0
         mov       di,offset CDNulBeg
         push      ds
         pop       es
         mov       cx,offset(CDNulEnd-CDNulBeg)
         cld
         rep       stosb                    ; vynulov†n° dat
         ret

CDNul    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° parametrñ pro hl†®en°
; -----------------------------------------------------------------------------

CDPDek   PROC      NEAR

; ------ á°slo aktu†ln° stopy

         mov       al,ds:[CDATrack]         ; aktu†ln° stopa
         mov       si,offset CDROMP11
         call      CDPNum                   ; dek¢dov†n° aktu†ln° nahr†vky

; ------ áas v aktu†ln° nahr†vce

         mov       ax,word ptr ds:[CDFAkt]  ; aktu†ln° pozice
         mov       dx,word ptr ds:[CDFAkt+2]
         sub       ax,word ptr ds:[CDFTrack] ; offset v aktu†ln° stopà
         sbb       dx,word ptr ds:[CDFTrack+2]
         mov       si,offset CDROMP12
         call      CDPDelk                  ; dek¢dov†n° áasu od zaá†tku stopy

; ------ áas do konce nahr†vky

         mov       ax,word ptr ds:[CDFNext] ; zaá†tek p©°®t° stopy
         mov       dx,word ptr ds:[CDFNext+2]
         sub       ax,word ptr ds:[CDFAkt] ; offset od aktu†ln° pozice
         sbb       dx,word ptr ds:[CDFAkt+2]
         mov       si,offset CDROMP13
         call      CDPDelk                  ; dek¢dov†n° áasu do konce stopy

; ------ dÇlka nahr†vky

         mov       ax,word ptr ds:[CDFNext] ; zaá†tek p©°®t° nahr†vky
         mov       dx,word ptr ds:[CDFNext+2]
         sub       ax,word ptr ds:[CDFTrack] ; dÇlka nahr†vky
         sbb       dx,word ptr ds:[CDFTrack+2]
         mov       si,offset CDROMP14
         call      CDPDelk                  ; dek¢dov†n° dÇlky nahr†vky

; ------ poáet stop

         mov       al,ds:[CDETrack]         ; koncov† stopa
         cmp       al,0                     ; je to platnò £daj ?
         je        CDPDek1                  ; neplatnò £daj
         sub       al,ds:[CDBTrack]         ; poáet stop - 1
         inc       ax                       ; AL = poáet stop
CDPDek1: mov       si,offset CDROMP21
         call      CDPNum                   ; dek¢dov†n° poátu stop

; ------ aktu†ln° absolutn° pozice

         mov       ax,word ptr ds:[CDFAkt]  ; r†meáek aktu†ln° pozice
         mov       dx,word ptr ds:[CDFAkt+2]
         sub       ax,word ptr ds:[CDFBeg] ; offset od poá†tku
         sbb       dx,word ptr ds:[CDFBeg+2]
         mov       si,offset CDROMP22       ; aktu†ln° pozice
         call      CDPDelk                  ; dek¢dov†n° pozice v disku

; ------ zbytek do konce disku

         mov       ax,word ptr ds:[CDFEnd]  ; r†meáek konce disku
         mov       dx,word ptr ds:[CDFEnd+2]
         sub       ax,word ptr ds:[CDFAkt]  ; offset od aktu†ln° pozice
         sbb       dx,word ptr ds:[CDFAkt+2]
         mov       si,offset CDROMP23       ; zbylò áas
         call      CDPDelk                  ; dek¢dov†n° zbylÇho áasu

; ------ celkov† dÇlka disku

         mov       ax,word ptr ds:[CDFDelk]  ; dÇlka disku
         mov       dx,word ptr ds:[CDFDelk+2]
         mov       si,offset CDROMP24       ; dÇlka disku
         call      CDPDelk                  ; dek¢dov†n° dÇlky disku
         ret

CDPDek   ENDP

; -----------------------------------------------------------------------------
;        uloëen° áasu DX:AX do bufferu DS:SI ve tvaru MM:SS:FF
; -----------------------------------------------------------------------------

CDPDelk  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si

; ------ ochrana proti hav†rii p©eteáen°m

         cmp       dx,6
         jbe       CDPDelk2
         xor       dx,dx
         xor       ax,ax

; ------ dek¢dov†n° minut

CDPDelk2:mov       cx,60*75                 ; poáet r†meákñ na minutu
         div       cx                       ; vòpoáet poátu minut
         call      CDPNum                   ; uloëen° £daje minut

; ------ dek¢dov†n° sekund

         xchg      ax,dx                    ; AX <- zbytek
         xor       dx,dx                    ; DX <- 0
         mov       cx,75                    ; poáet r†meákñ na sekundu
         div       cx                       ; vòpoáet sekund
         call      CDPNum                   ; uloëen° £daje sekund

; ------ dek¢dov†n° setiny sekundy

         xchg      ax,dx                    ; AX <- zbytek
         mov       cl,100                   ; n†sobek pro p©epoáet na setiny
         mul       cx                       ; p©epoáet na setiny
         mov       cl,75
         div       cl                       ; vòpoáet setin sekundy
         call      CDPNum                   ; uloëen° £daje r†meákñ

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

CDPDelk  ENDP

; -----------------------------------------------------------------------------
;        uloëen° á°sla AL jako 2 á°slice do bufferu DS:SI -> SI zvò®° o 3
; -----------------------------------------------------------------------------

CDPNum   PROC      NEAR

         push      ax

         aam                                ; rozdàlen° na 2 znaky BCD
         add       ax,"00"                  ; korekce na ASCII znaky
         xchg      al,ah                    ; oprava pozic
         mov       ds:[si],ax               ; uloëen° á°slic

         inc       si
         inc       si
         inc       si                       ; zvò®en° ukl†dac° adresy

         pop       ax
         ret

CDPNum   ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla poá†teán°ho r†meáku nahr†ky AL -> DX:AX
; -----------------------------------------------------------------------------

CDGTrack PROC      NEAR

; ------ á°slo r†meáku pro malÇ á°slo stopy

         cmp       al,ds:[CDBTrack]         ; je stopa platn† ?
         jae       CDGTrck1                 ; stopa je platn†
         mov       ax,word ptr ds:[CDFBeg]  ; r†meáek poá†tku disku
         mov       dx,word ptr ds:[CDFBeg+2]
         ret

; ------ á°slo r†meáku pro p©ekroáenÇ á°slo stopy

CDGTrck1:cmp       al,ds:[CDETrack]         ; je stopa platn† ?
         jbe       CDGTrck2                 ; stopa je je®tà platn†
         mov       ax,word ptr ds:[CDFEnd]  ; r†meáek konce disku
         mov       dx,word ptr ds:[CDFEnd+2]
         ret

; ------ á°slo r†meáku, je-li naáten† mapa disku

CDGTrck2:test      byte ptr ds:[CDDParam],bit1 ; byl disk vymànàn ?
         jnz       CDGTrck6                 ; disk byl vymànàn

         push      bx
         push      es

         mov       ah,0
         shl       ax,1
         shl       ax,1                     ; AX <- á°slo stopy * 4
         xchg      ax,bx                    ; BX <- poëadovan† stopa * 4
         mov       ax,ds:[CDSegm]           ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu -> ES
         mov       ax,es:[bx]               ; offset stopy LOW
         mov       dx,es:[bx+2]             ; offset stopy HIGH

         pop       es
         pop       bx
         ret

; ------ £schova registrñ

CDGTrck6:push      cx
         push      si

; ------ naáten° informac° o stopà

         mov       ds:[ZahlCD+1],al         ; poëadovan† stopa
         mov       al,0bh                   ; funkce áten° informac° o stopà
         mov       cl,5                     ; poáet bajtñ poëadavku
         call      CDInpIO                  ; naáten° informac° o stopà

; ------ naáten° poá†teán°ho áasu stopy

         mov       si,offset ZahlCD+2
         push      cs
         call      near ptr GetRBook        ; naáten° poá†teán°ho r†meáku

; ------ omezen° áasu stopy

         call      CDGOmez                  ; omezen° mezi poá†tek a konec

; ------ n†vrat registrñ

         pop       si
         pop       cx
         ret

CDGTrack ENDP

; -----------------------------------------------------------------------------
;        omezen° mezi doln° a horn° okraj disku
; -----------------------------------------------------------------------------

CDGOmez  PROC      NEAR

; ------ omezen° áasu zdola

         cmp       dx,word ptr ds:[CDFBeg+2] ; podteáen° poá†teán° pozice ?
         jne       CDGOmez2
         cmp       ax,word ptr ds:[CDFBeg]
CDGOmez2:jae       CDGOmez3                 ; nen° podteáen° poá†teán° pozice
         mov       ax,word ptr ds:[CDFBeg]  ; omezen° na poá†teán° pozici
         mov       dx,word ptr ds:[CDFBeg+2]

; ------ omezen° áasu shora

CDGOmez3:cmp       dx,word ptr ds:[CDFEnd+2] ; je p©eteáen° koncovÇ pozice ?
         jne       CDGOmez4
         cmp       ax,word ptr ds:[CDFEnd]
CDGOmez4:jbe       CDGOmez5                 ; nen° p©eteáen° koncovÇ pozice
         mov       ax,word ptr ds:[CDFEnd]  ; omezen° na koncovou pozici
         mov       dx,word ptr ds:[CDFEnd+2]
CDGOmez5:ret

CDGOmez  ENDP

; -----------------------------------------------------------------------------
;        áten° ze za©°zen° CD (funkce AL), dÇlka poëadavku CL
; -----------------------------------------------------------------------------

CDInpIO  PROC      NEAR

         mov       ds:[ZahlCD],al           ; poëadovan† funkce
         mov       ch,0                     ; CH <- 0
         mov       al,ds:[CDDsk]            ; AL <- á°slo disku
         call      far ptr InpIOCD          ; naáten° informac° o disku
         ret

CDInpIO  ENDP

; -----------------------------------------------------------------------------
;        zasunut° disku
; -----------------------------------------------------------------------------

CDClose  PROC      NEAR

         mov       byte ptr ds:[ZahlCD],5   ; povel pro zasunut°
         jmp       short CDEject1

CDClose  ENDP

; -----------------------------------------------------------------------------
;        vysunut° disku
; -----------------------------------------------------------------------------

CDEject  PROC      NEAR

         mov       byte ptr ds:[ZahlCD],0   ; povel pro EJECT

; ------ £schova registrñ

CDEject1:push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

         call      far ptr NulIOCD          ; nulov†n° bufferu poëadavku
         mov       bx,di                    ; buffer poëadavku
         mov       al,26                    ; dÇlka poëadavku
         stosb                              ; dÇlka poëadavku
         mov       al,ds:[CDDsk]            ; poëadovanò disk
         stosb                              ; poëadovanò disk
         mov       al,0ch                   ; povel pro z†pis na IOCTL
         stosb
         mov       di,offset PozadCD+0eh    ; pokraáov†n° - p©enosov† adresa
         mov       ax,offset ZahlCD         ; adresa poëadavku
         stosw                              ; offset adresy
         mov       ax,ds
         stosw                              ; segment adresy
         mov       cx,1
         stosw                              ; poáet bajtñ k naáten°

; ------ vysl†n° poëadavku (ES:BX=adresa bufferu poëadavku)

         mov       cl,ds:[CDDsk]
         mov       al,10h                   ; podfunkce ovl†d†n° za©°zen°
         mov       ch,0
         call      far ptr IntCD            ; vysl†n° poëadavku

; ------ kontrola navr†cenÇho stavu

         test      byte ptr ds:[PozadCD+3+1],80h ; byla chyba ?
         jz        CDEject2                 ; nebyla chyba
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

CDEject2:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CDEject  ENDP

; -----------------------------------------------------------------------------
;        p©ehr†t° nahr†vky
; -----------------------------------------------------------------------------

CDPlay0: mov       word ptr ds:[CDFPlay],ax ; aktu†ln° absolutn° pozice
         mov       word ptr ds:[CDFPlay+2],dx
         mov       word ptr ds:[CDFAkt],ax ; je to nov† aktu†ln° pozice
         mov       word ptr ds:[CDFAkt+2],dx

CDPlay   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ inicializace bufferu poëadavku

         call      far ptr NulIOCD          ; nulov†n° bufferu poëadavku
         mov       al,16h                   ; dÇlka poëadavku
         stosb
         mov       al,ds:[CDDsk]            ; aktivn° disk
         stosb
         mov       al,84h
         stosb                              ; povel pro p©ehr†v†n°

; ------ adresovac° m¢d

         mov       di,offset PozadCD+0dh
         mov       al,1
         stosb                              ; adresovac° m¢d Red Book

; ------ nastaven° p©ehr†vac° adresy (poá†teán° sektor)

         mov       ax,word ptr ds:[CDFPlay] ; adresa pro p©ehr†v†n°
         mov       dx,word ptr ds:[CDFPlay+2]
         push      cs
         call      near ptr SetRBook        ; uloëen° á°sla r†meáku

; ------ nastaven° dÇlky k p©ehr†n° (poáet sektorñ k p©ehr†n°)

         mov       ax,word ptr ds:[CDFEnd] ; adresa konce
         mov       dx,word ptr ds:[CDFEnd+2]
         sub       ax,word ptr ds:[CDFPlay] ; zbòvaj°c° poáet sektorñ
         sbb       dx,word ptr ds:[CDFPlay+2]
         stosw                              ; poáet sektorñ
         xchg      ax,dx
         stosw
         jmp       short CDStop2            ; vysl†n° poëadavku

CDPlay   ENDP

; -----------------------------------------------------------------------------
;        pokraáov†n° v p©ehr†v†n° CD-ROM (CY=chyba)
; -----------------------------------------------------------------------------

CDCont   PROC      NEAR

         push      ax
         mov       al,88h                   ; povel pro pokraáov†n°
         jmp       short CDStop1

CDCont   ENDP

; -----------------------------------------------------------------------------
;        zastaven° p©ehr†v†n° CD-ROM (CY=chyba)
; -----------------------------------------------------------------------------

CDStop   PROC      NEAR

         push      ax
         mov       al,85h                   ; povel STOP

; ------ £schova registrñ

CDStop1: push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ inicializace bufferu poëadavku

         push      ax
         call      far ptr NulIOCD          ; nulov†n° bufferu poëadavku
         mov       al,0dh                   ; dÇlka poëadavku
         stosb
         mov       al,ds:[CDDsk]            ; aktivn° disk
         stosb
         pop       ax
         stosb                              ; povel

; ------ vysl†n° poëadavku

CDStop2: mov       al,10h                   ; podfunkce ovl†d†n° za©°zen°
         mov       cl,ds:[CDDsk]            ; aktivn° disk
         mov       ch,0
         mov       bx,offset PozadCD        ; buffer poëadavku
         call      far ptr IntCD            ; vysl†n° poëadavku

; ------ kontrola navr†cenÇho stavu

         test      byte ptr ds:[PozadCD+3+1],80h ; byla chyba ?
         jz        CDStop9                  ; nebyla chyba
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

CDStop9: pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CDStop   ENDP

; *****************************************************************************
;                               SetRBook
;                   nastaven° á°sla r†meáku CD-ROM
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo r†mce
;        DS:DI
; VùSTUP: DI+4
; *****************************************************************************

SetRBook PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ á°slo r†meáku

         cld
         mov       cx,75                    ; poáet r†meákñ na sekundu
         div       cx                       ; p©epoáet na sekundy a r†meáky
         mov       ds:[di],dl               ; á°slo r†meáku
         inc       di

; ------ á°slo sekundy

         mov       cl,60                    ; poáet sekund na minutu
         div       cl                       ; vòpoáet sekund
         mov       ds:[di],ah               ; á°slo sekundy
         inc       di

; ------ á°slo minuty

         mov       ah,0
         mov       ds:[di],ax               ; minuta
         inc       di
         inc       di

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       ax
         ret

SetRBook ENDP

; *****************************************************************************
;                                  GetRBook
;                         naáten° á°sla r†meáku CD-ROM
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=á°slo r†mce CD-ROM v Red Book form†tu
; VùSTUP: DX:AX=á°slo r†mce (omezeno na 99:59:74 - tj. maxim†lnà 449999)
; *****************************************************************************

GetRBook PROC      FAR

         mov       al,60                    ; poáet sekund na minutu
         mul       byte ptr ds:[si+2]       ; p©epoáet minut na sekundy
         add       al,ds:[si+1]             ; p©iáten° sekund
         adc       ah,0
         mov       dx,75                    ; poáet r†meákñ na sekundu
         mul       dx                       ; p©epoáet sekund na r†meáky
         add       al,ds:[si]               ; p©iáten° poátu r†meákñ
         adc       ah,0
         adc       dx,0

         cmp       dx,6                     ; vy®®° á†st á°sla 449999
         jne       GetRBok2
         cmp       ax,56783                 ; nië®° á†st á°sla 449999
GetRBok2:jbe       GetRBok4                 ; á°slo je OK
         mov       dx,6                     ; omezen° á°sla
         mov       ax,56783
GetRBok4:ret

GetRBook ENDP

; -----------------------------------------------------------------------------
;        inicializace menu CD-disku
; -----------------------------------------------------------------------------

InitCDMn PROC      FAR

         call      far ptr CentMenu         ; vyst©edàn° menu
         ret

InitCDMn ENDP

; *****************************************************************************
;        zobrazen° menu CD-disku DS:SI
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) ukazatel ©†dku na displeji
;                   SS:[BP-2] (1) poá†teán° pozice okna
;                   SS:[BP-3] (1) vò®ka okna
;                   SS:[BP-4] (1) ®°©ka okna
;                   SS:[BP-6] (2) hladina k zobrazen°
;                   SS:[BP-10] (4) omezenò konec disku
;                   SS:[BP-12] (2) adresa poá†tku indik†toru v bufferu
;                   SS:[BP-14] (2) dÇlka indik†toru (pozic)
; *****************************************************************************

DispCDMn PROC      FAR

         call      far ptr DispRamM         ; zobrazen° horn° a doln° linky

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ inicializace lok†ln°ch promànnòch

         sub       sp,14
         mov       ah,0
         mov       dx,word ptr ds:[si+MnuPoz] ; ©†dek a pozice k zobrazen°
         mov       ss:[bp-2],dx             ; ukazatel ©†dku a pozice
         mov       cx,word ptr ds:[si+MnuSir] ; ®°©ka a vò®ka okna menu
         mov       ss:[bp-4],cx             ; ®°©ka a vò®ka okna
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen° menu
         mov       ss:[bp-6],ax             ; hladina k zobrazen°

         mov       al,cl                    ; AL <- ®°©ka okna
         mov       ah,0
         sub       al,4                     ; odeáten° okrajñ
         mov       ah,60                    ; poáet sekund na minutu
         mul       ah                       ; omezen° v sekund†ch
         mov       dx,75                    ; poáet sektorñ na sekundu
         mul       dx                       ; omezen° v r†meác°ch
         add       ax,word ptr ds:[CDFBeg]  ; p©iáten° poá†tku
         adc       dx,word ptr ds:[CDFBeg+2]
         cmp       dx,word ptr ds:[CDFEnd+2] ; je konec del®° ?
         jne       DispCDM1
         cmp       ax,word ptr ds:[CDFEnd]
DispCDM1:jbe       DispCDM2                 ; konec je del®°
         mov       ax,word ptr ds:[CDFEnd]  ; omezen° dÇlky
         mov       dx,word ptr ds:[CDFEnd+2]
DispCDM2:mov       ss:[bp-10],ax            ; omezenò konec disku
         mov       ss:[bp-10+2],dx

         mov       ch,0
         shl       cx,1                     ; CX <- velikost bufferu pro ©†dek
         sub       sp,cx                    ; m°sto k dek¢dov†n° ©†dku

         mov       bx,75*60/4               ; dàlitel pro p©epoáet na 1/4 minuty
         adc       dx,0
         div       bx                       ; vòpoáet 1/4 sekund
         add       ax,3                     ; bude zaokrouhlen° nahoru
         shr       ax,1
         shr       ax,1
         mov       ss:[bp-14],ax            ; dÇlka indik†toru (pozic)
         inc       ax
         inc       ax                       ; váetnà okrajñ r†mu
         shr       cx,1                     ; CX <- ®°©ka okna (pozic)
         sub       cx,ax                    ; CX <- zbytek na okraje
         shr       cx,1                     ; polovina na okraje
         mov       ds:[CDMapPoz],cl         ; pozice poá†tku mapy disku v oknà
         shl       cx,1                     ; offset poá†tku
         add       cx,sp                    ; CX <- adresa poá†tku v bufferu
         mov       ss:[bp-12],cx            ; adresa poá†tku indik†toru

; ------ aktu†ln° nahr†vka

         mov       dx,ss:[bp-2]             ; ©†dek a pozice k zobrazen°
         mov       cx,ss:[bp-4]             ; ®°©ka okna
         mov       ax,ss:[bp-6]             ; hladina k zobrazen°
         inc       dh
         mov       si,offset CDROMMP1
         call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ disk celkem

         inc       dh
         mov       si,offset CDROMMP2
         call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ pr†zdnò ©†dek

         inc       dh
         mov       si,offset CDROMMP0
         call      far ptr DispTxtM         ; zobrazen° ©†dku
         inc       dh
         mov       ss:[bp-2],dx             ; nov† pozice k zobrazen°

; ------ á°sla nahr†vek

         call      DispCDC                  ; vymaz†n° ©†dku
         jz        DspCDM36

         mov       bl,ds:[CDBTrack]         ; poá†teán° stopa
DspCDM32:push      di
         mov       al,bl                    ; AL <- á°slo stopy
         call      CDGTrack                 ; naáten° á°sla r†meáku
         call      DispCDO                  ; p©epoáet
         shl       ax,1                     ; offset
         add       di,ax                    ; pozice k uloëen°
         mov       al,bl
         cmp       al,10
         jb        DspCDM33
         add       al,7
DspCDM33:add       al,"0"
         cmp       al,"Z"
         ja        DspCDM34
         mov       es:[di+2],al             ; uloëen° pozice
DspCDM34:pop       di
         inc       bx                       ; zvò®en° á°sla stopy
         cmp       bl,ds:[CDETrack]         ; jsou jië v®echny stopy ?
         jbe       DspCDM32                 ; dal®° stopa

DspCDM36:call      DispCDD                  ; zobrazen° ©†dku

; ------ horn° stupnice

         call      DispCDC                  ; vymaz†n° ©†dku
         jz        DspCDM39

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al,"⁄"
         stosw                              ; levò horn° okraj

         push      di
         mov       al,"ƒ"
         mov       cx,ss:[bp-14]            ; dÇlka indik†toru
         rep       stosw                    ; inicializace horn° stupnice

         mov       al,"ø"                   ; pravò horn° okraj
         stosw
         pop       di

         mov       bl,ds:[CDBTrack]         ; poá†teán° stopa
DspCDM38:push      di
         mov       al,bl                    ; AL <- á°slo stopy
         call      CDGTrack                 ; naáten° á°sla r†meáku
         call      DispCDO                  ; p©epoáet
         shl       ax,1                     ; offset
         add       di,ax                    ; pozice k uloëen°
         mov       byte ptr es:[di],"≈"     ; uloëen° pozice
         pop       di
         inc       bx                       ; zvò®en° á°sla stopy
         cmp       bl,ds:[CDETrack]         ; jsou jië v®echny stopy ?
         jbe       DspCDM38                 ; dal®° stopa

DspCDM39:call      DispCDD                  ; zobrazen° ©†dku

; ------ indik†tor, horn° á†st

         call      DispCDC                  ; vymaz†n° ©†dku
         jz        DspCDM49

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al,"≥"
         stosw                              ; levò okraj r†mu

         mov       ax,word ptr ds:[CDFAkt]  ; aktu†ln° pozice
         mov       dx,word ptr ds:[CDFAkt+2]
         call      DispCDO                  ; p©epoáet

         mov       bx,ss:[bp-14]            ; dÇlka indik†toru
         sub       bx,ax                    ; zbytek indik†toru

         xchg      ax,cx                    ; CX <- dÇlka plnÇ á†sti

         push      bx
         push      cx
         push      dx

         mov       ah,ds:[CDColInd]         ; barva indik†toru
         mov       al,"€"
         rep       stosw                    ; uloëen° plnÇ á†sti

         cmp       dl,3                     ; bude necel† á†st ?
         jne       DspCDM43
         mov       al,"‹"
         stosw
         dec       bx

DspCDM43:mov       al," "
         mov       cx,bx                    ; CX <- zbytek
         rep       stosw                    ; uloëen° zbytku

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al,"≥"
         stosw                              ; pravò okraj r†mu

         pop       dx
         pop       cx
         pop       bx

DspCDM49:call      DispCDD                  ; zobrazen° ©†dku

; ------ indik†tor, doln° á†st

         call      DispCDC                  ; vymaz†n° ©†dku
         jz        DspCDM59

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al,"≥"
         stosw                              ; levò okraj r†mu

         mov       ah,ds:[CDColInd]         ; barva indik†toru
         mov       al,"€"
         rep       stosw                    ; uloëen° plnÇ á†sti

         cmp       dl,1                     ; bude necel† á†st ?
         jb        DspCDM53
         ja        DspCDM52
         mov       al,"‹"
DspCDM52:stosw
         dec       bx

DspCDM53:mov       al," "
         mov       cx,bx                    ; CX <- zbytek
         rep       stosw                    ; uloëen° zbytku

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al,"≥"
         stosw                              ; pravò okraj r†mu

DspCDM59:call      DispCDD                  ; zobrazen° ©†dku

; ------ doln° stupnice

         call      DispCDC                  ; vymaz†n° ©†dku
         jz        DspCDM64

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al,"¿"                   ; levò doln° roh
         stosw

         mov       cx,ss:[bp-14]            ; dÇlka indik†toru (pozic)
         mov       dl,1                     ; á°taá stupnice
DspCDM61:mov       al,"¡"
         dec       dl                       ; je ukazatel ?
         jnz       DspCDM62                 ; nen° ukazatel
         mov       al,"≈"
         mov       dl,5
DspCDM62:stosw
         loop      DspCDM61

         mov       al,"Ÿ"
         stosw                              ; pravò doln° roh

DspCDM64:call      DispCDD                  ; zobrazen° ©†dku

; ------ áasy

         call      DispCDC                  ; vymaz†n° ©†dku
         jz        DspCDM69

         mov       cx,ss:[bp-14]            ; dÇlka indik†toru (pozic)
         mov       dx,1                     ; á°taá stupnice, á°slo áasu
DspCDM66:dec       dl                       ; je ukazatel ?
         jnz       DspCDM67                 ; nen° ukazatel
         mov       dl,5
         mov       al,dh                    ; AL <- á°slo
         aam
         add       ax,"00"
         mov       es:[di+2],al
         cmp       ah,"0"
         je        DspCDM67
         mov       es:[di],ah
DspCDM67:inc       di
         inc       di
         inc       dh
         loop      DspCDM66

DspCDM69:call      DispCDD                  ; zobrazen° ©†dku

; ------ stav

         mov       dx,ss:[bp-2]             ; ©†dek a pozice k zobrazen°
         mov       cx,ss:[bp-4]             ; ®°©ka okna
         mov       ax,ss:[bp-6]             ; hladina k zobrazen°
         mov       si,offset CDROMMP5       ; EJECT
         cmp       byte ptr ds:[CDStav],1   ; je EJECT ?
         jb        DispCDM8                 ; je EJECT
         mov       si,offset CDROMMP6       ; NO DISC
         je        DispCDM8                 ; je NO DISC
         mov       si,offset CDROMMP7       ; STOP
         cmp       byte ptr ds:[CDStav],3   ; je PAUSE ?
         jb        DispCDM8                 ; je STOP
         mov       si,offset CDROMMP8       ; PAUSE
         je        DispCDM8                 ; je PAUSE
         mov       si,offset CDROMP91       ; jinak PLAY
         test      byte ptr ds:[CDFAkt],bit4
         jz        DispCDM8
         mov       si,offset CDROMP92

DispCDM8:call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ pr†zdnò ©†dek

         inc       dh
         mov       si,offset CDROMMP0
         call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ n†povàda 1

         inc       dh
         mov       si,offset CDROMMP3
         call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ n†povàda 2

         inc       dh
         mov       si,offset CDROMMP4
         call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ n†povàda 3

         inc       dh
         mov       si,offset CDROMP42
         call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ n†povàda 4

         inc       dh
         mov       si,offset CDROMP43
         call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispCDMn ENDP

; ------ vymaz†n° ©†dku

DispCDC: push      ss
         pop       es                       ; ES <- buffer
         mov       di,sp
         inc       di
         inc       di                       ; p©eskoáen° n†vratovÇ adresy

         push      cx

         cld
         mov       ah,ds:[ColMnu1R]         ; bàën† barva textu
         mov       al,"≥"                   ; levò okraj
         stosw

         mov       cl,ss:[bp-4]             ; CL <- ®°©ka okna
         mov       ch,0
         dec       cx
         dec       cx                       ; CX <- vnit©n° ®°©ka okna
         mov       ah,ds:[ColMnu1]
         mov       al," "                   ; vnit©n° znak mezery
         rep       stosw                    ; vymaz†n° ©†dku

         mov       ah,ds:[ColMnu1L]
         mov       al,"≥"                   ; pravò okraj
         stosw                              ; pravò okraj

         mov       di,ss:[bp-12]            ; poá†tek indik†toru
         cmp       byte ptr ds:[CDETrack],0 ; jsou platnÇ stopy ?

         pop       cx
         ret

; ------ zobrazen° ©†dku

DispCDD: mov       si,sp                    ; SI <- buffer ©†dku
         inc       si
         inc       si

         push      cx
         push      dx

         mov       dx,ss:[bp-2]             ; ©†dek a pozice k zobrazen°
         mov       cx,ss:[bp-4]             ; ®°©ka okna
         mov       ax,ss:[bp-6]             ; hladina k zobrazen°
         push      dx
         call      far ptr DispKStr         ; zobrazen° ©†dku
         pop       dx
         inc       dh
         mov       ss:[bp-2],dx

         pop       dx
         pop       cx
         ret

; ------ omezen° na konec disku, p©epoáet na minutu (->AX) a á†st (->DX)

DispCDO: push      bx

         cmp       dx,ss:[bp-10+2]          ; je omezen° konce disku ?
         jne       DispCDO2
         cmp       ax,ss:[bp-10]
DispCDO2:jbe       DispCDO4
         mov       ax,ss:[bp-10]            ; omezen°
         mov       dx,ss:[bp-10+2]
DispCDO4:sub       ax,word ptr ds:[CDFBeg]  ; offset od poá†tku disku
         sbb       dx,word ptr ds:[CDFBeg+2]
         mov       bx,75*60/4               ; pro p©epoáet na 1/4 minut
         div       bx                       ; p©epoáet na 1/4 minut
         mov       bx,4                     ; pro p©epoáet na minuty
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; p©epoáet na minuty

         pop       bx
         ret

; *****************************************************************************
;
;                           menu Nastaven°
;
; *****************************************************************************
;˛
Nastav   PROC      FAR

         mov       bx,ds:[NumMenu]          ; poáet menu
         shl       bx,1
         mov       ax,word ptr ds:[PozMenu+bx-2] ; poá†t. pozice p©ede®lÇho okna
         add       ax,107h
         mov       word ptr ds:[si+MnuPoz],ax
         jmp       far ptr VertMenu

Nastav   ENDP

; -----------------------------------------------------------------------------
;        menu - nastaven° n†rodn°ho k¢du
; -----------------------------------------------------------------------------

NastKod  PROC      FAR

         mov       ax,word ptr ds:[ZNMnVert+MnuPoz] ; pozice p©ede®lÇho menu
         add       ax,1*HI + 7              ; posun poá†tku okna
         mov       word ptr ds:[si+MnuPoz],ax ; pozice tohoto okna
         call      KodNMnS                  ; p©°prava p©ep°naáñ
         jmp       far ptr VertMenu

NastKod  ENDP

; ------ zmàna n†rodn°ho k¢du

KodNMnX1 PROC      FAR

         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn° poloëka
         cmp       al,ds:[CodePage]         ; je zmàna k¢du ?
         je        KodNMX13                 ; nen° zmàna k¢du
         mov       ds:[CodePage],al         ; nov† k¢dov† str†nka
         mov       ds:[CodePag0],al         ; uráen† k¢dov† str†nka
         mov       byte ptr ds:[CodePagK],1 ; je k¢d Kamenickòch
         cmp       al,3                     ; je Kamenickòch ?
         je        KodNMX12                 ; je k¢d Kamenickòch
         inc       byte ptr ds:[CodePagK]   ; je Latin 2
         cmp       al,4                     ; je Latin 2 ?
         je        KodNMX12                 ; je Latin 2
         mov       byte ptr ds:[CodePagK],0 ; jinak k¢d neuráen

KodNMX12:call      KodNMnS                  ; p©°prava p©ep°naáñ
         cmp       bl," "                   ; je p©ep°naá ?
         jne       KodNMX14                 ; nen° p©ep°naá
         call      far ptr InitVMod         ; inicializace videom¢du
         call      far ptr DispAll          ; novÇ zobrazen° v®eho
KodNMX13:ret

KodNMX14:add       sp,4
         call      far ptr ClosMnuA         ; uzav©en° menu
         call      far ptr InitVMod         ; inicializace videom¢du
         call      far ptr DispAll          ; novÇ zobrazen° v®eho
         jmp       far ptr Main0

KodNMnX1 ENDP

; ------ p©ep°naá Vlastn° fonty

KodNMnX2 PROC      FAR

         xor       byte ptr ds:[ParDisp2],bit5 ; zmàna p©°znaku DownLoad
         jmp       short KodNMX12           ; p©edefinov†n° displeje

KodNMnX2 ENDP

; -----------------------------------------------------------------------------
;        p©°prava p©ep°naáñ pro menu volby n†rodn°ho k¢du DS:SI
; -----------------------------------------------------------------------------

KodNMnS  PROC      NEAR

         push      cx
         push      dx

         mov       cl,ds:[CodePage]         ; aktu†ln° k¢dov† str†nka
         dec       cx
         mov       dl,bit0
         shl       dl,cl                    ; rotace p©ep°naáe na pozici
         test      byte ptr ds:[ParDisp2],bit5 ; prov†d° se DownLoad ?
         jz        KodNMnS1                 ; nen° DownLoad
         or        dl,bit4                  ; p©°znak DownLoad
KodNMnS1:call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         pop       dx
         pop       cx
         ret

KodNMnS  ENDP

; -----------------------------------------------------------------------------
;        nastaven° uëivatelskÇho menu
; -----------------------------------------------------------------------------

NastIniU PROC      FAR

; ------ zru®en° n†vratovÇ adresy a uzav©en° oken menu

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu

; ------ p©°prava lok†ln°ho bufferu

         sub       sp,FileMax+30            ; buffer pro jmÇno souboru

; ------ implicitn° jmÇno souboru DOSMAN.MNU

         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       si,offset UserMNam       ; jmÇno souboru DOSMAN.MNU
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ test, zda je jmÇno souboru zad†no

         mov       si,offset UserMFil       ; zadanÇ jmÇno
         cmp       byte ptr ds:[si],0       ; je zad†n soubor ?
         je        short NastInU4           ; nen° zad†n - implicitn°

; ------ p©enos zadanÇho jmÇna souboru

         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         cld
NastInU2:lodsb
         stosb
         cmp       al,0
         jne       NastInU2
         dec       di                       ; n†vrat na koncovou 0

; ------ vyvol†n° editace souboru uëivatelskÇho menu

NastInU4:sub       di,sp                    ; DI <- dÇlka jmÇna souboru
         mov       cx,di                    ; CX <- dÇlka jmÇna souboru
         mov       di,sp                    ; offset jmÇna souboru
         mov       byte ptr ds:[SRSMnPl4],0 ; nen° jmÇno souboru
         mov       byte ptr ds:[LinNum],0   ; nen° koment†© k souboru
         mov       byte ptr ds:[ZapsTypI],4 ; p©°znak uëivatelskÇho menu
         call      far ptr EditNOT          ; obsluha editoru NOT

; ------ n†vrat z editace

         add       sp,FileMax+30            ; n†vrat ukazatele z†sobn°ku
         jmp       far ptr Main0

NastIniU ENDP

; -----------------------------------------------------------------------------
;        nastaven° konfigurace DOS Manaëeru
; -----------------------------------------------------------------------------
;˛
NastIni  PROC      FAR

; ------ zru®en° n†vratovÇ adresy a uzav©en° oken menu

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken menu

; ------ p©°prava lok†ln°ho bufferu

;NastIniF LABEL     FAR

         sub       sp,FileMax+30            ; buffer pro jmÇno souboru

; ------ jmÇno souboru DOSMAN.INI

         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       si,offset DosmIni        ; jmÇno souboru DOSMAN.INI
         call      far ptr TempFile         ; sestaven° jmÇna souboru

; ------ vyvol†n° editace konfiguraán°ho souboru

         sub       di,sp                    ; DI <- dÇlka jmÇna souboru
         mov       cx,di                    ; CX <- dÇlka jmÇna souboru
         mov       di,sp                    ; offset jmÇna souboru
         mov       byte ptr ds:[SRSMnPl4],0 ; nen° jmÇno souboru
         mov       byte ptr ds:[LinNum],0   ; nen° koment†© k souboru
         mov       byte ptr ds:[ZapsTypI],3 ; p©°znak konfiguraán°ho souboru
         and       byte ptr ds:[StartPar],not bit1 ; nen° aktualizace INI souboru
         call      far ptr EditNOT          ; obsluha editoru NOT

; ------ n†vrat z editace

         add       sp,FileMax+30            ; n†vrat ukazatele z†sobn°ku
         test      byte ptr ds:[WindPar],bit6 ; je editace souborñ ?
         jnz       NastIni1                 ; je editace souborñ
         test      byte ptr ds:[StartPar],bit1 ; je aktualizace INI ?
         jnz       NastIni2                 ; je aktualizace INI
NastIni1:jmp       far ptr Main0

NastIni2:jmp       far ptr ProgrExe         ; aktualizace INI souboru


;; ------ sestaven° plnÇ specifikace programu DOSMINIT.EXE (vol†no tÇë z Ctrl-F10)
;
;NastIniF LABEL     FAR
;
;         push      ds
;         pop       es                       ; ES <- adresa bufferu k ukl†d†n°
;         mov       di,offset LineCBuf       ; buffer p©°kazovÇho ©†dku
;         mov       si,offset NastIniP       ; jmÇno programu DOSMINIT.EXE
;         call      far ptr HomeFile         ; sestaven° jmÇna programu
;
;; ------ oddàlovac° mezera mezi jmÇnem programu a parametrem
;
;         mov       byte ptr ds:[di]," "     ; oddàlovac° mezera
;         inc       di                       ; p©eskoáen° mezery
;
;; ------ p©id†n° parametru - specifikace konfiguraán°ho souboru DOSMAN.INI
;
;         mov       si,offset DosmIni        ; jmÇno souboru DOSMAN.INI
;         call      far ptr TempFile         ; sestaven° jmÇna souboru
;
;; ------ oddàlovac° mezera mezi jmÇnem souboru a programovòm adres†©em
;
;NastIni3:mov       byte ptr ds:[di]," "     ; oddàlovac° mezera
;         inc       di                       ; p©eskoáen° mezery
;
;; ------ p©id†n° programovÇho adres†©e
;
;         mov       si,offset NastIni0       ; pr†zdnò soubor
;         call      far ptr HomeFile         ; programovò adres†©e
;
;; ------ oznaáen° konce textu
;
;         mov       word ptr ds:[di],CR + LF*HI ; oznaáen° konce ©†dku
;
;; ------ dÇlka textu
;
;         sub       di,offset LineCBuf       ; dÇlka textu
;         xchg      ax,di
;         mov       ds:[LineCNum],al         ; dÇlka p©°kazu
;         mov       byte ptr ds:[UserSwcM],bit1+bit3 ; je m¢d spou®tàn° LOADER
;         jmp       far ptr ProgrExe         ; proveden° p©°kazu

NastIni  ENDP

; *****************************************************************************
;
;                                 Hodiny
;
; *****************************************************************************
;˛
Hodiny   PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken

; ------ otev©en° okna hodin

         mov       si,offset ZHMnuLin       ; okno hodin
         mov       word ptr ds:[si+MnuHlp],offset ZHMnuLH1 ; z†kladn° n†povàda
         and       byte ptr ds:[HodParm],not bit0+bit1+bit2 ; zru®en° p©°znakñ
         call      far ptr OpenMnu          ; otev©en° okna hodin
         or        byte ptr ds:[ParZvl],bit1 ; p©°znak zapnut° hodin

; ------ áek†n° na zad†n° kl†vesy

AWZMnu51:call      far ptr DispTKur         ; zobrazen° kurzoru
         call      far ptr InpChar          ; vstup znaku z kl†vesnice
         call      far ptr MCtrlO           ; p©echodnÇ vypnut° menu
         jc        AWZMnu51                 ; byla funkce Ctrl-O

; ------ ovl†d†n° my®°

         cmp       bh,MousXKod/HI           ; je k¢d my®i ?
         jne       AWZM5111                 ; nen° k¢d my®i
         and       bl,not bit6              ; zru®en° p©°znaku dvoj°ho stisku
         cmp       bl,MousXRP               ; stisk pravÇho tlaá°tka ?
         je        AWZM5110                 ; p©eru®en° pravòm tlaá°tkem my®i
         test      bl,bit2+bit3             ; stisk nàkterÇho tlaá°tka ?
         jz        AWZMnu51                 ; nen° stisk tlaá°tka
         call      far ptr MouseMnu         ; test, zda je okno menu
         mov       bx,1c0dh                 ; n†hrada kl†vesou ENTER
         jnc       AWZM5111                 ; je proveden° volby jako ENTER
AWZM5110:mov       bx,11bh                  ; n†hrada kl†vesou ESC

; ------ test, zda je reëim modifikace

AWZM5111:mov       ah,byte ptr ds:[si+MnuNum] ; poáet poloëek
         mov       al,byte ptr ds:[si+MnuAkt] ; aktivn° poloëka
         test      byte ptr ds:[HodParm],bit0 ; je reëim modifikace ?
         jnz       AWZMn511                 ; je reëim modifikace

; ------ test, zda je ESC

         cmp       bl,1bh                   ; ESC ?
         je        AWZMnu50

; ------ ENTER

         cmp       bl,0dh                   ; ENTER ?
         jne       AWZMnu51                 ; jin† kl†vesa neplat°
         or        byte ptr ds:[HodParm],bit0 ; reëim modifikace
         mov       word ptr ds:[si+MnuHlp],offset ZHMnuLH2 ; n†povàda editace
AWZM5114:call      far ptr DispMnu          ; novÇ zobrazen° menu
         jmp       short AWZMnu51           ; dal®° kl†vesa

; ------ ukonáen° reëimu editace ESC

AWZMn512:and       byte ptr ds:[HodParm],not bit0+bit1+bit2 ; nen° modifikace
         mov       word ptr ds:[si+MnuHlp],offset ZHMnuLH1 ; z†kladn° n†povàda
         jmp       short AWZM5114

; ------ test, zda je znak á°slice v reëimu modifikace

AWZMn511:cmp       bl," "                   ; je mezera ?
         jne       AWZM5112
         mov       bl,"0"                   ; mezera se nahrad° "0"
AWZM5112:cmp       bl,"0"
         jb        AWZMn513                 ; nen° á°slice
         cmp       bl,"9"
         ja        AWZMn513                 ; nen° á°slice

; ------ zad†n° á°slice

         mov       di,ax                    ; AL=aktivn° poloëka
         and       di,0ffh                  ; aktivn° poloëka
         add       di,offset TKurzPoz-1     ; evropskò a americkò form†t data
         cmp       byte ptr ds:[FormDat],2  ; je japonskò form†t data ?
         jne       AWZMn510                 ; nen° japonskò form†t data
         add       di,offset(TKurzPz0-TKurzPoz) ; japonskò form†t data
AWZMn510:mov       di,word ptr cs:[di]      ; offset kurzoru
         and       di,0ffh                  ; offset kurzoru
         cmp       al,6                     ; je datum ?
         jbe       AWZMn515                 ; je áas
         inc       di
         inc       di                       ; korekce pro datum
         or        byte ptr ds:[HodParm],bit2 ; p©°znak modifikace data
         jmp       short AWZMn514
AWZMn515:or        byte ptr ds:[HodParm],bit1 ; p©°znak modifikace áasu
AWZMn514:mov       ds:[di+HodMCas],bl       ; uloëen° á°slice
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         jmp       short AWZMnu52           ; posun kurzoru vpravo

; ------ konec ESC

AWZMnu50:and       byte ptr ds:[ParZvl],not bit1 ; nejsou zobrazeny hodiny
         call      far ptr ClosMnuA         ; uzav©en° okna hodin
         jmp       far ptr Main0

AWZMn513:call      far ptr JumpBX

         dw        4d00h,AWZMnu52           ; kurzor vpravo
         dw        4b00h,AWZMnu53           ; kurzor vlevo
         dw        4700h,AWZMnu54           ; HOME
         dw        4f00h,AWZMnu55           ; END
         dw        0f09h,AWZMnu56           ; TAB
         dw        0f00h,AWZMnu56           ; *TAB
         dw        7300h,AWZMn565           ; ^VLEVO
         dw        7400h,AWZMn568           ; ^VPRAVO
         dw        0e08h,AWZMnu53           ; BS

         dw        011bh,AWZMn512           ; ESC
         dw        1c0dh,AWZMn591           ; ENTER

         dw        0,AWZMnu51

; ------ kurzor vpravo

AWZMnu52:inc       ax                       ; zvò®en° aktivn° poloëky
         cmp       al,ah                    ; p©ekroáena posledn° poloëka ?
         jbe       AWZMnu58                 ; poloëka je OK
         mov       al,1                     ; p©eteáen° na prvn° poloëku
         jmp       short AWZMnu58

; ------ kurzor vlevo

AWZMnu53:dec       al                       ; sn°ëen° aktivn° poloëky
         jnz       AWZMnu58                 ; nen° p©ekroáena prvn° poloëka
         mov       al,ah                    ; p©eteáen° na posledn° poloëku
         jmp       short AWZMnu58

; ------ HOME

AWZMnu54:cmp       al,7                     ; je uvnit© data ?
         ja        AWZMn542                 ; je uvnit© data
         mov       al,1                     ; zaá†tek áasu
         jmp       short AWZMnu58
AWZMn542:mov       al,7                     ; zaá†tek data
         jmp       short AWZMnu58

; ------ END

AWZMnu55:cmp       al,6                     ; je konec áasu ?
         jb        AWZMn552                 ; je p©ed koncem áasu
         mov       al,14                    ; konec data
         jmp       short AWZMnu58
AWZMn552:mov       al,6                     ; konec áasu
         jmp       short AWZMnu58

; ------ TAB

AWZMnu56:cmp       al,12                    ; je za polovinou roku ?
         jbe       AWZMn561                 ; je to je®tà OK
         mov       al,12                    ; omezen° pozice na 6 á°slic
AWZMn561:sub       al,6                     ; p©epnut° do pole áasu
         ja        AWZMn562                 ; je pole áasu OK
         add       al,12                    ; oprava na pole data
AWZMn562:jmp       short AWZMnu58

; ------ slovo vlevo

AWZMn565:and       al,not bit0              ; zarovn†n° na sudou pozici
         cmp       byte ptr ds:[FormDat],2  ; je japonskò form†t data ?
         je        AWZM5652                 ; je japonskò form†t data

         cmp       al,14                    ; je posledn° á°slice roku ?
         jne       AWZMn566                 ; nen° posledn° á°slice roku
         mov       al,12                    ; omezen° na 6 á°slic data
AWZMn566:sub       al,2                     ; posun vlevo o 1 pole
         jnc       AWZMn567                 ; nen° podteáen° poá†tku
         mov       al,10                    ; oprava na poá†tek roku
AWZMn567:inc       ax                       ; n†vrat poloëky zpàt
         jmp       short AWZMnu58

AWZM5652:cmp       al,10                    ; je posledn° dvojá°sl° roku ?
         jne       AWZM5653                 ; nen°
         mov       al,8                     ; oprava na poá†tek roku
AWZM5653:sub       al,2                     ; posun vlevo o 1 pole
         jnc       AWZMn567                 ; nen° podteáen° poá†tku
         mov       al,12                    ; oprava na poá†tek posledn° poloëky
         jmp       short AWZMn567

; ------ slovo vpravo

AWZMn568:dec       ax                       ; poloëka relativnà
         and       al,not bit0              ; zarovn†n° na sudou pozici
         add       al,2                     ; zvò®en° pozice
         cmp       byte ptr ds:[FormDat],2  ; je japonskò form†t data ?
         je        AWZM5682                 ; je japonskò form†t data

         cmp       al,10                    ; je konec roku ?
         jbe       AWZMn567                 ; nen° konec roku
AWZM5681:xor       al,al                    ; p©esun na poá†tek prvn° poloëky
         jmp       short AWZMn567

AWZM5682:cmp       al,14                    ; je posledn° poloëka ?
         je        AWZM5681                 ; je posledn° poloëka -> poá†tek
         cmp       al,8                     ; je st©ed roku ?
         jne       AWZMn567                 ; nen° st©ed roku
         mov       al,10                    ; oprava na dal®° poloëku
         jmp       short AWZMn567

; ------ nastaven° novÇ pozice kurzoru

AWZMnu58:mov       byte ptr ds:[si+MnuAkt],al ; nov† aktivn° poloëka
AWZMnu59:jmp       AWZMnu51                 ; zobrazen° menu

; ------ nastaven° zadanÇho data a áasu ENTER

AWZMn591:push      si

         test      byte ptr ds:[HodParm],bit1 ; byl áas modifikov†n ?
         jz        AWZMn592                 ; áas nebyl modifikov†n

         mov       si,offset HodMCas        ; £daj áasu
         call      DekCas                   ; dek¢dov†n° hodiny
         mov       ch,al                    ; hodina
         call      DekCas                   ; dek¢dov†n° minuty
         mov       cl,al                    ; minuta
         call      DekCas                   ; dek¢dov†n° sekundy
         mov       dh,al                    ; dekunda
         mov       dl,0                     ; setiny sekundy
         mov       ah,2dh
         int       21h                      ; nastaven° systÇmovÇho áasu

AWZMn592:test      byte ptr ds:[HodParm],bit2 ; byl datum modifikov†n ?
         jz        AWZMn593                 ; datum nebyl modifikov†n

         mov       si,offset HodMDat        ; £daj data

         cmp       byte ptr ds:[FormDat],2  ; je japonskò form†t ?
         jne       AWZM5921
         call      DekCas                   ; dek¢dov†n° stolet°
         mov       cl,100                   ; n†sobek
         mul       cl                       ; p©epoáet na stolet°
         xchg      ax,cx                    ; stolet°
         dec       si
         call      DekCas                   ; dek¢dov†n° jednotek roku
         mov       ah,0
         add       cx,ax                    ; rok
         call      DekCas                   ; dek¢dov†n° màs°ce
         mov       dh,al                    ; màs°c
         call      DekCas                   ; dek¢dov†n° dne
         mov       dl,al                    ; den
         jmp       short AWZM5924

AWZM5921:call      DekCas                   ; dek¢dov†n° dne (màs°ce)
         mov       dl,al                    ; den (màs°c)
         call      DekCas                   ; dek¢dov†n° màs°ce (dne)
         mov       dh,al                    ; màs°c (den)
         cmp       byte ptr ds:[FormDat],0  ; je americkò form†t ?
         jne       AWZM5922                 ; nen° americkò form†t
         xchg      dl,dh                    ; oprava bajtñ

AWZM5922:call      DekCas                   ; dek¢dov†n° stolet°
         mov       cl,100                   ; n†sobek
         mul       cl                       ; p©epoáet na stolet°
         xchg      ax,cx                    ; CX <- stolet°
         dec       si
         call      DekCas                   ; dek¢dov†n° jednotek roku
         mov       ah,0
         add       cx,ax                    ; rok
AWZM5924:mov       ah,2bh
         int       21h                      ; nastaven° systÇmovÇho data

AWZMn593:pop       si
         jmp       AWZMn512                 ; n†vrat do bàënÇho reëimu

Hodiny   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° jednoho á°sla áasu (2 á°slice)
; -----------------------------------------------------------------------------

DekCas   PROC      NEAR

         cld
         lodsw
         xchg      ah,al
         and       ax,0f0fh
         aad
         inc       si
         ret

DekCas   ENDP

; *****************************************************************************
;                             DispTKur
;                    zobrazen° kurzoru hodin
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; *****************************************************************************

DispTKur PROC      FAR

         push      bx
         push      dx
         push      di

         mov       dx,word ptr ds:[si+MnuPoz] ; pozice okna
         add       dh,8                     ; ©†dek pro poloëky
         add       dl,19                    ; pozice pro poloëky
         mov       bh,0
         mov       bl,byte ptr ds:[si+MnuAkt] ; BX <- aktivn° poloëka

         test      byte ptr ds:[HodParm],bit0 ; je reëim modifikace ?
         jnz       DispTKr1                 ; je reëim modifikace

         call      far ptr KurzOff          ; vypnut° kurzoru
         jmp       short DispTKr3

DispTKr1:mov       di,offset TKurzPoz-1     ; evropskò a americkò form†t data
         cmp       byte ptr ds:[FormDat],2  ; je japonskò form†t data ?
         jne       DispTKr2                 ; nen° japonskò form†t data
         mov       di,offset TKurzPz0-1     ; japonskò form†t data

DispTKr2:add       dl,cs:[bx+di]            ; posun pozice
         call      far ptr SetKurz          ; nastaven° pozice kurzoru

DispTKr3:pop       di
         pop       dx
         pop       bx
         ret

DispTKur ENDP

TKurzPoz db        0,1,3,4,6,7              ; offsety - evropskò a americkò form†t
         db        23,24,26,27,29,30,31,32

TKurzPz0 db        0,1,3,4,6,7              ; offsety - japonskò form†t
         db        23,24,25,26,28,29,31,32

; *****************************************************************************
;                              InitTMnu
;                     inicializace menu hodin
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
; *****************************************************************************

InitTMnu PROC      FAR

         mov       byte ptr ds:[si+MnuAkt],1 ; aktivn° poloëka
         call      far ptr CentMenu         ; vyst©edàn° okna
         ret

InitTMnu ENDP

; *****************************************************************************
;                             DispTMnu
;                         zobrazen° hodin
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice menu
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-20] (20) buffer pro dek¢dov†n° data a áasu
;                   SS:[BP-22] (2) adresa definice okna
;                   SS:[BP-23] (1) ©†dek k zobrazen°
;                   SS:[BP-24] (1) pozice k zobrazen°
;                   SS:[BP-26] (2) hladina k zobrazen°
; *****************************************************************************

DispTMnu PROC      FAR

         call      far ptr DispRamM         ; zobrazen° horn° a doln° linky

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,160 + 26              ; vytvo©en° bufferu v z†sobn°ku

         mov       ss:[bp-22],si            ; £schova definice okna
         mov       dx,word ptr ds:[si+MnuPoz] ; ©†dek a pozice k zobrazen°
         inc       dh                       ; poá†teán° ©†dek
         mov       ss:[bp-24],dx            ; ©†dek a pozice k zobrazen°
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen°
         mov       ah,0
         mov       ss:[bp-26],ax            ; hladina k zobrazen° menu

; ------ dek¢dov†n° £daje systÇmovÇho áasu

         push      ss
         pop       es                       ; ES <- z†sobn°k v bufferu
         lea       di,[bp-20]               ; buffer k dek¢dov†n° áasu
         call      far ptr DekSTime         ; dek¢dov†n° systÇmovÇho áasu

; ------ dek¢dov†n° horn°ho okraje

         cld
         mov       di,sp

         mov       ah,ds:[ColMnu1R]         ; levò okraj
         mov       al,"≥"                   ; "≥" levò okraj
         stosw

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al," "                   ; lev† mezera
         stosw

         push      ax
         mov       ah,ds:[ColHod]           ; barva áasu
         mov       cx,65                    ; dÇlka ©†dku
         rep       stosw                    ; vymaz†n° ©†dku
         pop       ax

         stosw

         mov       ah,ds:[ColMnu1L]
         mov       al,"≥"                   ; "≥"
         stosw

; ------ zobrazen° horn°ho okraje

         call      DispTMD                  ; zobrazen° ©†dku

; ------ levò okraj linky £daje áasu

         mov       bl,0                     ; á°taá linek fontñ
DispTMn1:mov       di,sp                    ; buffer v z†sobn°ku
         cld

         mov       ah,ds:[ColMnu1R]         ; levò okraj
         mov       al,"≥"                   ; "≥" levò okraj
         stosw

         mov       ah,ds:[ColMnu1]          ; bàën† barva okna
         mov       al," "                   ; lev† mezera
         stosw

         mov       ah,ds:[ColHod]           ; barva áasu
         stosw                              ; £vodn° mezera

; ------ dek¢dov†n° znakñ £daje áasu

         mov       bh,8                     ; á°taá znakñ na ©†dku
         lea       si,[bp-20]               ; buffer s £dajem áasu

; ------ p©evod jednoho znaku

DispTMn3:push      si
         mov       al,ss:[si]               ; jeden znak k dek¢dov†n°
         sub       al,"0"                   ; korekce na á°slo
         cmp       al,9
         jbe       DispTM32
         mov       al,10                    ; omezen° - oddàlovac° znak
DispTM32:mov       ah,35                    ; poáet bajtñ na znak
         mul       ah                       ; offset fontu v tabulce
         add       al,bl                    ; p©iáten° offsetu linky
         adc       ah,0                     ; offset linky v tabulce
         add       ax,offset ObrCis         ; adresa linky
         xchg      si,ax                    ; SI <- adresa linky
         mov       ah,ds:[ColHod]           ; barva áasu
         mov       cx,7                     ; poáet bajtñ
DispTMn4:lodsb
         stosw
         loop      DispTMn4                 ; dal®° znak
         pop       si
         mov       al," "
         stosw                              ; oddàlovac°/koncov† mezera

; ------ p©°prava k dek¢dov†n° dal®°ho znaku

         inc       si
         inc       si                       ; adresa dal®°ho znaku k dek¢dov†n°
         dec       bh                       ; á°taá znakñ
         jnz       DispTMn3                 ; dal®° znak

; ------ dek¢dov†n° pravÇho okraje

         mov       ah,ds:[ColMnu1]          ; bàën† barva
         mov       al," "                   ; prav† mezera
         stosw

         mov       ah,ds:[ColMnu1L]
         mov       al,"≥"                   ; "≥" pravò okraj
         stosw

; ------ zobrazen° jednÇ linky £daje áasu

         call      DispTMD                  ; zobrazen° linky £daje áasu

; ------ p©°prava k dek¢dov†n° dal®° linky

         add       bl,7                     ; offset dal®° linky
         cmp       bl,5*7                   ; jsou jië v®echny linky ?
         jb        DispTMn1                 ; dal®° linka

; ------ oddàlovac° á†ra

         mov       ax,ss:[bp-26]            ; hladina k zobrazen°
         mov       dx,ss:[bp-24]            ; ©†dek a pozice k zobrazen°
         mov       cl,69                    ; ®°©ka okna
         call      far ptr DispCarM         ; zobrazen° oddàlovac° á†ry
         inc       byte ptr ss:[bp-23]      ; zvò®en° ukazatele ©†dku

; ------ dek¢dov†n° textu £daje áasu

         test      byte ptr ds:[HodParm],bit1 ; byla modifikace áasu ?
         jnz       DispTMn8                 ; byla modifikace áasu

         cld
         lea       si,[bp-20]               ; £daj áasu
         mov       cx,8                     ; poáet znakñ
         mov       di,offset HodMCas        ; £daj áasu
DispTMn5:lods      byte ptr es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         loop      DispTMn5

; ------ dek¢dov†n° £daje data

DispTMn8:test      byte ptr ds:[HodParm],bit2 ; byla modifikace data ?
         jnz       DispTMn7                 ; byla modifikace data

; ------ naáten° systÇmovÇho data

         mov       ah,2eh                   ; AH <- nesm° bòt nula (=barva)
         lea       di,[bp-20]               ; buffer
         mov       si,di                    ; SI <- buffer k naáten° data
         call      far ptr DekSDate         ; dek¢dov†n° systÇmovÇho data

; ------ p©enos textu £daje data

         mov       cx,10                    ; poáet znakñ
         mov       di,offset HodMDat        ; £daj data
DispTMn6:lods      byte ptr es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         loop      DispTMn6

; ------ p©enos dne v tòdnu

         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data

         mov       di,offset HodMDen
         mov       cx,offset(DnyTxt0-DnyTxt)
         mul       cl                       ; offset textu
         add       ax,offset DnyTxt         ; adresa textu
         xchg      ax,si                    ; SI <- adresa textu
         cld
DispTM62:lodsb
         mov       ds:[di],al
         inc       di
         loop      DispTM62

; ------ zobrazen° ©†dku s £dajem áasu a data

DispTMn7:mov       ax,ss:[bp-26]            ; hladina k zobrazen°
         mov       si,offset HodMTxt1       ; text ©†dku
         mov       dx,ss:[bp-24]            ; ©†dek a pozice k zobrazen°
         mov       cl,69                    ; dÇlka ©†dku
         call      far ptr DispTxtM         ; zobrazen° ©†dku

; ------ n†vrat registrñ

DispTMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispTMnu ENDP

; ------ zobrazen° ©†dku

DispTMD: mov       ax,ss:[bp-26]            ; hladina k zobrazen°
         mov       si,sp                    ; dek¢dovanò text v z†sobn°ku
         inc       si
         inc       si
         mov       cl,69                    ; dÇlka textu
         mov       dx,ss:[bp-24]            ; ©†dek a pozice k zobrazen°
         call      far ptr DispKStr         ; zobrazen° horn°ho ©†dku okna
         inc       byte ptr ss:[bp-23]      ; zvò®en° ukazatele ©†dku
         ret

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           Kalkul†tor
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
AWZMnu7  LABEL     FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken
         call      far ptr Kalkul           ; vyvol†n° kalkul†toru
         jmp       far ptr Main0

; -----------------------------------------------------------------------------
;        kalkul†tor
; -----------------------------------------------------------------------------
; £rovnà operac°:  + - un†rn°
;                  () !
;                  funkce
;                  ^
;                  * / :
;                  + -
;                  NOT
;                  AND
;                  OR, XOR
;
; konstanty:               0-9 A-F . , PI (tÇë „) EUL (Eulerova konstanta e)
;                          N†sleduje-li v á°sle za znakem "," znak "-", je
;                          povaëov†n za 0 (nap©. 200,-). Znak ' je oddàlovaá
;                          ©†dñ a v textu se ignoruje.
; aritmetickÇ operace:     + (tÇë un†rn° +) - (tÇë un†rn° -) * / : ^
; á°seln† soustava:        $ (=hex) % (=bin) @ (=oct) # (=dec)
; logickÇ operace:         OR (tÇë |) XOR (tÇë _) AND (tÇë &) NOT (tÇë ~)
; aritmetickÇ funkce:      SQRT (odmocnina - tÇë ˚)  ! faktori†l
;                          Faktori†l se uv†d° za á°slem n! nebo za z†vorkou ()!
; exponenci†ln° funkce:    LOG (dek) LN (p©ir.) EXP (p©ir.)
; trigonometrickÇ funkce:  SIN COS TG COTG ARCSIN ARCCOS ARCTAN DEG (radi†ny na
;                          stupnà) RAD (stupnà na radi†ny) (tÇë TAN a COTAN)
; rñznÇ funkce:            INT (celÇ á°slo) FRA (desetinn† á†st á°sla)
;                          ABS (absolutn° hodnota) WORD (slovo) DWORD (dvojslovo)
;                          MAXINT (maxim†ln° á°slo)
; pamàü:                   SET0 aë SET9 - uloëen° argumentu do pamàti 0 aë 9
;                          M0 aë M9 - symbol se nahrad° obsahem pamàti 0 aë 9
; cyklus:                  REP0 aë REP9 - opakov†n° vòpoátu n†sleduj°c°ho vòrazu
;                          (zapsanò stejnòm zpñsobem jako argument funkce)
;                          Ä°slo 0 aë 9 ud†v† pamàü 0 aë 9, ve kterÇ je uloëen
;                          poáet opakov†n°. Bàhem cyklu je obsah danÇ pamàti
;                          inkrementov†n od 1 do zadanÇho á°sla, lze ji
;                          pouë°vat jako argument uvnit© tàla cyklu.
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:SI=ukazatel ASCIIZ textu k dek¢dov†n°
;                   ES:DI=ukazatel vrcholu v z†sobn°ku á°sel
;                   DS=datovò segment
;                   CLD
; -----------------------------------------------------------------------------

Kalkul   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         sub       sp,260                   ; pracovn° buffer (pevn† velikost!)

; ------ £schova kurzoru

         call      far ptr GetKurz          ; poskytnut° kurzoru
         mov       ds:[KalkOKur],dx         ; £schova kurzoru

; ------ nastaven° p©°znaku kalkul†toru

         or        byte ptr ds:[ParZvl],bit3 ; p©°znak kalkul†toru

; ------ p©°prava oznaáen° oddàlovaáñ

         mov       al,ds:[OddelDes]         ; oddàlovaá desetin
         mov       ds:[ZKMnuLP6],al         ; oddàlovaá desetin
         mov       al,ds:[OddelRad]         ; oddàlovaá ©†dñ
         mov       ds:[ZKMnuLP7],al         ; oddàlovaá ©†dñ
         mov       al,ds:[OddelPol]         ; oddàlovaá dat
         mov       ds:[ZKMnuLP8],al         ; oddàlovaá dat

; ------ vytvo©en° bufferu pro pamàü

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        Kalkul06                 ; chyba
         mov       ds:[KalSMem],ax          ; segment pamàt°
         mov       bx,10*256                ; velikost bufferu pamàti
         call      far ptr ModiSegS         ; nastaven° velikosti bufferu
         jc        Kalkul06                 ; chyba pamàti

; ------ vynulov†n° bufferu pamàt°

         call      far ptr GetDat           ; adresa segmentu pamàt° -> ES
         xor       ax,ax                    ; AX <- 0 nulovac° slovo
         xor       di,di                    ; DI <- 0
         mov       cx,10*256/2              ; velikost ve slovech
         cld
         rep       stosw                    ; vynulov†n° segmentu pamàt°

; ------ vytvo©en° bufferu pro á°sla

         mov       bx,3000                  ; asi tak nàco na 20 á°sel
         call      far ptr CreatDat         ; vytvo©en° bufferu pro á°sla
         jnc       Kalkul1                  ; je to OK
Kalkul06:call      far ptr MemErr           ; chyba pamàti
Kalkul0: jmp       Kalkul9

; ------ p©°prava parametrñ bufferu

Kalkul1: mov       ds:[KalSegm],ax          ; segment z†sobn°ku
         mov       ds:[KalSEnd],bx          ; adresa konce volnÇ pamàti

; ------ zobrazen° p©°padnÇho vòsledku, zad†n° vòrazu pro vòpoáet

Kalkul18:mov       byte ptr ds:[ZKMnuLnN],0 ; nen° p©edvolba
Kalkul2: mov       si,offset ZKMnuLin       ; menu kalkul†toru
         call      KalkulP                  ; p©°prava p©ep°naáñ
         call      far ptr Lin0Menu         ; zad†n° vòrazu pro vòpoáet
         jc        Kalkul0                  ; p©eru®en° operace
         call      KalkulP                  ; p©°prava p©ep°naáñ

; ------ hl†®en°, ëe prob°h† vòpoáet

         mov       si,offset ZKMnuLHl
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

; ------ uloëen° zadanÇho vòrazu do z†sobn°ku

         mov       si,offset LinBuff        ; buffer p©°kazovÇho ©†dku
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet zadanòch znakñ
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         cld
         mov       ds:[KalErMP3],cl         ; dÇlka textu (2. á†st)
         jcxz      Kalkul4                  ; nen° nic zad†no

Kalkul3: lodsb                              ; naáten° znaku
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         stosb                              ; uloëen° znaku
         loop      Kalkul3                  ; dal®° znak

Kalkul4: mov       al,0                     ; koncov† 0
         stosb                              ; uloëen° koncovÇ 0

; ------ p©°prava k rozboru vòrazu

         mov       ax,ds:[KalSegm]          ; segment z†sobn°ku á°sel
         call      far ptr GetDat           ; adresa z†sobn°ku á°sel -> ES
         xor       di,di                    ; ukazatel vrcholu z†sobn°ku á°sel
         mov       si,sp                    ; SI <- buffer v z†sobn°ku

; ------ test, zda bylo nàco zad†no

         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      KalkSPC                  ; vypu®tàn° mezer
         cmp       al,0                     ; je nàco zad†no ?
         je        Kalkul18                 ; nen° nic zad†no

; ------ p©°prava k hl†®en° chyby

         mov       word ptr ds:[KalErMP1],offset KalErMPO ; chyba p©eteáen°
         mov       word ptr ds:[KalErMP2+3],ss
         mov       word ptr ds:[KalErMP2+1],sp
         mov       word ptr ds:[KalErMP3+3],ss

; ------ vòpoáet á°sla - z†kladn° £rove§ OR

         call      KalkOR                   ; vòpoáet £rovnà OR a XOR
         jnc       Kalkul6                  ; v®e je OK

; ------ chyba operace

Kalkul5: mov       word ptr ds:[KalErMP1],offset KalErMPV ; chyba vòrazu
         stc                                ; p©°znak chyby
         call      KalErOvf                 ; obsluha hl†®en° chyby
         call      KalkulP                  ; p©°prava p©ep°naáñ
Kalkul58:call      far ptr FlushEsc         ; vypr†zdnàn° ESC
         jmp       Kalkul18

; ------ chyba, pokud zbyl nàjakò text

Kalkul6: cmp       byte ptr ss:[si],0       ; je konec textu ?
         jne       Kalkul5                  ; nàco zbylo - chyba
         call      KalkulP                  ; p©°prava p©ep°naáñ

; ------ dek¢dov†n° vòsledku do z†sobn°ku

         mov       si,sp                    ; SI <- buffer v z†sobn°ku
         mov       cx,255                   ; max. dÇlka bufferu
         mov       dx,ss                    ; DX <- segment bufferu
         call      KalkDek                  ; dek¢dov†n° á°sla do bufferu

; ------ p©°prava p©edvolby

         sub       si,sp                    ; dÇlka textu
         mov       byte ptr ds:[ZKMnuLnN],1 ; 1 p©edvolba
         mov       word ptr ds:[ZKMnuLnD],si ; dÇlka textu
         mov       word ptr ds:[ZKMnuLnA],sp ; adresa bufferu
         mov       word ptr ds:[ZKMnuLnA+2],ss ; segment bufferu
         jmp       Kalkul2                  ; zobrazen° vòsledku, novÇ zad†n°

; ------ zru®en° segmentu kalkul†toru

Kalkul9: mov       ax,ds:[KalSegm]          ; segment kalkul†toru
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[KalSegm],ax
         mov       ax,ds:[KalSMem]          ; segment pamàt°
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[KalSMem],ax

; ------ zru®en° p©°znaku kalkul†toru

         and       byte ptr ds:[ParZvl],not bit3 ; nen° kalkul†tor

; ------ n†vrat zobrazen° kurzoru

         mov       dx,ds:[KalkOKur]         ; pñvodn° kurzor
         call      far ptr SetKurz          ; n†vrat kurzoru

         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

; ------ n†vrat registrñ

         add       sp,260                   ; n†vrat SP
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Kalkul   ENDP

; ------ p©ep°naá HEX

KalkulXH PROC      FAR

         xor       byte ptr ds:[KalParm],bit0 ; zmàna p©°znaku HEX m¢du
KalkXH2: call      KalkulP                  ; novÇ nastaven° p©ep°naáñ
         call      far ptr DispMnu          ; novÇ zobrazen° okna
         ret

KalkulXH ENDP

; ------ p©ep°naá RAD

KalkulXR PROC      FAR

         xor       byte ptr ds:[KalParm],bit1    ; zmàna p©ep°naáe RAD
         jmp       short KalkXH2

KalkulXR ENDP

; ------ p©ep°naá Tis°ce

KalkulXT PROC      FAR

         xor       byte ptr ds:[KalParm],bit2 ; zmàna p©°znaku odsazen°
         jmp       short KalkXH2

KalkulXT ENDP

; ------ poáet desetinnòch m°st

KalkulXM PROC      FAR

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       bx,99                    ; maxim†ln° hodnota á°sla
         mov       ch,0                     ; minim†ln° hodnota á°sla
         mov       cl,2                     ; dÇlka textu
         mov       dx,word ptr ds:[si+MnuPoz] ; poá†teán° pozice menu
         add       dl,55
         add       dh,ds:[si+MnuVys]
         sub       dh,3                     ; pozice relativnà
         mov       di,offset ZKMnuLP4       ; buffer k dek¢dov†n° pozic
         push      si
         mov       si,offset ZKMnuLH2       ; text n†povàdy
         call      far ptr MenuNum          ; zad†n° pozic tabul†toru
         pop       si
         mov       byte ptr ds:[KalkMist],al ; poáet desetinnòch m°st

         jmp       short KalkXH2

KalkulXM ENDP

; ------ p©°prava p©ep°naáñ menu

KalkulP  PROC      NEAR

         push      ax
         push      dx
         push      si

         mov       si,offset ZKMnuLin       ; menu kalkul†toru

         and       byte ptr ds:[KalParm],not bit6 ; nen° tabulkovò kalkul†tor

; desetiny: rozsah 10 aë 108 bajtñ (=23 aë 253 á°slic)
; cel† á†st: rozsah 30 aë 128 bajtñ (=70 aë 300 á°slic)

; Pro implicitn°ch 20 znakñ je desetiny 30 bajtñ (70 á°slic), cel† á†st
; 50 bajtñ (117 á°slic)

         mov       ax,ds:[KalkMist]         ; poáet desetinnòch m°st (0 aë 99)
         shr       ax,1                     ; 0.5 n†sobek (0 aë 49)
         add       ax,5                     ; rezerva asi 20 á°slic (5 aë 54)
         mov       ds:[KalNumDW],ax         ; poáet slov na desetiny
         mov       ds:[KalNumXW],ax         ; poáet slov celkem
         push      ax
         shl       ax,1                     ; p©evod na bajty (10 aë 108)
         mov       ds:[KalNumD],ax          ; poáet bajtñ na desetiny
         mov       ds:[KalNumX],ax          ; poáet bajtñ celkem
         pop       ax
         add       ax,10                    ; na cel† á°sla asi 40 znakñ nav°c
         mov       ds:[KalNumNW],ax         ; poáet slov na celou á†st (15 - 64)
         add       ds:[KalNumXW],ax
         shl       ax,1                     ; p©evod na bajty (30 aë 128)
         mov       ds:[KalNumN],ax          ; poáet bajtñ na celou á†st
         add       ds:[KalNumX],ax          ; poáet bajtñ celkem

         mov       al,byte ptr ds:[KalkMist] ; poáet m°st kalkul†toru
         aam
         add       ax,"00"
         xchg      al,ah
         cmp       al,"0"
         jne       KalkulP1
         mov       al," "
KalkulP1:mov       word ptr ds:[ZKMnuLP4],ax ; poáet m°st

         mov       dl,ds:[KalParm]          ; p©ep°naáe

         mov       al,ds:[ZnakSwch]         ; znak p©ep°naáe - zapnuto
         mov       byte ptr ds:[KalkZakl],16 ; HEX z†klad
         mov       word ptr ds:[KalkOdsz],4 ; odsazen° pro HEX m¢d
         test      dl,bit0                  ; je HEX m¢d ?
         jnz       KalkulP2                 ; je HEX m¢d
         mov       al,ds:[ZnakSwch+1]       ; znak p©ep°naáe - vypnuto
         mov       byte ptr ds:[KalkZakl],10 ; dekadickò m¢d
         mov       byte ptr ds:[KalkOdsz],3 ; odsazen° pro DEK m¢d

KalkulP2:mov       ds:[ZKMnuLP1],al         ; oznaáen° p©ep°naáe HEX

         mov       al,ds:[ZnakSwch]         ; je zapnuto
         test      dl,bit1                  ; je RAD ?
         jnz       KalkulP3                 ; je RAD
         mov       al,ds:[ZnakSwch+1]       ; nen° zapnuto
KalkulP3:mov       ds:[ZKMnuLP2],al         ; oznaáen° p©ep°naáe RAD

         mov       al,ds:[ZnakSwch]         ; je zapnuto
         test      dl,bit2                  ; je odsazen° ?
         jnz       KalkulP4                 ; je odsazen°
         mov       byte ptr ds:[KalkOdsz],-1 ; nen° odsazen°
         mov       al,ds:[ZnakSwch+1]       ; nen° zapnuto
KalkulP4:mov       ds:[ZKMnuLP3],al         ; oznaáen° p©ep°naáe

         call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         pop       si
         pop       dx
         pop       ax
         ret

KalkulP  ENDP

; -----------------------------------------------------------------------------
;        hl†®en° chyby (je-li CY), uchov†v† registr p©°znakñ !
; -----------------------------------------------------------------------------

KalErOvf PROC      NEAR

; ------ test, zda byla chyba

         jnc       KalErOv9                 ; nebyla chyba

; ------ £schova registrñ

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ test, zda je jië p©eru®en° operace (tj. bylo jië hl†®en°)

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        KalErOv8                 ; je p©eru®en° operace

; ------ test, zda je tabulkovò kalkul†tor

         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jnz       KalErOv7                 ; je tabulka - p©eru®en°

; ------ p©°prava hl†®en°

         mov       ax,ds:[KalkLast]         ; ukazatel SI
         mov       word ptr ds:[KalErMP3+1],ax ; adresa textu chyby
         sub       ax,word ptr ds:[KalErMP2+1] ; dÇlka textu
         mov       byte ptr ds:[KalErMP2],al ; dÇlka prvn° á†sti
         sub       byte ptr ds:[KalErMP3],al ; sn°ëen° dÇlky 2. á†sti

; ------ hl†®en° chyby

         mov       si,offset KalErMnu       ; text hl†®en°
         call      far ptr Lin0MenF         ; hl†®en° chyby
KalErOv7:call      far ptr SetEsc           ; nastaven° p©eru®en°

; ------ n†vrat registrñ

KalErOv8:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
KalErOv9:ret

KalErOvf ENDP

; -----------------------------------------------------------------------------
;        vòpoáet £rovnà OR a XOR
; -----------------------------------------------------------------------------
; VSTUP: SS:SI=ukazatel ASCIIZ textu k rozboru
;        ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: CY=chyba
;         ES:DI=zvò®enò ukazatel vrcholu z†sobn°ku á°sel (pokud je á°slo)
; -----------------------------------------------------------------------------

KalFOR   PROC      FAR

         call      KalkOR
         ret

KalFOR   ENDP

KalkOR   PROC      NEAR

; ------ naáten° prvn°ho operandu - £rove§ AND

         call      KalkAND                  ; vòpoáet £rovnà AND
         jc        KalkOR9                  ; chyba - nen° ë†dnÇ á°slo

; ------ test, zda n†sleduje oper†tor OR

KalkOR1: call      KalkSPC                  ; vypu®tàn° mezer -> AX=2 znaky
         cmp       al,"|"                   ; je OR ?
         je        KalkOR2                  ; je OR
         cmp       ax,"RO"                  ; je OR ?
         jne       KalkOR4                  ; nen° OR

         inc       si                       ; p©eskoáen° znaku "O"
KalkOR2: inc       si                       ; p©eskoáen° znaku "R" nebo "|"

; ------ naáten° druhÇho operandu pro OR

         call      KalkAND                  ; vòpoáet £rovnà AND
         jc        KalkOR9                  ; chyba - nen° dal®° á°slo

; ------ proveden° operace OR

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         call      KalXOR                   ; proveden° operace OR
         jmp       short KalkOR1            ; dal®° operand

; ------ test, zda n†sleduje oper†tor XOR (mezery jsou jië vypu®tàny)

KalkOR4: cmp       al,"_"                   ; je XOR ?
         je        KalkOR6                  ; je XOR
         cmp       ax,"OX"                  ; je XOR ?
         jne       KalkOR8                  ; nen° XOR
         cmp       byte ptr ss:[si+2],"R"   ; je XOR ?
         jne       KalkOR8                  ; nen° XOR
         inc       si                       ; p©eskoáen° znaku "X"
         inc       si                       ; p©eskoáen° znaku "O"
KalkOR6: inc       si                       ; p©eskoáen° znaku "R" nebo "_"

; ------ naáten° druhÇho operandu pro XOR

         call      KalkAND                  ; vòpoáet £rovnà AND
         jc        KalkOR9                  ; chyba - nen° dal®° á°slo

; ------ proveden° operace XOR

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         call      KalXXOR                  ; proveden° operace XOR
         jmp       short KalkOR1            ; dal®° operand

KalkOR8: clc                                ; p©°znak naáten° á°sla OK
KalkOR9: ret

KalkOR   ENDP

; -----------------------------------------------------------------------------
;        vòpoáet £rovnà AND
; -----------------------------------------------------------------------------
; VSTUP: SS:SI=ukazatel ASCIIZ textu k rozboru
;        ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: CY=chyba
;         ES:DI=zvò®enò ukazatel vrcholu z†sobn°ku á°sel (pokud je á°slo)
; -----------------------------------------------------------------------------

KalkAND  PROC      NEAR

; ------ naáten° prvn°ho operandu - £rove§ NOT

         call      KalkNOT                  ; vòpoáet £rovnà NOT
         jc        KalkAND9                 ; chyba - nen° ë†dnÇ á°slo

; ------ test, zda n†sleduje oper†tor AND

KalkAND1:call      KalkSPC                  ; vypu®tàn° mezer -> AX=2 znaky
         cmp       al,"&"                   ; je AND ?
         je        KalkAND2                 ; je AND
         cmp       ax,"NA"                  ; je AND ?
         jne       KalkAND8                 ; nen° AND
         cmp       byte ptr ss:[si+2],"D"   ; je AND ?
         jne       KalkAND8                 ; nen° AND

         inc       si                       ; p©eskoáen° znaku "A"
         inc       si                       ; p©eskoáen° znaku "N"
KalkAND2:inc       si                       ; p©eskoáen° znaku "D" nebo "&"

; ------ naáten° druhÇho operandu pro AND

         call      KalkNOT                  ; vòpoáet £rovnà NOT
         jc        KalkAND9                 ; chyba - nen° dal®° á°slo

; ------ proveden° operace AND

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         call      KalXAND                  ; proveden° operace AND
         jmp       short KalkAND1           ; dal®° operand

KalkAND8:clc                                ; p©°znak naáten° á°sla OK
KalkAND9:ret

KalkAND  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet £rovnà NOT
; -----------------------------------------------------------------------------
; VSTUP: SS:SI=ukazatel ASCIIZ textu k rozboru
;        ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: CY=nen° ë†dnÇ á°slo
;         ES:DI=zvò®enò ukazatel vrcholu z†sobn°ku á°sel (pokud je á°slo)
; -----------------------------------------------------------------------------

KalkNOT  PROC      NEAR

; ------ test, zda je oper†tor NOT

         call      KalkSPC                  ; vypu®tàn° mezer
         cmp       al,"~"                   ; je NOT ?
         je        KalkNOT2                 ; je NOT
         cmp       ax,"ON"                  ; je NOT ?
         jne       KalkADD                  ; nen° NOT - pokraáuje £rove§ ADD
         cmp       byte ptr ss:[si+2],"T"   ; je NOT ?
         jne       KalkADD                  ; nen° NOT - pokraáuje £rove§ ADD

         inc       si                       ; p©eskoáen° znaku "N"
         inc       si                       ; p©eskoáen° znaku "O"
KalkNOT2:inc       si                       ; p©eskoáen° znaku "T" nebo "!"

; ------ naáten° operandu pro NOT

         call      KalkNOT                  ; naáten° operandu pro NOT
         jc        KalkNOT9                 ; nen° operand pro NOT

; ------ proveden° operace NOT

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         call      KalXNOT                  ; proveden° operace NOT
KalkNOT9:ret

KalkNOT  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet £rovnà ADD a SUB
; -----------------------------------------------------------------------------
; VSTUP: SS:SI=ukazatel ASCIIZ textu k rozboru
;        ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: CY=chyba
;         ES:DI=zvò®enò ukazatel vrcholu z†sobn°ku á°sel (pokud je á°slo)
; -----------------------------------------------------------------------------

KalkADD  PROC      NEAR

; ------ naáten° prvn°ho operandu - £rove§ MUL

         call      KalkMUL                  ; vòpoáet £rovnà MUL
         jc        KalkADD9                 ; chyba - nen° ë†dnÇ á°slo

; ------ test, zda n†sleduje oper†tor ADD

KalkADD1:call      KalkSPC                  ; vypu®tàn° mezer -> AX=2 znaky
         cmp       al,"+"                   ; je ADD ?
         jne       KalkADD4                 ; nen° ADD
         inc       si                       ; p©eskoáen° znaku "+"

; ------ naáten° druhÇho operandu pro ADD

         call      KalkMUL                  ; vòpoáet £rovnà MUL
         jc        KalkADD9                 ; chyba - nen° dal®° á°slo

; ------ proveden° operace ADD

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         call      KalXADD                  ; proveden° operace ADD
         jc        KalkADD9                 ; chyba
         jmp       short KalkADD1           ; dal®° operand

; ------ test, zda n†sleduje oper†tor SUB (mezery jsou jië vypu®tàny)

KalkADD4:cmp       al,"-"                   ; je SUB ?
         jne       KalkADD8                 ; nen° SUB
         inc       si                       ; p©eskoáen° znaku "-"

; ------ naáten° druhÇho operandu pro SUB

         call      KalkMUL                  ; vòpoáet £rovnà MUL
         jc        KalkADD9                 ; chyba - nen° dal®° á°slo

; ------ proveden° operace SUB

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         call      KalXSUB                  ; proveden° operace SUB
         jc        KalkADD9                 ; chyba
         jmp       short KalkADD1           ; dal®° operand

KalkADD8:clc                                ; p©°znak naáten° á°sla OK
KalkADD9:ret

KalkADD  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet £rovnà MUL a DIV
; -----------------------------------------------------------------------------
; VSTUP: SS:SI=ukazatel ASCIIZ textu k rozboru
;        ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: CY=chyba
;         ES:DI=zvò®enò ukazatel vrcholu z†sobn°ku á°sel (pokud je á°slo)
; -----------------------------------------------------------------------------

KalkMUL  PROC      NEAR

; ------ naáten° prvn°ho operandu - £rove§ POW

         call      KalkPOW                  ; vòpoáet £rovnà POW
         jc        KalkMUL9                 ; chyba - nen° ë†dnÇ á°slo

; ------ test, zda n†sleduje oper†tor MUL

KalkMUL1:call      KalkSPC                  ; vypu®tàn° mezer -> AX=2 znaky
         cmp       al,"*"                   ; je MUL ?
         jne       KalkMUL4                 ; nen° MUL
         inc       si                       ; p©eskoáen° znaku "*"

; ------ naáten° druhÇho operandu pro MUL

         call      KalkPOW                  ; vòpoáet £rovnà POW
         jc        KalkMUL9                 ; chyba - nen° dal®° á°slo

; ------ proveden° operace MUL

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         call      KalXMUL                  ; proveden° operace MUL
         jc        KalkMUL9                 ; chyba
         jmp       short KalkMUL1           ; dal®° operand

; ------ test, zda n†sleduje oper†tor DIV (mezery jsou jië vypu®tàny)

KalkMUL4:cmp       al,"/"                   ; je DIV ?
         je        KalkMUL5                 ; je DIV
         cmp       al,":"                   ; je DIV ?
         jne       KalkMUL8                 ; nen° DIV
KalkMUL5:inc       si                       ; p©eskoáen° znaku "/" nebo ":"

; ------ naáten° druhÇho operandu pro DIV

         call      KalkPOW                  ; vòpoáet £rovnà POW
         jc        KalkMUL9                 ; chyba - nen° dal®° á°slo

; ------ proveden° operace DIV

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         call      KalXDIV                  ; proveden° operace DIV
         jc        KalkMUL9                 ; chyba
         jmp       short KalkMUL1           ; dal®° operand

KalkMUL8:clc                                ; p©°znak naáten° á°sla OK
KalkMUL9:ret

KalkMUL  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet £rovnà POW
; -----------------------------------------------------------------------------
; VSTUP: SS:SI=ukazatel ASCIIZ textu k rozboru
;        ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: CY=chyba
;         ES:DI=zvò®enò ukazatel vrcholu z†sobn°ku á°sel (pokud je á°slo)
; -----------------------------------------------------------------------------

KalkPOW  PROC      NEAR

; ------ naáten° prvn°ho operandu - £rove§ FNC

         call      KalkFnc                  ; vòpoáet £rovnà Fnc
         jc        KalkPOW9                 ; chyba - nen° ë†dnÇ á°slo

; ------ test, zda n†sleduje oper†tor POW

         call      KalkSPC                  ; vypu®tàn° mezer -> AX=2 znaky
         cmp       al,"^"                   ; je POW ?
         jne       KalkPOW8                 ; nen° MUL
         inc       si                       ; p©eskoáen° znaku "^"

; ------ naáten° druhÇho operandu pro POW

         call      KalkFnc                  ; vòpoáet £rovnà FNC
         jc        KalkPOW9                 ; chyba - nen° dal®° á°slo

; ------ absolutn° hodnota a logaritmus prvn°ho operandu

         mov       ds:[KalkLast],si         ; £schova ukazatele SI
         push      di
         sub       di,ds:[KalNumX]          ; konec prvn°ho operandu
         mov       dl,0                     ; DX <- 0 á°slo je kladnÇ
         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalkPOW2                 ; á°slo nebylo z†pornÇ
         mov       dl,bit0                  ; p©°znak z†pornÇho operandu
KalkPOW2:call      KalXLN                   ; p©irozenò logaritmus prvn°ho operandu
         pop       di
         jc        KalkPOW9                 ; chyba (nap©. je 0)

; ------ vyn†soben° operandñ

         call      KalXMUL
         jc        KalkPOW9                 ; chyba operace

; ------ p©irozenò exponent souáinu

         call      KalXEXP                  ; p©irozenò exponent souáinu
         jc        KalkPOW9                 ; chyba

; ------ n†vrat znamÇnka vòsledku

         or        dl,dl                    ; bylo á°slo z†pornÇ ?
         jz        KalkPOW8                 ; nebylo z†pornÇ
         call      KalXNEG                  ; z†pornÇ á°slo
KalkPOW8:clc                                ; p©°znak operace OK
KalkPOW9:ret

KalkPOW  ENDP

; -----------------------------------------------------------------------------
;        obsluha funkc°
; -----------------------------------------------------------------------------
;˛
KalkFnc  PROC      NEAR

; ------ vypu®tàn° mezer

KalkFnc0:call      KalkSpc                  ; vypu®tàn° mezer

; ------ vypu®tàn° un†rn°ch "+"

         inc       si                       ; p©°padnÇ p©eskoáen° znaku
         cmp       al,"+"                   ; je un†rn° "+" ?
         je        KalkFnc0                 ; un†rn° "+" se ignoruje
         dec       si                       ; n†vrat znaku

; ------ p©°prava k prohled†n° tabulky

         mov       bx,offset KalkFTab       ; tabulka funkc°
         mov       ch,0

; ------ dÇlka slova k porovn†n°

KalkFnc1:mov       cl,cs:[bx]               ; dÇlka slova
         and       cl,bit0+bit1+bit2        ; dÇlka slova (max. 7 znakñ)
         mov       dx,offset KalkNumT       ; adresa obsluhy pro á°slo
         jcxz      KalkFnc4                 ; konec tabulky - naáten° á°sla

; ------ porovn†n° textu slova

         push      bx
         push      cx
         push      si

KalkFnc2:mov       al,ss:[si]               ; znak z textu
         inc       si                       ; zvò®en° ukazatele znakñ
         inc       bx                       ; zvò®en° ukazatele v tabulce
         cmp       al,cs:[bx]               ; porovn†n° s tabulkou
         loope     KalkFnc2                 ; dal®° znak

         mov       dx,cs:[bx+1]             ; p©°padn† adresa skoku

         pop       si
         pop       cx
         pop       bx
         je        KalkFnc4                 ; slovo nalezeno

; ------ p©°prava pro dal®° slovo

KalkFnc3:add       bx,cx                    ; konec slova
         add       bx,3                     ; zaá†tek dal®°ho slova
         jmp       short KalkFnc1           ; test dal®°ho slova

; ------ je®tà mus° n†sledovat á°slice -> AL

KalkFnc4:test      byte ptr cs:[bx],bit6    ; mus° n†sledovat á°slice ?
         jz        KalkFnc6                 ; nen†sleduje á°slice

         push      si
         add       si,cx                    ; p©eskoáen° textu
         mov       al,ss:[si]               ; n†sleduj°c° á°slice
         sub       al,"0"                   ; n†sleduje á°slice ?
         jb        KalkFnc5                 ; nen†sleduje á°slice
         cmp       al,9+1
         cmc
KalkFnc5:pop       si
         jc        KalkFnc3                 ; nen†sleduje á°slice
         inc       si                       ; p©eskoá° se znak á°slice

; ------ slovo nalezeno OK - p©eskoáen° textu slova

KalkFnc6:add       si,cx                    ; p©eskoáen° slova

; ------ naáten° argumentu pro funkci

         test      byte ptr cs:[bx],bit7    ; naá°t† se argument ?
         jnz       KalkFnc7                 ; argument se nenaá°t†

         push      ax
         push      bx                       ; zaá†tek slova
         push      dx                       ; adresa skoku

         call      KalkFnc                  ; naáten° argumentu

         pop       dx
         pop       bx
         pop       ax
         jc        KalkFnc9                 ; chyba

; ------ kontrola rezervy volnÇ pamàti (asi tak pro 4 á°sla)

KalkFnc7:push      ax
         mov       ax,ds:[KalSEnd]          ; maxim†ln° konec pamàti
         sub       ax,ds:[KalNumX]          ; rezerva pro 1 á°slo
         sub       ax,ds:[KalNumX]          ; rezerva pro 2 á°sla
         sub       ax,ds:[KalNumX]          ; rezerva pro 3 á°sla
         sub       ax,ds:[KalNumX]          ; rezerva pro 4 á°sla
         cmp       di,ax                    ; je p©eteáen° ?
         pop       ax
         jbe       KalkFnc8                 ; pamàü je OK
         call      far ptr MemErr           ; chybovÇ hl†®en°
         jmp       short KalkFnc9

; ------ vyvol†n° funkce

KalkFnc8:mov       ds:[KalkLast],si         ; £schova ukazatele SI
         push      bx
         call      DX                       ; vyvol†n° obsluhy funkce
         pop       bx
         jc        KalkFnc9                 ; chyba

; ------ obsluha faktori†lu

         test      byte ptr cs:[bx],bit5    ; n†sleduje faktori†l ?
         jz        KalkFn86                 ; nen†sleduje faktori†l
         call      KalXFAC0                 ; vòpoáet faktori†lu
         jc        KalkFnc9                 ; chyba

; ------ konverze radi†nñ na stupnà

KalkFn86:test      byte ptr cs:[bx],bit4    ; konverze na stupnà ?
         jz        KalkFnc9                 ; nen° konverze na stupnà
         test      byte ptr ds:[KalParm],bit1 ; pouë°vaj° se RAD ?
         jnz       KalkFnc9                 ; pouë°vaj° se RAD
         jmp       KalFDEG                  ; konverze na stupnà

KalkFnc9:ret

KalkFnc  ENDP

; ------ tabulka obsluh funkc°
; p©°znaky:        bit 0 aë bit2: dÇlka 1 aë 7
;                  bit 3: 1=
;                  bit 4: 1=po operaci konverze na stupnà
;                  bit 5: 1=n†sleduje obsluha faktori†lu
;                  bit 6: 1=mus° n†sledovat je®tà znak á°slice -> do AL á°slo
;                  bit 7: 1=nenaá°tat argument
;               0 = konec (je funkce naáten° á°sla)

KalkFTab label     byte
         db        1,'-'
         dw        KalXNEG

         db        1+bit5+bit7,'('
         dw        KalFZAV

         db        3+bit6,'SET'
         dw        KalXSET

         db        2+bit5+bit6+bit7,'RM'
         dw        KalXRCL

         db        3,'EXP'
         dw        KalXEXP

         db        3,'LOG'
         dw        KalXLOG

         db        2,'LN'
         dw        KalXLN

         db        1,'˚'
         dw        KalXSQR

         db        4,'SQRT'
         dw        KalXSQR

         db        3,'SIN'
         dw        KalXSIN

         db        3,'COS'
         dw        KalXCOS

         db        2,'TG'
         dw        KalFTG

         db        4,'COTG'
         dw        KalFCTG

         db        3,'TAN'
         dw        KalFTG

         db        5,'COTAN'
         dw        KalFCTG

         db        6+bit4,'ARCSIN'
         dw        KalXASN

         db        6+bit4,'ARCCOS'
         dw        KalXACN

         db        5+bit4,'ARCTG'
         dw        KalXATG

         db        7+bit4,'ARCCOTG'
         dw        KalXACT

         db        6+bit4,'ARCTAN'
         dw        KalXATG

         db        7+bit4,'ARCOTAN'
         dw        KalXACT

         db        3,'DEG'
         dw        KalFDEG

         db        3,'RAD'
         dw        KalFRAD

         db        3,'INT'
         dw        KalXINT

         db        3,'FRA'
         dw        KalXFRA

         db        3,'ABS'
         dw        KalXABS0

         db        2+bit7,'PI'
         dw        KalXPI

         db        3+bit7,'EUL'
         dw        KalXEUL

         db        4,'IFNE'
         dw        KalXIFNE

         db        3,'IFE'
         dw        KalXIFE

         db        4,'IFGE'
         dw        KalXIFGE

         db        4,'IFLE'
         dw        KalXIFLE

         db        3,'IFG'
         dw        KalXIFG

         db        3,'IFL'
         dw        KalXIFL

         db        6+bit7,'MAXINT'
         dw        KalXMXI

         db        3+bit6+bit7,'REP'
         dw        KalFREP

         db        3+bit7,'RND'
         dw        KalXRND

         db        4+bit7,'COLS'
         dw        KalXCLS

         db        4+bit7,'ROWS'
         dw        KalXRWS

         db        5+bit7,'COUNT'
         dw        KalXCNT

         db        3+bit7,'SUM'
         dw        KalXSUM

         db        3+bit7,'AVG'
         dw        KalXAVG

         db        3+bit7,'MAX'
         dw        KalXMAX

         db        3+bit7,'MIN'
         dw        KalXMIN

         db        3,'HEX'
         dw        KalXHEX

         db        3,'BIN'
         dw        KalXBIN

         db        4+bit7,'CASE'
         dw        KalFCAS

         db        0+bit5+bit7

; -----------------------------------------------------------------------------
;        obsluha funkce TG (ES:DI=naátenò argument)
; -----------------------------------------------------------------------------

KalFTG   PROC      NEAR

; ------ duplikace argumentu

         push      di
         call      KalXDUP                  ; kopie argumentu
         pop       di

; ------ prvn° argument bude SIN

         call      KalXSIN                  ; prvn° argument jako SIN

; ------ druhò argument bude COS

         add       di,ds:[KalNumX]          ; konec druhÇho argumentu
         call      KalXCOS                  ; druhò argument jako COS

; ------ vydàlen° SIN/COS

         call      KalXDIV                  ; vydàlen° SIN/COS
         ret

KalFTG   ENDP

; -----------------------------------------------------------------------------
;        obsluha funkce COTG (ES:DI=naátenò argument)
; -----------------------------------------------------------------------------

KalFCTG  PROC      NEAR

; ------ duplikace argumentu

         push      di
         call      KalXDUP                  ; kopie argumentu
         pop       di

; ------ prvn° argument bude COS

         call      KalXCOS                  ; prvn° argument jako COS

; ------ druhò argument bude SIN

         add       di,ds:[KalNumX]          ; konec druhÇho argumentu
         call      KalXSIN                  ; druhò argument jako SIN

; ------ vydàlen° COS/SIN

         call      KalXDIV                  ; vydàlen° COS/SIN
         ret

KalFCTG  ENDP

; -----------------------------------------------------------------------------
;        obsluha funkce DEG (ES:DI=naátenò argument)
; -----------------------------------------------------------------------------

KalFDEG  PROC      NEAR

; ------ vytvo©en° á°sla "180"

         mov       bx,di                    ; BX <- zaá†tek á°sla
         call      KalXNUL                  ; vynulov†n° á°sla
         add       bx,ds:[KalNumD]          ; adresa celÇ á†sti á°sla
         mov       byte ptr es:[bx],180     ; nastaven° "180"

; ------ vyn†soben° á°sla *180

         call      KalXMUL                  ; vyn†soben° á°slem 180

; ------ vytvo©en° á°sla PI

         call      KalXPI                   ; naáten° á°sla PI

; ------ vydàlen° á°sla á°slem PI

         call      KalXDIV                  ; vydàlen° á°slem PI
         ret

KalFDEG  ENDP

; -----------------------------------------------------------------------------
;        obsluha funkce RAD (ES:DI=naátenò argument)
; -----------------------------------------------------------------------------

KalFRAD  PROC      NEAR

; ------ vytvo©en° á°sla PI

         call      KalXPI                   ; naáten° á°sla PI

; ------ vyn†soben° á°sla *PI

         call      KalXMUL                  ; vyn†soben° á°slem PI

; ------ vytvo©en° á°sla 180

         mov       bx,di                    ; BX <- zaá†tek á°sla
         call      KalXNUL                  ; vynulov†n° á°sla
         add       bx,ds:[KalNumD]          ; adresa celÇ á†sti á°sla
         mov       byte ptr es:[bx],180     ; nastaven° "180"

; ------ vydàlen° á°sla á°slem 180

         call      KalXDIV                  ; vydàlen° á°slem 180
         ret

KalFRAD  ENDP

; -----------------------------------------------------------------------------
;        RND: n†hodnÇ á°slo
; -----------------------------------------------------------------------------

KalXRND  PROC      NEAR

         call      KalXNUL                  ; uloëen° á°sla "0"

         push      ax
         push      cx
         push      di

         sub       di,ds:[KalNumX]          ; zaá†tek á°sla
         mov       cx,ds:[KalNumDW]         ; poáet slov desetinnÇ á†sti
KalXRND2:call      far ptr Random           ; vygenerov†n° n†hodnÇho á°sla
         cld
         stosw                              ; uloëen° slova
         loop      KalXRND2

         pop       di
         pop       cx
         pop       ax
         clc
         ret

KalXRND  ENDP

; -----------------------------------------------------------------------------
;        COLS: poáet sloupcñ bloku tabulky
; -----------------------------------------------------------------------------

KalXCLS  PROC      NEAR

; ------ inicializace á°sla na "0"

         call      KalXNUL                  ; uloëen° á°sla "0"
         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXCLS9                 ; nen° tabulkovò kalkul†tor

; ------ £schova registrñ

         push      ax
         push      di

; ------ p©°prava blokovÇ operace

         call      KalBlok                  ; p©°prava blokovÇ operace

; ------ poáet sloupcñ bloku

         mov       ax,ds:[TBBlokCE]         ; sloupec konce tabulky
         sub       ax,ds:[TBBlokCB]         ; ®°©ka tabulky - 1
         inc       ax                       ; oprava

; ------ nastaven° á°sla

         sub       di,ds:[KalNumN]          ; zaá†tek celÇho á°sla
         mov       es:[di],ax               ; navr†cenò vòsledek operace

; ------ ukonáen° operace s blokem

         call      far ptr TDIniBlk         ; ukonáen° operace s blokem

; ------ n†vrat registrñ

         pop       di
         pop       ax
KalXCLS9:clc                                ; p©°znak operace OK
         ret

KalXCLS  ENDP

; -----------------------------------------------------------------------------
;        ROWS: poáet ©†dkñ bloku tabulky
; -----------------------------------------------------------------------------

KalXRWS  PROC      NEAR

; ------ inicializace á°sla na "0"

         call      KalXNUL                  ; uloëen° á°sla "0"
         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXRWS9                 ; nen° tabulkovò kalkul†tor

; ------ £schova registrñ

         push      ax
         push      cx
         push      di

; ------ p©°prava blokovÇ operace

         call      KalBlok                  ; p©°prava blokovÇ operace

; ------ poáet ©†dkñ bloku

         mov       ax,ds:[TBBlokRE]         ; ©†dek konce tabulky
         sub       ax,ds:[TBBlokRB]         ; vò®ka tabulky - 1
         mov       cl,TBLRotR               ; rotace pro p©evod ©†dkñ
         shr       ax,cl                    ; p©evod na poáet ©†dkñ
         inc       ax                       ; oprava

; ------ nastaven° á°sla

         sub       di,ds:[KalNumN]          ; zaá†tek celÇho á°sla
         mov       es:[di],ax               ; navr†cenò vòsledek operace

; ------ ukonáen° operace s blokem

         call      far ptr TDIniBlk         ; ukonáen° operace s blokem

; ------ n†vrat registrñ

         pop       di
         pop       cx
         pop       ax
KalXRWS9:clc                                ; p©°znak operace OK
         ret

KalXRWS  ENDP

; -----------------------------------------------------------------------------
;        COUNT: poáet bunàk v bloku tabulky
; -----------------------------------------------------------------------------

KalXCNT  PROC      NEAR

; ------ inicializace á°sla na "0"

         call      KalXNUL                  ; uloëen° á°sla "0"
         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXCNT9                 ; nen° tabulkovò kalkul†tor

; ------ £schova registrñ

         push      ax

; ------ p©°prava blokovÇ operace

         call      KalBlok                  ; p©°prava blokovÇ operace

; ------ nalezen° dal®° bu§ky

KalXCNT2:call      KalGetBn                 ; nalezen° dal®°ho á°sla
         jc        KalXCNT8                 ; nen° dal®° bu§ka

; ------ zvò®en° á°taáe bunàk

         sub       di,ds:[KalNumX]          ; zru®en° á°sla z bufferu
         push      di
         sub       di,ds:[KalNumN]          ; zaá†tek celÇho á°sla
         inc       word ptr es:[di]         ; zvò®en° á°taáe
         pop       di
         jmp       short KalXCNT2           ; hled†n° dal®°ho á°sla

; ------ ukonáen° operace s blokem

KalXCNT8:call      far ptr TDIniBlk         ; ukonáen° operace s blokem

; ------ n†vrat registrñ

         pop       ax
KalXCNT9:clc                                ; p©°znak operace OK
         ret

KalXCNT  ENDP

; -----------------------------------------------------------------------------
;        AVG: aritmetickò prñmàr bloku tabulky
; -----------------------------------------------------------------------------

KalXAVG  PROC      NEAR

; ------ souáet bloku tabulky

         call      KalXSUM                  ; souáet bloku tabulky
         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXAVG2                 ; nen° tabulkovò kalkul†tor

; ------ test, zda n†sleduj°c° á°slo je = 0

         push      di
         add       di,ds:[KalNumD]          ; zaá†tek celÇho á°sla
         cmp       word ptr es:[di],0       ; byla nàjak† bu§ka ?
         pop       di
         je        KalXAVG2                 ; nebyla ë†dn† bu§ka

; ------ vydàlen° souátu poátem bunàk

         add       di,ds:[KalNumX]          ; n†sleduj°c° á°slo bude platnÇ
         call      KalXDIV                  ; vydàlen° souátu poátem bunàk
KalXAVG2:ret

KalXAVG  ENDP

; -----------------------------------------------------------------------------
;        SUM: souáet bloku tabulky (n†sleduj°c° á°slo obsahuje poáet bunàk !)
; -----------------------------------------------------------------------------

KalXSUM  PROC      NEAR

; ------ inicializace á°sla na "0"

         call      KalXNUL                  ; uloëen° á°sla "0"
         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXSUM9                 ; nen° tabulkovò kalkul†tor

; ------ £schova registrñ

         push      ax
         push      dx

; ------ p©°prava blokovÇ operace

         xor       dx,dx                    ; DX <- 0 á°taá bunàk
         call      KalBlok                  ; p©°prava blokovÇ operace

; ------ nalezen° dal®° bu§ky

KalXSUM2:call      KalGetBn                 ; nalezen° dal®°ho á°sla
         jc        KalXSUM8                 ; nen° dal®° bu§ka

; ------ p©iáten° bu§ky

         inc       dx                       ; zvò®en° á°taáe bunàk
         call      KalXADD                  ; p©iáten° á°sla
         jmp       short KalXSUM2           ; hled†n° dal®°ho á°sla

; ------ ukonáen° operace s blokem

KalXSUM8:call      far ptr TDIniBlk         ; ukonáen° operace s blokem

; ------ inicializace á°taáe bunàk

         push      di
         call      KalXNUL                  ; uloëen° á°sla "0"
         sub       di,ds:[KalNumN]          ; zaá†tek celÇho á°sla
         mov       es:[di],dx               ; poáet naátenòch bunàk
         pop       di

; ------ n†vrat registrñ

         pop       dx
         pop       ax
KalXSUM9:clc                                ; p©°znak operace OK
         ret

KalXSUM  ENDP

; -----------------------------------------------------------------------------
;        MIN: minim†ln° hodnota v bloku
; -----------------------------------------------------------------------------
;˛
KalXMIN  PROC      NEAR

; ------ inicializace á°sla na "0"

         call      KalXNUL                  ; uloëen° á°sla "0"
         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXMIN9                 ; nen° tabulkovò kalkul†tor

; ------ £schova registrñ

         push      ax
         push      cx

; ------ p©°prava blokovÇ operace

         call      KalBlok                  ; p©°prava blokovÇ operace

; ------ test, zda je alespo§ jedna bu§ka

         call      KalGetBn                 ; nalezen° prvn° bu§ky
         jc        KalXMIN8                 ; nen° ë†dnÇ á°slo
         sub       di,ds:[KalNumX]          ; zru®en° á°sla z bufferu
         jmp       short KalXMIN3           ; uloëen° á°sla

; ------ nalezen° dal®° bu§ky

KalXMIN2:call      KalGetBn                 ; nalezen° dal®°ho á°sla
         jc        KalXMIN8                 ; nen° dal®° bu§ka

; ------ porovn†n°, zda je novÇ á°slo men®°

         call      KalXCMP                  ; porovn†n° á°sel
         jbe       KalXMIN2                 ; á°slo nen° men®°

; ------ uloëen° novÇho á°sla

KalXMIN3:push      si
         mov       si,di                    ; SI <- zaá†tek druhÇho á°sla
         sub       di,ds:[KalNumX]          ; zaá†tek prvn°ho á°sla
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         cld
         rep       movs word ptr es:[di],es:[si] ; uloëen° novÇho á°sla
         pop       si
         jmp       short KalXMIN2           ; hled†n° dal®°ho á°sla

; ------ ukonáen° operace s blokem

KalXMIN8:call      far ptr TDIniBlk         ; ukonáen° operace s blokem

; ------ n†vrat registrñ

         pop       cx
         pop       ax
KalXMIN9:clc                                ; p©°znak operace OK
         ret

KalXMIN  ENDP

; -----------------------------------------------------------------------------
;        MAX: maxim†ln° hodnota v bloku
; -----------------------------------------------------------------------------

KalXMAX  PROC      NEAR

; ------ inicializace á°sla na "0"

         call      KalXNUL                  ; uloëen° á°sla "0"
         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXMAX9                 ; nen° tabulkovò kalkul†tor

; ------ £schova registrñ

         push      ax
         push      cx

; ------ p©°prava blokovÇ operace

         call      KalBlok                  ; p©°prava blokovÇ operace

; ------ test, zda je alespo§ jedna bu§ka

         call      KalGetBn                 ; nalezen° prvn° bu§ky
         jc        KalXMAX8                 ; nen° ë†dnÇ á°slo
         sub       di,ds:[KalNumX]          ; zru®en° á°sla z bufferu
         jmp       short KalXMAX3           ; uloëen° á°sla

; ------ nalezen° dal®° bu§ky

KalXMAX2:call      KalGetBn                 ; nalezen° dal®°ho á°sla
         jc        KalXMAX8                 ; nen° dal®° bu§ka

; ------ porovn†n°, zda je novÇ á°slo vàt®°

         call      KalXCMP                  ; porovn†n° á°sel
         jae       KalXMAX2                 ; á°slo nen° vàt®°

; ------ uloëen° novÇho á°sla

KalXMAX3:push      si
         mov       si,di                    ; SI <- zaá†tek druhÇho á°sla
         sub       di,ds:[KalNumX]          ; zaá†tek prvn°ho á°sla
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         cld
         rep       movs word ptr es:[di],es:[si] ; uloëen° novÇho á°sla
         pop       si
         jmp       short KalXMAX2           ; hled†n° dal®°ho á°sla

; ------ ukonáen° operace s blokem

KalXMAX8:call      far ptr TDIniBlk         ; ukonáen° operace s blokem

; ------ n†vrat registrñ

         pop       cx
         pop       ax
KalXMAX9:clc                                ; p©°znak operace OK
         ret

KalXMAX  ENDP

; -----------------------------------------------------------------------------
;        p©evod á°sla na HEX soustavu (jen cel† á†st á°sla a jen kladnÇ á°slo)
; -----------------------------------------------------------------------------

KalXHEX  PROC      NEAR

         call      KalKInt                  ; korekce p©ed celoá°selnou operac°

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di

; ------ p©°prava k dek¢dov†n° celÇ á†sti á°sla

         mov       cx,ds:[KalNumNW]         ; poáet slov celÇ á†sti
         mov       si,di                    ; SI <- konec á°sla
         sub       si,cx                    ; polovina celÇ á†sti á°sla

; ------ nalezen° konce celÇ á†sti á°sla

KalXHEX2:dec       di                       ; posun ukl†dac° adresy
         dec       si                       ; posun átec° adresy
         cmp       byte ptr es:[si],0       ; je á°slo ?
         jne       KalXHEX3                 ; je á°slo k dek¢dov†n°
         dec       di                       ; posun ukl†dac° adresy
         loop      KalXHEX2                 ; dal®° znak
         mov       byte ptr es:[di],"0"     ; bude jen "0" jako á°slo
         jmp       short KalXHEX5           ; nen° celÇ á°slo

; ------ dek¢dov†n° celÇ á†sti á°sla HEX

KalXHEX3:mov       al,es:[si]               ; á°slo k dek¢dov†n°
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; p©°prava vy®®° tetr†dy
         call      KalXHXNm                 ; uloëen° á°slice HEX

         mov       al,es:[si]               ; á°slo k dek¢dov†n°
         call      KalXHXNm                 ; uloëen° á°slice HEX
         dec       si                       ; posun ukazatele dat
         loop      KalXHEX3                 ; dal®° znak

; ------ n†vrat registrñ

KalXHEX5:pop       di
         pop       si
         pop       cx
         pop       ax
         clc
         ret

KalXHEX  ENDP

; ------ uloëen° znaku HEX

KalXHXNm:and       al,0fh                   ; nië®° tetr†da
         cmp       al,9
         jbe       KalXHNm2
         add       al,7                     ; korekce na HEX znak
KalXHNm2:add       al,"0"                   ; korekce na ASCII znak
         mov       es:[di],al               ; uloëen° znaku
         dec       di                       ; posun ukl†dac° adresy
         ret

; -----------------------------------------------------------------------------
;        p©evod á°sla na BIN soustavu (jen cel† á†st á°sla a jen kladnÇ á°slo)
; -----------------------------------------------------------------------------

KalXBIN  PROC      NEAR

         call      KalKInt                  ; korekce p©ed celoá°selnou operac°

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di

; ------ p©°prava k dek¢dov†n° celÇ á†sti á°sla

         mov       cx,ds:[KalNumN]          ; poáet bajtñ celÇ á†sti
         mov       ax,cx                    ; AL <- poáet bajtñ celÇ á†sti
         mov       si,di                    ; SI <- konec á°sla
         sub       si,cx                    ; SI <- zaá†tek celÇ á†sti á°sla
         shr       cx,1                     ; poáet bajtñ celÇ á†sti / 2
         shr       cx,1                     ; poáet bajtñ celÇ á†sti / 4
         shr       cx,1                     ; poáet bajtñ celÇ á†sti / 8
         add       si,cx                    ; konec á°sla k dek¢dov†n°
         and       ax,7                     ; poáet lichòch pozic
         sub       di,ax                    ; oprava ukl†dac° adresy
         jcxz      KalXBIN2                 ; nen° nic k dek¢dov†n°

; ------ nalezen° konce celÇ á†sti á°sla

KalXBIN1:dec       si                       ; posun átec° adresy
         cmp       byte ptr es:[si],0
         jne       KalXBIN3                 ; je nàjakÇ á°slo
         sub       di,8                     ; posun ukazatele
         loop      KalXBIN1                 ; dal®° znak
KalXBIN2:mov       byte ptr es:[di],"0"     ; bude jen "0" jako á°slo
         jmp       short KalXBIN8           ; nen° celÇ á°slo

; ------ dek¢dov†n° celÇ á†sti á°sla BIN

KalXBIN3:mov       al,es:[si]               ; á°slo k dek¢dov†n°
         mov       bx,8                     ; poáet bitñ k dek¢dov†n°
KalXBIN4:dec       di                       ; posun ukl†dac° adresy
         shl       al,1                     ; je bit nastaven ?
         mov       byte ptr es:[di],"0"     ; bit nen° nastaven
         jnc       KalXBIN5                 ; bit nen° nastaven
         inc       byte ptr es:[di]         ; bit je nastaven
KalXBIN5:dec       bx
         jnz       KalXBIN4

         dec       si                       ; posun ukazatele dat
         loop      KalXBIN3                 ; dal®° znak

; ------ n†vrat registrñ

KalXBIN8:pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         clc
         ret

KalXBIN  ENDP

; -----------------------------------------------------------------------------
;        CASE: vòbàr hodnoty ze seznamu (v z†sobn°ku je á°taá)
; -----------------------------------------------------------------------------

KalFCAS  PROC      NEAR

; ------ test, zda je otev°rac° z†vorka

         call      KalkSPC                  ; vypu®tàn° mezer
         cmp       al,"("                   ; je otev°rac° z†vorka ?
         stc                                ; p©°znak chyby
         jne       KalFCAS9                 ; nen° z†vorka - chyba
         inc       si                       ; p©eskoáen° z†vorky

; ------ naáten° á°taáe

         call      KalkOR                   ; naáten° £rovnà OR
         jc        KalFCAS9                 ; chyba - nen° á°slo

; ------ inicializace á°sla na 0 (nen°-li ë†dnò argument)

         call      KalXNUL                  ; uloëen° á°sla 0

; ------ test, zda bude dal®° argument (v z†sobn°ku je á°taá + minulò argument)

KalFCAS2:call      KalkSPC                  ; vypu®tàn° mezer -> AX=2 znaky
         cmp       al,")"                   ; uzav°rac° z†vorka ?
         jne       KalFCAS3
         inc       si                       ; zru®en° z†vorky
         jmp       short KalFCAS7

KalFCAS3:cmp       al,ds:[OddelPol]         ; bude dal®° argument ?
         jne       KalFCAS7                 ; nen° dal®° argument
         inc       si                       ; p©eskoáen° oddàlovaáe poloëek
         sub       di,ds:[KalNumX]          ; zru®en° minulÇho argumentu

; ------ naáten° dal®°ho argumentu

         call      KalkOR                   ; naáten° £rovnà OR
         jc        KalFCAS9                 ; chyba

; ------ dekrementace á°taáe

         call      KalXXCH                  ; z†màna operandñ
         call      KalXDEC                  ; dekrementace á°taáe
         test      byte ptr es:[di-1],bit7  ; je jië z†pornÇ á°slo ?
         jnz       KalFCAS4                 ; nalezeno poëadovanÇ á°slo
         call      KalXXCH                  ; n†vrat á°taáe
         jmp       short KalFCAS2           ; novò test

; ------ vypu®tàn° zbylòch argumentñ

KalFCAS4:call      KalkSPC                  ; vypu®tàn° mezer -> AX=2 znaky
         cmp       al,")"                   ; uzav°rac° z†vorka ?
         jne       KalFCAS5
         inc       si                       ; zru®en° z†vorky
         jmp       short KalFCAS8

KalFCAS5:cmp       al,ds:[OddelPol]         ; bude dal®° argument ?
         jne       KalFCAS8                 ; nen° dal®° argument
         inc       si                       ; p©eskoáen° oddàlovaáe poloëek
         call      KalkOR                   ; naáten° £rovnà OR
         jc        KalFCAS9                 ; chyba
         sub       di,ds:[KalNumX]          ; zru®en° argumentu
         jmp       short KalFCAS4

; ------ nalezenò argument plat°

KalFCAS7:call      KalXXCH                  ; z†màna operandñ
KalFCAS8:sub       di,ds:[KalNumX]          ; zru®en° á°taáe
         clc                                ; p©°znak operace OK
KalFCAS9:ret

KalFCAS  ENDP

; -----------------------------------------------------------------------------
;        inicializace bloku pro blokovou operaci (niá° registr AX !)
; -----------------------------------------------------------------------------

KalBlok  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      dx

; ------ vypu®tàn° p©°padnÇ otv°rac° z†vorky

         call      KalkSPC                  ; vypu®tàn° mezer
         cmp       al,"("                   ; je otv°rac° z†vorka ?
         jne       KalBLok2                 ; nen° otv°rac° z†vorka
         inc       si                       ; p©eskoáen° z†vorky

; ------ naáten° poá†tku bloku

KalBlok2:call      KalkSPC                  ; vypu®tàn° mezer
         call      KalTbFBn                 ; naáten° á°sla bu§ky poá†tku
         jnc       KalBlok3                 ; á°slo bu§ky je OK
         xor       ax,ax                    ; n†hradn° blok = poá†tek tabulky
KalBlok3:xchg      ax,bx                    ; BX <- bu§ka poá†tku bloku

; ------ vypu®tàn° prvn° oddàlovac° teáky nebo oddàlovaáe ":"

         call      KalkSPC                  ; vypu®tàn° mezer
         cmp       al,","
         je        KalBLK32
         cmp       al,"-"
         je        KalBLK32
         cmp       al,":"
         je        KalBLK32
         cmp       al,"."
         jne       KalBlok4
KalBlk32:inc       si

; ------ vypu®tàn° druhÇ oddàlovac° teáky

KalBlok4:call      KalkSPC                  ; vypu®tàn° mezer
         cmp       al,","
         je        KalBLK42
         cmp       al,"-"
         je        KalBLK42
         cmp       al,":"
         je        KalBLK42
         cmp       al,"."
         jne       KalBlok5
KalBLK42:inc       si

; ------ naáten° konce bloku

KalBlok5:call      KalkSPC                  ; vypu®tàn° mezer
         call      KalTbFBn                 ; naáten° á°sla bu§ky poá†tku
         jnc       KalBlok6                 ; á°slo bu§ky je OK
         mov       ax,TBLMaxC+TBLMaxR*TBLNasR ; n†hradn° blok = konec tabulky
KalBlok6:xchg      ax,dx                    ; DX <- bu§ka konce bloku

; ------ inicializace vyhled†v†n° v bloku

         call      far ptr TInitBlk         ; inicializace vyhled†v†n° v bloku

; ------ n†vrat registrñ

         pop       dx
         pop       bx
         jmp       KalFZAV8                 ; vypu®tàn° koncovÇ z†vorky

KalBlok  ENDP

; -----------------------------------------------------------------------------
;        naáten° dal®° bu§ky bloku do bufferu -> CY=nen° dal®° bu§ka
; -----------------------------------------------------------------------------
; VSTUP: SS:[BP-2] (2) adresa segmentu okna
; -----------------------------------------------------------------------------

KalGetBn PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si

; ------ vyhled†n° dal®° bu§ky

         push      es
         mov       es,ss:[bp-2]             ; adresa okna
         xchg      si,di                    ; SI <- buffer
KalGetB2:call      far ptr TbGetBlk         ; nalezen° dal®° bu§ky
         jc        KalGetB4                 ; nen° dal®° bu§ka
         test      byte ptr es:[di+TBLXParm],bit0 ; je to textov† bu§ka ?
         jnz       KalGetB2                 ; textov† bu§ka je zak†zan†
KalGetB4:xchg      si,di                    ; SI <- bu§ka, DI <- buffer
         pop       es
         jc        KalGetB9                 ; nen° dal®° bu§ka

; ------ p©enesen° á°sla do bufferu

         add       si,TblXReal              ; hodnota bu§ky
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         push      ds
         mov       ds,ss:[bp-2]             ; adresa bufferu s á°slem
         cld
         rep       movsw                    ; p©enos á°sla
         pop       ds
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

KalGetB9:pop       si
         pop       cx
         ret

KalGetBn ENDP

; -----------------------------------------------------------------------------
;        podm°nka IFxx (navr†t° "1" p©i splnàn° podm°nky, jinak vrac° "0")
; -----------------------------------------------------------------------------
; p©°znaky v AL  bit0: 1=men®° ("L"), bit1: 1=rovno ("E"), bit 2: 1=vàt®° ("G")
; -----------------------------------------------------------------------------

KalXIF   PROC      NEAR

KalXIFE: push      ax
         mov       al,bit1                  ; rovno
         jmp       short KalXIF1

KalXIFNE:push      ax
         mov       al,bit0+bit2             ; men®° nebo vàt®° (=nerovno)
         jmp       short KalXIF1

KalXIFG: push      ax
         mov       al,bit2                  ; vàt®°
         jmp       short KalXIF1

KalXIFL: push      ax
         mov       al,bit0                  ; men®°
         jmp       short KalXIF1

KalXIFGE:push      ax
         mov       al,bit1+bit2             ; rovno nebo vàt®°
         jmp       short KalXIF1

KalXIFLE:push      ax
         mov       al,bit0+bit1             ; men®° nebo rovno

; ------ porovn†n° á°sla s nulou

KalXIF1: call      KalXNUL                  ; uloëen° á°sla "0" do z†sobn°ku
         call      KalXCMP                  ; porovn†n° á°sla s nulou

; ------ vynulov†n° á°sla v z†sobn°ku

         pushf
         sub       di,ds:[KalNumX]          ; zru®en° á°sla
         call      KalXNUL                  ; uloëen° á°sla "0" do z†sobn°ku
         popf

; ------ vyhodnocen° vòsledku porovn†n°

         ja        KalXIF2                  ; á°slo je kladnÇ
         jb        KalXIF4                  ; á°slo je z†pornÇ
         test      al,bit1                  ; povolena nula ?
         jmp       short KalXIF6
KalXIF2: test      al,bit2                  ; povoleno kladnÇ á°slo ?
         jmp       short KalXIF6
KalXIF4: test      al,bit0                  ; povoleno z†pornÇ á°slo ?
KalXIF6: jz        KalXIF8                  ; podm°nka nesplnàna

; ------ nastaven° á°sla na "1", je-li podm°nka splnàna

KalXIF7: push      di
         sub       di,ds:[KalNumN]          ; zaá†tek celÇho á°sla
         inc       byte ptr es:[di]         ; nastaven° á°sla na "1"
         pop       di

; ------ n†vrat registrñ

KalXIF8: pop       ax
         clc                                ; p©°znak operace OK
         ret

KalXIF   ENDP

; -----------------------------------------------------------------------------
;        obsluha z†vorek
; -----------------------------------------------------------------------------

KalFZAV  PROC      NEAR

; ------ naáten° vnit©ku z†vorky

         call      KalkOR                   ; naáten° £rovnà OR
         jc        KalFZAV9                 ; chyba - nen° á°slo

; ------ test, zda n†sleduje prav† z†vorka ")" (sk†áe se sem odjinud !)

KalFZAV8:call      KalkSPC                  ; vypu®tàn° mezer -> AX=2 znaky
         cmp       al,")"                   ; n†sleduje á°slo ")" ?
         stc                                ; p©°znak chyby
         jne       KalFZAV9                 ; nen†sleduje - to je chyba
         inc       si                       ; p©eskoáen° znaku ")"
         clc                                ; p©°znak operace OK
KalFZAV9:ret

KalFZAV  ENDP

; -----------------------------------------------------------------------------
;        obsluha opakov†n° vòpoátu, AL=á°slo pamàti
; -----------------------------------------------------------------------------

KalFREP  PROC      NEAR

; ------ naáten° obsahu pamàti jako á°taá, p©°prava parametrñ

         call      KalXRCL                  ; naáten° obsahu pamàti AL
         call      KalXDEC                  ; p©ednastaven° á°taáe
         call      KalXNUL                  ; vytvo©en° á°sla 0
         call      KalXSET                  ; nastaven° pamàti á°slo AL
         sub       di,ds:[KalNumX]          ; zru®en° á°sla
         mov       bx,si                    ; BX <- adresa poá†tku parametru

; ------ zvò®en° obsahu pamàti AL

KalFREP2:call      KalXRCL                  ; naáten° obsahu pamàti AL
         call      KalXINC                  ; inkrementace pamàti AL
         call      KalXSET                  ; nastaven° á°sla do pamàti AL
         sub       di,ds:[KalNumX]          ; zru®en° á°sla

; ------ naáten° opakovanÇho parametru (AL=á°slo pamàti, BX=zaá†tek parametrñ)

         mov       si,bx                    ; SI <- n†vrat poá†tku
         push      ax
         push      bx
         call      KalkFnc                  ; naáten° parametru
         pop       bx
         pop       ax
         jc        KalFREP9                 ; chyba nebo p©eru®en° operace
         sub       di,ds:[KalNumX]          ; zru®en° argumentu

; ------ test p©eru®en° operace

         call      far ptr TestBEsc         ; test p©eru®en° operace
         jc        KalFREP9                 ; je p©eru®en° operace

; ------ dekrementace á°taáe

         call      KalXDEC                  ; dekrementace á°taáe
         test      byte ptr es:[di-1],bit7  ; je á°taá jië = 0 ?
         jns       KalFREP2                 ; á°taá je®tà nen° = 0

; ------ p©enesen° argumentu na m°sto á°taáe

         push      si
         mov       si,di
         sub       di,ds:[KalNumX]
         mov       cx,ds:[KalNumXW]
         cld
         rep       movs word ptr es:[di],es:[si]
         pop       si
         clc

KalFREP9:ret

KalFREP  ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla
; -----------------------------------------------------------------------------

KalkNumF PROC      FAR

         call      KalkNum
         ret

KalkNumF ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla bu§ky ze z†sobn°ku
; -----------------------------------------------------------------------------

KalTbFBn PROC      NEAR

         push      es
         push      ss
         pop       es                       ; ES <- segment bufferu s textem
         call      far ptr ETblFBn          ; naáten° á°sla bu§ky do AX
         pop       es
         ret

KalTbFBn ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla (se znamÇnkem) (mus° bòt zaji®tàno volnÇ m°sto)
; -----------------------------------------------------------------------------
; VSTUP: SS:SI=ukazatel ASCIIZ textu k rozboru
;        ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: CY=nen° á°slo
;         ES:DI=zvò®enò ukazatel vrcholu z†sobn°ku á°sel (pokud je á°slo)
;         SS:SI=novò ukazatel ASCIIZ textu k rozboru
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) adresa zaá†tku á°sla
;                   SS:[BP-4] (2) á°seln† soustava
;                   SS:[BP-5] (1)
;                   SS:[BP-6] (1) bit 0: 1=byla nàjak† á°slice
;                                 bit 1: 1=á°slo je z†pornÇ
;                   SS:[BP-6-KalNumD-2] (KalNumD+2) vzorek desetin
; -----------------------------------------------------------------------------
;˛
; ------ naáten° obsahu bu§ky pro kalkul†tor

KalkNumT PROC      NEAR

         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalkNum                  ; nen° tabulkovò kalkul†tor
         cmp       byte ptr ss:[si],"A"     ; je to p°smeno ?
         jb        KalkNum                  ; nen° p°smeno
         cmp       byte ptr ss:[si],"Z"
         ja        KalkNum                  ; nen° p°smeno

         push      ax
         call      KalTbFBn                 ; naáten° á°sla bu§ky
         call      far ptr ETblFGB          ; naáten° hodnoty bu§ky AX
         pop       ax
         clc                                ; p©°znak operace OK
         ret

KalkNumT ENDP

KalkNum  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,6+2
         mov       cx,ds:[KalNumD]          ; CX <- poáet bajtñ desetinnÇ á†sti
         sub       sp,cx                    ; vzorek pro dek¢dov†n° desetin
         mov       ss:[bp-2],di             ; adresa zaá†tku á°sla
         mov       ax,ds:[KalkZakl]         ; á°selnò z†klad
         mov       ss:[bp-4],ax             ; á°selnò z†klad
         mov       byte ptr ss:[bp-6],0     ; parametry

; ------ vynulov†n° bufferu pro á°slo

         call      KalXNUL                  ; vynulov†n° a p©°prava bufferu

; ------ zmàna á°selnÇ soustavy, zmàna znamÇnka

KalkNm15:call      KalkSPC                  ; vypu®tàn° mezer
         mov       bx,256
         cmp       al,'"'
         je        KalkNm16
         mov       bx,10
         cmp       al,"#"
         je        KalkNm16
         mov       bl,16
         cmp       al,"$"
         je        KalkNm16
         mov       bl,2
         cmp       al,"%"
         je        KalkNm16
         mov       bl,8
         cmp       al,"@"
         je        KalkNm16
         cmp       al,"+"
         je        KalkNm17                 ; znamÇnko "+" se ignoruje
         cmp       al,"-"
         jne       KalkNm18
         xor       byte ptr ss:[bp-6],bit1  ; zmàna znamÇnka á°sla
         jmp       short KalkNm17

KalkNm16:mov       ss:[bp-4],bx             ; á°selnò z†klad
KalkNm17:inc       si                       ; vypu®tàn° prefixu
         cmp       al,'"'
         jne       KalkNm15

; ------ inicializace vzorku desetin na á°slo "1" (CX=dÇlka desetin v bajtech)

KalkNm18:mov       di,sp                    ; DI <- z†sobn°k
         push      es
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         xor       ax,ax                    ; AX <- 0
         shr       cx,1                     ; CX <- poáet slov desetinnÇ á†sti
         cld
         rep       stosw                    ; vymaz†n° á°sla
         inc       ax                       ; AX <- 1
         stosw                              ; bude to á°slo "1"
         pop       es

; ------ test, zda budou desetiny

KalkNum2:cmp       byte ptr ss:[bp-4],0
         je        KalkNm22                 ; je textov† soustava

KalkNm21:mov       al,ss:[si]               ; p©ipravenò znak
         or        al,al
         jz        KalkNm22
         inc       si
         cmp       al,ds:[OddelRad]         ; oddàlovaá ©†dñ
         je        KalkNm21                 ; oddàlovaá ©†dñ se vypou®t°
         dec       si

         cmp       al,ds:[OddelDes]         ; desetiny ?
         je        KalkNum4                 ; jsou desetiny
;         cmp       al,"."                   ; budou desetiny ?
;         je        KalkNum4                 ; budou desetiny OK
;         cmp       al,","
;         je        KalkNum4                 ; je desetinn† á†rka

; ------ naáten° á°slice celÇ á†sti

KalkNm22:call      KalkNm                   ; naáten° á°slice
         jc        KalkNum8                 ; nen° dal®° platnò znak
         or        byte ptr ss:[bp-6],bit0  ; p©°znak, ëe je á°slice
         xchg      ax,bx                    ; BX <- á°slo k p©iáten° (=p©enos)

; ------ vyn†soben° celÇ á†sti á°sla á°selnòm z†kladem a p©iáten° á°slice

         cld
         push      si
         mov       si,ss:[bp-4]             ; SI <- á°selnò z†klad á°sla
         mov       di,ss:[bp-2]             ; DI <- adresa zaá†tku á°sla
         add       di,ds:[KalNumD]          ; DI <- zaá†tek celoá°selnÇ á†sti
         mov       cx,ds:[KalNumNW]         ; CX <- poáet slov celÇ á†sti
KalkNum3:mov       ax,es:[di]               ; AX <- slovo á°sla
         mul       si                       ; vyn†soben° á°sla z†kladem
         add       ax,bx                    ; p©iáten° p©ede®lÇho p©enosu
         adc       dx,0
         mov       bx,dx                    ; BX <- p©enos pro dal®° pozici
         stosw                              ; uloëen° slova á°sla
         loop      KalkNum3                 ; dal®° slovo á°sla
         pop       si
         jmp       short KalkNum2           ; dal®° á°slice

; ------ vypu®tàn° desetinnÇ á†rky (p©°padnà i "-" za ",")

KalkNum4:cmp       byte ptr ss:[si+1],"-"   ; bude á†rka k vypu®tàn° ?
         jne       KalkNum5                 ; nebude á†rka "-"
         inc       si                       ; vypust° se á†rka "-"
KalkNum5:inc       si                       ; vypu®tàn° desetinnÇ á†rky
         or        byte ptr ss:[bp-6],bit0  ; p©°znak, ëe je á°slice

; ------ posun vzorku desetin o ©†d dolñ

KalkNum6:mov       bx,ss:[bp-4]             ; BX <- á°selnò z†klad á°sla
         lea       di,[bp-6]                ; DI <- konec á°sla vzorku
         mov       cx,ds:[KalNumDW]         ; CX <- poáet slov desetinnÇ á†sti
         inc       cx                       ; o 1 slovo je tam nav°c
         xor       dx,dx                    ; DX <- 0 nen° p©enos dolñ
KalkNum7:dec       di
         dec       di                       ; DI <- posun adresy v bufferu
         mov       ax,ss:[di]               ; AX <- slovo vzorku desetin
         div       bx                       ; vydàlen° á°selnòm z†kladem
         mov       ss:[di],ax               ; uloëen° novÇho vzorku
         loop      KalkNum7                 ; dal®° slovo vzorku

; ------ naáten° dal®° á°slice desetinnÇ á†sti -> BX

         call      KalkNm                   ; naáten° dal®° á°slice
         jc        KalkNum8                 ; nen° dal®° á°slice
         xchg      ax,bx                    ; BX <- nov† á°slice

; ------ uloëen° desetinnÇ á†sti á°slice

         mov       ax,sp                    ; AX <- zaá†tek vzorku desetin

         cld
         push      si
         push      bp

         xchg      ax,si                    ; SI <- zaá†tek vzorku desetin
         mov       cx,ds:[KalNumDW]         ; poáet slov desetinnÇ á†sti á°sla
         mov       di,ss:[bp-2]             ; DI <- adresa zaá†tku á°sla
         xor       bp,bp                    ; BP <- 0 nen° p©enos
KalkNm72:lods      word ptr ss:[si]         ; naáten° slova vzorku desetin
         mul       bx                       ; vyn†soben° novou á°slic°
         add       ax,bp                    ; p©iáten° starÇho p©enosu
         adc       dx,0
         add       es:[di],ax               ; p©iáten° ke st©adaái
         adc       dx,0                     ; p©enos HIGH
         mov       bp,dx                    ; BP <- novò p©enos
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      KalkNm72                 ; dal®° á°slice

         pop       bp
         pop       si
         jmp       short KalkNum6           ; dal®° á°slice

; ------ test, zda je á°slo platnÇ

KalkNum8:mov       di,ss:[bp-2]             ; DI <- adresa zaá†tku á°sla
         test      byte ptr ss:[bp-6],bit0  ; byla nàjak† á°slice ?
         stc                                ; p©°znak chyby
         jz        KalkNum9                 ; nebyla á°slice - chyba
         add       di,ds:[KalNumX]          ; adresa konce á°sla

; ------ oprava znamÇnka á°sla

         test      byte ptr ss:[bp-6],bit1  ; je á°slo z†pornÇ ?
         jz        KalkNm82                 ; á°slo nen° z†pornÇ
         call      KalXNEG                  ; negace á°sla

; ------ n†vrat registrñ

KalkNm82:clc                                ; p©°znak operace OK
KalkNum9:mov       sp,bp
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KalkNum  ENDP

; -----------------------------------------------------------------------------
;        naáten° á°slice z SS:SI -> AX (CY=nen° dal®° platn† á°slice)
; -----------------------------------------------------------------------------
; VSTUP: SS:[BP-4] (2) á°seln† soustava
; -----------------------------------------------------------------------------

KalkNm   PROC      NEAR

; ------ naáten° dal®°ho znaku

         cld
KalkNm1: lods      byte ptr ss:[si]         ; naáten° dal®°ho znaku

; ------ naáten° znaku pro textovou soustavu

         cmp       byte ptr ss:[bp-4],0     ; je to textov† soustava ?
         jne       KalkNm2
         cmp       al,0                     ; konec textu ?
         je        KalkNm8                  ; konec textu
         cmp       al,'"'
         je        KalkNm8A                 ; konec textu
         clc
         jmp       short KalkNm9

; ------ oddàlovaá ©†dñ se ignoruje

KalkNm2: cmp       al,ds:[OddelRad]         ; oddàlovaá ©†dñ
         je        KalkNm1                  ; oddàlovaá ©†dñ se ignoruje

; ------ konverze na á°slo

         sub       al,"0"                   ; konverze na á°slo
         jc        KalkNm8                  ; nen° platn† á°slice

; ------ test, zda je á°slice

         cmp       al,9                     ; je to á°slice ?
         jbe       KalkNm4                  ; je to á°slice - OK

; ------ korekce pro p°smeno

         sub       al,7                     ; korekce pro p°smeno
         cmp       al,10                    ; je to platnò znak ?
         jb        KalkNm8                  ; nen° to platnò znak

; ------ kontrola, zda je povolenò znak

KalkNm4: cmp       al,ss:[bp-4]             ; je to povolenò znak ?
         cmc
         jnc       KalkNm9                  ; je to platnò znak OK

; ------ nen° platnò znak

KalkNm8: dec       si                       ; n†vrat ukazatele textu
KalkNm8A:stc                                ; p©°znak neplatnÇho znaku
KalkNm9: mov       ah,0                     ; AX <- á°slo
         ret

KalkNm   ENDP

; -----------------------------------------------------------------------------
;        proveden° operace OR
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (2 á°sla)
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel sn°ëenò o 2. á°slo
; -----------------------------------------------------------------------------

KalXOR   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      ds

; ------ p©°prava registrñ

         cld
         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ na á°slo
         sub       di,cx                    ; DI <- zaá†tek 2. á°sla
         mov       si,di                    ; SI <- zaá†tek 2. á°sla
         sub       di,cx                    ; DI <- zaá†tek 1. á°sla
         shr       cx,1                     ; CX <- poáet slov na á°slo
         push      es
         pop       ds                       ; DS <- segment z†sobn°ku á°sel

; ------ proveden° operace OR

KalXOR2: lodsw                              ; naáten° slova 2. á°sla
         or        ds:[di],ax               ; operace OR
         inc       di
         inc       di                       ; zvò®en° ukazatele v 1. á°sle
         loop      KalXOR2                  ; dal®° slovo v á°sle

; ------ n†vrat registrñ

         pop       ds
         pop       si
         pop       cx
         pop       ax
;         clc
         ret

KalXOR   ENDP

; -----------------------------------------------------------------------------
;        proveden° operace XOR
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (2 á°sla)
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel sn°ëenò o 2. á°slo
; -----------------------------------------------------------------------------

KalXXOR  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      ds

; ------ p©°prava registrñ

         cld
         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ na á°slo
         sub       di,cx                    ; DI <- zaá†tek 2. á°sla
         mov       si,di                    ; SI <- zaá†tek 2. á°sla
         sub       di,cx                    ; DI <- zaá†tek 1. á°sla
         shr       cx,1                     ; CX <- poáet slov na á°slo
         push      es
         pop       ds                       ; DS <- segment z†sobn°ku á°sel

; ------ proveden° operace XOR

KalXXOR2:lodsw                              ; naáten° slova 2. á°sla
         xor       ds:[di],ax               ; operace XOR
         inc       di
         inc       di                       ; zvò®en° ukazatele v 1. á°sle
         loop      KalXXOR2                 ; dal®° slovo v á°sle

; ------ n†vrat registrñ

         pop       ds
         pop       si
         pop       cx
         pop       ax
;         clc
         ret

KalXXOR  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace AND
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (2 á°sla)
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel sn°ëenò o 2. á°slo
; -----------------------------------------------------------------------------

KalXAND  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      ds

; ------ p©°prava registrñ

         cld
         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ na á°slo
         sub       di,cx                    ; DI <- zaá†tek 2. á°sla
         mov       si,di                    ; SI <- zaá†tek 2. á°sla
         sub       di,cx                    ; DI <- zaá†tek 1. á°sla
         shr       cx,1                     ; CX <- poáet slov na á°slo
         push      es
         pop       ds                       ; DS <- segment z†sobn°ku á°sel

; ------ proveden° operace AND

KalXAND2:lodsw                              ; naáten° slova 2. á°sla
         and       ds:[di],ax               ; operace AND
         inc       di
         inc       di                       ; zvò®en° ukazatele v 1. á°sle
         loop      KalXAND2                 ; dal®° slovo v á°sle

; ------ n†vrat registrñ

         pop       ds
         pop       si
         pop       cx
         pop       ax
;         clc
         ret

KalXAND  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace NOT
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; -----------------------------------------------------------------------------

KalXNOT  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      ds

; ------ p©°prava registrñ

         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ na á°slo
         sub       di,cx                    ; DI <- zaá†tek á°sla
         shr       cx,1                     ; CX <- poáet slov na á°slo
         push      es
         pop       ds                       ; DS <- segment z†sobn°ku á°sel
KalXNOT2:not       word ptr ds:[di]         ; operace NOT
         inc       di
         inc       di                       ; zvò®en° ukazatele v 1. á°sle
         loop      KalXNOT2                 ; dal®° slovo v á°sle

; ------ n†vrat registrñ

         pop       ds
         pop       cx
         clc
         ret

KalXNOT  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace CMP - porovn†n° á°sel (neniá° ë†dnÇ z á°sel)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (2 á°sla)
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel sn°ëenò o 2. á°slo
;         CY,NZ=prvn° á°slo men®° neë druhÇ
;         NC,ZY=prvn° á°slo shodnÇ s druhòm
;         NC,NZ=prvn° á°slo vàt®° neë druhÇ
; -----------------------------------------------------------------------------

KalXCMP  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      ds

; ------ p©°prava registrñ

         cld
         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ na á°slo
         sub       di,cx                    ; DI <- zaá†tek 2. á°sla
         mov       si,di                    ; SI <- zaá†tek 2. á°sla
         sub       si,cx                    ; SI <- zaá†tek 1. á°sla
         shr       cx,1                     ; CX <- poáet slov na á°slo
         push      es
         pop       ds                       ; DS <- segment z†sobn°ku á°sel
         xor       dx,dx                    ; DX <- st©adaá pro test nuly
;         clc                                ; nen° p©enos

; ------ proveden° operace CMP (odeáten° se dàl† aë po INC DI kvñli p©°znakñm)

         push      di                       ; zaá†tek 2. á°sla
KalXCMP2:lodsw                              ; naáten° slova 1. á°sla
         sbb       ax,ds:[di]               ; odeáten° slova 2. á°sla
         inc       di
         inc       di                       ; zvò®en° ukazatele v 2. á°sle

         pushf
         add       dx,ax                    ; p©iáten° ke st©adaái nuly
         popf

         loop      KalXCMP2                 ; dal®° slovo v á°sle
         pop       di                       ; zaá†tek 2. á°sla

; ------ vyhodnocen° vòsledku porovn†n°

         or        ax,ax                    ; je 1. á°slo men®° neë 2. ?
         stc                                ; p©°znaky CY, NZ
         js        KalXCMP4                 ; prvn° á°slo je men®° neë 2.
         or        dx,dx                    ; nastaven° p©°znakñ ZF a NC

; ------ n†vrat registrñ

KalXCMP4:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

KalXCMP  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace ADD
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (2 á°sla)
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel sn°ëenò o 2. á°slo
;         CY=chyba p©eteáen°
; -----------------------------------------------------------------------------

;KalFADD  PROC      FAR
;
;         call      KalXADD
;         ret
;
;KalFADD  ENDP

KalXADD  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      ds

; ------ p©°prava registrñ

         cld
         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ na á°slo
         sub       di,cx                    ; DI <- zaá†tek 2. á°sla
         mov       si,di                    ; SI <- zaá†tek 2. á°sla
         sub       di,cx                    ; DI <- zaá†tek 1. á°sla
         shr       cx,1                     ; CX <- poáet slov na á°slo
         push      es
         pop       ds                       ; DS <- segment z†sobn°ku á°sel
         clc                                ; nen° p©enos

; ------ proveden° operace ADD (p©iáten° se dàl† aë po INC DI kvñli p©°znakñm)

KalXADD2:lodsw                              ; naáten° slova 2. á°sla
         inc       di
         inc       di                       ; zvò®en° ukazatele v 1. á°sle
         adc       ds:[di-2],ax             ; operace ADD
         loop      KalXADD2                 ; dal®° slovo v á°sle

; ------ nastaven° p©°znaku p©eteáen°

         clc                                ; p©°znak - nen° p©eteáen°
         jno       KalXADD4                 ; nen° p©eteáen°
         stc                                ; p©°znak - je p©eteáen°

; ------ n†vrat registrñ

KalXADD4:pop       ds
         pop       si
         pop       cx
         pop       ax
         call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXADD  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace SUB
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (2 á°sla)
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel sn°ëenò o 2. á°slo
; -----------------------------------------------------------------------------

;KalFSUB  PROC      FAR
;
;         call      KalXSUB
;         ret
;
;KalFSUB  ENDP

KalXSUB  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      ds

; ------ p©°prava registrñ

         cld
         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ na á°slo
         sub       di,cx                    ; DI <- zaá†tek 2. á°sla
         mov       si,di                    ; SI <- zaá†tek 2. á°sla
         sub       di,cx                    ; DI <- zaá†tek 1. á°sla
         shr       cx,1                     ; CX <- poáet slov na á°slo
         push      es
         pop       ds                       ; DS <- segment z†sobn°ku á°sel
         clc                                ; nen° p©enos

; ------ proveden° operace SUB (odeáten° se dàl† aë po INC DI kvñli p©°znakñm)

KalXSUB2:lodsw                              ; naáten° slova 2. á°sla
         inc       di
         inc       di                       ; zvò®en° ukazatele v 1. á°sle
         sbb       ds:[di-2],ax             ; operace SUB
         loop      KalXSUB2                 ; dal®° slovo v á°sle

; ------ nastaven° p©°znaku p©eteáen°

         clc                                ; p©°znak - nen° p©eteáen°
         jno       KalXSUB4                 ; nen° p©eteáen°
         stc                                ; p©°znak - je p©eteáen°

; ------ n†vrat registrñ

KalXSUB4:pop       ds
         pop       si
         pop       cx
         pop       ax
         call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXSUB  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace MUL (á°slo 2 p©ev†d° na absolutn° hodnotu)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (2 á°sla)
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel sn°ëenò o 2. á°slo
;         CY=chyba p©eteáen°
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] adresa á°sla 1
;                   SS:[BP-4] adresa á°sla 2
;                   SS:[BP-6] segment á°sla 1 a 2  ƒƒƒƒƒƒƒƒƒƒƒødohromady - áten°
;                   SS:[BP-8] poá†tek nenulovÇ á†sti á°sla 1 ƒŸadresy á°sla 1
;                   SS:[BP-10] dÇlka nenulovÇ á†sti á°sla 1 (slov !)
;                   SS:[BP-12] (2) poáet bajtñ na á°slo
;                   SS:[BP-14] (2) poáet bajtñ na desetinnou á†st á°sla
;                   SS:[BP-15]
;                   SS:[BP-16] (1) bit 0: 1=vòsledek z†pornò
;                   SS:[BP-18] (2) p©eteáen° st©adaáe (mus° bòt posledn° !!!)
;                              (2*KalNumX) st©adaá mezivòsledku
; -----------------------------------------------------------------------------
;˛

;KalFMUL  PROC      FAR
;
;         call      KalXMUL
;         ret
;
;KalFMUL  ENDP

KalXMUL  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava lok†ln°ho bufferu

         sub       sp,18                    ; lok†ln° promànnÇ
         mov       ax,ds:[KalNumX]          ; AX <- dÇlka á°sla (bajtñ)
         sub       sp,ax
         sub       sp,ax                    ; m°sto pro lok†ln° buffer

; ------ absolutn° hodnota á°sla 2

         mov       byte ptr ss:[bp-16],0    ; parametry
         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXML02                 ; á°slo bylo kladnÇ
         xor       byte ptr ss:[bp-16],bit0 ; zmàna znamÇnka vòsledku

; ------ absolutn° hodnota á°sla 1

KalXML02:sub       di,ax                    ; DI <- konec á°sla 1
         mov       ss:[bp-4],di             ; adresa á°sla 2
         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXML03                 ; á°slo bylo kladnÇ
         xor       byte ptr ss:[bp-16],bit0 ; zmàna znamÇnka vòsledku

; ------ p©°prava lok†ln°ch promànnòch

KalXML03:sub       di,ax                    ; posun ukazatele á°sel
         mov       ss:[bp-2],di             ; adresa á°sla 1
         mov       ss:[bp-6],es             ; segment á°sla 1 a 2
         mov       ss:[bp-12],ax            ; poáet bajtñ na á°slo
         xchg      ax,cx                    ; CX <- poáet bajtñ na á°slo
         mov       ax,ds:[KalNumD]          ; poáet bajtñ desetinnÇ á†sti á°sla
         mov       ss:[bp-14],ax            ; poáet bajtñ desetinnÇ á†sti á°sla

; ------ vynulov†n° st©adaáe

         mov       di,sp                    ; DI <- zaá†tek st©adaáe
         push      es
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         call      KalXNUL                  ; vynulov†n° st©adaáe LOW
         call      KalXNUL                  ; vynulov†n° st©adaáe HIGH
         pop       es

; ------ nalezen° zaá†tku nenulovÇ á†sti á°sla 1 (CX=poáet bajtñ na á°slo)

         shr       cx,1                     ; CX <- poáet slov na á°slo
         mov       di,ss:[bp-2]             ; DI <- adresa á°sla 1
         xor       ax,ax                    ; AX <- porovn†vanÇ slovo
         cld                                ; smàr nahoru
         repe      scasw                    ; nalezen° zaá†tku nenulovÇ á†sti
         jne       KalXMUL1                 ; zaá†tek nalezen OK
         jmp       KalXMUL9                 ; á°slo 1 je celÇ "0" (je NC)

KalXMUL1:dec       di
         dec       di                       ; n†vrat zaá†tku á°sla 1
         inc       cx                       ; n†vrat CX
         mov       ss:[bp-8],di             ; adresa zaá†tku á°sla 1

; ------ nalezen° konce nenulovÇ á†sti á°sla 1 (CX=poáet slov do konce)

         mov       di,ss:[bp-4]             ; DI <- adresa á°sla 2 (=konec 1)
         dec       di
         dec       di                       ; DI <- posledn° slovo á°sla 1
         std                                ; smàr dolñ
         repe      scasw                    ; nalezen° konce nenulovÇ á†sti
         inc       cx                       ; n†vrat CX
         mov       ss:[bp-10],cx            ; dÇlka nenulovÇ á†sti á°sla 1 (slov)

; ------ p©°prava k n†soben° jedn°m slovem n†sobitele

         cld
         mov       cx,ss:[bp-12]            ; CX <- poáet bajtñ na á°slo
         shr       cx,1                     ; CX <- poáet slov na á°slo
KalXMUL2:mov       word ptr ss:[bp-18],0    ; nulov†n° p©eteáen° st©adaáe
         mov       es,ss:[bp-6]             ; ES <- segment á°sla 2
         mov       si,ss:[bp-4]             ; SI <- adresa á°sla 2
         lods      word ptr es:[si]         ; naáten° slova á°sla 2
         mov       ss:[bp-4],si             ; £schova novÇho ukazatele
         or        ax,ax                    ; je slovo = 0 ?
         jz        KalXMUL6                 ; slovo = 0, nic se nen†sob°
         xchg      ax,bx                    ; BX <- n†sobitel

; ------ p©°prava k vyn†soben° n†sobence jedn°m slovem

         mov       di,sp                    ; DI <- st©adaá
         add       di,ss:[bp-12]
         sub       di,cx
         sub       di,cx                    ; DI <- ukl†dac° adresa n†sobku
         les       si,ss:[bp-8]             ; poá†tek nenulovÇ á†sti á°sla 1
         add       di,si                    ; + nenulovò zaá†tek á°sla 1
         sub       di,ss:[bp-2]             ; - zaá†tek á°sla 1 = posunut°

         push      cx
         push      bp

         mov       cx,ss:[bp-10]            ; CX <- dÇlka nenulovÇ á†sti á°sla 1
         xor       bp,bp                    ; BP <- 0 nen° p©enos
KalXMUL3:lods      word ptr es:[si]         ; AX <- slovo n†sobence
         mul       bx                       ; vyn†soben° n†sobitelem
         add       ax,bp                    ; p©iáten° p©enosu
         adc       dx,0
         add       ss:[di],ax               ; p©iáten° ke st©adaái
         adc       dx,0
         mov       bp,dx                    ; BP <- p©enos

KalXMUL4:inc       di
         inc       di
         loop      KalXMUL3                 ; dal®° slovo
         inc       cx                       ; CX <- 1
         add       ss:[di],bp               ; p©enos
         mov       bp,cx                    ; BP <- 1
         jc        KalXMUL4                 ; je p©eteáen°

         pop       bp
         pop       cx

KalXMUL6:loop      KalXMUL2                 ; dal®° slovo

; ------ uloëen° st©adaáe do bufferu á°sla 1

KalXMUL9:mov       si,sp                    ; SI <- st©adaá
         add       si,ss:[bp-14]            ; + desetinn† á†st
         push      ds
         push      ss
         pop       ds                       ; DS <- segment st©adaáe
         mov       di,ss:[bp-2]             ; DI <- adresa bufferu á°sla 1
         mov       es,ss:[bp-6]             ; ES <- segment á°sla 1
         mov       cx,ss:[bp-12]            ; CX <- poáet bajtñ na á°slo
         shr       cx,1                     ; CX <- poáet slov na á°slo
         cld
         rep       movsw                    ; uloëen° st©adaáe do bufferu á°sla
         pop       ds

; ------ test, zda je p©eteáen°

         push      di
         push      es

         push      ss
         pop       es
         mov       di,si
         test      byte ptr es:[di-1],bit7  ; je p©eteáen° ?
         jnz       KalXMulB                 ; je p©eteáen°
         xor       ax,ax                    ; AX <- 0
         mov       cx,ds:[KalNumNW]         ; dÇlka celÇ á†sti
         repe      scasw                    ; test zbytku á°sla

KalXMulB:pop       es
         pop       di
         stc
         jnz       KalXMulA                 ; je p©eteáen°

; ------ test p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        KalXMULA                 ; je p©eru®en° operace

; ------ oprava znamÇnka vòsledku

         test      byte ptr ss:[bp-16],bit0 ; je vòsledek z†pornò ?
         jz        KalXMULA                 ; vòsledek nen° z†pornò
         call      KalXNEG                  ; oprava znamÇnka vòsledku
;         clc

; ------ n†vrat registrñ

KalXMULA:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

         pushf
         sub       di,ds:[KalNumX]          ; posun ukazatele bufferu
         popf

         call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXMUL  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace DIV (á°slo 2 uprav° na absolutn° hodnotu)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (2 á°sla)
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel sn°ëenò o 2. á°slo
;         CY=p©eteáen°
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment k uloëen° vòsledku ƒøpouë°v† se
;                   SS:[BP-4] (2) offset k uloëen° vòsledku  ƒŸspolu !
;                   SS:[BP-6] (2) offset bajtu k uloëen° vòsledku
;                   SS:[BP-7] (1) maska bitu k ukl†d†n° vòsledku
;                   SS:[BP-8] (1) bit 0: 1=vòsledek z†pornò
;                   SS:[BP-10] (2) poáet bajtñ na á°slo
;                   SS:[BP-12] (2) poáet bajtñ na desetinnou á†st á°sla
;                   SS:[BP-14] (2) adresa dàlitele v z†sobn°ku
;                   SS:[BP-16] (2) adresa dàlence v z†sobn°ku
;                   SS:[BP-18] (2) datovò segment
;                   SS:[BP-20] (2) adresa posledn°ho slova dàlitele
;                   SS:[BP-22] (2) adresa posledn°ho slova dàlence
;                              (2*KalNumX) dàlitel
;                              (2*KalNumX) dàlenec
; -----------------------------------------------------------------------------

;KalFDIV  PROC      FAR
;
;         call      KalXDIV
;         ret
;
;KalFDIV  ENDP
;

KalXDIV  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava lok†ln°ho bufferu

         sub       sp,22                    ; lok†ln° promànnÇ
         mov       ax,ds:[KalNumX]          ; AX <- dÇlka á°sla (bajtñ)
         mov       ss:[bp-10],ax            ; poáet bajtñ na á°slo
         sub       sp,ax
         sub       sp,ax
         sub       sp,ax
         sub       sp,ax                    ; m°sto pro lok†ln° buffer
         mov       ss:[bp-18],ds            ; £schova datovÇho segmentu

; ------ absolutn° hodnota á°sla 2

         mov       word ptr ss:[bp-8],0 + bit7*HI ; parametry + maska
         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXDV02                 ; á°slo nebylo z†pornÇ
         xor       byte ptr ss:[bp-8],bit0 ; zmàna znamÇnka vòsledku

; ------ absolutn° hodnota á°sla 1

KalXDV02:sub       di,ax                    ; DI <- konec á°sla 1
         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXDV03                 ; á°slo nebylo z†pornÇ
         xor       byte ptr ss:[bp-8],bit0  ; zmàna znamÇnka vòsledku

; ------ £schova adresy á°sla 1

KalXDV03:sub       di,ax                    ; DI <- zaá†tek á°sla 1
         mov       ss:[bp-4],di             ; offset á°sla 1
         mov       ss:[bp-2],es             ; segment á°sla 1
         dec       ax                       ; AX <- poáet bajtñ á°sla - 1
         mov       ss:[bp-6],ax             ; offset bajtu k uloëen° vòsledku
         mov       ax,ds:[KalNumD]          ; poáet bajtñ desetinnÇ á†sti á°sla
         mov       ss:[bp-12],ax            ; poáet bajtñ desetinnÇ á†sti á°sla

; ------ vynulov†n° bufferu (màn° natrvalo ES <- SS !!!)

         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       ss:[bp-16],di            ; adresa dàlence v z†sobn°ku
         call      KalXNUL                  ; vynulov†n° dàlence LOW
         call      KalXNUL                  ; vynulov†n° dàlence HIGH
         mov       ax,di                    ; AX <- adresa konce dàlence
         dec       ax
         dec       ax                       ; korekce
         mov       ss:[bp-22],ax            ; adresa posledn°ho slova dàlence
         mov       ss:[bp-14],di            ; adresa dàlitele v z†sobn°ku
         call      KalXNUL                  ; vynulov†n° dàlitele LOW
         call      KalXNUL                  ; vynulov†n° dàlitele HIGH
         dec       di
         dec       di                       ; DI <- posledn° slovo dàlitele
         mov       ss:[bp-20],di            ; adresa posledn°ho slova dàlitele

; ------ uloëen° á°sel do z†sobn°ku

         mov       cx,ss:[bp-10]            ; poáet bajtñ na á°slo
         push      ds
         lds       si,ss:[bp-4]             ; adresa dàlence
         mov       di,ss:[bp-16]            ; adresa dàlence v z†sobn°ku
         add       di,ss:[bp-12]            ; adresa k uloëen° dàlence
         cld
         shr       cx,1                     ; velikost dàlence ve slovech
         push      cx
         rep       movsw                    ; uloëen° dàlence do z†sobn°ku
         pop       cx
         mov       di,ss:[bp-14]            ; adresa dàlitele v z†sobn°ku
         add       di,ss:[bp-10]            ; adresa k uloëen° dàlitele
         rep       movsw                    ; uloëen° dàlitele do z†sobn°ku
         pop       ds

; ------ vynulov†n° st©adaáe vòsledku

         push      es
         les       di,ss:[bp-4]             ; st©adaá vòsledku
         call      KalXNUL                  ; vynulov†n° st©adaáe vòsledku
         pop       es

; ------ rotace dàlitele o bit vpravo (màn° natrvalo DS <- SS !!!)

         mov       di,ss:[bp-20]            ; adresa konce dàlitele v z†sobn°ku
         mov       cx,ss:[bp-10]            ; poáet bajtñ na á°slo
         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
         clc                                ; nen° p©enos
KalXDIV1:rcr       word ptr ds:[di],1       ; rotace o 1 bit vpravo
         dec       di
         dec       di                       ; posun adresy
         loop      KalXDIV1                 ; dal®° slovo

; ------ porovn†n° dàlence s dàlitelem

KalXDIV2:mov       cx,ss:[bp-10]            ; poáet bajtñ na á°slo
         mov       si,ss:[bp-22]            ; SI <- adresa konce dàlence
         mov       di,ss:[bp-20]            ; DI <- adresa konce dàlitele
         std                                ; smàr dolñ
         repe      cmpsw                    ; porovn†n° dàlence s dàlitelem
         jb        KalXDIV4                 ; dàlenec men®° neë dàlitel

; ------ nastaven° masky ve st©adaái

         lds       si,ss:[bp-4]             ; DS:SI <- adresa st©adaáe
         add       si,ss:[bp-6]             ; p©iáten° offsetu ve st©adaái
         mov       al,ss:[bp-7]             ; maska bitu k uloëen° vòsledku
         or        byte ptr ds:[si],al      ; nastaven° bitu ve st©adaái
         push      ss
         pop       ds                       ; DS <- z†sobn°k

; ------ odeáten° dàlitele od dàlence

         mov       cx,ss:[bp-10]            ; poáet bajtñ na á°slo
         mov       si,ss:[bp-14]            ; adresa dàlitele
         mov       di,ss:[bp-16]            ; adresa dàlence
         cld
         clc                                ; nen° p©enos
KalXDIV3:lodsw                              ; naáten° slova dàlitele
         sbb       word ptr ds:[di],ax      ; p©enos v dàlenci
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      KalXDIV3                 ; dal®° slovo

; ------ rotace dàlitele o bit vpravo

KalXDIV4:mov       di,ss:[bp-20]            ; adresa konce dàlitele v z†sobn°ku
         mov       cx,ss:[bp-10]            ; poáet bajtñ na á°slo
         clc                                ; nen° p©enos
KalXDIV5:rcr       word ptr ds:[di],1       ; rotace o 1 bit vpravo
         dec       di
         dec       di                       ; posun adresy
         loop      KalXDIV5                 ; dal®° slovo

; ------ posun masky o bit vpravo

         ror       byte ptr ss:[bp-7],1     ; rotace masky vpravo
         jnc       KalXDIV2                 ; dal®° bit
         dec       word ptr ss:[bp-6]       ; sn°ëen° offsetu
         jns       KalXDIV2                 ; dal®° slovo

; ------ oprava znamÇnka vòsledku

         mov       ds,ss:[bp-18]            ; datovò segment
         les       di,ss:[bp-4]             ; ES:DI <- adresa st©adaáe
         add       di,ss:[bp-10]            ; DI <- konec st©adaáe
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        KalXDIV9                 ; je p©eru®en° operace
         test      byte ptr es:[di-1],bit7  ; je p©eteáen° ?
         stc                                ; p©°znak chyby
         jnz       KalXDIV9                 ; je p©eteáen°
         test      byte ptr ss:[bp-8],bit0  ; je vòsledek z†pornò ?
         jz        KalXDIV8                 ; vòsledek nen° z†pornò
         call      KalXNEG                  ; oprava znamÇnka vòsledku
KalXDIV8:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

KalXDIV9:mov       sp,bp
         pop       es
         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

         call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXDIV  ENDP

; -----------------------------------------------------------------------------
;        vygenerov†n° maxim†ln°ho á°sla
; -----------------------------------------------------------------------------

KalXMXI  PROC      NEAR

         call      KalXNUL                  ; vygenerov†n° nuly
         call      KalXDEC                  ; nastaven° na "-1"
         and       byte ptr es:[di-1],not bit7 ; zru®en° znamÇnkovÇho bitu
         ret

KalXMXI  ENDP

; -----------------------------------------------------------------------------
;        uloëen° á°sla ES:DI do pamàti AL (= 0 aë 9)
; -----------------------------------------------------------------------------

KalXSET  PROC      NEAR

; ------ pro tabulkovò kalkul†tor se operace neprovede

         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXSET1                 ; nen° tabulkovò kalkul†tor
         ret

; ------ £schova registrñ

KalXSET1:push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ zaá†tek á°sla v bufferu -> SI

         sub       di,ds:[KalNumX]          ; DI <- zaá†tek á°sla
         mov       si,di                    ; SI <- zaá†tek á°sla

; ------ adresa pamàti -> DI

         mov       ah,al                    ; AH <- á°slo pamàti 0...9
         mov       al,0                     ; AX <- adresa pamàti
         xchg      ax,di                    ; DI <- adresa pamàti

; ------ vynulov†n° pamàti

         push      di
         push      es

         mov       ax,ds:[KalSMem]          ; segment pamàti
         call      far ptr GetDat           ; adresa segmentu pamàti -> ES
         mov       cx,256/2                 ; CX <- dÇlka pamàti/2
         xor       ax,ax                    ; AX <- 0
         cld
         rep       stosw                    ; vynulov†n° pamàti
         mov       dx,es                    ; DX <- segment pamàti

         pop       es
         pop       di

; ------ implicitn° dÇlka dat k uloëen° -> CX

         mov       cx,256                   ; tolik bajtñ k uloëen°

; ------ oprava, m†-li á°slo mÇnà desetinnòch m°st

         mov       ax,128                   ; dÇlka desetinnÇ á†sti v pamàti
         sub       ax,ds:[KalNumD]          ; chybàj°c° data na zaá†tku
         jbe       KalXSET2                 ; nem† mÇnà desetinnòch m°st
         add       di,ax                    ; oprava ukl†dac° adresy
         sub       cx,ax                    ; sn°ëen° dÇlky dat k uloëen°

; ------ oprava, m†-li á°slo mÇnà celòch m°st

KalXSET2:mov       ax,128                   ; dÇlka celÇ á†sti v pamàti
         sub       ax,ds:[KalNumN]          ; chybàj°c° data do konce
         jbe       KalXSET3                 ; nem† mÇnà celòch m°st
         sub       cx,ax                    ; sn°ëen° dÇlky á°sla

; ------ oprava, m†-li á°slo v°ce desetinnòch m°st

KalXSET3:mov       ax,ds:[KalNumD]          ; poáet desetinnòch m°st á°sla
         sub       ax,128                   ; p©ebòvaj°c° m°sta
         jbe       KalXSET4                 ; nic nep©ebòv†
         add       si,ax                    ; oprava zdrojovÇ adresy

; ------ p©enesen° á°sla do bufferu

KalXSET4:push      es
         pop       ds                       ; DS <- segment á°sla
         mov       es,dx                    ; ES <- segment bufferu
         cld
         shr       cx,1                     ; velikost ve slovech
         rep       movsw                    ; £schova á°sla do pamàti

; ------ n†vrat registrñ

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         clc
         ret

KalXSET  ENDP

; -----------------------------------------------------------------------------
;       n†vrat á°sla z pamàti AL (= 0 aë 9) (nic se nekontroluje) -> ES:DI zvò®°
; -----------------------------------------------------------------------------

KalXRCL  PROC      NEAR

; ------ vynulov†n° bufferu, zvò®en° adresy á°sla v bufferu

         call      KalXNUL                  ; vynulov†n° bufferu
         test      byte ptr ds:[KalParm],bit6 ; je tabulkovò kalkul†tor ?
         jz        KalXRCL1                 ; nen° tabulkovò kalkul†tor
         ret

; ------ £schova registrñ

KalXRCL1:push      ax
         push      cx
         push      dx
         push      si
         push      di

; ------ adresa pamàti -> SI

         mov       ah,al                    ; AH <- á°slo pamàti 0...9
         mov       al,0                     ; AX <- adresa pamàti
         xchg      ax,si                    ; SI <- adresa pamàti

; ------ adresa zaá†tku bufferu á°sla -> DI

         sub       di,ds:[KalNumX]          ; DI <- adresa zaá†tku bufferu á°sla

; ------ implicitn° dÇlka dat k uloëen° -> CX

         mov       cx,256                   ; tolik bajtñ k uloëen°

; ------ oprava, m†-li á°slo mÇnà desetinnòch m°st

         mov       ax,128                   ; dÇlka desetinnÇ á†sti v pamàti
         sub       ax,ds:[KalNumD]          ; chybàj°c° data na zaá†tku
         jbe       KalXRCL2                 ; nem† mÇnà desetinnòch m°st
         add       si,ax                    ; oprava átec° adresy
         sub       cx,ax                    ; sn°ëen° dÇlky dat k uloëen°

; ------ oprava, m†-li á°slo mÇnà celòch m°st

KalXRCL2:mov       ax,128                   ; dÇlka celÇ á†sti v pamàti
         sub       ax,ds:[KalNumN]          ; chybàj°c° data do konce
         jbe       KalXRCL3                 ; nem† mÇnà celòch m°st
         sub       cx,ax                    ; sn°ëen° dÇlky á°sla

; ------ oprava, m†-li á°slo v°ce desetinnòch m°st

KalXRCL3:mov       ax,ds:[KalNumD]          ; poáet desetinnòch m°st á°sla
         sub       ax,128                   ; p©ebòvaj°c° m°sta
         jbe       KalXRCL4                 ; nic nep©ebòv†
         add       di,ax                    ; oprava c°lovÇ adresy

; ------ p©enesen° á°sla do bufferu

KalXRCL4:push      ds
         mov       ax,ds:[KalSMem]          ; segment pamàti
         call      far ptr GetSgAdr         ; adresa segmentu pamàti -> DX
         mov       ds,dx                    ; DS <- segment pamàti
         cld
         shr       cx,1                     ; velikost ve slovech
         rep       movsw                    ; n†vrat á°sla do pamàti
         pop       ds

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         clc
         ret

KalXRCL  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet faktori†lu FAC
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; VùSTUP: CY=p©eteáen°
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) adresa n†sobitele á°sla v z†sobn°ku
;                   SS:[BP-7] (1)
;                   SS:[BP-8] (1) bit 0: 1=vòsledek z†pornò
; -----------------------------------------------------------------------------

KalXFAC0:cmp       byte ptr ss:[si],"!"     ; je faktori†l ?
         je        KalXFAC1                 ; je faktori†l
         clc
         ret

KalXFAC1:inc       si                       ; p©eskoáen° znaku "!"


KalXFAC  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,8
         mov       cx,ds:[KalNumX]          ; CX <- velikost á°sla v bajtech
         sub       sp,cx                    ; buffer n†sobitele
         mov       ss:[bp-6],sp             ; adresa n†sobitele á°sla
         sub       sp,cx                    ; buffer st©adaáe
         mov       byte ptr ss:[bp-8],0     ; parametry

; ------ absolutn° hodnota á°sla

         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXFAC2                 ; á°slo nebylo z†pornÇ
         or        byte ptr ss:[bp-8],bit0  ; vòsledek z†pornò

; ------ £schova adresy á°sla

KalXFAC2:mov       ss:[bp-2],es             ; segment bufferu á°sla
         sub       di,cx                    ; DI <- zaá†tek á°sla
         mov       ss:[bp-4],di             ; offset á°sla

; ------ uloëen° á°sla do z†sobn°ku

         mov       si,di                    ; SI <- zaá†tek á°sla
         mov       di,sp                    ; DI <- adresa st©adaáe á°sla
         shr       cx,1                     ; CX <- dÇlka á°sla ve slovech

         push      ds

         push      es
         pop       ds                       ; DS <- segment á°sla
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku

         push      si
         push      cx
         cld
         rep       movsw                    ; uloëen° á°sla do z†sobn°ku
         pop       cx
         pop       si
         rep       movsw                    ; druh† kopie á°sla

         pop       ds

; ------ kontrola velikosti á°sla

         xor       ax,ax                    ; AX <- 0
         mov       cx,ds:[KalNumNW]         ; CX <- poáet slov celÇ á†sti
         dec       di
         dec       di                       ; DI <- adresa konce á°sla
         dec       cx                       ; bez 1 slova
         std                                ; smàr dolñ
         repe      scasw                    ; test nulovosti á°sla
         stc                                ; p©°znak chyby
         jne       KalXFAC9                 ; chyba p©eteáen°
         cmp       word ptr es:[di],500     ; asi tak maximum
         cmc
         jc        KalXFAC9                 ; chyba p©eteáen°

; ------ sn°ëen° n†sobitele

KalXFAC3:mov       di,ss:[bp-6]             ; adresa n†sobitele á°sla
         add       di,ds:[KalNumD]          ; adresa celÇ á†sti á°sla
         cmp       word ptr es:[di],2       ; minim†ln° á°slo
         jbe       KalXFAC6                 ; konec operace
         dec       word ptr es:[di]         ; sn°ëen° ukazatele á°sla

; ------ vyn†soben° á°sla

         lea       di,[bp-8]                ; adresa konce á°sel
         call      KalXMUL                  ; vyn†soben° á°sel

; ------ test p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jnc       KalXFAC3                 ; nen° p©eru®en° operace
         jmp       short KalXFAC9

; ------ p©enesen° á°sla do bufferu

KalXFAC6:mov       si,sp                    ; SI <- st©adaá á°sla
         les       di,ss:[bp-4]             ; adresa á°sla
         mov       cx,ds:[KalNumXW]         ; CX <- dÇlka á°sla ve slovech
         push      ds
         cld
         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
         rep       movsw                    ; uloëen° á°sla
         pop       ds

; ------ oprava znamÇnka á°sla

         test      byte ptr ss:[bp-8],bit0  ; vòsledek z†pornò ?
         jz        KalXFAC9                 ; nen° vòsledek z†pornò
         call      KalXNEG                  ; negace á°sla
;         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

KalXFAC9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       ax
         call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXFAC  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet Eulerovy konstanty (mus° bòt volnÇ m°sto k uloëen° á°sla !)
; -----------------------------------------------------------------------------
; vzorec pro vòpoáet: e = 1 + 1/1! + 1/2! + 1/3! + 1/4! + 1/5! + .....
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku zvò®en° o 1 á°slo
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) dÇlka platnÇ á†sti p©°rustku (slov)
;                   SS:[BP-8] (2) á°taá pro dàlen° p©°rustku
;                             (KalNumX) p©°rustek á°sla
; -----------------------------------------------------------------------------

KalXEUL  PROC      NEAR

; ------ vynulov†n° bufferu, zvò®en° ukazatele ES:DI

         call      KalXNUL                  ; vynulov†n° bufferu

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,8
         sub       sp,ds:[KalNumX]          ; m°sto v bufferu pro p©°rustek
         sub       di,ds:[KalNumX]          ; n†vrat zaá†tku á°sla
         mov       ss:[bp-2],es             ; segment bufferu á°sla
         mov       ss:[bp-4],di             ; offset bufferu á°sla
         add       di,ds:[KalNumD]          ; adresa celÇ á†sti á°sla
         mov       byte ptr es:[di],2       ; inicializace na "2"
         mov       ax,ds:[KalNumDW]         ; velikost desetinnÇ á†sti (slov)
         inc       ax                       ; 1 slovo nav°c (v celòch á°slech)
         mov       ss:[bp-6],ax             ; dÇlka platnÇ á†sti p©°rustku (slov)
         mov       word ptr ss:[bp-8],1     ; á°taá pro dàlen° p©°rustku

; ------ vynulov†n° bufferu p©°rustku a inicializace na á°slo "1"

         mov       di,sp                    ; DI <- buffer p©°rustku
         push      es
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         call      KalXNUL                  ; vynulov†n° bufferu p©°rustku
         sub       di,ds:[KalNumN]          ; adresa celÇ á†sti á°sla
         mov       byte ptr es:[di],1       ; inicializace na 1
         pop       es

; ------ p©°prava registrñ k vydàlen° p©°rustku

         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku

KalXEUL2:mov       si,sp                    ; SI <- zaá†tek á°sla
         xor       dx,dx                    ; DX <- 0 nen° p©enos
         inc       word ptr ss:[bp-8]       ; zvò®en° á°taáe pro dàlen° p©°rustku
         mov       bx,ss:[bp-8]             ; á°taá pro dàlen° p©°rustku
         mov       cx,ss:[bp-6]             ; CX <- dÇlka platnÇ á†sti p©°rustku
         add       si,cx
         add       si,cx                    ; adresa za koncem p©°rustku
         dec       si
         dec       si                       ; posledn° slovo p©°rustku
         std                                ; smàr dolñ

; ------ zkr†cen° p©°rustku, je-li posledn° slovo = 0

         cmp       word ptr ds:[si],0       ; je nevòznamn† "0" ?
         jne       KalXEUL3                 ; nen° je®tà nevòznamn† "0"
         dec       si
         dec       si                       ; zkr†cen° o 1 slovo
         dec       word ptr ss:[bp-6]       ; sn°ëen° dÇlky
         jz        KalXEUL9                 ; je jië dÇlka = 0
         dec       cx                       ; sn°ëen° dÇlky

; ------ vydàlen° p©°rustku á°taáem

KalXEUL3:lodsw                              ; naáten° slova p©°rustku
         div       bx                       ; vydàlen° á°taáem
         mov       ds:[si+2],ax             ; n†vrat p©°rustku
         loop      KalXEUL3                 ; dal®° slovo

; ------ p©iáten° p©°rustku ke st©adaái

         mov       cx,ss:[bp-6]             ; CX <- dÇlka platnÇ á†sti p©°rustku
         inc       si
         inc       si                       ; n†vrat zaá†tku p©°rustku
         cld                                ; smàr nahoru
         mov       di,ss:[bp-4]             ; DI <- offset bufferu á°sla
         clc                                ; nen° p©enos
KalXEUL4:lodsw                              ; naáten° slova p©°rustku
         adc       es:[di],ax               ; p©iáten° ke st©adaái
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      KalXEUL4                 ; dal®° slovo
         jnc       KalXEUL2                 ; nen° p©enos

; ------ doplnàn° p©enosu

KalXEUL5:adc       word ptr es:[di],0       ; p©enos
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         jnc       KalXEUL2                 ; nen° p©enos
         jmp       short KalXEUL5           ; je p©enos

; ------ n†vrat registrñ

KalXEUL9:mov       sp,bp
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         clc
         ret

KalXEUL  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet PI konstanty (mus° bòt volnÇ m°sto k uloëen° á°sla !)
; -----------------------------------------------------------------------------
; vzorec: PI = 6*(1/2 + 1/(2^3*2*3) + 3/(2^5*2*4*5) + 3*5/(2^7*2*4*6*7) +
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel
;        DS=datovò segment
; VùSTUP: ES:DI=ukazatel vrcholu z†sobn°ku zvò®enò o 1 á°slo
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) dÇlka platnÇ á†sti p©°rustku (slov)
;                   SS:[BP-8] (2) á°taá pro dàlen° p©°rustku
;                             (KalNumX) p©°rustek á°sla (inic. na "3")
; -----------------------------------------------------------------------------

KalXPI   PROC      NEAR

; ------ vynulov†n° bufferu, zvò®en° ukazatele ES:DI

         call      KalXNUL                  ; vynulov†n° bufferu

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,8
         sub       sp,ds:[KalNumX]          ; m°sto v bufferu pro p©°rustek
         sub       di,ds:[KalNumX]          ; n†vrat zaá†tku á°sla
         mov       ss:[bp-2],es             ; segment bufferu á°sla
         mov       ss:[bp-4],di             ; offset bufferu á°sla
         mov       ax,ds:[KalNumDW]         ; velikost desetinnÇ á†sti (slov)
         inc       ax                       ; 1 slovo nav°c (v celòch á°slech)
         mov       ss:[bp-6],ax             ; dÇlka platnÇ á†sti p©°rustku (slov)
         mov       word ptr ss:[bp-8],1     ; á°taá pro dàlen° p©°rustku

; ------ vynulov†n° bufferu p©°rustku a inicializace na á°slo "3"

         mov       di,sp                    ; DI <- buffer p©°rustku
         push      es
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         call      KalXNUL                  ; vynulov†n° bufferu p©°rustku
         sub       di,ds:[KalNumN]          ; adresa celÇ á†sti á°sla
         mov       byte ptr es:[di],3       ; inicializace na "3"
         pop       es

; ------ p©iáten° p©°rustku ke st©adaái (nyn° je DS=SS !)

         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
KalXPI2: mov       cx,ss:[bp-6]             ; CX <- dÇlka platnÇ á†sti p©°rustku
         cld                                ; smàr nahoru
         mov       si,sp                    ; SI <- p©°rustek
         mov       di,ss:[bp-4]             ; DI <- offset bufferu á°sla
         clc                                ; nen° p©enos
KalXPI3: lodsw                              ; naáten° slova p©°rustku
         adc       es:[di],ax               ; p©iáten° ke st©adaái
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      KalXPI3                  ; dal®° slovo
         jnc       KalXPI5                  ; nen° p©enos

; ------ doplnàn° p©enosu

KalXPI4: adc       word ptr es:[di],0       ; p©enos
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         jc        KalXPI4

; ------ p©°prava k n†soben° p©°rustku

KalXPI5: mov       si,sp                    ; SI <- zaá†tek á°sla
         mov       bx,ss:[bp-8]             ; á°taá pro dàlen° p©°rustku
         mov       cx,ss:[bp-6]             ; CX <- dÇlka platnÇ á†sti p©°rustku

; ------ vyn†soben° p©°rustku staròm á°taáem

         cld
         xor       di,di                    ; nen° p©enos
         push      si
         push      cx
KalXPI6: lodsw                              ; naáten° slova
         mul       bx                       ; vyn†soben° á°taáem
         add       ax,di                    ; p©enos
         adc       dx,0
         mov       di,dx
         mov       ds:[si-2],ax
         loop      KalXPI6
         pop       cx
         pop       si

; ------ vyn†soben° p©°rustku staròm á°taáem

         xor       di,di                    ; nen° p©enos
         push      cx
KalXPI62:lodsw                              ; naáten° slova
         mul       bx                       ; vyn†soben° á°taáem
         add       ax,di                    ; p©enos
         adc       dx,0
         mov       di,dx
         mov       ds:[si-2],ax
         loop      KalXPI62
         mov       ds:[si],dx
         pop       cx

         or        dx,dx
         jz        KalXPI63
         inc       si
         inc       si
         inc       cx
         inc       word ptr ss:[bp-6]

; ------ test, zda bude zkr†cen°

KalXPI63:or        dx,ax                    ; bude zkr†cen° ?
         jnz       KalXPI7                  ; nebude zkr†cen°
         dec       cx                       ; zkr†cen°
         dec       si
         dec       si
         dec       word ptr ss:[bp-6]       ; sn°ëen° á°taáe dÇlky
         jz        KalXPI9                  ; konec

; ------ p©°prava k dàlen°

KalXPI7: dec       si
         dec       si                       ; posledn° slovo
         std                                ; smàr dolñ

; ------ vydàlen° p©°rustku á°taáem + 1

         xor       dx,dx                    ; DX <- 0 nen° p©enos
         inc       word ptr ss:[bp-8]       ; zvò®en° á°taáe
         inc       bx
         push      si
         push      cx
KalXPI8: lodsw                              ; naáten° slova p©°rustku
         div       bx                       ; vydàlen° á°taáem
         mov       ds:[si+2],ax             ; n†vrat p©°rustku
         loop      KalXPI8                  ; dal®° slovo
         pop       cx
         pop       si

; ------ vydàlen° p©°rustku á°taáem + 2

         xor       dx,dx                    ; DX <- 0 nen° p©enos
         inc       word ptr ss:[bp-8]       ; zvò®en° á°taáe
         inc       bx
         push      si
         push      cx
KalXPI82:lodsw                              ; naáten° slova p©°rustku
         div       bx                       ; vydàlen° á°taáem
         mov       ds:[si+2],ax             ; n†vrat p©°rustku
         loop      KalXPI82                 ; dal®° slovo
         pop       cx
         pop       si

; ------ vydàlen° p©°rustku á°slem 4

         xor       dx,dx                    ; DX <- 0 nen° p©enos
         mov       bx,4
KalXPI84:lodsw                              ; naáten° slova p©°rustku
         div       bx                       ; vydàlen° á°taáem
         mov       ds:[si+2],ax             ; n†vrat p©°rustku
         loop      KalXPI84                 ; dal®° slovo
         jmp       KalXPI2                  ; dal®° cyklus

; ------ n†vrat registrñ

KalXPI9: mov       sp,bp
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         clc
         ret

KalXPI  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet funkce ARCTG (pouë°v† 1 dal®° á°slo v z†sobn°ku á°sel !)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel á°sel v bufferu á°sel (konec á°sla)
;        DS=datovò segment
; VùSTUP: CY=p©eteáen°
;   niá° registry !!!!
; -----------------------------------------------------------------------------
; lok†ln° registry: DL=p©°znaky     bit 0: 1=á°slo bylo z†pornÇ
;                                   bit 1: 1=pot©ebn† konverze ARCTG/ARCCOTG
; -----------------------------------------------------------------------------
;˛
KalXACT: mov       dl,bit1                  ; p©°znak funkce ARCCOTG
         jmp       short KalXATG1

KalXATG  PROC      NEAR

; ------ absolutn° hodnota á°sla

         mov       dl,0                     ; p©°znak, ëe á°slo je kladnÇ
KalXATG1:call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXATG2                 ; á°slo bylo kladnÇ
         or        dl,bit0                  ; p©°znak, ëe á°slo bylo z†pornÇ

; ------ test, zda je á°slo men®° nebo vàt®° neë 1

KalXATG2:push      di
         dec       di
         dec       di                       ; posledn° slovo á°sla
         mov       cx,ds:[KalNumNW]         ; dÇlka celÇ á†sti ve slovech
         dec       cx                       ; bez 1 slova
         xor       ax,ax                    ; porovn†vanÇ slovo
         std                                ; smàr dolñ
         repe      scasw                    ; test, zda je vàt®° neë 64 KB
         jne       KalXAT22                 ; je vàt®° neë 64 KB
         cmp       word ptr es:[di],1       ; je rñznÇ od 1 ?
         jne       KalXATG3                 ; je rñznÇ od 1

         dec       di
         dec       di                       ; posledn° slovo desetin
         mov       cx,ds:[KalNumDW]         ; dÇlka desetin
         repe      scasw                    ; porovn†n° zbytku, zda je 1
KalXAT22:clc                                ; p©°znak "rovno" nebo "vàt®°"

KalXATG3:pop       di
         jb        KalXATG6                 ; á°slo je men®° neë 1
         ja        KalXATG4                 ; á°slo je vàt®° neë 1

; ------ á°slo je = 1, vòsledkem m† bòt PI/4

         sub       di,ds:[KalNumX]          ; zru®en° á°sla
         call      KalXPI                   ; vytvo©en° á°sla PI
         call      KalXRLD                  ; á°slo PI/2
         call      KalXRLD                  ; á°slo PI/4
         jmp       short KalXATG8

; ------ á°slo je vàt®° neë 1

KalXATG4:xor       dl,bit1                  ; zmàna konverze
         call      KalXNUL                  ; vytvo©en° nuly
         call      KalXINC                  ; korekce na á°slo 1
         call      KalXXCH                  ; z†màna á°sel
         call      KalXDIV                  ; p©evr†cen† hodnota á°sla

; ------ vòpoáet funkce ARCTG/ARCCOTG

KalXATG6:call      KalXATN                  ; vòpoáet ARCTG
         jc        KalXATG9                 ; p©eteáen°

; ------ korekce vòsledku

         test      dl,bit1                  ; je pot©ebn† korekce ?
         jz        KalXATG7                 ; nen° pot©ebn† korekce
         call      KalXNEG                  ; negace á°sla
         call      KalXPI                   ; vytvo©en° á°sla PI
         call      KalXRLD                  ; vydàlen° á°sla PI/2
         call      KalXADD                  ; souáet á°sel

; ------ oprava znamÇnka á°sla

KalXATG7:test      dl,bit0                  ; bylo á°slo z†pornÇ ?
         jz        KalXATG8                 ; nebylo z†pornÇ
         call      KalXNEG                  ; negace á°sla

KalXATG8:clc                                ; p©°znak operace OK

KalXATG9:ret

KalXATG  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet funkce ARCSIN (pouë°v† 1 dal®° á°slo v z†sobn°ku á°sel !)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel á°sel v bufferu á°sel (konec á°sla)
;        DS=datovò segment
; VùSTUP: CY=p©eteáen°
;   niá° registry !!!!
; -----------------------------------------------------------------------------
; lok†ln° registry: DL=p©°znaky     bit 0: 1=á°slo bylo z†pornÇ
;                                   bit 1: 1=pot©ebn† konverze ARCSIN/ARCCOS
;                                   bit 2: 1=COS
;                                   bit 3: 1=á°slo bylo > 0.5
; -----------------------------------------------------------------------------
;˛
KalXACN: mov       dl,bit1+bit2             ; p©°znak funkce ARCCOS
         jmp       short KalXASN1

KalXASN  PROC      NEAR

; ------ absolutn° hodnota á°sla

         mov       dl,0                     ; p©°znak, ëe á°slo je kladnÇ
KalXASN1:call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXASN2                 ; á°slo bylo kladnÇ
         or        dl,bit0                  ; p©°znak, ëe á°slo bylo z†pornÇ

; ------ kontrola, zda á°slo je vàt®° neë 64 KB

KalXASN2:push      di
         mov       cx,ds:[KalNumNW]         ; dÇlka celÇ á†sti á°sla
         dec       cx                       ; bez 1 slova
         sub       di,cx
         sub       di,cx                    ; zaá†tek celÇ á†sti á°sla + 1slovo
         mov       bx,di                    ; BX <- zaá†tek celÇ á†sti á°sla
         xor       ax,ax                    ; AX <- 0
         cld
         repe      scasw                    ; test, zda je á°slo velkÇ
         pop       di
         jne       KalXASN8                 ; á°slo je velkÇ

; ------ kontrola, zda á°slo je 2 a vàt®°

         cmp       word ptr es:[bx-2],1     ; je á°slo velkÇ ?
         ja        KalXASN8                 ; á°slo je velkÇ
         jb        KalXASN4                 ; á°slo je OK

; ------ kontrola, zda á°slo je vàt®° neë 1 (AX=0)

         push      di
         mov       cx,ds:[KalNumDW]         ; dÇlka desetin
         sub       di,ds:[KalNumX]          ; zaá†tek á°sla
         repe      scasw                    ; jsou desetiny = 0 ?
         pop       di
         jne       KalXASN8                 ; á°slo je vàt®° neë 1

; ------ test, zda á°slo je vàt®° neë 1/2

KalXASN4:cmp       word ptr es:[bx-3],256/2 ; je á°slo vàt®° neë 1/2 ?
         jbe       KalXASN6                 ; á°slo je OK

; ------ konverze na p©°buznou funkci

         xor       dl,bit1+bit3             ; p©°znak konverze á°sla
         call      KalXDUP                  ; zdvojen° á°sla
         call      KalXMUL                  ; druh† mocnina á°sla
         call      KalXNUL                  ; vytvo©en° á°sla 0
         call      KalXINC                  ; £prava na á°slo 1
         call      KalXXCH                  ; z†màna á°sel
         call      KalXSUB                  ; odeáten° á°sel
         call      KalXSQR                  ; odmocnina z á°sla

; ------ vòpoáet funkce ARCSIN

KalXASN6:call      KalXARC                  ; vòpoáet funkce ARCSIN

; ------ n†vrat znamÇnka funkce

         test      dl,bit0                  ; bylo á°slo z†pornÇ ?
         jz        KalXASN7                 ; á°slo nebylo z†pornÇ
         call      KalXNEG                  ; n†vrat znamÇnka á°sla

; ------ opravn† konverze á°sla

KalXASN7:test      dl,bit1                  ; je pot©eba prov†dàt konverzi ?
         jz        KalXAS72                 ; konverze se neprov†d°

         call      KalXNEG                  ; negace vòsledku
         call      KalXPI                   ; vytvo©en° á°sla PI
         call      KalXRLD                  ; vydàlen° PI/2
         call      KalXADD                  ; souáet

; ------ dopl§uj°c° oprava

KalXAS72:test      dl,bit3                  ; bylo á°slo > 0.5 ?
         jz        KalXAS74                 ; nebylo vàt®° neë 0.5
         test      dl,bit0                  ; bylo á°slo z†pornÇ ?
         jz        KalXAS74                 ; á°slo nebylo z†pornÇ

         call      KalXPI                   ; vytvo©en° á°sla PI

         test      dl,bit2                  ; je COS ?
         jnz       KalXAS73                 ; je COS
         call      KalXSUB                  ; odeáten° á°sla PI
         jmp       short KalXAS74

KalXAS73:call      KalXADD                  ; p©iáten° á°sla PI

KalXAS74:clc                                ; p©°znak operace OK
         jmp       short KalXASN9

KalXASN8:stc                                ; p©°znak chyby
KalXASN9:call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXASN  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet funkce ARCSIN bez kontroly rozsahu (mus° bòt 0 aë +0.5 !)
; -----------------------------------------------------------------------------
; vzorec: ARCSIN = x + x^3/2/3 + 3*x^5/2/4/5 + 3*5*x^7/2/4/6/7 +
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) dÇlka platnÇ á†sti p©°rustku (slov)
;                   SS:[BP-8] (2) á°taá pro dàlen° p©°rustku
;                   SS:[BP-10] (2) adresa koeficientu v z†sobn°ku
;                   SS:[BP-12] (2) datovò segment
;                             (KalNumX) koeficient n†soben° á°sla (x^2)
;                             (KalNumX) p©°rustek á°sla
; -----------------------------------------------------------------------------
;˛
KalXARC  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,12

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,ds:[KalNumX]          ; m°sto v bufferu pro á°slo 1
         mov       ss:[bp-10],sp            ; adresa koeficientu v z†sobn°ku
         sub       sp,ds:[KalNumX]          ; m°sto v bufferu pro p©°rustek
         sub       di,ds:[KalNumX]          ; zaá†tek á°sla
         mov       ss:[bp-2],es             ; segment bufferu á°sla
         mov       ss:[bp-4],di             ; offset bufferu á°sla
         mov       ax,ds:[KalNumDW]         ; velikost desetinnÇ á†sti (slov)
         inc       ax                       ; 1 slovo nav°c (v celòch á°slech)
         mov       ss:[bp-6],ax             ; dÇlka platnÇ á†sti p©°rustku (slov)
         mov       word ptr ss:[bp-8],1     ; á°taá pro dàlen° p©°rustku
         mov       ss:[bp-12],ds            ; datovò segment

; ------ £schova á°sla do z†sobn°ku

         mov       di,sp                    ; ukl†dac° adresa do z†sobn°ku
         push      ds
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lds       si,ss:[bp-4]             ; adresa á°sla
         cld
         rep       movsw                    ; £schova á°sla do z†sobn°ku
         pop       ds

; ------ druh† mocnina á°sla

         call      KalXDUP                  ; kopie á°sla
         push      di
         call      KalXMUL                  ; druh† mocnina á°sla
         pop       di
         call      KalXXCH                  ; z†màna á°sel

; ------ vynulov†n° bufferu st©adaáe

         les       di,ss:[bp-4]             ; adresa st©adaáe
         call      KalXNUL                  ; vynulov†n° st©adaáe

; ------ p©iáten° p©°rustku ke st©adaái

KalXARC2:mov       si,sp                    ; SI <- p©°rustek
         mov       cx,ss:[bp-6]             ; CX <- dÇlka platnÇ á†sti p©°rustku
         les       di,ss:[bp-4]             ; adresa bufferu á°sla
         cld                                ; smàr nahoru
         clc                                ; nen° p©enos
KalXARC3:lods      word ptr ss:[si]         ; naáten° slova p©°rustku
         adc       es:[di],ax               ; p©iáten° ke st©adaái
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      KalXARC3                 ; dal®° slovo
         jnc       KalXARC5                 ; nen° p©enos

; ------ doplnàn° p©enosu

KalXARC4:adc       word ptr es:[di],0       ; p©enos
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         jc        KalXARC4

; ------ vyn†soben° p©°rustku koeficientem

KalXARC5:push      ss
         pop       es                       ; ES <- z†sobn°k
         lea       di,[bp-12]               ; konec 2. á°sla
         call      KalXMUL                  ; vyn†soben° koeficientem

; ------ vyn†soben° p©°rustku staròm á°taáem

         mov       si,sp                    ; SI <- zaá†tek á°sla
         mov       bx,ss:[bp-8]             ; á°taá pro dàlen° p©°rustku
         mov       cx,ss:[bp-6]             ; CX <- dÇlka platnÇ á†sti p©°rustku

         cld
         xor       di,di                    ; nen° p©enos
         push      si
         push      cx
KalXARC6:lods      word ptr ss:[si]         ; naáten° slova
         mul       bx                       ; vyn†soben° á°taáem
         add       ax,di                    ; p©enos
         adc       dx,0
         mov       di,dx
         mov       ss:[si-2],ax
         loop      KalXARC6
         mov       ss:[si],dx
         pop       cx
         pop       si

         or        dx,dx
         jz        KalXAR61
         inc       cx
         inc       word ptr ss:[bp-6]

; ------ vyn†soben° p©°rustku staròm á°taáem

KalXAR61:xor       di,di                    ; nen° p©enos
         push      cx
KalXAR62:lods      word ptr ss:[si]         ; naáten° slova
         mul       bx                       ; vyn†soben° á°taáem
         add       ax,di                    ; p©enos
         adc       dx,0
         mov       di,dx
         mov       ss:[si-2],ax
         loop      KalXAR62
         mov       ss:[si],dx
         pop       cx

         or        dx,dx
         jz        KalXAR63
         inc       si
         inc       si
         inc       cx
         inc       word ptr ss:[bp-6]

; ------ test, zda bude zkr†cen°

KalXAR63:or        dx,ax                    ; bude zkr†cen° ?
         jnz       KalXARC7                 ; nebude zkr†cen°
         dec       cx                       ; zkr†cen°
         dec       si
         dec       si
         dec       word ptr ss:[bp-6]       ; sn°ëen° á°taáe dÇlky
         jz        KalXARC9                 ; konec

; ------ p©°prava k dàlen°

KalXARC7:dec       si
         dec       si                       ; posledn° slovo
         std                                ; smàr dolñ

; ------ vydàlen° p©°rustku á°taáem + 1

         xor       dx,dx                    ; DX <- 0 nen° p©enos
         inc       word ptr ss:[bp-8]       ; zvò®en° á°taáe
         inc       bx
         push      si
         push      cx
KalXARC8:lods      word ptr ss:[si]         ; naáten° slova p©°rustku
         div       bx                       ; vydàlen° á°taáem
         mov       ss:[si+2],ax             ; n†vrat p©°rustku
         loop      KalXARC8                 ; dal®° slovo
         pop       cx
         pop       si

; ------ vydàlen° p©°rustku á°taáem + 2

         xor       dx,dx                    ; DX <- 0 nen° p©enos
         inc       word ptr ss:[bp-8]       ; zvò®en° á°taáe
         inc       bx
KalXAR82:lods      word ptr ss:[si]         ; naáten° slova p©°rustku
         div       bx                       ; vydàlen° á°taáem
         mov       ss:[si+2],ax             ; n†vrat p©°rustku
         loop      KalXAR82                 ; dal®° slovo
         jmp       KalXARC2                 ; dal®° cyklus

; ------ n†vrat registrñ

KalXARC9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         clc
         ret

KalXARC  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet funkce ARCTG bez kontroly rozsahu (mus° bòt 0 aë +1.0 !)
; -----------------------------------------------------------------------------
; vzorec: ARCTG = x - x^3/3 + x^5/5 - x^7/7 + ....
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; VùSTUP: CY=p©eteáen°
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) dÇlka platnÇ á†sti p©°rustku (slov)
;                   SS:[BP-8] (2) á°taá pro dàlen° p©°rustku
;                   SS:[BP-10] (2) adresa koeficientu v z†sobn°ku (á°slo 3)
;                   SS:[BP-12] (2) adresa p©°rustku k n†soben° (á°slo 2)
;                             (KalNumX) koeficient n†soben° á°sla (x^2)
;                             (KalNumX) p©°rustek á°sla k n†soben°
;                             (KalNumX) p©°rustek á°sla vydàlen° á°taáem
; -----------------------------------------------------------------------------
;˛
KalXATN  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,12

; ------ p©°prava lok†ln°ch promànnòch

         mov       cx,ds:[KalNumX]          ; dÇlka á°sla v bajtech
         sub       sp,cx                    ; m°sto v bufferu pro á°slo 1
         mov       ss:[bp-10],sp            ; adresa koeficientu v z†sobn°ku
         sub       sp,cx                    ; m°sto v bufferu pro p©°rustek
         mov       ss:[bp-12],sp            ; adresa p©°rustku k n†soben°
         sub       sp,cx                    ; m°sto v bufferu
         sub       di,cx                    ; zaá†tek á°sla
         mov       ss:[bp-2],es             ; segment bufferu á°sla
         mov       ss:[bp-4],di             ; offset bufferu á°sla
         mov       ax,ds:[KalNumDW]         ; velikost desetinnÇ á†sti (slov)
         inc       ax                       ; 1 slovo nav°c (v celòch á°slech)
         mov       ss:[bp-6],ax             ; dÇlka platnÇ á†sti p©°rustku (slov)
         mov       word ptr ss:[bp-8],1     ; á°taá pro dàlen° p©°rustku

; ------ £schova á°sla do z†sobn°ku (jako á°slo 2)

         mov       di,ss:[bp-12]            ; ukl†dac° adresa do z†sobn°ku
         push      ds
         shr       cx,1                     ; dÇlka á°sla ve slovech
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lds       si,ss:[bp-4]             ; adresa á°sla
         cld
         rep       movsw                    ; £schova á°sla do z†sobn°ku
         pop       ds

; ------ druh† mocnina á°sla (do bufferu á°sla 3)

         call      KalXDUP                  ; kopie á°sla do bufferu 3
         push      di
         call      KalXMUL                  ; druh† mocnina á°sla
         pop       di
         call      KalXXCH                  ; z†màna á°sel

; ------ vynulov†n° bufferu st©adaáe

         les       di,ss:[bp-4]             ; adresa st©adaáe
         call      KalXNUL                  ; vynulov†n° st©adaáe

; ------ vydàlen° p©°rustku á°taáem (a uloëen° do bufferu á°sla 1)

KalXATN2:push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp                    ; DI <- ukl†dac° adresa
         call      KalXNUL                  ; vynulov†n° bufferu p©°rustku

         mov       di,sp

         mov       si,ss:[bp-12]            ; SI <- zaá†tek á°sla 2
         mov       cx,ss:[bp-6]             ; CX <- dÇlka platnÇ á†sti p©°rustku
         add       si,cx
         add       si,cx                    ; konec p©°rustku
         dec       si
         dec       si                       ; SI <- posledn° slovo p©°rustku

         cmp       word ptr ss:[si],0       ; je slovo = 0 ?
         jne       KalXATN3                 ; nen° = 0
         dec       cx                       ; zkr†cen°
         dec       si
         dec       si
         dec       word ptr ss:[bp-6]       ; zkr†cen° dÇlky
         clc                                ; p©°znak operace OK
         jz        KalXATN9

KalXATN3:add       di,cx
         add       di,cx                    ; ukl†dac° adresa
         dec       di
         dec       di
         mov       bx,ss:[bp-8]             ; á°taá pro dàlen° p©°rustku
         xor       dx,dx                    ; nen° p©enos
         std                                ; smàr dolñ

         push      cx
KalXATN4:lods      word ptr ss:[si]         ; naáten° slova
         div       bx                       ; vydàlen° á°taáem
         stosw                              ; uloëen° slova
         loop      KalXATN4
         pop       cx

; ------ p©iáten° p©°rustku ke st©adaái

         mov       si,sp                    ; SI <- p©°rustek
         les       di,ss:[bp-4]             ; adresa bufferu á°sla
         cld                                ; smàr nahoru
         clc                                ; nen° p©enos
         test      byte ptr ss:[bp-8],bit1  ; je odeá°t†n° ?
         jz        KalXAT44                 ; p©iá°t† se

KalXAT42:lods      word ptr ss:[si]         ; naáten° slova p©°rustku
         sbb       es:[di],ax               ; p©iáten° ke st©adaái
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      KalXAT42                 ; dal®° slovo
         jnc       KalXATN5                 ; nen° p©enos

KalXAT43:sbb       word ptr es:[di],0       ; p©enos
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         jc        KalXAT43
         jmp       short KalXATN5

KalXAT44:lods      word ptr ss:[si]         ; naáten° slova p©°rustku
         adc       es:[di],ax               ; p©iáten° ke st©adaái
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         loop      KalXAT44                 ; dal®° slovo
         jnc       KalXATN5                 ; nen° p©enos

KalXAT46:adc       word ptr es:[di],0       ; p©enos
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
         jc        KalXAT46

; ------ vyn†soben° p©°rustku koeficientem

KalXATN5:lea       di,[bp-12]               ; konec á°sla 3
         push      ss
         pop       es                       ; ES <- z†sobn°k
         call      KalXMUL                  ; vyn†soben° á°sla

; ------ posun ukazatele

         call      far ptr TestBEsc
         jc        KalXATN9

         inc       word ptr ss:[bp-8]
         stc                                ; p©°znak p©eteáen°
         jz        KalXATN9
         inc       word ptr ss:[bp-8]
         jmp       KalXATN2

; ------ n†vrat registrñ

KalXATN9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         clc
         ret

KalXATN  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet p©irozenÇho exponentu EXP
; -----------------------------------------------------------------------------
; vzorec pro vòpoáet: e^x = 1 + x/1! + x^2/2! + x^3/3! + x^4/4! + x^5/5! + ...
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo) (je platnÇ +/- 1000)
;        DS=datovò segment
; VùSTUP: CY=p©eteáen°
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) adresa p©°rustku v z†sobn°ku
;                   SS:[BP-7] (1)
;                   SS:[BP-8] (1) bit 0: 1=p©°rustek se p©iá°t†
;                                 bit 1: 1=á°slo X je kladnÇ (p©iá°t† se vëdy)
;                   SS:[BP-10] (2) á°taá N pro dàlen° p©°rustku (faktori†l)
;                                 (KalNumX) pñvodn° á°slo X
;                                 (KalNumX) p©°rustek (je n†soben X a dàlen N)
;                                 (KalNumX) st©adaá á°sla
; -----------------------------------------------------------------------------

KalXEXP  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,10
         mov       cx,ds:[KalNumX]          ; CX <- velikost á°sla v bajtech
         mov       ss:[bp-2],es             ; segment á°sla
         mov       ss:[bp-4],di             ; offset konce á°sla
         sub       ss:[bp-4],cx             ; zaá†tek á°sla
         sub       sp,cx                    ; buffer pñvodn°ho á°sla
         sub       sp,cx                    ; buffer p©°rustku
         mov       ss:[bp-6],sp             ; adresa p©°rustku v z†sobn°ku
         sub       sp,cx                    ; buffer st©adaáe
         mov       byte ptr ss:[bp-8],bit0+bit1 ; parametry - á°slo je kladnÇ
         mov       word ptr ss:[bp-10],0    ; á°taá pro dàlen° p©°rustku

; ------ absolutn° hodnota á°sla

         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXEXP1                 ; á°slo nebylo z†pornÇ
         mov       byte ptr ss:[bp-8],0     ; p©°rustek se odeá°t†

; ------ vynulov†n° st©adaáe a p©°rustku a jejich nastaven° na "1"

KalXEXP1:push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp                    ; DI <- zaá†tek bufferu
         call      KalXNUL                  ; vynulov†n° st©adaáe
         call      KalXNUL                  ; vynulov†n° p©°rustku
         push      di
         sub       di,ds:[KalNumN]          ; zaá†tek celÇ á†sti á°sla
         inc       byte ptr es:[di]         ; nastaven° p©°rustku na "1"
         sub       di,ds:[KalNumX]          ; cel† á†st á°sla st©adaáe
         inc       byte ptr es:[di]         ; nastaven° st©adaáe na "1"
         pop       di

; ------ uloëen° á°sla

         push      ds
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         lds       si,ss:[bp-4]             ; á°slo
         cld
         rep       movsw                    ; uloëen° á°sla do bufferu
         pop       ds

; ------ vydàlen° p©°rustku á°taáem

KalXEXP2:inc       word ptr ss:[bp-10]      ; zvò®en° á°taáe pro dàlen°
         mov       bx,ss:[bp-10]            ; BX <- á°taá pro dàlen°
         xor       di,di                    ; SI <- st©adaá nuly
         xor       dx,dx                    ; DX <- 0 nen° p©enos
         mov       si,ss:[bp-6]             ; adresa p©°rustku
         mov       cx,ds:[KalNumX]          ; dÇlka á°sla ve slovech
         add       si,cx                    ; adresa konec á°sla
         dec       si
         dec       si                       ; posledn° slovo á°sla
         shr       cx,1                     ; velikost á°sla ve slovech

         push      ds
         push      ss
         pop       ds                       ; DS <- datovò segment
         std                                ; smàr dolñ
KalXEXP3:lodsw                              ; naáten° slova p©°rustku
         div       bx                       ; vydàlen° á°taáem faktori†lu
         mov       ds:[si+2],ax             ; uloëen° á°sla
         or        di,ax                    ; st©adaá nuly
         loop      KalXEXP3                 ; dal®° slovo
         pop       ds
         jz        KalXEXP8                 ; p©°rustek je jië = 0

; ------ vyn†soben° p©°rustku á°slem X

         lea       di,[bp-10]               ; konec pñvodn°ho á°sla
         call      KalXMUL                  ; vyn†soben° á°slem

; ------ p©iáten°/odeáten° p©°rustku

         mov       di,sp
         add       di,ds:[KalNumX]
         add       di,ds:[KalNumX]          ; konec p©°rustku
         test      byte ptr ss:[bp-8],bit0+bit1 ; je p©iá°t†n° ?
         jnz       KalXEXP4                 ; p©iá°t† se
         call      KalXSUB                  ; odeáten°
         jmp       short KalXEXP5

KalXEXP4:call      KalXADD                  ; p©iáten°

KalXEXP5:xor       byte ptr ss:[bp-8],bit0  ; zmàna p©°znaku

         call      far ptr TestBEsc
         jnc       KalXEXP2

; ------ uloëen° vòsledku do bufferu

KalXEXP8:mov       si,sp                    ; SI <- st©adaá
         mov       cx,ds:[KalNumXW]         ; CX <- dÇlka á°sla ve slovech
         push      ds
         les       di,ss:[bp-4]             ; adresa á°sla
         push      ss
         pop       ds
         cld
         rep       movsw                    ; uloëen° á°sla
         pop       ds
         clc

; ------ n†vrat registrñ

KalXEXP9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXEXP  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet p©irozenÇho logaritmu LN
; -----------------------------------------------------------------------------
; vzorec: D = (x-1)/(x+1)
;         LN x = 2*D + 2*D/3*D^2 + 2*D/5*D^4 + 2*D/7*D^6 + 2*D/9*D^8 + ...
; P©ed operac° je á°slo pro zrychlen° normalizov†no do intervalu 1 aë 3
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; VùSTUP: CY=p©eteáen° (z†pornÇ á°slo)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) korekce vòsledku - slovo k p©iáten°
;                   SS:[BP-8] (2) (á°taá pro dàlen° p©°rustku-1)/2
;                   SS:[BP-10] (2) adresa á°sla 3 v z†sobn°ku
;                   SS:[BP-12] (2) adresa á°sla 2 v z†sobn°ku
;                   SS:[BP-14] (2) dÇlka platnÇ á†sti p©°rustku (slov)
;                             (KalNumX) n†sob°c° koeficient ((x-1)/(x+1))^2
;                             (KalNumX) p©°rustek á°sla (inic. na 2*(x-1)/(x+1))
;                             (KalNumX) p©°rustek á°sla dàlenò á°taáem /N
; -----------------------------------------------------------------------------

KalXLN   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ p©°prava bufferñ v z†sobn°ku

         sub       sp,14
         mov       cx,ds:[KalNumX]          ; CX <- dÇlka á°sla v bajtech
         sub       sp,cx
         mov       ss:[bp-10],sp            ; adresa á°sla 3 v z†sobn°ku
         sub       sp,cx
         mov       ss:[bp-12],sp            ; adresa á°sla 2 v z†sobn°ku
         sub       sp,cx

; ------ kontrola, zda je á°slo kladnÇ

         test      byte ptr es:[di-1],bit7  ; je á°slo kladnÇ ?
         jz        KalXLN1                  ; á°slo je kladnÇ OK
KalXLN0: stc                                ; p©°znak chyby á°sla
         jmp       KalXLN9                  ; chyba á°sla

; ------ p©°prava lok†ln°ch promànnòch

KalXLN1: sub       di,cx                    ; zaá†tek á°sla
         mov       ss:[bp-2],es             ; segment bufferu á°sla
         mov       ss:[bp-4],di             ; offset bufferu á°sla
         mov       word ptr ss:[bp-6],0     ; nen° korekce vòsledku
         mov       word ptr ss:[bp-8],0     ; á°taá pro dàlen° p©°rustku
         mov       ax,ds:[KalNumDW]         ; dÇlka desetinnÇ á†st (slov)
         inc       ax                       ; + 1 slovo nav°c
         mov       ss:[bp-14],ax            ; dÇlka platnÇ á†sti p©°rustku

; ------ kontrola, zda nen° á°slo = 0 (CX=dÇlka á°sla)

         cld
         xor       ax,ax                    ; AX <- 0
         shr       cx,1                     ; dÇlka á°sla ve slovech
         repe      scasw                    ; kontrola á°sla na 0
         je        KalXLN0                  ; chyba - á°slo je = 0

; ------ p©°prava Eulerovy konstanty do bufferñ 1, 2 a 3

         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         call      KalXEUL                  ; vòpoáet Eulerovy konstanty
         call      KalXDUP                  ; zdvojen° á°sla EUL do bufferu 2
         push      di                       ; zaá†tek á°sla 3
         call      KalXDUP                  ; zdvojen° á°sla EUL do bufferu 3
         pop       di                       ; zaá†tek á°sla 3

; ------ 8. mocnina Eulerova á°sla

         call      KalXMUL                  ; 1. á°slo = EUL^2
         call      KalXDUP                  ; zdvojen° EUL^2 do bufferu á°sla 2
         call      KalXMUL                  ; 1. á°slo = EUL^4
         call      KalXDUP                  ; zdvojen° EUL^4 do bufferu á°sla 2
         call      KalXMUL                  ; 1. á°slo = EUL^8
         call      KalXDUP                  ; zdvojen° EUL^8 do bufferu á°sla 2

; ------ £schova á°sla do z†sobn°ku (do bufferu á°sla 1)

         mov       cx,ds:[KalNumXW]         ; CX <- dÇlka á°sla ve slovech
         mov       di,sp                    ; DI <- zaá†tek 1. á°sla
         push      ds
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lds       si,ss:[bp-4]             ; adresa á°sla
         cld
         rep       movsw                    ; £schova á°sla do z†sobn°ku
         pop       ds

; ------ vynulov†n° st©adaáe vòsledku

         les       di,ss:[bp-4]             ; adresa á°sla
         call      KalXNUL                  ; vynulov†n° st©adaáe vòsledku

; ------ test, zda je á°slo vàt®° neë asi 8 (tj. asi tak 2*EUL)

         push      ss
         pop       es                       ; ES <- z†sobn°k
KalXLN2: mov       di,ss:[bp-12]            ; adresa konce 1. á°sla
         mov       cx,ds:[KalNumNW]         ; CX <- dÇlka celÇ á†sti á°sla
         dec       cx                       ; bez jednoho slova
         dec       di
         dec       di                       ; posledn° slovo á°sla
         xor       ax,ax                    ; AX <- kontrolovanÇ slovo
         std                                ; smàr dolñ
         repe      scasw                    ; kontrola á°sla
         jne       KalXLN3                  ; á°slo je vàt®°
         cmp       word ptr es:[di],8       ; je á°slo OK ?
         jb        KalXLN4                  ; á°slo vyhovuje

; ------ sn°ëen° velikosti á°sla

KalXLN3: add       word ptr ss:[bp-6],8     ; korekce vòsledku
         mov       di,ss:[bp-10]            ; konec 2. á°sla
         call      KalXDIV                  ; vydàlen° á°sla á°slem EUL^8
         jmp       short KalXLN2            ; dal®° test

; ------ test, zda je á°slo men®° neë 1/2981 (tj. 1/EUL^8)

KalXLN4: mov       di,sp                    ; DI <- z†sobn°k
         add       di,ds:[KalNumD]          ; zaá†tek celÇ á†sti
         cmp       word ptr es:[di],0       ; je á°slo < 1 ?
         jne       KalXLN5                  ; je á°slo > 1
         cmp       word ptr es:[di-2],22    ; je á°slo > 1/2981 ?
         jae       KalXLN5                  ; á°slo vyhovuje OK

; ------ zvò®en° velikosti á°sla

         sub       word ptr ss:[bp-6],8     ; korekce vòsledku
         mov       di,ss:[bp-10]            ; konec 2. á°sla
         call      KalXMUL                  ; vyn†soben° á°sla á°slem EUL^8
         jmp       short KalXLN4            ; dal®° test

; ------ posun á°sla do bufferu 2

KalXLN5: mov       di,ss:[bp-12]            ; konec á°sla 1
         call      KalXDUP                  ; kopie á°sla do bufferu 2

; ------ test, zda je á°slo men®° neë 3 (tj. EUL)

KalXLN6: mov       di,ss:[bp-12]            ; adresa á°sla 2
         add       di,ds:[KalNumD]          ; adresa celÇ á†sti á°sla
         cmp       byte ptr es:[di],3       ; je á°slo men®° neë 3 ?
         jb        KalXLN62                 ; á°slo je OK

; ------ sn°ëen° velikosti á°sla

         inc       word ptr ss:[bp-6]       ; korekce vòsledku
         lea       di,ss:[bp-14]            ; konec á°sla 3
         call      KalXDIV                  ; vydàlen° á°sla á°slem EUL
         jmp       short KalXLN6            ; dal®° test

; ------ test, zda je á°slo vàt®° neë 1

KalXLN62:mov       di,ss:[bp-12]            ; zaá†tek á°sla 2
         add       di,ds:[KalNumD]          ; adresa celÇ á†sti á°sla
         cmp       byte ptr es:[di],1       ; je á°slo vàt®° neë 1 ?
         jae       KalXLN64                 ; á°slo je OK

; ------ zvò®en° velikosti á°sla

         dec       word ptr ss:[bp-6]       ; korekce vòsledku
         lea       di,ss:[bp-14]            ; konec á°sla 3
         call      KalXMUL                  ; vyn†soben° á°sla á°slem EUL
         jmp       short KalXLN62           ; dal®° test

; ------ kopie á°sla 2 do bufferu 3

KalXLN64:mov       di,ss:[bp-10]            ; konec á°sla 2
         call      KalXDUP                  ; kopie do bufferu á°sla 3

; ------ inkrementace á°sla v bufferu 3, dekrementace á°sla v bufferu 2 (DI=zaá.3)

         push      di                       ; konec á°sla 3
         call      KalXINC                  ; á°slo 3 se inkrementuje
         mov       di,ss:[bp-10]            ; konec á°sla 2
         call      KalXDEC                  ; á°slo 2 se dekrementuje
         pop       di                       ; konec á°sla 3

; ------ vydàlen° á°sla 2 / á°slo 3 (tj. (X-1)/(X+1)), kopie do bufferu 3

         call      KalXDIV                  ; vydàlen° (X-1)/(X+1)
         call      KalXDUP                  ; kopie do bufferu á°sla 3

; ------ 2. mocnina á°sla 2 (DI=konec á°sla 3)

         call      KalXMUL                  ; á°slo 2 = ((X-1)/(X+1))^2

; ------ z†màna á°sel 2 a 3, á°slo 3 se p©itom n†sob° * 2 (DI=zaá†tek á°sla 3)

         mov       si,ss:[bp-12]            ; SI <- adresa á°sla 2
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         push      ds
         push      ss
         pop       ds                       ; DS <- z†sobn°k
         clc                                ; nen° p©enos
         cld
KalXLN65:lodsw                              ; naáten° slova á°sla 2
         xchg      ax,ds:[di]               ; z†màna s á°slem 3
         rcl       ax,1                     ; á°slo 3 se n†sob° 2* (s p©enosem)
         mov       ds:[si-2],ax             ; uloëen°
         inc       di
         inc       di                       ; zvò®en° adresy
         loop      KalXLN65                 ; dal®° slovo
         pop       ds

; ------ vynulov†n° bufferu á°sla 1

KalXLN7: mov       di,sp                    ; zaá†tek á°sla 1
         call      KalXNUL                  ; vynulov†n° á°sla 1

; ------ p©°prava registrñ k vydàlen° p©°rustku á°slem á°taáe

         mov       bx,ss:[bp-8]             ; á°taá pro dàlen° p©°rustku
         shl       bx,1                     ; á°taá * 2
         inc       bx                       ; + 1
         mov       di,sp                    ; DI <- zaá†tek á°sla 1
         mov       si,ss:[bp-12]            ; adresa á°sla 2
         mov       cx,ss:[bp-14]            ; dÇlka platnÇ á†sti p©°rustku
         xor       dx,dx                    ; DX <- 0 nen° p©enos
         add       si,cx
         add       si,cx                    ; konec platnÇ á†sti 2
         cmp       word ptr ss:[si-2],0     ; zkr†t° se p©°rustek ?
         jne       KalXLN72                 ; nezkr†t° se
         dec       si
         dec       si
         dec       cx                       ; zkr†cen°
         dec       word ptr ss:[bp-14]      ; zkr†cen°
         jz        KalXLN8                  ; konec

KalXLN72:add       di,cx
         add       di,cx                    ; konec platnÇ á†sti 1

; ------ vydàlen° á°sla 2 á°taáem p©°rustku a uloëen° jako á°slo 1

KalXLN74:dec       si
         dec       si                       ; sn°ëen° ukazatele á°sla 2
         dec       di
         dec       di                       ; sn°ëen° ukazatele á°sla 1
         mov       ax,es:[si]               ; slovo p©°rustku 1
         div       bx                       ; vydàlen° á°taáem
         mov       es:[di],ax
         loop      KalXLN74                 ; dal®° slovo

; ------ p©iáten° p©°rustku ke st©adaái

         mov       si,sp                    ; SI <- zaá†tek p©°rustku
         les       di,ss:[bp-4]             ; adresa st©adaáe
         mov       cx,ds:[KalNumDW]         ; dÇlka desetinnÇ á†sti (slov)
         inc       cx                       ; 1 slovo nav°c
         clc                                ; nen° p©enos
KalXLN78:mov       ax,ss:[si]               ; slovo p©°rustku
         adc       es:[di],ax
         inc       si
         inc       si
         inc       di
         inc       di
         loop      KalXLN78                 ; dal®° slovo

; ------ vyn†soben° p©°rustku mocninou

         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lea       di,[bp-14]               ; konec slova 3
         call      KalXMUL                  ; vyn†soben° p©°rustku

; ------ zvò®en° á°taáe

         inc       word ptr ss:[bp-8]       ; zvò®en° á°taáe p©°rustku
         jnz       KalXLN7                  ; dal®° operace

; ------ oprava st©adaáe vòsledku (m† hodnotu 0.0 aë 2.0 !!!)

KalXLN8: les       di,ss:[bp-4]             ; st©adaá vòsledku
         mov       ax,ss:[bp-6]             ; AX <- korekce vòsledku
         add       di,ds:[KalNumD]          ; zaá†tek celÇ á†sti á°sla
         add       word ptr es:[di],ax      ; p©iáten° á°sla korekce
         or        ax,ax                    ; bylo to z†pornÇ á°slo ?
         jns       KalXLN88                 ; nebylo to z†pornÇ á°slo

         mov       cx,ds:[KalNumNW]         ; dÇlka celÇ á†sti (slov)
         dec       cx                       ; bez 1 slova
KalXLN83:inc       di
         inc       di
         dec       word ptr es:[di]         ; p©enos pro z†pornÇ á°slo
         loop      KalXLN83
KalXLN88:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

KalXLN9: mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXLN   ENDP

; -----------------------------------------------------------------------------
;        vòpoáet dekadickÇho logaritmu LOG (pouë°v† 2 pozice v z†sobn°ku á°sel!)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo) + 1 á°slo pouëije !
;        DS=datovò segment
; VùSTUP: CY=p©eteáen° (z†pornÇ á°slo)
; -----------------------------------------------------------------------------

KalXLOG  PROC      NEAR

; ------ vòpoáet p©irozenÇho logaritmu

         call      KalXLN                   ; vòpoáet p©irozenÇho logaritmu
         jc        KalXLOG9

; ------ konstanta 10

         call      KalXNUL                  ; vynulov†n° bufferu
         push      di
         sub       di,ds:[KalNumN]          ; cel† á†st
         mov       byte ptr es:[di],10      ; á°slo "10"
         pop       di

; ------ p©irozenò logaritmus á°sla 10

         call      KalXLN                   ; vòpoáet logaritmu á°sla 10

; ------ vydàlen° logaritmu logaritmem á°sla 10

         call      KalXDIV                  ; vydàlen°
KalXLOG9:ret

KalXLOG  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet funkce COS (DEG nebo RAD podle p©ep°naáe KalParm !)
; -----------------------------------------------------------------------------
; vzorec: COS x = 1 - x^2/2! + x^4/4! - x^6/6! + x^8/8! - ...
; P©ed operac° je á°slo normalizov†no do intervalu 0 aë PI
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; -----------------------------------------------------------------------------

KalXCOS  PROC      NEAR

         push      ax
         mov       al,bit1                  ; je funkce COS
         jmp       short KalXSIN1

KalXCOS  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet funkce SIN (DEG nebo RAD podle p©ep°naáe KalParm !)
; -----------------------------------------------------------------------------
; vzorec: SIN x = x/1! - x^3/3! + x^5/5! - x^7/7! + x^9/9! - ...
; P©ed operac° je á°slo normalizov†no do intervalu 0 aë PI
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) á°taá pro dàlen° p©°rustku
;                   SS:[BP-8] (2) adresa n†sob°c°ho koeficientu v z†sobn°ku
;                   SS:[BP-10] (2) dÇlka platnÇ á†sti p©°rustku (slov)
;                   SS:[BP-11] (1)
;                   SS:[BP-12] (1) bit 0: 1=p©°rustek se odeá°t†
;                                  bit 1: 0=SIN, 1=COS
;                             (KalNumX) n†sob°c° koeficient x^2
;                             (KalNumX) p©°rustek á°sla
; -----------------------------------------------------------------------------

KalXSIN  PROC      NEAR

; ------ £schova registrñ

         push      ax
         mov       al,0                     ; je funkce SIN
KalXSIN1:push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava bufferñ v z†sobn°ku (AL=typ operace)

         sub       sp,12
         mov       cx,ds:[KalNumX]          ; CX <- dÇlka á°sla v bajtech
         sub       sp,cx
         mov       ss:[bp-8],sp             ; adresa n†sob°c°ho koeficientu
         sub       sp,cx

; ------ p©°prava lok†ln°ch promànnòch (AL=typ operace)

         sub       di,cx                    ; zaá†tek á°sla
         mov       ss:[bp-2],es             ; segment bufferu á°sla
         mov       ss:[bp-4],di             ; offset bufferu á°sla
         mov       byte ptr ss:[bp-12],al   ; parametry (bit 1: 1=COS)
         mov       word ptr ss:[bp-6],1     ; á°taá pro dàlen° p©°rustku
         mov       ax,ds:[KalNumDW]         ; dÇlka desetinnÇ á†st (slov)
         inc       ax                       ; + 1 slovo nav°c
         mov       ss:[bp-10],ax            ; dÇlka platnÇ á†sti p©°rustku

; ------ uloëen° á°sla do z†sobn°ku

         mov       di,sp                    ; DI <- buffer á°sla
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla (slov)
         push      ds
         lds       si,ss:[bp-4]             ; adresa á°sla
         cld
         rep       movsw                    ; £schova á°sla
         pop       ds

; ------ naáten° á°sla PI nebo 180

         test      byte ptr ds:[KalParm],bit1 ; pouë°vaj° se RAD ?
         jnz       KalXSN12                 ; pouë°vaj° se RAD
         call      KalXNUL                  ; vynulov†n° bufferu
         push      di
         sub       di,ds:[KalNumN]          ; zaá†tek celÇ á†sti
         mov       byte ptr es:[di],180     ; 180 stup§ñ
         pop       di
         jmp       short KalXSN14

KalXSN12:call      KalXPI                   ; naáten° á°sla PI

; ------ p©iáten° PI/2 (nebo 180/2) pro COS

KalXSN14:test      byte ptr ss:[bp-12],bit1 ; je to SIN ?
         jz        KalXSIN2                 ; je to SIN
         call      KalXRLD                  ; vydàlen° PI/2 (180/2)
         call      KalXADD                  ; p©iáten° PI/2 (180/2) pro COS
         push      di
         lea       di,[bp-12]               ; konec á°sla 2 (=PI/2 nebo 180/2)
         call      KalXRLU                  ; vyn†soben° zpàt na PI (180)
         pop       di

; ------ test, zda je á°slo z†pornÇ, absolutn° hodnota á°sla

KalXSIN2:call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXSIN3                 ; á°slo nebylo z†pornÇ
         xor       byte ptr ss:[bp-12],bit0 ; zmàna znamÇnka

; ------ omezen° na interval á°sla PI (180)

KalXSIN3:lea       di,[bp-12]               ; konec á°sla PI (180)
         call      KalXDIV                  ; vydàlen° á°slem PI (180)
         push      di
         sub       di,ds:[KalNumN]          ; zaá†tek celÇ á†sti
         test      byte ptr es:[di],bit0    ; je to lich† sekce PI ?
         pop       di
         jz        KalXSN32                 ; nen° to lich† sekce
         xor       byte ptr ss:[bp-12],bit0 ; zmàna znamÇnka pro SIN
KalXSN32:call      KalXFRA                  ; o©ez†n° celÇ á†sti á°sla
         test      byte ptr ds:[KalParm],bit1 ; pouë°vaj° se RAD ?
         jnz       KalXSN34                 ; pouë°vaj° se RAD
         call      KalXPI                   ; pro DEG je pot©eba naá°st PI
KalXSN34:lea       di,[bp-12]               ; konec á°sla PI
         call      KalXMUL                  ; n†vrat á°sla vyn†soben°m * PI

; ------ druh† mocnina á°sla v bufferu 2

         call      KalXDUP                  ; zdvojen° á°sla
         push      di
         call      KalXMUL                  ; druh† mocnina á°sla
         pop       di
         call      KalXXCH                  ; z†màna á°sel v bufferech

; ------ vynulov†n° st©adaáe

         les       di,ss:[bp-4]             ; adresa st©adaáe
         call      KalXNUL                  ; vynulov†n° st©adaáe

; ------ p©iáten°/odeáten° á°sla p©°rustku ke st©adaái

         push      ss
         pop       es

KalXSIN4:mov       si,sp                    ; SI <- p©°rustek
         mov       cx,ds:[KalNumXW]         ; poáet slov á°sla

         push      ds
         les       di,ss:[bp-4]             ; adresa st©adaáe
         push      ss
         pop       ds                       ; DS <- z†sobn°k
         cld
         test      byte ptr ss:[bp-12],bit0 ; p©°rustek se odeá°t† ?
         jnz       KalXSN52                 ; p©°rustek se odeá°t†

KalXSIN5:lodsw
         adc       es:[di],ax
         inc       di
         inc       di
         loop      KalXSIN5
         jmp       short KalXSN54

KalXSN52:lodsw
         sbb       es:[di],ax
         inc       di
         inc       di
         loop      KalXSN52

KalXSN54:pop       ds
         xor       byte ptr ss:[bp-12],bit0 ; zmàna p©°znaku pro p©°®tà

; ------ vyn†soben° p©°rustku koeficientem x^2

         push      ss
         pop       es                       ; ES <- z†sobn°k
         lea       di,[bp-12]               ; konec á°sla 2
         call      KalXMUL                  ; vyn†soben° p©°rustku

; ------ p©°prava k vydàlen° p©°rustku

         mov       cx,ss:[bp-10]            ; dÇlka platnÇ á†sti á°sla
         mov       di,sp                    ; DI <- á°slo 1
         add       di,cx
         add       di,cx                    ; konec p©°rustku
         cmp       word ptr es:[di-2],0     ; je slovo jië = 0 ?
         jne       KalXSIN6                 ; je®tà nen° = 0
         dec       di
         dec       di
         dec       cx
         dec       word ptr ss:[bp-10]
         jz        KalXSIN8                 ; konec

; ------ vydàlen° p©°rustku

KalXSIN6:inc       word ptr ss:[bp-6]       ; zvò®en° á°taáe
         mov       bx,ss:[bp-6]             ; á°taá

         xor       dx,dx                    ; nen° p©enos
         push      di
         push      cx
KalXSN62:dec       di
         dec       di
         mov       ax,es:[di]
         div       bx
         mov       es:[di],ax
         loop      KalXSN62
         pop       cx
         pop       di

; ------ vydàlen° p©°rustku podruhÇ

         inc       word ptr ss:[bp-6]       ; zvò®en° á°taáe
         inc       bx                       ; á°taá

         xor       dx,dx                    ; nen° p©enos
KalXSN64:dec       di
         dec       di
         mov       ax,es:[di]
         div       bx
         mov       es:[di],ax
         loop      KalXSN64

         jmp       short KalXSIN4

; ------ n†vrat registrñ

KalXSIN8:clc
KalXSIN9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KalXSIN  ENDP

; -----------------------------------------------------------------------------
;        o©ez†n° celÇ á†sti á°sla ES:DI (=konec), DS=datovò segment
; -----------------------------------------------------------------------------

KalXFRA  PROC      NEAR

         call      KalKInt                  ; korekce p©ed celoá°selnou operac°

; ------ £schova registrñ

         push      ax
         push      cx

; ------ o©ez†n° celÇ á†sti á°sla

         xor       ax,ax                    ; AX <- 0 pro kladnÇ á°slo
         test      byte ptr es:[di-1],bit7  ; je to kladnÇ á°slo ?
         jz        KalXFRA2                 ; je to kladnÇ á°slo
         dec       ax                       ; AX <- -1 pro z†pornÇ á°slo
KalXFRA2:sub       di,ds:[KalNumN]          ; zaá†tek celÇho á°sla
         mov       cx,ds:[KalNumNW]         ; dÇlka celÇho á°sla (slov)
         cld
         rep       stosw                    ; vymaz†n° celÇ á†sti á°sla

; ------ n†vrat registrñ

         pop       cx
         pop       ax
         clc
         ret

KalXFRA  ENDP

; -----------------------------------------------------------------------------
;        o©ez†n° desetinnÇ á†sti á°sla ES:DI (=konec), DS=datovò segment
; -----------------------------------------------------------------------------

;KalFINT  PROC      FAR
;
;         call      KalXINT
;         ret
;
;KalFINT  ENDP

KalXINT  PROC      NEAR

         call      KalKInt                  ; korekce p©ed celoá°selnou operac°

; ------ £schova registrñ

         push      ax
         push      cx

; ------ o©ez†n° desetinnÇ á†sti á°sla

         push      di
         xor       ax,ax                    ; AX <- 0 pro kladnÇ á°slo
         sub       di,ds:[KalNumX]          ; zaá†tek á°sla
         mov       cx,ds:[KalNumDW]         ; dÇlka desetin á°sla (slov)
         cld

         push      di
         push      cx
         repe      scasw                    ; test, zda je desetinn† á†st = 0
         pop       cx
         pop       di

         rep       stosw                    ; vymaz†n° desetinnÇ á†sti á°sla
         pop       di
         je        KalXINT2                 ; desetiny byly = 0

; ------ zvò®en° o 1, je-li z†pornÇ á°slo (a jsou-li desetiny <> 0)

         test      byte ptr es:[di-1],bit7  ; je to kladnÇ á°slo ?
         jz        KalXINT2                 ; je to kladnÇ á°slo
         call      KalXINC                  ; zvò®en° o 1

; ------ n†vrat registrñ

KalXINT2:pop       cx
         pop       ax
         clc
         ret

KalXINT  ENDP

; -----------------------------------------------------------------------------
;        korekce á°sla ES:DI p©ed celoá°selnou operac°, DS=datovò segment
; -----------------------------------------------------------------------------

KalKInt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ adresa k p©iáten° korekce

         mov       bl,es:[di-1]             ; nejvy®®° bajt á°sla
         mov       cx,ds:[KalNumX]          ; poáet bajtñ na á°slo celkem
         sub       di,cx                    ; zaá†tek celÇ á†sti á°sla
         cld
         mov       ax,ds:[KalNumD]          ; poáet bajtñ desetinnÇ á†sti
         shl       ax,1                     ; asi tak á°slic desetinnÇ á†sti
         sub       ax,ds:[KalkMist]         ; asi tak skrytòch á°slic
         jnc       KalKInt2                 ; nen° podteáen°
         xor       ax,ax                    ; omezen°
KalKInt2:shr       ax,1                     ; skryt† á†st v bajtech
         shr       ax,1                     ; polovina skrytÇ á†sti
         shr       ax,1                     ; to je asi tak offset korekce
         add       di,ax                    ; poá†tek ke korekci
         sub       cx,ax                    ; poáet bajtñ ke korekci

; ------ odeáten° korekce

         xor       ax,ax
         or        bl,bl                    ; je z†pornÇ á°slo ?
         stc                                ; poá†teán° p©enos korekce
         jns       KalKInt6                 ; je kladnÇ á°slo

; ------ odeáten° korekce

KalKInt4:sbb       byte ptr es:[di],al      ; korekce
         inc       di
         loop      KalKInt4
         jmp       short KalKInt8

; ------ p©iáten° korekce

KalKInt6:adc       byte ptr es:[di],al      ; korekce
         inc       di
         loop      KalKInt6

; ------ n†vrat registrñ

KalKInt8:pop       cx
         pop       bx
         pop       ax
         ret

KalKInt  ENDP

; -----------------------------------------------------------------------------
;        vòpoáet odmocniny SQRT
; -----------------------------------------------------------------------------
; vzorec: D = x-1
; SQRT x = 1 + 1/2*D - 1/(2*4)*D^2 + (1*3)/(2*4*6)*D^3 - (1*3*5)/(2*4*6*8)*D^4 +
; P©ed operac° je á°slo normalizov†no do intervalu 0.4 aë 1.6
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; VùSTUP: CY=p©eteáen° (z†pornÇ á°slo)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla (zaá†tek)
;                   SS:[BP-6] (2) korekce vòsledku (poáet rotac° *2 nebo /2)
;                   SS:[BP-8] (2) á°taá pro dàlen° p©°rustku/2
;                   SS:[BP-10] (2) adresa n†sob°c°ho koeficientu v z†sobn°ku
;                   SS:[BP-12] (2) dÇlka platnÇ á†sti p©°rustku (slov)
;                   SS:[BP-13] (1)
;                   SS:[BP-14] (1) bit 0: 1=koeficient se odeá°t†
;                                  bit 1: 1=koeficient se odeá°t† vëdy
;                             (KalNumX) n†sob°c° koeficient (x-1)
;                             (KalNumX) p©°rustek á°sla
; -----------------------------------------------------------------------------

;KalFSQR  PROC      FAR
;
;         call      KalXSQR
;         ret
;
;KalFSQR  ENDP


KalXSQR  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ p©°prava bufferñ v z†sobn°ku

         sub       sp,14
         mov       cx,ds:[KalNumX]          ; dÇlka á°sla v bajtech
         sub       sp,cx
         mov       ss:[bp-10],sp            ; adresa n†sob°c°ho koeficientu
         sub       sp,cx

; ------ kontrola, zda je á°slo kladnÇ

         test      byte ptr es:[di-1],bit7  ; je á°slo kladnÇ ?
         jz        KalXSQR2                 ; á°slo je kladnÇ OK
KalXSQR0:stc                                ; p©°znak chyby á°sla
KalXSQR1:jmp       KalXSQR9                 ; chyba á°sla

; ------ p©°prava lok†ln°ch promànnòch

KalXSQR2:sub       di,cx                    ; adresa zaá†tku á°sla
         mov       ss:[bp-2],es             ; segment á°sla
         mov       ss:[bp-4],di             ; offset á°sla
         mov       word ptr ss:[bp-6],0     ; korekce vòsledku
         mov       word ptr ss:[bp-8],0     ; á°taá pro dàlen° p©°rustku
         mov       ax,ds:[KalNumDW]         ; dÇlka platnÇ á†sti p©°rustku
         inc       ax                       ; + cel† á†st
         mov       ss:[bp-12],ax            ; dÇlka platnÇ á†sti p©°rustku

; ------ test, zda je á°slo = 0 (CX=dÇlka á°sla v bajtech)

         xor       ax,ax                    ; AX <- 0
         mov       ss:[bp-14],ax            ; parametry
         cld
         shr       cx,1                     ; dÇlka á°sla ve slovech
         repe      scasw                    ; test, zda je á°slo = 0
         je        KalXSQR1                 ; á°slo je = 0, to je OK

; ------ £schova á°sla do z†sobn°ku

         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         mov       si,ss:[bp-4]             ; SI <- adresa á°sla
         mov       di,ss:[bp-10]            ; adresa n†sob°c°ho koeficientu
         push      ds

         push      es
         pop       ds                       ; DS <- segment á°sla
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         cld
         rep       movsw                    ; £schova á°sla do z†sobn°ku

         pop       ds

; ------ vynulov†n° st©adaáe vòsledku a nastaven° na poá†teán° "1"

         les       di,ss:[bp-4]             ; adresa á°sla
         call      KalXNUL                  ; vynulov†n° st©adaáe vòsledku
         call      KalXINC                  ; nastaven° na poá†teán° "1"
         push      ss
         pop       es                       ; ES <- z†sobn°k

; ------ test, zda je á°slo > 64K (AX=0!)

KalXSQR3:lea       di,[bp-14-2]             ; offset posledn°ho slova á°sla
         mov       cx,ds:[KalNumNW]         ; dÇlka celÇ á†sti ve slovech
         dec       cx                       ; bez 1 slova
         std                                ; dolñ
         repe      scasw                    ; test
         je        KalXSQR4                 ; á°slo je OK

; ------ posun á°sla o 1 slovo dolñ

         add       word ptr ss:[bp-6],8     ; mus° se 8* zn†sobit 2
         lea       di,[bp-14]               ; konec á°sla
         call      KalXRWD                  ; posun á°sla o slovo dolñ
         jmp       short KalXSQR3

; ------ test, zda je á°slo < 1/64K (AX=0!)

KalXSQR4:mov       di,ss:[bp-10]            ; adresa á°sla
         mov       cx,ds:[KalNumD]          ; poáet bajtñ desetin
         add       di,cx                    ; adresa celÇ á†sti
         cmp       es:[di],ax
         jne       KalXSQR5                 ; je to OK
         cmp       es:[di-2],ax             ; je vàt®° neë 1/64K ?
         jne       KalXSQR5                 ; je OK

; ------ posun á°sla o 1 slovo nahoru

         sub       word ptr ss:[bp-6],8     ; mus° se 8* vydàlit 2
         lea       di,[bp-14]               ; konec á°sla
         call      KalXRWU                  ; posun á°sla o slovo nahoru
         jmp       short KalXSQR4

; ------ test, zda je á°slo > 1.6

KalXSQR5:mov       di,ss:[bp-10]            ; adresa á°sla
         mov       cx,ds:[KalNumD]          ; poáet bajtñ desetin
         add       di,cx                    ; adresa zaá†tku celÇho á°sla
         cmp       word ptr es:[di],2       ; je á°slo 2 a vàt®° ?
         jae       KalXSQ52                 ; je 2 a vàt®°
         cmp       word ptr es:[di-1],409   ; je vàt®° neë 1.6 ?
         jbe       KalXSQ55                 ; nen° men®° neë 1.6 - je to OK

; ------ rotace á°sla o 2 bity dolñ

KalXSQ52:inc       word ptr ss:[bp-6]       ; mus° se zn†sobit 2
         lea       di,[bp-14]               ; konec á°sla
         call      KalXRLD                  ; posun o 1 bit dolñ
         call      KalXRLD                  ; posun o 1 bit dolñ
         jmp       short KalXSQR5

; ------ test, zda je á°slo < 0.4

KalXSQ55:mov       di,ss:[bp-10]            ; adresa á°sla
         mov       cx,ds:[KalNumD]          ; poáet bajtñ desetin
         add       di,cx                    ; adresa zaá†tku celÇho á°sla
         cmp       word ptr es:[di-1],102   ; je vàt®° neë 0.4 ?
         jae       KalXSQR6                 ; je vàt®° neë 0.4 - je to OK

; ------ rotace á°sla o 2 bity nahoru

         dec       word ptr ss:[bp-6]       ; mus° se vydàlit 2
         lea       di,[bp-14]               ; konec á°sla
         call      KalXRLU                  ; posun o 1 bit nahoru
         call      KalXRLU                  ; posun o 1 bit nahoru
         jmp       short KalXSQ55

; ------ p©°prava p©°rustku

KalXSQR6:mov       di,sp                    ; DI <- adresa p©°rustku
         call      KalXNUL                  ; vynulov†n° p©°rustku
         call      KalXINC                  ; nastaven° p©°rustku na "1"

; ------ nastaven° koeficientu - 1

         lea       di,[bp-14]               ; konec koeficientu
         call      KalXDEC                  ; sn°ëen° koeficientu o 1

; ------ test, zda je koeficient nyn° z†pornò

         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalXSQR7                 ; á°slo nebylo z†pornÇ
         or        byte ptr ss:[bp-14],bit1 ; odeá°t† se vëdy

; ------ vyn†soben° p©°rustku koeficientem (koeficient < 1, proto neprodlouë°)

KalXSQR7:lea       di,[bp-14]               ; adresa konce koeficientu
         push      ss
         pop       es                       ; ES <- z†sobn°k
         call      KalXMUL                  ; vyn†soben° koeficientem

; ------ test, zda je jië p©°rustek = 0

         mov       cx,ss:[bp-12]            ; dÇlka platnÇ á†sti (slov)
         mov       di,sp                    ; adresa p©°rustku
         add       di,cx
         add       di,cx                    ; adresa konce
         dec       di
         dec       di                       ; posledn° slovo p©°rustku
         cmp       word ptr es:[di],0       ; je jië = 0 ?
         jne       KalXSQ72                 ; nen° = 0
         dec       di
         dec       di                       ; posun adresy
         dec       cx                       ; sn°ëen° dÇlky
         dec       word ptr ss:[bp-12]      ; sn°ëen° dÇlky
         jz        KalXSQR8                 ; p©°rustek je jië = 0

; ------ vydàlen° p©°rustku sudòm á°slem á°taáe

KalXSQ72:inc       word ptr ss:[bp-8]       ; zvò®en° á°taáe pro dàlen°
         mov       bx,ss:[bp-8]             ; á°taá pro dàlen° p©°rustku
         shl       bx,1                     ; á°taá * 2
         xor       dx,dx                    ; DX <- 0 nen° p©enos

         push      cx
KalXSQ73:mov       ax,es:[di]
         div       bx
         mov       es:[di],ax
         dec       di
         dec       di
         loop      KalXSQ73
         pop       cx

; ------ vyn†soben° p©°rustku lichòm á°slem á°taáe

         sub       bx,3
         jbe       KalXSQ75
         xor       si,si                    ; SI <- nen° p©enos
KalXSQ74:inc       di
         inc       di
         mov       ax,es:[di]
         mul       bx
         add       ax,si
         adc       dx,0
         mov       es:[di],ax
         mov       si,dx
         loop      KalXSQ74
         or        dx,dx                    ; je p©enos ?
         jz        KalXSQ75
         mov       es:[di+2],dx             ; dÇlka se zase zvò®°
         inc       word ptr ss:[bp-12]      ; zvò®en° dÇlky

; ------ p©iáten°/odeáten° p©°rustku k á°slu

KalXSQ75:cld
         les       di,ss:[bp-4]             ; adresa st©adaáe
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         mov       si,sp                    ; p©°rustek

         push      ds
         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
         test      byte ptr ss:[bp-14],bit0+bit1 ; odeá°t† se ?
         jz        KalXSQ77                 ; neodeá°t† se
                                           ;* je NC
KalXSQ76:lodsw
         sbb       word ptr es:[di],ax
         inc       di
         inc       di
         loop      KalXSQ76
         jmp       short KalXSQ79

KalXSQ77:lodsw
         adc       word ptr es:[di],ax
         inc       di
         inc       di
         loop      KalXSQ77

KalXSQ79:pop       ds
         xor       byte ptr ss:[bp-14],bit0 ; zmàna p©°znaku
         jmp       KalXSQR7

; ------ oprava á°sla

KalXSQR8:les       di,ss:[bp-4]             ; adresa á°sla
         add       di,ds:[KalNumX]          ; adresa konce á°sla
         mov       ax,ss:[bp-6]             ; korekce vòsledku
         or        ax,ax                    ; bude dàlen° ?
         js        KalXSQ83                 ; bude dàlen°

KalXSQ81:cmp       ax,16                    ; je dost bitñ ?
         jb        KalXSQ82
         sub       ax,16
         call      KalXRWU                  ; posun o slovo nahoru
         jmp       short KalXSQ81

KalXSQ82:or        ax,ax
         jz        KalXSQ88
         dec       ax
         call      KalXRLU                  ; posun o 1 bit nahoru
         jmp       short KalXSQ82

KalXSQ83:neg       ax

KalXSQ84:cmp       ax,16                    ; je dost bitñ ?
         jb        KalXSQ85
         sub       ax,16
         call      KalXRWD                  ; posun o slovo dolñ
         jmp       short KalXSQ84

KalXSQ85:or        ax,ax
         jz        KalXSQ88
         dec       ax
         call      KalXRLD                  ; posun o 1 bit dolñ
         jmp       short KalXSQ85

KalXSQ88:clc

; ------ n†vrat registrñ

KalXSQR9:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      KalErOvf                 ; hl†®en° chyby p©eteáen°
         ret

KalXSQR  ENDP

; -----------------------------------------------------------------------------
;        posun á°sla ES:DI (=konec) o slovo dolñ
; -----------------------------------------------------------------------------

KalXRWD  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      ds

; ------ posun á°sla o slovo dolñ

         sub       di,ds:[KalNumX]          ; zaá†tek á°sla
         mov       si,di                    ; SI <- zaá†tek á°sla
         inc       si
         inc       si                       ; 2. slovo á°sla
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         dec       cx                       ; bez 1 slova
         cld                                ; smàr nahoru
         push      es
         pop       ds                       ; DS <- segment á°sla
         rep       movsw                    ; p©esun á°sla
         mov       ds:[di],cx               ; posledn° uvolnànÇ slovo

; ------ n†vrat registrñ

         pop       ds
         pop       di
         pop       si
         pop       cx
         clc
         ret

KalXRWD  ENDP

; -----------------------------------------------------------------------------
;        posun á°sla ES:DI (=konec) o slovo nahoru
; -----------------------------------------------------------------------------

KalXRWU  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      ds

; ------ posun á°sla o slovo nahoru

         dec       di
         dec       di                       ; posledn° slovo á°sla
         mov       si,di                    ; SI <- posledn° slovo á°sla
         dec       si
         dec       si                       ; p©edposledn° slovo á°sla
         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         dec       cx                       ; bez 1 slova
         std                                ; smàr dolñ
         push      es
         pop       ds                       ; DS <- segment á°sla
         rep       movsw                    ; p©esun á°sla
         mov       ds:[di],cx               ; prvn° slovo

; ------ n†vrat registrñ

         pop       ds
         pop       di
         pop       si
         pop       cx
         clc
         ret

KalXRWU  ENDP

; -----------------------------------------------------------------------------
;        posun á°sla ES:DI (=konec) o 1 bit dolñ
; -----------------------------------------------------------------------------

KalXRLD  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di
         push      ds

; ------ posun á°sla o 1 bit dolñ

         mov       cx,ds:[KalNumXW]         ; dÇlka á°sla ve slovech
         push      es
         pop       ds                       ; DS <- segment á°sla
         clc                                ; nen° p©enos
KalXRLD2:dec       di
         dec       di                       ; posun adresy
         rcr       word ptr ds:[di],1       ; rotace o 1 bit vpravo
         loop      KalXRLD2                 ; dal®° slovo

; ------ n†vrat registrñ

         pop       ds
         pop       di
         pop       cx
         clc
         ret

KalXRLD  ENDP

; -----------------------------------------------------------------------------
;        posun á°sla ES:DI (=konec) o 1 bit nahoru
; -----------------------------------------------------------------------------

KalXRLU  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      di
         push      ds

; ------ posun á°sla o 1 bit nahoru

         mov       cx,ds:[KalNumX]          ; dÇlka á°sla v bajtech
         sub       di,cx                    ; zaá†tek á°sla
         shr       cx,1                     ; dÇlka á°sla ve slovech
         push      es
         pop       ds                       ; DS <- segment á°sla
         clc                                ; nen° p©enos
KalXRLU2:rcl       word ptr ds:[di],1       ; rotace o 1 bit vlevo
         inc       di
         inc       di                       ; posun adresy
         loop      KalXRLU2                 ; dal®° slovo

; ------ n†vrat registrñ

         pop       ds
         pop       di
         pop       cx
         clc
         ret

KalXRLU  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace ABS
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; VùSTUP: CY=byla zmàna znamÇnka
; -----------------------------------------------------------------------------

;KalFABS  PROC      FAR
;
;         call      KalXABS
;         clc
;         ret
;
;KalFABS  ENDP


KalXABS0:call      KalXABS
         clc                                ; operace OK
         ret

KalXABS  PROC      NEAR

         test      byte ptr es:[di-1],bit7  ; je to z†pornÇ á°slo ?
         jz        KalXABS2                 ; je to kladnÇ á°slo
         call      KalXNEG                  ; negace á°sla
         stc                                ; p©°znak zmàny znamÇnka
KalXABS2:ret

KalXABS  ENDP

; -----------------------------------------------------------------------------
;        proveden° operace NEG
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel vrcholu z†sobn°ku á°sel (1 á°slo)
;        DS=datovò segment
; -----------------------------------------------------------------------------

;KalFNEG  PROC      FAR
;
;         call      KalXNEG
;         ret
;
;KalFNEG  ENDP


KalXNEG  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      ds

; ------ p©°prava registrñ

         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ na á°slo
         sub       di,cx                    ; DI <- zaá†tek á°sla
         shr       cx,1                     ; CX <- poáet slov na á°slo
         push      es
         pop       ds                       ; DS <- segment z†sobn°ku á°sel
         mov       ah,bit0                  ; bude p©enos
KalXNEG2:not       word ptr ds:[di]         ; operace NOT
         sahf                               ; nastaven° p©°znakñ do FLAG
         adc       word ptr ds:[di],0       ; p©enos
         lahf                               ; naáten° p©°znakñ do AH
         inc       di
         inc       di                       ; zvò®en° ukazatele v 1. á°sle
         loop      KalXNEG2                 ; dal®° slovo v á°sle

; ------ n†vrat registrñ

         pop       ds
         pop       cx
         pop       ax
         clc
         ret

KalXNEG  ENDP

; -----------------------------------------------------------------------------
;        zdvojen° á°sla na vrcholu z†sobn°ku ES:DI -> ES:DI se zvò®° o á°slo
; -----------------------------------------------------------------------------

KalXDUP  PROC      NEAR

         push      cx
         push      si
         push      ds

         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ á°sla
         mov       si,di                    ; SI <- konec z†sobn°ku
         sub       si,cx                    ; SI <- zaá†tek bufferu á°sla
         push      es
         pop       ds                       ; DS <- segment bufferu
         cld
         shr       cx,1                     ; CX <- poáet slov á°sla
         rep       movsw                    ; kopie á°sla

         pop       ds
         pop       si
         pop       cx
         clc
         ret

KalXDUP  ENDP

; -----------------------------------------------------------------------------
;        z†màna 2 á°sel na vrcholu z†sobn°ku ES:DI
; -----------------------------------------------------------------------------

KalXXCH  PROC      NEAR

         push      ax
         push      cx
         push      si
         push      ds

         mov       cx,ds:[KalNumX]          ; CX <- poáet bajtñ á°sla
         sub       di,cx                    ; DI <- zaá†tek bufferu á°sla 2
         mov       si,di
         sub       si,cx                    ; SI <- zaá†tek bufferu á°sla 1

         push      es
         pop       ds                       ; DS <- segment bufferu
         cld
         shr       cx,1                     ; CX <- poáet slov á°sla
KalXXCH2:lodsw                              ; naáten° slova á°sla 1
         xchg      ax,ds:[di]               ; z†màna s bufferem 2
         mov       ds:[si-2],ax             ; uloëen° do bufferu 1
         inc       di
         inc       di                       ; zvò®en° adresy
         loop      KalXXCH2                 ; dal®° slovo

         pop       ds
         pop       si
         pop       cx
         pop       ax
         clc
         ret

KalXXCH  ENDP

; -----------------------------------------------------------------------------
;        inkrementace á°sla ES:DI=konec á°sla (DS=datovò segment)
; -----------------------------------------------------------------------------

KalXINC  PROC      NEAR

         push      ax
         push      cx
         push      di
         push      ds

         mov       cx,ds:[KalNumNW]         ; dÇlka celÇ á†sti ve slovech
         sub       di,cx
         sub       di,cx                    ; adresa celÇ á†sti
         xor       ax,ax                    ; AX <- 0
         push      es
         pop       ds                       ; DS <- segment
         stc                                ; p©enos
KalXINC2:adc       ds:[di],ax               ; p©enos
         jnc       KalXINC3                 ; nen° dal®° p©enos
         inc       di
         inc       di
         loop      KalXINC2

KalXINC3:pop       ds
         pop       di
         pop       cx
         pop       ax
         clc
         ret

KalXINC  ENDP

; -----------------------------------------------------------------------------
;        dekrementace á°sla ES:DI=konec á°sla (DS=datovò segment)
; -----------------------------------------------------------------------------

KalXDEC  PROC      NEAR

         push      ax
         push      cx
         push      di
         push      ds

         mov       cx,ds:[KalNumNW]         ; dÇlka celÇ á†sti ve slovech
         sub       di,cx
         sub       di,cx                    ; adresa celÇ á†sti
         xor       ax,ax                    ; AX <- 0
         push      es
         pop       ds                       ; DS <- segment
         stc                                ; p©enos
KalXDEC2:sbb       ds:[di],ax               ; p©enos
         jnc       KalXDEC3                 ; nen° dal®° p©enos
         inc       di
         inc       di
         loop      KalXDEC2

KalXDEC3:pop       ds
         pop       di
         pop       cx
         pop       ax
         clc
         ret

KalXDEC  ENDP

; -----------------------------------------------------------------------------
;        uloëen° á°sla "0" do bufferu ES:DI -> zvò®en° ES:DI (DS=datovò segment)
; -----------------------------------------------------------------------------

KalFNUL  PROC      FAR

         call      KalXNUL
         ret

KalFNUL  ENDP

KalXNUL  PROC      NEAR

         push      ax
         push      cx

         mov       cx,ds:[KalNumXW]         ; CX <- poáet slov á°sla
         xor       ax,ax                    ; AX <- 0 nulovac° slovo
         cld
         rep       stosw                    ; vynulov†n° á°sla

         pop       cx
         pop       ax
;         clc
         ret

KalXNUL  ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer z textu SS:SI -> AX p©ipravenÇ 2 znaky
; -----------------------------------------------------------------------------

KalkSPC  PROC      NEAR

         cld
KalkSPC1:lods      word ptr ss:[si]         ; AX <- p©ipravenÇ 2 znaky
         dec       si                       ; n†vrat na p©°®t° znak
         cmp       al,ds:[OddelRad]
         je        KalkSPC1                 ; oddàlovaá ©†dñ se vypust°
         cmp       al," "                   ; je p©ipravenò znak mezera ?
         je        KalkSPC1                 ; je mezera - dal®° znak
         dec       si                       ; n†vrat na prvn° znak
         ret

KalkSPC  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°sla do textovÇho tvaru
; -----------------------------------------------------------------------------

KalkDekF PROC      FAR

         call      KalkDek
         ret

KalkDekF ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°sla do textovÇho tvaru
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=vrchol z†sobn°ku á°sel (1 á°slo)
;        DX:SI=buffer k uloëen° á°sla
;        CX=max. velikost bufferu k uloëen° á°sla (max. znakñ k uloëen°)
;        DS=datovò segment
; VùSTUP: ES:DI=vrchol z†sobn°ku á°sel sn°ëenò o 1 á°slo
;         DX:SI=konec za uloëenòm á°slem
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment bufferu á°sla
;                   SS:[BP-4] (2) offset bufferu á°sla
;                   SS:[BP-6] (2) segment k uloëen° textu á°sla
;                   SS:[BP-8] (2) offset k uloëen° textu á°sla
;                   SS:[BP-10] (2) á°taá slov (znakñ) v z†sobn°ku
;                   SS:[BP-12] (2) velikost bufferu k uloëen° á°sla
;                   SS:[BP-14] (2) zaá†tek bufferu k uloëen° textu á°sla
; -----------------------------------------------------------------------------
;˛
KalkDek  PROC      NEAR

; ------ £schova registrñ

         sub       di,ds:[KalNumX]          ; sn°ëen° bufferu á°sla
         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava lok†ln°ch promànnòch

         sub       sp,14
         mov       ss:[bp-2],es             ; segment bufferu á°sla
         mov       ss:[bp-4],di             ; offset bufferu á°sla
         mov       ss:[bp-6],dx             ; segment k uloëen° á°sla
         mov       ss:[bp-8],si             ; offset k uloëen° á°sla
         mov       word ptr ss:[bp-10],0    ; á°taá slov v z†sobn°ku
         mov       ss:[bp-12],cx            ; velikost vòstupn°ho bufferu
         mov       ss:[bp-14],si            ; zaá†tek bufferu k uloëen° á°sla

; ------ dek¢dov†n° znamÇnka "-" á°sla

         add       di,ds:[KalNumX]          ; konec á°sla k dek¢dov†n°
         call      KalXABS                  ; absolutn° hodnota á°sla
         jnc       KalkDek1                 ; á°slo nebylo z†pornÇ
         mov       al,"-"                   ; znamÇnko "-"
         call      KalkDk                   ; uloëen° znamÇnka "-"
         inc       word ptr ss:[bp-14]      ; oprava adresy poá†tku á°sla

; ------ vydàlen° celÇ á†sti á°sla z†kladem á°selnÇ soustavy

KalkDek1:les       di,ss:[bp-4]             ; adresa bufferu á°sla
         add       di,ds:[KalNumX]          ; konec á°sla k dek¢dov†n°
         xor       si,si                    ; SI <- st©adaá kontroly 0 á°sla
         xor       dx,dx                    ; DX <- 0 nen° p©enos
         mov       bx,ds:[KalkZakl]         ; z†klad á°selnÇ soustavy
         mov       cx,ds:[KalNumN]          ; dÇlka celÇ á†sti v bajtech
         shr       cx,1                     ; dÇlka celÇ á†sti ve slovech
KalkDek2:dec       di
         dec       di                       ; sn°ëen° ukazatele á°sla
         mov       ax,es:[di]               ; slovo á°sla
         div       bx                       ; vydàlen° z†kladem á°selnÇ soustavy
         mov       es:[di],ax               ; uloëen° novÇho slova
         or        si,ax                    ; st©adaá testu 0
         loop      KalkDek2                 ; dal®° slovo á°sla

; ------ korekce á°sla na znak ASCII a uloëen° do z†sobn°ku

         cmp       dl,10                    ; je >= 10 ?
         jb        KalkDek3                 ; je < 10
         add       dl,7                     ; korekce pro p°smeno
KalkDek3:add       dl,"0"                   ; korekce na znak ASCII
         push      dx                       ; £schova á°slice do z†sobn°ku
         inc       word ptr ss:[bp-10]      ; á°taá slov v z†sobn°ku

; ------ nen°-li je®tà 0, vòpoáet dal®° á°slice

         or        si,si                    ; je á°slo jië = 0 ?
         jnz       KalkDek1                 ; vòpoáet dal®° á°slice

; ------ vòpoáet odsazen° ©†dñ -> DX

         xor       dx,dx                    ; DX <- 0
         mov       cx,ss:[bp-10]            ; CX <- poáet á°slic v z†sobn°ku
         mov       ax,cx                    ; AX <- poáet á°slic v z†sobn°ku
         dec       ax                       ; p©ednastaven° - 1
         div       word ptr ds:[KalkOdsz]   ; vòpoáet zbytku v ©†du
         inc       dx                       ; DX <- p©ednastaven° + 1

; ------ dek¢dov†n° celÇ á†sti á°sla

KalkDek4:pop       ax                       ; n†vrat á°slice ze z†sobn°ku
         call      KalkDk                   ; uloëen° á°slice do bufferu
         dec       dx                       ; sn°ëen° á°taáe znakñ v ©†du
         jnz       KalkDek5                 ; nen° dal®° odsazen°
         mov       dx,ds:[KalkOdsz]         ; novò á°taá odsazen°
         cmp       cx,1                     ; je jië posledn° á°slice ?
         je        KalkDek5                 ; je jië posledn° á°slice - nic
         mov       al,ds:[OddelRad]         ; oddàlovac° znak ©†dñ
         call      KalkDk                   ; uloëen° oddàlovaáe ©†dñ
KalkDek5:loop      KalkDek4                 ; dal®° znak

; ------ uloëen° oddàlovac° teáky

         mov       al,ds:[OddelDes]         ; oddàlovac° teáka
         call      KalkDk                   ; uloëen° oddàlovac° teáky

; ------ p©°prava k dek¢dov†n° desetinnÇ á†sti á°sla

         mov       cx,ds:[KalkMist]         ; poáet desetinnòch m°st á°sla
         jcxz      KalkD622                 ; nejsou desetinn† m°sta

; ------ dek¢dov†n° jednÇ á°slice desetinnÇ á†sti

KalkDek6:les       di,ss:[bp-4]             ; adresa bufferu á°sla
         push      cx
         mov       cx,ds:[KalNumD]          ; CX <- poáet bajtñ desetinnÇ á†sti
         shr       cx,1                     ; CX <- poáet slov desetinnÇ á†sti
         mov       bx,ds:[KalkZakl]         ; BX <- á°selnò z†klad
         xor       si,si                    ; SI <- p©enos
         cld
KalkDk61:mov       ax,es:[di]               ; slovo desetinnÇ á†sti
         mul       bx                       ; vyn†soben° á°selnòm z†kladem
         add       ax,si                    ; p©enos z p©ede®lÇ operace
         adc       dx,0
         stosw                              ; uloëen° á°sla do bufferu
         mov       si,dx                    ; SI <- £schova p©enosu
         loop      KalkDk61                 ; dal®° slovo
         pop       cx

; ------ uloëen° á°slice

         xchg      ax,dx                    ; AL <- dek¢dovan† á°slice
         cmp       al,10                    ; je á°slice ?
         jb        KalkDk62                 ; je á°slice
         add       al,7                     ; korekce pro p°smeno
KalkDk62:add       al,"0"                   ; korekce na ASCII znak
         call      KalkDK                   ; uloëen° á°slice do bufferu
         loop      KalkDek6                 ; dal®° á°slice

; ------ test, zda bude zaokrouhlen° á°sla nahoru

KalkD622:les       di,ss:[bp-4]             ; adresa bufferu á°sla
         add       di,ds:[KalNumD]          ; konec desetin
         test      byte ptr es:[di-1],bit7  ; je zbytek desetin < 0.5 ?
         jz        KalkDek7                 ; zaokrouhlen° se nedàl†

; ------ p©°prava maxim†ln°ho znaku tÇto á°selnÇ soustavy -> AH

         mov       ah,byte ptr ds:[KalkZakl] ; AH <- z†klad á°selnÇ soustavy
         add       ah,"0" - 1               ; maxim†ln° znak soustavy
         cmp       ah,"9"                   ; je to je®tà á°slice ?
         jbe       KalkDk63                 ; je to je®tà á°slice
         add       ah,7                     ; korekce pro p°smeno

; ------ ukl†dac° adresa á°sla

KalkDk63:les       di,ss:[bp-8]             ; ukl†dac° adresa á°sla

; ------ test, zda je jië zaá†tek bufferu

KalkDk64:dec       di                       ; sn°ëen° ukazatele v bufferu
         cmp       di,ss:[bp-14]            ; je jië zaá†tek bufferu ?
         jb        KalkDk67                 ; je jië zaá†tek bufferu

; ------ vypu®tàn° neá°selnòch znakñ

         mov       al,es:[di]               ; p©ipravenò znak
         cmp       al,ds:[OddelDes]         ; desetinn† teáka ?
         je        KalkDk64                 ; p©eskoáen° desetinnÇ teáky
         cmp       al,ds:[OddelRad]         ; je oddàlovaá ©†dñ ?
         je        KalkDk64                 ; p©eskoáen° oddàlovaáe ©†dñ

; ------ zvò®en° á°slice

         inc       ax                       ; zvò®en° á°slice
         cmp       al,"9"+1                 ; je zmàna na p°smeno ?
         jne       KalkDk65                 ; nen° zmàna na p°smeno
         mov       al,"A"                   ; zmàna na p°smeno
KalkDk65:mov       es:[di],al               ; novò znak

; ------ test, zda je pokraáov†n° p©enosu

         cmp       al,ah                    ; je p©eteáen° á°sla ?
         jbe       KalkDek7                 ; nen° p©eteáen° á°slice
         mov       byte ptr es:[di],"0"     ; p©i p©eteáen° n†hrada "0"
         jmp       short KalkDk64           ; dal®° pozice á°sla

; ------ p©i p©eteáen° ©†du odsun á°sla

KalkDk67:mov       di,ss:[bp-8]             ; DI <- konec za á°slem
         dec       di                       ; DI <- posledn° znak á°sla
         mov       cx,di                    ; CX <- posledn° znak á°sla
         sub       cx,ss:[bp-14]            ; CX <- poáet znakñ k odsunu - 1

         cmp       word ptr ss:[bp-12],0    ; zbylo m°sto v bufferu ?
         je        KalkDk68                 ; v bufferu nen° volnÇ m°sto
         dec       word ptr ss:[bp-12]      ; sn°ëen° volnÇho m°sta v bufferu
         inc       word ptr ss:[bp-8]       ; posun ukl†dac° adresy
         inc       di                       ; posun c°lovÇ adresy
         inc       cx                       ; zvò®en° dÇlky na plnò poáet znakñ

KalkDk68:mov       si,di                    ; SI <- konec textu
         dec       si                       ; SI <- posledn° znak
         std                                ; smàr dolñ
         rep       movs byte ptr es:[di],es:[si] ; odsun textu
         mov       al,"1"
         stosb                              ; dopl§uj°c° á°slice

; ------ odstranàn° koncovòch nul

KalkDek7:les       di,ss:[bp-8]             ; ukl†dac° adresa textu (konec)
KalkDek8:dec       di                       ; sn°ëen° ukazatele textu
         mov       al,es:[di]               ; AL <- posledn° znak
         cmp       al,"0"
         je        KalkDek8                 ; nula se odstran°
         cmp       al,ds:[OddelDes]
         je        KalkDek9                 ; teáka se odstran°
         inc       di                       ; n†vrat na posledn° á°slici
KalkDek9:cmp       word ptr es:[di-2],"0-"  ; je "-0" ?
         jne       KalkDekA                 ; nen° "-0"
         dec       di                       ; zru®en° znaku "0"
         mov       byte ptr es:[di-1],"0"   ; n†hrada
KalkDekA:mov       si,di                    ; SI <- konec textu

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KalkDek  ENDP

; ------ uloëen° znaku AL do vòstupn°ho bufferu

KalkDk:  cmp       word ptr ss:[bp-12],0    ; je vòstupn° buffer plnò ?
         je        KalkDk2                  ; vòstupn° buffer je jië plnò
         dec       word ptr ss:[bp-12]      ; sn°ëen° á°taáe znakñ
         push      di
         push      es
         les       di,ss:[bp-8]             ; ukazatel ukl†dac° adresy
         cld
         stosb                              ; uloëen° znaku do bufferu
         mov       ss:[bp-8],di             ; nov† ukl†dac° adresa
         pop       es
         pop       di
KalkDk2: ret

CodeZvl  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

ParZvl   db        0                        ; parametry aktivity
                                            ;    bit 0: 1=zapnuta tabulka ASCII
                                            ;    bit 1: 1=zapnuty hodiny
                                            ;    bit 2: 1=zapnuto okno di†©e
                                            ;    bit 3: 1=zapnut kalkul†tor

                                            ;    bit 7: 1=je editace z†pisn°kem

;; -----------------------------------------------------------------------------
;;        Definice vertik†ln°ho podmenu - zvl†®tn° funkce
;; -----------------------------------------------------------------------------
;
;ZMn2Vert label     byte                   ;* menu zvl†®tn°ch funkc°
;
;         db        2                        ; typ menu - vertik†ln° podmenu
;
;         db        0                        ; hladina k zobrazen° menu
;         dw        1                        ; aktivn° poloëka menu
;         dw        14                       ; poáet platnòch poloëek menu
;         dw        16                       ; celkovò poáet poloëek menu
;
;         dw        ZMn2VA1                  ; adresa definice poloëek menu
;         dw        ZMnuVH1                  ; adresa n†povàd
;         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
;         dw        ZMnuVA13                 ; adresa blokovac° tabulky
;         dw        0                        ; adresa tabulky p©ep°naáñ
;         dw        ZMn2VT1                  ; adresa titulu okna
;         dw        ZMnuVExe                 ; tabulka obsluh voleb menu
;         dw        ZMnuVAdr                 ; tabulka adres podmenu
;         dd        0                        ; n†vratov† adresa p©i p©eru®en°
;
;         db        11                       ; poá†teán° pozice
;         db        1                        ; poá†teán° ©†dek
;         db        25                       ; ®°©ka
;         db        18                       ; vò®ka
;
;ZMn2VT1  db        15,'zvl†®tn° funkce'
;
;ZMn2VA1  db        1,9,'Informace'
;         db        1,22,'Makra                ',16
;         db        1,22,'Nastaven°            ',16
;         db        bit6+bit7,0
;         db        1,13,'ASCII tabulka'
;         db        1,7,'CD disk'
;         db        1,17,'Di†© (nefunkán°!)'
;         db        1,6,'Hodiny'
;         db        1,8,'Komprese'
;;         db        1,5,'Linka'
;         db        1,10,'P©enos dat'
;         db        1,6,'Seznam'
;         db        1,7,'Tabulky'
;         db        1,7,'Vòpoáty'
;         db        1,8,'Z†pisn°k'
;         db        bit6+bit7,0
;         db        1,16,'UëivatelskÇ menu'

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - zvl†®tn° funkce
; -----------------------------------------------------------------------------

ZMnuVert label     byte                   ;* menu zvl†®tn°ch funkc°

         db        1                        ; typ menu - vertik†ln° menu hlavn°

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        9                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        ZMnuVA1                  ; adresa definice poloëek menu
         dw        ZMnuVH1                  ; adresa n†povàd
         dw        Hlp@PodmenuZvlastni      ; á°slo str†nky velkÇ n†povàdy
         dw        ZMnuVA13                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZMnuVT1                  ; adresa titulu okna
         dw        ZMnuVExe                 ; tabulka obsluh voleb menu
         dw        ZMnuVAdr                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        11                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        12                       ; vò®ka

ZMnuVA1  label     byte
;         db        1,9,'Informace'
;         db        1,17,'Makra           ',16
         db        1,17,'Nastaven°       ',16
         db        bit6+bit7,0
         db        1,13,'ASCII tabulka'
         db        1,7,'CD disk'
         db        1,8,'Kalend†©'
         db        1,6,'Hodiny'
;         db        1,8,'Komprese'
;         db        1,5,'Linka'
;         db        1,10,'P©enos dat'
         db        1,6,'Seznam'
         db        1,7,'Tabulky'
         db        1,7,'Vòpoáty'
         db        1,8,'Z†pisn°k'

ZMnuVA13 db        0,0,0,0,0,0,0,0,0

ZMnuVT1  db        8,'zvl†®tn°'

HelpS    SEGMENT   BYTE PUBLIC
ZMnuVH1  label     byte
;         db        55,'V®eobecnÇ informace o poá°taái a o programu DOS Manaëer'
;         db        35,'Makra - vytv†©en°, editace, uloëen°'
         db        64,'Nastaven° konfigurace - videom¢d, n†rodn° k¢d, inicializace, ...'
         db        62,'Tabulka ASCII znakñ - zad†v†n° nestandardn°ch znakñ (Ctrl-P)'
         db        49,'Ovl†d†n° p©ehr†v†n° audio CD diskñ v CD mechanice'
         db        17,'Kalend†© (Alt-)'
;         db        32,'Kalend†©, denn° z†znamn°k, bud°k'
         db        45,'Zobrazen° a nastaven° systÇmovÇho data a áasu'
;         db        24,'Komprese a archivace dat'
;         db        51,'Komunikace - p©enosy dat mezi poá°taái pomoc° linky'
         db        26,'DatovÇ seznamy a kartotÇky'
         db        30,'Tabulky - tabulkovò kalkul†tor'
         db        29,'Vòpoáty - kalkul†tor (Alt=)'
         db        43,'TextovÇ soubory, dopisy, pozn†mky, z†pisn°k'
HelpS    ENDS

ZMnuVExe label     dword                    ; tabulka obsluh menu
;         dd        AWZMnu1                  ; informace
;         dd        AWZMnu2                  ; makra
         dd        Nastav                   ; nastaven°
         dd        AsciiTab                 ; ASCII
         dd        CDdisk                   ; CD disk
         dd        Kalendar                 ; di†©
         dd        Hodiny                   ; hodiny
;         dd        0                        ; komprese
;         dd        0                        ; linka
         dd        DSezn                    ; seznam
         dd        Tablk                    ; tabulky
         dd        AWZMnu7                  ; vòpoáty
         dd        Zapis                    ; z†pisn°k

ZMnuVAdr label     word                     ; tabulka adres podmenu
;         dw        0
;         dw        0
         dw        ZNMnVert                 ; nastaven°
         dw        0
         dw        0
         dw        0
         dw        0
;         dw        0
;         dw        0
         dw        0
         dw        0
         dw        0
         dw        0

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - nastaven°
; -----------------------------------------------------------------------------

ZNMnVert label     byte                   ;* menu zvl†®tn°ch funkc° - nastaven°

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        4                        ; poáet platnòch poloëek menu
         dw        4                        ; celkovò poáet poloëek menu

         dw        ZNMnVA1                  ; adresa definice poloëek menu
         dw        ZNMnVH1                  ; adresa n†povàd
         dw        Hlp@PodmenuNastaveni     ; á°slo str†nky velkÇ n†povàdy
         dw        ZNMnVA13                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ZNMnVT1                  ; adresa titulu okna
         dw        ZNMnVExe                 ; tabulka obsluh voleb menu
         dw        ZNMnVAdr                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        11                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        6                        ; vò®ka

ZNMnVA1  db        1,17,'Videom¢d        ',16
         db        1,17,'N†rodn° k¢d     ',16
         db        1,12,'Inicializace'
         db        1,16,'UëivatelskÇ menu'

; Tabulka povolen° je modifikov†na p©i inicializaci !

ZNMnVA13 db        0,0,0,0

ZNMnVT1  db        9,'nastaven°'

HelpS    SEGMENT   BYTE PUBLIC
ZNMnVH1  db        28,'Nastaven° videom¢du displeje'
         db        48,'Nastaven° n†rodn°ho k¢du (áe®tina) pro zobrazen°'
         db        58,'Inicializaán° nastaven° programu DOS Manaëer - konfigurace'
         db        51,'Modifikace hlavn°ho uëivatelskÇho menu DOS Manaëeru'
HelpS    ENDS

ZNMnVExe label     dword                    ; tabulka obsluh menu
         dd        NastDis                  ; nastaven° displeje
         dd        NastKod                  ; nastaven° n†rodn°ho k¢du
         dd        NastIni                  ; inicializaán° nastaven°
         dd        NastIniU                 ; nastaven° uëivatelskÇho menu

ZNMnVAdr label     word                     ; tabulka adres podmenu
         dw        DspNMnu                  ; menu nastaven° displeje
         dw        KodNMnu                  ; menu nastaven° n†rodn°ho k¢du
         dw        0
         dw        0

;NastIniP db        8,'DOSMINIT'
;NastIni0 db        0                        ; pr†zdnò soubor

; -----------------------------------------------------------------------------
;        nastaven° n†rodn°ho k¢du
; -----------------------------------------------------------------------------

KodNMnu  label     byte

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        5                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        KodNMnuP                 ; adresa definice poloëek menu
         dw        KodNMnuH                 ; adresa n†povàd
         dw        Hlp@NastaveniNarodnihoKoduDOSMANu ; á°slo str†nky velkÇ n†povàdy
         dw        KodNMnuB                 ; adresa blokovac° tabulky
         dw        KodNMnuS                 ; adresa tabulky p©ep°naáñ
         dw        KodNMnuT                 ; adresa titulu okna
         dw        KodNMnuX                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        11                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        8                        ; vò®ka

KodNMnuP db        1+bit7,5,'ASCII'
         db        1+bit7,3,'IBM'
         db        1+bit7,7,'KEYBCS2'
         db        1+bit7,7,'Latin 2'
         db        bit6+bit7,0
         db        1+bit7,13,'Vlastn° fonty'

KodNMnuB db        0,0,0,0,0

KodNMnuS db        0,0,0,0,0

KodNMnuT db        11,'n†rodn° k¢d'

HelpS    SEGMENT   BYTE PUBLIC
KodNMnuH db        37,'Texty nebudou zobrazeny s diakritikou'
         db        68,'Texty budou zobrazeny s omezenou diakritikou podle tabulky znakñ IBM'
         db        74,'Texty budou zobrazeny v n†rodn°m k¢du KEYBCS2 (tj. k¢d brat©° Kamenickòch)'
         db        66,'Texty budou zobrazeny v n†rodn°m k¢du Latin 2 (k¢dov† str†nka 852)'
         db        71,'Na displeji bude pouëita vlastn° definice fontñ (pouze EGA, VGA a SVGA)'
HelpS    ENDS

KodNMnuX label     dword                    ; tabulka obsluh menu
         dd        KodNMnX1                 ; ASCII
         dd        KodNMnX1                 ; IBM
         dd        KodNMnX1                 ; KEYBCS2
         dd        KodNMnX1                 ; Latin 2
         dd        KodNMnX2                 ; vlastn° fonty

; -----------------------------------------------------------------------------
;        CD disk
; -----------------------------------------------------------------------------
;˛
; ------ chyba - nen° nainstalov†n ovladaá CD diskñ

CDErDMnu label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        CDErDMnP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PrehravacCDDisku     ; á°slo str†nky velkÇ n†povàdy
         dw        CDErDMnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CDErDMnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
         db        11                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie
         db        0                        ; poáet p©edvoleb

CDErDMnP db        bit6,0
         db        bit6,6,0,'CHYBA'
         db        bit6,40,'Nen° nainstalov†n ovladaá CD-ROM diskñ !'
         db        bit6,45,'(poëadov†n ',0,'MSCDEX.EXE',0,' verze minim†lnà 2.00)'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

CDErDMnB db        0                        ; blokovac° tabulka

CDErDMnT db        19,'nen° ovladaá CD-ROM'

; ------ menu CD disku

CDROMMnu label     byte

         db        19                       ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        1                        ; celkovò poáet poloëek menu

         dw        0                        ; zaá†tek definice poloëek menu
         dw        CDROMMnH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PrehravacCDDisku     ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CDROMMnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        78                       ; ®°©ka okna
         db        17                       ; vò®ka okna

CDROMMP1 db        bit6,69,'nahr†vka:  ',0
CDROMP11 db        '00',0,'   áas ',0
CDROMP12 db        '00:00,00',0,'   zbòv† ',0
CDROMP13 db        '00:00,00',0,'   dÇlka ',0
CDROMP14 db        '00:00,00'

CDROMMP2 db        bit6,69,'  celkem:  ',0
CDROMP21 db        '00',0,'   áas ',0
CDROMP22 db        '00:00,00',0,'   zbòv† ',0
CDROMP23 db        '00:00,00',0,'   dÇlka ',0
CDROMP24 db        '00:00,00'

CDROMMP3 db        bit6,70,0,'^<-',0,'  ',0,'^->',0,'  nahr†vka zpàt/vp©ed (',0,'/\',0,'  ',0,'\/',0,')   ',0,'Mezera',0,'  PAUSE, PLAY'
CDROMMP4 db        bit6,66,' ',0,'<-',0,'   ',0,'->',0,'  o 15 sekund zpàt/vp©ed         ',0,'Delete',0,'  STOP       '
CDROMP42 db        bit6,66,0,'Home',0,' ',0,'End',0,'  prvn°/posledn° nahr†vka        ',0,'Insert',0,'  EJECT      '
CDROMP43 db        bit6,68,0,'1',0,'-',0,'9',0,'  ',0,'A',0,'-',0,'Z',0,'  start od zvolenÇ nahr†vky                         '

CDROMMP5 db        bit6,9,0,30,30,' EJECT'
CDROMMP6 db        bit6,9,0,22,22,' EJECT'
CDROMMP7 db        bit6,9,0,'[',254,'] STOP'
CDROMMP8 db        bit6,9,0,'∫∫ PAUSE'

CDROMP91 db        bit6,9,0,16,16,'  PLAY'
CDROMP92 db        bit6,9,0,' ',16,16,' PLAY'

CDROMMP0 db        bit6,0

HelpS    SEGMENT   BYTE PUBLIC
CDROMMnH db        37,'Opu®tàn° p©ehr†vaáe kl†vesou Esc...'
HelpS    ENDS

CDROMMnT db        18,'p©ehr†vaá CD diskñ'

CDNulBeg label     byte                     ; zaá†tek k vynulov†n°
CDBTrack db        0                        ; poá†teán° stopa
CDETrack db        0                        ; koncov† stopa

CDATrack db        0                        ; aktu†ln° stopa
CDFTrack dd        0                        ; r†meáek poá†tku aktu†ln° stopy
CDFNext  dd        0                        ; r†meáek poá†tku p©°®t° stopy

CDFBeg   dd        0                        ; r†meáek poá†tku disku
CDFAkt   dd        0                        ; aktu†ln° r†meáek disku
CDFAktO  dd        0                        ; uschovan† star† aktu†ln° pozice
CDFEnd   dd        0                        ; r†meáek konce disku
CDFDelk  dd        0                        ; dÇlka disku
CDNulEnd label     byte                     ; konec k vynulov†n°

CDSegm   dw        0                        ; segment s mapou stop (max. 100)

CDFPlay  dd        0                        ; adresa pro p©ehr†v†n°

CDDsk    db        0                        ; á°slo CD disku

;CDVerz   dw        0                        ; verze ovladaáe CD-ROM
;                                            ;   WINDOWS 95 = 2.95

CDCitRad dw        0                        ; á°taáe ©†du pro st©ed pozice

CDMapPoz db        0                        ; pozice poá†tku mapy disku v oknà

CDStav   db        0                        ; aktu†ln° stav
                                            ;   0 = EJECT
                                            ;   1 = LOADING
                                            ;   2 = STOP
                                            ;   3 = PAUSE
                                            ;   4 = PLAY

CDDParam db        0                        ; parametry
                                            ;
                                            ;   bit 1: 1=disk vymànàn

; -----------------------------------------------------------------------------
;        definice hodin
; -----------------------------------------------------------------------------
;˛
;ColHod   db        0ah                      ; barva textu áasu

HodParm  db        0                        ; parametry:
                                            ;  bit 0: 1=reëim modifikace
                                            ;  bit 1: 1=áas zmànàn
                                            ;  bit 2: 1=datum zmànàn

ZHMnuLin db        6                        ; typ menu - hodiny

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka - kurzor na ©†dku
         dw        14                       ; poáet platnòch poloëek
         dw        14                       ; celkovò poáet poloëek

         dw        HodMTxt1                 ; zaá†tek definice poloëek
         dw        ZHMnuLH1                 ; n†povàda
         dw        Hlp@Hodiny               ; á°slo str†nky velkÇ n†povàdy
         dw        0                        ; blokovac° tabulka
         dw        0                        ; p©ep°naáe
         dw        ZHMnuLT1                 ; adresa titulu okna
         dw        0                        ; tabulka obsluh voleb menu
         dw        0                        ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        (80-70)/2                ; poá†teán° pozice
         db        6                        ; poá†teán° ©†dek
         db        69                       ; ®°©ka okna
         db        10                       ; vò®ka okna

HodMTxt1 db        bit6,HodMTxt3-$-1
         db        '       Äas  ',0
HodMCas  db        '00:00:00',0
         db        '        Datum  ',0
HodMDat  db        '01.01.1980   '
HodMDen  db        'nedàle '
HodMTxt3 label     byte

ZHMnuLT1 db        6,'hodiny'

HelpS    SEGMENT   BYTE PUBLIC
ZHMnuLH1 db        43,'Enter=nastaven° data a áasu; Esc=n†vrat'
ZHMnuLH2 db        69,'Zadejte novò áas a datum a stisknàte Enter; Esc=n†vrat beze zmàny'
HelpS    ENDS

ObrCis   db        '‹€ﬂﬂﬂ€‹'                ; obr†zky á°slic pro hodiny
         db        '€€   €€'
         db        '€€   €€'
         db        '€€   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        '  ‹€€  '
         db        ' ﬂﬂ€€  '
         db        '   €€  '
         db        '   €€  '
         db        ' ﬂﬂﬂﬂﬂﬂ'
         db        '‹€ﬂﬂﬂ€‹'
         db        '    ‹€ﬂ'
         db        '  ‹€ﬂ  '
         db        '‹€ﬂ  ‹‹'
         db        'ﬂﬂﬂﬂﬂﬂﬂ'
         db        '‹€ﬂﬂﬂ€‹'
         db        '     €€'
         db        '  ﬂﬂﬂ€‹'
         db        '‹‹   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        '   ‹€€ '
         db        ' ‹€ﬂ€€ '
         db        '€€‹‹€€‹'
         db        '    €€ '
         db        '   ﬂﬂﬂﬂ'
         db        '€€ﬂﬂﬂﬂﬂ'
         db        '€€     '
         db        'ﬂﬂﬂﬂﬂ€‹'
         db        '‹‹   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        ' ‹€ﬂﬂﬂ '
         db        '€€     '
         db        '€€ﬂﬂﬂ€‹'
         db        '€€   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        '€€ﬂﬂﬂ€€'
         db        '    ‹€ﬂ'
         db        '  ‹€ﬂ  '
         db        '  €€   '
         db        '  ﬂﬂ   '
         db        '‹€ﬂﬂﬂ€‹'
         db        '€€   €€'
         db        '‹€ﬂﬂﬂ€‹'
         db        '€€   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        '‹€ﬂﬂﬂ€‹'
         db        '€€   €€'
         db        ' ﬂﬂﬂﬂ€€'
         db        '    ‹€ﬂ'
         db        ' ﬂﬂﬂﬂ  '
         db        '       '
         db        '   €€  '
         db        '       '
         db        '   €€  '
         db        '       '

DnyTxt   db        'nedàle '
DnyTxt0  db        'pondàl°'
         db        '£terò  '
         db        'st©eda '
         db        'átvrtek'
         db        'p†tek  '
         db        'sobota '

; -----------------------------------------------------------------------------
;        kalkul†tor
; -----------------------------------------------------------------------------
;˛
ZKMnuLin label     byte                   ;* kalkul†tor
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        7                        ; poáet platnòch poloëek menu
         dw        9                        ; celkovò poáet poloëek menu

         dw        ZKMnuLP                  ; zaá†tek definice poloëek menu
         dw        ZKMnuLH                  ; adresa tabulky textñ n†povàdy
         dw        Hlp@Kalkulator           ; á°slo str†nky velkÇ n†povàdy
         dw        ZKMnuLB                  ; adresa blokovac° tabulky
         dw        ZKMnuLS                  ; adresa tabulky p©ep°naáñ
         dw        ZKMnuLT                  ; adresa titulu okna
         dw        ZKMnuLX                  ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        10                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        73                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ - v®e
         db        1,0,'     '              ; zak†zanÇ znaky

         db        HistCis                  ; historie
ZKMnuLnN db        0                        ; poáet p©edvoleb
ZKMnuLnD dw        0                        ; dÇlka
ZKMnuLnA dd        0                        ; adresa

; ------ poloëky voleb

ZKMnuLP  db        bit6,offset(ZKMnuLP0-ZKMnuLP)-2
         db        'Zadejte matematickò vòraz (oddàlovaá desetin "',0
ZKMnuLP6 db        '.',0,'", ©†dñ "',0
ZKMnuLP7 db        ' ',0,'", dat "',0
ZKMnuLP8 db        ',',0,'"):'
ZKMnuLP0 label     byte

         db        0,0
         db        bit6+bit7,0
         db        1,7,'Vòpoáet'
         db        1+bit7,5,'HEX '
ZKMnuLP1 db        '-'
         db        1+bit7,5,'RAD '
ZKMnuLP2 db        '-'
         db        1+bit7,8,'Tis°ce '
ZKMnuLP3 db        '-'
         db        1,7,'M°st '
ZKMnuLP4 db        '99'
         db        1,6,'N†vrat'


ZKMnuLB  db        0,0,0,0,0,0,0            ; blokovac° tabulka

ZKMnuLS  db        0,0,0                    ; p©ep°naáe

ZKMnuLT  db        10,'kalkul†tor'

ZKMnuLX  label     dword
         dd        Lin0MenR                 ; ©†dky
         dd        Lin0MenR                 ; vòpoáet
         dd        KalkulXH                 ; HEX
         dd        KalkulXR                 ; RAD
         dd        KalkulXT                 ; Tis°ce
         dd        KalkulXM                 ; M°st
         dd        Lin0MenR                 ; n†vrat

ZKMnuLHl db        18,'Prob°h† vòpoáet...'

KalkOKur dw        0                        ; uschovanò pñvodn° kurzor

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
ZKMnuLH  db        ZKMnuLH1-ZKMnuLH-1
         db        'SQRT PI-EUL ARC-SIN-COS-TG-COTG DEG-RAD LOG-LN-EXP INT-FRA-ABS OR-AND-XOR-NOT'
ZKMnuLH1 db        37,'Vòpoáet zadanÇho matematickÇho vòrazu'
         db        43,'Implicitnà hexadecim†ln° á°seln† soustava'
         db        63,'Vòpoáty goniometrickòch funkc° probàhnou implicitnà v radi†nech'
         db        30,'Odsazen° ©†dñ celÇ á†sti á°sla'
         db        40,'Volba poátu zobrazenòch desetinnòch m°st'

         db        3,1
         dw        MenuHlP2

ZKMnuLH2 db        54,'Zadejte poáet zobrazenòch desetinnòch m°st 0 aë 99'

HelpS    ENDS

; ------ chyba zad†n° vòrazu k vòpoátu

KalErMnu label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        KalErMnP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@Kalkulator           ; á°slo str†nky velkÇ n†povàdy
         dw        KalErMnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KalErMnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
         db        11                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie
         db        0                        ; poáet p©edvoleb

KalErMnP db        bit6,0
         db        bit6,6,0,'CHYBA'
         db        bit6,3,1
KalErMP1 dw        KalErMPV

         db        bit6,15,3
KalErMP2 db        0
         dd        0
         db        0,'?',0,3
KalErMP3 db        0
         dd        0

         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'


KalErMPV db        32,'ChybnÇ zad†n° vòrazu k vòpoátu !'
KalErMPO db        24,'Chyba p©eteáen° vòrazu !'


KalErMnB db        0                        ; blokovac° tabulka

KalErMnT db        13,'chyba vòpoátu'

; ------ definice á°sla (v®e sudÇ a >2 !) (nesm° bòt moc velkÇ - do z†sobn°ku
;        se mus° vej°t p©i dàlen° 4 á°sla !
; DEK: Na 1 á°slici se spot©ebuje 0.42 Bajtu. (tj. 4.7 á°slice na slovo)
; HEX: Na 1 á°slici se spot©ebuje 0.5 Bajtu. (tj. 4 á°slice na slovo)

KalNumN  dw        0                        ; poáet bajtñ celoá°selnÇ á†sti
KalNumNW dw        0                        ; poáet slov celoá°selnÇ á†sti

KalNumD  dw        0                        ; poáet bajtñ desetinnÇ á†sti
KalNumDW dw        0                        ; poáet slov desetinnÇ á†sti

KalNumX  dw        0                        ; poáet bajtñ na á°slo celkem
KalNumXW dw        0                        ; poáet slov na á°slo celkem

KalParm  db        bit2,0                   ; parametry (doplnàno na slovo !)
                                            ;   bit 0: 1=HEX m¢d
                                            ;   bit 1: 1=pouë°vaj° se RAD
                                            ;   bit 2: 1=odsazen° tis°cñ

                                            ;   bit 6: 1=tabulkovò kalkul†tor

KalkZakl dw        0                        ; á°selnò z†klad vòpoátñ
KalkOdsz dw        0                        ; odsazen° á°selnòch ©†dñ (255=vyp)
KalkMist dw        20                       ; poáet desetinnòch m°st á°sla

KalkLast dw        0                        ; adresa posledn°ho ukazatele SI

KalSegm  dw        0                        ; segment z†sobn°ku á°sel
KalSMem  dw        0                        ; segment pamàt° (kaëd† 256 bajtñ)
KalSEnd  dw        0                        ; adresa konce volnÇ pamàti

; -----------------------------------------------------------------------------
;        Definice menu - v®eobecnÇ informace
; -----------------------------------------------------------------------------
;˛
;ZIMnuLin label     byte                   ;* v®eobecnÇ informace
;
;         db        3                        ; typ menu - ©†dkovÇ menu
;
;         dw        1                        ; aktivn° poloëka menu
;         dw        1                        ; poáet platnòch poloëek menu
;         dw        9                        ; celkovò poáet poloëek menu
;
;         dw        offset ZIMnuLA1          ; zaá†tek definice poloëek menu
;         dw        offset ZIMnuLH1          ; adresa tabulky textñ n†povàdy
;         dw        Hlp@Main                 ; á°slo str†nky velkÇ n†povàdy
;         dw        offset ZIMnuBlk          ; adresa blokovac° tabulky
;         dw        0                        ; adresa tabulky p©ep°naáñ
;
;         db        21                       ; poá†teán° pozice okna
;         db        5                        ; poá†teán° ©†dek okna
;         db        34                       ; ®°©ka okna
;         db        13                       ; vò®ka okna
;
;         dw        0                        ; prvn° zobrazenò ©†dek
;         dw        0                        ; aktivn° zobrazenò ©†dek
;         dw        0                        ; celkovò poáet ©†dkñ
;         dw        0                        ; poáet zobrazenòch ©†dkñ
;
;; ------ poloëky voleb
;
;ZIMnuLA1 dw        ZIMnuLA2-$
;         db        0 + bit6
;         db        '
;
;
;         '     DOS Manaëer - verze 2.00'
;         '       (c) Miroslav Nàmeáek'
;                       G O L E M
;
;                 Licence: 0000-0000
;
;
;                V®eobecnÇ informace
;               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;            operaán° systÇm: MS DOS verze 5.00
;
;          celkov† pamàü DOS: 654 KB
;            voln† pamàü DOS: 234 KB
;            roz®°©en† pamàü: 1024 KB
;      voln† roz®°©en† pamàü: 234 KB
;
;
;
;             Informace o hardware poá°taáe
;            ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;                    poá°taá: AT
;            hlavn° procesor: Intel 80486
;     matematickò koprocesor: interni
;           hodiny procesoru: 25 MHz
;                  pamàü RAM: 4096 KB
;                       BIOS: AWARD
;          datum vzniku BIOS: 5.prosince 1990
;                 moduly ROM: C000h
;              sÇriovÇ porty: 03F8h, 02F8h
;            paraleln° porty: 0378h
;             grafick† karta: VGA 256 KB
;              logickÇ disky: A, B, C, D
;                pevnÇ disky: 130 MB (typ 49)
;         disketovÇ jednotky: 5.25"/1.2MB, 3.5"/1.44MB
;
;
;
;
;ZIMnuLA8 dw        ZIMnuLA9-$
;         db        bit6 + bit7
;
;ZIMnuLA9 dw        ZIMnuBlk-$
;         db        1
;         db        'N†vrat'  Hardware
;
;ZIMnuBlk db        0                        ; blokovac° tabulka
;
;; ------ n†povàda
;
;ZIMnuLH1 dw        ZIMnuLH2-$
;         db        'Opu®tàn° informaán°ho okna kl†vesou <Esc> nebo <Enter>'
;
;ZIMnuLH2 label     word
;

Data     ENDS

         END
