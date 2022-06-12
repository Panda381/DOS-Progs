COMMENT %

 Monitorovac¡ program pro p©eru¨en¡ kl vesnice INT09 

%
code	SEGMENT page
	ASSUME	cs:code,ds:code

	org	100h

start:
	jmp	init

adrkey	dd	0				; adresa driveru kl vesnice

key:						; program obsluhy kl vesnice
	push	bx
	push	ds
	push	cx
	push	di
	mov	bx,40h
	mov	ds,bx
	mov	bx,word ptr ds:[1ch]		; ukazatel bufferu znak–
	pushf
	call	dword ptr cs:[adrkey]		; vyvol n¡ p©eru¨en¡ kl vesnice
	cli
	push	ax
	cmp	bx,word ptr ds:[1ch]		; byl p©ijat znak ?
	jnz	key1				; byl p©ijat
keynul:	jmp	konec				; konec programu
key1:	mov	al,byte ptr ds:[17h]		; status
	call	pbyte
	mov	al,"/"
	call	pznak
	mov	ax,[bx]
	cmp	al,32
	jnz	key2
	inc	cs:[prerus]
	jmp	short key3
key2:	mov	cs:[prerus],0
key3:	call	pword
	mov	al,13
	call	pznak
	mov	al,10
	call	pznak
	jmp	konec

pword:	push	ax
	mov	al,ah
	call	pbyte
	pop	ax
pbyte:	push	ax
	mov	cl,4
	ror	al,cl
	call	phex
	pop	ax
phex:	and	al,15
	add	al,30h
	cmp	al,3ah
	jc	pznak
	add	al,7
pznak:	mov	dl,al
	mov	ah,6
	int	21h
	ret

konec:	mov	word ptr ds:[1ch],bx
	pop	ax
	pop	di
	pop	cx
	pop	ds
	pop	bx
	iret

init:   push	cs
	pop	ds
	mov	dx,offset text1
	mov	ah,9
	int	21h
	mov	ax,3509h		; p©e‡ten¡ vektoru p©eru¨en¡ 09h
	int	21h
	mov	word ptr [adrkey],bx	; nastaven¡ vektoru p©eru¨en¡ kl vesnice
   	mov	word ptr [adrkey+2],es
	mov	dx,offset key
	mov     ax,2509h
	int	21h			; nastaven¡ nov‚ adresy p©eru¨en¡
cyklus: cmp	cs:[prerus],2
	jnz	cyklus
	mov	dx,word ptr cs:[adrkey+2]
	mov	ds,dx
	mov	dx,word ptr cs:[adrkey]
	mov	ax,2509h
	int	21h
	mov	ah,4ch
	int	21h


prerus	db	0

text1	db	'Monitorovac¡ program p©eru¨en¡ kl vesnice INT09.'
	db	13,10,'P©eru¨en¡ programu je mo‘n‚ dvojnasobnym stiskem mezery.'
	db	13,10,'$'

code	ENDS

stack	SEGMENT	stack
	DW	256 DUP(?)		; z sobn¡k 256 slov
stack	ENDS

	END	start		; startovac¡ adresa
