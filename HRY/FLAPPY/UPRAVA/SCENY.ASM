
; *****************************************************************************
;
;                         Definice sc‚n
;
; *****************************************************************************

Hesla    label     byte                     ; hesla
         db        'shiba'                  ; 1-5
         db        'MegmI'                  ; 6-10
         db        'PenTA'                  ; 11-15
         db        'miki!'                  ; 16-20
         db        'sakra'                  ; 21-25
         db        '1,2,0'                  ; 26-30
         db        '??OkU'                  ; 31-35
         db        'OmoRI'                  ; 36-40
         db        'U-CaN'                  ; 41-45
         db        'QuoTe'                  ; 46-50
         db        'ayAko'                  ; 51-55
         db        'Uf,f,'                  ; 56-60
         db        'Chie?'                  ; 61-65
         db        'sAKE!'                  ; 66-70
         db        'Syogn'                  ; 71-75
         db        'bUSHi'                  ; 76-80
         db        'BakA!'                  ; 81-85
         db        'STONE'                  ; 86-90
         db        'Japan'                  ; 91-95
         db        'HArfE'                  ; 96-100
         db        'Sappr'                  ; 101-105
         db        'OhaYo'                  ; 106-110
         db        'Gohan'                  ; 111-115
         db        'Ramen'                  ; 116-120
         db        'Nemui'                  ; 121-125
         db        'Natsu'                  ; 126-130
         db        'Yuki!'                  ; 131-135
         db        'HeIwa'                  ; 136-140
         db        'Pice!'                  ; 141-145
         db        'MZ801'                  ; 146-150
         db        'Engla'                  ; 151-155
         db        'Rome!'                  ; 156-160
         db        'PaRie'                  ; 161-165
         db        'Letgo'                  ; 166-170
         db        'FrEnc'                  ; 171-175
         db        'AFewe'                  ; 176-180
         db        'GerMa'                  ; 181-185
         db        'Tokyo'                  ; 186-190
         db        'Prend'                  ; 191-195
         db        'OKU-H'                  ; 196-200

Scena1   dw        Scena2-$

         db        00000000b,00000000b,00000000b
         db        11011111b,11111011b,11100000b
         db        00000001b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00001110b,11011101b,11100000b
         db        00000000b,01000000b,00000000b
         db        11111011b,01110111b,11100000b
         db        00000000b,00000000b,00000000b
         db        01111111b,11011110b,11100000b
         db        00000000b,00000000b,00000000b
         db        2,48                     ; pozice a © dek modr‚ cihly

         db        5                        ; po‡et koul¡
         db        38,8                     ; modr  koule
         db        38,20
         db        46,20
         db        66,20
         db        38,36

         db        3                        ; po‡et duch–
         db        2,16
         db        66,28
         db        38,44

         db        7                        ; po‡et st©el
         db        20,10
         db        52,10
         db        56,22
         db        20,30
         db        60,30
         db        4,46
         db        74,46

Scena2   dw        Scena3-$

         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00100000b,10111111b,10000000b
         db        00110001b,10000011b,00000000b
         db        00111011b,10000110b,00000000b
         db        00101110b,10001100b,00000000b
         db        00100100b,10010000b,00000000b
         db        00100000b,10111111b,10000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        50,36                    ; pozice a © dek modr‚ cihly

         db        7                        ; po‡et koul¡
         db        34,8                     ; modr  koule
         db        34,12
         db        42,12
         db        46,12
         db        50,32
         db        62,32
         db        10,12

         db        0                        ; po‡et duch–

Scena3   dw        0
