Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   mov       ah,2ah
         int       21h

         mov       al,dl
         call      DispNum                  ; den

         mov       al,"."
         call      DispChr

         mov       al,dh
         call      DispNum                  ; mˆs¡c

         mov       al,"."
         call      DispChr

         mov       ax,100
         xchg      ax,cx
         div       cl
         call      DispNum                  ; rok (stolet¡)
         mov       al,ah
         call      DispNum                  ; rok

         mov       al," "
         call      DispChr


         mov       ah,2ch
         int       21h

         mov       al,ch
         call      DispNum                  ; hodina

         mov       al,":"
         call      DispChr

         mov       al,cl
         call      DispNum                  ; minuta

         mov       al,":"
         call      DispChr

         mov       al,dh
         call      DispNum                  ; sekunda

         int       20h

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AL (2 ‡¡slice)
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         push      ax
         aam
         add       ax,"00"
         xchg      al,ah
         call      DispChr
         xchg      al,ah
         call      DispChr
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx

         xchg      ax,dx
         mov       ah,2
         int       21h

         pop       dx
         pop       ax
         ret

DispChr  ENDP

Code     ENDS
         END       Start
