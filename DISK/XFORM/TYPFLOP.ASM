
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©¡prava p©¡kazov‚ho © dku

Start:   mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         cld

; ------ nalezen¡ znaku v p©¡kazov‚m © dku

Start1:  jcxz      Start4
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "
         jbe       Start1                   ; vypu¨tˆn¡ znaku mezery

; ------ test, zda je ozna‡en¡ disku

         or        al,20h                   ; korekce na mal‚ p¡smeno
         sub       al,"a"                   ; ‡¡slo disku
         jc        Start4                   ; neplatn‚ ozna‡en¡ disku
         cmp       al,1
         jbe       Start5                   ; ‡¡slo disku je OK

; ------ chyba zad n¡ - zobrazen¡ n povˆdy

Start4:  mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
         mov       ax,4c00h
         int       21h

; ------ na‡ten¡ typu disku AL z CMOS

Start5:  add       byte ptr ds:[DiskTxtX],al
         call      GetTDisk                 ; ‡ten¡ typu disku z CMOS
         jnc       Start6                   ; disk detekov n OK
         call      TestCMOS                 ; je pamˆŸ CMOS ?
         mov       al,1                     ; mechanika 360 KB (asi je XT)
         jc        Start6                   ; nen¡ pamˆŸ CMOS, asi je XT
         mov       al,0                     ; neplatn˜ disk

; ------ £vodn¡ ‡ st hl ¨en¡

Start6:  push      ax
         mov       dx,offset DiskTxt
         mov       ah,9
         int       21h
         pop       ax

; ------ text disku

         push      ax
         mov       ah,0
         mov       dx,offset DiskTxt1
         dec       ax
         jz        Start7
         mov       dx,offset DiskTxt2
         dec       ax
         jz        Start7
         mov       dx,offset DiskTxt3
         dec       ax
         jz        Start7
         mov       dx,offset DiskTxt4
         dec       ax
         jz        Start7
         mov       dx,offset DiskTxt5
         dec       ax
         jz        Start7
         mov       dx,offset DiskTxt0
Start7:  mov       ah,9
         int       21h
         pop       ax

; ------ n vrat s n vratov˜m k¢dem AL

         mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        na‡ten¡ typu mechaniky AL z CMOS -> AL (CY=neplatn˜ disk)
; -----------------------------------------------------------------------------

GetTDisk PROC      NEAR

         call      TestCMOS                 ; test pamˆti CMOS
         jc        GetTDsk3                 ; neplatn  CMOS

         inc       ax                       ; 1=A:, 2=B:
         shl       al,1
         shl       al,1                     ; 4=A:, 8=B:
         xchg      ax,cx                    ; CL <- 4=A:, 8=B:

         mov       ah,10h                   ; ‡¡slo registru CMOS
         call      ReadCMOS                 ; na‡ten¡ registru z CMOS -> AL
         rol       al,cl                    ; rotace ‡¡sla na pozici
         and       al,0fh                   ; ‡¡slo mechaniky

         cmp       al,1                     ; minim ln¡ ‡¡slo 1
         jb        GetTDsk3                 ; neplatn˜ disk
         cmp       al,6                     ; maxim ln¡ ‡¡slo 5
         cmc

GetTDsk3:ret

GetTDisk ENDP

; -----------------------------------------------------------------------------
;        test kontroln¡ho sou‡tu pamˆti CMOS -> CY=neplatn  pamˆŸ
; -----------------------------------------------------------------------------

TestCMOS PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

; ------ kontroln¡ sou‡et CMOS

         xor       dx,dx                    ; st©ada‡ kontroln¡ho sou‡tu
         mov       ah,10h                   ; ukazatel ‡¡sla registru
TestCMS2:call      ReadCMOS                 ; ‡ten¡ bajtu
         add       dl,al                    ; p©i‡ten¡
         adc       dh,0
         inc       ah                       ; zv˜¨en¡ ukazatele
         cmp       ah,2eh
         jne       TestCMS2                 ; dal¨¡ bajt

; ------ kontrola kontroln¡ho sou‡tu

         call      ReadCMOS                 ; ‡ten¡ bajtu 2Eh
         cmp       al,dh                    ; souhlas¡ sou‡et HIGH ?
         jne       TestCMS8                 ; nesouhlas¡
         inc       ah
         call      ReadCMOS                 ; ‡ten¡ bajtu 2Fh
         cmp       al,dl                    ; souhlas¡ sou‡et LOW ?
         je        TestCMS9                 ; souhlas¡ OK
TestCMS8:stc                                ; p©¡znak chyby

; ------ n vrat registr–

TestCMS9:pop       dx
         pop       ax
         ret

TestCMOS ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ bajtu z pamˆti CMOS (adresa AH) -> AL
; -----------------------------------------------------------------------------

ReadCMOS PROC      NEAR

         xchg      al,ah
         out       [70h],al                 ; nastaven¡ adresy
         xchg      al,ah
         jmp       short $+2
         jmp       short $+2
         jmp       short $+2
         in        al,[71h]                 ; na‡ten¡ hodnoty CMOS
         ret

ReadCMOS ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

HelpTxt  db        'TYPFLOP V1.0 - detekce typu disketove mechaniky; (c) Miroslav Nemecek',13,10
         db        ' Zadejte oznaceni disku A nebo B, ktery chcete detekovat.',13,10
         db        ' Navraceny kod (ERRORLEVEL):   0 ..... disk neni nainstalovan',13,10
         db        '                               1 ..... mechanika 360 KB DD 5 1/4"',13,10
         db        '                               2 ..... mechanika 1.2 MB HD 5 1/4"',13,10
         db        '                               3 ..... mechanika 720 KB DD 3 1/2"',13,10
         db        '                               4 ..... mechanika 1.44 MB HD 3 1/2"',13,10
         db        '                               5 ..... mechanika 2.88 MB QD 3 1/2"',13,10
         db        '$'

DiskTxt  db        'Disk '
DiskTxtX db        'A: detekovan jako $'

DiskTxt0 db        'neplatny.',13,10,'$'
DiskTxt1 db        '360 KB DD 5 1/4".',13,10,'$'
DiskTxt2 db        '1.2 MB HD 5 1/4".',13,10,'$'
DiskTxt3 db        '720 KB DD 3 1/2".',13,10,'$'
DiskTxt4 db        '1.44 MB HD 3 1/2".',13,10,'$'
DiskTxt5 db        '2.88 MB QD 3 1/2".',13,10,'$'

Code     ENDS
         END       Start
