  
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                     ®achy
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;d_7205_00C2_e   equ     0C2h
;d_7205_09B4_e   equ     9B4h
;d_7205_09BC_e   equ     9BCh
;d_7205_09C0_e   equ     9C0h
;d_7205_09D1_e   equ     9D1h
;d_7205_09E6_e   equ     9E6h
;d_7205_09EC_e   equ     9ECh
  
;-------------------------------------------------------------- CODE  ----
  
Code            segment
                assume cs:Code,ds:Data,ss:Zasob

;==========================================================================
;        uloëen° novÇ definice do z†sobn°ku tahñ
;==========================================================================
  
l_0000   PROC      NEAR

         mov       dx,ds:[d_09CC]           ; ukazatel v z†sobn°ku tahñ
         lea       bx,ds:[d_09AA]           ; konec z†sobn°ku tahñ
         cmp       dx,bx                    ; je z†sobn°k jië plnò ?
         jae       l_0046                   ; z†sobn°k je jië plnò
         mov       bx,ds:[d_09CA]
         mov       ds:[d_09CA],dx
         mov       ds:[bx],dx
         test      byte ptr ds:[d_09D0],8
         jnz       l_0022
         or        byte ptr ds:[d_09D1],10h
l_0022:  mov       bx,dx
         mov       word ptr ds:[bx],0       ; bodov†n° tahu
         mov       al,ds:[d_09B2]
         mov       ds:[bx+2],al
         mov       al,ds:[d_09B4]           ; pozice p©i pokusu o tah
         mov       ds:[bx+3],al
         mov       al,ds:[d_09D1]           ; pñvodn° obsah novÇho pol°áka
         mov       ds:[bx+4],al
         mov       byte ptr ds:[bx+5],0
         add       bx,6                     ; zvò®en° ukazatele v z†sobn°ku
         mov       ds:[d_09CC],bx           ; ukazatel v z†sobn°ku tahñ
         ret
l_0046:  mov       word ptr ds:[bx],0       ; ohodnocen° - ë†dnò bod
         ret

l_0000   ENDP
  
         db        0
  
;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_004C   PROC      NEAR

         xor       byte ptr ds:[d_09CF],80h
         jns       l_0057
         dec       byte ptr ds:[d_09D4]     ; á°taá tahñ
l_0057:  dec       word ptr ds:[d_09C6]
         dec       byte ptr ds:[d_09D6]     ; á°taá hloubky (£rove§ hry)
         mov       bx,ds:[d_09C2]
         sub       bx,4
         mov       ds:[d_09C2],bx
         mov       ax,ds:[bx+2]
         mov       ds:[d_09CC],ax           ; ukazatel v z†sobn°ku tahñ
         mov       ax,ds:[bx]
         mov       ds:[d_09C4],ax
         call      l_0EC2                   ; n†vrat tahu z bufferu tahñ
         ret

l_004C   ENDP
  
         db      0
  
;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_007A   PROC      NEAR

         push      cx
         push      dx
         push      di
         mov       al,byte ptr ds:[d_09C0]
         cmp       al,0
         je        l_00AE
         mov       bl,cl
         mov       dl,0
         mov       cl,al
         mov       ch,0
         mov       al,ds:[d_09B4]           ; pozice p©i pokusu o tah
         lea       di,ds:[d_0165]           ; tabulka pozic figurek
         cld       
l_0094:  repne     scasb                    ; nalezen° pozice figurky
         jnz       l_00AE                   ; pozice nenalezena
         cmp       dl,0
         jne       l_00F3
         mov       dl,1
         mov       bh,ds:[di+9]
         cmp       bh,bl
         je        l_0094
         neg       bh
         cmp       bh,bl
         je        l_0094
         jnz       l_00F3
l_00AE:  mov       di,word ptr ds:[d_09BC]  ; soupe©ova figurka
         lea       bx,ds:[d_0149]           ; tabulka áernÇho hr†áe
         mov       ah,0
         mov       al,ds:[d_09D1]           ; pñvodn° figurka na pol°áku
         test      al,80h                   ; byla to b°l† figurka ?
         jz        l_00C3                   ; byla to áern† figurka
         lea       bx,ds:[d_0157]           ; tabulka b°lÇho hr†áe
l_00C3:  and       al,7                     ; figurka
         test      dh,80h
         jz        l_00CC
         mov       al,5                     ; bude d†ma
l_00CC:  inc       byte ptr ds:[bx]         ; zvò®en° celkovÇho poátu figurek
         add       bx,ax
         add       bx,ax
         mov       ax,ds:[bx]               ; stav figurek
         cmp       al,0
         je        l_00EB
         cmp       ah,0
         je        l_00E4
         inc       bx
         inc       bx
         mov       ax,ds:[bx]
         jmp       short l_00EB
         nop
l_00E4:  mov       ah,ds:[di+d_00C2]        ; bodov†n°
         jmp       short l_00F1
         nop
l_00EB:  mov       ah,al
         mov       al,ds:[di+d_00C2]        ; bodov†n°
l_00F1:  mov       ds:[bx],ax
l_00F3:  pop       di
         pop       dx
         pop       cx
         ret       

l_007A   ENDP
  
         db        0
  
;==========================================================================
;        prohl°ëen° okol° figurky
;==========================================================================
  
l_00F8   PROC      NEAR

         push      cx
         mov       ch,10h                   ; á°taá smàrñ
         mov       di,0                     ; ukazatel smàrñ
l_00FE:  mov       cl,ds:[di+d_009C]        ; smàr pohybu figurky
         mov       dh,0
         mov       al,ds:[d_09B6]           ; souáasn† pozice
         mov       ds:[d_09B4],al           ; pozice p©i pokusu o tah
l_010A:  inc       dh                       ; á°taá krokñ v danÇm smàru
         call      l_0AF6                   ; pokus o tah danòm smàrem
         cmp       al,1                     ; je skok na soupe©e ?
         je        l_0129                   ; je skok na soupe©e
         cmp       al,2                     ; je skok na vlastn° ?
         je        l_0134                   ; je skok na vlastn°
         cmp       al,0                     ; skok na pr†zdnÇ pol°áko ?
         jne       l_0120                   ; je skok mimo ®achovnici
         cmp       ch,9                   
         jae       l_010A                   ; dal®° pokus
                                          ;* skok ven z ®achovnice
l_0120:  inc       di                       ; zvò®en° adresy v tabulce
         dec       ch                       ; á°taá skokñ
         jnz       l_00FE                   ; dal®° pokus
         mov       al,0                     ; p©°znak - nen° skok
l_0127:  pop       cx
         ret       
                                          ;* nalezen soupe©
l_0129:  test      dh,40h                   ; byla jië nalezena vlastn° ?
         jnz       l_0120                   ; byla nalezena vlastn°
         or        dh,20h                   ; p©°znak nalezen° soupe©e
         jmp       short l_013C             ; dal®° hled†n°
         nop                              
                                          ;* nalezen vlastn°
l_0134:  test      dh,20h                   ; byl jië nalezen soupe© ?
         jnz       l_0120                   ; byl jië nalezen soupe©
         or        dh,40h                   ; p©°znak nalezen° vlastn°ho
l_013C:  mov       dl,ds:[d_09BC]           ; ru®en† figurka
         cmp       ch,9                   
         jb        l_0190                 
         cmp       dl,5                     ; d†ma
         jne       l_0150                   ; nen° d†ma
         or        dh,80h                   ; p©°znak
         jmp       short l_0195             ;
         nop

l_0150:  mov       al,dh
         and       al,0Fh
         cmp       al,1
         jne       l_015D
         cmp       dl,6                     ; je kr†l ?
         je        l_0195
l_015D:  cmp       ch,0Dh
         jb        l_0189
         cmp       dl,3                     ; je st©elec ?
         je        l_0195
         mov       al,dh
         and       al,0Fh
         cmp       al,1
         jne       l_0120
         cmp       dl,1                     ; je pà®ec ?
         jne       l_0120                   ; nen° pà®ec
         test      byte ptr ds:[d_09D1],80h
         jz        l_0182
         cmp       ch,0Fh
         jb        l_0120
         jnc       l_0195
l_0182:  cmp       ch,0Fh
         jae       l_0120
         jc        l_0195
l_0189:  cmp       dl,4                     ; je vàë ?
         jne       l_0120                   ; nen° vàë
         jz        l_0195
l_0190:  cmp       dl,2                     ; je jezdec ?
         jne       l_0120                   ; nen° jezdec
l_0195:  cmp       byte ptr ds:[d_09BA],7
         je        l_01A5
         test      dh,20h                                ; ' '
         jz        l_01A8
         mov       al,1
         jmp       short l_0127
l_01A5:  call      l_007A
l_01A8:  mov       al,ds:[d_09BC]
         cmp       al,6
         je        l_01B6
         cmp       al,2
         je        l_01B6
         jmp       l_010A
l_01B6:  jmp       l_0120

l_00F8   ENDP
  
         db        0
  
;==========================================================================
;        dek¢dov†n° pozice pro zobrazen°
;==========================================================================
  
l_01BA   PROC      NEAR

                                          ;* dek¢dov†n° pozice
                                            ; VSTUP: AL=pozice (bin†rnà)
                                            ; VùSTUP: AX=sou©adnice (textovà)
         mov       ah,0                          ; AH <- 0
         mov       bl,0Ah                        ; poáet bajtñ na ©†dek
         div       bl                            ; vòpoáet ©†dku a pozice
         xchg      al,ah                         ; AL<-pozice, AH<-©†dek
         add       ah,2Fh                        ; korekce ©†dku na á°slo
         add       al,40h                        ; korekce pozice na p°smeno
         ret

l_01BA   ENDP

;==========================================================================
;        n†hodnò vòbàr tabulky zah†jen° hry
;==========================================================================
  
l_01C8   PROC      NEAR

         mov       ah,2Ch
         int       21h                      ; poskytnut° systÇmovÇho áasu
         mov       al,dl                    ; setina sekundy
         and       al,3                     ; nië®° 2 bity setiny sekundy
         mov       dl,6                     
         mul       dl                       ; n†hodnÇ á°slo 0, 6, 12, 18
         lea       dx,ds:[d_000E]           
         add       ax,dx                    
         mov       ds:[d_09C8],ax           ; n†hodnà vybran† tabulka tahñ
         ret

l_01C8   ENDP

;==========================================================================
;        test ro®†dy
;==========================================================================
  
l_01DE   proc    near

         test      byte ptr ds:[d_09D0],8
         jz        l_01E6
         ret       

l_01E6:  cmp       byte ptr ds:[d_09D7],0
         je        l_01EE
         ret       

l_01EE:  mov       cx,0FF03h                ; posun kr†le o 3 pole vpravo
l_01F1:  add       cl,ds:[d_09B2]           
         mov       bh,0                     
         mov       bl,cl                    ; testovanÇ pol°áko
         mov       word ptr ds:[d_09B6],bx  
         mov       al,ds:[bx+d_00D1]        ; obsah pol°áka
         and       al,7Fh                   ; zru®en° p©°znaku barvy
         cmp       al,4                     ; je vàë ?
         jne       l_026E                   ; nen° vàë
         jz        l_0229

l_0209:  mov       bx,word ptr ds:[d_09B6]  ; pozice v ®achovnici
         cmp       byte ptr ds:[bx+d_00D1],0 ; je pr†zdnÇ pole ?
         jne       l_026E                   ; nen° pr†zdnÇ pole
         cmp       bl,5Ch                                ; '\'
         je        l_0229
         cmp       bl,16h
         je        l_0229
         call      l_00F8                   ; test okol° figurky
         cmp       al,0
         jne       l_026E
         mov       bx,word ptr ds:[d_09B6]
l_0229:  add       bl,ch
         mov       word ptr ds:[d_09B6],bx
         cmp       bl,ds:[d_09B2]
         jne       l_0209
         sub       bl,ch
         sub       bl,ch
         mov       ds:[d_09B4],bl           ; pozice p©i pokusu o tah
         mov       byte ptr ds:[d_09D1],40h
         call      l_0000                   ; uloëen° definice do z†sobn°ku tahñ
         mov       al,ds:[d_09B2]
         sub       al,ch
         mov       ds:[d_09B4],al           ; pozice p©i pokusu o tah
         mov       ds:[d_09B2],cl
         mov       byte ptr ds:[d_09D1],0
         call      l_0000                   ; uloëen° definice do z†sobn°ku tahñ
         mov       bx,ds:[d_09CA]
         sub       bx,6
         mov       ds:[d_09CA],bx
         mov       word ptr ds:[bx],0
         mov       al,ds:[d_09B6]
         mov       ds:[d_09B2],al

l_026E:  cmp       ch,1                     ; byl jië druhò smàr ?
         je        l_0279                   ; byl jië druhò smàr
         mov       cx,1FCh                  ; posun kr†le o 4 pozice vlevo
         jmp       l_01F1                   ; novò pokus

l_0279:  ret

l_01DE   ENDP

;==========================================================================
;        vymaz†n° informaán°ho ©†dku
;==========================================================================
  
l_027A   PROC      NEAR

         mov       dh,18h                   ; ©†dek kurzoru 24 - posledn°
         mov       dl,0                     ; pozice kurzoru 0
         mov       bh,0                     ; str†nka 0
         mov       ah,2                     
         int       10h                      ; nastaven° pozice kurzoru dolñ
         lea       dx,ds:[d_0026]           ; text pro vymaz†n°
         mov       ah,9                     
         int       21h                      ; tisk textu "         "
         mov       dh,18h                   ; ©†dek kurzoru 24 - posledn°
         mov       dl,0                     ; pozice kurzoru 0
         mov       bh,0                     ; str†nka 0
         mov       ah,2                     
         int       10h                      ; nastaven° pozice kurzoru
         ret

l_027A   ENDP
  
         db        0
  
;==========================================================================
;        Tah poá°taáe
;==========================================================================
  
l_0298   PROC      NEAR

         mov       al,57h                   ; oznaáen° poá°taáe b°lÇ "W"
         cmp       byte ptr ds:[d_09CE],0   ; m† hr†á áernÇ ?
         je        l_02A3                   ; hr†á m† áernÇ
         mov       al,42h                   ; oznaáen° poá°taáe áernÇ "B"
l_02A3:  mov       ds:[d_005E],al           ; oznaáen° barvy poá°taáe
         mov       ds:[d_007D],al           ; oznaáen° barvy poá°taáe
         mov       al,ds:[d_09D5]           ; £rove§ hry
         add       al,30h                   ; korekce na á°slici ASCII
         mov       ds:[d_0070],al           ; nastaven° oznaáen° á°slice
         cmp       byte ptr ds:[d_09CE],0   ; m† hr†á áernÇ ?
         jne       l_02BF                   ; hr†á m† b°lÇ
         cmp       byte ptr ds:[d_09D4],1   ; á°taá tahñ = 1 ?
         je        l_02CA                   ; je prvn° tah
l_02BF:  call      l_027A                   ; vymaz†n° textovÇho ©†dku
         lea       dx,ds:[d_0055]           ; text "COMPUTER WORKING"
         mov       ah,9                     
         int       21h                      ; tisk "COMPUTER WORKING "
l_02CA:  call      l_0606                   ; nalezen° tahu pro poá°taá
         call      l_027A                   ; vymaz†n° textovÇho ©†dku
         lea       dx,ds:[d_0073]           ; text "COMPUTER:"
         mov       ah,9                     
         int       21h                      ; tisk textu "COMPUTER(W): "
         mov       ax,ds:[d_09C8]           
         mov       ds:[d_09C4],ax           
         cmp       byte ptr ds:[d_017F],1
         jne       l_02EA                   
         mov       cl,1                     
         call      l_05B0                   ; hl†®en° o matu

l_02EA:  call      l_09B4                   ; proveden° jednoho tahu
         mov       al,ds:[d_09CE]           ; 80=hr†á m† b°lÇ, 00=áernÇ
         mov       ds:[d_09CF],al           ; 80=poá°taá m† b°lÇ, 00=áernÇ
         call      l_052A                   ; volba tahu pro ro®†du

                                           ;* norm†ln° tah
         cmp       ch,0                     ; je norm†ln° tah ?
         jne       l_0316                   ; nen° norm†ln° tah
         mov       al,dl                    ; c°lov† pozice
         call      l_01BA                   ; dek¢dov†n° pozice (textovà)
         mov       word ptr ds:[d_0085],ax  ; nastaven° c°le tahu
         mov       al,cl                    ; vòchoz° pozice
         call      l_01BA                   ; dek¢dov†n° pozice (textovà)
         mov       word ptr ds:[d_0082],ax  ; nastaven° vòchoz° pozice
         lea       dx,ds:[d_0082]           ; text "XX-XX"
         mov       ah,9                     
         int       21h                      ; tisk textu "XX-XX"
         jmp       short l_033E             ; pokraáov†n°
         nop                                
                                           ;* mal† ro®†da
l_0316:  test      ch,2                     ; je mal† ro®†da ?
         jz        l_0326                   ; nen° mal† ro®†da
         lea       dx,ds:[d_0089]           ; text "O-O"
         mov       ah,9                     
         int       21h                      ; tisk textu "O-O"
         jmp       short l_033E             ; pokraáov†n°
         nop                                
                                           ;* velk† ro®†da
l_0326:  test      ch,4                     ; je velk† ro®†da ?
         jz        l_0336                   ; nen° velk† ro®†da
         lea       dx,ds:[d_008E]           ; text "O-O-O"
         mov       ah,9                     
         int       21h                      ; tisk textu "O-O-O"
         jmp       short l_033E             ; pokraáov†n°
         nop                                

l_0336:  lea       dx,ds:[d_0095]           ; text "PxPep"
         mov       ah,9                     
         int       21h                      ; tisk textu "PxPep"

l_033E:  cmp       byte ptr ds:[d_017F],0FFh
         jne       l_034D
         mov       cl,0                     
         call      l_05B0                   ; hl†®en° o matu
         jmp       short l_0368             ; konec, áek† na znak
         nop
                                            
l_034D:  lea       bx,ds:[d_09E2]           ;
         call      l_0E46                   ; zobrazen° uplynulÇho áasu
         mov       al,ds:[d_09CE]           ; 80=hr†á m† b°lÇ, 00=áernÇ
         xor       al,80h                   
         call      l_08EC                   ; test okol° aktivn° figurky
         cmp       al,0                     
         je        l_0368                   
         lea       dx,ds:[d_004E]           
         mov       ah,9                     
         int       21h                      ; tisk textu "Check"
l_0368:  mov       ah,8                     
         int       21h                      ; vstup znaku z konzoly bez echa
         ret                                

l_0298   ENDP
  
         db        0
  
;==========================================================================
;        Zobrazen° ®achovnice
;==========================================================================
  
l_036E   PROC      NEAR
                                          ;* zobrazen° celÇ ®achovnice

         mov       bx,15h                   ; á°slo prvn°ho pol°áka
l_0371:  mov       dl,ds:[bx+d_00D1]        ; mapa ®achovnice
         cmp       dl,0FFh                  ; je zak†zanÇ pol°áko ?
         je        l_037F                   ; pol°áko je zak†zanÇ
         mov       al,bl                    ; á°slo pol°áka
         call      l_0386                   ; zobrazen° pol°áka
l_037F:  inc       bx                       ; zvò®en° á°sla pol°áka
         cmp       bx,63h                   ; je jië konec (=99) ?
         jb        l_0371                   ; dal®° pol°áko
         ret       

l_036E   ENDP

;==========================================================================
;        zobrazen° pol°áka
;==========================================================================
  
                                                 ; VSTUP: AL=á°slo pol°áka
                                                 ;        DL=obsah pol°áka

l_0386   PROC      NEAR

         push      es
         push      bp
         push      si
         push      di
         push      dx
         push      cx
         push      bx
         push      ax
         mov       bx,0B800h                ; segment videopamàti
         mov       es,bx                    ; segment videopamàti
         cld                                ; smàr dolñ
                                          ;* vòpoáet sou©adnic pol°áka
         mov       ah,0                     ; AH <- 0
         mov       cl,0Ah                   ; poáet bajtñ na ©†dek
         div       cl                       ; vòpoáet sou©adnic pol°áka
         sub       al,2                     ; odeáten° okraje
         neg       al                       ; - á°slo ©†dku
         add       al,7                     ; poá†teán° offset á°sla ©†dku
         dec       ah                       ; á°slo pozice - 1
         mov       bl,ah                    ; £schova á°sla pozice
                                          ;* vòpoáet masky pro barvu
         mov       bp,0                     ; maska barvy pol°áka
         cmp       dl,80h                   ; je b°l† figurka ?
         jne       l_03AE                   ; je b°l† figurka
         not       bp                       ; maska 0ffffh pro áernou barvu
l_03AE:  xor       ah,al                    ; test barvy pol°áka
         test      ah,1                     ; je áernÇ pol°áko ?
         jnz       l_03BA                   ; je b°lÇ pol°áko
         not       bp                       ; negace barvy podkladu
         xor       dl,80h                   ; zmàna barvy figurky
                                          ;* vòpoáet adresy ve videopamàti
l_03BA:  mov       cl,18h                   ; poáet linek na pol°áko
         mul       cl                       ; p©epoáet ©†dku na linky
         mov       cl,28h                   ; poáet bajtñ na ©†dek
         mul       cl                       ; vòpoáet á°sla linky
         mov       di,ax                    ; poá†teán° á°slo linky
         mov       al,0Ah                   ; poáet bajtñ na ®°©ku pol°áka
         mul       bl                       ; vòpoáet offsetu na ©†dku
         add       di,ax                    ; adresa pol°áka ve videopamàti
                                          ;* zobraz° se pr†zdnÇ pol°áko ?
         mov       al,dl                    ; á°slo figurky
         rol       al,1                     ; á°slo figurky * 2
         and       al,0Fh                   ; á°slo figurky
         sub       al,2                     ; odeáten° á°sla pà®ce
         jns       l_03F6                   ; je figurka
                                          ;* zobrazen° pr†zdnÇho pol°áka
         mov       bh,18h                   ; poáet linek na vò®ku pol°áka
l_03D6:  mov       ax,bp                    ; barva podkladu pol°áka
         mov       cx,5                     ; poáet bajtñ na ®°©ku pol°áka
         rep       stosw                  
         sub       di,0Ah                   ; vymaz†n° pol°áka horizont.
         mov       ax,es                    ; n†vrat ukl†dac° adresy
         xor       ax,200h                  ; segment videopamàti
         mov       es,ax                    ; zvò®en° adresy o 2000h
         test      ax,200h                  ; segment videopamàti
         jnz       l_03EF                   ; byla to druh† á†st linky ?
         add       di,50h                   ; byla to druh† á†st linky
l_03EF:  dec       bh                       ; zvò®en° adresy ve videopamàti
         jnz       l_03D6                   ; á°taá linek na vò®ku
         jmp       short l_043F             ; zobrazen° dal®° linky
         nop                                ; n†vrat
                                          
l_03F6:  mov       cl,78h                 ;* p©°prava zobrazen° figurky
         mul       cl                       ; dÇlka obr†zku figurky
         lea       si,ds:[d_0A8C]           ; vòpoáet offsetu v tabulce
         add       si,ax                    ; tabulka figurek
         mov       cl,18h                   ; adresa figurky v tabulce
l_0402:  mov       ch,5                     ; poáet linek na vò®ku
                                            ; poáet bajtñ na ®°©ku
l_0404:  lodsb                            ;* zdvojen° bodñ grafiky
         mov       bl,al                    ; naáten° bajtu figurky
         mov       bh,8                     ; bajt grafiky
         mov       dx,0                     ; poáet bitñ grafiky
l_040C:  ror       bl,1                     ; st©adaá grafiky
         mov       al,bl                    ; nejnië®° bit z grafiky
         and       al,80h                 
         sar       al,1                     ; novò nejnië®° bit
         shr       dx,1                     ; zdvojen° bitu 7 do bitu 6
         shr       dx,1                   
         or        dh,al                    ; rotace DX na novÇ pozice
         dec       bh                       ; vloëen° zdvojenÇho bitu
         jnz       l_040C                   ; á°taá bitñ
                                            ; dal®° bit k p©evodu
         mov       ax,dx                  ;* z†pis slova grafiky
         xchg      al,ah                  
         xor       ax,bp                  
         stosw                              ; maskov†n° barvy
         dec       ch                       ; uloëen° grafickÇho slova
         jnz       l_0404                   ; á°taá bajtñ
         sub       di,0Ah                   ; dal®° bajt pol°áka
         mov       ax,es                    ; n†vrat adresy ve videopamàti
         xor       ax,200h                  ; segment videopamàti
         mov       es,ax                    ; posun segmentu o 2000h nahoru
         test      ax,200h                  ; segment videopamàti
         jnz       l_043B                   ; je to horn° á†st ?
         add       di,50h                   ; je to horn° á†st
l_043B:  dec       cl                       ; zvò®en° adresy ve videopamàti
         jnz       l_0402                   ; á°taá linek na vò®ku
l_043F:  pop       ax                       ; zobrazen° dal®° linky
         pop       bx
         pop       cx
         pop       dx
         pop       di
         pop       si
         pop       bp
         pop       es
         ret

l_0386   ENDP

;==========================================================================
;
;        Start programu
;
;==========================================================================

chess    proc      far

start:   cli                                ; z†kaz p©eru®en°
         push      ds                       ; £schova DS
         mov       ax,SEG Data              ; datovò segment
         mov       ds,ax                    ; nastaven° datovÇho segmentu
         mov       es,ax                    ; ES <- datovò segment
         pop       ax                       ; AX <- prefix PSP
         mov       ds:[d_09EE],ax           ; segment PSP
         sti                                ; povolen° p©eru®en°
         lea       dx,ds:[d_09F0]           ; £vodn° text
         mov       ah,9                     
         int       21h                      ; zobrazen° £vodn°ho textu
         mov       byte ptr ds:[d_09CF],0   ; 80=poá°taá m† b°lÇ, 00=áernÇ
         call      l_0964                   ; volba barvy a £rovnà
         call      l_090E                   ; inicializace ®achovnice
         mov       ax,5                     ; poëadovanò videom¢d 5
         int       10h                      ; nastaven° videom¢du 5
         call      l_036E                   ; zobrazen° ®achovnice
         mov       byte ptr ds:[d_09D4],1   ; á°taá tahñ

l_0476:  test      byte ptr ds:[d_09CE],80h ; m† hr†á b°lÇ ?
         jnz       l_0486                   ; hr†á m† b°lÇ  - zaá°n†
                                          ;* na tahu je poá°taá
         call      l_0298                   ; tah poá°taáe
         call      l_0BF2                   ; volba tahu hr†áe
         jmp       short l_048C             
         nop                                
                                          ;* na tahu je hr†á
l_0486:  call      l_0BF2                   ; volba tahu hr†áe
         call      l_0298                   ; tah poá°taáe
l_048C:  inc       byte ptr ds:[d_09D4]     ; zvò®en° á°taáe tahñ
         jmp       short l_0476             ; dal®° tah
  
chess    ENDP
  
;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_0492   PROC      NEAR

         mov       al,ds:[d_09B2]
         test      byte ptr ds:[d_09D0],80h
         jz        l_049E
         add       al,0Ah
l_049E:  cmp       al,3Dh                                ; '='
         jb        l_0508
         cmp       al,44h                                ; 'D'
         ja        l_0508
         mov       bx,ds:[d_09C4]
         test      byte ptr ds:[bx+4],10h
         jz        l_0508
         mov       bl,ds:[bx+3]
         mov       ds:[d_09B8],bl
         mov       bh,0
         mov       al,ds:[bx+d_00D1]        ; obsah pole
         mov       ds:[d_09D2],al           
         and       al,7                     
         cmp       al,1                     ; je pà®†k ?
         jne       l_0508                   ; nen° pà®†k

         sub       bl,ds:[d_09B4]           ; pozice p©i pokusu o tah
         jns       l_04CE                   
         neg       bl                       ; absolutn° hodnota rozd°lu
l_04CE:  cmp       bl,0Ah
         jne       l_0508
         or        byte ptr ds:[d_09D1],40h              ; '@'
         call      l_0000                   ; uloëen° definice do z†sobn°ku tahñ
         mov       al,ds:[d_09B2]
         mov       ds:[d_09B6],al
         mov       al,ds:[d_09B8]
         mov       ds:[d_09B2],al
         mov       ds:[d_09B4],al           ; pozice p©i pokusu o tah
         mov       al,ds:[d_09D2]
         mov       ds:[d_09D1],al
         call      l_0000                   ; uloëen° definice do z†sobn°ku tahñ
         mov       al,ds:[d_09B6]
         mov       ds:[d_09B2],al
         mov       bx,ds:[d_09CA]
         sub       bx,6
         mov       ds:[d_09CA],bx
         mov       word ptr ds:[bx],0
l_0508:  ret

l_0492   ENDP
  
         db        0
  
;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_050A   PROC      NEAR

         call      l_09B4                   ; proveden° jednoho tahu
         mov       al,ds:[d_09CF]
         call      l_08EC                   ; test okol° aktivn° figurky
         cmp       al,0
         je        l_051F
         mov       byte ptr ds:[d_09D9],0
         jmp       short l_0525
         nop
l_051F:  call      l_0B24                   ; hodnocen° jednoho stavu ®achovnice
         call      l_0CA8                   
l_0525:  call      l_0EC2                   ; n†vrat tahu z bufferu tahñ
         ret

l_050A   ENDP
  
         db        0
  
;==========================================================================
;        volba tahu pro ro®†du
;==========================================================================
  
l_052A   PROC      NEAR

         mov       si,ds:[d_09C4]
         mov       al,ds:[d_09CF]           ; 80=poá°taá m† b°lÇ, 00=áernÇ
         cmp       al,ds:[d_09CE]           ; 80=hr†á m† b°lÇ, 00=áernÇ
         jne       l_056C
l_0537:  mov       bh,0
         mov       bl,ds:[si+3]
         cmp       bl,ds:[si+2]
         je        l_055B
         mov       dh,ds:[bx+d_00D1]        ; vektor ®achovnice
         test      byte ptr ds:[si+4],20h                   ; ' '
         jz        l_0551
         and       dh,0F8h
         or        dh,1
l_0551:  mov       dl,0
         mov       bl,ds:[si+2]                ; á°slo pol°áka
         mov       ch,0Ah                      ; poáet bliknut° kurzoru
         call      l_05E8                      ; blik†n° kurzoru
l_055B:  mov       bh,0                     
         mov       bl,ds:[si+3]             
         mov       dh,ds:[si+4]             
         mov       dl,ds:[bx+d_00D1]        ; vektor ®achovnice
         mov       ch,0Ah                   
         call      l_05E8                      ; blik†n° kurzoru
l_056C:  test      byte ptr ds:[si+4],40h                   ; '@'
         jz        l_0577
         add       si,6
         jmp       short l_0537
l_0577:  mov       bx,ds:[d_09C4]
         mov       cl,ds:[bx+2]
         mov       dl,ds:[bx+3]
         mov       ch,0
         test      byte ptr ds:[bx+4],40h                   ; '@'
         jz        l_05AF
         add       bx,6
         mov       cl,ds:[bx+2]
         mov       dl,ds:[bx+3]
         cmp       cl,dl
         jne       l_059C
         or        ch,1
         jmp       short l_05AF
         nop
l_059C:  cmp       dl,1Ah
         je        l_05AC
         cmp       dl,60h                                ; '`'
         je        l_05AC
         or        ch,4
         jmp       short l_05AF
         nop
l_05AC:  or        ch,2
l_05AF:  ret

l_052A   ENDP

;==========================================================================
;        hl†®en° o matu (nebo bl°ë°c°m se matu)
;==========================================================================
  
l_05B0   PROC      NEAR

         mov       al,ds:[d_09D3]           ; zbylò poáet tahñ 1
         sub       al,ds:[d_09D4]           ; á°taá tahñ
         jnz       l_05D4                   ; nen° vòhra
         cmp       cl,0                     ; je v°tàzem poá°taá ?
         je        l_05C9                   ; ano
                                          ;* vyhr†l hr†á
         lea       dx,ds:[d_0A5A]         
         mov       ah,9                   
         int       21h                      ; zobrazen° textu "MATE-YOU WIN"
         jmp       l_0894                   ; konec hry

                                          ;* vyhr†l poá°taá
l_05C9:  lea       dx,ds:[d_0A3A]         
         mov       ah,9                   
         int       21h                      ; zobrazen° textu "MATE - I WIN"
         jmp       l_0894                   ; konec hry

                                          ;* mat se bl°ë°
l_05D4:  cmp       cl,0                     ; hraje poá°taá ?
         jne       l_05E6                   ; nehraje poá°taá
         add       al,30h                   ; korekce na á°slici                                  ; '0'
         mov       ds:[d_0A52],al         
         lea       dx,ds:[d_0A4A]         
         mov       ah,9                   
         int       21h                      ; zobrazen° textu "MATE IN X MOVES"
l_05E6:  ret

l_05B0   ENDP
  
         db        0
  
;==========================================================================
;        blik†n° kurzoru
;==========================================================================
  
l_05E8   PROC      NEAR
                                                 ; VSTUP: CH=poáet bliknut°
                                                 ;        BL=á°slo pol°áka
                                                 ;        DL=figurka
                                                 ;        DH=figurka s kurzorem

         mov       cl,0                     ; p©°znak dvoj°ho bliknut°
l_05EA:  call      l_07AE                   ; proveden° obsluhy kl†vesy
         push      cx                       ; £schova p©°znaku zobrazen°
         mov       cx,2710h                 ; prodleva pro blik†n°
         loop      $                        ; prodleva
         pop       cx                       ; n†vrat p©°znaku zobrazen°
         xchg      dl,dh                    ;
         mov       al,bl                    ; á°slo pol°áka
         call      l_0386                   ; zobrazen° pol°áka AL
         xor       cl,1                     ; test p©°znaku ukonáen° tahu
         jnz       l_05EA                   ; tah nebyl dokonáen
         dec       ch                       ; á°taá poátu bliknut°
         jnz       l_05EA                   ; dal®° cyklus bliknut°
         ret

l_05E8   ENDP
  
         db        0
  
;==========================================================================
;        nalezen° tahu pro poá°taá
;==========================================================================
  
l_0606   PROC      NEAR

; --- p©°prava

         mov       ah,2Ch                                ; ','
         int       21h
         mov       ds:[d_09E2],dx           ; £schova systÇm. áasu
         mov       ds:[d_09E4],cx           
         mov       al,ds:[d_09D5]           ; £rove§ hry 1-6
         mov       ds:[d_0A6C],al           ; £schova £rovnà hry p©i tahu

; ------ prvn° tah - n†hodnÇ zah†jen°       

         cmp       byte ptr ds:[d_09D4],1   ; je to prvn° tah ?
         jne       l_062F                   ; nen° prvn° tah
         mov       byte ptr ds:[d_017F],0
         test      byte ptr ds:[d_09CE],80h ; 80=hr†á m† b°lÇ, 00=áernÇ
         jnz       l_062F                   
         call      l_01C8                   ; n†hodnò vòbàr tabulky zah†jen°
         ret                                

; ----- pro mÇnà neë 3. tah omezen° £rovnà hry na 1 (pro rozehr†n°)                        ry na 1 (pro rozehr†n°)

l_062F:  cmp       byte ptr ds:[d_09D4],3   ; á°taá tahñ
         ja        l_063B
         mov       byte ptr ds:[d_09D5],1   ; na zaá†tku £rove§ hry = 1

l_063B:  mov       ax,0                     
         mov       byte ptr ds:[d_09D6],al  ; á°taá hloubky (£rove§ hry)
         mov       ds:[d_09C8],ax           
         lea       ax,ds:[d_01B2]           ; zaá†tek tabulky tahñ
         mov       ds:[d_09CC],ax           ; ukazatel v z†sobn°ku tahñ
         lea       ax,ds:[d_018A]           
         sub       ax,2                     
         mov       ds:[d_09C2],ax           
         mov       al,ds:[d_09CE]           ; 80=hr†á m† b°lÇ, 00=áernÇ
         mov       ds:[d_09CF],al           ; 80=poá°taá m† b°lÇ, 00=áernÇ
         lea       di,ds:[d_017E]           
         mov       ds:[d_09C6],di           
         mov       ch,0                     
         mov       cl,ds:[d_09D5]           ; £rove§ hry
         add       cl,2                     
         mov       al,0                     
         cld                                
         rep       stosb                    
         mov       ds:[d_09DF],al           
         mov       ds:[d_09E0],al           
         call      l_0B24                   
         call      l_0CA8                   ; hodnocen° jednoho stavu ®achovnice
         mov       al,ds:[d_09DA]           
         mov       ds:[d_09DF],al           
         mov       al,ds:[d_09DE]           
         mov       ds:[d_09E0],al           
         jmp       short l_069D             
         nop                                


l_068C:  mov       dh,18h
         mov       dl,1Dh
         mov       bh,0
         mov       ah,2
         int       10h                      ; nastaven° pozice kurzoru
         lea       bx,ds:[d_09E2]           
         call      l_0E46                   ; zobrazen° uplynulÇho áasu
l_069D:  inc       byte ptr ds:[d_09D6]     ; á°taá hloubky (£rove§ hry)
         mov       byte ptr ds:[d_09D8],0
         call      l_08A2                   ; test, zda m† hr†á dal®° tah
         mov       al,byte ptr ds:[d_09D6]  ; á°taá hloubky (£rove§ hry)
         cmp       al,ds:[d_09D5]           ; £rove§ hry
         jae       l_06B5
         call      l_0E88
l_06B5:  mov       ax,ds:[d_09C2]
         mov       ds:[d_09C4],ax
l_06BB:  mov       bx,ds:[d_09C4]
         mov       ax,ds:[bx]
         cmp       ax,0
         je        l_072A
         mov       ds:[d_09C4],ax
         mov       bx,ds:[d_09C2]
         mov       ds:[bx],ax
         mov       al,byte ptr ds:[d_09D6]  ; á°taá hloubky (£rove§ hry)
         cmp       al,ds:[d_09D5]           ; £rove§ hry
         jb        l_0701                   
         call      l_09B4                   ; proveden° jednoho tahu
         mov       al,ds:[d_09CF]           
         call      l_08EC                   ; test okol° aktivn° figurky
         cmp       al,0                     
         je        l_06EA                   
         call      l_0EC2                   ; n†vrat tahu z bufferu tahñ
         jmp       short l_06BB

l_06EA:  mov       al,byte ptr ds:[d_09D6]  ; á°taá hloubky (£rove§ hry)
         cmp       al,ds:[d_09D5]           ; £rove§ hry
         jne       l_0759                   
         mov       al,ds:[d_09CF]           
         xor       al,80h                   
         call      l_08EC                   ; test okol° aktivn° figurky
         cmp       al,0
         je        l_0759
         jnz       l_070E
l_0701:  mov       bx,ds:[d_09C4]
         cmp       byte ptr ds:[bx+5],0
         je        l_06BB
         call      l_09B4                   ; proveden° jednoho tahu
l_070E:  xor       byte ptr ds:[d_09CF],80h
         js        l_0719
         inc       d_09D4                   ; á°taá tahñ
l_0719:  mov       bx,ds:[d_09C6]
         mov       al,ds:[bx]
         mov       ds:[bx+2],al
         inc       bx
         mov       ds:[d_09C6],bx
         jmp       l_068C
l_072A:  cmp       byte ptr ds:[d_09D8],0
         jne       l_0745
         mov       al,80h
         cmp       byte ptr ds:[d_09D7],0
         je        l_0765
         mov       al,ds:[d_09D4]           ; á°taá tahñ
         mov       ds:[d_09D3],al           ; zbylò poáet tahñ 1
         mov       al,0FFh
         jmp       short l_0765
         nop
l_0745:  cmp       byte ptr ds:[d_09D6],1   ; á°taá hloubky (£rove§ hry)
         je        l_07A6
         call      l_004C
         mov       bx,ds:[d_09C6]
         mov       al,ds:[bx+2]
         jmp       short l_076E
         nop
l_0759:  call      l_0B24                   ; hodnocen° jednoho stavu ®achovnice
         call      l_0CA8                   
         call      l_0EC2                   ; n†vrat tahu z bufferu tahñ
         mov       al,ds:[d_09D9]
l_0765:  mov       byte ptr ds:[d_09D8],1
         mov       bx,ds:[d_09C6]
l_076E:  cmp       al,ds:[bx]
         ja        l_0778
         call      l_004C
l_0775:  jmp       l_06BB
l_0778:  neg       al
         inc       bx
         cmp       al,ds:[bx]
         jbe       l_0775
         mov       ds:[bx],al
         cmp       byte ptr ds:[d_09D6],1   ; á°taá hloubky (£rove§ hry)
         jne       l_0775
         mov       ax,ds:[d_09C4]
         mov       ds:[d_09C8],ax
         mov       ax,word ptr ds:[d_017E]
         cmp       ah,0FFh
         jne       l_0775
         sub       byte ptr ds:[d_09D5],2   ; £rove§ hry
         test      byte ptr ds:[d_09CE],80h ; 80=hr†á m† b°lÇ, 00=áernÇ
         jz        l_07A6                   
         dec       byte ptr ds:[d_09D3]     ; zbylò poáet tahñ 1
l_07A6:  mov       al,ds:[d_0A6C]           ; £schova £rovnà hry p©i tahu
         mov       ds:[d_09D5],al           ; £rove§ hry
         ret

l_0606   ENDP
  
         db        0
  
;==========================================================================
;        Tah hr†áe - pohyb figurkou
;==========================================================================
  
l_07AE   PROC      NEAR
                                          ;* obsluha kl†vesnice
         mov       ah,0Bh
         int       21h                      ; test stavu kl†vesnice
         cmp       al,0                     
         je        l_07E5                   ; znak nen° p©ipraven
         mov       ah,8                     
         int       21h                      ; vstup znaku z konzoly bez echa
         cmp       al,0                     
         jne       l_07E5                   ; je to ASCII znak
         push      bx                       
         push      cx                       
         push      dx                       
         push      si                       
         push      di                       
         push      bp                       
         mov       ah,8                     
         int       21h                      ; vstup SCAN k¢du kl†vesy
         lea       di,ds:[d_0A6E]           ; tabulka SCAN k¢dñ kl†ves
         mov       cx,0Ah                   ; poáet kl†ves v tabulce
         mov       bx,cx                    ; á°taá kl†ves
         cld                                ; smàr nahoru
         repne     scasb
         jnz       l_07DF                   ; nalezen° znaku v tabulce
         dec       bx                       ; znak nenalezen
         sub       bx,cx                    ; poáet znakñ - 1
         shl       bx,1                     ; á°slo kl†vesy v tabulce
         call      word ptr ds:[bx+d_0A78]  ; á°slo kl†vesy * 2
l_07DF:  pop       bp                       ; proveden° obsluhy kl†vesy
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
  
l_07E5:  ret

l_07AE   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Home - vlevo nahoru
; -----------------------------------------------------------------------------

l_07E6   PROC      NEAR

         call      l_0802                   ; kurzor nahoru
         call      l_0811                   ; kurzor vlevo
         ret

l_07E6   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Page Up - vpravo nahoru
; -----------------------------------------------------------------------------

l_07ED   PROC      NEAR

         call      l_0802                   ; kurzor nahoru
         call      l_0829                   ; kurzor vpravo
         ret

l_07ED   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa End - vlevo dolñ
; -----------------------------------------------------------------------------

l_07F4   PROC      NEAR

         call      l_0841                   ; kurzor dolñ
         call      l_0811                   ; kurzor vlevo
         ret

l_07F4   ENDP

; -----------------------------------------------------------------------------
;        Page Down - vpravo dolñ
; -----------------------------------------------------------------------------

l_07FB   PROC      NEAR

         call      l_0841                   ; kurzor dolñ
         call      l_0829                   ; kurzor vpravo
         ret

l_07FB   ENDP

; -----------------------------------------------------------------------------
;        kurzor nahoru
; -----------------------------------------------------------------------------

l_0802   PROC      NEAR

         mov       al,ds:[d_09E6]           ; pozice kurzoru
         add       al,0ah                   ; zvò®en° ©†dku o 10
         cmp       al,64h                   ; je p©ekroáen okraj ?
         jb        l_080D                   ; okraj je®tà nen° p©ekroáen
         sub       al,50h                   ; sn°ëen° na spodn° okraj
l_080D:  mov       ds:[d_09E6],al           ; nov† pozice kurzoru
         ret

l_0802   ENDP

; -----------------------------------------------------------------------------
;        kurzor vlevo
; -----------------------------------------------------------------------------

l_0811   PROC      NEAR

         dec       byte ptr ds:[d_09E6]     ; sn°ëen° pozice kurzoru
         mov       ah,0
         mov       al,ds:[d_09E6]           ; pozice kurzoru
         mov       cl,10                    ; poáet pozic na ©†dek
         div       cl                       ; kontrola okraje
         cmp       ah,0                     ; byl p©echod p©es okraj ?
         jne       l_0828                   ; nebyl p©echod p©es okraj
         add       byte ptr ds:[d_09E6],8   ; korekce na konec ©†dku
l_0828:  ret

l_0811   ENDP

; -----------------------------------------------------------------------------
;        kurzor vpravo
; -----------------------------------------------------------------------------

l_0829   PROC      NEAR

         inc       byte ptr ds:[d_09E6]     ; zvò®en° pozice kurzoru
         mov       ah,0
         mov       al,ds:[d_09E6]           ; pozice kurzoru
         mov       cl,10                    ; poáet pozic na ©†dek
         div       cl                       ; kontrola okraje
         cmp       ah,9                     ; byl p©echod p©es okraj ?
         jne       l_0840                   ; nebyl p©echod p©es okraj
         sub       byte ptr ds:[d_09E6],8   ; korekce na zaá†tek ©†dku
l_0840:  ret

l_0829   ENDP

; -----------------------------------------------------------------------------
;        kurzor dolñ
; -----------------------------------------------------------------------------

l_0841   PROC      NEAR

         mov       al,ds:[d_09E6]           ; pozice kurzoru
         sub       al,10                    ; sn°ëen° á°sla ©†dku
         cmp       al,20                    ; je podteáen° pod okraj ?
         ja        l_084C                   ; nen° pod spodn°m okrajem
         add       al,50h                   ; korekce na horn° okraj
l_084C:  mov       ds:[d_09E6],al           ; nov† pozice kurzoru
         ret

l_0841   ENDP

; -----------------------------------------------------------------------------
;        Insert - poloëen° figurky
; -----------------------------------------------------------------------------

l_0850   PROC      NEAR

         cmp       byte ptr ds:[d_09E7],2   ; áek† se na poloëen° ?
         jne       l_0862                   ; neáek† se na Insert
         mov       al,ds:[d_09E6]           ; pozice kurzoru
         mov       ds:[d_09EA],al           ; nov† pozice figurky
         mov       byte ptr ds:[d_09E7],0   ; p©°znak stavu klidu
l_0862:  ret

l_0850   ENDP

; -----------------------------------------------------------------------------
;        Delete - uchopen° figurky
; -----------------------------------------------------------------------------

l_0863   PROC      NEAR

         cmp       byte ptr ds:[d_09E7],1   ; áek† se na uchopen° ?
         jne       l_0862                   ; neáek† se na uchopen°
         mov       bh,0
         mov       bl,ds:[d_09E6]           ; pozice kurzoru
         mov       al,ds:[bx+d_00D1]        ; p©en†®en† figurka
         cmp       al,0                     ; je nàjak† figurka ?
         je        l_0893                   ; nen° figurka
         xor       al,ds:[d_09CE]           ; je to figurka spr†vnÇ barvy ?
         jns       l_0893                   ; je to ®patn† figurka
         mov       ds:[d_09E9],bl           ; vòchoz° pozice figurky
         mov       al,ds:[bx+d_00D1]        ; p©en†®en† figurka
         mov       ds:[d_09E8],al           ; p©en†®en† figurka
         mov       byte ptr ds:[bx+d_00D1],0 ; vektor ®achovnice
         mov       byte ptr ds:[d_09E7],2   ; p©°znak áek†n° na poloëen°
l_0893:  ret

l_0863   ENDP

; -----------------------------------------------------------------------------
;        konec hry - nàkdo vyhr†l
; -----------------------------------------------------------------------------

l_0894   PROC      NEAR

         mov       ah,8
         int       21h                      ; vstup znaku z konzoly bez echa
         mov       ax,2                     
         int       10h                      ; nastaven° videom¢du 2
         jmp       dword ptr ds:[d_09EC]    ; skok na adresu PSP:0

l_0894   ENDP

         db        0
  
;==========================================================================
;        test, zda je nàjak† figurka, s kterou lze t†hnout
;==========================================================================
  
l_08A2   PROC      NEAR

         mov       al,ds:[d_09CF]           ; barva aktivn°ho hr†áe
         call      l_08EC                   ; test okol° aktivn° figurky
         mov       ds:[d_09D7],al           
         mov       dx,ds:[d_09CC]           ; ukazatel v z†sobn°ku tahñ
         mov       bx,ds:[d_09C2]           
         mov       ds:[bx+2],dx             
         add       bx,4                     
         mov       ds:[d_09C2],bx           
         mov       ds:[d_09CA],bx           
         mov       bx,15h                   ; prvn° pol°áko ®achovnice

l_08C4:  mov       word ptr ds:[d_09B2],bx  ; ukazatel v ®achovnici
         mov       al,ds:[bx+d_00D1]        ; k†men na ®achovnici
         cmp       al,0                     ; je pr†zdnÇ pole ?
         je        l_08E0                   ; pr†zdnÇ pole - dal®°
         cmp       al,0FFh                  ; mimo ®achovnici ?
         je        l_08E0                   ; je mimo - konec
         mov       ds:[d_09D0],al           ; testovan† figurka
         xor       al,ds:[d_09CF]           ; je to figurka hr†áe ?
         js        l_08E0                   ; nen° - dal®°
         call      l_0A30                   ; test, zda lze s figurkou t†hnout

l_08E0:  mov       bx,word ptr ds:[d_09B2]
         inc       bx
         cmp       bl,63h
         jb        l_08C4
         ret

l_08A2   ENDP
  
         db        0
  
;==========================================================================
;        test okol° aktivn° figurky (AL=barva protihr†áe)
;==========================================================================
  
l_08EC   PROC      NEAR

         rol       al,1                     ; barva -> bit 0
         and       ax,1                     ; barva protihr†áe
         mov       bx,ax                    ; BX <- barva prohr†áe (1=b°l†)
         mov       bl,ds:[bx+d_0179]        ; pozice kurzoru b°lò/áernò
         mov       bh,0                     ; BH <- 0
         mov       word ptr ds:[d_09B6],bx  ; pracovn° pozice hr†áe
         mov       al,ds:[bx+d_00D1]        ; figurka na pozici
         mov       ds:[d_09D0],al           ; figurka p©i testu
         and       al,7                     
         mov       ds:[d_09BA],al           ; figurka p©i testu
         call      l_00F8                   ; test okol° figurky
         ret

l_08EC   ENDP
  
         db        0
  
;==========================================================================
;        Inicializace ®achovnice
;==========================================================================
  
l_090E   PROC      NEAR

                                          ;* inicializace ®achovnice
         lea       di,ds:[d_00D1]           ; mapa ®achovnice
         mov       cx,78h                   ; dÇlka mapy ®achovnice
         mov       al,0FFh                  ; nulovac° bajt
         cld                                
         rep       stosb                    ; vymaz†n° mapy ®achovnice
                                          ;* rozm°stàn° figurek
         mov       bx,0                     ; offset v ®achovnici
l_091D:  mov       al,ds:[bx+d_00C9]        ; áern† figurka
         mov       ds:[bx+d_00E6],al        ; um°stàn° áernÇ figurky
         or        al,80h                   ; p©°znak b°lÇ figurky
         mov       ds:[bx+d_012C],al        ; um°stàn° b°lÇ figurky
         mov       al,1                     ; áernò pà®ec
         mov       ds:[bx+d_00F0],al        ; um°stàn° áernÇho pà®ce
         or        al,80h                   ; p©°znak b°lÇ figurky
         mov       ds:[bx+d_0122],al        ; um°stàn° b°lÇho pà®ce
         mov       al,0                     ; nulovac° bajt
         mov       ds:[bx+d_00FA],al        ; ostatn° ©†dky se vymaëou
         mov       ds:[bx+d_0104],al      
         mov       ds:[bx+d_010E],al      
         mov       ds:[bx+d_0118],al      
         inc       bx                       ; zvò®en° ukazatele ®achovnice
         cmp       bx,8                     ; jsou jië v®echny sloupce ?
         jb        l_091D                   ; nejsou je®tà v®echny sloupce
         mov       byte ptr ds:[d_0179],19h ; pozice kurzoru b°lÇho
         mov       byte ptr ds:[d_017A],5Fh ; pozice kurzoru áernÇho
         mov       byte ptr ds:[d_017B],18h ; b°l† d†ma
         mov       byte ptr ds:[d_017C],5Eh ; áern† d†ma
         ret

l_090E   ENDP

;==========================================================================
;        Volba barvy a £rovnà
;==========================================================================
  
l_0964   PROC      NEAR

         lea       dx,ds:[d_102C]           ; text "WHICH COLOR..."
         mov       ah,9                     
         int       21h                      ; zobrazen° "WHICH COLOR..."
         mov       ah,1                     
         int       21h                      ; vstup z konzoly s echem
         cmp       al,57h                   ; je "W" (b°l† barva) ?
         je        l_0980                   ; je b°l† barva hr†áe
         cmp       al,42h                   ; je "B" (áern† barva hr†áe) ?
         jne       l_0964                   ; chyba zad†n° - znovu
         mov       byte ptr ds:[d_09CE],0   ; hr†á m† áernou barvu
         jmp       short l_0985             
         nop                                
l_0980:  mov       byte ptr ds:[d_09CE],80h ; hr†á m† b°lou barvu

l_0985:  lea       dx,ds:[d_1050]           ; text "WHICH LEVEL..."
         mov       ah,9                     
         int       21h                      ; zobrazen° "WHICH LEVEL..."
         mov       ah,1                     
         int       21h                      ; vstup znaku z echem
         sub       al,30h                   ; korekce na bin†rn° á°slo
         cmp       al,1                     ; minim†ln° á°slo = 1
         jb        l_0985                   ; chybnÇ zad†n°
         cmp       al,6                     ; maxim†ln° á°slo = 6
         ja        l_0985                   ; chybnÇ zad†n°
         mov       ds:[d_09D5],al           ; £rove§ hry 1 aë 6
         ret

l_0964   ENDP
  
         db        0
  
;==========================================================================
;        omezen° á°sla AL na CH (absolutnà)
;==========================================================================
  
l_09A0   PROC      NEAR

                                          ;* kontrola p©ekroáen° á°sla AL
         and       al,al                    ; test AL
         lahf                               ; £schova registru p©°znakñ
         jns       l_09A7                   ; je kladnÇ á°slo
         neg       al                       ; absolutn° hodnota á°sla
l_09A7:  cmp       al,ch                    
         jb        l_09AD                   
         mov       al,ch                    
l_09AD:  sahf                               ; n†vrat registru p©°znakñ
         jns       l_09B2                   ; bylo to kladnÇ á°slo
         neg       al                       ; n†vrat z†pornÇho á°sla
l_09B2:  ret

l_09A0   ENDP
  
         db        0
  
;==========================================================================
;        proveden° jednoho tahu
;==========================================================================
  
l_09B4   PROC      NEAR

         mov       si,ds:[d_09C4]           ; ukazatel v bufferu tahñ
l_09B8:  mov       bh,0                     
         mov       dh,ds:[si+4]             ; c°lov† figurka
         mov       bl,ds:[si+2]             ; vòchoz° pozice
         mov       di,bx                    ; vòchoz° pozice
         mov       bl,ds:[si+3]             ; c°lov† pozice
         mov       si,bx                    ; c°lov† pozice
         mov       dl,ds:[di+d_00D1]        ; figurka, kter† t†hne
         mov       bl,dl                    ; £schova figurky k t†hnut°
         rol       bl,1                     
         and       bx,1                     ; barva figurky
         nop
         test      dh,20h                   ; n†hrada pà®†ka d†mou ?
         jnz       l_0A07                   ; je n†hrada pà®†ka d†mou
         mov       al,dl                    ; aktivn° figurka
         and       al,7                     ; zru®en° barvy
         cmp       al,5                     ; je d†ma ?
         je        l_0A0F                   ; je d†ma
         cmp       al,6                     ; je kr†l ?
         je        l_0A17                   ; je kr†l

l_09E4:  or        dl,8
         mov       ds:[si+d_00D1],dl        ; aktivn° figurka na novÇ pozici
         mov       byte ptr ds:[di+d_00D1],0; zru®en° aktivn° figurky
         test      dh,40h                   ; bude dal®° tah ?
         jnz       l_0A27                   ; bude dal®° tah (ro®†da)
         mov       al,dh                    ; ru®en† figurka
         and       al,7                     ; zru®en° barvy
         cmp       al,5                     ; byla to d†ma ?
         jne       l_0A06                   ; nebyla to d†ma
         xor       bx,1
         nop
         mov       byte ptr ds:[bx+d_017B],0; zru®en° pozice d†my
l_0A06:  ret

; ------ n†hrada pà®†ka d†mou

l_0A07:  and       dl,0F8h                  ; zru®en° figurky
         or        dl,5                     ; n†hrada d†mou
         jmp       short l_09E4

; ------ tah d†mou - nov† pozice

l_0A0F:  mov     ax,si                      ; c°lov† pozice figurky
         mov     ds:[bx+d_017B],al          ; nov† pozice d†my
         jmp     short l_09E4

; ------- tah kr†lem

l_0A17:  test    dh,40h                     ; byla to ro®†da ?
         jz      l_0A1F                     ; nebyla ro®†da
         or      dl,10h                     ; p©°znak 2. tahu ro®†dy

l_0A1F:  mov     ax,si                      
         mov     ds:[bx+d_0179],al          ; nov† pozice kurzoru
         jmp     short l_09E4

l_0A27:  mov     si,ds:[d_09C4]
         add     si,6
         jmp     short l_09B8

l_09B4   ENDP

;==========================================================================
;        test, zda lze s figurkou t†hnout
;==========================================================================
  
l_0A30   PROC      NEAR

; ------ p©°prava poátu a adresy moënòch tahñ figurky

         mov       al,ds:[d_09D0]           ; testovan† figurka
         and       al,87h                   ; figurka s barvou
         cmp       al,81h                   ; je áernò pà®†k ?
         jne       l_0A3B                   ; nen° áernò pà®†k
         dec       al                       ; n†hradnò á°slo figurky 0
l_0A3B:  and       al,7                     ; zru®en° barvy
         mov       ds:[d_09BA],al           ; figurka
         mov       bh,0                     
         mov       bl,al                    ; figurka
         mov       ch,ds:[bx+d_00BB]        ; poáet moënòch tahñ
         mov       bl,ds:[bx+d_00B4]        ; adresa moënòch tahñ
         mov       di,bx                    ; adresa moënòch tahñ figurky

; --------- test jednoho tahu figurky

l_0A4E:  mov       cl,ds:[di+d_009C]        ; moënò smàr tahu figurky
         mov       al,ds:[d_09B2]           ; pozice figurky
         mov       ds:[d_09B4],al           ; pozice p©i pokusu o tah

; ------- test jednoho kroku

l_0A58:  call      l_0AF6                   ; pokus o tah danòm smàrem

         cmp       al,2                     ; je skok na vlastn° nebo ven ?
         jae       l_0A7A                   ; skok na vlastn° nebo ven - chyba

         cmp       al,0                     ; je pr†zdnÇ ?
         lahf                               ; £schova p©°znakñ
         mov       al,ds:[d_09BA]           ; figurka
         cmp       al,1                     ; je pà®†k ?
         jbe       l_0A8A                   ; pà®†k nebo pr†zdnÇ pol°áko
         call      l_0000                   ; uloëen° definice do z†sobn°ku tahñ
         sahf                               ; n†vrat p©°znakñ
         jnz       l_0A7A                   ; nen° pr†zdnÇ pol°áko
         mov       al,ds:[d_09BA]           ; figurka
         cmp       al,6                     ; je kr†l ?
         je        l_0A7A                   ; je kr†l - nelze dal®° krok
         cmp       al,3                     ; je st©elec, vàë nebo d†ma ?
         jae       l_0A58                   ; st©elec, vàë nebo d†ma-dal®° krok

l_0A7A:  inc       di
         dec       ch
         jnz       l_0A4E
         mov       al,ds:[d_09BA]
         cmp       al,6
         jne       l_0A89
         call      l_01DE                   ; test ro®†dy
l_0A89:  ret

l_0A8A:  cmp       ch,3
         jb        l_0ABB
         jz        l_0AB3
         sahf                               ; jinak je prvn° tah - p©°mo
         jnz       l_0A7A                   ; nen° pr†zdnÇ pole - chyba
         mov       al,ds:[d_09B4]           ; pozice p©i pokusu o tah
         cmp       al,5Bh                                ; '['
         jae       l_0A9F
         cmp       al,1Dh
         jae       l_0AA4
l_0A9F:  or        byte ptr ds:[d_09D1],20h ; p©°znak posl. ©ady pà®†kem
l_0AA4:  call      l_0000                   ; uloëen° definice do z†sobn°ku tahñ
         inc       di
         dec       ch
         test      byte ptr ds:[d_09D0],8
         jz        l_0A58                   ; dal®° krok
         jnz       l_0A7A
l_0AB3:  sahf
         jnz       l_0A7A
l_0AB6:  call      l_0000                   ; uloëen° definice do z†sobn°ku tahñ
         jmp       short l_0A7A

l_0ABB:  sahf
         jz        l_0AD0
         mov       al,ds:[d_09B4]           ; pozice p©i pokusu o tah
         cmp       al,5Bh                                ; '['
         jae       l_0AC9
         cmp       al,1Dh
         jae       l_0AB6
l_0AC9:  or        byte ptr ds:[d_09D1],20h              ; ' '
         jmp       short l_0AB6

l_0AD0:  call      l_0492
         jmp       short l_0A7A

l_0A30   ENDP
  
         db        0
  
;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_0AD6   PROC      NEAR

         inc       bp
         xchg      ch,cl
         xchg      di,si
         mov       ax,0
         cmp       ch,0
         je        l_0AF5
         dec       ch
         cld       
l_0AE6:  scasw
         jz        l_0AE6
         dec       di
         dec       di
         mov       ax,ds:[di]
         mov       ds:[di],ah
         mov       byte ptr ds:[di+1],0
         add       al,al
l_0AF5:  ret

l_0AD6   ENDP

;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_0AF6   PROC      NEAR
                                               ;* pokus o tah danòm smàrem
                                                 ; VSTUP: CL=p©°rustek skoku
                                                 ; VùSTUP: AL=0 - pr†zdnÇ pole
                                                 ;         AL=1 - na soupe©e
                                                 ;         AL=2 - na vlastn°
                                                 ;         AL=3 - tah ven

         mov       bx,word ptr ds:[d_09B4]  ; pozice p©i pokusu o tah
         add       bl,cl                    ; zvò®en° pozice o tah
         mov       word ptr ds:[d_09B4],bx  ; nov† pozice p©i pokusu o tah
         mov       al,ds:[bx+d_00D1]        ; obsah novÇ pozice
         cmp       al,0FFh                  ; je zak†zan† oblast ?
         je        l_0B21                   ; je tah ven z ®achovnice
         mov       ds:[d_09D1],al           ; pñvodn° obsah na pol°áku
         and       al,7                     ; zru®en° p©°znaku barvy
         mov       ds:[d_09BC],al           ; ru®en† figurka
         jz        l_0B23                   ; pr†zdnÇ pol°áko
         mov       al,ds:[d_09D1]           ; pñvodn° obsah pol°áka
         xor       al,ds:[d_09D0]           ; test barvy figurky
         jns       l_0B1E                   ; stejn† barva - chyba
         mov       al,1                     ; skok na soupe©e - OK
         ret       

l_0B1E:  mov       al,2                     ; p©°znak - skok na vlastn°
         ret       

l_0B21:  mov       al,3                     ; p©°znak - tah je ven
l_0B23:  ret

l_0AF6   ENDP

;==========================================================================
;        hodnocen° jednoho stavu ®achovnice
;==========================================================================
  
l_0B24   PROC      NEAR

         mov       word ptr ds:[d_09C0],0
         mov       si,0
l_0B2D:  mov       bl,ds:[si+d_0179]        ; pozice kurzoru b°lÇho
         cmp       bl,0
         jne       l_0B39
         jmp       l_0BEE

l_0B39:  cmp       bl,0FFh
         jne       l_0B3F
         ret       

l_0B3F:  mov       bh,0
         mov       word ptr ds:[d_09B6],bx  ; testovan† pozice
         mov       al,ds:[bx+d_00D1]        ; vektor ®achovnice
         mov       ds:[d_09D0],al           ; testovan† figurka
         mov       ch,8                     ; poáet pokusñ
         mov       di,0                     
l_0B51:  mov       al,ds:[d_09B6]           ; testovan† pozice
         mov       ds:[d_09B4],al           ; pozice p©i pokusu o tah
         mov       byte ptr ds:[d_09B8],0
         mov       cl,ds:[di+d_009C]

l_0B60:  call      l_0AF6                   ; pokus o tah danòm smàrem
         cmp       al,0                     
         je        l_0B60                   ; je pr†zdnÇ pole - dal®°
         cmp       al,3                     
         je        l_0BE6                   ; tah ven
         cmp       al,2                     ; skok na vlastn°
         je        l_0B8E

         cmp       byte ptr ds:[d_09B8],0
         je        l_0BE6
         mov       al,ds:[d_09BC]           ; pñvodn° figurka
         cmp       al,5                     ; byla to d†ma ?
         je        l_0B9D                   ; byla to d†ma
         cmp       ch,5                     
         jb        l_0B88                   
         cmp       al,3                     ; byl to st©elece ?
         jne       l_0BE6                   ; nebyl to st©elec
         jz        l_0BD2                   ; byl to st©elec - OK

l_0B88:  cmp       al,4                     ; byla to vàë ?
         jne       l_0BE6                   ; nebyla to vàë
         jz        l_0BD2                   ; byla to vàë

l_0B8E:  cmp       byte ptr ds:[d_09B8],0
         jne       l_0BE6
         mov       al,ds:[d_09B4]           ; pozice p©i pokusu o tah
         mov       ds:[d_09B8],al
         jmp       short l_0B60

l_0B9D:  mov       al,ds:[d_09D0]           ; testovan† figurka
         and       al,7                     ; zru®en° barvy
         cmp       al,5                     ; byla to d†ma ?
         jne       l_0BD2                   ; nebyla to d†ma - dobrò tah
         push      cx
         push      di
         mov       al,0
         mov       cx,0Eh
         lea       di,ds:[d_0149]
         cld       
         rep       stosw
         mov       byte ptr ds:[d_09BA],7
         call      l_00F8                   ; test okol° figurky
         pop       di
         pop       cx
         mov       al,ds:[d_0149]
         sub       al,ds:[d_0157]
         test      byte ptr ds:[d_09D0],80h
         jz        l_0BCE
         neg       al
l_0BCE:  dec       al
         jns       l_0BE6
l_0BD2:  mov       bx,ds:[d_09C0]
         inc       bx
         mov       ds:[d_09C0],bx
         mov       ds:[bx+d_016F],cl
         mov       al,ds:[d_09B8]
         mov       ds:[bx+d_0165],al
l_0BE6:  inc       di
         dec       ch
         jz        l_0BEE
         jmp       l_0B51
l_0BEE:  inc       si
         jmp       l_0B2D

l_0B24   ENDP

;==========================================================================
;        Tah hr†áe
;==========================================================================
  
l_0BF2   PROC      NEAR

                                          ;* volba tahu hr†áe
         mov       al,42h                   ; "B" - áern†
         mov       ah,ds:[d_017A]           ; pozice kurzoru áernÇho
         cmp       byte ptr ds:[d_09CE],0   ; m† hr†á áernou ?
         je        l_0C05                   ; hr†á m† áernou
         mov       al,57h                   ; b°l† barva
         mov       ah,ds:[d_0179]           ; pozice kurzoru b°lÇho
l_0C05:  mov       ds:[d_10A2],al           ; znak barvy hr†áe "Delete"
         mov       ds:[d_10C7],al           ; znak barvy hr†áe "Insert"
         mov       ds:[d_09E6],ah           ; aktu†ln° pozice kurzoru
                                          ;* zvednut° figurky
l_0C0F:  mov       byte ptr ds:[d_09E7],1   ; p©°znak áek†n° na DEL
         call      l_027A                   ; vymaz†n° textovÇho ©†dku
         lea       dx,ds:[d_109B]           ; text "PICK UP ..."
         mov       ah,9                   
         int       21h                      ; zobrazen° textu "PICK UP..."
l_0C1F:  mov       bh,0                     ; BH <- 0
         mov       bl,ds:[d_09E6]           ; pozice kurzoru
         mov       dl,ds:[bx+d_00D1]        ; figurka na pozici kurzoru
         mov       dh,dl                    ; £schova figurky
         xor       dh,80h                   ; inverzn° figurka
         mov       ch,1                     ; poáet cyklñ = 1
         call      l_05E8                   ; obsluha kurzoru
         cmp       byte ptr ds:[d_09E7],1   ; áek† se na zvednut° ?
         je        l_0C1F                   ; áek†n° na zvednut° figurky
                                          ;* poloëen° figurky
         call      l_027A                   ; vymaz†n° textovÇho ©†dku
         lea       dx,ds:[d_10C0]           ; text "PLACE PIECE..."
         mov       ah,9                   
         int       21h                      ; zobrazen° textu "PLACE ..."
l_0C45:  mov       bh,0                     ; BH <- 0
         mov       bl,ds:[d_09E6]           ; pozice kurzoru
         mov       dl,ds:[bx+d_00D1]        ; figurka na pozici kurzoru
         mov       dh,ds:[d_09E8]           ; p©en†®en† figurka
         mov       ch,1                     ; poáet cyklñ = 1
         call      l_05E8                   ; obsluha kurzoru
         cmp       byte ptr ds:[d_09E7],2   ; áek† se na poloëen° ?
         je        l_0C45                   ; áek†n° na poloëen° figurky
                                          ;* test navr†cen° figurky
         mov       bh,0                     ; BH <- 0
         mov       bl,ds:[d_09E9]           ; vòchoz° pozice figurky
         mov       al,ds:[d_09E8]           ; p©en†®en† figurka
         mov       ds:[bx+d_00D1],al        ; navr†cen° figurky zpàt
         mov       dl,bl                    ; vòchoz° pozice p©en†®en°
         mov       dh,ds:[d_09EA]           ; nov† pozice figurky
         cmp       dl,dh                    ; je stejn† pozice ?
         je        l_0C0F                   ; figurka navr†cena - znovu
                                          ;* test spr†vnosti tahu
         call      l_0F48                   ; test spr†vnosti tahu
         jnc       l_0C96                   ; tah je OK - nov† pozice
         call      l_027A                   ; vymaz†n° textovÇho ©†dku
         lea       dx,ds:[d_1080]           ; text "INVALID MOVE"
         mov       ah,9                   
         int       21h                      ; zobrazen° textu "INVALID MOVE"
         mov       al,ds:[d_09E9]           ; vòchoz° pozice figurky
         mov       ds:[d_09E6],al           ; pozice kurzoru
         mov       dl,ds:[d_09E8]           ; p©en†®en† figurka
         call      l_0386                   ; zobrazen° pol°áka
         jmp       l_0C0F                   ; nov† volba tahu

                                          ;* zobrazen° novÇ pozice figurky
l_0C96:  mov       al,ds:[d_09EA]           ; nov† pozice figurky
         mov       bh,0                     ; BH <- 0
         mov       bl,al                    ; BX <- nov† pozice figurky
         mov       dl,ds:[bx+d_00D1]        ; vektor ®achovnice
         call      l_0386                   ; zobrazen° pol°áka
         call      l_052A                   ; volba tahu pro ro®†du
         ret

l_0BF2   ENDP

;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_0CA8   PROC      NEAR

         mov       al,0
         mov       ds:[d_09DE],al
         mov       ds:[d_09DA],al
         mov       ds:[d_09DB],al
         mov       ds:[d_09DC],al
         mov       ds:[d_09DD],al
         mov       ds:[d_09E1],al
         mov       byte ptr ds:[d_09BA],7
         mov       bx,15h
l_0CC4:  mov       word ptr ds:[d_09B6],bx
         mov       al,ds:[bx+d_00D1]        ; vektor ®achovnice
         cmp       al,0FFh
         jne       l_0CD3
         jmp       l_0D90
l_0CD3:  mov       cl,al
         mov       ds:[d_09D0],al
         and       al,7
         mov       ds:[d_09BE],al
         cmp       al,1
         jbe       l_0D1C
         cmp       al,4
         jb        l_0D0A
         cmp       al,6
         je        l_0CF2
         cmp       byte ptr ds:[d_09D4],7   ; á°taá tahñ
         jb        l_0D03
         jnc       l_0D03
l_0CF2:  test      cl,10h
         jz        l_0D03
         mov       al,6
         test      cl,80h
         jz        l_0D18
         neg       al
         jmp       short l_0D18
         nop
l_0D03:  test      cl,8
         jz        l_0D1C
         jnz       l_0D0F
l_0D0A:  test      cl,8
         jnz       l_0D1C
l_0D0F:  mov       al,2
         test      cl,80h
         jnz       l_0D18
         neg       al
l_0D18:  add       ds:[d_09DA],al
l_0D1C:  mov       al,0
         mov       cx,0Eh
         lea       di,ds:[d_0149]
         cld       
         rep       stosw
         call      l_00F8                   ; test okol° figurky
         mov       al,ds:[d_0149]
         sub       al,ds:[d_0157]
         add       ds:[d_09DA],al
         cmp       byte ptr ds:[d_09D0],0
         je        l_0D90
         call      l_0F9E
         cmp       dl,0
         je        l_0D81
         dec       dh
         mov       al,ds:[d_09D0]
         xor       al,ds:[d_09CF]
         js        l_0D6C
         cmp       dl,ds:[d_09DB]
         jb        l_0D81
         mov       ds:[d_09DB],dl
         mov       bx,ds:[d_09C4]
         mov       al,ds:[d_09B6]
         cmp       al,ds:[bx+3]
         jne       l_0D81
         mov       ds:[d_09E1],al
         jmp       short l_0D81
         nop

l_0D6C:  mov       al,dl
         cmp       al,ds:[d_09DC]
         jb        l_0D78
         xchg      al,ds:[d_09DC]
l_0D78:  cmp       al,ds:[d_09DD]
         jb        l_0D81
         mov       ds:[d_09DD],al
l_0D81:  mov       al,dh
         test      byte ptr ds:[d_09D0],80h
         jz        l_0D8C
         neg       al
l_0D8C:  add       ds:[d_09DE],al
l_0D90:  mov       bx,word ptr ds:[d_09B6]
         inc       bx
         cmp       bx,63h
         jae       l_0D9D
         jmp       l_0CC4
l_0D9D:  cmp       byte ptr ds:[d_09E1],0
         je        l_0DAF
         mov       al,ds:[d_09DD]
         mov       ds:[d_09DC],al
         mov       byte ptr ds:[d_09DD],0
l_0DAF:  mov       al,ds:[d_09DB]
         cmp       al,0
         je        l_0DB8
         dec       al
l_0DB8:  mov       ch,al
         mov       al,ds:[d_09DC]
         cmp       al,0
         je        l_0DCC
         mov       al,ds:[d_09DD]
         cmp       al,0
         je        l_0DCC
         dec       al
         shr       al,1
l_0DCC:  sub       al,ch
         test      byte ptr ds:[d_09CF],80h
         jz        l_0DD7
         neg       al
l_0DD7:  add       al,ds:[d_09DE]
         sub       al,ds:[d_09E0]
         mov       ch,1Eh                   ; max. hodnota = 30
         call      l_09A0                   ; omezen° á°sla AL na CH
         mov       dl,al
         mov       al,ds:[d_09DA]
         sub       al,ds:[d_09DF]
         cmp       byte ptr ds:[d_09E1],0
         je        l_0DF6
         mov       al,0
l_0DF6:  mov       ch,6                     ; max. hodnota = 6
         call      l_09A0                   ; omezen° á°sla AL na CH
         shl       dl,1
         shl       dl,1
         add       al,dl
         test      byte ptr ds:[d_09CF],80h
         jnz       l_0E0A
         neg       al
l_0E0A:  add       al,80h
         mov       ds:[d_09D9],al
         mov       bx,ds:[d_09C4]
         mov       [bx+5],al
         ret

l_0CA8   ENDP
  
         db        0
  
;==========================================================================
;        ;* zobrazen° á°sla dekadicky
;==========================================================================
  
l_0E18   PROC      NEAR

         push      cx
         push      dx
         mov       ch,al                    ; zobrazovanÇ á°slo
         mov       cl,64h                   ; dàlitel 100
         cmp       al,cl                    ; je á°slo > 100 ?
         jae       l_0E24                   ; á°slo je vàt®° neë 100
         mov       cl,0Ah                   ; dàlitel 10
l_0E24:  mov       ah,0                     ; AH <- 0
         mov       al,ch                    ; zobrazovanÇ á°slo
         div       cl                       ; vòpoáet nejvy®®° á°slice
         mov       ch,ah                    ; £schova mÇnà vòznamnÇ á°slice
         add       al,30h                   ; korekce prvn° á°sl. na ASCII
         mov       dl,al                    ; á°slice
         mov       ah,2                     
         int       21h                      ; zobrazen° á°slice des°tek
         mov       ah,0                     ; AH <- 0
         mov       al,cl                    ; á°seln° z†klad
         mov       cl,0Ah                   ; CL <- 10 dàlitel
         div       cl                       ; vòpoáet novÇho á°sel.dàlitele
         mov       cl,al                    ; novò á°selnò dàlitel
         cmp       al,0                     ; je jië dàlitel = 0 ?
         jne       l_0E24                   ; dàlitel nen° je®tà 0 - dal®°
         pop       dx
         pop       cx
         ret

l_0E18   ENDP
  
         db        0
  
;==========================================================================
;        ;* zobrazen° uplynulÇho áasu
;==========================================================================
  
l_0E46   PROC      NEAR

         mov       ah,2Ch
         int       21h                      ; poskytnut° systÇmovÇho áasu
         sub       dh,ds:[bx+1]             ; rozd°l v sekund†ch
         jns       l_0E54                   ; nen° p©ekroáen° sekund
         add       dh,3Ch                   ; p©etoáen° o 60 sekund
         dec       cl                       ; sn°ëen° £daje minut
l_0E54:  sub       cl,ds:[bx+2]             ; rozd°l v minut†ch
         jns       l_0E5E                   ; nen° p©ekroáen° minut
         add       cl,3Ch                   ; p©etoáen° o 60 sekund
         dec       ch                       ; sn°ëen° £daje o hodin†ch
l_0E5E:  sub       ch,ds:[bx+3]             ; rozd°l v hodin†ch
         jns       l_0E66                   ; nen° p©ekroáen° hodin
         add       ch,18h                   ; p©etoáen° hodin o 24
l_0E66:  mov       al,ch                    ; hodina
         call      l_0E18                   ; zobrazen° hodin
         mov       dl,3Ah                   ; oddàlovac° ':'
         mov       ah,2                     
         int       21h                      ; zobrazen° oddàlovaáe ":"
         mov       al,cl                    ; minuty
         call      l_0E18                   ; zobrazen° minut
         mov       dl,3Ah                   ; oddàlovaá ':'
         mov       ah,2                     
         int       21h                      ; zobrazen° oddàlovaáe ":"
         mov       al,dh                    ; sekundy
         call      l_0E18                   ; zobrazen° sekund
         mov       dl,20h                   ;' '
         mov       ah,2                     
         int       21h                      ; zobrazen° koncovÇ mezery
         ret

l_0E46   ENDP

;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_0E88   PROC      NEAR

         mov       cx,ds:[d_09C2]
         mov       di,0
l_0E8F:  mov       bx,cx
         mov       cx,[bx]
         mov       [bx],di
         cmp       cx,0
         jne       l_0E9B
         ret       

l_0E9B:  mov       ds:[d_09C4],cx
         call      l_050A
         mov       bx,ds:[d_09C2]
         mov       cx,ds:[d_09C4]
l_0EAA:  mov       di,ds:[bx]
         cmp       di,0
         je        l_0EB9
         mov       al,ds:[d_09D9]
         cmp       al,ds:[di+5]
         jae       l_0EBD
l_0EB9:  mov       ds:[bx],cx
         jmp       short l_0E8F
l_0EBD:  mov       bx,di
         jmp       short l_0EAA

l_0E88   ENDP
  
         db        0
  
;==========================================================================
;        n†vrat tahu z bufferu tahñ
;==========================================================================
  
l_0EC2   PROC      NEAR

         mov       si,ds:[d_09C4]           ; ukazatel v bufferu tahñ

l_0EC6:  mov       bh,0                     
         mov       dh,ds:[si+4]             ; pñvodn° obsah novÇho pole
         mov       bl,ds:[si+2]             ; vòchoz° pozice tahu
         mov       di,bx                    ; vòchoz° pozice tahu
         mov       bl,ds:[si+3]             ; c°lov† pozice tahu
         mov       si,bx                    ; c°lov† pozice tahu
         mov       dl,ds:[si+d_00D1]        ; figurka, s kterou se t†hlo
         mov       bl,dl                    ; figurka k t†hnut°
         rol       bl,1                     ; figurka * 2
         and       bx,1                     ; barva figurky
         nop
         test      dh,20h                   ; byla n†hrada pà®†ka d†mou ?
         jnz       l_0F1E                   ; byla n†hrada pà®†ka d†mou
         mov       al,dl                    ; figurka, kter† t†hla
         and       al,7                     ; zru®en° barvy
         cmp       al,5                     ; byla to d†ma ?
         je        l_0F26                   ; t†hla d†ma
         cmp       al,6                     ; t†hl kr†l ?
         je        l_0F2E                   ; t†hl kr†l
                                            
l_0EF2:  test      dh,10h
         jz        l_0EFA                   
         and       dl,0F7h                  
l_0EFA:  mov       ds:[di+d_00D1],dl        ; uloëen° pñvodn° figurky
         mov       al,dh                    ; pñvodn° figurka
         and       al,8Fh                   ; zru®en° p©°znakñ
         mov       ds:[si+d_00D1],al        ; n†vrat ru®enÇ figurky
         test      dh,40h                   ; bude dal®° tah ?
         jnz       l_0F3E                   ; n†vrat dal®°ho tahu
         mov       al,dh                    ; ru®en† figurka
         and       al,7                     ; zru®en° barvy
         cmp       al,5                     ; je to d†ma ?
         jne       l_0F1D                   ; nen° to d†ma
         mov       ax,si                    ; pozice d†my
         xor       bx,1                     
         nop
         mov       ds:[bx+d_017B],al        ; pñvodn° pozice d†my
l_0F1D:  ret

; ------ byla n†hrada pà®†ka d†mou - n†vrat pà®†ka

l_0F1E:  and       dl,0F8h                  ; zru®en° figurky
         or        dl,1                     ; n†hrada pà®†kem
         jmp       short l_0EF2

; ----- t†hla d†ma

l_0F26:  mov       ax,di                    ; pñvodn° pozice d†my
         mov       ds:[bx+d_017B],al        ; n†vrat pozice d†my
         jmp       short l_0EF2

; ----- t†hne kr†l

l_0F2E:  test      dh,40h
         jz        l_0F36
         and       dl,0EFh
l_0F36:  mov       ax,di
         mov       ds:[bx+d_0179],al        ; pozice kurzoru b°lÇho
         jmp       short l_0EF2

; ------ dal®° tah

l_0F3E:  mov       si,ds:[d_09C4]           ; ukazatel v bufferu tahñ
         add       si,6                     ; zvò®en° pozice v bufferu
         jmp       l_0EC6

l_0EC2   ENDP

;==========================================================================
;        Test spr†vnosti tahu
;==========================================================================
  
l_0F48   PROC      NEAR

                                          ;* test spr†vnosti tahu
         push      word ptr ds:[d_09C4]
         mov       al,ds:[d_09CE]           ; 80=hr†á m† b°lÇ, 00=áernÇ
         xor       al,80h                   ; zmàna p©°znaku barvy
         mov       ds:[d_09CF],al           ; poëadovan† barva poá°taáe

         lea       ax,ds:[d_018A]           ; zaá†tek tabulky tahñ
         sub       ax,2                     
         mov       ds:[d_09C2],ax           ; ukazatel v bufferu tahñ
         lea       ax,ds:[d_05B2]           
         mov       ds:[d_09CC],ax           ; ukazatel v z†sobn°ku tahñ
         push      dx                       
         call      l_08A2                   ; test, zda m† hr†á dal®° tah
         pop       dx                       
         lea       bx,ds:[d_05B2]           
l_0F6E:  cmp       dl,ds:[bx+2]             
         jne       l_0F78                   
         cmp       dh,ds:[bx+3]             
         je        l_0F81                   
l_0F78:  mov       bx,ds:[bx]               
         cmp       bx,0                     
         jne       l_0F6E                   
         jz        l_0F98                   
l_0F81:  mov       ds:[d_09C4],bx           
         call      l_09B4                   ; proveden° jednoho tahu

         mov       al,ds:[d_09CF]           ; barva poá°taáe
         call      l_08EC                   ; test okol° aktivn° figurky
         cmp       al,0                     
         jne       l_0F95                   

         pop       ax                       
         clc                                
         ret                                

l_0F95:  call      l_0EC2                   ; n†vrat tahu z bufferu tahñ
l_0F98:  pop       word ptr ds:[d_09C4]     
         stc                                ; p©°znak chyby - nepovolenò tah
         ret

l_0F48   ENDP

;==========================================================================
;                              SUBROUTINE
;==========================================================================
  
l_0F9E   PROC      NEAR

         lea       di,ds:[d_014B]
         lea       si,ds:[d_0159]
         mov       ch,ds:[d_0149]
         mov       cl,ds:[d_0157]
         test      byte ptr ds:[d_09D0],80h
         jz        l_0FB9
         xchg      di,si
         xchg      ch,cl
l_0FB9:  mov       bp,0
         mov       dl,0
         mov       bx,word ptr ds:[d_09BE]
         mov       dh,ds:[bx+d_00C2]
         shl       dh,1
         mov       bh,dh
         call      l_0AD6
         jz        l_0FFC
l_0FCF:  mov       bl,al
         call      l_0AD6
         jz        l_0FEA
         cmp       bh,bl
         jae       l_0FEA
l_0FDA:  cmp       al,bl
         jb        l_0FFC                            ;*
         call      l_0AD6
         jz        l_0FFC                            ;*
         mov       bl,al
         call      l_0AD6
         jnz       l_0FDA
l_0FEA:  test      bp,1
         jz        l_0FF2                            ;*
         neg       bh
l_0FF2:  add       dl,bh
         cmp       al,0
         je        l_0FFC
         mov       bh,bl
         jmp       short l_0FCF
l_0FFC:  ret

l_0F9E   ENDP

         db        0

Code     ENDS

;-------------------------------------------------------------- DATA  ----
  
Data     SEGMENT WORD PUBLIC
  
d_000E   db        0,0,23h,37h,10h,0        ; tabulka zah†jen° tahñ
         db        0,0,22h,36h,10h,0
         db        0,0,16h,2Bh,10h,0
         db        0,0,1Bh,2Eh,10h,0

d_0026   db        39 dup (20h),'$'         ; text pro vymaz†n°

d_004E   db        'CHECK $'

d_0055   db        'COMPUTER('
d_005E   db        'W): WORKING LEVEL '
d_0070   db        'X $'

d_0073   db        7,'COMPUTER('
d_007D   db        'W): $'

d_0082   db        'XX-'
d_0085   db        'XX $'

d_0089   db        'O-O $'
d_008E   db        'O-O-O $'
d_0095   db        'PxPep $'

                                          ;* moënÇ smàry figurek
d_009C   db        9,11,-11,-9              ; smàry ®ikmo
         db        10,-10,1,-1              ; smàry kolmo
         db        -21,-12,8,19             ; konàm vlevo
         db        21,12,-8,-19             ; konàm vpravo
         db        10,10,11,9               ; tahy b°lÇho pà®†ka
         db        -10,-10,-11,-9           ; tahy áernÇho pà®†ka

d_00B4   db        14h,10h,8,0,4,0,0        ; offset moënòch smàrñ figurek
d_00BB   db        4,4,8,4,4,8,8            ; poáet moënòch smàrñ figurek
d_00C2   db        0,1,3,3,5,9,10           ; bodov†n° figurek
d_00C9   db        4,2,3,5,6,3,2,4          ; inicial. rozm°stàn° figurek

                                          ;* mapa ®achovnice
d_00D1   db        21 dup (0)               ; spodn° okraj ®achovnice
d_00E6   db        10 dup (0)               ; ©†dek 1
d_00F0   db        10 dup (0)               ; ©†dek 2
d_00FA   db        10 dup (0)               ; ©†dek 3
d_0104   db        10 dup (0)               ; ©†dek 4
d_010E   db        10 dup (0)               ; ©†dek 5
d_0118   db        10 dup (0)               ; ©†dek 6
d_0122   db        10 dup (0)               ; ©†dek 7
d_012C   db        10 dup (0)               ; ©†dek 8
d_0136   db        19 dup (0)               ; horn° okraj ®achovnice

                                                 ;    0=pr†zdnÇ pol°áko
                                                 ;    1=pà®ec
                                                 ;    2=jezdec
                                                 ;    3=st©elec
                                                 ;    4=vàë
                                                 ;    5=d†ma
                                                 ;    6=kr†l
                                                 ;    0ffh=zak†zanÇ pol°áko
                                                 ; bit 7: 1=b°l† barva,0=áern†

d_0149   db        0,0                      ; tabulka poátu áernòch figurek
d_014B   db        12 dup (0)

d_0157   db        0,0                      ; tabulka poátu b°lòch figurek
d_0159   db        12 dup (0)

d_0165   db        10 dup (0)               ; tabulka pozic figurek
d_016F   db        10 dup (0)

d_0179   db        19h                      ; pozice kurzoru b°lÇho
d_017A   db        5Fh                      ; pozice kurzoru áernÇho
d_017B   db        18h                      ; pozice b°lÇ d†my
d_017C   db        5Eh                      ; pozice áernÇ d†my
         db        0FFh
d_017E   db        0
d_017F   db        0
         db        10 dup(0)
                                                 ; 0: bodov†n° tahu
                                                 ; 2: vòchoz° pozice tahu
                                                 ; 3: c°lov† pozice tahu
                                                 ; 4: pñvodn° obsah novÇho pole

d_018A   db        40 dup(0)                ; tabulka tahñ

d_01B2   db        1024 dup(0)

d_05B2   db        1016 dup (0)             ; tabulka tahñ

d_09AA   db        8 dup(0)

d_09B2   db        0,0
d_09B4   db        0,0                      ; pozice p©i pokusu o tah
d_09B6   db        0,0                      ; pracovn° pozice aktiv. hr†áe
d_09B8   db        0,0
d_09BA   db        0,0                      ; pracovn° figurka
d_09BC   db        0,0                      ; ru®en† figurka p©i skoku
d_09BE   db        0,0
d_09C0   dw        0
d_09C2   dw        18Ah                     ; ukazatel v z†sobn°ku tahñ
d_09C4   dw        0
d_09C6   dw        0
d_09C8   dw        0                        ; n†hodnà vybran† tabulka tahñ
d_09CA   dw        0
d_09CC   dw        1B2h                     ; ukazatel v z†sobn°ku tahñ
d_09CE   db        0                        ; 80=hr†á m† b°lÇ, 00=áernÇ
d_09CF   db        0                        ; barva poá°taáe (80=b°le)
d_09D0   db        0                        ; figurka p©i pracovn°m testu
d_09D1   db        0                        ; pñvod.obsah na novÇm pol°áku
                                                 ;  10h - je to 2. tah ro®†dy
                                                 ;  20h - n†hrada pà®†ka d†mou
                                                 ;  40h - je to 1. tah ro®†dy
d_09D2   db        0
d_09D3   db        0                        ; zbylò poáet tahñ
d_09D4   db        0                        ; á°taá tahñ
d_09D5   db        2                        ; £rove§ hry
d_09D6   db        0
d_09D7   db        0
d_09D8   db        0
d_09D9   db        0
d_09DA   db        0
d_09DB   db        0
d_09DC   db        0
d_09DD   db        0
d_09DE   db        0
d_09DF   db        0
d_09E0   db        0
d_09E1   db        0
d_09E2   dw        0
d_09E4   dw        0
d_09E6   db        0                        ; aktivn° pozice kurzoru
d_09E7   db        0                        ; p©°znak volby figurky
                                                 ;   0=figurka byla poloëena
                                                 ;   1=áek† se na uchopen°
                                                 ;   2=figurka je uchopena
d_09E8   db        0                        ; p©en†®en† aktivn° figurka
d_09E9   db        0                        ; vòchoz° pozice figurky
d_09EA   db        0,0                      ; nov† pozice figurky
d_09EC   dw        0
d_09EE   dw        0                        ; segment PSP

d_09F0   db        'CHESS88 V2.0 - A CHESS ' ; £vodn° text
         db        'PROGRAM FOR THE IBM '
         db        'PERSONAL COMPUTER BY '
         db        'DON BERG$',0

d_0A3A   db        'MATE - I WIN',7,7,7,'$' ; poá°taá vyhr†l

d_0A4A   db        'MATE IN '
d_0A52   db        'X MOVES$'               ; mat v X taz°ch

d_0A5A   db        'MATE - YOU WIN',7,7,'$' ; hr†á vyhr†l
         db        0

d_0A6C   db        0,0                      ; £schova £rovnà hry p©i tahu

                                          ;* tabulka k¢dñ ©°dic°ch kl†ves
d_0A6E   db        47h                      ; Home
         db        49h                      ; Page Up
         db        4fh                      ; End
         db        51h                      ; Page Down
         db        48h                      ; kurzor nahoru
         db        4bh                      ; kurzor vlevo
         db        4dh                      ; kurzor vpravo
         db        50h                      ; kurzor dolñ
         db        52h                      ; Insert
         db        53h                      ; Delete

                                          ;* adresy obsluh kl†ves
d_0A78   dw        l_07E6                   ; Home
         dw        l_07Ed                   ; Page Up
         dw        l_07F4                   ; End
         dw        l_07FB                   ; Page Down
         dw        l_0802                   ; kurzor nahoru
         dw        l_0811                   ; kurzor vlevo
         dw        l_0829                   ; kurzor vpravo
         dw        l_0841                   ; kurzor dolñ
         dw        l_0850                   ; Insert
         dw        l_0863                   ; Delete


d_0A8C   label     byte                     ; obr†zky figurek
                                                 ; (kaëd† zab°r† 78h bajtñ)
                                                 ; (st©°d† se pln†/obrysy)

                                          ; 1: pà®†k plnò
         db        0,0,0,0,0
         db        0,0,38h,0,0
         db        0,0,0feh,0,0
         db        0,1,0ffh,0,0
         db        0,3,0ffh,80h,0
         db        0,3,0ffh,80h,0
         db        0,1,0ffh,0,0
         db        0,0,0feh,0,0
         db        0,0,38h,0,0
         db        0,3,0ffh,80h,0
         db        0,0,44h,0,0
         db        0,0,38h,0,0
         db        0,0,38h,0,0
         db        0,0,38h,0,0
         db        0,0,38h,0,0
         db        0,0,7ch,0,0
         db        0,1,1,0,0
         db        0,3,0ffh,80h,0
         db        0,0fh,0ffh,0e0h,0
         db        0,10h,0,10h,0
         db        0,1fh,0ffh,0f0h,0
         db        0,3fh,0ffh,0f8h,0
         db        0,0,0,0,0
         db        0,0,0,0,0

                                            ; 1: pà®†k obrys
         db        0,0,0,0,0
         db        0,0,38h,0,0
         db        0,0,0c6h,0,0
         db        0,1,1,0,0
         db        0,2,0,80h,0
         db        0,2,0,80h,0
         db        0,1,1,0,0
         db        0,0,0c6h,0,0
         db        0,0,28h,0,0
         db        0,3,0ffh,80h,0
         db        0,0,44h,0,0
         db        0,0,44h,0,0
         db        0,0,44h,0,0
         db        0,0,44h,0,0
         db        0,0,44h,0,0
         db        0,0,82h,0,0
         db        0,3,0ffh,80h,0
         db        0,4,0,40h,0
         db        0,8,0,20h,0
         db        0,1fh,0ffh,0f0h,0
         db        0,20h,0,8,0
         db        0,3fh,0ffh,0f8h,0
         db        0,0,0,0,0
         db        0,0,0,0,0

                                            ; 2: jezdec plnò
         db        0,0,0,0,0
         db        0,1,3,0,0
         db        0,1,87h,0,0
         db        0,1,0ffh,80h,0
         db        0,3,0ffh,60h,0
         db        0,7,0ffh,70h,0
         db        0,0fh,0ffh,0b8h,0
         db        0,0fh,0bfh,0dch,0
         db        0,0fh,0ffh,0dch,0
         db        0,1fh,0fbh,0ech,0
         db        0,3fh,0f7h,0ech,0
         db        0,7fh,0f7h,0ech,0
         db        0,6fh,0cfh,0ech,0
         db        0,7ch,3fh,0f6h,0
         db        0,38h,7fh,0f6h,0
         db        0,0,0ffh,0f6h,0
         db        0,1,0ffh,0f6h,0
         db        0,1,0ffh,0fbh,0
         db        0,3,0ffh,0fbh,0
         db        0,7,0ffh,0fah,0
         db        0,0fh,0ffh,0fbh,0
         db        0,0fh,0ffh,0fbh,0
         db        0,0fh,0ffh,0fbh,0
         db        0,0,0,0,0

                                            ; 2: jezdec obrys
         db        0,0,0,0,0
         db        0,1,83h,0,0
         db        0,1,45h,0,0
         db        0,1,78h,80h,0
         db        0,2,0,0e0h,0
         db        0,4,0,0f0h,0
         db        0,8,0,78h,0
         db        0,8,40h,3ch,0
         db        0,8,0,3ch,0
         db        0,10h,4,1ch,0
         db        0,20h,8,1ch,0
         db        0,40h,30h,1ch,0
         db        0,53h,0e0h,1ch,0
         db        0,44h,20h,0eh,0
         db        0,38h,40h,0eh,0
         db        0,0,80h,0eh,0
         db        0,1,0,0eh,0
         db        0,1,0,7,0
         db        0,2,0,7,0
         db        0,4,0,6,0
         db        0,8,0,7,0
         db        0,8,0,7,0
         db        0,0fh,0ffh,0ffh,0
         db        0,0,0,0,0

                                            ; 3: st©elec plnò
         db        0,0,0,0,0
         db        0,0,10h,0,0
         db        0,0,7ch,0,0
         db        0,0,0feh,0,0
         db        0,1,0ffh,0,0
         db        0,3,0efh,80h,0
         db        0,7,0efh,0c0h,0
         db        0,7,0efh,0c0h,0
         db        0,0fh,0efh,0e0h,0
         db        0,0eh,0,0e0h,0
         db        0,0fh,0efh,0e0h,0
         db        0,7,0efh,0c0h,0
         db        0,7,0efh,0c0h,0
         db        0,3,0efh,80h,0
         db        0,3,0ffh,80h,0
         db        0,1,0ffh,0,0
         db        0,1,0ffh,0,0
         db        0,0,82h,0,0
         db        0,0,82h,0,0
         db        0,0fch,82h,7eh,0
         db        3,0ffh,0efh,0ffh,80h
         db        7,8fh,0efh,0e3h,0c0h
         db        3,0,0,1,80h
         db        0,0,0,0,0

                                            ; 3: st©elec obrys
         db        0,0,0,0,0
         db        0,0,10h,0,0
         db        0,0,6ch,0,0
         db        0,0,82h,0,0
         db        0,1,1,0,0
         db        0,2,10h,80h,0
         db        0,4,10h,40h,0
         db        0,4,10h,40h,0
         db        0,8,10h,20h,0
         db        0,9,0ffh,20h,0
         db        0,8,10h,20h,0
         db        0,4,10h,40h,0
         db        0,4,10h,40h,0
         db        0,2,10h,80h,0
         db        0,2,0,80h,0
         db        0,1,1,0,0
         db        0,1,1,0,0
         db        0,0,0feh,0,0
         db        0,0,0feh,0,0
         db        0,0fch,0feh,7eh,0
         db        3,0ffh,0efh,0ffh,80h
         db        7,8fh,0efh,0e3h,0c0h
         db        3,0,0,1,80h
         db        0,0,0,0,0

                                            ; 4: vàë pln†
         db        0,0,0,0,0
         db        0,78h,7ch,3ch,0
         db        0,78h,7ch,3ch,0
         db        0,78h,7ch,3ch,0
         db        0,7fh,0ffh,0fch,0
         db        0,7fh,0ffh,0fch,0
         db        0,40h,0,8,0
         db        0,1fh,0ffh,0f0h,0
         db        0,8,0,20h,0
         db        0,7,0ffh,0c0h,0
         db        0,7,0ffh,0c0h,0
         db        0,7,0ffh,0c0h,0
         db        0,7,0ffh,0c0h,0
         db        0,7,0ffh,0c0h,0
         db        0,7,0ffh,0c0h,0
         db        0,7,0ffh,0c0h,0
         db        0,7,0ffh,0c0h,0
         db        0,4,0,40h,0
         db        0,0fh,0ffh,0e0h,0
         db        0,1fh,0ffh,0f0h,0
         db        0,20h,0,8,0
         db        0,3fh,0ffh,0f8h,0
         db        0,3fh,0ffh,0f8h,0
         db        0,0,0,0,0

                                            ; 4: vàë obrys
         db        0,0,0,0,0
         db        0,78h,7ch,3ch,0
         db        0,48h,44h,24h,0
         db        0,48h,44h,24h,0
         db        0,4fh,0c7h,0e4h,0
         db        0,40h,0,4,0
         db        0,3fh,0ffh,0f8h,0
         db        0,10h,0,10h,0
         db        0,0fh,0ffh,0e0h,0
         db        0,4,0,40h,0
         db        0,4,0,40h,0
         db        0,4,0,40h,0
         db        0,4,0,40h,0
         db        0,4,0,40h,0
         db        0,4,0,40h,0
         db        0,4,0,40h,0
         db        0,4,0,40h,0
         db        0,7,0ffh,0c0h,0
         db        0,8,0,20h,0
         db        0,10h,0,10h,0
         db        0,3fh,0ffh,0f8h,0
         db        0,20h,0,8,0
         db        0,3fh,0ffh,0f8h,0
         db        0,0,0,0,0

                                            ; 5: d†ma pln†
         db        0,0,0,0,0
         db        0,1,1,0,0
         db        0,3,83h,80h,0
         db        1,1,1,1,0
         db        3,81h,1,3,80h
         db        1,3,83h,81h,0
         db        1,3,83h,81h,0
         db        1,87h,0c7h,0c3h,0
         db        1,0c7h,0c7h,0c7h,0
         db        1,0efh,0efh,0efh,0
         db        1,0ffh,0ffh,0ffh,0
         db        0,0ffh,0ffh,0feh,0
         db        0,80h,0,2,0
         db        0,0ffh,0ffh,0feh,0
         db        0,7bh,0efh,0bch,0
         db        0,71h,0c7h,1ch,0
         db        0,7bh,0efh,0bch,0
         db        0,3fh,0ffh,0f8h,0
         db        0,20h,0,8,0
         db        0,1fh,0ffh,0f0h,0
         db        0,0fh,0ffh,0e0h,0
         db        0,7,0ffh,0c0h,0
         db        0,0,0,0,0
         db        0,0,0,0,0

                                            ; 5: d†ma obrys
         db        0,0,0,0,0
         db        0,1,1,0,0
         db        0,3,83h,80h,0
         db        1,1,1,1,0
         db        3,81h,1,3,80h
         db        1,2,82h,81h,0
         db        1,2,82h,81h,0
         db        1,84h,44h,43h,0
         db        1,44h,44h,45h,0
         db        1,28h,28h,29h,0
         db        1,18h,38h,31h,0
         db        0,80h,0,2,0
         db        0,0ffh,0ffh,0feh,0
         db        0,80h,0,2,0
         db        0,44h,10h,44h,0
         db        0,4eh,38h,0e4h,0
         db        0,44h,10h,44h,0
         db        0,20h,0,8,0
         db        0,3fh,0ffh,0f8h,0
         db        0,10h,0,10h,0
         db        0,8,0,20h,0
         db        0,7,0ffh,0c0h,0
         db        0,0,0,0,0
         db        0,0,0,0,0

                                            ; 6: kr†l plnò
         db        0,0,0,0,0
         db        0,0,38h,0,0
         db        0,0,38h,0,0
         db        0,0,38h,0,0
         db        0,1,0ffh,0,0
         db        0,71h,0ffh,1ch,0
         db        0,0fdh,0ffh,7eh,0
         db        1,0feh,38h,0ffh,0
         db        1,0ffh,39h,0ffh,0
         db        3,0ffh,0bbh,0ffh,80h
         db        3,0ffh,83h,0ffh,80h
         db        3,0f7h,0c7h,0dfh,80h
         db        1,0f7h,0c7h,0dfh,0
         db        1,0c1h,0c7h,7,0
         db        0,0f7h,0ffh,0deh,0
         db        0,77h,0ffh,0dch,0
         db        0,7fh,0ffh,0fch,0
         db        0,20h,0,8,0
         db        0,3fh,0ffh,0f8h,0
         db        0,10h,0,10h,0
         db        0,1fh,0ffh,0f0h,0
         db        0,0fh,0ffh,0e0h,0
         db        0,0,0,0,0
         db        0,0,0,0,0

                                            ; 6: kr†l obrys
         db        0,0,0,0,0
         db        0,0,38h,0,0
         db        0,0,28h,0,0
         db        0,0,28h,0,0
         db        0,1,0efh,0,0
         db        0,71h,1,1ch,0
         db        0,8dh,0efh,62h,0
         db        1,2,28h,81h,0
         db        1,1,29h,1,0
         db        2,0,0bah,0,80h
         db        2,0,82h,0,80h
         db        2,8,44h,20h,80h
         db        1,8,44h,21h,0
         db        1,3eh,44h,0f9h,0
         db        0,88h,38h,22h,0
         db        0,48h,0,24h,0
         db        0,40h,0,4,0
         db        0,3fh,0ffh,0f8h,0
         db        0,20h,0,8,0
         db        0,1fh,0ffh,0f0h,0
         db        0,10h,0,10h,0
         db        0,0fh,0ffh,0e0h,0
         db        0,0,0,0,0
         db        0,0,0,0,0

d_102C   db        0Dh,0Ah,'WHICH COLOR DO YOU SELECT (W/B)? $'

d_1050   db        0Dh,0Ah,'WHICH LOOK AHEAD LEVEL DO YOU SELECT (1-6)? $'
         db        0

d_1080   db        'INVALID MOVE - TRY AGAIN ',7,'$'

d_109B   db        'PLAYER('
d_10A2   db        'B): PICK UP PIECE USING "DEL"$'

d_10C0   db        'PLAYER('
d_10C7   db        'B): PLACE PIECE USING "INS"$'

         db        13 dup (0)
  
Data     ENDS

;--------------------------------------------------------- stack_seg_c  ---
  
Zasob    SEGMENT   STACK

         db        64 dup('STACK   ')
  
Zasob    ENDS
  
         END       Start
