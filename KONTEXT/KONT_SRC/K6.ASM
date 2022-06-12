
INCLUDE  KDEF.ASM

Code     SEGMENT   BYTE PUBLIC
         ASSUME    cs:Code,ds:Data

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_A0FC   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         jmp       l_A1FE

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_A108   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         mov       bp,ax
         push      bp
         ;jmp       l_A117
         db        0e9h,0,0

l_A117:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         push      di
         mov       ax,0
         call      l_1B0C
         call      l_1970
         mov       ax,0
         mov       bx,[bp-4]
         mov       ss:[bx-6],ax
l_A133:  mov       bx,[bp-4]
         mov       ax,ss:[bx-6]
         cmp       ax,0
         jg        l_A142
         ;jmp       l_A170
         db        0e9h
         dw        l_A170-$-2

l_A142:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         call      l_1950
         mov       ax,[bp+4]
         call      l_1B0C
         call      l_19AD
         mov       bx,[bp-4]
         mov       ax,ss:[bx-6]
         dec       ax
         call      l_1B0C
         call      l_1983
         call      l_1970
l_A170:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         inc       ax
         mov       bx,[bp-2]
         mov       ss:[bx-8],ax
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textovÇho ©†dku
         xor       ah,ah
         mov       ah,al
         mov       al,1
         push      ax
         mov       di,9A51h
         push      cs
         mov       cl,10h
         call      l_1204
         call      l_136C
         mov       bx,[bp-4]
         mov       ss:[bx-6],ax
         mov       bx,[bp-4]
         mov       ax,ss:[bx-6]
         cmp       ax,0
         mov       ax,1
         jz        l_A1B5
         dec       ax
l_A1B5:  push      ax
         mov       bx,[bp-4]
         mov       ax,ss:[bx-6]
         cmp       ax,[bp+4]
         mov       ax,1
         jg        l_A1C6
         dec       ax
l_A1C6:  pop       cx
         or        ax,cx
         push      ax
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jg        l_A1E1
         dec       ax
l_A1E1:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_A1EB
         jmp       l_A133

l_A1EB:  mov       ax,2
         mov       bx,[bp-2]
         mov       ss:[bx-9],al
         ;jmp       l_A1F8
         db        0e9h,0,0

l_A1F8:  mov       sp,bp
         pop       bp
         ret       2

l_A108   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_A0FC)
; -----------------------------------------------------------------------------

l_A1FE:  sub       sp,87h
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         mov       bx,[bp-2]
         mov       ss:[bx-6],ax
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-8]
         push      ss
         push      di
         call      l_384B
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_A232
         ;jmp       l_A23F
         db        0e9h
         dw        l_A23F-$-2

l_A232:  mov       ax,1
         mov       bx,[bp-2]
         mov       ss:[bx-9],al
         jmp       l_A3D7

l_A23F:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textovÇho ©†dku
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_326B]
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         je        l_A25D
         ;jmp       l_A267
         db        0e9h
         dw        l_A267-$-2

l_A25D:  mov       ax,10h
         push      ax
         call      l_A108
         jmp       l_A3D7

l_A267:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textovÇho ©†dku
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3269]
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         je        l_A285
         ;jmp       l_A28F
         db        0e9h
         dw        l_A28F-$-2

l_A285:  mov       ax,2
         push      ax
         call      l_A108
         jmp       l_A3D7

l_A28F:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textovÇho ©†dku
         xor       ah,ah
         push      ax
         call      l_14D9
         mov       ax,30h
         push      ax
         mov       ax,39h
         call      l_14F2
         call      l_15BE
         jnz       l_A2B3
         jmp       l_A34F

l_A2B3:  lea       di,[bp-8Bh]
         push      ss
         push      di
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         push      ax
         mov       ax,0FFh
         call      l_1320                   ; vyjmut° pod©etàzce z ©etàzce
         mov       cl,80h
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         lea       di,[bp-8Bh]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         push      di
         lea       di,[bp-0Ah]
         push      ss
         call      l_0E6C
         mov       ax,[bp-0Ah]
         cmp       ax,0
         jg        l_A2F6
         ;jmp       l_A330
         db        0e9h
         dw        l_A330-$-2

l_A2F6:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         add       ax,[bp-0Ah]
         sub       ax,1
         mov       bx,[bp-2]
         mov       ss:[bx-8],ax
         lea       di,[bp-8Bh]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       ax,1
         push      ax
         mov       ax,[bp-0Ah]
         dec       ax
         call      l_1320                   ; vyjmut° pod©etàzce z ©etàzce
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         push      di
         lea       di,[bp-0Ah]
         push      ss
         call      l_0E6C
         ;jmp       l_A342
         db        0e9h
         dw        l_A342-$-2

l_A330:  mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         inc       ax
         mov       bx,[bp-2]
         mov       ss:[bx-8],ax
l_A342:  mov       ax,2
         mov       bx,[bp-2]
         mov       ss:[bx-9],al
         jmp       l_A3D7

l_A34F:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         mov       [bp-6],ax
         mov       ax,0
         mov       [bp-8],ax
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       bl,[di]
         mov       bh,0
         mov       [bx+di+1],bh
         ;add       di,[bp-6]
         db        3,0BEh,0FAh,0FFh         ;!
         mov       si,offset l_9AB8
         mov       ah,0FEh
         xor       cx,cx
l_A374:  push      di
         dec       di
         dec       si
l_A377:  inc       di
         inc       si
         mov       al,cs:[si]
         cmp       al,ah
         je        l_A396
         cmp       al,[di]
         je        l_A377
         pop       di
l_A385:  inc       si
         cmp       ah,cs:[si]
         jne       l_A385
         inc       si
         inc       cx
         cmp       bh,cs:[si]
         jne       l_A374
         xor       cx,cx
         jmp       short l_A39F

l_A396:  mov       ax,di
         pop       di
         sub       ax,di
         ;mov       [bp-8],ax
         db        89h,86h,0F8h,0FFh        ;!
l_A39F:  ;mov       [bp-6],cx
         db        89h,8Eh,0FAh,0FFh        ;!
         mov       ax,[bp-6]
         cmp       ax,0
         je        l_A3AE
         ;jmp       l_A3BC
         db        0e9h
         dw        l_A3BC-$-2

l_A3AE:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         push      ax
         call      l_9B20
         ;jmp       l_A3D7
         db        0e9h
         dw        l_A3D7-$-2

l_A3BC:  mov       ax,[bp-6]
         mov       bx,[bp-2]
         mov       ss:[bx-9],al
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         add       ax,[bp-8]
         mov       bx,[bp-2]
         mov       ss:[bx-8],ax
l_A3D7:  ;jmp       l_A3DA
         db        0e9h,0,0

l_A3DA:  mov       sp,bp
         pop       bp
         ret

l_A0FC   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_A3DE   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         jmp       l_A5D4

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_A3EA   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         mov       bp,ax
         push      bp
         jmp       l_A58C

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_A3F9   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         push      word ptr [bp-6]
         mov       bp,ax
         push      bp
         jmp       l_A561

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_A40B   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         push      word ptr [bp-6]
         push      word ptr [bp-8]
         mov       bp,ax
         push      bp
         ;jmp       l_A420
         db        0e9h,0,0

l_A420:  dec       sp
         mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         cmp       ax,0
         je        l_A432
         ;jmp       l_A435
         db        0e9h
         dw        l_A435-$-2

l_A432:  jmp       l_A55A

l_A435:  cmp       ax,2
         jl        l_A43F
         cmp       ax,4
         jle       l_A442
l_A43F:  ;jmp       l_A49B
         db        0e9h
         dw        l_A49B-$-2

l_A442:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         cmp       ax,3
         je        l_A453
         ;jmp       l_A468
         db        0e9h
         dw        l_A468-$-2

l_A453:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         push      di
         mov       ax,1
         call      l_1B0C
         call      l_1CE0
         call      l_1970
l_A468:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         cmp       ax,4
         je        l_A479
         ;jmp       l_A48E
         db        0e9h
         dw        l_A48E-$-2

l_A479:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         push      di
         call      l_195F
         db        82h,21h,0a2h,0dah,0fh,49h

         call      l_1970
l_A48E:  mov       ax,2
         push      ax
         call      l_9C15
         call      l_A0FC
         jmp       l_A55A

l_A49B:  cmp       ax,8
         je        l_A4A3
         ;jmp       l_A4B6
         db        0e9h
         dw        l_A4B6-$-2

l_A4A3:  call      l_A0FC
         call      l_A40B
         mov       ax,8
         push      ax
         call      l_9C15
         call      l_A0FC
         jmp       l_A55A

l_A4B6:  cmp       ax,0Ah
         je        l_A4BE
         ;jmp       l_A4D1
         db        0e9h
         dw        l_A4D1-$-2

l_A4BE:  call      l_A0FC
         call      l_A40B
         mov       ax,7
         push      ax
         call      l_9C15
         call      l_A0FC
         jmp       l_A55A

l_A4D1:  cmp       ax,5
         je        l_A4D9
         ;jmp       l_A505
         db        0e9h
         dw        l_A505-$-2

l_A4D9:  call      l_A0FC
         call      l_A3DE
         mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         cmp       ax,6
         jne       l_A4F0
         ;jmp       l_A4FF
         db        0e9h
         dw        l_A4FF-$-2

l_A4F0:  mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         inc       ax
         push      ax
         call      l_9B20
l_A4FF:  call      l_A0FC
         ;jmp       l_A55A
         db        0e9h
         dw        l_A55A-$-2

l_A505:  cmp       ax,13h
         jl        l_A50F
         cmp       ax,1Dh
         jle       l_A512
l_A50F:  ;jmp       l_A54F
         db        0e9h
         dw        l_A54F-$-2

l_A512:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         mov       [bp-0Bh],al
         call      l_A0FC
         mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         cmp       ax,5
         jne       l_A532
         ;jmp       l_A540
         db        0e9h
         dw        l_A540-$-2

l_A532:  mov       bx,[bp-2]
         mov       ax,ss:[bx-6]
         push      ax
         call      l_9B20
         ;jmp       l_A54C
         db        0e9h
         dw        l_A54C-$-2

l_A540:  call      l_A40B
         mov       al,[bp-0Bh]
         xor       ah,ah
         push      ax
         call      l_9C15
l_A54C:  ;jmp       l_A55A
         db        0e9h
         dw        l_A55A-$-2

l_A54F:  mov       bx,[bp-2]
         mov       ax,ss:[bx-6]
         push      ax
         call      l_9B20
l_A55A:  ;jmp       l_A55D
         db        0e9h,0,0

l_A55D:  mov       sp,bp
         pop       bp
         ret

l_A40B   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_A3F9)
; -----------------------------------------------------------------------------

l_A561:  call      l_A40B
l_A564:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         cmp       ax,12h
         je        l_A575
         ;jmp       l_A585
         db        0e9h
         dw        l_A585-$-2

l_A575:  call      l_A0FC
         call      l_A40B
         mov       ax,12h
         push      ax
         call      l_9C15
         ;jmp       l_A564
         db        0e9h
         dw        l_A564-$-2

l_A585:  ;jmp       l_A588
         db        0e9h,0,0

l_A588:  mov       sp,bp
         pop       bp
         ret

l_A3F9   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_A3EA)
; -----------------------------------------------------------------------------

l_A58C:  dec       sp
         call      l_A3F9
l_A590:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         push      ax
         call      l_14D9
         mov       ax,0Eh
         push      ax
         mov       ax,11h
         call      l_14F2
         call      l_15BE
         jnz       l_A5AF
         ;jmp       l_A5CD
         db        0e9h
         dw        l_A5CD-$-2

l_A5AF:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         mov       [bp-7],al
         call      l_A0FC
         call      l_A3F9
         mov       al,[bp-7]
         xor       ah,ah
         push      ax
         call      l_9C15
         ;jmp       l_A590
         db        0e9h
         dw        l_A590-$-2

l_A5CD:  ;jmp       l_A5D0
         db        0e9h,0,0

l_A5D0:  mov       sp,bp
         pop       bp
         ret

l_A3EA   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_A3DE)
; -----------------------------------------------------------------------------

l_A5D4:  dec       sp
         mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         push      ax
         call      l_14D9
         mov       ax,9
         call      l_14EB
         mov       ax,0Ah
         call      l_14EB
         call      l_15BE
         jnz       l_A5F6
         ;jmp       l_A61F
         db        0e9h
         dw        l_A61F-$-2

l_A5F6:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         mov       [bp-5],al
         call      l_A0FC
         call      l_A3EA
         mov       al,[bp-5]
         xor       ah,ah
         cmp       ax,0Ah
         je        l_A615
         ;jmp       l_A61C
         db        0e9h
         dw        l_A61C-$-2

l_A615:  mov       ax,7
         push      ax
         call      l_9C15
l_A61C:  ;jmp       l_A622
         db        0e9h
         dw        l_A622-$-2

l_A61F:  call      l_A3EA
l_A622:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         push      ax
         call      l_14D9
         mov       ax,9
         push      ax
         mov       ax,0Dh
         call      l_14F2
         call      l_15BE
         jnz       l_A641
         ;jmp       l_A65F
         db        0e9h
         dw        l_A65F-$-2

l_A641:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         mov       [bp-5],al
         call      l_A0FC
         call      l_A3EA
         mov       al,[bp-5]
         xor       ah,ah
         push      ax
         call      l_9C15
         ;jmp       l_A622
         db        0e9h
         dw        l_A622-$-2

l_A65F:  ;jmp       l_A662
         db        0e9h,0,0

l_A662:  mov       sp,bp
         pop       bp
         ret

l_A3DE   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_9AB1)
; -----------------------------------------------------------------------------

l_A666:  sub       sp,13h
         mov       ax,1
         mov       [bp-4],ax
         mov       ax,1
         mov       [bp-8],ax
         lea       di,[bp-15h]
         push      ss
         push      di
         mov       ax,0
         call      l_1B0C
         call      l_1970
         call      l_A0FC
         call      l_A3DE
         mov       al,[bp-9]
         xor       ah,ah
         cmp       ax,1
         jne       l_A696
         ;jmp       l_A69E
         db        0e9h
         dw        l_A69E-$-2

l_A696:  mov       ax,[bp-8]
         dec       ax
         push      ax
         call      l_9B20
l_A69E:  les       di,dword ptr [bp+8]
         push      es
         push      di
         lea       di,[bp-15h]
         push      ss
         call      l_1950
         call      l_1970
         ;jmp       l_A6B0
         db        0e9h,0,0

l_A6B0:  mov       sp,bp
         pop       bp
         ret       8

;l_9AB1   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JR a Extra/kalkul†tor (vòpoáty v textu - kalkul†tor)
; -----------------------------------------------------------------------------

l_A6B6   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_A6BD
         db        0e9h,0,0

l_A6BD:  sub       sp,14h
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         call      l_4855                   ; korekce editovanÇho ©†dku
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         cmp       ax,0
         je        l_A6D3
         ;jmp       l_A6D6
         db        0e9h
         dw        l_A6D6-$-2

l_A6D3:  jmp       l_A951

l_A6D6:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         call      l_591F                   ; nulov†n° bufferu £schovò zmàn
         mov       ax,1
         push      ax
         call      l_5972
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      di
         call      l_3631                   ; konverze ©etàzce na velk† p°smena
         mov       si,offset d_EC59         ; buffer textovÇho ©†dku
         mov       cl,[si]
         mov       ch,0
         xor       bx,bx
         xor       dx,dx
         ;mov       [bp-0Ch],dx
         db        89h,96h,0F4h,0FFh
l_A6FA:  inc       bx
         cmp       byte ptr [bx+si],23h
         je        l_A70F
         cmp       byte ptr [bx+si],20h
         je        l_A70B
         or        dx,dx
         jnz       l_A70B
         mov       dx,bx
l_A70B:  loop      l_A6FA
         mov       bx,dx
l_A70F:  ;mov       [bp-4],bx
         db        89h,9Eh,0FCh,0FFh        ;!
         mov       cl,[si]
         mov       ch,0
         cmp       byte ptr [bx+si],23h
         jne       l_A71D
         inc       bx
l_A71D:  mov       di,8
         mov       al,[bx+si]
         cmp       al,2Eh
         jne       l_A73E
         mov       di,0FFFFh
l_A729:  inc       di
         inc       bx
         cmp       bx,cx
         ja        l_A734
         cmp       byte ptr [bx+si],23h
         je        l_A729
l_A734:  cmp       di,8
         jbe       l_A761
         mov       di,8
         jmp       short l_A761

l_A73E:  cmp       al,48h
         jne       l_A74C
         mov       ax,10h
         mov       dl,byte ptr cs:[l_326B]
         jmp       short l_A758

l_A74C:  cmp       al,42h
         jne       l_A761
         mov       ax,2
         mov       dl,byte ptr cs:[l_3269]
l_A758:  ;mov       [bp-0Ch],ax
         db        89h,86h,0F4h,0FFh        ;!
         ;mov       [bp-15h],dl
         db        88h,96h,0EBh,0FFh        ;!
         inc       bx
l_A761:  mov       ax,bx
         ;mov       [bp-0Ah],di
         db        89h,0BEh,0F6h,0FFh       ;!
         ;mov       byte ptr [bp-16h],0
         db        0C6h,86h,0EAh,0FFh,0     ;!
         dec       bx
l_A76D:  inc       bx
         cmp       bx,cx
         ja        l_A78A
         cmp       byte ptr [bx+si],23h
         je        l_A786
         cmp       byte ptr [bx+si],2Ch
         jne       l_A76D
         mov       byte ptr [bx+si],2Eh
         ;mov       byte ptr [bp-16h],1
         db        0C6h,86h,0EAh,0FFh,1     ;!
         jmp       short l_A76D

l_A786:  dec       bx
         mov       [si],bl
         inc       bx
l_A78A:  ;mov       [bp-8],bx
         db        89h,9Eh,0F8h,0FFh        ;!
         dec       ax
         ;mov       [bp-0Eh],ax
         db        89h,86h,0F2h,0FFh        ;!
         jz        l_A79C
         mov       bl,1
         push      bx
         push      ax
         call      l_37F3                   ; p©°sun zbytku ©†dku DELETE
l_A79C:  lea       di,[bp-14h]
         push      ss
         push      di
         lea       di,[bp-6]
         push      ss
         push      di
         call      l_9AB1
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         je        l_A7B4
         jmp       l_A948

l_A7B4:  mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©°znak modifikace textu
         mov       ax,[bp-0Ch]
         cmp       ax,0
         jg        l_A7C5
         jmp       l_A84D

l_A7C5:  dec       sp
         dec       sp
         lea       di,[bp-14h]
         push      ss
         call      l_1950
         call      l_9A61
         mov       [bp-0Eh],ax
         mov       di,offset d_F059
         push      ds
         push      di
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        0

         mov       cl,0ffh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
l_A7E2:  mov       ax,[bp-0Eh]
         push      ax
         mov       ax,[bp-0Ch]
         dec       ax
         pop       cx
         and       ax,cx
         xchg      ax,di
         mov       al,byte ptr cs:[l_9A51+di]
         xor       ah,ah
         mov       ah,al
         mov       al,1
         push      ax
         mov       di,offset d_F059
         push      ds
         push      di
         mov       ax,1
         mov       cl,0FFh
         call      l_13B0
         mov       ax,[bp-0Eh]
         mov       cx,1
         shr       ax,cl
         mov       [bp-0Eh],ax
         mov       ax,[bp-0Ch]
         cmp       ax,10h
         je        l_A81D
         ;jmp       l_A828
         db        0e9h
         dw        l_A828-$-2

l_A81D:  mov       ax,[bp-0Eh]
         mov       cx,3
         shr       ax,cl
         mov       [bp-0Eh],ax
l_A828:  mov       ax,[bp-0Eh]
         cmp       ax,0
         je        l_A833
         ;jmp       l_A7E2
         db        0e9h
         dw        l_A7E2-$-2

l_A833:  mov       al,[bp-15h]
         xor       ah,ah
         mov       ah,al
         mov       al,1
         push      ax
         mov       di,offset d_F059
         push      ds
         push      di
         mov       ax,1
         mov       cl,0FFh
         call      l_13B0
         ;jmp       l_A8AD
         db        0e9h
         dw        l_A8AD-$-2

l_A84D:  lea       di,[bp-14h]
         push      ss
         call      l_1950
         mov       ax,1
         push      ax
         mov       ax,[bp-0Ah]
         push      ax
         mov       di,offset d_F059
         push      ds
         mov       cl,0FFh
         call      l_0E0C
         mov       ax,[bp-0Ah]
         cmp       ax,8
         je        l_A870
         ;jmp       l_A8AD
         db        0e9h
         dw        l_A8AD-$-2

l_A870:  mov       al,ds:[d_F059]
         xor       ah,ah
         xchg      ax,di
         mov       al,ds:[d_F059+di]
         xor       ah,ah
         cmp       ax,30h
         je        l_A884
         ;jmp       l_A890
         db        0e9h
         dw        l_A890-$-2

l_A884:  mov       al,ds:[d_F059]
         xor       ah,ah
         dec       ax
         mov       ds:[d_F059],al
         ;jmp       l_A870
         db        0e9h
         dw        l_A870-$-2

l_A890:  mov       al,ds:[d_F059]
         xor       ah,ah
         xchg      ax,di
         mov       al,ds:[d_F059+di]
         xor       ah,ah
         cmp       ax,2Eh
         je        l_A8A4
         ;jmp       l_A8AD
         db        0e9h
         dw        l_A8AD-$-2

l_A8A4:  mov       al,ds:[d_F059]
         xor       ah,ah
         dec       ax
         mov       ds:[d_F059],al
l_A8AD:  mov       ax,2E01h
         push      ax
         mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         mov       [bp-6],ax
         mov       ax,[bp-6]
         cmp       ax,0
         mov       ax,1
         jg        l_A8CA
         dec       ax
l_A8CA:  push      ax
         mov       al,[bp-16h]
         xor       ah,ah
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_A8DA
         ;jmp       l_A8E5
         db        0e9h
         dw        l_A8E5-$-2

l_A8DA:  mov       ax,[bp-6]
         xchg      ax,di
         mov       ax,2Ch
         mov       ds:[d_F059+di],al
l_A8E5:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       ax,[bp-4]
         push      ax
         mov       ax,[bp-8]
         sub       ax,[bp-4]
         add       ax,1
         push      ax
         call      l_37F3                   ; p©°sun zbytku ©†dku DELETE
         mov       ax,[bp-4]
         push      ax
         mov       al,ds:[d_F059]
         xor       ah,ah
         push      ax
         call      l_3799                   ; odsun zbytku ©†dku INSERT
         mov       di,offset d_F059+1
         push      ds
         push      di
         mov       ax,[bp-4]
         xchg      ax,di
         add       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      di
         mov       al,ds:[d_F059]
         xor       ah,ah
         call      l_0F2E                   ; posun dat (s p©ekryvem)
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         cmp       ax,[bp-4]
         jl        l_A92A
         ;jmp       l_A93A
         db        0e9h
         dw        l_A93A-$-2

l_A92A:  mov       ax,[bp-4]
         dec       ax
         push      ax
         mov       al,ds:[d_F059]
         xor       ah,ah
         pop       cx
         add       ax,cx
         mov       byte ptr ds:[d_EC59],al  ; dÇlka textovÇho ©†dku
l_A93A:  mov       ax,[bp-4]
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim†ln° dÇlka ©†dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
         ;jmp       l_A951
         db        0e9h
         dw        l_A951-$-2

l_A948:  mov       ax,[bp-0Eh]
         add       ax,[bp-6]
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
l_A951:  ;jmp       l_A954
         db        0e9h,0,0

l_A954:  mov       sp,bp
         pop       bp
         ret

l_A6B6   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JI a Extra/prostor (volba editaán°ho prostoru)
; -----------------------------------------------------------------------------

l_A958   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_A95F
         db        0e9h,0,0

l_A95F:  dec       sp
         dec       sp
         mov       ax,0
         push      ax
         call      l_6E3A                   ; volba prostoru
         push      ax
         call      l_9840                   ; p©epnut° na novò editaán° prostor
         ;jmp       l_A96F
         db        0e9h,0,0

l_A96F:  mov       sp,bp
         pop       bp
         ret

l_A958   ENDP

; -----------------------------------------------------------------------------
;        z†pis data/áasu do textu
; -----------------------------------------------------------------------------

l_A973   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_A97A
         db        0e9h,0,0

l_A97A:  mov       al,byte ptr ds:[d_F259]  ; buffer p©ehr†vanÇ makrokl†vesy
         xor       ah,ah
         cmp       ax,0
         je        l_A987
         ;jmp       l_A98D
         db        0e9h
         dw        l_A98D-$-2

l_A987:  mov       ax,1
         mov       word ptr ds:[d_F79F],ax  ; ukazatel p©ehr†vanÇ makrokl†vesy
l_A98D:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         jnz       l_A999
         ;jmp       l_A9AF
         db        0e9h
         dw        l_A9AF-$-2

; ------ z†pis data do textu

l_A999:  sub       sp,0Fh                   ; lok†ln° buffer k dek¢dov†n°
         call      l_64D0                   ; dek¢dov†n° systÇmovÇho data
         mov       di,offset d_F259         ; buffer p©ehr†vanÇ makrokl†vesy
         push      ds
         push      di
         mov       ax,word ptr ds:[d_F79F]  ; ukazatel p©ehr†vanÇ makrokl†vesy
         mov       cl,0FFh
         call      l_13B0
         ;jmp       l_A9C2
         db        0e9h
         dw        l_A9C2-$-2

; ------ z†pis áasu do textu

l_A9AF:  sub       sp,0Fh                   ; lok†ln° buffer k dek¢dov†n°
         call      l_646C                   ; dek¢dov†n° systÇmovÇho áasu
         mov       di,offset d_F259         ; buffer p©ehr†vanÇ makrokl†vesy
         push      ds
         push      di
         mov       ax,word ptr ds:[d_F79F]  ; ukazatel p©ehr†vanÇ makrokl†vesy
         mov       cl,0FFh
         call      l_13B0
l_A9C2:  ;jmp       l_A9C5
         db        0e9h,0,0

l_A9C5:  mov       sp,bp
         pop       bp
         ret       2

l_A973   ENDP

; *****************************************************************************
;
;                             Obsluha kalend†©e
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JK a Extra/kalend†© (kalend†©/hodiny)
; -----------------------------------------------------------------------------

l_A9CB   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_AA90

l_A9D2   db        5,'Leden',0,0,0,0
         db        4,'ónor',0,0,0,0,0
         db        6,'B©ezen',0,0,0
         db        5,'Duben',0,0,0,0
         db        6,'Kvàten',0,0,0
         db        6,'Äerven',0,0,0
         db        8,'Äervenec',0
         db        5,'Srpen',0,0,0,0
         db        4,'Z†©°',0,0,0,0,0
         db        5,'û°jen',0,0,0,0
         db        8,'Listopad',0
         db        8,'Prosinec',0

l_AA4A   db        31                       ; Leden
         db        28                       ; ónor
         db        31                       ; B©ezen
         db        30                       ; Duben
         db        31                       ; Kvàten
         db        30                       ; Äerven
         db        31                       ; Äervenec
         db        31                       ; Srpen
         db        30                       ; Z†©°
         db        31                       ; û°jen
         db        30                       ; Listopad
         db        31                       ; Prosinec

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_AA56   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_AA62
         db        0e9h,0,0

l_AA62:  mov       ax,45h
         push      ax
         mov       ax,3
         push      ax
         mov       ax,20h
         push      ax
         sub       sp,0Fh
         call      l_646C                   ; dek¢dov†n° systÇmovÇho áasu
         call      l_1460
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       ax,2001h
         push      ax
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       cl,0FFh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         ;jmp       l_AA8C
         db        0e9h,0,0

l_AA8C:  mov       sp,bp
         pop       bp
         ret

l_AA56   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_A9CB)
; -----------------------------------------------------------------------------

l_AA90:  sub       sp,19h
         mov       ax,2Ah
         push      ax
         call      l_63DA                   ; vol†n° sluëby DOS INT 21h
         mov       al,byte ptr ds:[d_0266+1]; registr DH pro vol†n° INT 21h
         xor       ah,ah
         mov       [bp-4],ax
         mov       ax,ds:[d_0264]           ; registr CX pro vol†n° INT 21h
         mov       [bp-6],ax
         mov       ax,8
         push      ax
         call      l_4D50                   ; zobrazen° n†povàdy k volb†m
         mov       ax,0
         mov       [bp-1Bh],al
l_AAB5:  mov       ax,2Ah
         push      ax
         call      l_63DA                   ; vol†n° sluëby DOS INT 21h
         ;mov       ax,[bp-6]
         db        8Bh,86h,0FAh,0FFh        ;!
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!
         mov       dx,ax
         dec       ax
         shr       ax,1
         shr       ax,1
         add       ax,dx
         dec       ax
         mov       si,offset l_AA4A
         mov       cx,bx
         dec       cx
         jz        l_AADF
l_AAD6:  add       al,cs:[si]
         adc       ah,0
         inc       si
         loop      l_AAD6
l_AADF:  mov       cl,cs:[si]
         test      dl,3
         jnz       l_AAF3
         cmp       bl,2
         jne       l_AAED
         inc       cx
l_AAED:  cmp       bl,2
         jbe       l_AAF3
         inc       ax
l_AAF3:  xor       dx,dx
         mov       bl,7
         div       bx
         or        dx,dx
         jnz       l_AAFF
         mov       dl,bl
l_AAFF:  ;mov       [bp-0Ah],dx
         db        89h,96h,0F6h,0FFh        ;!
         ;mov       [bp-8],cx
         db        89h,8Eh,0F8h,0FFh        ;!
         mov       ax,34h
         push      ax
         mov       ax,3
         push      ax
         mov       ax,42h
         push      ax
         mov       ax,3
         push      ax
         mov       ax,1
         push      ax
         call      l_34F8                   ; vykreslen° okna (kurzoru)
         mov       ax,28h                   ; m¢d znaku - podtrëenò inverzn°
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku
         mov       ax,34h
         push      ax
         mov       ax,3
         push      ax
         mov       ax,[bp-4]
         mov       cx,0Ah
         mul       cx
         xchg      ax,di
         add       di,offset l_A9D2 - 10
         push      cs
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       ax,2001h
         push      ax
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         sub       sp,9
         mov       ax,[bp-6]
         push      ax
         call      l_36BB                   ; p©evod á°sla INTEGER na ©etàzec
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       cl,0FFh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         mov       ax,20h
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku - invzern°
         mov       ax,0
         push      ax
         mov       ax,5
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_AB6F
         jmp       l_AC73

l_AB6F:  inc       cx
         mov       [bp-10h],ax
l_AB73:  push      cx
         mov       ax,1
         push      ax
         mov       ax,7
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_AB84
         jmp       l_AC69

l_AB84:  inc       cx
         mov       [bp-0Eh],ax
l_AB88:  push      cx
         mov       ax,[bp-0Eh]
         push      ax
         mov       ax,[bp-10h]
         mov       cx,7
         imul      cx
         pop       cx
         add       ax,cx
         sub       ax,[bp-0Ah]
         add       ax,1
         mov       [bp-0Ch],ax
         mov       ax,[bp-0Ch]
         cmp       ax,1
         mov       ax,1
         jge       l_ABAD
         dec       ax
l_ABAD:  push      ax
         mov       ax,[bp-0Ch]
         cmp       ax,[bp-8]
         mov       ax,1
         jle       l_ABBA
         dec       ax
l_ABBA:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_ABC4
         ;jmp       l_ABD8
         db        0e9h
         dw        l_ABD8-$-2

l_ABC4:  mov       ax,[bp-0Ch]
         push      ax
         mov       ax,2
         push      ax
         lea       di,[bp-19h]
         push      ss
         mov       cl,8
         call      l_0DF3                   ; dek¢d. á°sla INTEGER na text (DEK)
         ;jmp       l_ABE8
         db        0e9h
         dw        l_ABE8-$-2

l_ABD8:  lea       di,[bp-19h]
         push      ss
         push      di
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        2,'  '

         mov       cl,8
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
l_ABE8:  mov       ax,[bp-0Ch]
         push      ax
         mov       al,byte ptr ds:[d_0266]  ; registr DL pro vol†n° INT 21h
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jz        l_ABFB
         dec       ax
l_ABFB:  push      ax
         mov       ax,[bp-6]
         cmp       ax,ds:[d_0264]           ; registr CX pro vol†n° INT 21h
         mov       ax,1
         jz        l_AC09
         dec       ax
l_AC09:  pop       cx
         and       ax,cx
         push      ax
         mov       ax,[bp-4]
         push      ax
         mov       al,byte ptr ds:[d_0266+1]; registr DH pro vol†n° INT 21h
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jz        l_AC20
         dec       ax
l_AC20:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_AC2A
         ;jmp       l_AC33
         db        0e9h
         dw        l_AC33-$-2

l_AC2A:  mov       ax,0
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku - bàënò
         ;jmp       l_AC39
         db        0e9h
         dw        l_AC39-$-2

l_AC33:  mov       ax,20h
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku - inverzn°
l_AC39:  mov       ax,30h
         push      ax
         mov       ax,[bp-0Eh]
         mov       cx,2
         shl       ax,cl
         pop       cx
         add       ax,cx
         push      ax
         mov       ax,[bp-10h]
         add       ax,7
         push      ax
         lea       di,[bp-19h]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0FFh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         pop       cx
         dec       cx
         jz        l_AC69
         inc       word ptr [bp-0Eh]
         jmp       l_AB88

l_AC69:  pop       cx
         dec       cx
         jz        l_AC73
         inc       word ptr [bp-10h]
         jmp       l_AB73

l_AC73:  mov       byte ptr ds:[d_FE56],0   ; m¢d zobrazen° znaku - bàënò
l_AC78:  call      l_AA56
         push      ax
         call      l_5444                   ; vstup z kl†vesnice + makra + tisk
         or        ax,ax
         jz        l_AC78
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!
         ;mov       cx,[bp-6]
         db        8Bh,8Eh,0FAh,0FFh        ;!
         cmp       al,4
         jne       l_AC99
         inc       bx
         cmp       bl,0Ch
         jbe       l_ACD9
         mov       bl,1
         jmp       short l_AC9D

l_AC99:  cmp       al,5
         jne       l_ACA7
l_AC9D:  inc       cx
         cmp       cx,833h
         jbe       l_ACD9
         dec       cx
         jmp       short l_ACD9

l_ACA7:  cmp       al,13h
         jne       l_ACB2
         dec       bx
         jnz       l_ACD9
         mov       bl,0Ch
         jmp       short l_ACB6

l_ACB2:  cmp       al,18h
         jne       l_ACC0
l_ACB6:  dec       cx
         cmp       cx,76Dh
         jae       l_ACD9
         inc       cx
         jmp       short l_ACD9

l_ACC0:  cmp       al,0Dh
         je        l_ACCD
         cmp       al,1Bh
         jne       l_ACD9
         mov       byte ptr ds:[d_F78A],1   ; 1=p©°znak p©eru®en° editace volby
l_ACCD:  mov       ax,8
         push      ax
         call      l_4E5D                   ; n†vrat podkladu pod n†povàdou
         ;mov       byte ptr [bp-1Bh],1
         db        0C6h,86h,0E5h,0FFh,1     ;!
l_ACD9:  ;mov       [bp-4],bx
         db        89h,9Eh,0FCh,0FFh        ;!
         ;mov       [bp-6],cx
         db        89h,8Eh,0FAh,0FFh        ;!
         mov       al,[bp-1Bh]
         xor       ah,ah
         or        ax,ax
         jnz       l_ACED
         jmp       l_AAB5

l_ACED:  ;jmp       l_ACF0
         db        0e9h,0,0

l_ACF0:  mov       sp,bp
         pop       bp
         ret

l_A9CB   ENDP

; *****************************************************************************
;
;                   Obsluha grafickÇho editoru
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JG a Extra/grafickò editor (grafickò editor)
; -----------------------------------------------------------------------------

l_ACF4   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_ACFB
         db        0e9h,0,0

l_ACFB:  mov       ax,1
         mov       byte ptr ds:[d_F78D],al
         mov       ax,0
         mov       byte ptr ds:[d_F78E],al
         mov       ax,0
         mov       byte ptr ds:[d_F799],al
         mov       al,byte ptr cs:[l_3264]  ; zobr. line†lu ©†d.(1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_AD1A
         ;jmp       l_AD24
         db        0e9h
         dw        l_AD24-$-2

l_AD1A:  mov       ax,0
         mov       byte ptr cs:[l_3264],al  ; zobr. line†lu ©†d.(1=zap., 0=vyp.)
         call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
l_AD24:  mov       ax,0
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku - bàënò
         mov       ax,37h
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        26,' ',18h,' [≥]∫   ∞ ± ≤ € ‹ ﬂ › ﬁ '

         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         ;jmp       l_AD5B
         db        0e9h,0,0

l_AD5B:  mov       sp,bp
         pop       bp
         ret

l_ACF4   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_AD5F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_AD66
         db        0e9h,0,0

l_AD66:  jmp       l_AEAF

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_AD69   PROC      NEAR

         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         xor       dx,dx
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         cmp       bl,[di]
         ja        l_AD8A
         mov       bl,[bx+di]
         sub       bl,0B3h
         jc        l_AD8A
         cmp       bl,27h             ; '''
         ja        l_AD8A
         mov       dl,cs:[l_3478+bx]
l_AD8A:  ret

l_AD69   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_AD8B   PROC      NEAR

         cmp       ah,byte ptr ds:[d_F78E]
         je        l_AD8A
         mov       bl,byte ptr ds:[d_F799]
         mov       bh,0
         mov       al,cs:[l_34A0+bx]
         cmp       bl,1
         jbe       l_ADA4
         jmp       l_AE3C

l_ADA4:  test      cl,1
         jz        l_ADB1
         mov       al,0C4h
         or        bl,bl
         jz        l_ADB1
         mov       al,0CDh
l_ADB1:  mov       ch,0
         mov       ah,0
l_ADB5:  mov       dl,byte ptr ds:[d_F799]
         inc       dx
         cmp       ah,cl
         je        l_AE1C
         xor       dx,dx
         push      ax
         push      cx
         dec       ah
         jns       l_ADDD
         cmp       word ptr ds:[d_E698],1   ; á°slo aktivn°ho editovanÇho ©†dku
         je        l_AE1A
         call      l_5C8B                   ; posun kurzoru o ©†dek nahoru CtrlE
         call      l_AD69
         mov       cl,2
         shr       dl,cl
         push      dx
         call      l_5CE8                   ; posun kurzoru o ©†dek dolñ Ctrl-X
         jmp       short l_AE16

l_ADDD:  dec       ah
         jns       l_ADED
         call      l_5DAD                   ; posun kurzoru o pozici vpravo
         call      l_AD69
         push      dx
         call      l_5D88                   ; kurzor o pozici vlevo
         jmp       short l_AE16

l_ADED:  dec       ah
         jns       l_AE01
         call      l_5CE8                   ; posun kurzoru o ©†dek dolñ Ctrl-X
         call      l_AD69
         mov       cl,6
         shr       dl,cl
         push      dx
         call      l_5C8B                   ; posun kurzoru o ©†dek nahoru CtrlE
         jmp       short l_AE16

l_AE01:  cmp       byte ptr ds:[d_E69A],1   ; pozice kurzoru na ©†dku
         je        l_AE1A
         call      l_5D88                   ; kurzor o pozici vlevo
         call      l_AD69
         mov       cl,4
         shr       dl,cl
         push      dx
         call      l_5DAD                   ; posun kurzoru o pozici vpravo
l_AE16:  pop       dx
         and       dl,3
l_AE1A:  pop       cx
         pop       ax
l_AE1C:  shl       ch,1
         shl       ch,1
         or        ch,dl
         inc       ah
         cmp       ah,4
         jne       l_ADB5
         mov       bx,27h
l_AE2C:  cmp       ch,cs:[l_3478+bx]
         je        l_AE38
         dec       bx
         jns       l_AE2C
         jmp       short l_AE3C

l_AE38:  mov       al,bl
         add       al,0B3h
l_AE3C:  push      ax
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       ax,1
         push      ax
         call      l_5972
         mov       cx,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       bl,[di]
         mov       bh,0
         cmp       cl,bl
         jbe       l_AE69
         cmp       byte ptr [bx+di],11h
         je        l_AE5C
         inc       bx
l_AE5C:  push      di
         push      cx
         push      bx
         sub       cx,bx
         push      cx
         call      l_372A
         pop       cx
         pop       di
         mov       [di],cl
l_AE69:  pop       ax
         mov       bx,cx
         mov       [bx+di],al
         mov       byte ptr ds:[d_ED59+bx],bh ; buffer atributñ znakñ text. ©†dku
         mov       byte ptr ds:[d_E6A8],bh  ; 0=p©°znak modifikace textu
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         jbe       l_AE82
         mov       word ptr ds:[d_F7A3],ax  ; skuteánò poáet ©†dkñ prostoru
l_AE82:  push      bx
         push      bx
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
         ret

l_AD8B   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_AE88   PROC      NEAR

         push      bx
         mov       bh,0
         shl       bx,1
         add       bl,3Ah
         push      cx
         push      bx
         push      cx                       ; znak
         push      bx                       ; pozice
         xor       bx,bx
         push      bx                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         pop       bx
         pop       cx
         inc       bx
         inc       bx
         cmp       cl,20h
         je        l_AEA5
         inc       cx
         inc       cx
l_AEA5:  push      cx                       ; znak
         push      bx                       ; pozice
         xor       bx,bx
         push      bx                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         pop       bx
         ret

l_AE88   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_AD5F)
; -----------------------------------------------------------------------------

l_AEAF:  ;mov       al,[bp+4]
         db        8Ah,86h,4,0              ;!
         mov       bl,byte ptr ds:[d_F799]
         mov       cl,20h
         mov       byte ptr ds:[d_FE56],0   ; m¢d zobrazen° znaku - bàënò
         cmp       al,1Bh
         je        l_AF02
         cmp       al,0Dh
         je        l_AF0D
         push      ax
         mov       ah,2
         int       16h
         test      al,3
         pop       ax
         jz        l_AEE3
         cmp       al,34h
         je        l_AF2A
         cmp       al,36h
         je        l_AF35
         cmp       al,13h
         je        l_AF2A
         cmp       al,4
         je        l_AF35
         jmp       l_AF97

l_AEE3:  cmp       al,5
         je        l_AF56
         cmp       al,18h
         je        l_AF4C
         cmp       al,13h
         je        l_AF60
         cmp       al,4
         je        l_AF6A
         cmp       al,3
         je        l_AF74
         cmp       al,12h
         je        l_AF79
         cmp       al,11h
         je        l_AF7E
         jmp       l_AF97

l_AF02:  mov       byte ptr ds:[d_F78D],0
         call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
         jmp       l_AF97

l_AF0D:  xor       ax,ax
         mov       al,byte ptr ds:[d_F78E]
         xor       al,1
         mov       byte ptr ds:[d_F78E],al
         or        ax,ax
         mov       al,18h
         jz        l_AF1E
         inc       ax
l_AF1E:  push      ax                       ; znak
         mov       al,38h
         push      ax                       ; pozice
         xor       ax,ax
         push      ax                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         jmp       short l_AF97

l_AF2A:  call      l_AE88
         dec       bl
         jns       l_AF41
         mov       bl,0Ah
         jmp       short l_AF41

l_AF35:  call      l_AE88
         inc       bl
         cmp       bl,0Ah
         jbe       l_AF41
         xor       bl,bl
l_AF41:  mov       cl,5Bh
         call      l_AE88
         mov       byte ptr ds:[d_F799],bl
         jmp       short l_AF97

l_AF4C:  mov       cl,2
         call      l_AD8B
         call      l_5CE8                   ; posun kurzoru o ©†dek dolñ Ctrl-X
         jmp       short l_AF97

l_AF56:  mov       cl,0
         call      l_AD8B
         call      l_5C8B                   ; posun kurzoru o ©†dek nahoru CtrlE
         jmp       short l_AF97

l_AF60:  mov       cl,3
         call      l_AD8B
         call      l_5D88                   ; kurzor o pozici vlevo
         jmp       short l_AF97

l_AF6A:  mov       cl,1
         call      l_AD8B
         call      l_5DAD                   ; posun kurzoru o pozici vpravo
         jmp       short l_AF97

l_AF74:  call      l_60F6
         jmp       short l_AF97

l_AF79:  call      l_608C
         jmp       short l_AF97

l_AF7E:  push      ax
         call      l_5444                   ; vstup z kl†vesnice + makra + tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velkÇ p°smeno
         cmp       al,53h
         jne       l_AF90
         call      l_5D74                   ; p©esun kurzoru na zaá†tek ©†dku
         jmp       short l_AF97

l_AF90:  cmp       al,44h
         jne       l_AF97
         call      l_5DC2                   ; p©esun kurzoru na konec ©†dku
l_AF97:  ;jmp       l_AF9A
         db        0e9h,0,0

l_AF9A:  mov       sp,bp
         pop       bp
         ret       2

l_AD5F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_AFA0   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_AFA7
         db        0e9h,0,0

l_AFA7:  sub       sp,17h
         dec       sp
         call      l_65E5                   ; kontrola, zda je oznaáen blok
         push      ax
         mov       al,byte ptr ds:[d_E6AA]  ; 1=p©°znak sloupcovÇho bloku
         xor       ah,ah
         xor       al,1
         pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_AFC0
         ;jmp       l_AFC9
         db        0e9h
         dw        l_AFC9-$-2

l_AFC0:  mov       ax,13h
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         jmp       l_B204

l_AFC9:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         lea       di,[bp-12h]
         push      ss
         push      di
         mov       ax,0
         call      l_1B0C
         call      l_1970
         mov       ax,0
         mov       [bp-4],ax
         mov       ax,0
         mov       [bp-0Ch],ax
         mov       ax,0
         mov       [bp-19h],al
         mov       ax,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
         push      ax
         mov       ax,word ptr ds:[d_E692]  ; ©†dek konce bloku
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_AFFC
         jmp       l_B12D

l_AFFC:  inc       cx
         mov       [bp-6],ax
l_B000:  push      cx
         mov       ax,[bp-6]
         push      ax                       ; á°slo ©†dku
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov†n° ©†dku do edit. bufferu
         mov       ax,word ptr ds:[d_E694]  ; pozice zaá†tku sloupcovÇho bloku
         mov       [bp-0Ah],ax
l_B018:  xor       dx,dx
         mov       si,offset d_EC59         ; buffer textovÇho ©†dku
         mov       cl,[si]
         mov       ch,0
         mov       di,offset d_F059
         mov       [di],ch
         mov       bx,di
         ;mov       ax,[bp-0Ah]
         db        8Bh,86h,0F6h,0FFh        ;!
         add       si,ax
         cmp       cx,word ptr ds:[d_E696]  ; pozice konec sloupcovÇho bloku
         jbe       l_B038
         mov       cx,word ptr ds:[d_E696]  ; pozice konec sloupcovÇho bloku
l_B038:  sub       cx,ax
         inc       cx
         dec       si
l_B03C:  inc       si
         dec       cx
         jns       l_B043
         jmp       l_B0CD

l_B043:  mov       al,[si]
l_B045:  cmp       al,2Dh
         je        l_B053
         cmp       al,30h
         jb        l_B03C
         cmp       al,39h
         ja        l_B03C
         jmp       short l_B06D

l_B053:  inc       si
         dec       cx
         js        l_B0CD
         mov       al,[si]
         cmp       al,20h
         je        l_B053
         cmp       al,0FFh
         je        l_B053
         cmp       al,30h
         jb        l_B045
         cmp       al,39h
         ja        l_B045
         inc       di
         mov       byte ptr [di],2Dh
l_B06D:  inc       di
         mov       [di],al
l_B070:  inc       si
         dec       cx
         js        l_B0BD
         mov       al,[si]
         cmp       al,2Eh
         je        l_B070
         cmp       al,0FFh
         je        l_B070
         cmp       al,2Ch
         je        l_B08C
         cmp       al,30h
         jb        l_B0BD
         cmp       al,39h
         jbe       l_B06D
         jmp       short l_B0BD

l_B08C:  inc       di
         mov       byte ptr [di],2Eh
         inc       si
         dec       cx
         js        l_B0BD
         mov       al,[si]
         cmp       al,2Dh
         jne       l_B0A3
         inc       dx
         ;mov       [bp-19h],dl
         db        88h,96h,0E7h,0FFh        ;!
         inc       dx
         inc       si
         jmp       short l_B0BD

l_B0A3:  dec       si
         inc       cx
l_B0A5:  inc       si
         dec       cx
         js        l_B0BD
         mov       al,[si]
         cmp       al,0FFh
         je        l_B0A5
         cmp       al,30h
         jb        l_B0BD
         cmp       al,39h
         ja        l_B0BD
         inc       dx
         inc       di
         mov       [di],al
         jmp       short l_B0A5

l_B0BD:  ;cmp       dx,[bp-4]
         db        3Bh,96h,0FCh,0FFh        ;!
         jbe       l_B0C7
         ;mov       [bp-4],dx
         db        89h,96h,0FCh,0FFh        ;!
l_B0C7:  mov       ax,di
         sub       ax,bx
         mov       [bx],al
l_B0CD:  sub       si,offset d_EC59         ; buffer textovÇho ©†dku
         inc       si
         ;mov       [bp-0Ah],si
         db        89h,0B6h,0F6h,0FFh       ;!
         mov       al,ds:[d_F059]
         xor       ah,ah
         cmp       ax,0
         jg        l_B0E3
         ;jmp       l_B116
         db        0e9h
         dw        l_B116-$-2

l_B0E3:  mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         lea       di,[bp-18h]
         push      ss
         push      di
         lea       di,[bp-8]
         push      ss
         call      l_0E6C
         lea       di,[bp-12h]
         push      ss
         push      di
         lea       di,[bp-12h]
         push      ss
         call      l_1950
         lea       di,[bp-18h]
         push      ss
         call      l_1950
         call      l_1983
         call      l_1970
         mov       ax,[bp-0Ch]
         inc       ax
         mov       [bp-0Ch],ax
l_B116:  mov       al,ds:[d_F059]
         xor       ah,ah
         cmp       ax,0
         je        l_B123
         jmp       l_B018

l_B123:  pop       cx
         dec       cx
         jz        l_B12D
         inc       word ptr [bp-6]
         jmp       l_B000

l_B12D:  mov       ax,[bp-0Ch]
         cmp       ax,0
         mov       ax,1
         jg        l_B139
         dec       ax
l_B139:  push      ax
         mov       al,[bp+4]
         xor       ah,ah
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_B149
         ;jmp       l_B161
         db        0e9h
         dw        l_B161-$-2

l_B149:  lea       di,[bp-12h]
         push      ss
         push      di
         lea       di,[bp-12h]
         push      ss
         call      l_1950
         mov       ax,[bp-0Ch]
         call      l_1B0C
         call      l_19BC
         call      l_1970
l_B161:  lea       di,[bp-12h]
         push      ss
         call      l_1950
         mov       ax,0
         push      ax
         mov       ax,[bp-4]
         push      ax
         mov       di,offset d_F059
         push      ds
         mov       cl,0FFh
         call      l_0E0C
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       di,offset d_F059
         xor       bx,bx
         mov       cl,[di]
         mov       ch,0
         ;mov       ax,[bp-4]
         db        8Bh,86h,0FCh,0FFh        ;!
l_B189:  inc       bx
         cmp       byte ptr [bx+di],2Eh
         je        l_B196
         loop      l_B189
         mov       ax,0FFFFh
         jmp       short l_B199

l_B196:  mov       byte ptr [bx+di],2Ch
l_B199:  mov       bl,[di]
         cmp       al,2
         jne       l_B1B7
         ;cmp       bh,[bp-19h]
         db        3Ah,0BEh,0E7h,0FFh       ;!
         je        l_B1B7
         cmp       byte ptr [bx+di],30h
         jne       l_B1B7
         cmp       byte ptr [bx+di-1],30h
         jne       l_B1B7
         dec       bx
         mov       byte ptr [bx+di],2Dh
         mov       [di],bl
         dec       ax
l_B1B7:  mov       cx,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         inc       cx
         add       cx,ax
         sub       cx,bx
         jg        l_B1C5
         mov       cx,1
l_B1C5:  mov       word ptr ds:[d_E69A],cx  ; pozice kurzoru na ©†dku
         mov       al,byte ptr ds:[d_F259]  ; buffer p©ehr†vanÇ makrokl†vesy
         xor       ah,ah
         cmp       ax,0
         jg        l_B1D6
         ;jmp       l_B1ED
         db        0e9h
         dw        l_B1ED-$-2

l_B1D6:  mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       di,offset d_F259         ; buffer p©ehr†vanÇ makrokl†vesy
         push      ds
         push      di
         mov       ax,word ptr ds:[d_F79F]  ; ukazatel p©ehr†vanÇ makrokl†vesy
         mov       cl,0FFh
         call      l_13B0
         ;jmp       l_B204
         db        0e9h
         dw        l_B204-$-2

l_B1ED:  mov       di,offset d_F259         ; buffer p©ehr†vanÇ makrokl†vesy
         push      ds
         push      di
         mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         mov       ax,1
         mov       word ptr ds:[d_F79F],ax  ; ukazatel p©ehr†vanÇ makrokl†vesy
l_B204:  ;jmp       l_B207
         db        0e9h,0,0

l_B207:  mov       sp,bp
         pop       bp
         ret       2

l_AFA0   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JM a Extra/sloupcovò prñmàr (sloupcovò prñmàr)
; -----------------------------------------------------------------------------

l_B20D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B214
         db        0e9h,0,0

l_B214:  mov       ax,1
         push      ax
         call      l_AFA0
         ;jmp       l_B21E
         db        0e9h,0,0

l_B21E:  mov       sp,bp
         pop       bp
         ret

l_B20D   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JS a Extra/sloupcovò souáet (sloupcovò souáet)
; -----------------------------------------------------------------------------

l_B222   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B229
         db        0e9h,0,0

l_B229:  mov       ax,0
         push      ax
         call      l_AFA0
         ;jmp       l_B233
         db        0e9h,0,0

l_B233:  mov       sp,bp
         pop       bp
         ret

l_B222   ENDP

; *****************************************************************************
;
;                       Obsluha menu n†povàdy
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-J (menu info/displej)
; -----------------------------------------------------------------------------

l_B237   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B23E
         db        0e9h,0,0

l_B23E:  jmp       short l_B27B

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JD (z†pis data do textu)
; -----------------------------------------------------------------------------

l_B240   PROC      NEAR

         push      ax
         call      l_A973                   ; z†pis data/áasu do textu
         ret

l_B240   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JF (blik†n° kurzoru zap/vyp)
; -----------------------------------------------------------------------------

l_B245   PROC      NEAR

         xor       byte ptr cs:[l_3276],al  ; blik†n° kurzoru (1=zap., 0=vyp.)
         ret

l_B245   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JH (n†povàda zap/vyp)
; -----------------------------------------------------------------------------

l_B24B   PROC      NEAR

         xor       byte ptr cs:[l_3277],al  ; n†povàda (1=zap., 0=vyp.)
         ret

l_B24B   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JT (z†pis áasu do textu)
; -----------------------------------------------------------------------------

l_B251   PROC      NEAR

         dec       ax
         push      ax
         call      l_A973                   ; z†pis data/áasu do textu
         ret

l_B251   ENDP

l_B257   db        'BCDFGHIKMRST'

l_B263   dw        l_98AF                   ; Ctrl-JB p©epnut° ©†dkov†n° displ.
l_B265   dw        l_9916                   ; Ctrl-JC volba barev displeje
l_B267   dw        l_B240                   ; Ctrl-JD z†pis data do textu
l_B269   dw        l_B245                   ; Ctrl-JF blik†n° kurzoru zap/vyp
l_B26B   dw        l_ACF4                   ; Ctrl-JG grafickò editor
l_B26D   dw        l_B24B                   ; Ctrl-JH n†povàda zap/vyp
l_B26F   dw        l_A958                   ; Ctrl-JI volba pracovn°ho prostoru
l_B271   dw        l_A9CB                   ; Ctrl-JK kalend†©, hodiny
l_B273   dw        l_B20D                   ; Ctrl-JM sloupcovò prñmàr
l_B275   dw        l_A6B6                   ; Ctrl-JR vòpoátu v textu
l_B277   dw        l_B222                   ; Ctrl-JS sloupcovò souáet
l_B279   dw        l_B251                   ; Ctrl-JT z†pis áasu do textu

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_B237)
; -----------------------------------------------------------------------------

l_B27B:  mov       ax,1
         push      ax
         call      l_4D50                   ; zobrazen° n†povàdy k volb†m
         push      ax
         call      l_54DE                   ; vstup kl†vesy s áek†n°m+makro+tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velkÇ p°smeno
         push      ax
         mov       ax,1
         push      ax
         call      l_4E5D                   ; n†vrat podkladu pod n†povàdou
         pop       ax
         mov       bx,offset l_B263
         mov       cx,0Ch
         mov       si,offset l_B257
l_B29D:  cmp       al,cs:[si]
         je        l_B2A9
         inc       si
         inc       bx
         inc       bx
         loop      l_B29D
         jmp       short l_B2AF

l_B2A9:  mov       ax,1
         call      word ptr cs:[bx]
l_B2AF:  ;jmp       l_B2B2
         db        0e9h,0,0

l_B2B2:  mov       sp,bp
         pop       bp
         ret

l_B237   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B2B6   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B2BD
         db        0e9h,0,0

l_B2BD:  jmp       short l_B2C5

l_B2BF   db        'ÑéîôÅö'

l_B2C5:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       ax,1
         push      ax
         call      l_5972
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         cmp       bl,[di]
         ja        l_B33D
         cmp       byte ptr [bx+di],15h
         je        l_B2E4
         cmp       byte ptr [bx+di],20h
         jb        l_B33D
l_B2E4:  mov       byte ptr ds:[d_E6A8],ah  ; 0=p©°znak modifikace textu
         ;mov       dl,[bp+4]
         db        8Ah,96h,4,0              ;!
         or        dl,dl
         jns       l_B322
         mov       al,[bx+di]
         and       al,0DFh
         cmp       al,41h
         jb        l_B33D
         cmp       al,5Ah
         ja        l_B301
         xor       byte ptr [bx+di],20h
         jmp       short l_B336

l_B301:  mov       al,[bx+di]
         mov       si,offset l_B2BF
         mov       ah,6
l_B308:  cmp       al,cs:[si]
         je        l_B314
         inc       si
         dec       ah
         jnz       l_B308
         jmp       short l_B33D

l_B314:  shr       ah,1
         jnc       l_B31A
         dec       si
         dec       si
l_B31A:  inc       si
         mov       al,cs:[si]
         mov       [bx+di],al
         jmp       short l_B336

l_B322:  mov       si,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         dec       bx
         cmp       byte ptr [bx+di],0FFh
         je        l_B32C
         inc       bx
l_B32C:  xor       [bx+si],dl
         cmp       byte ptr [bx+di],0FFh
         jne       l_B336
         inc       bx
         xor       [bx+si],dl
l_B336:  push      bx
         push      bx
         push      bx
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
         pop       bx
l_B33D:  inc       bx
         mov       word ptr ds:[d_E69A],bx  ; pozice kurzoru na ©†dku
         cmp       bl,byte ptr cs:[l_325A]  ; ®°©ka ©†dku textu (znakñ)
         jne       l_B35A
         call      l_5C9F                   ; posun kurzoru o ©†dek dolñ
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         call      l_5D74                   ; p©esun kurzoru na zaá†tek ©†dku
         mov       di,offset d_E69A         ; pozice kurzoru na ©†dku
         push      ds
         push      di
         call      l_384B
l_B35A:  ;jmp       l_B35D
         db        0e9h,0,0

l_B35D:  mov       sp,bp
         pop       bp
         ret       2

l_B2B6   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-- (z†màna dvou znakñ za kurzorem)
; -----------------------------------------------------------------------------

l_B363   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B36A
         db        0e9h,0,0

l_B36A:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       ax,1
         push      ax
         call      l_5972
         mov       si,offset d_EC59         ; buffer textovÇho ©†dku
         mov       di,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         mov       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         cmp       bl,[si]
         jae       l_B3A7
         mov       ax,[bx+si]
         cmp       al,0FFh
         je        l_B3A7
         cmp       ah,0FFh
         je        l_B3A7
         cmp       ah,11h
         je        l_B3A7
         mov       byte ptr ds:[d_E6A8],0   ; 0=p©°znak modifikace textu
         xchg      al,ah
         mov       [bx+si],ax
         mov       ax,[bx+di]
         xchg      al,ah
         mov       [bx+di],ax
         push      bx
         inc       bx
         push      bx
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
l_B3A7:  ;jmp       l_B3AA
         db        0e9h,0,0

l_B3AA:  mov       sp,bp
         pop       bp
         ret

l_B363   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KT a Blok/zmàna p°sma (zmàna typu p°sma v bloku)
; -----------------------------------------------------------------------------

l_B3AE   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B3B5
         db        0e9h,0,0

l_B3B5:  sub       sp,4
         dec       sp
         call      l_65E5                   ; kontrola, zda je oznaáen blok
         jnz       l_B3C1
         ;jmp       l_B3C4
         db        0e9h
         dw        l_B3C4-$-2

l_B3C1:  jmp       l_B4BF

l_B3C4:  jmp       short l_B424

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B3C6   PROC      NEAR

         push      bx
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         cmp       ah,byte ptr ds:[d_F788]  ; zvolenò aktu†ln° typ p°sma
         jne       l_B3EB
         dec       bx
l_B3D1:  inc       bx
         cmp       bx,ax
         ja        l_B422
         cmp       byte ptr [bx+di],0FFh
         jne       l_B3D1
         push      ax
         push      bx
         push      di
         push      bx
         mov       bl,1
         push      bx
         call      l_37F3                   ; p©°sun zbytku ©†dku DELETE
         pop       di
         pop       bx
         pop       ax
         dec       ax
         jmp       short l_B3D1

l_B3EB:  dec       bx
l_B3EC:  inc       bx
         cmp       bx,ax
         ja        l_B422
         mov       dl,[bx+di]
         cmp       dl,0FFh
         je        l_B41F
         cmp       dl,15h
         je        l_B402
         cmp       dl,20h
         jb        l_B3EC
l_B402:  cmp       byte ptr [bx+di-1],0FFh
         je        l_B3EC
         push      ax
         push      bx
         push      di
         push      bx
         mov       bl,1
         push      bx
         call      l_3799                   ; odsun zbytku ©†dku INSERT
         pop       di
         pop       bx
         pop       ax
         cmp       ah,byte ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         jne       l_B422
         mov       byte ptr [bx+di],0FFh
         inc       ax
l_B41F:  inc       bx
         jmp       short l_B3EC

l_B422:  pop       bx
         ret

l_B3C6   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_B3AE)
; -----------------------------------------------------------------------------

l_B424:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         mov       byte ptr ds:[d_E6A8],0   ; 0=p©°znak modifikace textu
         mov       dx,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       si,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
l_B436:  push      dx
         push      si
         push      di
         push      dx                       ; á°slo ©†dku
         push      ds
         push      di
         push      ds
         push      si
         call      l_3F5A                   ; dek¢dov†n° ©†dku do edit. bufferu
         ;lea       di,[bp-4]
         db        8Dh,0BEh,0FCh,0FFh       ;!
         mov       word ptr ss:[di],1
         push      ss
         push      di
         call      l_384B
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         mov       ah,0
         cmp       ah,byte ptr ds:[d_E6AA]  ; 1=p©°znak sloupcovÇho bloku
         je        l_B471
         cmp       bx,word ptr ds:[d_E694]  ; pozice zaá†tku sloupcovÇho bloku
         jae       l_B468
         mov       bx,word ptr ds:[d_E694]  ; pozice zaá†tku sloupcovÇho bloku
l_B468:  cmp       ax,word ptr ds:[d_E696]  ; pozice konec sloupcovÇho bloku
         jbe       l_B471
         mov       ax,word ptr ds:[d_E696]  ; pozice konec sloupcovÇho bloku
l_B471:  call      l_B3C6
         pop       di
         pop       si
l_B476:  cmp       bx,ax
         ja        l_B492
         cmp       byte ptr [bx+di],15h
         je        l_B484
         cmp       byte ptr [bx+di],20h
         jb        l_B48F
l_B484:  mov       dl,[bx+si]
         and       dl,0C0h
         or        dl,byte ptr ds:[d_F79A]
         mov       [bx+si],dl
l_B48F:  inc       bx
         jmp       short l_B476

l_B492:  pop       dx
         push      dx
         push      si
         push      di
         push      dx
         push      ds
         push      di
         push      ds
         push      si
         call      l_3E83                   ; uloëen° edit. ©†dku do souboru
         pop       di
         pop       si
         pop       dx
         inc       dx
         cmp       dx,word ptr ds:[d_E692]  ; ©†dek konce bloku
         jbe       l_B436
         call      l_6801
         mov       bx,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         dec       bx
         shl       bx,1
         mov       ax,word ptr ds:[d_E5E4+bx] ; tabulka zobrazenòch ©†dkñ
         cmp       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         jne       l_B4BF
         call      l_4C6D                   ; obnoven° zobrazen° obrazovky
l_B4BF:  ;jmp       l_B4C2
         db        0e9h,0,0

l_B4C2:  mov       sp,bp
         pop       bp
         ret       

l_B3AE   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B4C6   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B4CD
         db        0e9h,0,0

l_B4CD:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       bx,1
         mov       cx,9
         mov       dh,0Ah
         xor       si,si
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
l_B4DD:  cmp       bl,[di]
         ja        l_B515
         mov       al,byte ptr cs:[l_3268+si] ; rychlost blik†n° kurzoru
         inc       bx
         cmp       byte ptr [bx+di-1],2Ch
         je        l_B50E
         xor       ax,ax
         dec       bx
l_B4F0:  mov       dl,[bx+di]
         inc       bx
         cmp       dl,2Ch
         je        l_B50E
         sub       dl,30h
         jc        l_B526
         cmp       dl,9
         ja        l_B526
         mul       dh
         jc        l_B526
         add       al,dl
         jc        l_B526
         cmp       bl,[di]
         jbe       l_B4F0
l_B50E:  mov       byte ptr ds:[d_CD98+si],al
         inc       si
         loop      l_B4DD
l_B515:  mov       cx,si
         jcxz      l_B52C
         push      cs
         pop       es
         mov       si,offset d_CD98
         mov       di,offset l_3268         ; rychlost blik†n° kurzoru
         cld       
         repne     movsb
         jmp       short l_B52C

l_B526:  mov       word ptr ds:[d_F79D],0Dh ; k¢d chyby KonTextu
l_B52C:  ;jmp       l_B52F
         db        0e9h,0,0

l_B52F:  mov       sp,bp
         pop       bp
         ret       

l_B4C6   ENDP

; -----------------------------------------------------------------------------
;        obsluha menu Tisk/áten° instalace (naáten° definice tisk†rny)
; -----------------------------------------------------------------------------

l_B533   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B53A
         db        0e9h,0,0

l_B53A:  sub       sp,84h
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        37,'JmÇno souboru pro instalaci tisk†rny '

         mov       cl,80h
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         lea       di,[bp-83h]
         push      ss
         push      di
         call      l_7463                   ; zad†n° jmÇna souboru
         mov       al,ds:[d_F78A]           ; 1=p©°znak p©eru®en° editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_B581
         jmp       l_B61C

l_B581:  mov       di,offset d_CD98
         push      ds
         push      di
         lea       di,[bp-83h]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_2940                   ; p©°prava jmÇna souboru k operaci
         mov       di,offset d_CD98
         push      ds
         mov       cx,1
         call      l_2945
         dec       sp
         call      l_739F                   ; test, zda nastala diskov† chyba
         xor       al,1
         jnz       l_B5A6
         ;jmp       l_B61C
         db        0e9h
         dw        l_B61C-$-2

l_B5A6:  mov       di,offset d_CD98
         push      ds
         call      l_2A66
         mov       [bp-86h],ax
         mov       di,offset d_CD98
         push      ds
         call      l_298A
         mov       ax,[bp-86h]
         push      ax
         mov       ax,18Fh
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         je        l_B5C9
         ;jmp       l_B616
         db        0e9h
         dw        l_B616-$-2

l_B5C9:  mov       di,offset d_CD98
         push      ds
         push      di
         lea       di,[bp-83h]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_2940                   ; p©°prava jmÇna souboru k operaci
         mov       di,offset d_CD98
         push      ds
         mov       cx,18Fh
         call      l_2945
         dec       sp
         call      l_739F                   ; test, zda nastala diskov† chyba
         xor       al,1
         jnz       l_B5EE
         ;jmp       l_B605
         db        0e9h
         dw        l_B605-$-2

l_B5EE:  mov       di,offset d_CD98
         push      ds
         call      l_299C
         mov       di,offset l_30C1         ; k¢dy tisk†rny tiskovòch efektñ
         push      cs
         call      l_29B9
         dec       sp
         call      l_739F                   ; test, zda nastala diskov† chyba
         jnz       l_B605
         ;jmp       l_B605
         db        0e9h,0,0

l_B605:  mov       di,offset d_CD98
         push      ds
         call      l_298A
         call      l_0FFC
         mov       [bp-86h],ax
         ;jmp       l_B61C
         db        0e9h
         dw        l_B61C-$-2

l_B616:  mov       ax,0Dh
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
l_B61C:  mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_B627
         ;jmp       l_B62A
         db        0e9h
         dw        l_B62A-$-2

l_B627:  call      l_5A89                   ; zobrazen° chybovÇho hl†®en°
l_B62A:  mov       ax,1
         mov       byte ptr ds:[d_F78A],al  ; 1=p©°znak p©eru®en° editace volby
         call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
         call      l_468D                   ; zobrazen° parametrñ ve stav. ©†dku
         ;jmp       l_B639
         db        0e9h,0,0

l_B639:  mov       sp,bp
         pop       bp
         ret       

l_B533   ENDP

; -----------------------------------------------------------------------------
;        zmàna instalace tisk†rny, obsluha volby Tisk/zmàna instalace
; -----------------------------------------------------------------------------

l_B63D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B644
         db        0e9h,0,0

l_B644:  sub       sp,81h
         lea       di,[bp-83h]
         push      ss
         push      di
         mov       di,offset d_FDD5         ; p©°stupov† cesta k SCREEN.OVL
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        13,'TINSTALL.COM '

         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         sub       sp,9
         mov       ax,cs
         push      ax
         call      l_36BB                   ; p©evod á°sla INTEGER na ©etàzec
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       ax,2001h
         push      ax
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         sub       sp,9
         mov       di,offset l_30c1         ; k¢dy tisk†rny tiskovòch efektñ
         xchg      ax,di
         push      ax
         call      l_36BB                   ; p©evod á°sla INTEGER na ©etàzec
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       cl,80h
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         lea       di,[bp-83h]
         push      ss
         push      di
         mov       ax,0
         push      ax
         call      l_8062
         mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_B6A7
         ;jmp       l_B6AA
         db        0e9h
         dw        l_B6AA-$-2

l_B6A7:  call      l_5A89                   ; zobrazen° chybovÇho hl†®en°
l_B6AA:  call      l_468D                   ; zobrazen° parametrñ ve stav. ©†dku
         mov       ax,1
         mov       ds:[d_F78A],al           ; 1=p©°znak p©eru®en° editace volby
         ;jmp       l_B6B6
         db        0e9h,0,0

l_B6B6:  mov       sp,bp
         pop       bp
         ret       

l_B63D   ENDP

; -----------------------------------------------------------------------------
;        obsluha povelu Ctrl-P (volba typu p°sma)
; -----------------------------------------------------------------------------

l_B6BA   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B6C1
         db        0e9h,0,0

l_B6C1:  jmp       short l_B6FE

l_B6C3   db        'NFUKBHT'                ; p°smena voleb

l_B6CA   db        0,10h,8,4,20h,1,2        ; v†hy jednotlivòch voleb

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B6D1   PROC      NEAR

         mov       dx,2
         mov       si,offset l_B6CA
l_B6D7:  mov       al,cs:[si]
         cmp       al,bl
         je        l_B6E4
         test      al,bl
         mov       al,2Dh
         jz        l_B6E6
l_B6E4:  mov       al,0FBh
l_B6E6:  mov       ah,0
         push      bx
         push      dx
         push      si
         push      ax                       ; znak
         mov       al,4Eh
         push      ax                       ; pozice
         push      dx                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         pop       si
         pop       dx
         pop       bx
         inc       si
         inc       dx
         cmp       dl,8
         jbe       l_B6D7
         ret       

l_B6D1   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_B6BA)
; -----------------------------------------------------------------------------

l_B6FE:  mov       ax,4
         push      ax
         call      l_4D50                   ; zobrazen° n†povàdy k volb†m
         mov       bl,byte ptr ds:[d_F788]  ; zvolenò aktu†ln° typ p°sma
         mov       cl,5
         shl       bl,cl
         or        bl,byte ptr ds:[d_F79A]
         cmp       byte ptr ds:[d_F78C],0
         je        l_B71B
         call      l_B6D1
l_B71B:  push      bx
         push      ax
         call      l_54DE                   ; vstup kl†vesy s áek†n°m+makro+tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velkÇ p°smeno
         push      ax
         mov       ax,4
         push      ax
         call      l_4E5D                   ; n†vrat podkladu pod n†povàdou
         pop       ax
         pop       bx
         push      ax
         mov       si,offset l_B6C3
         mov       cx,7
l_B736:  cmp       al,cs:[si]
         je        l_B740
         inc       si
         loop      l_B736
         jmp       short l_B768

l_B740:  mov       al,cs:[si+7]
         cmp       al,1
         jae       l_B74A
         mov       bl,al
l_B74A:  jnz       l_B74F
         and       bl,0FDh
l_B74F:  cmp       al,2
         jne       l_B756
         and       bl,0FEh
l_B756:  xor       bl,al
         mov       al,bl
         mov       cl,5
         shr       al,cl
         mov       byte ptr ds:[d_F788],al  ; zvolenò aktu†ln° typ p°sma
         and       bl,1Fh
         mov       byte ptr ds:[d_F79A],bl
l_B768:  pop       ax
         cmp       al,31h
         jb        l_B780
         cmp       al,38h
         ja        l_B780
         sub       al,31h
         mov       cl,al
         mov       bx,1
         shl       bx,cl
         push      bx
         call      l_B2B6
         jmp       short l_B790

l_B780:  cmp       al,52h
         jne       l_B789
         call      l_B533
         jmp       short l_B790

l_B789:  cmp       al,40h
         jne       l_B790
         call      l_B4C6
l_B790:  ;jmp       l_B793
         db        0e9h,0,0

l_B793:  mov       sp,bp
         pop       bp
         ret       

l_B6BA   ENDP

; *****************************************************************************
;
;                         Obsluha menu Kurzor
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QR a Kurzor/zaá†tek textu (kurzor na zaá†tek textu)
; -----------------------------------------------------------------------------

l_B797   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B79E
         db        0e9h,0,0

l_B79E:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         call      l_5D74                   ; p©esun kurzoru na zaá†tek ©†dku
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         cmp       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         jg        l_B7B0
         ;jmp       l_B7BF
         db        0e9h
         dw        l_B7BF-$-2

l_B7B0:  mov       ax,1                     ; novò ©†dek = 1
         mov       word ptr ds:[d_E698],ax  ; á°slo aktivn°ho editovanÇho ©†dku
         mov       ax,1                     ; ©†dek na displeji = 1
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce
         call      l_4C6D                   ; obnoven° zobrazen° obrazovky
l_B7BF:  mov       ax,1
         mov       word ptr ds:[d_E698],ax  ; á°slo aktivn°ho editovanÇho ©†dku
         mov       ax,1
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce
         ;jmp       l_B7CE
         db        0e9h,0,0

l_B7CE:  mov       sp,bp
         pop       bp
         ret       

l_B797   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QC a Kurzor/konec textu (kurzor na konec souboru)
; -----------------------------------------------------------------------------

l_B7D2   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B7D9
         db        0e9h,0,0

l_B7D9:  sub       sp,4
         call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         mov       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         push      ax                       ; poëadovanò ©†dek - posledn° ©†dek
         call      l_4CC6                   ; p©esun kurzoru na zadanò ©†dek
         call      l_5DC2                   ; p©esun kurzoru na konec ©†dku
         ;jmp       l_B7EC
         db        0e9h,0,0

l_B7EC:  mov       sp,bp
         pop       bp
         ret       

l_B7D2   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QE (p©esun kurzoru na horn° okraj obrazovky)
; -----------------------------------------------------------------------------

l_B7F0   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B7F7
         db        0e9h,0,0

l_B7F7:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         call      l_4A3C                   ; inic. bufferu á°sel zobraz. ©†dkñ
         mov       ax,1                     ; horn° okraj obrazovky
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce
         mov       ax,word ptr ds:[d_E5E4]  ; tabulka zobrazenòch ©†dkñ
         cmp       ax,0
         je        l_B80E
         ;jmp       l_B814
         db        0e9h
         dw        l_B814-$-2

l_B80E:  mov       ax,2
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce
l_B814:  mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         shl       ax,1
         xchg      ax,di
         mov       ax,word ptr ds:[d_E5E2+di]
         mov       word ptr ds:[d_E698],ax  ; á°slo aktivn°ho editovanÇho ©†dku
         ;jmp       l_B824
         db        0e9h,0,0

l_B824:  mov       sp,bp
         pop       bp
         ret       

l_B7F0   ENDP

; -----------------------------------------------------------------------------
;        obsluha povelu Ctrl-QX (p©esun kurzoru na doln° okraj obrazovky)
; -----------------------------------------------------------------------------

l_B828   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B82F
         db        0e9h,0,0

l_B82F:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         call      l_4A3C                   ; inic. bufferu á°sel zobraz. ©†dkñ
         mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         dec       ax
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce

         mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         shl       ax,1
         xchg      ax,di
         mov       ax,word ptr ds:[d_E5E2+di]
         cmp       ax,0
         je        l_B84E
         ;jmp       l_B855
         db        0e9h
         dw        l_B855-$-2

l_B84E:  mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         dec       ax
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce
l_B855:  mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         shl       ax,1
         xchg      ax,di
         mov       ax,word ptr ds:[d_E5E2+di]
         mov       word ptr ds:[d_E698],ax  ; á°slo aktivn°ho editovanÇho ©†dku
         ;jmp       l_B865
         db        0e9h,0,0

l_B865:  mov       sp,bp
         pop       bp
         ret       

l_B828   ENDP

; *****************************************************************************
;
;                             Vyhled†v†n° textu
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B869   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_B870
         db        0e9h,0,0

l_B870:  jmp       l_B972

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B873   PROC      NEAR

         push      cx
         xor       ax,ax
         mov       cx,ax
         mov       si,offset d_F459         ; text k hled†n°
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       al,[di]
         mov       cl,[si]
         sub       ax,bx
         jl        l_B8AF
         inc       ax
         inc       ax
         sub       ax,cx
         jle       l_B8AF
         jcxz      l_B8B1
         add       di,bx
         inc       si
l_B891:  push      si
         push      di
         push      cx
l_B894:  mov       dl,[si]
         cmp       dl,1
         je        l_B89F
         cmp       dl,[di]
         jne       l_B8A5
l_B89F:  inc       si
         inc       di
         loop      l_B894
         or        cx,cx
l_B8A5:  pop       cx
         pop       di
         pop       si
         jz        l_B8B1
         inc       di
         inc       bx
         dec       ax
         jnz       l_B891
l_B8AF:  xor       bx,bx
l_B8B1:  pop       cx
         ret       

l_B873   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B8B3   PROC      NEAR

         push      cx
         or        bx,bx
         jle       l_B8F3
         xor       ax,ax
         mov       cx,ax
         mov       si,offset d_F459         ; text k hled†n°
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       al,[di]
         mov       cl,[si]
         inc       ax
         sub       ax,cx
         jle       l_B8F3
         cmp       bx,ax
         jle       l_B8D1
         mov       bx,ax
l_B8D1:  jcxz      l_B8F5
         add       di,bx
         inc       si
l_B8D6:  push      si
         push      di
         push      cx
l_B8D9:  mov       dl,[si]
         cmp       dl,1
         je        l_B8E4
         cmp       dl,[di]
         jne       l_B8EA
l_B8E4:  inc       si
         inc       di
         loop      l_B8D9
         or        cx,cx
l_B8EA:  pop       cx
         pop       di
         pop       si
         jz        l_B8F5
         dec       di
         dec       bx
         jnz       l_B8D6
l_B8F3:  xor       bx,bx
l_B8F5:  pop       cx
         ret       

l_B8B3   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B8F7   PROC      NEAR

         push      bx
         mov       bx,offset l_3378
         xlat      cs:[bx]
         test      al,2
         pop       bx
         ret       

l_B8F7   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B901   PROC      NEAR

         mov       dl,1
         or        bx,bx
         jle       l_B94D
         cmp       bh,byte ptr ds:[d_F793]
         je        l_B92F
         mov       si,offset d_EC59         ; buffer textovÇho ©†dku
         cmp       bl,dl
         je        l_B91C
         mov       al,[bx+si-1]
         call      l_B8F7
         jnz       l_B94B
l_B91C:  mov       ax,bx
         add       al,byte ptr ds:[d_F459]  ; text k hled†n°
         cmp       al,[si]
         ja        l_B92F
         add       si,ax
         mov       al,[si]
         call      l_B8F7
         jnz       l_B94B
l_B92F:  mov       al,byte ptr ds:[d_F794]
         and       al,byte ptr ds:[d_E6AA]  ; 1=p©°znak sloupcovÇho bloku
         jz        l_B94D
         cmp       bx,word ptr ds:[d_E694]  ; pozice zaá†tku sloupcovÇho bloku
         jb        l_B94B
         mov       ax,bx
         add       al,byte ptr ds:[d_F459]  ; text k hled†n°
         dec       ax
         cmp       ax,word ptr ds:[d_E696]  ; pozice konec sloupcovÇho bloku
         jbe       l_B94D
l_B94B:  xor       dl,dl
l_B94D:  or        dl,dl
         ret       

l_B901   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_B950   PROC      NEAR

         push      bx
         push      cx
         push      cx                       ; á°slo ©†dku
         mov       si,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      si
         mov       si,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         push      ds
         push      si
         call      l_3F5A                   ; dek¢dov†n° ©†dku do edit. bufferu
         cmp       byte ptr ds:[d_F795],0
         je        l_B96F
         mov       si,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      si
         call      l_3631                   ; konverze ©etàzce na velk† p°smena
l_B96F:  pop       cx
         pop       bx
         ret       

l_B950   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_B869)
; -----------------------------------------------------------------------------

l_B972:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         ;les       si,dword ptr [bp+8]
         db        0C4h,0B6h,8,0            ;!
         mov       bx,es:[si]
         ;les       si,dword ptr [bp+4]
         db        0C4h,0B6h,4,0            ;!
         mov       cx,es:[si]
         cmp       byte ptr ds:[d_F791],0
         je        l_B9B2
         mov       dx,1
         cmp       dh,byte ptr ds:[d_F794]
         je        l_B997
         mov       dx,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
l_B997:  push      dx
         call      l_B950
l_B99B:  dec       bl
         call      l_B8B3
         call      l_B901
         jz        l_B99B
         pop       dx
         or        bx,bx
         jnz       l_B9DA
         dec       cx
         cmp       cx,dx
         jae       l_B997
         inc       cx
         jmp       short l_B9DA

l_B9B2:  mov       dx,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         cmp       byte ptr ds:[d_F794],0
         je        l_B9C1
         mov       dx,word ptr ds:[d_E692]  ; ©†dek konce bloku
l_B9C1:  push      dx
         call      l_B950
l_B9C5:  inc       bl
         call      l_B873
         call      l_B901
         jz        l_B9C5
         pop       dx
         or        bx,bx
         jnz       l_B9DA
         inc       cx
         cmp       cx,dx
         jbe       l_B9C1
         dec       cx
l_B9DA:  ;les       si,dword ptr [bp+8]
         db        0C4h,0B6h,8,0            ;!
         mov       es:[si],bx
         ;les       si,dword ptr [bp+4]
         db        0C4h,0B6h,4,0            ;!
         mov       es:[si],cx
         or        bx,bx
         jz        l_B9F4
         mov       word ptr ds:[d_E69A],bx  ; pozice kurzoru na ©†dku
         push      cx                       ; poëadovanò ©†dek
         call      l_4CC6                   ; p©esun kurzoru na zadanò ©†dek
l_B9F4:  ;jmp       l_B9F7
         db        0e9h,0,0

l_B9F7:  mov       sp,bp
         pop       bp
         ret       8

l_B869   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-L a Kurzor/dal®° hled†n° (pokraáov†n° v hled†v†n°)
; -----------------------------------------------------------------------------

l_B9FD   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_BA5E
         db        0e9h
         dw        l_BA5E-$-2

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_BA04   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_BA10
         db        0e9h,0,0

l_BA10:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         sub       ax,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         push      ax
         mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         sub       ax,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         push      ax
         mov       di,offset d_F459         ; text k hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         pop       cx
         add       ax,cx
         sub       ax,1
         push      ax
         mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         push      ax
         mov       ax,2
         push      ax
         call      l_34F8                   ; vykreslen° okna (kurzoru)
         call      l_43F3                   ; vymaz†n° horn°ho stavovÇho ©†dku
         ;jmp       l_BA5A
         db        0e9h,0,0

l_BA5A:  mov       sp,bp
         pop       bp
         ret       

l_BA04   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_B9FD)
; -----------------------------------------------------------------------------

l_BA5E:  sub       sp,8
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         mov       [bp-4],ax
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         mov       [bp-6],ax
         mov       al,byte ptr ds:[d_F792]
         xor       ah,ah
         or        ax,ax
         jnz       l_BA79
         ;jmp       l_BAD0
         db        0e9h
         dw        l_BAD0-$-2

l_BA79:  mov       ax,0
         mov       [bp-4],ax
         mov       al,byte ptr ds:[d_F794]
         xor       ah,ah
         or        ax,ax
         jnz       l_BA8B
         ;jmp       l_BAB5
         db        0e9h
         dw        l_BAB5-$-2

l_BA8B:  dec       sp
         call      l_65E5                   ; kontrola, zda je oznaáen blok
         jnz       l_BA94
         ;jmp       l_BA97
         db        0e9h
         dw        l_BA97-$-2

l_BA94:  jmp       l_BCD4

l_BA97:  mov       al,byte ptr ds:[d_F791]
         xor       ah,ah
         or        ax,ax
         jnz       l_BAA3
         ;jmp       l_BAAC
         db        0e9h
         dw        l_BAAC-$-2

l_BAA3:  mov       ax,word ptr ds:[d_E692]  ; ©†dek konce bloku
         mov       [bp-6],ax
         ;jmp       l_BAB2
         db        0e9h
         dw        l_BAB2-$-2

l_BAAC:  mov       ax,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
         mov       [bp-6],ax
l_BAB2:  ;jmp       l_BAD0
         db        0e9h
         dw        l_BAD0-$-2

l_BAB5:  mov       al,byte ptr ds:[d_F791]
         xor       ah,ah
         or        ax,ax
         jnz       l_BAC1
         ;jmp       l_BACA
         db        0e9h
         dw        l_BACA-$-2

l_BAC1:  mov       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         mov       [bp-6],ax
         ;jmp       l_BAD0
         db        0e9h
         dw        l_BAD0-$-2

l_BACA:  mov       ax,1
         mov       [bp-6],ax
l_BAD0:  lea       di,[bp-4]
         push      ss
         push      di
         lea       di,[bp-6]
         push      ss
         push      di
         call      l_B869
         mov       ax,[bp-4]
         cmp       ax,0
         je        l_BAE8
         ;jmp       l_BAF1
         db        0e9h
         dw        l_BAF1-$-2

l_BAE8:  mov       ax,7
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         jmp       l_BCD4

l_BAF1:  mov       al,byte ptr ds:[d_F797]
         xor       ah,ah
         xor       al,1
         jnz       l_BAFD
         ;jmp       l_BB00
         db        0e9h
         dw        l_BB00-$-2

l_BAFD:  jmp       l_BCD1

l_BB00:  mov       ax,41h
         mov       [bp-8],ax
         mov       al,byte ptr ds:[d_F796]
         xor       ah,ah
         or        ax,ax
         jnz       l_BB12
         ;jmp       l_BB6D
         db        0e9h
         dw        l_BB6D-$-2

l_BB12:  call      l_BA04
         mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        17,'Nahradit textem "'

         mov       di,offset d_F4DA         ; text k nahrazen°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        9,'" (A/N) ?'

         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl†vesy s áek†n°m+makro+tisk
         mov       [bp-8],ax
         call      l_BA04
         mov       ax,[bp-8]
         cmp       ax,1bh
         je        l_BB6A
         ;jmp       l_BB6D
         db        0e9h
         dw        l_BB6D-$-2

l_BB6A:  jmp       l_BCD1

l_BB6D:  dec       sp
         mov       ax,[bp-8]
         push      ax
         call      l_36F5                   ; p©evod znaku na velkÇ p°smeno
         cmp       ax,41h
         je        l_BB7D
         jmp       l_BC59

l_BB7D:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       ax,1
         push      ax
         call      l_5972
         mov       di,offset d_F4DA         ; text k nahrazen°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         push      ax
         mov       di,offset d_F459         ; text k hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       [bp-0Ah],ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         xchg      ax,di
         mov       al,byte ptr ds:[d_ED59+di] ; buffer atributñ znakñ text. ©†dku
         xor       ah,ah
         mov       [bp-8],ax
         mov       ax,[bp-0Ah]
         cmp       ax,0
         jg        l_BBBB
         ;jmp       l_BBE9
         db        0e9h
         dw        l_BBE9-$-2

l_BBBB:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       ax,[bp-0Ah]
         push      ax
         call      l_3799                   ; odsun zbytku ©†dku INSERT
         mov       al,byte ptr ds:[d_F791]
         xor       ah,ah
         xor       al,1
         jnz       l_BBD2
         ;jmp       l_BBDB
         db        0e9h
         dw        l_BBDB-$-2

l_BBD2:  mov       ax,[bp-4]
         add       ax,[bp-0Ah]
         mov       [bp-4],ax
l_BBDB:  mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_BBE6
         ;jmp       l_BBE9
         db        0e9h
         dw        l_BBE9-$-2

l_BBE6:  jmp       l_BCD4

l_BBE9:  mov       ax,[bp-0Ah]
         cmp       ax,0
         jl        l_BBF4
         ;jmp       l_BC01
         db        0e9h
         dw        l_BC01-$-2

l_BBF4:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       ax,[bp-0Ah]
         neg       ax
         push      ax
         call      l_37F3                   ; p©°sun zbytku ©†dku DELETE
l_BC01:  mov       di,offset d_F4DA+1       ; text k nahrazen°
         push      ds
         push      di
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         xchg      ax,di
         add       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      di
         mov       di,offset d_F4DA         ; text k nahrazen°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         call      l_0F2E                   ; posun dat (s p©ekryvem)
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         xchg      ax,di
         add       di,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         push      ds
         push      di
         mov       di,offset d_F4DA         ; text k nahrazen°
         push      ds                       ; adresa
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         push      ax                       ; dÇlka
l_BC32:  mov       ax,[bp-8]                ; konstanta
         call      l_0F25                   ; vynulov†n° bufferu konstantou
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim†ln° dÇlka ©†dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
         mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©°znak modifikace textu
         dec       sp
         dec       sp
         call      l_5414                   ; vstup znaku z kl†vesnice
         cmp       ax,1Bh
         je        l_BC56
         ;jmp       l_BC59
         db        0e9h
         dw        l_BC59-$-2

l_BC56:  ;jmp       l_BCD1
         db        0e9h
         dw        l_BCD1-$-2

l_BC59:  mov       al,byte ptr ds:[d_F792]
         xor       ah,ah
         or        ax,ax
         jnz       l_BC65
         ;jmp       l_BC75
         db        0e9h
         dw        l_BC75-$-2

l_BC65:  lea       di,[bp-4]
         push      ss
         push      di
         lea       di,[bp-6]
         push      ss
         push      di
         call      l_B869
         ;jmp       l_BC7B
         db        0e9h
         dw        l_BC7B-$-2

l_BC75:  mov       ax,0
         mov       [bp-4],ax
l_BC7B:  mov       ax,[bp-4]
         cmp       ax,0
         je        l_BC86
         jmp       l_BB00

l_BC86:  mov       al,byte ptr ds:[d_F792]
         xor       ah,ah
         or        ax,ax
         jnz       l_BC92
         ;jmp       l_BCD1
         db        0e9h
         dw        l_BCD1-$-2

l_BC92:  mov       al,byte ptr ds:[d_F794]
         xor       ah,ah
         or        ax,ax
         jnz       l_BC9E
         ;jmp       l_BCBC
         db        0e9h
         dw        l_BCBC-$-2

l_BC9E:  mov       al,byte ptr ds:[d_F791]
         xor       ah,ah
         or        ax,ax
         jnz       l_BCAA
         ;jmp       l_BCB3
         db        0e9h
         dw        l_BCB3-$-2

l_BCAA:  call      l_6801
         call      l_5D74                   ; p©esun kurzoru na zaá†tek ©†dku
         ;jmp       l_BCB9
         db        0e9h
         dw        l_BCB9-$-2

l_BCB3:  call      l_6816
         call      l_5DC2                   ; p©esun kurzoru na konec ©†dku
l_BCB9:  ;jmp       l_BCD1
         db        0e9h
         dw        l_BCD1-$-2

l_BCBC:  mov       al,byte ptr ds:[d_F791]
         xor       ah,ah
         or        ax,ax
         jnz       l_BCC8
         ;jmp       l_BCCE
         db        0e9h
         dw        l_BCCE-$-2

l_BCC8:  call      l_B797
         ;jmp       l_BCD1
         db        0e9h
         dw        l_BCD1-$-2

l_BCCE:  call      l_B7D2
l_BCD1:  call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
l_BCD4:  ;jmp       l_BCD7
         db        0e9h,0,0

l_BCD7:  mov       sp,bp
         pop       bp
         ret       

l_B9FD   ENDP

; -----------------------------------------------------------------------------
;        obsluha voleb Ctrl-QA a Ctrl-QF (hled†n°/n†hrada textu)
; -----------------------------------------------------------------------------

l_BCDB   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_BCE2
         db        0e9h,0,0

l_BCE2:  mov       al,[bp+4]
         xor       ah,ah
         mov       ds:[d_F797],al
         mov       ax,1
         mov       ds:[d_F790],al           ; 1=povoleno zobrazen° menu
         call      l_43F3                   ; vymaz†n° horn°ho stavovÇho ©†dku
         mov       ax,2
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        7,'Hledat:'

         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         mov       di,offset d_F359         ; editaán° buffer zad†n° parametru
         push      ds
         push      di
         mov       di,offset d_F459         ; text k hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0ffh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         mov       ax,10
         push      ax                       ; pozice k zobrazen° textu
         mov       ax,0
         push      ax                       ; ©†dek k zobrazen° textu
         mov       ax,7fh
         push      ax                       ; maxim†ln° dÇlka textu
         mov       ax,1
         push      ax                       ; typ znakñ - v®echny znaky
         mov       di,offset d_F459         ; text k hled†n°
         push      ds                       ; adresa bufferu k uloëen° textu
         push      di
         call      l_56C0                   ; editace zad†n° textovÇho parametru
         mov       al,ds:[d_F78A]           ; 1=p©°znak p©eru®en° editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_BD43
         ;jmp       l_BD49
         db        0e9h
         dw        l_BD49-$-2

l_BD43:  call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
         jmp       l_BF25

l_BD49:  mov       al,ds:[d_F797]
         xor       ah,ah
         or        ax,ax
         jnz       l_BD55
         ;jmp       l_BDB6
         db        0e9h
         dw        l_BDB6-$-2

l_BD55:  call      l_43F3                   ; vymaz†n° horn°ho stavovÇho ©†dku
         mov       ax,2
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        15,' Nahradit á°m :'

         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         mov       di,offset d_F359         ; editaán° buffer zad†n° parametru
         push      ds
         push      di
         mov       di,offset d_F4DA         ; text k nahrazen°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0ffh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         mov       ax,12h
         push      ax                       ; poá†teán° pozice k zobrazen°
         mov       ax,0
         push      ax                       ; ©†dek k zobrazen° textu
         mov       ax,7fh
         push      ax                       ; maxim†ln° dÇlka textu
         mov       ax,1
         push      ax                       ; typ znakñ - v®echny znaky
         mov       di,offset d_F4DA         ; text k nahrazen°
         push      ds                       ; adresa bufferu k uloëen° textu
         push      di
         call      l_56C0                   ; editace zad†n° textovÇho parametru
         mov       al,ds:[d_F78A]           ; 1=p©°znak p©eru®en° editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_BDB0
         ;jmp       l_BDB6
         db        0e9h
         dw        l_BDB6-$-2

l_BDB0:  call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
         jmp       l_BF25

l_BDB6:  call      l_43F3                   ; vymaz†n° horn°ho stavovÇho ©†dku
         mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        9,'  Volby :'

         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         mov       ax,13h
         push      ax
         call      l_4D50                   ; zobrazen° n†povàdy k volb†m
         mov       al,ds:[d_F797]
         xor       ah,ah
         push      ax
         mov       al,ds:[d_F78C]
         xor       ah,ah
         pop       cx
         and       ax,cx
         or        ax,ax
l_BDED:  jnz       l_BDF2
         ;jmp       l_BE17
         db        0e9h
         dw        l_BE17-$-2

l_BDF2:  mov       ax,3Ch
         push      ax
         mov       ax,8
         push      ax
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        17,'N  bez dot†z†n°  '

         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
l_BE17:  mov       di,offset d_F359         ; editaán° buffer zad†n° parametru
         push      ds
         push      di
         mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         mov       ax,0Fh
         push      ax                       ; pozice k zobrazen° textu
         mov       ax,0
         push      ax                       ; ©†dek k zobrazen°
         mov       ax,6
         push      ax                       ; maxim†ln° dÇlka textu
         mov       ax,80h
         push      ax                       ; typ znakñ - parametry hled†n°
         mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds                       ; adresa bufferu k uloëen° textu
         push      di
         call      l_56C0                   ; editace zad†n° textovÇho parametru
         mov       ax,13h
         push      ax
         call      l_4E5D                   ; n†vrat podkladu pod n†povàdou
         mov       al,ds:[d_F78A]           ; 1=p©°znak p©eru®en° editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_BE53
         ;jmp       l_BE59
         db        0e9h
         dw        l_BE59-$-2

l_BE53:  call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
         jmp       l_BF25

l_BE59:  mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds
         push      di
         call      l_3631                   ; konverze ©etàzce na velk† p°smena
         mov       ax,4201h
         push      ax
         mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         cmp       ax,0
         mov       ax,1
         jg        l_BE78
         dec       ax
l_BE78:  mov       ds:[d_F791],al
         mov       ax,4701h
         push      ax
         mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         cmp       ax,0
         mov       ax,1
         jg        l_BE92
         dec       ax
l_BE92:  mov       ds:[d_F792],al
         mov       ax,5701h
         push      ax
         mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         cmp       ax,0
         mov       ax,1
         jg        l_BEAC
         dec       ax
l_BEAC:  mov       ds:[d_F793],al
         mov       ax,5501h
         push      ax
         mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         cmp       ax,0
         mov       ax,1
         jg        l_BEC6
         dec       ax
l_BEC6:  mov       ds:[d_F795],al
         mov       ax,4E01h
         push      ax
         mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         cmp       ax,0
         mov       ax,1
         jz        l_BEE0
         dec       ax
l_BEE0:  mov       ds:[d_F796],al
         mov       ax,4C01h
         push      ax
         mov       di,offset d_F77D         ; buffer parametrñ hled†n°
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         cmp       ax,0
         mov       ax,1
         jg        l_BEFA
         dec       ax
l_BEFA:  mov       ds:[d_F794],al
         mov       al,ds:[d_F792]
         xor       ah,ah
         push      ax
         mov       al,ds:[d_F794]
         xor       ah,ah
         pop       cx
         or        ax,cx
         mov       ds:[d_F792],al
         mov       al,ds:[d_F795]
         xor       ah,ah
         or        ax,ax
         jnz       l_BF1A
         ;jmp       l_BF22
         db        0e9h
         dw        l_BF22-$-2

l_BF1A:  mov       di,offset d_F459         ; text k hled†n°
         push      ds
         push      di
         call      l_3631                   ; konverze ©etàzce na velk† p°smena
l_BF22:  call      l_B9FD
l_BF25:  ;jmp       l_BF28
         db        0e9h,0,0

l_BF28:  mov       sp,bp
         pop       bp
         ret       2

l_BCDB   ENDP

; *****************************************************************************
;
;                   Obsluha voleb maz†n° textu
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QG, Ctrl-QY a Maz†n°/od kurzoru (maë po konec ©†dku)
; -----------------------------------------------------------------------------

l_BF2E   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_BF35
         db        0e9h,0,0

l_BF35:  mov       ax,1
         push      ax
         call      l_5972
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       al,[di]
         mov       ah,0
         mov       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         cmp       bx,ax
         ja        l_BF67
         mov       byte ptr ds:[d_E6A8],ah  ; 0=p©°znak modifikace textu
         dec       bx
         cmp       byte ptr [bx+di],0FFh
         jne       l_BF59
         dec       bx
l_BF59:  mov       [di],bl
         inc       bx
         push      bx
         push      word ptr ds:[d_E6A6]     ; maxim†ln° dÇlka ©†dku od L okraje
         call      l_4855                   ; korekce editovanÇho ©†dku
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
l_BF67:  ;jmp       l_BF6A
         db        0e9h,0,0

l_BF6A:  mov       sp,bp
         pop       bp
         ret       

l_BF2E   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QH a Maz†n°/po kurzor (maz†n° textu k zaá†tku ©†dku)
; -----------------------------------------------------------------------------

l_BF6E   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_BF75
         db        0e9h,0,0

l_BF75:  mov       ax,1
         push      ax
         call      l_5972
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         call      l_5D88                   ; kurzor o pozici vlevo
         mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©°znak modifikace textu
         mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         call      l_37F3                   ; p©°sun zbytku ©†dku DELETE
         call      l_4855                   ; korekce editovanÇho ©†dku
         mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim†ln° dÇlka ©†dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
         call      l_5D74                   ; p©esun kurzoru na zaá†tek ©†dku
         ;jmp       l_BFA7
         db        0e9h,0,0

l_BFA7:  mov       sp,bp
         pop       bp
         ret       

l_BF6E   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QP a Kurzor/na znaáku (n†vrat kurzoru na znaáku)
; -----------------------------------------------------------------------------

l_BFAB   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_BFB2
         db        0e9h,0,0

l_BFB2:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         mov       ax,ds:[d_E6A2]           ; pozice uschovanÇ znaáky v textu
         mov       ds:[d_E69A],ax           ; n†vrat pozice kurzoru na ©†dku
         mov       ax,ds:[d_E6A0]           ; ©†dek uschovanÇ znaáky v textu
         push      ax                       ; poëadovanò ©†dek
         call      l_4CC6                   ; p©esun kurzoru na zadanò ©†dek
         ;jmp       l_BFC5
         db        0e9h,0,0

l_BFC5:  mov       sp,bp
         pop       bp
         ret       

l_BFAB   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QM a Kurzor/nastaven° znaáky (nastaven° znaáky)
; -----------------------------------------------------------------------------

l_BFC9   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_BFD0
         db        0e9h,0,0

l_BFD0:  mov       ax,ds:[d_E69A]           ; pozice kurzoru na ©†dku
         mov       ds:[d_E6A2],ax           ; £schova pozice kurzoru na ©†dku
         mov       ax,ds:[d_E698]           ; á°slo aktivn°ho editovanÇho ©†dku
         mov       ds:[d_E6A0],ax           ; £schova ©†dku s kurzorem
         ;jmp       l_BFDF
         db        0e9h,0,0

l_BFDF:  mov       sp,bp
         pop       bp
         ret       

l_BFC9   ENDP

; -----------------------------------------------------------------------------
;        obsluha povelu Ctrl-QZ a Kurzor/na pozici (kurzor na zadanou pozici)
; -----------------------------------------------------------------------------

l_BFE3   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_BFEA
         db        0e9h,0,0

l_BFEA:  sub       sp,4
         call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      di
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        25,'Kurzor na - ©†dek,pozici:'

         mov       cl,0ffh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         mov       al,cs:[l_3263]           ; zobraz. str†nk. (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_C024
         ;jmp       l_C03B
         db        0e9h
         dw        l_C03B-$-2

l_C024:  call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku
         db        6,'str., '

         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      di
         mov       ax,0dh
         mov       cl,0ffh
         call      l_13B0
l_C03B:  call      l_43F3                   ; vymaz†n° horn°ho stavovÇho ©†dku
         mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         mov       di,offset d_F359         ; editaán° buffer zad†n° parametru
         push      ds
         push      di

l_C05A:  mov       di,offset d_F75F         ; zadan† pozice kurzoru v souboru
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         mov       ax,7
         push      ax
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         pop       cx
         add       ax,cx
         push      ax                       ; pozice k zobrazen° textu
         mov       ax,0                     
         push      ax                       ; ©†dek k zobrazen°
         mov       ax,0Ah                   
         push      ax                       ; maxim†ln° dÇlka textu
         mov       ax,1                     
         push      ax                       ; typ znakñ - v®echny znaky
         mov       di,offset d_F75F         ; zadan† pozice kurzoru v souboru
         push      ds                       ; adresa bufferu k uloëen° textu
         push      di                       
         call      l_56C0                   ; editace zad†n° textovÇho parametru
         call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
         mov       al,ds:[d_F78A]           ; 1=p©°znak p©eru®en° editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_C09B
         ;jmp       l_C09E
         db        0e9h
         dw        l_C09E-$-2

l_C09B:  jmp       l_C146

l_C09E:  jmp       short l_C0E0

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_C0A0   PROC      NEAR

         cmp       bl,[si]
         ja        l_C0DB
         mov       cl,[bx+si]
         mov       ch,0
         inc       bx
         cmp       cl,2Ch
         je        l_C0DB
         xor       ax,ax
         dec       bx
l_C0B1:  cmp       bl,[si]
         ja        l_C0DB
         mov       cl,[bx+si]
         inc       bx
         cmp       cl,2Ch
         je        l_C0DB
         sub       cl,30h
         jc        l_C0D2
         cmp       cl,9
         ja        l_C0D2
         mov       dx,0Ah
         mul       dx
         jc        l_C0D2
         add       ax,cx
         jnc       l_C0B1
l_C0D2:  mov       word ptr ds:[d_F79D],9   ; k¢d chyby KonTextu
         pop       ax
         jmp       short l_C146

l_C0DB:  or        ax,ax
         jz        l_C0D2
         ret       

l_C0A0   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_BFE3)
; -----------------------------------------------------------------------------

l_C0E0:  mov       si,offset d_F75F         ; zadan† pozice kurzoru v souboru
         mov       bx,1
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         cmp       bh,byte ptr cs:[l_3263]  ; zobraz. str†nk. (1=zap., 0=vyp.)
         je        l_C114
         xor       dx,dx
         dec       ax
         div       word ptr ds:[d_F7A9]     ; poáet ©†dkñ na str†nku bez okrajñ
         inc       ax
         inc       dx
         mov       di,dx
         call      l_C0A0
         dec       ax
         mul       word ptr ds:[d_F7A9]     ; poáet ©†dkñ na str†nku bez okrajñ
         xchg      ax,di
         call      l_C0A0
         cmp       ax,word ptr ds:[d_F7A9]  ; poáet ©†dkñ na str†nku bez okrajñ
         jbe       l_C110
         mov       ax,word ptr ds:[d_F7A9]  ; poáet ©†dkñ na str†nku bez okrajñ
l_C110:  add       ax,di
         jmp       short l_C117

l_C114:  call      l_C0A0
l_C117:  cmp       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         jbe       l_C120
         mov       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
l_C120:  mov       di,ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         add       al,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         call      l_C0A0
         cmp       ax,0EFh
         jbe       l_C135
         mov       ax,0EFh
l_C135:  sub       al,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         ja        l_C13F
         mov       ax,1
l_C13F:  mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
         push      di
         call      l_4CC6                   ; p©esun kurzoru na zadanò ©†dek
l_C146:  ;jmp       l_C149
         db        0e9h,0,0

l_C149:  mov       sp,bp
         pop       bp
         ret       

l_BFE3   ENDP

Code     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                   Datovò segment
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Data     SEGMENT   BYTE PUBLIC

Data     ENDS
         END
