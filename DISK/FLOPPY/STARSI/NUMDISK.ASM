
code     segment
         assume    cs:code
         org       100h

start:
         call      getdisk


         mov       dx,offset helptxt
         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[80h]
         cld
start1:  jcxz      chyba
         lodsb
         dec       cx
         cmp       al," "
         jbe       start1
         sub       al,"0"
         jb        chyba
         cmp       al,4
         ja        chyba


         or        al,al
         jnz       start4

         mov       ah,14h
         call      readcmos
         and       al,3eh
         jmp       short start5


start4:  mov       cl,al
         dec       cl
         ror       cl,1
         ror       cl,1

         mov       ah,14h
         call      readcmos
         and       al,3fh
         or        al,1
         or        al,cl
start5:  call      writcmos

         call      sumcmos
         mov       ah,2eh
         mov       al,dh
         call      writcmos
         inc       ah
         mov       al,dl
         call      writcmos

         call      getdisk

         mov       dx,offset poctxt

chyba:   mov       ah,9
         int       21h
         int       20h

                                          ;* kontroln° souáet CMOS (-> DX)
                                            ; VùSTUP: ZY=kontr. souáet souhlas°

sumcmos: push      ax
         mov       ah,10h                   ; poá†teán° adresa
         xor       dx,dx                    ; vòchoz° hodnota kontroln°ho souátu
sumcmos1:call      readcmos                 ; áten° bajtu z cmos
         add       dl,al                    ; p©iáten° nië®°ho bajtu
         adc       dh,0                     ; p©enos do vy®®°ho bajtu
         inc       ah                       ; zvò®en° adresy v pamàti
         cmp       ah,2dh                   ; jsou jië v®echna data ?
         jbe       sumcmos1                 ; nejsou je®tà v®echna data
         mov       ah,2eh                   ; adresa vy®®°ho bajtu kontr. souátu
         call      readcmos                 ; áten° vy®®°ho bajtu kontr. souátu
         cmp       al,dh                    ; souhlas° vy®®° bajt ?
         jne       sumcmos2                 ; vy®®° bajt nesouhlas°
         mov       ah,2fh                   ; adresa nië®°ho bajtu kontr. souátu
         call      readcmos                 ; áten° nië®°ho bajtu kontr. souátu
         cmp       al,dl                    ; souhlas° nië®° bajt ?
sumcmos2:pop       ax
         ret


getdisk: mov       ah,14h
         call      readcmos
         xor       ah,ah
         test      al,1
         jz        start0
         rol       al,1
         rol       al,1
         and       al,3
         inc       al
         mov       ah,al
start0:  add       ah,"0"
         mov       ds:[poctxt0],ah
         ret


                                          ;* áten° bajtu z CMOS (AH=adresa)
readcmos:xchg      ah,al
         out       [70h],al                 ; adresa v CMOS
         xchg      ah,al
         jmp       $+2
         jmp       $+2
         jmp       $+2
         jmp       $+2                      ; prodleva
         in        al,[71h]                 ; áten° bajtu z adresy AH
         ret

                                          ;* z†pis bajtu do CMOS (AH=adresa)
writcmos:xchg      ah,al
         out       [70h],al                 ; adresa v CMOS
         xchg      ah,al
         jmp       $+2
         jmp       $+2
         jmp       $+2
         jmp       $+2                      ; prodleva
         out       [71h],al                 ; z†pis bajtu na adresu AH
         ret


helptxt  db        'Zadejte pocet disketovych mechanik 0 az 4 !',13,10
poctxt   db        'Pocet disketovych mechanik je nyni: '
poctxt0  db        '0',13,10,'$'

code     ends
         end       start
