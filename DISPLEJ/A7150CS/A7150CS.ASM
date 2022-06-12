
; *****************************************************************************
;
;               Instal†tor áeskòch fontñ pro ROBOTRON A 7150
;
; *****************************************************************************

code     SEGMENT
         ASSUME    CS:code,ds:code
         org       100h

start:
         mov       dx,offset uvtxt
         mov       ah,9
         int       21h
         mov       si,offset font
         mov       bx,256*18
cekej:   xor       cx,cx
cekej1:  mov       dx,200h
         xor       ax,ax
         out       dx,al
         in        al,dx
         test      al,2
         loopnz    cekej1
         jnz       chyba
         mov       dx,202h
         lodsb
         out       dx,al
         dec       bx
         jnz       cekej
         int       20h

chyba:   mov       dx,offset errtxt
         mov       ah,9
         int       21h
         int       20h

uvtxt    db        'CS fonty pro ',255,' ROBOTRON A 7150; (c) Miroslav Nemecek'
         db        13,10,'$'

errtxt   db        'Neni nainstalovana karta CGA pro A 7150 !',13,10,'$'

font:
         db        16,0
         db        0,0,0,0,0,0,0                           ; 0
         db        0,0,0,0,0,0,0
         db        0,0
         db        16,1
         db        0,0,7eh,81h,0a5h,81h,81h                ; 1
         db        0bdh,99h,81h,7eh,0,0,0             
         db        0,0
         db        16,2
         db        0,0,7eh,0ffh,0dbh,0ffh,0ffh             ; 2
         db        0c3h,0e7h,0ffh,7eh,0,0,0           
         db        0,0
         db        16,3
         db        0,0,0,6ch,0feh,0feh,0feh                ; 3
         db        0feh,7ch,38h,10h,0,0,0             
         db        0,0
         db        16,4
         db        0,0,0,10h,38h,7ch,0feh                  ; 4
         db        7ch,38h,10h,0,0,0,0                
         db        0,0
         db        16,5
         db        0,0,18h,3ch,3ch,0e7h,0e7h               ; 5
         db        0e7h,18h,18h,3ch,0,0,0             
         db        0,0
         db        16,6
         db        0,0,18h,3ch,7eh,0ffh,0ffh               ; 6
         db        7eh,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,7
         db        0,0,0,0,0,18h,3ch                       ; 7
         db        3ch,18h,0,0,0,0,0                  
         db        0,0
         db        16,8
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0e7h,0c3h      ; 8
         db        0c3h,0e7h,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0,0
         db        16,9
         db        0,0,0,0,3ch,66h,42h                     ; 9
         db        42h,66h,3ch,0,0,0,0                
         db        0,0
         db        16,10
         db        0ffh,0ffh,0ffh,0ffh,0c3h,99h,0bdh       ; 10
         db        0bdh,99h,0c3h,0ffh,0ffh,0ffh,0ffh  
         db        0,0
         db        16,11
         db        0,0,1eh,0eh,1ah,32h,78h                 ; 11
         db        0cch,0cch,0cch,78h,0,0,0           
         db        0,0
         db        16,12
         db        0,0,3ch,66h,66h,66h,3ch                 ; 12
         db        18h,7eh,18h,18h,0,0,0              
         db        0,0
         db        16,13
         db        0,0,3fh,33h,3fh,30h,30h                 ; 13
         db        30h,70h,0f0h,0e0h,0,0,0            
         db        0,0
         db        16,14
         db        0,0,7fh,63h,7fh,63h,63h                 ; 14
         db        63h,67h,0e7h,0e6h,0c0h,0,0         
         db        0,0
         db        16,15
         db        0,0,18h,18h,0dbh,3ch,0e7h               ; 15
         db        3ch,0dbh,18h,18h,0,0,0             
         db        0,0
         db        16,16
         db        0,0,80h,0c0h,0e0h,0f8h,0feh             ; 16
         db        0f8h,0e0h,0c0h,80h,0,0,0           
         db        0,0
         db        16,17
         db        0,0,2,6,0eh,3eh,0feh                    ; 17
         db        3eh,0eh,6,2,0,0,0                  
         db        0,0
         db        16,18
         db        0,0,18h,3ch,7eh,18h,18h                 ; 18
         db        18h,7eh,3ch,18h,0,0,0              
         db        0,0
         db        16,19
         db        0,0,66h,66h,66h,66h,66h                 ; 19
         db        66h,0,66h,66h,0,0,0                
         db        0,0
         db        16,20
         db        0,0,7fh,0dbh,0dbh,0dbh,7bh              ; 20
         db        1bh,1bh,1bh,1bh,0,0,0              
         db        0,0
         db        16,21
         db        0,7ch,0c6h,60h,38h,6ch,0c6h             ; 21  " "
         db        0c6h,6ch,38h,0ch,0c6h,7ch,0        
         db        0,0
         db        16,22
         db        0,0,0,0,0,0,0                           ; 22
         db        0,0feh,0feh,0feh,0,0,0             
         db        0,0
         db        16,23
         db        0,0,18h,3ch,7eh,18h,18h                 ; 23
         db        18h,7eh,3ch,18h,7eh,0,0            
         db        0,0
         db        16,24
         db        0,0,18h,3ch,7eh,18h,18h                 ; 24
         db        18h,18h,18h,18h,0,0,0              
         db        0,0
         db        16,25
         db        0,0,18h,18h,18h,18h,18h                 ; 25
         db        18h,7eh,3ch,18h,0,0,0              
         db        0,0
         db        16,26
         db        0,0,0,0,18h,0ch,0feh                    ; 26
         db        0ch,18h,0,0,0,0,0                  
         db        0,0
         db        16,27
         db        0,0,0,0,30h,60h                         ; 27
         db        0feh,60h,30h,0,0,0,0,0             
         db        0,0
         db        16,28
         db        0,0,0,0,0,0c0h,0c0h                     ; 28
         db        0c0h,0feh,0,0,0,0,0                
         db        0,0
         db        16,29
         db        0,0,0,0,28h,6ch,0feh                    ; 29
         db        6ch,28h,0,0,0,0,0                  
         db        0,0
         db        16,30
         db        0,0,0,10h,38h,38h,7ch                   ; 30
         db        7ch,0feh,0feh,0,0,0,0              
         db        0,0
         db        16,31
         db        0,0,0,0feh,0feh,7ch,7ch                 ; 31
         db        38h,38h,10h,0,0,0,0                
         db        0,0
         db        16,32
         db        0,0,0,0,0,0,0                           ; 32  " "
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,33
         db        0,0,18h,3ch,3ch,3ch,18h                 ; 33  "!"
         db        18h,0,18h,18h,0,0,0                
         db        0,0
         db        16,34
         db        0,66h,66h,66h,24h,0,0                   ; 34  "
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,35
         db        0,0,6ch,6ch,0feh,6ch,6ch                ; 35  "#"
         db        6ch,0feh,6ch,6ch,0,0,0             
         db        0,0
         db        16,36
         db        18h,18h,7ch,0c6h,0c2h,0c0h,7ch          ; 36  "$"
         db        6,86h,0c6h,7ch,18h,18h,0           
         db        0,0
         db        16,37
         db        0,0,0,0,0c2h,0c6h,0ch                   ; 37  "%"
         db        18h,30h,66h,0c6h,0,0,0             
         db        0,0
         db        16,38
         db        0,0,38h,6ch,6ch,38h,76h                 ; 38  "&"
         db        0dch,0cch,0cch,76h,0,0,0           
         db        0,0
         db        16,39
         db        0,30h,30h,30h,60h,0,0                   ; 39  "'"
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,40
         db        0,0,0ch,18h,30h,30h,30h                 ; 40  "("
         db        30h,30h,18h,0ch,0,0,0              
         db        0,0
         db        16,41
         db        0,0,30h,18h,0ch,0ch,0ch                 ; 41  ")"
         db        0ch,0ch,18h,30h,0,0,0              
         db        0,0
         db        16,42
         db        0,0,0,0,66h,3ch,0ffh                    ; 42  "*"
         db        3ch,66h,0,0,0,0,0                  
         db        0,0
         db        16,43
         db        0,0,0,0,18h,18h,7eh                     ; 43  "+"
         db        18h,18h,0,0,0,0,0                  
         db        0,0
         db        16,44
         db        0,0,0,0,0,0,0                           ; 44  ","
         db        0,18h,18h,18h,30h,0,0              
         db        0,0
         db        16,45
         db        0,0,0,0,0,0                             ; 45  "-"
         db        0feh,0,0,0,0,0,0,0                 
         db        0,0
         db        16,46
         db        0,0,0,0,0,0,0                           ; 46  "."
         db        0,0,18h,18h,0,0,0                  
         db        0,0
         db        16,47
         db        0,0,2,6,0ch,18h,30h                     ; 47  "/"
         db        60h,0c0h,80h,0,0,0,0               
         db        0,0
         db        16,48
         db        0,0,7ch,0c6h,0ceh,0deh,0f6h             ; 48  "0"
         db        0e6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,49
         db        0,0,18h,38h,78h,18h,18h                 ; 49  "1"
         db        18h,18h,18h,7eh,0,0,0              
         db        0,0
         db        16,50
         db        0,0,7ch,0c6h,6,0ch,18h                  ; 50  "2"
         db        30h,60h,0c6h,0feh,0,0,0            
         db        0,0
         db        16,51
         db        0,0,7ch,0c6h,6,6,3ch                    ; 51  "3"
         db        6,6,0c6h,7ch,0,0,0                 
         db        0,0
         db        16,52
         db        0,0,0ch,1ch,3ch,6ch,0cch                ; 52  "4"
         db        0feh,0ch,0ch,1eh,0,0,0             
         db        0,0
         db        16,53
         db        0,0,0feh,0c0h,0c0h,0c0h,0fch            ; 53  "5"
         db        6,6,0c6h,7ch,0,0,0                 
         db        0,0
         db        16,54
         db        0,0,38h,60h,0c0h,0c0h,0fch              ; 54  "6"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,55
         db        0,0,0feh,0c6h,6,0ch,18h                 ; 55  "7"
         db        30h,30h,30h,30h,0,0,0              
         db        0,0
         db        16,56
         db        0,0,7ch,0c6h,0c6h,0c6h,7ch              ; 56  "8"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,57
         db        0,0,7ch,0c6h,0c6h,0c6h,7eh              ; 57  "9"
         db        6,6,0ch,78h,0,0,0                  
         db        0,0
         db        16,58
         db        0,0,0,18h,18h,0,0                       ; 58  ":"
         db        0,18h,18h,0,0,0,0                  
         db        0,0
         db        16,59
         db        0,0,0,18h,18h,0,0                       ; 59  ";"
         db        0,18h,18h,30h,0,0,0                
         db        0,0
         db        16,60
         db        0,0,6,0ch,18h,30h,60h                   ; 60  "<"
         db        30h,18h,0ch,6,0,0,0                
         db        0,0
         db        16,61
         db        0,0,0,0,0,7eh,0                         ; 61  "="
         db        0,7eh,0,0,0,0,0                    
         db        0,0
         db        16,62
         db        0,0,60h,30h,18h,0ch,6                   ; 62  ">"
         db        0ch,18h,30h,60h,0,0,0              
         db        0,0
         db        16,63
         db        0,0,7ch,0c6h,0c6h,0ch,18h               ; 63  "?"
         db        18h,0,18h,18h,0,0,0                
         db        0,0
         db        16,64
         db        0,0,7ch,0c6h,0c6h,0deh,0deh             ; 64  "@"
         db        0deh,0dch,0c0h,7ch,0,0,0           
         db        0,0
         db        16,65
         db        0,0,10h,38h,6ch,0c6h,0c6h               ; 65  "A"
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0
         db        16,66
         db        0,0,0fch,66h,66h,66h,7ch                ; 66  "B"
         db        66h,66h,66h,0fch,0,0,0             
         db        0,0
         db        16,67
         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 67  "C"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0
         db        16,68
         db        0,0,0f8h,6ch,66h,66h,66h                ; 68  "D"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        0,0
         db        16,69
         db        0,0,0feh,66h,62h,68h,78h                ; 69  "E"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,0
         db        16,70
         db        0,0,0feh,66h,62h,68h,78h                ; 70  "F"
         db        68h,60h,60h,0f0h,0,0,0             
         db        0,0
         db        16,71
         db        0,0,3ch,66h,0c2h,0c0h,0c0h              ; 71  "G"
         db        0deh,0c6h,66h,3ah,0,0,0            
         db        0,0
         db        16,72
         db        0,0,0c6h,0c6h,0c6h,0c6h,0feh            ; 72  "H"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0
         db        16,73
         db        0,0,3ch,18h,18h,18h,18h                 ; 73  "I"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,74
         db        0,0,1eh,0ch,0ch,0ch,0ch                 ; 74  "J"
         db        0ch,0cch,0cch,78h,0,0,0            
         db        0,0
         db        16,75
         db        0,0,0e6h,66h,6ch,6ch,78h                ; 75  "K"
         db        6ch,6ch,66h,0e6h,0,0,0             
         db        0,0
         db        16,76
         db        0,0,0f0h,60h,60h,60h,60h                ; 76  "L"
         db        60h,62h,66h,0feh,0,0,0             
         db        0,0
         db        16,77
         db        0,0,0c6h,0eeh,0feh,0feh,0d6h            ; 77  "M"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0
         db        16,78
         db        0,0,0c6h,0e6h,0f6h,0feh,0deh            ; 78  "N"
         db        0ceh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0
         db        16,79
         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 79  "O"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0
         db        16,80
         db        0,0,0fch,66h,66h,66h,7ch                ; 80  "P"
         db        60h,60h,60h,0f0h,0,0,0             
         db        0,0
         db        16,81
         db        0,0,7ch,0c6h,0c6h,0c6h,0c6h             ; 81  "Q"
         db        0d6h,0deh,7ch,0ch,0eh,0,0          
         db        0,0
         db        16,82
         db        0,0,0fch,66h,66h,66h,7ch                ; 82  "R"
         db        6ch,66h,66h,0e6h,0,0,0             
         db        0,0
         db        16,83
         db        0,0,7ch,0c6h,0c6h,60h,38h               ; 83  "S"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        0,0
         db        16,84
         db        0,0,7eh,7eh,5ah,18h,18h                 ; 84  "T"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,85
         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 85  "U"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,86
         db        0,0,0c6h,0c6h,0c6h,0c6h,0c6h            ; 86  "V"
         db        0c6h,6ch,38h,10h,0,0,0             
         db        0,0
         db        16,87
         db        0,0,0c6h,0c6h,0c6h,0c6h,0d6h            ; 87  "W"
         db        0d6h,0feh,7ch,6ch,0,0,0            
         db        0,0
         db        16,88
         db        0,0,0c6h,0c6h,6ch,38h,38h               ; 88  "X"
         db        38h,6ch,0c6h,0c6h,0,0,0            
         db        0,0
         db        16,89
         db        0,0,66h,66h,66h,66h,3ch                 ; 89  "Y"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,90
         db        0,0,0feh,0c6h,8ch,18h,30h               ; 90  "Z"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,0
         db        16,91
         db        0,0,3ch,30h,30h,30h,30h                 ; 91  "["
         db        30h,30h,30h,3ch,0,0,0              
         db        0,0
         db        16,92
         db        0,0,80h,0c0h,0e0h,70h,38h               ; 92  "\"
         db        1ch,0eh,6,2,0,0,0                  
         db        0,0
         db        16,93
         db        0,0,3ch,0ch,0ch,0ch,0ch                 ; 93  "]"
         db        0ch,0ch,0ch,3ch,0,0,0              
         db        0,0
         db        16,94
         db        10h,38h,6ch,0c6h,0,0,0                  ; 94  "^"
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,95
         db        0,0,0,0,0,0,0                           ; 95  "_"
         db        0,0,0,0,0,0ffh,0                   
         db        0,0
         db        16,96
         db        30h,30h,18h,0,0,0,0                     ; 96  "`"
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,97
         db        0,0,0,0,0,78h,0ch                       ; 97  "a"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0
         db        16,98
         db        0,0,0e0h,60h,60h,78h,6ch                ; 98  "b"
         db        66h,66h,66h,7ch,0,0,0              
         db        0,0
         db        16,99
         db        0,0,0,0,0,7ch,0c6h                      ; 99  "c"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,100
         db        0,0,1ch,0ch,0ch,3ch,6ch                 ; 100 "d"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0
         db        16,101
         db        0,0,0,0,0,7ch,0c6h                      ; 101 "e"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,102
         db        0,0,38h,6ch,64h,60h,0f0h                ; 102 "f"
         db        60h,60h,60h,0f0h,0,0,0             
         db        0,0
         db        16,103
         db        0,0,0,0,0,76h,0cch                      ; 103 "g"
         db        0cch,0cch,7ch,0ch,0cch,78h,0       
         db        0,0
         db        16,104
         db        0,0,0e0h,60h,60h,6ch,76h                ; 104 "h"
         db        66h,66h,66h,0e6h,0,0,0             
         db        0,0
         db        16,105
         db        0,0,18h,18h,0,38h,18h                   ; 105 "i"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,106
         db        0,0,6,6,0,0eh,6                         ; 106 "j"
         db        6,6,6,66h,66h,3ch,0                
         db        0,0
         db        16,107
         db        0,0,0e0h,60h,60h,66h,6ch                ; 107 "k"
         db        78h,6ch,66h,0e6h,0,0,0             
         db        0,0
         db        16,108
         db        0,0,38h,18h,18h,18h,18h                 ; 108 "l"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,109
         db        0,0,0,0,0,0ech,0feh                     ; 109 "m"
         db        0d6h,0d6h,0d6h,0c6h,0,0,0          
         db        0,0
         db        16,110
         db        0,0,0,0,0,0dch,66h                      ; 110 "n"
         db        66h,66h,66h,66h,0,0,0              
         db        0,0
         db        16,111
         db        0,0,0,0,0,7ch,0c6h                      ; 111 "o"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,112
         db        0,0,0,0,0,0dch,66h                      ; 112 "p"
         db        66h,66h,7ch,60h,60h,0f0h,0         
         db        0,0
         db        16,113
         db        0,0,0,0,0,76h,0cch                      ; 113 "q"
         db        0cch,0cch,7ch,0ch,0ch,1eh,0        
         db        0,0
         db        16,114
         db        0,0,0,0,0,0dch,76h                      ; 114 "r"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0
         db        16,115
         db        0,0,0,0,0,7ch,0c6h                      ; 115 "s"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0,0
         db        16,116
         db        0,0,10h,30h,30h,0fch,30h                ; 116 "t"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,0
         db        16,117
         db        0,0,0,0,0,0cch,0cch                     ; 117 "u"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0
         db        16,118
         db        0,0,0,0,0,66h,66h                       ; 118 "v"
         db        66h,66h,3ch,18h,0,0,0              
         db        0,0
         db        16,119
         db        0,0,0,0,0,0c6h,0c6h                     ; 119 "w"
         db        0d6h,0d6h,0feh,6ch,0,0,0           
         db        0,0
         db        16,120
         db        0,0,0,0,0,0c6h,6ch                      ; 120 "x"
         db        38h,38h,6ch,0c6h,0,0,0             
         db        0,0
         db        16,121
         db        0,0,0,0,0,0c6h,0c6h                     ; 121 "y"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0,0
         db        16,122
         db        0,0,0,0,0,0feh,0cch                     ; 122 "z"
         db        18h,30h,66h,0feh,0,0,0             
         db        0,0
         db        16,123
         db        0,0,0eh,18h,18h,18h,70h                 ; 123 "{"
         db        18h,18h,18h,0eh,0,0,0              
         db        0,0
         db        16,124
         db        0,0,18h,18h,18h,18h,0                   ; 124 "|"
         db        18h,18h,18h,18h,0,0,0              
         db        0,0
         db        16,125
         db        0,0,70h,18h,18h,18h,0eh                 ; 125 "}"
         db        18h,18h,18h,70h,0,0,0              
         db        0,0
         db        16,126
         db        0,0,76h,0dch,0,0,0                      ; 126 "~"
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,127
         db        0,0,0,0,10h,38h,6ch                     ; 127 ""
         db        0c6h,0c6h,0feh,0,0,0,0             
         db        0,0
         db        16,128
         db        66h,3ch,3ch,66h,0c2h,0c0h,0c0h          ; 128 "Ä"
         db        0c0h,0c2h,66h,3ch,0,0,0            
         db        0,0
         db        16,129
         db        0,0,0cch,0cch,0,0cch,0cch               ; 129 "Å"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0
         db        16,130
         db        0,6,0ch,18h,0,7ch,0c6h                  ; 130 "Ç"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,131
         db        6ch,38h,1ch,0ch,0ch,3ch,6ch             ; 131 "É"
         db        0cch,0cch,0cch,7eh,0,0,0           
         db        0,0
         db        16,132
         db        0,0,0cch,0cch,0,78h,0ch                 ; 132 "Ñ"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0
         db        16,133
         db        0cch,78h,0f8h,6ch,66h,66h,66h           ; 133 "Ö"
         db        66h,66h,6ch,0f8h,0,0,0             
         db        0,0
         db        16,134
         db        66h,3ch,7eh,7eh,5ah,18h,18h             ; 134 "Ü"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,135
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 135 "á"
         db        0c0h,0c0h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,136
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 136 "à"
         db        0feh,0c0h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,137
         db        66h,3ch,0feh,66h,62h,68h,78h            ; 137 "â"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,0
         db        16,138
         db        0,6,0f6h,64h,60h,60h,60h                ; 138 "ä"
         db        60h,62h,66h,0feh,0,0,0             
         db        0,0
         db        16,139
         db        0ch,18h,3ch,18h,18h,18h,18h             ; 139 "ã"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,140
         db        36h,1ch,70h,30h,30h,30h,30h             ; 140 "å"
         db        30h,30h,30h,78h,0,0,0              
         db        0,0
         db        16,141
         db        6h,6,74h,30h,30h,30h,30h                ; 141 "ç"
         db        30h,30h,30h,78h,0,0,0              
         db        0,0
         db        16,142
         db        0c6h,0c6h,10h,38h,6ch,0c6h,0c6h         ; 142 "é"
         db        0feh,0c6h,0c6h,0c6h,0,0,0
         db        0,0
         db        16,143
         db        6h,0ch,10h,38h,6ch,0c6h,0c6h            ; 143 "è"
         db        0feh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0
         db        16,144
         db        0ch,18h,0feh,66h,62h,68h,78h            ; 144 "ê"
         db        68h,62h,66h,0feh,0,0,0             
         db        0,0
         db        16,145
         db        0,0,0cch,78h,0,0feh,0cch                ; 145 "ë"
         db        18h,30h,66h,0feh,0,0,0             
         db        0,0
         db        16,146
         db        66h,3ch,0feh,0c6h,8ch,18h,30h           ; 146 "í"
         db        60h,0c2h,0c6h,0feh,0,0,0           
         db        0,0
         db        16,147
         db        0,10h,38h,6ch,0,7ch,0c6h                ; 147 "ì"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,148
         db        0,0,0c6h,0c6h,0,7ch,0c6h                ; 148 "î"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,149
         db        6,0ch,38h,6ch,0c6h,0c6h,0c6h            ; 149 "ï"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0
         db        16,150
         db        0,38h,6ch,38h,0,0cch,0cch               ; 150 "ñ"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0
         db        16,151
         db        0ch,18h,0c6h,0c6h,0c6h,0c6h,0c6h        ; 151 "ó"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,152
         db        0,6,0ch,18h,0,0c6h,0c6h                 ; 152 "ò"
         db        0c6h,0c6h,7eh,6,0ch,0f8h,0         
         db        0,0
         db        16,153
         db        0c6h,0c6h,38h,6ch,0c6h,0c6h,0c6h        ; 153 "ô"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0
         db        16,154
         db        0c6h,0c6h,0,0c6h,0c6h,0c6h,0c6h         ; 154 "ö"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,155
         db        66h,3ch,7ch,0c6h,0c6h,60h,38h           ; 155 "õ"
         db        0ch,0c6h,0c6h,7ch,0,0,0            
         db        0,0
         db        16,156
         db        36h,1ch,0f0h,60h,60h,60h,60h            ; 156 "ú"
         db        60h,62h,66h,0feh,0,0,0             
         db        0,0
         db        16,157
         db        0ch,18h,66h,66h,66h,66h,3ch             ; 157 "ù"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,158
         db        66h,3ch,0fch,66h,66h,66h,7ch            ; 158 "û"
         db        6ch,66h,66h,0f6h,0,0,0             
         db        0,0
         db        16,159
         db        36h,1ch,10h,30h,30h,0fch,30h            ; 159 "ü"
         db        30h,30h,36h,1ch,0,0,0              
         db        0,0
         db        16,160
         db        0,0ch,18h,30h,0,78h,0ch                 ; 160 "†"
         db        7ch,0cch,0cch,76h,0,0,0            
         db        0,0
         db        16,161
         db        0,6,0ch,18h,0,38h,18h                   ; 161 "°"
         db        18h,18h,18h,3ch,0,0,0              
         db        0,0
         db        16,162
         db        0,0ch,18h,30h,0,7ch,0c6h                ; 162 "¢"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,163
         db        0,0ch,18h,30h,0,0cch,0cch               ; 163 "£"
         db        0cch,0cch,0cch,76h,0,0,0           
         db        0,0
         db        16,164
         db        0,0,66h,3ch,0,0dch,66h                  ; 164 "§"
         db        66h,66h,66h,66h,0,0,0              
         db        0,0
         db        16,165
         db        66h,3ch,0c6h,0e6h,0f6h,0feh,0deh        ; 165 "•"
         db        0ceh,0c6h,0c6h,0c6h,0,0,0          
         db        0,0
         db        16,166
         db        3ch,66h,3ch,0c6h,0c6h,0c6h,0c6h         ; 166 "¶"
         db        0c6h,0c6h,0c6h,7ch,0,0,0           
         db        0,0
         db        16,167
         db        7ch,0c6h,38h,6ch,0c6h,0c6h,0c6h         ; 167 "ß"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0
         db        16,168
         db        0,0,66h,3ch,0,7ch,0c6h                  ; 168 "®"
         db        70h,1ch,0c6h,7ch,0,0,0             
         db        0,0
         db        16,169
         db        0,0,0cch,78h,0,0dch,76h                 ; 169 "©"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0
         db        16,170
         db        0,0,0ch,18h,0,0dch,76h                  ; 170 "™"
         db        66h,60h,60h,0f0h,0,0,0             
         db        0,0
         db        16,171
         db        0ch,18h,0fch,66h,66h,66h,7ch            ; 171 "´"
         db        6ch,66h,66h,0e6h,0,0,0             
         db        0,0
         db        16,172
         db        0,0c0h,0c0h,0c6h,0cch,0d8h,30h          ; 172 "¨"
         db        66h,0ceh,9eh,3eh,6,6,0             
         db        0,0
         db        16,173
         db        0,0,7ch,0c6h,60h,38h,6ch                ; 173 "≠"
         db        0c6h,6ch,38h,0ch,0c6h,7ch,0        
         db        0,0
         db        16,174
         db        0,0,0,0,36h,6ch,0d8h                    ; 174 "Æ"
         db        6ch,36h,0,0,0,0,0                  
         db        0,0
         db        16,175
         db        0,0,0,0,0d8h,6ch,36h                    ; 175 "Ø"
         db        6ch,0d8h,0,0,0,0,0                 
         db        0,0
         db        16,176
         db        11h,44h,11h,44h,11h,44h,11h             ; 176 "∞"
         db        44h,11h,44h,11h,44h,11h,44h        
         db        11h,44h
         db        16,177
         db        55h,0aah,55h,0aah,55h,0aah,55h          ; 177 "±"
         db        0aah,55h,0aah,55h,0aah,55h,0aah    
         db        55h,0aah
         db        16,178
         db        0ddh,77h,0ddh,77h,0ddh,77h,0ddh         ; 178 "≤"
         db        77h,0ddh,77h,0ddh,77h,0ddh,77h     
         db        0ddh,77h
         db        16,179
         db        18h,18h,18h,18h,18h,18h,18h             ; 179 "≥"
         db        18h,18h,18h,18h,18h,18h,18h        
         db        18h,18h
         db        16,180
         db        18h,18h,18h,18h,18h,18h,18h             ; 180 "¥"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        18h,18h
         db        16,181
         db        18h,18h,18h,18h,18h,0f8h,18h            ; 181 "µ"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        18h,18h
         db        16,182
         db        36h,36h,36h,36h,36h,36h,36h             ; 182 "∂"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        36h,36h
         db        16,183
         db        0,0,0,0,0,0,0                           ; 183 "∑"
         db        0feh,36h,36h,36h,36h,36h,36h       
         db        36h,36h
         db        16,184
         db        0,0,0,0,0,0f8h,18h                      ; 184 "∏"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        18h,18h
         db        16,185
         db        36h,36h,36h,36h,36h,0f6h,6              ; 185 "π"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        36h,36h
         db        16,186
         db        36h,36h,36h,36h,36h,36h,36h             ; 186 "∫"
         db        36h,36h,36h,36h,36h,36h,36h        
         db        36h,36h
         db        16,187
         db        0,0,0,0,0,0feh,6                        ; 187 "ª"
         db        0f6h,36h,36h,36h,36h,36h,36h       
         db        36h,36h
         db        16,188
         db        36h,36h,36h,36h,36h,0f6h,6              ; 188 "º"
         db        0feh,0,0,0,0,0,0                   
         db        0,0
         db        16,189
         db        36h,36h,36h,36h,36h,36h,36h             ; 189 "Ω"
         db        0feh,0,0,0,0,0,0                   
         db        0,0
         db        16,190
         db        18h,18h,18h,18h,18h,0f8h,18h            ; 190 "æ"
         db        0f8h,0,0,0,0,0,0                   
         db        0,0
         db        16,191
         db        0,0,0,0,0,0,0                           ; 191 "ø"
         db        0f8h,18h,18h,18h,18h,18h,18h       
         db        18h,18h
         db        16,192
         db        18h,18h,18h,18h,18h,18h,18h             ; 192 "¿"
         db        1fh,0,0,0,0,0,0                    
         db        0,0
         db        16,193
         db        18h,18h,18h,18h,18h,18h,18h             ; 193 "¡"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0
         db        16,194
         db        0,0,0,0,0,0,0                           ; 194 "¬"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h
         db        16,195
         db        18h,18h,18h,18h,18h,18h,18h             ; 195 "√"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        18h,18h
         db        16,196
         db        0,0,0,0,0,0,0                           ; 196 "ƒ"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0
         db        16,197
         db        18h,18h,18h,18h,18h,18h,18h             ; 197 "≈"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h
         db        16,198
         db        18h,18h,18h,18h,18h,1fh,18h             ; 198 "∆"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        18h,18h
         db        16,199
         db        36h,36h,36h,36h,36h,36h,36h             ; 199 "«"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        36h,36h
         db        16,200
         db        36h,36h,36h,36h,36h,37h,30h             ; 200 "»"
         db        3fh,0,0,0,0,0,0                    
         db        0,0
         db        16,201
         db        0,0,0,0,0,3fh,30h                       ; 201 "…"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        36h,36h
         db        16,202
         db        36h,36h,36h,36h,36h,0f7h,0              ; 202 " "
         db        0ffh,0,0,0,0,0,0                   
         db        0,0
         db        16,203
         db        0,0,0,0,0,0ffh,0                        ; 203 "À"
         db        0f7h,36h,36h,36h,36h,36h,36h       
         db        36h,36h
         db        16,204
         db        36h,36h,36h,36h,36h,37h,30h             ; 204 "Ã"
         db        37h,36h,36h,36h,36h,36h,36h        
         db        36h,36h
         db        16,205
         db        0,0,0,0,0,0ffh,0                        ; 205 "Õ"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0
         db        16,206
         db        36h,36h,36h,36h,36h,0f7h,0              ; 206 "Œ"
         db        0f7h,36h,36h,36h,36h,36h,36h       
         db        36h,36h
         db        16,207
         db        18h,18h,18h,18h,18h,0ffh,0              ; 207 "œ"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0
         db        16,208
         db        36h,36h,36h,36h,36h,36h,36h             ; 208 "–"
         db        0ffh,0,0,0,0,0,0                   
         db        0,0
         db        16,209
         db        0,0,0,0,0,0ffh,0                        ; 209 "—"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h
         db        16,210
         db        0,0,0,0,0,0,0                           ; 210 "“"
         db        0ffh,36h,36h,36h,36h,36h,36h       
         db        36h,36h
         db        16,211
         db        36h,36h,36h,36h,36h,36h,36h             ; 211 "”"
         db        3fh,0,0,0,0,0,0                    
         db        0,0
         db        16,212
         db        18h,18h,18h,18h,18h,1fh,18h             ; 212 "‘"
         db        1fh,0,0,0,0,0,0                    
         db        0,0
         db        16,213
         db        0,0,0,0,0,1fh,18h                       ; 213 "’"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        18h,18h
         db        16,214
         db        0,0,0,0,0,0,0                           ; 214 "÷"
         db        3fh,36h,36h,36h,36h,36h,36h        
         db        36h,36h
         db        16,215
         db        36h,36h,36h,36h,36h,36h,36h             ; 215 "◊"
         db        0ffh,36h,36h,36h,36h,36h,36h       
         db        36h,36h
         db        16,216
         db        18h,18h,18h,18h,18h,0ffh,18h            ; 216 "ÿ"
         db        0ffh,18h,18h,18h,18h,18h,18h       
         db        18h,18h
         db        16,217
         db        18h,18h,18h,18h,18h,18h,18h             ; 217 "Ÿ"
         db        0f8h,0,0,0,0,0,0                   
         db        0,0
         db        16,218
         db        0,0,0,0,0,0,0                           ; 218 "⁄"
         db        1fh,18h,18h,18h,18h,18h,18h        
         db        18h,18h
         db        16,219
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 219 "€"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0ffh,0ffh
         db        16,220
         db        0,0,0,0,0,0,0                           ; 220 "‹"
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh 
         db        0ffh,0ffh
         db        16,221
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h      ; 221 "›"
         db        0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h 
         db        0f0h,0f0h
         db        16,222
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh             ; 222 "ﬁ"
         db        0fh,0fh,0fh,0fh,0fh,0fh,0fh        
         db        0fh,0fh
         db        16,223
         db        0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh      ; 223 "ﬂ"
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,224
         db        0,0,0,0,0,76h,0dch                      ; 224 "‡"
         db        0d8h,0d8h,0dch,76h,0,0,0           
         db        0,0
         db        16,225
         db        0,0,0,0,7ch,0c6h,0fch                   ; 225 "·"
         db        0c6h,0c6h,0fch,0c0h,0c0h,0c0h,40h
         db        0,0
         db        16,226
         db        0,0,0feh,0c6h,0c6h,0c0h,0c0h            ; 226 "‚"
         db        0c0h,0c0h,0c0h,0c0h,0,0,0          
         db        0,0
         db        16,227
         db        0,0,0,0,0feh,6ch,6ch                    ; 227 "„"
         db        6ch,6ch,6ch,6ch,0,0,0              
         db        0,0
         db        16,228
         db        0,0,0feh,0c6h,60h,30h,18h               ; 228 "‰"
         db        30h,60h,0c6h,0feh,0,0,0            
         db        0,0
         db        16,229
         db        0,0,0,0,0,7eh,0d8h                      ; 229 "Â"
         db        0d8h,0d8h,0d8h,70h,0,0,0           
         db        0,0
         db        16,230
         db        0,0,0,0,66h,66h,66h                     ; 230 "Ê"
         db        66h,66h,7ch,60h,60h,0c0h,0
         db        0,0
         db        16,231
         db        0,0,0,0,76h,0dch,18h                    ; 231 "Á"
         db        18h,18h,18h,0ch,0,0,0
         db        0,0
         db        16,232
         db        0,0,7eh,18h,3ch,66h,66h                 ; 232 "Ë"
         db        66h,3ch,18h,7eh,0,0,0              
         db        0,0
         db        16,233
         db        0,0,38h,6ch,0c6h,0c6h,0feh              ; 233 "È"
         db        0c6h,0c6h,6ch,38h,0,0,0            
         db        0,0
         db        16,234
         db        0,0,38h,6ch,0c6h,0c6h,0c6h              ; 234 "Í"
         db        6ch,6ch,6ch,0eeh,0,0,0             
         db        0,0
         db        16,235
         db        0,0,1eh,30h,18h,0ch,3eh                 ; 235 "Î"
         db        66h,66h,66h,3ch,0,0,0              
         db        0,0
         db        16,236
         db        0,0,0,0,0,7eh,0dbh                      ; 236 "Ï"
         db        0dbh,7eh,0,0,0,0,0                 
         db        0,0
         db        16,237
         db        0,0,3,6,7eh,0dbh,0dbh                   ; 237 "Ì"
         db        0f3h,7eh,60h,0c0h,0,0,0            
         db        0,0
         db        16,238
         db        0,0,1ch,30h,60h,60h,7ch                 ; 238 "Ó"
         db        60h,60h,30h,1ch,0,0,0              
         db        0,0
         db        16,239
         db        0,0,0,7ch,0c6h,0c6h,0c6h                ; 239 "Ô"
         db        0c6h,0c6h,0c6h,0c6h,0,0,0          
         db        0,0
         db        16,240
         db        0,0,0,0feh,0,0,0feh                     ; 240 ""
         db        0,0,0feh,0,0,0,0                   
         db        0,0
         db        16,241
         db        0,0,0,18h,18h,7eh,18h                   ; 241 "Ò"
         db        18h,0,0,0ffh,0,0,0                 
         db        0,0
         db        16,242
         db        0,0,30h,18h,0ch,6,0ch                   ; 242 "Ú"
         db        18h,30h,0,7eh,0,0,0                
         db        0,0
         db        16,243
         db        0,0,0ch,18h,30h,60h,30h                 ; 243 "Û"
         db        18h,0ch,0,7eh,0,0,0                
         db        0,0
         db        16,244
         db        0,0,0eh,1bh,1bh,18h,18h                 ; 244 "Ù"
         db        18h,18h,18h,18h,18h,18h,18h        
         db        18h,18h
         db        16,245
         db        18h,18h,18h,18h,18h,18h,18h             ; 245 "ı"
         db        18h,0d8h,0d8h,70h,0,0,0            
         db        0,0
         db        16,246
         db        0,0,0,18h,18h,0,7eh                     ; 246 "ˆ"
         db        0,18h,18h,0,0,0,0                  
         db        0,0
         db        16,247
         db        0,0,0,0,76h,0dch,0                      ; 247 "˜"
         db        76h,0dch,0,0,0,0,0                 
         db        0,0
         db        16,248
         db        0,38h,6ch,6ch,38h,0,0                   ; 248 "¯"
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,249
         db        0,0,0,0,0,0,18h                         ; 249 "˘"
         db        18h,0,0,0,0,0,0                    
         db        0,0
         db        16,250
         db        0,0,0,0,0,0,0                           ; 250 "˙"
         db        18h,0,0,0,0,0,0                    
         db        0,0
         db        16,251
         db        0,0fh,0ch,0ch,0ch,0ch,0ch               ; 251 "˚"
         db        0ech,6ch,3ch,1ch,0,0,0             
         db        0,0
         db        16,252
         db        0,0d8h,6ch,6ch,6ch,6ch,6ch              ; 252 "¸"
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,253
         db        0,70h,0d8h,30h,60h,0c8h,0f8h            ; 253 "˝"
         db        0,0,0,0,0,0,0                      
         db        0,0
         db        16,254
         db        0,0,0,0,7ch,7ch,7ch                     ; 254 "˛"
         db        7ch,7ch,7ch,0,0,0,0                
         db        0,0
         db        16,255
         db        0,07ch,044h,044h,044h,07ch,038h          ; 255
         db        0feh,09eh,0feh,0feh,0,0,0
         db        0,0
;         db        0feh,0feh,0feh,0feh,0eeh,0c6h,0eeh      ; 255
;         db        0feh,0eeh,0eeh,0eeh,0feh,0,0
;         db        0,0

code     ENDS
         end       start
