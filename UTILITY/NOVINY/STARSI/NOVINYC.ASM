code     segment
         assume    cs:code,ds:code
         org       100h

TopVRAM  EQU       30*80                    ; zaá†tek textu ve videopamàti
Linek    EQU       4                        ; poáet linek na bod znaku

start:

; ------ nastaven° obsluhy p©eru®en°

         mov       ax,2523h
         mov       dx,offset Navrat
         int       21h                      ; nastaven° adresy INT 21h

; ------ p©°prava k rozboru p©°kazovÇho ©†dku

         cld                                ; smàr nahoru
         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; poáet znakñ parametru
         mov       dx,offset Soubor         ; implicitn° soubor NOVINY.DAT

; ------ nalezen° zaá†tku zad†n° souboru

         cld
Start001:jcxz      Start009                 ; nen° zad†n° - je implicitn° soubor
         lodsb                              ; naáten° znaku z ©†dku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al,13                    ; je konec ©†dku CR ?
         je        Start009                 ; konec zad†n° (je CR)
         cmp       al," "                   ; je oddàlovaá ?
         jbe       Start001                 ; je oddàlovaá - vypustàn°
         mov       dx,si                    ; adresa zaá†tku zadanÇho textu
         dec       dx                       ; n†vrat adresy zadanÇho parametru

; ------ nalezen° konce zad†n° souboru

Start002:lodsb                              ; naáten° znaku z ©†dku
         jcxz      Start003                 ; konec ©†dku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al,13                    ; je konec ©†dku CR ?
         je        Start003                 ; konec zad†n° (je CR)
         cmp       al," "                   ; je oddàlovaá ?
         ja        Start002                 ; nen° oddàlovaá - dal®° znak
Start003:mov       byte ptr ds:[si-1],0     ; oznaáen° konce textu

; ------ otev©en° souboru

Start009:mov       ax,3d00h
         int       21h                      ; otev©en° souboru
         mov       bx,ax                    ; identifik†tor souboru
         jnc       Start1                   ; soubor otev©en OK

; ------ chyba - soubor nenalezen

Start00: mov       dx,offset ErrTxt
Start01: mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
Start0:  int       20h                      ; konec programu

; ------ naáten° souboru do pamàti

Start1:  mov       cx,sp                    ; z†sobn°k
         mov       dx,offset Buffer
         sub       cx,dx                    ; zbyl† kapacita
         jc        Start0                   ; chyba
         sub       cx,512                   ; rezerva pro z†sobn°k
         jc        Start0
         mov       ah,3fh
         int       21h                      ; naáten° souboru
         jc        Start00                  ; chyba áten°
         add       ds:[BuffEnd],ax          ; konec dat v bufferu
         mov       cx,ax                    ; poáet naátenòch bajtñ

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ inicializace videom¢du

         mov       ax,4                     ; videom¢d CGA 320x200
         int       10h                      ; inicializace videom¢du
         mov       ah,0fh
         int       10h                      ; poskytnut° videom¢du
         mov       dx,offset CardTxt        ; text - chybn† karta
         cmp       al,4
         jne       Start01                  ; chyba - chybn† karta

; ------ nastaven° palet displeje

         mov       ah,0bh
         mov       bx,100h
         int       10h

; ------ b†zov† ©°dic° adresa videokarty

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; ES <- 0
         mov       ax,ds:[463h]             ; b†zov† adresa portu CRT
         add       ax,6
         pop       ds
         mov       ds:[AdrPort],ax          ; adresa portu CRT

; ------ inicializaán° zobrazen° obrazovky

         mov       es,ds:[SegVRAM]          ; segment videopamàti
         mov       ax,5555h                 ; barva r†mu
         cld
         mov       cx,Linek*80/2            ; poáet bodñ/2
         mov       di,TopVRAM-Linek*80      ; adresa ve videopamàti
         rep       stosw                    ; horn° linka
         mov       di,TopVRAM+Linek*80*9    ; adresa pro druhou linku
         mov       cx,Linek*80/2
         rep       stosw

; ------ vymaz†n° podkladu

         mov       ax,0aaaah
         mov       di,TopVRAM
         mov       cx,Linek*80*9/2
         rep       stosw


         mov       si,offset Buffer         ; buffer s textem
         call      ReadCh
         mov       ds:[Znak],al

Start5:
         call      DispTxt

         inc       byte ptr ds:[Faze]
         and       byte ptr ds:[Faze],7
         jnz       Start6                   ;

         call      ReadCh
         mov       ds:[Znak],al

Start6:

         mov       ah,1
         int       16h
         jz        Start5

         xor       ax,ax
         int       16h

; ------ konec programu

Navrat:  mov       ax,3
         int       10h                      ; vymaz†n° displeje

         mov       dx,offset InfTxt
         mov       ah,9
         int       21h                      ; zobrazen° licenán°ho textu

         int       20h

; -----------------------------------------------------------------------------
;        rotace n†pisu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ synchronizace na zpàtnò bàh

         mov       dx,ds:[AdrPort]          ; adresa portu CRT
DispTx01:in        al,dx
         test      al,8
         jnz       DispTx01
DispTxt0:in        al,dx
         test      al,8
         jz        DispTxt0

; ------ rotace n†pisu o pozici vlevo

         push      ds
         mov       es,ds:[SegVRAM]
         mov       ds,ds:[SegVRAM]
         mov       si,TopVRAM+1+Linek*80
         mov       di,TopVRAM+Linek*80
         mov       cx,Linek*80*7
         cld
         rep       movsb
         pop       ds

; ------ stanoven° adresy znaku v tabulce fontñ

         mov       al,14                    ; poáet bajtñ na znak
         mul       byte ptr ds:[Znak]       ; vòpoáet offsetu znaku v tabulce
         mov       si,ax                    ; offset v tabulce znakñ
         add       si,offset Font           ; adresa znaku

; ------ zobrazen° znaku

         mov       di,TopVRAM+Linek*80-1
         mov       cl,ds:[Faze]             ; f†ze zobrazen° znaku
         mov       dl,14                    ; poáet linek znaku
DispTxt1:lodsb                              ; bajt definice znaku
         shl       ax,cl                    ; vypu®tàn° poá†teán°ch bodñ
         shl       al,1                     ; testovanò bit
         mov       al,0aah                  ; barva podkladu
         jnc       DispTxt2                 ; je podklad
         mov       al,0ffh                  ; jinak barva bodu
DispTxt2:

         stosb
         add       di,80-1
         stosb
         add       di,80-1
;         stosb
;         add       di,80-1
;         stosb
 ;        add       di,80-1

         dec       dl
         jnz       DispTxt1                 ; dal®° dvojice linek

; ------ n†vrat registrñ

DispTxt9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        áten° znaku z bufferu DS:SI
; -----------------------------------------------------------------------------

ReadCh   PROC      NEAR

; ------ £schova registrñ

         push      cx

; ------ poáet bajtñ v bufferu

         mov       cx,ds:[BuffEnd]          ; konec bufferu
         sub       cx,offset Buffer         ; poáet znakñ v bufferu
         jcxz      ReadCh8                  ; v bufferu nic nen°
         inc       cx                       ; p©ednastaven°

; ------ oprava ukazatele na zaá†tek bufferu

ReadCh1: dec       cx                       ; á°taá pokusñ o nalezen° znaku
         jcxz      ReadCh8                  ; byly jië v®echny znaky
         cmp       si,ds:[BuffEnd]          ; je za koncem bufferu ?
         jb        ReadCh2                  ; nen° je®tà za koncem bufferu
         mov       si,offset Buffer         ; oprava na zaá†tek bufferu

; ------ p©eskoáen° znaku EOF

ReadCh2: cmp       byte ptr ds:[si],26      ; je znak konce souboru ?
         jne       ReadCh3                  ; nen° znak konce souboru
         inc       si                       ; p©ednastaven°
         cmp       si,ds:[BuffEnd]          ; je konec bufferu ?
         je        ReadCh1                  ; je to konec souboru
         dec       si                       ; n†vrat znaku

; ------ p©eskoáen° dvojice CR/LF

ReadCh3: cmp       word ptr ds:[si],0a0dh   ; je CR/LF ?
         jne       ReadCh7                  ; nen° CR/LF - je platnò znak
         inc       si
         cmp       si,ds:[BuffEnd]          ; byl to posledn° znak ?
         jae       ReadCh6                  ; byl to posledn° znak
         inc       si                       ; p©eskoáen° i dal®°ho znaku
         jmp       short ReadCh1            ; dal®° pokus

; ------ nen° CR/LF

ReadCh6: dec       si                       ; n†vrat znaku

; ------ znak je platnò - jeho naáten°

ReadCh7: cld
         lodsb
         jmp       short ReadCh9

; ------ nelze nalÇzt platnò znak - n†hrada mezerou

ReadCh8: mov       al," "                   ; n†hradn° znak mezery

; ------ n†vrat registrñ

ReadCh9: pop       cx
         ret

ReadCh   ENDP


; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Soubor   db        'NOVINY.DAT',0

Font     db        0,0,0,0,0,0,0                           ; 0
         db        0,0,0,0,0,0,0                      
         db        0,0,7eh,81h,0a5h,81h,81h                ; 1
         db        0bdh,99h,81h,7eh,0,0,0             
         db        0,0,7eh,0ffh,0dbh,0ffh,0ffh             ; 2
         db        0c3h,0e7h,0ffh,7eh,0,0,0           
         db        0,0,0,6ch,0feh,0feh,0feh                ; 3
         db        0feh,7ch,38h,10h,0,0,0             
         db        0,0,0,10h,38h,7ch,0feh                  ; 4
         db        7ch,38h,10h,0,0,0,0                
         db        0,0,18h,3ch,3ch,0e7h,0e7h               ; 5
         db        0e7h,18h,18h,3ch,0,0,0             
         db        0,0,18h,3ch,7eh,0ffh,0ffh               ; 6
         db        7eh,18h,18h,3ch,0,0,0              
         db        0,0,0,0,0,18h,3ch                       ; 7
         db        3ch,18h,0,0,0,0,0                  
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0e7h,0c3h      ; 8
         db        0c3h,0e7h,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0,0,0,0,3ch,66h,42h                     ; 9
         db        42h,66h,3ch,0,0,0,0                
         db        0ffh,0ffh,0ffh,0ffh,0c3h,99h,0bdh       ; 10
         db        0bdh,99h,0c3h,0ffh,0ffh,0ffh,0ffh  
         db        0,0,1eh,0eh,1ah,32h,78h                 ; 11
         db        0cch,0cch,0cch,78h,0,0,0           
         db        0,0,3ch,66h,66h,66h,3ch                 ; 12
         db        18h,7eh,18h,18h,0,0,0              
         db        0,0,3fh,33h,3fh,30h,30h                 ; 13
         db        30h,70h,0f0h,0e0h,0,0,0            
         db        0,0,7fh,63h,7fh,63h,63h                 ; 14
         db        63h,67h,0e7h,0e6h,0c0h,0,0         
         db        0,0,18h,18h,0dbh,3ch,0e7h               ; 15
         db        3ch,0dbh,18h,18h,0,0,0             
         db        0,0,80h,0c0h,0e0h,0f8h,0feh             ; 16
         db        0f8h,0e0h,0c0h,80h,0,0,0           
         db        0,0,2,6,0eh,3eh,0feh                    ; 17
         db        3eh,0eh,6,2,0,0,0                  
         db        0,0,18h,3ch,7eh,18h,18h                 ; 18
         db        18h,7eh,3ch,18h,0,0,0              
         db        0,0,66h,66h,66h,66h,66h                 ; 19
         db        66h,0,66h,66h,0,0,0                
         db        0,0,7fh,0dbh,0dbh,0dbh,7bh              ; 20
         db        1bh,1bh,1bh,1bh,0,0,0              
         db        0,7ch,0c6h,60h,38h,6ch,0c6h             ; 21  " "
         db        0c6h,6ch,38h,0ch,0c6h,7ch,0        
         db        0,0,0,0,0,0,0                           ; 22
         db        0,0feh,0feh,0feh,0,0,0             
         db        0,0,18h,3ch,7eh,18h,18h                 ; 23
         db        18h,7eh,3ch,18h,7eh,0,0            
         db        0,0,18h,3ch,7eh,18h,18h                 ; 24
         db        18h,18h,18h,18h,0,0,0              
         db        0,0,18h,18h,18h,18h,18h                 ; 25
         db        18h,7eh,3ch,18h,0,0,0              
         db        0,0,0,0,18h,0ch,0feh                    ; 26
         db        0ch,18h,0,0,0,0,0                  
         db        0,0,0,0,30h,60h                         ; 27
         db        0feh,60h,30h,0,0,0,0,0             
         db        0,0,0,0,0,0c0h,0c0h                     ; 28
         db        0c0h,0feh,0,0,0,0,0                
         db        0,0,0,0,28h,6ch,0feh                    ; 29
         db        6ch,28h,0,0,0,0,0                  
         db        0,0,0,10h,38h,38h,7ch                   ; 30
         db        7ch,0feh,0feh,0,0,0,0              
         db        0,0,0,0feh,0feh,7ch,7ch                 ; 31
         db        38h,38h,10h,0,0,0,0                
         db        0,0,0,0,0,0,0                           ; 32  " "
         db        0,0,0,0,0,0,0                      
         db        0,0,18h,3ch,3ch,3ch,18h                 ; 33  "!"
         db        18h,0,18h,18h,0,0,0                
         db        0,66h,66h,66h,24h,0,0                   ; 34  "
         db        0,0,0,0,0,0,0                      
         db        0,0,6ch,6ch,0feh,6ch,6ch                ; 35  "#"
         db        6ch,0feh,6ch,6ch,0,0,0             
         db        18h,18h,7ch,0c6h,0c2h,0c0h,7ch          ; 36  "$"
         db        6,86h,0c6h,7ch,18h,18h,0           
         db        0,0,0,0,0c2h,0c6h,0ch                   ; 37  "%"
         db        18h,30h,66h,0c6h,0,0,0             
         db        0,0,38h,6ch,6ch,38h,76h                 ; 38  "&"
         db        0dch,0cch,0cch,76h,0,0,0           
         db        0,30h,30h,30h,60h,0,0                   ; 39  "'"
         db        0,0,0,0,0,0,0                      
         db        0,0,0ch,18h,30h,30h,30h                 ; 40  "("
         db        30h,30h,18h,0ch,0,0,0              
         db        0,0,30h,18h,0ch,0ch,0ch                 ; 41  ")"
         db        0ch,0ch,18h,30h,0,0,0              
         db        0,0,0,0,66h,3ch,0ffh                    ; 42  "*"
         db        3ch,66h,0,0,0,0,0                  
         db        0,0,0,0,18h,18h,7eh                     ; 43  "+"
         db        18h,18h,0,0,0,0,0                  
         db        0,0,0,0,0,0,0                           ; 44  ","
         db        0,18h,18h,18h,30h,0,0              
         db        0,0,0,0,0,0                             ; 45  "-"
         db        0feh,0,0,0,0,0,0,0                 
         db        0,0,0,0,0,0,0                           ; 46  "."
         db        0,0,18h,18h,0,0,0                  
         db        0,0,2,6,0ch,18h,30h                     ; 47  "/"
         db        60h,0c0h,80h,0,0,0,0               
         db        0,0,7ch,0c6h,0ceh,0deh,0f6h             ; 48  "0"
         db        0e6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,18h,38h,78h,18h,18h                 ; 49  "1"
         db        18h,18h,18h,7eh,0,0,0              
         db        0,0,7ch,0c6h,6,0ch,18h                  ; 50  "2"
         db        30h,60h,0c6h,0feh,0,0,0            
         db        0,0,7ch,0c6h,6,6,3ch                    ; 51  "3"
         db        6,6,0c6h,7ch,0,0,0                 
         db        0,0,0ch,1ch,3ch,6ch,0cch                ; 52  "4"
         db        0feh,0ch,0ch,1eh,0,0,0             
         db        0,0,0feh,0c0h,0c0h,0c0h,0fch            ; 53  "5"
         db        6,6,0c6h,7ch,0,0,0                 
         db        0,0,38h,60h,0c0h,0c0h,0fch              ; 54  "6"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0feh,0c6h,6,0ch,18h                 ; 55  "7"
         db        30h,30h,30h,30h,0,0,0              
         db        0,0,7ch,0c6h,0c6h,0c6h,7ch              ; 56  "8"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,7ch,0c6h,0c6h,0c6h,7eh              ; 57  "9"
         db        6,6,0ch,78h,0,0,0                  
         db        0,0,0,18h,18h,0,0                       ; 58  ":"
         db        0,18h,18h,0,0,0,0                  
         db        0,0,0,18h,18h,0,0                       ; 59  ";"
         db        0,18h,18h,30h,0,0,0                
         db        0,0,6,0ch,18h,30h,60h                   ; 60  "<"
         db        30h,18h,0ch,6,0,0,0                
         db        0,0,0,0,0,7eh,0                         ; 61  "="
         db        0,7eh,0,0,0,0,0                    
         db        0,0,60h,30h,18h,0ch,6                   ; 62  ">"
         db        0ch,18h,30h,60h,0,0,0              
         db        0,0,7ch,0c6h,0c6h,0ch,18h               ; 63  "?"
         db        18h,0,18h,18h,0,0,0                
         db        0,0,7ch,0c6h,0c6h,0deh,0deh             ; 64  "@"
         db        0deh,0dch,0c0h,7ch,0,0,0           
         db        0,0,10h,38h,6ch,0c6h,0c6h               ; 65  "A"
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,0fch,66h,66h,66h,7ch                ; 66  "B"
         db        66h,66h,66h,0fch,0,0,0             
         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 67  "C"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0,0f8h,6ch,66h,66h,66h                ; 68  "D"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        0,0,0feh,66h,62h,68h,78h                ; 69  "E"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,0,0feh,66h,62h,68h,78h                ; 70  "F"
         db        68h,60h,60h,0f0h,0,0,0             
         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 71  "G"
         db        0deh,0c6h,66h,3ah,0,0,0            
         db        0,0,0c6h,0c6h,0c6h,0c6h,0feh            ; 72  "H"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,3ch,18h,18h,18h,18h                 ; 73  "I"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,1eh,0ch,0ch,0ch,0ch                 ; 74  "J"
         db        0ch,0cch,0cch,78h,0,0,0            
         db        0,0,0e6h,66h,6ch,6ch,78h                ; 75  "K"
         db        6ch,6ch,66h,0e6h,0,0,0             
         db        0,0,0f0h,60h,60h,60h,60h                ; 76  "L"
         db        60h,62h,66h,0feh,0,0,0             
         db        0,0,0c6h,0eeh,0feh,0feh,0d6h            ; 77  "M"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,0c6h,0e6h,0f6h,0feh,0deh            ; 78  "N"
         db        0ceh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 79  "O"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,0fch,66h,66h,66h,7ch                ; 80  "P"
         db        60h,60h,60h,0f0h,0,0,0             
         db        0,0,7ch,0c6h,0c6h,0c6h,0c6h             ; 81  "Q"
         db        0d6h,0deh,7ch,0ch,0eh,0,0          
         db        0,0,0fch,66h,66h,66h,7ch                ; 82  "R"
         db        6ch,66h,66h,0e6h,0,0,0             
         db        0,0,7ch,0c6h,0c6h,60h,38h               ; 83  "S"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        0,0,7eh,7eh,5ah,18h,18h                 ; 84  "T"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 85  "U"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 86  "V"
         db        0c6h,6ch,38h,10h,0,0,0             
         db        0,0,0c6h,0c6h,0c6h,0c6h,0d6h            ; 87  "W"
         db        0d6h,0feh,7ch,6ch,0,0,0            
         db        0,0,0c6h,0c6h,6ch,38h,38h               ; 88  "X"
         db        38h,6ch,0c6h,0c6h,0,0,0            
         db        0,0,66h,66h,66h,66h,3ch                 ; 89  "Y"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0feh,0c6h,8ch,18h,30h               ; 90  "Z"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,0,3ch,30h,30h,30h,30h                 ; 91  "["
         db        30h,30h,30h,3ch,0,0,0              
         db        0,0,80h,0c0h,0e0h,70h,38h               ; 92  "\"
         db        1ch,0eh,6,2,0,0,0                  
         db        0,0,3ch,0ch,0ch,0ch,0ch                 ; 93  "]"
         db        0ch,0ch,0ch,3ch,0,0,0              
         db        10h,38h,6ch,0c6h,0,0,0                  ; 94  "^"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,0,0                           ; 95  "_"
         db        0,0,0,0,0,0ffh,0                   
         db        30h,30h,18h,0,0,0,0                     ; 96  "`"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,78h,0ch                       ; 97  "a"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0,0e0h,60h,60h,78h,6ch                ; 98  "b"
         db        66h,66h,66h,7ch,0,0,0              
         db        0,0,0,0,0,7ch,0c6h                      ; 99  "c"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0,1ch,0ch,0ch,3ch,6ch                 ; 100 "d"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,0,0,0,7ch,0c6h                      ; 101 "e"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        0,0,38h,6ch,64h,60h,0f0h                ; 102 "f"
         db        60h,60h,60h,0f0h,0,0,0             
         db        0,0,0,0,0,76h,0cch                      ; 103 "g"
         db        0cch,0cch,7ch,0ch,0cch,78h,0       
         db        0,0,0e0h,60h,60h,6ch,76h                ; 104 "h"
         db        66h,66h,66h,0e6h,0,0,0             
         db        0,0,18h,18h,0,38h,18h                   ; 105 "i"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,6,6,0,0eh,6                         ; 106 "j"
         db        6,6,6,66h,66h,3ch,0                
         db        0,0,0e0h,60h,60h,66h,6ch                ; 107 "k"
         db        78h,6ch,66h,0e6h,0,0,0             
         db        0,0,38h,18h,18h,18h,18h                 ; 108 "l"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,0,0,0,0ech,0feh                     ; 109 "m"
         db        0d6h,0d6h,0d6h,0c6h,0,0,0          
         db        0,0,0,0,0,0dch,66h                      ; 110 "n"
         db        66h,66h,66h,66h,0,0,0              
         db        0,0,0,0,0,7ch,0c6h                      ; 111 "o"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0,0,0,0dch,66h                      ; 112 "p"
         db        66h,66h,7ch,60h,60h,0f0h,0         
         db        0,0,0,0,0,76h,0cch                      ; 113 "q"
         db        0cch,0cch,7ch,0ch,0ch,1eh,0        
         db        0,0,0,0,0,0dch,76h                      ; 114 "r"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0,0,0,0,7ch,0c6h                      ; 115 "s"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0,0,10h,30h,30h,0fch,30h                ; 116 "t"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,0,0,0,0,0cch,0cch                     ; 117 "u"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,0,0,0,66h,66h                       ; 118 "v"
         db        66h,66h,3ch,18h,0,0,0              
         db        0,0,0,0,0,0c6h,0c6h                     ; 119 "w"
         db        0d6h,0d6h,0feh,6ch,0,0,0           
         db        0,0,0,0,0,0c6h,6ch                      ; 120 "x"
         db        38h,38h,6ch,0c6h,0,0,0             
         db        0,0,0,0,0,0c6h,0c6h                     ; 121 "y"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0,0,0,0,0,0feh,0cch                     ; 122 "z"
         db        18h,30h,66h,0feh,0,0,0             
         db        0,0,0eh,18h,18h,18h,70h                 ; 123 "{"
         db        18h,18h,18h,0eh,0,0,0              
         db        0,0,18h,18h,18h,18h,0                   ; 124 "|"
         db        18h,18h,18h,18h,0,0,0              
         db        0,0,70h,18h,18h,18h,0eh                 ; 125 "}"
         db        18h,18h,18h,70h,0,0,0              
         db        0,0,76h,0dch,0,0,0                      ; 126 "~"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,10h,38h,6ch                     ; 127 ""
         db        0c6h,0c6h,0feh,0,0,0,0             
         db        66h,3ch,3ch,66h,0c2h,0c0h,0c0h          ; 128 "Ä"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0,0cch,0cch,0,0cch,0cch               ; 129 "Å"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0ch,18h,30h,0,7ch,0c6h                ; 130 "Ç"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        68h,30h,1ch,0ch,0ch,3ch,6ch             ; 131 "É"
         db        0cch,0cch,0cch,7eh,0,0,0           
         db        0,0,0cch,0cch,0,78h,0ch                 ; 132 "Ñ"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0cch,78h,0f8h,6ch,66h,66h,66h           ; 133 "Ö"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        66h,3ch,7eh,7eh,5ah,18h,18h             ; 134 "Ü"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 135 "á"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 136 "à"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        66h,3ch,0feh,66h,62h,68h,78h            ; 137 "â"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,6,0f6h,64h,60h,60h,60h                ; 138 "ä"
         db        60h,62h,66h,0feh,0,0,0             
         db        0ch,18h,3ch,18h,18h,18h,18h             ; 139 "ã"
         db        18h,18h,18h,3ch,0,0,0              
         db        36h,1ch,70h,30h,30h,30h,30h             ; 140 "å"
         db        30h,30h,30h,78h,0,0,0              
         db        6h,6,74h,30h,30h,30h,30h                ; 141 "ç"
         db        30h,30h,30h,78h,0,0,0              
         db        0,0c6h,0c6h,10h,38h,6ch,0c6h            ; 142 "é"
         db        0c6h,0feh,0c6h,0c6h,0,0,0          
         db        6h,0ch,10h,38h,6ch,0c6h,0c6h            ; 143 "è"
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        18h,30h,60h,0,0feh,66h,60h              ; 144 "ê"
         db        7ch,60h,66h,0feh,0,0,0             
         db        0,0,0cch,78h,0,0feh,0cch                ; 145 "ë"
         db        18h,30h,66h,0feh,0,0,0             
         db        66h,3ch,0feh,0c6h,8ch,18h,30h           ; 146 "í"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,10h,38h,6ch,0,7ch,0c6h                ; 147 "ì"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0c6h,0c6h,0,7ch,0c6h                ; 148 "î"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0ch,18h,38h,6ch,0c6h,0c6h,0c6h          ; 149 "ï"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,38h,6ch,38h,0,0cch,0cch               ; 150 "ñ"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0ch,18h,0c6h,0c6h,0c6h,0c6h,0c6h        ; 151 "ó"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0ch,18h,0,0c6h,0c6h                 ; 152 "ò"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0,0c6h,0c6h,38h,6ch,0c6h,0c6h           ; 153 "ô"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0c6h,0c6h,0,0c6h,0c6h,0c6h            ; 154 "ö"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        66h,3ch,7ch,0c6h,0c6h,60h,38h           ; 155 "õ"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        36h,1ch,0f0h,60h,60h,60h,60h            ; 156 "ú"
         db        60h,62h,66h,0feh,0,0,0             
         db        6h,0ch,66h,66h,66h,66h,3ch              ; 157 "ù"
         db        18h,18h,18h,3ch,0,0,0              
         db        66h,3ch,0fch,66h,66h,66h,7ch            ; 158 "û"
         db        6ch,66h,66h,0f6h,0,0,0             
         db        36h,1ch,10h,30h,30h,0fch,30h            ; 159 "ü"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,18h,30h,60h,0,78h,0ch                 ; 160 "†"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0ch,18h,30h,0,38h,18h                 ; 161 "°"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,18h,30h,60h,0,7ch,0c6h                ; 162 "¢"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,18h,30h,60h,0,0cch,0cch               ; 163 "£"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0,66h,3ch,0,0dch,66h                  ; 164 "§"
         db        66h,66h,66h,66h,0,0,0              
         db        66h,3ch,0c6h,0e6h,0f6h,0feh,0deh        ; 165 "•"
         db        0ceh,0c6h,0c6h,0c6h,0,0,0          
         db        3ch,66h,3ch,0c6h,0c6h,0c6h,0c6h         ; 166 "¶"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        7ch,0c6h,38h,6ch,0c6h,0c6h,0c6h         ; 167 "ß"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 168 "®"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0,0,0cch,78h,0,0dch,76h                 ; 169 "©"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0,0ch,18h,0,0dch,76h                  ; 170 "™"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0ch,18h,0fch,66h,66h,66h,7ch            ; 171 "´"
         db        6ch,66h,66h,0e6h,0,0,0             
         db        0,0c0h,0c0h,0c6h,0cch,0d8h,30h          ; 172 "¨"
         db        66h,0ceh,9eh,3eh,6,6,0             
         db        0,0,7ch,0c6h,60h,38h,6ch                ; 173 "≠"
         db        0c6h,6ch,38h,0ch,0c6h,7ch,0        
         db        0,0,0,0,36h,6ch,0d8h                    ; 174 "Æ"
         db        6ch,36h,0,0,0,0,0                  
         db        0,0,0,0,0d8h,6ch,36h                    ; 175 "Ø"
         db        6ch,0d8h,0,0,0,0,0                 
         db        11h,44h,11h,44h,11h,44h,11h             ; 176 "∞"
         db        44h,11h,44h,11h,44h,11h,44h        
         db        55h,0aah,55h,0aah,55h,0aah,55h          ; 177 "±"
         db        0aah,55h,0aah,55h,0aah,55h,0aah    
         db        0ddh,77h,0ddh,77h,0ddh,77h,0ddh         ; 178 "≤"
         db        77h,0ddh,77h,0ddh,77h,0ddh,77h     
         db        18h,18h,18h,18h,18h,18h,18h             ; 179 "≥"
         db        18h,18h,18h,18h,18h,18h,18h        
         db        18h,18h,18h,18h,18h,18h,18h             ; 180 "¥"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,0f8h,18h            ; 181 "µ"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        36h,36h,36h,36h,36h,36h,36h             ; 182 "∂"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        0,0,0,0,0,0,0                           ; 183 "∑"
         db        0feh,36h,36h,36h,36h,36h,36h       
         db        0,0,0,0,0,0f8h,18h                      ; 184 "∏"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        36h,36h,36h,36h,36h,0f6h,6              ; 185 "π"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        36h,36h,36h,36h,36h,36h,36h             ; 186 "∫"
         db        36h,36h,36h,36h,36h,36h,36h        
         db        0,0,0,0,0,0feh,6                        ; 187 "ª"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        36h,36h,36h,36h,36h,0f6h,6              ; 188 "º"
         db        0feh,0,0,0,0,0,0                   
         db        36h,36h,36h,36h,36h,36h,36h             ; 189 "Ω"
         db        0feh,0,0,0,0,0,0                   
         db        18h,18h,18h,18h,18h,0f8h,18h            ; 190 "æ"
         db        0f8h,0,0,0,0,0,0                   
         db        0,0,0,0,0,0,0                           ; 191 "ø"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,18h,18h             ; 192 "¿"
         db        1fh,0,0,0,0,0,0                    
         db        18h,18h,18h,18h,18h,18h,18h             ; 193 "¡"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0,0,0,0,0,0                           ; 194 "¬"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,18h,18h             ; 195 "√"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        0,0,0,0,0,0,0                           ; 196 "ƒ"
         db        0ffh,0,0,0,0,0,0                   
         db        18h,18h,18h,18h,18h,18h,18h             ; 197 "≈"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,1fh,18h             ; 198 "∆"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        36h,36h,36h,36h,36h,36h,36h             ; 199 "«"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        36h,36h,36h,36h,36h,37h,30h             ; 200 "»"
         db        3fh,0,0,0,0,0,0                    
         db        0,0,0,0,0,3fh,30h                       ; 201 "…"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        36h,36h,36h,36h,36h,0f7h,0              ; 202 " "
         db        0ffh,0,0,0,0,0,0                   
         db        0,0,0,0,0,0ffh,0                        ; 203 "À"
         db        0f7h,36h,36h,36h,36h,36h,36h       
         db        36h,36h,36h,36h,36h,37h,30h             ; 204 "Ã"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        0,0,0,0,0,0ffh,0                        ; 205 "Õ"
         db        0ffh,0,0,0,0,0,0                   
         db        36h,36h,36h,36h,36h,0f7h,0              ; 206 "Œ"
         db        0f7h,36h,36h,36h,36h,36h,36h       
         db        18h,18h,18h,18h,18h,0ffh,0              ; 207 "œ"
         db        0ffh,0,0,0,0,0,0                   
         db        36h,36h,36h,36h,36h,36h,36h             ; 208 "–"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0,0,0,0,0ffh,0                        ; 209 "—"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        0,0,0,0,0,0,0                           ; 210 "“"
         db        0ffh,36h,36h,36h,36h,36h,36h       
         db        36h,36h,36h,36h,36h,36h,36h             ; 211 "”"
         db        3fh,0,0,0,0,0,0                    
         db        18h,18h,18h,18h,18h,1fh,18h             ; 212 "‘"
         db        1fh,0,0,0,0,0,0                    
         db        0,0,0,0,0,1fh,18h                       ; 213 "’"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        0,0,0,0,0,0,0                           ; 214 "÷"
         db        3fh,36h,36h,36h,36h,36h,36h        
         db        36h,36h,36h,36h,36h,36h,36h             ; 215 "◊"
         db        0ffh,36h,36h,36h,36h,36h,36h       
         db        18h,18h,18h,18h,18h,0ffh,18h            ; 216 "ÿ"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h,18h,18h,18h,18h,18h             ; 217 "Ÿ"
         db        0f8h,0,0,0,0,0,0                   
         db        0,0,0,0,0,0,0                           ; 218 "⁄"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 219 "€"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0,0,0,0,0,0,0                           ; 220 "‹"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h      ; 221 "›"
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h 
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh             ; 222 "ﬁ"
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh        
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 223 "ﬂ"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,76h,0dch                      ; 224 "‡"
         db        0d8h,0d8h,0dch,76h,0,0,0           
         db        0,0,0,0,7ch,0c6h,0fch                   ; 225 "·"
         db        0c6h,0c6h,0fch,0c0h,0c0h,40h,0     
         db        0,0,0feh,0c6h,0c6h,0c0h,0c0h            ; 226 "‚"
         db        0c0h,0c0h,0c0h,0c0h,0,0,0          
         db        0,0,0,0,0feh,6ch,6ch                    ; 227 "„"
         db        6ch,6ch,6ch,6ch,0,0,0              
         db        0,0,0feh,0c6h,60h,30h,18h               ; 228 "‰"
         db        30h,60h,0c6h,0feh,0,0,0            
         db        0,0,0,0,0,7eh,0d8h                      ; 229 "Â"
         db        0d8h,0d8h,0d8h,70h,0,0,0           
         db        0,0,0,0,66h,66h,66h                     ; 230 "Ê"
         db        66h,7ch,60h,60h,0c0h,0,0           
         db        0,0,0,0,76h,0dch,18h                    ; 231 "Á"
         db        18h,18h,18h,18h,0,0,0              
         db        0,0,7eh,18h,3ch,66h,66h                 ; 232 "Ë"
         db        66h,3ch,18h,7eh,0,0,0              
         db        0,0,38h,6ch,0c6h,0c6h,0feh              ; 233 "È"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 234 "Í"
         db        6ch,6ch,6ch,0eeh,0,0,0             
         db        0,0,1eh,30h,18h,0ch,3eh                 ; 235 "Î"
         db        66h,66h,66h,3ch,0,0,0              
         db        0,0,0,0,0,7eh,0dbh                      ; 236 "Ï"
         db        0dbh,7eh,0,0,0,0,0                 
         db        0,0,3,6,7eh,0dbh,0dbh                   ; 237 "Ì"
         db        0f3h,7eh,60h,0c0h,0,0,0            
         db        0,0,1ch,30h,60h,60h,7ch                 ; 238 "Ó"
         db        60h,60h,30h,1ch,0,0,0              
         db        0,0,0,7ch,0c6h,0c6h,0c6h                ; 239 "Ô"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0,0,0feh,0,0,0feh                     ; 240 ""
         db        0,0,0feh,0,0,0,0                   
         db        0,0,0,18h,18h,7eh,18h                   ; 241 "Ò"
         db        18h,0,0,0ffh,0,0,0                 
         db        0,0,30h,18h,0ch,6,0ch                   ; 242 "Ú"
         db        18h,30h,0,7eh,0,0,0                
         db        0,0,0ch,18h,30h,60h,30h                 ; 243 "Û"
         db        18h,0ch,0,7eh,0,0,0                
         db        0,0,0eh,1bh,1bh,18h,18h                 ; 244 "Ù"
         db        18h,18h,18h,18h,18h,18h,18h        
         db        18h,18h,18h,18h,18h,18h,18h             ; 245 "ı"
         db        18h,0d8h,0d8h,70h,0,0,0            
         db        0,0,0,18h,18h,0,7eh                     ; 246 "ˆ"
         db        0,18h,18h,0,0,0,0                  
         db        0,0,0,0,76h,0dch,0                      ; 247 "˜"
         db        76h,0dch,0,0,0,0,0                 
         db        0,38h,6ch,6ch,38h,0,0                   ; 248 "¯"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,0,0,18h                         ; 249 "˘"
         db        18h,0,0,0,0,0,0                    
         db        0,0,0,0,0,0,0                           ; 250 "˙"
         db        18h,0,0,0,0,0,0                    
         db        0,0fh,0ch,0ch,0ch,0ch,0ch               ; 251 "˚"
         db        0ech,6ch,3ch,1ch,0,0,0             
         db        0,0d8h,6ch,6ch,6ch,6ch,6ch              ; 252 "¸"
         db        0,0,0,0,0,0,0                      
         db        0,70h,0d8h,30h,60h,0c8h,0f8h            ; 253 "˝"
         db        0,0,0,0,0,0,0                      
         db        0,0,0,0,7ch,7ch,7ch                     ; 254 "˛"
         db        7ch,7ch,7ch,0,0,0,0                
         db        0,0,0,0,0,0,0                           ; 255
         db        0,0,0,0,0,0,0

ErrTxt   db        'Chybne zadani souboru k zobrazeni !',13,10,'$'

InfTxt   db        'NOVINY V1.0; (c) Miroslav Nemecek',13,10,'$'

CardTxt  db        'Program vyzaduje grafickou kartu CGA/EGA/VGA !',13,10,'$'

SegVRAM  dw        0b800h                   ; segment videopamàti
AdrPort  dw        3d4h                     ; adresa portu CRT

Faze     db        0                        ; á°taá f†ze znaku
Znak     db        " "                      ; znak k zobrazen°

BuffEnd  dw        offset Buffer            ; adresa konce dat

Buffer   db        1000h dup(" ")           ; diskovò buffer

code     ends
         end       start
