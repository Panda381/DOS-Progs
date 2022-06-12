
; Macros which may be required for proper re-assembly

IF (target EQ 'M4')
;-----------------------------------------------------------------------------
;  MASM 4.0 does not allow retf and retn, allowed by current assemblers.
;  These marcos, convert RETF and RETN into data bytes that are acceptable
;  to MASM 4.0.


retf            macro   ret_count               ; Fixup for Assembler
                if      ret_count+0 GT 1
                db      0CAh
                dw      ret_count
                else
                db      0CBh
                endif
endm

retn            macro  ret_count
                if     ret_count+0 GT 1
                db     0C2h
                dw     ret_count
                else
                db     0C3h
                endif
endm

ENDIF


IF (target EQ 'M4') OR (target EQ 'M5') 
;-----------------------------------------------------------------------------
; Due to a bug in earlier MASM assemblers, the valid instruction type 
; "mov segreg, reg"  cannot be used, if the register is not AX.  
; For example:  mov  es, bx

movseg          macro reg16, unused, Imm16      ; Fixup for Assembler
                ifidn  <reg16>, <bx>            
                db     0BBh                     
                endif                           
                ifidn  <reg16>, <cx>            
                db     0B9h                     
                endif
                ifidn  <reg16>, <dx>
                db     0BAh
                endif
                ifidn  <reg16>, <si>
                db     0BEh
                endif
                ifidn  <reg16>, <di>
                db     0BFh
                endif
                ifidn  <reg16>, <bp>
                db     0BDh
                endif
                ifidn  <reg16>, <sp>
                db     0BCh
                endif
                ifidn  <reg16>, <BX>
                db     0BBH
                endif
                ifidn  <reg16>, <CX>
                db     0B9H
                endif
                ifidn  <reg16>, <DX>
                db     0BAH
                endif
                ifidn  <reg16>, <SI>
                db     0BEH
                endif
                ifidn  <reg16>, <DI>
                db     0BFH
                endif
                ifidn  <reg16>, <BP>
                db     0BDH
                endif
                ifidn  <reg16>, <SP>
                db     0BCH
                endif
                dw     seg Imm16
endm

ENDIF


IF (target EQ 'T3') or (target EQ 'T2')
;-----------------------------------------------------------------------------
; Some assemblers, like TASM, check each far call, to see if the subroutine is 
; in the same segment as the call.  If so, rather than produce the standard 
; five byte far call, they push cs, and call near.  For byte identical code, 
; this macro forces the standard far call.  

calls           macro   dummy1, dummy2, slocation
                db      9Ah                     ; forced call far instruction
                dw      offset slocation, seg slocation
endm

ENDIF



IFE (target EQ 'NO')
;-----------------------------------------------------------------------------
;  Some compilers and some assemblers will code a call that goes to a far
;  subroutine in the same segment as:
;
;               PUSH    CS
;               CALL    near
;
;  This saves one byte, and is slightly faster.  If the assembler you are
;  using (i.e. MASM, Optasm) does not do this automatically, the following
;  macros are used to code the same information.  In other words, the binary
;  file has "PUSH CS, CALL near", and Sourcer ensures the same instructions
;  are used!  (macro CALLF)
;

callf           macro   location
                push    cs
                call    near ptr location
endm

;  Some compilers generate an unnecessary DS override on the call instruction
;  when compacting the CALLF type function.  Macro CALLFX handles this case.

callfx          macro   location
                push    cs
                db      3Eh
                call    near ptr location
endm

ENDIF

