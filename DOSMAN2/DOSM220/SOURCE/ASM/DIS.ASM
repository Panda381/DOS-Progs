

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              D I S P L E J
;                             Obsluha displeje
;
; =============================================================================
;
;        PushScr  (FAR)  - £schova obsahu obrazovky
;        PopScr   (FAR)  - n vrat obsahu syst‚mov‚ obrazovky (v˜©ez)
;
;        SizeHKur (FAR)  - nastaven¡ vysok‚ho kurzoru
;        SizeLKur (FAR)  - nastaven¡ n¡zk‚ho kurzoru
;        KurzOff  (FAR)  - vypnut¡ kurzoru (nastaven¡ mimo displej)
;        SetKurz  (FAR)  - nastaven¡ pozice kurzoru na displeji
;
;        StinWin  (FAR)  - zobrazen¡ st¡nu pod oknem
;
;        Disp1Chr (FAR)  - zobrazen¡ jednoho znaku
;        DispChr  (FAR)  - v¡cen sobn‚ zobrazen¡ znaku
;        DispTxt  (FAR)  - zobrazen¡ textov‚ho ©etˆzce jednou barvou
;        DispStr  (FAR)  - zobrazen¡ textov‚ho ©etˆzce s atributy barvy
;
;        InitVMod (FAR)  - inicializace videom¢du pro textov˜ m¢d
;        TestSnow (FAR)  - test (a korekce) obsluhy snˆ‘en¡
;        SetVMode (FAR)  - nastaven¡ videom¢du AL
;        AktPDisp (FAR)  - aktualizace parametr– displeje
;        DetCard  (FAR)  - detekce videokarty (rozpozn n¡ karty EGA/VGA)
;
;        Int10P   (FAR)  - vol n¡ p©eru¨en¡ INT 10h s £schovou registr–
;
;        STopAdr  (WORD) - po‡ te‡n¡ offset k zobrazen¡ podkladu syst. obrazovky
;        SSegment (WORD) - ‡¡slo datov‚ho segmentu s uschovanou syst. obrazovkou
;        SBajtRow (WORD) - po‡et bajt– na © dek syst‚mov‚ obrazovky
;        SKurzor  (WORD) - p–vodn¡ pozice kurzoru uschovan‚ syst‚mov‚ obrazovky
;        SPodklad (WORD) - podkladov˜ znak k vymaz n¡ zbytku syst‚mov‚ obrazovky
;        STopLine (BYTE) - po‡ te‡n¡ © dek k zobrazen¡ podkladu syst. obrazovky
;        SRadku   (BYTE) - po‡et © dk– uschovan‚ syst‚mov‚ obrazovky
;        SPozic   (BYTE) - po‡et pozic na © dek uschovan‚ syst‚mov‚ obrazovky
;
;        AdrVRAM  (DWORD)- adresa po‡ tku videopamˆti
;        PortCRT  (WORD) - adresa portu video©adi‡e k synchronizaci snˆ‘en¡
;        ByteRow  (WORD) - po‡et bajt– na © dek
;        Pozic    (BYTE) - po‡et pozic na © dek
;        MaxPoz   (BYTE) - ‡¡slo maxim ln¡ pozice na © dku
;        Radku    (BYTE) - celkov˜ po‡et © dk– na displeji
;        MaxRow   (BYTE) - ‡¡slo maxim ln¡ho zobrazen‚ho © dku
;        EgaVga   (BYTE) - p©¡znak instalace videokarty EGA nebo VGA
;        ChckSnow (BYTE) - p©¡znak obsluhy snˆ‘en¡ obrazovky
;        AktPage  (BYTE) - ‡¡slo aktivn¡ videostr nky
;        LineFont (BYTE) - po‡et linek na znak syst‚mov‚ho fontu
;        UserVMod (BYTE) - u‘ivatelsk˜ videom¢d
;        AktVMod  (BYTE) - aktu ln¡ videom¢d
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  ASM\DEF.ASM

CodeDis  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDis,ds:Data

; *****************************************************************************
;                                InitIDis
;                    inicializace parametr– displeje
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

InitIDis PROC      FAR

; ------ nalezen¡ dal¨¡ho parametru

InitIDs1:call      far ptr NextLIni         ; dal¨¡ © dek
         jnc       InitIDs2                 ; je dal¨¡ © dek OK
IniIDs12:ret

InitIDs2:cmp       byte ptr es:[di],"["
         je        IniIDs12
         call      far ptr JumpPTxt

         db        9,'INITVMODE'
         dw        IniIDs31

         db        9,'VIDEOMODE'
         dw        IniIDs33

         db        8,'DOWNLOAD'
         dw        IniIDs35

         db        6,'INTENS'
         dw        IniIDs36

         db        7,'SNOWING'
         dw        IniIDs37

         db        7,'RESFONT'
         dw        IniIDs38

         db        8,'MONOMODE'
         dw        IniIDs39

         db        8,'INISTART'
         dw        IniIDs3A

         db        8,'USERMODE'
         dw        IniIDs3B

         db        0
         dw        InitIDs1

; ------ inicializa‡n¡ videom¢d

IniIDs31:test      byte ptr ds:[StartPar],bit2 ; opakovan˜ start ?
         jnz       IniIDs32                 ; je opakovan˜ start
         mov       si,offset InitVMd        ; inicializa‡n¡ videom¢d
         call      IniIVMod                 ; na‡ten¡ po‘adovan‚ho videom¢du
IniIDs32:jmp       InitIDs1

; ------ povolen‚ videom¢dy

IniIDs33:mov       si,offset ShftVMod+1     ; tabulka videom¢d–
         mov       cx,MaxVMod               ; po‡et videom¢d–
         mov       byte ptr ds:[si-1],0     ; nejsou videom¢dy pro Shift-F10
IniIDs34:call      IniIVMod                 ; na‡ten¡ videom¢du
         jc        IniID342                 ; nen¡ platn˜ videom¢d
         inc       byte ptr ds:[ShftVMod]   ; zv˜¨en¡ ‡¡ta‡e videom¢d–
IniID342:loop      IniIDs34                 ; dal¨¡ videom¢d
         jmp       short IniIDs32

; ------ DownLoad font–

IniIDs35:test      byte ptr ds:[StartPar],bit2 ; opakovan˜ start ?
         jnz       IniID352                 ; je opakovan˜ start
         call      far ptr InitIPYN         ; na‡ten¡ parametru Y/N
         jc        IniID351                 ; parametr nedefinov n
         and       byte ptr ds:[ParDisp2],not bit5 ; nen¡ DownLoad
         jcxz      IniIDs32                 ; nen¡ download
IniID351:or        byte ptr ds:[ParDisp2],bit5 ; je DownLoad
IniID352:jmp       short IniIDs32

; ------ zv˜¨en  intenzita pozad¡ znak–

IniIDs36:and       byte ptr ds:[ParDisp2],not bit0+bit1 ; nedefinov no
         call      far ptr InitIPYN         ; na‡ten¡ parametru Y/N
         jc        IniIDs32                 ; parametr nedefinov n
         or        byte ptr ds:[ParDisp2],bit0 ; blik n¡
         jcxz      IniIDs32                 ; je blik n¡
         xor       byte ptr ds:[ParDisp2],bit0+bit1 ; zv˜¨en  intenzita
         jmp       short IniID352

; ------ obsluha snˆ‘en¡

IniIDs37:mov       byte ptr ds:[ChckSnow],0 ; nen¡ snˆ‘en¡
         call      far ptr InitIPYN         ; na‡ten¡ parametru Y/N
         jc        IniIDs32                 ; parametr nedefinov n
         jcxz      IniIDs32                 ; nen¡ snˆ‘en¡
         inc       byte ptr ds:[ChckSnow]   ; je snˆ‘en¡
         jmp       short IniID352

; ------ navr cen¡ font– pro DOS

IniIDs38:call      far ptr InitIPYN         ; na‡ten¡ parametru Y/N
         jc        IniID381                 ; parametr nedefinov n
         and       byte ptr ds:[ParDisp],not bit6 ; fonty se nenavrac¡
         jcxz      IniID352                 ; fonty se nevrac¡
IniID381:or        byte ptr ds:[ParDisp],bit6 ; navr tit fonty pro DOS
         jmp       short IniID352

; ------ up©ednostnˆn¡ MONO videom¢du

IniIDs39:and       byte ptr ds:[MonoMod],not bit5+bit6 ; nen¡ up©ednostnˆn¡
         call      far ptr InitIPYN         ; na‡ten¡ parametru Y/N
         jc        IniID392                 ; parametr nedefinov n
         or        byte ptr ds:[MonoMod],bit6 ; up©ednostnit COLOR m¢d
         jcxz      IniID392                 ; nen¡ MONO m¢d
         xor       byte ptr ds:[MonoMod],bit5+bit6 ; up©ednostnit MONO m¢d
IniID392:jmp       short IniID352

; ------ inicializace videom¢du p©i startu

IniIDs3A:call      far ptr InitIPYN         ; na‡ten¡ parametru Y/N
         jc        IniID392                 ; parametr nedefinov n
         and       byte ptr ds:[ParDisp],not bit7 ; nen¡ inicializace
         jcxz      IniID392                 ; nen¡ inicializace
         or        byte ptr ds:[ParDisp],bit7 ; inicializovat videom¢d
         jmp       short IniID392

; ------ u‘ivatelsk˜ videom¢d

IniIDs3B:call      far ptr InitICar         ; vypu¨tˆn¡ oddˆlovac¡ ‡ rky
         call      far ptr InitIBNm         ; na‡ten¡ ¨¡©ky videom¢du
         jc        IniID392                 ; nen¡ platn‚ ‡¡slo
         mov       si,offset IniID3BD       ; buffer m¢du
         mov       ds:[si+2],al             ; £schova ‡¡sla m¢du

         call      far ptr InitISpc         ; vypu¨tˆn¡ mezer
         mov       al,es:[di]               ; n sleduj¡c¡ znak
         cmp       al,":"
         jne       IniID3B2                 ; nen¡ oddˆlova‡
         inc       di                       ; vypu¨tˆn¡ znaku

IniID3B2:call      IniIVMod                 ; na‡ten¡ videom¢du
         jc        IniIDs3B                 ; neplatn‚ ‡¡slo
         mov       ax,ds:[IniID3BD+2]       ; ‡¡slo videom¢du
         mov       dx,ds:[IniID3BD]         ; rozli¨en¡ videom¢du
         call      StorVMod                 ; ulo‘en¡ videom¢du
         jmp       short IniIDs3B           ; dal¨¡ videom¢d

InitIDis ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ parametr– videom¢du (¨¡©ka * v˜¨ka) do adresy DS:SI (CY=nen¡)
; -----------------------------------------------------------------------------

IniIVMod PROC      NEAR

         mov       word ptr ds:[si],0       ; nedefinov no
IniIVMd1:call      far ptr InitICar         ; vypu¨tˆn¡ oddˆlovac¡ ‡ rky
         call      far ptr InitIBNm         ; na‡ten¡ ¨¡©ky videom¢du
         jc        IniIVMd9                 ; nen¡ platn‚ ‡¡slo
         mov       ds:[si],al               ; ulo‘en¡ ¨¡©ky videom¢du

         call      far ptr InitISpc         ; vypu¨tˆn¡ mezer
         mov       al,es:[di]               ; n sleduj¡c¡ znak
         cmp       al,"*"
         je        IniIVMd2                 ; oddˆlova‡
         cmp       al,"X"
         je        IniIVMd2                 ; oddˆlova‡
         cmp       al,"x"
         jne       IniIVMd4                 ; nen¡ oddˆlova‡
IniIVMd2:inc       di                       ; vypu¨tˆn¡ znaku
         call      far ptr InitISpc         ; vypu¨tˆn¡ mezer

IniIVMd4:call      far ptr InitIBNm         ; na‡ten¡ dal¨¡ho ‡¡sla
         jc        IniIVMd9                 ; nen¡ platn‚ ‡¡slo

         cmp       al,10                    ; minim ln¡ v˜¨ka
         jb        IniIVMd9                 ; chyba
         cmp       byte ptr ds:[si],30      ; minim ln¡ ¨¡©ka
         jb        IniIVMd9                 ; chyba

         inc       si
         mov       ds:[si],al               ; ulo‘en¡ v˜¨ky videom¢du
         inc       si

IniIVMd9:ret

IniIVMod ENDP

; *****************************************************************************
;                                NastDis
;                   nastaven¡ parametr– displeje
; *****************************************************************************

NastDis  PROC      FAR

; ------ p©¡prava aktivn¡ polo‘ky pro menu

         mov       ax,ds:[InitVMdM]         ; adresa aktu ln¡ho videom¢du
         sub       ax,offset TabVMod-4      ; offset v tabulce
         shr       ax,1
         shr       ax,1                     ; ‡¡slo videom¢du
         mov       byte ptr ds:[si+MnuAkt],al ; aktivn¡ polo‘ka

; ------ pozice okna

         mov       ax,word ptr ds:[ZNMnVert+MnuPoz] ; menu p–vodn¡ho menu
         add       ax,1*HI + 7              ; © dek + 1
         mov       word ptr ds:[si+MnuPoz],ax ; po‡ tek okna
         jmp       far ptr VertMenu         ; obsluha menu

NastDis  ENDP

; -----------------------------------------------------------------------------
;        volba videom¢du
; -----------------------------------------------------------------------------

NastDis2 PROC      FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech menu

         mov       bx,ds:[si+MnuAkt]        ; zvolen  polo‘ka
         shl       bx,1
         shl       bx,1                     ; offset v tabulce
         add       bx,offset TabVMod-4      ; adresa definice videom¢du
         mov       ax,ds:[bx]               ; videom¢d
         mov       ds:[InitVMdN],ax         ; ‡¡slo videom¢du
         mov       ds:[InitVMdM],bx         ; adresa videom¢du
         mov       ax,ds:[bx+2]             ; rozmˆry videom¢du
         mov       word ptr ds:[InitVMd],ax ; rozmˆry videom¢du

         call      far ptr InitVMdI         ; inicializace videom¢du
         call      far ptr DispAll          ; nov‚ zobrazen¡ v¨eho
         jmp       far ptr Main0

NastDis2 ENDP

; *****************************************************************************
;                               PushScr
;      £schova obsahu syst‚mov‚ obrazovky (mus¡ b˜t zn m‚ parametry displeje)
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; ni‡¡ v¨echny registry kromˆ DS
; *****************************************************************************

PushScr  PROC      FAR

; ------ vytvo©en¡ segmentu pro uschov n¡ obsahu obrazovky

         mov       byte ptr ds:[SRadku],0
         mov       word ptr ds:[SSegment],0
         call      far ptr CreatSeg         ; vytvo©en¡ nov‚ho datov‚ho segmentu
         jc        PushSc02                 ; chyba pamˆti
         mov       ds:[SSegment],ax         ; segment s obsahem obrazovky

         test      byte ptr ds:[ProgSwc3],bit1 ; extern¡ stm¡va‡ ?
         jz        PushScr0                 ; nen¡ extern¡ stm¡va‡
PushSc02:ret

PushScr0:test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jz        PushScr1                 ; nen¡ okno WINDOWS

         test      byte ptr ds:[StartPar],bit2 ; je prvn¡ start ?
         jz        PushSc02                 ; je prvn¡ start - neuchov  se

; ------ kontrola, zda je obsluhovan˜ textov˜ videom¢d

PushScr1:mov       dh,0
         mov       dl,ds:[AktVMod]          ; aktu ln¡ videom¢d
         mov       ds:[SAktVMod],dl         ; £schova videom¢du
         mov       bx,ds:[VESAVMod]         ; aktu ln¡ VESA videom¢d
         mov       si,offset TabVMod-4      ; tabulka videom¢d–
         mov       cx,ds:[NumVMod]          ; po‡et videom¢d–
PushScr2:add       si,4                     ; dal¨¡ videom¢d
         mov       ax,ds:[si]               ; nastaven˜ videom¢d
         and       ah,not bit6+bit7         ; nulov n¡ p©¡znak–
         cmp       ax,dx                    ; je to obsluhovan˜ videom¢d ?
         je        PushScr4                 ; nalezen videom¢d OK
         cmp       ax,bx                    ; je VESA videom¢d ?
         je        PushScr4                 ; je videom¢d OK
         loop      PushScr2                 ; dal¨¡ videom¢d

; ------ test, zda je standardn¡ textov˜ videom¢d

         cmp       al,7
         je        PushScr4                 ; videom¢d MDA
         cmp       al,3
         jbe       PushScr4
         cmp       al,19
         jbe       PushScr9                 ; nen¡ standardn¡ textov˜ videom¢d

; ------ test, zda je textov˜ videom¢d VGA

         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       PushScr9                 ; je okno WINDOWS
         cmp       byte ptr ds:[TypVCard],4 ; je VGA karta ?
         jb        PushScr9                 ; nen¡ VGA karta
         mov       dx,3ceh
         mov       al,6
         out       dx,al                    ; ©¡dic¡ registr
         in        al,dx
         cmp       al,6                     ; byl registr nastaven ?
         jne       PushScr9                 ; nen¡ karta VGA
         inc       dx
         in        al,dx                    ; stav ©¡dic¡ho registru
         and       al,0fh
         cmp       al,1110b                 ; textov˜ m¢d CGA
         je        PushScr4                 ; je textov˜ m¢d CGA
         cmp       al,1010b                 ; textov˜ m¢d MDA
         jne       PushScr9                 ; nen¡ platn˜ textov˜ videom¢d

; ------ nastaven¡ velikosti segmentu £schovy obrazovky

PushScr4:mov       al,ds:[Pozic]            ; po‡et pozic na © dek
         mul       byte ptr ds:[Radku]      ; v˜po‡et po‡tu pozic celkem
         mov       cx,ax                    ; CX <- po‡et znak– celkem
         shl       ax,1                     ; po‡et bajt– celkem
         jc        PushScr9                 ; p©¡li¨ velk  videostr nka (chyba?)
         xchg      ax,bx                    ; BX <- po‡et bajt– celkem
         mov       ax,ds:[SSegment]         ; segment bloku pamˆti
         call      far ptr ModiSegS         ; nastaven¡ velikosti segmentu
         jc        PushScr9                 ; p©ete‡en¡ pamˆti

; ------ £schova obsahu obrazovky

         call      far ptr GetDat           ; poskytnut¡ adresy bloku -> ES
         push      ds                       ; £schova DS
         lds       si,ds:[AdrVRAM]          ; adresa za‡ tku obrazovky
         xor       di,di                    ; ukl dac¡ adresa
         cld                                ; smˆr nahoru
         rep       movsw                    ; £schova obsahu obrazovky
         mov       al,ds:[si-1]             ; atribut barvy na posledn¡m © dku
         pop       ds                       ; n vrat DS
         mov       byte ptr ds:[SPodklad+1],al ; £schova barvy znaku

; ------ £schova po‡tu © dk– a po‡tu pozic

         mov       al,ds:[Radku]            ; aktu ln¡ po‡et © dk–
         mov       ds:[SRadku],al           ; £schova po‡tu © dk–
         mov       al,ds:[Pozic]            ; aktu ln¡ po‡et pozic na © dek
         mov       ds:[SPozic],al           ; £schova po‡tu pozic
         mov       ah,0
         shl       ax,1
         mov       ds:[SBajtRow],ax         ; po‡et bajt– na © dek

; ------ £schova aktu ln¡ pozice kurzoru

         call      far ptr GetKurz          ; poskytnut¡ pozice kurzoru
         mov       ds:[SKurzor],dx          ; £schova pozice kurzoru

; ------ n vrat registr–

PushScr9:ret

PushScr  ENDP

; *****************************************************************************
;                                  PopScr
;                        n vrat obsahu obrazovky
; -----------------------------------------------------------------------------
; VSTUP: CL=¨¡©ka okna
;        CH=v˜¨ka okna
;        DL=po‡ te‡n¡ pozice okna
;        DH=po‡ te‡n¡ © dek okna
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) adresa bufferu obrazovky
;                   SS:[BP-4] (2) ukazatel adresy v bufferu
;                   SS:[BP-6] (2)
;                   SS:[BP-7] (1) ukazatel © dku na displeji
;                   SS:[BP-8] (1) ukazatel pozice na © dku
;                   SS:[BP-9] (1) ‡¡ta‡ © dk– k zobrazen¡ celkem
;                   SS:[BP-10] (1) po‡et pozic k zobrazen¡ celkem
;                   SS:[BP-11] (1) ‡¡ta‡ platn˜ch © dk– k zobrazen¡
;                   SS:[BP-12] (1) po‡et platn˜ch pozic k zobrazen¡
; *****************************************************************************

PopScr   PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ buffer pro lok ln¡ promˆnn‚

         mov       al,cl                    ; ¨¡©ka v˜©ezu (pozic)
         mov       ah,0
         shl       ax,1                     ; velikost bufferu
         add       ax,12                    ; velikost lok ln¡ch promˆnn˜ch
         sub       sp,ax                    ; buffer

; ------ adresa segmentu uschovan‚ obrazovky (chyba nevad¡ - je 0 © dk–)

         mov       ax,ds:[SSegment]         ; segment s uschovanou obrazovkou
         call      far ptr GetDat           ; poskytnut¡ adresy segmentu
         mov       ss:[bp-2],es             ; adresa segmentu bufferu

; ------ po‡ te‡n¡ adresa v bufferu

         mov       al,ds:[SPozic]           ; p–vodn¡ po‡et pozic na © dek
         mul       dh                       ; p©epo‡et © dk– na pozice
         add       al,dl                    ; p©i‡ten¡ po‡ te‡n¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset © dku
         add       ax,ds:[STopAdr]          ; posun po‡ tku
         mov       ss:[bp-4],ax             ; adresa v bufferu
         mov       ss:[bp-8],dx             ; ukazatel © dku a pozice na displ.
         mov       ss:[bp-10],cx            ; ‡¡ta‡ © dk– a ¨¡©ka © dku

; ------ po‡et znak– k zobrazen¡ z bufferu -> AL

         mov       al,ds:[SPozic]           ; po‡et pozic na © dek
         sub       al,dl                    ; zbyl˜ po‡et pozic do konce © dku
         jnc       PopScr1                  ; jsou nˆjak‚ pozice
         mov       al,0                     ; nezbyly ‘ dn‚ pozice
PopScr1: cmp       al,cl                    ; je © dek del¨¡ ?
         jbe       PopScr2                  ; zb˜v  m‚nˆ znak–
         mov       al,cl                    ; omezen¡ d‚lky © dku

; ------ po‡et © dk– k zobrazen¡ z bufferu -> AH

PopScr2: mov       ah,ds:[SRadku]           ; celkov˜ po‡et © dk–
         sub       ah,ds:[STopLine]         ; celkov˜ po‡et zbyl˜ch © dk–
         sub       ah,dh                    ; zbyl˜ po‡et © dk– do konce
         jnc       PopScr3                  ; jsou nˆjak‚ © dky
         mov       ah,0                     ; nezbyly ‘ dn‚ © dky
PopScr3: cmp       ah,ch                    ; je v¡ce © dk– ?
         jbe       PopScr4                  ; zb˜v  m‚nˆ © dk–
         mov       ah,ch                    ; omezen¡ po‡tu © dk–
PopScr4: mov       ss:[bp-12],ax            ; po‡et platn˜ch © dk– a pozic

; ------ inicializa‡n¡ vymaz n¡ © dku

         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku
         xor       cx,cx                    ; CX <- 0
         cmp       ss:[bp-9],cl             ; je nˆjak˜ © dek k zobrazen¡ ?
         je        PopScr9                  ; nen¡ ‘ dn˜ © dek k zobrazen¡
PopScr5: mov       ax,ds:[SPodklad]         ; znak podkladu
         mov       cl,ss:[bp-10]            ; po‡et pozic k zobrazen¡
         mov       di,sp                    ; buffer v z sobn¡ku
         cld
         rep       stosw                    ; vymaz n¡ © dku

; ------ test, zda je dal¨¡ platn˜ © dek

         cmp       byte ptr ss:[bp-11],0    ; je dal¨¡ platn˜ © dek ?
         je        PopScr8                  ; nen¡ dal¨¡ platn˜ © dek
         dec       byte ptr ss:[bp-11]      ; sn¡‘en¡ ‡¡ta‡e platn˜ch © dk–

; ------ dek¢dov n¡ textu © dku

         mov       di,sp                    ; adresa bufferu v z sobn¡ku
         push      ds
         mov       cl,ss:[bp-12]            ; po‡et platn˜ch pozic k zobrazen¡
         mov       si,ss:[bp-4]             ; ukazatel adresy v bufferu
         mov       ds,ss:[bp-2]             ; adresa bufferu
         rep       movsw                    ; p©enos textu
         pop       ds

; ------ zobrazen¡ © dku v bufferu

PopScr8: mov       si,sp                    ; buffer v z sobn¡ku
         mov       cl,ss:[bp-10]            ; po‡et pozic k zobrazen¡
         mov       dx,ss:[bp-8]             ; ukazatel © dku a pozice
         xor       ax,ax                    ; AX <- 0 hladina k zobrazen¡
         call      far ptr DispMStr         ; zobrazen¡ bufferu

; ------ p©¡prava pro dal¨¡ © dek

         mov       ax,ds:[SBajtRow]         ; po‡et bajt– na © dek
         add       ss:[bp-4],ax             ; zv˜¨en¡ ukazatele adresy
         inc       byte ptr ss:[bp-7]       ; zv˜¨en¡ ukazatele © dku
         dec       byte ptr ss:[bp-9]       ; ‡¡ta‡ © dk– k zobrazen¡
         jnz       PopScr5                  ; dal¨¡ © dek

; ------ n vrat registr–

PopScr9: mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

PopScr   ENDP

; -----------------------------------------------------------------------------
;                               PushFont
;                    £schova aktu ln¡ho nastaven¡ font–
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

PushFont PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ adresa bufferu

         and       byte ptr ds:[ParDisp],not bit3 ; fonty nejsou uschov ny
         cmp       byte ptr ds:[EgaVga],0   ; je displej EGA/VGA ?
         je        PshFont9                 ; nen¡ displej EGA/VGA
         mov       ax,ds:[FontSegm]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        PshFont9                 ; nˆjak  chyba

         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       PshFont9                 ; je m¢d v oknˆ WINDOWS

; ------ zapnut¡ znakov‚ho m¢du

         cli
         call      FontOn                   ; zapnut¡ znakov‚ho m¢du

; ------ £schova definice font–

         push      ds
         mov       ax,0a000h
         mov       ds,ax                    ; DS <- segment videopamˆti
         xor       di,di                    ; po‡ tek bufferu
         mov       si,32*128                ; adresa druh‚ poloviny znak–
         mov       cx,32*128/2              ; velikost druh‚ poloviny znak–
         cld
         rep       movsw                    ; p©enos definice znaku
         pop       ds

; ------ n vrat textov‚ho m¢du

         call      FontOff                  ; n vrat textov‚ho m¢du
         sti
         or        byte ptr ds:[ParDisp],bit3 ; p©¡znak na‡ten¡ font–

; ------ n vrat registr–

PshFont9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

PushFont ENDP

; *****************************************************************************
;                               PopFont
;                   n vrat p–vodn¡ch font– displeje
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

PopFont  PROC      FAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ adresa bufferu

         test      byte ptr ds:[ParDisp],bit3 ; jsou fonty uschov ny ?
         jz        PopFont9                 ; fonty nejsou uschov ny
         mov       ax,ds:[FontSegm]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        PopFont9                 ; nˆjak  chyba

; ------ zapnut¡ znakov‚ho m¢du

         cli
         call      FontOn                   ; zapnut¡ znakov‚ho m¢du

; ------ n vrat definice font–

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         mov       ax,0a000h
         mov       es,ax                    ; DS <- segment videopamˆti
         mov       di,32*128                ; adresa druh‚ poloviny znak–
         mov       cx,32*128/2              ; velikost druh‚ poloviny znak–
         xor       si,si                    ; adresa po‡ tku bufferu
         cld
         rep       movsw                    ; p©enos definice znaku
         pop       ds

; ------ n vrat textov‚ho m¢du

         call      FontOff                  ; n vrat textov‚ho m¢du
         sti
         and       byte ptr ds:[ParDisp3],not bit0+bit1 ; nejsou fonty

; ------ n vrat registr–

PopFont9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

PopFont  ENDP

; *****************************************************************************
;                               GetFont
;                   na‡ten¡ definice fontu z displeje
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k na‡ten¡
;        ES:DI=buffer k na‡ten¡ definice fontu (32 bajt–)
;        DS=datov˜ segment
; VSTUP: ES:DI=adresa dal¨¡ho znaku (zv˜¨en  o 32 bajt–)
; *****************************************************************************

GetFont  PROC      FAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di

; ------ test, zda je karta EGA/VGA

         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA/VGA ?
         je        GetFont9                 ; nen¡ karta EGA/VGA

         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       GetFont9                 ; je m¢d WINDOWS

; ------ v˜po‡et adresy ve videopamˆti

         mov       ah,32                    ; po‡et bajt– na znak
         mul       ah                       ; adresa znaku ve videopamˆti
         xchg      ax,si                    ; SI <- adresa znaku ve videopamˆti

; ------ zapnut¡ znakov‚ho m¢du

         cli
         call      FontOn                   ; zapnut¡ znakov‚ho m¢du

; ------ p©enos definice znaku

         push      ds
         mov       ax,0a000h
         mov       ds,ax                    ; DS <- segment videopamˆti
         mov       cx,32/2                  ; po‡et slov k p©enesen¡
         cld
         rep       movsw                    ; p©enos definice znaku
         pop       ds

; ------ n vrat textov‚ho m¢du

         call      FontOff                  ; n vrat textov‚ho m¢du
         sti

; ------ n vrat registr–

GetFont9:pop       di
         pop       si
         pop       cx
         pop       ax
         add       di,32
         ret

GetFont  ENDP

; *****************************************************************************
;                               SetFont
;                    nastaven¡ definice fontu
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k nastaven¡
;        ES:SI=buffer k z pisu definice fontu (32 bajt–)
;        DS=datov˜ segment
; VSTUP: ES:SI=adresa dal¨¡ho znaku (zv˜¨en  o 32 bajt–)
; *****************************************************************************

SetFont  PROC      FAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ test, zda je karta EGA/VGA

         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA/VGA ?
         je        SetFont9                 ; nen¡ karta EGA/VGA

         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       SetFont9                 ; je m¢d WINDOWS

; ------ v˜po‡et adresy ve videopamˆti

         mov       ah,32                    ; po‡et bajt– na znak
         mul       ah                       ; adresa znaku ve videopamˆti
         xchg      ax,di                    ; DI <- adresa znaku ve videopamˆti

; ------ zapnut¡ znakov‚ho m¢du

         cli
         call      FontOn                   ; zapnut¡ znakov‚ho m¢du

; ------ p©enos definice znaku

         push      ds
         push      es
         pop       ds                       ; DS <- adresa bufferu
         mov       ax,0a000h
         mov       es,ax                    ; DS <- segment videopamˆti
         mov       cx,32/2                  ; po‡et slov k p©enesen¡
         cld
         rep       movsw                    ; p©enos definice znaku
         pop       ds

; ------ n vrat textov‚ho m¢du

         call      FontOff                  ; n vrat textov‚ho m¢du
         sti

; ------ n vrat registr–

SetFont9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         add       si,32
         ret

SetFont  ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ m¢du definice font–
; -----------------------------------------------------------------------------

FontOn   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ synchronizace registr–

         mov       dx,3dah
         in        al,dx

; ------ synchronn¡ RESET (neprov dˆt - rozhazuje displej !)

         mov       dl,0c4h                  ; port 3C4h
;         mov       ax,0*HI + bit0           ; prov‚st synchronn¡ RESET
;         call      SetDPort                 ; nastaven¡ registru

; ------ povolen z pis do roviny 2

         mov       ax,2*HI + bit2           ; registr 2, rovina 2
         call      SetDPort                 ; nastaven¡ registru

; ------ nastaven¡ sekven‡n¡ho adresov‚ho m¢du

         mov       ax,4*HI + bit0+bit1+bit2 ; registr 4, sekven‡n¡ m¢d
         call      SetDPort                 ; nastaven¡ registru

; ------ vynulov n¡ synchronn¡ho RESET (neprov dˆt - rozhazuje displej !)

;         mov       ax,0*HI + bit0+bit1      ; vynulovat synchronn¡ RESET
;         call      SetDPort                 ; nastaven¡ registru

; ------ nastaven¡ neprokl dan‚ho adresov n¡

         mov       dl,0ceh                  ; port 3CEh
         mov       ax,5*HI + 0              ; registr 5, neprokl dan˜ m¢d
         call      SetDPort                 ; nastaven¡ registru

; ------ nastaven¡ m¢du pamˆti A000h

         mov       ax,6*HI + 1*bit2         ; registr 6, m¢d pamˆti A000h 64 KB
         call      SetDPort                 ; nastaven¡ registru

; ------ nastaven¡ ‡tec¡ roviny

         mov       ax,4*HI + 2              ; registr 4, ‡tec¡ rovina 2
         call      SetDPort                 ; nastaven¡ registru

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

FontOn   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ m¢du definice font–
; -----------------------------------------------------------------------------

FontOff  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ synchronn¡ RESET (neprov dˆt - rozhazuje displej !)

         mov       dx,3c4h                  ; port 3C4h
;         mov       ax,0*HI + bit0           ; prov‚st synchronn¡ RESET
;         call      SetDPort                 ; nastaven¡ registru

; ------ povolen z pis do rovin 0 a 1

         mov       ax,2*HI + bit0+bit1      ; registr 2, roviny 0 a 1
         call      SetDPort                 ; nastaven¡ registru

; ------ nastaven¡ prokl dan‚ho adresov‚ho m¢du rovin

         mov       ax,4*HI + bit0+bit1      ; registr 4, prokl dan˜ m¢d
         call      SetDPort                 ; nastaven¡ registru

; ------ vynulov n¡ synchronn¡ho RESET (neprov dˆt - rozhazuje displej !)

;         mov       ax,0*HI + bit0+bit1      ; vynulovat synchronn¡ RESET
;         call      SetDPort                 ; nastaven¡ registru

; ------ nastaven¡ prokl dan‚ho adresov n¡

         mov       dl,0ceh                  ; port 3CEh
         mov       ax,5*HI + bit4           ; registr 5, prokl dan˜ m¢d
         call      SetDPort                 ; nastaven¡ registru

; ------ nastaven¡ m¢du pamˆti B000h nebo B800h

         mov       ax,6*HI + 2*bit2+bit1    ; registr 6, m¢d pamˆti B000h
         cmp       byte ptr ds:[AdrVRAM+3],0b0h ; je adresa B000h ?
         je        FontOff2                 ; je adresa B000h
         mov       al,3*bit2+bit1           ; jinak adresa B800h
FontOff2:call      SetDPort                 ; nastaven¡ registru

; ------ nastaven¡ ‡tec¡ roviny 0

         mov       ax,4*HI + 0              ; registr 4, ‡tec¡ rovina 0
         call      SetDPort                 ; nastaven¡ registru

; ------ n vrat registr–

         pop       dx
         pop       ax
         ret

FontOff  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registru AH na AL, port DX
; -----------------------------------------------------------------------------

SetDPort PROC      NEAR

         xchg      ah,al
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         xchg      ah,al
         inc       dx
         out       dx,al                    ; nastaven¡ registru
         dec       dx
         ret

SetDPort ENDP

; *****************************************************************************
;                              SizeHKur
;                    nastaven¡ vysok‚ho kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

SizeHKur PROC      FAR

         push      ax
         push      cx

         mov       cl,ds:[LineFont]         ; po‡et linek na znak
         mov       ch,cl
         dec       cx                       ; posledn¡ linka
         shr       ch,1                     ; polovi‡n¡ linka
         cmp       byte ptr ds:[AktVMod],7  ; je bˆ‘n˜ textov˜ m¢d ?
         ja        SizeLKr2                 ; nen¡ bˆ‘n˜ textov˜ m¢d
         mov       cx,407h                  ; vysok˜ kurzor pro CGA
         jb        SizeLKr2                 ; je videom¢d CGA
         cmp       byte ptr ds:[LineFont],8 ; je 8 linek na font ?
         je        SizeLKr2                 ; je 8 linek na font MDA
         mov       cx,60ch                  ; jinak kurzor pro MDA
         jmp       short SizeLKr2           ; je videom¢d MDA

SizeHKur ENDP

; *****************************************************************************
;                             SizeLKur
;                     nastaven¡ n¡zk‚ho kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

SizeLKur PROC      FAR

         push      ax
         push      cx

         mov       cl,ds:[LineFont]         ; po‡et linek na znak
         dec       cx                       ; posledn¡ linka
         mov       ch,cl
         dec       ch                       ; p©edposledn¡ linka
         cmp       byte ptr ds:[AktVMod],7  ; je bˆ‘n˜ textov˜ m¢d ?
         ja        SizeLKr2                 ; nen¡ bˆ‘n˜ textov˜ m¢d
         mov       cx,607h                  ; n¡zk˜ kurzor pro CGA
         jb        SizeLKr2                 ; je videom¢d CGA
         cmp       byte ptr ds:[LineFont],8 ; je 8 linek na font ?
         je        SizeLKr2                 ; je 8 linek na font MDA
         mov       cx,0b0ch                 ; jinak kurzor pro MDA
SizeLKr2:mov       ah,1
         cmp       cx,cs:[KurzOSiz]         ; je velikost nastavena ?
         je        SizeLKr4                 ; velikost je ji‘ nastavena
         mov       cs:[KurzOSiz],cx         ; £schova velikosti
         call      far ptr Int10P           ; nastaven¡ velikosti kurzoru

SizeLKr4:pop       cx
         pop       ax
         ret

SizeLKur ENDP

; *****************************************************************************
;                             GetKurz
;                       poskytnut¡ pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: DL=pozice kurzoru
;         DH=© dek kurzoru
; *****************************************************************************

GetKurz  PROC      FAR

         push      ax
         push      bx
         push      cx

         mov       bh,ds:[AktPage]          ; aktivn¡ videostr nka
         mov       ah,3                     ; funkce - poskytnut¡ kurzoru
         call      far ptr Int10P           ; poskytnut¡ pozice kurzoru

         pop       cx
         pop       bx
         pop       ax
         ret

GetKurz  ENDP

; *****************************************************************************
;                               KurzInv
;                nastaven¡ evidence kurzoru jako neplatn 
; *****************************************************************************

KurzInv  PROC      FAR

         mov       word ptr cs:[KurzOPoz],-1 ; kurzor neplatn˜
         mov       word ptr cs:[KurzOSiz],-1 ; velikost kurzoru neplatn 
         ret

KurzInv  ENDP

KurzOPoz dw        -1                       ; uschovan  pozice kurzoru
KurzOSiz dw        -1                       ; uschovan  velikost kurzoru

; *****************************************************************************
;                                KurzOff
;                            vypnut¡ kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

KurzOff  PROC      FAR

         push      dx

         mov       dl,0                     ; pozice kurzoru
         mov       dh,ds:[Radku]            ; prvn¡ © dek "za rohem"

         test      byte ptr ds:[MonoMod],bit4 ; je v˜stup v ANSI m¢du ?
         jz        KurzOff1                 ; nen¡ v˜stup v ANSI m¢du

         dec       dh                       ; maxim ln¡ © dek
         mov       dl,ds:[MaxPoz]           ; maxim ln¡ pozice

KurzOff1:call      far ptr SetKurz0         ; nastaven¡ pozice kurzoru

         pop       dx
         ret

KurzOff  ENDP

; *****************************************************************************
;                               SetKurz
;                      nastaven¡ pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice kurzoru
;        DH=© dek kurzoru
;        DS=datov˜ segment
; *****************************************************************************

SetKurz  PROC      FAR

         test      byte ptr ds:[DarkParm],bit1 ; je displej ztmaven ?
         jnz       KurzOff                  ; displej je ztmaven

; ------ test, zda je v˜stup v ANSI m¢du

SetKurz0:test      byte ptr ds:[MonoMod],bit4 ; je v˜stup v ANSI m¢du ?
         jnz       SetKurz9                 ; je v˜stup v ANSI m¢du

         push      ax
         push      bx

         mov       bh,ds:[AktPage]          ; aktivn¡ videostr nka
         mov       ah,2                     ; funkce - nastaven¡ pozice kurzoru
         cmp       dx,cs:[KurzOPoz]         ; je ji‘ nastaven ?
         je        SetKurz8                 ; kurzor je ji‘ nastaven
         mov       cs:[KurzOPoz],dx         ; £schova pozice kurzoru

         call      far ptr Int10P           ; nastaven¡ pozice kurzoru

SetKurz8:pop       bx
         pop       ax
         ret

SetKurz9:call      AnsiKur                  ; nastaven¡ kurzoru ANSII
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        test ©etˆzce DX (d‚lka CL), zda je pobl¡‘ kurzoru my¨i (CY=nen¡)
; -----------------------------------------------------------------------------

TestStr  PROC      NEAR

         push      ax

; ------ rozli¨en¡, zda je grafick˜ m¢d my¨i

         test      byte ptr ds:[ParMous2],bit0 ; je grafick˜ m¢d my¨i ?
         jz        TestStr6                 ; nen¡ grafick˜ m¢d my¨i

; ------ test ©etˆzce, zda je nad kurzorem my¨i

         mov       al,byte ptr ds:[MousePoz+1] ; © dek kurzoru my¨i
         cmp       dh,al                    ; je ©etˆzec nad kurzorem my¨i ?
         jb        TestStr9                 ; ©etˆzec je nad kurzorem my¨i

; ------ test ©etˆzce, zda je pod kurzorem my¨i

         inc       ax                       ; spodn¡ okraj kurzoru my¨i
         cmp       al,dh                    ; je ©etˆzec pod kurzorem my¨i ?
         jb        TestStr9                 ; ©etˆzec je pod kurzorem my¨i

; ------ test ©etˆzce, zda je za kurzorem my¨i

         mov       al,byte ptr ds:[MousePoz] ; pozice kurzoru my¨i
         inc       ax                       ; prav˜ okraj kurzoru my¨i
         cmp       al,dl                    ; je ©etˆzec za kurzorem my¨i ?
         jb        TestStr9                 ; ©etˆzec je za kurzorem my¨i
         jmp       short TestStr7           ; test, zda je p©ed kurzorem my¨i

; ------ test ©etˆzce, pokud nen¡ grafick˜ m¢d my¨i

TestStr6:cmp       dh,byte ptr ds:[MousePoz+1] ; je © dek s my¨¡ ?
         jne       TestStr9                 ; nen¡ © dek s my¨¡
         cmp       dl,byte ptr ds:[MousePoz] ; je text za kurzorem ?
         ja        TestStr9                 ; text je za kurzorem

; ------ test ©etˆzce, zda je p©ed kurzorem my¨i

TestStr7:mov       al,dl                    ; pozice po‡ tku ©etˆzce
         add       al,cl                    ; pozice za koncem ©etˆzce
         cmp       al,byte ptr ds:[MousePoz] ; je text p©ed kurzorem ?
         jb        TestStr9                 ; text je p©ed kurzorem

; ------ ©etˆzec je pobl¡‘ my¨i

TestStr8:clc
         pop       ax
         ret

; ------ ©etˆzec nen¡ pobl¡‘ my¨i

TestStr9:stc
         pop       ax
         ret

TestStr  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na zatemnˆn¡ p©i obsluze snˆ‘en¡ (DX=adresa ©adi‡e displeje)
; -----------------------------------------------------------------------------

WaitSnow PROC      NEAR

         sti                                ; p©eru¨en¡ povoleno
         in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         test      al,8                     ; prob¡h  vertik ln¡ impuls ?
         jnz       WaitSnw5                 ; prob¡h  vertik ln¡ impuls
WaitSnw3:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         rcr       al,1                     ; test horizont ln¡ho zpˆtn‚ho bˆhu
         jc        WaitSnw3                 ; je horiz. zpˆtn˜ bˆh - ‡ek n¡
WaitSnw4:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         rcr       al,1                     ; test horiz. zpˆtn‚ho bˆhu
         jnc       WaitSnw4                 ; ‡ek n¡ na horiz. zpˆtn˜ bˆh
WaitSnw5:ret

WaitSnow ENDP

; *****************************************************************************
;                                  DispTxt
;                  Zobrazen¡ textov‚ho ©etˆzce na obrazovce
; -----------------------------------------------------------------------------
; VSTUP:  AH=atribut barvy
;         CL=po‡et znak– textu
;         DL=po‡ te‡n¡ pozice
;         DH=© dek
;         DS=datov˜ segment
;         ES:SI=adresa textov‚ho ©etˆzce (bez atribut–)
; VSTUP: DL=nov  pozice
; *****************************************************************************

DispTxt  PROC      FAR

; ------ kontrola maxim ln¡ pozice a © dku

         cmp       dl,ds:[MaxPoz]           ; kontrola maxim ln¡ pozice
         ja        DispTxt9                 ; pozice p©ekro‡ena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim ln¡ho © dku
         ja        DispTxt9                 ; © dek p©ekro‡en

; ------ obsluha my¨i

         call      TestStr                  ; test, zda p©ekr˜v  kurzor my¨i
         jc        DispTxt0                 ; text je p©ed kurzorem

         call      far ptr MouseOff         ; vypnut¡ kurzoru my¨i
         call      far ptr DispTxt0         ; zobrazen¡ st¡nu
         call      far ptr MouseOn          ; zapnut¡ kurzoru my¨i
         ret

; ------ test, zda je v˜stup v ANSI m¢du

DispTxt0:test      byte ptr ds:[MonoMod],bit4 ; je v˜stup v ANSI m¢du ?
         jnz       DispTxtA                 ; je v˜stup v ANSI m¢du

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
         mov       ch,0                     ; CX = po‡et znak–

; ------ omezen¡ po‡tu znak– (do konce © dku)

         mov       al,ds:[Pozic]            ; po‡et pozic na © dek
         sub       al,dl                    ; zbyl˜ po‡et mo‘n˜ch pozic
         cmp       al,cl                    ; p©ekro‡en po‡et znak– ?
         ja        DispTxt1                 ; nen¡ p©ekro‡en po‡et znak–
         mov       cl,al                    ; omezen¡ po‡tu znak–

; ------ v˜po‡et adresy ve videopamˆti

DispTxt1:push      es                       ; £schova segmentu zdrojov‚ho textu
         les       di,ds:[AdrVRAM]          ; adresa za‡ tku VRAM
         push      ax                       ; £schova atributu barvy
         mov       al,ds:[Pozic]            ; po‡et znak– na © dek
         mul       dh                       ; p©epo‡et © dk– na pozice
         mov       dh,0                     ; DX=pozice
         add       ax,dx                    ; p©i‡ten¡ pozice
         shl       ax,1                     ; * 2 = offset ve videostr nce
         add       di,ax                    ; adresa ve videopamˆti
         pop       ax                       ; AH = atribut barvy

; ------ p©¡prava dat; zji¨tˆn¡, zda se kontroluje snˆ‘en¡

         cld                                ; smˆr posunu ukazatele nahoru
         cmp       byte ptr ds:[ChckSnow],0 ; prov d¡ se kontrola snˆ‘en¡ ?
         je        DispTxt6                 ; neprov d¡ se kontrola snˆ‘en¡

; ------ p©enos dat s obsluhou snˆ‘en¡

         mov       dx,ds:[PortCRT]          ; stavov˜ registr ©adi‡e displeje
         pop       ds                       ; segment zdrojov‚ adresy
         jcxz      DispTxt8                 ; nen¡ ‘ dn˜ znak k p©enosu
DispTxt2:call      WaitSnow                 ; ‡ek n¡ na zatemnˆn¡
         lodsb                              ; na‡ten¡ znaku k zobrazen¡
         stosw                              ; p©enos jednoho znaku
         loop      DispTxt2                 ; p©enos dal¨¡ho znaku
         jmp       short DispTxt8

; ------ p©enos dat bez kontroly snˆ‘en¡

DispTxt6:pop       ds                       ; segment ©etˆzce
         jcxz      DispTxt8                 ; nen¡ ‘ dn˜ znak k p©enosu
DispTxt7:lodsb                              ; znak k zobrazen¡
         stosw                              ; ulo‘en¡ znaku
         loop      DispTxt7                 ; p©enos dat bez kontroly snˆ‘en¡

; ------ n vrat registr–, konec

DispTxt8:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax

; ------ zv˜¨en¡ ukazatele pozice na © dku

DispTxt9:add       dl,cl                    ; zv˜¨en¡ pozice
         ret

; ------ v˜stup v ANSI m¢du

DispTxtA:push      ax
         push      cx
         push      si

         mov       ch,0
         jcxz      DispTxA9
DispTxA2:mov       al,es:[si]
         inc       si
         call      DosChar                  ; v˜stup znaku
         loop      DispTxA2

DispTxA9:pop       si
         pop       cx
         pop       ax
         ret

DispTxt  ENDP

; *****************************************************************************
;                                  DispStr
;                  Zobrazen¡ textov‚ho ©etˆzce na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  CL=po‡et znak– textu
;         DL=po‡ te‡n¡ pozice
;         DH=© dek
;         DS=datov˜ segment
;         ES:SI=adresa textov‚ho ©etˆzce (1 znak = 2 bajty = znak a atribut)
; VSTUP: DL=nov  pozice
; *****************************************************************************

DispStr  PROC      FAR

; ------ kontrola pozice a © dku

         cmp       dl,ds:[MaxPoz]           ; kontrola maxim ln¡ pozice
         ja        DispStr8                 ; pozice p©ekro‡ena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim ln¡ho © dku
         ja        DispStr8                 ; © dek p©ekro‡en

; ------ obsluha my¨i

         call      TestStr                  ; test, zda p©ekr˜v  kurzor my¨i
         jc        DispStr0                 ; nep©ekr˜v  se s my¨¡

         call      far ptr MouseOff         ; vypnut¡ kurzoru my¨i
         call      far ptr DispStr0         ; zobrazen¡ st¡nu
         call      far ptr MouseOn          ; zapnut¡ kurzoru my¨i
         ret

; ------ test, zda je v˜stup v ANSI m¢du

DispStr0:test      byte ptr ds:[MonoMod],bit4 ; je v˜stup v ANSI m¢du ?
         jnz       DispStr9                 ; je v˜stup v ANSI m¢du

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
         mov       ch,0                     ; CX = po‡et znak–

; ------ omezen¡ po‡tu znak– do konce © dku

         mov       al,ds:[Pozic]            ; po‡et pozic na © dek
         sub       al,dl                    ; zbyl˜ po‡et mo‘n˜ch pozic
         cmp       al,cl                    ; p©ekro‡en po‡et znak– ?
         ja        DispStr1                 ; nen¡ p©ekro‡en po‡et znak–
         mov       cl,al                    ; omezen¡ po‡tu znak–

; ------ v˜po‡et adresy ve videopamˆti

DispStr1:push      es                       ; £schova segmentu zdrojov‚ho textu
         les       di,ds:[AdrVRAM]          ; adresa za‡ tku VRAM
         mov       al,ds:[Pozic]            ; po‡et znak– na © dek
         mul       dh                       ; p©epo‡et © dk– na pozice
         mov       dh,0                     ; DX=pozice
         add       ax,dx                    ; p©i‡ten¡ pozice
         shl       ax,1                     ; * 2 = offset ve videostr nce
         add       di,ax                    ; adresa ve videopamˆti

; ------ p©¡prava dat; zji¨tˆn¡, zda se kontroluje snˆ‘en¡

         cld                                ; smˆr posunu ukazatele nahoru
         cmp       byte ptr ds:[ChckSnow],0 ; prov d¡ se kontrola snˆ‘en¡ ?
         je        DispStr6                 ; neprov d¡ se kontrola snˆ‘en¡

; ------ p©enos dat s obsluhou snˆ‘en¡

         mov       dx,ds:[PortCRT]          ; stavov˜ registr ©adi‡e displeje
         pop       ds                       ; segment zdrojov‚ adresy
         jcxz      DispStr8                 ; nen¡ ‘ dn˜ znak k p©enosu
DispStr2:call      WaitSnow                 ; ‡ek n¡ na zatemnˆn¡
         movsw                              ; p©enos jednoho znaku
         loop      DispStr2                 ; p©enos dal¨¡ho znaku
         jmp       short DispStr7

; ------ p©enos dat bez kontroly snˆ‘en¡

DispStr6:pop       ds                       ; segment adresy ©etˆzce
         rep       movsw                    ; p©enos dat bez kontroly snˆ‘en¡

; ------ n vrat registr–, konec

DispStr7:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax

; ------ zv˜¨en¡ ukazatele pozice

DispStr8:add       dl,cl                    ; zv˜¨en¡ pozice
         ret

; ------ v˜stup v ANSI m¢du

DispStr9:push      ax
         push      cx
         push      si

         mov       ch,0
         jcxz      DispSt99

DispSt92:cld
         lods      word ptr es:[si]         ; na‡ten¡ znaku k v˜stupu
         call      DosChar                  ; v˜stup znaku
         loop      DispSt92

DispSt99:pop       si
         pop       cx
         pop       ax
         ret

DispStr  ENDP

; *****************************************************************************
;                              Intens
;                  nastaven¡ intenzity pozad¡ displeje
; -----------------------------------------------------------------------------
; VSTUP: AL=1 intenzivn¡ pozad¡
;        AL=0 blikaj¡c¡ pozad¡
; *****************************************************************************

Intens   PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx

; ------ p©¡prava m¢du

         mov       bx,(bit3+bit0)*HI + 0    ; p©¡znak zv˜¨en‚ intenzity textu
         test      al,bit0                  ; zv˜¨en  intenzita ?
         jnz       SetIntn1                 ; zv˜¨en  intenzita
         mov       bx,(bit5+bit3+bit0)*HI + 1 ; p©¡znak blikaj¡c¡ho textu
         jmp       short SetIntn1

Intens   ENDP

; *****************************************************************************
;                              SetInten
;                   nastaven¡ aktu ln¡ intenzity displeje
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

SetInten PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx

; ------ p©¡prava m¢du

         test      byte ptr ds:[ParDisp2],bit0+bit1
         jz        SetIntn9                 ; nenastavuje se
         mov       bx,(bit3+bit0)*HI + 0    ; p©¡znak zv˜¨en‚ intenzity textu
         test      byte ptr ds:[ParDisp2],bit1 ; zv˜¨en  intenzita ?
         jnz       SetIntn1                 ; zv˜¨en  intenzita
         mov       bx,(bit5+bit3+bit0)*HI + 1 ; p©¡znak blikaj¡c¡ho textu

; ------ nastaven¡ intenzity pomoc¡ BIOS

SetIntn1:mov       ax,1003h
         push      bx
         call      far ptr Int10P           ; nastaven¡ intenzity pozad¡
         pop       bx

; ------ nastaven¡ intenzity pomoc¡ portu

         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA/VGA ?
         jne       SetIntn9                 ; je karta EGA/VGA

         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       SetIntn9                 ; je m¢d WINDOWS

         mov       al,bh
         cmp       byte ptr ds:[Pozic],60
         ja        SetIntn2
         and       al,not bit0              ; je m¢d 40 znak–
SetIntn2:mov       dx,3d8h
         out       dx,al
         or        al,bit2                  ; ‡ernob¡l˜ m¢d
         mov       dl,0b8h
         out       dx,al

; ------ n vrat registr–

SetIntn9:pop       dx
         pop       bx
         pop       ax
         ret

SetInten ENDP

; *****************************************************************************
;                              ImplVMod
;                   implicitn¡ videom¢d p©i startu
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; zni‡en‚ registry: AX, BX, CX, SI
; *****************************************************************************

ImplVMod PROC      FAR

; ------ pro ANSI je inicializa‡n¡ videom¢d 80x25

         test      byte ptr ds:[MonoMod],bit4 ; je v˜stup ANSI ?
         jnz       ImplVMd2                 ; je v˜stup ANSI

; ------ nalezen¡ videom¢du zadan‚ho u‘ivatelem

         mov       dx,word ptr ds:[InitVMd] ; rozmˆry po‘adovan‚ho videom¢du
         call      SrcVMod                  ; nalezen¡ videom¢du v tabulce
         jnc       ImplVMd4                 ; videom¢d nalezen OK

;; ------ ponech n¡ aktu ln¡ho videom¢du
;
;         mov       dl,ds:[Pozic]            ; po‡et pozic na © dek
;         mov       dh,ds:[Radku]            ; po‡et © dk– celkem
;         mov       word ptr ds:[InitVMd],dx ; implicitn¡ videom¢d
;         call      SrcVMod                  ; nalezen¡ videom¢du v tabulce
;         jnc       ImplVMd4                 ; videom¢d nalezen OK

; ------ nalezen¡ standardn¡ho videom¢du 80x25

ImplVMd2:mov       dx,80 + 25*HI
         mov       word ptr ds:[InitVMd],dx ; implicitn¡ videom¢d
         call      SrcVMod                  ; nalezen¡ standardn¡ho videom¢du

; ------ £schova ‡¡sla videom¢du

ImplVMd4:mov       ax,ds:[si]               ; ‡¡slo videom¢du
         mov       ds:[InitVMdN],ax         ; ‡¡slo po‘adovan‚ho videom¢du
         mov       ds:[InitVMdM],si         ; adresa aktu ln¡ho videom¢du
         ret

ImplVMod ENDP

; *****************************************************************************
;                               ShiftF10
;                     posun k dal¨¡mu videom¢du
;           Mus¡ b˜t ozna‡en nˆkter˜ videom¢d jako povolen˜ !
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

ShiftF10 PROC      FAR

; ------ £schova registr–

         push      ax
         push      si

; ------ nalezen¡ dal¨¡ho videom¢du

         mov       si,ds:[InitVMdM]         ; aktu ln¡ videom¢d
ShftF102:add       si,4                     ; zv˜¨en¡ ukazatele v tabulce
         cmp       si,offset TabVMod+4*MaxVMod ; je ji‘ konec tabulky ?
         jb        ShftF104                 ; nen¡ je¨tˆ konec tabulky
         mov       si,offset TabVMod        ; za‡ tek tabulky
ShftF104:test      byte ptr ds:[si+1],bit6  ; je to ozna‡en˜ m¢d ?
         jz        ShftF102                 ; nen¡ ozna‡en˜ m¢d - dal¨¡

; ------ parametry nalezen‚ho videom¢du

         mov       ax,ds:[si]               ; ‡¡slo videom¢du
         mov       ds:[InitVMdN],ax         ; ‡¡slo videom¢du
         mov       ds:[InitVMdM],si         ; adresa videom¢du
         mov       ax,ds:[si+2]             ; rozmˆry videom¢du
         mov       word ptr ds:[InitVMd],ax ; rozmˆry videom¢du

; ------ n vrat registr–

         pop       si
         pop       ax

InitVMdI PROC      FAR

         call      far ptr InitVMod

         push      si
         mov       si,offset AMnuMain       ; hlavn¡ adres ©ov‚ menu
         call      far ptr InitMMnu         ; inicializace hlavn¡ho menu
         mov       si,offset EMnuMain       ; hlavn¡ menu editoru
         call      far ptr InitMMnu         ; inicializace hlavn¡ho menu
         pop       si
         ret

InitVMdI ENDP

ShiftF10 ENDP

; *****************************************************************************
;                                InitVMod
;                    nastaven¡ aktu ln¡ho videom¢du
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************
;þ
InitVMod PROC      FAR

; ------ £schova registr–

         call      far ptr MouseOff         ; vypnut¡ kurzoru my¨i
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ inicializace videom¢du pro ANSI

         test      byte ptr ds:[MonoMod],bit4 ; je v˜stup ANSI ?
         jz        InitVMd1                 ; nen¡ v˜stup ANSI

         call      DosEsc                   ; nep©esunovat kurzor na konci © dku
         mov       al,"="
         call      DosChar0

         mov       si,ds:[InitVMdM]         ; adresa po‘adovan‚ho m¢du
         mov       al,"0"                   ; 40 znak–
         cmp       byte ptr ds:[si+2],80    ; bude m‚nˆ pozic ?
         jb        InitVM02                 ; bude m‚nˆ pozic
         mov       al,"2"                   ; 80 znak–
InitVM02:test      byte ptr ds:[si+1],bit7  ; je to MONO m¢d ?
         jnz       InitVM03                 ; je to MONO m¢d
         inc       ax                       ; barevn˜ m¢d
InitVM03:call      DosChar0                 ; ‡¡slo m¢du
         mov       al,"h"
         call      DosChar0

; ------ ‡¡slo po‘adovan‚ho videom¢du

InitVMd1:mov       ax,ds:[InitVMdN]         ; ‡¡slo po‘adovan‚ho videom¢du
         and       ah,not bit6+bit7         ; je to videom¢d VESA ?
         jz        InitVMd3                 ; nen¡ videom¢d VESA
         dec       ah                       ; korekce na ‡¡slo videom¢du VESA

; ------ test, zda je ji‘ nastaven videom¢d VESA (pouze je-li start programu)

         test      byte ptr ds:[StartPar],bit4 ; je startovac¡ inicializace ?
         jz        InitVMd2                 ; nen¡ startovac¡ inicializace
         test      byte ptr ds:[ParDisp],bit7 ; inicializovat videom¢d v‘dy ?
         jnz       InitVMd2                 ; inicializovat videom¢d v‘dy
         xor       bx,bx                    ; BX <- 0 p©ednastaven¡
         push      ax                       ; po‘adovan˜ videom¢d
         mov       ax,4f03h
         call      far ptr Int10P           ; poskytnut¡ videom¢du VESA
         cmp       ax,4fh                   ; je operace OK ?
         pop       ax
         jne       InitVMd2                 ; chyba
         cmp       ax,bx                    ; je videom¢d nastaven ?
         jne       InitVMd2                 ; nen¡ nastaven
         jmp       InitVMd7                 ; videom¢d nastaven OK

; ------ nastaven¡ videom¢du VESA

InitVMd2:xchg      ax,bx                    ; BX <- po‘adovan˜ videom¢d
         call      InitVMdB                 ; nulov n¡ p©¡znaku hust‚ho © dkov.
         mov       ax,4f02h
         call      far ptr Int10P           ; nastaven¡ videom¢du VESA
         jmp       short InitVMd6

; ------ test, zda je ji‘ nastaven bˆ‘n˜ videom¢d

InitVMd3:test      byte ptr ds:[StartPar],bit4 ; je startovac¡ inicializace ?
         jz        InitVMd4                 ; nen¡ startovac¡ inicializace
         test      byte ptr ds:[ParDisp],bit7 ; inicializovat videom¢d v‘dy ?
         jnz       InitVMd4                 ; inicializovat videom¢d v‘dy
         cmp       al,ds:[AktVMod]          ; je videom¢d ji‘ nastaven ?
         jne       InitVMd4                 ; videom¢d nen¡ nastaven
         mov       dx,word ptr ds:[InitVMd] ; po‘adovan‚ rozli¨en¡
         cmp       dl,ds:[Pozic]            ; souhlas¡ po‡et pozic ?
         jne       InitVMd4                 ; po‡et pozic nesouhlas¡
         cmp       dh,ds:[Radku]            ; souhlas¡ po‡et © dk– ?
         je        InitVMd7                 ; v¨e souhlas¡ OK

; ------ nastaven¡ videom¢du bˆ‘n˜m zp–sobem

InitVMd4:push      bx
         call      InitVMdB                 ; nulov n¡ p©¡znaku hust‚ho © dkov.
         call      far ptr SetVMode         ; nastaven¡ po‘adovan‚ho videom¢du
         call      InitVMdB                 ; nulov n¡ p©¡znaku hust‚ho © dkov.
         pop       bx

; ------ test, zda bude mˆnˆn po‡et © dk–

         cmp       byte ptr ds:[TypVCard],3 ; je EGA nebo VGA ?
         jb        InitVMd7                 ; nen¡ EGA/VGA
         cmp       byte ptr ds:[InitVMdN],7 ; je bˆ‘n˜ textov˜ videom¢d ?
         ja        InitVMd7                 ; je videom¢d S-VGA
         mov       al,ds:[InitVMd+1]        ; po‘adovan˜ po‡et © dk–
         cmp       al,ds:[Radku]            ; souhlas¡ po‡et © dk– ?
         jbe       IniVMd62                 ; po‡et © dk– je OK

; ------ nastaven¡ hust¨¡ho © dkov n¡

         cmp       al,30                    ; po‘aduje se 28 © dk– VGA ?
         mov       ax,1111h                 ; na‡ten¡ font– 8x14 VGA
         jbe       InitVMd5                 ; budou fonty 8x14
         mov       al,12h                   ; jinak fonty 8x8
InitVMd5:xor       bx,bx
         call      far ptr Int10P           ; na‡ten¡ font–

; ------ alternativn¡ tisk obrazovky EGA/VGA

InitVMd6:mov       ah,12h
         mov       bl,20h
         call      far ptr Int10P           ; alternativn¡ tisk obrazovky

; ------ aktualizace nov˜ch parametr– displeje

         call      far ptr AktPDisp         ; aktualizace parametr– displeje

; ------ nastaven¡ v¡ce pozic na © dek

IniVMd62:cmp       byte ptr ds:[TypVCard],4 ; je VGA ?
         jb        InitVMd7                 ; nen¡ VGA
         cmp       byte ptr ds:[InitVMd],90 ; po‘adov no 90 pozic na © dek ?
         jne       InitVMd7                 ; nen¡ 90 pozic na © dek
         call      VMod90                   ; nastaven¡ 90 pozic na © dek
         call      far ptr AktPDisp         ; aktualizace parametr– displeje

; ------ korekce p©¡znaku obsluhy snˆ‘en¡

InitVMd7:call      TestSnow                 ; test obsluhy snˆ‘en¡
         call      far ptr InitRows         ; inicializace v˜¨ky oken

; ------ nastaven¡ blok– font– 0 a 0

         cmp       byte ptr ds:[EgaVga],0   ; je displej EGA/VGA ?
         je        InitVM72                 ; nen¡ displej EGA/VGA
         mov       ax,1103h
         xor       bx,bx
         call      far ptr Int10P           ; nastaven¡ blok– 0 a 0

; ------ inicializace ukazatel– hlavn¡ho menu

InitVM72:
; !!!!!!!!!!!!!!!!!!!!!!
; Pozor - p©i zmˆnˆ n rodn¡ho k¢du se zmˆn¡ pozice menu Zvl ¨tn¡
;         podle menu editoru, i kdy‘ je aktivn¡ adres ©ov‚ menu. Radˆji
;         inicializaci nedˆlat.
;
;         mov       si,offset AMnuMain       ; hlavn¡ adres ©ov‚ menu
;         call      far ptr InitMMnu         ; inicializace hlavn¡ho menu
;         mov       si,offset EMnuMain       ; hlavn¡ menu editoru
;         call      far ptr InitMMnu         ; inicializace hlavn¡ho menu

; ------ inicializace barev

IniVMd74:mov       si,offset ColColo        ; barevn˜ m¢d
         test      byte ptr ds:[MonoMod],bit0+bit1 ; je MONO m¢d ?
         jz        InitVMd8                 ; nen¡ MONO m¢d
         mov       si,offset ColMono
InitVMd8:mov       cx,offset ColsEnd
         sub       cx,offset ColsBeg
         push      ds
         pop       es
         mov       di,offset ColsBeg
         cld
         rep       movsb

; ------ oprava p©¡znaku hust‚ho © dkov n¡ BIOS

         call      InitVMdB                 ; nulov n¡ p©¡znaku hust‚ho © dkov.
         cmp       byte ptr ds:[Radku],28   ; je hust‚ © dkov n¡ ?
         jbe       InitVMd9                 ; nen¡ hust‚ © dkov n¡
         or        byte ptr es:[487h],bit0  ; je hust‚ © dkov n¡

; ------ £schova font– displeje

InitVMd9:call      PushFont                 ; £schova font– displeje

; ------ detekce n rodn¡ho k¢du

         call      DetCodeP                 ; detekce k¢dov‚ str nky
         mov       ah,al                    ; £schova aktivn¡ho k¢du

         cmp       byte ptr ds:[CodePage],0 ; je k¢d detekov n ?
         jne       IniVMd91                 ; k¢d je ji‘ detekov n

         cmp       al,3                     ; je nˆjak˜ k¢d ?
         jae       IniVMd90                 ; je nˆjak˜ k¢d
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA/VGA ?
         je        IniVMd90                 ; nen¡ karta EGA/VGA
         test      byte ptr ds:[ParDisp2],bit5 ; prov d¡ se DownLoad font– ?
         jz        IniVMd90                 ; DownLoad se neprov d¡
         mov       al,3                     ; fonty Kamenick˜ch
         cmp       byte ptr ds:[VerzeOS+1],6 ; je syst‚m 6 a v˜¨e ?
         jb        IniVMd90                 ; pro star¨¡ u‘ivatele Kamenick˜ch
         inc       ax                       ; jinak fonty Latin 2
IniVMd90:mov       ds:[CodePage],al         ; detekovan˜ font
         mov       byte ptr ds:[CodePagK],1 ; je k¢d Kamenick˜ch
         cmp       al,3                     ; je Kamenick˜ch ?
         je        IniVMd91                 ; je Kamenick˜ch
         inc       byte ptr ds:[CodePagK]   ; je k¢d Latin 2
         cmp       al,4                     ; je Latin 2 ?
         je        IniVMd91                 ; je Latin 2
         mov       byte ptr ds:[CodePagK],0 ; jinak k¢d neur‡en˜

; ------ test, zda jsou fonty ji‘ nadefinov ny

IniVMd91:and       byte ptr ds:[ParDisp],not bit5 ; download nen¡ proveden
         cmp       ah,ds:[CodePage]         ; je k¢d ji‘ nastaven ?
         jne       IniVMd95                 ; k¢d nen¡ nastaven
         or        byte ptr ds:[ParDisp],bit5 ; k¢d je ji‘ nastaven

; ------ inicializace vlastn¡ch font–

IniVMd95:call      far ptr InitFont         ; inicializace n rodn¡ch font–
IniVMd96:

; ------ inicializace tabulky znak–

InitVMdA:mov       si,offset LZnakTab       ; definice pro Latin 2
         cmp       byte ptr ds:[CodePage],4 ; je k¢d Latin 2 ?
         je        IniVMdA2                 ; je Latin 2
         mov       si,offset BZnakTab       ; bˆ‘n‚ znaky

IniVMdA2:mov       di,offset ZnakTab        ; tabulka znak–
         mov       cx,offset(ZnakTab0-ZnakTab) ; d‚lka tabulky
         push      ds
         pop       es
         cld
         rep       movsb                    ; p©enos definic znak–

; ------ p©¡prava k¢dov‚ str nky displeje

         mov       bl,ds:[CodePage]         ; k¢dov  str nka
         mov       bh,0
         shl       bx,1
         mov       ax,ds:[bx+CodePagT]      ; adresa
         mov       ds:[KodFntTb],ax         ; adresa k¢dovac¡ tabulky

; ------ inicializace ANSI

         test      byte ptr ds:[MonoMod],bit4 ; je v˜stup ANSI ?
         jnz       IniVMdA3
         jmp       IniVMdA4                 ; nen¡ v˜stup ANSI

; ------ kurzor se z konce © dku nep©esunuje na dal¨¡

IniVMdA3:call      DosEsc                   ; nep©esunovat kurzor na konci © dku
         mov       al,"="
         call      DosChar0
         mov       al,"7"
         call      DosChar0
         mov       al,"l"
         call      DosChar0

; ------ norm ln¡ atributy barev

         call      DosEsc                   ; norm ln¡ atributy barev
         mov       al,"0"
         call      DosChar0
         mov       al,"m"
         call      DosChar0
         mov       byte ptr ds:[AnsiAtr],0

; ------ nastaven¡ po‡ tku okna - lev˜ horn¡ roh

         call      DosEsc
         call      DosCharS                 ; oddˆlovac¡ znak ";"
         mov       al,"H"
         call      DosChar0                 ; kurzor do lev‚ho horn¡ho rohu
         mov       word ptr ds:[AnsiPoz],0  ; kurzor v lev‚m horn¡m rohu

; ------ zru¨en¡ star‚ho segmentu ANSI

         mov       ax,ds:[AnsiSegm]         ; segment ANSI
         call      far ptr DelSeg           ; zru¨en¡ segmentu ANSI
         mov       ds:[AnsiSegm],ax         ; p©¡znak zru¨en¡ segmentu
         mov       ds:[AnsiSize],ax         ; velikost segmentu = 0

; ------ vytvo©en¡ nov‚ho segmentu ANSI

         mov       al,ds:[Radku]            ; po‡et © dk– celkem
         mov       ah,0
         mul       word ptr ds:[ByteRow]    ; v˜po‡et velikosti videopamˆti
         or        dx,dx                    ; je v¡ce ne‘ 64 KB ?
         jnz       IniVMdA4                 ; je v¡ce ne‘ 64 KB
         xchg      ax,bx                    ; BX <- velikost videopamˆti

         call      far ptr CreatSeg         ; vytvo©en¡ segmentu ANSI
         jc        IniVMdA4
         mov       ds:[AnsiSegm],ax         ; segment ANSI
         call      far ptr ModiSegS         ; nastaven¡ velikosti segmentu
         jc        IniVMdA4                 ; chyba
         mov       ds:[AnsiSize],bx         ; velikost segmentu

; ------ vynulov n¡ segmentu ANSI

         call      far ptr GetDat           ; adresa segmentu
         xor       di,di
         xor       ax,ax                    ; nulovac¡ slovo
         mov       cx,bx                    ; CX <- velikost segmentu
         shr       cx,1                     ; velikost ve slovech
         cld
         rep       stosw                    ; vymaz n¡ segmentu

; ------ n vrat registr–

IniVMdA4:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr InitMous         ; inicializace my¨i
         call      far ptr SizeLKur         ; nastaven¡ kurzoru
         call      far ptr SetInten         ; nastaven¡ intenzity displeje
         call      SetGray                  ; nastaven¡ ¨ed‚ stupnice
         ret

InitVMod ENDP

; ------ nulov n¡ p©¡znaku hust‚ho © dkov n¡

InitVMdB:push      ax
         xor       ax,ax
         mov       es,ax
         and       byte ptr es:[487h],not bit7+bit0
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        nastaven¡ ¨ed‚ stupnice
; -----------------------------------------------------------------------------

SetGray  PROC      NEAR

         test      byte ptr ds:[ParDisp2],bit4 ; pou‘¡t ¨ed‚ palety VGA ?
         jz        SetGray9                 ; nejsou ¨ed‚ palety VGA
         push      ax
         push      bx
         push      cx
         push      dx

         mov       ax,101bh
         xor       bx,bx
         mov       cx,100h
         call      far ptr Int10P

         pop       dx
         pop       cx
         pop       bx
         pop       ax
SetGray9:ret

SetGray  ENDP

; -----------------------------------------------------------------------------
;        detekce k¢dov‚ str nky displeje -> AX
; -----------------------------------------------------------------------------

DetCodeP PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©ednastaven¡ pro displeje Hercules a CGA

         mov       bp,2                     ; implicitnˆ k¢d IBM
         cmp       byte ptr ds:[TypVCard],3 ; je HGC nebo CGA ?
         jb        DetCodP9                 ; je HGC nebo CGA

         mov       bp,4                     ; k¢d Latin 2
         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       DetCodP9                 ; je m¢d WINDOWS

; ------ zapnut¡ m¢du font–

         cli
         call      FontOn                   ; zapnut¡ m¢du font–

; ------ p©¡prava registr–

         xor       cx,cx                    ; CX <- 0
         mov       ax,0a000h
         mov       es,ax                    ; ES <- segment font–
         mov       bx,offset TestCodT       ; tabulka k¢d–

; ------ ulo‘en¡ ‡¡sla k¢du a p©¡prava k testu jednoho k¢du

DetCodP2:mov       al,cs:[bx]               ; ‡¡slo k¢du
         mov       ah,0
         xchg      ax,bp                    ; BP <- ulo‘en¡ ‡¡sla k¢du
         inc       bx                       ; p©esko‡en¡ ‡¡sla k¢du
         mov       dx,800h                  ; DH <- po‡et k¢d–, DL = ‡¡ta‡ shod

; ------ adresa testovan‚ho znaku (> 128)

DetCodP3:mov       al,32                    ; po‡et bajt– na znak
         mul       byte ptr cs:[bx]         ; adresa testovan‚ho znaku
         inc       bx
         xchg      ax,si                    ; SI <- adresa testovan‚ho znaku

; ------ adresa referen‡n¡ho znaku (< 128)

         mov       al,32                    ; po‡et bajt– na znak
         mul       byte ptr cs:[bx]         ; adresa referen‡n¡ho znaku
         inc       bx
         xchg      ax,di                    ; DI <- adresa referen‡n¡ho znaku

; ------ porovn n¡ znaku

         mov       cl,ds:[LineFont]         ; po‡et bajt– na znak
DetCodP4:mov       al,es:[di]               ; referen‡n¡ znak
         mov       ah,es:[si]               ; testovan˜ znak
         inc       si
         inc       di
         cmp       al,0                     ; je mezera ?
         jne       DetCodP5                 ; nen¡ mezera
         mov       ah,0                     ; n hrada v referenci
DetCodP5:cmp       al,ah                    ; je shoda ?
         loope     DetCodP4                 ; p©i shodˆ dal¨¡ bajt
         jne       DetCodP6                 ; nen¡ shoda
         inc       dx                       ; ‡¡ta‡ shody

; ------ dal¨¡ znak jednoho k¢du

DetCodP6:dec       dh                       ; ‡¡ta‡ znak– jednoho k¢du
         jnz       DetCodP3                 ; dal¨¡ znak jednoho k¢du

; ------ rozli‘en¡, zda byl nalezen k¢d OK

         cmp       dl,5                     ; minim ln¡ po‡et shod
         jae       DetCodP8                 ; k¢d nalezen OK

; ------ p©¡prava pro dal¨¡ k¢d

         cmp       byte ptr cs:[bx],0       ; je konec tabulky ?
         jne       DetCodP2                 ; test dal¨¡ho k¢du

; ------ implicitn¡ m¢d, pokud k¢d nebyl nalezen

         mov       bp,1                     ; nen¡ diakritika

; ------ vypnut¡ m¢du font–

DetCodP8:call      FontOff                  ; vypnut¡ m¢du font–
         sti

; ------ n vrat registr–

DetCodP9:xchg      ax,bp                    ; AX <- detekovan˜ k¢d
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

DetCodeP ENDP

; ------ tabulka znak– pro detekci font–

TestCodT label     byte
         db        3                        ; k¢d Kamenick˜ch
         db        '‡c'                     ; ‡
         db        'ˆe'                     ; ˆ
         db        '‘z'                     ; ‘
         db        '–u'                     ; –
         db        '˜y'                     ; ˜
         db        '¤n'                     ; ¤
         db        '¨s'                     ; ¨
         db        '©r'                     ; ©

         db        4                        ; k¢d Latin 2
         db        133,'u'                  ; –
         db        159,'c'                  ; ‡
         db        167,'z'                  ; ‘
         db        216,'e'                  ; ˆ
         db        229,'n'                  ; ¤
         db        231,'s'                  ; ¨
         db        236,'y'                  ; ˜
         db        253,'r'                  ; ©

         db        2                        ; k¢d IBM
         db        'u'                     ; 
         db        '‚e'                     ; ‚
         db        '„a'                     ; „
         db        '“o'                     ; “
         db        ' a'                     ;  
         db        '¡i'                     ; ¡
         db        '¢o'                     ; ¢
         db        '£u'                     ; £

         db        0                        ; konec tabulky

; -----------------------------------------------------------------------------
;        nastaven¡ 90 pozic na © dek (pro VGA)
; -----------------------------------------------------------------------------

VMod90   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      es

; ------ synchronizace registr– CRT

         cli
         mov       dx,ds:[PortCRT]          ; adresa CRT + 6
         in        al,dx                    ; synchronizace registr– CRT

; ------ £schova registru 11h

         sub       dx,6
         mov       al,11h
         out       dx,al                    ; volba registru 11h
         inc       dx
         in        al,dx                    ; na‡ten¡ registru 11h
         dec       dx
         mov       ah,al                    ; AH <- na‡ten  hodnota
         mov       al,11h                   ; registr 11h
         push      ax                       ; £schova registru 11h

; ------ vypnut¡ ochrany registr– VGA

         and       ah,not bit7              ; ochrana bude vypnuta
         out       dx,ax                    ; vypnut¡ ochrany registr–

; ------ nastaven¡ ©adi‡e CRT

         cld
         mov       cx,7                     ; po‡et registr–
         mov       si,offset Reg90          ; nastaven¡ registr– 90 pozic
VMod902: lodsw
         out       dx,ax
         loop      VMod902                  ; nastaven¡ registr– CRT

; ------ n vrat registru 11h

         pop       ax
         out       dx,al                    ; n vrat registru 11h

; ------ synchronn¡ reset

         mov       dx,3c4h
         mov       ax,bit0*HI + 0
         out       dx,ax                    ; synchronn¡ reset karty

; ------ nastaven¡ 8 bod– na znak

         mov       ax,bit0*HI + 1
         out       dx,ax                    ; nastaven¡ 8 bod– na znak

; ------ uvolnˆn¡ synchronn¡ho reset

         mov       ax,(bit0+bit1)*HI + 0
         out       dx,ax                    ; uvolnˆn¡ synchronn¡ho reset

; ------ nastaven¡ registr– BIOS

         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       al,90                    ; po‡et pozic na © dek
         mov       es:[44ah],al             ; po‡et pozic na © dek
         mul       byte ptr ds:[Radku]      ; po‡et znak– na obrazovku
         shl       ax,1                     ; po‡et bajt– na obrazovku
         mov       es:[44ch],ax             ; d‚lka bufferu displeje

; ------ nastaven¡ horizont ln¡ho posunu PANNING

         mov       dl,0c0h
         mov       al,13h                   ; registr PANNING
         out       dx,al                    ; volba registru PANNING
         mov       al,0
         out       dx,al                    ; nastaven¡ posunu 0
         mov       al,bit5
         out       dx,al                    ; uvolnˆn¡ displeje
         sti

; ------ n vrat registr–

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

VMod90   ENDP

; *****************************************************************************
;                                  InitSFnt
;                   inicializace segmentu pro £schovu font–
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; VSTUP: CY=chyba pamˆti
; ni‡¡ registry AX, BX
; *****************************************************************************

InitSFnt PROC      FAR

; ------ test, zda je karta EGA/VGA

         cmp       byte ptr ds:[EgaVga],0   ; je displej EGA/VGA ?
         je        InitSFn9                 ; nen¡ displej EGA/VGA

; ------ vytvo©en¡ segmentu pro £schovu font–

         call      far ptr CreatSeg         ; vytvo©en¡ segmentu
         jc        InitSFn9
         mov       ds:[FontSegm],ax         ; segment bufferu

; ------ nastaven¡ velikosti segmentu font–

         mov       bx,32*128/16             ; 128 znak– po 32 bajtech (4 KB)
         call      far ptr ModiSeg          ; nastaven¡ velikosti segmentu
InitSFn9:ret

InitSFnt ENDP

; -----------------------------------------------------------------------------
;        inicializace n rodn¡ch font– displeje
; -----------------------------------------------------------------------------

InitFont PROC      FAR

; ------ test, zda se p©edefinov n¡ znak– provede

         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA/VGA ?
         je        InitFnt9                 ; nen¡ karta EGA/VGA
         test      byte ptr ds:[ParDisp2],bit5 ; povolen DownLoad font– ?
         jz        InitFnt9                 ; nen¡ povolen DownLoad font–
         cmp       byte ptr ds:[CodePage],3 ; jsou fonty ?
         jb        InitFnt9                 ; neprov d¡ se DownLoad
         test      byte ptr ds:[ParDisp],bit5 ; jsou fonty ji‘ nastaveny ?
         jnz       InitFnt9                 ; fonty jsou ji‘ nastaveny
         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       InitFnt9                 ; je m¢d WINDOWS

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ adresa bufferu uschovan˜ch font–

         mov       bp,0a000h+(32*128)/16    ; adresa, nen¡-li buffer
         test      byte ptr ds:[ParDisp],bit3 ; jsou fonty uschov ny ?
         jz        InitFnt2                 ; fonty nejsou uschov ny
         mov       ax,ds:[FontSegm]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        InitFnt2                 ; nˆjak  chyba
         mov       bp,es                    ; BP <- adresa bufferu

; ------ zapnut¡ znakov‚ho m¢du

InitFnt2:cli
         call      FontOn                   ; zapnut¡ znakov‚ho m¢du

; ------ p©edefinov n¡ font–

         mov       ch,0
         mov       cl,ds:[LineFont]         ; po‡et linek na znak
         mov       bx,offset Font8
         cmp       cl,10
         jbe       InitFnt3
         mov       bx,offset Font14
InitFnt3:call      Defin

; ------ vypnut¡ znakov‚ho m¢du

         call      FontOff                  ; vypnut¡ znakov‚ho m¢du
         sti

; ------ n vrat registr–

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
InitFnt9:ret

InitFont ENDP

; -----------------------------------------------------------------------------
;        p©edefinov n¡ n rodn¡ch font–
; -----------------------------------------------------------------------------
; VSTUP: CS:BX=vlastn¡ fonty
;        CX=po‡et linek na znak
;        BP=segment bufferu font– > 128
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

Defin    PROC      NEAR

         push      ds

; ------ adresa definice fontu

         mov       si,offset TabLat         ; definice pro Latin 2
         cmp       byte ptr ds:[CodePage],4 ; je Latin 2 ?
         je        Tabel0                   ; je Latin 2
         mov       si,offset TabKam         ; definice pro Kamenick˜ch

; ------ p©¡prava registr–

Tabel0:  mov       ax,0a000h                ; segment videopamˆti
         mov       es,ax                    ; segment videopamˆti
         mov       ds,ax
         mov       dh,80h                   ; po‡ te‡n¡ ukazatel znak–

; ------ test konce tabulky

Tabel1:  mov       ax,cs:[si]               ; definice z tabulky
         inc       si
         inc       si
         or        ax,ax                    ; je konec tabulky ?
         jnz       Tabel2                   ; nen¡ je¨tˆ konec tabulky

         pop       ds
         ret

; ------ proveden¡ skoku

Tabel2:  push      ax
         and       al,7                     ; d‚lka skoku
         add       dh,al                    ; zv˜¨en¡ ‡¡sla znaku
         pop       ax

; ------ p©evod znaku

         shr       al,1
         shr       al,1
         shr       al,1                     ; ‡¡slo fontu (0 a‘ 31)
         mov       dl,ah                    ; standardn¡ znak
         call      PrevCh                   ; p©evod znaku
         inc       dh                       ; zv˜¨en¡ ukazatele
         jmp       short Tabel1             ; dal¨¡ font

Defin    ENDP

; -----------------------------------------------------------------------------
;     P©evod znaku
; -----------------------------------------------------------------------------
; VSTUP: ES,DS=segment videopamˆti
;        CS:BX=vlastn¡ fonty
;        DL=standardn¡ znak
;        DH=m¡sto k ulo‘en¡
;        AL=‡¡slo fontu 0 a‘ 31
; -----------------------------------------------------------------------------
; zni‡en‚ registry: AX, DI
; -----------------------------------------------------------------------------

PrevCh   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         mov       ah,0
         cld                                ; smˆr nahoru

; ------ adresa vlastn¡ho fontu

Prevch0: dec       ax
         js        Prevch4                  ; font nalezen
         push      ax
         mov       al,cs:[bx]               ; definice fontu
         inc       bx
         and       al,0fh                   ; d‚lka fontu
         add       bx,ax                    ; zv˜¨en¡ adresy fontu
         pop       ax
         jmp       short Prevch0            ; dal¨¡ font

; ------ adresa m¡sta ulo‘en¡ znaku ES:DI

Prevch4: mov       al,32                    ; po‡et bajt– na znak ve fontech
         mul       dh                       ; offset ve videopamˆti
         xchg      ax,di                    ; adresa znaku ve videopamˆti

; ------ adresa standardn¡ho fontu DS:SI

         mov       al,32                    ; po‡et linek na znak
         mul       dl                       ; offset v tabulce stand. znak–
         push      es
         pop       ds                       ; DS <- segment videopamˆti
         or        dl,dl                    ; je znak > 127 ?
         jns       PrevCh45                 ; nen¡ znak > 127
         mov       ds,bp                    ; DS <- adresa bufferu font–
         sub       ax,128*32                ; korekce adresy
PrevCh45:xchg      ax,si                    ; SI <- adresa standardn¡ho znaku

; ------ po‡ te‡n¡ a koncov  linka fontu

         mov       dl,cs:[bx]               ; po‡ te‡n¡ linka a d‚lka
         inc       bx                       ; zv˜¨en¡ adresy
         mov       dh,dl                    ; kopie do DH
         and       dl,0fh                   ; DL=d‚lka 0 a‘ 15
         shr       dh,1
         shr       dh,1
         shr       dh,1
         shr       dh,1                     ; DH=po‡ te‡n¡ linka 0 a‘ 15

; ------ korekce pro fonty 16x8 a 19x8

         cmp       cl,14
         jbe       Prevch5

         cmp       cl,19
         jb        Prevch55
         or        dh,dh
         jz        PrevCh55
         add       dh,2
         cmp       dh,8
         jbe       Prevch55
         inc       dh
Prevch55:cmp       dh,8
         jb        Prevch5                  ; je v horn¡ polovinˆ
         add       dh,2                     ; zv˜¨en¡ pozice

; ------ korekce horn¡ch linek pro 8x8

Prevch5: or        dl,dl                    ; je nˆjak˜ font ?
         jz        Prevch8                  ; nen¡ ‘ dn˜ font - nen¡ korekce
         cmp       dh,4                     ; je font dole ?
         jae       Prevch8                  ; je font dole - nen¡ korekce
         inc       si
         mov       ax,100h                  ; korekce pro font 8x8
         cmp       cl,8                     ; je font 8x8 ?
         je        Prevch7                  ; nen¡ font 8x8
         dec       si
Prevch8: mov       ah,-1                    ; nen¡ korekce pro ostatn¡ znaky

; ------ p©evod jednoho znaku

         mov       cx,32                    ; po‡et linek k p©evodu
Prevch1: lodsb                              ; bajt standardn¡ho fontu
         dec       ah                       ; korekce pro fonty 8x8
         jnz       Prevch7                  ; nen¡ prvn¡ bajt
         or        al,ds:[si-2]             ; + bajt z p©ede¨l‚ linky
Prevch7: dec       dh                       ; ‡¡ta‡ po‡ te‡n¡ linky
         jns       Prevch2                  ; je pod po‡ te‡n¡ linkou
         dec       dl                       ; ‡¡ta‡ po‡tu linek
         js        Prevch2                  ; je nad koncovou linkou
         or        al,cs:[bx]               ; slou‡en¡ s vlatn¡m znakem
         inc       bx                       ; zv˜¨en¡ adresy vlastn¡ho fontu
Prevch2: stosb                              ; ulo‘en¡ do videopamˆti
         loop      Prevch1                  ; dal¨¡ bajt

; ------ n vrat registr–

Prevch3: pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

PrevCh   ENDP

font8    label     byte                     ; fonty 8x8
         db        2,0ch,18h                ; carv: ‡ rka pro velk  p¡smena
         db        2,0ch,18h                ; carm: ‡ rka pro mal  p¡smena
         db        2,3,3                    ; carp: ‡ rka po prav‚ stranˆ
         db        2,30h,18h                ; zcarv: zpˆtn  ‡ rka pro velk  p¡s.
         db        2,30h,18h                ; zcarm: zpˆtn  ‡ rka pro mal  p¡sm.
         db        2,6ch,38h                ; hacv: h ‡ek pro velk  p¡smena
         db        2,6ch,38h                ; hacm: h ‡ek pro mal  p¡smena
         db        3,3,1,2                  ; hacp: h ‡ek po prav‚ stranˆ
         db        3,10h,28h,10h            ; krov: krou‘ek nad velk˜m "U"
         db        3,38h,6ch,38h            ; krom: krou‘ek nad mal˜m "u"
         db        1,0feh                   ; strv: st©¡¨ka nad velk˜m p¡smenem
         db        32h,30h,0c0h             ; skrl: p©e¨krtnut¡ vlevo
         db        32h,18h,60h              ; skrs: p©e¨krtnut¡ uprost©ed
         db        21h,7eh                  ; skrp: p©e¨krtnut¡ vpravo
         db        2,66h,0cch               ; dvov: dvoj‡ rka nad velk˜m p¡sm.
         db        2,66h,0cch               ; dvom: dvoj‡ rka nad mal˜m p¡sm.
         db        62h,8,0eh                ; (patr: pati‡ka vpravo)
         db        62h,10h,1eh              ; pats: pati‡ka uprost©ed
         db        62h,18h,78h              ; ocap: oc sek uprost©ed
         db        1,18h                    ; tecv: te‡ka nad velk˜m p¡smenem
         db        1,18h                    ; tecm: te‡ka nad mal˜m p¡smenem
         db        2,0c6h,7ch               ; misv: miska nad velk˜m p¡smenem
         db        2,0c6h,7ch               ; mism: miska nad mal˜m p¡smenem
         db        7,0c6h,7ch,0c6h,0c6h,0c6h,7ch,0c6h ; spc1: rubl
         db        1,66h                    ; dvot: dvojte‡ka
         db        0                        ; nofn: konec tabulky

font14   label     byte                     ; fonty 8x14 a 8x16
         db        2,0ch,18h                ; carv: ‡ rka pro velk  p¡smena
         db        13h,0ch,18h,30h          ; carm: ‡ rka pro mal  p¡smena
         db        3,3,3,2                  ; carp: ‡ rka po prav‚ stranˆ
         db        2,30h,18h                ; zcarv: zpˆtn  ‡ rka pro velk  p¡s.
         db        13h,30h,18h,0ch          ; zcarm: zpˆtn  ‡ rka pro mal  p¡sm.
         db        3,66h,3ch,18h            ; hacv: h ‡ek pro velk  p¡smena
         db        13h,66h,3ch,18h          ; hacm: h ‡ek pro mal  p¡smena
         db        4,3,3,1,2                ; hacp: h ‡ek po prav‚ stranˆ
         db        3,10h,28h,10h            ; krov: krou‘ek nad velk˜m "U"
         db        13h,38h,6ch,38h          ; krom: krou‘ek nad mal˜m "u"
         db        2,7eh,0c3h               ; strv: st©¡¨ka nad velk˜m p¡smenem
         db        52h,30h,0c0h             ; skrl: p©e¨krtnut¡ vlevo
         db        52h,0ch,30h              ; skrs: p©e¨krtnut¡ uprost©ed
         db        31h,7eh                  ; skrp: p©e¨krtnut¡ vpravo
         db        2,33h,66h                ; dvov: dvoj‡ rka nad velk˜m p¡sm.
         db        22h,33h,66h              ; dvom: dvoj‡ rka nad mal˜m p¡sm.
         db        094h,8,8,8,0eh           ; patr: (pati‡ka vpravo)
         db        094h,18h,18h,30h,1eh     ; pats: pati‡ka uprost©ed
         db        0a4h,18h,18h,0ch,78h     ; ocap: oc sek uprost©ed
         db        2,18h,18h                ; tecv: te‡ka nad velk˜m p¡smenem
         db        22h,18h,18h              ; tecm: te‡ka nad mal˜m p¡smenem
         db        2,0c6h,7ch               ; misv: miska nad velk˜m p¡smenem
         db        22h,0c6h,7ch             ; mism: miska nad mal˜m p¡smenem
         db        47h,0c6h,7ch,0c6h,0c6h,0c6h,7ch,0c6h ; spc1: rubl
         db        1,66h                    ; dvot: dvojte‡ka
         db        0                        ; nofn: konec tabulky

carv     equ       00h                      ; ‡ rka pro velk  p¡smena
carm     equ       08h                      ; ‡ rka pro mal  p¡smena
carp     equ       10h                      ; ‡ rka po prav‚ stranˆ
zcarv    equ       18h                      ; zpˆtn  ‡ rka pro velk  p¡smena
zcarm    equ       20h                      ; zpˆtn  ‡ rka pro mal  p¡smena
hacv     equ       28h                      ; h ‡ek pro velk  p¡smena
hacm     equ       30h                      ; h ‡ek pro mal  p¡smena
hacp     equ       38h                      ; h ‡ek po prav‚ stranˆ
krov     equ       40h                      ; krou‘ek nad velk˜m "U"
krom     equ       48h                      ; krou‘ek nad mal˜m "u"
strv     equ       50h                      ; st©¡¨ka nad velk˜m p¡smenem
skrl     equ       58h                      ; p©e¨krnut¡ vlevo
skrs     equ       60h                      ; p©e¨krtnut¡ uprost©ed
skrp     equ       68h                      ; p©e¨krtnut¡ vpravo
dvov     equ       70h                      ; dvoj‡ rka nad velk˜m p¡smenem
dvom     equ       78h                      ; dvoj‡ rka nad mal˜m p¡smenem
;patr     equ       80h                      ; pati‡ka vpravo
pats     equ       88h                      ; pati‡ka uprost©ed
ocap     equ       90h                      ; oc sek uprost©ed
tecv     equ       98h                      ; te‡ka nad velk˜m p¡smenem
tecm     equ       0a0h                     ; te‡ka nad mal˜m p¡smenem
misv     equ       0a8h                     ; miska nad velk˜m p¡smenem
mism     equ       0b0h                     ; miska nad mal˜m p¡smenem
spc1     equ       0b8h                     ; speci ln¡ znak - rubl
dvot     equ       0c0h                     ; dvojte‡ka

nofn     equ       0c8h                     ; konec tabulky

TabKam   label     byte                     ; defini‡n¡ tabulka Kamenick˜ch
         db        hacv,'C'                 ; "C" s h ‡kem
         db        carm+1,'e'               ; "e" s ‡ rkou
         db        hacp,'d'                 ; "d" s h ‡kem
         db        hacv+1,'D'               ; "D" s h ‡kem
         db        hacv,'T'                 ; "T" s h ‡kem
         db        hacm,'c'                 ; "c" s h ‡kem
         db        hacm,'e'                 ; "e" s h ‡kem
         db        hacv,'E'                 ; "E" s h ‡kem
         db        carv,'L'                 ; "L" s ‡ rkou
         db        carv,'I'                 ; "I" s ‡ rkou
         db        hacp,'l'                 ; "l" s h ‡kem
         db        carv,'l'                 ; "l" s ‡ rkou
         db        carv+1,'A'               ; "A" s ‡ rkou
         db        carv,'E'                 ; "E" s ‡ rkou
         db        hacm,'z'                 ; "z" s h ‡kem
         db        hacv,'Z'                 ; "Z" s h ‡kem
         db        carv+2,'O'               ; "O" s ‡ rkou
         db        krom,'u'                 ; "u" s krou‘kem
         db        carv,'U'                 ; "U" s ‡ rkou
         db        carm,'y'                 ; "y" s ‡ rkou
         db        hacv+2,'S'               ; "S" s h ‡kem
         db        hacp,'L'                 ; "L" s h ‡kem
         db        carv,'Y'                 ; "Y" s ‡ rkou
         db        hacv,'R'                 ; "R" s h ‡kem
         db        hacp,'t'                 ; "t" s h ‡kem
         db        carm,'a'                 ; "a" s ‡ rkou
         db        carm+1,'o'               ; "o" s ‡ rkou
         db        carm,'u'                 ; "u" s ‡ rkou
         db        hacm,'n'                 ; "n" s h ‡kem
         db        hacv,'N'                 ; "N" s h ‡kem
         db        krov,'U'                 ; "U" s krou‘kem
         db        strv,'O'                 ; "O" se st©¡¨kou
         db        hacm,'s'                 ; "s" s h ‡kem
         db        hacm,'r'                 ; "r" s h ‡kem
         db        carm,'r'                 ; "r" s ‡ rkou
         db        carv,'R'                 ; "R" s ‡ rkou
         db        nofn+1,21                ; paragraf
         dw        0

TabLat   label     byte                     ; defini‡n¡ tabulka Latin 2
         db        carm+2,'e'               ; "e" s ‡ rkou
         db        krom+2,'u'               ; "u" s krou‘kem
         db        carm,'c'                 ; "c" s ‡ rkou
         db        ocap,'c'                 ; "c" s oc skem
         db        skrs,'l'                 ; "l" p©e¨krtnut‚
         db        dvov+1,'O'               ; "O" s dvoj‡ rkou
         db        dvom,'o'                 ; "o" s dvoj‡ rkou
         db        carv+1,'Z'               ; "Z" s ‡ rkou
         db        carv+1,'C'               ; "C" s ‡ rkou
         db        carv,'E'                 ; "E" s ‡ rkou
         db        carv,'L'                 ; "L" s ‡ rkou
         db        carv,'l'                 ; "l" s ‡ rkou
         db        hacp+2,'L'               ; "L" s h ‡kem
         db        hacp,'l'                 ; "l" s h ‡kem
         db        carv,'S'                 ; "S" s ‡ rkou
         db        carm,'s'                 ; "s" s ‡ rkou
         db        hacv+2,'T'               ; "T" s h ‡kem
         db        hacp,'t'                 ; "t" s h ‡kem
         db        skrl,'L'                 ; "L" p©e¨krtnut‚
         db        nofn,'x'                 ; p©e¨krtnut¡
         db        hacm,'c'                 ; "c" s h ‡kem
         db        carm,'a'                 ; "a" s ‡ rkou
         db        carm+1,'o'               ; "o" s ‡ rkou
         db        carm,'u'                 ; "u" s ‡ rkou
         db        pats,'A'                 ; "A" s pati‡kou
         db        pats,'a'                 ; "a" s pati‡kou
         db        hacv,'Z'                 ; "Z" s h ‡kem
         db        hacm,'z'                 ; "z" s h ‡kem
         db        pats,'E'                 ; "E" s pati‡kou
         db        pats,'e'                 ; "e" s pati‡kou
         db        carm+1,'z'               ; "z" s ‡ rkou
         db        hacv,'C'                 ; "C" s h ‡kem
         db        ocap,'s'                 ; "s" s oc skem
         db        carv+7,'A'               ; "A" s ‡ rkou
         db        strv,'A'                 ; "A" se st©¡¨kou
         db        hacv,'E'                 ; "E" s h ‡kem
         db        ocap,'S'                 ; "S" s oc skem
         db        tecv+4,'Z'               ; "Z" s te‡kou
         db        tecm,'z'                 ; "z" s te‡kou
         db        misv+7,'A'               ; "A" s miskou
         db        mism,'a'                 ; "a" s miskou
         db        spc1+7,' '               ; rubl
         db        skrp,'d'                 ; "d" p©e¨krtnut‚
         db        skrl,'D'                 ; "D" p©e¨krtnut‚
         db        hacv,'D'                 ; "D" s h ‡kem
         db        dvot,'E'                 ; "E" dvojte‡ka
         db        hacp,'d'                 ; "d" s h ‡kem
         db        hacv,'N'                 ; "N" s h ‡kem
         db        carv,'I'                 ; "I" s ‡ rkou
         db        strv,'I'                 ; "I" se st©¡¨kou
         db        hacm,'e'                 ; "e" s h ‡kem
         db        ocap+4,'T'               ; "T" s oc skem
         db        krov,'U'                 ; "U" s krou‘kem
         db        carv+1,'O'               ; "O" s ‡ rkou
         db        strv+1,'O'               ; "O" se st©¡¨kou
         db        carv,'N'                 ; "N" s ‡ rkou
         db        carm,'n'                 ; "n" s ‡ rkou
         db        hacm,'n'                 ; "n" s h ‡kem
         db        hacv,'S'                 ; "S" s h ‡kem
         db        hacm,'s'                 ; "s" s h ‡kem
         db        carv,'R'                 ; "R" s ‡ rkou
         db        carv,'U'                 ; "U" s ‡ rkou
         db        carm,'r'                 ; "r" s ‡ rkou
         db        dvov,'U'                 ; "U" s dvoj‡ rkou
         db        carm,'y'                 ; "y" s ‡ rkou
         db        carv,'Y'                 ; "Y" s ‡ rkou
         db        ocap,'t'                 ; "t" s oc skem
         db        carm,' '                 ; ‡ rka vpravo
         db        nofn,'-'                 ; poml‡ka
         db        dvom,' '                 ; dvoj‡ rka
         db        pats,' '                 ; pati‡ka
         db        hacm,' '                 ; h ‡ek
         db        mism,' '                 ; miska
         db        nofn,21                  ; paragraf
         db        ocap+1,' '               ; oc sek
         db        krom,' '                 ; krou‘ek
         db        dvot,' '                 ; dvojte‡ka
         db        dvom+1,'u'               ; "u" s dvoj‡ rkou
         db        hacv,'R'                 ; "R" s h ‡kem
         db        hacm,'r'                 ; "r" s h ‡kem
         dw        0

; -----------------------------------------------------------------------------
;                              TestSnow
;                  test (a oprava) obsluhy snˆ‘en¡
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

TestSnow PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ test, zda se m  prov dˆt obsluha snˆ‘en¡

         cmp       byte ptr ds:[ChckSnow],0 ; m  se prov dˆt obsluha snˆ‘en¡ ?
         je        TestSnw8                 ; obsluha snˆ‘en¡ se neprov d¡

; ------ p©¡prava registr– k testu obsluhy snˆ‘en¡

         mov       dx,ds:[PortCRT]          ; stavov˜ registr ©adi‡e displeje
         mov       ch,90h                   ; maxim ln¡ doba pro ‡ek n¡
         sti                                ; povoleno p©eru¨en¡

; ------ ‡ek n¡ na konec zpˆtn‚ho bˆhu

TestSnw4:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         test      al,1                     ; test horizont ln¡ho zpˆtn‚ho bˆhu
         loopnz    TestSnw4                 ; ‡ek n¡ na konec horiz. bˆhu
         jnz       TestSnw7                 ; p©ete‡en¡ doby ‡ek n¡

; ------ ‡ek n¡ na za‡ tek zpˆtn‚ho bˆhu

TestSnw5:in        al,dx                    ; ‡ten¡ stavu video©adi‡e 6845
         test      al,1                     ; test horiz. zpˆtn‚ho bˆhu
         loopz     TestSnw5                 ; ‡ek n¡ na horiz. zpˆtn˜ bˆh
         jnz       TestSnw8                 ; nen¡ p©ete‡en¡ doby

; ------ obsluha snˆ‘en¡ nepracuje

TestSnw7:mov       byte ptr ds:[ChckSnow],0 ; zru¨en¡ p©¡znaku obsluhy snˆ‘en¡

; ------ n vrat registr–

TestSnw8:pop       dx
         pop       cx
         pop       ax
         ret

TestSnow ENDP

; *****************************************************************************
;                               SetVMode
;           Nastaven¡ videom¢du (vhodn‚ rozpozn n¡ videokarty EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  AL=po‘adovan˜ videom¢d
;         DS=datov˜ segment
; VSTUP: AL=nov˜ aktu ln¡ videom¢d
;         CY=videom¢d nenastaven
; *****************************************************************************

SetVMode PROC      FAR

; ------ £schova registr–

         push      bx
         push      ax                       ; £schova po‘adovan‚ho videom¢du

; ------ nastaven¡ videom¢du

         mov       ah,0                     ; funkce nastaven¡ videom¢du
         call      far ptr Int10P           ; nastaven¡ videom¢du
         call      far ptr AktPDisp         ; poskytnut¡ aktivn¡ho videom¢du
         xchg      ax,bx                    ; BL <- £schova aktu ln¡ho videom¢du

; ------ n vrat registr–, zhodnocen¡ v˜sledku

         pop       ax                       ; n vrat po‘adovan‚ho videom¢du
         xchg      al,bl                    ; AL <- nov˜ videom¢d
         cmp       al,bl                    ; souhlas¡ videom¢d s po‘adovan˜m ?
         je        SetVMod1                 ; videom¢d nastaven OK
         stc                                ; p©¡znak chyby nastaven¡ videom¢du
SetVMod1:pop       bx
         ret

SetVMode ENDP

; *****************************************************************************
;                               AktPDisp
;  Atualizace parametr– displeje podle videom¢du (vy‘aduje rozpozn n¡ videokarty)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datov˜ segment
; VSTUP: AL=aktu ln¡ videom¢d
; *****************************************************************************

AktPDisp PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ aktu ln¡ videom¢d a aktu ln¡ videostr nka

         mov       ah,0fh
         call      far ptr Int10P           ; poskytnut¡ aktu ln¡ho videom¢du
         and       al,7fh                   ; zru¨en¡ p©¡znaku nemaz n¡ displeje
         mov       ds:[AktVMod],al          ; aktu ln¡ videom¢d
         mov       byte ptr ds:[VESAVMod],al ; VESA videom¢d
         mov       byte ptr ds:[VESAVMod+1],0
         mov       ds:[AktPage],bh          ; £schova aktivn¡ videostr nky

; ------ po‡et pozic na © dek

         mov       al,ah                    ; AL <- po‡et pozic na © dek
         mov       ah,0
         cmp       al,254                   ; maxim ln¡ po‡et pozic na © dek
         ja        AktPDis1                 ; po‡et pozic na © dek je neplatn˜
         cmp       al,40                    ; minim ln¡ po‡et pozic na © dek
         jae       AktPDis2                 ; po‡et pozic na © dek je OK
AktPDis1:mov       al,80                    ; implicitn¡ po‡et pozic na © dek
AktPDis2:mov       ds:[Pozic],al            ; po‡et pozic na © dek
         dec       ax
         mov       ds:[MaxPoz],al           ; posledn¡ pozice na © dku
         inc       ax
         shl       ax,1
         mov       ds:[ByteRow],ax          ; po‡et bajt– na © dek

; ------ aktu ln¡ VESA videom¢d

         cmp       byte ptr ds:[TypVCard],5 ; je VESA videokarta ?
         jne       AktPDs22                 ; nen¡ VESA videokarta
         mov       ax,4f03h
         call      far ptr Int10P           ; poskytnut¡ VESA videom¢du
         cmp       ax,4fh
         jne       AktPDs22                 ; nen¡ platn˜ videom¢d
         and       bh,1fh                   ; nulov n¡ p©¡znak–
         inc       bh                       ; korekce ‡¡sla videom¢du
         mov       ds:[VESAVMod],bx         ; aktu ln¡ VESA videom¢d

; ------ adresa videopamˆti

AktPDs22:mov       bx,40h
         mov       es,bx                    ; ES <- 40h segment dat BIOS
         mov       al,ds:[AktVMod]          ; aktu ln¡ videom¢d
         mov       byte ptr ds:[AdrVRAM+3],0B0h ; segment videopamˆti pro MDA
         or        byte ptr ds:[MonoMod],bit1 ; je MONO videom¢d
         cmp       al,7                     ; je videom¢d MDA ?
         je        AktPDis4                 ; je videom¢d MDA
         cmp       al,15                    ; je videom¢d EGA MONO ?
         je        AktPDis4                 ; je videom¢d EGA MONO
         cmp       al,19                    ; je standardn¡ videom¢d ?
         jbe       AktPDis3                 ; je standardn¡ barevn˜ videom¢d
         cmp       byte ptr es:[63h],0b4h   ; je displej MONO ?
         je        AktPDis4                 ; je displej MONO (vy¨¨¡ m¢dy)
AktPDis3:mov       byte ptr ds:[AdrVRAM+3],0B8h ; segment videopamˆti pro CGA
         and       byte ptr ds:[MonoMod],not bit1 ; nen¡ MONO m¢d
AktPDis4:mov       bx,es:[4eh]              ; po‡ te‡n¡ adresa videopamˆti
         mov       word ptr ds:[AdrVRAM],bx ; po‡ te‡n¡ adresa videopamˆti
         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       AktPDs44                 ; je m¢d WINDOWS
         call      KorAVRAM                 ; korekce adresy videopamˆti

; ------ po‡et © dk– displeje

AktPDs44:mov       al,25-1                  ; p©ednastaven¡ na 25 © dk–
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA, VGA ?
         je        AktPDis5                 ; nen¡ karta EGA/VGA
         cmp       byte ptr es:[84h],25-1   ; je £daj po‡tu © dk– platn˜ ?
         jb        AktPDis5                 ; £daj po‡tu © dk– nen¡ platn˜
         cmp       byte ptr es:[84h],254-1  ; maxim ln¡ po‡et © dk–
         ja        AktPDis5                 ; £daj po‡tu © dk– nen¡ platn˜
         mov       al,es:[84h]              ; po‡et © dk– displeje - 1
AktPDis5:mov       ds:[MaxRow],al           ; maxim ln¡ © dek na displeji
         inc       ax                       ; po‡et © dk– celkem
         mov       ds:[Radku],al            ; po‡et © dk– celkem

; ------ po‡et linek na znakov˜ font

         mov       al,14                    ; karta Hercules m  14 linek na font
         cmp       byte ptr ds:[TypVCard],1 ; je Hercules ?
         je        AktPDis8                 ; je karta Hercules
         cmp       byte ptr ds:[TypVCard],3 ; je karta EGA ?
         jb        AktPDis7                 ; karta CGA m  8 linek na znak
         je        AktPDis6                 ; po‡et linek na znak pro EGA kartu

         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       AktPDis6                 ; je m¢d WINDOWS

                                          ;* detekce pro VGA
         mov       dx,es:[63h]              ; b zov  ©¡dic¡ adresa displeje
         cmp       dh,3                     ; je platn  adresa ?
         jne       AktPDis6                 ; nen¡ platn  adresa
         mov       al,9
         out       dx,al                    ; registr 9
         in        al,dx
         cmp       al,9                     ; byl registr nastaven ?
         jne       AktPDis6                 ; chyba nastaven¡ registru
         inc       dx
         in        al,dx                    ; maxim ln¡ linka znaku
         and       al,bit0+bit1+bit2+bit3+bit4 ; platn‚ bity
         inc       ax                       ; korekce 1...
         cmp       al,6
         jb        AktPDis6                 ; chybn˜ £daj
         cmp       al,32
         jbe       AktPDis8                 ; £daj je asi OK

AktPDis6:mov       al,es:[85h]              ; v˜¨ka znaku
         cmp       al,6
         jb        AktPDis7                 ; chybn˜ £daj
         cmp       al,32
         jbe       AktPDis8                 ; v˜¨ka znaku je OK

AktPDis7:mov       al,8                     ; po‡et linek na znak pro CGA
AktPDis8:mov       ds:[LineFont],al         ; v˜¨ka znaku v link ch

; ------ zji¨tˆn¡ b zov‚ ©¡dic¡ adresy displeje CRT

         mov       ax,es:[63h]              ; b zov  adresa portu ©adi‡e CRT
         add       ax,6
         cmp       ax,3b4h+6                ; je platn  adresa ?
         je        AktPDis9                 ; je platn  adresa OK
         cmp       ax,3d4h+6                ; je platn  adresa ?
         je        AktPDis9                 ; je platn  adresa OK
         mov       ax,3b4h+6                ; adresa pro MONO
         test      byte ptr ds:[MonoMod],bit1 ; je MONO m¢d ?
         jnz       AktPDis9                 ; je MONO m¢d
         mov       ax,3d4h+6                ; adresa pro barevn˜ m¢d
AktPDis9:mov       ds:[PortCRT],ax          ; stavov˜ registr ©adi‡e displeje

; ------ korekce pro ANSI m¢d

         test      byte ptr ds:[MonoMod],bit4 ; je v˜stup ANSI ?
         jz        AktPDisB                 ; nen¡ v˜stup ANSI
         mov       byte ptr ds:[Radku],25   ; po‡et © dk–
         mov       byte ptr ds:[MaxRow],24  ; maxim ln¡ © dek
         mov       ax,80                    ; po‡et pozic na © dek
         cmp       byte ptr ds:[Pozic],80
         jae       AktPDisA
         shr       ax,1                     ; bude 40 znak– na © dek
AktPDisA:mov       byte ptr ds:[Pozic],al   ; po‡et pozic na © dek
         dec       ax
         mov       byte ptr ds:[MaxPoz],al  ; maxim ln¡ pozice na © dku
         inc       ax
         shl       ax,1
         mov       ds:[ByteRow],ax          ; po‡et bajt– na © dek

; ------ n vrat registr–

AktPDisB:pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         mov       al,ds:[AktVMod]          ; aktu ln¡ videom¢d
         ret

AktPDisp ENDP

; -----------------------------------------------------------------------------
;        korekce adresy videopamˆti
; -----------------------------------------------------------------------------

KorAVRAM PROC      NEAR

; ------ test implicitn¡ adresy videopamˆti

         call      KorAVRM2                 ; test adresy videopamˆti
         je        KorAVRM8                 ; adresa videopamˆti je OK

; ------ £schova registr–

KorAVRM2:push      ax
         push      bx
         push      dx

; ------ test videopamˆti
; Upozornˆn¡: nejsou spolehliv‚ operace s videopamˆt¡ jako je CMP AX,ES:[BX],
;             mus¡ se pou‘¡vat v‘dy MOV - objev¡ se nap©. po opu¨tˆn¡ SPIRIT 5.0

         push      ds
         lds       bx,ds:[AdrVRAM]          ; adresa videopamˆti
         mov       ax,ds:[bx]               ; p–vodn¡ znak
         push      ax                       ; £schova p–vodn¡ho znaku
         xor       ax,55aah                 ; zmˆna znaku
         mov       ds:[bx],ax               ; ulo‘en¡ zmˆnˆn‚ho znaku
         mov       dx,ds:[bx]               ; nov˜ obsah videopamˆti
         cmp       ax,dx                    ; je obsah pamˆti OK ?
         pop       ax                       ; p–vodn¡ znak
         mov       ds:[bx],ax               ; n vrat p–vodn¡ho znaku
         jne       KorAVRM4                 ; obsah pamˆti nesouhlas¡
         mov       dx,ds:[bx]               ; novˆ ulo‘en˜ znak
         cmp       ax,dx                    ; souhlas¡ nov˜ obsah pamˆti ?
KorAVRM4:pop       ds
         je        KorAVRM6                 ; pamˆŸ je OK
         xor       byte ptr ds:[MonoMod],bit1 ; p©¡znak MONO barev
         xor       byte ptr ds:[AdrVRAM+3],0B8h XOR 0B0h ; zmˆna adresy
                                           ;* zde je nastaven NZ
; ------ n vrat registr–

KorAVRM6:pop       dx
         pop       bx
         pop       ax
KorAVRM8:ret

KorAVRAM ENDP

; *****************************************************************************
;                              DetCard
;                        Detekce videokarty
;        (po‡et videom¢d– mus¡ b˜t 0 nebo nastaven na u‘ivatelsk‚ m¢dy !)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datov˜ segment
; *****************************************************************************
;þ
DetCard  PROC      FAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test videokarty EGA/VGA

         mov       ah,12h                   ; slu‘ba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut¡ informac¡ o EGA
         call      far ptr Int10P           ; poskytnut¡ informac¡ o EGA/VGA
         mov       byte ptr ds:[EgaVga],0   ; zru¨en¡ p©¡znaku karty EGA/VGA
         cmp       bh,2                     ; kontrola navr cen‚ho m¢du displeje
         ja        DetCard5                 ; nen¡ to karta EGA/VGA
         cmp       bl,5                     ; maxim lnˆ povolen 1 MB pamˆti
         ja        DetCard5                 ; nen¡
         inc       byte ptr ds:[EgaVga]     ; p©¡znak karty EGA/VGA

; ------ rozli¨en¡ videokarty EGA a VGA

         mov       ax,1a00h
         call      far ptr Int10P           ; dotaz na instalaci karty
         cmp       al,1ah
         jne       DetCard3                 ; funkce nen¡ obsluhovan  - je EGA
         cmp       bl,7
         je        DetCard2                 ; je karta VGA
         cmp       bl,8
         je        DetCard2                 ; je karta VGA
         cmp       bl,11
         je        DetCard2                 ; je karta VGA
         cmp       bl,12
         jne       DetCard3                 ; nen¡ karta VGA

; ------ je karta VGA

DetCard2:mov       byte ptr ds:[TypVCard],4 ; je karta VGA
         mov       word ptr ds:[DspNMPl1],offset CardTxtV ; VGA
         mov       si,offset StandVMV       ; standardn¡ m¢dy VGA
         jmp       short DetCard7

; ------ je karta EGA

DetCard3:mov       byte ptr ds:[TypVCard],3 ; je EGA
         mov       word ptr ds:[DspNMPl1],offset CardTxtE ; EGA
         mov       si,offset StandVME       ; standardn¡ m¢dy EGA
         jmp       short DetCard7

; ------ rozli¨en¡ karet CGA/Hercules

DetCard5:mov       ah,0fh
         call      far ptr Int10P           ; poskytnut¡ aktivn¡ho videom¢du
         cmp       al,7                     ; je videom¢d 7 (Hercules) ?
         jne       DetCard6                 ; nen¡ Hercules - je CGA

; ------ je karta Hercules

         mov       byte ptr ds:[TypVCard],1 ; Hercules
         mov       word ptr ds:[DspNMPl1],offset CardTxtH ; Hercules
         mov       si,offset StandVMH       ; standardn¡ m¢dy Hercules
         jmp       short DetCard7

; ------ je karta CGA (AL=aktu ln¡ videom¢d)

DetCard6:mov       byte ptr ds:[StandVMC+1],1 ; barevn˜ m¢d CGA 40 x 25
         mov       byte ptr ds:[StandVMC+4],3 ; barevn˜ m¢d CGA 80 x 25
         cmp       al,0
         je        DetCrd62
         cmp       al,2
         je        DetCrd62
         cmp       al,5
         jne       DetCrd64
DetCrd62:dec       byte ptr ds:[StandVMC+1] ; ¨ed˜ videom¢d CGA 40 x 25
         dec       byte ptr ds:[StandVMC+4] ; ¨ed˜ videom¢d CGA 80 x 25

DetCrd64:mov       byte ptr ds:[TypVCard],2 ; CGA
         mov       word ptr ds:[DspNMPl1],offset CardTxtC ; CGA
         mov       si,offset StandVMC       ; standardn¡ m¢dy CGA

; ------ ulo‘en¡ definice standardn¡ch videom¢d–

DetCard7:
;         mov       byte ptr ds:[NumVMod],0  ; nejsou videom¢dy
         call      StorTVMd                 ; ulo‘en¡ videom¢d– podle tabulky

; ------ o¨ah v n¡ ROM BIOS nep©¡pustn‚ pro 8086 (chyba parity nebo zpomaluje)

         cmp       byte ptr ds:[TypVCard],3 ; je EGA ?
         jae       DetCrd72                 ; je EGA a vy¨¨¡
         xor       ax,ax                    ; AX <- 0
         push      ax                       ; do z sobn¡ku 0
         popf                               ; 0 do registru p©¡znak–
         pushf                              ; do z sobn¡ku registr p©¡znak–
         pop       ax                       ; AX <- registr p©¡znak–
         cmp       ah,0f0h                  ; jsou bity natvrdo 1 ?
         je        DetCard8                 ; je procesor 8086

; ------ detekce typu videokarty (nap©. je-li emulace ni‘¨¡ karty)

DetCrd72:call      DetVGA                   ; detekce typu videokarty

; ------ detekce VESA Super VGA

         cmp       byte ptr ds:[TypVCard],4 ; je VGA karta ?
         jb        DetCard8                 ; nen¡ VGA karta
         test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       DetCard8                 ; je okno WINDOWS
         call      DetVESA                  ; detekce VESA karty

; ------ aktualizace parametr– displeje

DetCard8:call      far ptr AktPDisp         ; aktualizace parametr– displeje

; ------ p©edvolby pro ANSI

         mov       di,offset IniHGCVM       ; videom¢dy vhodn‚ t‚‘ pro ANSI
         test      byte ptr ds:[MonoMod],bit4 ; je v˜stup ANSI ?
         jnz       DetCrd82                 ; je ANSI

; ------ p©¡prava p©edvoleb pro Shift-F10

         mov       di,offset ShftVMod       ; povolen‚ videom¢dy pro Shift-F10
         call      IniS10Md                 ; inicializace videom¢d–
         jnc       DetCrd88                 ; byl nˆjak˜ videom¢d OK

         mov       al,ds:[TypVCard]         ; typ videokarty
         mov       ah,0
         mov       di,offset IniHGCVM       ; videom¢dy pro Hercules
         dec       ax
         jz        DetCrd82                 ; je Hercules
         mov       di,offset IniCGAVM       ; videom¢dy pro CGA
         dec       ax
         jz        DetCrd82                 ; je CGA
         mov       di,offset IniEGAVM       ; videom¢dy pro EGA
         dec       ax
         jz        DetCrd82                 ; je EGA
         mov       di,offset IniVGAVM       ; videom¢dy pro VGA
         dec       ax
         jz        DetCrd82                 ; je VGA
         mov       di,offset IniSVGVM       ; videom¢dy pro SVGA
DetCrd82:call      IniS10Md                 ; inicializace videom¢d–

; ------ oprava parametr– menu

DetCrd88:mov       al,byte ptr ds:[NumVMod] ; po‡et videom¢d–
         mov       byte ptr ds:[DspNMnu+MnuNum],al ; po‡et platn˜ch polo‘. menu
         inc       ax
         mov       byte ptr ds:[DspNMnu+MnuSum],al ; celkov˜ po‡et polo‘ek menu
         inc       ax
         inc       ax
         mov       byte ptr ds:[DspNMnu+MnuVys],al ; v˜¨ka okna menu

; ------ dek¢dov n¡ parametr– videom¢d– do menu

         mov       cx,ds:[NumVMod]          ; po‡et videom¢d–
         mov       si,offset TabVMod        ; tabulka videom¢d–
         mov       di,offset DspNMPl2+10    ; buffer k dek¢dov n¡
         push      ds
         pop       es                       ; ES <- datov˜ segment
         xor       bx,bx                    ; nen¡ oddˆlova‡ ani barva
         xor       dx,dx                    ; DX <- 0

DetCard9:cld
         lodsw                              ; ‡¡slo videom¢du
         mov       byte ptr ds:[di+6]," "   ; bˆ‘n˜ videom¢d
         test      ah,not bit7+bit6         ; je videom¢d SVGA ?
         jz        DetCrd91                 ; nen¡ SVGA
         mov       byte ptr ds:[di+6],"*"   ; p©¡znak videom¢du SVGA

DetCrd91:mov       word ptr ds:[di+7],"  "  ; barevn˜ m¢d
         mov       word ptr ds:[di+9],"  "
         test      ah,bit7                  ; je MONO m¢d ?
         jz        DetCrd92                 ; je barevn˜ m¢d
         mov       word ptr ds:[di+7],"OM"  ; je MONO m¢d
         mov       word ptr ds:[di+9],"ON"

DetCrd92:mov       byte ptr ds:[di-8]," "   ; nen¡ Shift-F10
         test      ah,bit6                  ; je Shift-F10 ?
         jz        DetCrd94                 ; nen¡ Shift-F10
         mov       al,ds:[ZnakSwch]         ; znak p©ep¡na‡e
         mov       ds:[di-8],al             ; je Shift-F10

DetCrd94:mov       ah,0
         lodsb                              ; ¨¡©ka (pozic)
         mov       word ptr ds:[di-3],"  "  ; vymaz n¡ star‚ho ‡¡sla
         call      far ptr DekNumD          ; dek¢dov n¡ po‡tu znak– na © dek

         cld
         lodsb                              ; v˜¨ka (© dk–)
         inc       di
         inc       di
         inc       di
         mov       word ptr ds:[di+1],"  "  ; vymaz n¡ star‚ho ‡¡sla
         push      di
         mov       ah,0                     ; nen¡ barva
         call      far ptr DekNumB          ; dek¢dov n¡ po‡tu © dk–
         pop       di
         add       di,2+16

         loop      DetCard9                 ; dal¨¡ videom¢d

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DetCard  ENDP

; -----------------------------------------------------------------------------
;  inicializace povolen¡ videom¢d– podle tabulky DS:DI (CY=chyba, ni‡¡ registry)
; -----------------------------------------------------------------------------

IniS10Md PROC      NEAR

; ------ p©¡prava k inicializaci videom¢d–

         mov       cl,ds:[di]               ; po‡et videom¢d– v tabulce
         mov       ch,0
         xor       bx,bx                    ; BX <- 0
         inc       di                       ; za‡ tek tabulky
         jcxz      IniS10M8                 ; nen¡ ‘ dn˜ videom¢d

; ------ inicializace videom¢d–

IniS10M3:mov       dx,ds:[di]               ; po‘adovan‚ rozli¨en¡
         call      SrcVMod                  ; nalezen¡ videom¢du v tabulce
         jc        IniS10M5                 ; videom¢d nenalezen
         inc       bx                       ; p©¡znak nalezen¡ videom¢du
         or        byte ptr ds:[si+1],bit14/bit8 ; p©¡znak Shift-F10
IniS10M5:inc       di
         inc       di                       ; adresa dal¨¡ho videom¢du
         loop      IniS10M3                 ; dal¨¡ videom¢d

; ------ test, zda byl nalezen alespo¤ 1 videom¢d

IniS10M8:cmp       bl,1                     ; nen¡ ‘ dn˜ videom¢d -> CY
         ret

IniS10Md ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ videom¢du s rozmˆry DX
; -> SI=adresa definice v tabulce, CY=m¢d nenalezen (SI=za‡ tek tabulky)
; -----------------------------------------------------------------------------

SrcVMod  PROC      NEAR

; ------ p©¡prava p©¡znaku MONO m¢du -> AH

         push      ax
         mov       ah,0                     ; nen¡ MONO m¢d
         test      byte ptr ds:[MonoMod],bit6 ; up©ednostnit COLOR m¢d ?
         jnz       SrcVMd02                 ; je COLOR m¢d
         test      byte ptr ds:[MonoMod],bit5 ; up©ednostnit MONO m¢d ?
         jnz       SrcVMd01                 ; je MONO m¢d
         test      byte ptr ds:[MonoMod],bit1 ; je MONO m¢d ?
         jz        SrcVMd02                 ; nen¡ MONO m¢d
SrcVMd01:mov       ah,bit7                  ; p©¡znak MONO m¢du

; ------ nalezen¡ se zmˆnou p©¡znaku MONO

SrcVMd02:call      SrcVMod1                 ; prvn¡ pokus o hled n¡
         jnc       SrcVMod0                 ; videom¢d nalezen OK
         xor       ah,bit7                  ; zmˆna p©¡znaku
         call      SrcVMod1                 ; druh˜ pokus o hled n¡
SrcVMod0:pop       ax
         ret

; ------ £schova registr–

SrcVMod1:push      cx

; ------ nalezen¡ m¢du v tabulce

         mov       si,offset TabVMod-4      ; tabulka videom¢d–
         mov       cx,ds:[NumVMod]          ; po‡et videom¢d– v tabulce
SrcVMod2:add       si,4                     ; adresa dal¨¡ho videom¢du
         cmp       dx,ds:[si+2]             ; souhlas¡ rozmˆry ?
         jne       SrcVMod3                 ; rozmˆry nesouhlas¡
         mov       al,ds:[si+1]
         and       al,bit7                  ; p©¡znak MONO
         cmp       al,ah                    ; souhlas¡ p©¡znak MONO ?
SrcVMod3:loopne    SrcVMod2                 ; dal¨¡ videom¢d
         je        SrcVMod6                 ; videom¢d nalezen OK

; ------ chyba - videom¢d nenalezen

         mov       si,offset TabVMod        ; za‡ tek tabulky
         stc                                ; p©¡znak nenalezen¡ videom¢du

; ------ n vrat registr–

SrcVMod6:pop       cx
         ret

SrcVMod  ENDP

; -----------------------------------------------------------------------------
;        detekce typu videokarty podle ROM BIOS
; -----------------------------------------------------------------------------

DetVGA   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava k detekci

         mov       byte ptr ds:[TypVGA],1   ; ukazatel ‡¡sla typu karty
         mov       ax,0c000h                ; segment ROM BIOS videokarty
         mov       es,ax                    ; segment karty
         mov       si,offset SVGADef        ; definice videkaret
         xor       ax,ax                    ; AH <- 0
         xor       cx,cx                    ; CH <- 0
         cld
         cmp       byte ptr ds:[CPU],3      ; dostate‡n˜ typ procesoru ?
         jb        DetVGA4                  ; je mal˜ typ procesoru

; ------ p©¡prava k vyhled n¡ jednoho vzorku (definice DS:SI)

DetVGA1: lodsb                              ; d‚lka jednoho vzorku
         and       al,not bit7              ; nulov n¡ p©¡znaku EGA
         xchg      ax,cx                    ; CX <- d‚lka vzorku
         xor       di,di                    ; po‡ te‡n¡ adresa

; ------ p©¡prava k testu na jedn‚ adrese

DetVGA2: push      si
         push      di
         push      cx

; ------ porovn n¡ vzorku na jedn‚ adrese

DetVGA3: inc       di                       ; zv˜¨en¡ adresy v BIOS
         mov       al,es:[di]
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         inc       si
         cmp       al,ds:[si-1]             ; porovn n¡ text–
         loope     DetVGA3

; ------ p©¡prava dal¨¡ adresy

         pop       cx
         pop       di
         pop       si
         je        DetVGA5                  ; vzorek nalezen OK

         inc       di                       ; zv˜¨en¡ ukazatele adresy
         cmp       di,400h                  ; maxim ln¡ adresa
         jb        DetVGA2                  ; test na dal¨¡ adrese

; ------ p©¡prava pro dal¨¡ vzorek

         inc       byte ptr ds:[TypVGA]     ; zv˜¨en¡ ukazatele ‡¡sla karty
         add       si,cx                    ; adresa konce textu
         lodsb                              ; d‚lka popisn‚ho textu
         add       si,ax                    ; adresa za‡ tku tabulky videom¢d–
         lodsb                              ; po‡et videom¢d–
         add       si,ax
         shl       ax,1
         add       si,ax                    ; adresa definice dal¨¡ karty
         cmp       byte ptr ds:[si],0       ; je ji‘ konec tabulky ?
         jne       DetVGA1                  ; hled n¡ dal¨¡ho vzorku
DetVGA4: mov       byte ptr ds:[TypVGA],0   ; typ VGA karty nezn m˜
         jmp       short DetVGA8            ; karta nenalezena

; ------ vzorek nalezen OK

DetVGA5: mov       al,ds:[si-1]             ; bit 7: p©¡znak EGA karty
         add       si,cx                    ; adresa pln‚ho n zvu karty
         mov       ds:[DspNMPl1],si         ; n zev videokarty

; ------ ulo‘en¡ videom¢d– karty

         cmp       byte ptr ds:[TypVCard],3 ; je EGA karta ?
         jb        DetVGA8                  ; je n¡zk˜ typ videokarty
         ja        DetVGA6                  ; je VGA karta
         test      al,bit7                  ; je povoleno pro EGA kartu ?
         jz        DetVGA8                  ; nen¡ povoleno pro EGA kartu
DetVGA6: test      byte ptr ds:[ParDisp2],bit6 ; je m¢d v oknˆ WINDOWS ?
         jnz       DetVGA8                  ; je okno WINDOWS
         lodsb                              ; d‚lka n zvu karty
         add       si,ax                    ; adresa definice videom¢d–
         call      StorTVMd                 ; ulo‘en¡ definice videom¢d–

; ------ n vrat registr–

DetVGA8: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DetVGA   ENDP

; -----------------------------------------------------------------------------
;        detekce a ulo‘en¡ parametr– VESA karty
; -----------------------------------------------------------------------------

DetVESA  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ na‡ten¡ informac¡ VESA

         mov       bp,sp
         sub       sp,520                   ; buffer
         push      ss
         pop       es                       ; ES <- segment v z sobn¡ku
         mov       di,sp                    ; buffer v z sobn¡ku
         mov       ax,4f00h
         mov       word ptr es:[di],0       ; p©ednastaven¡ bufferu
         call      far ptr Int10P           ; test instalace VESA

; ------ test, zda je to VESA

         cmp       ax,4fh                   ; je operace OK ?
         jne       DetVESA0                 ; chyba - nen¡ VESA
         cmp       word ptr es:[di],"EV"
         jne       DetVESA0                 ; nen¡ VESA
         cmp       word ptr es:[di+2],"AS"
         je        DetVESA1                 ; je VESA OK
DetVESA0:jmp       DetVESA9

; ------ £schova ukazatel– VESA

DetVESA1:mov       byte ptr ds:[TypVCard],5 ; je VESA VGA
         cmp       byte ptr ds:[TypVGA],0   ; je karta VGA zn m  ?
         jne       DetVESA2                 ; karta VGA je zn m 
         mov       word ptr ds:[DspNMPl1],offset CardTxtS ; je karta VESA VGA
DetVESA2:mov       ax,es:[di+4]             ; verze VESA
         mov       ds:[VESAVer],ax          ; verze VESA
         mov       ax,es:[di+6]             ; ukazatel na OEM LOW
         mov       word ptr ds:[VESAOEM],ax
         mov       ax,es:[di+8]
         mov       word ptr ds:[VESAOEM+2],ax

; ------ £schova seznamu videom¢d– do bufferu v z sobn¡ku

         push      ds
         cld
         lds       si,es:[di+0eh]           ; ukazatel na seznam videom¢d–
         lea       di,ss:[bp-200]           ; buffer v z sobn¡ku
         mov       cx,200/2-1
         push      di                       ; za‡ tek bufferu
         rep       movsw                    ; p©enos ‡¡sel videom¢d–
         pop       si                       ; SI <- za‡ tek bufferu
         mov       ax,-1
         stosw                              ; pojistn‚ zakon‡en¡ tabulky
         pop       ds

; ------ ‡¡slo dal¨¡ho videom¢du VESA (ukazatel bufferu SI)

DetVESA4:mov       cx,es:[si]               ; CX <- videom¢d
         inc       cx                       ; je konec tabulky ?
         jz        DetVESA9                 ; je konec tabulky
         dec       cx                       ; n vrat ‡¡sla videom¢du
         inc       si
         inc       si                       ; zv˜¨en¡ ukazatele videom¢d–
         and       ch,1fh                   ; aby nep©etekly p©¡znaky

; ------ na‡ten¡ informac¡ o videom¢du

         mov       di,sp                    ; buffer v z sobn¡ku
         mov       ax,4f01h
         mov       byte ptr es:[di],bit4    ; p©ednastaven¡ na nespr vnˆ
         push      cx
         call      far ptr Int10P           ; dotaz na videom¢d
         pop       cx

; ------ kontrola platnosti videom¢du

         cmp       ax,4fh
         jne       DetVESA4                 ; chyba
         mov       al,es:[di]               ; atributy
         mov       ah,al                    ; £schova atribut–
         and       al,bit0+bit1+bit4        ; tyto informace jsou d–le‘it‚
         cmp       al,bit0+bit1             ; takov˜ mus¡ b˜t stav
         jne       DetVESA4                 ; nen¡ spr vn˜ videom¢d
         inc       ch                       ; p©¡znak videom¢du VESA

; ------ p©¡znak MONO

         test      ah,bit3                  ; je to MONO m¢d ?
         jnz       DetVESA7                 ; je to barevn˜ m¢d
         or        ch,bit7                  ; je to MONO m¢d

; ------ ¨¡©ka a v˜¨ka displeje

DetVESA7:mov       dx,es:[di+12h]           ; ¨¡©ka displeje
         cmp       dx,254                   ; maxim ln¡ ¨¡©ka displeje
         jae       DetVESA4                 ; neplatn˜ videom¢d
         cmp       dl,40                    ; minim ln¡ ¨¡©ka displeje
         jb        DetVESA4                 ; neplatn˜ videom¢d
         cmp       word ptr es:[di+14h],254 ; v˜¨ka displeje
         jae       DetVESA4                 ; neplatn˜ videom¢d
         mov       dh,es:[di+14h]           ; v˜¨ka okna
         cmp       dh,24                    ; minim ln¡ v˜¨ka displeje
         jb        DetVESA4                 ; neplatn˜ videom¢d

; ------ ulo‘en¡ parametr– videom¢du

         xchg      ax,cx                    ; AX <- ‡¡slo videom¢du
         call      StorVMod                 ; ulo‘en¡ videom¢du
         jmp       short DetVESA4           ; dal¨¡ videom¢d

; ------ n vrat registr–

DetVESA9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DetVESA  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ tabulky DS:SI videom¢d–
; -----------------------------------------------------------------------------

StorTVMd PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si

; ------ ulo‘en¡ definice videom¢d–

         mov       ch,0
         mov       cl,ds:[si]               ; po‡et videom¢d– v definici
         inc       si                       ; za‡ tek definice videom¢d–
StorTVM1:cld
         lodsb                              ; ‡¡slo videom¢du
         mov       ah,al                    ; AH <- p©¡znak MONO m¢du
         and       ah,bit7                  ; p©¡znak MONO m¢du
         and       al,not bit7              ; nulov n¡ p©¡znaku MONO m¢du
         xchg      ax,dx
         lodsw                              ; rozli¨en¡
         xchg      ax,dx                    ; DX <- rozli¨en¡, AX <- ‡¡slo+MONO
         call      StorVMod                 ; ulo‘en¡ definice videom¢du
         loop      StorTVM1                 ; dal¨¡ videom¢d

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

StorTVMd ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ videom¢du AX karty (rozli¨en¡ DX)
; -----------------------------------------------------------------------------

StorVMod PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si

; ------ p©¡prava k prohled n¡ tabulky

         xchg      ax,bx                    ; BX <- ‡¡slo videom¢du
         mov       cx,ds:[NumVMod]          ; po‡et videom¢d–
         mov       si,offset TabVMod        ; tabulka videom¢d–
         jcxz      StorVMd8                 ; nen¡ nic v tabulce

; ------ porovn n¡ ¨¡©ky okna

StorVMd1:cmp       dl,ds:[si+2]             ; bude se vkl dat ?
         jb        StorVMd7                 ; men¨¡ ¨¡©ka p©ed vˆt¨¡ - vlo‘en¡
         ja        StorVMd6                 ; vˆt¨¡ polo‘ka - dal¨¡ polo‘ka

; ------ porovn n¡ v˜¨ky okna

         cmp       dh,ds:[si+3]             ; bude se vkl dat ?
         jb        StorVMd7                 ; men¨¡ v˜¨ka - vlo‘en¡
         ja        StorVMd6                 ; vˆt¨¡ v˜¨ka - dal¨¡ polo‘ka

; ------ porovn n¡ atribut– MONO/COLOR

         mov       ah,ds:[si+1]             ; star˜ atribut MONO
         mov       al,bh                    ; nov˜ atribut MONO
         and       ax,bit7 + bit7*HI        ; maskov n¡ atribut–
         cmp       al,ah                    ; je COLOR p©ed MONO ?
         jb        StorVMd7                 ; je COLOR p©ed MONO - vlo‘en¡
         ja        StorVMd6                 ; je MONO p©ed COLOR - dal¨¡ polo‘ka

; ------ porovn n¡ ‡¡sla videom¢du (p©¡znak Shift-F10 je nyn¡ vynulovan˜ !)

         cmp       bx,ds:[si]               ; je to vy¨¨¡ videom¢d ?
         jbe       StorVMd9                 ; stejn˜ nebo ni‘¨¡ m¢d - nevlo‘¡ se

; ------ standardn¡ m¢d se nevyhazuje

         mov       ax,ds:[si]               ; p–vodn¡ videom¢d
         and       ah,not bit7+bit6         ; nulov n¡ p©¡znak–
         cmp       ax,16                    ; je to standardn¡ videom¢d ?
         jb        StorVMd9                 ; standardn¡ m¢d se ponech 

; ------ vy¨¨¡ ‡¡slo videom¢du (nap©. SVGA) - n hrada parametr–

         mov       ds:[si],bx               ; nov‚ ‡¡slo videom¢du
         jmp       short StorVMd9

; ------ p©¡prava k testu dal¨¡ polo‘ky

StorVMd6:add       si,4                     ; zv˜¨en¡ ukazatele v tabulce
         loop      StorVMd1                 ; test dal¨¡ polo‘ky
         jmp       short StorVMd8           ; ulo‘en¡ na konec tabulky

; ------ odsun zbyl˜ch polo‘ek (je vlo‘en¡)

StorVMd7:xchg      bx,ds:[si]               ; z mˆna definic videom¢d–
         xchg      dx,ds:[si+2]
         add       si,4                     ; zv˜¨en¡ ukazatele v tabulce
         loop      StorVMd7                 ; dal¨¡ videom¢d

; ------ ulo‘en¡ polo‘ky na konec tabulky (adresa DS:SI)

StorVMd8:cmp       byte ptr ds:[NumVMod],MaxVMod ; maxim ln¡ po‡et videom¢d–
         jae       StorVMd9                 ; je ji‘ maxim ln¡ po‡et videom¢d–
         mov       ds:[si],bx               ; ulo‘en¡ ‡¡sla videom¢du
         mov       ds:[si+2],dx             ; ulo‘en¡ rozli¨en¡
         inc       byte ptr ds:[NumVMod]    ; zv˜¨en¡ po‡tu videom¢d–

; ------ n vrat registr–

StorVMd9:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

StorVMod ENDP

; *****************************************************************************
;                              Int10P
;                Vol n¡ INT 10h s £schovou registr–
; *****************************************************************************

Int10P   PROC      FAR

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

Int10P   ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku AX v DOS m¢du (na pozici DX) -> DL se zv˜¨¡ o 1
; -----------------------------------------------------------------------------

DosChar  PROC      NEAR

; ------ £schova registr–

         push      si
         push      es

; ------ adresa bufferu obrazovky

         push      ax
         mov       ax,ds:[AnsiSegm]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         pop       ax
         jc        DosChar7                 ; neplat¡ - asi se zobraz¡

; ------ v˜po‡et adresy v bufferu

         push      ax
         mov       al,ds:[Pozic]            ; po‡et pozic na © dek
         mul       dh                       ; p©epo‡et © dku na pozice
         add       al,dl                    ; p©i‡ten¡ pozice
         adc       ah,0
         shl       ax,1                     ; offset v bufferu
         cmp       ax,ds:[AnsiSize]         ; je offset OK ?
         xchg      ax,si                    ; SI <- adresa v bufferu
         pop       ax
         jae       DosChar7                 ; neplatn  adresa - zobraz¡ se

; ------ kontrola znaku

         cmp       ax,es:[si]               ; souhlas¡ znak ?
         je        DosChar8                 ; znak souhlas¡
         mov       es:[si],ax               ; ulo‘en¡ znaku
DosChar7:stc                                ; po‘adavek zobrazen¡

; ------ n vrat registr–

DosChar8:pop       es
         pop       si
         jnc       DosChar9                 ; nezobraz¡ se

; ------ znak se zobraz¡ - nastaven¡ kurzoru a barvy

         call      AnsiKur                  ; nastaven¡ kurzoru
         call      AnsiCol                  ; nastaven¡ barvy

; ------ konverze nˆkter˜ch znak– < 32 na zobraziteln‚ znaky

         push      ax
         cmp       al," "
         jae       DosChar1

         mov       ah,al                    ; AH <- £schova znaku
         mov       al,"*"
         cmp       ah,7
         je        DosChar1
         cmp       ah,4
         je        DosChar1
         mov       al,">"
         cmp       ah,16
         je        DosChar1
         mov       al,"<"
         cmp       ah,17
         je        DosChar1
         mov       al," "

; ------ vysl n¡ znaku

DosChar1:inc       byte ptr ds:[AnsiPoz]    ; zv˜¨en¡ pozice
         call      DosChar0                 ; vysl n¡ znaku
         pop       ax

DosChar9:inc       dx                       ; zv˜¨en¡ pozice na © dku
         ret

DosChar  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ barvy ANSI na AH
; -----------------------------------------------------------------------------

AnsiCol  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx

; ------ test, zda se barva zmˆnila

         cmp       ah,ds:[AnsiAtr]          ; uschovan‚ atributy
         je        AnsiCol9                 ; atributy se nezmˆnily

; ------ £vodn¡ ESC posloupnost

         call      DosEsc                   ; £vodn¡ ESC posloupnost

; ------ nastaven¡ intenzity pop©ed¡

         mov       al,ah                    ; AL <- po‘adovan‚ atributy
         xor       al,ds:[AnsiAtr]          ; test zmˆny atribut–
         test      al,bit3                  ; zmˆnila se intenzita pop©ed¡ ?
         jz        AnsiCol3                 ; intenzita pop©ed¡ se nezmˆnila

         mov       al,"1"                   ; zv˜raznˆn¡
         test      ah,8                     ; je intenzivn¡ pop©ed¡ ?
         jnz       AnsiCol1                 ; je intenzivn¡ pop©ed¡
         mov       al,"0"                   ; norm ln¡ text
AnsiCol1:call      DosChar0
         call      DosCharS                 ; oddˆlova‡ za parametrem ";"

; ------ nastaven¡ po‘adovan‚ barvy pop©ed¡

AnsiCol3:mov       bl,ah                    ; po‘adovan‚ atributy
         and       bx,7                     ; atributy pop©ed¡
         mov       al,cs:[bx+TransCol]      ; odpov¡daj¡c¡ atributy v ANSII
         call      DosBNum                  ; vysl n¡ ‡¡sla pro atributy
         call      DosCharS                 ; oddˆlova‡ za parametrem ";"

; ------ nastaven¡ po‘adovan‚ barvy pozad¡ (blik n¡ se ignoruje)

         mov       bl,ah                    ; po‘adovan‚ atributy
         shr       bl,1
         shr       bl,1
         shr       bl,1
         shr       bl,1
         and       bx,7                     ; atributy pozad¡
         mov       al,cs:[bx+TransCol]      ; odpov¡daj¡c¡ atributy v ANSII
         add       al,10                    ; korekce pro ‡¡slo pozad¡
         call      DosBNum                  ; vysl n¡ ‡¡sla pro atribut
         mov       ds:[AnsiAtr],ah          ; £schova nov˜ch atribut–

; ------ vysl n¡ povelu pro nastaven¡ barev

         mov       al,"m"                   ; povel pro nastaven¡ barev
         call      DosChar0

; ------ n vrat registr–

AnsiCol9:pop       bx
         pop       ax
         ret

AnsiCol  ENDP

; ------ k¢dy pro jednotliv‚ barvy (barvy pop©ed¡, pro pozad¡ se p©i‡te 10)

TransCol db        30                       ; 0: ‡ern 
         db        34                       ; 1: modr 
         db        32                       ; 2: zelen 
         db        36                       ; 3: modrozelen 
         db        31                       ; 4: ‡erven 
         db        35                       ; 5: purpurov 
         db        33                       ; 6: ‘lut 
         db        37                       ; 7: b¡l 

; -----------------------------------------------------------------------------
;        nastaven¡ pozice kurzoru ANSI na DX
; -----------------------------------------------------------------------------

AnsiKur  PROC      NEAR

; ------ test, zda je pot©eba mˆnit pozici kurzoru ANSI

         cmp       dx,ds:[AnsiPoz]          ; zmˆnila se pozice ?
         je        AnsiKur9                 ; pozice se nezmˆnila

; ------ £vodn¡ ESC posloupnost

         push      ax
         call      DosEsc                   ; £vodn¡ ESC

; ------ rozli¨en¡, zda se zmˆnil © dek

         cmp       dh,byte ptr ds:[AnsiPoz+1] ; zmˆnˆn © dek ?
         jne       AnsiKur7                 ; zmˆnˆn © dek

; ------ © dek nezmˆnˆn: p©¡prava posunu v pozic¡ch

         mov       al,dl                    ; pozice
         sub       al,byte ptr ds:[AnsiPoz] ; rozd¡l pozic
         jb        AnsiKur7                 ; posun vlevo (nemus¡ souhlasit-zara‘en)

; ------ vysl n¡ ‡¡sla posunu (pro 1 pozici nen¡ pot©eba ‘ dn‚ ‡¡slo)

         call      DosBNum1                 ; po‡et pozic vpravo
         mov       al,"C"                   ; p©¡kaz pro posun vpravo
         jmp       short AnsiKur8

; ------ © dek zmˆnˆn - nastaven¡ pozice kurzoru absolutnˆ

AnsiKur7:mov       al,dh                    ; © dek
         inc       ax                       ; korekce ‡¡sla
         call      DosBNum1                 ; v˜stup ‡¡sla © dku
         call      DosCharS                 ; oddˆlova‡ ";"
         mov       al,dl                    ; pozice
         inc       ax                       ; korekce ‡¡sla pozice
         call      DosBNum1                 ; v˜stup ‡¡sla pozice

; ------ vysl n¡ znaku povelu

         mov       al,"H"
AnsiKur8:call      DosChar0                 ; vysl n¡ znaku povelu

; ------ £schova nov‚ pozice kurzoru

         pop       ax
         mov       ds:[AnsiPoz],dx          ; £schova nov‚ pozice
AnsiKur9:ret

AnsiKur  ENDP

; -----------------------------------------------------------------------------
;        v˜stup ‡¡sla AL v DOS m¢du (‡¡slo mus¡ b˜t maxim lnˆ 99 !)
; -----------------------------------------------------------------------------

DosBNum1:cmp       al,1                     ; je pot©eba v˜stup ?
         jbe       DosBNum6                 ; ‡¡slo nen¡ pot©eba vys¡lat

DosBNum  PROC      NEAR

         push      ax
         aam                                ; rozdˆlen¡ na 2 BCD ‡¡slice
         add       ax,"00"                  ; korekce na ASCII ‡¡slice
         xchg      al,ah                    ; AL <- vy¨¨¡, AH <- ni‘¨¡ ‡¡slice
         cmp       al,"0"                   ; je platn  ‡¡slice ?
         je        DosBNum4                 ; ‡¡slice se ignoruje
         call      DosChar0                 ; v˜stup znaku
DosBNum4:xchg      al,ah                    ; AL <- ni‘¨¡ ‡¡slice
         call      DosChar0                 ; v˜stup znaku
         pop       ax
DosBNum6:ret

DosBNum  ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku AL v DOS m¢du
; -----------------------------------------------------------------------------

DosCharS:mov       al,";"                   ; oddˆlova‡ dat
         jmp       short DosChar0           ; v˜stup znaku

DosEsc:  mov       al,ESCP                  ; k¢d ESCAPE
         call      DosChar0
         mov       al,"["                   ; otev¡rac¡ z vorka

DosChar0 PROC      NEAR

         push      ax
         push      dx
         xchg      ax,dx                    ; DL <- znak k v˜stupu
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DosChar0 ENDP

CodeDis  ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                 Data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT
;þ
; -----------------------------------------------------------------------------
;        Parametry uschovan‚ho obsahu obrazovky
; -----------------------------------------------------------------------------

STopAdr  dw        0                        ; adresa po‡ tku k zobrazen¡
SSegment dw        0                        ; segment s uschovanou obrazovkou
SBajtRow dw        0                        ; po‡et bajt– na © dek
SKurzor  dw        0                        ; uschovan˜ syst‚mov˜ kurzor
SPodklad dw        7*HI+" "                 ; p–vodn¡ znak (barva) podkladu
STopLine db        0                        ; po‡ te‡n¡ ‡¡slo zobrazen‚ho © dku
SRadku   db        0                        ; uschovan˜ po‡et © dk– displeje
SPozic   db        0                        ; p–vodn¡ po‡et pozic na © dek
SAktVMod db        0                        ; uschovan˜ aktivn¡ videom¢d

; -----------------------------------------------------------------------------
;        parametry ANSI ovlada‡e
; -----------------------------------------------------------------------------

AnsiAtr  db        0                        ; uschovan‚ atributy barev ANSI
AnsiPoz  dw        0                        ; uschovan  sou©adnice kurzoru ANSI
AnsiSegm dw        0                        ; segment s obrazovkou ANSI (0=nen¡)
AnsiSize dw        0                        ; velikost segmentu ANSI (0=nen¡)

; -----------------------------------------------------------------------------
;        Parametry displeje a videom¢du
; -----------------------------------------------------------------------------

AdrVRAM  dd        0b8000000h               ; adresa videostr nky displeje
PortCRT  dw        3dah                     ; b zov  adresa portu ©adi‡e CRT
ByteRow  dw        160                      ; po‡et bajt– na © dek
Pozic    db        80                       ; po‡et pozic na © dek
MaxPoz   db        79                       ; maxim ln¡ pozice na © dku
Radku    db        25                       ; po‡et © dk– celkem
MaxRow   db        24                       ; maxim ln¡ © dek na displeji
EgaVga   db        0                        ; 1=p©¡znak, ‘e je karta EGA/VGA
;MonoMod  db        0                        ; p©¡znak MONO barev
;                                            ;   bit 0: 1=po‘adavek MONO (LCD)
;                                            ;   bit 1: 1=MONO videom¢d
;
;                                            ;   bit 4: 1=je v˜stup ANSI
;                                            ;   bit 5: 1=up©ednostnit MONO m¢d
;                                            ;   bit 6: 1=up©ednostnit COLOR m¢d

ChckSnow db        0                        ; 1=p©¡znak kontroly snˆ‘en¡
AktPage  db        0                        ; aktivn¡ videostr nka
LineFont db        16                       ; aktu ln¡ po‡et linek na font

AktVMod  db        3                        ; aktu ln¡ videom¢d
VESAVMod dw        0                        ; aktu ln¡ VESA videom¢d + 256

FontSegm dw        0                        ; segment s fonty (4 KB)

ParDisp  db        bit2                     ; parametry displeje
                                            ;      (bit 1: 1=je grafick˜ m¢d)
                                            ;      (bit 2: 1=povolen grafick˜ m¢d)
                                            ;   bit 3: 1=uschov ny fonty displ.

                                            ;   bit 5: 1=fonty maj¡ spr vn˜ k¢d
                                            ;   bit 6: 1=navr tit fonty pro DOS
                                            ;   bit 7: 1=inicial. displeje v‘dy
                                            ;      (parametr se p©ednastavuje
                                            ;       sou‡asnˆ s detekc¡ dlouh˜ch
                                            ;       jmen WINDOWS 95)

;ParDisp2 db        0                        ; parametry displeje 2
;                                            ;   bit 0: 1=blik n¡ pozad¡ znak–
;                                            ;   bit 1: 1=zv˜¨en  intenzita znak–
;                                            ;   bit 2: 1=blik n¡ znak– DOS
;                                            ;   bit 3: 1=zv˜¨en  intenzita DOS
;                                            ;   bit 4: 1=pou‘¡t ¨ed‚ palety VGA
;                                            ;   bit 5: 1=pou‘ij¡ se vlastn¡ fonty
                                             ;   bit 6: 1=je okno WINDOWS

ParDisp3 db        0                        ; parametry displeje 3
                                            ;  bit 0: 1=nadefinov ny ‡esk‚ fonty
                                            ;  bit 1: 1=nadefinov ny grafick‚ fonty
                                            ;  bit 2: 1=nadefinov ny znaky my¨i

TypVCard db        0                        ; detekovan˜ typ videokarty
                                            ; 1: Hercules
                                            ; 2: CGA
                                            ; 3: EGA
                                            ; 4: VGA
                                            ; 5: VESA Super VGA

TypVGA   db        0                        ; typ VGA/EGA karty (podle tabulky)
                                            ; 0 = nezn m˜ typ

CardTxtH db        8,'Hercules'
CardTxtC db        3,'CGA'
CardTxtE db        3,'EGA'
CardTxtV db        3,'VGA'
CardTxtS db        9,'Super VGA'

; ------ standardn¡ videom¢dy

StandVMH db        1                        ; Hercules
         db        7+bit7,80,25

StandVMC db        2                        ; CGA
         db        1, 40,25
         db        3, 80,25

StandVME db        5                        ; EGA
         db        1,40,25
         db        3,80,25
         db        3,80,43
         db        7+bit7,80,25
         db        7+bit7,80,43

StandVMV db        10                       ; VGA a SVGA
         db        1,40,25
         db        3,80,25
         db        3,80,28
         db        3,80,50
         db        3,90,25
         db        3,90,28
         db        3,90,50
         db        7+bit7,80,25
         db        7+bit7,80,28
         db        7+bit7,80,50

; ------ inicializa‡n¡ videom¢dy pro Shift-F10

IniHGCVM db        1
         db        80,25                    ; Hercules videom¢dy pro Shift-F10

IniCGAVM db        2
         db        40,25                    ; CGA videom¢dy pro Shift-F10
         db        80,25

IniEGAVM db        2
         db        80,25                    ; EGA videom¢dy pro Shift-F10
         db        80,43

IniVGAVM db        4
         db        80,25                    ; VGA videom¢dy pro Shift-F10
         db        80,28
         db        80,50
         db        90,50

IniSVGVM db        5
         db        80,25                    ; SVGA videom¢dy pro Shift-F10
         db        80,28
         db        80,50
         db        90,50
         db        132,60

; -----------------------------------------------------------------------------
;        parametry VESA karty
; -----------------------------------------------------------------------------

VESAVer  dw        0                        ; verze VESA
VESAOEM  dd        0                        ; ukazatel na jm‚no OEM (firma)

; -----------------------------------------------------------------------------
;        Definice vertik ln¡ho menu - displej
; -----------------------------------------------------------------------------

DspNMnu  label     byte                   ;* menu zvl ¨tn¡ch funkc¡ - displej

         db        2                        ; typ menu - vertik ln¡ podmenu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        MaxVMod                  ; po‡et platn˜ch polo‘ek menu
         dw        MaxVMod+1                ; celkov˜ po‡et polo‘ek menu

         dw        DspNMPol                 ; adresa definice polo‘ek menu
         dw        DspNMHlp                 ; adresa n povˆd
         dw        Hlp@NastaveniVideomoduDispleje ; ‡¡slo str nky velk‚ n povˆdy
         dw        DspNMBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DspNMT1                  ; adresa titulu okna
         dw        DspNMExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        11                       ; po‡ te‡n¡ pozice
         db        1                        ; po‡ te‡n¡ © dek
         db        23                       ; ¨¡©ka
         db        MaxVMod+3                ; v˜¨ka

DspNMPol db        bit6,4,0,1
DspNMPl1 dw        CardTxtE

DspNMPl2 label     byte
X=0
         REPT      MaxVMod
         db        3,19,'  ',"A"+X,': ... x ..      '
X=X+1
         ENDM

DspNMBlk label     byte
         db        MaxVMod dup(0)

DspNMT1  db        8,'videom¢d'

HelpS    SEGMENT   BYTE PUBLIC
DspNMHlp label     word
         dw        MaxVMod dup(3+1*HI,DspNMHl1)
HelpS    ENDS

DspNMHl1 db        25,'Enter = zmˆna videom¢du'

DspNMExe label     dword                    ; tabulka obsluh menu
         dd        MaxVMod dup(NastDis2)

; -----------------------------------------------------------------------------
;        tabulka videokaret S-VGA
; -----------------------------------------------------------------------------
; Struktura definice karty:
;     0: (1) d‚lka textu k identifikaci karty (0=konec tabulky)
;               bit 7: 1=povoleno t‚‘ pro EGA videokartu
;        (x) text k identifikaci karty
;        (1) d‚lka textu n zvu karty
;        (x) text n zvu karty
;        (1) po‡et definovan˜ch textov˜ch videom¢d–
;
; Struktura tabulky videom¢d–:
;     0: (1) bit 0 - 6: ‡¡slo videom¢du
;            bit 7: 1=MONO m¢d
;     1: (1) horizont ln¡ rozli¨en¡
;     2: (1) vertik ln¡ rozli¨en¡
; -----------------------------------------------------------------------------

SVGADef  label     byte                     ; defini‡n¡ tabulka Super-VGA karet

; ------ Ahead B VGA (m¢dy z Ahead System EGA2001)

         db        7,'AHEAD B'              ; text k identifikaci karty
         db        11,'Ahead B VGA'
         db        4                        ; po‡et videom¢d–

         db        35,132,25                ; 132 x 25/14
         db        34,132,44                ; 132 x 44/8
         db        80+bit7,132,25           ; 132 x 25 MONO/14
         db        82+bit7,132,44           ; 132 x 44 MONO/8

; ------ Ahead System EGA2001

         db        7+bit7,'AHEAD S'         ; text k identifikaci karty
         db        20,'Ahead System EGA2001'
         db        4                        ; po‡et videom¢d–

         db        35,132,25                ; 132 x 25/14
         db        34,132,44                ; 132 x 44/8
         db        80+bit7,132,25           ; 132 x 25 MONO/14
         db        82+bit7,132,44           ; 132 x 44 MONO/8

; ------ Allstar Peacock VGA

         db        7,'ALLSTAR'              ; text k identifikaci karty
         db        19,'Allstar Peacock VGA'
         db        5                        ; po‡et videom¢d–

         db        38, 80,60                ;  80 x 60/8
         db        42,100,40                ; 100 x 40/12
         db        36,132,25                ; 132 x 25/16
         db        35,132,28                ; 132 x 28/14
         db        34,132,43                ; 132 x 43/8

; ------ AST VGA Plus

         db        7,'AST VGA'              ; text k identifikaci karty
         db        12,'AST VGA Plus'
         db        2                        ; po‡et videom¢d–

         db        85,132,25                ; 132 x 25/14
         db        84,132,43                ; 132 x 43/8

; ------ AT&T 6300 (m¢dy z AT&T VDC600)

         db        6+bit7,'AT&T 6'          ; text k identifikaci karty
         db        13,'AT&T 6300 EGA'
         db        4                        ; po‡et videom¢d–

         db        85,132,25                ; 132 x 25/16
         db        84,132,43                ; 132 x 43/9
         db        87+bit7,132,25           ; 132 x 25 MONO
         db        86+bit7,132,43           ; 132 x 43 MONO/9

; ------ AT&T VDC600

         db        6+bit7,'AT&T V'          ; text k identifikaci karty
         db        15,'AT&T VDC600 EGA'
         db        4                        ; po‡et videom¢d–

         db        85,132,25                ; 132 x 25/16
         db        84,132,43                ; 132 x 43/9
         db        87+bit7,132,25           ; 132 x 25 MONO
         db        86+bit7,132,43           ; 132 x 43 MONO/9

; ------ ATI EGA Wonder

         db        7+bit7,'ATI EGA'         ; text k identifikaci karty
         db        14,'ATI EGA Wonder'
         db        5                        ; po‡et videom¢d–

         db        88, 80,33                ;  80 x 33/14
         db        35,132,25                ; 132 x 25/8
         db        51,132,44                ; 132 x 44/8
         db        39+bit7,132,25           ; 132 x 25 MONO/8
         db        55+bit7,132,44           ; 132 x 44 MONO/8

; ------ ATI Prism Elite (m¢dy z ATI VGA Wonder)

         db        7,'ATI PRI'              ; text k identifikaci karty
         db        19,'ATI Prism Elite VGA'
         db        6                        ; po‡et videom¢d–

         db        91, 80,30                ;  80 x 30/16
         db        88, 80,33                ;  80 x 33/14
         db        35,132,25                ; 132 x 25/8
         db        51,132,44                ; 132 x 44/8
         db        39+bit7,132,25           ; 132 x 25 MONO/8
         db        55+bit7,132,44           ; 132 x 44 MONO/8

; ------ ATI VGA Wonder

         db        7,'ATI VGA'              ; text k identifikaci karty
         db        14,'ATI VGA Wonder'
         db        6                        ; po‡et videom¢d–

         db        91, 80,30                ;  80 x 30/16
         db        88, 80,33                ;  80 x 33/14
         db        35,132,25                ; 132 x 25/8
         db        51,132,44                ; 132 x 44/8
         db        39+bit7,132,25           ; 132 x 25 MONO/8
         db        55+bit7,132,44           ; 132 x 44 MONO/8

; ------ ATI VIP (ATI Super VGA ?)

         db        7,'ATI VIP'              ; text k identifikaci karty
         db        17,'ATI VIP Super VGA'
         db        6                        ; po‡et videom¢d–

         db        85, 80,66                ;  80 x 66/8
         db        88, 80,33                ;  80 x 33/14
         db        35,132,25                ; 132 x 25/8
         db        51,132,44                ; 132 x 44/8
         db        39+bit7,132,25           ; 132 x 25 MONO/8
         db        55+bit7,132,44           ; 132 x 44 MONO/8

; ------ ATI MACH64

         db        7,'ATI-264'              ; text k identifikaci karty
         db        10,'ATI MACH64'
         db        4                        ; po‡et videom¢d–

         db        33,100,25                ; 100 x 25
         db        34,100,30                ; 100 x 30
         db        35,132,25                ; 132 x 25
         db        51,132,44                ; 132 x 44

; ------ Avance Logic AL2101

         db        6,'AVANCE'
         db        12,'Avance Logic'
         db        7

         db        36, 80,30                ;  80 x 30
         db        37, 80,43                ;  80 x 43
         db        38, 80,60                ;  80 x 60
         db        32,132,25                ; 132 x 25
         db        33,132,30                ; 132 x 30
         db        34,132,43                ; 132 x 43
         db        35,132,60                ; 132 x 60

; ------ C&T chipset VGA (Chips and Technologies VGA) (ovˆ©eno dokumentac¡)

         db        9,'CHIPS AND'            ; text k identifikaci karty
         db        20,'Chips & Technol. VGA'
         db        2                        ; po‡et videom¢d–

         db        96,132,25                ; 132 x 25/16
         db        97,132,50                ; 132 x 50/8

; ------ Cardinal

         db        8,'CARDINAL'             ; text k identifikaci karty
         db        12,'Cardinal VGA'
         db        0

; ------ Cirrus (510, 520, 5320, 5420, 5422, 5426) - smˆsice m¢d– karet

         db        6,'CIRRUS'               ; text k identifikaci karty
         db        10,'Cirrus VGA'
         db        13
         db        83, 80,60                ;  80 x 60
         db        64,100,30                ; 100 x 30
         db        65,100,50                ; 100 x 50
         db        66,100,60                ; 100 x 60
         db        20,132,25                ; 132 x 25/16
         db        24+bit7,132,25           ; 132 x 25/14 MONO
         db        36,132,28                ; 132 x 28
         db        80,132,30                ; 132 x 30
         db        25,132,34                ; 132 x 34
         db        84,132,43                ; 132 x 43/8
         db        30,132,44                ; 132 x 44
         db        97,132,50                ; 132 x 50
         db        82,132,60                ; 132 x 60

; ------ Compaq VGA Portable

         db        6,'COMPAQ'               ; text k identifikaci karty
         db        19,'Compaq VGA Portable'
         db        0

; ------ Corona/Cordata

         db        6+bit7,'CORONA'          ; text k identifikaci karty
         db        10,'Corona EGA'
         db        0

; ------ Dell VGA

         db        8,'DELL VGA'             ; text k identifikaci karty
         db        8,'Dell VGA'
         db        0

; ------ Diamond Speedstar

         db        13,'DIAMOND SPEED'
         db        17,'Diamond Speedstar'
         db        8

         db        65,80,34
         db        103,80,43
         db        102,80,50
         db        85,132,25
         db        71,132,28
         db        84,132,43
         db        33,132,44
         db        105,132,50

; ------ Diamond

         db        7,'DIAMOND'
         db        12,'Diamond SVGA'
         db        2

         db        85,132,25
         db        84,132,43

; ------ (Genoa 6400) Genoa Super VGA

         db        6,'GENOA '               ; text k identifikaci karty
         db        15,'Genoa Super VGA'
         db        14                       ; po‡et videom¢d–

         db        88, 80,32                ;  80 x 32/14
         db       114, 80,60                ;  80 x 60/8
         db       116, 80,66                ;  80 x 66/8
         db        90,100,42                ; 100 x 42/12
         db       107,100,37                ; 100 x 37/8
         db        96,132,25                ; 132 x 25/16
         db        97,132,29                ; 132 x 29/14
         db        98,132,32                ; 132 x 32/13
         db        99,132,44                ; 132 x 44/12
         db       100,132,60                ; 132 x 60/8
         db        69+bit7, 80,44           ;  80 x 44 MONO/12
         db        70+bit7,132,25           ; 132 x 25 MONO/16
         db        72+bit7,132,32           ; 132 x 32 MONO/13
         db        73+bit7,132,44           ; 132 x 44 MONO/12

; ------ Hewlett-Packard D1180A

         db        7+bit7,'HEWLETT'         ; text k identifikaci karty
         db        21,'Hewlett-Packard D1180'
         db        2                        ; po‡et videom¢d–

         db        85,132,25                ; 132 x 25/14
         db        84,132,43                ; 132 x 43/8

; ------ Imtec

         db        5,'IMTEC'                ; text k identifikaci karty
         db        9,'Imtec VGA'
         db        0

; ------ Lava Chrome II EGA

         db        8+bit7,'LAVA CHR'        ; text k identifikaci karty
         db        18,'Lava Chrome II EGA'
         db        5                        ; po‡et videom¢d–

         db        81, 80,30                ;  80 x 30/16
         db        80, 80,34                ;  80 x 34/14
         db        82, 80,60                ;  80 x 60/8
         db        84,132,25                ; 132 x 25/14
         db        82,132,43                ; 132 x 43/8

; ------ Logix

         db        5,'LOGIX'                ; text k identifikaci karty
         db        9,'Logix VGA'
         db        0

; ------ Maxxon

         db        6,'MAXXON'               ; text k identifikaci karty
         db        10,'Maxxon VGA'
         db        0

; ------ NSI Smart EGA+

         db        9+bit7,'NSI SMART'       ; text k identifikaci karty
         db        14,'NSI Smart EGA+'
         db        2                        ; po‡et videom¢d–

         db        87+bit7,132,25           ; 132 x 25 MONO/14
         db        86+bit7,132,43           ; 132 x 43 MONO/8

; ------ OAK Technology VGA (testov no)

         db        9,'OAK TECHN'            ; text k identifikaci karty
         db        18,'OAK Technology VGA'
         db        4                        ; po‡et videom¢d–

         db        78, 80,60                ;  80 x 60/8
         db        80,132,25                ; 132 x 25/14
         db        81,132,43                ; 132 x 43/8
         db        79,132,60                ; 132 x 60/8

; ------ Orchid Prodesigner VGA

         db        6,'ORCHID'               ; text k identifikaci karty
         db        20,'Orchid Prodesig. VGA'
         db        5                        ; po‡et videom¢d–

         db        38, 80,60                ;  80 x 60/8
         db        42,100,40                ; 100 x 40/16
         db        36,132,25                ; 132 x 25/16
         db        35,132,28                ; 132 x 28/14
         db        34,132,44                ; 132 x 44/8

; ------ Paradise EGA-480 (ovˆ©eno)

         db        10+bit7,' PEGA BIOS'     ; text k identifikaci karty
         db        16,'Paradise EGA-480'
         db        6                        ; po‡et videom¢d–

         db        83, 80,25                ;  80 x 25/16
         db        81, 80,30                ;  80 x 30/16
         db        85,132,25                ; 132 x 25/14
         db        84,132,43                ; 132 x 43/8
         db        87+bit7,132,25           ; 132 x 25 MONO/14
         db        86+bit7,132,43           ; 132 x 43 MONO/8

; ------ Paradise Super VGA

         db        8,'PARADISE'             ; text k identifikaci karty
         db        14,'Paradise S-VGA'
         db        4                        ; po‡et videom¢d–

         db        85,132,25                ; 132 x 25/16
         db        84,132,43                ; 132 x 43/9
         db        87+bit7,132,25           ; 132 x 25 MONO/16
         db        86+bit7,132,43           ; 132 x 43 MONO/9

; ------ Quadram

         db        7,'QUADRAM'
         db        17,'Quadram Ultra VGA'
         db        9

         db        72h,80,60
         db        74h,80,66
         db        76h,94,29
         db        78h,100,75
         db        7ah,114,60
         db        60h,132,25
         db        61h,132,29
         db        62h,132,32
         db        63h,132,44

; ------ Realtek

         db        7,'REALTEK'              ; text k identifikaci karty
         db        11,'Realtek VGA'
         db        7                        ; po‡et videom¢d–

         db        24, 80,30                ;  80 x 30/16
         db        25, 80,43                ;  80 x 43/8
         db        26, 80,60                ;  80 x 60/8
         db        27,132,25                ; 132 x 25/16
         db        28,132,30                ; 132 x 30/14
         db        29,132,43                ; 132 x 43/8
         db        30,132,60                ; 132 x 60/8

; ------ SEFCO TVGA

         db        5,'SEFCO'                ; text k identifikaci karty
         db        10,'SEFCO TVGA'
         db        0

; ------ Sigma VGA

         db        5,'SIGMA'                ; text k identifikaci karty
         db        9,'Sigma VGA'
         db        0

; ------ STB VGA

         db        7,'STB VGA'              ; text k identifikaci karty
         db        7,'STB VGA'
         db        0

; ------ Tatung VGA

         db        6,'TATUNG'               ; text k identifikaci karty
         db        10,'Tatung VGA'
         db        6                        ; po‡et videom¢d–

         db        64, 80,43                ;  80 x 43/8
         db        67, 80,60                ;  80 x 60/8
         db        68,100,60                ; 100 x 60/8
         db        65,132,25                ; 132 x 25/14
         db        69,132,28                ; 132 x 28/13
         db        66,132,43                ; 132 x 43/8

; ------ Taxan 565 EGA

         db        5+bit7,'TAXAN'           ; text k identifikaci karty
         db        13,'Taxan 565 EGA'
         db        4                        ; po‡et videom¢d–

         db        85,132,25                ; 132 x 25/14
         db        84,132,43                ; 132 x 43/8
         db        87+bit7,132,25           ; 132 x 25 MONO/14
         db        86+bit7,132,43           ; 132 x 43 MONO/8

; ------ Tecmar VGA/AD

         db        6,'TECMAR'               ; text k identifikaci karty
         db        13,'Tecmar VGA/AD'
         db        2                        ; po‡et videom¢d–

         db        64, 80,43                ;  80 x 43/8
         db        23,132,25                ; 132 x 25/14

; ------ Toshiba 3100 AT&T

         db        7+bit7,'TOSHIBA'         ; text k identifikaci karty
         db        17,'Toshiba 3100 AT&T'
         db        0

; ------ Trident TVGA (8800, 8900, 9000) (testov no a dokumentov no TVGA 9000)

         db        7,'TRIDENT'              ; text k identifikaci karty
         db        17,'Trident Super VGA'
         db        7                        ; po‡et videom¢d–

         db        80, 80,30                ;  80 x 30/16
         db        81, 80,43                ;  80 x 43/11
         db        82, 80,60                ;  80 x 60/8
         db        83,132,25                ; 132 x 25/14
         db        84,132,30                ; 132 x 30/16
         db        85,132,43                ; 132 x 43/11
         db        86,132,60                ; 132 x 60/8

; ------ Tseng Labs EVA

         db        14,'TSENG LABS EVA'      ; text k identifikaci karty
         db        14,'Tseng Labs EVA'
         db        7                        ; po‡et videom¢d–

         db        38, 80,60                ;  80 x 60/8
         db        35,132,25                ; 132 x 25/14
         db        36,132,28                ; 132 x 28/13
         db        34,132,44                ; 132 x 44/8
         db        25+bit7,132,25           ; 132 x 25 MONO/14
         db        26+bit7,132,28           ; 132 x 28 MONO/13
         db        24+bit7,132,44           ; 132 x 44 MONO/8

; ------ Tseng ET4000 chipset (Tseng Labs Super VGA)

         db        6,'TSENG '               ; text k identifikaci karty
         db        20,'Tseng Labs Super VGA'
         db        9                        ; po‡et videom¢d–

         db        23, 80,43                ;  80 x 43/8
         db        38, 80,60                ;  80 x 60/8
         db        42,100,40                ; 100 x 40/15
         db        35,132,25                ; 132 x 25/14
         db        36,132,28                ; 132 x 28/13
         db        34,132,44                ; 132 x 44/8
         db        25+bit7,132,25           ; 132 x 25 MONO/14
         db        26+bit7,132,28           ; 132 x 28 MONO/13
         db        24+bit7,132,44           ; 132 x 44 MONO/8

; ------ VEGA VGA

         db        8,'VEGA VGA'             ; text k identifikaci karty
         db        8,'VEGA VGA'
         db        10                       ; po‡et videom¢d–

         db        64, 80,43                ;  80 x 43/8
         db        67, 80,60                ;  80 x 60/8
         db        68,100,60                ; 100 x 60/8
         db        77,120,25                ; 120 x 25/16
         db        78,120,43                ; 120 x 43/8
         db        65,132,25                ; 132 x 25/14
         db        66,132,43                ; 132 x 43/8
         db        80+bit7,80,43            ;  80 x 43 MONO/8
         db        81+bit7,132,25           ; 132 x 25 MONO/14
         db        82+bit7,132,43           ; 132 x 43 MONO/8

; ------ Video7 V-RAM VGA (Video7 Super VGA)

         db        6,'VIDEO7'               ; text k identifikaci karty
         db        16,'Video7 Super VGA'
         db        6                        ; po‡et videom¢d–

         db        64, 80,43                ;  80 x 43/8
         db        67, 80,60                ;  80 x 60/8
         db        68,100,60                ; 100 x 60/8
         db        65,132,25                ; 132 x 25/16
         db        69,132,28                ; 132 x 28/14
         db        66,132,43                ; 132 x 43/8

; ------ Western Digital VGA

         db        13,'WESTERN DIGIT'
         db        19,'Western Digital VGA'
         db        6

         db        28,132,25                ; 132 x 25/16
         db        85,132,25                ; 132 x 25/14
         db        84,132,43                ; 132 x 43/8
         db        29,132,44                ; 132 x 44/8
         db        87+bit7,132,25           ; 132 x 25 MONO/14
         db        86+bit7,132,43           ; 132 x 43 MONO/8

; ------ Zymos Poach

         db        5,'ZYMOS'                ; text k identifikaci karty
         db        15,'Zymos Poach VGA'
         db        0

; ------ konec tabulky

         db        0

; ------ nastaven¡ registr– VGA pro m¢d 90 pozic na © dek

Reg90    label     byte
         db        0,106                    ; celkov  horizont ln¡ d‚lka
         db        1,89                     ; konec horizont ln¡ho zobrazen¡
         db        2,90                     ; za‡ tek horizont ln¡ho zatemnˆn¡
         db        3,8dh                    ; konec horizont ln¡ho zatemnˆn¡
         db        4,94 ;99                     ; za‡ tek horiz. zpˆtn‚ho bˆhu
         db        5,83h ;88h                    ; konec horiz. zpˆtn‚ho bˆhu
         db        13h,(2*90)/4             ; p©¡rustek adresy videolinek

; ------ definice znak– pro Latin2

LZnakTab label     byte
         db        'o-'                     ; znak p©ep¡na‡e menu

         db        198,199,208,209,242,247  ; znaky kurzoru my¨i pro Latin 2

         db        255,7                    ; znaky pro ztmaven¡ displeje
         db        250,7
         db        7,7
         db        '*',7
         db        '*',8
         db        7,8
         db        250,8
         db        255,8
         db        ' ',7

; ------ definice znak– pro k¢d Kamenick˜ch

BZnakTab label     byte
         db        'û-'                     ; znak p©ep¡na‡e menu

         db        208,210,211,214,189,183  ; bˆ‘n‚ znaky kurzoru my¨i

         db        250,7                    ; znaky pro ztmaven¡ displeje
         db        249,7
         db        7,7
         db        '*',7
         db        '*',8
         db        7,8
         db        249,8
         db        250,8
         db        ' ',7

; ------ aktu ln¡ definice znak–

ZnakTab  label     byte                     ; tabulka znak–
ZnakSwch db        'û-'                     ; znak p©ep¡na‡e menu

MouseKCh db        208,210,211,214,189,183  ; znaky kurzoru my¨i

DarkMap  db        250,7                    ; znaky pro ztmaven¡ displeje
         db        249,7
         db        7,7
         db        '*',7
         db        '*',8
         db        7,8
         db        249,8
         db        250,8
         db        ' ',7

ZnakTab0 label     byte

InitVMdN dw        3                        ; ‡¡slo po‘adovan‚ho videom¢du
                                            ;   (bit14 a bit15 neplat¡ !)
InitVMdM dw        TabVMod                  ; adresa po‘adovan‚ho videom¢du
;InitVMd  db        80,25                    ; rozmˆry po‘adovan‚ho videom¢du

ShftVMod db        0                        ; po‡et videom¢d–
         db        MaxVMod dup(0,0)         ; povolen‚ videom¢dy pro Shift-F10

; ------ pracovn¡ buffer pro na‡ten¡ u‘ivatelsk‚ho videom¢du
IniID3BD dw        0,0                      ; ¨¡©ka * v˜¨ka, ‡¡slo, 0

NumVMod  dw        0                        ; po‡et videom¢d– v tabulce
TabVMod  db        MaxVMod*4 dup(0)         ; tabulka videom¢d–
                                            ;   0: (2) bit 0-14: ‡¡slo videom¢du
                                            ;              > 255 = VESA videom¢d+256
                                            ;          bit 14: 1=je Shift-F10
                                            ;          bit 15: 1=MONO
                                            ;   2: (1) ¨¡©ka (pozic)
                                            ;   3: (1) v˜¨ka (© dk–)

CodePagT dw        TbKamIBM                 ; 0: KAM -> nezn m˜ k¢d
         dw        TbKamCs0                 ; 1: KAM -> bez diakritiky
         dw        TbKamIBM                 ; 2: KAM -> IBM
         dw        0                        ; 3: KAM -> Kamenick˜ch
         dw        TbKamLat                 ; 4: KAM -> Latin 2

         dw        TbLatIBM                 ; 0: LAT -> nezn m˜ k¢d
         dw        TbLatCs0                 ; 1: LAT -> bez diakritiky
         dw        TbLatIBM                 ; 2: LAT -> IBM
         dw        TbLatKam                 ; 3: LAT -> Kamenick˜ch
         dw        0                        ; 4: LAT -> Latin 2

Data     ENDS

         END
