; *****************************************************************************
;                    Instalace áeskòch znakñ na displej
; *****************************************************************************
code     segment
         assume    cs:code,ds:code

         org       100h
start:   jmp       instal                   ; instalace programu

old10    dd        0                        ; pñvodn° adresa obsluhy INT 10h

int10i:                                   ;* vol†n° pñvodn° obsluhy INT 10h
         pushf                              ; simulace isntrukce INT xx
         call      dword ptr cs:[old10]     ; nastaven° novÇho videom¢du
         ret

int10:                                      ; obsluha displeje INT 10h
         pushf
         or        ah,ah                    ; je nastaven° m¢du displeje ?
         jz        int103                   ; je nastaven° videom¢du
         cmp       ah,11h
         jne       int102                   ; nen° operace s fonty
         cmp       al,1
         je        int103                   ; naáten° fontu 8x14
         cmp       al,2
         je        int103                   ; naáten° fontu 8x8
         cmp       al,4
         je        int103                   ; naáten° fontu 8x16
         cmp       al,11h
         je        int103                   ; naáten° fontu 8x14
         cmp       al,12h
         je        int103                   ; naáten° fontu 8x8
         cmp       al,14h
         je        int103                   ; naáten° fontu 8x16
int102:  popf                               ; simulace isntrukce INT xx
         jmp       dword ptr cs:[old10]     ; skok na pñvodn° obsluhu INT 10h
int103:                                   ;* nastaven° áeskÇho videom¢du
         popf                               ; n†vrat registru p©°znakñ
         call      int10i                   ; nastaven° novÇho videom¢du

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         push      cs
         pop       es
         mov       ax,40h
         mov       ds,ax                    ; data BIOS
                                          ;* £schova parametrñ displeje
         mov       ah,3
         mov       bh,ds:[62h]              ; aktivn° str†nka displeje
         call      int10i                   ; z°sk†n° pozice a rozmàrñ kurzoru
         push      dx                       ; £schova pozice kurzoru
         push      cx                       ; £schova velikosti kurzoru
                                          ;* rozvàtven° podle m¢dñ
         mov       al,ds:[49h]              ; aktivn° videom¢d
         and       al,7fh
         cmp       al,3
         jbe       int107                   ; je textovò m¢d - OK (instalace)
         cmp       al,7
         je        int107                   ; je MDA m¢d - OK (instalace)

;         cmp       al,15
;         je        int10a
;         cmp       al,16
;         je        int10a

         jmp       int109                   ; nezn†mò videom¢d


;int10a:                                   ;* grafickò m¢d 640x350
 ;        mov       ax,1122h
 ;        mov       bl,2                     ; 25 ©†dkñ
 ;        int       10h                      ; naáten° fontñ ROM 8x14
 ;
 ;        lea       bp,[kam14x]              ; tabulka fontñ
 ;
 ;        push      cs
 ;        pop       es
 ;
 ;        mov       ax,1121h
 ;        xor       dx,dx
 ;        mov       cx,14                    ; 14 bajtñ na znak
 ;        mov       bh,14
 ;        mov       bl,2                     ; 25 ©†dkñ
 ;        call      int10i                   ; naáten° uëivatelskòch fontñ
 ;
 ;        lea       bp,[kam14x]              ; tabulka fontñ
 ;        xor       ax,ax
 ;        mov       es,ax
 ;        mov       es:[110h],bp
 ;        mov       es:[112h],cs
 ;
 ;        jmp       short int109             ; n†vrat parametrñ displeje

int107:                                   ;* inicializace textovòch fontñ

                                          ;* naáten° standardn°ch fontñ
         mov       ax,1114h                 ; p©°kaz pro naáten° fontñ 8x16
         cmp       byte ptr ds:[85h],16     ; je m¢d 16 linek na znak ?
         je        int104                   ; je m¢d 16 linek na znak
         mov       al,12h                   ; p©°kaz pro naáten° fontñ 8x8
         cmp       byte ptr ds:[85h],8      ; je m¢d 8 linek na znak ?
         je        int104                   ; je m¢d 8 linek na znak
         dec       al                       ; p©°kaz pro naáten° fontñ 8x14
int104:  xor       bl,bl                    ; blok fontñ 0
         call      int10i                   ; naáten° standardn°ch fontñ
                                          ;* naáten° uëivatelskòch fontñ
         lea       bp,[kam16]               ; tabulka fontñ 8x16
         mov       bx,1000h                 ; blok 0, 16 bajtñ na znak
         cmp       byte ptr ds:[85h],16     ; je m¢d 16 linek na znak ?
         je        int108                   ; je m¢d 16 linek na znak
         lea       bp,[kam8]                ; tabulka fontñ 8x8
         mov       bh,8                     ; blok 0, 8 bajtñ na znak
         cmp       byte ptr ds:[85h],8      ; je m¢d 8 linek na znak ?
         je        int108                   ; je m¢d 8 linek na znak
         lea       bp,[kam14]               ; tabulka fontñ 8x14
         mov       bh,14                    ; blok 0, 14 bajtñ na znak
int108:  mov       ax,1110h                 ; p©°kaz pro naáten° uëiv. fontñ
         mov       cx,128                   ; poáet znakñ = 128
         mov       dx,128                   ; offset zaá†tku tabulky = 128
         call      int10i                   ; naáten° uëivatelskòch fontñ
int109:                                   ;* n†vrat parametrñ displeje
         pop       cx
         mov       ah,1
         call      int10i                   ; nastaven° velikosti kurzoru
         mov       ah,2
         pop       dx
         mov       bh,ds:[62h]              ; aktivn° str†nka displeje
         call      int10i                   ; nastaven° pñvodn° pozice kurzoru

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret


;kam8x    label     byte
;
;         db        0,0,0,0,0,0,0,0                         ; 0
;         db        7eh,0c3h,0a5h,81h,0a5h,99h,0c3h,7eh     ; 1
;         db        7eh,0ffh,0dbh,0ffh,0dbh,0e7h,0ffh,7eh   ; 2
;         db        0,6ch,0feh,0feh,7ch,38h,10h,0           ; 3
;         db        0,10h,38h,7ch,0feh,7ch,38h,10h          ; 4
;         db        0,38h,38h,0d6h,0feh,0d6h,10h,38h        ; 5
;         db        0,10h,38h,7ch,0feh,0d6h,10h,38h         ; 6
;         db        0,0,18h,3ch,3ch,18h,0,0                 ; 7
;         db        0ffh,0ffh,0e7h,0c3h,0c3h,0e7h,0ffh,0ffh ; 8
;         db        0,3ch,66h,42h,42h,66h,3ch,0             ; 9
;         db        0ffh,0c3h,99h,0bdh,0bdh,99h,0c3h,0ffh   ; 10
;         db        0fh,7,0fh,7dh,0cch,0cch,0cch,78h        ; 11
;         db        3ch,66h,66h,66h,3ch,18h,7eh,18h         ; 12
;         db        30h,38h,3ch,34h,30h,0d0h,0f0h,60h       ; 13
;         db        3fh,33h,3fh,33h,33h,0ddh,0ffh,66h       ; 14
;         db        99h,5ah,24h,0c3h,0c3h,24h,5ah,99h       ; 15
;         db        40h,70h,7ch,7eh,7ch,70h,40h,0           ; 16
;         db        2h,0eh,3eh,7eh,3eh,0eh,2,0              ; 17
;         db        18h,3ch,7eh,18h,18h,7eh,3ch,18h         ; 18
;         db        6ch,6ch,6ch,6ch,6ch,0,6ch,0             ; 19
;         db        7eh,0f4h,0f4h,74h,34h,34h,34h,0         ; 20
;         db        3ch,60h,38h,6ch,6ch,38h,0ch,78h         ; 21  " "
;         db        0,0,0,0,7eh,7eh,7eh,0                   ; 22
;         db        18h,3ch,7eh,18h,7eh,3ch,18h,7eh         ; 23
;         db        18h,3ch,7eh,18h,18h,18h,18h,18h         ; 24
;         db        18h,18h,18h,18h,18h,7eh,3ch,18h         ; 25
;         db        0,4,6,0ffh,0ffh,6,4,0                   ; 26
;         db        0,20h,60h,0ffh,0ffh,60h,20h,0           ; 27
;         db        0,60h,60h,60h,60h,7eh,0,0               ; 28
;         db        0,24h,66h,0ffh,0ffh,66h,24h,0           ; 29
;         db        0,8,1ch,3eh,7fh,7fh,7fh,0               ; 30
;         db        0,7fh,7fh,7fh,3eh,1ch,8,0               ; 31
;         db        0,0,0,0,0,0,0,0                         ; 32  " "
;         db        18h,18h,18h,18h,18h,0,18h,0             ; 33  "!"
;         db        6ch,6ch,6ch,0,0,0,0,0                   ; 34  "
;         db        6ch,6ch,0feh,6ch,0feh,6ch,6ch,0         ; 35  "#"
;         db        18h,3eh,58h,3ch,1ah,7ch,18h,0           ; 36  "$"
;         db        0,63h,66h,0ch,18h,33h,63h,0             ; 37  "%"
;         db        1ch,36h,1ch,3bh,6eh,66h,3bh,0           ; 38  "&"
;         db        18h,18h,30h,0,0,0,0,0                   ; 39  "'"
;         db        0ch,18h,30h,30h,30h,18h,0ch,0           ; 40  "("
;         db        30h,18h,0ch,0ch,0ch,18h,30h,0           ; 41  ")"
;         db        0,66h,3ch,0ffh,3ch,66h,0,0              ; 42  "*"
;         db        0,18h,18h,7eh,18h,18h,0,0               ; 43  "+"
;         db        0,0,0,0,0,18h,18h,30h                   ; 44  ","
;         db        0,0,0,7eh,0,0,0,0                       ; 45  "-"
;         db        0,0,0,0,0,18h,18h,0                     ; 46  "."
;         db        6h,0ch,18h,30h,60h,0c0h,80h,0           ; 47  "/"
;         db        7ch,0c6h,0ceh,0d6h,0e6h,0c6h,7ch,0      ; 48  "0"
;         db        18h,38h,18h,18h,18h,18h,18h,0           ; 49  "1"
;         db        3ch,66h,6,0ch,18h,30h,7eh,0             ; 50  "2"
;         db        3ch,66h,6,1ch,6,66h,3ch,0               ; 51  "3"
;         db        1ch,3ch,6ch,0cch,0feh,0ch,0ch,0         ; 52  "4"
;         db        7eh,60h,7ch,6,6,66h,3ch,0               ; 53  "5"
;         db        3ch,66h,60h,7ch,66h,66h,3ch,0           ; 54  "6"
;         db        7eh,6,6,0ch,18h,18h,18h,0               ; 55  "7"
;         db        3ch,66h,66h,3ch,66h,66h,3ch,0           ; 56  "8"
;         db        3ch,66h,66h,3eh,0ch,18h,30h,0           ; 57  "9"
;         db        0,0,18h,18h,0,18h,18h,0                 ; 58  ":"
;         db        0,0,18h,18h,0,18h,18h,30h               ; 59  ";"
;         db        0ch,18h,30h,60h,30h,18h,0ch,0           ; 60  "<"
;         db        0,0,7eh,0,0,7eh,0,0                     ; 61  "="
;         db        60h,30h,18h,0ch,18h,30h,60h,0           ; 62  ">"
;         db        3ch,66h,6,0ch,18h,0,18h,0               ; 63  "?"
;         db        7ch,0c6h,0deh,0deh,0deh,0c0h,7ch,0      ; 64  "@"
;         db        38h,6ch,0c6h,0c6h,0feh,0c6h,0c6h,0      ; 65  "A"
;         db        0fch,0c6h,0c6h,0fch,0c6h,0c6h,0fch,0    ; 66  "B"
;         db        3ch,66h,0c0h,0c0h,0c0h,66h,3ch,0        ; 67  "C"
;         db        0f8h,0cch,0c6h,0c6h,0c6h,0cch,0f8h,0    ; 68  "D"
;         db        0feh,0c0h,0c0h,0f8h,0c0h,0c0h,0feh,0    ; 69  "E"
;         db        0feh,0c0h,0c0h,0f8h,0c0h,0c0h,0c0h,0    ; 70  "F"
;         db        3ch,66h,0c0h,0c0h,0ceh,66h,3eh,0        ; 71  "G"
;         db        0c6h,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,0    ; 72  "H"
;         db        78h,30h,30h,30h,30h,30h,78h,0           ; 73  "I"
;         db        6h,6,6,6,0c6h,0c6h,7ch,0                ; 74  "J"
;         db        0c6h,0cch,0d8h,0f0h,0d8h,0cch,0c6h,0    ; 75  "K"
;         db        0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0feh,0    ; 76  "L"
;         db        0c6h,0eeh,0feh,0d6h,0c6h,0c6h,0c6h,0    ; 77  "M"
;         db        0c6h,0e6h,0f6h,0deh,0ceh,0c6h,0c6h,0    ; 78  "N"
;         db        38h,6ch,0c6h,0c6h,0c6h,6ch,38h,0        ; 79  "O"
;         db        0fch,0c6h,0c6h,0fch,0c0h,0c0h,0c0h,0    ; 80  "P"
;         db        38h,6ch,0c6h,0c6h,0dah,6ch,36h,0        ; 81  "Q"
;         db        0fch,0c6h,0c6h,0fch,0cch,0c6h,0c6h,0    ; 82  "R"
;         db        7ch,0c6h,0c0h,7ch,6,0c6h,7ch,0          ; 83  "S"
;         db        0fch,30h,30h,30h,30h,30h,30h,0          ; 84  "T"
;         db        0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,7ch,0     ; 85  "U"
;         db        0c6h,0c6h,0c6h,0c6h,0c6h,6ch,38h,0      ; 86  "V"
;         db        0c6h,0c6h,0c6h,0d6h,0feh,0eeh,0c6h,0    ; 87  "W"
;         db        0c6h,0c6h,6ch,38h,6ch,0c6h,0c6h,0       ; 88  "X"
;         db        66h,66h,66h,3ch,18h,18h,18h,0           ; 89  "Y"
;         db        0feh,6,0ch,18h,30h,60h,0feh,0           ; 90  "Z"
;         db        3ch,30h,30h,30h,30h,30h,3ch,0           ; 91  "["
;         db        0c0h,60h,30h,18h,0ch,6,2,0              ; 92  "\"
;         db        3ch,0ch,0ch,0ch,0ch,0ch,3ch,0           ; 93  "]"
;         db        8h,1ch,36h,63h,0,0,0,0                  ; 94  "^"
;         db        0,0,0,0,0,0,0,0ffh                      ; 95  "_"
;         db        30h,18h,0ch,0,0,0,0,0                   ; 96  "`"
;         db        0,0,7ch,6,7eh,0c6h,7eh,0                ; 97  "a"
;         db        0c0h,0c0h,0fch,0c6h,0c6h,0c6h,0fch,0    ; 98  "b"
;         db        0,0,7ch,0c6h,0c0h,0c6h,7ch,0            ; 99  "c"
;         db        6h,6,7eh,0c6h,0c6h,0c6h,7eh,0           ; 100 "d"
;         db        0,0,7ch,0c6h,0feh,0c0h,7ch,0            ; 101 "e"
;         db        3ch,66h,60h,0f8h,60h,60h,60h,0          ; 102 "f"
;         db        0,0,7eh,0c6h,0c6h,7eh,6,0fch            ; 103 "g"
;         db        0c0h,0c0h,0fch,0c6h,0c6h,0c6h,0c6h,0    ; 104 "h"
;         db        18h,0,18h,18h,18h,18h,18h,0             ; 105 "i"
;         db        0ch,0,0ch,0ch,0ch,0ch,0cch,78h          ; 106 "j"
;         db        0c0h,0c0h,0c6h,0cch,0f8h,0cch,0c6h,0    ; 107 "k"
;         db        18h,18h,18h,18h,18h,18h,18h,0           ; 108 "l"
;         db        0,0,6ch,0feh,0d6h,0c6h,0c6h,0           ; 109 "m"
;         db        0,0,0fch,0c6h,0c6h,0c6h,0c6h,0          ; 110 "n"
;         db        0,0,7ch,0c6h,0c6h,0c6h,7ch,0            ; 111 "o"
;         db        0,0,0fch,0c6h,0c6h,0fch,0c0h,0c0h       ; 112 "p"
;         db        0,0,7eh,0c6h,0c6h,7eh,6,6               ; 113 "q"
;         db        0,0,0fch,0c6h,0c0h,0c0h,0c0h,0          ; 114 "r"
;         db        0,0,7ch,0c0h,7ch,6,0fch,0               ; 115 "s"
;         db        60h,60h,0fch,60h,60h,66h,3ch,0          ; 116 "t"
;         db        0,0,0c6h,0c6h,0c6h,0c6h,7eh,0           ; 117 "u"
;         db        0,0,0c6h,0c6h,0c6h,6ch,38h,0            ; 118 "v"
;         db        0,0,0c6h,0c6h,0d6h,0feh,6ch,0           ; 119 "w"
;         db        0,0,0c6h,6ch,38h,6ch,0c6h,0             ; 120 "x"
;         db        0,0,0c6h,0c6h,0c6h,7eh,6,0fch           ; 121 "y"
;         db        0,0,7eh,0ch,18h,30h,7eh,0               ; 122 "z"
;         db        0eh,18h,18h,70h,18h,18h,0eh,0           ; 123 "{"
;         db        18h,18h,18h,0,18h,18h,18h,0             ; 124 "|"
;         db        70h,18h,18h,0eh,18h,18h,70h,0           ; 125 "}"
;         db        32h,4ch,0,0,0,0,0,0                     ; 126 "~"
;         db        0,18h,3ch,66h,0c3h,0c3h,0ffh,0          ; 127 ""

kam8     label     byte                   ;* fonty 8*8

         db        3ch,66h,0c0h,0c0h,66h,3ch,18h,38h       ; 128 "C" s oc†skem
         db        66h,0,0c6h,0c6h,0c6h,0c6h,7eh,0         ; 129 "Å"
         db        0ch,18h,7ch,0c6h,0feh,0c0h,7ch,0        ; 130 "Ç"
         db        7eh,0,7ch,6,7eh,0c6h,7eh,0              ; 131 "a" se st©°®kou
         db        66h,0,7ch,6,7eh,0c6h,7eh,0              ; 132 "Ñ"
         db        3ch,66h,3ch,0c6h,0c6h,0c6h,7eh,0        ; 133 "ñ"
         db        6,0ch,7ch,0c6h,0c0h,0c6h,7ch,0          ; 134 "c" s á†rkou
         db        0,7ch,0c6h,0c0h,0c6h,7ch,18h,38h        ; 135 "c" s oc†skem
         db        18h,18h,18h,1ch,38h,18h,18h,0           ; 136 "l" p©e®ktnutÇ
         db        66h,0,7ch,0c6h,0feh,0c0h,7ch,0          ; 137 "e" p©ehlasovanÇ
         db        66h,38h,6ch,0c6h,0c6h,6ch,38h,0         ; 138 "O" se 2 á†rkama
         db        66h,0,7ch,0c6h,0c6h,0c6h,7ch,0          ; 139 "o" se 2 á†rkama
         db        3ch,66h,18h,18h,18h,18h,18h,0           ; 140 "i" se st©°®kou
         db        0ch,0feh,0ch,18h,30h,60h,0feh,0         ; 141 "Z" s á†rkou
         db        0c6h,38h,6ch,0c6h,0feh,0c6h,0c6h,0      ; 142 "é"
         db        6,3ch,66h,0c0h,0c0h,66h,3ch,0           ; 143 "C" s á†rkou
         db        0ch,18h,7eh,60h,78h,60h,7eh,0           ; 144 "ê"
         db        0cch,0cch,0d8h,0c0h,0c0h,0c0h,0feh,0    ; 145 "ä"
         db        1bh,1bh,18h,18h,18h,18h,18h,0           ; 146 "ç"
         db        38h,06ch,0,7ch,0c6h,0c6h,7ch,0          ; 147 "ì"
         db        0c6h,0,7ch,0c6h,0c6h,0c6h,7ch,0         ; 148 "î"
         db        0dbh,0ceh,0c0h,0c0h,0c0h,0c0h,0feh,0    ; 149 "ú"
         db        35h,32h,30h,30h,30h,30h,30h,0           ; 150 "å"
         db        0ch,7eh,0c0h,7ch,6,0c6h,7ch,0           ; 151 "S" s á†rkou
         db        06h,0ch,7eh,0c0h,7ch,6,0fch,0           ; 152 "s" s á†rkou
         db        0c6h,38h,6ch,0c6h,0c6h,6ch,38h,0        ; 153 "ô"
         db        0c6h,0,0c6h,0c6h,0c6h,0c6h,7ch,0        ; 154 "ö"
         db        66h,3ch,7eh,18h,18h,18h,18h,0           ; 155 "Ü"
         db        66h,66h,0f4h,60h,60h,66h,3ch,0          ; 156 "ü"
         db        0f0h,060h,060h,070h,0e0h,062h,0feh,0    ; 157 "L" p©e®krtnutÇ
         db        0,0,0c6h,6ch,38h,6ch,0c6h,0             ; 158 "x"
         db        66h,3ch,7ch,0c6h,0c0h,0c6h,7ch,0        ; 159 "á"
         db        0ch,18h,7ch,6,7eh,0c6h,7eh,0            ; 160 "†"
         db        0ch,18h,0,18h,18h,18h,18h,0             ; 161 "°"
         db        0ch,18h,0,7ch,0c6h,0c6h,7ch,0           ; 162 "¢"
         db        18h,30h,0,0c6h,0c6h,0c6h,7eh,0          ; 163 "£"
         db        38h,6ch,0c6h,0c6h,0feh,0c6h,0ceh,0ch    ; 164 "A" s noëiákou
         db        0,0,7ch,6,7eh,0c6h,7eh,18h              ; 165 "a" s noëiákou
         db        6ch,0feh,0ch,18h,30h,60h,0feh,0         ; 166 "í"
         db        66h,3ch,7eh,0ch,18h,30h,7eh,0           ; 167 "ë"
         db        0feh,0c0h,0c0h,0f8h,0c0h,0c0h,0feh,0ch  ; 168 "E" s noëiákou
         db        0,0,7ch,0c6h,0feh,0c0h,7ch,0ch          ; 169 "e" s noëiákou
         db        0,0,0,7eh,6,6,0,0                       ; 170 "-" zalomen†
         db        6,0ch,7eh,0ch,18h,30h,7eh,0             ; 171 "z" s á†rkou
         db        66h,3ch,66h,0c0h,0c0h,66h,3ch,0         ; 172 "Ä"
         db        0,0,7ch,0c0h,7ch,6,0fch,0ch             ; 173 "s" s oc†skem
         db        0,36h,6ch,0d8h,6ch,36h,0,0              ; 174 "Æ"
         db        0,0d8h,6ch,36h,6ch,0d8h,0,0             ; 175 "Ø"
         db        22h,88h,22h,88h,22h,88h,22h,88h         ; 176 "∞"
         db        55h,0aah,55h,0aah,55h,0aah,55h,0aah     ; 177 "±"
         db        0ddh,77h,0ddh,77h,0ddh,77h,0ddh,77h     ; 178 "≤"
         db        18h,18h,18h,18h,18h,18h,18h,18h         ; 179 "≥"
         db        18h,18h,18h,18h,0f8h,18h,18h,18h        ; 180 "¥"
         db        13h,3bh,6ch,0c6h,0feh,0c6h,0c6h,0       ; 181 "è"
         db        7ch,38h,6ch,0c6h,0feh,0c6h,0c6h,0       ; 182 "A" se st©°®kou
         db        0cch,78h,0fch,0c0h,0f0h,0c0h,0fch,0     ; 183 "â"
         db        7ch,0c6h,0c0h,7ch,6,0c6h,7ch,0ch        ; 184 "S" s oc†skem
         db        66h,66h,0e6h,6,0e6h,66h,66h,66h         ; 185 "π"
         db        66h,66h,66h,66h,66h,66h,66h,66h         ; 186 "∫"
         db        0,0,0feh,6,0e6h,66h,66h,66h             ; 187 "ª"
         db        66h,66h,0e6h,6,0feh,0,0,0               ; 188 "º"
         db        0ch,0feh,0ch,18h,30h,60h,0feh,0         ; 189 "Z" s teákou
         db        0ch,0,7eh,0ch,18h,30h,7eh,0             ; 190 "z" s teákou
         db        0,0,0,0,0f8h,18h,18h,18h                ; 191 "ø"
         db        18h,18h,18h,18h,1fh,0,0,0               ; 192 "¿"
         db        18h,18h,18h,18h,0ffh,0,0,0              ; 193 "¡"
         db        0,0,0,0,0ffh,18h,18h,18h                ; 194 "¬"
         db        18h,18h,18h,18h,1fh,18h,18h,18h         ; 195 "√"
         db        0,0,0,0,0ffh,0,0,0                      ; 196 "ƒ"
         db        18h,18h,18h,18h,0ffh,18h,18h,18h        ; 197 "≈"
         db        7ch,38h,6ch,0c6h,0feh,0c6h,0c6h,0       ; 198 "A" s h†ákem
         db        6ch,38h,7ch,6,7eh,0c6h,7eh,0            ; 199 "a" s h†ákem
         db        66h,66h,67h,60h,7fh,0,0,0               ; 200 "»"
         db        0,0,7fh,60h,67h,66h,66h,66h             ; 201 "…"
         db        66h,66h,0e7h,0,0ffh,0,0,0               ; 202 " "
         db        0,0,0ffh,0,0e7h,66h,66h,66h             ; 203 "À"
         db        66h,66h,67h,60h,67h,66h,66h,66h         ; 204 "Ã"
         db        0,0,0ffh,0,0ffh,0,0,0                   ; 205 "Õ"
         db        66h,66h,0e7h,0,0e7h,66h,66h,66h         ; 206 "Œ"
         db        0,0,0c6h,7ch,48h,7ch,0c6h,0             ; 207 "x" s d°rou
         db        6,0fh,6,7eh,0c6h,0c6h,7eh,0             ; 208 "d" p©e®krtnutÇ
         db        0f8h,06ch,066h,076h,0e6h,06ch,0f8h,0    ; 209 "D" p©e®krnutÇ
         db        0cch,78h,0f8h,0cch,0c6h,0cch,0f8h,0     ; 210 "Ö"
         db        66h,0,0feh,0c0h,0f8h,0c0h,0feh,0        ; 211 "E" p©ehlasovanÇ
         db        96h,66h,6,7eh,0c6h,0c6h,7eh,0           ; 212 "É"
         db        66h,3ch,0e6h,0f6h,0deh,0ceh,0c6h,0      ; 213 "•"
         db        0ch,18h,3ch,18h,18h,18h,3ch,0           ; 214 "ã"
         db        7eh,0c3h,3ch,18h,18h,18h,3ch,0          ; 215 "I" se st©°®kou
         db        66h,3ch,7ch,0c6h,0feh,0c0h,7ch,0        ; 216 "à"
         db        18h,18h,18h,18h,0f8h,0,0,0              ; 217 "Ÿ"
         db        0,0,0,0,1fh,18h,18h,18h                 ; 218 "⁄"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh ; 219 "€"
         db        0,0,0,0,0ffh,0ffh,0ffh,0ffh             ; 220 "‹"
         db        0fch,30h,30h,30h,30h,30h,38h,8          ; 221 "T" s oc†skem
         db        18h,0a4h,0dah,0c6h,0c6h,0c6h,7ch,0      ; 222 "¶"
         db        0ffh,0ffh,0ffh,0ffh,0,0,0,0             ; 223 "ﬂ"
         db        3h,3bh,6ch,0c6h,0c6h,6ch,38h,0          ; 224 "ï"
         db        3ch,66h,7ch,66h,66h,7ch,60h,60h         ; 225 "·"
         db        7ch,82h,38h,6ch,0c6h,6ch,38h,0          ; 226 "ß"
         db        0deh,0e6h,0f6h,0deh,0ceh,0c6h,0c6h,0    ; 227 "N" s á†rkou
         db        06h,0ch,0fch,0c6h,0c6h,0c6h,0c6h,0      ; 228 "n" s á†rkou
         db        6ch,38h,0fch,0c6h,0c6h,0c6h,0c6h,0      ; 229 "§"
         db        24h,7eh,0c0h,7ch,6,0c6h,7ch,0           ; 230 "õ"
         db        66h,3ch,7eh,0c0h,7ch,6,0fch,0           ; 231 "®"
         db        18h,30h,0fch,0c6h,0fch,0c6h,0c6h,0      ; 232 "´"
         db        0ch,0dah,0c6h,0c6h,0c6h,0c6h,7ch,0      ; 233 "ó"
         db        18h,30h,0dch,0e6h,0c0h,0c0h,0c0h,0      ; 234 "™"
         db        0c6h,0,0c6h,0c6h,0c6h,0c6h,7ch,0        ; 235 "U" se 2 á†rkama
         db        0ch,18h,0c6h,0c6h,0c6h,7eh,6,0fch       ; 236 "ò"
         db        0ch,5ah,66h,3ch,18h,18h,18h,0           ; 237 "ù"
         db        60h,60h,0fch,60h,60h,66h,3ch,0ch        ; 238 "t" s oc†skem
         db        0ch,18h,30h,0,0,0,0,0                   ; 239 "'"
         db        0,0,0,70h,0,0,0,0                       ; 240 "-" kr†tk†
         db        33h,66h,0cch,0,0,0,0,0                  ; 241 " 2 á†rky
         db        0,0,0,0,30h,30h,3ch,0                   ; 242 patiáka
         db        0,66h,3ch,0,0,0,0,0                     ; 243 h†áek
         db        0,0c6h,7ch,0,0,0,0,0                    ; 244 miska
         db        3ch,60h,38h,6ch,6ch,38h,0ch,78h         ; 245 "≠" paragraf
         db        0,18h,0,7eh,0,18h,0,0                   ; 246 "ˆ"
         db        0,0,0,0,0,30h,18h,70h                   ; 247 oc†sek
         db        0,3ch,66h,66h,3ch,0,0,0                 ; 248 "¯"
         db        0,66h,0,0,0,0,0,0                       ; 249 "˘" dvojteáka
         db        0,0,0,18h,18h,0,0,0                     ; 250 "˘"
         db        0c6h,0,0c6h,0c6h,0c6h,0c6h,7eh,0        ; 251 "u" p©ehlasovanÇ
         db        0cch,78h,0fch,0c6h,0fch,0c6h,0c6h,0     ; 252 "û"
         db        0cch,78h,0fch,0c6h,0c0h,0c0h,0c0h,0     ; 253 "©"
         db        0,0,78h,78h,78h,78h,0,0                 ; 254 "˛"
         db        0,0,0,0,0,0,0,0                         ; 255



;kam14x   label     byte
;
;         db        0,0,0,0,0,0,0                           ; 0
;         db        0,0,0,0,0,0,0
;         db        0,0,7eh,81h,0a5h,81h,81h                ; 1
;         db        0bdh,99h,81h,7eh,0,0,0
;         db        0,0,7eh,0ffh,0dbh,0ffh,0ffh             ; 2
;         db        0c3h,0e7h,0ffh,7eh,0,0,0
;         db        0,0,0,6ch,0feh,0feh,0feh                ; 3
;         db        0feh,7ch,38h,10h,0,0,0
;         db        0,0,0,10h,38h,7ch,0feh                  ; 4
;         db        7ch,38h,10h,0,0,0,0
;         db        0,0,18h,3ch,3ch,0e7h,0e7h               ; 5
;         db        0e7h,18h,18h,3ch,0,0,0
;         db        0,0,18h,3ch,7eh,0ffh,0ffh               ; 6
;         db        7eh,18h,18h,3ch,0,0,0
;         db        0,0,0,0,0,18h,3ch                       ; 7
;         db        3ch,18h,0,0,0,0,0
;         db        0ffh,0ffh,0ffh,0ffh,0ffh,0e7h,0c3h      ; 8
;         db        0c3h,0e7h,0ffh,0ffh,0ffh,0ffh,0ffh
;         db        0,0,0,0,3ch,66h,42h                     ; 9
;         db        42h,66h,3ch,0,0,0,0
;         db        0ffh,0ffh,0ffh,0ffh,0c3h,99h,0bdh       ; 10
;         db        0bdh,99h,0c3h,0ffh,0ffh,0ffh,0ffh
;         db        0,0,1eh,0eh,1ah,32h,78h                 ; 11
;         db        0cch,0cch,0cch,78h,0,0,0
;         db        0,0,3ch,66h,66h,66h,3ch                 ; 12
;         db        18h,7eh,18h,18h,0,0,0
;         db        0,0,3fh,33h,3fh,30h,30h                 ; 13
;         db        30h,70h,0f0h,0e0h,0,0,0
;         db        0,0,7fh,63h,7fh,63h,63h                 ; 14
;         db        63h,67h,0e7h,0e6h,0c0h,0,0
;         db        0,0,18h,18h,0dbh,3ch,0e7h               ; 15
;         db        3ch,0dbh,18h,18h,0,0,0
;         db        0,0,80h,0c0h,0e0h,0f8h,0feh             ; 16
;         db        0f8h,0e0h,0c0h,80h,0,0,0
;         db        0,0,2,6,0eh,3eh,0feh                    ; 17
;         db        3eh,0eh,6,2,0,0,0
;         db        0,0,18h,3ch,7eh,18h,18h                 ; 18
;         db        18h,7eh,3ch,18h,0,0,0
;         db        0,0,66h,66h,66h,66h,66h                 ; 19
;         db        66h,0,66h,66h,0,0,0
;         db        0,0,7fh,0dbh,0dbh,0dbh,7bh              ; 20
;         db        1bh,1bh,1bh,1bh,0,0,0
;         db        0,7ch,0c6h,60h,38h,6ch,0c6h             ; 21  " "
;         db        0c6h,6ch,38h,0ch,0c6h,7ch,0
;         db        0,0,0,0,0,0,0                           ; 22
;         db        0,0feh,0feh,0feh,0,0,0
;         db        0,0,18h,3ch,7eh,18h,18h                 ; 23
;         db        18h,7eh,3ch,18h,7eh,0,0
;         db        0,0,18h,3ch,7eh,18h,18h                 ; 24
;         db        18h,18h,18h,18h,0,0,0
;         db        0,0,18h,18h,18h,18h,18h                 ; 25
;         db        18h,7eh,3ch,18h,0,0,0
;         db        0,0,0,0,18h,0ch,0feh                    ; 26
;         db        0ch,18h,0,0,0,0,0
;         db        0,0,0,0,30h,60h                         ; 27
;         db        0feh,60h,30h,0,0,0,0,0
;         db        0,0,0,0,0,0c0h,0c0h                     ; 28
;         db        0c0h,0feh,0,0,0,0,0
;         db        0,0,0,0,28h,6ch,0feh                    ; 29
;         db        6ch,28h,0,0,0,0,0
;         db        0,0,0,10h,38h,38h,7ch                   ; 30
;         db        7ch,0feh,0feh,0,0,0,0
;         db        0,0,0,0feh,0feh,7ch,7ch                 ; 31
;         db        38h,38h,10h,0,0,0,0
;         db        0,0,0,0,0,0,0                           ; 32  " "
;         db        0,0,0,0,0,0,0
;         db        0,0,18h,3ch,3ch,3ch,18h                 ; 33  "!"
;         db        18h,0,18h,18h,0,0,0
;         db        0,66h,66h,66h,24h,0,0                   ; 34  "
;         db        0,0,0,0,0,0,0
;         db        0,0,6ch,6ch,0feh,6ch,6ch                ; 35  "#"
;         db        6ch,0feh,6ch,6ch,0,0,0
;         db        18h,18h,7ch,0c6h,0c2h,0c0h,7ch          ; 36  "$"
;         db        6,86h,0c6h,7ch,18h,18h,0
;         db        0,0,0,0,0c2h,0c6h,0ch                   ; 37  "%"
;         db        18h,30h,66h,0c6h,0,0,0
;         db        0,0,38h,6ch,6ch,38h,76h                 ; 38  "&"
;         db        0dch,0cch,0cch,76h,0,0,0
;         db        0,30h,30h,30h,60h,0,0                   ; 39  "'"
;         db        0,0,0,0,0,0,0
;         db        0,0,0ch,18h,30h,30h,30h                 ; 40  "("
;         db        30h,30h,18h,0ch,0,0,0
;         db        0,0,30h,18h,0ch,0ch,0ch                 ; 41  ")"
;         db        0ch,0ch,18h,30h,0,0,0
;         db        0,0,0,0,66h,3ch,0ffh                    ; 42  "*"
;         db        3ch,66h,0,0,0,0,0
;         db        0,0,0,0,18h,18h,7eh                     ; 43  "+"
;         db        18h,18h,0,0,0,0,0
;         db        0,0,0,0,0,0,0                           ; 44  ","
;         db        0,18h,18h,18h,30h,0,0
;         db        0,0,0,0,0,0                             ; 45  "-"
;         db        0feh,0,0,0,0,0,0,0
;         db        0,0,0,0,0,0,0                           ; 46  "."
;         db        0,0,18h,18h,0,0,0
;         db        0,0,2,6,0ch,18h,30h                     ; 47  "/"
;         db        60h,0c0h,80h,0,0,0,0
;         db        0,0,7ch,0c6h,0ceh,0deh,0f6h             ; 48  "0"
;         db        0e6h,0c6h,0c6h,7ch,0,0,0
;         db        0,0,18h,38h,78h,18h,18h                 ; 49  "1"
;         db        18h,18h,18h,7eh,0,0,0
;         db        0,0,7ch,0c6h,6,0ch,18h                  ; 50  "2"
;         db        30h,60h,0c6h,0feh,0,0,0
;         db        0,0,7ch,0c6h,6,6,3ch                    ; 51  "3"
;         db        6,6,0c6h,7ch,0,0,0
;         db        0,0,0ch,1ch,3ch,6ch,0cch                ; 52  "4"
;         db        0feh,0ch,0ch,1eh,0,0,0
;         db        0,0,0feh,0c0h,0c0h,0c0h,0fch            ; 53  "5"
;         db        6,6,0c6h,7ch,0,0,0
;         db        0,0,38h,60h,0c0h,0c0h,0fch              ; 54  "6"
;         db        0c6h,0c6h,0c6h,7ch,0,0,0
;         db        0,0,0feh,0c6h,6,0ch,18h                 ; 55  "7"
;         db        30h,30h,30h,30h,0,0,0
;         db        0,0,7ch,0c6h,0c6h,0c6h,7ch              ; 56  "8"
;         db        0c6h,0c6h,0c6h,7ch,0,0,0
;         db        0,0,7ch,0c6h,0c6h,0c6h,7eh              ; 57  "9"
;         db        6,6,0ch,78h,0,0,0
;         db        0,0,0,18h,18h,0,0                       ; 58  ":"
;         db        0,18h,18h,0,0,0,0
;         db        0,0,0,18h,18h,0,0                       ; 59  ";"
;         db        0,18h,18h,30h,0,0,0
;         db        0,0,6,0ch,18h,30h,60h                   ; 60  "<"
;         db        30h,18h,0ch,6,0,0,0
;         db        0,0,0,0,0,7eh,0                         ; 61  "="
;         db        0,7eh,0,0,0,0,0
;         db        0,0,60h,30h,18h,0ch,6                   ; 62  ">"
;         db        0ch,18h,30h,60h,0,0,0
;         db        0,0,7ch,0c6h,0c6h,0ch,18h               ; 63  "?"
;         db        18h,0,18h,18h,0,0,0
;         db        0,0,7ch,0c6h,0c6h,0deh,0deh             ; 64  "@"
;         db        0deh,0dch,0c0h,7ch,0,0,0
;         db        0,0,10h,38h,6ch,0c6h,0c6h               ; 65  "A"
;         db        0feh,0c6h,0c6h,0c6h,0,0,0
;         db        0,0,0fch,66h,66h,66h,7ch                ; 66  "B"
;         db        66h,66h,66h,0fch,0,0,0
;         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 67  "C"
;         db        0c0h,0c2h,66h,3ch,0,0,0
;         db        0,0,0f8h,6ch,66h,66h,66h                ; 68  "D"
;         db        66h,66h,6ch,0f8h,0,0,0
;         db        0,0,0feh,66h,62h,68h,78h                ; 69  "E"
;         db        68h,62h,66h,0feh,0,0,0
;         db        0,0,0feh,66h,62h,68h,78h                ; 70  "F"
;         db        68h,60h,60h,0f0h,0,0,0
;         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 71  "G"
;         db        0deh,0c6h,66h,3ah,0,0,0
;         db        0,0,0c6h,0c6h,0c6h,0c6h,0feh            ; 72  "H"
;         db        0c6h,0c6h,0c6h,0c6h,0,0,0
;         db        0,0,3ch,18h,18h,18h,18h                 ; 73  "I"
;         db        18h,18h,18h,3ch,0,0,0
;         db        0,0,1eh,0ch,0ch,0ch,0ch                 ; 74  "J"
;         db        0ch,0cch,0cch,78h,0,0,0
;         db        0,0,0e6h,66h,6ch,6ch,78h                ; 75  "K"
;         db        6ch,6ch,66h,0e6h,0,0,0
;         db        0,0,0f0h,60h,60h,60h,60h                ; 76  "L"
;         db        60h,62h,66h,0feh,0,0,0
;         db        0,0,0c6h,0eeh,0feh,0feh,0d6h            ; 77  "M"
;         db        0c6h,0c6h,0c6h,0c6h,0,0,0
;         db        0,0,0c6h,0e6h,0f6h,0feh,0deh            ; 78  "N"
;         db        0ceh,0c6h,0c6h,0c6h,0,0,0
;         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 79  "O"
;         db        0c6h,0c6h,6ch,38h,0,0,0
;         db        0,0,0fch,66h,66h,66h,7ch                ; 80  "P"
;         db        60h,60h,60h,0f0h,0,0,0
;         db        0,0,7ch,0c6h,0c6h,0c6h,0c6h             ; 81  "Q"
;         db        0d6h,0deh,7ch,0ch,0eh,0,0
;         db        0,0,0fch,66h,66h,66h,7ch                ; 82  "R"
;         db        6ch,66h,66h,0e6h,0,0,0
;         db        0,0,7ch,0c6h,0c6h,60h,38h               ; 83  "S"
;         db        0ch,0c6h,0c6h,7ch,0,0,0
;         db        0,0,7eh,7eh,5ah,18h,18h                 ; 84  "T"
;         db        18h,18h,18h,3ch,0,0,0
;         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 85  "U"
;         db        0c6h,0c6h,0c6h,7ch,0,0,0
;         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 86  "V"
;         db        0c6h,6ch,38h,10h,0,0,0
;         db        0,0,0c6h,0c6h,0c6h,0c6h,0d6h            ; 87  "W"
;         db        0d6h,0feh,7ch,6ch,0,0,0
;         db        0,0,0c6h,0c6h,6ch,38h,38h               ; 88  "X"
;         db        38h,6ch,0c6h,0c6h,0,0,0
;         db        0,0,66h,66h,66h,66h,3ch                 ; 89  "Y"
;         db        18h,18h,18h,3ch,0,0,0
;         db        0,0,0feh,0c6h,8ch,18h,30h               ; 90  "Z"
;         db        60h,0c2h,0c6h,0feh,0,0,0
;         db        0,0,3ch,30h,30h,30h,30h                 ; 91  "["
;         db        30h,30h,30h,3ch,0,0,0
;         db        0,0,80h,0c0h,0e0h,70h,38h               ; 92  "\"
;         db        1ch,0eh,6,2,0,0,0
;         db        0,0,3ch,0ch,0ch,0ch,0ch                 ; 93  "]"
;         db        0ch,0ch,0ch,3ch,0,0,0
;         db        10h,38h,6ch,0c6h,0,0,0                  ; 94  "^"
;         db        0,0,0,0,0,0,0
;         db        0,0,0,0,0,0,0                           ; 95  "_"
;         db        0,0,0,0,0,0ffh,0
;         db        30h,30h,18h,0,0,0,0                     ; 96  "`"
;         db        0,0,0,0,0,0,0
;         db        0,0,0,0,0,78h,0ch                       ; 97  "a"
;         db        7ch,0cch,0cch,76h,0,0,0
;         db        0,0,0e0h,60h,60h,78h,6ch                ; 98  "b"
;         db        66h,66h,66h,7ch,0,0,0
;         db        0,0,0,0,0,7ch,0c6h                      ; 99  "c"
;         db        0c0h,0c0h,0c6h,7ch,0,0,0
;         db        0,0,1ch,0ch,0ch,3ch,6ch                 ; 100 "d"
;         db        0cch,0cch,0cch,76h,0,0,0
;         db        0,0,0,0,0,7ch,0c6h                      ; 101 "e"
;         db        0feh,0c0h,0c6h,7ch,0,0,0
;         db        0,0,38h,6ch,64h,60h,0f0h                ; 102 "f"
;         db        60h,60h,60h,0f0h,0,0,0
;         db        0,0,0,0,0,76h,0cch                      ; 103 "g"
;         db        0cch,0cch,7ch,0ch,0cch,78h,0
;         db        0,0,0e0h,60h,60h,6ch,76h                ; 104 "h"
;         db        66h,66h,66h,0e6h,0,0,0
;         db        0,0,18h,18h,0,38h,18h                   ; 105 "i"
;         db        18h,18h,18h,3ch,0,0,0
;         db        0,0,6,6,0,0eh,6                         ; 106 "j"
;         db        6,6,6,66h,66h,3ch,0
;         db        0,0,0e0h,60h,60h,66h,6ch                ; 107 "k"
;         db        78h,6ch,66h,0e6h,0,0,0
;         db        0,0,38h,18h,18h,18h,18h                 ; 108 "l"
;         db        18h,18h,18h,3ch,0,0,0
;         db        0,0,0,0,0,0ech,0feh                     ; 109 "m"
;         db        0d6h,0d6h,0d6h,0c6h,0,0,0
;         db        0,0,0,0,0,0dch,66h                      ; 110 "n"
;         db        66h,66h,66h,66h,0,0,0
;         db        0,0,0,0,0,7ch,0c6h                      ; 111 "o"
;         db        0c6h,0c6h,0c6h,7ch,0,0,0
;         db        0,0,0,0,0,0dch,66h                      ; 112 "p"
;         db        66h,66h,7ch,60h,60h,0f0h,0
;         db        0,0,0,0,0,76h,0cch                      ; 113 "q"
;         db        0cch,0cch,7ch,0ch,0ch,1eh,0
;         db        0,0,0,0,0,0dch,76h                      ; 114 "r"
;         db        66h,60h,60h,0f0h,0,0,0
;         db        0,0,0,0,0,7ch,0c6h                      ; 115 "s"
;         db        70h,1ch,0c6h,7ch,0,0,0
;         db        0,0,10h,30h,30h,0fch,30h                ; 116 "t"
;         db        30h,30h,36h,1ch,0,0,0
;         db        0,0,0,0,0,0cch,0cch                     ; 117 "u"
;         db        0cch,0cch,0cch,76h,0,0,0
;         db        0,0,0,0,0,66h,66h                       ; 118 "v"
;         db        66h,66h,3ch,18h,0,0,0
;         db        0,0,0,0,0,0c6h,0c6h                     ; 119 "w"
;         db        0d6h,0d6h,0feh,6ch,0,0,0
;         db        0,0,0,0,0,0c6h,6ch                      ; 120 "x"
;         db        38h,38h,6ch,0c6h,0,0,0
;         db        0,0,0,0,0,0c6h,0c6h                     ; 121 "y"
;         db        0c6h,0c6h,7eh,6,0ch,0f8h,0
;         db        0,0,0,0,0,0feh,0cch                     ; 122 "z"
;         db        18h,30h,66h,0feh,0,0,0
;         db        0,0,0eh,18h,18h,18h,70h                 ; 123 "{"
;         db        18h,18h,18h,0eh,0,0,0
;         db        0,0,18h,18h,18h,18h,0                   ; 124 "|"
;         db        18h,18h,18h,18h,0,0,0
;         db        0,0,70h,18h,18h,18h,0eh                 ; 125 "}"
;         db        18h,18h,18h,70h,0,0,0
;         db        0,0,76h,0dch,0,0,0                      ; 126 "~"
;         db        0,0,0,0,0,0,0
;         db        0,0,0,0,10h,38h,6ch                     ; 127 ""
;         db        0c6h,0c6h,0feh,0,0,0,0


kam14    label     byte                   ;* fonty Kamenickòch 8*14

         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 128 "C" s oc†skem
         db        0c0h,0c2h,66h,3ch,18h,0ch,38h
         db        0,0,0cch,0cch,0,0cch,0cch               ; 129 "Å"
         db        0cch,0cch,0cch,76h,0,0,0
         db        0,0ch,18h,30h,0,7ch,0c6h                ; 130 "Ç"
         db        0feh,0c0h,0c6h,7ch,0,0,0
         db        0,30h,78h,0cch,0,78h,0ch                ; 131 "a" se st©°®kou
         db        7ch,0cch,0cch,76h,0,0,0
         db        0,0,0cch,0cch,0,78h,0ch                 ; 132 "Ñ"
         db        7ch,0cch,0cch,76h,0,0,0
         db        0,38h,6ch,38h,0,0cch,0cch               ; 133 "ñ"
         db        0cch,0cch,0cch,76h,0,0,0
         db        0,0ch,18h,30h,0,7ch,0c6h                ; 134 "c" s á†rkou
         db        0c0h,0c0h,0c6h,7ch,0,0,0
         db        0,0,0,0,0,7ch,0c6h                      ; 135 "c" s oc†skem
         db        0c0h,0c0h,0c6h,7ch,18h,0ch,38h
         db        0,0,38h,18h,18h,1ch,38h                 ; 136 "l" p©e®krtnutÇ
         db        18h,18h,18h,3ch,0,0,0
         db        0,0,0cch,0cch,0,7ch,0c6h                ; 137 "e" p©ehlasovanÇ
         db        0feh,0c0h,0c6h,7ch,0,0,0
         db        63h,0c6h,0,38h,6ch,0c6h,0c6h            ; 138 "O" se 2 á†rkama
         db        0c6h,0c6h,6ch,38h,0,0,0
         db        0,33h,066h,0cch,0,7ch,0c6h              ; 139 "o" se 2 á†rkama
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,18h,3ch,66h,0,38h,18h                 ; 140 "i" se st©°®kou
         db        18h,18h,18h,3ch,0,0,0              
         db        0ch,18h,0feh,0c6h,8ch,18h,30h           ; 141 "Z" s á†rkou
         db        60h,0c2h,0c6h,0feh,0,0,0
         db        0,0c6h,0c6h,10h,38h,6ch,0c6h            ; 142 "é"
         db        0c6h,0feh,0c6h,0c6h,0,0,0          
         db        6,0ch,3ch,66h,0c2h,0c0h,0c0h            ; 143 "C" s á†rkou
         db        0c0h,0c2h,66h,3ch,0,0,0
         db        0ch,18h,0feh,66h,62h,68h,78h            ; 144 "ê"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,6,0f6h,64h,60h,60h,60h                ; 145 "ä"
         db        60h,62h,66h,0feh,0,0,0
         db        6h,6,74h,30h,30h,30h,30h                ; 146 "ç"
         db        30h,30h,30h,78h,0,0,0              
         db        0,30h,78h,0cch,0,7ch,0c6h               ; 147 "ì"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0,0c6h,0c6h,0,7ch,0c6h                ; 148 "î"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        36h,1ch,0f0h,60h,60h,60h,60h            ; 149 "ú"
         db        60h,62h,66h,0feh,0,0,0             
         db        36h,1ch,70h,30h,30h,30h,30h             ; 150 "å"
         db        30h,30h,30h,78h,0,0,0
         db        0ch,18h,7ch,0c6h,0c6h,60h,38h           ; 151 "S" s á†rkou
         db        0ch,0c6h,0c6h,7ch,0,0,0
         db        0,0ch,18h,30h,0,7ch,0c6h                ; 152 "s" s á†rkou
         db        70h,1ch,0c6h,7ch,0,0,0
         db        0,0c6h,0c6h,38h,6ch,0c6h,0c6h           ; 153 "ô"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0c6h,0c6h,0,0c6h,0c6h,0c6h            ; 154 "ö"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        66h,3ch,7eh,7eh,5ah,18h,18h             ; 155 "Ü"
         db        18h,18h,18h,3ch,0,0,0              
         db        36h,1ch,10h,30h,30h,0fch,30h            ; 156 "ü"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,0,0f0h,60h,60h,70h,0e0h               ; 157 "L" p©e®krtnutÇ
         db        060h,62h,66h,0feh,0,0,0
         db        0,0,0,0,0,0c6h,6ch                      ; 158 "x"
         db        38h,38h,6ch,0c6h,0,0,0
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 159 "á"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0ch,18h,30h,0,78h,0ch                 ; 160 "†"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,6,0ch,18h,0,38h,18h                   ; 161 "°"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0ch,18h,30h,0,7ch,0c6h                ; 162 "¢"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0ch,18h,30h,0,0cch,0cch               ; 163 "£"
         db        0cch,0cch,0cch,76h,0,0,0
         db        0,0,10h,38h,6ch,0c6h,0c6h               ; 164 "A" s noëiákou
         db        0feh,0c6h,0c6h,0ceh,8,0eh,0
         db        0,0,0,0,0,78h,0ch                       ; 165 "a" s noëiákou
         db        7ch,0cch,0cch,76h,10h,1ch,0
         db        66h,3ch,0feh,0c6h,8ch,18h,30h           ; 166 "í"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,0,0cch,78h,0,0feh,0cch                ; 167 "ë"
         db        18h,30h,66h,0feh,0,0,0             
         db        0,0,0feh,66h,62h,68h,78h                ; 168 "E" s noëiákou
         db        68h,62h,66h,0feh,10h,1ch,0
         db        0,0,0,0,0,7ch,0c6h                      ; 169 "e" s noëiákou
         db        0feh,0c0h,0c6h,7ch,10h,1ch,0
         db        0,0,0,0,0,0                             ; 170 "-" zalomen†
         db        0feh,6,6,6,0,0,0,0
         db        0,0ch,18h,30h,0,0feh,0cch               ; 171 "z" s á†rkou
         db        18h,30h,66h,0feh,0,0,0
         db        66h,3ch,3ch,66h,0c2h,0c0h,0c0h          ; 172 "Ä"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0,0,0,0,7ch,0c6h                      ; 173 "s" s oc†skem
         db        70h,1ch,0c6h,7ch,18h,0ch,38h
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
         db        3,6,10h,38h,6ch,0c6h,0c6h               ; 181 "è"µ
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        7ch,0c6h,10h,38h,6ch,0c6h,0c6h          ; 182 "A" se st©°®kou
         db        0feh,0c6h,0c6h,0c6h,0,0,0
         db        66h,3ch,0feh,66h,62h,68h,78h            ; 183 "â"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,0,7ch,0c6h,0c6h,60h,38h               ; 184 "S" s oc†skem
         db        0ch,0c6h,0c6h,7ch,18h,0ch,38h
         db        36h,36h,36h,36h,36h,0f6h,6              ; 185 "π"
         db        0f6h,36h,36h,36h,36h,36h,36h
         db        36h,36h,36h,36h,36h,36h,36h             ; 186 "∫"
         db        36h,36h,36h,36h,36h,36h,36h
         db        0,0,0,0,0,0feh,6                        ; 187 "ª"
         db        0f6h,36h,36h,36h,36h,36h,36h
         db        36h,36h,36h,36h,36h,0f6h,6              ; 188 "º"
         db        0feh,0,0,0,0,0,0
         db        18h,18h,0feh,0c6h,8ch,18h,30h           ; 189 "Z" s teákou
         db        60h,0c2h,0c6h,0feh,0,0,0
         db        0,0,30h,30h,0,0feh,0cch                 ; 190 "z" s teákou
         db        18h,30h,66h,0feh,0,0,0
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
         db        0c6h,06ch,10h,38h,6ch,0c6h,0c6h         ; 198 "A" s h†ákem
         db        0feh,0c6h,0c6h,0c6h,0,0,0
         db        0,0,0c6h,7ch,0,78h,0ch                  ; 199 "a" s h†ákem
         db        7ch,0cch,0cch,76h,0,0,0
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
         db        0,0,0,0c6h,0c6h,7ch,6ch                 ; 207 "x" k©°ëek s d°rou
         db        7ch,0c6h,0c6h,0,0,0,0
         db        0,0,0ch,1eh,0ch,3ch,6ch                 ; 208 "d" p©e®krtnutÇ
         db        0cch,0cch,0cch,76h,0,0,0
         db        0,0,0f8h,6ch,66h,66h,76h                ; 209 "D" p©e®krtnutÇ
         db        0e6h,66h,6ch,0f8h,0,0,0
         db        0cch,78h,0f8h,6ch,66h,66h,66h           ; 210 "Ö"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        66h,0,0feh,66h,62h,68h,78h              ; 211 "E" p©ehlasovanÇ
         db        68h,62h,66h,0feh,0,0,0             
         db        6ch,38h,1ch,0ch,0ch,3ch,6ch             ; 212 "É"
         db        0cch,0cch,0cch,7eh,0,0,0           
         db        0cch,78h,0c6h,0e6h,0f6h,0feh,0deh       ; 213 "•"
         db        0ceh,0c6h,0c6h,0c6h,0,0,0          
         db        0ch,18h,3ch,18h,18h,18h,18h             ; 214 "ã"
         db        18h,18h,18h,3ch,0,0,0              
         db        3ch,66h,0,3ch,18h,18h,18h               ; 215 "I" se st©°®kou
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 216 "à"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        18h,18h,18h,18h,18h,18h,18h             ; 217 "Ÿ"
         db        0f8h,0,0,0,0,0,0
         db        0,0,0,0,0,0,0                           ; 218 "⁄"
         db        1fh,18h,18h,18h,18h,18h,18h
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 219 "€"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
         db        0,0,0,0,0,0,0                           ; 220 "‹"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
         db        0,0,7eh,7eh,5ah,18h,18h                 ; 221 "T" s oc†skem
         db        18h,18h,18h,3ch,18h,0ch,38h
         db        3ch,66h,3ch,0c6h,0c6h,0c6h,0c6h         ; 222 "¶"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 223 "ﬂ"
         db        0,0,0,0,0,0,0
         db        6,0ch,38h,6ch,0c6h,0c6h,0c6h            ; 224 "ï"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0,0,0,7ch,0c6h,0fch                   ; 225 "·"
         db        0c6h,0c6h,0fch,0c0h,0c0h,40h,0
         db        7ch,0c6h,38h,6ch,0c6h,0c6h,0c6h         ; 226 "ß"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0ch,18h,0c6h,0e6h,0f6h,0feh,0deh        ; 227 "N" s á†rkou
         db        0ceh,0c6h,0c6h,0c6h,0,0,0
         db        0,0ch,18h,30h,0,0dch,66h                ; 228 "n" s á†rkou
         db        66h,66h,66h,66h,0,0,0
         db        0,0,66h,3ch,0,0dch,66h                  ; 229 "§"
         db        66h,66h,66h,66h,0,0,0              
         db        66h,3ch,7ch,0c6h,0c6h,60h,38h           ; 230 "õ"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 231 "®"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0ch,18h,0fch,66h,66h,66h,7ch            ; 232 "´"
         db        6ch,66h,66h,0e6h,0,0,0             
         db        0ch,18h,0c6h,0c6h,0c6h,0c6h,0c6h        ; 233 "ó"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,6,0ch,18h,0,0dch,76h                  ; 234 "™"
         db        66h,60h,60h,0f0h,0,0,0
         db        33h,66h,0,0c6h,0c6h,0c6h,0c6h           ; 235 "U" se 2 á†rkama
         db        0c6h,0c6h,0c6h,7ch,0,0,0
         db        0,6,0ch,18h,0,0c6h,0c6h                 ; 236 "ò"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0ch,18h,66h,66h,66h,66h,3ch             ; 237 "ù"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0,10h,30h,30h,0fch,30h                ; 238 "t" s oc†skem
         db        30h,30h,36h,1ch,18h,0ch,38h
         db        0,0ch,18h,30h,0,0,0                     ; 239 "'"
         db        0,0,0,0,0,0,0
         db        0,0,0,0,0,0                             ; 240 "-" kr†tk†
         db        0f0h,0,0,0,0,0,0,0
         db        0,0,066h,0cch,0,0,0                     ; 241 """ 2 á†rky
         db        0,0,0,0,0,0,0
         db        0,0,0,0,0,0,0                           ; 242 patiáka
         db        0,0,0,10h,10h,1ch,0
         db        0,6ch,38h,10h,0,0,0                     ; 243 h†áek
         db        0,0,0,0,0,0,0
         db        0,066h,3ch,0,0,0,0                      ; 244 miska
         db        0,0,0,0,0,0,0
         db        0,0,7ch,0c6h,60h,38h,6ch                ; 245 "≠" paragraf
         db        0c6h,6ch,38h,0ch,0c6h,7ch,0        
         db        0,0,0,18h,18h,0,7eh                     ; 246 "ˆ"
         db        0,18h,18h,0,0,0,0
         db        0,0,0,0,0,0,0                           ; 247 oc†sek
         db        0,0,0,0,18h,0ch,38h
         db        0,38h,6ch,38h,0,0,0                     ; 248 "¯" krouëek
         db        0,0,0,0,0,0,0
         db        0,0,66h,66h,0,0,0                       ; 249 dvojteáka
         db        0,0,0,0,0,0,0
         db        0,0,0,0,18h,18h,0                       ; 250 teáka
         db        0,0,0,0,0,0,0
         db        0,33h,66h,0cch,0,0cch,0cch              ; 251 "u" p©ehlasovanÇ
         db        0cch,0cch,0cch,76h,0,0,0
         db        66h,3ch,0fch,66h,66h,66h,7ch            ; 252 "û"
         db        6ch,66h,66h,0e6h,0,0,0
         db        0,0,0cch,78h,0,0dch,76h                 ; 253 "©"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0,0,0,7ch,7ch,7ch                     ; 254 "˛"
         db        7ch,7ch,7ch,0,0,0,0
         db        0,0,0,0,0,0,0                           ; 255
         db        0,0,0,0,0,0,0



;kam16x   label     byte
;
;db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 0
;db 000h,000h,07Eh,081h,0A5h,081h,081h,0BDh,099h,081h,081h,07Eh,000h,000h,000h,000h ; 1
;db 000h,000h,07Eh,0FFh,0DBh,0FFh,0FFh,0C3h,0E7h,0FFh,0FFh,07Eh,000h,000h,000h,000h ; 2
;db 000h,000h,000h,000h,06Ch,0FEh,0FEh,0FEh,0FEh,07Ch,038h,010h,000h,000h,000h,000h ; 3
;db 000h,000h,000h,000h,010h,038h,07Ch,0FEh,07Ch,038h,010h,000h,000h,000h,000h,000h ; 4
;db 000h,000h,000h,018h,03Ch,03Ch,0E7h,0E7h,0E7h,018h,018h,03Ch,000h,000h,000h,000h ; 5
;db 000h,000h,000h,018h,03Ch,07Eh,0FFh,0FFh,07Eh,018h,018h,03Ch,000h,000h,000h,000h ; 6
;db 000h,000h,000h,000h,000h,000h,018h,03Ch,03Ch,018h,000h,000h,000h,000h,000h,000h ; 7
;db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E7h,0C3h,0C3h,0E7h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh ; 8
;db 000h,000h,000h,000h,000h,03Ch,066h,042h,042h,066h,03Ch,000h,000h,000h,000h,000h ; 9
;db 0FFh,0FFh,0FFh,0FFh,0FFh,0C3h,099h,0BDh,0BDh,099h,0C3h,0FFh,0FFh,0FFh,0FFh,0FFh ; 10
;db 000h,000h,01Eh,00Eh,01Ah,032h,078h,0CCh,0CCh,0CCh,0CCh,078h,000h,000h,000h,000h ; 11
;db 000h,000h,03Ch,066h,066h,066h,066h,03Ch,018h,07Eh,018h,018h,000h,000h,000h,000h ; 12
;db 000h,000h,03Fh,033h,03Fh,030h,030h,030h,030h,070h,0F0h,0E0h,000h,000h,000h,000h ; 13
;db 000h,000h,07Fh,063h,07Fh,063h,063h,063h,063h,067h,0E7h,0E6h,0C0h,000h,000h,000h ; 14
;db 000h,000h,000h,018h,018h,0DBh,03Ch,0E7h,03Ch,0DBh,018h,018h,000h,000h,000h,000h ; 15
;db 000h,080h,0C0h,0E0h,0F0h,0F8h,0FEh,0F8h,0F0h,0E0h,0C0h,080h,000h,000h,000h,000h ; 16
;db 000h,002h,006h,00Eh,01Eh,03Eh,0FEh,03Eh,01Eh,00Eh,006h,002h,000h,000h,000h,000h ; 17
;db 000h,000h,018h,03Ch,07Eh,018h,018h,018h,07Eh,03Ch,018h,000h,000h,000h,000h,000h ; 18
;db 000h,000h,066h,066h,066h,066h,066h,066h,066h,000h,066h,066h,000h,000h,000h,000h ; 19
;db 000h,000h,07Fh,0DBh,0DBh,0DBh,07Bh,01Bh,01Bh,01Bh,01Bh,01Bh,000h,000h,000h,000h ; 20
;db 000h,07Ch,0C6h,060h,038h,06Ch,0C6h,0C6h,06Ch,038h,00Ch,0C6h,07Ch,000h,000h,000h ; 21  " "
;db 000h,000h,000h,000h,000h,000h,000h,000h,0FEh,0FEh,0FEh,0FEh,000h,000h,000h,000h ; 22
;db 000h,000h,018h,03Ch,07Eh,018h,018h,018h,07Eh,03Ch,018h,07Eh,000h,000h,000h,000h ; 23
;db 000h,000h,018h,03Ch,07Eh,018h,018h,018h,018h,018h,018h,018h,000h,000h,000h,000h ; 24
;db 000h,000h,018h,018h,018h,018h,018h,018h,018h,07Eh,03Ch,018h,000h,000h,000h,000h ; 25
;db 000h,000h,000h,000h,000h,018h,00Ch,0FEh,00Ch,018h,000h,000h,000h,000h,000h,000h ; 26
;db 000h,000h,000h,000h,000h,030h,060h,0FEh,060h,030h,000h,000h,000h,000h,000h,000h ; 27
;db 000h,000h,000h,000h,000h,000h,0C0h,0C0h,0C0h,0FEh,000h,000h,000h,000h,000h,000h ; 28
;db 000h,000h,000h,000h,000h,028h,06Ch,0FEh,06Ch,028h,000h,000h,000h,000h,000h,000h ; 29
;db 000h,000h,000h,000h,010h,038h,038h,07Ch,07Ch,0FEh,0FEh,000h,000h,000h,000h,000h ; 30
;db 000h,000h,000h,000h,0FEh,0FEh,07Ch,07Ch,038h,038h,010h,000h,000h,000h,000h,000h ; 31
;db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 32  " "
;db 000h,000h,018h,03Ch,03Ch,03Ch,018h,018h,018h,000h,018h,018h,000h,000h,000h,000h ; 33  "!"
;db 000h,066h,066h,066h,024h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 34  "
;db 000h,000h,000h,06Ch,06Ch,0FEh,06Ch,06Ch,06Ch,0FEh,06Ch,06Ch,000h,000h,000h,000h ; 35  "#"
;db 018h,018h,07Ch,0C6h,0C2h,0C0h,07Ch,006h,006h,086h,0C6h,07Ch,018h,018h,000h,000h ; 36  "$"
;db 000h,000h,000h,000h,0C2h,0C6h,00Ch,018h,030h,060h,0C6h,086h,000h,000h,000h,000h ; 37  "%"
;db 000h,000h,038h,06Ch,06Ch,038h,076h,0DCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 38  "&"
;db 000h,030h,030h,030h,060h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 39  "'"
;db 000h,000h,00Ch,018h,030h,030h,030h,030h,030h,030h,018h,00Ch,000h,000h,000h,000h ; 40  "("
;db 000h,000h,030h,018h,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,018h,030h,000h,000h,000h,000h ; 41  ")"
;db 000h,000h,000h,000h,000h,066h,03Ch,0FFh,03Ch,066h,000h,000h,000h,000h,000h,000h ; 42  "*"
;db 000h,000h,000h,000h,000h,018h,018h,07Eh,018h,018h,000h,000h,000h,000h,000h,000h ; 43  "+"
;db 000h,000h,000h,000h,000h,000h,000h,000h,000h,018h,018h,018h,030h,000h,000h,000h ; 44  ","
;db 000h,000h,000h,000h,000h,000h,000h,0FEh,000h,000h,000h,000h,000h,000h,000h,000h ; 45  "-"
;db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,018h,018h,000h,000h,000h,000h ; 46  "."
;db 000h,000h,000h,000h,002h,006h,00Ch,018h,030h,060h,0C0h,080h,000h,000h,000h,000h ; 47  "/"
;db 000h,000h,038h,06Ch,0C6h,0C6h,0D6h,0D6h,0C6h,0C6h,06Ch,038h,000h,000h,000h,000h ; 48  "0"
;db 000h,000h,018h,038h,078h,018h,018h,018h,018h,018h,018h,07Eh,000h,000h,000h,000h ; 49  "1"
;db 000h,000h,07Ch,0C6h,006h,00Ch,018h,030h,060h,0C0h,0C6h,0FEh,000h,000h,000h,000h ; 50  "2"
;db 000h,000h,07Ch,0C6h,006h,006h,03Ch,006h,006h,006h,0C6h,07Ch,000h,000h,000h,000h ; 51  "3"
;db 000h,000h,00Ch,01Ch,03Ch,06Ch,0CCh,0FEh,00Ch,00Ch,00Ch,01Eh,000h,000h,000h,000h ; 52  "4"
;db 000h,000h,0FEh,0C0h,0C0h,0C0h,0FCh,006h,006h,006h,0C6h,07Ch,000h,000h,000h,000h ; 53  "5"
;db 000h,000h,038h,060h,0C0h,0C0h,0FCh,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 54  "6"
;db 000h,000h,0FEh,0C6h,006h,006h,00Ch,018h,030h,030h,030h,030h,000h,000h,000h,000h ; 55  "7"
;db 000h,000h,07Ch,0C6h,0C6h,0C6h,07Ch,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 56  "8"
;db 000h,000h,07Ch,0C6h,0C6h,0C6h,07Eh,006h,006h,006h,00Ch,078h,000h,000h,000h,000h ; 57  "9"
;db 000h,000h,000h,000h,018h,018h,000h,000h,000h,018h,018h,000h,000h,000h,000h,000h ; 58  ":"
;db 000h,000h,000h,000h,018h,018h,000h,000h,000h,018h,018h,030h,000h,000h,000h,000h ; 59  ";"
;db 000h,000h,000h,006h,00Ch,018h,030h,060h,030h,018h,00Ch,006h,000h,000h,000h,000h ; 60  "<"
;db 000h,000h,000h,000h,000h,07Eh,000h,000h,07Eh,000h,000h,000h,000h,000h,000h,000h ; 61  "="
;db 000h,000h,000h,060h,030h,018h,00Ch,006h,00Ch,018h,030h,060h,000h,000h,000h,000h ; 62  ">"
;db 000h,000h,07Ch,0C6h,0C6h,00Ch,018h,018h,018h,000h,018h,018h,000h,000h,000h,000h ; 63  "?"
;db 000h,000h,000h,07Ch,0C6h,0C6h,0DEh,0DEh,0DEh,0DCh,0C0h,07Ch,000h,000h,000h,000h ; 64  "@"
;db 000h,000h,010h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 65  "A"
;db 000h,000h,0FCh,066h,066h,066h,07Ch,066h,066h,066h,066h,0FCh,000h,000h,000h,000h ; 66  "B"
;db 000h,000h,03Ch,066h,0C2h,0C0h,0C0h,0C0h,0C0h,0C2h,066h,03Ch,000h,000h,000h,000h ; 67  "C"
;db 000h,000h,0F8h,06Ch,066h,066h,066h,066h,066h,066h,06Ch,0F8h,000h,000h,000h,000h ; 68  "D"
;db 000h,000h,0FEh,066h,062h,068h,078h,068h,060h,062h,066h,0FEh,000h,000h,000h,000h ; 69  "E"
;db 000h,000h,0FEh,066h,062h,068h,078h,068h,060h,060h,060h,0F0h,000h,000h,000h,000h ; 70  "F"
;db 000h,000h,03Ch,066h,0C2h,0C0h,0C0h,0DEh,0C6h,0C6h,066h,03Ah,000h,000h,000h,000h ; 71  "G"
;db 000h,000h,0C6h,0C6h,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 72  "H"
;db 000h,000h,03Ch,018h,018h,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 73  "I"
;db 000h,000h,01Eh,00Ch,00Ch,00Ch,00Ch,00Ch,0CCh,0CCh,0CCh,078h,000h,000h,000h,000h ; 74  "J"
;db 000h,000h,0E6h,066h,066h,06Ch,078h,078h,06Ch,066h,066h,0E6h,000h,000h,000h,000h ; 75  "K"
;db 000h,000h,0F0h,060h,060h,060h,060h,060h,060h,062h,066h,0FEh,000h,000h,000h,000h ; 76  "L"
;db 000h,000h,0C6h,0EEh,0FEh,0FEh,0D6h,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 77  "M"
;db 000h,000h,0C6h,0E6h,0F6h,0FEh,0DEh,0CEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 78  "N"
;db 000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 79  "O"
;db 000h,000h,0FCh,066h,066h,066h,07Ch,060h,060h,060h,060h,0F0h,000h,000h,000h,000h ; 80  "P"
;db 000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0D6h,0DEh,07Ch,00Ch,00Eh,000h,000h ; 81  "Q"
;db 000h,000h,0FCh,066h,066h,066h,07Ch,06Ch,066h,066h,066h,0E6h,000h,000h,000h,000h ; 82  "R"
;db 000h,000h,07Ch,0C6h,0C6h,060h,038h,00Ch,006h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 83  "S"
;db 000h,000h,07Eh,07Eh,05Ah,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 84  "T"
;db 000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 85  "U"
;db 000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,06Ch,038h,010h,000h,000h,000h,000h ; 86  "V"
;db 000h,000h,0C6h,0C6h,0C6h,0C6h,0D6h,0D6h,0D6h,0FEh,0EEh,06Ch,000h,000h,000h,000h ; 87  "W"
;db 000h,000h,0C6h,0C6h,06Ch,07Ch,038h,038h,07Ch,06Ch,0C6h,0C6h,000h,000h,000h,000h ; 88  "X"
;db 000h,000h,066h,066h,066h,066h,03Ch,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 89  "Y"
;db 000h,000h,0FEh,0C6h,086h,00Ch,018h,030h,060h,0C2h,0C6h,0FEh,000h,000h,000h,000h ; 90  "Z"
;db 000h,000h,03Ch,030h,030h,030h,030h,030h,030h,030h,030h,03Ch,000h,000h,000h,000h ; 91  "["
;db 000h,000h,000h,080h,0C0h,0E0h,070h,038h,01Ch,00Eh,006h,002h,000h,000h,000h,000h ; 92  "\"
;db 000h,000h,03Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,03Ch,000h,000h,000h,000h ; 93  "]"
;db 010h,038h,06Ch,0C6h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 94  "^"
;db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h ; 95  "_"
;db 030h,030h,018h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 96  "`"
;db 000h,000h,000h,000h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 97  "a"
;db 000h,000h,0E0h,060h,060h,078h,06Ch,066h,066h,066h,066h,07Ch,000h,000h,000h,000h ; 98  "b"
;db 000h,000h,000h,000h,000h,07Ch,0C6h,0C0h,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h ; 99  "c"
;db 000h,000h,01Ch,00Ch,00Ch,03Ch,06Ch,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 100 "d"
;db 000h,000h,000h,000h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h ; 101 "e"
;db 000h,000h,038h,06Ch,064h,060h,0F0h,060h,060h,060h,060h,0F0h,000h,000h,000h,000h ; 102 "f"
;db 000h,000h,000h,000h,000h,076h,0CCh,0CCh,0CCh,0CCh,0CCh,07Ch,00Ch,0CCh,078h,000h ; 103 "g"
;db 000h,000h,0E0h,060h,060h,06Ch,076h,066h,066h,066h,066h,0E6h,000h,000h,000h,000h ; 104 "h"
;db 000h,000h,018h,018h,000h,038h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 105 "i"
;db 000h,000h,006h,006h,000h,00Eh,006h,006h,006h,006h,006h,006h,066h,066h,03Ch,000h ; 106 "j"
;db 000h,000h,0E0h,060h,060h,066h,06Ch,078h,078h,06Ch,066h,0E6h,000h,000h,000h,000h ; 107 "k"
;db 000h,000h,038h,018h,018h,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 108 "l"
;db 000h,000h,000h,000h,000h,0ECh,0FEh,0D6h,0D6h,0D6h,0D6h,0C6h,000h,000h,000h,000h ; 109 "m"
;db 000h,000h,000h,000h,000h,0DCh,066h,066h,066h,066h,066h,066h,000h,000h,000h,000h ; 110 "n"
;db 000h,000h,000h,000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 111 "o"
;db 000h,000h,000h,000h,000h,0DCh,066h,066h,066h,066h,066h,07Ch,060h,060h,0F0h,000h ; 112 "p"
;db 000h,000h,000h,000h,000h,076h,0CCh,0CCh,0CCh,0CCh,0CCh,07Ch,00Ch,00Ch,01Eh,000h ; 113 "q"
;db 000h,000h,000h,000h,000h,0DCh,076h,066h,060h,060h,060h,0F0h,000h,000h,000h,000h ; 114 "r"
;db 000h,000h,000h,000h,000h,07Ch,0C6h,060h,038h,00Ch,0C6h,07Ch,000h,000h,000h,000h ; 115 "s"
;db 000h,000h,010h,030h,030h,0FCh,030h,030h,030h,030h,036h,01Ch,000h,000h,000h,000h ; 116 "t"
;db 000h,000h,000h,000h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 117 "u"
;db 000h,000h,000h,000h,000h,066h,066h,066h,066h,066h,03Ch,018h,000h,000h,000h,000h ; 118 "v"
;db 000h,000h,000h,000h,000h,0C6h,0C6h,0D6h,0D6h,0D6h,0FEh,06Ch,000h,000h,000h,000h ; 119 "w"
;db 000h,000h,000h,000h,000h,0C6h,06Ch,038h,038h,038h,06Ch,0C6h,000h,000h,000h,000h ; 120 "x"
;db 000h,000h,000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh,006h,00Ch,0F8h,000h ; 121 "y"
;db 000h,000h,000h,000h,000h,0FEh,0CCh,018h,030h,060h,0C6h,0FEh,000h,000h,000h,000h ; 122 "z"
;db 000h,000h,00Eh,018h,018h,018h,070h,018h,018h,018h,018h,00Eh,000h,000h,000h,000h ; 123 "{"
;db 000h,000h,018h,018h,018h,018h,000h,018h,018h,018h,018h,018h,000h,000h,000h,000h ; 124 "|"
;db 000h,000h,070h,018h,018h,018h,00Eh,018h,018h,018h,018h,070h,000h,000h,000h,000h ; 125 "}"
;db 000h,000h,076h,0DCh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 126 "~"
;db 000h,000h,000h,000h,010h,038h,06Ch,0C6h,0C6h,0C6h,0FEh,000h,000h,000h,000h,000h ; 127 ""

kam16   label     byte



db 000h,000h,03ch,066h,0c2h,0c0h,0C0h,0C0h,0C2h,066h,03ch,00Ch,006h,07ch,000h,000h ; 128 "Ä"
db 000h,0cch,0CCh,000h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 129 "Å"
db 000h,00Ch,018h,030h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h ; 130 "Ç"
db 000h,010h,038h,06ch,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 131 "É"
db 000h,0cch,0CCh,000h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 132 "Ñ"
db 000h,038h,06ch,038h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 133 "Ö"
db 000h,00ch,018h,030h,000h,07Ch,0C6h,0C0h,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h ; 134 "Ü"
db 000h,000h,000h,000h,000h,03Ch,066h,060h,060h,066h,03ch,00Ch,006h,03ch,000h,000h ; 135 "á"
db 000h,000h,038h,018h,018h,018h,01ch,038h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 136 "à"
db 000h,0c6h,0C6h,000h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h ; 137 "â"
db 066h,0cch,000h,07ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 138 "ä"
db 000h,066h,0cch,000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 139 "ã"
db 000h,018h,03Ch,066h,000h,038h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 140 "å"
db 00ch,018h,0FEh,0C6h,086h,00Ch,018h,030h,060h,0C2h,0C6h,0FEh,000h,000h,000h,000h ; 141 "ç"
db 0c6h,0c6h,010h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 142 "é"
db 006h,00ch,03Ch,066h,0C2h,0C0h,0C0h,0C0h,0C0h,0C2h,066h,03Ch,000h,000h,000h,000h ; 143 "è"
db 00ch,018h,0FEh,066h,062h,068h,078h,068h,060h,062h,066h,0FEh,000h,000h,000h,000h ; 144 "ê"
db 006h,006h,0F4h,060h,060h,060h,060h,060h,060h,062h,066h,0FEh,000h,000h,000h,000h ; 145 "ë"
db 003h,003h,072h,030h,030h,030h,030h,030h,030h,030h,030h,078h,000h,000h,000h,000h ; 146 "í"
db 000h,038h,06ch,0c6h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 147 "ì"
db 000h,0c6h,0C6h,000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 148 "î"
db 01bh,00eh,0F4h,060h,060h,060h,060h,060h,060h,062h,066h,0FEh,000h,000h,000h,000h ; 149 "ï"
db 033h,01eh,070h,030h,030h,030h,030h,030h,030h,030h,030h,078h,000h,000h,000h,000h ; 150 "ñ"
db 00ch,018h,07Ch,0C6h,0C6h,060h,038h,00Ch,006h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 151 "ó"
db 000h,006h,00ch,018h,000h,07Ch,0C6h,060h,038h,00Ch,0C6h,07Ch,000h,000h,000h,000h ; 152 "ò"
db 0c6h,0C6h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 153 "ô"
db 0c6h,0C6h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 154 "ö"
db 066h,03ch,07Eh,07Eh,05Ah,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 155 "õ"
db 01bh,00eh,014h,030h,030h,0FCh,030h,030h,030h,030h,036h,01Ch,000h,000h,000h,000h ; 156 "ú"
db 000h,000h,0F0h,060h,060h,060h,070h,0e0h,060h,062h,066h,0FEh,000h,000h,000h,000h ; 157 "ù"
db 000h,000h,000h,0c6h,0c6h,06ch,06Ch,038h,038h,06Ch,06ch,0c6h,0c6h,000h,000h,000h ; 158 "û"
db 000h,066h,03ch,018h,000h,07Ch,0C6h,0C0h,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h ; 159 "ü"
db 000h,00ch,018h,030h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 160 "†"
db 000h,006h,00ch,018h,000h,038h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 161 "°"
db 000h,00ch,018h,030h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 162 "¢"
db 000h,00ch,018h,030h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 163 "£"
db 000h,000h,010h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0Ceh,008h,00eh,000h,000h ; 164 "§"
db 000h,000h,000h,000h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,010h,01ch,000h,000h ; 165 "•"
db 0cch,078h,0FEh,0C6h,086h,00Ch,018h,030h,060h,0C2h,0C6h,0FEh,000h,000h,000h,000h ; 166 "¶"
db 000h,066h,03ch,018h,000h,0FEh,0CCh,018h,030h,060h,0C6h,0FEh,000h,000h,000h,000h ; 167 "ß"
db 000h,000h,0FEh,066h,062h,068h,078h,068h,060h,062h,066h,0FEh,010h,01ch,000h,000h ; 168 "®"
db 000h,000h,000h,000h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,010h,01ch,000h,000h ; 169 "©"
db 000h,000h,000h,000h,000h,000h,0FEh,006h,006h,006h,006h,000h,000h,000h,000h,000h ; 170 "™"
db 000h,006h,00ch,018h,000h,0FEh,0CCh,018h,030h,060h,0C6h,0FEh,000h,000h,000h,000h ; 171 "´"
db 066h,03ch,03ch,066h,0c2h,0c0h,0C0h,0C0h,0C0h,0C2h,066h,03Ch,000h,000h,000h,000h ; 172 "¨"
db 000h,000h,000h,000h,000h,07Ch,0C6h,060h,038h,00Ch,0C6h,07Ch,018h,00ch,078h,000h ; 173 "≠"
db 000h,000h,000h,000h,000h,036h,06Ch,0D8h,06Ch,036h,000h,000h,000h,000h,000h,000h ; 174 "Æ"
db 000h,000h,000h,000h,000h,0D8h,06Ch,036h,06Ch,0D8h,000h,000h,000h,000h,000h,000h ; 175 "Ø"
db 011h,044h,011h,044h,011h,044h,011h,044h,011h,044h,011h,044h,011h,044h,011h,044h ; 176 "∞"
db 055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh ; 177 "±"
db 0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h ; 178 "≤"
db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h ; 179 "≥"
db 018h,018h,018h,018h,018h,018h,018h,0F8h,018h,018h,018h,018h,018h,018h,018h,018h ; 180 "¥"
db 006h,00ch,010h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 181 "µ"
db 07ch,0c6h,010h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 182 "∂"
db 066h,03ch,0FEh,066h,062h,068h,078h,068h,060h,062h,066h,0FEh,000h,000h,000h,000h ; 183 "∑"
db 000h,000h,07Ch,0C6h,0C6h,060h,038h,00Ch,006h,0C6h,0C6h,07Ch,018h,00ch,078h,000h ; 184 "∏"
db 036h,036h,036h,036h,036h,0F6h,006h,0F6h,036h,036h,036h,036h,036h,036h,036h,036h ; 185 "π"
db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h ; 186 "∫"
db 000h,000h,000h,000h,000h,0FEh,006h,0F6h,036h,036h,036h,036h,036h,036h,036h,036h ; 187 "ª"
db 036h,036h,036h,036h,036h,0F6h,006h,0FEh,000h,000h,000h,000h,000h,000h,000h,000h ; 188 "º"
db 018h,018h,0FEh,0C6h,086h,00Ch,018h,030h,060h,0C2h,0C6h,0FEh,000h,000h,000h,000h ; 189 "Ω"
db 000h,000h,018h,018h,000h,0FEh,0CCh,018h,030h,060h,0C6h,0FEh,000h,000h,000h,000h ; 190 "æ"
db 000h,000h,000h,000h,000h,000h,000h,0F8h,018h,018h,018h,018h,018h,018h,018h,018h ; 191 "ø"
db 018h,018h,018h,018h,018h,018h,018h,01Fh,000h,000h,000h,000h,000h,000h,000h,000h ; 192 "¿"
db 018h,018h,018h,018h,018h,018h,018h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h ; 193 "¡"
db 000h,000h,000h,000h,000h,000h,000h,0FFh,018h,018h,018h,018h,018h,018h,018h,018h ; 194 "¬"
db 018h,018h,018h,018h,018h,018h,018h,01Fh,018h,018h,018h,018h,018h,018h,018h,018h ; 195 "√"
db 000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h ; 196 "ƒ"
db 018h,018h,018h,018h,018h,018h,018h,0FFh,018h,018h,018h,018h,018h,018h,018h,018h ; 197 "≈"
db 0c6h,07ch,010h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 198 "∆"
db 000h,000h,0c6h,07ch,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 199 "«"
db 036h,036h,036h,036h,036h,037h,030h,03Fh,000h,000h,000h,000h,000h,000h,000h,000h ; 200 "»"
db 000h,000h,000h,000h,000h,03Fh,030h,037h,036h,036h,036h,036h,036h,036h,036h,036h ; 201 "…"
db 036h,036h,036h,036h,036h,0F7h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h ; 202 " "
db 000h,000h,000h,000h,000h,0FFh,000h,0F7h,036h,036h,036h,036h,036h,036h,036h,036h ; 203 "À"
db 036h,036h,036h,036h,036h,037h,030h,037h,036h,036h,036h,036h,036h,036h,036h,036h ; 204 "Ã"
db 000h,000h,000h,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h ; 205 "Õ"
db 036h,036h,036h,036h,036h,0F7h,000h,0F7h,036h,036h,036h,036h,036h,036h,036h,036h ; 206 "Œ"
db 000h,000h,000h,0c6h,0c6h,07ch,06ch,07ch,0c6h,0c6h,000h,000h,000h,000h,000h,000h ; 207 "œ"
db 000h,000h,00Ch,01eh,00Ch,03Ch,06Ch,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 208 "–"
db 000h,000h,0F8h,06Ch,066h,066h,076h,0e6h,066h,066h,06Ch,0F8h,000h,000h,000h,000h ; 209 "—"
db 0cch,078h,0F8h,06Ch,066h,066h,066h,066h,066h,066h,06Ch,0F8h,000h,000h,000h,000h ; 210 "“"
db 0c6h,000h,0FEh,066h,062h,068h,078h,068h,060h,062h,066h,0FEh,000h,000h,000h,000h ; 211 "”"
db 066h,03ch,000h,01Ch,00Ch,03Ch,06Ch,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 212 "‘"
db 06ch,038h,0c6h,0E6h,0F6h,0FEh,0DEh,0CEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 213 "’"
db 00ch,018h,000h,03ch,018h,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 214 "÷"
db 07eh,0c3h,03Ch,018h,018h,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 215 "◊"
db 000h,066h,03ch,018h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h ; 216 "ÿ"
db 018h,018h,018h,018h,018h,018h,018h,0F8h,000h,000h,000h,000h,000h,000h,000h,000h ; 217 "Ÿ"
db 000h,000h,000h,000h,000h,000h,000h,01Fh,018h,018h,018h,018h,018h,018h,018h,018h ; 218 "⁄"
db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh ; 219 "€"
db 000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh ; 220 "‹"
db 000h,000h,07Eh,07Eh,05Ah,018h,018h,018h,018h,018h,018h,03Ch,018h,00ch,078h,000h ; 221 "›"
db 038h,06ch,038h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 222 "ﬁ"
db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 223 "ﬂ"
db 00ch,018h,000h,07ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 224 "‡"
db 000h,000h,078h,0CCh,0CCh,0CCh,0D8h,0CCh,0C6h,0C6h,0C6h,0CCh,0c0h,000h,000h,000h ; 225 "·"
db 07ch,0c6h,000h,07ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 226 "‚"
db 00ch,018h,0c6h,0E6h,0F6h,0FEh,0DEh,0CEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h ; 227 "„"
db 000h,006h,00ch,018h,000h,0DCh,066h,066h,066h,066h,066h,066h,000h,000h,000h,000h ; 228 "‰"
db 000h,066h,03ch,018h,000h,0DCh,066h,066h,066h,066h,066h,066h,000h,000h,000h,000h ; 229 "Â"
db 066h,03ch,07Ch,0C6h,0C6h,060h,038h,00Ch,006h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 230 "Ê"
db 000h,066h,03ch,018h,000h,07Ch,0C6h,060h,038h,00Ch,0C6h,07Ch,000h,000h,000h,000h ; 231 "Á"
db 00ch,018h,0FCh,066h,066h,066h,07Ch,06Ch,066h,066h,066h,0E6h,000h,000h,000h,000h ; 232 "Ë"
db 00ch,018h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 233 "È"
db 000h,006h,00ch,018h,000h,0DCh,076h,066h,060h,060h,060h,0F0h,000h,000h,000h,000h ; 234 "Í"
db 063h,0c6h,000h,0C6h,0c6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h ; 235 "Î"
db 000h,006h,00ch,018h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh,006h,00Ch,0F8h,000h ; 236 "Ï"
db 00ch,018h,066h,066h,066h,066h,03Ch,018h,018h,018h,018h,03Ch,000h,000h,000h,000h ; 237 "Ì"
db 000h,000h,010h,030h,030h,0FCh,030h,030h,030h,030h,036h,01Ch,018h,00ch,078h,000h ; 238 "Ó"
db 000h,006h,00ch,018h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 239 "Ô"
db 000h,000h,000h,000h,000h,03ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 240 ""
db 000h,033h,066h,0cch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 241 "Ò"
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,010h,010h,01ch,000h,000h ; 242 "Ú"
db 000h,0cch,078h,030h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 243 "Û"
db 000h,0c6h,07ch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 244 "Ù"
db 000h,07Ch,0C6h,060h,038h,06Ch,0C6h,0C6h,06Ch,038h,00Ch,0C6h,07Ch,000h,000h,000h ; 245 "ı"
db 000h,000h,000h,000h,018h,018h,000h,07Eh,000h,018h,018h,000h,000h,000h,000h,000h ; 246 "ˆ"
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,018h,00ch,078h,000h ; 247 "˜"
db 000h,038h,06Ch,06Ch,038h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 248 "¯"
db 000h,0c6h,0c6h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 249 "˘"
db 000h,000h,000h,000h,000h,000h,018h,018h,000h,000h,000h,000h,000h,000h,000h,000h ; 250 "˙"
db 000h,033h,066h,0cch,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h ; 251 "˚"
db 0cch,078h,0FCh,066h,066h,066h,07Ch,06Ch,066h,066h,066h,0E6h,000h,000h,000h,000h ; 252 "¸"
db 000h,066h,03ch,018h,000h,0DCh,076h,066h,060h,060h,060h,0F0h,000h,000h,000h,000h ; 253 "˝"
db 000h,000h,000h,000h,07Ch,07Ch,07Ch,07Ch,07Ch,07Ch,07Ch,000h,000h,000h,000h,000h ; 254 "˛"
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h ; 255


instal:  mov       ah,12h
         mov       bl,10h
         int       10h
         jc        error                    ; nen° displej EGA
         cmp       bl,10h
         je        error                    ; nen° displej EGA
                                          ;* instalace obsluhy INT 10h
         mov       ax,3510h
         int       21h
         mov       word ptr ds:[old10],bx
         mov       word ptr ds:[old10+2],es
         lea       dx,[int10]
         mov       ax,2510h
         int       21h

         lea       dx,[kam8]                ; fonty 8*8
         mov       ax,251fh
         int       21h
                                          ;* nastaven° videom¢du
         mov       ah,0fh
         int       10h                      ; dotaz na souáasnò videom¢d
;         mov       ds:[vmod],al             ; £schova videom¢du
;         push      bx
;         push      ax
;         mov       ah,3
;         int       10h                      ; z°sk†n° pozice a rozmàrñ kurzoru
;         pop       ax
;         push      dx
;         push      cx
;         or        al,80h                   ; p©°znak - obrazovka se nemaëe
         xor       ah,ah
         int       10h                      ; novÇ nastaven° videom¢du
;         pop       cx
;         mov       ah,1
;         int       10h                      ; n†vrat rozmàrñ kurzoru
;         pop       dx
;         pop       bx
;         mov       ah,2
;         int       10h                      ; n†vrat pozice kurzoru
;         push      ds
;         xor       ax,ax
;         mov       ds,ax                    ; DS <- 0
;         and       byte ptr ds:[449h],7fh   ; zru®en° bitu 7 videom¢du
;         pop       ds
                                          ;* £vodn° text, instalace
         mov       ah,9
         lea       dx,[uvtxt]
         int       21h                      ; £vodn° text
         lea       dx,[instal]              ; dÇlka rezidentn° á†sti
         int       27h                      ; instalace programu
                                          ;* chyba - nen° karta EGA
error:   lea       dx,[errtxt]
         mov       ah,9
         int       21h
         int       20h

errtxt   db        'Nen° nainstalov†na karta EGA/VGA !',13,10,'$'

uvtxt    db        '¨eskÇ fonty EGA/VGA - k¢d Latin 2; (c) Miroslav Nÿmeüek'
         db        13,10,'$'

code     ends
         end       start
