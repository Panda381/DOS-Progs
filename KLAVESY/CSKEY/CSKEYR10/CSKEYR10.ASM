COMMENT %

 Driver pro obsluhu kl�vesnice s �esk�m fontem znak�

%
code	SEGMENT page
	ASSUME	cs:code,ds:code

	org	100h

start:
	jmp	init

adrkey	dd	0				; adresa driveru kl�vesnice
status	db	0
swtab	db	0
extab	dw	0

					; tabulka norm. �e�tiny
tab1	db	"1�"
	db	"2�"
	db	"3�"
	db	"4�"
	db	"5�"
	db	"6�"
	db	"7�"
	db	"8�"
	db	"9�"
	db	"0�"
	db	0

					; tabulka pro `
tab2	db	"+�"
	db	"=�"
	db	"q�"
	db	"Q�"
	db	"w�"
	db	"W�"
	db	"e�"
	db	"E�"
	db	"r�"
	db	"R�"
	db	"t�"
	db	"T�"
	db	"y�"
	db	"Y�"
	db	"u�"
	db	"U�"
	db	"i�"
	db	"I�"
	db	"o�"
	db	"O�"
	db	"p�"
	db	"P�"
	db	"a�"
	db	"A�"	
	db	"s�"
	db	"S�"
	db	"d�"
	db	"D�"
	db	"f�"
	db	"F�"
	db	"h�"
	db	"H�"
	db	"j�"
	db	"J�"
	db	"k�"
	db	"K�"
	db	"l�"
	db	"L�"
	db	"z�"
	db	"Z�"
	db	"c�"
	db	"C�"
	db	"n�"
	db	"N�"
	db	"m�"
	db	"M�"
	db	"<�"
	db	">�"
	db	0

					; tabulka pro ~
tab3	db	"+�"
	db	"=�"
	db	"q�"
	db	"Q�"
	db	"w�"
	db	"W�"
	db	"e�"
	db	"E�"
	db	"r�"
	db	"R�"
	db	"t�"
	db	"T�"
	db	"y�"
	db	"Y�"
	db	"u�"
	db	"U�"
	db	"i�"
	db	"I�"
	db	"o�"
	db	"O�"
	db	"p�"
	db	"P�"
	db	"a�"
	db	"A�"	
	db	"s�"
	db	"S�"
	db	"d�"
	db	"D�"
	db	"f�"
	db	"F�"
	db	"h�"
	db	"H�"
	db	"j�"
	db	"J�"
	db	"k�"
	db	"K�"
	db	"l�"
	db	"L�"
	db	"z�"
	db	"Z�"
	db	"c�"
	db	"C�"
	db	"n�"
	db	"N�"
	db	"m�"
	db	"M�"
	db	"<�"
	db	">�"
	db	0

tab4	db	"0",205
	db	"1",200
	db	"2",202
	db	"3",188
	db	"4",204
	db	"5",206
	db	"6",185
	db	"7",201
	db	"8",203
	db	"9",187
	db	2ch,186

	db	52h,196
	db	4fh,211
	db	50h,208
	db	51h,189
	db	4bh,199
	db	4ch,215
	db	4dh,182
	db	47h,214
	db	48h,210
	db	49h,183
	db	0


tab5	db	"0",196
	db	"1",192
	db	"2",193
	db	"3",217
	db	"4",195
	db	"5",197
	db	"6",180
	db	"7",218
	db	"8",194
	db	"9",191
	db	2ch,179

	db	52h,205
	db	4fh,212
	db	50h,207
	db	51h,190
	db	4bh,198
	db	4ch,216
	db	4dh,181
	db	47h,213
	db	48h,209
	db	49h,184
	db	0


key:						; program obsluhy kl�vesnice
	push	bx
	push	ds
	push	cx
	push	di
	mov	bx,40h
	mov	ds,bx
	mov	bx,word ptr ds:[1ch]		; ukazatel bufferu znak�
	pushf
	call	dword ptr cs:[adrkey]		; vyvol�n� p�eru�en� kl�vesnice
	cli
	push	ax
	mov	al,byte ptr ds:[17h]		; p�e�ten� statusu kl�vesnice
	mov	byte ptr cs:[status],al		; ulo�en� statusu
	mov	ax,[bx]				; p�e�ten� znaku z bufferu
	cmp	bx,word ptr ds:[1ch]		; byl p�ijat znak ?
	jnz	key1				; byl p�ijat
keynul:	jmp	konec				; konec programu
key1:	cmp	ah,0				; je to znak s ALT ?
	jnz	key5				; je ALT - konec
key10:	mov	cs:[extab],0			; zru�en� tabulky
	jmp	short keynul			; konec programu
key5:	cmp	ax,8300h
	jz	key11				; kl�vesa ALT- `/~
	cmp	al,27h				; je znak ` (carka) ?
	jnz	key2				; nen�
	mov	cs:[extab],offset tab2		; nastaven� tabulky 2
	jmp	short zrus			; zru�en� kl�vesy
key2:	cmp	al,60h				; je znak ~ (hacek) ?
	jnz	key3				; nen�
	mov	cs:[extab],offset tab3		; nastaven� tabulky 3
zrus:	mov	word ptr ds:[1ch],bx		; n�vrat ukazatele znak�
	jmp	konec				; konec programu
key11:	and	cs:[status],3
	mov	ax,0d27h
	jz	key12
	mov	ax,0d60h
key12:	mov	[bx],ax
	jmp	short key10
konec1:	jmp	konec
key3:	cmp	cs:[extab],0			; je roz���en� tabulka ?
	mov	di,word ptr cs:[extab]
	jnz	key4				; ano
	cmp	cs:[swtab],0			; je p�ep�na� tabulek ?
	jz	konec1				; tabulka IBM
	cmp	cs:[swtab],1
	jnz	key30
	cmp	ah,2
	jc	konec1
	cmp	ah,12
	jnc	konec1
	mov	di,offset tab1
	jmp	short key40
key30:	mov	di,offset tab4
	cmp	cs:[swtab],2
	jz	key33
	mov	di,offset tab5
key33:	cmp	ax,4e2bh
	jz	key40
	cmp	al,0f0h
	jz	key32
	cmp	al,0
	jnz     key31
key32:	mov	al,ah
	jmp	short key40
key31:	cmp	ah,13
	jc	konec
	cmp	al,30h
	jc	konec
	cmp	al,3ah
	jnc	konec
	jmp	short key40
key4:						; p�ek�dov�n� podle tabulky DI
	cmp	ax,0e08h
	jz	key43
	cmp	ax,53e0h
	jz	key43
	cmp	ax,0231h
	jnz	key41
	mov	cs:[swtab],0
	jmp	short key43
key41:	cmp	ax,0332h
	jnz	key42
	mov	cs:[swtab],1
key43:	mov	word ptr ds:[1ch],bx
	jmp	key6
key42:	cmp	ax,0433h
	jnz	key44
	mov	cs:[swtab],2
	jmp	short key43	
key44:	cmp	ax,0534h
	jnz	key40
	mov	cs:[swtab],3
	jmp	short key43
key40:
key7:	cmp	al,cs:[di]
	jz	key8
	inc	di
	inc	di
	cmp	byte ptr cs:[di],0
	jnz	key7
	jmp	short key6
key8:	inc	di
	mov	al,cs:[di]
	mov	ah,0
	mov	[bx],ax
key6:	mov	cs:[extab],0			; zru�en� p�echodn� tabulky

konec:	pop	ax
	pop	di
	pop	cx
	pop	ds
	pop	bx
	iret





init:   push	cs
	pop	ds
	mov	ax,3509h		; p�e�ten� vektoru p�eru�en� 09h
	int	21h
	cmp	bx,offset key		; obsluha kl�vesnice
	je	nainst			; hl��en�, �e je ji� nainstalov�n
	mov	word ptr [adrkey],bx	; nastaven� vektoru p�eru�en� kl�vesnice
   	mov	word ptr [adrkey+2],es
	mov	dx,offset key
	mov     ax,2509h
	int	21h			; nastaven� nov� adresy p�eru�en�
	mov	dx,offset text1			; uvodn� text
	mov	ah,9
	int	21h			; tisk �vodn�ho textu
	mov	dx,word ptr init	; konec programu
	int	27h			; ukon�en� programu jako rezidentn�

nainst:	mov	dx,offset text2		; hl��en�, �e je ji� nainstalov�n
	mov	ah,9
	int	21h
	mov	ah,4ch			; norm�ln� ukon�en� programu
	int	21h

text1	db	'Driver pro �eskou kl�vesnici ROBOTRON CM 1910 V 1.0 byl nainstalov�n.'
	db	13,10,'$'

text2	db	'Driver pro �eskou kl�vesnici je ji� nainstalov�n v pam�ti !'
	db	13,10,'$'

code	ENDS

stack	SEGMENT	stack
	DW	256 DUP(?)		; z�sobn�k 256 slov
stack	ENDS

	END	start		; startovac� adresa
