COMMENT %

 Driver pro obsluhu áeskÇ kl†vesnice - áeskÇ znaky jsou

%
code	SEGMENT page
	ASSUME	cs:code,ds:code

	org	100h

start:	jmp	init

	db	8,8,8,'Program pro obsluhu kl†vesnice - verze'
	db	' 1.0 pro TNS AT',13,10,'(C) JZD Slu®ovice - '
	db	'1986$'

ton:    				; spusteni tonu
	cmp	cx,15h
	jl	tonkon
	cmp	cx,4e20h
	jg	tonkon
	mov	ax,4f38h
	mov	dx,14h
	div	cx
	mov	dx,ax
	mov	ax,dx
	out	[42h],al
	mov	al,ah
	out	[42h],al
	in	al,[61h]
	or	al,3
	out	[61h],al
tonkon:	ret

tonoff:					; vypnuti tonu
	in	al,[61h]
	and	al,0fch
	out	[61h],al
	ret

prodl:					; casova prodleva pro ton
	xor	dx,dx
	mov	ax,bx
	mov	cx,83h
	mul	cx
	mov	cx,0ffffh
	div	cx
	inc	ax
	or	dx,dx
	jz	prod1
	mov	cx,dx
prod2:	loop	prod2
prod1:	dec	ax
	jnz	prod2
	ret

beep:					; pipnuti pri stisku klavesy
	push	ax
	push	bx
	push	cx
	push	dx
	mov	cx,0fa0h
	cmp	cs:[font1r],offset tab1r
	jz	beep1
	mov	cx,07d0h
	cmp	cs:[font1r],offset tab3r
	jz	beep1
	mov	cx,03e8h
beep1:	call	ton
	mov	bx,0ah
	call	prodl
	call	tonoff
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

chang:					; pipnuti pri zmene fontu
	push	ax
	push	bx
	push	cx
	push	dx
	mov	cx,960h
	cmp	cs:[font1r],offset tab1r
	jz	chang1
	mov     cx,4b0h
	cmp	cs:[font1r],offset tab3r
	jz	chang1
	mov	cx,258h
chang1:	call	ton
	mov	bx,50h
	call	prodl
	call	tonoff
	mov	cx,640h
	cmp	cs:[font1r],offset tab1r
        jz	chang2
	mov	cx,320h
	cmp	cs:[font1r],offset tab3r
	jz	chang2
	mov	cx,190h
chang2:	call	ton
	mov	bx,0a0h
	call	prodl
	call	tonoff
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret


error:					; pipnuti pri chybe
	push	ax
	push	bx
	push	cx
	push	dx
	mov	cx,0c80h
	cmp	cs:[font1r],offset tab2r
	jz	err1
	mov	cx,640h
err1:	call	ton
	mov	bx,12ch
	call	prodl
	call	tonoff
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

kurz:					; nakreslen° kurzorñ na obraz.
	push	ax
	push	cx
	push	di
	push	es
	mov	di,0b800h
	mov	es,di
	cld
	mov	cx,6
	mov	di,4b5h
	mov	al,10
	cmp	cs:[setton],0
	jz	kurz1
	mov	al,70h
kurz1:	stosb
	inc	di
        loop	kurz1
	mov	cx,12h
	mov	di,555h
	mov	al,10
	cmp	cs:[font1r],offset tab1r
	jnz	kurz2
	mov	al,70h
kurz2:	stosb
	inc	di
	loop	kurz2
	mov	cx,16h
	mov	di,5f5h
	mov	al,10
	cmp	cs:[font1r],offset tab3r
	jnz	kurz3
	mov	al,70h
kurz3:	stosb
	inc	di
	loop	kurz3
	mov	cx,13
	mov	di,695h
	mov	al,10
	cmp	cs:[font1r],offset tab2r
	jnz	kurz4
	mov	al,79h
kurz4:	stosb
	inc	di
	loop	kurz4
	mov	cx,13h
	mov	di,735h
	mov	al,10
	cmp	cs:[seterr],0
	jz	kurz5
	mov	al,70h
kurz5:	stosb
	inc	di
	loop	kurz5
	pop	es
	pop	di
	pop	cx
	pop	ax
	ret

font3r	dw	030dh
font3t	dw	036bh
font3l	dw	002fh

prep:					; prepnuti sady znaku
	push	ax
	mov	ax,cs:[font1r]
	mov	cs:[font3r],ax
	mov	ax,cs:[font1t]
	mov	cs:[font3t],ax
	mov	ax,cs:[font1l]
	mov	cs:[font3l],ax
	pop	ax
	ret


shift	db	0			; status kl†vesnice
setton	db	0			; p©°znak p°pnut° p©i stisku kl†v.
seterr	db	0ffh			; p©°znak p°pnut° p©i chybà
	dw	0
	dw	0

font1r	dw	offset tab1r		; adr. referenán° tab. norm†ln°
font1t	dw	offset tab1t		; adr. transformaán° tab. norm†ln°
font1l	dw	5			; dÇlka referenán° tabulky norm.

font2r	dw	0			; adr. referenán° tab. roz®°©enÇ
font2l	dw	0			; dÇlka referenán° tab. roz®°©enÇ
font2t	dw	0			; adr. transformaán° tab. roz®°©enÇ


tab1r	dw	2960h,297eh,2b5ch,2b7ch,0000h
tab1t	dw	2b5ch,2b7ch,2960h,297eh
tab2r	dw	2c7ah,2c5ah,2c1ah,2c00h,1579h,1559h,1519h,1500h
	dw	2960h,297eh,2b5ch,2b7ch,0231h,0332h,0433h,0534h
	dw	0636h,0736h,0837h,0938h,0a39h,0b30h,0c2dh,0221h
	dw	0340h,0423h,0524h,0625h,075eh,0826h,092ah,0a28h
	dw	0b29h,0c5fh,333ch,343eh,352fh,353fh,273bh,273ah
	dw	2827h,2822h,1a5bh,1a7bh,1b5dh,1b7dh,0000h
tab2t	dw	1579h,1559h,1519h,1500h,2c7ah,2c5ah,2c1ah,2c00h
	dw	2b5ch,2b7ch,2822h,273bh,022bh,0388h,04a8h,0587h
	dw	06a9h,0791h,0898h,09a0h,0aa1h,0b82h,0d3dh,0231h
	dw	0332h,0433h,0534h,0635h,0736h,0837h,0938h,0a39h
	dw	0b30h,0625h,353fh,273ah,0c2dh,0c5fh,2796h,2822h
	dw	28adh,0221h,1aa3h,352fh,0b29h,0a28h
tab3r	dw	2960h,297eh,2b5ch,2b7ch,0231h,0332h,0433h,0534h
	dw	0635h,0736h,0837h,0938h,0a39h,0b30h,0221h,0340h
	dw	0423h,0524h,0625h,075eh,0826h,092ah,0a28h,0b29h
	dw	0c2dh,0c5fh,7800h,7900h,7a00h,7b00h,7c00h,7d00h
	dw	0101h,0101h,0101h,0101h,0101h,0000h
tab3t	dw	0101h,0101h,2901h,297eh,022bh,0388h,04a8h,0587h
	dw	06a9h,0791h,0898h,09a0h,0aa1h,0b82h,0231h,0332h
	dw	0433h,0534h,0635h,0736h,0837h,0938h,0a39h,0b30h
	dw	0d3dh,0c2dh,0221h,0340h,0423h,0524h,0625h,075eh
	dw	0826h,092ah,0a28h,0b29h,0c5fh

tab4r	db	'AEILORUYaeiloruy†Ç°ò£',0
tab4t	db	'èêãäï´óù†Ç°ç¢™£ò†Ç°ò£'
tab5r	db	'CDELNORSTUZcdelnorstuzà®á©ëñ',0
tab5t	db	'ÄÖâú•ßûõÜ¶íáÉàå§ì©®üñëà®á©ëñ'
tab6r	db	'AOUaou',0
tab6t	db	'éôöÑîÅ'

sethlp	db	0			; p©°znak reëimu HELP


buffer	db	100 DUP(0)

adrinp	dw	0
adrin2	dw	0


zac:						; program obsluhy klavesnice

	jmp	dword ptr cs:[adrinp]

	pushf

	mov	cx,03e8h
	call	ton
	mov	bx,1000
	call	prodl
	call	tonoff
	cli
        iret

	push	bx
	push	ds
	mov	bx,40h
	mov	ds,bx
	mov	bx,[1ch]
	pushf
	call	dword ptr cs:[adrinp]
	cli
	push	ax
	mov	al,[17h]
	mov	cs:[shift],al			; status
	pop	ax
	cmp	bx,[1ch]
	jz	neznak
	jmp	jeznak
neznak:	and	cs:[shift],0fh
	cmp	cs:[shift],9
	jz	zac1
	jmp	short konec
zac1:	cmp	cs:[font1r],offset tab2r
	call    chang
	jmp	short konec1

jeznak: call	beep

konec1:
konec:	pop	ds
	pop	bx
	iret






init:   mov	ax,code 		; ulozeni adresy segmentu
	mov	ds,ax			;  do registru DS
	mov	ax,3509h		; p©eáten° vektoru p©eru®en° 9
	int	21h
	cmp	bx,offset zac
	jz	nainst
	mov	[adrinp],bx		; nastaven° vektoru p©eru®en° kl†vesnic°
   	mov	[adrin2],es
	mov	dx,offset zac
	mov     ax,2509h
	int	21h			; nastaven° novÇ adresy p©eru®en°
	mov	dx,offset text			; uvodn° text
	mov	ah,9
	int	21h			; tisk £vodn°ho textu
	mov	dx,word ptr init-start + 200h	; dÇlka programu
	int	27h			; ukonáen° programu jako rezidentn°

nainst:	mov	dx,offset text2
	mov	ah,9
	int	21
	int	20


text	db	'Driver pro áeskou kl†vesnici byl nainstalov†n.'
	db	13,10,'$'

text2	db	'Driver je jiz  nainstalovan v pameti !',13,10,'$'


code	ENDS

stack	SEGMENT	stack
	DW	128 DUP(?)		; z†sobn°k 128 slov
stack	ENDS


	END	start		; startovac° adresa
