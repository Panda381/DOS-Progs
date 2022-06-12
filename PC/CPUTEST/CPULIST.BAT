@echo off
cls
echo.
echo ษอออ VAROVANI อออ VAROVANI อออ VAROVANI อออ VAROVANI อออ VAROVANI อออป
echo บ                                                                    บ
echo บ   Program CPUTEST i tento povelovy soubor jsou urceny pouze pro    บ
echo บ   uzivatele znale programovani v ASSEMBLERU. Neodborne  pouziti    บ
echo บ   programu CPUTEST nebo neodborna modifikace tohoto  poveloveho    บ
echo บ     souboru muze zpusobit vaznou havarii pocitace !!!!!!!!!!!      บ
echo บ                                                                    บ
echo บ   Povelovy soubor muzete nyni prerusit stiskem Ctrl-Break...       บ
echo บ                                                                    บ
echo ศอออ VAROVANI อออ VAROVANI อออ VAROVANI อออ VAROVANI อออ VAROVANI อออผ
echo.
echo  Tento  povelovy soubor vygeneruje vypis rychlosti nejpouzivanejsich
echo  instrukci  procesoru.  Vypis  se provadi soucasne na obrazovku i do
echo  souboru  vypisu  CPULIST.LST. Neni-li rychlost procesoru detekovana
echo  spravne, lze ji zadat uvedenim parametru "/Cn" za jmenem poveloveho
echo  souboru CPULIST (kde "n" je rychlost procesoru v MHz).
echo.
echo U procesoru 80386 a vyssi je nutne vypnout v SETUP BIOS externi CACHE !
echo.
echo  Stisknete libovolnou klavesu nebo preruste stiskem Ctrl-Break:
echo.
pause

CPUTEST %1
CPUTEST %1 > CPULIST.LST
ECHO ----------------------------------
ECHO ---------------------------------- >> CPULIST.LST
CPUTEST , 26 90,90,         "prefix ES:   : " %1
CPUTEST , 26 90,90,         "prefix ES:   : " %1 >> CPULIST.LST
CPUTEST , 37,,              "AAA          : " %1
CPUTEST , 37,,              "AAA          : " %1 >> CPULIST.LST
CPUTEST , D5 0A,,           "AAD          : " %1
CPUTEST , D5 0A,,           "AAD          : " %1 >> CPULIST.LST
CPUTEST , D4 0A,,           "AAM          : " %1
CPUTEST , D4 0A,,           "AAM          : " %1 >> CPULIST.LST
CPUTEST , 3F,,              "AAS          : " %1
CPUTEST , 3F,,              "AAS          : " %1 >> CPULIST.LST
CPUTEST , 12 C3,,           "ADC AL,BL    : " %1
CPUTEST , 12 C3,,           "ADC AL,BL    : " %1 >> CPULIST.LST
CPUTEST , 02 C3,,           "ADD AL,BL    : " %1
CPUTEST , 02 C3,,           "ADD AL,BL    : " %1 >> CPULIST.LST
CPUTEST , 02 CA,,           "ADD CL,DL    : " %1
CPUTEST , 02 CA,,           "ADD CL,DL    : " %1 >> CPULIST.LST
CPUTEST , 02 06 $fffe,,     "ADD AL,[adr] : " %1
CPUTEST , 02 06 $fffe,,     "ADD AL,[adr] : " %1 >> CPULIST.LST
CPUTEST , 04 12,,           "ADD AL,12    : " %1
CPUTEST , 04 12,,           "ADD AL,12    : " %1 >> CPULIST.LST
CPUTEST , 80 C3 12,,        "ADD BL,12    : " %1
CPUTEST , 80 C3 12,,        "ADD BL,12    : " %1 >> CPULIST.LST
CPUTEST , 22 C3,,           "AND AL,BL    : " %1
CPUTEST , 22 C3,,           "AND AL,BL    : " %1 >> CPULIST.LST
CPUTEST , E8 0 0,,          "CALL NEAR    : " %1
CPUTEST , E8 0 0,,          "CALL NEAR    : " %1 >> CPULIST.LST
CPUTEST BB 05 00, FF D3 83 C3 05,83 C3 05, "CALL BX      : " %1
CPUTEST BB 05 00, FF D3 83 C3 05,83 C3 05, "CALL BX      : " %1 >> CPULIST.LST
CPUTEST , 9A $4 @,,         "CALL FAR     : " %1
CPUTEST , 9A $4 @,,         "CALL FAR     : " %1 >> CPULIST.LST
CPUTEST , 98,,              "CBW          : " %1
CPUTEST , 98,,              "CBW          : " %1 >> CPULIST.LST
CPUTEST , F8,,              "CLC          : " %1
CPUTEST , F8,,              "CLC          : " %1 >> CPULIST.LST
CPUTEST , FC,,              "CLD          : " %1
CPUTEST , FC,,              "CLD          : " %1 >> CPULIST.LST
CPUTEST , FA,,              "CLI          : " %1
CPUTEST , FA,,              "CLI          : " %1 >> CPULIST.LST
CPUTEST , F5,,              "CMC          : " %1
CPUTEST , F5,,              "CMC          : " %1 >> CPULIST.LST
CPUTEST , 3B C3,,           "CMP AX,BX    : " %1
CPUTEST , 3B C3,,           "CMP AX,BX    : " %1 >> CPULIST.LST
CPUTEST FC,A6,,             "CMPSB        : " %1
CPUTEST FC,A6,,             "CMPSB        : " %1 >> CPULIST.LST
CPUTEST FC,A7 90,90,        "CMPSW        : " %1
CPUTEST FC,A7 90,90,        "CMPSW        : " %1 >> CPULIST.LST
CPUTEST , 99,,              "CWD          : " %1
CPUTEST , 99,,              "CWD          : " %1 >> CPULIST.LST
CPUTEST , 27,,              "DAA          : " %1
CPUTEST , 27,,              "DAA          : " %1 >> CPULIST.LST
CPUTEST , 2F,,              "DAS          : " %1
CPUTEST , 2F,,              "DAS          : " %1 >> CPULIST.LST
CPUTEST , 48,,              "DEC AX       : " %1
CPUTEST , 48,,              "DEC AX       : " %1 >> CPULIST.LST
CPUTEST B9 78 56, BA 14 32 F7 F1,BA 14 32, "DIV CX       : " %1
CPUTEST B9 78 56, BA 14 32 F7 F1,BA 14 32, "DIV CX       : " %1 >> CPULIST.LST
CPUTEST B9 78 56, BA 14 22 F7 F9,BA 14 22, "IDIV CX      : " %1
CPUTEST B9 78 56, BA 14 22 F7 F9,BA 14 22, "IDIV CX      : " %1 >> CPULIST.LST
CPUTEST B9 78 56, BA 14 22 F7 E9,BA 14 22, "IMUL CX      : " %1
CPUTEST B9 78 56, BA 14 22 F7 E9,BA 14 22, "IMUL CX      : " %1 >> CPULIST.LST
CPUTEST ,E4 61,,            "IN AL,[61h]  : " %1
CPUTEST ,E4 61,,            "IN AL,[61h]  : " %1 >> CPULIST.LST
CPUTEST ,E5 61,,            "IN AX,[61h]  : " %1
CPUTEST ,E5 61,,            "IN AX,[61h]  : " %1 >> CPULIST.LST
CPUTEST BA 61 00,EC,,       "IN AL,DX     : " %1
CPUTEST BA 61 00,EC,,       "IN AL,DX     : " %1 >> CPULIST.LST
CPUTEST BA 61 00,ED,,       "IN AX,DX     : " %1
CPUTEST BA 61 00,ED,,       "IN AX,DX     : " %1 >> CPULIST.LST
CPUTEST ,40,,               "INC AX       : " %1
CPUTEST ,40,,               "INC AX       : " %1 >> CPULIST.LST
if not errorlevel 7 goto NOINSB
CPUTEST FC BA 61 00,6C,,    "INSB         : " %1
CPUTEST FC BA 61 00,6C,,    "INSB         : " %1 >> CPULIST.LST
:NOINSB
rem XOR AX,AX/MOV DS,AX/MOV [8C],12/MOV [8E],@///INT 23/ADD [8C],7///ADD [8C],7
CPUTEST 33 C0 8E D8 C7 6 8C 0 12 0 C7 6 8E 0 @,CD 23 83 6 8C 0 7,83 6 8C 0 7, "INT 23       : " %1
CPUTEST 33 C0 8E D8 C7 6 8C 0 12 0 C7 6 8E 0 @,CD 23 83 6 8C 0 7,83 6 8C 0 7, "INT 23       : " %1 >> CPULIST.LST
rem XOR AX,AX/MOV DS,AX/MOV [0C],11/MOV [0E],@///INT3/ADD [0C],6///ADD [0C],6
CPUTEST 33 C0 8E D8 C7 6 0C 0 11 0 C7 6 0E 0 @,CC 83 6 0C 0 6,83 6 0C 0 6, "INT3         : " %1
CPUTEST 33 C0 8E D8 C7 6 0C 0 11 0 C7 6 0E 0 @,CC 83 6 0C 0 6,83 6 0C 0 6, "INT3         : " %1 >> CPULIST.LST
rem XOR AX,AX/MOV DS,AX/MOV [8C],12/MOV [8E],@/JMP 12/IRET///INT 23/ADD [8C],7///INT 23/ADD [8C],7
CPUTEST EB 01 CF, 9C 9A 2 0 @, 9C 9A $4 @,"IRET         : " %1
CPUTEST EB 01 CF, 9C 9A 2 0 @, 9C 9A $4 @,"IRET         : " %1 >> CPULIST.LST
CPUTEST F9,72 0,,           "JC     (ano) : " %1
CPUTEST F9,72 0,,           "JC     (ano) : " %1 >> CPULIST.LST
CPUTEST F8,72 0,,           "JC     (ne)  : " %1
CPUTEST F8,72 0,,           "JC     (ne)  : " %1 >> CPULIST.LST
if not errorlevel 8 goto NOJC
CPUTEST F9,0F 82 0 0,,      "JC NEAR (ano): " %1
CPUTEST F9,0F 82 0 0,,      "JC NEAR (ano): " %1 >> CPULIST.LST
CPUTEST F8,0F 82 0 0,,      "JC NEAR (ne) : " %1
CPUTEST F8,0F 82 0 0,,      "JC NEAR (ne) : " %1 >> CPULIST.LST
:NOJC
CPUTEST B9 0 0,E3 0,,       "JCXZ   (ano) : " %1
CPUTEST B9 0 0,E3 0,,       "JCXZ   (ano) : " %1 >> CPULIST.LST
CPUTEST B9 1 0,E3 0,,       "JCXZ   (ne)  : " %1
CPUTEST B9 1 0,E3 0,,       "JCXZ   (ne)  : " %1 >> CPULIST.LST
CPUTEST ,EB 0,,             "JMP SHORT    : " %1
CPUTEST ,EB 0,,             "JMP SHORT    : " %1 >> CPULIST.LST
CPUTEST ,E9 0 0,,           "JMP NEAR     : " %1
CPUTEST ,E9 0 0,,           "JMP NEAR     : " %1 >> CPULIST.LST
CPUTEST ,9F,,               "LAHF         : " %1
CPUTEST ,9F,,               "LAHF         : " %1 >> CPULIST.LST
CPUTEST ,C4 36 $fffe,,      "LES SI,[adr] : " %1
CPUTEST ,C4 36 $fffe,,      "LES SI,[adr] : " %1 >> CPULIST.LST
CPUTEST ,8D 07,,            "LEA AX,[BX]  : " %1
CPUTEST ,8D 07,,            "LEA AX,[BX]  : " %1 >> CPULIST.LST
CPUTEST ,F0 2 7,2 7,        "LOCK         : " %1
CPUTEST ,F0 2 7,2 7,        "LOCK         : " %1 >> CPULIST.LST
CPUTEST FC,AC,,             "LODSB        : " %1
CPUTEST FC,AC,,             "LODSB        : " %1 >> CPULIST.LST
CPUTEST FC,AD,,             "LODSW        : " %1
CPUTEST FC,AD,,             "LODSW        : " %1 >> CPULIST.LST
CPUTEST B9 0 0,E2 0 41,41   "LOOP   (ano) : " %1
CPUTEST B9 0 0,E2 0 41,41   "LOOP   (ano) : " %1 >> CPULIST.LST
CPUTEST B9 1 0,E2 0 41,41   "LOOP   (ne)  : " %1
CPUTEST B9 1 0,E2 0 41,41   "LOOP   (ne)  : " %1 >> CPULIST.LST
CPUTEST B9 0 0,E1 0 41,41   "LOOPE  (ano) : " %1
CPUTEST B9 0 0,E1 0 41,41   "LOOPE  (ano) : " %1 >> CPULIST.LST
CPUTEST B9 1 0,E1 0 41,41   "LOOPE  (ne)  : " %1
CPUTEST B9 1 0,E1 0 41,41   "LOOPE  (ne)  : " %1 >> CPULIST.LST
CPUTEST ,B0 12,,            "MOV AL,12    : " %1
CPUTEST ,B0 12,,            "MOV AL,12    : " %1 >> CPULIST.LST
CPUTEST ,B8 34 12,,         "MOV AX,1234  : " %1
CPUTEST ,B8 34 12,,         "MOV AX,1234  : " %1 >> CPULIST.LST
CPUTEST ,BB 34 12,,         "MOV BX,1234  : " %1
CPUTEST ,BB 34 12,,         "MOV BX,1234  : " %1 >> CPULIST.LST
CPUTEST ,8A D9,,            "MOV BL,CL    : " %1
CPUTEST ,8A D9,,            "MOV BL,CL    : " %1 >> CPULIST.LST
CPUTEST ,8B D9,,            "MOV BX,CX    : " %1
CPUTEST ,8B D9,,            "MOV BX,CX    : " %1 >> CPULIST.LST
CPUTEST , 8A 4,,            "MOV AL,[SI]  : " %1
CPUTEST , 8A 4,,            "MOV AL,[SI]  : " %1 >> CPULIST.LST
CPUTEST ,8E C0,,            "MOV ES,AX    : " %1
CPUTEST ,8E C0,,            "MOV ES,AX    : " %1 >> CPULIST.LST
CPUTEST ,C7 6 0 0 34 12,,   "MOV [0],1234 : " %1
CPUTEST ,C7 6 0 0 34 12,,   "MOV [0],1234 : " %1 >> CPULIST.LST
CPUTEST BE 0 80 FC,A4,,     "MOVSB        : " %1
CPUTEST BE 0 80 FC,A4,,     "MOVSB        : " %1 >> CPULIST.LST
CPUTEST BE 0 80 FC,A5 90,90,"MOVSW        : " %1
CPUTEST BE 0 80 FC,A5 90,90,"MOVSW        : " %1 >> CPULIST.LST
CPUTEST B9 56 32 B8 23 12,F7 E1,,"MUL CX       : " %1
CPUTEST B9 56 32 B8 23 12,F7 E1,,"MUL CX       : " %1 >> CPULIST.LST
CPUTEST B0 23,F6 26 $fffe,, "MUL BYTE[adr]: " %1
CPUTEST B0 23,F6 26 $fffe,, "MUL BYTE[adr]: " %1 >> CPULIST.LST
CPUTEST ,F7 D8,,            "NEG AX       : " %1
CPUTEST ,F7 D8,,            "NEG AX       : " %1 >> CPULIST.LST
CPUTEST ,90,,               "NOP          : " %1
CPUTEST ,90,,               "NOP          : " %1 >> CPULIST.LST
CPUTEST ,F7 D0,,            "NOT AX       : " %1
CPUTEST ,F7 D0,,            "NOT AX       : " %1 >> CPULIST.LST
CPUTEST ,F6 D0,,            "NOT AL       : " %1
CPUTEST ,F6 D0,,            "NOT AL       : " %1 >> CPULIST.LST
CPUTEST ,0A C3,,            "OR AL,BL     : " %1
CPUTEST ,0A C3,,            "OR AL,BL     : " %1 >> CPULIST.LST
CPUTEST ,E4 61 E6 61,E4 61, "OUT [61],AL  : " %1
CPUTEST ,E4 61 E6 61,E4 61, "OUT [61],AL  : " %1 >> CPULIST.LST
CPUTEST BA 61 00,EC EE,EC,  "OUT DX,AL    : " %1
CPUTEST BA 61 00,EC EE,EC,  "OUT DX,AL    : " %1 >> CPULIST.LST
CPUTEST ,50 58,50,          "POP AX       : " %1
CPUTEST ,50 58,50,          "POP AX       : " %1 >> CPULIST.LST
CPUTEST ,50,,               "PUSH AX      : " %1
CPUTEST ,50,,               "PUSH AX      : " %1 >> CPULIST.LST
CPUTEST ,9C,,               "PUSHF        : " %1
CPUTEST ,9C,,               "PUSHF        : " %1 >> CPULIST.LST
CPUTEST ,D1 D0,,            "RCL AX,1     : " %1
CPUTEST ,D1 D0,,            "RCL AX,1     : " %1 >> CPULIST.LST
CPUTEST B1 8,D3 D0,,        "RCL AX,CL    : " %1
CPUTEST B1 8,D3 D0,,        "RCL AX,CL    : " %1 >> CPULIST.LST
if not errorlevel 7 goto NORCL
CPUTEST ,C1 D0 8,,          "RCL AX,8     : " %1
CPUTEST ,C1 D0 8,,          "RCL AX,8     : " %1 >> CPULIST.LST
:NORCL
CPUTEST , 41 F3 A6, 41 A6,  "REP          : " %1
CPUTEST , 41 F3 A6, 41 A6,  "REP          : " %1 >> CPULIST.LST
CPUTEST EB 01 C3, E8 -$0, E8 0 0,"RET NEAR     : " %1
CPUTEST EB 01 C3, E8 -$0, E8 0 0,"RET NEAR     : " %1 >> CPULIST.LST
CPUTEST EB 01 CB, 9A 2 0 @, 9A $4 @,"RET FAR      : " %1
CPUTEST EB 01 CB, 9A 2 0 @, 9A $4 @,"RET FAR      : " %1 >> CPULIST.LST
CPUTEST ,D1 C0,,            "ROL AX,1     : " %1
CPUTEST ,D1 C0,,            "ROL AX,1     : " %1 >> CPULIST.LST
CPUTEST ,9E,,               "SAHF         : " %1
CPUTEST ,9E,,               "SAHF         : " %1 >> CPULIST.LST
CPUTEST ,D1 F8,,            "SAR AX,1     : " %1
CPUTEST ,D1 F8,,            "SAR AX,1     : " %1 >> CPULIST.LST
CPUTEST ,1B C3,,            "SBB AX,BX    : " %1
CPUTEST ,1B C3,,            "SBB AX,BX    : " %1 >> CPULIST.LST
CPUTEST FC,AE,,             "SCASB        : " %1
CPUTEST FC,AE,,             "SCASB        : " %1 >> CPULIST.LST
CPUTEST FC,AF 90,90,        "SCASW        : " %1
CPUTEST FC,AF 90,90,        "SCASW        : " %1 >> CPULIST.LST
CPUTEST ,D1 E0,,            "SHL AX,1     : " %1
CPUTEST ,D1 E0,,            "SHL AX,1     : " %1 >> CPULIST.LST
CPUTEST ,D1 E8,,            "SHR AX,1     : " %1
CPUTEST ,D1 E8,,            "SHR AX,1     : " %1 >> CPULIST.LST
CPUTEST ,F9,,               "STC          : " %1
CPUTEST ,F9,,               "STC          : " %1 >> CPULIST.LST
CPUTEST ,FD,,               "STD          : " %1
CPUTEST ,FD,,               "STD          : " %1 >> CPULIST.LST
CPUTEST ,FB,,               "STI          : " %1
CPUTEST ,FB,,               "STI          : " %1 >> CPULIST.LST
CPUTEST FC,AA,,             "STOSB        : " %1
CPUTEST FC,AA,,             "STOSB        : " %1 >> CPULIST.LST
CPUTEST FC,90 AB,90,        "STOSW        : " %1
CPUTEST FC,90 AB,90,        "STOSW        : " %1 >> CPULIST.LST
CPUTEST ,2B C3,,            "SUB AX,BX    : " %1
CPUTEST ,2B C3,,            "SUB AX,BX    : " %1 >> CPULIST.LST
CPUTEST ,85 D8,,            "TEST AX,BX   : " %1
CPUTEST ,85 D8,,            "TEST AX,BX   : " %1 >> CPULIST.LST
CPUTEST ,93,,               "XCHG AX,BX   : " %1
CPUTEST ,93,,               "XCHG AX,BX   : " %1 >> CPULIST.LST
CPUTEST ,87 CB,,            "XCHG BX,CX   : " %1
CPUTEST ,87 CB,,            "XCHG BX,CX   : " %1 >> CPULIST.LST
CPUTEST ,D7,,               "XLAT         : " %1
CPUTEST ,D7,,               "XLAT         : " %1 >> CPULIST.LST
CPUTEST ,33 C3,,            "XOR AX,BX    : " %1
CPUTEST ,33 C3,,            "XOR AX,BX    : " %1 >> CPULIST.LST
