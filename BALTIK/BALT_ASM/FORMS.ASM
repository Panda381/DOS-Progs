
INCLUDE         def.inc

.Code

; -----------------------------------------------------------------------------
;               registrace okna
; -----------------------------------------------------------------------------

FormReg         PROC    Form: DWORD

; --- sestaven� jm�na t��dy okna

                les     di,Form
                add     di,WClassName0          ; buffer ��sla t��dy
                call    DekHWord,HInstance, es di ; dek�dov�n� ident. aplikace
                les     di,Form
                mov     ax,es                   ; segment popisova�e t��dy
                add     ax,di                   ; -> identifik�tor t��dy
                add     di,WClassName0+4        ; buffer ��sla t��dy
                call    DekHWord,ax, es di      ; dek�dov�n� ident. t��dy

; --- inicializace t��dy popisova�e okna

                les     di,Form
                mov     ax,di
                add     ax,WClassName
                mov     wrd es:[di].WClass.clsLpszClassName,ax
                mov     wrd es:[di].WClass.clsLpszClassName+2,es
                cmp     wrd es:[di].WClass.clsLpfnWndProc+2,0 ; je obsluha ?
                jne     FormReg2
                mov     wrd es:[di].WClass.clsLpfnWndProc, of WndProc ; obsluha
                mov     wrd es:[di].WClass.clsLpfnWndProc+2, seg WndProc
FormReg2:       mov     ax,HInstance            ; aktu�ln� instance
                mov     es:[di].WClass.clsHInstance,ax ; instance pro t��du okna

; --- inicializace ovlada�e pro kurzor

                cmp     es:[di].WClass.clsHCursor,0 ; je kurzor ?
                jne     FormReg4                ; je kurzor
                call    LOADCURSOR,0,0,IDC_ARROW ; na�ten� ovlada�e kurzoru
                les     di,Form
                mov     es:[di].WClass.clsHCursor,ax ; typ kurzoru v okn�

; --- inicializace barvy pozad� okna

FormReg4:       cmp     es:[di].WClass.clsHbrBackground,-1 ; je pozad� ?
                jne     FormReg5                ; je pozad�
                call    GETSTOCKOBJECT,LTGRAY_BRUSH ; na�ten� identifik. barvy
                les     di,Form
                mov     es:[di].WClass.clsHbrBackground,ax ; barva pozad� okna

; --- zaregistrov�n� t��dy okna

FormReg5:       add     di,WClass
                call    REGISTERCLASS,es di     ; zaregistrov�n� t��dy okna
                ret

FormReg         ENDP

; -----------------------------------------------------------------------------
;               vytvo�en� okna
; -----------------------------------------------------------------------------

FormCreate      PROC    Form: DWORD

; --- p��prava ukazatel� okna

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

; --- implicitn� jm�no formul��e

FormCreate4:    cmp     wrd es:[di].FormName+2,0
                jne     FormCreate5
                mov     ax,wrd es:[di].WClass.clsLpszClassName
                mov     wrd es:[di].FormName,ax
                mov     ax,wrd es:[di].WClass.clsLpszClassName+2
                mov     wrd es:[di].FormName+2,ax

; --- vytvo�en� okna

FormCreate5:    call    CREATEWINDOW,                           \
                        es:[di].WClass.clsLpszClassName,        \  ; t��da
                        es:[di].FormName,                       \  ; titulek
                        es:[di].FormStyleH, es:[di].FormStyleL, \  ; styl
                        es:[di].FormBounds.bnLeft,              \  ; X
                        es:[di].FormBounds.bnTop,               \  ; Y
                        es:[di].FormBounds.bnWidth,             \  ; ���ka
                        es:[di].FormBounds.bnHeight,            \  ; v��ka
                        es:[di].FormParent,                     \  ; rodi�
                        es:[di].FormMenu,                       \  ; menu
                        HInstance,                              \  ; aplikace
                        0,0                                        ; parametry
                les     di,Form
                mov     es:[di].FormHandle,ax   ; handle okna
                ret

FormCreate      ENDP

; -----------------------------------------------------------------------------
;               implicitn� obsluha okna
; -----------------------------------------------------------------------------

WndProc         PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

                call    FormEvents,hwnd,wmsg,wparam,lparam,cs of WndProcTab
                ret

WndProc         ENDP

WndProcTab      dw      0

; -----------------------------------------------------------------------------
;               skok na obsluhu zpr�vy
; -----------------------------------------------------------------------------

FormEvents      PROC    hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD,EventTab:DWORD
                USES    es,si

                les     si,EventTab
FormEvents2:    mov     ax,es:[si]              ; ��slo zpr�vy
                or      ax,ax                   ; je konec tabulky ?
                jz      FormEvents6             ; konec tabulky
                cmp     ax,wmsg                 ; souhlas� ��slo zpr�vy ?
                je      FormEvents4             ; ��slo zpr�vy souhlas�
                add     si,6                    ; dal�� polo�ka v tabulce
                jmp     FormEvents2

FormEvents4:    call    dword ptr es:[si+2] PASCAL,hwnd,wmsg,wparam,lparam
                xor     dx,dx                   ; n�vratov� parametr HIGH
                jmp     FormEvents8

FormEvents6:    call    DEFWINDOWPROC,hwnd,wmsg,wparam,lparam ; implicitn�
FormEvents8:    ret

FormEvents      ENDP

; -----------------------------------------------------------------------------
;               dek�dov�n� slova HEX (4 ��slice)
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
;               dek�dov�n� bajtu HEX (2 ��slice)
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