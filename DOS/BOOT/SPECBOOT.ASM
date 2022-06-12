code     segment
         assume    cs:code,ds:code
         org       100h
start:
         mov       dx,offset text
         mov       ah,9
         int       21h

         mov       ax,0c08h
         int       21h
         cmp       al,27
         je        konec

         mov       si,5

opet:
         mov       ah,3
         mov       al,9
         mov       ch,0
         mov       cl,1
         mov       dh,0
         mov       dl,0
         mov       bx,offset boot
         push      cs
         pop       es
         int       13h
         jnc       dalsi
         dec       si
         jnz       opet
         jmp       short chyba1

dalsi:
         mov       ah,3
         mov       al,1
         mov       ch,0
         mov       cl,1
         mov       dh,1
         mov       dl,0
         mov       bx,offset boot + 9*512
         push      cs
         pop       es
         int       13h
         jnc       konec
         dec       si
         jnz       dalsi

chyba1:  mov       dx,offset chyba
         mov       ah,9
         int       21h

konec:
         mov       ah,0dh
         int       21h

         int       20h


text     db        'Data na diskete A: budou znicena (Esc=konec) !',13,10,'$'

chyba    db        'Chyba !',13,10,'$'

         org       7c00h

boot     label     word

         jmp       Bstart

         db        'GOLEM 92'               ; identifikace

                                            ; 1 sektor ROOT
                                            ; 2*3 sektory FAT
                                            ; 3 sektory ROOT
                                            ; 710 datov˜ch sektor–

         dw        512                      ; d‚lka sektoru
         db        1                        ; velikost bloku (sektor–)
         dw        1                        ; po‡et rezervovan˜ch sektor–
         db        2                        ; po‡et alok. tabulek FAT
         dw        30h                      ; max. po‡et polo‘ek ROOT
         dw        720                      ; celkem sektor– na m‚diu
         db        0fdh                     ; popisova‡ m‚dia
         dw        3                        ; po‡et sektor– v jedn‚ FAT
         dw        9                        ; po‡et sektor– na stopu
         dw        2                        ; po‡et hlav disku
         dd        0                        ; skryt˜ch sektor– (4-bajty)
         dd        0                        ; celkem sektor– (4-bajty)

         db        0                        ; disk (pracovn¡)
         db        0                        ; hlava (pracovn¡)

         db        29h                      ; identifik tor
         dw        0,0                      ; s‚riov‚ ‡¡slo

         db        'DOS MANAZER'
         db        'FAT12   '

Bstart:  xor       ax,ax
         mov       ss,ax
         mov       sp,offset Boot
         sti

         push      ss
         pop       ds
         push      ss
         pop       es

         mov       si,offset btext
         cld

BDispTxt:lodsb
         or        al,al
         jz        bret
         mov       ah,0eh
         mov       bx,7
         int       10h
         jmp       short bdisptxt

BRet:    sti
         xor       ax,ax
         int       16h

         int       19h


BText    db        13
         db        'Nesystemova disketa. Vymente disketu',13,10
         db        'a stisknete libovolnou klavesu .....',13,10,0

         db        510-offset($-boot) dup(0)

         dw        0aa55h

                                          ;* 1. FAT tabulka
         db        0fdh,0ffh,0ffh
         db        3*512-3 dup(0)

                                          ;* 2. FAT tabulka
         db        0fdh,0ffh,0ffh
         db        3*512-3 dup(0)

                                          ;* ROOT
         db        3*512 dup(0)

code     ends
         end       start
