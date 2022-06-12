COMMENT %

 Driver pro obsluhu kl†vesnice s áeskòm fontem znakñ

%
code     SEGMENT   page
         ASSUME    cs:code,ds:code

         db        "Driver pro áeskou kl†vesnici CSKEY V1.1",13,10
         db        "(C) MNS leden 1990",13,10

start:
         jmp       init

adrkey   dd        0                   ; adresa driveru kl†vesnice
status   db        0
swtab    db        0
extab    dw        0
parins   db        0                   ; citac znaku INSERT
znakz    dw        219                 ; poslednà vloëenò znak

                                       ; tabulka norm. áe®tiny
tab1     db        "1ñ"
         db        "2à"
         db        "3®"
         db        "4á"
         db        "5©"
         db        "6ë"
         db        "7ò"
         db        "8†"
         db        "9°"
         db        "0Ç"
         db        0

tab11    db        "1¶"
         db        "2â"
         db        "3õ"
         db        "4Ä"
         db        "5û"
         db        "6í"
         db        "7ù"
         db        "8è"
         db        "9ã"
         db        "0ê"
         db        0


                                       ; tabulka pro `
tab2     db        "+Ò"
         db        "="
         db        "qÑ"
         db        "Qé"
         db        "wà"
         db        "Wâ"
         db        "eÇ"
         db        "Eê"
         db        "r©"
         db        "Rû"
         db        "tü"
         db        "TÜ"
         db        "yò"
         db        "Yù"
         db        "u£"
         db        "Uó"
         db        "i°"
         db        "Iã"
         db        "o¢"
         db        "Oï"
         db        "pî"
         db        "Pô"
         db        "a†"
         db        "Aè"
         db        "s®"
         db        "Sõ"
         db        "dÉ"
         db        "DÖ"
         db        "f™"
         db        "F´"
         db        "hÅ"
         db        "Hö"
         db        "jñ"
         db        "J¶"
         db        "kì"
         db        "Kß"
         db        "lç"
         db        "Lä"
         db        "zë"
         db        "Zí"
         db        "cá"
         db        "CÄ"
         db        "n§"
         db        "N•"
         db        "må"
         db        "Mú"
         db        ",Æ"
         db        "<Û"
         db        ".Ø"
         db        ">Ú"
         db        0

                                       ; tabulka pro ~
tab3     db        "+Ò"
         db        "="
         db        "qÑ"
         db        "Qé"
         db        "wà"
         db        "Wâ"
         db        "eà"
         db        "Eâ"
         db        "r©"
         db        "Rû"
         db        "tü"
         db        "TÜ"
         db        "yò"
         db        "Yù"
         db        "uñ"
         db        "U¶"
         db        "i°"
         db        "Iã"
         db        "oì"
         db        "Oß"
         db        "pî"
         db        "Pô"
         db        "aÑ"
         db        "Aé"
         db        "s®"
         db        "Sõ"
         db        "dÉ"
         db        "DÖ"
         db        "f™"
         db        "F´"
         db        "hÅ"
         db        "Hö"
         db        "jñ"
         db        "J¶"
         db        "kì"
         db        "Kß"
         db        "lå"
         db        "Lú"
         db        "zë"
         db        "Zí"
         db        "cá"
         db        "CÄ"
         db        "n§"
         db        "N•"
         db        "må"
         db        "Mú"
         db        ",Æ"
         db        "<Û"
         db        ".Ø"
         db        ">Ú"
         db        0

tab4     db        "0",205
         db        "1",200
         db        "2",202
         db        "3",188
         db        "4",204
         db        "5",206
         db        "6",185
         db        "7",201
         db        "8",203
         db        "9",187
         db        ".",186

         db        52h,205
         db        4fh,212
         db        50h,207
         db        51h,190
         db        4bh,198
         db        4ch,216
         db        4dh,181
         db        47h,213
         db        48h,209
         db        49h,184
         db        53h,179
         db        "/",176
         db        "*",177
         db        "-",178
         db        "+",219
         db        0


tab5     db        "0",196
         db        "1",192
         db        "2",193
         db        "3",217
         db        "4",195
         db        "5",197
         db        "6",180
         db        "7",218
         db        "8",194
         db        "9",191
         db        ".",179

         db        52h,196
         db        4fh,211
         db        50h,208
         db        51h,189
         db        4bh,199
         db        4ch,215
         db        4dh,182
         db        47h,214
         db        48h,210
         db        49h,183
         db        53h,186
         db        "/",176
         db        "*",177
         db        "-",178
         db        "+",219
         db        0


key:                                   ; program obsluhy kl†vesnice
         push      bx
         push      ds
         push      cx
         push      di
         mov       bx,40h
         mov       ds,bx
         mov       bx,word ptr ds:[1ch] ; ukazatel bufferu znakñ
         pushf
         call      dword ptr cs:[adrkey] ; vyvol†n° p©eru®en° kl†vesnice
         cli
         push      ax
         mov       al,byte ptr ds:[17h] ; p©eáten° statusu kl†vesnice
         mov       byte ptr cs:[status],al ; uloëen° statusu
         mov       ax,[bx]              ; p©eáten° znaku z bufferu
         cmp       bx,word ptr ds:[1ch] ; byl p©ijat znak ?
         jnz       key1                ; byl p©ijat
keynul:                                ; nebyl p©ijat znak
         mov       al,byte ptr ds:[18h] ; status kl†vesnice
         cmp       al,80h              ; je kl†vesa INS ?
         jnz       keynl1              ; nen° kl†vesa INS
         mov       al,cs:[parins]
         xor       al,1
         mov       cs:[parins],al      ; zmena priznaku INS
         jz        keynl1              ; je sudy znak
         mov       ax,52e0h            ; k¢d INS
         call      inskey              ; vloëen° znaku INS
keynl1:  jmp       konec               ; konec programu
key1:
         cmp       ax,52e0h            ; je znak INS ?
         jnz       keynl2
         mov       al,1
         mov       cs:[parins],al
         jmp       short keynl1

keynl2:
         mov       al,cs:[status]
         and       al,3
         mov       ax,[bx]
         jz        keynl9
         cmp       ax,48e0h            ; ®ipka nahoru
         jnz       keynl3
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,48e0h
         jmp       short keynl7
keynl3:  cmp       ax,50e0h
         jnz       keynl4
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,50e0h
         jmp       short keynl7
keynl4:  cmp       ax,4de0h
         jnz       keynl5
         mov       ax,cs:[znakz]
         mov       [bx],ax
         jmp       short keynl8

keynl5:  cmp       ax,4be0h
         jnz       keynl9
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,4be0h
keynl7:  call      inskey
keynl8:  jmp       konec

keynl9:
         cmp       ah,0                ; je to znak s ALT ?
         jnz       key5                ; je ALT - konec
key10:   mov       cs:[extab],0        ; zru®en° tabulky
         jmp       keynul              ; konec programu
key5:    cmp       ax,29f0h
         jz        key11               ; kl†vesa ALT- `/~
         cmp       al,60h              ; je znak ` (carka) ?
         jnz       key2                ; nen°
         mov       cs:[extab],offset tab2 ; nastaven° tabulky 2
         jmp       short zrus          ; zru®en° kl†vesy
key2:    cmp       al,7eh              ; je znak ~ (hacek) ?
         jnz       key3                ; nen°
         mov       cs:[extab],offset tab3 ; nastaven° tabulky 3
zrus:    mov       word ptr ds:[1ch],bx ; n†vrat ukazatele znakñ
         jmp       konec               ; konec programu
key11:   and       cs:[status],3
         mov       ax,2960h
         jz        key12
         mov       ax,297eh
key12:   mov       [bx],ax
         jmp       short key10
konec1:  jmp       konec
key3:    cmp       cs:[extab],0        ; je roz®°©en† tabulka ?
         mov       di,word ptr cs:[extab]
         jnz       key4                ; ano
         cmp       cs:[swtab],0        ; je p©ep°naá tabulek ?
         jz        konec1              ; tabulka IBM
         cmp       cs:[swtab],1
         jnz       key30
         cmp       ah,2
         jc        konec1
         cmp       ah,12
         jnc       konec1
         mov       di,offset tab1
         test      cs:[status],40h     ; p©°znak CAPS LOCK
         jz        key320
         mov       di,offset tab11     ; jsou velk† p°smena
         jmp       short key320
key30:   mov       di,offset tab4
         cmp       cs:[swtab],2
         jz        key33
         mov       di,offset tab5
key33:   cmp       ax,4e2bh
         jz        key40
         cmp       ax,4a2dh
         jz        key40
         cmp       ax,372ah
         jz        key40
         cmp       ax,0e02fh
         jz        key40
         cmp       ax,532eh
         jz        key40
         cmp       al,0f0h
         jz        key32
         cmp       al,0
         jnz       key31
key32:   mov       al,ah
key320:  jmp       short key40
key31:   cmp       ah,13
         jc        konec
         cmp       al,30h
         jc        konec
         cmp       al,3ah
         jnc       konec
         jmp       short key40
key4:                                  ; p©ek¢dov†n° podle tabulky DI
         cmp       ax,0e08h
         jz        key43
         cmp       ax,53e0h
         jz        key43
         cmp       ax,0231h
         jnz       key41
         mov       cs:[swtab],0
         jmp       short key43
key41:   cmp       ax,0332h
         jnz       key42
         mov       cs:[swtab],1
key43:   mov       word ptr ds:[1ch],bx
         jmp       key6
key42:   cmp       ax,0433h
         jnz       key44
         mov       cs:[swtab],2
         jmp       short key43
key44:   cmp       ax,0534h
         jnz       key40
         mov       cs:[swtab],3
         jmp       short key43
key40:
key7:    cmp       al,cs:[di]
         jz        key8
         inc       di
         inc       di
         cmp       byte ptr cs:[di],0
         jnz       key7
         jmp       short key6
key8:    inc       di
         mov       al,cs:[di]
         mov       ah,0
         mov       [bx],ax
key6:    mov       cs:[extab],0        ; zru®en° p©echodnÇ tabulky

konec:                                 ; konec se z†znamem znaku
         mov       ax,[bx]             ; p©eáten° znaku z bufferu
         cmp       bx,word ptr ds:[1ch]; byl p©ijat znak ?
         jz        konec3              ; nebyl p©ijat
         test      ah,ah
         jz        konec2
         cmp       al,32
         jc        konec3
         cmp       al,7fh
         jz        konec3
         cmp       al,0e0h
         jz        konec3
         cmp       al,0f0h
         jz        konec3
konec2:  mov       cs:[znakz],ax       ; uloëen° poslednà zadanÇho znaku
konec3:  pop       ax
         pop       di
         pop       cx
         pop       ds
         pop       bx
         iret

inskey:                                ; vloëen° znaku AX do bufferu
         mov       bx,word ptr ds:[1ch] ; ukazatel pro uloëen° znaku
         push      bx
         inc       bx
         inc       bx                  ; zvò®en° pozice
         cmp       bx,3eh              ; je p©ekroáen° konce bufferu ?
         jc        insk1               ; nen°
         mov       bx,1eh              ; zaá†tek bufferu
insk1:   cmp       bx,word ptr ds:[1ah] ; ukazatel pro áten° znaku
         jz        insk2               ; nen° volnÇ m°sto v bufferu
         mov       word ptr ds:[1ch],bx ; novò ukazatel
         pop       bx                  ; pñvodn° ukazatel
         mov       ds:[bx],ax          ; uloëen° znaku
         mov       bx,word ptr ds:[1ch]
         ret
insk2:   pop       bx                  ; n†vrat ukazatele znakñ
         ret

init:    push      cs
         pop       ds
         mov       ax,3509h            ; p©eáten° vektoru p©eru®en° 09h
         int       21h
         cmp       bx,offset key       ; obsluha kl†vesnice
         je        nainst              ; hl†®en°, ëe je jië nainstalov†n
         mov       word ptr [adrkey],bx ; nastaven° vektoru p©eru®en° kl†vesnice
         mov       word ptr [adrkey+2],es
         mov       dx,offset key
         mov       ax,2509h
         int       21h                 ; nastaven° novÇ adresy p©eru®en°
         mov       dx,offset text1     ; uvodn° text
         mov       ah,9
         int       21h                 ; tisk £vodn°ho textu
         mov       dx,word ptr init    ; konec programu
         int       27h                 ; ukonáen° programu jako rezidentn°

nainst:  mov       dx,offset text2     ; hl†®en°, ëe je jië nainstalov†n
         mov       ah,9
         int       21h
         mov       ah,4ch              ; norm†ln° ukonáen° programu
         int       21h

text1    db        'Driver pro áeskou kl†vesnici CSKEY V 1.1 byl nainstalov†n.'
         db        13,10,'$'

text2    db        'Driver pro áeskou kl†vesnici je jië nainstalov†n v pamàti !'
         db        13,10,'$'

code     ENDS

stack    SEGMENT   stack
         DW        256 DUP(?)          ; z†sobn°k 256 slov
stack    ENDS

         END       start               ; startovac° adresa
