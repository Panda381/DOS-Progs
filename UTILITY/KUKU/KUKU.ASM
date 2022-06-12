
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:

         mov       ah,2ah
         int       21h
         mov       ah,7
         mul       ah
         add       ax,offset Dny
         xchg      ax,si
         mov       di,offset Text1+1
         xchg      ax,cx
         mov       cx,7
         cld
         rep       movsb
         mov       di,offset Text2+10
         call      DekNum
         mov       di,offset Text2+5
         mov       al,dh
         call      DekNum0
         mov       di,offset Text2+2
         mov       al,dl
         call      DekNum0

         mov       ah,2ch
         int       21h
         mov       di,offset Text3+8
         mov       al,dh
         call      DekNum0
         mov       di,offset Text3+5
         mov       al,cl
         call      DekNum0
         mov       di,offset Text3+2
         mov       al,ch
         call      DekNum0

         mov       dx,offset Text
         mov       ah,9
         int       21h

         xor       ax,ax
         mov       es,ax
         mov       ax,es:[46ch]
         mov       dx,es:[46ch+2]
         add       ax,2731                  ; posun o 5/2 minut
         adc       dx,0
         mov       cx,5462                  ; po‡et impuls– na 5 minut
         div       cx                       ; v˜po‡et £seku 5 minut
         xchg      ax,cx

         mov       si,offset Hlaseni
         jcxz      Start4

         cld
Start3:  lodsb
         cmp       al,"$"
         jne       Start3
         loop      Start3

Start4:  mov       dx,si
         mov       ah,9
         int       21h

         mov       dx,offset Tecka
         mov       ah,9
         int       21h

         int       20h

DekNum0: mov       ah,0

DekNum:  push      dx
         push      cx
DekNum1: xor       dx,dx
         mov       cx,10
         div       cx
         add       dl,"0"
         mov       ds:[di],dl
         dec       di
         or        ax,ax
         jnz       DekNum1
         pop       cx
         pop       dx
         ret

Text     db        13,10
         db        '              /--\',13,10
         db        '            <  o  \  ___',13,10
         db        'ÚÄÄÄÄÄÄÄÄÄÄ¿  \          \--',13,10
Text1    db        '³          ³    \     )   _/',13,10
Text2    db        '³00.00.0000³      - \  \',13,10
Text3    db        '³00:00:00  ³        /  /',13,10
         db        'ÀÄÄÄÄÄÄÄÄÄÄÙ        A  A',13,10
         db        13,10
         db        'KU - KU !   $'

Tecka    db        '.',13,10,'$'

dny      db        'nedˆle '
         db        'pondˆl¡'
         db        '£ter˜  '
         db        'st©eda '
         db        '‡tvrtek'
         db        'p tek  '
         db        'sobota '

Hlaseni  db        'Je pr vˆ p–lnoc$'
         db        'Pr vˆ odbila p–lnoc$'

; ------ 1

         db        'Bude za chv¡li ‡tvrt na jednu r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na jednu r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na jednu r no$'

         db        'Bude za chv¡li p–l jedn‚ r no$'
         db        'Je p©esnˆ p–l jedn‚ r no$'
         db        'Je p–l jedn‚ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na jednu r no$'
         db        'Je t©i‡tvrtˆ na jednu r no$'
         db        'Je t©i‡tvrtˆ na jednu r no pry‡$'

         db        'Bude za chv¡li jedna hodina r no$'
         db        'Je pr vˆ jedna hodina r no$'
         db        'Byla jedna hodina r no$'

; ------ 2

         db        'Bude za chv¡li ‡tvrt na dvˆ r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na dvˆ r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na dvˆ r no$'

         db        'Bude za chv¡li p–l druh‚ r no$'
         db        'Je p©esnˆ p–l druh‚ r no$'
         db        'Je p–l druh‚ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na dvˆ r no$'
         db        'Je t©i‡tvrtˆ na dvˆ r no$'
         db        'Je t©i‡tvrtˆ na dvˆ r no pry‡$'

         db        'Budou za chv¡li dvˆ hodiny r no$'
         db        'Jsou pr vˆ dvˆ hodiny r no$'
         db        'Byly dvˆ hodiny r no$'

; ------ 3

         db        'Bude za chv¡li ‡tvrt na t©i r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na t©i r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na t©i r no$'

         db        'Bude za chv¡li p–l t©et¡ r no$'
         db        'Je p©esnˆ p–l t©et¡ r no$'
         db        'Je p–l t©et¡ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na t©i r no$'
         db        'Je t©i‡tvrtˆ na t©i r no$'
         db        'Je t©i‡tvrtˆ na t©i r no pry‡$'

         db        'Budou za chv¡li t©i hodiny r no$'
         db        'Jsou pr vˆ t©i hodiny r no$'
         db        'Jsou t©i hodiny r no pry‡$'

; ------ 4

         db        'Bude za chv¡li ‡tvrt na ‡ty©i r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na ‡ty©i r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na ‡ty©i r no$'

         db        'Bude za chv¡li p–l ‡tvrt‚ r no$'
         db        'Je p©esnˆ p–l ‡tvrt‚ r no$'
         db        'Je p–l ‡tvrt‚ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na ‡ty©i r no$'
         db        'Je t©i‡tvrtˆ na ‡ty©i r no$'
         db        'Je t©i‡tvrtˆ na ‡ty©i r no pry‡$'

         db        'Budou za chv¡li ‡ty©i hodiny r no$'
         db        'Jsou pr vˆ ‡ty©i hodiny r no$'
         db        'Jsou ‡ty©i hodiny r no pry‡$'

; ------ 5

         db        'Bude za chv¡li ‡tvrt na pˆt r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na pˆt r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na pˆt r no$'

         db        'Bude za chv¡li p–l p t‚ r no$'
         db        'Je p©esnˆ p–l p t‚ r no$'
         db        'Je p–l p t‚ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na pˆt r no$'
         db        'Je t©i‡tvrtˆ na pˆt r no$'
         db        'Je t©i‡tvrtˆ na pˆt r no pry‡$'

         db        'Bude za chv¡li pˆt hodin r no$'
         db        'Je pr vˆ pˆt hodin r no$'
         db        'Je pˆt hodin r no pry‡$'

; ------ 6

         db        'Bude za chv¡li ‡tvrt na ¨est r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na ¨est r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na ¨est r no$'

         db        'Bude za chv¡li p–l ¨est‚ r no$'
         db        'Je p©esnˆ p–l ¨est‚ r no$'
         db        'Je p–l ¨est‚ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na ¨est r no$'
         db        'Je t©i‡tvrtˆ na ¨est r no$'
         db        'Je t©i‡tvrtˆ na ¨est r no pry‡$'

         db        'Bude za chv¡li ¨est hodin r no$'
         db        'Je pr vˆ ¨est hodin r no$'
         db        'Je ¨est hodin r no pry‡$'

; ------ 7

         db        'Bude za chv¡li ‡tvrt na sedum r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na sedum r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na sedum r no$'

         db        'Bude za chv¡li p–l sedm‚ r no$'
         db        'Je p©esnˆ p–l sedm‚ r no$'
         db        'Je p–l sedm‚ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na sedum r no$'
         db        'Je t©i‡tvrtˆ na sedum r no$'
         db        'Je t©i‡tvrtˆ na sedum r no pry‡$'

         db        'Bude za chv¡li sedum hodin r no$'
         db        'Je pr vˆ sedum hodin r no$'
         db        'Je sedum hodin r no pry‡$'

; ------ 8

         db        'Bude za chv¡li ‡tvrt na osum r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na osum r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na osum r no$'

         db        'Bude za chv¡li p–l osm‚ r no$'
         db        'Je p©esnˆ p–l osm‚ r no$'
         db        'Je p–l osm‚ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na osum r no$'
         db        'Je t©i‡tvrtˆ na osum r no$'
         db        'Je t©i‡tvrtˆ na osum r no pry‡$'

         db        'Bude za chv¡li osum hodin r no$'
         db        'Je pr vˆ osum hodin r no$'
         db        'Je osum hodin r no pry‡$'

; ------ 9

         db        'Bude za chv¡li ‡tvrt na devˆt r no$'
         db        'Teƒ je p©esnˆ ‡tvrt na devˆt r no$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na devˆt r no$'

         db        'Bude za chv¡li p–l dev t‚ r no$'
         db        'Je p©esnˆ p–l dev t‚ r no$'
         db        'Je p–l dev t‚ r no pry‡$'

         db        'Bude t©i‡tvrtˆ na devˆt r no$'
         db        'Je t©i‡tvrtˆ na devˆt r no$'
         db        'Je t©i‡tvrtˆ na devˆt r no pry‡$'

         db        'Bude za chv¡li devˆt hodin r no$'
         db        'Je pr vˆ devˆt hodin r no$'
         db        'Je devˆt hodin r no pry‡$'

; ------ 10

         db        'Bude za chv¡li ‡tvrt na deset dopoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na deset dopoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na deset dopoledne$'

         db        'Bude za chv¡li p–l des t‚ dopoledne$'
         db        'Je p©esnˆ p–l des t‚ dopoledne$'
         db        'Je p–l des t‚ dopoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na deset dopoledne$'
         db        'Je t©i‡tvrtˆ na deset dopoledne$'
         db        'Je t©i‡tvrtˆ na deset dopoledne pry‡$'

         db        'Bude za chv¡li deset hodin dopoledne$'
         db        'Je pr vˆ deset hodin dopoledne$'
         db        'Je deset hodin dopoledne pry‡$'

; ------ 11

         db        'Bude za chv¡li ‡tvrt na jeden ct dopoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na jeden ct dopoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na jeden ct dopoledne$'

         db        'Bude za chv¡li p–l jeden ct‚ dopoledne$'
         db        'Je p©esnˆ p–l jeden ct‚ dopoledne$'
         db        'Je p–l jeden ct‚ dopoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na jeden ct dopoledne$'
         db        'Je t©i‡tvrtˆ na jeden ct dopoledne$'
         db        'Je t©i‡tvrtˆ na jeden ct dopoledne pry‡$'

         db        'Bude za chv¡li jeden ct hodin dopoledne$'
         db        'Je pr vˆ jeden ct hodin dopoledne$'
         db        'Je jeden ct hodin dopoledne pry‡$'

; ------ 12

         db        'Bude za chv¡li ‡tvrt na dvan ct dopoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na dvan ct dopoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na dvan ct dopoledne$'

         db        'Bude za chv¡li p–l dvan ct‚ dopoledne$'
         db        'Je p©esnˆ p–l dvan ct‚ dopoledne$'
         db        'Je p–l dvan ct‚ dopoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na dvan ct dopoledne$'
         db        'Je t©i‡tvrtˆ na dvan ct dopoledne$'
         db        'Je t©i‡tvrtˆ na dvan ct dopoledne pry‡$'

         db        'Bude za chv¡li poledne$'
         db        'Je pr vˆ poledne$'
         db        'Bylo p©ed chv¡l¡ poledne$'

; ------ 13

         db        'Bude za chv¡li ‡tvrt na jednu odpoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na jednu odpoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na jednu odpoledne$'

         db        'Bude za chv¡li p–l jedn‚ odpoledne$'
         db        'Je p©esnˆ p–l jedn‚ odpoledne$'
         db        'Je p–l jedn‚ odpoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na jednu odpoledne$'
         db        'Je t©i‡tvrtˆ na jednu odpoledne$'
         db        'Je t©i‡tvrtˆ na jednu odpoledne pry‡$'

         db        'Bude za chv¡li jedna hodina odpoledne$'
         db        'Je pr vˆ jedna hodina odpoledne$'
         db        'Byla jedna hodina odpoledne$'

; ------ 14

         db        'Bude za chv¡li ‡tvrt na dvˆ odpoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na dvˆ odpoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na dvˆ odpoledne$'

         db        'Bude za chv¡li p–l druh‚ odpoledne$'
         db        'Je p©esnˆ p–l druh‚ odpoledne$'
         db        'Je p–l druh‚ odpoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na dvˆ odpoledne$'
         db        'Je t©i‡tvrtˆ na dvˆ odpoledne$'
         db        'Je t©i‡tvrtˆ na dvˆ odpoledne pry‡$'

         db        'Budou za chv¡li dvˆ hodiny odpoledne$'
         db        'Jsou pr vˆ dvˆ hodiny odpoledne$'
         db        'Byly dvˆ hodiny odpoledne$'

; ------ 15

         db        'Bude za chv¡li ‡tvrt na t©i odpoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na t©i odpoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na t©i odpoledne$'

         db        'Bude za chv¡li p–l t©et¡ odpoledne$'
         db        'Je p©esnˆ p–l t©et¡ odpoledne$'
         db        'Je p–l t©et¡ odpoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na t©i odpoledne$'
         db        'Je t©i‡tvrtˆ na t©i odpoledne$'
         db        'Je t©i‡tvrtˆ na t©i odpoledne pry‡$'

         db        'Budou za chv¡li t©i hodiny odpoledne$'
         db        'Jsou pr vˆ t©i hodiny odpoledne$'
         db        'Jsou t©i hodiny odpoledne pry‡$'

; ------ 16

         db        'Bude za chv¡li ‡tvrt na ‡ty©i odpoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na ‡ty©i odpoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na ‡ty©i odpoledne$'

         db        'Bude za chv¡li p–l ‡tvrt‚ odpoledne$'
         db        'Je p©esnˆ p–l ‡tvrt‚ odpoledne$'
         db        'Je p–l ‡tvrt‚ odpoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na ‡ty©i odpoledne$'
         db        'Je t©i‡tvrtˆ na ‡ty©i odpoledne$'
         db        'Je t©i‡tvrtˆ na ‡ty©i odpoledne pry‡$'

         db        'Budou za chv¡li ‡ty©i hodiny odpoledne$'
         db        'Jsou pr vˆ ‡ty©i hodiny odpoledne$'
         db        'Jsou ‡ty©i hodiny odpoledne pry‡$'

; ------ 17

         db        'Bude za chv¡li ‡tvrt na pˆt odpoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na pˆt odpoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na pˆt odpoledne$'

         db        'Bude za chv¡li p–l p t‚ odpoledne$'
         db        'Je p©esnˆ p–l p t‚ odpoledne$'
         db        'Je p–l p t‚ odpoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na pˆt odpoledne$'
         db        'Je t©i‡tvrtˆ na pˆt odpoledne$'
         db        'Je t©i‡tvrtˆ na pˆt odpoledne pry‡$'

         db        'Bude za chv¡li pˆt hodin odpoledne$'
         db        'Je pr vˆ pˆt hodin odpoledne$'
         db        'Je pˆt hodin odpoledne pry‡$'

; ------ 18

         db        'Bude za chv¡li ‡tvrt na ¨est odpoledne$'
         db        'Teƒ je p©esnˆ ‡tvrt na ¨est odpoledne$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na ¨est odpoledne$'

         db        'Bude za chv¡li p–l ¨est‚ odpoledne$'
         db        'Je p©esnˆ p–l ¨est‚ odpoledne$'
         db        'Je p–l ¨est‚ odpoledne pry‡$'

         db        'Bude t©i‡tvrtˆ na ¨est odpoledne$'
         db        'Je t©i‡tvrtˆ na ¨est odpoledne$'
         db        'Je t©i‡tvrtˆ na ¨est odpoledne pry‡$'

         db        'Bude za chv¡li ¨est hodin odpoledne$'
         db        'Je pr vˆ ¨est hodin odpoledne$'
         db        'Je ¨est hodin odpoledne pry‡$'

; ------ 19

         db        'Bude za chv¡li ‡tvrt na sedum ve‡er$'
         db        'Teƒ je p©esnˆ ‡tvrt na sedum ve‡er$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na sedum ve‡er$'

         db        'Bude za chv¡li p–l sedm‚ ve‡er$'
         db        'Je p©esnˆ p–l sedm‚ ve‡er$'
         db        'Je p–l sedm‚ ve‡er pry‡$'

         db        'Bude t©i‡tvrtˆ na sedum ve‡er$'
         db        'Je t©i‡tvrtˆ na sedum ve‡er$'
         db        'Je t©i‡tvrtˆ na sedum ve‡er pry‡$'

         db        'Bude za chv¡li sedum hodin ve‡er$'
         db        'Je pr vˆ sedum hodin ve‡er$'
         db        'Je sedum hodin ve‡er pry‡$'

; ------ 8

         db        'Bude za chv¡li ‡tvrt na osum ve‡er$'
         db        'Teƒ je p©esnˆ ‡tvrt na osum ve‡er$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na osum ve‡er$'

         db        'Bude za chv¡li p–l osm‚ ve‡er$'
         db        'Je p©esnˆ p–l osm‚ ve‡er$'
         db        'Je p–l osm‚ ve‡er pry‡$'

         db        'Bude t©i‡tvrtˆ na osum ve‡er$'
         db        'Je t©i‡tvrtˆ na osum ve‡er$'
         db        'Je t©i‡tvrtˆ na osum ve‡er pry‡$'

         db        'Bude za chv¡li osum hodin ve‡er$'
         db        'Je pr vˆ osum hodin ve‡er$'
         db        'Je osum hodin ve‡er pry‡$'

; ------ 9

         db        'Bude za chv¡li ‡tvrt na devˆt ve‡er$'
         db        'Teƒ je p©esnˆ ‡tvrt na devˆt ve‡er$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na devˆt ve‡er$'

         db        'Bude za chv¡li p–l dev t‚ ve‡er$'
         db        'Je p©esnˆ p–l dev t‚ ve‡er$'
         db        'Je p–l dev t‚ ve‡er pry‡$'

         db        'Bude t©i‡tvrtˆ na devˆt ve‡er$'
         db        'Je t©i‡tvrtˆ na devˆt ve‡er$'
         db        'Je t©i‡tvrtˆ na devˆt ve‡er pry‡$'

         db        'Bude za chv¡li devˆt hodin ve‡er$'
         db        'Je pr vˆ devˆt hodin ve‡er$'
         db        'Je devˆt hodin ve‡er pry‡$'

; ------ 10

         db        'Bude za chv¡li ‡tvrt na deset ve‡er$'
         db        'Teƒ je p©esnˆ ‡tvrt na deset ve‡er$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na deset ve‡er$'

         db        'Bude za chv¡li p–l des t‚ ve‡er$'
         db        'Je p©esnˆ p–l des t‚ ve‡er$'
         db        'Je p–l des t‚ ve‡er pry‡$'

         db        'Bude t©i‡tvrtˆ na deset ve‡er$'
         db        'Je t©i‡tvrtˆ na deset ve‡er$'
         db        'Je t©i‡tvrtˆ na deset ve‡er pry‡$'

         db        'Bude za chv¡li deset hodin ve‡er$'
         db        'Je pr vˆ deset hodin ve‡er$'
         db        'Je deset hodin ve‡er pry‡$'

; ------ 11

         db        'Bude za chv¡li ‡tvrt na jeden ct ve‡er$'
         db        'Teƒ je p©esnˆ ‡tvrt na jeden ct ve‡er$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na jeden ct ve‡er$'

         db        'Bude za chv¡li p–l jeden ct‚ ve‡er$'
         db        'Je p©esnˆ p–l jeden ct‚ ve‡er$'
         db        'Je p–l jeden ct‚ ve‡er pry‡$'

         db        'Bude t©i‡tvrtˆ na jeden ct ve‡er$'
         db        'Je t©i‡tvrtˆ na jeden ct ve‡er$'
         db        'Je t©i‡tvrtˆ na jeden ct ve‡er pry‡$'

         db        'Bude za chv¡li jeden ct hodin ve‡er$'
         db        'Je pr vˆ jeden ct hodin ve‡er$'
         db        'Je jeden ct hodin ve‡er pry‡$'

; ------ 12

         db        'Bude za chv¡li ‡tvrt na dvan ct ve‡er$'
         db        'Teƒ je p©esnˆ ‡tvrt na dvan ct ve‡er$'
         db        'Bylo p©ed chv¡l¡ ‡tvrt na dvan ct ve‡er$'

         db        'Bude za chv¡li p–l dvan ct‚ ve‡er$'
         db        'Je p©esnˆ p–l dvan ct‚ ve‡er$'
         db        'Je p–l dvan ct‚ ve‡er pry‡$'

         db        'Bude t©i‡tvrtˆ na dvan ct ve‡er$'
         db        'Je t©i‡tvrtˆ na dvan ct ve‡er$'
         db        'Je t©i‡tvrtˆ na dvan ct ve‡er pry‡$'

         db        'Za chv¡li odbije p–lnoc$'
         db        'Je pr vˆ p–lnoc$'

Code     ENDS
         END       Start
