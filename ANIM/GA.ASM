
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;
;                                G A P A
;                         Grafick� Anima뇆� ProgrAm
;
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�


Code     SEGMENT
         ASSUME    cs:Code,ds:Data

Start:











         mov       ax,4c00h
         int       21h



; -----------------------------------------------------------------------------

Zahlavi  label     byte                   ;* z쟦lav� souboru

; ------ povinn� 뇿st z쟦lav� souboru

Ident    db        'SCR'                    ; 0: identifikace souboru
Param    db        0                        ; 3: parametry
                                            ;     bit 0: 1=komprese souboru
                                            ;     bit 1: 1=vektorov� definice
                                            ;     bit 2: 1=je maska obr쟺k�
                                            ;            (jen bodov� definice)

DelZahl  db        0                        ; 4: d굃ka z쟦lav� v odstavc죅h 16 B
                                            ;     (16 B a� 4080 B)
VMod     db        0                        ; 5: videom줰

Rovin    db        0                        ; po놽t barevn쁟h rovin
BitPoint db        0                        ; po놽t bit� na bod

FirstPic dw        0                        ; 눀slo prvn죋o obr쟺ku (znaku)

NumPic   dw        0                        ;   po놽t obr쟺k� (znak�)
Palet    dw        0                        ; po놽t slov definice palet

; ------ tabulka adres obr쟺k� (offset 16) (adresy po dekompresi)

                                          ;* tabulka adres jednotliv쁟h obr쟺k�
AdrPic   label     word

; ------ nepovinn� 뇿st - tabulka palet (n쟳leduje ihned za tabulkou adres)

TabPal   label     word                   ;* tabulka definic palet


; ------ definice jednoho obr쟺ku pro bodovou definici

Sirka    dw        0                        ; Æ쯭a (bod�)
Vyska    dw        0                        ; v삩ka (linek)
                                          ;* n쟳leduje pæpadn� maska a definice
                                          ;* barevn쁟h rovin

; ------ definice obr쟺ku pro vektorovou definici





KonHl    label     byte                     ; konec z쟦lav�




Code     ENDS


Data     SEGMENT


Konfig   label     byte                     ; konfigura뇆� tabulka

VideoMod db        -1                       ; videom줰 (-1 = automatick�)





Data     ENDS


; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;
;                           Z쟳obn죏
;
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

StackS   SEGMENT   Stack

         dw        512 dup(?);

StackS   ENDS


; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;
;                         Datov� buffer
;
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

DataS    SEGMENT   Stack

DataS    ENDS

         END       Start
