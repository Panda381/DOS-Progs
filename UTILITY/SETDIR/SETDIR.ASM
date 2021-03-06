                                            ; n�vratov� k�dy:
                                            ;   0 = OK
                                            ;   1 = p�eru�en� Ctrl-Break
                                            ;   2 = chybn� zad�n� disku
                                            ;   3 = chybn� zad�n� adres��e
                                            ;   4 = chybn� soubor jm�na adres��e
                                            ;   5 = nen� nic zad�no
Code     SEGMENT
         ASSUME cs:Code,ds:Code
         ORG       100h

; ------ �schova ��sla verze DOS

Start:   mov       ah,30h
         int       21h                      ; na�ten� ��sla DOS
         mov       ds:[VerzeDOS],al         ; ��slo verze DOS

; ------ definice obsluhy p�eru�en� programu

         mov       dx,offset INT23          ; p�eru�en� programu
         mov       ax,2523h
         int       21h                      ; p�edefinov�n� obsluhy p�eru�en�

; ------ p��prava p��kazov�ho ��dku

         cld                                ; sm�r nahoru
         mov       si,81h                   ; za��tek zadan�ho textu
         mov       bh,0                     ; BH <- 0
         mov       bl,ds:[si-1]             ; po�et znak� zadan�ho textu
         mov       byte ptr ds:[si+bx],bh   ; ozna�en� konce textu
         call      PrepTxt                  ; p��prava p��kazov�ho ��dku
         jnc       Start2                   ; je n�jak� zad�n�

; ------ chyba zad�n� - nen� ��dn� text

Start1:  mov       dx,offset ErrTxt
         mov       ah,9
         int       21h
         mov       al,5                     ; k�d chyby - nen� nic zad�no
Start14: jmp       Konec

; ------ test, zda je odkaz na jin� soubor

Start2:  cmp       byte ptr ds:[si],"@"     ; je odkaz na jin� soubor ?
         jne       start3                   ; nen� odkaz na jin� soubor

; ------ p��prava jm�na souboru

         inc       si                       ; p�esko�en� znaku "@"
         call      PrepTxt                  ; p��prava jm�na souboru
         jc        Start1                   ; chyba zad�n�

; ------ na�ten� zadan�ho souboru

         mov       dx,si                    ; DX <- jm�no souboru
         mov       ax,3d00h
         int       21h                      ; otev�en� souboru
         xchg      ax,bx                    ; identifik�tor souboru
Start24: mov       al,4                     ; chyba - chybn� soubor specifikace
         jc        start14                  ; soubor nenalezen
         mov       dx,offset Buffer         ; buffer k na�ten� souboru
         mov       cx,500                   ; max. d�lka souboru
         mov       ah,3fh
         int       21h                      ; na�ten� souboru
         jc        Start24
         xchg      ax,di                    ; po�et na�ten�ch bajt�
         mov       byte ptr ds:[Buffer+di],0 ; ozna�en� konce textu
         mov       ah,3eh
         int       21h                      ; uzav�en� souboru

; ------ p��prava textu

         mov       si,offset buffer         ; za��tek textu v pam�ti
         call      PrepTxt                  ; p��prava textu
         jc        start24                  ; nen� nic zad�no - chybn� soubor

; ------ nastaven� disku

Start3:  cmp       byte ptr ds:[si+1],":"   ; je to ozna�en� disku ?
         jne       Start4                   ; disk nen� zad�n
         cld
         lodsw                              ; na�ten� disku + odd�lov� ":"
         dec       ax                       ; relativn� ��slo disku
         and       al,1fh                   ; ��slo disku
         xchg      ax,dx                    ; DL <- ��slo po�adovan�ho disku
         mov       ah,0eh
         int       21h                      ; nastaven� po�adovan�ho disku
         mov       ah,19h
         int       21h                      ; poskytnut� aktivn�ho disku
         cmp       al,dl                    ; opravdu se disk nastavil ?
         mov       al,2                     ; k�d chyby - chybn� zad�n� disku
         jne       Konec                    ; bylo chybn� zad�n� disku

; ------ nastaven� z�kladn�ho adres��e

Start4:  cmp       byte ptr ds:[si],"\"     ; je z�kladn� adres�� ?
         jne       Start5
         inc       si                       ; p�esko�en� znaku "\"
         mov       dx,offset RootDir        ; z�kladn� adres��
         mov       ah,3bh
         int       21h                      ; nastaven� z�kladn�ho adres��e

; ------ nalezen� konce podadres��e

Start5:  mov       dx,si                    ; �schova za��tku podadres��e
Start6:  cld
         mov       al,ds:[si]               ; na�ten� znaku
         cmp       al,0                     ; je konec textu ?
         je        Start7                   ; je konec textu
         inc       si
         cmp       al,"\"                   ; je odd�lova� podadres��� ?
         jne       Start6                   ; je odd�lova� podadres���
         mov       byte ptr ds:[si-1],0     ; ozna�en� konce textu

; ------ adres�� se nenastavuje, n�sleduje-li ".." (=m��e to b�t soubor)

Start7:  cmp       word ptr ds:[si],".."
         jne       Start8
         cmp       byte ptr ds:[si+2],0
         je        Start72
         cmp       byte ptr ds:[si+2],"\"
         jne       Start8
         inc       si                       ; p�esko�en� koncov�ho znaku "\"
Start72: inc       si
         inc       si                       ; p�esko�en� adres��e ".."
         jmp       short Start5             ; dal� podadres��

; ------ test, zda je dal� podadres��

Start8:  mov       al,0                     ; k�d chyby - OK
         cmp       si,dx                    ; je n�jak� znak ?
         je        Konec                    ; operace OK

; ------ vytvo�en� a nastaven� dlouh�ho podadres��e

         cmp       byte ptr ds:[VerzeDOS],7 ; je DOS 7.xx ?
         jb        Start82                  ; je mal� verze
         mov       ax,7139h
         int       21h                      ; vytvo�en� dlouh�ho adres��e
         stc                                ; p�ednastaven� chyby
         mov       ax,713bh
         int       21h                      ; nastaven� dlouh�ho adres��e
         jc        Start82                  ; chyba
         cmp       ax,7100h                 ; funkce podporovan� ?
         jne       Start5                   ; je to asi OK

; ------ vytvo�en� a nastaven� kr�tk�ho podadres��e

Start82: mov       ah,39h
         int       21h                      ; vytvo�en� po�adovan�ho adres��e
         mov       ah,3bh
         int       21h                      ; nastaven� nov�ho podadres��e
         jnc       start5                   ; operace OK

         mov       al,3                     ; k�d chyby - chyba adres��e
         jmp       short konec              ; konec s chybou

INT23:   mov       al,1                     ; p��znak p�eru�en� Ctrl-Break
Konec:   mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        p��prava textu DS:SI (ni�� AL a BX !) -> CY=nen� nic zad�no
; -----------------------------------------------------------------------------

PrepTxt  PROC      NEAR

; ------ vypu�t�n� mezer p�ed textem -> SI

         cld
PrepTxt2:lodsb                              ; na�ten� znaku
         cmp       al," "                   ; je mezerera ?
         je        PrepTxt2                 ; mezera se vypust�
         cmp       al,9                     ; je tabul�tor ?
         je        PrepTxt2                 ; tabul�tor se vypust�
         dec       si                       ; n�vrat na posledn� znak

; ------ nalezen� konce textu -> BX

         mov       bx,si                    ; BX <- za��tek textu
         dec       bx
PrepTxt3:inc       bx
         mov       al,ds:[bx]
         cmp       al,9                     ; tabul�tor
         jne       PrepTxt4
         mov       al," "                   ; n�hrada mezerou
         mov       ds:[bx],al               ; n�hrada i v textu
PrepTxt4:cmp       al," "                   ; je konec textu ?
         jae       PrepTxt3                 ; je platn� znak

; ------ vypu�t�n� mezer z konce textu

PrepTxt5:cmp       bx,si                    ; je ji� za��tek textu ?
         je        PrepTxt6                 ; je ji� za��tek textu
         dec       bx
         cmp       byte ptr ds:[bx]," "     ; je mezera ?
         je        PrepTxt5                 ; vypu�t�n� mezer
         inc       bx
PrepTxt6:mov       byte ptr ds:[bx],0       ; ozna�en� konce textu
         cmp       byte ptr ds:[si],1       ; text, zda je n�co zad�no
         ret

PrepTxt  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

RootDir  db        '\',0                    ; z�kladn� adres��

VerzeDOS db        0                        ; verze DOS (hlavn� c�slo)

ErrTxt   db        'SETDIR V1.30 - nastaveni/vytvoreni adresare; (c) Miroslav Nemecek 1997',13,10
         db        13,10
         db        ' zadejte: jmeno_pozadovaneho_adresare',13,10
         db        '    nebo: @soubor_se_jmenem_adresare',13,10
         db        13,10
         db        'V prostredi WINDOWS 95 lze pouzivat tez dlouha jmena adresaru.',13,10
         db        '$'

Buffer   label     byte                     ; buffer k na�ten� souboru

Code     ENDS
         END       Start
