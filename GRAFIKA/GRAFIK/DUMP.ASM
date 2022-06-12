code     segment
         assume    cs:code,ds:code
         org       100h

start:

         mov       ax,3d00h
         mov       dx,offset soub
         int       21h
         jc        konec

         mov       dx,offset buffer
         mov       cx,528
         mov       bx,ax
         mov       ah,3fh
         int       21h
         jc        konec

         mov       si,offset buffer + 16
         mov       bx,4
s0:
         mov       cx,32
s1:
         mov       al,"d"
         call      dispch
         call      dispch
         mov       al," "
         call      dispch
         mov       dl,ds:[si]
         call      dispb
         mov       dl,ds:[si+1]
         call      dispb
         mov       dl,ds:[si+2]
         call      dispb
         mov       dl,ds:[si+3]
         call      dispb
         mov       al,13
         call      dispch
         mov       al,10
         call      dispch
         add       si,4
         loop      s1

         mov       al,13
         call      dispch
         mov       al,10
         call      dispch

         dec       bx
         jnz       s0

konec:   int       20h




dispb:   push      cx
         mov       cx,8
dispb1:  shl       dl,1
         mov       al,"0"
         jnc       dispb2
         mov       al,"1"
dispb2:  call      dispch
         loop      dispb1
         pop       cx
         ret


dispch:  push      ax
         push      dx
         mov       dl,al
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

soub     db        'A.SCR',0


buffer   db        528 dup(0)

code     ends
         end       start
