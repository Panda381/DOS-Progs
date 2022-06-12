  
  
a_0006   equ       6
a_0008   equ       8
a_0013   equ       13h
a_0015   equ       15h
a_0043   equ       43h
a_072E   equ       72Eh
a_077E   equ       77Eh
a_07EC   equ       7ECh

seg_b    segment   para
         assume    cs:seg_b, ds:seg_b


         org       0

         db        0EBh, 63h, 90h
b_0003   db        0, 0
b_0005   dw        0
b_0007   dd        00000h
b_000B   dd        00000h
b_000F   dw        1
b_0011   db        0
b_0012   db        2
b_0013   db        8
b_0014   db        2
b_0015   db        0
         db         50h, 00h
         db        29 dup (0)
b_0035   db        0
         db         00h, 14h, 00h, 66h, 01h, 11h
         db         00h,66h, 1, 34h, 00h,66h
         db         1
b_0043   dw        0
b_0045   dw        0
b_0047   dw        0, 0
b_004B   dw        0
b_004D   dw        0
         db        16h
         db        12 dup (0)
b_005C   db        0
b_005D   dw        0
b_005F   dw        0
b_0061   dw        0, 0
         db        0FCh, 33h,0F6h, 8Bh,0FEh, 2Eh
         db         8Bh, 0Eh, 0Fh, 00h, 83h,0F9h
         db         01h, 75h, 1Dh,0B9h, 00h, 08h
         db         33h,0DBh
b_0079:            
         inc       cx
         jz        b_008C
         mov       ds,cx
         mov       al,[bx]
         not       al
         mov       [bx],al
         cmp       al,[bx]
         not       al
         mov       [bx],al
         jz        b_0079
b_008C:            
         mov       cs:b_000F,cx
b_0091:            
         mov       ax,cs
         mov       ds,ax
         mov       ax,810h
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         sub       cx,ax
         mov       es,cx
         mov       cx,802h
         shr       cx,1
         rep       movsw
         push      es
         mov       ax,0B1h
         push      ax
         retf      
         mov       ax,cs:b_0005
         mov       ds,ax
         mov       ax,word ptr cs:b_0007+2
         mov       es,ax
         xor       si,si
         mov       di,si
         mov       cx,2800h
         rep       movsw
         lds       si,cs:b_000B
         mov       dx,cs:b_000F
         cli       
         mov       ax,cs
         mov       ss,ax
         mov       sp,0D9h
         sti       
         call      ss:b_0007
         mov       ss:b_0005,es
         mov       word ptr ss:b_0003,di
;*       call      far ptr s_0070_0A32              ;*
         db         9Ah, 32h, 0Ah, 70h, 00h
         sti       
         cld       
         mov       bx,cs
         sub       bx,10h
         mov       es,bx
         xor       si,si
         mov       di,si
         mov       cx,80h
         rep       movsw
         mov       ah,50h             ; 'P'
         int       21h
         push      ds
         push      cs
         pop       ds
         mov       dx,offset int_24
         mov       ax,2524h
         int       21h
         pop       ds
         mov       dl,ss:b_0011
         or        dl,dl
         jz        b_011E
         dec       dl
         mov       ah,0Eh
         int       21h
b_011E:            
         call      b_01A6
         push      cs
         pop       ds
         mov       al,b_0013
         cbw       
         mov       cx,ax
         xor       bx,bx
         mov       ah,3Eh             ; '>'
         int       21h
         mov       bx,2

b_0132:            
         mov       ah,3Eh             ; '>'
         int       21h
         inc       bx
         loop      b_0132

         mov       dx,offset b_06FD+9
         mov       al,2
         mov       ah,3Dh             ; '='
         stc       
         int       21h
         jnc       b_014A
         call      b_066C
         jmp       short b_015D
b_014A:            
         push      ax
         mov       bx,1
         mov       ah,3Eh             ; '>'
         int       21h
         pop       ax
         mov       bx,ax
         mov       ah,45h             ; 'E'
         int       21h
         mov       ah,45h             ; 'E'
         int       21h
b_015D:            
         mov       dx,offset b_06FD+12h
         mov       al,2
         call      b_06C7
         mov       dx,offset b_06FD+1Bh
         mov       al,1
         call      b_06C7
         mov       si,offset b_0015
         push      ds
         pop       es
         mov       di,si
         mov       cl,0FFh
b_0176:            
         inc       cl
         lodsb     
         stosb     
         or        al,al
         jnz       b_0176
         dec       di
         mov       al,0Dh
         stosb     
         mov       b_0014,cl
         push      cs
         pop       es
         mov       dx,offset b_06FD+30h
         mov       bx,offset b_0035
         mov       [bx+4],cs
         mov       [bx+8],cs
         mov       [bx+0Ch],cs
         xor       ax,ax
         mov       ah,4Bh             ; 'K'
         stc       
         int       21h
         mov       dx,7D8h
         call      b_066C
b_01A4:            
         jmp       short b_01A4

;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_01A6   PROC      near
         push      cs
         pop       ds
         mov       bx,0FFFFh
         mov       ah,48h             ; 'H'
         int       21h
         mov       ah,48h             ; 'H'
         int       21h
         mov       b_004D,ax
         mov       word ptr b_0047+2,ax
         mov       ax,3700h
         int       21h
         mov       b_0015,dl
         mov       dx,offset b_06FD+24h
         mov       ax,3D00h
         stc       
         int       21h
         jc        b_01D0
         jmp       b_0279
b_01D0:            
         push      cs
         pop       ds
         call      b_05EF
         mov       al,b_0013
         sub       al,5
         jbe       b_0217
         cbw       
         mov       bx,b_0047
         mov       dx,word ptr b_0047+2
         lds       di,dword ptr b_0003
         lds       di,dword ptr [di+4]
         mov       [di],bx
         mov       [di+2],dx
         push      cs
         pop       ds
         les       di,dword ptr b_0047
         mov       word ptr es:[di],0FFFFh
         mov       es:[di+4],ax
         mov       bl,28h             ; '('
         mul       bl
         mov       cx,ax
         add       b_0047,ax
         mov       ax,6
         add       b_0047,ax
         add       di,ax
         xor       ax,ax
         rep       stosb
b_0217:            
         call      b_05EF
         dec       b_0012
         jz        b_024F
         push      ds
         les       di,dword ptr b_0047
         lds       bx,dword ptr b_0003
         mov       ax,[bx+13h]
         mov       es:[di],ax
         mov       ax,[bx+15h]
         mov       es:[di+2],ax
         mov       [bx+13h],di
         mov       [bx+15h],es
         mov       word ptr es:[di+4],0FFh
         mov       bx,[bx+11h]
         pop       ds
         add       bx,10h
         add       b_0047,bx
         jmp       short b_0217
b_024F:            
         call      b_05EF
         mov       bx,word ptr b_0047+2
         mov       ax,b_004D
         mov       es,ax
         sub       bx,ax
         mov       ah,4Ah             ; 'J'
         int       21h
         push      es
         mov       ax,es
         dec       ax
         mov       es,ax
         mov       word ptr es:[1],8
         pop       es
         retn      
b_0270:            
         mov       dx,a_077E
         call      b_068C
         jmp       b_0306
b_0279:            
         mov       bx,ax
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h
         mov       ds:a_0043,ax
         xor       dx,dx
         mov       ax,4200h
         int       21h
         mov       dx,cs
         mov       ax,ds:a_0043
         add       ax,0Fh
         mov       cl,4
         shr       ax,cl
         sub       dx,ax
         sub       dx,11h
         mov       ds,dx
         mov       es,dx
         xor       dx,dx
         mov       cx,ss:b_0043
         mov       ah,3Fh             ; '?'
         stc       
         int       21h
         pushf     
         push      cs
         pop       ds
         push      ax
         mov       ah,3Eh             ; '>'
         int       21h
         pop       ax
         popf      
         jc        b_02BF
         cmp       cx,ax
         je        b_02C8
b_02BF:            
         mov       dx,721h
         call      b_066C
b_02C5:            
         jmp       b_01D0
b_02C8:            
         call      b_0532
         call      b_0519
b_02CE:            
         jc        b_02C5
         mov       ah,al
         call      b_0519
         cmp       ah,42h             ; 'B'
         jne       b_02E9
         call      b_063D
         jz        b_0306
         cmp       ax,64h
         jae       b_0270
         mov       b_0012,al
         jmp       short b_0306
b_02E9:            
         cmp       ah,43h             ; 'C'
         je        b_02F1
         jmp       short b_030D
         db        90h
b_02F1:            
         cmp       al,4Fh             ; 'O'
         jne       b_0306
         call      b_0519
         jc        b_02C5
         cmp       al,4Eh             ; 'N'
         jne       b_0306
         mov       ah,33h             ; '3'
         mov       al,1
         mov       dl,al
         int       21h
b_0306:            
         push      cs
         pop       ds
         call      b_05C7
         jmp       short b_02CE
b_030D:            
         cmp       ah,44h             ; 'D'
         je        b_0315
         jmp       b_049A
b_0315:            
         mov       bx,cs
         mov       ds,bx
         mov       b_0061,si
         mov       word ptr b_0061+2,es
         call      b_05EF
         xor       ax,ax
         mov       word ptr b_0007,ax
         mov       ax,word ptr b_0047+2
         mov       word ptr b_0007+2,ax
         mov       b_004B,ax
         push      es
         pop       ds
         mov       dx,si
         mov       es,bx
         mov       bx,offset b_0047+2
         mov       al,3
         mov       ah,4Bh             ; 'K'
         stc       
         int       21h
         push      ds
         pop       es
         push      cs
         pop       ds
         jnc       b_034D
b_0348:            
         call      b_0670
         jmp       short b_0306
b_034D:            
         push      es
         push      si
         push      cs
         pop       es
         mov       bx,a_0006
         call      b_060A
         mov       bx,a_0008
         call      b_060A
         push      cs
         pop       ds
         mov       ax,b_005F
         cmp       ax,b_000F
         jb        b_036C
         pop       si
         pop       es
         jmp       short b_0348
b_036C:            
         mov       word ptr b_0047+2,ax
         mov       ax,b_005D
         mov       b_0047,ax
         lds       dx,b_0007
         mov       si,dx
         add       si,4
         les       di,dword ptr cs:b_0003
         mov       ax,[si]
         test      ax,8000h
         jz        b_03A7
         test      ax,1
         jz        b_0397
         mov       es:[di+0Ch],dx
         mov       es:[di+0Eh],ds
b_0397:            
         test      ax,8
         jz        b_03A4
         mov       es:[di+8],dx
         mov       es:[di+0Ah],ds
b_03A4:            
         jmp       b_044B
b_03A7:            
         mov       al,cs:b_005C
         or        al,al
         jnz       b_03BC
         mov       cs:b_0047,0
         mov       ax,0FFFFh
         jmp       b_0470
b_03BC:            
         cbw       
         mov       cx,ax
         mov       dh,ah
         mov       dl,es:[di+10h]
         add       es:[di+10h],al
         lds       bx,dword ptr cs:b_0061

b_03CE:            
         les       bp,dword ptr cs:b_0003
         les       bp,dword ptr es:[bp]
b_03D7:            
         cmp       word ptr es:[bp+18h],0FFFFh
         je        b_03E4
         les       bp,dword ptr es:[bp+18h]
         jmp       short b_03D7
b_03E4:            
         mov       ax,cs:b_0047
         mov       es:[bp+18h],ax
         mov       ax,word ptr cs:b_0047+2
         mov       es:[bp+1Ah],ax
         les       bp,dword ptr cs:b_0047
         add       cs:b_0047,5Eh
         mov       word ptr es:[bp+18h],0FFFFh
         mov       byte ptr es:[bp+17h],0FFh
         mov       si,[bx]
         inc       bx
         inc       bx
         mov       es:[bp],dx
         mov       ah,53h             ; 'S'
         int       21h
         mov       ax,es:[bp+2]
         push      es
         les       di,dword ptr cs:b_0003
         cmp       ax,es:[di+11h]
         pop       es
         jbe       b_0435
         pop       si
         pop       es
         mov       dx,7A2h
         mov       bx,7A5h
         call      b_0676
         jmp       b_0306
b_0435:            
         push      ds
         push      dx
         lds       dx,cs:b_0007
         mov       es:[bp+12h],dx
         mov       es:[bp+14h],ds
         pop       dx
         pop       ds
         inc       dx
         inc       dh
         loop      b_03CE

b_044B:            
         les       di,dword ptr cs:b_0003
         mov       cx,es:[di+17h]
         mov       dx,es:[di+19h]
         lds       si,cs:b_0007
         mov       es:[di+17h],si
         mov       es:[di+19h],ds
         mov       ax,[si]
         mov       word ptr cs:b_0007,ax
         mov       [si],cx
         mov       [si+2],dx
b_0470:            
         pop       si
         pop       es
         inc       ax
         jz        b_0478
         jmp       b_034D
b_0478:            
         jmp       b_0306
b_047B:            
         cmp       ah,51h             ; 'Q'
         jne       b_04AE
         call      b_063D
         jz        b_0478
         or        ah,ah
         jnz       b_0478
         mov       ah,38h             ; '8'
         mov       dx,0FFFFh
         int       21h
         jnc       b_0478
         mov       dx,a_07EC
         call      b_068C
         jmp       short b_0478
b_049A:            
         cmp       ah,46h             ; 'F'
         jne       b_047B
         call      b_063D
         jz        b_0478
         cmp       ax,64h
         jae       b_0504
         mov       ds:a_0013,al
         jmp       short b_0478
b_04AE:            
         cmp       ah,57h             ; 'W'
         jne       b_04C1
         mov       dl,al
         mov       ax,3701h
         mov       ds:a_0015,dl
         int       21h
         jmp       b_0306
b_04C1:            
         cmp       ah,41h             ; 'A'
         jne       b_04D4
         cmp       al,46h             ; 'F'
         jne       b_04D1
         mov       ax,3703h
         xor       dl,dl
         int       21h
b_04D1:            
         jmp       b_0306
b_04D4:            
         cmp       ah,53h             ; 'S'
         jne       b_0504
         mov       byte ptr ds:a_0015,0
         mov       di,a_072E
         mov       [di-1],al
b_04E4:            
         call      b_0519
         or        al,al
         jz        b_0507
         cmp       al,20h             ; ' '
         jb        b_04F4
         mov       [di],al
         inc       di
         jmp       short b_04E4
b_04F4:            
         mov       byte ptr [di],0
         call      b_0519
         cmp       al,0Ah
         jne       b_0501
         call      b_0519
b_0501:            
         jmp       b_02CE
b_0504:            
         jmp       b_0270
b_0507:            
         mov       byte ptr [di],0
         mov       di,15h
b_050D:            
         call      b_0519
         cmp       al,20h             ; ' '
         jb        b_04F4
         mov       [di],al
         inc       di
         jmp       short b_050D
b_01A6   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_0519   PROC      near
         mov       cx,b_0043
         jcxz      b_0530
         mov       si,b_0045
         mov       al,es:[si]
         dec       b_0043
         inc       b_0045
         clc       
         retn      
b_0530:            
         stc       
         retn      
b_0519   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_0532   PROC      near
         mov       cx,ds:a_0043
         jcxz      b_0530
         call      b_05D4
         xor       si,si
         mov       di,si
b_053F:            
         call      b_059B
         cmp       al,20h             ; ' '
         jb        b_053F
         push      cx
         push      si
         push      di
         mov       bp,si
         dec       bp
         mov       si,offset b_073A
         mov       ch,0
b_0551:            
         mov       di,bp
         mov       cl,[si]
         inc       si
         jcxz      b_0566
         repe      cmpsb
         lahf      
         add       si,cx
         sahf      
         lodsb     
         jnz       b_0551
         pop       di
         pop       si
         pop       cx
         jmp       short b_056B
b_0566:            
         pop       di
         pop       si
         pop       cx
         mov       al,5Ah             ; 'Z'
b_056B:            
         stosb     
b_056C:            
         call      b_0593
         call      b_05A8
         jnz       b_056C
         call      b_059B
         stosb     
b_0578:            
         call      b_0593
         stosb     
         cmp       al,20h             ; ' '
         ja        b_0578
         cmp       al,0Ah
         je        b_053F
         mov       byte ptr es:[di-1],0
b_0589:            
         call      b_0593
         stosb     
         cmp       al,0Ah
         jne       b_0589
         jmp       short b_053F
b_0532   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_0593   PROC      near
         jcxz      b_05BB
         mov       al,es:[si]
         inc       si
         dec       cx
         retn      

;==== External En==try into Subroutine ====================================

b_059B:            
b_059B:            
         jcxz      b_05BB
         mov       al,es:[si]
         inc       si
         dec       cx
         call      b_05A8
         jz        b_059B

b_05A7:            
         retn      

;==== External En==try into Subroutine ====================================

b_05A8:            
         cmp       al,20h             ; ' '
         je        b_05A7
         cmp       al,9
         je        b_05A7
         cmp       al,3Dh             ; '='
         je        b_05A7
         cmp       al,2Ch             ; ','
         je        b_05A7
         cmp       al,3Bh             ; ';'
         retn      
b_05BB:            
         pop       cx
         mov       b_0043,di
         xor       si,si
         mov       b_0045,si
         retn      
b_0593   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_05C7   PROC      near
b_05C7:            
         call      b_0519
         jc        b_05D3
         cmp       al,0Ah
         jne       b_05C7
         call      b_0519

b_05D3:            
         retn      
b_05C7   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_05D4   PROC      near
         push      cx
         push      si
         push      ds
         push      es
         pop       ds
         xor       si,si

b_05DB:            
         lodsb     
         cmp       al,61h             ; 'a'
         jb        b_05E9
         cmp       al,7Ah             ; 'z'
         ja        b_05E9
         sub       al,20h             ; ' '
         mov       [si-1],al
b_05E9:            
         loop      b_05DB

         pop       ds
         pop       si
         pop       cx
         retn      
b_05D4   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_05EF   PROC      near
         mov       ax,ss:b_0047
         add       ax,0Fh
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         add       word ptr ss:b_0047+2,ax
         xor       ax,ax
         mov       ss:b_0047,ax
         retn      
b_05EF   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_060A   PROC      near
         mov       ds,word ptr cs:b_0007+2
         add       bx,word ptr cs:b_0007
         mov       ax,[bx]
         push      word ptr cs:b_0007
         mov       word ptr cs:b_0007,ax
         mov       bx,4Fh
         call      ss:b_0007
         pop       word ptr cs:b_0007
         retn      
b_060A   ENDP      

b_062D:            
         pop       ax
         jmp       b_0270

;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_0631   PROC      near
         sub       al,30h             ; '0'
         jc        b_063B
         cmp       al,9
         ja        b_063B
         clc       
         retn      
b_063B:            
         stc       
         retn      
b_0631   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_063D   PROC      near
         xor       bx,bx
b_063F:            
         call      b_0631
         jc        b_062D
         xchg      ax,bx
         push      bx
         mov       bx,0Ah
         mul       bx
         pop       bx
         add       al,bl
         adc       ah,0
         jc        b_062D
         xchg      ax,bx
         call      b_0519
         jc        b_0667
         or        al,al
         jnz       b_063F
         inc       ss:b_0043
         dec       ss:b_0045
b_0667:            
         mov       ax,bx
         or        ax,ax
         retn      
b_063D   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_066C   PROC      near
         push      cs
         pop       es
         mov       si,dx

;==== External En==try into Subroutine ====================================

b_0670:            
         mov       bx,7A2h
         mov       dx,offset b_0775+51h

;==== External En==try into Subroutine ====================================

b_0676:            
         push      cs
         pop       ds
         mov       ah,9
         int       21h
b_067C:            
         mov       dl,es:[si]
         or        dl,dl
         jz        b_068A
         mov       ah,2
         int       21h
         inc       si
         jmp       short b_067C
b_068A:            
         mov       dx,bx

;==== External En==try into Subroutine ====================================

b_068C:            
         mov       ah,9
         int       21h
         retn      
b_066C   ENDP      

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      bx
         xor       ax,ax
         mov       ah,3Dh             ; '='
         stc       
         int       21h
         pop       dx
         jc        b_06C0
         push      es
         pop       ds
         mov       bx,ax
         mov       cx,0FF00h
         mov       ah,3Fh             ; '?'
         stc       
         int       21h
         jc        b_06C0
         mov       si,dx
         cmp       word ptr [si],5A4Dh
         jne       b_06BB
         stc       
         jmp       short b_06C0
b_06BB:            
         mov       ah,3Eh             ; '>'
         stc       
         int       21h
b_06C0:            
         pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         retn      

;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_06C7   PROC      near
         call      b_06E4
         jnc       b_06D3
b_06CC:            
         mov       dx,offset b_06FD
         call      b_06E4

b_06D2:            
         retn      
b_06D3:            
         xor       ax,ax
         mov       ah,44h             ; 'D'
         int       21h
         test      dl,80h
         jnz       b_06D2
         mov       ah,3Eh             ; '>'
         int       21h
         jmp       short b_06CC
b_06C7   ENDP      


;==========================================================================
;                  SUBROUTINE
;==========================================================================

b_06E4   PROC      near
         mov       ah,3Dh             ; '='
         stc       
         int       21h
         retn      
b_06E4   ENDP      


;==========================================================================
;                  
;                  External Entry Point
;                  
;==========================================================================

int_24   proc      far
         add       sp,6
         pop       ax
         pop       bx
         pop       cx
         pop       dx
         pop       si
         pop       di
         pop       bp
         pop       ds
         pop       es
         push      ax
         mov       ah,19h
         int       21h
         pop       ax
         iret      
int_24   endp      

b_06FD   db        '\DEV\NUL', 0
         db        '\DEV\CON', 0
         db        '\DEV\AUX', 0
         db        '\DEV\PRN', 0
         db        '\CONFIG.SYS', 0
         db        '\COMMAND.COM', 0
b_073A   db        7
         db        'BUFFERSB'
         db         05h, 42h, 52h, 45h, 41h, 4Bh
         db         43h, 05h, 53h, 48h, 45h, 4Ch
         db         4Ch, 53h, 06h, 44h, 45h, 56h
         db         49h, 43h, 45h, 44h, 05h
         db        'FILESF', 8, 'SWITCHARW', 8, 'AVA'
         db        'ILDEVA'
         db        7
b_0775   db        'COUNTRYQ', 0
         db        0Dh, 0Ah, 'Unrecognized command i'
         db        'n CONFIG.SYS', 0Dh, 0Ah, '$'
         db        0Dh, 0Ah, 'Sector size too large '
         db        'in file $'
         db        0Dh, 0Ah, 'Bad or missing $'
         db        'Command Interpreter', 0
         db        0Dh, 0Ah, 'Bad Country code', 0Dh
         db        0Ah, '$'
  
seg_b    ends
