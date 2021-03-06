
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
         mov       cx,5462                  ; po�et impuls� na 5 minut
         div       cx                       ; v�po�et �seku 5 minut
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
         db        '����������Ŀ  \          \--',13,10
Text1    db        '�          �    \     )   _/',13,10
Text2    db        '�00.00.0000�      - \  \',13,10
Text3    db        '�00:00:00  �        /  /',13,10
         db        '������������        A  A',13,10
         db        13,10
         db        'KU - KU !   $'

Tecka    db        '.',13,10,'$'

dny      db        'ned�le '
         db        'pond�l�'
         db        '�ter�  '
         db        'st�eda '
         db        '�tvrtek'
         db        'p�tek  '
         db        'sobota '

Hlaseni  db        'Je pr�v� p�lnoc$'
         db        'Pr�v� odbila p�lnoc$'

; ------ 1

         db        'Bude za chv�li �tvrt na jednu r�no$'
         db        'Te� je p�esn� �tvrt na jednu r�no$'
         db        'Bylo p�ed chv�l� �tvrt na jednu r�no$'

         db        'Bude za chv�li p�l jedn� r�no$'
         db        'Je p�esn� p�l jedn� r�no$'
         db        'Je p�l jedn� r�no pry�$'

         db        'Bude t�i�tvrt� na jednu r�no$'
         db        'Je t�i�tvrt� na jednu r�no$'
         db        'Je t�i�tvrt� na jednu r�no pry�$'

         db        'Bude za chv�li jedna hodina r�no$'
         db        'Je pr�v� jedna hodina r�no$'
         db        'Byla jedna hodina r�no$'

; ------ 2

         db        'Bude za chv�li �tvrt na dv� r�no$'
         db        'Te� je p�esn� �tvrt na dv� r�no$'
         db        'Bylo p�ed chv�l� �tvrt na dv� r�no$'

         db        'Bude za chv�li p�l druh� r�no$'
         db        'Je p�esn� p�l druh� r�no$'
         db        'Je p�l druh� r�no pry�$'

         db        'Bude t�i�tvrt� na dv� r�no$'
         db        'Je t�i�tvrt� na dv� r�no$'
         db        'Je t�i�tvrt� na dv� r�no pry�$'

         db        'Budou za chv�li dv� hodiny r�no$'
         db        'Jsou pr�v� dv� hodiny r�no$'
         db        'Byly dv� hodiny r�no$'

; ------ 3

         db        'Bude za chv�li �tvrt na t�i r�no$'
         db        'Te� je p�esn� �tvrt na t�i r�no$'
         db        'Bylo p�ed chv�l� �tvrt na t�i r�no$'

         db        'Bude za chv�li p�l t�et� r�no$'
         db        'Je p�esn� p�l t�et� r�no$'
         db        'Je p�l t�et� r�no pry�$'

         db        'Bude t�i�tvrt� na t�i r�no$'
         db        'Je t�i�tvrt� na t�i r�no$'
         db        'Je t�i�tvrt� na t�i r�no pry�$'

         db        'Budou za chv�li t�i hodiny r�no$'
         db        'Jsou pr�v� t�i hodiny r�no$'
         db        'Jsou t�i hodiny r�no pry�$'

; ------ 4

         db        'Bude za chv�li �tvrt na �ty�i r�no$'
         db        'Te� je p�esn� �tvrt na �ty�i r�no$'
         db        'Bylo p�ed chv�l� �tvrt na �ty�i r�no$'

         db        'Bude za chv�li p�l �tvrt� r�no$'
         db        'Je p�esn� p�l �tvrt� r�no$'
         db        'Je p�l �tvrt� r�no pry�$'

         db        'Bude t�i�tvrt� na �ty�i r�no$'
         db        'Je t�i�tvrt� na �ty�i r�no$'
         db        'Je t�i�tvrt� na �ty�i r�no pry�$'

         db        'Budou za chv�li �ty�i hodiny r�no$'
         db        'Jsou pr�v� �ty�i hodiny r�no$'
         db        'Jsou �ty�i hodiny r�no pry�$'

; ------ 5

         db        'Bude za chv�li �tvrt na p�t r�no$'
         db        'Te� je p�esn� �tvrt na p�t r�no$'
         db        'Bylo p�ed chv�l� �tvrt na p�t r�no$'

         db        'Bude za chv�li p�l p�t� r�no$'
         db        'Je p�esn� p�l p�t� r�no$'
         db        'Je p�l p�t� r�no pry�$'

         db        'Bude t�i�tvrt� na p�t r�no$'
         db        'Je t�i�tvrt� na p�t r�no$'
         db        'Je t�i�tvrt� na p�t r�no pry�$'

         db        'Bude za chv�li p�t hodin r�no$'
         db        'Je pr�v� p�t hodin r�no$'
         db        'Je p�t hodin r�no pry�$'

; ------ 6

         db        'Bude za chv�li �tvrt na �est r�no$'
         db        'Te� je p�esn� �tvrt na �est r�no$'
         db        'Bylo p�ed chv�l� �tvrt na �est r�no$'

         db        'Bude za chv�li p�l �est� r�no$'
         db        'Je p�esn� p�l �est� r�no$'
         db        'Je p�l �est� r�no pry�$'

         db        'Bude t�i�tvrt� na �est r�no$'
         db        'Je t�i�tvrt� na �est r�no$'
         db        'Je t�i�tvrt� na �est r�no pry�$'

         db        'Bude za chv�li �est hodin r�no$'
         db        'Je pr�v� �est hodin r�no$'
         db        'Je �est hodin r�no pry�$'

; ------ 7

         db        'Bude za chv�li �tvrt na sedum r�no$'
         db        'Te� je p�esn� �tvrt na sedum r�no$'
         db        'Bylo p�ed chv�l� �tvrt na sedum r�no$'

         db        'Bude za chv�li p�l sedm� r�no$'
         db        'Je p�esn� p�l sedm� r�no$'
         db        'Je p�l sedm� r�no pry�$'

         db        'Bude t�i�tvrt� na sedum r�no$'
         db        'Je t�i�tvrt� na sedum r�no$'
         db        'Je t�i�tvrt� na sedum r�no pry�$'

         db        'Bude za chv�li sedum hodin r�no$'
         db        'Je pr�v� sedum hodin r�no$'
         db        'Je sedum hodin r�no pry�$'

; ------ 8

         db        'Bude za chv�li �tvrt na osum r�no$'
         db        'Te� je p�esn� �tvrt na osum r�no$'
         db        'Bylo p�ed chv�l� �tvrt na osum r�no$'

         db        'Bude za chv�li p�l osm� r�no$'
         db        'Je p�esn� p�l osm� r�no$'
         db        'Je p�l osm� r�no pry�$'

         db        'Bude t�i�tvrt� na osum r�no$'
         db        'Je t�i�tvrt� na osum r�no$'
         db        'Je t�i�tvrt� na osum r�no pry�$'

         db        'Bude za chv�li osum hodin r�no$'
         db        'Je pr�v� osum hodin r�no$'
         db        'Je osum hodin r�no pry�$'

; ------ 9

         db        'Bude za chv�li �tvrt na dev�t r�no$'
         db        'Te� je p�esn� �tvrt na dev�t r�no$'
         db        'Bylo p�ed chv�l� �tvrt na dev�t r�no$'

         db        'Bude za chv�li p�l dev�t� r�no$'
         db        'Je p�esn� p�l dev�t� r�no$'
         db        'Je p�l dev�t� r�no pry�$'

         db        'Bude t�i�tvrt� na dev�t r�no$'
         db        'Je t�i�tvrt� na dev�t r�no$'
         db        'Je t�i�tvrt� na dev�t r�no pry�$'

         db        'Bude za chv�li dev�t hodin r�no$'
         db        'Je pr�v� dev�t hodin r�no$'
         db        'Je dev�t hodin r�no pry�$'

; ------ 10

         db        'Bude za chv�li �tvrt na deset dopoledne$'
         db        'Te� je p�esn� �tvrt na deset dopoledne$'
         db        'Bylo p�ed chv�l� �tvrt na deset dopoledne$'

         db        'Bude za chv�li p�l des�t� dopoledne$'
         db        'Je p�esn� p�l des�t� dopoledne$'
         db        'Je p�l des�t� dopoledne pry�$'

         db        'Bude t�i�tvrt� na deset dopoledne$'
         db        'Je t�i�tvrt� na deset dopoledne$'
         db        'Je t�i�tvrt� na deset dopoledne pry�$'

         db        'Bude za chv�li deset hodin dopoledne$'
         db        'Je pr�v� deset hodin dopoledne$'
         db        'Je deset hodin dopoledne pry�$'

; ------ 11

         db        'Bude za chv�li �tvrt na jeden�ct dopoledne$'
         db        'Te� je p�esn� �tvrt na jeden�ct dopoledne$'
         db        'Bylo p�ed chv�l� �tvrt na jeden�ct dopoledne$'

         db        'Bude za chv�li p�l jeden�ct� dopoledne$'
         db        'Je p�esn� p�l jeden�ct� dopoledne$'
         db        'Je p�l jeden�ct� dopoledne pry�$'

         db        'Bude t�i�tvrt� na jeden�ct dopoledne$'
         db        'Je t�i�tvrt� na jeden�ct dopoledne$'
         db        'Je t�i�tvrt� na jeden�ct dopoledne pry�$'

         db        'Bude za chv�li jeden�ct hodin dopoledne$'
         db        'Je pr�v� jeden�ct hodin dopoledne$'
         db        'Je jeden�ct hodin dopoledne pry�$'

; ------ 12

         db        'Bude za chv�li �tvrt na dvan�ct dopoledne$'
         db        'Te� je p�esn� �tvrt na dvan�ct dopoledne$'
         db        'Bylo p�ed chv�l� �tvrt na dvan�ct dopoledne$'

         db        'Bude za chv�li p�l dvan�ct� dopoledne$'
         db        'Je p�esn� p�l dvan�ct� dopoledne$'
         db        'Je p�l dvan�ct� dopoledne pry�$'

         db        'Bude t�i�tvrt� na dvan�ct dopoledne$'
         db        'Je t�i�tvrt� na dvan�ct dopoledne$'
         db        'Je t�i�tvrt� na dvan�ct dopoledne pry�$'

         db        'Bude za chv�li poledne$'
         db        'Je pr�v� poledne$'
         db        'Bylo p�ed chv�l� poledne$'

; ------ 13

         db        'Bude za chv�li �tvrt na jednu odpoledne$'
         db        'Te� je p�esn� �tvrt na jednu odpoledne$'
         db        'Bylo p�ed chv�l� �tvrt na jednu odpoledne$'

         db        'Bude za chv�li p�l jedn� odpoledne$'
         db        'Je p�esn� p�l jedn� odpoledne$'
         db        'Je p�l jedn� odpoledne pry�$'

         db        'Bude t�i�tvrt� na jednu odpoledne$'
         db        'Je t�i�tvrt� na jednu odpoledne$'
         db        'Je t�i�tvrt� na jednu odpoledne pry�$'

         db        'Bude za chv�li jedna hodina odpoledne$'
         db        'Je pr�v� jedna hodina odpoledne$'
         db        'Byla jedna hodina odpoledne$'

; ------ 14

         db        'Bude za chv�li �tvrt na dv� odpoledne$'
         db        'Te� je p�esn� �tvrt na dv� odpoledne$'
         db        'Bylo p�ed chv�l� �tvrt na dv� odpoledne$'

         db        'Bude za chv�li p�l druh� odpoledne$'
         db        'Je p�esn� p�l druh� odpoledne$'
         db        'Je p�l druh� odpoledne pry�$'

         db        'Bude t�i�tvrt� na dv� odpoledne$'
         db        'Je t�i�tvrt� na dv� odpoledne$'
         db        'Je t�i�tvrt� na dv� odpoledne pry�$'

         db        'Budou za chv�li dv� hodiny odpoledne$'
         db        'Jsou pr�v� dv� hodiny odpoledne$'
         db        'Byly dv� hodiny odpoledne$'

; ------ 15

         db        'Bude za chv�li �tvrt na t�i odpoledne$'
         db        'Te� je p�esn� �tvrt na t�i odpoledne$'
         db        'Bylo p�ed chv�l� �tvrt na t�i odpoledne$'

         db        'Bude za chv�li p�l t�et� odpoledne$'
         db        'Je p�esn� p�l t�et� odpoledne$'
         db        'Je p�l t�et� odpoledne pry�$'

         db        'Bude t�i�tvrt� na t�i odpoledne$'
         db        'Je t�i�tvrt� na t�i odpoledne$'
         db        'Je t�i�tvrt� na t�i odpoledne pry�$'

         db        'Budou za chv�li t�i hodiny odpoledne$'
         db        'Jsou pr�v� t�i hodiny odpoledne$'
         db        'Jsou t�i hodiny odpoledne pry�$'

; ------ 16

         db        'Bude za chv�li �tvrt na �ty�i odpoledne$'
         db        'Te� je p�esn� �tvrt na �ty�i odpoledne$'
         db        'Bylo p�ed chv�l� �tvrt na �ty�i odpoledne$'

         db        'Bude za chv�li p�l �tvrt� odpoledne$'
         db        'Je p�esn� p�l �tvrt� odpoledne$'
         db        'Je p�l �tvrt� odpoledne pry�$'

         db        'Bude t�i�tvrt� na �ty�i odpoledne$'
         db        'Je t�i�tvrt� na �ty�i odpoledne$'
         db        'Je t�i�tvrt� na �ty�i odpoledne pry�$'

         db        'Budou za chv�li �ty�i hodiny odpoledne$'
         db        'Jsou pr�v� �ty�i hodiny odpoledne$'
         db        'Jsou �ty�i hodiny odpoledne pry�$'

; ------ 17

         db        'Bude za chv�li �tvrt na p�t odpoledne$'
         db        'Te� je p�esn� �tvrt na p�t odpoledne$'
         db        'Bylo p�ed chv�l� �tvrt na p�t odpoledne$'

         db        'Bude za chv�li p�l p�t� odpoledne$'
         db        'Je p�esn� p�l p�t� odpoledne$'
         db        'Je p�l p�t� odpoledne pry�$'

         db        'Bude t�i�tvrt� na p�t odpoledne$'
         db        'Je t�i�tvrt� na p�t odpoledne$'
         db        'Je t�i�tvrt� na p�t odpoledne pry�$'

         db        'Bude za chv�li p�t hodin odpoledne$'
         db        'Je pr�v� p�t hodin odpoledne$'
         db        'Je p�t hodin odpoledne pry�$'

; ------ 18

         db        'Bude za chv�li �tvrt na �est odpoledne$'
         db        'Te� je p�esn� �tvrt na �est odpoledne$'
         db        'Bylo p�ed chv�l� �tvrt na �est odpoledne$'

         db        'Bude za chv�li p�l �est� odpoledne$'
         db        'Je p�esn� p�l �est� odpoledne$'
         db        'Je p�l �est� odpoledne pry�$'

         db        'Bude t�i�tvrt� na �est odpoledne$'
         db        'Je t�i�tvrt� na �est odpoledne$'
         db        'Je t�i�tvrt� na �est odpoledne pry�$'

         db        'Bude za chv�li �est hodin odpoledne$'
         db        'Je pr�v� �est hodin odpoledne$'
         db        'Je �est hodin odpoledne pry�$'

; ------ 19

         db        'Bude za chv�li �tvrt na sedum ve�er$'
         db        'Te� je p�esn� �tvrt na sedum ve�er$'
         db        'Bylo p�ed chv�l� �tvrt na sedum ve�er$'

         db        'Bude za chv�li p�l sedm� ve�er$'
         db        'Je p�esn� p�l sedm� ve�er$'
         db        'Je p�l sedm� ve�er pry�$'

         db        'Bude t�i�tvrt� na sedum ve�er$'
         db        'Je t�i�tvrt� na sedum ve�er$'
         db        'Je t�i�tvrt� na sedum ve�er pry�$'

         db        'Bude za chv�li sedum hodin ve�er$'
         db        'Je pr�v� sedum hodin ve�er$'
         db        'Je sedum hodin ve�er pry�$'

; ------ 8

         db        'Bude za chv�li �tvrt na osum ve�er$'
         db        'Te� je p�esn� �tvrt na osum ve�er$'
         db        'Bylo p�ed chv�l� �tvrt na osum ve�er$'

         db        'Bude za chv�li p�l osm� ve�er$'
         db        'Je p�esn� p�l osm� ve�er$'
         db        'Je p�l osm� ve�er pry�$'

         db        'Bude t�i�tvrt� na osum ve�er$'
         db        'Je t�i�tvrt� na osum ve�er$'
         db        'Je t�i�tvrt� na osum ve�er pry�$'

         db        'Bude za chv�li osum hodin ve�er$'
         db        'Je pr�v� osum hodin ve�er$'
         db        'Je osum hodin ve�er pry�$'

; ------ 9

         db        'Bude za chv�li �tvrt na dev�t ve�er$'
         db        'Te� je p�esn� �tvrt na dev�t ve�er$'
         db        'Bylo p�ed chv�l� �tvrt na dev�t ve�er$'

         db        'Bude za chv�li p�l dev�t� ve�er$'
         db        'Je p�esn� p�l dev�t� ve�er$'
         db        'Je p�l dev�t� ve�er pry�$'

         db        'Bude t�i�tvrt� na dev�t ve�er$'
         db        'Je t�i�tvrt� na dev�t ve�er$'
         db        'Je t�i�tvrt� na dev�t ve�er pry�$'

         db        'Bude za chv�li dev�t hodin ve�er$'
         db        'Je pr�v� dev�t hodin ve�er$'
         db        'Je dev�t hodin ve�er pry�$'

; ------ 10

         db        'Bude za chv�li �tvrt na deset ve�er$'
         db        'Te� je p�esn� �tvrt na deset ve�er$'
         db        'Bylo p�ed chv�l� �tvrt na deset ve�er$'

         db        'Bude za chv�li p�l des�t� ve�er$'
         db        'Je p�esn� p�l des�t� ve�er$'
         db        'Je p�l des�t� ve�er pry�$'

         db        'Bude t�i�tvrt� na deset ve�er$'
         db        'Je t�i�tvrt� na deset ve�er$'
         db        'Je t�i�tvrt� na deset ve�er pry�$'

         db        'Bude za chv�li deset hodin ve�er$'
         db        'Je pr�v� deset hodin ve�er$'
         db        'Je deset hodin ve�er pry�$'

; ------ 11

         db        'Bude za chv�li �tvrt na jeden�ct ve�er$'
         db        'Te� je p�esn� �tvrt na jeden�ct ve�er$'
         db        'Bylo p�ed chv�l� �tvrt na jeden�ct ve�er$'

         db        'Bude za chv�li p�l jeden�ct� ve�er$'
         db        'Je p�esn� p�l jeden�ct� ve�er$'
         db        'Je p�l jeden�ct� ve�er pry�$'

         db        'Bude t�i�tvrt� na jeden�ct ve�er$'
         db        'Je t�i�tvrt� na jeden�ct ve�er$'
         db        'Je t�i�tvrt� na jeden�ct ve�er pry�$'

         db        'Bude za chv�li jeden�ct hodin ve�er$'
         db        'Je pr�v� jeden�ct hodin ve�er$'
         db        'Je jeden�ct hodin ve�er pry�$'

; ------ 12

         db        'Bude za chv�li �tvrt na dvan�ct ve�er$'
         db        'Te� je p�esn� �tvrt na dvan�ct ve�er$'
         db        'Bylo p�ed chv�l� �tvrt na dvan�ct ve�er$'

         db        'Bude za chv�li p�l dvan�ct� ve�er$'
         db        'Je p�esn� p�l dvan�ct� ve�er$'
         db        'Je p�l dvan�ct� ve�er pry�$'

         db        'Bude t�i�tvrt� na dvan�ct ve�er$'
         db        'Je t�i�tvrt� na dvan�ct ve�er$'
         db        'Je t�i�tvrt� na dvan�ct ve�er pry�$'

         db        'Za chv�li odbije p�lnoc$'
         db        'Je pr�v� p�lnoc$'

Code     ENDS
         END       Start
