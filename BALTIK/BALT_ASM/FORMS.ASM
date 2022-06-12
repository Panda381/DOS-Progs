
INCLUDE         def.inc

.Code

; -----------------------------------------------------------------------------
;               registrace okna
; -----------------------------------------------------------------------------

FormReg         PROC    Form: DWORD

; --- sestavení jména tøídy okna

                les     di,Form
                add     di,WClassName0          ; buffer èísla tøídy
                call    DekHWord,HInstance, es di ; dekódování ident. aplikace
                les     di,Form
                mov     ax,es                   ; segment popisovaèe tøídy
                add     ax,di                   ; -> identifikátor tøídy
                add     di,WClassName0+4        ; buffer èísla tøídy
                call    DekHWord,ax, es di      ; dekódování ident. tøídy

; --- inicializace tøídy popisovaèe okna

                les     di,Form
                mov     ax,di
                add     ax,WClassName
                mov     wrd es:[di].WClass.clsLpszClassName,ax
                mov     wrd es:[di].WClass.clsLpszClassName+2,es
                cmp     wrd es:[di].WClass.clsLpfnWndProc+2,0 ; je obsluha ?
                jne     FormReg2
                mov     wrd es:[di].WClass.clsLpfnWndProc, of WndProc ; obsluha
                mov     wrd es:[di].WClass.clsLpfnWndProc+2, seg WndProc
FormReg2:       mov     ax,HInstance            ; aktuální instance
                mov     es:[di].WClass.clsHInstance,ax ; instance pro tøídu okna

; --- inicializace ovladaèe pro kurzor

                cmp     es:[di].WClass.clsHCursor,0 ; je kurzor ?
                jne     FormReg4                ; je kurzor
                call    LOADCURSOR,0,0,IDC_ARROW ; naètení ovladaèe kurzoru
                les     di,Form
                mov     es:[di].WClass.clsHCursor,ax ; typ kurzoru v oknì

; --- inicializace barvy pozadí okna

FormReg4:       cmp     es:[di].WClass.clsHbrBackground,-1 ; je pozadí ?
                jne     FormReg5                ; je pozadí
                call    GETSTOCKOBJECT,LTGRAY_BRUSH ; naètení identifik. barvy
                les     di,Form
                mov     es:[di].WClass.clsHbrBackground,ax ; barva pozadí okna

; --- zaregistrování tøídy okna

FormReg5:       add     di,WClass
                call    REGISTERCLASS,es di     ; zaregistrování tøídy okna
                ret

FormReg         ENDP

; -----------------------------------------------------------------------------
;               vytvoøení okna
; -----------------------------------------------------------------------------

FormCreate      PROC    Form: DWORD

; --- pøíprava ukazatelù okna

                les     di,Form
                cmp     es:[di].FormBounds.bnWidth,CW_USECENTER
                jne     FormCreate1
                mov     es:[di].FormBounds.bnWidth,640

FormCreate1:    cmp     es:[di].FormBounds.bnHeight,CW_USECENTER
                jne     FormCreate2
                mov     es:[di].FormBounds.bnHeight,450

FormCreate2:    cmp     es:[di].FormBounds.bnLeft,CW_USECENTER
                jne     FormCreate3
                mov     es:[di].FormBounds.bnLeft,(800-640)/2

FormCreate3:    cmp     es:[di].FormBounds.bnTop,CW_USECENTER
                jne     FormCreate4
                mov     es:[di].FormBounds.bnTop,(600-450)/2

; --- implicitní jméno formuláøe

FormCreate4:    cmp     wrd es:[di].FormName+2,0
                jne     FormCreate5
                mov     ax,wrd es:[di].WClass.clsLpszClassName
                mov     wrd es:[di].FormName,ax
                mov     ax,wrd es:[di].WClass.clsLpszClassName+2
                mov     wrd es:[di].FormName+2,ax

; --- vytvoøení okna

FormCreate5:    call    CREATEWINDOW,                           \
                        es:[di].WClass.clsLpszClassName,        \  ; tøída
                        es:[di].FormName,                       \  ; titulek
                        es:[di].FormStyleH, es:[di].FormStyleL, \  ; styl
                        es:[di].FormBounds.bnLeft,              \  ; X
                        es:[di].FormBounds.bnTop,               \  ; Y
                        es:[di].FormBounds.bnWidth,             \  ; šíøka
                        es:[di].FormBounds.bnHeight,            \  ; výška
                        es:[di].FormParent,                     \  ; rodiè
                        es:[di].FormMenu,                       \  ; menu
                        HInstance,                              \  ; aplikace
                        0,0                                        ; parametry
                les     di,Form
                mov     es:[di].FormHandle,ax   ; handle okna
                ret

FormCreate      ENDP

; -----------------------------------------------------------------------------
;               implicitní obsluha okna
; -----------------------------------------------------------------------------

WndProc         PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                call    FormEvents,hwnd,wmsg,wparam,lparam,cs of WndProcTab
                ret

WndProc         ENDP

WndProcTab      dw      0

; -----------------------------------------------------------------------------
;               skok na obsluhu zprávy
; -----------------------------------------------------------------------------

FormEvents      PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD,EventTab:DWORD
                USES    es,si

                les     si,EventTab
FormEvents2:    mov     ax,es:[si]              ; èíslo zprávy
                or      ax,ax                   ; je konec tabulky ?
                jz      FormEvents6             ; konec tabulky
                cmp     ax,wmsg                 ; souhlasí èíslo zprávy ?
                je      FormEvents4             ; èíslo zprávy souhlasí
                add     si,6                    ; další položka v tabulce
                jmp     FormEvents2

FormEvents4:    call    dword ptr es:[si+2] PASCAL,hwnd,wmsg,wparam,lparam
                xor     dx,dx                   ; návratový parametr HIGH
                jmp     FormEvents8

FormEvents6:    call    DEFWINDOWPROC,hwnd,wmsg,wparam,lparam ; implicitní
FormEvents8:    ret

FormEvents      ENDP

; -----------------------------------------------------------------------------
;               dekódování slova HEX (4 èíslice)
; -----------------------------------------------------------------------------

DekHWord        PROC    Cislo: WORD, Adresa: DWORD

                mov     ax,Cislo
                mov     al,ah
                mov     ah,0
                call    DekHByte, ax, Adresa
                les     di,Adresa
                inc     di
                inc     di
                call    DekHByte, Cislo, es di
                ret

DekHWord        ENDP

; -----------------------------------------------------------------------------
;               dekódování bajtu HEX (2 èíslice)
; -----------------------------------------------------------------------------

DekHByte        PROC    Cislo: WORD, Adresa: DWORD

                les     di,Adresa
                mov     ax,Cislo
                push    ax
                shr     al,1
                shr     al,1
                shr     al,1
                shr     al,1
                call    DekHChr
                pop     ax
                call    DekHChr
                ret

DekHByte        ENDP

DekHChr         PROC    NEAR

                and     al,0fh
                cmp     al,10
                jb      DekHChr2
                add     al,"A"-("9"+1)
DekHChr2:       add     al,"0"
                cld
                stosb
                ret

DekHChr         ENDP

                ENDS
                END
