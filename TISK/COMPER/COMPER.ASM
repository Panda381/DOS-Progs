
; *****************************************************************************
;                         ovladaá tisk†rny COMPER
; *****************************************************************************

code     segment
         assume    cs:code,ds:code

         org       100h

start:   jmp       init


old17    dd        0

int17    proc      far

         cmp       ah,0
         je        int171

int170:  jmp       dword ptr cs:[old17]

int171:  push      si
         push      cx
         mov       ch,0
         mov       si,offset tabul
int172:  cmp       al,cs:[si]
         je        int175
         inc       si
         mov       cl,cs:[si]
         inc       si
         add       si,cx
         cmp       si,offset tabul0
         jb        int172
         pop       cx
         pop       si
         cmp       al,128
         jb        int170
int173:  mov       al," "
         jmp       short int170

int175:  inc       si
         mov       cl,cs:[si]
         inc       si
         jcxz      int173
int176:  mov       al,cs:[si]
         inc       si
         mov       ah,0
         push      si
         push      cx
         pushf
         call      dword ptr cs:[old17]
         pop       cx
         pop       si
         loop      int176
int177:  pop       cx
         pop       si
         iret


tabul    label     byte

         db        '#',5,'=',8,'"',8,','
         db        '@',3,'O',8,'a'
         db        '[',1,'<'
         db        '\',2,27,'/'
         db        ']',1,'>'
         db        '{',1,'('
         db        '|',2,27,'/'
         db        '}',1,')'
         db        '~',1,'@'
         db        'Ä',3,'C',8,'"'
         db        'Å',1,'}'
         db        'Ç',3,'e',8,39
         db        'É',3,'d',8,39
         db        'Ñ',1,'{'
         db        'Ö',3,'D',8,'"'
         db        'Ü',3,'T',8,'"'
         db        'á',3,'c',8,'"'
         db        'à',3,'e',8,'"'
         db        'â',3,'E',8,'"'
         db        'ä',3,'L',8,39
         db        'ã',3,'I',8,39
         db        'å',3,'l',8,'"'
         db        'ç',3,'l',8,39
         db        'é',1,'['
         db        'è',3,'A',8,39
         db        'ê',3,'E',8,39
         db        'ë',3,'z',8,'"'
         db        'í',3,'Z',8,'"'
         db        'ì',3,'o',8,'^'
         db        'î',1,'|'
         db        'ï',3,'O',8,39
         db        'ñ',3,'}',8,39
         db        'ó',3,'U',8,39
         db        'ò',3,'y',8,39
         db        'ô',1,'\'
         db        'ö',1,']'
         db        'õ',3,'S',8,'"'
         db        'ú',3,'L',8,'"'
         db        'ù',3,'Y',8,39
         db        'û',3,'R',8,'"'
         db        'ü',3,'t',8,'"'
         db        '†',3,'a',8,39
         db        '°',3,'i',8,39
         db        '¢',3,'o',8,39
         db        '£',3,'u',8,39
         db        '§',3,'n',8,'"'
         db        '•',3,'N',8,'"'
         db        '¶',3,']',8,39
         db        'ß',3,'O',8,'^'
         db        '®',3,'s',8,'"'
         db        '©',3,'r',8,'"'
         db        '™',3,'r',8,39
         db        '´',3,'R',8,39
         db        '≠',2,27,' '
         db        176,1,'*'
         db        177,1,'*'
         db        178,1,'*'
         db        179,2,27,47
         db        180,1,'+'
         db        181,1,'+'
         db        182,1,'+'
         db        183,1,'+'
         db        184,1,'+'
         db        185,1,'+'
         db        186,2,27,47
         db        187,1,'+'
         db        188,1,'+'
         db        189,1,'+'
         db        190,1,'+'
         db        191,1,'+'
         db        192,1,'+'
         db        193,1,'+'
         db        194,1,'+'
         db        195,1,'+'
         db        196,1,'-'
         db        197,1,'+'
         db        198,1,'+'
         db        199,1,'+'
         db        200,1,'+'
         db        201,1,'+'
         db        202,1,'+'
         db        203,1,'+'
         db        204,1,'+'
         db        205,1,'-'
         db        206,1,'+'
         db        207,1,'+'
         db        208,1,'+'
         db        209,1,'+'
         db        210,1,'+'
         db        211,1,'+'
         db        212,1,'+'
         db        213,1,'+'
         db        214,1,'+'
         db        215,1,'+'
         db        216,1,'+'
         db        217,1,'+'
         db        218,1,'+'
         db        219,1,'*'
         db        220,1,'*'
         db        221,1,'*'
         db        222,1,'*'
         db        223,1,'*'

tabul0   label     byte



int17    endp




init:    mov       ax,3517h
         int       21h
         mov       word ptr ds:[old17],bx
         mov       word ptr ds:[old17+2],es

         mov       dx,offset int17
         mov       ax,2517h
         int       21h

         xor       ax,ax
         mov       es,ax
         mov       di,478h
         mov       cx,4
         inc       ax
         cld
         rep       stosb

         mov       dx,offset init
         int       27h

code     ends
         end       start
