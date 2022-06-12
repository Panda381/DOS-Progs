; ---------------- GET - zad n¡ parametru povelov‚ho souboru ------------------
code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h
get:                                      ;* nalezen¡ otcovsk‚ho prost©ed¡
         mov       es,ds:[10h]              ; segment s otcovsk˜m programem
         mov       dx,es:[2ch]              ; segment otcovsk‚ho prost©ed¡
         dec       dx                       ; popisova‡ alok. bloku prost©ed¡
         mov       es,dx                    ; popisova‡ alok. bloku prost©ed¡
         mov       bx,es:[3]                ; velikost aloka‡n¡ho bloku
         mov       cl,4
         shl       bx,cl                    ; velikost alok. bloku v bajtech
         mov       ax,es:[1]                ; vlastn¡k aloka‡n¡ho bloku
         inc       dx                       ; n vrat za‡ tku prost©ed¡
         mov       es,dx                    ; za‡ tek prost©ed¡ otcovsk‚ho prog.
         cmp       ax,ds:[10h]              ; je spr vn˜ vlastn¡k alok. bloku ?
         je        get1                     ; je spr vn˜ vlastn¡k bloku
chyba:   mov       ax,4c01h                 ; chyba operace
         int       21h                      ; nen¡ spr vn˜ vlastn¡k - konec
                                          ;* nalezen¡ identifik toru "GET="
get1:    xor       di,di                    ; za‡ tek prost©ed¡
get2:    cmp       byte ptr es:[di],0       ; je konec ©etˆzc– prost©ed¡ ?
         je        get5                     ; text nenalezen - nov‚ zad n¡
         push      di                       ; za‡ tek testovan‚ho ©etˆzce
         lea       si,[textget]             ; identifika‡n¡ text
         mov       cx,4                     ; d‚lka identifika‡n¡ho textu
         repe      cmpsb                    ; porovn n¡ za‡ tku ©etˆzce
         pop       di                       ; za‡ tek testovan‚ho ©etˆzce
         pushf                              ; £schova p©¡znaku shody ©etˆzc–
         mov       si,di                    ; mezi£schova za‡ tku ©etˆzce
         mov       cx,bx                    ; max. d‚lka pro hled n¡
         xor       al,al                    ; hledan˜ bajt 0
         repne     scasb                    ; nalezen¡ konce ©etˆzce
         popf                               ; n vrat p©¡znaku shody ©etˆzc–
         jne       get2                     ; nenalezen - test dal¨¡ho ©etˆzce
get4:                                     ;* vypu¨tˆn¡ ©etˆzce "GET=..."
         push      es                       ; segment otcovsk‚ho prost©ed¡
         pop       ds                       ; DS <- segment otcovsk‚ho prost©ed¡
         xchg      si,di                    ; SI=p–vodn¡ adresa, DI=nov  adresa
         mov       cx,bx                    ; d‚lka bloku prost©ed¡
         sub       cx,si                    ; d‚lka textu k p©esunu
         rep       movsb                    ; vypu¨tˆn¡ textu "GET=..."
get5:                                     ;* nalezen¡ konce ©etˆzc– prost©ed¡
         xor       di,di                    ; za‡ tek prost©ed¡
         xor       ax,ax                    ; hledan‚ slovo 0
get6:    scasw                              ; je konec ©etˆzc– prost©ed¡ ?
         pushf
         dec       di                       ; n vrat ukazatele o 1 zpˆt
         popf
         jne       get6                     ; nalezen¡ konce ©etˆzc– prost©ed¡
                                          ;* nastaven¡ maxim ln¡ d‚lky textu
         push      cs
         pop       ds                       ; DS <- CS
         sub       bx,di                    ; voln˜ prostor v prost©ed¡
         sub       bx,5                     ; ode‡ten¡ d‚lky pro GET= a 0 + 1
         jbe       chyba                    ; je mal˜ prostor v prost©ed¡
         cmp       bx,123                   ; je vˆt¨¡ ne‘ maxim ln¡ d‚lka ?
         jbe       get7                     ; d‚lka je povolen 
         mov       bl,123                   ; omezen¡ maxim ln¡ d‚lky © dku
get7:    mov       ds:[textbf],bl           ; nastaven¡ velikosti bufferu
                                          ;* zobrazen¡ v˜zvy k zad n¡ textu
         mov       si,82h                   ; za‡ tek textu
         mov       dx,si                    ; text k zobrazen¡
         xor       bx,bx                    ; CX <- 0
         mov       bl,ds:[si-2]             ; d‚lka zadan‚ho textu
         mov       word ptr ds:[si+bx-1],"$"; ozna‡en¡ konce textu
         or        bx,bx
         jnz       get8                     ; je zadan˜ nˆjak˜ znak
         lea       dx,[texthlp]             ; text n povˆdy
get8:    mov       ah,9
         int       21h                      ; zobrazen¡ textu
                                          ;* zad n¡ nov‚ho textu "GET=..."
         mov       ah,10
         lea       dx,[textbf]              ; buffer pro zad n¡ textu
         int       21h                      ; zad n¡ textu z kl vesnice
         mov       dl,10                    ; znak <LF>
         mov       ah,2
         int       21h                      ; posun na dal¨¡ © dek
                                          ;* ulo‘en¡ zadan‚ho textu do prost©ed¡
         xor       cx,cx                    ; CX <- 0
         mov       cl,[textbf+1]            ; po‡et znak– zadan‚ho textu
         jcxz      get9                     ; nen¡ zadan˜ ‘ dn˜ text - konec
         lea       si,[textget]             ; identifika‡n¡ text "GET="
         movsw                              ; p©enos znak– "GE"
         movsw                              ; p©enos znak– "T="
         lea       si,[textbf+2]            ; zadan˜ text
         rep       movsb                    ; p©enos textu do prost©ed¡
         xor       ax,ax                    ; ozna‡en¡ konce prost©ed¡ 0
         stosw                              ; ulo‘en¡ ozna‡en¡ konce prost©ed¡
get9:    mov       ax,4c00h
         int       21h                      ; ukon‡en¡ programu

textget  db        'GET='
textbf   db        127,0                    ; za‡ tek bufferu pro zad n¡ textu
texthlp  db        'Priklad: GET Zadejte cilovy adresar: ',13,10
         db        '         INSTALL *.exe %GET%',13,10,'$'

code     ENDS
         END       get
