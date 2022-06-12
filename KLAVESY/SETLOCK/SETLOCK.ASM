
code     segment
         assume    cs:code,ds:code
         org       100h
start:
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

         xor       ax,ax
         mov       es,ax

         mov       si,81h
         xor       ch,ch
         mov       cl,ds:[80h]              ; po‡et znak–
         jcxz      Chyba
         cld
         cli                                ; z kaz p©eru¨en¡

s1:      lodsb
         cmp       al," "
         jbe       s9

; ------ N

         cmp       al,"N"
         jne       s2

         or        byte ptr es:[417h],20h
;         or        byte ptr es:[497h],2
         jmp       short s8

s2:      cmp       al,"n"
         jne       s3

         and       byte ptr es:[417h],not 20h
;         and       byte ptr es:[497h],not 2
         jmp       short s8

s3:      cmp       al,"C"
         jne       s4

         or        byte ptr es:[417h],40h
;         or        byte ptr es:[497h],4
         jmp       short s8

s4:      cmp       al,"c"
         jne       s5

         and       byte ptr es:[417h],not 40h
;         and       byte ptr es:[497h],not 4
         jmp       short s8

s5:      cmp       al,"S"
         jne       s6

         or        byte ptr es:[417h],10h
;         or        byte ptr es:[497h],1
         jmp       short s8

s6:      cmp       al,"s"
         jne       s91

         and       byte ptr es:[417h],not 10h
;         and       byte ptr es:[497h],not 1

s8: ;     and       byte ptr es:[497h],not 40h
s9:      loop      s1
         jmp       short Konec


s91:     cmp       al,"x"
         jne       s92

         and       byte ptr es:[496h],not 10h
         jmp       short s9

s92:     cmp       al,"X"
         jne       Chyba
         or        byte ptr es:[496h],10h
         jmp       short s9

Chyba:   mov       ah,9
         mov       dx,offset HlpTxt
         int       21h
         cli

Konec:
;         mov       al,0edh
;         out       [64h],al
;
;         mov       cx,2000h
;         loop      $
;
;         mov       al,es:[497h]
;         and       al,7
;         out       [64h],al

         sti
         int       20h

UvTxt    db        'SETLOCK V1.20 - nastaveni presmykacu klavesnice; (c) Miroslav Nemecek',13,10
         db        '$'

HlpTxt   db        'zadejte:    N - Num Lock zapnout',13,10
         db        '            n - Num Lock vypnout',13,10
         db        '            C - Caps Lock zapnout',13,10
         db        '            c - Caps Lock vypnout',13,10
         db        '            S - Scroll Lock zapnout',13,10
         db        '            s - Scroll Lock vypnout',13,10
         db        '            X - priznak rozsirene klavesnice 101/102 zapnout',13,10
         db        '            x - priznak rozsirene klavesnice 101/102 vypnout',13,10
         db        '$'

code     ends
         end       start
