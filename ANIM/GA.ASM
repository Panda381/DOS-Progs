
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                                G A P A
;                         Grafick˜ Anima‡n¡ ProgrAm
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


Code     SEGMENT
         ASSUME    cs:Code,ds:Data

Start:











         mov       ax,4c00h
         int       21h



; -----------------------------------------------------------------------------

Zahlavi  label     byte                   ;* z hlav¡ souboru

; ------ povinn  ‡ st z hlav¡ souboru

Ident    db        'SCR'                    ; 0: identifikace souboru
Param    db        0                        ; 3: parametry
                                            ;     bit 0: 1=komprese souboru
                                            ;     bit 1: 1=vektorov  definice
                                            ;     bit 2: 1=je maska obr zk–
                                            ;            (jen bodov  definice)

DelZahl  db        0                        ; 4: d‚lka z hlav¡ v odstavc¡ch 16 B
                                            ;     (16 B a‘ 4080 B)
VMod     db        0                        ; 5: videom¢d

Rovin    db        0                        ; po‡et barevn˜ch rovin
BitPoint db        0                        ; po‡et bit– na bod

FirstPic dw        0                        ; ‡¡slo prvn¡ho obr zku (znaku)

NumPic   dw        0                        ;   po‡et obr zk– (znak–)
Palet    dw        0                        ; po‡et slov definice palet

; ------ tabulka adres obr zk– (offset 16) (adresy po dekompresi)

                                          ;* tabulka adres jednotliv˜ch obr zk–
AdrPic   label     word

; ------ nepovinn  ‡ st - tabulka palet (n sleduje ihned za tabulkou adres)

TabPal   label     word                   ;* tabulka definic palet


; ------ definice jednoho obr zku pro bodovou definici

Sirka    dw        0                        ; ¨¡©ka (bod–)
Vyska    dw        0                        ; v˜¨ka (linek)
                                          ;* n sleduje p©¡padn  maska a definice
                                          ;* barevn˜ch rovin

; ------ definice obr zku pro vektorovou definici





KonHl    label     byte                     ; konec z hlav¡




Code     ENDS


Data     SEGMENT


Konfig   label     byte                     ; konfigura‡n¡ tabulka

VideoMod db        -1                       ; videom¢d (-1 = automatick˜)





Data     ENDS


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                           Z sobn¡k
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

StackS   SEGMENT   Stack

         dw        512 dup(?);

StackS   ENDS


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                         Datov˜ buffer
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

DataS    SEGMENT   Stack

DataS    ENDS

         END       Start
